extends RefCounted

const ICON_DIR := "res://assets/ui/icons/weather/"
const MINUTES_PER_DAY := 1440.0


static func get_current_weather_state(time_manager: Node) -> Dictionary:
	var time_state := _get_time_state(time_manager)
	var day_index := int(time_state.get("day_index", 1))
	var minutes := float(time_state.get("current_game_minutes", 525.0))
	var time_of_day := str(time_state.get("time_of_day", "morning"))
	var forecast_weather_type := get_weather_type_for_day(day_index)
	var weather_type := get_current_weather_type(day_index, minutes)
	var temperature := calculate_temperature(day_index, minutes, weather_type)

	return {
		"day_index": day_index,
		"time_of_day": time_of_day,
		"weather_type": weather_type,
		"forecast_weather_type": forecast_weather_type,
		"description": get_weather_description(weather_type),
		"temperature": temperature,
		"temperature_text": format_temperature(temperature),
		"icon_path": get_weather_icon_path(time_of_day, weather_type)
	}


static func get_forecast(time_manager: Node, days: int = 7) -> Array:
	var time_state := _get_time_state(time_manager)
	var current_day_index := int(time_state.get("day_index", 1))
	var current_time_of_day := str(time_state.get("time_of_day", "morning"))
	var forecast: Array = []

	for offset in range(max(days, 0)):
		var day_index := current_day_index + offset
		var weather_type := get_weather_type_for_day(day_index)
		var icon_time_of_day := current_time_of_day if offset == 0 else "day"
		var temperature := calculate_temperature(day_index, 14.0 * 60.0, weather_type)
		forecast.append({
			"day_index": day_index,
			"label": get_forecast_day_label(offset, day_index),
			"weather_type": weather_type,
			"description": get_weather_description(weather_type),
			"temperature": temperature,
			"temperature_text": format_temperature(temperature),
			"icon_path": get_weather_icon_path(icon_time_of_day, weather_type)
		})

	return forecast


static func get_weather_icon_path(time_of_day: String, weather_type: String) -> String:
	var normalized_weather := normalize_weather_type(weather_type)
	match normalized_weather:
		"storm":
			return ICON_DIR + "rain_with_thunderstorms.png"
		"rain":
			return ICON_DIR + "rain.png"
		"cloudy":
			if is_night(time_of_day):
				return ICON_DIR + "night_cloudy.png"
			return ICON_DIR + "day_cloudy.png"
		_:
			if is_night(time_of_day):
				return ICON_DIR + "night.png"
			return ICON_DIR + "day.png"


static func normalize_weather_type(weather_type: String) -> String:
	match weather_type:
		"storm", "thunderstorm", "rain_with_thunderstorms":
			return "storm"
		"rain", "rainy":
			return "rain"
		"cloudy", "overcast", "fog", "mist", "night_mist":
			return "cloudy"
		_:
			return "clear"


static func get_weather_description(weather_type: String) -> String:
	match normalize_weather_type(weather_type):
		"storm":
			return "Дождь с грозой"
		"rain":
			return "Дождь"
		"cloudy":
			return "Облачно"
		_:
			return "Ясно"


static func get_weather_type_for_day(day_index: int) -> String:
	var pattern := ["clear", "cloudy", "rain", "clear", "cloudy", "storm", "clear", "cloudy"]
	var index := posmod(day_index - 1, pattern.size())
	return str(pattern[index])


static func get_current_weather_type(day_index: int, minutes_in_day: float) -> String:
	var forecast_type := normalize_weather_type(get_weather_type_for_day(day_index))
	var minutes := fposmod(minutes_in_day, MINUTES_PER_DAY)

	match forecast_type:
		"storm":
			return _get_storm_day_weather(day_index, minutes)
		"rain":
			return _get_rain_day_weather(day_index, minutes)
		"cloudy":
			return _get_cloudy_day_weather(day_index, minutes)
		_:
			return _get_clear_day_weather(day_index, minutes)


static func _get_rain_day_weather(day_index: int, minutes: float) -> String:
	var first_start := 280.0 + _stable_unit(day_index, 11) * 150.0
	var first_duration := 95.0 + _stable_unit(day_index, 12) * 95.0
	var second_start := 690.0 + _stable_unit(day_index, 13) * 180.0
	var second_duration := 120.0 + _stable_unit(day_index, 14) * 120.0
	var third_start := 1040.0 + _stable_unit(day_index, 15) * 170.0
	var third_duration := 75.0 + _stable_unit(day_index, 16) * 100.0

	if _is_minutes_in_window(minutes, first_start, first_duration):
		return "rain"
	if _is_minutes_in_window(minutes, second_start, second_duration):
		return "rain"
	if _is_minutes_in_window(minutes, third_start, third_duration) and _stable_unit(day_index, 17) > 0.22:
		return "rain"

	return "cloudy"


static func _get_storm_day_weather(day_index: int, minutes: float) -> String:
	var rain_start := 240.0 + _stable_unit(day_index, 21) * 160.0
	var rain_duration := 90.0 + _stable_unit(day_index, 22) * 120.0
	var storm_start := 610.0 + _stable_unit(day_index, 23) * 270.0
	var storm_duration := 70.0 + _stable_unit(day_index, 24) * 100.0
	var late_start := 1010.0 + _stable_unit(day_index, 25) * 190.0
	var late_duration := 85.0 + _stable_unit(day_index, 26) * 120.0

	if _is_minutes_in_window(minutes, storm_start, storm_duration):
		var local_progress := clampf((minutes - storm_start) / maxf(storm_duration, 1.0), 0.0, 1.0)
		if local_progress < 0.16 or local_progress > 0.88:
			return "rain"
		return "storm"
	if _is_minutes_in_window(minutes, rain_start, rain_duration):
		return "rain"
	if _is_minutes_in_window(minutes, late_start, late_duration):
		if _stable_unit(day_index, 27) > 0.58:
			return "storm"
		return "rain"

	return "cloudy"


static func _get_cloudy_day_weather(day_index: int, minutes: float) -> String:
	var clear_start := 620.0 + _stable_unit(day_index, 31) * 260.0
	var clear_duration := 90.0 + _stable_unit(day_index, 32) * 160.0
	var late_cloud_start := 980.0 + _stable_unit(day_index, 33) * 150.0

	if _is_minutes_in_window(minutes, clear_start, clear_duration):
		return "clear"
	if minutes > late_cloud_start or minutes < 260.0:
		return "cloudy"
	return "cloudy"


static func _get_clear_day_weather(day_index: int, minutes: float) -> String:
	var cloud_start := 780.0 + _stable_unit(day_index, 41) * 220.0
	var cloud_duration := 55.0 + _stable_unit(day_index, 42) * 95.0
	if _stable_unit(day_index, 43) > 0.48 and _is_minutes_in_window(minutes, cloud_start, cloud_duration):
		return "cloudy"
	return "clear"


static func _is_minutes_in_window(minutes: float, start: float, duration: float) -> bool:
	var wrapped_start := fposmod(start, MINUTES_PER_DAY)
	var wrapped_end := fposmod(start + maxf(duration, 0.0), MINUTES_PER_DAY)
	if duration >= MINUTES_PER_DAY:
		return true
	if wrapped_start <= wrapped_end:
		return minutes >= wrapped_start and minutes <= wrapped_end
	return minutes >= wrapped_start or minutes <= wrapped_end


static func _stable_unit(day_index: int, salt: int) -> float:
	var value := sin(float(day_index * 92821 + salt * 68917)) * 43758.5453123
	return fposmod(value, 1.0)


static func calculate_temperature(day_index: int, minutes_in_day: float, weather_type: String) -> int:
	var hour := int(floor(fposmod(minutes_in_day, MINUTES_PER_DAY) / 60.0))
	var temperature := 20.0 + sin(float(day_index) * 0.83) * 3.6

	if hour >= 11 and hour < 17:
		temperature += 2.8
	elif hour >= 5 and hour < 10:
		temperature -= 1.0
	elif hour >= 22 or hour < 5:
		temperature -= 4.8

	match normalize_weather_type(weather_type):
		"storm":
			temperature -= 4.2
		"rain":
			temperature -= 3.2
		"cloudy":
			temperature -= 1.4

	return roundi(clampf(temperature, 7.0, 31.0))


static func format_temperature(value: int) -> String:
	return "%d°C" % value


static func get_forecast_day_label(offset: int, _day_index: int) -> String:
	if offset == 0:
		return "Сегодня"
	if offset == 1:
		return "Завтра"
	if offset == 2:
		return "Послезавтра"
	var suffix := "дня" if offset >= 3 and offset <= 4 else "дней"
	return "Через %d %s" % [offset, suffix]


static func is_night(time_of_day: String) -> bool:
	return time_of_day == "night"


static func _get_time_state(time_manager: Node) -> Dictionary:
	if time_manager != null and time_manager.has_method("get_time_state"):
		var state = time_manager.call("get_time_state")
		if state is Dictionary:
			return (state as Dictionary).duplicate(true)

	if time_manager != null:
		return {
			"current_game_minutes": float(time_manager.get("current_game_minutes")),
			"time_of_day": str(time_manager.get("time_of_day")),
			"day_index": int(time_manager.get("day_index"))
		}

	return {
		"current_game_minutes": 525.0,
		"time_of_day": "morning",
		"day_index": 1
	}
