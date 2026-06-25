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
signal lure_retrieve_started(state: Dictionary)
signal lure_retrieve_updated(state: Dictionary)
signal lure_retrieve_finished(state: Dictionary)
signal float_nudge(nudge_data: Dictionary)
signal bite_preview_event(event_data: Dictionary)
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
var _bite_phase: String = "idle"
var _bite_phase_timer: float = 0.0
var _bite_phase_data: Dictionary = {}
var _bite_phase_nibble_index: int = 0
var _bite_phase_nibble_count: int = 0
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
var _fight_mode: String = "pole"
var _reel_drag_value: float = 0.0
var _reel_drag_percent: float = 0.0
var _line_out: float = 0.0
var _spool_capacity: float = 0.0
var _fish_pulling_line_out: bool = false
var _reel_handle_speed: float = 0.0
var _reel_line_out_speed: float = 0.0
var _reel_wear_pressure: float = 0.0
var _lure_retrieve_progress: float = 0.0
var _lure_retrieve_speed: float = 0.0
var _lure_retrieve_update_timer: float = 0.0
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
var _main_line_load_ratio: float = 0.0
var _leader_load_ratio: float = 0.0
var _rod_load_ratio: float = 0.0
var _rod_overload_time: float = 0.0
var _line_overload_time: float = 0.0
var _leader_overload_time: float = 0.0
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
var vibration_enabled: bool = true
var _fight_vibration_timer: float = 0.0
var _fight_vibration_debug_timer: float = 0.0
var _last_vibration_strength: float = 0.0
var _last_vibration_label: String = "off"
var _last_struggle_vibration_msec: int = 0
var _safe_zone_strength_factor: float = 1.0
var _safe_zone_size_ratio: float = 0.0

const USE_NEW_BITE_SYSTEM := true
const BITE_CHECK_INTERVAL := 0.8
const BASE_BITE_WINDOW_SECONDS := 1.4
const EARLY_HOOK_COOLDOWN := 1.5
const FALSE_NUDGE_MIN_DELAY := 1.2
const FALSE_NUDGE_MAX_DELAY := 3.2
const FALSE_NUDGE_CHANCE := 0.28
const APPROACH_GOOD_MIN := 1.8
const APPROACH_GOOD_MAX := 3.8
const APPROACH_NORMAL_MIN := 3.0
const APPROACH_NORMAL_MAX := 6.0
const APPROACH_WEAK_MIN := 5.0
const APPROACH_WEAK_MAX := 10.0
const APPROACH_POOR_MIN := 8.0
const APPROACH_POOR_MAX := 16.0
const APPROACH_AFTER_LEFT_MULTIPLIER := 1.02
const APPROACH_AFTER_SPOOK_MULTIPLIER := 1.14
const APPROACH_AFTER_BAIT_STOLEN_MULTIPLIER := 1.06
const BITE_PHASE_INTEREST_MIN := 0.55
const BITE_PHASE_INTEREST_MAX := 1.45
const BITE_DECISION_MIN := 0.18
const BITE_DECISION_MAX := 0.55
const HOOK_INPUT_GUARD_MSEC := 260
const BITE_WINDOW_EARLY_GRACE_SECONDS := 0.35
const PLAYER_PULL_FORCE := 1.18
const PLAYER_RELEASE_FORCE := -0.92
const PLAYER_FORCE_RESPONSE := 3.05
const FISH_FORCE_RESPONSE := 4.25
const TENSION_DAMPING := 2.95
const TENSION_VELOCITY_LIMIT := 0.72
const BASE_FISH_DRAG := -0.055
const PROGRESS_DECAY := 0.095
const NEAR_ZONE_PROGRESS_MARGIN := 0.12
const REEL_LINE_OUT_START_RATIO := 0.16
const REEL_LINE_OUT_PULL_SCALE := 5.4
const REEL_HANDLE_FORWARD_SPEED := 7.5
const REEL_HANDLE_BACKWARD_SPEED := -5.4
const LURE_RETRIEVE_CHECK_INTERVAL := 0.48
const LURE_RETRIEVE_UPDATE_INTERVAL := 0.10
const LURE_RETRIEVE_MIN_PROGRESS_FOR_BITE := 0.08
const LURE_RETRIEVE_MAX_PROGRESS_FOR_BITE := 0.94
const TENSION_FIGHT_DEBUG := false
const MIN_FIGHT_DURATION := 6.5
const MAX_FIGHT_DURATION := 36.0
const SMALL_SAFE_ZONE_WIDTH := 0.35
const MEDIUM_SAFE_ZONE_WIDTH := 0.25
const LARGE_SAFE_ZONE_WIDTH := 0.16
const TROPHY_SAFE_ZONE_WIDTH := 0.10
const GREEN_ZONE_OVERLOAD_RELIEF_THRESHOLD := 0.55
const GREEN_ZONE_OVERLOAD_TIMER_MIN := 0.08
const GREEN_ZONE_OVERLOAD_TIMER_MAX := 0.24
const GREEN_ZONE_OVERLOAD_LIMIT_MIN := 1.75
const GREEN_ZONE_OVERLOAD_LIMIT_MAX := 2.80
const FIGHT_VIBRATION_MIN_INTERVAL := 0.15
const FIGHT_VIBRATION_MAX_INTERVAL := 0.35
const FIGHT_VIBRATION_MIN_MS := 20.0
const FIGHT_VIBRATION_MAX_MS := 140.0
const FIGHT_JERK_VIBRATION_MAX_MS := 220.0
const FAILURE_NO_BITE := "NO_BITE"
const FAILURE_BAD_DEPTH := "BAD_DEPTH"
const FAILURE_BAD_BAIT := "BAD_BAIT"
const FAILURE_BAD_HOOK := "BAD_HOOK"
const FAILURE_WEAK_TACKLE := "WEAK_TACKLE"
const FAILURE_LINE_BROKE := "LINE_BROKE"
const FAILURE_LEADER_BROKE := "LEADER_BROKE"
const FAILURE_ROD_OVERLOAD := "ROD_OVERLOAD"
const FAILURE_FISH_ESCAPED_LOW_TENSION := "FISH_ESCAPED_LOW_TENSION"
const FAILURE_FISH_ESCAPED_HIGH_TENSION := "FISH_ESCAPED_HIGH_TENSION"
const FAILURE_FISH_ESCAPED_HOOK := "FISH_ESCAPED_HOOK"
const FAILURE_FISH_TOO_STRONG := "FISH_TOO_STRONG"
const FAILURE_CONDITION_CRITICAL := "CONDITION_CRITICAL"
const FAILURE_UNKNOWN := "UNKNOWN"
const WeatherUIHelperScript := preload("res://scripts/ui/helpers/WeatherUIHelper.gd")
const SHOW_WEATHER_BITE_DEBUG := false

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

func _get_condition_manager() -> Node:
	return get_node_or_null("/root/PlayerConditionManager")

func _get_condition_fishing_modifiers() -> Dictionary:
	var condition_manager := _get_condition_manager()
	if condition_manager != null and condition_manager.has_method("get_fishing_modifiers"):
		var raw_modifiers = condition_manager.call("get_fishing_modifiers")
		if raw_modifiers is Dictionary:
			return (raw_modifiers as Dictionary).duplicate(true)
	return {
		"condition_quality": 1.0,
		"bite_chance_multiplier": 1.0,
		"bite_window_multiplier": 1.0,
		"reeling_difficulty_multiplier": 1.0,
		"escape_risk_multiplier": 1.0,
		"tension_fail_time_multiplier": 1.0,
		"false_nudge_chance_multiplier": 1.0,
		"error_chance_multiplier": 1.0,
		"reaction_multiplier": 1.0
	}

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

	var condition_manager := _get_condition_manager()
	if condition_manager != null and condition_manager.has_method("can_start_fishing") and not bool(condition_manager.call("can_start_fishing")):
		var block_message := ""
		if condition_manager.has_method("get_fishing_block_message"):
			block_message = str(condition_manager.call("get_fishing_block_message"))
		if block_message == "":
			block_message = "Вы слишком плохо себя чувствуете. Нужно уйти с водоёма и восстановиться."
		_emit_fishing_failure(
			FAILURE_CONDITION_CRITICAL,
			"Плохое самочувствие",
			block_message,
			"Отдохните в лагере или восстановитесь перед ловлей.",
			{"severity": "high", "spot_id": spot_id, "condition_state": condition_manager.call("get_condition_state") if condition_manager.has_method("get_condition_state") else {}}
		)
		return

	is_fishing = true
	is_reeling = false
	fishing_state = FishingState.CASTING
	_reel_input_active = false
	_last_hook_attempt_msec = 0
	_clear_active_bite_data()
	_tackle_stats = PlayerData.get_tackle_stats()
	_fight_mode = _get_effective_fight_mode_from_stats(_tackle_stats)
	if not BuildConfig.ENABLE_SPINNING_FEATURES:
		_fight_mode = "pole"
	_tackle_stats["fight_mode"] = _fight_mode
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
	var weather_type := _get_current_weather_type()
	var weather_modifiers := _get_weather_bite_modifiers(weather_type)
	var weather_bite_multiplier: float = float(weather_modifiers.get("bite_chance", 1.0))
	var wind_effects := _get_wind_effects(spot)
	weather_bite_multiplier *= float(wind_effects.get("bite_chance_multiplier", 1.0))
	var condition_modifiers := _get_condition_fishing_modifiers()
	weather_bite_multiplier *= float(condition_modifiers.get("bite_chance_multiplier", 1.0))
	weather_bite_multiplier *= clampf(float(_tackle_stats.get("rig_bite_chance_multiplier", 1.0)), 0.82, 1.05)

	if use_new_bite_system:
		_start_waiting_for_active_bite(spot, spot_id, available_fish, spot_depth_modifier)
		return

	var bite_speed: float = clamp(
		(1.0 + float(_tackle_stats.get("bite_detection_bonus", 0.0)) + float(_tackle_stats.get("fish_attraction", 0.0)) + bait_bonus * 0.35 - float(_tackle_stats.get("visibility_penalty", 0.0))) * spot_bite_modifier * clamp(time_activity_modifier, 0.55, 1.35) * weather_bite_multiplier,
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
		(0.64 + float(_tackle_stats.get("bite_detection_bonus", 0.0)) + float(_tackle_stats.get("fish_attraction", 0.0)) + bait_bonus + float(_tackle_stats.get("hook_success_bonus", 0.0)) - float(_tackle_stats.get("visibility_penalty", 0.0))) * spot_bite_modifier * clamp(time_activity_modifier, 0.42, 1.38) * weather_bite_multiplier,
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
				"time_activity_modifier": time_activity_modifier,
				"weather_type": weather_type,
				"weather_bite_multiplier": weather_bite_multiplier,
				"wind_effects": wind_effects,
				"condition_modifiers": condition_modifiers
			}
		)
		return

	var fish_id: String = _get_random_tackle_fish_id(
		available_fish,
		spot["rare_chance_modifier"],
		weather_modifiers
	)

	if not PlayerData.consume_current_terminal_tackle_for_bite(1):
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
	var catch_data: Dictionary = FishDatabase.create_catch(fish_id, _get_weather_adjusted_weight_bias(catch_fish, weather_modifiers))
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
	_attach_catch_context_metadata(catch_data)
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

		var early_hook_data := {
			"message": "Рыба испугалась!",
			"cooldown": EARLY_HOOK_COOLDOWN,
			"bite_phase": _bite_phase
		}
		_fail_hook("too_early", early_hook_data)
		return

	if fishing_state != FishingState.BITE_WINDOW:
		return

	var elapsed := _bite_window_elapsed
	var perfect_start := float(_pending_bite_data.get("perfect_start", 0.35))
	var perfect_end := float(_pending_bite_data.get("perfect_end", 1.05))

	if elapsed < maxf(perfect_start - BITE_WINDOW_EARLY_GRACE_SECONDS, 0.0):
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

	var condition_modifiers := _get_condition_fishing_modifiers()
	var raw_condition_modifiers = _pending_bite_data.get("condition_modifiers", {})
	if raw_condition_modifiers is Dictionary:
		condition_modifiers = (raw_condition_modifiers as Dictionary).duplicate(true)
	var error_multiplier := clampf(float(condition_modifiers.get("error_chance_multiplier", 1.0)), 1.0, 1.75)
	var condition_error_chance := clampf((error_multiplier - 1.0) * 0.18, 0.0, 0.14)
	if condition_error_chance > 0.0 and randf() < condition_error_chance:
		_fail_hook("condition_mistake", {
			"elapsed": elapsed,
			"perfect_start": perfect_start,
			"perfect_end": perfect_end,
			"message": "Подсечка сорвалась из-за плохого самочувствия."
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
	_reset_bite_preview_phase()
	_bite_check_timer = _roll_next_approach_delay(_get_active_bite_balance_data())
	_bite_window_elapsed = 0.0
	_bite_window_seconds = 0.0
	_false_nudge_timer = randf_range(FALSE_NUDGE_MIN_DELAY, FALSE_NUDGE_MAX_DELAY)
	_hook_cooldown_timer = 0.0
	fishing_state = FishingState.WAITING_FOR_BITE
	waiting_for_bite_started.emit()
	fishing_started.emit(0)
	if _fight_mode == "reel":
		_initialize_lure_retrieve()
		var retrieve_state := _get_lure_retrieve_state()
		if BuildConfig.ENABLE_VERBOSE_LOGS:
			_debug_log_spinning_state("retrieve_start", retrieve_state)
		lure_retrieve_started.emit(retrieve_state)


func _update_active_bite_system(delta: float) -> void:
	if not is_fishing or is_reeling:
		return

	if fishing_state == FishingState.WAITING_FOR_BITE:
		if _fight_mode == "reel":
			_update_lure_retrieve(delta)
			return

		_hook_cooldown_timer = max(_hook_cooldown_timer - delta, 0.0)
		_update_false_nudge(delta)

		if _hook_cooldown_timer > 0.0:
			return

		if _bite_phase == "idle" or _bite_phase == "approach_wait":
			_bite_check_timer -= delta
			if _bite_check_timer <= 0.0:
				_try_start_active_bite()
		else:
			_update_float_bite_phase(delta)
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

func _initialize_lure_retrieve() -> void:
	_lure_retrieve_progress = 0.0
	_lure_retrieve_speed = 0.0
	_lure_retrieve_update_timer = 0.0
	_bite_check_timer = LURE_RETRIEVE_CHECK_INTERVAL
	_hook_cooldown_timer = 0.0
	_spool_capacity = max(float(_tackle_stats.get("spool_capacity", 0.0)), 10.0)
	_line_out = clamp(max(8.0, _spool_capacity * 0.22), 4.0, max(_spool_capacity * 0.70, 4.0))
	_reel_handle_speed = 0.0
	_reel_line_out_speed = 0.0
	_feedback_message = "Веди приманку подмоткой."


func _update_lure_retrieve(delta: float) -> void:
	var retrieve_speed: float = max(float(_tackle_stats.get("retrieve_speed", 0.0)), 0.35)
	var target_speed: float = retrieve_speed if _reel_input_active else 0.0
	_lure_retrieve_speed = lerp(_lure_retrieve_speed, target_speed, clamp(delta * 7.0, 0.0, 1.0))

	if _reel_input_active:
		var retrieve_duration: float = clamp(10.5 / clamp(retrieve_speed, 0.55, 1.85), 6.2, 14.5)
		var previous_progress := _lure_retrieve_progress
		_lure_retrieve_progress = clamp(_lure_retrieve_progress + delta / retrieve_duration, 0.0, 1.0)
		_reel_line_out_speed = (_lure_retrieve_progress - previous_progress) / max(delta, 0.001)
		_line_out = lerp(max(_spool_capacity * 0.22, 8.0), 0.0, _lure_retrieve_progress)
		_reel_handle_speed = REEL_HANDLE_FORWARD_SPEED * clamp(_lure_retrieve_speed / retrieve_speed, 0.25, 1.35)
		_feedback_message = "Проводка: приманка идёт к берегу."
		_update_lure_retrieve_bite_check(delta)
	else:
		_reel_line_out_speed = 0.0
		_reel_handle_speed = lerp(_reel_handle_speed, 0.0, clamp(delta * 6.0, 0.0, 1.0))
		_feedback_message = "Зажми кнопку, чтобы вести приманку."

	_lure_retrieve_update_timer -= delta
	if _lure_retrieve_update_timer <= 0.0:
		_lure_retrieve_update_timer = LURE_RETRIEVE_UPDATE_INTERVAL
		lure_retrieve_updated.emit(_get_lure_retrieve_state())

	if _lure_retrieve_progress >= 1.0:
		_finish_lure_retrieve_no_bite()


func _update_lure_retrieve_bite_check(delta: float) -> void:
	if _lure_retrieve_progress < LURE_RETRIEVE_MIN_PROGRESS_FOR_BITE or _lure_retrieve_progress > LURE_RETRIEVE_MAX_PROGRESS_FOR_BITE:
		return

	_bite_check_timer -= delta
	if _bite_check_timer > 0.0:
		return
	_bite_check_timer = LURE_RETRIEVE_CHECK_INTERVAL
	_try_start_lure_retrieve_bite()


func _try_start_lure_retrieve_bite() -> void:
	if _active_available_fish.is_empty() or _active_spot.is_empty():
		_finish_lure_retrieve_no_bite()
		return

	var bite_data := _get_active_bite_balance_data()
	var middle_water_bonus: float = sin(clamp(_lure_retrieve_progress, 0.0, 1.0) * PI)
	var retrieve_speed: float = max(float(_tackle_stats.get("retrieve_speed", 0.0)), 0.35)
	var motion_bonus: float = clamp(_lure_retrieve_speed / retrieve_speed, 0.25, 1.20)
	var bite_chance: float = clamp(float(bite_data.get("bite_chance", 0.08)) * (0.72 + middle_water_bonus * 0.78) * (0.72 + motion_bonus * 0.30), 0.025, 0.24)
	if randf() > bite_chance:
		return

	var weather_modifiers: Dictionary = bite_data.get("weather_modifiers", {})
	var fish_id: String = _get_random_tackle_fish_id(
		_active_available_fish,
		float(_active_spot.get("rare_chance_modifier", 1.0)),
		weather_modifiers
	)

	if not PlayerData.consume_current_terminal_tackle_for_bite(1):
		is_fishing = false
		fishing_state = FishingState.FAILED
		_emit_fishing_failure(
			FAILURE_WEAK_TACKLE,
			"Нет приманки",
			"Приманка потеряна до поклёвки.",
			"Проверьте оснащение спиннинга.",
			{"severity": "low", "spot_id": _active_spot_id}
		)
		return

	var catch_data := _prepare_catch_data_for_bite(fish_id, bite_data)
	if catch_data.is_empty():
		is_fishing = false
		fishing_state = FishingState.FAILED
		_emit_fishing_failure(
			FAILURE_FISH_ESCAPED_HOOK,
			"",
			"Рыба ударила по приманке и сорвалась.",
			"Проверьте приманку, поводок и состояние снасти.",
			{"severity": "medium", "fish_id": fish_id, "spot_id": _active_spot_id}
		)
		return

	catch_data["lure_retrieve_progress"] = _lure_retrieve_progress
	fishing_state = FishingState.HOOKED
	_feedback_message = "Удар по приманке! Вываживай."
	_start_reeling(catch_data)


func _finish_lure_retrieve_no_bite() -> void:
	if not is_fishing or is_reeling or _fight_mode != "reel":
		return

	_fishing_cycle_id += 1
	is_fishing = false
	fishing_state = FishingState.IDLE
	_reel_input_active = false
	_reel_handle_speed = 0.0
	_lure_retrieve_speed = 0.0
	lure_retrieve_finished.emit(_get_lure_retrieve_state())
	_clear_active_bite_data()


func _get_lure_retrieve_state() -> Dictionary:
	return {
		"fight_mode": "reel",
		"phase": "retrieve",
		"retrieve_progress": _lure_retrieve_progress,
		"retrieve_speed": _lure_retrieve_speed,
		"input_active": _reel_input_active,
		"line_out": _line_out,
		"spool_capacity": _spool_capacity,
		"reel_handle_speed": _reel_handle_speed,
		"reel_line_out_speed": _reel_line_out_speed,
		"feedback_message": _feedback_message
	}


func _debug_log_spinning_state(context: String, state: Dictionary = {}) -> void:
	if not BuildConfig.ENABLE_VERBOSE_LOGS or _fight_mode != "reel":
		return
	print("[SpinningTest] %s tackle=%s handle=%.2f input=%s tension=%.2f fish_force=%.2f" % [
		context,
		str(_tackle_stats.get("tackle_type", "spinning")),
		float(state.get("reel_handle_speed", _reel_handle_speed)),
		str(state.get("input_active", _reel_input_active)),
		float(state.get("tension", _tension)),
		float(state.get("fish_force", _fish_force))
	])


func _get_effective_fight_mode_from_stats(stats: Dictionary) -> String:
	if not BuildConfig.ENABLE_SPINNING_FEATURES:
		return "pole"
	var tackle_type := str(stats.get("tackle_type", "float")).strip_edges().to_lower()
	var fight_mode := str(stats.get("fight_mode", "pole")).strip_edges().to_lower()
	if tackle_type == "spinning" and fight_mode == "reel":
		return "reel"
	return "pole"


func _update_false_nudge(delta: float) -> void:
	if _fight_mode == "reel":
		return

	_false_nudge_timer -= delta
	if _false_nudge_timer > 0.0:
		return

	_false_nudge_timer = randf_range(FALSE_NUDGE_MIN_DELAY, FALSE_NUDGE_MAX_DELAY)
	var wind_effects: Dictionary = _get_wind_effects(_active_spot)
	var condition_modifiers := _get_condition_fishing_modifiers()
	var false_nudge_chance: float = clamp(
		(FALSE_NUDGE_CHANCE + float(wind_effects.get("false_bite_chance", 0.0)))
			* clampf(float(condition_modifiers.get("false_nudge_chance_multiplier", 1.0)), 1.0, 1.75),
		0.06,
		0.82
	)
	if randf() > false_nudge_chance:
		return

	float_nudge.emit(_build_false_nudge_data(wind_effects))


func _build_false_nudge_data(wind_effects: Dictionary = {}) -> Dictionary:
	var roll: float = randf()
	var kind: String = "small"
	var strength: float = randf_range(0.18, 0.32)
	var duration: float = randf_range(0.26, 0.42)
	var wind_false_bonus: float = clamp(float(wind_effects.get("false_bite_chance", 0.0)), 0.0, 0.45)

	if roll > 0.82:
		kind = "suspicious"
		strength = randf_range(0.46, 0.62)
		duration = randf_range(0.42, 0.62)
	elif roll > 0.52:
		kind = "medium"
		strength = randf_range(0.30, 0.46)
		duration = randf_range(0.34, 0.52)

	if bool(wind_effects.get("gust_active", false)) and roll > 0.58:
		kind = "suspicious"
		strength += 0.10
		duration += 0.08

	return {
		"kind": kind,
		"strength": clamp(strength + wind_false_bonus * 0.35, 0.12, 0.82),
		"duration": clamp(duration + wind_false_bonus * 0.18, 0.18, 0.78),
		"wind_speed_mps": float(wind_effects.get("wind_speed_mps", 0.0)),
		"gust_active": bool(wind_effects.get("gust_active", false))
	}


func _try_start_active_bite() -> void:
	if _active_available_fish.is_empty() or _active_spot.is_empty():
		is_fishing = false
		fishing_state = FishingState.FAILED
		_emit_no_candidate_failure(_active_spot, _active_spot_id)
		return

	var bite_data := _get_active_bite_balance_data()
	var approach_chance: float = clampf(0.64 + float(bite_data.get("bite_chance", 0.10)) * 1.85, 0.62, 0.96)
	if randf() > approach_chance:
		_schedule_next_fish_approach(bite_data, "no_fish_approached")
		return

	var weather_modifiers: Dictionary = bite_data.get("weather_modifiers", {})
	var fish_id: String = _get_random_tackle_fish_id(
		_active_available_fish,
		float(_active_spot.get("rare_chance_modifier", 1.0)),
		weather_modifiers
	)

	var staged_catch_data := _prepare_catch_data_for_bite(fish_id, bite_data)
	if staged_catch_data.is_empty():
		_schedule_next_fish_approach(bite_data, "fish_inspected_and_left")
		return

	var fish := FishDatabase.get_fish(fish_id)
	var profile := _get_fish_bite_profile(fish, float(staged_catch_data.get("weight", -1.0)))
	profile = _apply_bite_profile_context(profile, fish, fish_id, bite_data)
	if randf() > float(profile.get("interest_chance", 0.64)):
		_emit_bite_preview_event("lost_interest", {
			"fish_id": fish_id,
			"behavior": str(profile.get("behavior", "calm")),
			"visual_style": "lost_interest",
			"strength": 0.14,
			"duration": 0.35,
			"outcome": "fish_inspected_and_left",
			"wind_effects": bite_data.get("wind_effects", {})
		})
		_schedule_next_fish_approach(bite_data, "fish_inspected_and_left")
		return

	_bite_phase = "interest"
	_bite_phase_timer = randf_range(BITE_PHASE_INTEREST_MIN, BITE_PHASE_INTEREST_MAX)
	_bite_phase_nibble_index = 0
	_bite_phase_nibble_count = randi_range(int(profile.get("nibble_count_min", 1)), int(profile.get("nibble_count_max", 3)))
	_bite_phase_data = {
		"fish_id": fish_id,
		"fish": fish.duplicate(true),
		"catch_data": staged_catch_data.duplicate(true),
		"profile": profile.duplicate(true),
		"balance_data": bite_data.duplicate(true)
	}
	_emit_bite_preview_event("interest", {
		"fish_id": fish_id,
		"behavior": str(profile.get("behavior", "calm")),
		"visual_style": "interest",
		"strength": 0.12,
		"duration": _bite_phase_timer,
		"wind_effects": bite_data.get("wind_effects", {}),
		"bite_visibility_multiplier": float(profile.get("bite_visibility_multiplier", 1.0))
	})
	return

	if not PlayerData.consume_current_terminal_tackle_for_bite(1):
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

	var catch_data := _prepare_catch_data_for_bite(fish_id, bite_data)
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


func _update_float_bite_phase(delta: float) -> void:
	if _bite_phase == "idle" or _bite_phase == "approach_wait":
		return

	if _bite_phase_data.is_empty() and _bite_phase != "lost_interest":
		_schedule_next_fish_approach(_get_active_bite_balance_data(), "fish_inspected_and_left")
		return

	_bite_phase_timer -= delta
	if _bite_phase_timer > 0.0:
		return

	match _bite_phase:
		"interest":
			_advance_interest_phase()
		"nibble_pause":
			_start_next_nibble_phase()
		"nibble":
			if _bite_phase_nibble_index >= _bite_phase_nibble_count:
				_bite_phase = "decision"
				_bite_phase_timer = randf_range(BITE_DECISION_MIN, BITE_DECISION_MAX)
			else:
				var profile: Dictionary = _bite_phase_data.get("profile", {})
				_bite_phase = "nibble_pause"
				_bite_phase_timer = randf_range(
					float(profile.get("nibble_interval_min", 0.28)),
					float(profile.get("nibble_interval_max", 0.82))
				)
		"decision":
			_resolve_bite_decision()
		"take":
			_open_bite_window_from_phase()
		"lost_interest":
			_finish_bite_preview_sequence(str(_bite_phase_data.get("outcome", "fish_nibbled_and_left")))
		"bait_stolen":
			_finish_bite_preview_sequence("bait_stolen")
		_:
			_schedule_next_fish_approach(_get_active_bite_balance_data(), "fish_inspected_and_left")


func _advance_interest_phase() -> void:
	var profile: Dictionary = _bite_phase_data.get("profile", {})
	var spook_chance: float = clampf(float(profile.get("spook_chance", 0.08)) * 0.35, 0.0, 0.24)
	if randf() < spook_chance:
		_start_lost_interest_phase("fish_inspected_and_left")
		return

	if _bite_phase_nibble_count <= 0:
		_bite_phase = "decision"
		_bite_phase_timer = randf_range(BITE_DECISION_MIN, BITE_DECISION_MAX)
		return

	_bite_phase = "nibble_pause"
	_bite_phase_timer = randf_range(
		float(profile.get("nibble_interval_min", 0.28)),
		float(profile.get("nibble_interval_max", 0.82))
	)


func _start_next_nibble_phase() -> void:
	if _bite_phase_data.is_empty():
		_schedule_next_fish_approach(_get_active_bite_balance_data(), "fish_inspected_and_left")
		return

	if _bite_phase_nibble_index >= _bite_phase_nibble_count:
		_bite_phase = "decision"
		_bite_phase_timer = randf_range(BITE_DECISION_MIN, BITE_DECISION_MAX)
		return

	var profile: Dictionary = _bite_phase_data.get("profile", {})
	var wind_effects: Dictionary = _get_phase_wind_effects()
	var visibility_multiplier: float = clampf(
		float(profile.get("bite_visibility_multiplier", 1.0)) * float(wind_effects.get("bite_visibility_multiplier", 1.0)),
		0.45,
		1.16
	)
	var style := str(profile.get("visual_style", "nibble"))
	var strength: float = randf_range(
		float(profile.get("nibble_strength_min", 0.18)),
		float(profile.get("nibble_strength_max", 0.42))
	) * visibility_multiplier
	var duration: float = clampf(randf_range(0.16, 0.36) * (1.18 if style == "cautious_nibble" else 1.0), 0.12, 0.62)

	_bite_phase_nibble_index += 1
	_bite_phase = "nibble"
	_bite_phase_timer = duration
	_emit_bite_preview_event("nibble", {
		"fish_id": str(_bite_phase_data.get("fish_id", "")),
		"behavior": str(profile.get("behavior", "calm")),
		"strength": clampf(strength, 0.08, 0.92),
		"duration": duration,
		"nibble_index": _bite_phase_nibble_index,
		"nibble_count": _bite_phase_nibble_count,
		"visual_style": style,
		"wind_effects": wind_effects,
		"bite_visibility_multiplier": visibility_multiplier
	})


func _resolve_bite_decision() -> void:
	if _bite_phase_data.is_empty():
		_schedule_next_fish_approach(_get_active_bite_balance_data(), "fish_inspected_and_left")
		return

	var profile: Dictionary = _bite_phase_data.get("profile", {})
	var commit_chance: float = clampf(float(profile.get("commit_chance", 0.45)), 0.04, 0.90)
	var bait_steal_chance: float = clampf(float(profile.get("bait_steal_chance", 0.10)), 0.0, 0.45)
	var spook_chance: float = clampf(float(profile.get("spook_chance", 0.08)), 0.0, 0.44)
	var max_nibbles: int = max(int(profile.get("nibble_count_max", _bite_phase_nibble_count)), _bite_phase_nibble_count)
	var continue_chance: float = clampf(0.10 + (1.0 - commit_chance) * 0.12 + spook_chance * 0.10, 0.04, 0.30)
	if _bite_phase_nibble_index < max_nibbles and randf() < continue_chance:
		_bite_phase_nibble_count += 1
		_bite_phase = "nibble_pause"
		_bite_phase_timer = randf_range(
			float(profile.get("nibble_interval_min", 0.28)),
			float(profile.get("nibble_interval_max", 0.82))
		)
		return

	var roll := randf()
	if roll < commit_chance:
		_start_strong_bite_phase()
		return

	if roll < commit_chance + bait_steal_chance:
		_start_bait_stolen_phase()
		return

	_start_lost_interest_phase("fish_nibbled_and_left" if roll > commit_chance + bait_steal_chance + spook_chance else "fish_inspected_and_left")


func _start_lost_interest_phase(outcome: String) -> void:
	var profile: Dictionary = _bite_phase_data.get("profile", {})
	_bite_phase_data["outcome"] = outcome
	_bite_phase = "lost_interest"
	_bite_phase_timer = 0.46
	_emit_bite_preview_event("lost_interest", {
		"fish_id": str(_bite_phase_data.get("fish_id", "")),
		"behavior": str(profile.get("behavior", "calm")),
		"strength": 0.12,
		"duration": _bite_phase_timer,
		"visual_style": "lost_interest",
		"outcome": outcome,
		"wind_effects": _get_phase_wind_effects(),
		"bite_visibility_multiplier": float(profile.get("bite_visibility_multiplier", 1.0))
	})


func _start_bait_stolen_phase() -> void:
	if not _consume_terminal_tackle_for_bite_outcome("bait_stolen"):
		return

	var profile: Dictionary = _bite_phase_data.get("profile", {})
	_bite_phase_data["outcome"] = "bait_stolen"
	_bite_phase = "bait_stolen"
	_bite_phase_timer = 0.58
	_emit_bite_preview_event("bait_stolen", {
		"fish_id": str(_bite_phase_data.get("fish_id", "")),
		"behavior": str(profile.get("behavior", "calm")),
		"strength": clampf(float(profile.get("nibble_strength_max", 0.45)) + 0.16, 0.25, 0.82),
		"duration": _bite_phase_timer,
		"visual_style": "bait_stolen",
		"outcome": "bait_stolen",
		"wind_effects": _get_phase_wind_effects(),
		"bite_visibility_multiplier": float(profile.get("bite_visibility_multiplier", 1.0))
	})


func _start_strong_bite_phase() -> void:
	if _bite_phase_data.is_empty():
		_schedule_next_fish_approach(_get_active_bite_balance_data(), "fish_inspected_and_left")
		return

	var fish_id := str(_bite_phase_data.get("fish_id", ""))
	var catch_data: Dictionary = _bite_phase_data.get("catch_data", {})
	var balance_data: Dictionary = _bite_phase_data.get("balance_data", {})
	var profile: Dictionary = _bite_phase_data.get("profile", {})
	if fish_id == "" or catch_data.is_empty():
		_schedule_next_fish_approach(balance_data, "fish_inspected_and_left")
		return

	if not _consume_terminal_tackle_for_bite_outcome("strong_bite"):
		return

	var bite_balance := balance_data.duplicate(true)
	bite_balance["bite_profile"] = profile.duplicate(true)
	_pending_catch = catch_data.duplicate(true)
	_pending_bite_data = _build_bite_window_data(fish_id, _pending_catch, bite_balance)
	_bite_window_seconds = float(_pending_bite_data.get("bite_window_seconds", BASE_BITE_WINDOW_SECONDS))
	_bite_window_elapsed = 0.0
	var take_delay := randf_range(float(profile.get("take_delay_min", 0.10)), float(profile.get("take_delay_max", 0.36)))
	_bite_phase_data["outcome"] = "strong_bite"
	_bite_phase = "take"
	_bite_phase_timer = take_delay
	_emit_bite_preview_event("take", {
		"fish_id": fish_id,
		"behavior": str(profile.get("behavior", "calm")),
		"strength": clampf(float(_pending_bite_data.get("strength", profile.get("strong_bite_strength", 0.75))), 0.30, 1.0),
		"duration": take_delay,
		"visual_style": str(_pending_bite_data.get("visual_style", profile.get("visual_style", "submerge"))),
		"wind_effects": _get_phase_wind_effects(),
		"bite_visibility_multiplier": float(_pending_bite_data.get("bite_visibility_multiplier", profile.get("bite_visibility_multiplier", 1.0))),
		"submerge_speed": float(profile.get("submerge_speed", 1.0))
	})


func _open_bite_window_from_phase() -> void:
	if _pending_catch.is_empty() or _pending_bite_data.is_empty():
		_schedule_next_fish_approach(_get_active_bite_balance_data(), "fish_inspected_and_left")
		return

	_bite_window_seconds = float(_pending_bite_data.get("bite_window_seconds", BASE_BITE_WINDOW_SECONDS))
	_bite_window_elapsed = 0.0
	fishing_state = FishingState.BITE_WINDOW
	_reset_bite_preview_phase()
	bite_started.emit(_pending_bite_data.duplicate(true))


func _consume_terminal_tackle_for_bite_outcome(outcome: String) -> bool:
	if PlayerData.consume_current_terminal_tackle_for_bite(1):
		return true

	is_fishing = false
	fishing_state = FishingState.FAILED
	_reset_bite_preview_phase()
	_emit_fishing_failure(
		FAILURE_WEAK_TACKLE,
		"РќРµС‚ РЅР°Р¶РёРІРєРё",
		"РќР°Р¶РёРІРєР° Р·Р°РєРѕРЅС‡РёР»Р°СЃСЊ РґРѕ РїРѕРєР»С‘РІРєРё.",
		"РџРѕРїРѕР»РЅРёС‚Рµ РЅР°Р¶РёРІРєСѓ РёР»Рё СЌРєРёРїРёСЂСѓР№С‚Рµ РґСЂСѓРіСѓСЋ.",
		{"severity": "low", "spot_id": _active_spot_id, "outcome": outcome}
	)
	return false


func _finish_bite_preview_sequence(outcome: String) -> void:
	var balance_data: Dictionary = _bite_phase_data.get("balance_data", {})
	_pending_catch.clear()
	_pending_bite_data.clear()
	_bite_window_elapsed = 0.0
	_bite_window_seconds = 0.0
	_reset_bite_preview_phase()
	_schedule_next_fish_approach(balance_data, outcome)


func _schedule_next_fish_approach(balance_data: Dictionary = {}, outcome: String = "no_fish_approached") -> void:
	_pending_catch.clear()
	_pending_bite_data.clear()
	_bite_window_elapsed = 0.0
	_bite_window_seconds = 0.0
	_bite_phase = "approach_wait"
	_bite_phase_timer = 0.0
	_bite_phase_data.clear()
	_bite_phase_nibble_index = 0
	_bite_phase_nibble_count = 0
	_bite_check_timer = _roll_next_approach_delay(balance_data, outcome)


func _roll_next_approach_delay(balance_data: Dictionary = {}, outcome: String = "") -> float:
	if balance_data.is_empty():
		balance_data = _get_active_bite_balance_data()

	var bite_chance: float = clampf(float(balance_data.get("bite_chance", 0.08)), 0.02, 0.28)
	var score: float = clampf((bite_chance - 0.04) / 0.20, 0.0, 1.0)
	var min_delay := APPROACH_POOR_MIN
	var max_delay := APPROACH_POOR_MAX
	if score >= 0.64:
		min_delay = APPROACH_GOOD_MIN
		max_delay = APPROACH_GOOD_MAX
	elif score >= 0.28:
		min_delay = APPROACH_NORMAL_MIN
		max_delay = APPROACH_NORMAL_MAX
	elif score >= 0.12:
		min_delay = APPROACH_WEAK_MIN
		max_delay = APPROACH_WEAK_MAX

	var delay := randf_range(min_delay, max_delay)
	match outcome:
		"fish_inspected_and_left", "fish_nibbled_and_left":
			delay *= APPROACH_AFTER_LEFT_MULTIPLIER
		"fish_spooked", "too_early", "early_hook":
			delay *= APPROACH_AFTER_SPOOK_MULTIPLIER
		"bait_stolen":
			delay *= APPROACH_AFTER_BAIT_STOLEN_MULTIPLIER
		"missed_bite", "late_hook":
			delay *= 1.28
	return max(delay, BITE_CHECK_INTERVAL)


func _reset_bite_preview_phase() -> void:
	_bite_phase = "idle"
	_bite_phase_timer = 0.0
	_bite_phase_data.clear()
	_bite_phase_nibble_index = 0
	_bite_phase_nibble_count = 0


func _get_phase_wind_effects() -> Dictionary:
	var balance_data: Dictionary = _bite_phase_data.get("balance_data", {})
	if balance_data.has("wind_effects") and balance_data.get("wind_effects") is Dictionary:
		return (balance_data.get("wind_effects") as Dictionary).duplicate(true)
	return _get_wind_effects(_active_spot)


func _emit_bite_preview_event(phase: String, event_data: Dictionary = {}) -> void:
	var payload := event_data.duplicate(true)
	payload["phase"] = phase
	if not payload.has("wind_effects"):
		payload["wind_effects"] = _get_phase_wind_effects()
	if not payload.has("bite_phase"):
		payload["bite_phase"] = _bite_phase
	bite_preview_event.emit(payload)


func _get_active_bite_balance_data() -> Dictionary:
	var bait_bonus: float = _get_best_bait_bonus(_active_available_fish)
	var time_activity_modifier: float = _get_average_time_activity_modifier(_active_available_fish)
	var spot_bite_modifier: float = float(_active_spot.get("bite_chance_modifier", 1.0)) * _active_spot_depth_modifier
	var weather_type := _get_current_weather_type()
	var weather_modifiers := _get_weather_bite_modifiers(weather_type)
	var weather_bite_multiplier: float = float(weather_modifiers.get("bite_chance", 1.0))
	var wind_effects := _get_wind_effects(_active_spot)
	var condition_modifiers := _get_condition_fishing_modifiers()
	var rig_bite_multiplier: float = clampf(float(_tackle_stats.get("rig_bite_chance_multiplier", 1.0)), 0.82, 1.05)
	var bite_chance: float = clamp(
		(
			0.115
			+ float(_tackle_stats.get("bite_detection_bonus", 0.0)) * 0.10
			+ float(_tackle_stats.get("fish_attraction", 0.0)) * 0.10
			+ bait_bonus * 0.09
			+ float(_tackle_stats.get("hook_success_bonus", 0.0)) * 0.06
			- float(_tackle_stats.get("visibility_penalty", 0.0)) * 0.08
		) * spot_bite_modifier * clamp(time_activity_modifier, 0.42, 1.38) * weather_bite_multiplier * float(wind_effects.get("bite_chance_multiplier", 1.0)) * float(condition_modifiers.get("bite_chance_multiplier", 1.0)) * rig_bite_multiplier,
		0.075,
		0.30
	)

	if SHOW_WEATHER_BITE_DEBUG and BuildConfig.ENABLE_VERBOSE_LOGS:
		print("[WeatherBite] weather=%s bite_x=%.2f final=%.3f modifiers=%s" % [
			weather_type,
			weather_bite_multiplier,
			bite_chance,
			str(weather_modifiers)
		])

	return {
		"bite_chance": bite_chance,
		"spot_depth_modifier": _active_spot_depth_modifier,
		"bait_bonus": bait_bonus,
		"time_activity_modifier": time_activity_modifier,
		"spot_bite_modifier": spot_bite_modifier,
		"weather_type": weather_type,
		"weather_bite_multiplier": weather_bite_multiplier,
		"weather_modifiers": weather_modifiers,
		"wind_effects": wind_effects,
		"condition_modifiers": condition_modifiers
	}


func _get_fish_bite_profile(fish: Dictionary, catch_weight: float = -1.0) -> Dictionary:
	var behavior := str(fish.get("behavior_type", fish.get("behavior", "calm"))).to_lower()
	var aggression: float = clampf(float(fish.get("aggression", 0.35)), 0.0, 1.0)
	var escape_risk: float = clampf(float(fish.get("escape_risk", fish.get("escape_chance", 0.20))), 0.0, 1.0)
	var reference_weight: float = catch_weight
	if reference_weight <= 0.0:
		reference_weight = (float(fish.get("min_weight", 0.05)) + float(fish.get("max_weight", 0.8))) * 0.5
	var max_weight: float = max(float(fish.get("max_weight", max(reference_weight, 0.1))), 0.1)
	var size_ratio: float = clampf(reference_weight / max_weight, 0.0, 1.0)
	var size_class := _get_fish_size_class(fish, reference_weight)
	var rarity := str(fish.get("rarity", "common")).to_lower()

	var profile := {
		"approach_interval_min": APPROACH_NORMAL_MIN,
		"approach_interval_max": APPROACH_NORMAL_MAX,
		"interest_chance": 0.86,
		"commit_chance": 0.68,
		"nibble_count_min": 1,
		"nibble_count_max": 3,
		"nibble_interval_min": 0.28,
		"nibble_interval_max": 0.82,
		"nibble_strength_min": 0.18,
		"nibble_strength_max": 0.42,
		"take_delay_min": 0.18,
		"take_delay_max": 0.46,
		"strong_bite_strength": 0.68,
		"submerge_speed": 1.0,
		"spook_chance": 0.08,
		"bait_steal_chance": 0.10,
		"bite_window_multiplier": 1.0,
		"visual_style": "nibble",
		"behavior": behavior,
		"bite_visibility_multiplier": 1.0
	}

	match behavior:
		"cautious", "shy":
			profile["interest_chance"] = 0.78
			profile["commit_chance"] = 0.54
			profile["nibble_count_min"] = 2
			profile["nibble_count_max"] = 5
			profile["nibble_interval_min"] = 0.44
			profile["nibble_interval_max"] = 1.18
			profile["nibble_strength_min"] = 0.10
			profile["nibble_strength_max"] = 0.30
			profile["take_delay_min"] = 0.18
			profile["take_delay_max"] = 0.46
			profile["spook_chance"] = 0.16
			profile["bait_steal_chance"] = 0.14
			profile["bite_window_multiplier"] = 0.90
			profile["visual_style"] = "cautious_nibble"
		"aggressive":
			profile["interest_chance"] = 0.90
			profile["commit_chance"] = 0.76
			profile["nibble_count_min"] = 0
			profile["nibble_count_max"] = 2
			profile["nibble_interval_min"] = 0.14
			profile["nibble_interval_max"] = 0.42
			profile["nibble_strength_min"] = 0.34
			profile["nibble_strength_max"] = 0.68
			profile["take_delay_min"] = 0.10
			profile["take_delay_max"] = 0.30
			profile["strong_bite_strength"] = 0.84
			profile["submerge_speed"] = 1.34
			profile["spook_chance"] = 0.06
			profile["bait_steal_chance"] = 0.08
			profile["bite_window_multiplier"] = 1.04
			profile["visual_style"] = "aggressive_take"
		"erratic":
			profile["interest_chance"] = 0.84
			profile["commit_chance"] = 0.68
			profile["nibble_count_min"] = 1
			profile["nibble_count_max"] = 4
			profile["nibble_interval_min"] = 0.18
			profile["nibble_interval_max"] = 0.70
			profile["nibble_strength_min"] = 0.22
			profile["nibble_strength_max"] = 0.62
			profile["take_delay_min"] = 0.14
			profile["take_delay_max"] = 0.36
			profile["strong_bite_strength"] = 0.78
			profile["submerge_speed"] = 1.18
			profile["spook_chance"] = 0.11
			profile["bait_steal_chance"] = 0.12
			profile["visual_style"] = "erratic_take"

	if size_class == "small" or max_weight <= 0.22:
		profile["interest_chance"] = float(profile["interest_chance"]) + 0.04
		profile["commit_chance"] = float(profile["commit_chance"]) - 0.06
		profile["nibble_count_min"] = max(int(profile["nibble_count_min"]), 3)
		profile["nibble_count_max"] = max(int(profile["nibble_count_max"]), 6)
		profile["nibble_interval_min"] = min(float(profile["nibble_interval_min"]), 0.18)
		profile["nibble_interval_max"] = min(float(profile["nibble_interval_max"]), 0.52)
		profile["nibble_strength_min"] = min(float(profile["nibble_strength_min"]), 0.08)
		profile["nibble_strength_max"] = min(float(profile["nibble_strength_max"]), 0.28)
		profile["bait_steal_chance"] = float(profile["bait_steal_chance"]) + 0.10
		profile["visual_style"] = "small_fish_taps"
	elif size_class == "large" or reference_weight >= 1.35 or max_weight >= 2.25:
		profile["interest_chance"] = float(profile["interest_chance"]) - 0.04
		profile["commit_chance"] = float(profile["commit_chance"]) - 0.01
		profile["nibble_count_min"] = max(int(profile["nibble_count_min"]), 1)
		profile["nibble_count_max"] = max(int(profile["nibble_count_max"]), 3)
		profile["nibble_interval_min"] = max(float(profile["nibble_interval_min"]), 0.42)
		profile["nibble_interval_max"] = max(float(profile["nibble_interval_max"]), 1.10)
		profile["nibble_strength_min"] = max(float(profile["nibble_strength_min"]), 0.30)
		profile["nibble_strength_max"] = max(float(profile["nibble_strength_max"]), 0.62)
		profile["take_delay_min"] = max(float(profile["take_delay_min"]), 0.18)
		profile["take_delay_max"] = max(float(profile["take_delay_max"]), 0.48)
		profile["strong_bite_strength"] = max(float(profile["strong_bite_strength"]), 0.82)
		profile["submerge_speed"] = 0.72
		profile["bite_window_multiplier"] = float(profile["bite_window_multiplier"]) * 0.94
		profile["visual_style"] = "heavy_take"

	profile["interest_chance"] = float(profile["interest_chance"]) + (aggression - 0.35) * 0.10 - escape_risk * 0.06
	profile["commit_chance"] = float(profile["commit_chance"]) + (aggression - 0.35) * 0.24 - escape_risk * 0.12 + size_ratio * 0.04
	profile["spook_chance"] = float(profile["spook_chance"]) + escape_risk * 0.12 - aggression * 0.04
	profile["strong_bite_strength"] = float(profile["strong_bite_strength"]) + aggression * 0.10 + size_ratio * 0.12

	if rarity == "rare":
		profile["commit_chance"] = float(profile["commit_chance"]) - 0.03
		profile["spook_chance"] = float(profile["spook_chance"]) + 0.03
	elif rarity == "very_rare" or rarity == "legendary":
		profile["commit_chance"] = float(profile["commit_chance"]) - 0.04
		profile["spook_chance"] = float(profile["spook_chance"]) + 0.06
		profile["bite_window_multiplier"] = float(profile["bite_window_multiplier"]) * 0.92

	profile["interest_chance"] = clampf(float(profile["interest_chance"]), 0.18, 0.94)
	profile["commit_chance"] = clampf(float(profile["commit_chance"]), 0.06, 0.88)
	profile["spook_chance"] = clampf(float(profile["spook_chance"]), 0.0, 0.42)
	profile["bait_steal_chance"] = clampf(float(profile["bait_steal_chance"]), 0.0, 0.46)
	profile["strong_bite_strength"] = clampf(float(profile["strong_bite_strength"]), 0.30, 1.0)
	profile["bite_window_multiplier"] = clampf(float(profile["bite_window_multiplier"]), 0.68, 1.26)
	return profile


func _apply_bite_profile_context(profile: Dictionary, fish: Dictionary, fish_id: String, balance_data: Dictionary) -> Dictionary:
	var result := profile.duplicate(true)
	var depth_multiplier: float = clampf(_get_depth_match_multiplier(fish), 0.0, 1.25)
	var bait_multiplier: float = clampf(_get_bait_match_multiplier(fish, fish_id), 0.0, 1.80)
	var hook_multiplier: float = clampf(_get_hook_match_multiplier(fish), 0.0, 1.30)
	var line_multiplier: float = clampf(_get_line_visibility_multiplier(fish), 0.50, 1.16)
	var time_multiplier: float = clampf(_get_time_activity_modifier(fish), 0.30, 1.48)
	var peak_multiplier: float = 1.0 + _get_time_peak_modifier(fish) * 0.16
	var weather_modifiers: Dictionary = balance_data.get("weather_modifiers", _get_weather_bite_modifiers(_get_current_weather_type()))
	var weather_multiplier: float = clampf(_get_weather_fish_weight_multiplier(fish, weather_modifiers), 0.65, 1.35)
	var wind_effects: Dictionary = balance_data.get("wind_effects", _get_wind_effects(_active_spot))
	var condition_modifiers: Dictionary = balance_data.get("condition_modifiers", _get_condition_fishing_modifiers())
	var condition_multiplier: float = clampf(float(condition_modifiers.get("bite_chance_multiplier", 1.0)), 0.65, 1.25)
	var temp_multiplier: float = _get_temperature_activity_modifier(fish)
	var rig_commit_multiplier: float = clampf(float(_tackle_stats.get("rig_commit_multiplier", 1.0)), 0.86, 1.05)
	var rig_interest_multiplier: float = clampf(float(_tackle_stats.get("rig_bite_chance_multiplier", 1.0)), 0.82, 1.05)

	var interest_context: float = clampf(
		(0.78 + depth_multiplier * 0.22)
			* (0.60 + bait_multiplier * 0.34)
			* (0.78 + line_multiplier * 0.20)
			* clampf(time_multiplier, 0.40, 1.22)
			* weather_multiplier
			* condition_multiplier
			* temp_multiplier
			* rig_interest_multiplier,
		0.42,
		1.45
	)
	var commit_context: float = clampf(
		(0.62 + bait_multiplier * 0.36)
			* (0.64 + hook_multiplier * 0.32)
			* (0.88 + _get_time_peak_modifier(fish) * 0.18)
			* clampf(weather_multiplier, 0.70, 1.22)
			* temp_multiplier
			* rig_commit_multiplier,
		0.38,
		1.38
	)
	result["interest_chance"] = clampf(float(result.get("interest_chance", 0.68)) * interest_context, 0.16, 0.95)
	result["commit_chance"] = clampf(float(result.get("commit_chance", 0.44)) * commit_context, 0.10, 0.90)

	if bait_multiplier < 0.55:
		result["commit_chance"] = float(result["commit_chance"]) * 0.78
		result["bait_steal_chance"] = float(result.get("bait_steal_chance", 0.10)) + 0.035
		result["nibble_count_max"] = max(int(result.get("nibble_count_max", 3)), int(result.get("nibble_count_min", 1)) + 1)
	elif bait_multiplier > 1.08:
		result["commit_chance"] = float(result["commit_chance"]) + 0.06
		result["interest_chance"] = float(result["interest_chance"]) + 0.04

	if hook_multiplier < 0.70:
		result["commit_chance"] = float(result["commit_chance"]) * clampf(0.74 + hook_multiplier * 0.24, 0.64, 0.90)
		result["spook_chance"] = float(result.get("spook_chance", 0.08)) + (0.70 - hook_multiplier) * 0.12
		result["bite_window_multiplier"] = float(result.get("bite_window_multiplier", 1.0)) * clampf(0.86 + hook_multiplier * 0.14, 0.78, 0.96)
	elif hook_multiplier > 1.06:
		result["bite_window_multiplier"] = float(result.get("bite_window_multiplier", 1.0)) * 1.04

	if line_multiplier < 0.82:
		result["spook_chance"] = float(result.get("spook_chance", 0.08)) + (0.82 - line_multiplier) * 0.12
		result["interest_chance"] = float(result["interest_chance"]) * clampf(0.78 + line_multiplier * 0.22, 0.68, 1.0)

	var wind_visibility: float = clampf(float(wind_effects.get("bite_visibility_multiplier", 1.0)), 0.68, 1.08)
	var wind_penalty: float = clampf(float(wind_effects.get("effective_wind_penalty", 0.0)), 0.0, 0.60)
	result["bite_visibility_multiplier"] = clampf(float(result.get("bite_visibility_multiplier", 1.0)) * wind_visibility, 0.48, 1.16)
	result["nibble_strength_min"] = float(result.get("nibble_strength_min", 0.16)) * clampf(wind_visibility + 0.05, 0.70, 1.08)
	result["nibble_strength_max"] = float(result.get("nibble_strength_max", 0.42)) * clampf(wind_visibility + 0.04, 0.70, 1.08)
	result["spook_chance"] = float(result.get("spook_chance", 0.08)) + wind_penalty * 0.05
	result["commit_chance"] = float(result["commit_chance"]) * peak_multiplier
	result["bite_window_multiplier"] = float(result.get("bite_window_multiplier", 1.0)) * clampf(float(condition_modifiers.get("reaction_multiplier", 1.0)), 0.74, 1.14)

	result["interest_chance"] = clampf(float(result["interest_chance"]), 0.14, 0.95)
	result["commit_chance"] = clampf(float(result["commit_chance"]), 0.08, 0.92)
	result["spook_chance"] = clampf(float(result.get("spook_chance", 0.08)), 0.0, 0.48)
	result["bait_steal_chance"] = clampf(float(result.get("bait_steal_chance", 0.10)), 0.0, 0.50)
	result["bite_window_multiplier"] = clampf(float(result.get("bite_window_multiplier", 1.0)), 0.62, 1.34)
	result["nibble_strength_min"] = clampf(float(result.get("nibble_strength_min", 0.12)), 0.06, 0.75)
	result["nibble_strength_max"] = clampf(float(result.get("nibble_strength_max", 0.38)), float(result["nibble_strength_min"]) + 0.03, 0.92)
	return result


func _get_current_temperature_c() -> float:
	var weather_manager := get_node_or_null("/root/WeatherManager")
	if weather_manager != null:
		if weather_manager.has_method("get_current_weather_state"):
			var manager_state = weather_manager.call("get_current_weather_state")
			if manager_state is Dictionary:
				var state_dict := manager_state as Dictionary
				if state_dict.has("temperature"):
					return float(state_dict.get("temperature", 20.0))
				if state_dict.has("current_temperature"):
					return float(state_dict.get("current_temperature", 20.0))
		var direct_temperature = weather_manager.get("temperature")
		if direct_temperature != null:
			return float(direct_temperature)
		var current_temperature = weather_manager.get("current_temperature")
		if current_temperature != null:
			return float(current_temperature)

	var time_manager := get_node_or_null("/root/TimeManager")
	if time_manager != null:
		var time_temperature = time_manager.get("temperature")
		if time_temperature != null:
			return float(time_temperature)
		var time_weather_state = time_manager.get("weather_state")
		if time_weather_state is Dictionary:
			var time_weather_dict := time_weather_state as Dictionary
			if time_weather_dict.has("temperature"):
				return float(time_weather_dict.get("temperature", 20.0))

	var helper_state := WeatherUIHelperScript.get_current_weather_state(time_manager)
	return float(helper_state.get("temperature", 20.0))


func _get_temperature_activity_modifier(fish: Dictionary) -> float:
	if not fish.has("preferred_temperature_min") and not fish.has("preferred_temperature_max") and not fish.has("preferred_temperature_optimal"):
		return 1.0

	var current_temperature := _get_current_temperature_c()
	var min_temperature: float = float(fish.get("preferred_temperature_min", fish.get("preferred_temperature_optimal", 20.0) - 5.0))
	var max_temperature: float = float(fish.get("preferred_temperature_max", fish.get("preferred_temperature_optimal", 20.0) + 5.0))
	if min_temperature > max_temperature:
		var swap := min_temperature
		min_temperature = max_temperature
		max_temperature = swap
	var optimal_temperature: float = clampf(float(fish.get("preferred_temperature_optimal", (min_temperature + max_temperature) * 0.5)), min_temperature, max_temperature)

	if current_temperature >= min_temperature and current_temperature <= max_temperature:
		var warm_range: float = max(max(abs(optimal_temperature - min_temperature), abs(max_temperature - optimal_temperature)), 1.0)
		var optimal_distance: float = abs(current_temperature - optimal_temperature) / warm_range
		return clampf(1.08 - optimal_distance * 0.16, 0.92, 1.08)

	var distance: float = min(abs(current_temperature - min_temperature), abs(current_temperature - max_temperature))
	return clampf(0.92 - distance * 0.055, 0.55, 0.92)


func _prepare_catch_data_for_bite(fish_id: String, bite_data: Dictionary = {}) -> Dictionary:
	var catch_fish := FishDatabase.get_fish(fish_id)
	var weather_modifiers: Dictionary = bite_data.get("weather_modifiers", _get_weather_bite_modifiers(_get_current_weather_type()))
	var catch_data: Dictionary = FishDatabase.create_catch(fish_id, _get_weather_adjusted_weight_bias(catch_fish, weather_modifiers))
	if catch_data.is_empty():
		return {}

	catch_data["spot_id"] = str(_active_spot.get("id", _active_spot_id))
	catch_data["spot_name"] = str(_active_spot.get("name", "-"))
	catch_data["waterbody_id"] = str(_active_spot.get("waterbody_id", PlayerData.current_waterbody))
	catch_data["waterbody_name"] = str(_active_spot.get("waterbody_name", ""))
	_attach_catch_context_metadata(catch_data)
	return FishFreshnessManager.stamp_catch(catch_data)


func _attach_catch_context_metadata(catch_data: Dictionary) -> void:
	var bait_id := str(_tackle_stats.get("bait_id", ""))
	if not bait_id.is_empty():
		catch_data["bait_id"] = bait_id

	var bait_type := str(_tackle_stats.get("bait_type", ""))
	if not bait_type.is_empty():
		catch_data["bait_type"] = bait_type

	var secondary_bait_id := str(_tackle_stats.get("secondary_bait_id", ""))
	if not secondary_bait_id.is_empty():
		catch_data["secondary_bait_id"] = secondary_bait_id

	var secondary_bait_type := str(_tackle_stats.get("secondary_bait_type", ""))
	if not secondary_bait_type.is_empty():
		catch_data["secondary_bait_type"] = secondary_bait_type

	var bait_types_value = _tackle_stats.get("bait_types", [])
	if bait_types_value is Array and not bait_types_value.is_empty():
		catch_data["bait_types"] = (bait_types_value as Array).duplicate()

	var current_tackle := PlayerData.current_tackle
	if current_tackle is Dictionary:
		var rod = current_tackle.get("rod", {})
		if rod is Dictionary:
			var rod_name := str(rod.get("name", ""))
			if not rod_name.is_empty():
				catch_data["tackle_name"] = rod_name

	catch_data["tackle_type"] = str(_tackle_stats.get("tackle_type", "float"))
	catch_data["fight_mode"] = str(_tackle_stats.get("fight_mode", _fight_mode))
	if str(_tackle_stats.get("reel_name", "")) != "":
		catch_data["reel_name"] = str(_tackle_stats.get("reel_name", ""))
		catch_data["reel_size"] = int(_tackle_stats.get("reel_size", 0))
	catch_data["fishing_depth"] = float(_tackle_stats.get("fishing_depth", PlayerData.fishing_depth))


func _build_bite_window_data(fish_id: String, catch_data: Dictionary, balance_data: Dictionary) -> Dictionary:
	var fish := FishDatabase.get_fish(fish_id)
	var profile: Dictionary = balance_data.get("bite_profile", {})
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

	var wind_effects: Dictionary = balance_data.get("wind_effects", {})
	var effective_wind_penalty: float = clamp(float(wind_effects.get("effective_wind_penalty", 0.0)), 0.0, 0.60)
	var sensitivity_rating: float = clamp(float(_tackle_stats.get("float_sensitivity_rating", 0.85)), 0.0, 1.0)
	var visibility_rating: float = clamp(float(_tackle_stats.get("float_bite_visibility_rating", 0.85)), 0.0, 1.0)
	var hook_timing_bonus: float = clamp(float(_tackle_stats.get("hook_timing_bonus", 0.0)), 0.0, 0.20)
	var bite_visibility_multiplier: float = clamp(float(wind_effects.get("bite_visibility_multiplier", 1.0)), 0.70, 1.06)
	var condition_modifiers := _get_condition_fishing_modifiers()
	var raw_condition_modifiers = balance_data.get("condition_modifiers", {})
	if raw_condition_modifiers is Dictionary:
		condition_modifiers = (raw_condition_modifiers as Dictionary).duplicate(true)
	window += (sensitivity_rating - 0.70) * 0.14
	window += (visibility_rating - 0.75) * 0.08
	window *= 1.0 + hook_timing_bonus
	window *= clampf(float(condition_modifiers.get("bite_window_multiplier", 1.0)), 0.55, 1.0)
	window *= clampf(float(profile.get("bite_window_multiplier", 1.0)), 0.65, 1.35)
	window -= effective_wind_penalty * 0.12
	window = clamp(window - size_ratio * 0.12, 0.85, 1.8)
	var perfect_start: float = window * 0.25
	var perfect_end: float = window * 0.75
	var timing_padding: float = clamp((sensitivity_rating - 0.55) * 0.08 + hook_timing_bonus * 0.10 - effective_wind_penalty * 0.03, -0.04, 0.10)
	perfect_start = clamp(perfect_start - timing_padding, window * 0.12, window * 0.44)
	perfect_end = clamp(perfect_end + timing_padding, perfect_start + 0.35, window * 0.92)
	var strength: float = clamp((0.42 + size_ratio * 0.38 + float(balance_data.get("bite_chance", 0.08)) * 0.90) * bite_visibility_multiplier, 0.30, 1.0)
	strength = max(strength, clampf(float(profile.get("strong_bite_strength", strength)), 0.30, 1.0))
	var profile_visibility_multiplier: float = clampf(float(profile.get("bite_visibility_multiplier", 1.0)), 0.48, 1.16)
	var visual_style := str(profile.get("visual_style", "submerge"))
	if visual_style == "nibble" or visual_style == "cautious_nibble" or visual_style == "small_fish_taps":
		visual_style = "submerge"

	return {
		"fish_id": fish_id,
		"bite_window_seconds": window,
		"perfect_start": perfect_start,
		"perfect_end": perfect_end,
		"strength": strength,
		"fish_name": str(catch_data.get("name", fish.get("name", "-"))),
		"rarity": rarity,
		"behavior": behavior,
		"weight": weight,
		"wind_effects": wind_effects,
		"condition_modifiers": condition_modifiers,
		"visual_style": visual_style,
		"bite_profile": profile.duplicate(true),
		"bite_visibility_multiplier": profile_visibility_multiplier
	}


func _fail_hook(reason: String, data: Dictionary = {}) -> void:
	var failure_data := data.duplicate(true)
	failure_data["reason"] = reason
	failure_data["bite_data"] = _pending_bite_data.duplicate(true)
	failure_data["bite_phase"] = _bite_phase
	hook_failed.emit(reason, failure_data)
	_pending_catch.clear()
	_pending_bite_data.clear()
	_bite_window_elapsed = 0.0
	_bite_window_seconds = 0.0
	fishing_state = FishingState.WAITING_FOR_BITE
	var next_approach_outcome := reason
	if reason == "too_early" or reason == "early_hook":
		next_approach_outcome = "fish_spooked"
	_reset_bite_preview_phase()
	_hook_cooldown_timer = float(failure_data.get("cooldown", EARLY_HOOK_COOLDOWN if reason == "too_early" or reason == "early_hook" else 0.65))
	_bite_phase = "approach_wait"
	_bite_check_timer = max(_hook_cooldown_timer, _roll_next_approach_delay(_get_active_bite_balance_data(), next_approach_outcome))
	_false_nudge_timer = randf_range(FALSE_NUDGE_MIN_DELAY, FALSE_NUDGE_MAX_DELAY)


func _clear_active_bite_data() -> void:
	_pending_catch.clear()
	_pending_bite_data.clear()
	_reset_bite_preview_phase()
	_active_spot.clear()
	_active_spot_id = ""
	_active_available_fish.clear()
	_active_spot_depth_modifier = 1.0
	_bite_check_timer = 0.0
	_bite_window_elapsed = 0.0
	_bite_window_seconds = 0.0
	_false_nudge_timer = 0.0
	_hook_cooldown_timer = 0.0
	_lure_retrieve_progress = 0.0
	_lure_retrieve_speed = 0.0
	_lure_retrieve_update_timer = 0.0


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


func can_cancel_current_fishing_wait() -> bool:
	if not is_fishing or is_reeling:
		return false
	if fishing_state == FishingState.WAITING_FOR_BITE or fishing_state == FishingState.BITE_WINDOW:
		return true
	return not use_new_bite_system and fishing_state == FishingState.CASTING


func cancel_current_fishing_wait() -> bool:
	if not can_cancel_current_fishing_wait():
		return false

	return cancel_current_fishing()


func can_cancel_current_fishing() -> bool:
	return is_fishing or is_reeling or fishing_state != FishingState.IDLE


func cancel_current_fishing() -> bool:
	if not can_cancel_current_fishing():
		return false

	_fishing_cycle_id += 1
	is_fishing = false
	is_reeling = false
	fishing_state = FishingState.IDLE
	_reel_input_active = false
	_last_hook_attempt_msec = 0
	_current_catch.clear()
	_pending_catch.clear()
	_pending_bite_data.clear()
	_clear_active_bite_data()
	_last_fail_kind = ""
	stop_fight_vibration()
	return true


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

		if _get_hook_match_multiplier(fish) < 0.06:
			continue

		if _get_bait_match_multiplier(fish, str(fish_id)) < 0.05:
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


func _get_current_weather_type() -> String:
	var time_manager := get_node_or_null("/root/TimeManager")
	var weather_state := WeatherUIHelperScript.get_current_weather_state(time_manager)
	return str(weather_state.get("weather_type", "clear"))


func _get_weather_effect_type_for_bite(weather_type: String) -> String:
	var raw_type := str(weather_type).strip_edges().to_lower()
	match raw_type:
		"storm", "thunderstorm", "rain_with_thunderstorms", "гроза", "дождь с грозой":
			return "thunderstorm"
		"rain", "rainy", "дождь":
			return "rain"
		"cloudy", "overcast", "fog", "mist", "night_mist", "пасмурно", "облачно":
			return "cloudy"

	var normalized := WeatherUIHelperScript.normalize_weather_type(raw_type)
	if normalized == "storm":
		return "thunderstorm"
	return normalized


func _get_weather_bite_modifiers(weather_type: String) -> Dictionary:
	match _get_weather_effect_type_for_bite(weather_type):
		"cloudy":
			return {
				"bite_chance": 1.05,
				"small_fish": 1.00,
				"bottom_fish": 1.05,
				"predator": 1.03,
				"large_fish": 1.03,
				"trophy_chance": 1.00,
				"rare_chance": 1.00
			}
		"rain":
			return {
				"bite_chance": 1.10,
				"small_fish": 0.90,
				"bottom_fish": 1.12,
				"predator": 1.08,
				"large_fish": 1.08,
				"trophy_chance": 1.03,
				"rare_chance": 1.02
			}
		"thunderstorm":
			return {
				"bite_chance": 0.90,
				"small_fish": 0.75,
				"bottom_fish": 1.00,
				"predator": 1.12,
				"large_fish": 1.15,
				"trophy_chance": 1.06,
				"rare_chance": 1.05
			}

	return {
		"bite_chance": 1.00,
		"small_fish": 1.00,
		"bottom_fish": 1.00,
		"predator": 1.00,
		"large_fish": 1.00,
		"trophy_chance": 1.00,
		"rare_chance": 1.00
	}


func _get_weather_fish_weight_multiplier(fish: Dictionary, weather_modifiers: Dictionary) -> float:
	if fish.is_empty():
		return 1.0

	var multiplier := 1.0
	var size_class := _get_fish_size_class(fish)
	var habitat := str(fish.get("habitat", "lake")).to_lower()
	var behavior := str(fish.get("behavior_type", fish.get("behavior", "calm"))).to_lower()
	var rarity := str(fish.get("rarity", "common")).to_lower()
	var rarity_type := str(fish.get("rarityType", "common")).to_lower()

	if size_class == "small":
		multiplier *= float(weather_modifiers.get("small_fish", 1.0))
	elif size_class == "large":
		multiplier *= float(weather_modifiers.get("large_fish", 1.0))

	if habitat == "bottom" or habitat == "deep":
		multiplier *= float(weather_modifiers.get("bottom_fish", 1.0))

	if habitat == "predator" or behavior == "aggressive":
		multiplier *= float(weather_modifiers.get("predator", 1.0))

	if rarity == "rare" or rarity == "very_rare" or rarity == "legendary" or rarity_type.find("rare") >= 0 or rarity_type.find("legendary") >= 0:
		multiplier *= float(weather_modifiers.get("rare_chance", 1.0))

	return clamp(multiplier, 0.50, 1.35)


func _get_weather_adjusted_weight_bias(fish: Dictionary, weather_modifiers: Dictionary) -> float:
	var bias := _get_time_peak_modifier(fish)
	var trophy_multiplier := float(weather_modifiers.get("trophy_chance", 1.0))
	if trophy_multiplier > 1.0:
		bias += (trophy_multiplier - 1.0) * 0.45
	return clamp(bias, 0.0, 1.0)


func _get_weather_debug_categories(fish: Dictionary) -> Array:
	var categories: Array = []
	if fish.is_empty():
		return categories

	var size_class := _get_fish_size_class(fish)
	var habitat := str(fish.get("habitat", "lake")).to_lower()
	var behavior := str(fish.get("behavior_type", fish.get("behavior", "calm"))).to_lower()
	var rarity := str(fish.get("rarity", "common")).to_lower()
	var rarity_type := str(fish.get("rarityType", "common")).to_lower()

	categories.append(size_class)
	if habitat == "bottom" or habitat == "deep":
		categories.append("bottom")
	if habitat == "predator" or behavior == "aggressive":
		categories.append("predator")
	if rarity == "rare" or rarity == "very_rare" or rarity == "legendary" or rarity_type.find("rare") >= 0 or rarity_type.find("legendary") >= 0:
		categories.append("rare")

	return categories


func _get_random_tackle_fish_id(available_fish: Array, rare_chance_modifier: float, weather_modifiers: Dictionary = {}) -> String:
	var weighted_list: Array = []
	if weather_modifiers.is_empty():
		weather_modifiers = _get_weather_bite_modifiers(_get_current_weather_type())

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
		var weather_weight_multiplier: float = _get_weather_fish_weight_multiplier(fish, weather_modifiers)
		var float_depth_multiplier: float = clamp(float(_tackle_stats.get("float_depth_match", 1.0)), 0.58, 1.05)
		var final_weight: int = max(roundi(float(weight) * depth_multiplier * bait_multiplier * hook_multiplier * line_multiplier * time_multiplier * peak_multiplier * weather_weight_multiplier * float_depth_multiplier), 1)

		for i in final_weight:
			weighted_list.append(fish_id)

	if weighted_list.is_empty():
		return FishDatabase.get_random_fish_id(available_fish, rare_chance_modifier)

	var selected_fish_id := str(weighted_list.pick_random())
	if SHOW_WEATHER_BITE_DEBUG and BuildConfig.ENABLE_VERBOSE_LOGS:
		var selected_fish := FishDatabase.get_fish(selected_fish_id)
		print("[WeatherBite] selected=%s categories=%s weight_x=%.2f" % [
			selected_fish_id,
			str(_get_weather_debug_categories(selected_fish)),
			_get_weather_fish_weight_multiplier(selected_fish, weather_modifiers)
		])
	return selected_fish_id

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
	var float_depth_match: float = clamp(float(_tackle_stats.get("float_depth_match", 1.0)), 0.58, 1.0)
	# spot.min_depth / effective_min_depth = рабочая глубина рыбы, not physical shore depth.
	var min_depth: float = float(spot.get("min_depth", 0.2))
	var max_depth: float = float(spot.get("max_depth", 6.0))
	var reach_bonus: float = clamp(float(_tackle_stats.get("reach_bonus", 0.0)), -0.06, 0.22)
	var depth_range: float = max(max_depth - min_depth, 0.1)
	var reach_margin: float = depth_range * max(reach_bonus, 0.0)

	if depth < min_depth - reach_margin or depth > max_depth + reach_margin:
		return clamp(0.34 * float_depth_match, 0.28, 0.34)
	if depth < min_depth or depth > max_depth:
		return clamp((0.34 + reach_bonus * 0.85) * float_depth_match, 0.30, 0.52)

	var preferred_depth: float = clamp(float(spot.get("preferred_depth", spot.get("depth", (min_depth + max_depth) * 0.5))), min_depth, max_depth)
	var half_range: float = max(depth_range * 0.5 * (1.0 + max(reach_bonus, 0.0) * 1.10), 0.1)
	var distance: float = abs(depth - preferred_depth) / half_range
	var falloff: float = max(0.26 - max(reach_bonus, 0.0) * 0.08, 0.18)
	return clamp((1.10 - distance * falloff) * float_depth_match, 0.58, 1.12)

func _get_wind_effects(spot: Dictionary) -> Dictionary:
	var wind_state: Dictionary = _get_current_wind_state(spot)
	var wind_speed: float = max(float(wind_state.get("speed_mps", 0.0)), 0.0)
	var gust_strength: float = max(float(wind_state.get("gust_strength", 0.0)), 0.0)
	var gust_active: bool = bool(wind_state.get("gust_active", false))
	var wind_resistance: float = clamp(float(_tackle_stats.get("wind_resistance", 0.65)), 0.0, 1.0)
	var drift_resistance: float = clamp(float(_tackle_stats.get("drift_resistance", 0.65)), 0.0, 1.0)
	var false_bite_resistance: float = clamp(float(_tackle_stats.get("false_bite_resistance", 0.65)), 0.0, 1.0)
	var vegetation_control: float = clamp(float(_tackle_stats.get("vegetation_control", 0.55)), 0.0, 1.0)
	var cast_distance_bonus: float = clamp(float(_tackle_stats.get("cast_distance_bonus", 0.0)), -0.20, 0.25)
	var long_range_accuracy_bonus: float = clamp(float(_tackle_stats.get("long_range_accuracy_bonus", 0.0)), 0.0, 0.20)
	var setup_comfort: float = clamp(float(_tackle_stats.get("setup_comfort", 0.0)), 0.0, 0.20)
	var heavy_bait_penalty: float = clamp(float(_tackle_stats.get("heavy_bait_penalty", 0.0)), 0.0, 0.22)
	var float_depth_match: float = clamp(float(_tackle_stats.get("float_depth_match", 1.0)), 0.58, 1.0)
	var wind_penalty: float = max(wind_speed - 2.0, 0.0) / 8.0
	var effective_wind_penalty: float = wind_penalty * (1.0 - wind_resistance * 0.65)
	if gust_active:
		effective_wind_penalty += gust_strength * 0.025 * (1.0 - wind_resistance * 0.45)
	effective_wind_penalty = clamp(effective_wind_penalty, 0.0, 0.60)

	var vegetation_penalty: float = max(wind_speed - 3.0, 0.0) * 0.035 * _get_spot_vegetation_factor(spot) * (1.0 - vegetation_control * 0.70)
	var light_wind_bonus: float = min(wind_speed, 2.0) * 0.012
	var bite_visibility_multiplier: float = clamp(1.0 - effective_wind_penalty * 0.35 - heavy_bait_penalty * 0.10, 0.72, 1.05)
	var bite_chance_multiplier: float = clamp(1.0 + light_wind_bonus - effective_wind_penalty * 0.18 - vegetation_penalty - heavy_bait_penalty * 0.14, 0.78, 1.05) * float_depth_match
	var false_bite_chance: float = effective_wind_penalty * (1.0 - false_bite_resistance) * 0.25
	if gust_active:
		false_bite_chance += clamp(gust_strength / 10.0, 0.0, 0.18) * (1.0 - false_bite_resistance * 0.60)
	false_bite_chance *= 1.0 - setup_comfort * 0.40
	var cast_accuracy: float = clamp(1.0 - effective_wind_penalty * 0.20 + cast_distance_bonus * 0.10 + long_range_accuracy_bonus * 0.18 + setup_comfort * 0.08, 0.72, 1.14)
	var drift_speed: float = wind_speed * 0.9 * (1.0 - drift_resistance * 0.65)
	if gust_active:
		drift_speed *= 1.4 + gust_strength * 0.15

	return {
		"wind_state": wind_state,
		"wind_speed_mps": wind_speed,
		"gust_strength": gust_strength,
		"gust_active": gust_active,
		"wind_penalty": wind_penalty,
		"effective_wind_penalty": effective_wind_penalty,
		"bite_visibility_multiplier": bite_visibility_multiplier,
		"bite_chance_multiplier": clamp(bite_chance_multiplier, 0.58, 1.05),
		"false_bite_chance": clamp(false_bite_chance, 0.0, 0.45),
		"cast_accuracy": cast_accuracy,
		"drift_speed": max(drift_speed, 0.0),
		"vegetation_penalty": vegetation_penalty,
		"heavy_bait_penalty": heavy_bait_penalty
	}

func _get_current_wind_state(spot: Dictionary) -> Dictionary:
	var wind_manager := get_node_or_null("/root/WindManager")
	var spot_id := str(spot.get("id", _active_spot_id))
	if wind_manager != null:
		if wind_manager.has_method("get_effective_wind_state"):
			var effective_state = wind_manager.call("get_effective_wind_state", spot_id)
			if effective_state is Dictionary:
				return (effective_state as Dictionary).duplicate(true)
		if wind_manager.has_method("get_wind_state"):
			var base_state = wind_manager.call("get_wind_state")
			if base_state is Dictionary:
				return (base_state as Dictionary).duplicate(true)

	return {
		"speed_mps": 0.0,
		"direction_degrees": 0.0,
		"direction_vector": Vector2.RIGHT,
		"gust_strength": 0.0,
		"gust_active": false,
		"description": "Штиль",
		"icon_key": "wind_calm"
	}

func _get_spot_vegetation_factor(spot: Dictionary) -> float:
	var spot_type := str(spot.get("type", "")).to_lower()
	var visual_tag := str(spot.get("visual_tag", "")).to_lower()
	if spot_type.find("reeds") >= 0 or visual_tag.find("reeds") >= 0:
		return 1.0
	if spot_type.find("duckweed") >= 0 or visual_tag.find("duckweed") >= 0 or visual_tag.find("frog") >= 0:
		return 0.95
	if spot_type.find("snag") >= 0 or visual_tag.find("snag") >= 0:
		return 0.55
	return 0.0

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

	return clamp((1.0 - visibility * caution) * _get_leader_fish_bite_multiplier(fish), 0.52, 1.12)

func _get_leader_fish_bite_multiplier(fish: Dictionary) -> float:
	var leader_strength: float = float(_tackle_stats.get("leader_strength", 0.0))
	if leader_strength <= 0.0:
		return 1.0

	var fish_id := str(fish.get("id", ""))
	var behavior := str(fish.get("behavior_type", fish.get("behavior", "calm"))).to_lower()
	var max_weight: float = max(float(fish.get("max_weight", 1.0)), 0.05)
	var average_weight: float = max((float(fish.get("min_weight", 0.0)) + max_weight) * 0.5, 0.03)
	var material := str(_tackle_stats.get("leader_material", "")).to_lower()
	var length_cm: int = int(_tackle_stats.get("leader_length_cm", 20))
	var is_predator := str(fish.get("habitat", "")).to_lower() == "predator" or ["rotan", "perch", "young_pike", "small_catfish", "pike", "catfish", "eel", "zander", "moon_catfish"].has(fish_id)
	var cautious := max_weight <= 0.8 or behavior == "calm" or behavior == "cautious" or behavior == "shy"
	var active := behavior == "aggressive" or behavior == "erratic"
	var multiplier := 1.0 + float(_tackle_stats.get("leader_cautious_bite_bonus", 0.0)) * (1.0 if cautious else 0.30)

	if length_cm <= 15:
		if active:
			multiplier += 0.05
		if cautious:
			multiplier -= 0.05
	elif length_cm >= 40:
		if cautious:
			multiplier += 0.10
		multiplier -= 0.05

	var overpower_ratio: float = leader_strength / max(average_weight, 0.05)
	if cautious and overpower_ratio > 3.0:
		multiplier -= clamp((overpower_ratio - 3.0) * 0.018, 0.02, float(_tackle_stats.get("leader_small_fish_penalty", 0.12)))
	if max_weight <= 0.35 and leader_strength >= 5.0:
		multiplier -= 0.06

	match material:
		"fluoro", "fluorocarbon":
			if cautious:
				multiplier += 0.05
		"braid", "braided":
			if cautious:
				multiplier -= 0.05
			if active:
				multiplier += 0.02
		"reinforced":
			if cautious:
				multiplier -= 0.07
		"steel":
			if is_predator:
				multiplier += 0.04
			else:
				multiplier -= 0.16 if cautious else 0.08

	return clamp(multiplier, 0.45, 1.14)

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
		return clamp(0.24 - float(too_big_steps) * 0.025, 0.10, 0.24)

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
				target_fit = 0.74
		"medium":
			if fish_size == "small":
				target_fit = 0.92
			if fish_size == "medium":
				target_fit = 1.14
			elif fish_size == "large":
				target_fit = 0.92
		"large":
			if fish_size == "small":
				target_fit = 0.78
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
	if is_reeling:
		_reel_input_active = active
		return
	if _fight_mode == "reel" and is_fishing and fishing_state == FishingState.WAITING_FOR_BITE:
		_reel_input_active = active
		return
	_reel_input_active = false

func set_vibration_enabled(enabled: bool) -> void:
	vibration_enabled = enabled
	if not vibration_enabled:
		stop_fight_vibration()

func is_vibration_enabled() -> bool:
	return vibration_enabled

func get_gameplay_settings() -> Dictionary:
	return {
		"vibration_enabled": vibration_enabled
	}

func set_gameplay_settings(settings: Dictionary) -> void:
	if settings.has("vibration_enabled"):
		set_vibration_enabled(bool(settings.get("vibration_enabled", true)))

func _resolve_fish_for_catch(fish_data: Dictionary) -> Dictionary:
	var fish_id := str(fish_data.get("id", ""))
	if fish_id != "":
		var fish: Dictionary = FishDatabase.get_fish(fish_id)
		if not fish.is_empty():
			return fish
	return fish_data

func _get_fight_weight_ratio(fish_data: Dictionary, fish: Dictionary) -> float:
	var weight: float = max(float(fish_data.get("weight", 0.0)), 0.0)
	var min_weight: float = float(fish.get("min_weight", fish.get("minWeight", fish_data.get("minWeight", weight))))
	var max_weight: float = float(fish.get("max_weight", fish.get("maxWeight", fish_data.get("maxWeight", max(weight, min_weight + 0.01)))))
	var span: float = max(max_weight - min_weight, 0.01)
	return clamp((weight - min_weight) / span, 0.0, 1.0)

func _get_fight_catch_rank(fish_data: Dictionary, fish: Dictionary) -> String:
	var rank := str(fish_data.get("catch_rank", ""))
	if rank != "":
		return rank
	if fish.is_empty():
		return "normal"
	return FishDatabase.get_catch_rank(fish, float(fish_data.get("weight", 0.0)))

func _get_fish_strength_factor(fish_data: Dictionary, fish: Dictionary) -> float:
	var weight: float = max(float(fish_data.get("weight", 0.0)), 0.0)
	var min_weight: float = float(fish.get("min_weight", fish.get("minWeight", fish_data.get("minWeight", weight))))
	var max_weight: float = float(fish.get("max_weight", fish.get("maxWeight", fish_data.get("maxWeight", max(weight, min_weight + 0.01)))))
	var average_weight: float = max((min_weight + max_weight) * 0.5, 0.05)
	var relative_weight: float = clamp(weight / average_weight, 0.35, 3.4)
	var species_strength: float = float(fish_data.get("strength", fish.get("strength", fish.get("base_fight_power", 1.0))))
	var stamina: float = float(fish_data.get("stamina", fish.get("stamina", 1.0)))
	var aggression: float = float(fish_data.get("aggression", fish.get("aggression", 0.5)))
	var rank := _get_fight_catch_rank(fish_data, fish)
	var trophy_bonus: float = 0.0
	if bool(fish_data.get("is_trophy", false)) or bool(fish_data.get("is_trophy_status", false)) or rank == "trophy" or rank == "rarity":
		trophy_bonus += 0.35
	if bool(fish_data.get("is_rarity", false)) or rank == "rarity":
		trophy_bonus += 0.25

	var absolute_size_bonus: float = clamp(pow(max(weight, 0.05), 0.28) * 0.16, 0.0, 0.42)
	var factor: float = (
		species_strength * 0.52
		+ relative_weight * 0.26
		+ stamina * 0.10
		+ aggression * 0.08
		+ absolute_size_bonus
		+ trophy_bonus
	)
	return clamp(factor, 0.45, 3.2)

func get_safe_tension_zone(fish_data: Dictionary) -> Dictionary:
	var fish: Dictionary = _resolve_fish_for_catch(fish_data)
	var weight: float = max(float(fish_data.get("weight", 0.0)), 0.0)
	var size_class := _get_fish_size_class(fish, weight)
	var rank := _get_fight_catch_rank(fish_data, fish)
	var strength_factor: float = _get_fish_strength_factor(fish_data, fish)
	var size_ratio: float = _get_fight_weight_ratio(fish_data, fish)
	var is_trophy_fish: bool = bool(fish_data.get("is_trophy", false)) or bool(fish_data.get("is_trophy_status", false)) or rank == "trophy" or rank == "rarity"
	var width: float = MEDIUM_SAFE_ZONE_WIDTH

	match size_class:
		"small":
			width = SMALL_SAFE_ZONE_WIDTH
		"large":
			width = LARGE_SAFE_ZONE_WIDTH
		_:
			width = MEDIUM_SAFE_ZONE_WIDTH

	var strength_narrowing: float = clamp((strength_factor - 0.75) / 2.1, 0.0, 1.0)
	width = lerp(width, TROPHY_SAFE_ZONE_WIDTH, strength_narrowing * 0.68)
	width -= clamp(size_ratio * 0.045, 0.0, 0.045)
	if is_trophy_fish:
		width = min(width, lerp(0.13, TROPHY_SAFE_ZONE_WIDTH, clamp((strength_factor - 1.0) / 1.6, 0.0, 1.0)))
	if rank == "rarity":
		width = min(width, 0.12)

	var behavior := str(fish_data.get("behavior_type", fish_data.get("behavior", fish.get("behavior_type", fish.get("behavior", _current_behavior)))))
	var tuning: Dictionary = _get_behavior_tuning(behavior)
	width *= float(tuning.get("green_width", 1.0))
	var difficulty_pressure: float = _difficulty if is_reeling else float(fish_data.get("difficulty", fish.get("difficulty", 1.0)))
	width -= clamp((difficulty_pressure - 1.0) * 0.025, 0.0, 0.08)

	var tackle_width_bonus: float = clamp(
		float(_tackle_stats.get("control_bonus", 0.0))
		+ float(_tackle_stats.get("stability", 0.0))
		+ float(_tackle_stats.get("green_zone_bonus", 0.0)),
		0.0,
		0.45
	)
	width = clamp(width + tackle_width_bonus * 0.18, TROPHY_SAFE_ZONE_WIDTH, 0.42)

	var center: float = 0.54 + clamp((strength_factor - 1.0) * 0.025, -0.03, 0.05)
	if size_class == "small":
		center -= 0.02
	elif size_class == "large":
		center += 0.015
	if is_trophy_fish:
		center += 0.015
	center = clamp(center, 0.43, 0.66)

	var zone_min: float = clamp(center - width * 0.5, 0.16, 0.76)
	var zone_max: float = clamp(center + width * 0.5, zone_min + TROPHY_SAFE_ZONE_WIDTH, 0.88)
	return {
		"min": zone_min,
		"max": zone_max,
		"width": zone_max - zone_min,
		"strength": strength_factor,
		"size_ratio": size_ratio,
		"size_class": size_class
	}

func _get_target_fight_duration(catch_data: Dictionary, fish: Dictionary, tuning: Dictionary, rod_strength: float) -> float:
	var weight: float = max(float(catch_data.get("weight", 0.0)), 0.0)
	var size_class := _get_fish_size_class(fish, weight)
	var rank := _get_fight_catch_rank(catch_data, fish)
	var strength_factor: float = _get_fish_strength_factor(catch_data, fish)
	var weight_ratio: float = _get_fight_weight_ratio(catch_data, fish)
	var is_trophy_fish: bool = bool(catch_data.get("is_trophy", false)) or bool(catch_data.get("is_trophy_status", false)) or rank == "trophy" or rank == "rarity"
	var base_duration: float = 10.0
	var min_duration: float = MIN_FIGHT_DURATION

	match size_class:
		"small":
			base_duration = lerp(6.5, 9.5, clamp((strength_factor - 0.45) / 0.85, 0.0, 1.0))
			min_duration = MIN_FIGHT_DURATION
		"large":
			base_duration = lerp(15.0, 30.0, clamp((strength_factor - 1.0) / 1.75, 0.0, 1.0))
			min_duration = 15.0
		_:
			base_duration = lerp(8.0, 15.0, clamp((strength_factor - 0.70) / 1.15, 0.0, 1.0))
			min_duration = 8.0

	if is_trophy_fish:
		base_duration = max(base_duration, lerp(22.0, 34.0, clamp((strength_factor - 1.15) / 1.85, 0.0, 1.0)))
		min_duration = 20.0
	if rank == "rarity":
		min_duration = 24.0

	var stamina_factor: float = lerp(0.92, 1.24, clamp((_fish_stamina - 0.35) / 1.9, 0.0, 1.0))
	var difficulty_factor: float = lerp(0.95, 1.24, clamp((_difficulty - 0.75) / 2.9, 0.0, 1.0))
	var size_pressure: float = lerp(0.95, 1.12, weight_ratio)
	var tackle_help: float = clamp(
		float(_tackle_stats.get("control_bonus", 0.0)) * 0.45
		+ float(_tackle_stats.get("hook_success_bonus", 0.0)) * 0.22
		+ max(rod_strength - 1.0, 0.0) * 0.08,
		0.0,
		0.38
	)
	var duration: float = base_duration * stamina_factor * difficulty_factor * size_pressure * float(tuning.get("progress_time", 1.0)) / (1.0 + tackle_help)
	return clamp(duration, min_duration, MAX_FIGHT_DURATION)

func _calculate_fight_vibration_strength() -> float:
	if not is_reeling:
		return 0.0

	var fish_intensity: float = clamp(
		(_fish_strength - 0.30) / 2.20 * 0.42
		+ (_fight_power - 0.35) / 4.40 * 0.30
		+ _weight_ratio * 0.18
		+ _fish_aggression * 0.10,
		0.0,
		1.0
	)
	var zone_pressure: float = 0.0
	if _tension > _green_max:
		zone_pressure = lerp(0.58, 1.0, inverse_lerp(_green_max, 1.0, _tension))
	elif _tension >= _green_min:
		zone_pressure = lerp(0.35, 0.64, _control_value)
	else:
		zone_pressure = lerp(0.0, 0.22, inverse_lerp(0.0, max(_green_min, 0.01), _tension))

	var strength: float = 0.0
	if _reel_input_active:
		strength = zone_pressure * (0.72 + fish_intensity * 0.58)
		if _tension < _green_min:
			strength *= 0.45
	else:
		if _struggle_power > 0.45 and _tension >= _green_min * 0.82:
			strength = (0.10 + fish_intensity * 0.16 + clamp(_struggle_power * 0.12, 0.0, 0.18))
		else:
			strength = 0.0

	if _tension > _green_max:
		strength += clamp(_critical_break_risk * 0.45 + (_high_danger_time / max(_high_fail_limit, 0.1)) * 0.22, 0.0, 0.45)

	return clamp(strength, 0.0, 1.0)

func _get_vibration_label(strength: float) -> String:
	if strength <= 0.08:
		return "off"
	if strength < 0.32:
		return "low"
	if strength < 0.66:
		return "medium"
	return "strong"

func update_fight_vibration(delta: float) -> void:
	if not is_reeling or not vibration_enabled:
		stop_fight_vibration()
		return

	var strength: float = _calculate_fight_vibration_strength()
	_last_vibration_strength = strength
	_last_vibration_label = _get_vibration_label(strength)
	_debug_tension_fight(delta)

	if strength <= 0.08:
		_fight_vibration_timer = min(_fight_vibration_timer, FIGHT_VIBRATION_MAX_INTERVAL)
		return

	_fight_vibration_timer -= delta
	if _fight_vibration_timer > 0.0:
		return

	trigger_fish_pull_vibration(strength)
	_fight_vibration_timer = lerp(FIGHT_VIBRATION_MAX_INTERVAL, FIGHT_VIBRATION_MIN_INTERVAL, strength)

func trigger_fish_pull_vibration(strength: float) -> void:
	if not vibration_enabled:
		return

	var normalized: float = clamp(strength, 0.0, 1.0)
	if normalized <= 0.05:
		return

	var duration_ms: int = roundi(lerp(FIGHT_VIBRATION_MIN_MS, FIGHT_VIBRATION_MAX_MS, normalized))
	if _struggle_event == "short_jerk" or _struggle_event == "long_pull":
		duration_ms = max(duration_ms, roundi(lerp(70.0, FIGHT_JERK_VIBRATION_MAX_MS, normalized)))
	Input.vibrate_handheld(duration_ms, normalized)

func _trigger_fish_pull_vibration(strength: float) -> void:
	if not vibration_enabled:
		return

	var now_msec := Time.get_ticks_msec()
	if now_msec - _last_struggle_vibration_msec < 120:
		return
	_last_struggle_vibration_msec = now_msec
	trigger_fish_pull_vibration(strength)

func stop_fight_vibration() -> void:
	_fight_vibration_timer = 0.0
	_fight_vibration_debug_timer = 0.0
	_last_vibration_strength = 0.0
	_last_vibration_label = "off"

func _debug_tension_fight(delta: float) -> void:
	if not TENSION_FIGHT_DEBUG or not BuildConfig.ENABLE_VERBOSE_LOGS:
		return

	_fight_vibration_debug_timer -= delta
	if _fight_vibration_debug_timer > 0.0:
		return

	_fight_vibration_debug_timer = 1.0
	print("[TensionFight] tension=%d%%, progress=%d%%, pulling=%s, vibration=%s" % [
		roundi(_tension * 100.0),
		roundi(_catch_progress * 100.0),
		str(_reel_input_active),
		_last_vibration_label
	])

func _process(delta: float) -> void:
	if use_new_bite_system:
		_update_active_bite_system(delta)

	if not is_reeling:
		return

	if _fight_mode == "reel":
		_update_reel_fight(delta)
	else:
		_update_struggle(delta)
		_update_tension(delta)
		_update_progress_and_danger(delta)
	update_fight_vibration(delta)

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
	_fight_mode = _get_effective_fight_mode_from_stats(_tackle_stats)
	if not BuildConfig.ENABLE_SPINNING_FEATURES:
		_fight_mode = "pole"
	_tackle_stats["fight_mode"] = _fight_mode

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
	var main_line_capacity_ratio: float = _effective_load_kg / max(float(_tackle_stats.get("raw_line_strength", _tackle_stats.get("line_strength", 1.0))), 0.1)
	var leader_capacity_ratio: float = 0.0
	if float(_tackle_stats.get("leader_strength", 0.0)) > 0.0:
		leader_capacity_ratio = _effective_load_kg / max(float(_tackle_stats.get("leader_strength", 0.0)), 0.1)
	var line_capacity_ratio: float = max(main_line_capacity_ratio, leader_capacity_ratio)
	rod_overload = max(rod_capacity_ratio - 1.0, 0.0) / rod_strength
	line_overload = max(line_capacity_ratio - 1.0, 0.0) / line_break_resistance
	overload_penalty = max(rod_overload, line_overload * 0.74)
	_line_pressure = line_capacity_ratio
	_line_load_ratio = line_capacity_ratio
	_main_line_load_ratio = main_line_capacity_ratio
	_leader_load_ratio = leader_capacity_ratio
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
	var condition_modifiers := _get_condition_fishing_modifiers()
	_difficulty = clamp(
		_difficulty * clampf(float(condition_modifiers.get("reeling_difficulty_multiplier", 1.0)), 1.0, 1.65),
		0.75,
		4.20
	)
	_escape_risk = clamp(
		_escape_risk * clampf(float(condition_modifiers.get("escape_risk_multiplier", 1.0)), 1.0, 1.85),
		0.05,
		0.92
	)
	_current_catch["condition_modifiers"] = condition_modifiers
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
	_leader_overload_time = 0.0
	_wear_pressure = max(_line_load_ratio, _rod_load_ratio)
	_last_fail_kind = ""
	_tension_velocity = 0.0
	_player_force = 0.0
	stop_fight_vibration()
	_last_struggle_vibration_msec = 0

	var safe_zone := get_safe_tension_zone(catch_data)
	_safe_zone_strength_factor = float(safe_zone.get("strength", _fish_strength))
	_safe_zone_size_ratio = float(safe_zone.get("size_ratio", _weight_ratio))
	var green_width: float = clamp(float(safe_zone.get("width", 0.28)), TROPHY_SAFE_ZONE_WIDTH, 0.42)
	var green_center: float = clamp(
		(float(safe_zone.get("min", 0.38)) + float(safe_zone.get("max", 0.68))) * 0.5 + randf_range(-0.030, 0.030),
		0.43,
		0.66
	)
	_green_min = clamp(green_center - green_width * 0.5, 0.16, 0.76)
	_green_max = clamp(green_center + green_width * 0.5, _green_min + TROPHY_SAFE_ZONE_WIDTH, 0.88)
	_tension = clamp((_green_min + _green_max) * 0.5 - 0.04, 0.18, 0.82)

	var break_safety: float = line_break_resistance * line_durability * clamp(rod_strength, 0.7, 1.35)
	var escape_safety: float = (1.0 / max(float(_tackle_stats.get("fish_escape_modifier", 1.0)), 0.2)) + float(_tackle_stats.get("hook_success_bonus", 0.0))
	var condition_fail_time_multiplier := clampf(float(condition_modifiers.get("tension_fail_time_multiplier", 1.0)), 0.58, 1.0)
	_high_fail_limit = clamp((1.30 * break_safety) / (_difficulty * float(tuning["danger"]) * (1.0 + overload_penalty * 0.45)) * condition_fail_time_multiplier, 0.42, 1.55)
	_low_fail_limit = clamp((1.52 * escape_safety) / (_difficulty * float(tuning["danger"]) * (1.0 + _escape_risk)) * condition_fail_time_multiplier, 0.52, 1.85)
	_target_progress_time = _get_target_fight_duration(catch_data, fish, tuning, rod_strength)
	_initialize_reel_mode(catch_data)

	if BuildConfig.ENABLE_VERBOSE_LOGS:
		_debug_log_spinning_state("fight_start", _get_reeling_state())
		print("[TensionFight] fish=%s, weight=%.2fkg, strength=%.2f, safe_zone=%d%%-%d%%, target_duration=%.1fs" % [
			str(catch_data.get("name", fish.get("name", "-"))),
			catch_weight,
			_safe_zone_strength_factor,
			roundi(_green_min * 100.0),
			roundi(_green_max * 100.0),
			_target_progress_time
		])

	reeling_started.emit(_current_catch, _get_reeling_state())
	reeling_updated.emit(_get_reeling_state())

func _initialize_reel_mode(catch_data: Dictionary) -> void:
	_reel_drag_value = 0.0
	_reel_drag_percent = 0.0
	_line_out = 0.0
	_spool_capacity = 0.0
	_fish_pulling_line_out = false
	_reel_handle_speed = 0.0
	_reel_line_out_speed = 0.0
	_reel_wear_pressure = 0.0

	if _fight_mode != "reel":
		return

	_spool_capacity = max(float(_tackle_stats.get("spool_capacity", 0.0)), 10.0)
	var max_drag: float = max(float(_tackle_stats.get("max_drag", _tackle_stats.get("reel_max_drag", 0.0))), 0.1)
	_reel_drag_percent = clamp(float(_tackle_stats.get("drag_percent", 0.45)), 0.15, 0.95)
	_reel_drag_value = clamp(float(_tackle_stats.get("drag_value", max_drag * _reel_drag_percent)), max_drag * 0.12, max_drag)
	_reel_drag_percent = clamp(_reel_drag_value / max_drag, 0.0, 1.0)

	var catch_weight: float = float(catch_data.get("weight", 0.0))
	var opening_line: float = max(7.0, catch_weight * 3.8 + _weight_ratio * 12.0)
	_line_out = clamp(max(_spool_capacity * REEL_LINE_OUT_START_RATIO, opening_line), 3.0, _spool_capacity * 0.58)
	_feedback_message = "Работай катушкой и держи натяжение."

func _update_reel_fight(delta: float) -> void:
	_update_struggle(delta)
	_update_reel_tension(delta)
	_update_progress_and_danger(delta)

	if not is_reeling:
		return

	_update_reel_spool_failure()
	if not is_reeling:
		return

	if _fish_pulling_line_out:
		_feedback_message = "Фрикцион отдаёт леску."
		if _spool_capacity > 0.0 and _line_out >= _spool_capacity * 0.82:
			_feedback_message = "Шпуля почти пуста!"
	elif _reel_input_active:
		_feedback_message = "Катушка подматывает."

func _update_reel_tension(delta: float) -> void:
	var tuning: Dictionary = _get_behavior_tuning(_current_behavior)
	var max_drag: float = max(float(_tackle_stats.get("max_drag", _tackle_stats.get("reel_max_drag", 0.0))), 0.1)
	if _reel_drag_value <= 0.0:
		_reel_drag_value = max_drag * 0.45
	_reel_drag_percent = clamp(_reel_drag_value / max_drag, 0.05, 1.0)

	var retrieve_speed: float = max(float(_tackle_stats.get("retrieve_speed", 0.0)), 0.05)
	var drag_hold: float = _reel_drag_percent * (0.72 + _control_value * 0.16)
	var fish_pull: float = max(_fish_force, 0.0) + _struggle_power * 0.20 + _fish_strength * 0.055 + _difficulty * 0.025
	var fish_line_delta: float = max(fish_pull - drag_hold, 0.0) * REEL_LINE_OUT_PULL_SCALE * (0.58 + _difficulty * 0.18) * delta
	var retrieve_delta: float = 0.0

	if _reel_input_active and _tension < 0.93:
		var tension_slowdown: float = clamp(inverse_lerp(0.76, 0.94, _tension), 0.0, 1.0)
		var retrieve_control: float = lerp(0.62, 1.22, clamp(_control_value, 0.0, 1.0))
		retrieve_delta = retrieve_speed * retrieve_control * (1.0 - tension_slowdown * 0.62) * 2.15 * delta

	var old_line_out: float = _line_out
	_line_out = clamp(_line_out + fish_line_delta - retrieve_delta, 0.0, max(_spool_capacity, 0.0))
	_reel_line_out_speed = (_line_out - old_line_out) / max(delta, 0.001)
	_fish_pulling_line_out = fish_line_delta > retrieve_delta + 0.002 and _reel_line_out_speed > 0.0

	if _fish_pulling_line_out:
		_reel_handle_speed = REEL_HANDLE_BACKWARD_SPEED * clamp(abs(_reel_line_out_speed) / max(retrieve_speed, 0.1), 0.35, 1.8)
	elif _reel_input_active and retrieve_delta > 0.0:
		_reel_handle_speed = REEL_HANDLE_FORWARD_SPEED * clamp(retrieve_delta / max(retrieve_speed * delta, 0.001), 0.25, 1.7)
	else:
		_reel_handle_speed = lerp(_reel_handle_speed, 0.0, clamp(delta * 5.0, 0.0, 1.0))

	var player_target: float = PLAYER_PULL_FORCE * 0.52 + retrieve_speed * 0.18 if _reel_input_active else PLAYER_RELEASE_FORCE * 0.28
	var player_response: float = PLAYER_FORCE_RESPONSE * 0.92 * float(tuning["player_response"])
	_player_force = lerp(_player_force, player_target, clamp(delta * player_response, 0.0, 1.0))

	var drag_pressure: float = lerp(0.12, 0.50, _reel_drag_percent)
	var damping: float = TENSION_DAMPING * 1.10 * float(tuning["damping"])
	var acceleration: float = _player_force + _fish_force * (0.68 + _reel_drag_percent * 0.34) + BASE_FISH_DRAG * _difficulty - drag_pressure - _tension_velocity * damping
	acceleration -= max(_reel_line_out_speed, 0.0) * 0.14
	acceleration += max(-_reel_line_out_speed, 0.0) * 0.045

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

	_reel_wear_pressure = max(_reel_wear_pressure, _reel_drag_percent * (0.45 + max(_line_load_ratio, _rod_load_ratio) * 0.38) + abs(_reel_line_out_speed) * 0.018)

func _update_reel_spool_failure() -> void:
	if _fight_mode != "reel" or _spool_capacity <= 0.0:
		return
	if _line_out >= _spool_capacity - 0.15:
		_finish_reeling_failed("Леска сошла со шпули. Рыба ушла.", "spool_empty", FAILURE_FISH_TOO_STRONG)

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
	if event_name == "short_jerk" or event_name == "long_pull":
		var jerk_strength: float = clamp(abs(_target_fish_force) * 0.56 + _safe_zone_strength_factor * 0.10 + _fight_power * 0.08, 0.0, 1.0)
		if not _reel_input_active:
			jerk_strength *= 0.42
		_trigger_fish_pull_vibration(jerk_strength)

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
	if _fight_mode == "reel":
		var drag_load: float = lerp(0.76, 1.18, clamp(_reel_drag_percent, 0.0, 1.0))
		var line_out_relief: float = 1.0 - clamp(max(_reel_line_out_speed, 0.0) * 0.035, 0.0, 0.28)
		var retrieve_load: float = 1.0 + clamp(max(-_reel_line_out_speed, 0.0) * 0.014, 0.0, 0.18)
		tension_load = lerp(0.48, 1.34, _tension)
		load_kg = base_load * tension_load * (1.0 + struggle_load) * drag_load * line_out_relief * retrieve_load
	var main_line_capacity: float = max(float(_tackle_stats.get("raw_line_strength", _tackle_stats.get("line_strength", 1.0))), 0.1)
	var leader_capacity: float = max(float(_tackle_stats.get("leader_strength", 0.0)), 0.0)
	var main_line_ratio: float = load_kg / main_line_capacity
	var leader_ratio: float = load_kg / leader_capacity if leader_capacity > 0.0 else 0.0
	var rod_capacity: float = max(float(_tackle_stats.get("max_fish_weight", 1.0)), 0.1)

	return {
		"load_kg": load_kg,
		"line_ratio": max(main_line_ratio, leader_ratio),
		"main_line_ratio": main_line_ratio,
		"leader_ratio": leader_ratio,
		"rod_ratio": load_kg / rod_capacity
	}

func _get_weakest_line_break_kind() -> String:
	if _leader_load_ratio <= 0.0:
		return "line_break"
	if _leader_load_ratio >= _main_line_load_ratio * 0.96:
		return "leader_break"
	return "line_break"

func _get_green_zone_control_factor() -> float:
	if _tension < _green_min or _tension > _green_max:
		return 0.0

	var green_center: float = (_green_min + _green_max) * 0.5
	var green_half_width: float = max((_green_max - _green_min) * 0.5, 0.01)
	return max(clamp(1.0 - abs(_tension - green_center) / green_half_width, 0.0, 1.0), 0.05)

func _get_green_zone_overload_timer_multiplier(green_control: float) -> float:
	if green_control <= 0.0:
		return 1.0
	return lerp(GREEN_ZONE_OVERLOAD_TIMER_MAX, GREEN_ZONE_OVERLOAD_TIMER_MIN, green_control)

func _get_green_zone_overload_limit_multiplier(green_control: float) -> float:
	if green_control <= 0.0:
		return 1.0
	return lerp(GREEN_ZONE_OVERLOAD_LIMIT_MIN, GREEN_ZONE_OVERLOAD_LIMIT_MAX, green_control)

func _get_line_break_message(break_kind: String) -> String:
	if break_kind == "leader_break":
		return "Поводок не выдержал натяжения. Рыба ушла."
	return "Обрыв лески! Рыба ушла."

func _update_load_and_overload(delta: float) -> void:
	var load_info := _get_current_load_info()
	_line_load_ratio = float(load_info.get("line_ratio", 0.0))
	_main_line_load_ratio = float(load_info.get("main_line_ratio", _line_load_ratio))
	_leader_load_ratio = float(load_info.get("leader_ratio", 0.0))
	_rod_load_ratio = float(load_info.get("rod_ratio", 0.0))
	_line_pressure = max(_line_load_ratio, _line_pressure)
	_wear_pressure = max(_wear_pressure, max(_line_load_ratio, _rod_load_ratio))

	var line_overload: float = max(_line_load_ratio - 1.0, 0.0)
	var leader_overload: float = max(_leader_load_ratio - 1.0, 0.0)
	var rod_overload: float = max(_rod_load_ratio - 1.0, 0.0)
	var green_control: float = _get_green_zone_control_factor()
	var in_green_zone: bool = green_control > 0.0
	var overload_timer_multiplier: float = _get_green_zone_overload_timer_multiplier(green_control)
	var overload_limit_multiplier: float = _get_green_zone_overload_limit_multiplier(green_control)
	var overload_recovery_bonus: float = lerp(0.35, 0.85, green_control)

	if line_overload > 0.0:
		if in_green_zone and line_overload <= GREEN_ZONE_OVERLOAD_RELIEF_THRESHOLD:
			_line_overload_time = max(_line_overload_time - delta * (0.78 + overload_recovery_bonus), 0.0)
		else:
			_line_overload_time += delta * (0.72 + line_overload * 1.85) * (0.65 + _tension * 0.90) * overload_timer_multiplier
	else:
		_line_overload_time = max(_line_overload_time - delta * 0.78, 0.0)

	if leader_overload > 0.0:
		if in_green_zone and leader_overload <= GREEN_ZONE_OVERLOAD_RELIEF_THRESHOLD:
			_leader_overload_time = max(_leader_overload_time - delta * (0.88 + overload_recovery_bonus), 0.0)
		else:
			_leader_overload_time += delta * (0.80 + leader_overload * 2.10) * (0.70 + _tension * 0.92) * overload_timer_multiplier
	else:
		_leader_overload_time = max(_leader_overload_time - delta * 0.88, 0.0)

	if rod_overload > 0.0:
		if in_green_zone and rod_overload <= GREEN_ZONE_OVERLOAD_RELIEF_THRESHOLD:
			_rod_overload_time = max(_rod_overload_time - delta * (0.52 + overload_recovery_bonus), 0.0)
		else:
			_rod_overload_time += delta * (0.55 + rod_overload * 1.45) * (0.72 + _tension * 0.70) * overload_timer_multiplier
	else:
		_rod_overload_time = max(_rod_overload_time - delta * 0.52, 0.0)

	if leader_overload > 0.08 and _leader_load_ratio >= _main_line_load_ratio:
		_feedback_message = "О НЕТ, поводок перегружен!"
	elif line_overload > 0.08:
		_feedback_message = "О НЕТ, леска перегружена!"
	elif rod_overload > 0.10:
		_feedback_message = "Удочка трещит!"

	var line_break_chance: float = float(_tackle_stats.get("break_chance", 0.15))
	var leader_break_chance: float = float(_tackle_stats.get("leader_break_chance", 0.0))
	var leader_limit: float = clamp((1.82 - leader_break_chance * 1.30) / max(leader_overload, 0.08), 0.34, 2.10) * overload_limit_multiplier
	if leader_overload > 0.0 and _leader_overload_time >= leader_limit and _leader_load_ratio >= _main_line_load_ratio * 0.96:
		_finish_reeling_failed(_get_line_break_message("leader_break"), "leader_break", FAILURE_LEADER_BROKE)
		return

	var line_limit: float = clamp((2.05 - line_break_chance * 1.45) / max(line_overload, 0.08), 0.42, 2.50) * overload_limit_multiplier
	if line_overload > 0.0 and _line_overload_time >= line_limit:
		var break_kind := _get_weakest_line_break_kind()
		_finish_reeling_failed(_get_line_break_message(break_kind), break_kind, _get_failure_reason_for_fail_kind(break_kind))
		return

	var rod_limit: float = clamp(2.30 / max(rod_overload, 0.08), 0.65, 3.20) * overload_limit_multiplier
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
		var break_kind := _get_weakest_line_break_kind()
		_finish_reeling_failed(_get_line_break_message(break_kind), break_kind, _get_failure_reason_for_fail_kind(break_kind))
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
		var break_kind := _get_weakest_line_break_kind()
		_finish_reeling_failed("Критическое натяжение. %s" % ("Поводок лопнул." if break_kind == "leader_break" else "Леска лопнула."), break_kind, _get_failure_reason_for_fail_kind(break_kind))

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
		"leader": base_wear * 1.35 * float(_tackle_stats.get("leader_wear_rate", 0.020)) / 0.020,
		"hook": base_wear * 1.10 * float(_tackle_stats.get("hook_wear_rate", 0.026)) / 0.026,
		"line_broken": outcome == "line_break",
		"leader_broken": outcome == "leader_break",
		"leader_lost": false,
		"float_lost": false,
		"rod_broken": outcome == "rod_break",
		"hook_lost": false
	}

	if outcome == "line_break":
		wear["leader_lost"] = randf() < 0.82
		wear["hook_lost"] = randf() < 0.82
		wear["float_lost"] = randf() < 0.55
	elif outcome == "leader_break":
		wear["leader_lost"] = true
		wear["hook_lost"] = true
	elif outcome == "escape":
		wear["hook_lost"] = randf() < clamp(_escape_risk * 0.10, 0.02, 0.12)

	if _fight_mode == "reel":
		var reel_pressure: float = clamp(max(_reel_wear_pressure, max(_line_load_ratio, _rod_load_ratio) * 0.45), 0.25, 3.0)
		wear["reel"] = base_wear * reel_pressure * float(_tackle_stats.get("reel_wear_rate", 0.008)) / 0.008
		wear["reel_broken"] = outcome == "spool_empty" and randf() < clamp(reel_pressure * 0.08, 0.03, 0.22)
		if outcome == "spool_empty":
			wear["line_broken"] = true

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
	stop_fight_vibration()
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
			"Садок заполнен. Вернитесь в гавань и продайте часть улова.",
			"Продажа теперь доступна через покупателей в гавани.",
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
	if (bool(wear_result.get("leader_broken", false)) or bool(wear_result.get("leader_lost", false))) and final_message.find("Поводок") == -1:
		final_message += "\nПоводок потерян."
	if bool(wear_result.get("rod_broken", false)) and final_message.find("Удочка") == -1:
		final_message += "\nУдочка повреждена!"
	if bool(wear_result.get("reel_broken", false)) and final_message.find("Катушка") == -1:
		final_message += "\nКатушка повреждена!"
	if bool(wear_result.get("hook_lost", false)):
		final_message += "\nКрючок потерян."
	if bool(wear_result.get("float_lost", false)):
		final_message += "\nПоплавок потерян."

	var failure_reason: String = reason if reason != "" else _get_failure_reason_for_fail_kind(fail_kind)
	if fail_kind == "escape" and bool(wear_result.get("hook_lost", false)):
		failure_reason = FAILURE_FISH_ESCAPED_HOOK

	is_fishing = false
	is_reeling = false
	fishing_state = FishingState.FAILED
	_reel_input_active = false
	stop_fight_vibration()
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
		"leader_strength": float(_tackle_stats.get("leader_strength", 0.0)),
		"rod_strength": float(_tackle_stats.get("max_fish_weight", 0.0)),
		"line_load_ratio": _line_load_ratio,
		"leader_load_ratio": _leader_load_ratio,
		"rod_load_ratio": _rod_load_ratio,
		"tension": _tension,
		"fight_mode": _fight_mode,
		"reel_name": str(_tackle_stats.get("reel_name", "")),
		"reel_size": int(_tackle_stats.get("reel_size", 0)),
		"line_out": _line_out,
		"spool_capacity": _spool_capacity,
		"fishing_depth": float(_tackle_stats.get("fishing_depth", PlayerData.fishing_depth)),
		"bait": str(PlayerData.current_tackle.get("bait", {}).get("name", "")),
		"hook": str(PlayerData.current_tackle.get("hook", {}).get("name", "")),
		"leader": str(PlayerData.current_tackle.get("leader", {}).get("name", ""))
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
		FAILURE_LEADER_BROKE:
			return {
				"title": "Поводок порвался",
				"message": "Самым слабым звеном оказался поводок, рыба ушла.",
				"hint": "Поставьте поводок с большим тестом или держите натяжение в зелёной зоне.",
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
				"message": "Натяжение было слишком слабым, и рыба сорвалась.",
				"hint": "Старайся удерживать натяжение в зелёной зоне.",
				"severity": "medium"
			}
		FAILURE_FISH_ESCAPED_HIGH_TENSION:
			return {
				"title": "Рыба сорвалась",
				"message": "Натяжение стало слишком высоким.",
				"hint": "Отпускай леску при резких рывках.",
				"severity": "medium"
			}
		FAILURE_FISH_ESCAPED_HOOK:
			return {
				"title": "Рыба сорвалась с крючка",
				"message": "Крючок плохо удержал рыбу.",
				"hint": "Попробуй другой крючок или наживку.",
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
		"leader_break":
			return FAILURE_LEADER_BROKE
		"line_break":
			return FAILURE_LINE_BROKE
		"rod_break":
			return FAILURE_ROD_OVERLOAD
		"spool_empty":
			return FAILURE_FISH_TOO_STRONG
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
		if _get_hook_match_multiplier(fish) < 0.06:
			blocker_counts[FAILURE_BAD_HOOK] += 1
			continue
		if _get_bait_match_multiplier(fish, str(fish_id)) < 0.05:
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
	total_xp = max(roundi(float(total_xp) * _get_catch_rank_xp_multiplier(catch_data)), 0)

	var skill_effects := PlayerData.get_skill_effects()
	var xp_multiplier: float = 1.0 + float(skill_effects.get("xp_bonus", 0.0))
	xp_multiplier += float(skill_effects.get("float_fishing_xp_bonus", 0.0))
	var catch_rank := str(catch_data.get("catch_rank", "normal"))
	var rarity := str(catch_data.get("rarity", "common"))
	if catch_rank == "trophy" or catch_rank == "rarity" or rarity == "rare" or rarity == "very_rare" or rarity == "legendary":
		xp_multiplier += float(skill_effects.get("trophy_xp_bonus", 0.0))
	total_xp = max(roundi(float(total_xp) * max(xp_multiplier, 0.0)), 0)
	return PlayerData.add_xp(total_xp)

func _get_catch_rank_xp_multiplier(catch_data: Dictionary) -> float:
	var catch_rank := str(catch_data.get("catch_rank", "normal"))
	var fish_status := str(catch_data.get("fish_status", catch_data.get("status", "")))

	if catch_rank == "rarity" or bool(catch_data.get("is_rarity", false)) or bool(catch_data.get("is_record_weight", false)):
		return 2.0
	if catch_rank == "trophy" or fish_status == "trophy" or bool(catch_data.get("is_trophy", false)) or bool(catch_data.get("is_trophy_status", false)):
		return 1.5

	return 1.0

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
	var leader_load_ratio: float = float(load_info.get("leader_ratio", _leader_load_ratio))
	var rod_load_ratio: float = float(load_info.get("rod_ratio", _rod_load_ratio))
	var break_risk: float = clamp(max(_critical_break_risk, max(line_load_ratio - 1.0, 0.0) * 0.62 + max(_high_danger_time / max(_high_fail_limit, 0.1), 0.0) * 0.28), 0.0, 1.0)

	if _tension > _green_max:
		tension_status = "high"
	elif _tension < _green_min:
		tension_status = "low"

	return {
		"fish_name": str(_current_catch.get("name", "-")),
		"fish_weight": float(_current_catch.get("weight", 0.0)),
		"fight_mode": _fight_mode,
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
		"fish_strength_factor": _safe_zone_strength_factor,
		"fish_aggression": _fish_aggression,
		"load_kg": load_kg,
		"line_load_ratio": line_load_ratio,
		"leader_load_ratio": leader_load_ratio,
		"rod_load_ratio": rod_load_ratio,
		"rod_durability": float(_tackle_stats.get("rod_durability", _tackle_stats.get("durability", 1.0))),
		"reel_durability": float(_tackle_stats.get("reel_durability", 1.0)),
		"reel_name": str(_tackle_stats.get("reel_name", "")),
		"reel_size": int(_tackle_stats.get("reel_size", 0)),
		"reel_max_drag": float(_tackle_stats.get("reel_max_drag", _tackle_stats.get("max_drag", 0.0))),
		"drag_value": _reel_drag_value,
		"drag_percent": _reel_drag_percent,
		"retrieve_speed": float(_tackle_stats.get("retrieve_speed", 0.0)),
		"line_out": _line_out,
		"spool_capacity": _spool_capacity,
		"fish_pulling_line_out": _fish_pulling_line_out,
		"reel_handle_speed": _reel_handle_speed,
		"reel_line_out_speed": _reel_line_out_speed,
		"line_durability": float(_tackle_stats.get("line_durability", 1.0)),
		"leader_durability": float(_tackle_stats.get("leader_durability", 1.0)),
		"hook_durability": float(_tackle_stats.get("hook_durability", 1.0)),
		"line_strength": float(_tackle_stats.get("line_strength", 0.0)),
		"leader_strength": float(_tackle_stats.get("leader_strength", 0.0)),
		"critical_break_risk": _critical_break_risk,
		"break_risk": break_risk,
		"escape_risk": _escape_risk,
		"input_active": _reel_input_active,
		"status": tension_status,
		"high_danger": clamp(_high_danger_time / _high_fail_limit, 0.0, 1.0),
		"low_danger": clamp(_low_danger_time / _low_fail_limit, 0.0, 1.0),
		"target_duration": _target_progress_time,
		"safe_zone_width": _green_max - _green_min,
		"vibration_strength": _last_vibration_strength,
		"vibration_label": _last_vibration_label
	}
