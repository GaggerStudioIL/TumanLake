extends Node

signal time_changed(time_state: Dictionary)
signal period_changed(time_of_day: String)

const MINUTES_PER_DAY := 1440.0
const REAL_SECONDS_PER_GAME_DAY := 1800.0
const GAME_MINUTES_PER_REAL_SECOND := MINUTES_PER_DAY / REAL_SECONDS_PER_GAME_DAY

var current_game_minutes: float = 460.0
var current_hour: int = 7
var current_minute: int = 40
var day_progress: float = 0.0
var time_of_day: String = "morning"
var day_index: int = 1

var _last_time_of_day: String = "morning"
var _time_emit_accumulator: float = 0.0

func _ready() -> void:
	_recalculate_cached_time()

func _process(delta: float) -> void:
	advance_time(delta * GAME_MINUTES_PER_REAL_SECOND)

func advance_time(game_minutes: float) -> void:
	if game_minutes <= 0.0:
		return

	current_game_minutes += game_minutes

	while current_game_minutes >= MINUTES_PER_DAY:
		current_game_minutes -= MINUTES_PER_DAY
		day_index += 1

	_recalculate_cached_time()
	_time_emit_accumulator += game_minutes

	if time_of_day != _last_time_of_day:
		_last_time_of_day = time_of_day
		period_changed.emit(time_of_day)
		time_changed.emit(get_time_state())
	elif _time_emit_accumulator >= 1.0:
		_time_emit_accumulator = 0.0
		time_changed.emit(get_time_state())

func set_time(saved_minutes: float, saved_day_index: int = 1) -> void:
	current_game_minutes = fposmod(saved_minutes, MINUTES_PER_DAY)
	day_index = max(saved_day_index, 1)
	_recalculate_cached_time()
	_last_time_of_day = time_of_day
	_time_emit_accumulator = 0.0
	time_changed.emit(get_time_state())
	period_changed.emit(time_of_day)

func get_time_state() -> Dictionary:
	return {
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
	current_game_minutes = fposmod(current_game_minutes, MINUTES_PER_DAY)
	var rounded_minutes := int(floor(current_game_minutes))
	current_hour = int(rounded_minutes / 60) % 24
	current_minute = rounded_minutes % 60
	day_progress = current_game_minutes / MINUTES_PER_DAY
	time_of_day = _get_time_of_day(current_hour)

func _get_time_of_day(hour: int) -> String:
	if hour >= 5 and hour < 10:
		return "morning"
	if hour >= 10 and hour < 18:
		return "day"
	if hour >= 18 and hour < 22:
		return "evening"
	return "night"
