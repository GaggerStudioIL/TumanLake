extends Node

signal condition_changed(state: Dictionary)
signal condition_warning(message: String, warning_id: String)

const WeatherUIHelperScript := preload("res://scripts/ui/helpers/WeatherUIHelper.gd")

const DEFAULT_HEALTH := 100.0
const DEFAULT_BODY_TEMPERATURE := 36.6
const DEFAULT_HUNGER := 100.0
const MIN_WELLBEING_TO_FISH := 15.0
const HUNGER_WELLBEING_FLOOR := 38.0
const TEMPERATURE_WELLBEING_FLOOR := 20.0
const HUNGER_LOSS_PER_GAME_HOUR := 0.93
const AUTOSAVE_INTERVAL_SECONDS := 30.0
const WARNING_COOLDOWN_SECONDS := 90.0

var _last_total_game_minutes: float = -1.0
var _warning_cooldowns: Dictionary = {}
var _save_accumulator: float = 0.0
var _dirty := false
var _last_emitted_state: Dictionary = {}
var _condition_quality_bonus := 0.0
var _condition_quality_bonus_minutes_remaining := 0.0


func _ready() -> void:
	if PlayerData.has_method("ensure_condition_defaults"):
		PlayerData.ensure_condition_defaults()
	_last_total_game_minutes = _get_total_game_minutes()
	_emit_condition_changed(true)
	set_process(true)


func _process(delta: float) -> void:
	_tick_warning_cooldowns(delta)
	var elapsed_game_minutes := _consume_elapsed_game_minutes(delta)
	if elapsed_game_minutes > 0.0:
		var changed := update_condition(elapsed_game_minutes)
		_emit_condition_changed(changed)
		_maybe_emit_warnings()
	_maybe_autosave(delta)


func update_condition(elapsed_game_minutes: float) -> bool:
	if elapsed_game_minutes <= 0.0:
		return false

	var previous_health := float(PlayerData.health)
	var previous_temperature := float(PlayerData.body_temperature)
	var previous_hunger := float(PlayerData.hunger)
	var elapsed_game_hours := elapsed_game_minutes / 60.0
	var environment := get_environment_state()
	_tick_condition_bonus(elapsed_game_minutes)

	PlayerData.hunger = clampf(
		float(PlayerData.hunger) - HUNGER_LOSS_PER_GAME_HOUR * elapsed_game_hours * _get_progression_survival_multiplier("hunger_loss_multiplier", 1.0),
		0.0,
		100.0
	)

	var target_temperature := _get_target_body_temperature(environment)
	var temperature_rate := _get_body_temperature_rate(environment, target_temperature)
	PlayerData.body_temperature = move_toward(
		float(PlayerData.body_temperature),
		target_temperature,
		temperature_rate * elapsed_game_minutes
	)

	var wellbeing_delta_per_hour := _get_wellbeing_delta_per_game_hour()
	var next_wellbeing := float(PlayerData.health) + wellbeing_delta_per_hour * elapsed_game_hours
	if wellbeing_delta_per_hour < 0.0:
		next_wellbeing = maxf(next_wellbeing, _get_wellbeing_floor_for_current_state())
	PlayerData.health = clampf(next_wellbeing, 0.0, 100.0)

	if PlayerData.has_method("ensure_condition_defaults"):
		PlayerData.ensure_condition_defaults()

	var changed: bool = (
		abs(previous_health - float(PlayerData.health)) > 0.01
		or abs(previous_temperature - float(PlayerData.body_temperature)) > 0.005
		or abs(previous_hunger - float(PlayerData.hunger)) > 0.01
	)
	_dirty = _dirty or changed
	return changed


func get_condition_state() -> Dictionary:
	var wellbeing := clampf(float(PlayerData.health), 0.0, 100.0)
	var state := {
		"health": wellbeing,
		"wellbeing": wellbeing,
		"body_temperature": clampf(float(PlayerData.body_temperature), 30.0, 42.0),
		"hunger": clampf(float(PlayerData.hunger), 0.0, 100.0),
		"temperature_status": get_temperature_status(),
		"hunger_status": get_hunger_status(),
		"health_status": get_health_status(),
		"wellbeing_status": get_health_status(),
		"wellbeing_label": get_wellbeing_label(),
		"condition_quality": get_condition_quality(),
		"can_fish": can_start_fishing(),
		"block_message": get_fishing_block_message(),
		"environment": get_environment_state()
	}
	return state


func get_temperature_status() -> String:
	var value := float(PlayerData.body_temperature)
	if value < 34.5:
		return "freezing"
	if value < 35.5:
		return "cold"
	if value > 38.5:
		return "overheating"
	if value > 37.6:
		return "hot"
	if value >= 36.0 and value <= 37.2:
		return "normal"
	return "unstable"


func get_hunger_status() -> String:
	var value := float(PlayerData.hunger)
	if value < 10.0:
		return "critical"
	if value < 30.0:
		return "hungry"
	if value < 60.0:
		return "low"
	return "normal"


func get_health_status() -> String:
	var value := float(PlayerData.health)
	if value < 20.0:
		return "exhausted"
	if value < 40.0:
		return "poor"
	if value < 65.0:
		return "tired"
	if value < 90.0:
		return "normal"
	return "excellent"


func get_wellbeing_label() -> String:
	match get_health_status():
		"excellent":
			return "Отлично"
		"normal":
			return "Нормально"
		"tired":
			return "Устал"
		"poor":
			return "Плохо"
		_:
			return "Вымотан"


func get_condition_quality() -> float:
	var penalty := 0.0
	var health := clampf(float(PlayerData.health), 0.0, 100.0)
	var body_temperature := float(PlayerData.body_temperature)
	var hunger := clampf(float(PlayerData.hunger), 0.0, 100.0)

	if health < 70.0:
		penalty += (70.0 - health) / 70.0 * 0.28
	if hunger < 30.0:
		penalty += (30.0 - hunger) / 30.0 * 0.30
	if hunger < 10.0:
		penalty += (10.0 - hunger) / 10.0 * 0.10
	if body_temperature < 36.0:
		penalty += clampf((36.0 - body_temperature) / 2.0, 0.0, 1.0) * 0.34
	elif body_temperature > 37.2:
		penalty += clampf((body_temperature - 37.2) / 2.0, 0.0, 1.0) * 0.34

	return clampf(1.0 - penalty + _condition_quality_bonus, 0.12, 1.0)


func get_fishing_modifiers() -> Dictionary:
	var raw_quality := get_condition_quality()
	var penalty_multiplier := _get_progression_survival_multiplier("condition_penalty_multiplier", 1.0)
	var quality := clampf(1.0 - (1.0 - raw_quality) * penalty_multiplier, 0.12, 1.0)
	return {
		"condition_quality": quality,
		"bite_chance_multiplier": lerpf(0.60, 1.0, quality),
		"bite_window_multiplier": lerpf(0.62, 1.0, quality),
		"reeling_difficulty_multiplier": lerpf(1.58, 1.0, quality),
		"escape_risk_multiplier": lerpf(1.70, 1.0, quality),
		"tension_fail_time_multiplier": lerpf(0.66, 1.0, quality),
		"false_nudge_chance_multiplier": lerpf(1.55, 1.0, quality),
		"error_chance_multiplier": lerpf(1.55, 1.0, quality),
		"reaction_multiplier": quality
	}


func can_start_fishing() -> bool:
	if float(PlayerData.health) < MIN_WELLBEING_TO_FISH:
		return false
	var temperature_status := get_temperature_status()
	return temperature_status != "freezing" and temperature_status != "overheating"


func get_fishing_block_message() -> String:
	if can_start_fishing():
		return ""
	return "Вы плохо себя чувствуете. Нужно согреться, охладиться или отдохнуть.\nДействия: перекусить, выпить, открыть инвентарь, зайти в дом рыбака или отдохнуть."


func rest_to_safe_state() -> void:
	PlayerData.body_temperature = DEFAULT_BODY_TEMPERATURE
	PlayerData.health = maxf(float(PlayerData.health), 65.0)
	PlayerData.hunger = maxf(float(PlayerData.hunger), 45.0)
	if PlayerData.has_method("ensure_condition_defaults"):
		PlayerData.ensure_condition_defaults()
	_dirty = true
	_emit_condition_changed(true)
	_save_now()


func leave_to_camp_and_rest() -> void:
	rest_to_safe_state()


func can_use_agamim_cabin() -> bool:
	return str(PlayerData.current_waterbody) == "agamin_lake"


func rest_at_agamim_cabin() -> Dictionary:
	if not can_use_agamim_cabin():
		return {"success": false, "message": "Домик доступен только на Озере Агамим."}
	return _apply_rest_effect({
		"rest_minutes": 90.0,
		"health_restore": 35.0,
		"min_health": 70.0,
		"hunger_cost": 0.0,
		"normalize_temperature": true
	}, "Домик рыбака")


func normalize_temperature_at_agamim_cabin() -> Dictionary:
	if not can_use_agamim_cabin():
		return {"success": false, "message": "Домик доступен только на Озере Агамим."}
	_advance_game_time(35.0)
	PlayerData.body_temperature = DEFAULT_BODY_TEMPERATURE
	PlayerData.hunger = clampf(float(PlayerData.hunger) - 2.0, 0.0, 100.0)
	_mark_changed_and_save()
	return {"success": true, "message": "Вы привели температуру в норму в домике."}


func apply_consumable_item(item: Dictionary) -> Dictionary:
	if item.is_empty():
		return {"success": false, "message": "Предмет не найден."}
	var category := str(item.get("category", ""))
	if not ["food", "drink"].has(category):
		return {"success": false, "message": "Это нельзя использовать как еду или напиток."}
	var stats: Dictionary = item.get("stats", {}) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}
	var changed := false
	if stats.has("hunger_restore"):
		PlayerData.hunger = clampf(float(PlayerData.hunger) + float(stats.get("hunger_restore", 0.0)), 0.0, 100.0)
		changed = true
	if stats.has("health_restore"):
		PlayerData.health = clampf(float(PlayerData.health) + float(stats.get("health_restore", 0.0)), 0.0, 100.0)
		changed = true
	var environment := get_environment_state()
	if stats.has("temperature_delta_cold") and (float(PlayerData.body_temperature) < DEFAULT_BODY_TEMPERATURE or float(environment.get("air_temperature", 20.0)) <= 14.0):
		PlayerData.body_temperature = clampf(float(PlayerData.body_temperature) + float(stats.get("temperature_delta_cold", 0.0)), 30.0, 42.0)
		changed = true
	if stats.has("temperature_delta_hot") and (float(PlayerData.body_temperature) > DEFAULT_BODY_TEMPERATURE or float(environment.get("air_temperature", 20.0)) >= 26.0):
		PlayerData.body_temperature = clampf(float(PlayerData.body_temperature) + float(stats.get("temperature_delta_hot", 0.0)), 30.0, 42.0)
		changed = true
	if stats.has("condition_bonus"):
		_condition_quality_bonus = maxf(_condition_quality_bonus, float(stats.get("condition_bonus", 0.0)))
		_condition_quality_bonus_minutes_remaining = maxf(_condition_quality_bonus_minutes_remaining, float(stats.get("bonus_minutes", 60.0)))
		changed = true
	if not changed:
		changed = true
	_mark_changed_and_save()
	return {"success": true, "message": "Использовано: %s" % str(item.get("display_name_ru", item.get("name", "-")))}


func use_shelter_item(item: Dictionary) -> Dictionary:
	if item.is_empty() or str(item.get("category", "")) != "shelter":
		return {"success": false, "message": "Укрытие не найдено."}
	var stats: Dictionary = item.get("stats", {}) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}
	return _apply_rest_effect(stats, str(item.get("display_name_ru", item.get("name", "Укрытие"))))


func _apply_rest_effect(stats: Dictionary, source_name: String) -> Dictionary:
	var rest_minutes := maxf(float(stats.get("rest_minutes", 60.0)), 10.0)
	_advance_game_time(rest_minutes)
	if bool(stats.get("normalize_temperature", false)):
		PlayerData.body_temperature = DEFAULT_BODY_TEMPERATURE
	var restored_health := float(PlayerData.health) + float(stats.get("health_restore", 12.0))
	if stats.has("min_health"):
		restored_health = maxf(restored_health, float(stats.get("min_health", restored_health)))
	PlayerData.health = clampf(restored_health, 0.0, 100.0)
	PlayerData.hunger = clampf(float(PlayerData.hunger) - float(stats.get("hunger_cost", 6.0)), 0.0, 100.0)
	_mark_changed_and_save()
	return {"success": true, "message": "Отдых: %s. Состояние улучшилось." % source_name}


func _mark_changed_and_save() -> void:
	if PlayerData.has_method("ensure_condition_defaults"):
		PlayerData.ensure_condition_defaults()
	_dirty = true
	_emit_condition_changed(true)
	_save_now()


func get_environment_state() -> Dictionary:
	var time_manager := _get_time_manager()
	var weather_state := WeatherUIHelperScript.get_current_weather_state(time_manager)
	var wind_state := _get_wind_state()
	var time_state := {}
	if time_manager != null and time_manager.has_method("get_time_state"):
		var raw_time_state = time_manager.call("get_time_state")
		if raw_time_state is Dictionary:
			time_state = (raw_time_state as Dictionary).duplicate(true)

	return {
		"air_temperature": float(weather_state.get("temperature", 20.0)),
		"weather_type": str(weather_state.get("weather_type", "clear")),
		"time_of_day": str(weather_state.get("time_of_day", time_state.get("time_of_day", "morning"))),
		"wind_speed_mps": float(wind_state.get("speed_mps", 0.0)),
		"wind_gust_active": bool(wind_state.get("gust_active", false)),
		"weather": weather_state,
		"wind": wind_state,
		"time": time_state
	}


func _consume_elapsed_game_minutes(delta: float) -> float:
	var total_minutes := _get_total_game_minutes()
	var elapsed := 0.0
	if _last_total_game_minutes >= 0.0:
		elapsed = total_minutes - _last_total_game_minutes
	_last_total_game_minutes = total_minutes

	if elapsed <= 0.0:
		elapsed = delta * _get_fallback_game_minutes_per_real_second()
	return clampf(elapsed, 0.0, 180.0)


func _get_total_game_minutes() -> float:
	var time_manager := _get_time_manager()
	if time_manager != null:
		return float(time_manager.get("total_game_minutes"))
	return 525.0


func _get_fallback_game_minutes_per_real_second() -> float:
	var time_manager := _get_time_manager()
	if time_manager != null:
		return float(time_manager.get("game_minutes_per_real_second"))
	return 0.8


func _get_progression_survival_multiplier(key: String, fallback: float) -> float:
	var progression_db := get_node_or_null("/root/ProgressionDatabase")
	if progression_db == null or not progression_db.has_method("get_survival_multiplier_for_level"):
		return fallback
	var player_data := get_node_or_null("/root/PlayerData")
	var player_level: int = 1
	if player_data != null:
		player_level = maxi(int(player_data.get("level")), 1)
	var value = progression_db.call("get_survival_multiplier_for_level", player_level)
	if value is Dictionary:
		return clampf(float((value as Dictionary).get(key, fallback)), 0.0, 2.0)
	return fallback


func _get_target_body_temperature(environment: Dictionary) -> float:
	var air_temperature := float(environment.get("air_temperature", 20.0))
	var weather_type := str(environment.get("weather_type", "clear"))
	var time_of_day := str(environment.get("time_of_day", "day"))
	var wind_speed := float(environment.get("wind_speed_mps", 0.0))
	var target := DEFAULT_BODY_TEMPERATURE

	if air_temperature <= 10.0:
		target -= 0.35 + (10.0 - air_temperature) * 0.045
	elif air_temperature < 16.0:
		target -= (16.0 - air_temperature) * 0.018
	elif air_temperature > 27.0:
		target += (air_temperature - 27.0) * 0.055

	match _normalize_weather_type(weather_type):
		"storm":
			target -= 0.65
		"rain":
			target -= 0.45
		"cloudy":
			target -= 0.08

	if wind_speed > 3.0:
		target -= minf((wind_speed - 3.0) * 0.06, 0.45)
	if bool(environment.get("wind_gust_active", false)):
		target -= 0.10
	if time_of_day == "night":
		target -= 0.15
	elif time_of_day == "morning":
		target -= 0.05
	if air_temperature >= 29.0 and wind_speed < 1.0:
		target += 0.15

	target = _apply_clothing_temperature_modifier(target, environment)
	var impact_multiplier := _get_progression_survival_multiplier("temperature_impact_multiplier", 1.0)
	target = DEFAULT_BODY_TEMPERATURE + (target - DEFAULT_BODY_TEMPERATURE) * impact_multiplier
	return clampf(target, 33.4, 39.2)


func _apply_clothing_temperature_modifier(target: float, environment: Dictionary) -> float:
	if not PlayerData.has_method("get_clothing_protection"):
		return target
	var protection: Dictionary = PlayerData.get_clothing_protection()
	var air_temperature := float(environment.get("air_temperature", 20.0))
	var weather_type := _normalize_weather_type(str(environment.get("weather_type", "clear")))
	var wind_speed := float(environment.get("wind_speed_mps", 0.0))
	var cold_protection := float(protection.get("cold_protection", 0.0))
	var wind_protection := float(protection.get("wind_protection", 0.0))
	var rain_protection := float(protection.get("rain_protection", 0.0))
	var heat_protection := float(protection.get("heat_protection", 0.0))
	var warmth := float(protection.get("warmth", 0.0))
	var heat_penalty := float(protection.get("heat_penalty", 0.0))

	if target < DEFAULT_BODY_TEMPERATURE:
		var cold_gap := DEFAULT_BODY_TEMPERATURE - target
		var mitigation := cold_protection * 0.45 + wind_protection * 0.18 + warmth * 0.20
		if weather_type == "rain" or weather_type == "storm":
			mitigation += rain_protection * 0.32
		if wind_speed > 3.0:
			mitigation += wind_protection * 0.20
		target += minf(cold_gap * 0.75, mitigation)
	elif target > DEFAULT_BODY_TEMPERATURE:
		var hot_gap := target - DEFAULT_BODY_TEMPERATURE
		target -= minf(hot_gap * 0.65, heat_protection * 0.42)
		if air_temperature > 27.0:
			target += minf(heat_penalty * 0.24 + warmth * 0.06, 0.28)

	return target


func _get_body_temperature_rate(environment: Dictionary, target_temperature: float) -> float:
	var weather_type := _normalize_weather_type(str(environment.get("weather_type", "clear")))
	var wind_speed := float(environment.get("wind_speed_mps", 0.0))
	var rate := 0.004
	if abs(target_temperature - DEFAULT_BODY_TEMPERATURE) > 0.15:
		rate = 0.006
	if weather_type == "rain" or weather_type == "storm":
		rate += 0.002
	if wind_speed > 3.0:
		rate += minf((wind_speed - 3.0) * 0.0006, 0.003)
	return rate * _get_progression_survival_multiplier("temperature_impact_multiplier", 1.0)


func _get_wellbeing_delta_per_game_hour() -> float:
	var body_temperature := float(PlayerData.body_temperature)
	var hunger := float(PlayerData.hunger)
	var health_delta := 0.0

	if body_temperature < 34.5:
		health_delta -= 3.0
	elif body_temperature < 35.5:
		health_delta -= 1.0

	if body_temperature > 38.5:
		health_delta -= 3.0
	elif body_temperature > 37.6:
		health_delta -= 1.0

	if hunger < 10.0:
		health_delta -= 1.2

	if health_delta == 0.0 and hunger > 45.0 and body_temperature >= 36.0 and body_temperature <= 37.2:
		if float(PlayerData.health) < DEFAULT_HEALTH:
			health_delta += 0.35

	return health_delta


func _get_wellbeing_floor_for_current_state() -> float:
	var temperature_status := get_temperature_status()
	if ["cold", "freezing", "hot", "overheating"].has(temperature_status):
		return TEMPERATURE_WELLBEING_FLOOR
	if float(PlayerData.hunger) < 10.0:
		return HUNGER_WELLBEING_FLOOR
	return 0.0


func _maybe_emit_warnings() -> void:
	var temperature_status := get_temperature_status()
	if temperature_status == "cold" or temperature_status == "freezing":
		_try_emit_warning("cold", "Вы замерзаете. Нужно согреться.")
	elif temperature_status == "hot" or temperature_status == "overheating":
		_try_emit_warning("hot", "Вам жарко. Нужно охладиться.")

	if float(PlayerData.hunger) < 30.0:
		_try_emit_warning("hunger", "Вы голодны. Рыбачить становится сложнее.")

	if float(PlayerData.health) < 30.0:
		_try_emit_warning("critical_wellbeing", "Самочувствие очень низкое. Перекусите, выпейте что-нибудь или отдохните.")


func _try_emit_warning(warning_id: String, message: String) -> void:
	if float(_warning_cooldowns.get(warning_id, 0.0)) > 0.0:
		return
	_warning_cooldowns[warning_id] = WARNING_COOLDOWN_SECONDS
	condition_warning.emit(message, warning_id)


func _tick_warning_cooldowns(delta: float) -> void:
	for warning_id in _warning_cooldowns.keys():
		_warning_cooldowns[warning_id] = maxf(float(_warning_cooldowns[warning_id]) - delta, 0.0)


func _tick_condition_bonus(elapsed_game_minutes: float) -> void:
	if _condition_quality_bonus_minutes_remaining <= 0.0:
		_condition_quality_bonus = 0.0
		return
	_condition_quality_bonus_minutes_remaining = maxf(_condition_quality_bonus_minutes_remaining - elapsed_game_minutes, 0.0)
	if _condition_quality_bonus_minutes_remaining <= 0.0:
		_condition_quality_bonus = 0.0


func _emit_condition_changed(force: bool = false) -> void:
	var state := get_condition_state()
	if not force and not _has_state_changed_for_ui(state):
		return
	_last_emitted_state = state.duplicate(true)
	condition_changed.emit(state)


func _has_state_changed_for_ui(state: Dictionary) -> bool:
	if _last_emitted_state.is_empty():
		return true
	return (
		abs(float(state.get("health", 0.0)) - float(_last_emitted_state.get("health", -1.0))) >= 0.5
		or abs(float(state.get("body_temperature", 0.0)) - float(_last_emitted_state.get("body_temperature", -1.0))) >= 0.05
		or abs(float(state.get("hunger", 0.0)) - float(_last_emitted_state.get("hunger", -1.0))) >= 0.5
		or str(state.get("temperature_status", "")) != str(_last_emitted_state.get("temperature_status", ""))
		or str(state.get("hunger_status", "")) != str(_last_emitted_state.get("hunger_status", ""))
		or str(state.get("health_status", "")) != str(_last_emitted_state.get("health_status", ""))
	)


func _maybe_autosave(delta: float) -> void:
	if not _dirty:
		return
	_save_accumulator += delta
	if _save_accumulator < AUTOSAVE_INTERVAL_SECONDS:
		return
	_save_accumulator = 0.0
	_save_now()


func _save_now() -> void:
	_dirty = false
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null and save_manager.has_method("save_game"):
		save_manager.call_deferred("save_game")


func _advance_game_time(game_minutes: float) -> void:
	var time_manager := _get_time_manager()
	if time_manager != null and time_manager.has_method("advance_time"):
		time_manager.call("advance_time", maxf(game_minutes, 0.0))
	_last_total_game_minutes = _get_total_game_minutes()


func _get_wind_state() -> Dictionary:
	var wind_manager := get_node_or_null("/root/WindManager")
	if wind_manager == null:
		return {}
	if wind_manager.has_method("get_effective_wind_state"):
		var raw_effective = wind_manager.call("get_effective_wind_state", str(PlayerData.current_spot))
		if raw_effective is Dictionary:
			return (raw_effective as Dictionary).duplicate(true)
	if wind_manager.has_method("get_wind_state"):
		var raw_wind = wind_manager.call("get_wind_state")
		if raw_wind is Dictionary:
			return (raw_wind as Dictionary).duplicate(true)
	return {}


func _get_time_manager() -> Node:
	return get_node_or_null("/root/TimeManager")


func _normalize_weather_type(weather_type: String) -> String:
	match weather_type:
		"storm", "thunderstorm", "rain_with_thunderstorms":
			return "storm"
		"rain", "rainy":
			return "rain"
		"cloudy", "overcast", "fog", "mist", "night_mist":
			return "cloudy"
		_:
			return "clear"
