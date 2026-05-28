extends Node

const SILENCE_DB := -80.0
const FADE_SECONDS := 0.65

const VOICE_TRACKS := {
	"morning": [
		"res://assets/audio/ambient/voices/morning_voices_01.ogg"
	],
	"day": [
		"res://assets/audio/ambient/voices/day_voices_01.ogg"
	],
	"evening": [
		"res://assets/audio/ambient/voices/evening_voices_01.ogg"
	],
	"night": [
		"res://assets/audio/ambient/voices/night_voices_01.ogg",
		"res://assets/audio/ambient/voices/night_voices_02.ogg"
	]
}

const PERIOD_DELAYS := {
	"morning": Vector2(25.0, 65.0),
	"day": Vector2(30.0, 85.0),
	"evening": Vector2(30.0, 75.0),
	"night": Vector2(45.0, 110.0)
}

const PERIOD_VOLUMES := {
	"morning": 0.30,
	"day": 0.25,
	"evening": 0.28,
	"night": 0.24
}

var main
var _time_manager: Node
var _player: AudioStreamPlayer
var _fade_tween: Tween
var _rng := RandomNumberGenerator.new()
var _current_period := ""
var _last_track_path := ""
var _next_voice_delay := 0.0
var _time_manager_warning_reported := false


func _ready() -> void:
	_rng.randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)


func setup(main_ref) -> void:
	main = main_ref
	_ensure_player()
	_connect_time_manager()
	_switch_period(_get_current_period_key(), true)


func _process(delta: float) -> void:
	_connect_time_manager()
	if _current_period == "":
		_switch_period(_get_current_period_key(), true)
		return

	if _player != null and _player.playing:
		return

	_next_voice_delay -= delta
	if _next_voice_delay <= 0.0:
		_play_random_voice_for_period(_current_period)


func _ensure_player() -> void:
	if _player != null:
		return

	_player = AudioStreamPlayer.new()
	_player.name = "AmbientVoicesPlayer"
	_player.bus = _get_audio_bus_name("Ambience")
	_player.volume_db = SILENCE_DB
	add_child(_player)
	_player.finished.connect(_on_voice_finished)


func _connect_time_manager() -> void:
	if _time_manager != null:
		return

	_time_manager = get_node_or_null("/root/TimeManager")
	if _time_manager == null:
		if not _time_manager_warning_reported:
			_time_manager_warning_reported = true
			push_warning("Ambient voices need TimeManager to follow time of day.")
		return

	if _time_manager.has_signal("period_changed"):
		var callback := Callable(self, "_on_period_changed")
		if not _time_manager.period_changed.is_connected(callback):
			_time_manager.period_changed.connect(callback)


func _on_period_changed(time_of_day: String) -> void:
	_switch_period(_normalize_period_key(time_of_day), false)


func _switch_period(period_key: String, initial: bool) -> void:
	var normalized_period := _normalize_period_key(period_key)
	if normalized_period == _current_period and not initial:
		return

	_current_period = normalized_period
	_stop_current_voice()
	_schedule_next_voice(initial)


func _schedule_next_voice(initial: bool = false) -> void:
	var delay_range: Vector2 = PERIOD_DELAYS.get(_current_period, Vector2(45.0, 100.0))
	if initial:
		_next_voice_delay = _rng.randf_range(4.0, 16.0)
	else:
		_next_voice_delay = _rng.randf_range(delay_range.x, delay_range.y)


func _play_random_voice_for_period(period_key: String) -> void:
	_ensure_player()
	var tracks: Array = VOICE_TRACKS.get(period_key, [])
	if tracks.is_empty():
		_schedule_next_voice(false)
		return

	var path := _pick_track(tracks)
	var stream := _load_audio_stream(path)
	if stream == null:
		push_warning("Ambient voice audio is missing: %s" % path)
		_schedule_next_voice(false)
		return

	_last_track_path = path
	_set_stream_loop(stream, false)
	_player.stop()
	_player.stream = stream
	_player.volume_db = SILENCE_DB
	_player.play()
	_fade_to(_get_target_db(float(PERIOD_VOLUMES.get(period_key, 0.26))), FADE_SECONDS)


func _pick_track(tracks: Array) -> String:
	if tracks.size() == 1:
		return str(tracks[0])

	var path := str(tracks[_rng.randi_range(0, tracks.size() - 1)])
	if path == _last_track_path:
		var index := tracks.find(path)
		path = str(tracks[(index + 1) % tracks.size()])
	return path


func _stop_current_voice() -> void:
	if _player == null or not _player.playing:
		return

	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()

	var tween := create_tween()
	tween.tween_property(_player, "volume_db", SILENCE_DB, FADE_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "_clear_voice_after_fade"))
	_fade_tween = tween


func _clear_voice_after_fade() -> void:
	if _player != null:
		_player.stop()
		_player.stream = null


func _on_voice_finished() -> void:
	_schedule_next_voice(false)


func _fade_to(target_db: float, duration: float) -> void:
	if _player == null:
		return

	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()

	var tween := create_tween()
	tween.tween_property(_player, "volume_db", target_db, maxf(duration, 0.01)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_fade_tween = tween


func _get_current_period_key() -> String:
	_connect_time_manager()
	if _time_manager != null:
		return _normalize_period_key(str(_time_manager.get("time_of_day")))
	return "morning"


func _normalize_period_key(period_key: String) -> String:
	var normalized := period_key.strip_edges().to_lower()
	match normalized:
		"morning", "утро", "СѓС‚СЂРѕ":
			return "morning"
		"day", "день", "РґРµРЅСЊ":
			return "day"
		"evening", "вечер", "РІРµС‡РµСЂ":
			return "evening"
		"night", "ночь", "РЅРѕС‡СЊ":
			return "night"
	return "morning"


func _get_target_db(effect_volume: float) -> float:
	var master := 1.0
	var ambience := 0.72
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null and audio_manager.has_method("get_volume_settings"):
		var settings = audio_manager.call("get_volume_settings")
		if settings is Dictionary:
			master = float((settings as Dictionary).get("master_volume", master))
			ambience = float((settings as Dictionary).get("ambient_volume", ambience))
	return _volume_to_db(master * ambience * effect_volume)


func _load_audio_stream(path: String) -> AudioStream:
	if path.get_extension().to_lower() == "ogg":
		var ogg_stream := AudioStreamOggVorbis.load_from_file(path)
		if ogg_stream != null:
			return ogg_stream
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	return null


func _set_stream_loop(stream: AudioStream, enabled: bool) -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = enabled
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = enabled


func _get_audio_bus_name(preferred_bus: String, fallback_bus: String = "Master") -> String:
	if AudioServer.get_bus_index(preferred_bus) >= 0:
		return preferred_bus
	if AudioServer.get_bus_index(fallback_bus) >= 0:
		return fallback_bus
	return "Master"


func _volume_to_db(value: float) -> float:
	var volume := clampf(value, 0.0, 1.0)
	if volume <= 0.001:
		return SILENCE_DB
	return linear_to_db(volume)
