extends Node

const WATER_AMBIENT_PATH := "res://assets/audio/ambient/water_ambient_loop_01.ogg"
const SFX_CAST := "cast"
const SFX_BITE := "bite"
const SFX_CATCH_SUCCESS := "catch_success"
const SFX_TROPHY_CATCH := "trophy_catch"
const SFX_RARE_TROPHY_CATCH := "rare_trophy_catch"
const SFX_LINE_BREAK := "line_break"
const MUSIC_SILENCE_DB := -80.0
const AUDIO_SETTINGS_VERSION := 2
const DEFAULT_MASTER_VOLUME := 1.0
const DEFAULT_AMBIENT_VOLUME := 0.36
const DEFAULT_SFX_VOLUME := 0.38
const DEFAULT_MUSIC_VOLUME := 0.28
const LEGACY_DEFAULT_AMBIENT_VOLUME := 0.72
const LEGACY_DEFAULT_SFX_VOLUME := 0.75
const LEGACY_DEFAULT_MUSIC_VOLUME := 0.55

const SFX_PATHS := {
	"cast": "res://assets/audio/sfx/bite_soft_01.ogg",
	"bite": "res://assets/audio/sfx/cast_start_01.ogg",
	"catch_success": "res://assets/audio/sfx/catch_success_01.mp3",
	"trophy_catch": "res://assets/audio/sfx/trophy_catch.ogg",
	"rare_trophy_catch": "res://assets/audio/sfx/rare_trophy.ogg",
	"line_break": "res://assets/audio/sfx/line_break_01.ogg"
}

const SFX_PLAYER_NAMES := {
	"cast": "SfxPlayerCast",
	"bite": "SfxPlayerBite",
	"catch_success": "SfxPlayerCatch",
	"trophy_catch": "SfxPlayerTrophyCatch",
	"rare_trophy_catch": "SfxPlayerRareTrophyCatch",
	"line_break": "SfxPlayerLineBreak"
}

const MUSIC_TRACKS := {
	"morning": [
		"res://assets/audio/music/morning/morning_01.ogg",
		"res://assets/audio/music/morning/morning_02.ogg",
		"res://assets/audio/music/morning/morning_03.ogg"
	],
	"day": [
		"res://assets/audio/music/day/day_01.ogg",
		"res://assets/audio/music/day/day_02.ogg",
		"res://assets/audio/music/day/day_03.ogg"
	],
	"evening": [
		"res://assets/audio/music/evening/evening_01.ogg",
		"res://assets/audio/music/evening/evening_02.ogg",
		"res://assets/audio/music/evening/evening_03.ogg"
	],
	"night": [
		"res://assets/audio/music/night/night_01.ogg",
		"res://assets/audio/music/night/night_02.ogg",
		"res://assets/audio/music/night/night_03.ogg"
	]
}

const PERIOD_KEY_ALIASES := {
	"morning": "morning",
	"утро": "morning",
	"day": "day",
	"день": "day",
	"evening": "evening",
	"вечер": "evening",
	"night": "night",
	"ночь": "night"
}

var master_volume: float = DEFAULT_MASTER_VOLUME:
	set(value):
		master_volume = clampf(value, 0.0, 1.0)
		_apply_volumes()

var ambient_volume: float = DEFAULT_AMBIENT_VOLUME:
	set(value):
		ambient_volume = clampf(value, 0.0, 1.0)
		_apply_volumes()

var sfx_volume: float = DEFAULT_SFX_VOLUME:
	set(value):
		sfx_volume = clampf(value, 0.0, 1.0)
		_apply_volumes()

var music_volume: float = DEFAULT_MUSIC_VOLUME:
	set(value):
		music_volume = clampf(value, 0.0, 1.0)
		_apply_music_volume()

var music_source: String = "game"
var music_fade_duration: float = 3.0
var period_crossfade_duration: float = 6.0

var _ambient_player: AudioStreamPlayer
var _ambient_path := ""
var _sfx_players: Dictionary = {}
var _sfx_streams: Dictionary = {}
var _music_player_a: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer
var _active_music_player: AudioStreamPlayer
var _current_music_period := ""
var _current_music_path := ""
var _last_music_path_by_period: Dictionary = {}
var _music_streams: Dictionary = {}
var _music_tween: Tween
var _music_switch_generation := 0
var _music_rng := RandomNumberGenerator.new()
var _time_manager: Node
var _missing_sfx_reported: Dictionary = {}
var _missing_ambient_reported: Dictionary = {}
var _missing_music_reported: Dictionary = {}
var _empty_music_period_reported: Dictionary = {}
var _unknown_period_reported: Dictionary = {}
var _time_manager_warning_reported := false
var _time_signal_warning_reported := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music_rng.randomize()
	_ensure_players()
	_apply_volumes()
	_connect_time_manager()
	start_music_for_current_period()

func play_water_ambient_loop() -> void:
	play_ambient_loop(WATER_AMBIENT_PATH)

func play_ambient_loop(path: String) -> void:
	_ensure_players()

	if path == "":
		return
	if _ambient_player.stream == null or _ambient_path != path:
		var stream := _load_audio_stream(path)
		if stream == null:
			_report_missing_ambient(path)
			return
		_set_stream_loop(stream, true)
		_ambient_player.stream = stream
		_ambient_path = path

	if not _ambient_player.playing:
		_ambient_player.play()

func stop_ambient() -> void:
	if _ambient_player != null:
		_ambient_player.stop()

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_volumes()

func set_ambient_volume(value: float) -> void:
	ambient_volume = clampf(value, 0.0, 1.0)
	_apply_volumes()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_apply_volumes()

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_music_volume()

func get_music_volume() -> float:
	return music_volume

func set_music_source(source: String) -> void:
	var normalized := source.strip_edges().to_lower()
	if not ["game", "radio"].has(normalized):
		normalized = "game"
	if music_source == normalized:
		return
	music_source = normalized
	if music_source == "game":
		start_music_for_current_period()
	else:
		stop_music(0.8)

func get_music_source() -> String:
	return music_source

func set_volume_settings(settings: Dictionary) -> void:
	var settings_version := int(settings.get("settings_version", 0))
	var migrate_legacy_defaults := settings_version < AUDIO_SETTINGS_VERSION
	if settings.has("master_volume"):
		master_volume = clampf(float(settings["master_volume"]), 0.0, 1.0)
	if settings.has("ambient_volume"):
		ambient_volume = clampf(float(settings["ambient_volume"]), 0.0, 1.0)
	if settings.has("sfx_volume"):
		sfx_volume = clampf(float(settings["sfx_volume"]), 0.0, 1.0)
	if settings.has("music_volume"):
		music_volume = clampf(float(settings["music_volume"]), 0.0, 1.0)
	if migrate_legacy_defaults:
		if _approximately_equal(ambient_volume, LEGACY_DEFAULT_AMBIENT_VOLUME):
			ambient_volume = DEFAULT_AMBIENT_VOLUME
		if _approximately_equal(sfx_volume, LEGACY_DEFAULT_SFX_VOLUME):
			sfx_volume = DEFAULT_SFX_VOLUME
		if _approximately_equal(music_volume, LEGACY_DEFAULT_MUSIC_VOLUME):
			music_volume = DEFAULT_MUSIC_VOLUME
	if settings.has("music_source"):
		music_source = str(settings["music_source"]).strip_edges().to_lower()
		if not ["game", "radio"].has(music_source):
			music_source = "game"
	_apply_volumes()
	if music_source == "game":
		start_music_for_current_period()
	else:
		stop_music(0.0)

func get_volume_settings() -> Dictionary:
	return {
		"settings_version": AUDIO_SETTINGS_VERSION,
		"master_volume": master_volume,
		"ambient_volume": ambient_volume,
		"sfx_volume": sfx_volume,
		"music_volume": music_volume,
		"music_source": music_source
	}

func _approximately_equal(a: float, b: float) -> bool:
	return absf(a - b) <= 0.001

func play_splash() -> void:
	play_cast()

func play_cast() -> void:
	play_sfx(SFX_CAST)

func play_bite() -> void:
	play_sfx(SFX_BITE)

func play_catch() -> void:
	play_catch_success()

func play_catch_success() -> void:
	play_sfx(SFX_CATCH_SUCCESS)

func play_trophy_catch() -> void:
	play_sfx(SFX_TROPHY_CATCH)

func play_rare_trophy_catch() -> void:
	play_sfx(SFX_RARE_TROPHY_CATCH)

func play_line_break() -> void:
	play_sfx(SFX_LINE_BREAK)

func play_sfx(sfx_name: String) -> void:
	_ensure_players()

	var normalized_name := _normalize_sfx_name(sfx_name)
	var stream := _get_sfx_stream(normalized_name)
	if stream == null:
		return

	var player := _get_sfx_player(normalized_name)
	if player == null:
		return

	player.stop()
	player.stream = stream
	player.volume_db = _volume_to_db(master_volume * sfx_volume)
	player.play()

func start_music_for_current_period() -> void:
	if music_source != "game":
		return
	play_music_for_period(_get_current_period_key(), music_fade_duration)

func play_music_for_period(period_key: String, fade_duration: float = -1.0) -> void:
	if music_source != "game":
		return
	var normalized_period := _get_period_key(period_key)
	if normalized_period == "":
		_report_unknown_period(period_key)
		return

	var resolved_fade_duration := fade_duration
	if resolved_fade_duration < 0.0:
		resolved_fade_duration = music_fade_duration

	if _current_music_period == normalized_period and _active_music_player != null and _active_music_player.playing:
		_apply_music_volume()
		return

	play_random_track_for_period(normalized_period, resolved_fade_duration)

func play_random_track_for_period(period_key: String, fade_duration: float) -> void:
	if music_source != "game":
		return
	_ensure_players()

	var normalized_period := _get_period_key(period_key)
	if normalized_period == "":
		_report_unknown_period(period_key)
		return

	var track_path := _pick_random_track(normalized_period)
	if track_path == "":
		_report_empty_music_period(normalized_period)
		return

	_current_music_period = normalized_period
	_last_music_path_by_period[normalized_period] = track_path
	crossfade_to_music(track_path, fade_duration)

func crossfade_to_music(path: String, fade_duration: float) -> void:
	_ensure_players()

	if path == "":
		return

	var stream := _get_music_stream(path)
	if stream == null:
		return

	if _active_music_player != null and _current_music_path == path and _active_music_player.playing:
		_apply_music_volume()
		return

	var new_player := _get_next_music_player()
	if new_player == null:
		return

	_music_switch_generation += 1
	var generation := _music_switch_generation

	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
		_music_tween = null

	var old_players := _get_music_players_to_fade_out(new_player)
	new_player.stop()
	new_player.stream = stream
	_set_stream_loop(stream, false)
	new_player.bus = _get_audio_bus_name("Music")
	new_player.volume_db = MUSIC_SILENCE_DB
	new_player.play()

	_active_music_player = new_player
	_current_music_path = path

	var duration := maxf(fade_duration, 0.0)
	if duration <= 0.0:
		new_player.volume_db = _music_target_db()
		_finish_music_transition(old_players, generation)
		return

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(new_player, "volume_db", _music_target_db(), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for old_player in old_players:
		if old_player != null:
			tween.tween_property(old_player, "volume_db", MUSIC_SILENCE_DB, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_callback(Callable(self, "_finish_music_transition").bind(old_players, generation))
	_music_tween = tween

func stop_music(fade_duration: float = 2.0) -> void:
	_ensure_players()

	_music_switch_generation += 1
	var generation := _music_switch_generation

	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
		_music_tween = null

	var old_players := _get_music_players()
	_active_music_player = null
	_current_music_period = ""
	_current_music_path = ""

	var duration := maxf(fade_duration, 0.0)
	if duration <= 0.0:
		_finish_music_transition(old_players, generation)
		return

	var has_playing_player := false
	for old_player in old_players:
		if old_player != null and old_player.playing:
			has_playing_player = true
			break
	if not has_playing_player:
		_finish_music_transition(old_players, generation)
		return

	var tween := create_tween()
	tween.set_parallel(true)
	for old_player in old_players:
		if old_player != null and old_player.playing:
			tween.tween_property(old_player, "volume_db", MUSIC_SILENCE_DB, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_callback(Callable(self, "_finish_music_transition").bind(old_players, generation))
	_music_tween = tween

func _ensure_players() -> void:
	if _ambient_player == null:
		_ambient_player = AudioStreamPlayer.new()
		_ambient_player.name = "AmbientPlayer"
		add_child(_ambient_player)
	_ambient_player.bus = _get_audio_bus_name("Ambience")

	for sfx_name in SFX_PLAYER_NAMES.keys():
		var player: AudioStreamPlayer
		if _sfx_players.has(sfx_name):
			player = _sfx_players[sfx_name] as AudioStreamPlayer
		else:
			player = AudioStreamPlayer.new()
			player.name = str(SFX_PLAYER_NAMES[sfx_name])
			add_child(player)
			_sfx_players[sfx_name] = player
		player.bus = _get_audio_bus_name("SFX")

	if _music_player_a == null:
		_music_player_a = _create_music_player("MusicPlayerA")
	if _music_player_b == null:
		_music_player_b = _create_music_player("MusicPlayerB")

func _create_music_player(player_name: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.bus = _get_audio_bus_name("Music")
	player.volume_db = MUSIC_SILENCE_DB
	add_child(player)

	var finished_callable := Callable(self, "_on_music_finished").bind(player)
	if not player.is_connected("finished", finished_callable):
		player.connect("finished", finished_callable)

	return player

func _connect_time_manager() -> void:
	_time_manager = get_node_or_null("/root/TimeManager")
	if _time_manager == null:
		_report_time_manager_missing()
		return

	if not _time_manager.has_signal("period_changed"):
		_report_time_signal_missing()
		return

	var period_callable := Callable(self, "_on_period_changed")
	if not _time_manager.is_connected("period_changed", period_callable):
		_time_manager.connect("period_changed", period_callable)

func _on_period_changed(time_of_day: String) -> void:
	var period_key := _get_period_key(time_of_day)
	if period_key == "":
		_report_unknown_period(time_of_day)
		return

	if period_key == _current_music_period and _active_music_player != null and _active_music_player.playing:
		return

	play_music_for_period(period_key, period_crossfade_duration)

func _on_music_finished(player: AudioStreamPlayer = null) -> void:
	if player != null and player != _active_music_player:
		return

	var period_key := _current_music_period
	if period_key == "":
		period_key = _get_current_period_key()

	play_random_track_for_period(period_key, music_fade_duration)

func _get_period_key(time_of_day) -> String:
	var normalized := str(time_of_day).strip_edges().to_lower()
	if PERIOD_KEY_ALIASES.has(normalized):
		return str(PERIOD_KEY_ALIASES[normalized])
	return ""

func _get_current_period_key() -> String:
	if _time_manager == null:
		_time_manager = get_node_or_null("/root/TimeManager")

	if _time_manager != null:
		var current_time_of_day = _time_manager.get("time_of_day")
		var direct_period := _get_period_key(current_time_of_day)
		if direct_period != "":
			return direct_period

		if _time_manager.has_method("get_time_state"):
			var time_state = _time_manager.call("get_time_state")
			if time_state is Dictionary:
				var state_dict := time_state as Dictionary
				if state_dict.has("time_of_day"):
					var state_period := _get_period_key(state_dict["time_of_day"])
					if state_period != "":
						return state_period

		_report_unknown_period(current_time_of_day)
	else:
		_report_time_manager_missing()

	return "morning"

func _get_available_tracks(period_key: String) -> Array:
	var normalized_period := _get_period_key(period_key)
	if normalized_period == "" or not MUSIC_TRACKS.has(normalized_period):
		return []

	var available_tracks: Array = []
	var tracks := MUSIC_TRACKS[normalized_period] as Array
	for track_path in tracks:
		var path := str(track_path)
		if path == "":
			continue
		if _get_music_stream(path) != null:
			available_tracks.append(path)

	return available_tracks

func _pick_random_track(period_key: String) -> String:
	var available_tracks := _get_available_tracks(period_key)
	if available_tracks.is_empty():
		return ""

	var candidates := available_tracks.duplicate()
	var last_path := str(_last_music_path_by_period.get(period_key, ""))
	if candidates.size() > 1 and last_path != "":
		candidates.erase(last_path)

	var track_index := _music_rng.randi_range(0, candidates.size() - 1)
	return str(candidates[track_index])

func _apply_volumes() -> void:
	if _ambient_player != null:
		_ambient_player.volume_db = _volume_to_db(master_volume * ambient_volume)

	for player in _sfx_players.values():
		(player as AudioStreamPlayer).volume_db = _volume_to_db(master_volume * sfx_volume)

	_apply_music_volume()

func _apply_music_volume() -> void:
	if _active_music_player != null and _active_music_player.playing:
		_active_music_player.volume_db = _music_target_db()

	if _music_tween != null and _music_tween.is_valid():
		return

	for player in _get_music_players():
		if player == null:
			continue
		if player == _active_music_player and player.playing:
			player.volume_db = _music_target_db()
		else:
			player.volume_db = MUSIC_SILENCE_DB

func _normalize_sfx_name(sfx_name: String) -> String:
	match sfx_name:
		"splash":
			return SFX_CAST
		"catch":
			return SFX_CATCH_SUCCESS
		"trophy":
			return SFX_TROPHY_CATCH
		"rarity", "rare_trophy":
			return SFX_RARE_TROPHY_CATCH
		_:
			return sfx_name

func _get_sfx_stream(sfx_name: String) -> AudioStream:
	if not SFX_PATHS.has(sfx_name):
		push_warning("Unknown SFX: %s" % sfx_name)
		return null

	if _sfx_streams.has(sfx_name):
		return _sfx_streams[sfx_name] as AudioStream

	var path := str(SFX_PATHS[sfx_name])
	var stream := _load_audio_stream(path)
	if stream == null:
		_report_missing_sfx(sfx_name, path)
		return null

	_set_stream_loop(stream, false)
	_sfx_streams[sfx_name] = stream
	return stream

func _get_sfx_player(sfx_name: String) -> AudioStreamPlayer:
	if not _sfx_players.has(sfx_name):
		return null
	return _sfx_players[sfx_name] as AudioStreamPlayer

func _get_music_stream(path: String) -> AudioStream:
	if _music_streams.has(path):
		return _music_streams[path] as AudioStream

	var stream := _load_audio_stream(path)
	if stream == null:
		_report_missing_music(path)
		return null

	_set_stream_loop(stream, false)
	_music_streams[path] = stream
	return stream

func _get_music_players() -> Array:
	var players: Array = []
	if _music_player_a != null:
		players.append(_music_player_a)
	if _music_player_b != null:
		players.append(_music_player_b)
	return players

func _get_next_music_player() -> AudioStreamPlayer:
	if _music_player_a == null or _music_player_b == null:
		return null
	if _active_music_player == _music_player_a:
		return _music_player_b
	return _music_player_a

func _get_music_players_to_fade_out(new_player: AudioStreamPlayer) -> Array:
	var old_players: Array = []
	for player in _get_music_players():
		if player != null and player != new_player and player.playing:
			old_players.append(player)
	return old_players

func _finish_music_transition(old_players: Array, generation: int) -> void:
	if generation != _music_switch_generation:
		return

	for old_player in old_players:
		if old_player != null and old_player != _active_music_player:
			old_player.stop()
			old_player.volume_db = MUSIC_SILENCE_DB

	if _active_music_player != null and _active_music_player.playing:
		_active_music_player.volume_db = _music_target_db()

	_music_tween = null

func _music_target_db() -> float:
	return _volume_to_db(master_volume * music_volume)

func _get_audio_bus_name(preferred_bus: String, fallback_bus: String = "Master") -> String:
	if AudioServer.get_bus_index(preferred_bus) >= 0:
		return preferred_bus
	if AudioServer.get_bus_index(fallback_bus) >= 0:
		return fallback_bus
	return "Master"

func _volume_to_db(value: float) -> float:
	var volume := clampf(value, 0.0, 1.0)
	if volume <= 0.001:
		return MUSIC_SILENCE_DB
	return linear_to_db(volume)

func _load_audio_stream(path: String) -> AudioStream:
	match path.get_extension().to_lower():
		"ogg":
			var ogg_stream := AudioStreamOggVorbis.load_from_file(path)
			if ogg_stream != null:
				return ogg_stream
		"mp3":
			var mp3_stream := AudioStreamMP3.load_from_file(path)
			if mp3_stream != null:
				return mp3_stream

	if ResourceLoader.exists(path):
		return load(path) as AudioStream

	return null

func _set_stream_loop(stream: AudioStream, enabled: bool) -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = enabled
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = enabled

func _report_missing_ambient(path: String) -> void:
	if _missing_ambient_reported.has(path):
		return
	_missing_ambient_reported[path] = true
	push_warning("Ambient audio is missing: %s" % path)

func _report_missing_sfx(sfx_name: String, path: String) -> void:
	if _missing_sfx_reported.has(sfx_name):
		return
	_missing_sfx_reported[sfx_name] = true
	push_warning("SFX audio is missing: %s (%s)" % [sfx_name, path])

func _report_missing_music(path: String) -> void:
	if _missing_music_reported.has(path):
		return
	_missing_music_reported[path] = true
	push_warning("Music audio is missing: %s" % path)

func _report_empty_music_period(period_key: String) -> void:
	if _empty_music_period_reported.has(period_key):
		return
	_empty_music_period_reported[period_key] = true
	push_warning("No available music tracks for period: %s" % period_key)

func _report_unknown_period(time_of_day) -> void:
	var key := str(time_of_day)
	if _unknown_period_reported.has(key):
		return
	_unknown_period_reported[key] = true
	push_warning("Unsupported time of day for music: %s" % key)

func _report_time_manager_missing() -> void:
	if _time_manager_warning_reported:
		return
	_time_manager_warning_reported = true
	push_warning("TimeManager not found. Starting fallback morning music.")

func _report_time_signal_missing() -> void:
	if _time_signal_warning_reported:
		return
	_time_signal_warning_reported = true
	push_warning("TimeManager.period_changed signal is missing. Music will use the startup period only.")
