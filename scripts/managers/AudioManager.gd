extends Node

const WATER_AMBIENT_PATH := "res://assets/audio/ambient/water_ambient_loop_01.ogg"
const SFX_CAST := "cast"
const SFX_BITE := "bite"
const SFX_CATCH_SUCCESS := "catch_success"
const SFX_LINE_BREAK := "line_break"

const SFX_PATHS := {
	"cast": "res://assets/audio/sfx/bite_soft_01.ogg",
	"bite": "res://assets/audio/sfx/cast_start_01.ogg",
	"catch_success": "res://assets/audio/sfx/catch_success_01.mp3",
	"line_break": "res://assets/audio/sfx/line_break_01.ogg"
}

const SFX_PLAYER_NAMES := {
	"cast": "SfxPlayerCast",
	"bite": "SfxPlayerBite",
	"catch_success": "SfxPlayerCatch",
	"line_break": "SfxPlayerLineBreak"
}

var master_volume: float = 1.0:
	set(value):
		master_volume = clampf(value, 0.0, 1.0)
		_apply_volumes()

var ambient_volume: float = 0.72:
	set(value):
		ambient_volume = clampf(value, 0.0, 1.0)
		_apply_volumes()

var sfx_volume: float = 0.75:
	set(value):
		sfx_volume = clampf(value, 0.0, 1.0)
		_apply_volumes()

var _ambient_player: AudioStreamPlayer
var _ambient_path := ""
var _sfx_players: Dictionary = {}
var _sfx_streams: Dictionary = {}
var _missing_sfx_reported: Dictionary = {}
var _missing_ambient_reported: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_players()
	_apply_volumes()

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

func set_volume_settings(settings: Dictionary) -> void:
	if settings.has("master_volume"):
		master_volume = clampf(float(settings["master_volume"]), 0.0, 1.0)
	if settings.has("ambient_volume"):
		ambient_volume = clampf(float(settings["ambient_volume"]), 0.0, 1.0)
	if settings.has("sfx_volume"):
		sfx_volume = clampf(float(settings["sfx_volume"]), 0.0, 1.0)
	_apply_volumes()

func get_volume_settings() -> Dictionary:
	return {
		"master_volume": master_volume,
		"ambient_volume": ambient_volume,
		"sfx_volume": sfx_volume
	}

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

func _ensure_players() -> void:
	if _ambient_player == null:
		_ambient_player = AudioStreamPlayer.new()
		_ambient_player.name = "AmbientPlayer"
		_ambient_player.bus = "Master"
		add_child(_ambient_player)

	for sfx_name in SFX_PLAYER_NAMES.keys():
		if _sfx_players.has(sfx_name):
			continue

		var player := AudioStreamPlayer.new()
		player.name = str(SFX_PLAYER_NAMES[sfx_name])
		player.bus = "Master"
		add_child(player)
		_sfx_players[sfx_name] = player

func _normalize_sfx_name(sfx_name: String) -> String:
	match sfx_name:
		"splash":
			return SFX_CAST
		"catch":
			return SFX_CATCH_SUCCESS
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

func _apply_volumes() -> void:
	if _ambient_player != null:
		_ambient_player.volume_db = _volume_to_db(master_volume * ambient_volume)

	for player in _sfx_players.values():
		(player as AudioStreamPlayer).volume_db = _volume_to_db(master_volume * sfx_volume)

func _volume_to_db(value: float) -> float:
	var volume := clampf(value, 0.0, 1.0)
	if volume <= 0.001:
		return -80.0
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
