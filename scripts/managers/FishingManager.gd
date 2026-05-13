extends Node

signal fishing_started(seconds: int)
signal fishing_tick(seconds_left: int)
signal reeling_started(catch_data: Dictionary, state: Dictionary)
signal reeling_updated(state: Dictionary)
signal fish_caught(catch_data: Dictionary)
signal fishing_failed(message: String)

var is_fishing: bool = false
var is_reeling: bool = false

var _current_catch: Dictionary = {}
var _current_behavior: String = "calm"
var _reel_input_active: bool = false
var _tension: float = 0.5
var _tension_velocity: float = 0.0
var _player_force: float = 0.0
var _catch_progress: float = 0.0
var _control_value: float = 0.0
var _green_min: float = 0.38
var _green_max: float = 0.68
var _difficulty: float = 1.0
var _tackle_stats: Dictionary = {}
var _fish_force: float = 0.0
var _target_fish_force: float = 0.0
var _struggle_power: float = 0.0
var _struggle_event: String = "pause"
var _struggle_label: String = "пауза"
var _feedback_message: String = "Держи зеленую зону."
var _struggle_active: bool = false
var _struggle_timer: float = 0.0
var _next_struggle_timer: float = 0.0
var _high_danger_time: float = 0.0
var _low_danger_time: float = 0.0
var _critical_break_risk: float = 0.0
var _high_fail_limit: float = 1.15
var _low_fail_limit: float = 1.35
var _target_progress_time: float = 6.0

const PLAYER_PULL_FORCE := 1.18
const PLAYER_RELEASE_FORCE := -0.92
const PLAYER_FORCE_RESPONSE := 3.05
const FISH_FORCE_RESPONSE := 4.25
const TENSION_DAMPING := 2.95
const TENSION_VELOCITY_LIMIT := 0.72
const BASE_FISH_DRAG := -0.055
const PROGRESS_DECAY := 0.095
const NEAR_ZONE_PROGRESS_MARGIN := 0.12

func start_fishing(spot_id: String) -> void:
	if is_fishing:
		return

	var spot: Dictionary = SpotDatabase.get_spot(spot_id)

	if spot.is_empty():
		fishing_failed.emit("Точка клева не найдена.")
		return

	is_fishing = true
	is_reeling = false
	_reel_input_active = false
	_tackle_stats = PlayerData.get_tackle_stats()

	var bite_speed: float = clamp(
		1.0 + float(_tackle_stats.get("bite_detection_bonus", 0.0)) + float(_tackle_stats.get("fish_attraction", 0.0)) - float(_tackle_stats.get("visibility_penalty", 0.0)),
		0.65,
		1.45
	)
	var seconds: int = clamp(roundi(float(randi_range(3, 7)) / bite_speed), 2, 8)
	fishing_started.emit(seconds)

	for time_left in range(seconds, 0, -1):
		fishing_tick.emit(time_left)
		await get_tree().create_timer(1.0).timeout

	var available_fish: Array = _get_tackle_available_fish(spot["available_fish"])
	var bite_chance: float = clamp(
		0.72 + float(_tackle_stats.get("bite_detection_bonus", 0.0)) + float(_tackle_stats.get("fish_attraction", 0.0)) + float(_tackle_stats.get("hook_success_bonus", 0.0)) - float(_tackle_stats.get("visibility_penalty", 0.0)),
		0.30,
		0.98
	)

	if randf() > bite_chance:
		is_fishing = false
		fishing_failed.emit("Поклёвки не было. Попробуй другой темп или наживку.")
		return

	var fish_id: String = FishDatabase.get_random_fish_id(
		available_fish,
		spot["rare_chance_modifier"]
	)

	var catch_data: Dictionary = FishDatabase.create_catch(fish_id)
	catch_data["spot_name"] = spot["name"]

	_start_reeling(catch_data)

func _get_tackle_available_fish(spot_fish: Array) -> Array:
	var filtered_fish: Array = []
	var allowed_rarities: Array = _tackle_stats.get("allowed_rarities", [])
	var max_fish_weight: float = float(_tackle_stats.get("max_fish_weight", 1.0))
	var line_strength: float = float(_tackle_stats.get("line_strength", 1.0))
	var tackle_weight_limit: float = max(max_fish_weight * 1.25, line_strength * 4.0)

	for fish_id in spot_fish:
		var fish: Dictionary = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue

		var rarity: String = str(fish.get("rarity", "common"))
		if not allowed_rarities.is_empty() and not allowed_rarities.has(rarity):
			continue

		if float(fish.get("min_weight", 0.0)) > tackle_weight_limit:
			continue

		filtered_fish.append(fish_id)

	if filtered_fish.is_empty():
		return spot_fish

	return filtered_fish

func set_reel_input(active: bool) -> void:
	_reel_input_active = active and is_reeling

func _process(delta: float) -> void:
	if not is_reeling:
		return

	_update_struggle(delta)
	_update_tension(delta)
	_update_progress_and_danger(delta)

	if not is_reeling:
		return

	reeling_updated.emit(_get_reeling_state())

	if _catch_progress >= 1.0:
		_finish_reeling_success()

func _start_reeling(catch_data: Dictionary) -> void:
	_current_catch = catch_data
	is_reeling = true
	_reel_input_active = false
	_tackle_stats = PlayerData.get_tackle_stats()

	var fish: Dictionary = FishDatabase.get_fish(str(catch_data["id"]))
	var rarity: String = str(catch_data.get("rarity", "common"))
	_current_behavior = str(catch_data.get("behavior", fish.get("behavior", "calm")))

	var tuning: Dictionary = _get_behavior_tuning(_current_behavior)
	var rarity_factor: float = _get_rarity_factor(rarity)
	var min_weight: float = float(fish.get("min_weight", catch_data["weight"]))
	var max_weight: float = float(fish.get("max_weight", catch_data["weight"]))
	var weight_span: float = max(max_weight - min_weight, 0.01)
	var weight_ratio: float = clamp((float(catch_data["weight"]) - min_weight) / weight_span, 0.0, 1.0)
	var catch_weight: float = float(catch_data.get("weight", 0.0))
	var rod_capacity_ratio: float = catch_weight / max(float(_tackle_stats.get("max_fish_weight", 1.0)), 0.1)
	var line_capacity_ratio: float = catch_weight / max(float(_tackle_stats.get("line_strength", 1.0)), 0.1)
	var overload_penalty: float = max(max(rod_capacity_ratio - 1.0, 0.0), max(line_capacity_ratio - 1.0, 0.0) * 0.42)

	_difficulty = clamp(rarity_factor + weight_ratio * 0.55 + overload_penalty * 0.25, 0.85, 2.85)
	_catch_progress = 0.0
	_control_value = 0.0
	_fish_force = 0.0
	_target_fish_force = 0.0
	_struggle_power = 0.0
	_struggle_event = "pause"
	_struggle_label = "пауза"
	_feedback_message = "Держи зеленую зону."
	_struggle_active = false
	_struggle_timer = 0.0
	_next_struggle_timer = clamp(_get_next_struggle_interval() * randf_range(0.45, 0.75), 0.25, 1.15)
	_high_danger_time = 0.0
	_low_danger_time = 0.0
	_critical_break_risk = 0.0
	_tension_velocity = 0.0
	_player_force = 0.0

	var green_width: float = clamp(
		(0.36 - (_difficulty - 1.0) * 0.075)
		* float(tuning["green_width"])
		* (1.0 + float(_tackle_stats.get("control_bonus", 0.0)) + float(_tackle_stats.get("stability", 0.0))),
		0.16,
		0.38
	)
	var green_center: float = clamp(0.54 + randf_range(-0.045, 0.045), 0.43, 0.63)
	_green_min = clamp(green_center - green_width * 0.5, 0.16, 0.72)
	_green_max = clamp(green_center + green_width * 0.5, _green_min + 0.11, 0.88)
	_tension = clamp((_green_min + _green_max) * 0.5 - 0.04, 0.18, 0.82)

	var break_safety: float = float(_tackle_stats.get("break_resistance", 1.0)) * float(_tackle_stats.get("durability", 1.0))
	var escape_safety: float = (1.0 / max(float(_tackle_stats.get("fish_escape_modifier", 1.0)), 0.2)) + float(_tackle_stats.get("hook_success_bonus", 0.0))
	_high_fail_limit = clamp((1.30 * break_safety) / (_difficulty * float(tuning["danger"]) * (1.0 + overload_penalty * 0.45)), 0.42, 1.55)
	_low_fail_limit = clamp((1.52 * escape_safety) / (_difficulty * float(tuning["danger"])), 0.62, 1.85)
	_target_progress_time = clamp(
		(4.9 + _difficulty * 1.85) * float(tuning["progress_time"]) / (1.0 + float(_tackle_stats.get("control_bonus", 0.0)) + float(_tackle_stats.get("hook_success_bonus", 0.0))),
		5.5,
		12.5
	)

	reeling_started.emit(_current_catch, _get_reeling_state())
	reeling_updated.emit(_get_reeling_state())

func _update_struggle(delta: float) -> void:
	if _struggle_active:
		_struggle_timer -= delta

		if _struggle_timer <= 0.0:
			_struggle_active = false
			_target_fish_force = 0.0
			_struggle_event = "recovery"
			_struggle_label = "восстановление"
			_feedback_message = "Рыба устала!"
			_next_struggle_timer = _get_next_struggle_interval()
	else:
		_next_struggle_timer -= delta

		if _next_struggle_timer <= 0.0:
			_start_struggle_event(_pick_struggle_event())

	var tuning: Dictionary = _get_behavior_tuning(_current_behavior)
	var response: float = FISH_FORCE_RESPONSE * float(tuning["force_response"])

	_fish_force = lerp(_fish_force, _target_fish_force, clamp(delta * response, 0.0, 1.0))
	_struggle_power = abs(_fish_force)

func _start_struggle_event(event_name: String) -> void:
	var tuning: Dictionary = _get_behavior_tuning(_current_behavior)
	var power_scale: float = float(tuning["power"]) * _difficulty
	var event_power: float = 0.0
	var duration: float = 0.0
	var label: String = ""

	match event_name:
		"short_jerk":
			event_power = randf_range(0.42, 0.66) * power_scale
			duration = randf_range(0.18, 0.34)
			label = "короткий рывок"
			_feedback_message = "Рыба дернулась!"
		"long_pull":
			event_power = randf_range(0.24, 0.43) * power_scale
			duration = randf_range(0.85, 1.65)
			label = "длинный сильный рывок"
			_feedback_message = "Рыба давит вниз!"
		"weak_resistance":
			event_power = randf_range(0.10, 0.21) * power_scale
			duration = randf_range(0.55, 1.15)
			label = "слабое сопротивление"
			_feedback_message = "Рыба устала!"
		_:
			event_power = -randf_range(0.04, 0.12) * max(_difficulty, 0.9)
			duration = randf_range(0.45, 1.0)
			label = "пауза"
			event_name = "pause"
			_feedback_message = "Рыба устала!"

	if _current_behavior == "aggressive" and event_name == "short_jerk":
		event_power *= randf_range(1.10, 1.28)
		duration *= randf_range(0.72, 0.90)
	elif _current_behavior == "heavy" and event_name == "long_pull":
		event_power *= randf_range(1.10, 1.25)
		duration *= randf_range(1.22, 1.45)
	elif _current_behavior == "calm":
		event_power *= 0.82
		duration *= randf_range(0.85, 1.05)

	if _current_behavior == "erratic" and event_name != "long_pull" and randf() < 0.24:
		event_power *= -0.72
		label = "резкий провал"
		_feedback_message = "Рыба дернулась!"

	_target_fish_force = clamp(event_power, -0.42, 1.02)
	_struggle_timer = duration
	_struggle_event = event_name
	_struggle_label = label
	_struggle_active = true

func _pick_struggle_event() -> String:
	var tuning: Dictionary = _get_behavior_tuning(_current_behavior)
	var short_weight: float = float(tuning["short_jerk"])
	var long_weight: float = float(tuning["long_pull"])
	var weak_weight: float = float(tuning["weak_resistance"])
	var pause_weight: float = float(tuning["pause"])
	var total_weight: float = short_weight + long_weight + weak_weight + pause_weight
	var roll: float = randf() * total_weight

	if roll < short_weight:
		return "short_jerk"

	roll -= short_weight
	if roll < long_weight:
		return "long_pull"

	roll -= long_weight
	if roll < weak_weight:
		return "weak_resistance"

	return "pause"

func _get_next_struggle_interval() -> float:
	var tuning: Dictionary = _get_behavior_tuning(_current_behavior)
	var frequency: float = float(tuning["frequency"])
	var min_interval: float = 0.85
	var max_interval: float = 1.75

	match _current_behavior:
		"aggressive":
			min_interval = 0.45
			max_interval = 1.10
		"heavy":
			min_interval = 1.15
			max_interval = 2.45
		"erratic":
			min_interval = 0.38
			max_interval = 2.55
		_:
			min_interval = 1.35
			max_interval = 2.95

	var interval: float = randf_range(min_interval, max_interval) / max(_difficulty * frequency, 0.1)
	return clamp(interval, 0.26, 3.1)

func _update_tension(delta: float) -> void:
	var tuning: Dictionary = _get_behavior_tuning(_current_behavior)
	var player_target: float = PLAYER_PULL_FORCE if _reel_input_active else PLAYER_RELEASE_FORCE
	var player_response: float = PLAYER_FORCE_RESPONSE * float(tuning["player_response"])
	_player_force = lerp(_player_force, player_target, clamp(delta * player_response, 0.0, 1.0))

	var drag: float = BASE_FISH_DRAG * _difficulty
	var damping: float = TENSION_DAMPING * float(tuning["damping"])
	var acceleration: float = _player_force + _fish_force + drag - _tension_velocity * damping

	_tension_velocity = clamp(
		_tension_velocity + acceleration * delta,
		-TENSION_VELOCITY_LIMIT,
		TENSION_VELOCITY_LIMIT
	)
	_tension = clamp(_tension + _tension_velocity * delta, 0.0, 1.0)

	if _tension <= 0.0 and _tension_velocity < 0.0:
		_tension_velocity = 0.0
	elif _tension >= 1.0 and _tension_velocity > 0.0:
		_tension_velocity = 0.0

func _update_progress_and_danger(delta: float) -> void:
	var green_center: float = (_green_min + _green_max) * 0.5
	var green_half_width: float = max((_green_max - _green_min) * 0.5, 0.01)
	var distance_from_center: float = abs(_tension - green_center)
	var in_green_zone: bool = _tension >= _green_min and _tension <= _green_max
	var near_margin: float = max(NEAR_ZONE_PROGRESS_MARGIN, (_green_max - _green_min) * 0.62)

	_control_value = clamp(1.0 - distance_from_center / green_half_width, 0.0, 1.0)

	if in_green_zone:
		var control_bonus: float = lerp(1.05, 1.62, _control_value)
		_catch_progress = clamp(_catch_progress + delta * control_bonus / _target_progress_time, 0.0, 1.0)
		_high_danger_time = max(_high_danger_time - delta * 1.7, 0.0)
		_low_danger_time = max(_low_danger_time - delta * 1.7, 0.0)

		if _struggle_event == "recovery" or _struggle_event == "pause" or _struggle_event == "weak_resistance":
			_feedback_message = "Рыба устала!"
	else:
		var outside_distance: float = 0.0
		var near_zone_factor: float = 0.0

		if _tension > _green_max:
			near_zone_factor = clamp((_tension - _green_max) / near_margin, 0.0, 1.0)
			outside_distance = inverse_lerp(_green_max, 1.0, _tension)
			_high_danger_time += delta * lerp(0.42, 2.18, outside_distance)
			_low_danger_time = max(_low_danger_time - delta, 0.0)

			if outside_distance > 0.72 or _critical_break_risk > 0.45:
				_feedback_message = "Осторожно, обрыв!"
			else:
				_feedback_message = "Леска натянута!"
		elif _tension < _green_min:
			near_zone_factor = clamp((_green_min - _tension) / near_margin, 0.0, 1.0)
			outside_distance = inverse_lerp(_green_min, 0.0, _tension)
			_low_danger_time += delta * lerp(0.42, 1.96, outside_distance)
			_high_danger_time = max(_high_danger_time - delta, 0.0)
			_feedback_message = "Слабина. Подтяни леску!"

		if near_zone_factor < 1.0:
			var slow_progress: float = lerp(0.42, 0.08, near_zone_factor)
			_catch_progress = clamp(_catch_progress + delta * slow_progress / _target_progress_time, 0.0, 1.0)
		else:
			_catch_progress = max(_catch_progress - delta * PROGRESS_DECAY * lerp(0.65, 1.45, outside_distance), 0.0)

	_update_critical_break(delta)

	if not is_reeling:
		return

	if _high_danger_time >= _high_fail_limit:
		_finish_reeling_failed("Леска не выдержала натяжения. Рыба сорвалась.")
	elif _low_danger_time >= _low_fail_limit:
		_finish_reeling_failed("Натяжение упало. Рыба сошла с крючка.")

func _update_critical_break(delta: float) -> void:
	_critical_break_risk = 0.0

	if _tension < 0.94:
		return

	var severity: float = inverse_lerp(0.94, 1.0, _tension)
	var force_bonus: float = clamp(_struggle_power * 0.35, 0.0, 0.35)
	var catch_weight: float = float(_current_catch.get("weight", 0.0))
	var line_pressure: float = catch_weight / max(float(_tackle_stats.get("line_strength", 1.0)), 0.1)
	var break_safety: float = max(float(_tackle_stats.get("break_resistance", 1.0)) * float(_tackle_stats.get("durability", 1.0)), 0.1)
	_critical_break_risk = clamp(((0.10 + severity * 0.55) * _difficulty + force_bonus) * max(line_pressure, 0.75) / break_safety, 0.0, 1.0)
	_feedback_message = "Осторожно, обрыв!"

	if randf() < _critical_break_risk * 0.32 * delta:
		_finish_reeling_failed("Критическое натяжение. Снасть сломалась.")

func _finish_reeling_success() -> void:
	if not is_reeling:
		return

	var catch_data: Dictionary = _current_catch.duplicate(true)
	var added: bool = InventoryManager.add_fish(catch_data)

	is_fishing = false
	is_reeling = false
	_reel_input_active = false
	_current_catch = {}

	if added:
		var signal_data: Dictionary = catch_data.duplicate(true)
		signal_data["xp_result"] = _award_catch_xp(catch_data)
		fish_caught.emit(signal_data)
	else:
		fishing_failed.emit("Садок заполнен. Продай рыбу перед новой ловлей.")

func _finish_reeling_failed(message: String) -> void:
	if not is_reeling:
		return

	is_fishing = false
	is_reeling = false
	_reel_input_active = false
	_current_catch = {}
	fishing_failed.emit(message)

func _award_catch_xp(catch_data: Dictionary) -> Dictionary:
	var base_xp: int = int(catch_data.get("base_xp", 5))
	var weight_bonus: int = max(roundi(float(catch_data.get("weight", 0.0)) * 2.0), 0)
	var total_xp: int = base_xp + weight_bonus
	return PlayerData.add_xp(total_xp)

func _get_rarity_factor(rarity: String) -> float:
	match rarity:
		"uncommon":
			return 1.12
		"rare":
			return 1.42
		"legendary":
			return 1.82
		_:
			return 0.90

func _get_behavior_tuning(behavior: String) -> Dictionary:
	match behavior:
		"aggressive":
			return {
				"power": 1.12,
				"frequency": 1.55,
				"green_width": 0.92,
				"progress_time": 1.00,
				"danger": 1.05,
				"damping": 0.95,
				"player_response": 1.00,
				"force_response": 1.22,
				"short_jerk": 3.20,
				"long_pull": 0.85,
				"weak_resistance": 0.85,
				"pause": 0.45
			}
		"heavy":
			return {
				"power": 1.38,
				"frequency": 0.76,
				"green_width": 0.88,
				"progress_time": 1.28,
				"danger": 1.08,
				"damping": 0.72,
				"player_response": 0.78,
				"force_response": 0.52,
				"short_jerk": 0.45,
				"long_pull": 3.15,
				"weak_resistance": 0.80,
				"pause": 0.55
			}
		"erratic":
			return {
				"power": 1.10,
				"frequency": 1.42,
				"green_width": 0.84,
				"progress_time": 1.10,
				"danger": 1.12,
				"damping": 0.90,
				"player_response": 0.95,
				"force_response": 1.38,
				"short_jerk": 2.05,
				"long_pull": 1.20,
				"weak_resistance": 0.65,
				"pause": 1.75
			}
		_:
			return {
				"power": 0.62,
				"frequency": 0.62,
				"green_width": 1.14,
				"progress_time": 0.88,
				"danger": 0.92,
				"damping": 1.16,
				"player_response": 1.08,
				"force_response": 0.72,
				"short_jerk": 0.45,
				"long_pull": 0.25,
				"weak_resistance": 2.55,
				"pause": 2.35
			}

func _get_reeling_state() -> Dictionary:
	var tension_status := "green"

	if _tension > _green_max:
		tension_status = "high"
	elif _tension < _green_min:
		tension_status = "low"

	return {
		"tension": _tension,
		"green_min": _green_min,
		"green_max": _green_max,
		"control": _control_value,
		"progress": _catch_progress,
		"catch_progress": _catch_progress,
		"difficulty": _difficulty,
		"fish_force": _fish_force,
		"struggle_power": _struggle_power,
		"struggle_event": _struggle_label,
		"feedback_message": _feedback_message,
		"behavior": _current_behavior,
		"critical_break_risk": _critical_break_risk,
		"input_active": _reel_input_active,
		"status": tension_status,
		"high_danger": clamp(_high_danger_time / _high_fail_limit, 0.0, 1.0),
		"low_danger": clamp(_low_danger_time / _low_fail_limit, 0.0, 1.0)
	}
