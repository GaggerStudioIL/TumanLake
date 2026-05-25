extends Node

signal time_changed(time_state: Dictionary)
signal period_changed(time_of_day: String)

const LocalTimeProviderScript := preload("res://scripts/time/local_time_provider.gd")

const MINUTES_PER_DAY := 1440.0
const NEW_GAME_START_TOTAL_MINUTES := 8.0 * 60.0 + 45.0
const REAL_SECONDS_PER_GAME_DAY := 1800.0
const GAME_MINUTES_PER_REAL_SECOND := MINUTES_PER_DAY / REAL_SECONDS_PER_GAME_DAY

var game_minutes_per_real_second: float = GAME_MINUTES_PER_REAL_SECOND
var total_game_minutes: float = NEW_GAME_START_TOTAL_MINUTES
var current_game_minutes: float = NEW_GAME_START_TOTAL_MINUTES
var current_hour: int = 8
var current_minute: int = 45
var day_progress: float = 0.0
var time_of_day: String = "morning"
var day_index: int = 1
var time_initialized := false
var last_real_utc_unix_time: float = 0.0

var _last_time_of_day: String = "morning"
var _time_emit_accumulator: float = 0.0
var _time_provider = LocalTimeProviderScript.new()
var _time_provider_warning_reported := false

func _ready() -> void:
	initialize_new_game_time(false)

func _process(delta: float) -> void:
	advance_time(delta * game_minutes_per_real_second)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			save_time()
		NOTIFICATION_APPLICATION_RESUMED:
			apply_offline_progress()
		NOTIFICATION_WM_CLOSE_REQUEST:
			save_time()
			get_tree().quit()

func advance_time(game_minutes: float) -> void:
	if game_minutes <= 0.0:
		return

	total_game_minutes += game_minutes
	_recalculate_cached_time()
	_time_emit_accumulator += game_minutes
	_emit_time_state()

func initialize_new_game_time(save_after_init: bool = true) -> void:
	total_game_minutes = NEW_GAME_START_TOTAL_MINUTES
	time_initialized = true
	last_real_utc_unix_time = _get_utc_unix_time()
	_recalculate_cached_time()
	_time_emit_accumulator = 0.0
	_emit_time_state(true)

	if save_after_init:
		save_time()

func load_time_from_save(save_data: Dictionary) -> void:
	var game_time := _get_saved_game_time(save_data)
	var has_saved_time := _has_saved_time(save_data, game_time)

	if not bool(game_time.get("initialized", has_saved_time)):
		initialize_new_game_time(false)
		return

	total_game_minutes = _get_saved_total_game_minutes(save_data, game_time)
	time_initialized = true
	last_real_utc_unix_time = float(game_time.get(
		"last_real_utc_unix_time",
		save_data.get("last_real_utc_unix_time", 0.0)
	))
	_recalculate_cached_time()
	_time_emit_accumulator = 0.0
	apply_offline_progress(false)
	_emit_time_state(true)

func apply_offline_progress(save_after_apply: bool = true) -> void:
	if not time_initialized:
		initialize_new_game_time(false)

	var now := _get_utc_unix_time()
	if now <= 0.0:
		return

	var elapsed_real_seconds := now - last_real_utc_unix_time
	if last_real_utc_unix_time <= 0.0 or elapsed_real_seconds <= 0.0:
		last_real_utc_unix_time = now
		if save_after_apply:
			save_time()
		return

	advance_time(elapsed_real_seconds * game_minutes_per_real_second)
	last_real_utc_unix_time = now

	if save_after_apply:
		save_time()

func save_time() -> void:
	_update_last_real_utc_unix_time()
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null and save_manager.has_method("save_game"):
		save_manager.call("save_game")

func get_time_save_data(update_real_timestamp: bool = true) -> Dictionary:
	if not time_initialized:
		initialize_new_game_time(false)

	if update_real_timestamp:
		_update_last_real_utc_unix_time()

	_recalculate_cached_time()
	return {
		"initialized": time_initialized,
		"total_game_minutes": total_game_minutes,
		"current_game_minutes": current_game_minutes,
		"current_hour": current_hour,
		"current_minute": current_minute,
		"day_index": day_index,
		"last_real_utc_unix_time": last_real_utc_unix_time
	}

func set_time_provider(provider) -> void:
	if provider == null or not provider.has_method("get_utc_unix_time"):
		push_warning("Invalid time provider. Keeping current time provider.")
		return
	_time_provider = provider
	last_real_utc_unix_time = _get_utc_unix_time()

func set_time(saved_minutes: float, saved_day_index: int = 1) -> void:
	total_game_minutes = _compose_total_minutes(saved_minutes, saved_day_index)
	time_initialized = true
	last_real_utc_unix_time = _get_utc_unix_time()
	_recalculate_cached_time()
	_time_emit_accumulator = 0.0
	_emit_time_state(true)

func get_hour() -> int:
	return current_hour

func get_minute() -> int:
	return current_minute

func get_time_string() -> String:
	return get_clock_text()


func get_real_unix_time() -> float:
	return _get_utc_unix_time()


func get_time_state() -> Dictionary:
	return {
		"total_game_minutes": total_game_minutes,
		"current_game_minutes": current_game_minutes,
		"current_hour": current_hour,
		"current_minute": current_minute,
		"day_progress": day_progress,
		"time_of_day": time_of_day,
		"time_of_day_title": get_time_of_day_title(),
		"day_index": day_index
	}

func get_clock_text() -> String:
	return "%02d:%02d" % [current_hour, current_minute]

func get_time_of_day_title() -> String:
	match time_of_day:
		"morning":
			return "Утро"
		"day":
			return "День"
		"evening":
			return "Вечер"
		"night":
			return "Ночь"
		_:
			return "Утро"

func get_atmosphere_settings() -> Dictionary:
	match time_of_day:
		"morning":
			return {
				"background": Color("#153d3f"),
				"scene": Color(1.10, 1.03, 0.90, 1.0),
				"sun": Color(1.16, 0.92, 0.58, 0.88),
				"water": Color(0.90, 1.02, 0.96, 1.0),
				"mist": Color(1.03, 0.98, 0.86, 0.82),
				"vignette": Color(0.95, 0.92, 0.80, 0.78)
			}
		"day":
			return {
				"background": Color("#17444c"),
				"scene": Color(1.04, 1.08, 1.04, 1.0),
				"sun": Color(1.00, 1.04, 0.92, 0.68),
				"water": Color(1.02, 1.10, 1.08, 1.0),
				"mist": Color(0.88, 0.96, 0.92, 0.50),
				"vignette": Color(0.80, 0.92, 0.90, 0.62)
			}
		"evening":
			return {
				"background": Color("#20353a"),
				"scene": Color(1.10, 0.86, 0.70, 1.0),
				"sun": Color(1.22, 0.62, 0.32, 0.94),
				"water": Color(0.98, 0.82, 0.72, 1.0),
				"mist": Color(1.06, 0.76, 0.52, 0.70),
				"vignette": Color(1.00, 0.62, 0.38, 0.78)
			}
		"night":
			return {
				"background": Color("#08151f"),
				"scene": Color(0.50, 0.62, 0.80, 1.0),
				"sun": Color(0.34, 0.50, 0.82, 0.22),
				"water": Color(0.48, 0.66, 0.82, 1.0),
				"mist": Color(0.46, 0.62, 0.86, 0.68),
				"vignette": Color(0.32, 0.42, 0.64, 0.94)
			}
		_:
			return {}

func _recalculate_cached_time() -> void:
	total_game_minutes = maxf(total_game_minutes, 0.0)
	current_game_minutes = fposmod(total_game_minutes, MINUTES_PER_DAY)
	var rounded_minutes := int(floor(current_game_minutes))
	current_hour = int(rounded_minutes / 60) % 24
	current_minute = rounded_minutes % 60
	day_progress = current_game_minutes / MINUTES_PER_DAY
	day_index = int(floor(total_game_minutes / MINUTES_PER_DAY)) + 1
	time_of_day = _get_time_of_day(current_hour)

func _get_time_of_day(hour: int) -> String:
	if hour >= 5 and hour < 10:
		return "morning"
	if hour >= 10 and hour < 18:
		return "day"
	if hour >= 18 and hour < 22:
		return "evening"
	return "night"

func _emit_time_state(force_period_emit: bool = false) -> void:
	if force_period_emit or time_of_day != _last_time_of_day:
		_last_time_of_day = time_of_day
		period_changed.emit(time_of_day)
		time_changed.emit(get_time_state())
	elif _time_emit_accumulator >= 1.0:
		_time_emit_accumulator = 0.0
		time_changed.emit(get_time_state())

func _get_saved_game_time(save_data: Dictionary) -> Dictionary:
	var game_time = save_data.get("game_time", {})
	if game_time is Dictionary:
		return (game_time as Dictionary).duplicate(true)
	return {}

func _has_saved_time(save_data: Dictionary, game_time: Dictionary) -> bool:
	return game_time.has("total_game_minutes") \
		or game_time.has("current_game_minutes") \
		or save_data.has("total_game_minutes") \
		or save_data.has("current_game_minutes")

func _get_saved_total_game_minutes(save_data: Dictionary, game_time: Dictionary) -> float:
	if game_time.has("total_game_minutes"):
		return maxf(float(game_time.get("total_game_minutes", NEW_GAME_START_TOTAL_MINUTES)), 0.0)
	if save_data.has("total_game_minutes"):
		return maxf(float(save_data.get("total_game_minutes", NEW_GAME_START_TOTAL_MINUTES)), 0.0)

	var saved_minutes := float(game_time.get(
		"current_game_minutes",
		save_data.get("current_game_minutes", NEW_GAME_START_TOTAL_MINUTES)
	))
	var saved_day_index := int(game_time.get("day_index", save_data.get("day_index", 1)))
	return _compose_total_minutes(saved_minutes, saved_day_index)

func _compose_total_minutes(minutes_in_day: float, saved_day_index: int) -> float:
	var safe_day_index: int = max(saved_day_index, 1)
	var wrapped_minutes := fposmod(minutes_in_day, MINUTES_PER_DAY)
	return float(safe_day_index - 1) * MINUTES_PER_DAY + wrapped_minutes

func _update_last_real_utc_unix_time() -> void:
	var now := _get_utc_unix_time()
	if now > 0.0:
		last_real_utc_unix_time = now

func _get_utc_unix_time() -> float:
	if _time_provider != null and _time_provider.has_method("get_utc_unix_time"):
		return float(_time_provider.call("get_utc_unix_time"))

	if not _time_provider_warning_reported:
		_time_provider_warning_reported = true
		push_warning("Time provider is missing. Real-time progress is disabled.")

	return last_real_utc_unix_time
