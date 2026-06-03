extends Node

signal radio_state_changed(enabled: bool)
signal broadcast_state_changed(active: bool, status_text: String)
signal radio_message_started(message_type: String, message_text: String)
signal radio_message_finished()

const WeatherUIHelperScript := preload("res://scripts/ui/helpers/WeatherUIHelper.gd")

const STATION_TUMAN_FM := "tuman_fm"
const AUDIO_EXTENSIONS := ["ogg", "mp3", "wav"]
const SILENCE_DB := -80.0
const DUCK_MULTIPLIER := 0.34
const DUCK_FADE_SECONDS := 0.65
const RESTORE_FADE_SECONDS := 1.15
const FALLBACK_MESSAGE_SECONDS := 2.4
const MESSAGE_CHECK_INTERVAL := 30.0
const RADIO_MINUTES_PER_DAY := 1440.0
const MIN_VOICE_COOLDOWN_SECONDS := 180.0
const MAX_VOICE_COOLDOWN_SECONDS := 300.0
const WEATHER_PREVIOUS_SAMPLE_GAME_MINUTES := 60.0
const MESSAGE_TYPES := ["generic", "weather", "spot", "rare_fish", "market", "events"]
const TEMPERATURE_VOICE_DIR := "res://assets/audio/radio/voice/weather/temperature/"
const TEMPERATURE_MORNING_SAMPLE_MINUTES := 8.0 * 60.0
const TEMPERATURE_DAY_SAMPLE_MINUTES := 14.0 * 60.0
const TEMPERATURE_EVENING_SAMPLE_MINUTES := 20.0 * 60.0
const TEMPERATURE_NIGHT_SAMPLE_MINUTES := 23.0 * 60.0
const SCHEDULED_MORNING_FORECAST_MINUTES := 7.0 * 60.0
const SCHEDULED_NIGHT_FORECAST_MINUTES := 23.0 * 60.0
const SCHEDULED_FORECAST_POLL_SECONDS := 1.0
const RADIO_SETTINGS_VERSION := 2

const MUSIC_DIRS := {
	"morning": "res://assets/audio/radio/music/morning/",
	"day": "res://assets/audio/radio/music/day/",
	"evening": "res://assets/audio/radio/music/evening/",
	"night": "res://assets/audio/radio/music/night/",
	"rain": "res://assets/audio/radio/music/rain/",
	"fog": "res://assets/audio/radio/music/fog/"
}

const VOICE_DIRS := {
	"generic": "res://assets/audio/radio/voice/generic/",
	"weather": "res://assets/audio/radio/voice/weather/",
	"spot": "res://assets/audio/radio/voice/spot/",
	"market": "res://assets/audio/radio/voice/market/",
	"events": "res://assets/audio/radio/voice/events/",
	"rare_fish": "res://assets/audio/radio/voice/rare_fish/"
}

const VOICE_FILE_ALIASES := {
	"generic_01": ["vy_slushaete_tumanfm_radio_uvody", "vy_slushaete_tuman_fm_radio_u_vody"],
	"generic_02": ["ostavaytes_s_nami_vperedi_novosti"],
	"generic_news_soon": ["ostavaytes_s_nami_vperedi_novosti"],
	"generic_dj_artis": ["privet_vsem_s_vami_dj_artis"],
	"generic_intro": ["vy_slushaete_tumanfm_radio_uvody"],
	"weather_01": ["na_agamim_legkiy_tuman"],
	"weather_agamim_fog": ["na_agamim_legkiy_tuman"],
	"weather_rain_tomorrow": ["pogoda_menyaetsa_zavtra_dozhdi"],
	"weather_rain_to_sun": ["dozhd_smenitsa_solncem_ura"],
	"weather_temperature_today": ["segodnya_temperatura"]
}

const JINGLE_DIR := "res://assets/audio/radio/jingles/"

var radio_enabled: bool = true
var current_station: String = STATION_TUMAN_FM
var music_volume: float = 0.55
var voice_volume: float = 0.85
var jingle_volume: float = 0.80
var voice_cooldown_seconds: float = 240.0
var weather_message_cooldown_seconds: float = 300.0
var temperature_message_cooldown_seconds: float = 300.0
var scheduled_weather_forecast_enabled: bool = true
var scheduled_weather_forecast_window_minutes: float = 15.0
var radio_debug_enabled: bool = false
var last_voice_time: float = -999999.0
var last_weather_message_time: float = -999999.0
var last_temperature_message_time: float = -999999.0
var current_track: String = ""
var current_context: Dictionary = {}

var weather_lines: Array = [
	"На {waterbody} сегодня {weather_description}. Вода спокойная.",
	"Погода меняется. Рыба может вести себя осторожнее.",
	"Сводка Tuman FM: у воды держится {weather_description}, выбирайте снасть аккуратно.",
	"{waterbody}: погода сейчас - {weather_description}. Следите за глубиной и поплавком."
]
var spot_lines: Array = [
	"У точки {spot} замечена активность рыбы.",
	"Рыбаки говорят, что у {spot} сегодня стоит попробовать тихую проводку.",
	"Рыбаки сообщают: возле {spot} поклевки идут увереннее.",
	"Если вы рядом с {spot}, попробуйте сменить глубину перед забросом."
]
var market_lines: Array = [
	"Поставщики обновили ассортимент снастей.",
	"На рынке сегодня повышенный интерес к зачётной рыбе.",
	"На рынке обсуждают свежие поставки лески, крючков и наживки.",
	"Совет от Tuman FM: проверяйте состояние снасти перед долгой сессией."
]
var event_lines: Array = [
	"Сегодня рыбаки говорят о необычных всплесках у {spot}.",
	"Вечерние разговоры у воды: на {waterbody} ждут хороший клев.",
	"Турнирный слух дня: стабильная снасть важнее поспешного заброса."
]
var rare_fish_lines: Array = [
	"По слухам, у {spot} были замечены редкие всплески.",
	"Опытные рыбаки советуют присмотреться к глубине.",
	"Ходят слухи о редкой рыбе недалеко от {spot}.",
	"На {waterbody} заметили странные круги на воде. Возможно, редкий экземпляр рядом.",
	"Если вода вдруг замерла, не спешите. Редкая рыба любит тишину."
]
var generic_lines: Array = [
	"Вы слушаете Tuman FM - радио у воды.",
	"Оставайтесь с нами. Впереди рыбацкие новости.",
	"Tuman FM напоминает: хороший улов начинается со спокойного заброса.",
	"Оставайтесь с Tuman FM. Туман, вода и немного удачи."
]

var music_player: AudioStreamPlayer
var voice_player: AudioStreamPlayer
var jingle_player: AudioStreamPlayer

var _message_timer: Timer
var _restore_timer: Timer
var _rng := RandomNumberGenerator.new()
var _audio_stream_cache: Dictionary = {}
var _missing_directory_reported: Dictionary = {}
var _missing_audio_reported: Dictionary = {}
var _missing_voice_message_reported: Dictionary = {}
var _empty_music_pool_reported: Dictionary = {}
var _music_ducked := false
var _message_in_progress := false
var _voice_sequence_in_progress := false
var _broadcast_active := false
var _message_sequence_generation := 0
var _music_volume_tween: Tween
var _last_observed_weather := ""
var _last_temperature_scenario := ""
var _time_manager: Node
var _scheduled_forecast_poll_accumulator := 0.0
var _played_scheduled_weather_forecast_keys: Dictionary = {}
var _pending_scheduled_weather_forecast: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	_ensure_players()
	_ensure_timers()
	_connect_time_manager()
	_apply_all_volumes()
	if radio_enabled:
		radio_enabled = false
		start_radio()


func _process(delta: float) -> void:
	_scheduled_forecast_poll_accumulator += delta
	if _scheduled_forecast_poll_accumulator < SCHEDULED_FORECAST_POLL_SECONDS:
		return
	_scheduled_forecast_poll_accumulator = 0.0
	_connect_time_manager()
	if radio_enabled:
		_try_play_scheduled_weather_forecast(_get_time_state_safe())


func start_radio() -> void:
	_ensure_players()
	_ensure_timers()
	_connect_time_manager()
	var was_enabled := radio_enabled
	radio_enabled = true
	current_station = STATION_TUMAN_FM
	_set_audio_manager_music_source("radio")
	if not was_enabled:
		print("[TumanFM] Вы слушаете Tuman FM - радио у воды.")
		radio_state_changed.emit(true)
	if music_player == null or not music_player.playing:
		play_next_music_track()
	if _message_timer != null and _message_timer.is_stopped():
		_message_timer.start()
	_try_play_scheduled_weather_forecast(_get_time_state_safe())


func stop_radio() -> void:
	var was_enabled := radio_enabled
	radio_enabled = false
	_message_sequence_generation += 1
	_message_in_progress = false
	_voice_sequence_in_progress = false
	_pending_scheduled_weather_forecast.clear()
	_music_ducked = false
	_set_broadcast_state(false)
	_set_audio_manager_music_source("game")
	if _message_timer != null:
		_message_timer.stop()
	if _restore_timer != null:
		_restore_timer.stop()
	if _music_volume_tween != null and _music_volume_tween.is_valid():
		_music_volume_tween.kill()
		_music_volume_tween = null
	var players: Array = [music_player, voice_player, jingle_player]
	for player_ref in players:
		var player := player_ref as AudioStreamPlayer
		if player != null:
			player.stop()
	if was_enabled:
		radio_state_changed.emit(false)


func toggle_radio() -> void:
	set_radio_enabled(not radio_enabled)


func set_radio_enabled(value: bool) -> void:
	if value == radio_enabled:
		if value:
			_set_audio_manager_music_source("radio")
			if music_player == null or not music_player.playing:
				play_next_music_track()
			if _message_timer != null and _message_timer.is_stopped():
				_message_timer.start()
		return
	if value:
		start_radio()
	else:
		stop_radio()


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_music_volume()
	_apply_voice_volume()
	_apply_jingle_volume()


func set_voice_volume(value: float) -> void:
	voice_volume = clampf(value, 0.0, 1.0)
	_apply_voice_volume()


func set_jingle_volume(value: float) -> void:
	jingle_volume = clampf(value, 0.0, 1.0)
	_apply_jingle_volume()


func get_radio_settings() -> Dictionary:
	return {
		"settings_version": RADIO_SETTINGS_VERSION,
		"radio_enabled": radio_enabled,
		"current_station": current_station,
		"music_volume": music_volume,
		"voice_volume": voice_volume,
		"jingle_volume": jingle_volume,
		"voice_cooldown_seconds": voice_cooldown_seconds,
		"weather_message_cooldown_seconds": weather_message_cooldown_seconds,
		"temperature_message_cooldown_seconds": temperature_message_cooldown_seconds,
		"scheduled_weather_forecast_enabled": scheduled_weather_forecast_enabled,
		"scheduled_weather_forecast_window_minutes": scheduled_weather_forecast_window_minutes
	}


func set_radio_settings(settings: Dictionary) -> void:
	var saved_settings_version := int(settings.get("settings_version", 0))
	var legacy_settings := saved_settings_version < RADIO_SETTINGS_VERSION
	var has_radio_enabled_setting := settings.has("radio_enabled")

	if settings.has("current_station"):
		current_station = str(settings.get("current_station", STATION_TUMAN_FM))
	if settings.has("music_volume"):
		music_volume = clampf(float(settings.get("music_volume", music_volume)), 0.0, 1.0)
	if settings.has("voice_volume"):
		voice_volume = clampf(float(settings.get("voice_volume", voice_volume)), 0.0, 1.0)
	if settings.has("jingle_volume"):
		jingle_volume = clampf(float(settings.get("jingle_volume", jingle_volume)), 0.0, 1.0)
	if settings.has("voice_cooldown_seconds"):
		voice_cooldown_seconds = clampf(float(settings.get("voice_cooldown_seconds", voice_cooldown_seconds)), MIN_VOICE_COOLDOWN_SECONDS, MAX_VOICE_COOLDOWN_SECONDS)
	if settings.has("weather_message_cooldown_seconds"):
		weather_message_cooldown_seconds = clampf(float(settings.get("weather_message_cooldown_seconds", weather_message_cooldown_seconds)), 60.0, 1800.0)
	if settings.has("temperature_message_cooldown_seconds"):
		temperature_message_cooldown_seconds = clampf(float(settings.get("temperature_message_cooldown_seconds", temperature_message_cooldown_seconds)), 60.0, 1800.0)
	if settings.has("scheduled_weather_forecast_enabled"):
		scheduled_weather_forecast_enabled = bool(settings.get("scheduled_weather_forecast_enabled", scheduled_weather_forecast_enabled))
	if settings.has("scheduled_weather_forecast_window_minutes"):
		scheduled_weather_forecast_window_minutes = clampf(float(settings.get("scheduled_weather_forecast_window_minutes", scheduled_weather_forecast_window_minutes)), 1.0, 60.0)
	_apply_all_volumes()
	if has_radio_enabled_setting:
		var enabled := bool(settings.get("radio_enabled", radio_enabled))
		# Early alpha builds could persist false before the station was really initialized on Android.
		# Once the current settings_version is saved, a deliberate "radio off" choice is respected normally.
		if legacy_settings and not enabled:
			enabled = true
		set_radio_enabled(enabled)
	elif legacy_settings:
		set_radio_enabled(true)


func is_radio_enabled() -> bool:
	return radio_enabled


func is_broadcasting() -> bool:
	return _broadcast_active


func get_radio_display_status() -> String:
	return "Радиоэфир" if _broadcast_active else "Tuman FM"


func play_next_music_track() -> void:
	_ensure_players()
	if not radio_enabled:
		return

	var pool: Array = choose_music_pool_by_time_and_weather()
	if pool.is_empty():
		_report_empty_music_pool("all")
		return

	var candidates := pool.duplicate()
	if candidates.size() > 1 and current_track != "":
		candidates.erase(current_track)
	var path := str(candidates[_rng.randi_range(0, candidates.size() - 1)])
	var stream := _get_audio_stream(path)
	if stream == null:
		_report_missing_audio(path)
		current_track = ""
		if pool.size() > 1:
			pool.erase(path)
		return

	current_track = path
	music_player.stop()
	music_player.stream = stream
	_set_stream_loop(stream, false)
	_apply_music_volume()
	music_player.play()
	print("[TumanFM] music: %s" % current_track)


func choose_music_pool_by_time_and_weather() -> Array:
	current_context = build_context_message()
	var context := current_context
	var weather_type := str(context.get("weather_type", "")).to_lower()
	var period := str(context.get("time_of_day", "morning")).to_lower()
	var preferred_dirs: Array = []

	if weather_type.find("rain") >= 0 or weather_type.find("storm") >= 0:
		preferred_dirs.append(str(MUSIC_DIRS.get("rain", "")))
	elif weather_type.find("fog") >= 0 or weather_type.find("mist") >= 0:
		preferred_dirs.append(str(MUSIC_DIRS.get("fog", "")))

	if MUSIC_DIRS.has(period):
		preferred_dirs.append(str(MUSIC_DIRS.get(period, "")))
	else:
		preferred_dirs.append(str(MUSIC_DIRS.get("morning", "")))

	for directory_path in preferred_dirs:
		var files := _list_audio_files(str(directory_path))
		if not files.is_empty():
			return files

	var fallback: Array = []
	for directory_path in MUSIC_DIRS.values():
		fallback.append_array(_list_audio_files(str(directory_path)))
	return fallback


func try_play_radio_message() -> void:
	if _try_play_scheduled_weather_forecast(_get_time_state_safe()):
		return
	if not radio_enabled or _message_in_progress:
		return

	var now := _get_real_seconds()
	if now - last_voice_time < voice_cooldown_seconds:
		return

	current_context = get_radio_context()
	var message := _pick_context_message(current_context)
	var text := str(message.get("text", "Вы слушаете Tuman FM - радио у воды."))
	var message_id := str(message.get("id", "generic_01"))
	var message_type := str(message.get("type", "generic"))

	last_voice_time = now
	if message_type == "weather":
		last_weather_message_time = now
		if message_id == "weather_temperature_today":
			last_temperature_message_time = now
	_message_in_progress = true
	_message_sequence_generation += 1
	_play_context_message_sequence(message, _message_sequence_generation)


func play_jingle(id: String) -> bool:
	_ensure_players()
	var path := _find_jingle_path(id)
	if path == "":
		return false

	var stream := _get_audio_stream(path)
	if stream == null:
		_report_missing_audio(path)
		return false

	jingle_player.stop()
	jingle_player.stream = stream
	_set_stream_loop(stream, false)
	_apply_jingle_volume()
	jingle_player.play()
	return true


func play_voice_message(message_id: String, message_type: String = "") -> bool:
	_ensure_players()
	var path := _find_voice_path(message_id, message_type)
	if path == "":
		_report_missing_voice_message(message_id, message_type)
		return false

	var stream := _get_audio_stream(path)
	if stream == null:
		_report_missing_audio(path)
		return false

	voice_player.stop()
	voice_player.stream = stream
	_set_stream_loop(stream, false)
	_apply_voice_volume()
	voice_player.play()
	return true


func try_play_temperature_sequence(prefix_file: String, temperature: int, fallback_text: String) -> bool:
	var rounded_temperature := clampi(int(round(float(temperature))), 0, 36)
	var normalized_prefix := prefix_file.strip_edges()
	var number_file := "number_%d" % rounded_temperature
	var prefix_path := _find_audio_file(TEMPERATURE_VOICE_DIR, normalized_prefix)
	var number_path := _find_audio_file(TEMPERATURE_VOICE_DIR, number_file)

	if prefix_path == "" or number_path == "":
		if prefix_path == "":
			_report_missing_temperature_voice_part(normalized_prefix)
		if number_path == "":
			_report_missing_temperature_voice_part(number_file)
		_print_radio_fallback(fallback_text)
		return false

	return await play_voice_sequence([prefix_path, number_path])


func play_voice_sequence(files: Array) -> bool:
	_ensure_players()
	if not radio_enabled or voice_player == null:
		return false
	if _voice_sequence_in_progress or voice_player.playing:
		return false

	var streams: Array = []
	for file_path_value in files:
		var file_path := str(file_path_value)
		var stream := _get_audio_stream(file_path)
		if stream == null:
			_report_missing_audio(file_path)
			return false
		streams.append(stream)

	var generation := _message_sequence_generation
	_voice_sequence_in_progress = true
	duck_music()

	for stream_value in streams:
		if generation != _message_sequence_generation or not radio_enabled:
			_voice_sequence_in_progress = false
			return false
		var stream := stream_value as AudioStream
		voice_player.stop()
		voice_player.stream = stream
		_set_stream_loop(stream, false)
		_apply_voice_volume()
		voice_player.play()
		await voice_player.finished

	_voice_sequence_in_progress = false
	if generation == _message_sequence_generation:
		_finish_message_sequence()
	return true


func duck_music() -> void:
	_music_ducked = true
	_tween_music_volume(_get_music_target_db(), DUCK_FADE_SECONDS)


func restore_music() -> void:
	_music_ducked = false
	_tween_music_volume(_get_music_target_db(), RESTORE_FADE_SECONDS)


func build_context_message() -> Dictionary:
	return get_radio_context()


func get_radio_context() -> Dictionary:
	var waterbody_id := _get_current_waterbody_id()
	var spot_id := _get_current_spot_id()
	var time_state := _get_time_state_safe()
	var weather_state := _get_current_weather_state(time_state)
	var current_weather := _normalize_radio_weather(str(weather_state.get("weather_type", "clear")))
	var previous_weather := _get_previous_weather_type(time_state, current_weather)
	var tomorrow_weather := _get_tomorrow_weather_type(time_state)
	var temperature := int(weather_state.get("temperature", 21))

	var context := {
		"waterbody": get_current_waterbody_name(),
		"waterbody_id": waterbody_id,
		"spot": get_current_spot_name(),
		"spot_id": spot_id,
		"weather": current_weather,
		"weather_type": current_weather,
		"weather_description": str(weather_state.get("description", get_current_weather_name())),
		"previous_weather": previous_weather,
		"tomorrow_weather": tomorrow_weather,
		"temperature": temperature,
		"time_of_day": get_current_time_period(),
		"time_period": get_current_time_period()
	}
	_update_observed_weather(current_weather)
	return context


func get_temperature_forecast_context() -> Dictionary:
	var time_state := _get_time_state_safe()
	var day_index := int(time_state.get("day_index", 1))
	var current_minutes := float(time_state.get("current_game_minutes", 525.0))
	var current_weather_state := _get_current_weather_state(time_state)
	var current_temperature := int(current_weather_state.get(
		"temperature",
		_get_temperature_for_day_sample(day_index, current_minutes)
	))
	var morning_temperature := _get_temperature_for_day_sample(day_index, TEMPERATURE_MORNING_SAMPLE_MINUTES)
	var day_temperature := _get_temperature_for_day_sample(day_index, TEMPERATURE_DAY_SAMPLE_MINUTES)
	var evening_temperature := _get_temperature_for_day_sample(day_index, TEMPERATURE_EVENING_SAMPLE_MINUTES)
	var night_temperature := _get_temperature_for_day_sample(day_index, TEMPERATURE_NIGHT_SAMPLE_MINUTES)
	var temperatures := [
		current_temperature,
		morning_temperature,
		day_temperature,
		evening_temperature,
		night_temperature
	]

	return {
		"current_temperature": current_temperature,
		"morning_temperature": morning_temperature,
		"day_temperature": day_temperature,
		"evening_temperature": evening_temperature,
		"night_temperature": night_temperature,
		"today_max_temperature": temperatures.max(),
		"today_min_temperature": temperatures.min()
	}


func get_current_waterbody_name() -> String:
	var waterbody_id := "agamin_lake"
	var player_waterbody = PlayerData.get("current_waterbody")
	if player_waterbody != null:
		waterbody_id = str(player_waterbody)

	var waterbody_name := "Агамим"
	var waterbody_data := WaterbodyDatabase.get_waterbody(waterbody_id)
	if waterbody_data is Dictionary and not waterbody_data.is_empty():
		waterbody_name = str(waterbody_data.get("name", waterbody_name))
	return waterbody_name


func get_current_spot_name() -> String:
	var spot_id := "old_oak_pier"
	var player_spot = PlayerData.get("current_spot")
	if player_spot != null:
		spot_id = str(player_spot)
	var spot_name := "неизвестная точка"
	var spot_data := SpotDatabase.get_spot(spot_id)
	if spot_data is Dictionary and not spot_data.is_empty():
		spot_name = str(spot_data.get("name", spot_name))
	return spot_name


func get_current_weather_name() -> String:
	var weather_description := "спокойная погода"
	var weather_state := _get_current_weather_state(_get_time_state_safe())
	if not weather_state.is_empty():
		weather_description = str(weather_state.get("description", weather_description))
	return weather_description


func get_current_time_period() -> String:
	var time_of_day := "day"
	var time_manager: Node = get_node_or_null("/root/TimeManager")
	if time_manager != null:
		if time_manager.has_method("get_time_state"):
			var time_state = time_manager.call("get_time_state")
			if time_state is Dictionary:
				time_of_day = str((time_state as Dictionary).get("time_of_day", time_of_day))
		else:
			time_of_day = str(time_manager.get("time_of_day"))
	if not MUSIC_DIRS.has(time_of_day):
		return "day"
	return time_of_day


func _get_current_waterbody_id() -> String:
	var player_waterbody = PlayerData.get("current_waterbody")
	if player_waterbody != null:
		return str(player_waterbody)
	return "agamin_lake"


func _get_current_spot_id() -> String:
	var player_spot = PlayerData.get("current_spot")
	if player_spot != null:
		return str(player_spot)
	return "old_oak_pier"


func _get_current_weather_state(time_state: Dictionary = {}) -> Dictionary:
	var weather_manager_state := _get_weather_manager_state()
	if not weather_manager_state.is_empty():
		var manager_weather := _get_first_string_value(weather_manager_state, ["weather_type", "weather", "current_weather", "current_weather_type"], "")
		var manager_temperature = weather_manager_state.get("temperature", weather_manager_state.get("current_temperature", null))
		if manager_temperature != null or manager_weather != "":
			return {
				"weather_type": _normalize_radio_weather(manager_weather),
				"description": _get_weather_description(manager_weather),
				"temperature": int(manager_temperature) if manager_temperature != null else 21
			}

	var time_manager: Node = get_node_or_null("/root/TimeManager")
	if time_manager != null:
		return WeatherUIHelperScript.get_current_weather_state(time_manager)
	if not time_state.is_empty():
		var day_index := int(time_state.get("day_index", 1))
		var minutes := float(time_state.get("current_game_minutes", 525.0))
		var weather_type := WeatherUIHelperScript.get_current_weather_type(day_index, minutes)
		var temperature := WeatherUIHelperScript.calculate_temperature(day_index, minutes, weather_type)
		return {
			"description": WeatherUIHelperScript.get_weather_description(weather_type),
			"temperature": temperature,
			"weather_type": weather_type
		}
	return {
		"description": "спокойная погода",
		"temperature": 21,
		"weather_type": "clear"
	}


func _get_time_state_safe() -> Dictionary:
	var time_manager: Node = get_node_or_null("/root/TimeManager")
	if time_manager != null and time_manager.has_method("get_time_state"):
		var value = time_manager.call("get_time_state")
		if value is Dictionary:
			return (value as Dictionary).duplicate(true)
	if time_manager != null:
		return {
			"total_game_minutes": float(_get_node_property(time_manager, "total_game_minutes", 525.0)),
			"current_game_minutes": float(_get_node_property(time_manager, "current_game_minutes", 525.0)),
			"time_of_day": str(_get_node_property(time_manager, "time_of_day", "day")),
			"day_index": int(_get_node_property(time_manager, "day_index", 1))
		}
	return {
		"total_game_minutes": 525.0,
		"current_game_minutes": 525.0,
		"time_of_day": "day",
		"day_index": 1
	}


func _get_weather_manager_state() -> Dictionary:
	var weather_manager: Node = get_node_or_null("/root/WeatherManager")
	if weather_manager == null:
		return {}
	for method_name in ["get_weather_state", "get_current_weather_state"]:
		if weather_manager.has_method(method_name):
			var value = weather_manager.call(method_name)
			if value is Dictionary:
				return (value as Dictionary).duplicate(true)

	var result: Dictionary = {}
	var weather_value = _get_first_node_value(
		weather_manager,
		["weather_type", "weather", "current_weather", "current_weather_type"],
		""
	)
	if str(weather_value) != "":
		result["weather_type"] = str(weather_value)
	var temperature_value = _get_first_node_value(
		weather_manager,
		["temperature", "current_temperature"],
		null
	)
	if temperature_value != null:
		result["temperature"] = int(temperature_value)
	return result


func _get_previous_weather_type(time_state: Dictionary, current_weather: String) -> String:
	var weather_manager: Node = get_node_or_null("/root/WeatherManager")
	var manager_value = _call_first_method(weather_manager, ["get_previous_weather", "get_previous_weather_type"], "")
	if str(manager_value) != "":
		return _normalize_radio_weather(str(manager_value))

	if _last_observed_weather != "" and _last_observed_weather != current_weather:
		return _last_observed_weather

	var previous_from_time := _get_weather_type_at_game_offset(time_state, -WEATHER_PREVIOUS_SAMPLE_GAME_MINUTES)
	if previous_from_time != current_weather:
		return previous_from_time
	return ""


func _get_tomorrow_weather_type(time_state: Dictionary) -> String:
	var weather_manager: Node = get_node_or_null("/root/WeatherManager")
	var manager_value = _call_first_method(weather_manager, ["get_tomorrow_weather", "get_tomorrow_weather_type"], "")
	if str(manager_value) != "":
		return _normalize_radio_weather(str(manager_value))

	var day_index := int(time_state.get("day_index", 1))
	return _normalize_radio_weather(WeatherUIHelperScript.get_weather_type_for_day(day_index + 1))


func _get_weather_type_at_game_offset(time_state: Dictionary, offset_minutes: float) -> String:
	var total_minutes := float(time_state.get("total_game_minutes", 0.0))
	if total_minutes <= 0.0:
		var day_index := int(time_state.get("day_index", 1))
		var minutes := float(time_state.get("current_game_minutes", 525.0))
		total_minutes = float(maxi(day_index - 1, 0)) * RADIO_MINUTES_PER_DAY + minutes
	var sampled_total := maxf(total_minutes + offset_minutes, 0.0)
	var sampled_day_index := int(floor(sampled_total / RADIO_MINUTES_PER_DAY)) + 1
	var sampled_minutes := fposmod(sampled_total, RADIO_MINUTES_PER_DAY)
	return _normalize_radio_weather(WeatherUIHelperScript.get_current_weather_type(sampled_day_index, sampled_minutes))


func _get_temperature_for_day_sample(day_index: int, minutes_in_day: float) -> int:
	var weather_type := WeatherUIHelperScript.get_current_weather_type(day_index, minutes_in_day)
	return int(WeatherUIHelperScript.calculate_temperature(day_index, minutes_in_day, weather_type))


func _update_observed_weather(current_weather: String) -> void:
	if current_weather == "":
		return
	_last_observed_weather = current_weather


func _normalize_radio_weather(weather_value: String) -> String:
	var normalized := weather_value.strip_edges().to_lower()
	match normalized:
		"fog", "mist", "night_mist", "туман":
			return "fog"
		"storm", "thunderstorm", "rain_with_thunderstorms", "гроза":
			return "storm"
		"rain", "rainy", "дождь":
			return "rain"
		"cloudy", "overcast", "облачно":
			return "cloudy"
		"sunny", "clear", "ясно":
			return "clear"
		_:
			return "clear"


func _get_weather_description(weather_value: String) -> String:
	match _normalize_radio_weather(weather_value):
		"fog":
			return "Туман"
		"storm":
			return "Дождь с грозой"
		"rain":
			return "Дождь"
		"cloudy":
			return "Облачно"
		_:
			return "Ясно"


func _get_first_string_value(source: Dictionary, keys: Array, fallback: String) -> String:
	for key in keys:
		if source.has(key) and str(source.get(key, "")) != "":
			return str(source.get(key, fallback))
	return fallback


func _get_first_node_value(node: Node, property_names: Array, fallback):
	if node == null:
		return fallback
	for property_name in property_names:
		var value = _get_node_property(node, str(property_name), null)
		if value != null:
			return value
	return fallback


func _get_node_property(node: Node, property_name: String, fallback):
	if node == null:
		return fallback
	for property_info in node.get_property_list():
		if str((property_info as Dictionary).get("name", "")) == property_name:
			return node.get(property_name)
	return fallback


func _call_first_method(node: Node, method_names: Array, fallback):
	if node == null:
		return fallback
	for method_name in method_names:
		if node.has_method(str(method_name)):
			return node.call(str(method_name))
	return fallback


func _ensure_players() -> void:
	if music_player == null:
		music_player = AudioStreamPlayer.new()
		music_player.name = "MusicPlayer"
		music_player.bus = _get_audio_bus_name("Music")
		add_child(music_player)
		music_player.finished.connect(_on_music_finished)
	if voice_player == null:
		voice_player = AudioStreamPlayer.new()
		voice_player.name = "VoicePlayer"
		voice_player.bus = _get_audio_bus_name("Music")
		add_child(voice_player)
		voice_player.finished.connect(_on_voice_finished)
	if jingle_player == null:
		jingle_player = AudioStreamPlayer.new()
		jingle_player.name = "JinglePlayer"
		jingle_player.bus = _get_audio_bus_name("Music")
		add_child(jingle_player)


func _ensure_timers() -> void:
	if _message_timer == null:
		_message_timer = Timer.new()
		_message_timer.name = "MessageTimer"
		_message_timer.wait_time = MESSAGE_CHECK_INTERVAL
		_message_timer.one_shot = false
		_message_timer.autostart = false
		add_child(_message_timer)
		_message_timer.timeout.connect(try_play_radio_message)
	if _restore_timer == null:
		_restore_timer = Timer.new()
		_restore_timer.name = "RestoreMusicTimer"
		_restore_timer.one_shot = true
		add_child(_restore_timer)
		_restore_timer.timeout.connect(_on_restore_timer_timeout)


func _connect_time_manager() -> void:
	var time_manager: Node = get_node_or_null("/root/TimeManager")
	if time_manager == null:
		return
	_time_manager = time_manager
	if not time_manager.has_signal("time_changed"):
		return
	var time_callable := Callable(self, "_on_time_changed")
	if not time_manager.is_connected("time_changed", time_callable):
		time_manager.connect("time_changed", time_callable)


func _on_time_changed(time_state: Dictionary) -> void:
	_try_play_scheduled_weather_forecast(time_state)


func _try_play_scheduled_weather_forecast(time_state: Dictionary = {}) -> bool:
	if not scheduled_weather_forecast_enabled or not radio_enabled:
		return false
	if _try_play_pending_scheduled_weather_forecast():
		return true

	var safe_time_state := time_state.duplicate(true) if not time_state.is_empty() else _get_time_state_safe()
	var slot := _get_due_scheduled_weather_slot(safe_time_state)
	if slot == "":
		return false

	var forecast := _build_scheduled_weather_forecast(slot, safe_time_state)
	if _message_in_progress:
		_pending_scheduled_weather_forecast = forecast
		_debug_scheduled_weather_forecast("queued", forecast)
		return true

	_play_scheduled_weather_forecast(forecast)
	return true


func _try_play_pending_scheduled_weather_forecast() -> bool:
	if _pending_scheduled_weather_forecast.is_empty():
		return false
	if _message_in_progress:
		return true
	var forecast := _pending_scheduled_weather_forecast.duplicate(true)
	_pending_scheduled_weather_forecast.clear()
	_play_scheduled_weather_forecast(forecast)
	return true


func _play_scheduled_weather_forecast(forecast: Dictionary) -> void:
	if not radio_enabled or _message_in_progress:
		return
	var key := str(forecast.get("key", ""))
	if key != "":
		_played_scheduled_weather_forecast_keys[key] = true
	var context := (forecast.get("context", {}) as Dictionary).duplicate(true)
	var message := (forecast.get("message", {}) as Dictionary).duplicate(true)
	var now := _get_real_seconds()
	var message_id := str(message.get("id", "weather_temperature_today"))

	current_context = context
	last_voice_time = now
	last_weather_message_time = now
	if message_id == "weather_temperature_today":
		last_temperature_message_time = now

	_message_in_progress = true
	_message_sequence_generation += 1
	_debug_scheduled_weather_forecast("playing", forecast)
	_play_context_message_sequence(message, _message_sequence_generation)


func _build_scheduled_weather_forecast(slot: String, time_state: Dictionary) -> Dictionary:
	var key := _make_scheduled_weather_forecast_key(slot, time_state)
	var context := get_radio_context()
	context["scheduled_weather_slot"] = slot
	var scenario := _build_night_morning_forecast_scenario(time_state) if slot == "night" else _select_temperature_scenario(context)
	var message := {
		"id": "weather_temperature_today",
		"type": "weather",
		"text": str(scenario.get("text", "Прогноз погоды Tuman FM.")),
		"temperature_scenario": scenario,
		"scheduled_weather_slot": slot
	}
	return {
		"key": key,
		"slot": slot,
		"context": context,
		"message": message,
		"time_state": time_state.duplicate(true)
	}


func _build_night_morning_forecast_scenario(time_state: Dictionary) -> Dictionary:
	var tomorrow_day_index := int(time_state.get("day_index", 1)) + 1
	var morning_temperature := _get_temperature_for_day_sample(tomorrow_day_index, SCHEDULED_MORNING_FORECAST_MINUTES)
	var morning_weather := _normalize_radio_weather(WeatherUIHelperScript.get_current_weather_type(tomorrow_day_index, SCHEDULED_MORNING_FORECAST_MINUTES))
	var scenario := _build_temperature_scenario(
		"tomorrow_morning",
		"utrom_temperatura",
		morning_temperature,
		"Утром температура будет около %d градусов."
	)
	scenario["target_day_index"] = tomorrow_day_index
	scenario["weather"] = morning_weather
	scenario["text"] = "Прогноз на утро: температура около %d градусов." % int(scenario.get("temperature", morning_temperature))
	scenario["fallback_text"] = "[TumanFM] Завтра утром температура будет около %d градусов." % int(scenario.get("temperature", morning_temperature))
	if radio_debug_enabled:
		print("[TumanFM] Night forecast target: day=%d, weather=%s, temperature=%d" % [
			tomorrow_day_index,
			morning_weather,
			int(scenario.get("temperature", morning_temperature))
		])
	return scenario


func _get_due_scheduled_weather_slot(time_state: Dictionary) -> String:
	var minutes := fposmod(float(time_state.get("current_game_minutes", 525.0)), RADIO_MINUTES_PER_DAY)
	for slot in ["morning", "night"]:
		var target_minutes := _get_scheduled_weather_target_minutes(slot)
		if minutes >= target_minutes and minutes < target_minutes + scheduled_weather_forecast_window_minutes:
			var key := _make_scheduled_weather_forecast_key(slot, time_state)
			if not _played_scheduled_weather_forecast_keys.has(key):
				return slot
	return ""


func _get_scheduled_weather_target_minutes(slot: String) -> float:
	return SCHEDULED_NIGHT_FORECAST_MINUTES if slot == "night" else SCHEDULED_MORNING_FORECAST_MINUTES


func _make_scheduled_weather_forecast_key(slot: String, time_state: Dictionary) -> String:
	return "%d:%s" % [int(time_state.get("day_index", 1)), slot]


func _debug_scheduled_weather_forecast(action: String, forecast: Dictionary) -> void:
	if not radio_debug_enabled:
		return
	var slot := str(forecast.get("slot", ""))
	var key := str(forecast.get("key", ""))
	var message := forecast.get("message", {}) as Dictionary
	var scenario := message.get("temperature_scenario", {}) as Dictionary
	print("[TumanFM] Scheduled weather forecast %s: slot=%s, key=%s, scenario=%s, temperature=%d" % [
		action,
		slot,
		key,
		str(scenario.get("id", "")),
		int(scenario.get("temperature", 21))
	])


func _play_context_message_sequence(message: Dictionary, generation: int) -> void:
	var message_id := str(message.get("id", "generic_01"))
	var message_type := str(message.get("type", "generic"))
	var text := str(message.get("text", "Вы слушаете Tuman FM - радио у воды."))
	_set_broadcast_state(true, "Радиоэфир")
	radio_message_started.emit(message_type, text)
	duck_music()
	await get_tree().create_timer(DUCK_FADE_SECONDS).timeout
	if generation != _message_sequence_generation or not radio_enabled:
		return

	var played_jingle := play_jingle("default")
	if played_jingle:
		await jingle_player.finished
		if generation != _message_sequence_generation or not radio_enabled:
			return

	if message_id == "weather_temperature_today":
		var temperature_scenario := _get_temperature_scenario_from_message(message)
		var played_temperature := await try_play_temperature_sequence(
			str(temperature_scenario.get("prefix", "segodnya_temperatura")),
			int(temperature_scenario.get("temperature", current_context.get("temperature", 21))),
			str(temperature_scenario.get("fallback_text", "[TumanFM] Сегодня температура %d градусов." % int(current_context.get("temperature", 21))))
		)
		if generation != _message_sequence_generation or not radio_enabled:
			return
		_last_temperature_scenario = str(temperature_scenario.get("id", _last_temperature_scenario))
		if not played_temperature:
			_restore_timer.start(FALLBACK_MESSAGE_SECONDS)
		return

	var played_voice := play_voice_message(message_id, message_type)
	if not played_voice:
		print("[TumanFM] %s" % text)
		_restore_timer.start(FALLBACK_MESSAGE_SECONDS)


func _pick_context_message(context: Dictionary) -> Dictionary:
	var weather_aliases := get_available_weather_aliases(context)
	_debug_radio_weather_context(context, weather_aliases)

	var available_types: Array = ["generic", "market", "events", "rare_fish"]
	if _has_named_spot(context):
		available_types.append("spot")
	if not weather_aliases.is_empty():
		available_types.append("weather")

	var prefix := str(available_types[_rng.randi_range(0, available_types.size() - 1)])
	if prefix == "weather":
		return _pick_weather_message(context, weather_aliases)

	var lines := _get_message_lines(prefix)
	if lines.is_empty():
		lines = generic_lines
		prefix = "generic"
	var line_index := _rng.randi_range(0, lines.size() - 1)
	var template := str(lines[line_index])
	return {
		"id": "%s_%02d" % [prefix, line_index + 1],
		"type": prefix,
		"text": _format_context_line(template, context)
	}


func get_available_weather_aliases(context: Dictionary) -> Array[String]:
	var aliases: Array[String] = []
	var now := _get_real_seconds()
	if now - last_weather_message_time < weather_message_cooldown_seconds:
		return aliases

	var current_weather := _normalize_radio_weather(str(context.get("weather", "clear")))
	var previous_weather := _normalize_radio_weather(str(context.get("previous_weather", "")))
	var tomorrow_weather := _normalize_radio_weather(str(context.get("tomorrow_weather", "")))

	if tomorrow_weather == "rain":
		aliases.append("weather_rain_tomorrow")
	if previous_weather == "rain" and current_weather == "clear":
		aliases.append("weather_rain_to_sun")
	if current_weather == "fog" and _is_agamim_context(context):
		aliases.append("weather_agamim_fog")
	if _context_has_temperature(context) and now - last_temperature_message_time >= temperature_message_cooldown_seconds:
		aliases.append("weather_temperature_today")

	return aliases


func _pick_weather_message(context: Dictionary, aliases: Array[String]) -> Dictionary:
	var alias := str(aliases[_rng.randi_range(0, aliases.size() - 1)])
	if alias == "weather_temperature_today":
		var temperature_scenario := _select_temperature_scenario(context)
		return {
			"id": alias,
			"type": "weather",
			"text": str(temperature_scenario.get("text", _get_weather_alias_text(alias, context))),
			"temperature_scenario": temperature_scenario
		}
	return {
		"id": alias,
		"type": "weather",
		"text": _get_weather_alias_text(alias, context)
	}


func _select_temperature_scenario(context: Dictionary) -> Dictionary:
	var forecast := get_temperature_forecast_context()
	var current_temperature := int(forecast.get("current_temperature", context.get("temperature", 21)))
	var morning_temperature := int(forecast.get("morning_temperature", current_temperature))
	var day_temperature := int(forecast.get("day_temperature", current_temperature))
	var night_temperature := int(forecast.get("night_temperature", current_temperature))
	var time_period := str(context.get("time_period", context.get("time_of_day", "day")))
	var candidates: Array = []

	match time_period:
		"morning":
			if day_temperature >= morning_temperature + 3:
				candidates.append(_build_temperature_scenario(
					"day_warming",
					"blizhe_k_obedu_ozhidaetsa",
					day_temperature,
					"Ближе к обеду ожидается потепление до %d градусов."
				))
			candidates.append(_build_temperature_scenario(
				"current",
				"segodnya_temperatura",
				current_temperature,
				"Сегодня температура %d градусов."
			))
			candidates.append(_build_temperature_scenario(
				"morning",
				"utrom_temperatura",
				morning_temperature,
				"Утром температура будет около %d градусов."
			))
		"day":
			if night_temperature <= day_temperature - 3:
				candidates.append(_build_temperature_scenario(
					"night_cooling",
					"vecherom_i_k_nochi_temperatura",
					night_temperature,
					"Вечером и к ночи температура будет около %d градусов."
				))
			candidates.append(_build_temperature_scenario(
				"current",
				"segodnya_temperatura",
				current_temperature,
				"Сегодня температура %d градусов."
			))
		"evening":
			candidates.append(_build_temperature_scenario(
				"evening_cooling",
				"vecherom_i_k_nochi_temperatura",
				night_temperature,
				"Вечером и к ночи температура будет около %d градусов."
			))
			candidates.append(_build_temperature_scenario(
				"current",
				"segodnya_temperatura",
				current_temperature,
				"Сегодня температура %d градусов."
			))
		_:
			candidates.append(_build_temperature_scenario(
				"current",
				"segodnya_temperatura",
				current_temperature,
				"Сегодня температура %d градусов."
			))

	var selected: Dictionary = candidates[0]
	if candidates.size() > 1 and str(selected.get("id", "")) == _last_temperature_scenario:
		for candidate_value in candidates:
			var candidate := candidate_value as Dictionary
			if str(candidate.get("id", "")) != _last_temperature_scenario:
				selected = candidate
				break

	_debug_temperature_scenario(forecast, selected)
	return selected


func _build_temperature_scenario(scenario_id: String, prefix_file: String, temperature: int, text_template: String) -> Dictionary:
	var rounded_temperature := clampi(int(round(float(temperature))), 0, 36)
	return {
		"id": scenario_id,
		"prefix": prefix_file,
		"temperature": rounded_temperature,
		"number_file": "number_%d" % rounded_temperature,
		"text": text_template % rounded_temperature,
		"fallback_text": "[TumanFM] %s" % (text_template % rounded_temperature)
	}


func _get_temperature_scenario_from_message(message: Dictionary) -> Dictionary:
	var scenario_value = message.get("temperature_scenario", {})
	if scenario_value is Dictionary and not (scenario_value as Dictionary).is_empty():
		return (scenario_value as Dictionary).duplicate(true)
	return _select_temperature_scenario(current_context)


func _debug_temperature_scenario(forecast: Dictionary, scenario: Dictionary) -> void:
	if not radio_debug_enabled:
		return
	print("[TumanFM] Temperature forecast: morning=%d, day=%d, evening=%d, night=%d, current=%d" % [
		int(forecast.get("morning_temperature", 21)),
		int(forecast.get("day_temperature", 21)),
		int(forecast.get("evening_temperature", 21)),
		int(forecast.get("night_temperature", 21)),
		int(forecast.get("current_temperature", 21))
	])
	print("[TumanFM] Temperature scenario selected: %s" % str(scenario.get("id", "current")))
	print("[TumanFM] Temperature sequence: %s + %s" % [
		str(scenario.get("prefix", "segodnya_temperatura")),
		str(scenario.get("number_file", "number_%d" % int(scenario.get("temperature", 21))))
	])


func _get_weather_alias_text(alias: String, context: Dictionary) -> String:
	if alias == "weather_temperature_today":
		return "Сегодня температура %d градусов." % int(context.get("temperature", 21))
	match alias:
		"weather_agamim_fog":
			return "На Агамиме лёгкий туман. Видимость ниже обычного."
		"weather_rain_tomorrow":
			return "Погода меняется. Завтра возможны дожди."
		"weather_rain_to_sun":
			return "Дождь сменился солнцем. Самое время проверить клёв."
		"weather_temperature_today":
			return "Сегодня температура %d градус." % int(context.get("temperature", 21))
		_:
			return _format_context_line(str(weather_lines[0]), context)


func _get_message_lines(message_type: String) -> Array:
	match message_type:
		"weather":
			return weather_lines
		"spot":
			return spot_lines
		"market":
			return market_lines
		"events":
			return event_lines
		"rare_fish":
			return rare_fish_lines
		_:
			return generic_lines


func _has_named_spot(context: Dictionary) -> bool:
	var spot := str(context.get("spot", "")).strip_edges().to_lower()
	return spot != "" and spot != "неизвестная точка"


func _is_agamim_context(context: Dictionary) -> bool:
	var waterbody_id := str(context.get("waterbody_id", "")).strip_edges().to_lower()
	var waterbody := str(context.get("waterbody", "")).strip_edges().to_lower()
	return waterbody_id == "agamin_lake" or waterbody.find("агамим") >= 0


func _context_has_temperature(context: Dictionary) -> bool:
	var temperature = context.get("temperature", null)
	return temperature != null and (typeof(temperature) == TYPE_INT or typeof(temperature) == TYPE_FLOAT)


func _debug_radio_weather_context(context: Dictionary, weather_aliases: Array[String]) -> void:
	if not radio_debug_enabled:
		return
	print("[TumanFM] Context: weather=%s, previous_weather=%s, tomorrow_weather=%s, temperature=%d" % [
		str(context.get("weather", "clear")),
		str(context.get("previous_weather", "")),
		str(context.get("tomorrow_weather", "")),
		int(context.get("temperature", 21))
	])
	print("[TumanFM] Weather aliases available: %s" % ", ".join(weather_aliases))


func _format_context_line(template: String, context: Dictionary) -> String:
	var text := template
	for key in context.keys():
		text = text.replace("{%s}" % str(key), str(context[key]))
	return text


func _find_jingle_path(id: String) -> String:
	var normalized_id := id.strip_edges()
	if normalized_id != "":
		var exact_path := _find_audio_file(JINGLE_DIR, normalized_id)
		if exact_path != "":
			return exact_path

	var jingles := _list_audio_files(JINGLE_DIR)
	if jingles.is_empty():
		return ""
	return str(jingles[_rng.randi_range(0, jingles.size() - 1)])


func _find_voice_path(message_id: String, message_type: String = "") -> String:
	var normalized_id := message_id.strip_edges()
	var search_dirs := _get_voice_search_dirs(message_type)
	var has_explicit_alias := VOICE_FILE_ALIASES.has(normalized_id)

	if normalized_id != "":
		for directory_path in search_dirs:
			var path := _find_audio_file(str(directory_path), normalized_id)
			if path != "":
				return path
		if has_explicit_alias:
			for alias in VOICE_FILE_ALIASES[normalized_id]:
				for directory_path in search_dirs:
					var alias_path := _find_audio_file(str(directory_path), str(alias))
					if alias_path != "":
						return alias_path
			return ""

	if VOICE_DIRS.has(message_type):
		var category_files := _list_audio_files(str(VOICE_DIRS[message_type]))
		if not category_files.is_empty():
			return str(category_files[_rng.randi_range(0, category_files.size() - 1)])

	for directory_path in search_dirs:
		var files := _list_audio_files(str(directory_path))
		if not files.is_empty():
			return str(files[_rng.randi_range(0, files.size() - 1)])
	return ""


func _get_voice_search_dirs(message_type: String) -> Array:
	var dirs: Array = []
	if VOICE_DIRS.has(message_type):
		dirs.append(str(VOICE_DIRS[message_type]))
	for directory_path in VOICE_DIRS.values():
		var path := str(directory_path)
		if not dirs.has(path):
			dirs.append(path)
	return dirs


func _find_audio_file(directory_path: String, basename: String) -> String:
	if directory_path == "" or basename == "":
		return ""
	for extension in AUDIO_EXTENSIONS:
		var path := directory_path.path_join("%s.%s" % [basename, extension])
		if FileAccess.file_exists(path) or ResourceLoader.exists(path):
			return path
	return ""


func _list_audio_files(directory_path: String) -> Array:
	var files: Array = []
	if directory_path == "":
		return files

	var dir := DirAccess.open(directory_path)
	if dir == null:
		_report_missing_directory(directory_path)
		return files

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var extension := file_name.get_extension().to_lower()
			if AUDIO_EXTENSIONS.has(extension):
				files.append(directory_path.path_join(file_name))
			elif extension == "import":
				var imported_name := file_name.trim_suffix(".import")
				var imported_extension := imported_name.get_extension().to_lower()
				if AUDIO_EXTENSIONS.has(imported_extension):
					var imported_path := directory_path.path_join(imported_name)
					if ResourceLoader.exists(imported_path) or FileAccess.file_exists(imported_path):
						files.append(imported_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	return files


func _get_audio_stream(path: String) -> AudioStream:
	if _audio_stream_cache.has(path):
		return _audio_stream_cache[path] as AudioStream

	var stream: AudioStream = null
	if ResourceLoader.exists(path):
		stream = load(path) as AudioStream

	if stream == null:
		match path.get_extension().to_lower():
			"ogg":
				stream = AudioStreamOggVorbis.load_from_file(path)
			"mp3":
				stream = AudioStreamMP3.load_from_file(path)

	if stream != null:
		_audio_stream_cache[path] = stream
	return stream


func _set_stream_loop(stream: AudioStream, enabled: bool) -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = enabled
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = enabled


func _apply_all_volumes() -> void:
	_apply_music_volume()
	_apply_voice_volume()
	_apply_jingle_volume()


func _apply_music_volume() -> void:
	if music_player == null:
		return
	if _music_volume_tween != null and _music_volume_tween.is_valid():
		_music_volume_tween.kill()
		_music_volume_tween = null
	music_player.volume_db = _get_music_target_db()


func _get_music_target_db() -> float:
	var target_volume := music_volume
	if _music_ducked:
		target_volume *= DUCK_MULTIPLIER
	return _volume_to_db(target_volume)


func _tween_music_volume(target_db: float, duration: float) -> void:
	if music_player == null:
		return
	if _music_volume_tween != null and _music_volume_tween.is_valid():
		_music_volume_tween.kill()
		_music_volume_tween = null
	if duration <= 0.0 or not music_player.playing:
		music_player.volume_db = target_db
		return
	_music_volume_tween = create_tween()
	_music_volume_tween.tween_property(music_player, "volume_db", target_db, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _apply_voice_volume() -> void:
	if voice_player != null:
		voice_player.volume_db = _volume_to_db(music_volume * voice_volume)


func _apply_jingle_volume() -> void:
	if jingle_player != null:
		jingle_player.volume_db = _volume_to_db(music_volume * jingle_volume)


func _volume_to_db(value: float) -> float:
	var volume := clampf(value, 0.0, 1.0)
	if volume <= 0.001:
		return SILENCE_DB
	return linear_to_db(volume)


func _get_audio_bus_name(preferred_bus: String, fallback_bus: String = "Master") -> String:
	if AudioServer.get_bus_index(preferred_bus) >= 0:
		return preferred_bus
	if AudioServer.get_bus_index(fallback_bus) >= 0:
		return fallback_bus
	return "Master"


func _set_audio_manager_music_source(source: String) -> void:
	var audio_manager: Node = get_node_or_null("/root/AudioManager")
	if audio_manager == null or not audio_manager.has_method("set_music_source"):
		return
	if audio_manager.has_method("get_music_source") and str(audio_manager.call("get_music_source")) == source:
		return
	audio_manager.call("set_music_source", source)


func _get_real_seconds() -> float:
	return Time.get_ticks_msec() / 1000.0


func _on_music_finished() -> void:
	if radio_enabled:
		play_next_music_track()


func _on_voice_finished() -> void:
	if _voice_sequence_in_progress:
		return
	_finish_message_sequence()


func _on_restore_timer_timeout() -> void:
	_finish_message_sequence()


func _finish_message_sequence() -> void:
	_restore_timer.stop()
	_voice_sequence_in_progress = false
	if not _message_in_progress and not _broadcast_active:
		return
	_message_in_progress = false
	_set_broadcast_state(false)
	radio_message_finished.emit()
	restore_music()
	if radio_enabled and not _pending_scheduled_weather_forecast.is_empty():
		call_deferred("_try_play_pending_scheduled_weather_forecast")


func _set_broadcast_state(active: bool, status_text: String = "") -> void:
	if _broadcast_active == active:
		return
	_broadcast_active = active
	broadcast_state_changed.emit(active, status_text)


func _print_radio_fallback(text: String) -> void:
	if text.begins_with("[TumanFM]"):
		print(text)
	else:
		print("[TumanFM] %s" % text)


func _report_missing_directory(directory_path: String) -> void:
	if _missing_directory_reported.has(directory_path):
		return
	_missing_directory_reported[directory_path] = true
	push_warning("[TumanFM] Missing audio directory: %s" % directory_path)


func _report_missing_audio(path: String) -> void:
	if _missing_audio_reported.has(path):
		return
	_missing_audio_reported[path] = true
	push_warning("[TumanFM] Audio file is missing or unsupported: %s" % path)


func _report_missing_voice_message(message_id: String, message_type: String) -> void:
	var key := "%s:%s" % [message_type, message_id]
	if _missing_voice_message_reported.has(key):
		return
	_missing_voice_message_reported[key] = true
	push_warning("[TumanFM] Voice message is missing, using text fallback: %s" % key)


func _report_missing_temperature_voice_part(basename: String) -> void:
	var key := "temperature:%s" % basename
	if _missing_voice_message_reported.has(key):
		return
	_missing_voice_message_reported[key] = true
	push_warning("[TumanFM] Temperature voice part is missing: %s" % TEMPERATURE_VOICE_DIR.path_join("%s.[ogg|mp3|wav]" % basename))


func _report_empty_music_pool(pool_key: String) -> void:
	if _empty_music_pool_reported.has(pool_key):
		return
	_empty_music_pool_reported[pool_key] = true
	push_warning("[TumanFM] No radio music tracks found. Put files into res://assets/audio/radio/music/.")
