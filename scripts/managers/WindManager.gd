extends Node

signal wind_changed(wind_state: Dictionary)

const WeatherUIHelperScript := preload("res://scripts/ui/helpers/WeatherUIHelper.gd")

const DEFAULT_WIND_PROFILE := {
	"profile": "calm_lake",
	"base_wind_min": 0.2,
	"base_wind_max": 2.2,
	"strong_wind_weather": ["rain", "storm", "thunderstorm"],
	"gusts_allowed": true,
	"gust_chance_clear": 0.03,
	"gust_chance_rain": 0.22,
	"gust_chance_storm": 0.45
}
const WEATHER_WIND_SETTINGS := {
	"clear": {"min": 0.2, "max": 2.2, "gust_total_max": 2.8},
	"cloudy": {"min": 0.5, "max": 3.0, "gust_total_max": 3.5},
	"fog": {"min": 0.0, "max": 1.6, "gust_total_max": 1.8},
	"rain": {"min": 2.0, "max": 5.5, "gust_total_max": 7.0},
	"storm": {"min": 4.0, "max": 8.5, "gust_total_max": 11.0}
}

var _rng := RandomNumberGenerator.new()
var _current_speed_mps := 1.0
var _target_speed_mps := 1.0
var _current_direction_degrees := 72.0
var _target_direction_degrees := 72.0
var _gust_strength := 0.0
var _target_gust_strength := 0.0
var _gust_active := false
var _gust_timer := 0.0
var _gust_cooldown := 4.0
var _environment_poll_timer := 0.0
var _target_refresh_timer := 0.0
var _last_weather_type := ""
var _last_time_of_day := ""
var _last_spot_id := ""
var _last_day_index := -1
var _last_emitted_speed := -100.0
var _last_emitted_direction := -100.0
var _last_emitted_gust := false
var _time_manager_connected := false


func _ready() -> void:
	_rng.randomize()
	_current_direction_degrees = _rng.randf_range(0.0, 360.0)
	_target_direction_degrees = _current_direction_degrees
	_connect_time_manager()
	_poll_environment(true)
	_current_speed_mps = _target_speed_mps
	_emit_wind_changed(true)
	set_process(true)


func _process(delta: float) -> void:
	_connect_time_manager()

	_environment_poll_timer -= delta
	if _environment_poll_timer <= 0.0:
		_environment_poll_timer = 2.0
		_poll_environment(false)

	_target_refresh_timer -= delta
	if _target_refresh_timer <= 0.0:
		_target_refresh_timer = _rng.randf_range(7.0, 13.0)
		_rebuild_wind_targets(false)

	_update_gust(delta)
	_current_speed_mps = lerp(_current_speed_mps, _target_speed_mps, clamp(delta * 0.16, 0.0, 1.0))
	_current_direction_degrees = _lerp_angle_degrees(_current_direction_degrees, _target_direction_degrees, clamp(delta * 0.035, 0.0, 1.0))
	_emit_wind_changed(false)


func get_wind_state() -> Dictionary:
	return _build_wind_state(1.0, "")


func get_effective_wind_state(spot_id: String = "") -> Dictionary:
	var shelter := get_spot_wind_shelter(spot_id)
	return _build_wind_state(shelter, spot_id)


func get_wind_speed_mps() -> float:
	return float(get_wind_state().get("speed_mps", 0.0))


func get_wind_direction_degrees() -> float:
	return _current_direction_degrees


func get_wind_direction_vector() -> Vector2:
	return _direction_vector_from_degrees(_current_direction_degrees)


func get_wind_description() -> String:
	return _get_wind_description(get_wind_speed_mps())


func is_gust_active() -> bool:
	return _gust_active


func get_spot_wind_shelter(spot_id: String = "") -> float:
	var resolved_spot_id := spot_id
	if resolved_spot_id == "":
		resolved_spot_id = _get_current_spot_id()
	var spot := SpotDatabase.get_spot(resolved_spot_id)
	if spot.is_empty():
		return 1.0
	return clamp(float(spot.get("wind_shelter", 1.0)), 0.45, 1.25)


func _connect_time_manager() -> void:
	if _time_manager_connected:
		return
	var time_manager: Node = _get_time_manager()
	if time_manager == null:
		return
	if time_manager.has_signal("time_changed"):
		time_manager.time_changed.connect(_on_time_changed)
	if time_manager.has_signal("period_changed"):
		time_manager.period_changed.connect(_on_period_changed)
	_time_manager_connected = true


func _on_time_changed(_time_state: Dictionary) -> void:
	_poll_environment(false)


func _on_period_changed(_time_of_day: String) -> void:
	_poll_environment(true)


func _poll_environment(force: bool) -> void:
	var weather_type: String = _get_current_weather_type()
	var time_of_day: String = _get_current_time_of_day()
	var spot_id: String = _get_current_spot_id()
	var day_index: int = _get_current_day_index()
	var changed: bool = force
	changed = changed or weather_type != _last_weather_type
	changed = changed or time_of_day != _last_time_of_day
	changed = changed or spot_id != _last_spot_id
	changed = changed or day_index != _last_day_index

	if not changed:
		return

	_last_weather_type = weather_type
	_last_time_of_day = time_of_day
	_last_spot_id = spot_id
	_last_day_index = day_index
	_rebuild_wind_targets(force)


func _rebuild_wind_targets(force: bool) -> void:
	var weather_type: String = _get_current_weather_type()
	var normalized_weather: String = _normalize_wind_weather_type(weather_type)
	var settings: Dictionary = WEATHER_WIND_SETTINGS.get(normalized_weather, WEATHER_WIND_SETTINGS["clear"])
	var profile: Dictionary = _get_current_wind_profile()
	var min_speed: float = float(settings.get("min", 0.2))
	var max_speed: float = float(settings.get("max", 2.2))

	if normalized_weather == "clear":
		min_speed = float(profile.get("base_wind_min", min_speed))
		max_speed = float(profile.get("base_wind_max", max_speed))

	var time_multiplier: float = _get_time_of_day_wind_multiplier(normalized_weather)
	min_speed *= time_multiplier
	max_speed *= time_multiplier

	var sampled_speed: float = _rng.randf_range(min_speed, max(max_speed, min_speed + 0.05))
	if force:
		_target_speed_mps = sampled_speed
	else:
		_target_speed_mps = lerp(_target_speed_mps, sampled_speed, 0.38)

	var direction_step := 18.0
	if force:
		direction_step = 48.0 if _last_weather_type == weather_type else 120.0
	_target_direction_degrees = fposmod(_current_direction_degrees + _rng.randf_range(-direction_step, direction_step), 360.0)
	_gust_cooldown = min(_gust_cooldown, _rng.randf_range(2.5, 7.0))


func _update_gust(delta: float) -> void:
	if _gust_active:
		_gust_timer -= delta
		_gust_strength = lerp(_gust_strength, _target_gust_strength, clamp(delta * 2.0, 0.0, 1.0))
		if _gust_timer <= 0.0:
			_gust_active = false
			_target_gust_strength = 0.0
			_gust_cooldown = _rng.randf_range(5.0, 12.0)
		return

	_gust_strength = lerp(_gust_strength, 0.0, clamp(delta * 2.6, 0.0, 1.0))
	_gust_cooldown -= delta
	if _gust_cooldown > 0.0:
		return

	var chance: float = _get_current_gust_chance()
	if _rng.randf() < chance:
		_start_gust()
	else:
		_gust_cooldown = _rng.randf_range(4.0, 10.0)


func _start_gust() -> void:
	var normalized_weather: String = _normalize_wind_weather_type(_get_current_weather_type())
	var settings: Dictionary = WEATHER_WIND_SETTINGS.get(normalized_weather, WEATHER_WIND_SETTINGS["clear"])
	var gust_total_max: float = float(settings.get("gust_total_max", 2.8))
	var gust_ceiling: float = max(gust_total_max - _current_speed_mps, 0.25)
	_gust_active = true
	_gust_timer = _rng.randf_range(1.6, 4.6)
	_target_gust_strength = _rng.randf_range(0.20, gust_ceiling)
	_target_direction_degrees = fposmod(_target_direction_degrees + _rng.randf_range(-16.0, 16.0), 360.0)


func _get_current_gust_chance() -> float:
	var profile: Dictionary = _get_current_wind_profile()
	if not bool(profile.get("gusts_allowed", true)):
		return 0.0

	match _normalize_wind_weather_type(_get_current_weather_type()):
		"storm":
			return clamp(float(profile.get("gust_chance_storm", 0.45)), 0.0, 0.80)
		"rain":
			return clamp(float(profile.get("gust_chance_rain", 0.22)), 0.0, 0.60)
		"fog":
			return 0.01
		"cloudy":
			return 0.08
		_:
			return clamp(float(profile.get("gust_chance_clear", 0.03)), 0.0, 0.18)


func _build_wind_state(shelter: float, spot_id: String) -> Dictionary:
	var effective_gust: float = (_gust_strength if _gust_active else 0.0) * shelter
	var speed: float = max((_current_speed_mps + (_gust_strength if _gust_active else 0.0)) * shelter, 0.0)
	var description: String = _get_wind_description(speed)
	return {
		"speed_mps": speed,
		"base_speed_mps": _current_speed_mps * shelter,
		"direction_degrees": _current_direction_degrees,
		"direction_vector": _direction_vector_from_degrees(_current_direction_degrees),
		"gust_strength": effective_gust,
		"gust_active": _gust_active,
		"description": description,
		"label": description,
		"icon_key": _get_wind_icon_key(speed, _gust_active),
		"spot_id": spot_id,
		"wind_shelter": shelter
	}


func _emit_wind_changed(force: bool) -> void:
	var speed := get_wind_speed_mps()
	var direction_delta := _angle_delta_degrees(_last_emitted_direction, _current_direction_degrees)
	if not force and abs(speed - _last_emitted_speed) < 0.05 and direction_delta < 4.0 and _last_emitted_gust == _gust_active:
		return
	_last_emitted_speed = speed
	_last_emitted_direction = _current_direction_degrees
	_last_emitted_gust = _gust_active
	wind_changed.emit(get_wind_state())


func _get_current_weather_type() -> String:
	var weather_state := WeatherUIHelperScript.get_current_weather_state(_get_time_manager())
	return str(weather_state.get("weather_type", "clear"))


func _get_current_time_of_day() -> String:
	var time_manager: Node = _get_time_manager()
	if time_manager != null and time_manager.has_method("get_time_state"):
		var state = time_manager.call("get_time_state")
		if state is Dictionary:
			return str((state as Dictionary).get("time_of_day", "morning"))
	if time_manager != null:
		return str(time_manager.get("time_of_day"))
	return "morning"


func _get_current_day_index() -> int:
	var time_manager: Node = _get_time_manager()
	if time_manager != null and time_manager.has_method("get_time_state"):
		var state = time_manager.call("get_time_state")
		if state is Dictionary:
			return int((state as Dictionary).get("day_index", 1))
	return 1


func _get_time_manager() -> Node:
	return get_node_or_null("/root/TimeManager")


func _get_current_spot_id() -> String:
	if PlayerData != null:
		return str(PlayerData.current_spot)
	return "old_oak_pier"


func _get_current_waterbody_id() -> String:
	if PlayerData != null:
		return str(PlayerData.current_waterbody)
	return "agamin_lake"


func _get_current_wind_profile() -> Dictionary:
	var waterbody := WaterbodyDatabase.get_waterbody(_get_current_waterbody_id())
	var profile = waterbody.get("wind_profile", DEFAULT_WIND_PROFILE)
	if profile is Dictionary:
		return (profile as Dictionary).duplicate(true)
	return DEFAULT_WIND_PROFILE.duplicate(true)


func _normalize_wind_weather_type(weather_type: String) -> String:
	var lowered := weather_type.to_lower()
	if lowered == "fog" or lowered == "mist" or lowered == "night_mist":
		return "fog"
	return WeatherUIHelperScript.normalize_weather_type(lowered)


func _get_time_of_day_wind_multiplier(normalized_weather: String) -> float:
	if normalized_weather == "rain" or normalized_weather == "storm":
		return 1.0

	match _get_current_time_of_day():
		"night":
			return 0.75
		"morning":
			return 0.85
		"evening":
			return 0.90
		_:
			return 1.0


func _direction_vector_from_degrees(degrees: float) -> Vector2:
	var radians := deg_to_rad(degrees)
	return Vector2(cos(radians), sin(radians)).normalized()


func _get_wind_description(speed_mps: float) -> String:
	if speed_mps <= 0.5:
		return "Штиль"
	if speed_mps <= 2.0:
		return "Лёгкий ветер"
	if speed_mps <= 4.0:
		return "Умеренный ветер"
	if speed_mps <= 6.5:
		return "Сильный ветер"
	return "Порывы ветра"


func _get_wind_icon_key(speed_mps: float, gust_active: bool) -> String:
	if gust_active or speed_mps > 6.5:
		return "wind_gust"
	if speed_mps <= 0.5:
		return "wind_calm"
	if speed_mps <= 2.0:
		return "wind_light"
	if speed_mps <= 4.0:
		return "wind_moderate"
	return "wind_strong"


func _lerp_angle_degrees(from_degrees: float, to_degrees: float, weight: float) -> float:
	var delta := fposmod(to_degrees - from_degrees + 180.0, 360.0) - 180.0
	return fposmod(from_degrees + delta * weight, 360.0)


func _angle_delta_degrees(from_degrees: float, to_degrees: float) -> float:
	if from_degrees < -90.0:
		return 360.0
	return abs(fposmod(to_degrees - from_degrees + 180.0, 360.0) - 180.0)
