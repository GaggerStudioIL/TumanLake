extends Node

signal fishing_started(seconds: int)
signal fishing_tick(seconds_left: int)
signal reeling_started(catch_data: Dictionary, state: Dictionary)
signal reeling_updated(state: Dictionary)
signal fish_caught(catch_data: Dictionary)
signal fishing_failed(message: String)
signal fishing_failed_detailed(failure_data: Dictionary)
signal cast_started()
signal waiting_for_bite_started()
signal float_nudge(nudge_data: Dictionary)
signal bite_started(bite_data: Dictionary)
signal bite_window_updated(bite_data: Dictionary)
signal hook_success(catch_data: Dictionary)
signal hook_failed(reason: String, data: Dictionary)

enum FishingState {
	IDLE,
	CASTING,
	WAITING_FOR_BITE,
	BITE_WINDOW,
	HOOKED,
	REELING,
	CAUGHT,
	FAILED
}

var is_fishing: bool = false
var is_reeling: bool = false
var use_new_bite_system := true
var fishing_state: int = FishingState.IDLE

var _current_catch: Dictionary = {}
var _pending_catch: Dictionary = {}
var _pending_bite_data: Dictionary = {}
var _active_spot: Dictionary = {}
var _active_spot_id: String = ""
var _active_available_fish: Array = []
var _active_spot_depth_modifier: float = 1.0
var _bite_check_timer: float = 0.0
var _bite_window_elapsed: float = 0.0
var _bite_window_seconds: float = 0.0
var _false_nudge_timer: float = 0.0
var _hook_cooldown_timer: float = 0.0
var _fishing_cycle_id := 0
var _last_hook_attempt_msec := 0
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
var _fight_power: float = 1.0
var _fish_stamina: float = 1.0
var _fish_strength: float = 1.0
var _fish_aggression: float = 0.5
var _escape_risk: float = 0.25
var _escape_chance: float = 0.25
var _weight_difficulty: float = 1.0
var _line_pressure: float = 1.0
var _effective_load_kg: float = 0.0
var _line_load_ratio: float = 0.0
var _rod_load_ratio: float = 0.0
var _rod_overload_time: float = 0.0
var _line_overload_time: float = 0.0
var _wear_pressure: float = 0.0
var _last_fail_kind: String = ""
var _weight_ratio: float = 0.0
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

const USE_NEW_BITE_SYSTEM := true
const BITE_CHECK_INTERVAL := 1.0
const BASE_BITE_WINDOW_SECONDS := 1.4
const EARLY_HOOK_COOLDOWN := 1.5
const FALSE_NUDGE_MIN_DELAY := 1.2
const FALSE_NUDGE_MAX_DELAY := 3.2
const FALSE_NUDGE_CHANCE := 0.28
const HOOK_INPUT_GUARD_MSEC := 260
const PLAYER_PULL_FORCE := 1.18
const PLAYER_RELEASE_FORCE := -0.92
const PLAYER_FORCE_RESPONSE := 3.05
const FISH_FORCE_RESPONSE := 4.25
const TENSION_DAMPING := 2.95
const TENSION_VELOCITY_LIMIT := 0.72
const BASE_FISH_DRAG := -0.055
const PROGRESS_DECAY := 0.095
const NEAR_ZONE_PROGRESS_MARGIN := 0.12
const FAILURE_NO_BITE := "NO_BITE"
const FAILURE_BAD_DEPTH := "BAD_DEPTH"
const FAILURE_BAD_BAIT := "BAD_BAIT"
const FAILURE_BAD_HOOK := "BAD_HOOK"
const FAILURE_WEAK_TACKLE := "WEAK_TACKLE"
const FAILURE_LINE_BROKE := "LINE_BROKE"
const FAILURE_ROD_OVERLOAD := "ROD_OVERLOAD"
const FAILURE_FISH_ESCAPED_LOW_TENSION := "FISH_ESCAPED_LOW_TENSION"
const FAILURE_FISH_ESCAPED_HIGH_TENSION := "FISH_ESCAPED_HIGH_TENSION"
const FAILURE_FISH_ESCAPED_HOOK := "FISH_ESCAPED_HOOK"
const FAILURE_FISH_TOO_STRONG := "FISH_TOO_STRONG"
const FAILURE_UNKNOWN := "UNKNOWN"

func get_bite_candidates(spot_id: String) -> Array:
	var spot: Dictionary = SpotDatabase.get_spot(spot_id)

	if spot.is_empty():
		return []

	var previous_tackle_stats := _tackle_stats.duplicate(true)
	_tackle_stats = PlayerData.get_tackle_stats()
	# TODO: Wire depth_match_bonus and no_bite_reduction into the pre-bite odds after the no-bite balance pass.
	# TODO: Wire fish_jerk_reduction, escape_risk_reduction, and hook_escape_reduction into reeling after tuning tests.
	var candidates := _get_tackle_available_fish(spot.get("available_fish", []))
	_tackle_stats = previous_tackle_stats
	return candidates

func start_fishing(spot_id: String) -> void:
	if is_fishing:
		return

	_fishing_cycle_id += 1
	var cycle_id := _fishing_cycle_id
	var spot: Dictionary = SpotDatabase.get_spot(spot_id)

	if spot.is_empty():
		_emit_fishing_failure(
			FAILURE_UNKNOWN,
			"Точка не найдена",
			"Точка клёва не найдена.",
			"Выберите доступную точку ловли на карте.",
			{"severity": "low", "spot_id": spot_id}
		)
		return

	is_fishing = true
	is_reeling = false
	fishing_state = FishingState.CASTING
	_reel_input_active = false
	_last_hook_attempt_msec = 0
	_clear_active_bite_data()
	_tackle_stats = PlayerData.get_tackle_stats()
	cast_started.emit()
	var tackle_block_reason := PlayerData.get_tackle_block_reason()
	if tackle_block_reason != "":
		is_fishing = false
		fishing_state = FishingState.FAILED
		_emit_fishing_failure(
			FAILURE_WEAK_TACKLE,
			"Снасть не готова",
			tackle_block_reason,
			"Проверьте удочку, леску, крючок и наживку перед забросом.",
			{"severity": "medium", "spot_id": spot_id}
		)
		return

	var available_fish: Array = _get_tackle_available_fish(spot["available_fish"])
	var spot_depth_modifier: float = _get_spot_depth_match_multiplier(spot)

	if available_fish.is_empty():
		if use_new_bite_system:
			is_fishing = false
			fishing_state = FishingState.FAILED
			_emit_no_candidate_failure(spot, spot_id)
			return

		var slow_seconds: int = randi_range(10, 16)
		fishing_started.emit(slow_seconds)

		for time_left in range(slow_seconds, 0, -1):
			if not _is_fishing_cycle_current(cycle_id):
				return
			fishing_tick.emit(time_left)
			await get_tree().create_timer(1.0).timeout
			if not _is_fishing_cycle_current(cycle_id):
				return

		is_fishing = false
		_emit_no_candidate_failure(spot, spot_id)
		return

	var bait_bonus: float = _get_best_bait_bonus(available_fish)
	var time_activity_modifier: float = _get_average_time_activity_modifier(available_fish)
	var spot_bite_modifier: float = float(spot.get("bite_chance_modifier", 1.0)) * spot_depth_modifier

	if use_new_bite_system:
		_start_waiting_for_active_bite(spot, spot_id, available_fish, spot_depth_modifier)
		return

	var bite_speed: float = clamp(
		(1.0 + float(_tackle_stats.get("bite_detection_bonus", 0.0)) + float(_tackle_stats.get("fish_attraction", 0.0)) + bait_bonus * 0.35 - float(_tackle_stats.get("visibility_penalty", 0.0))) * spot_bite_modifier * clamp(time_activity_modifier, 0.55, 1.35),
		0.65,
		1.45
	)
	var seconds: int = clamp(roundi(float(randi_range(3, 7)) / bite_speed), 2, 8)
	fishing_started.emit(seconds)

	for time_left in range(seconds, 0, -1):
		if not _is_fishing_cycle_current(cycle_id):
			return
		fishing_tick.emit(time_left)
		await get_tree().create_timer(1.0).timeout
		if not _is_fishing_cycle_current(cycle_id):
			return

	var bite_chance: float = clamp(
		(0.64 + float(_tackle_stats.get("bite_detection_bonus", 0.0)) + float(_tackle_stats.get("fish_attraction", 0.0)) + bait_bonus + float(_tackle_stats.get("hook_success_bonus", 0.0)) - float(_tackle_stats.get("visibility_penalty", 0.0))) * spot_bite_modifier * clamp(time_activity_modifier, 0.42, 1.38),
		0.30,
		0.98
	)

	if randf() > bite_chance:
		is_fishing = false
		_emit_fishing_failure(
			FAILURE_NO_BITE,
			"",
			"",
			"",
			{
				"severity": "low",
				"bite_chance": bite_chance,
				"spot_depth_modifier": spot_depth_modifier,
				"bait_bonus": bait_bonus,
				"time_activity_modifier": time_activity_modifier
			}
		)
		return

	var fish_id: String = _get_random_tackle_fish_id(
		available_fish,
		spot["rare_chance_modifier"]
	)

	if not PlayerData.consume_current_tackle_baits(1):
		is_fishing = false
		_emit_fishing_failure(
			FAILURE_WEAK_TACKLE,
			"Нет наживки",
			"Наживка закончилась до поклёвки.",
			"Пополните наживку или экипируйте другую.",
			{"severity": "low", "spot_id": spot_id}
		)
		return

	var catch_fish := FishDatabase.get_fish(fish_id)
	var catch_data: Dictionary = FishDatabase.create_catch(fish_id, _get_time_peak_modifier(catch_fish))
	if catch_data.is_empty():
		is_fishing = false
		_emit_fishing_failure(
			FAILURE_FISH_ESCAPED_HOOK,
			"",
			"Рыба сорвалась до подсечки.",
			"Проверьте размер крючка, наживку и состояние снасти.",
			{"severity": "medium", "fish_id": fish_id, "spot_id": spot_id}
		)
		return

	catch_data["spot_id"] = str(spot.get("id", spot_id))
	catch_data["spot_name"] = spot["name"]
	catch_data["waterbody_id"] = str(spot.get("waterbody_id", PlayerData.current_waterbody))
	catch_data["waterbody_name"] = str(spot.get("waterbody_name", ""))
	catch_data = FishFreshnessManager.stamp_catch(catch_data)

	_start_reeling(catch_data)

func try_hook() -> void:
	if not use_new_bite_system:
		return

	if not is_fishing or is_reeling:
		return

	if fishing_state != FishingState.WAITING_FOR_BITE and fishing_state != FishingState.BITE_WINDOW:
		return

	var now := Time.get_ticks_msec()
	if now - _last_hook_attempt_msec < HOOK_INPUT_GUARD_MSEC:
		return
	_last_hook_attempt_msec = now

	if fishing_state == FishingState.WAITING_FOR_BITE:
		if _hook_cooldown_timer > 0.0:
			return

		_fail_hook("too_early", {
			"message": "Рыба испугалась!",
			"cooldown": EARLY_HOOK_COOLDOWN
		})
		return

	if fishing_state != FishingState.BITE_WINDOW:
		return

	var elapsed := _bite_window_elapsed
	var perfect_start := float(_pending_bite_data.get("perfect_start", 0.35))
	var perfect_end := float(_pending_bite_data.get("perfect_end", 1.05))

	if elapsed < perfect_start:
		_fail_hook("early_hook", {
			"elapsed": elapsed,
			"perfect_start": perfect_start,
			"message": "Рано!"
		})
		return

	if elapsed > perfect_end:
		_fail_hook("late_hook", {
			"elapsed": elapsed,
			"perfect_end": perfect_end,
			"message": "Поздно!"
		})
		return

	var catch_data := _pending_catch.duplicate(true)
	_pending_catch.clear()
	_pending_bite_data.clear()
	_bite_window_elapsed = 0.0
	_bite_window_seconds = 0.0
	fishing_state = FishingState.HOOKED
	hook_success.emit(catch_data.duplicate(true))
	_start_reeling(catch_data)


func _start_waiting_for_active_bite(spot: Dictionary, spot_id: String, available_fish: Array, spot_depth_modifier: float) -> void:
	_active_spot = spot.duplicate(true)
	_active_spot_id = spot_id
	_active_available_fish = available_fish.duplicate()
	_active_spot_depth_modifier = spot_depth_modifier
	_pending_catch.clear()
	_pending_bite_data.clear()
	_bite_check_timer = BITE_CHECK_INTERVAL
	_bite_window_elapsed = 0.0
	_bite_window_seconds = 0.0
	_false_nudge_timer = randf_range(FALSE_NUDGE_MIN_DELAY, FALSE_NUDGE_MAX_DELAY)
	_hook_cooldown_timer = 0.0
	fishing_state = FishingState.WAITING_FOR_BITE
	waiting_for_bite_started.emit()
	fishing_started.emit(0)


func _update_active_bite_system(delta: float) -> void:
	if not is_fishing or is_reeling:
		return

	if fishing_state == FishingState.WAITING_FOR_BITE:
		_hook_cooldown_timer = max(_hook_cooldown_timer - delta, 0.0)
		_update_false_nudge(delta)

		if _hook_cooldown_timer > 0.0:
			return

		_bite_check_timer -= delta
		if _bite_check_timer <= 0.0:
			_bite_check_timer = BITE_CHECK_INTERVAL
			_try_start_active_bite()
	elif fishing_state == FishingState.BITE_WINDOW:
		_bite_window_elapsed += delta
		var updated_data := _pending_bite_data.duplicate(true)
		updated_data["elapsed"] = _bite_window_elapsed
		updated_data["remaining"] = max(_bite_window_seconds - _bite_window_elapsed, 0.0)
		bite_window_updated.emit(updated_data)

		if _bite_window_elapsed >= _bite_window_seconds:
			_fail_hook("missed_bite", {
				"elapsed": _bite_window_elapsed,
				"message": "Рыба сорвалась!"
			})


func _update_false_nudge(delta: float) -> void:
	_false_nudge_timer -= delta
	if _false_nudge_timer > 0.0:
		return

	_false_nudge_timer = randf_range(FALSE_NUDGE_MIN_DELAY, FALSE_NUDGE_MAX_DELAY)
	if randf() > FALSE_NUDGE_CHANCE:
		return

	float_nudge.emit(_build_false_nudge_data())


func _build_false_nudge_data() -> Dictionary:
	var roll := randf()
	var kind := "small"
	var strength := randf_range(0.18, 0.32)
	var duration := randf_range(0.26, 0.42)

	if roll > 0.82:
		kind = "suspicious"
		strength = randf_range(0.46, 0.62)
		duration = randf_range(0.42, 0.62)
	elif roll > 0.52:
		kind = "medium"
		strength = randf_range(0.30, 0.46)
		duration = randf_range(0.34, 0.52)

	return {
		"kind": kind,
		"strength": strength,
		"duration": duration
	}


func _try_start_active_bite() -> void:
	if _active_available_fish.is_empty() or _active_spot.is_empty():
		is_fishing = false
		fishing_state = FishingState.FAILED
		_emit_no_candidate_failure(_active_spot, _active_spot_id)
		return

	var bite_data := _get_active_bite_balance_data()
	var bite_chance := float(bite_data.get("bite_chance", 0.08))
	if randf() > bite_chance:
		return

	var fish_id: String = _get_random_tackle_fish_id(
		_active_available_fish,
		float(_active_spot.get("rare_chance_modifier", 1.0))
	)

	if not PlayerData.consume_current_tackle_baits(1):
		is_fishing = false
		fishing_state = FishingState.FAILED
		_emit_fishing_failure(
			FAILURE_WEAK_TACKLE,
			"Нет наживки",
			"Наживка закончилась до поклёвки.",
			"Пополните наживку или экипируйте другую.",
			{"severity": "low", "spot_id": _active_spot_id}
		)
		return

	var catch_data := _prepare_catch_data_for_bite(fish_id)
	if catch_data.is_empty():
		is_fishing = false
		fishing_state = FishingState.FAILED
		_emit_fishing_failure(
			FAILURE_FISH_ESCAPED_HOOK,
			"",
			"Рыба сорвалась до подсечки.",
			"Проверьте размер крючка, наживку и состояние снасти.",
			{"severity": "medium", "fish_id": fish_id, "spot_id": _active_spot_id}
		)
		return

	_pending_catch = catch_data
	_pending_bite_data = _build_bite_window_data(fish_id, catch_data, bite_data)
	_bite_window_seconds = float(_pending_bite_data.get("bite_window_seconds", BASE_BITE_WINDOW_SECONDS))
	_bite_window_elapsed = 0.0
	fishing_state = FishingState.BITE_WINDOW
	bite_started.emit(_pending_bite_data.duplicate(true))


func _get_active_bite_balance_data() -> Dictionary:
	var bait_bonus: float = _get_best_bait_bonus(_active_available_fish)
	var time_activity_modifier: float = _get_average_time_activity_modifier(_active_available_fish)
	var spot_bite_modifier: float = float(_active_spot.get("bite_chance_modifier", 1.0)) * _active_spot_depth_modifier
	var bite_chance: float = clamp(
		(
			0.085
			+ float(_tackle_stats.get("bite_detection_bonus", 0.0)) * 0.10
			+ float(_tackle_stats.get("fish_attraction", 0.0)) * 0.10
			+ bait_bonus * 0.09
			+ float(_tackle_stats.get("hook_success_bonus", 0.0)) * 0.06
			- float(_tackle_stats.get("visibility_penalty", 0.0)) * 0.08
		) * spot_bite_modifier * clamp(time_activity_modifier, 0.42, 1.38),
		0.04,
		0.22
	)

	return {
		"bite_chance": bite_chance,
		"spot_depth_modifier": _active_spot_depth_modifier,
		"bait_bonus": bait_bonus,
		"time_activity_modifier": time_activity_modifier,
		"spot_bite_modifier": spot_bite_modifier
	}


func _prepare_catch_data_for_bite(fish_id: String) -> Dictionary:
	var catch_fish := FishDatabase.get_fish(fish_id)
	var catch_data: Dictionary = FishDatabase.create_catch(fish_id, _get_time_peak_modifier(catch_fish))
	if catch_data.is_empty():
		return {}

	catch_data["spot_id"] = str(_active_spot.get("id", _active_spot_id))
	catch_data["spot_name"] = str(_active_spot.get("name", "-"))
	catch_data["waterbody_id"] = str(_active_spot.get("waterbody_id", PlayerData.current_waterbody))
	catch_data["waterbody_name"] = str(_active_spot.get("waterbody_name", ""))
	return FishFreshnessManager.stamp_catch(catch_data)


func _build_bite_window_data(fish_id: String, catch_data: Dictionary, balance_data: Dictionary) -> Dictionary:
	var fish := FishDatabase.get_fish(fish_id)
	var rarity := str(catch_data.get("rarity", fish.get("rarity", "common")))
	var behavior := str(catch_data.get("behavior_type", catch_data.get("behavior", fish.get("behavior_type", fish.get("behavior", "calm")))))
	var weight := float(catch_data.get("weight", 0.0))
	var max_weight: float = max(float(fish.get("max_weight", max(weight, 1.0))), 0.1)
	var size_ratio: float = clamp(weight / max_weight, 0.0, 1.0)
	var window := BASE_BITE_WINDOW_SECONDS

	match rarity:
		"rare":
			window -= 0.08
		"very_rare":
			window -= 0.14
		"legendary":
			window -= 0.22

	if behavior == "cautious" or behavior == "shy":
		window -= 0.12
	elif behavior == "aggressive":
		window += 0.08

	window = clamp(window - size_ratio * 0.12, 1.15, 1.8)
	var perfect_start := window * 0.25
	var perfect_end := window * 0.75
	var strength: float = clamp(0.42 + size_ratio * 0.38 + float(balance_data.get("bite_chance", 0.08)) * 0.90, 0.35, 1.0)

	return {
		"fish_id": fish_id,
		"bite_window_seconds": window,
		"perfect_start": perfect_start,
		"perfect_end": perfect_end,
		"strength": strength,
		"fish_name": str(catch_data.get("name", fish.get("name", "-"))),
		"rarity": rarity,
		"behavior": behavior,
		"weight": weight
	}


func _fail_hook(reason: String, data: Dictionary = {}) -> void:
	var failure_data := data.duplicate(true)
	failure_data["reason"] = reason
	failure_data["bite_data"] = _pending_bite_data.duplicate(true)
	hook_failed.emit(reason, failure_data)
	_pending_catch.clear()
	_pending_bite_data.clear()
	_bite_window_elapsed = 0.0
	_bite_window_seconds = 0.0
	fishing_state = FishingState.WAITING_FOR_BITE
	_hook_cooldown_timer = float(failure_data.get("cooldown", EARLY_HOOK_COOLDOWN if reason == "too_early" or reason == "early_hook" else 0.65))
	_bite_check_timer = max(_hook_cooldown_timer, BITE_CHECK_INTERVAL)
	_false_nudge_timer = randf_range(FALSE_NUDGE_MIN_DELAY, FALSE_NUDGE_MAX_DELAY)


func _clear_active_bite_data() -> void:
	_pending_catch.clear()
	_pending_bite_data.clear()
	_active_spot.clear()
	_active_spot_id = ""
	_active_available_fish.clear()
	_active_spot_depth_modifier = 1.0
	_bite_check_timer = 0.0
	_bite_window_elapsed = 0.0
	_bite_window_seconds = 0.0
	_false_nudge_timer = 0.0
	_hook_cooldown_timer = 0.0


func reset_after_result() -> void:
	if is_reeling:
		return

	_fishing_cycle_id += 1
	is_fishing = false
	is_reeling = false
	fishing_state = FishingState.IDLE
	_reel_input_active = false
	_last_hook_attempt_msec = 0
	_current_catch.clear()
	_clear_active_bite_data()


func _is_fishing_cycle_current(cycle_id: int) -> bool:
	return is_fishing and cycle_id == _fishing_cycle_id


func _get_tackle_available_fish(spot_fish: Array) -> Array:
	var filtered_fish: Array = []
	var allowed_rarities: Array = _tackle_stats.get("allowed_rarities", [])
	var max_fish_weight: float = float(_tackle_stats.get("max_fish_weight", 1.0))
	var line_strength: float = float(_tackle_stats.get("line_strength", 1.0))
	var tackle_weight_limit: float = max(max_fish_weight * 1.32, line_strength * 2.25)

	for fish_id in spot_fish:
		var fish: Dictionary = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue

		if _get_depth_match_multiplier(fish) <= 0.0:
			continue

		var rarity: String = str(fish.get("rarity", "common"))
		if not allowed_rarities.is_empty() and not allowed_rarities.has(rarity):
			continue

		if float(fish.get("min_weight", 0.0)) > tackle_weight_limit:
			continue

		if _get_hook_match_multiplier(fish) <= 0.08:
			continue

		if _get_bait_match_multiplier(fish, str(fish_id)) <= 0.06:
			continue

		filtered_fish.append(fish_id)

	return filtered_fish

func _get_best_bait_bonus(spot_fish: Array) -> float:
	var attraction_by_id: Dictionary = _tackle_stats.get("fish_attraction_by_id", {})
	var best_bonus: float = 0.0

	for fish_id in spot_fish:
		var fish := FishDatabase.get_fish(str(fish_id))
		var bait_multiplier: float = _get_bait_match_multiplier(fish, str(fish_id))
		best_bonus = max(best_bonus, float(attraction_by_id.get(str(fish_id), 0.0)) + max(bait_multiplier - 1.0, 0.0) * 0.22)

	return best_bonus

func _get_random_tackle_fish_id(available_fish: Array, rare_chance_modifier: float) -> String:
	var weighted_list: Array = []

	for fish_id in available_fish:
		var fish: Dictionary = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue

		var rarity: String = str(fish["rarity"])
		var weight := 10

		if rarity == "common":
			weight = 70
		elif rarity == "uncommon":
			weight = 25
		elif rarity == "rare":
			weight = int(7 * rare_chance_modifier)
		elif rarity == "very_rare":
			weight = int(3 * rare_chance_modifier)
		elif rarity == "legendary":
			weight = int(1 * rare_chance_modifier)

		var depth_multiplier: float = _get_depth_match_multiplier(fish)
		var bait_multiplier: float = _get_bait_match_multiplier(fish, str(fish_id))
		var hook_multiplier: float = _get_hook_match_multiplier(fish)
		var line_multiplier: float = _get_line_visibility_multiplier(fish)
		var time_multiplier: float = _get_time_activity_modifier(fish)
		var peak_multiplier: float = 1.0 + _get_time_peak_modifier(fish) * 0.45
		var final_weight: int = max(roundi(float(weight) * depth_multiplier * bait_multiplier * hook_multiplier * line_multiplier * time_multiplier * peak_multiplier), 1)

		for i in final_weight:
			weighted_list.append(fish_id)

	if weighted_list.is_empty():
		return FishDatabase.get_random_fish_id(available_fish, rare_chance_modifier)

	return str(weighted_list.pick_random())

func _get_depth_match_multiplier(fish: Dictionary) -> float:
	var depth: float = float(_tackle_stats.get("fishing_depth", 1.2))
	var min_depth: float = float(fish.get("min_depth", 0.2))
	var max_depth: float = float(fish.get("max_depth", 6.0))
	var reach_bonus: float = clamp(float(_tackle_stats.get("reach_bonus", 0.0)), -0.06, 0.22)
	var depth_range: float = max(max_depth - min_depth, 0.1)
	var reach_margin: float = depth_range * max(reach_bonus, 0.0)

	if depth < min_depth - reach_margin or depth > max_depth + reach_margin:
		return 0.0
	if depth < min_depth or depth > max_depth:
		return clamp(0.38 + reach_bonus * 1.20, 0.34, 0.64)

	var preferred_depth: float = clamp(float(fish.get("preferred_depth", (min_depth + max_depth) * 0.5)), min_depth, max_depth)
	var half_range: float = max(depth_range * 0.5 * (1.0 + max(reach_bonus, 0.0) * 1.35), 0.1)
	var distance: float = abs(depth - preferred_depth) / half_range
	var falloff: float = max(0.48 - max(reach_bonus, 0.0) * 0.16, 0.36)
	return clamp(1.18 - distance * falloff, 0.48, 1.20)

func _get_spot_depth_match_multiplier(spot: Dictionary) -> float:
	var depth: float = float(_tackle_stats.get("fishing_depth", PlayerData.fishing_depth))
	var min_depth: float = float(spot.get("min_depth", 0.2))
	var max_depth: float = float(spot.get("max_depth", 6.0))
	var reach_bonus: float = clamp(float(_tackle_stats.get("reach_bonus", 0.0)), -0.06, 0.22)
	var depth_range: float = max(max_depth - min_depth, 0.1)
	var reach_margin: float = depth_range * max(reach_bonus, 0.0)

	if depth < min_depth - reach_margin or depth > max_depth + reach_margin:
		return 0.34
	if depth < min_depth or depth > max_depth:
		return clamp(0.34 + reach_bonus * 0.85, 0.34, 0.52)

	var preferred_depth: float = clamp(float(spot.get("preferred_depth", spot.get("depth", (min_depth + max_depth) * 0.5))), min_depth, max_depth)
	var half_range: float = max(depth_range * 0.5 * (1.0 + max(reach_bonus, 0.0) * 1.10), 0.1)
	var distance: float = abs(depth - preferred_depth) / half_range
	var falloff: float = max(0.26 - max(reach_bonus, 0.0) * 0.08, 0.18)
	return clamp(1.10 - distance * falloff, 0.82, 1.12)

func _get_bait_match_multiplier(fish: Dictionary, fish_id: String) -> float:
	if fish.is_empty():
		return 0.0

	var bait_type := str(_tackle_stats.get("bait_type", "worm"))
	var bait_types: Array = _tackle_stats.get("bait_types", [bait_type])
	if bait_types.is_empty():
		bait_types = [bait_type]
	var preferred_baits := _get_fish_preferred_baits(fish)
	var attraction_by_id: Dictionary = _tackle_stats.get("fish_attraction_by_id", {})
	var specific_attraction: float = float(attraction_by_id.get(fish_id, 0.0))
	var general_attraction: float = float(_tackle_stats.get("fish_attraction", 0.0))
	var target_fish_ids: Array = _tackle_stats.get("target_fish_ids", [])
	var secondary_fish_ids: Array = _tackle_stats.get("secondary_fish_ids", [])

	if specific_attraction > 0.0:
		return clamp(1.0 + specific_attraction, 0.85, 1.75)

	if target_fish_ids.has(fish_id):
		return 1.18

	if secondary_fish_ids.has(fish_id):
		return 0.95

	if preferred_baits.is_empty():
		return clamp(0.55 + general_attraction, 0.35, 0.72)

	for active_bait in bait_types:
		if preferred_baits.has(str(active_bait)):
			return clamp(0.72 + general_attraction, 0.68, 0.82)

	return 0.25

func _get_fish_preferred_baits(fish: Dictionary) -> Array:
	var preferred_baits = fish.get("preferred_baits", [])

	if typeof(preferred_baits) == TYPE_ARRAY:
		return preferred_baits

	return []

func _get_line_visibility_multiplier(fish: Dictionary) -> float:
	var visibility: float = float(_tackle_stats.get("visibility_penalty", _tackle_stats.get("visibility", 0.0)))
	var max_weight: float = float(fish.get("max_weight", 1.0))
	var behavior := str(fish.get("behavior_type", fish.get("behavior", "calm")))
	var caution: float = 0.70

	if max_weight <= 0.8:
		caution = 1.35
	elif behavior == "calm":
		caution = 1.05

	return clamp(1.0 - visibility * caution, 0.55, 1.0)

func _get_average_time_activity_modifier(fish_ids: Array) -> float:
	if fish_ids.is_empty():
		return 1.0

	var total := 0.0
	var count := 0

	for fish_id in fish_ids:
		var fish := FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue

		total += _get_time_activity_modifier(fish)
		count += 1

	if count == 0:
		return 1.0

	return clamp(total / float(count), 0.35, 1.45)

func _get_time_activity_modifier(fish: Dictionary) -> float:
	var current_minutes := int(floor(_get_current_game_minutes()))
	var start_minutes := int(fish.get("active_time_start", 300))
	var end_minutes := int(fish.get("active_time_end", 1320))
	var active := _is_time_in_range(current_minutes, start_minutes, end_minutes)
	var peak_modifier := _get_time_peak_modifier(fish)
	var base := 1.0 if active else 0.26

	return clamp(base + peak_modifier * 0.48, 0.18, 1.48)

func _get_time_peak_modifier(fish: Dictionary) -> float:
	var current_minutes := int(floor(_get_current_game_minutes()))
	var peak_minutes := int(fish.get("peak_time", 480))
	var distance := _circular_minutes_distance(current_minutes, peak_minutes)
	return clamp(1.0 - float(distance) / 210.0, 0.0, 1.0)

func _is_time_in_range(current_minutes: int, start_minutes: int, end_minutes: int) -> bool:
	current_minutes = int(fposmod(float(current_minutes), 1440.0))
	start_minutes = int(fposmod(float(start_minutes), 1440.0))
	end_minutes = int(fposmod(float(end_minutes), 1440.0))

	if start_minutes <= end_minutes:
		return current_minutes >= start_minutes and current_minutes <= end_minutes

	return current_minutes >= start_minutes or current_minutes <= end_minutes

func _circular_minutes_distance(a: int, b: int) -> int:
	var raw_distance: int = abs(a - b) % 1440
	return min(raw_distance, 1440 - raw_distance)

func _get_current_game_minutes() -> float:
	var time_manager := get_node_or_null("/root/TimeManager")

	if time_manager == null:
		return 525.0

	return float(time_manager.get("current_game_minutes"))

func _get_hook_match_multiplier(fish: Dictionary, catch_weight: float = -1.0) -> float:
	var hook_size: int = int(_tackle_stats.get("hook_size", 12))
	var min_hook_size: int = int(fish.get("min_hook_size", 2))
	var max_hook_size: int = int(fish.get("max_hook_size", 18))

	if hook_size < min_hook_size:
		var too_big_steps: int = min_hook_size - hook_size
		return clamp(0.18 - float(too_big_steps) * 0.02, 0.08, 0.18)

	if hook_size > max_hook_size:
		var too_small_steps: int = hook_size - max_hook_size
		return clamp(0.72 - float(too_small_steps) * 0.08, 0.30, 0.72)

	var hook_center: float = (float(min_hook_size) + float(max_hook_size)) * 0.5
	var hook_half_range: float = max((float(max_hook_size) - float(min_hook_size)) * 0.5, 1.0)
	var fit_distance: float = abs(float(hook_size) - hook_center) / hook_half_range
	var rule_fit: float = clamp(1.18 - fit_distance * 0.22, 1.0, 1.18)
	var target_size := str(_tackle_stats.get("target_fish_size", "small"))
	var fish_size := _get_fish_size_class(fish, catch_weight)
	var target_fit := 1.0

	match target_size:
		"small":
			if fish_size == "small":
				target_fit = 1.12
			elif fish_size == "medium":
				target_fit = 0.88
			else:
				target_fit = 0.62
		"medium":
			if fish_size == "small":
				target_fit = 0.92
			if fish_size == "medium":
				target_fit = 1.14
			elif fish_size == "large":
				target_fit = 0.92
		"large":
			if fish_size == "small":
				target_fit = 0.66
			elif fish_size == "medium":
				target_fit = 0.96
			else:
				target_fit = 1.16

	return clamp(rule_fit * target_fit, 0.30, 1.24)

func _get_fish_size_class(fish: Dictionary, catch_weight: float = -1.0) -> String:
	var reference_weight := catch_weight

	if reference_weight <= 0.0:
		reference_weight = (float(fish.get("min_weight", 0.0)) + float(fish.get("max_weight", 0.0))) * 0.5

	if reference_weight < 0.75:
		return "small"
	if reference_weight < 2.25:
		return "medium"
	return "large"

func set_reel_input(active: bool) -> void:
	_reel_input_active = active and is_reeling

func _process(delta: float) -> void:
	if use_new_bite_system:
		_update_active_bite_system(delta)

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
	_pending_catch.clear()
	_pending_bite_data.clear()
	is_reeling = true
	fishing_state = FishingState.REELING
	_reel_input_active = false
	_tackle_stats = PlayerData.get_tackle_stats()

	var fish: Dictionary = FishDatabase.get_fish(str(catch_data["id"]))
	var rarity: String = str(catch_data.get("rarity", "common"))
	_current_behavior = str(catch_data.get("behavior_type", catch_data.get("behavior", fish.get("behavior_type", fish.get("behavior", "calm")))))

	var tuning: Dictionary = _get_behavior_tuning(_current_behavior)
	var rarity_factor: float = _get_rarity_factor(rarity)
	var min_weight: float = float(fish.get("min_weight", catch_data["weight"]))
	var max_weight: float = float(fish.get("max_weight", catch_data["weight"]))
	var weight_span: float = max(max_weight - min_weight, 0.01)
	_weight_ratio = clamp((float(catch_data["weight"]) - min_weight) / weight_span, 0.0, 1.0)
	var catch_weight: float = float(catch_data.get("weight", 0.0))
	var rod_strength: float = max(float(_tackle_stats.get("rod_strength", 1.0)), 0.2)
	var line_break_resistance: float = max(float(_tackle_stats.get("break_resistance", 1.0)), 0.2)
	var line_durability: float = max(float(_tackle_stats.get("line_durability", 1.0)), 0.05)
	var rod_overload: float = 0.0
	var line_overload: float = 0.0
	var overload_penalty: float = 0.0
	var base_fight_power: float = float(catch_data.get("base_fight_power", fish.get("base_fight_power", 1.0)))
	_fish_strength = float(catch_data.get("strength", fish.get("strength", base_fight_power)))
	_fish_aggression = float(catch_data.get("aggression", fish.get("aggression", 0.5)))
	_fish_stamina = float(catch_data.get("stamina", fish.get("stamina", 1.0)))
	_escape_chance = float(catch_data.get("escape_chance", fish.get("escape_chance", fish.get("escape_risk", 0.25))))
	_weight_difficulty = float(catch_data.get("weight_difficulty_multiplier", fish.get("weight_difficulty_multiplier", 1.0)))
	_effective_load_kg = max(
		catch_weight * (0.50 + _fish_strength * 0.42) * (1.0 + _weight_ratio * 0.22),
		catch_weight * 0.35
	)
	var rod_capacity_ratio: float = _effective_load_kg / max(float(_tackle_stats.get("max_fish_weight", 1.0)), 0.1)
	var line_capacity_ratio: float = _effective_load_kg / max(float(_tackle_stats.get("line_strength", 1.0)), 0.1)
	rod_overload = max(rod_capacity_ratio - 1.0, 0.0) / rod_strength
	line_overload = max(line_capacity_ratio - 1.0, 0.0) / line_break_resistance
	overload_penalty = max(rod_overload, line_overload * 0.74)
	_line_pressure = line_capacity_ratio
	_line_load_ratio = line_capacity_ratio
	_rod_load_ratio = rod_capacity_ratio
	_fight_power = clamp(
		base_fight_power
		* (0.72 + _fish_strength * 0.28 + _fish_aggression * 0.12)
		* (1.0 + _weight_ratio * _weight_difficulty)
		* (1.0 + overload_penalty * 0.18)
		* max(1.0 - float(_tackle_stats.get("control_bonus", 0.0)) * 0.25 - float(_tackle_stats.get("stability", 0.0)) * 0.18, 0.68),
		0.35,
		4.75
	)
	_escape_risk = clamp(
		(_escape_chance + _weight_ratio * 0.17 * _weight_difficulty + max(line_overload, rod_overload) * 0.06)
		* float(_tackle_stats.get("fish_escape_modifier", 1.0))
		/ max(_get_hook_match_multiplier(fish, catch_weight), 0.35)
		/ max(float(_tackle_stats.get("hook_strength", 1.0)), 0.35)
		/ (1.0 + float(_tackle_stats.get("hook_success_bonus", 0.0))),
		0.05,
		0.85
	)

	_difficulty = clamp(
		rarity_factor
		+ _weight_ratio * _weight_difficulty * 0.55
		+ (base_fight_power - 1.0) * 0.26
		+ (_fish_strength - 1.0) * 0.22
		+ _fish_aggression * 0.12
		+ overload_penalty * 0.36,
		0.75,
		3.65
	)
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
	_rod_overload_time = 0.0
	_line_overload_time = 0.0
	_wear_pressure = max(_line_load_ratio, _rod_load_ratio)
	_last_fail_kind = ""
	_tension_velocity = 0.0
	_player_force = 0.0

	var green_width: float = clamp(
		(0.36 - (_difficulty - 1.0) * 0.075)
		* float(tuning["green_width"])
		* (1.0 + float(_tackle_stats.get("control_bonus", 0.0)) + float(_tackle_stats.get("stability", 0.0))),
		0.14,
		0.38
	)
	green_width = clamp(green_width + clamp(float(_tackle_stats.get("green_zone_bonus", 0.0)), 0.0, 0.30), 0.14, 0.48)
	var green_center: float = clamp(0.54 + randf_range(-0.045, 0.045), 0.43, 0.63)
	_green_min = clamp(green_center - green_width * 0.5, 0.16, 0.72)
	_green_max = clamp(green_center + green_width * 0.5, _green_min + 0.11, 0.88)
	_tension = clamp((_green_min + _green_max) * 0.5 - 0.04, 0.18, 0.82)

	var break_safety: float = line_break_resistance * line_durability * clamp(rod_strength, 0.7, 1.35)
	var escape_safety: float = (1.0 / max(float(_tackle_stats.get("fish_escape_modifier", 1.0)), 0.2)) + float(_tackle_stats.get("hook_success_bonus", 0.0))
	_high_fail_limit = clamp((1.30 * break_safety) / (_difficulty * float(tuning["danger"]) * (1.0 + overload_penalty * 0.45)), 0.42, 1.55)
	_low_fail_limit = clamp((1.52 * escape_safety) / (_difficulty * float(tuning["danger"]) * (1.0 + _escape_risk)), 0.52, 1.85)
	_target_progress_time = clamp(
		(4.2 + _fish_stamina * 2.25 + _difficulty * 1.15 + _weight_ratio * _weight_difficulty * 1.25)
		* float(tuning["progress_time"])
		/ (1.0 + float(_tackle_stats.get("control_bonus", 0.0)) + float(_tackle_stats.get("hook_success_bonus", 0.0)) + max(rod_strength - 1.0, 0.0) * 0.18),
		5.5,
		14.0
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
	var tackle_cushion: float = max(
		1.0 - float(_tackle_stats.get("control_bonus", 0.0)) * 0.18 - float(_tackle_stats.get("stability", 0.0)) * 0.22,
		0.68
	)
	var power_scale: float = float(tuning["power"]) * _difficulty * _fight_power * tackle_cushion * (0.84 + _fish_strength * 0.14 + _fish_aggression * 0.16)
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

	var interval: float = randf_range(min_interval, max_interval) / max(_difficulty * frequency * clamp(_fight_power, 0.65, 2.2), 0.1)
	return clamp(interval, 0.26, 3.1)

func _update_tension(delta: float) -> void:
	var tuning: Dictionary = _get_behavior_tuning(_current_behavior)
	var player_target: float = PLAYER_PULL_FORCE if _reel_input_active else PLAYER_RELEASE_FORCE
	var player_response: float = PLAYER_FORCE_RESPONSE * float(tuning["player_response"])
	_player_force = lerp(_player_force, player_target, clamp(delta * player_response, 0.0, 1.0))

	var drag: float = BASE_FISH_DRAG * _difficulty * clamp(_fight_power, 0.65, 2.5)
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

func _get_current_load_info() -> Dictionary:
	var fallback_weight: float = float(_current_catch.get("weight", 0.0))
	var base_load: float = max(_effective_load_kg, fallback_weight * 0.35)
	var tension_load: float = lerp(0.55, 1.55, _tension)
	var struggle_load: float = clamp(_struggle_power * 0.38, 0.0, 0.65)
	var load_kg: float = base_load * tension_load * (1.0 + struggle_load)
	var line_capacity: float = max(float(_tackle_stats.get("line_strength", 1.0)), 0.1)
	var rod_capacity: float = max(float(_tackle_stats.get("max_fish_weight", 1.0)), 0.1)

	return {
		"load_kg": load_kg,
		"line_ratio": load_kg / line_capacity,
		"rod_ratio": load_kg / rod_capacity
	}

func _update_load_and_overload(delta: float) -> void:
	var load_info := _get_current_load_info()
	_line_load_ratio = float(load_info.get("line_ratio", 0.0))
	_rod_load_ratio = float(load_info.get("rod_ratio", 0.0))
	_line_pressure = max(_line_load_ratio, _line_pressure)
	_wear_pressure = max(_wear_pressure, max(_line_load_ratio, _rod_load_ratio))

	var line_overload: float = max(_line_load_ratio - 1.0, 0.0)
	var rod_overload: float = max(_rod_load_ratio - 1.0, 0.0)

	if line_overload > 0.0:
		_line_overload_time += delta * (0.72 + line_overload * 1.85) * (0.65 + _tension * 0.90)
	else:
		_line_overload_time = max(_line_overload_time - delta * 0.78, 0.0)

	if rod_overload > 0.0:
		_rod_overload_time += delta * (0.55 + rod_overload * 1.45) * (0.72 + _tension * 0.70)
	else:
		_rod_overload_time = max(_rod_overload_time - delta * 0.52, 0.0)

	if line_overload > 0.08:
		_feedback_message = "О НЕТ, леска перегружена!"
	elif rod_overload > 0.10:
		_feedback_message = "Удочка трещит!"

	var line_break_chance: float = float(_tackle_stats.get("break_chance", 0.15))
	var line_limit: float = clamp((2.05 - line_break_chance * 1.45) / max(line_overload, 0.08), 0.42, 2.50)
	if line_overload > 0.0 and _line_overload_time >= line_limit:
		_finish_reeling_failed("Обрыв лески! Рыба ушла.", "line_break", FAILURE_LINE_BROKE)
		return

	var rod_limit: float = clamp(2.30 / max(rod_overload, 0.08), 0.65, 3.20)
	if rod_overload > 0.0 and _rod_overload_time >= rod_limit:
		var rod_break_chance: float = clamp((rod_overload * 0.22 + _tension * 0.08) * delta, 0.0, 0.32)
		if rod_overload > 0.82 or randf() < rod_break_chance:
			_finish_reeling_failed("Удочка повреждена! Рыба ушла.", "rod_break", FAILURE_ROD_OVERLOAD)

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
			var break_safety: float = max(
				float(_tackle_stats.get("break_resistance", 1.0))
				* float(_tackle_stats.get("line_durability", _tackle_stats.get("durability", 1.0)))
				* clamp(float(_tackle_stats.get("rod_strength", 1.0)), 0.7, 1.35),
				0.1
			)
			var break_pressure: float = max(_line_pressure, 0.70) / break_safety
			_high_danger_time += delta * lerp(0.42, 2.18, outside_distance) * clamp(break_pressure, 0.75, 2.4)
			_low_danger_time = max(_low_danger_time - delta, 0.0)

			if outside_distance > 0.72 or _critical_break_risk > 0.45:
				_feedback_message = "Осторожно, обрыв!"
			else:
				_feedback_message = "Леска натянута!"
		elif _tension < _green_min:
			near_zone_factor = clamp((_green_min - _tension) / near_margin, 0.0, 1.0)
			outside_distance = inverse_lerp(_green_min, 0.0, _tension)
			_low_danger_time += delta * lerp(0.42, 1.96, outside_distance) * (1.0 + _escape_risk)
			_high_danger_time = max(_high_danger_time - delta, 0.0)
			_feedback_message = "Слабина. Подтяни леску!"

		if near_zone_factor < 1.0:
			var slow_progress: float = lerp(0.42, 0.08, near_zone_factor)
			_catch_progress = clamp(_catch_progress + delta * slow_progress / _target_progress_time, 0.0, 1.0)
		else:
			_catch_progress = max(_catch_progress - delta * PROGRESS_DECAY * lerp(0.65, 1.45, outside_distance), 0.0)

	_update_critical_break(delta)
	_update_load_and_overload(delta)

	if not is_reeling:
		return

	if _high_danger_time >= _high_fail_limit:
		_finish_reeling_failed("Леска не выдержала натяжения. Рыба сорвалась.", "line_break", FAILURE_LINE_BROKE)
	elif _low_danger_time >= _low_fail_limit:
		_finish_reeling_failed("Натяжение упало. Рыба сошла с крючка.", "escape", FAILURE_FISH_ESCAPED_LOW_TENSION)

func _update_critical_break(delta: float) -> void:
	_critical_break_risk = 0.0

	if _tension < 0.94:
		return

	var severity: float = inverse_lerp(0.94, 1.0, _tension)
	var force_bonus: float = clamp(_struggle_power * 0.35, 0.0, 0.35)
	var load_info := _get_current_load_info()
	var line_pressure: float = float(load_info.get("line_ratio", 0.0))
	var break_safety: float = max(
		float(_tackle_stats.get("break_resistance", 1.0))
		* float(_tackle_stats.get("line_durability", _tackle_stats.get("durability", 1.0)))
		* clamp(float(_tackle_stats.get("rod_strength", 1.0)), 0.7, 1.35),
		0.1
	)
	var line_break_chance: float = float(_tackle_stats.get("break_chance", 0.15))
	_critical_break_risk = clamp(((0.10 + severity * 0.55) * _difficulty + force_bonus + line_break_chance * 0.20) * max(line_pressure, 0.75) / break_safety, 0.0, 1.0)
	_feedback_message = "Осторожно, обрыв!"

	if randf() < _critical_break_risk * 0.32 * delta:
		_finish_reeling_failed("Критическое натяжение. Леска лопнула.", "line_break", FAILURE_LINE_BROKE)

func _apply_reeling_wear(outcome: String) -> Dictionary:
	if _current_catch.is_empty():
		return {}

	var catch_weight: float = float(_current_catch.get("weight", 0.0))
	var load_factor: float = clamp(max(max(_wear_pressure, _line_load_ratio), max(_rod_load_ratio, 0.55)), 0.55, 3.25)
	var weight_factor: float = clamp(catch_weight / 2.0, 0.04, 2.50)
	var struggle_factor: float = clamp(_fight_power * 0.34 + _difficulty * 0.22 + _fish_strength * 0.15, 0.35, 2.25)
	var base_wear: float = (0.004 + weight_factor * 0.011) * struggle_factor * load_factor

	if outcome != "caught":
		base_wear *= 1.25

	var wear := {
		"rod": base_wear * float(_tackle_stats.get("durability_loss", 0.012)) / 0.012,
		"line": base_wear * 1.45 * float(_tackle_stats.get("line_wear_rate", 0.022)) / 0.022,
		"hook": base_wear * 1.10 * float(_tackle_stats.get("hook_wear_rate", 0.026)) / 0.026,
		"line_broken": outcome == "line_break",
		"rod_broken": outcome == "rod_break",
		"hook_lost": false
	}

	if outcome == "line_break":
		wear["hook_lost"] = randf() < 0.36
	elif outcome == "escape":
		wear["hook_lost"] = randf() < clamp(_escape_risk * 0.10, 0.02, 0.12)

	return PlayerData.apply_tackle_wear(wear)

func _finish_reeling_success() -> void:
	if not is_reeling:
		return

	_fishing_cycle_id += 1
	var catch_data: Dictionary = FishFreshnessManager.stamp_catch(PlayerData.prepare_record_info(_current_catch.duplicate(true)))
	var wear_result := _apply_reeling_wear("caught")
	var added: bool = InventoryManager.add_fish(catch_data)

	is_fishing = false
	is_reeling = false
	fishing_state = FishingState.CAUGHT
	_reel_input_active = false
	_current_catch = {}
	_clear_active_bite_data()

	if added:
		var signal_data: Dictionary = catch_data.duplicate(true)
		signal_data["tackle_wear"] = wear_result
		signal_data["xp_result"] = _award_catch_xp(catch_data)
		fish_caught.emit(signal_data)
	else:
		_emit_fishing_failure(
			FAILURE_UNKNOWN,
			"Садок заполнен",
			"Садок заполнен. Продайте рыбу перед новой ловлей.",
			"Откройте садок и освободите место.",
			{"severity": "low", "catch_data": catch_data}
		)

func _finish_reeling_failed(message: String, fail_kind: String = "escape", reason: String = "") -> void:
	if not is_reeling:
		return

	_fishing_cycle_id += 1
	_last_fail_kind = fail_kind
	var wear_result := _apply_reeling_wear(fail_kind)
	var final_message := message

	if bool(wear_result.get("line_broken", false)) and final_message.find("Обрыв") == -1:
		final_message += "\nОбрыв лески!"
	if bool(wear_result.get("rod_broken", false)) and final_message.find("Удочка") == -1:
		final_message += "\nУдочка повреждена!"
	if bool(wear_result.get("hook_lost", false)):
		final_message += "\nКрючок потерян."

	var failure_reason: String = reason if reason != "" else _get_failure_reason_for_fail_kind(fail_kind)
	if fail_kind == "escape" and bool(wear_result.get("hook_lost", false)):
		failure_reason = FAILURE_FISH_ESCAPED_HOOK

	is_fishing = false
	is_reeling = false
	fishing_state = FishingState.FAILED
	_reel_input_active = false
	_clear_active_bite_data()
	_emit_fishing_failure(
		failure_reason,
		"",
		"",
		"",
		{
			"severity": "medium",
			"raw_message": final_message,
			"fail_kind": fail_kind,
			"tackle_wear": wear_result
		}
	)
	_current_catch = {}

func _emit_no_candidate_failure(spot: Dictionary, spot_id: String) -> void:
	var failure_data: Dictionary = _build_no_candidate_failure_data(spot, spot_id)
	_emit_fishing_failure(
		str(failure_data.get("reason", FAILURE_UNKNOWN)),
		str(failure_data.get("title", "")),
		str(failure_data.get("message", "")),
		str(failure_data.get("hint", "")),
		failure_data
	)

func _emit_fishing_failure(
	reason: String,
	title: String = "",
	message: String = "",
	hint: String = "",
	extra_data: Dictionary = {}
) -> void:
	fishing_state = FishingState.FAILED
	var template: Dictionary = _get_failure_template(reason)
	var failure_data: Dictionary = {
		"reason": reason,
		"title": title if title != "" else str(template.get("title", "Неудачная попытка")),
		"message": message if message != "" else str(template.get("message", "Рыба ушла.")),
		"hint": hint if hint != "" else str(template.get("hint", "Проверьте снасть, наживку и глубину.")),
		"severity": str(extra_data.get("severity", template.get("severity", "normal")))
	}

	var context: Dictionary = _get_failure_context(extra_data)
	for key in context.keys():
		failure_data[key] = context[key]
	for key in extra_data.keys():
		failure_data[key] = extra_data[key]

	fishing_failed_detailed.emit(failure_data)
	fishing_failed.emit(str(failure_data.get("message", message)))

func _get_failure_context(extra_data: Dictionary = {}) -> Dictionary:
	var catch_data: Dictionary = {}
	var raw_catch = extra_data.get("catch_data", _current_catch)
	if typeof(raw_catch) == TYPE_DICTIONARY:
		catch_data = raw_catch

	var fish_name := str(extra_data.get("fish_name", catch_data.get("name", "")))
	var fish_weight: float = float(extra_data.get("fish_weight", catch_data.get("weight", 0.0)))
	var context: Dictionary = {
		"fish_name": fish_name,
		"fish_weight": fish_weight,
		"line_strength": float(_tackle_stats.get("line_strength", _tackle_stats.get("max_load", 0.0))),
		"rod_strength": float(_tackle_stats.get("max_fish_weight", 0.0)),
		"line_load_ratio": _line_load_ratio,
		"rod_load_ratio": _rod_load_ratio,
		"tension": _tension,
		"fishing_depth": float(_tackle_stats.get("fishing_depth", PlayerData.fishing_depth)),
		"bait": str(PlayerData.current_tackle.get("bait", {}).get("name", "")),
		"hook": str(PlayerData.current_tackle.get("hook", {}).get("name", ""))
	}

	if catch_data.has("id"):
		context["fish_id"] = str(catch_data.get("id", ""))
	if catch_data.has("spot_name"):
		context["spot_name"] = str(catch_data.get("spot_name", ""))
	if catch_data.has("waterbody_name"):
		context["waterbody_name"] = str(catch_data.get("waterbody_name", ""))

	return context

func _get_failure_template(reason: String) -> Dictionary:
	match reason:
		FAILURE_NO_BITE:
			return {
				"title": "Поклёвки не было",
				"message": "Рыба не заинтересовалась наживкой.",
				"hint": "Попробуйте другую наживку, глубину или точку ловли.",
				"severity": "low"
			}
		FAILURE_BAD_DEPTH:
			return {
				"title": "Неподходящая глубина",
				"message": "На этой глубине подходящей рыбы почти нет.",
				"hint": "Измените глубину или выберите другую точку.",
				"severity": "low"
			}
		FAILURE_BAD_BAIT:
			return {
				"title": "Наживка не подошла",
				"message": "Рыба здесь плохо реагирует на текущую наживку.",
				"hint": "Попробуйте червя, хлеб, тесто или опарыша.",
				"severity": "low"
			}
		FAILURE_BAD_HOOK:
			return {
				"title": "Крючок не подходит",
				"message": "Размер крючка плохо подходит для рыбы в этой точке.",
				"hint": "Для мелкой рыбы используйте меньшие крючки, для крупной — более прочные.",
				"severity": "low"
			}
		FAILURE_WEAK_TACKLE:
			return {
				"title": "Снасть слишком слабая",
				"message": "Рыба оказалась сильнее текущей снасти.",
				"hint": "Улучшите удочку, леску или крючок.",
				"severity": "medium"
			}
		FAILURE_LINE_BROKE:
			return {
				"title": "Леска порвалась",
				"message": "Натяжение стало слишком высоким, и леска не выдержала.",
				"hint": "Поставьте более прочную леску или отпускайте натяжение вовремя.",
				"severity": "medium"
			}
		FAILURE_ROD_OVERLOAD:
			return {
				"title": "Удочка не выдержала",
				"message": "Снасть была перегружена во время вываживания.",
				"hint": "Используйте более крепкое удилище для крупной рыбы.",
				"severity": "medium"
			}
		FAILURE_FISH_ESCAPED_LOW_TENSION:
			return {
				"title": "Рыба сошла",
				"message": "Натяжение было слишком слабым, и рыба освободилась.",
				"hint": "Не отпускайте леску слишком сильно. Держите натяжение в зелёной зоне.",
				"severity": "medium"
			}
		FAILURE_FISH_ESCAPED_HIGH_TENSION:
			return {
				"title": "Рыба сорвалась",
				"message": "Натяжение было слишком высоким, рыба резко дёрнула и сошла.",
				"hint": "Снижайте натяжение при рывках рыбы.",
				"severity": "medium"
			}
		FAILURE_FISH_ESCAPED_HOOK:
			return {
				"title": "Рыба сорвалась с крючка",
				"message": "Крючок плохо удержал рыбу.",
				"hint": "Попробуйте другой размер крючка или более подходящую наживку.",
				"severity": "medium"
			}
		FAILURE_FISH_TOO_STRONG:
			return {
				"title": "Рыба оказалась слишком сильной",
				"message": "Вы подсекли крупную рыбу, но снасть была на пределе.",
				"hint": "Вернитесь с более прочной леской и удочкой.",
				"severity": "high"
			}
		_:
			return {
				"title": "Неудачная попытка",
				"message": "Рыба ушла.",
				"hint": "Проверьте снасть, наживку и глубину.",
				"severity": "normal"
			}

func _get_failure_reason_for_fail_kind(fail_kind: String) -> String:
	match fail_kind:
		"line_break":
			return FAILURE_LINE_BROKE
		"rod_break":
			return FAILURE_ROD_OVERLOAD
		_:
			if _tension > _green_max:
				return FAILURE_FISH_ESCAPED_HIGH_TENSION
			if _tension < _green_min:
				return FAILURE_FISH_ESCAPED_LOW_TENSION
			return FAILURE_FISH_ESCAPED_HOOK

func _build_no_candidate_failure_data(spot: Dictionary, spot_id: String) -> Dictionary:
	var blocker_counts: Dictionary = {
		FAILURE_BAD_DEPTH: 0,
		FAILURE_BAD_BAIT: 0,
		FAILURE_BAD_HOOK: 0,
		FAILURE_WEAK_TACKLE: 0,
		FAILURE_FISH_TOO_STRONG: 0
	}
	var checked_count := 0
	var allowed_rarities: Array = _tackle_stats.get("allowed_rarities", [])
	var max_fish_weight: float = float(_tackle_stats.get("max_fish_weight", 1.0))
	var line_strength: float = float(_tackle_stats.get("line_strength", 1.0))
	var tackle_weight_limit: float = max(max_fish_weight * 1.32, line_strength * 2.25)

	for fish_id in spot.get("available_fish", []):
		var fish: Dictionary = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue

		checked_count += 1
		var rarity := str(fish.get("rarity", "common"))
		if _get_depth_match_multiplier(fish) <= 0.0:
			blocker_counts[FAILURE_BAD_DEPTH] += 1
			continue
		if not allowed_rarities.is_empty() and not allowed_rarities.has(rarity):
			blocker_counts[FAILURE_WEAK_TACKLE] += 1
			continue
		if float(fish.get("min_weight", 0.0)) > tackle_weight_limit:
			blocker_counts[FAILURE_FISH_TOO_STRONG] += 1
			continue
		if _get_hook_match_multiplier(fish) <= 0.08:
			blocker_counts[FAILURE_BAD_HOOK] += 1
			continue
		if _get_bait_match_multiplier(fish, str(fish_id)) <= 0.06:
			blocker_counts[FAILURE_BAD_BAIT] += 1
			continue

	if checked_count <= 0:
		return {
			"reason": FAILURE_UNKNOWN,
			"title": "Рыбы не найдено",
			"message": "В этой точке сейчас нет доступной рыбы.",
			"hint": "Выберите другую точку ловли.",
			"severity": "low",
			"spot_id": spot_id
		}

	var best_reason := FAILURE_BAD_DEPTH
	var best_count := -1
	for reason in blocker_counts.keys():
		var count := int(blocker_counts[reason])
		if count > best_count:
			best_count = count
			best_reason = str(reason)

	var template: Dictionary = _get_failure_template(best_reason)
	return {
		"reason": best_reason,
		"title": str(template.get("title", "")),
		"message": str(template.get("message", "")),
		"hint": str(template.get("hint", "")),
		"severity": str(template.get("severity", "low")),
		"spot_id": spot_id,
		"blocked_by_depth": int(blocker_counts[FAILURE_BAD_DEPTH]),
		"blocked_by_bait": int(blocker_counts[FAILURE_BAD_BAIT]),
		"blocked_by_hook": int(blocker_counts[FAILURE_BAD_HOOK]),
		"blocked_by_tackle": int(blocker_counts[FAILURE_WEAK_TACKLE]),
		"blocked_by_strength": int(blocker_counts[FAILURE_FISH_TOO_STRONG])
	}

func _infer_no_bite_failure_reason(_available_fish: Array, _spot_depth_modifier: float) -> String:
	return FAILURE_NO_BITE

func _award_catch_xp(catch_data: Dictionary) -> Dictionary:
	var base_xp: int = int(catch_data.get("base_xp", 5))
	var weight_bonus: int = max(roundi(float(catch_data.get("weight", 0.0)) * 2.0), 0)
	var total_xp: int = base_xp + weight_bonus
	var skill_effects := PlayerData.get_skill_effects()
	var xp_multiplier: float = 1.0 + float(skill_effects.get("xp_bonus", 0.0))
	var catch_rank := str(catch_data.get("catch_rank", "normal"))
	var rarity := str(catch_data.get("rarity", "common"))
	if catch_rank == "trophy" or catch_rank == "rarity" or rarity == "rare" or rarity == "very_rare" or rarity == "legendary":
		xp_multiplier += float(skill_effects.get("trophy_xp_bonus", 0.0))
	total_xp = max(roundi(float(total_xp) * max(xp_multiplier, 0.0)), 0)
	return PlayerData.add_xp(total_xp)

func _get_rarity_factor(rarity: String) -> float:
	match rarity:
		"uncommon":
			return 1.12
		"rare":
			return 1.42
		"very_rare":
			return 1.58
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
	var load_info := _get_current_load_info()
	var load_kg: float = float(load_info.get("load_kg", 0.0))
	var line_load_ratio: float = float(load_info.get("line_ratio", _line_load_ratio))
	var rod_load_ratio: float = float(load_info.get("rod_ratio", _rod_load_ratio))
	var break_risk: float = clamp(max(_critical_break_risk, max(line_load_ratio - 1.0, 0.0) * 0.62 + max(_high_danger_time / max(_high_fail_limit, 0.1), 0.0) * 0.28), 0.0, 1.0)

	if _tension > _green_max:
		tension_status = "high"
	elif _tension < _green_min:
		tension_status = "low"

	return {
		"fish_name": str(_current_catch.get("name", "-")),
		"fish_weight": float(_current_catch.get("weight", 0.0)),
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
		"fight_power": _fight_power,
		"fish_strength": _fish_strength,
		"fish_aggression": _fish_aggression,
		"load_kg": load_kg,
		"line_load_ratio": line_load_ratio,
		"rod_load_ratio": rod_load_ratio,
		"rod_durability": float(_tackle_stats.get("rod_durability", _tackle_stats.get("durability", 1.0))),
		"line_durability": float(_tackle_stats.get("line_durability", 1.0)),
		"hook_durability": float(_tackle_stats.get("hook_durability", 1.0)),
		"line_strength": float(_tackle_stats.get("line_strength", 0.0)),
		"critical_break_risk": _critical_break_risk,
		"break_risk": break_risk,
		"escape_risk": _escape_risk,
		"input_active": _reel_input_active,
		"status": tension_status,
		"high_danger": clamp(_high_danger_time / _high_fail_limit, 0.0, 1.0),
		"low_danger": clamp(_low_danger_time / _low_fail_limit, 0.0, 1.0)
	}
