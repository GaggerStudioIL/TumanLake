# Handles the main HUD, bottom navigation, and reeling panel.
extends RefCounted

var main
var theme
enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

const TENSION_VISUAL_SLACK_MAX := 0.25
const TENSION_VISUAL_WARNING_MIN := 0.70
const TENSION_VISUAL_CRITICAL_MIN := 0.90
const TENSION_COLOR_SLACK := Color(0.34, 0.58, 0.72, 1.0)
const TENSION_COLOR_SAFE := Color(0.30, 0.88, 0.42, 1.0)
const TENSION_COLOR_WARNING := Color(0.95, 0.70, 0.24, 1.0)
const TENSION_COLOR_CRITICAL := Color(0.95, 0.25, 0.22, 1.0)

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme

func open() -> void:
	refresh()

func close() -> void:
	pass

func refresh() -> void:
	_update_ui()

func is_open() -> bool:
	return main != null

func _update_ui() -> void:
	if main.main_hud_controller != null:
		main.main_hud_controller.refresh()
	else:
		main._update_time_hud()
		main.money_label.text = UIFormatters.format_money_amount(PlayerData.money)
		main.tackle_label.text = _get_main_hud_text()
		main.level_label.text = "LVL %d  %d/%d XP" % [
			PlayerData.level,
			PlayerData.current_xp,
			PlayerData.xp_to_next_level
		]
		main.xp_progress_bar.max_value = max(PlayerData.xp_to_next_level, 1)
		main.xp_progress_bar.value = clamp(PlayerData.current_xp, 0, PlayerData.xp_to_next_level)

	var reel_tackle_mode: bool = main._is_reel_tackle_mode() if main != null and main.has_method("_is_reel_tackle_mode") else false
	var active_retrieve_input: bool = main._fishing_ui_state == FishingUiState.WAITING and reel_tackle_mode
	var active_hook_input: bool = main._fishing_ui_state == FishingUiState.WAITING and bool(FishingManager.get("use_new_bite_system")) and not reel_tackle_mode
	var locked_for_result_or_fishing: bool = main._fishing_ui_state != FishingUiState.IDLE or main.is_cast_animating
	main.fish_button.disabled = (main._fishing_ui_state == FishingUiState.WAITING and not active_hook_input and not active_retrieve_input) or main.is_cast_animating
	main.spot_option_button.visible = false
	main.spot_option_button.disabled = true
	main.basket_button.disabled = main._fishing_ui_state == FishingUiState.WAITING or main._fishing_ui_state == FishingUiState.FIGHTING or main.is_cast_animating
	main.inventory_button.disabled = main._fishing_ui_state == FishingUiState.WAITING or main._fishing_ui_state == FishingUiState.FIGHTING or main.is_cast_animating
	main.tackle_button.disabled = main.inventory_button.disabled
	main.shop_button.disabled = main.inventory_button.disabled
	main.harbor_button.disabled = main.inventory_button.disabled
	main.map_button.disabled = main.inventory_button.disabled
	if main.system_menu_ui != null:
		main.system_menu_ui.set_disabled(main.inventory_button.disabled)
	main.bait_button.disabled = main.inventory_button.disabled
	main.reeling_panel.visible = main._fishing_ui_state == FishingUiState.FIGHTING
	main.debug_panel.visible = BuildConfig.ENABLE_DEBUG_PANEL

	if main._is_catch_reward_open():
		main._close_secondary_popups_for_reward()
		main._bring_catch_reward_to_front()

	if main.inventory_button.disabled:
		main.basket_panel.visible = false
		main.basket_backdrop.visible = false
		main.inventory_panel.visible = false
		main.inventory_backdrop.visible = false
		main.tackle_panel.visible = false
		main.tackle_backdrop.visible = false
		main.waterbody_panel.visible = false
		main.waterbody_backdrop.visible = false
		main.shop_panel.visible = false
		main.shop_backdrop.visible = false
		if main.fish_harbor_ui != null:
			main.fish_harbor_ui.visible = false
		if main.encyclopedia_ui != null:
			main.encyclopedia_ui.close(false)
		main._active_nav_tab = "fish"
		main._refresh_modal_input_blocker()

	match main._fishing_ui_state:
		FishingUiState.WAITING:
			main.fish_button.text = "Мотать" if active_retrieve_input else ("Подсечь" if active_hook_input else "Ожидание")
		FishingUiState.FIGHTING:
			main.fish_button.text = "Мотать" if reel_tackle_mode else "Тянуть"
		FishingUiState.CAUGHT, FishingUiState.FAILED:
			main.fish_button.text = "Вытянуть"
		_:
			main.fish_button.text = "Забросить"

	if main.is_cast_animating:
		main.fish_button.text = "Заброс..."

	main._refresh_fish_button_presentation()
	main._update_basket_ui()
	_refresh_bottom_nav_styles()
	if main.inventory_panel.visible:
		main._update_inventory_ui()
	if main.shop_panel.visible:
		main._update_shop_ui()
	if main.tackle_panel.visible:
		main._update_tackle_ui()
	if main.waterbody_panel.visible:
		main._update_waterbody_ui()
	if main.fish_harbor_ui != null and main.fish_harbor_ui.visible and main.fish_harbor_ui.has_method("refresh"):
		main.fish_harbor_ui.call("refresh")


func _refresh_bottom_nav_styles() -> void:
	var active_tab = main._active_nav_tab

	if main.basket_panel.visible:
		active_tab = "sell"
	elif main.tackle_panel != null and main.tackle_panel.visible:
		active_tab = "tackle"
	elif main.inventory_panel.visible:
		active_tab = main._active_nav_tab
	elif main.shop_panel != null and main.shop_panel.visible:
		active_tab = "shop"
	elif main.fish_harbor_ui != null and main.fish_harbor_ui.visible:
		active_tab = "harbor"
	elif main.waterbody_panel != null and main.waterbody_panel.visible:
		active_tab = "map"
	var nav_data: Array = [
		[main.inventory_button, "inventory"],
		[main.shop_button, "shop"],
		[main.harbor_button, "harbor"],
		[main.map_button, "map"]
	]

	for item in nav_data:
		var nav_button: Button = item[0]
		var tab_name: String = item[1]
		var is_active: bool = tab_name == active_tab
		main._refresh_side_menu_button_state(nav_button, is_active)
	main.nav_fish_button.visible = false

	var bait_active: bool = main.inventory_panel.visible and main._inventory_category == "bait"
	main._apply_action_button_style(main.feed_button, false)
	main._apply_action_button_style(main.bait_button, bait_active)
	main._apply_action_button_style(main.tackle_button, active_tab == "tackle")


func _get_main_hud_text() -> String:
	var spot = SpotDatabase.get_spot(PlayerData.current_spot)
	var waterbody = main._get_waterbody(PlayerData.current_waterbody)
	var tackle_stats = PlayerData.get_tackle_stats()
	var depth = float(spot.get("depth", 0.0))
	var bottom_type = "ил"

	if depth <= 1.6:
		bottom_type = "трава"
	elif depth >= 5.0:
		bottom_type = "яма"

	var activity = "ровная"
	if str(tackle_stats.get("fight_mode", "pole")) == "reel":
		return "%s\n%s\nГлубина %.1f м · снасть %.1f м\nУд. %.1f кг · леска %.1f кг\nКат. %d · шпуля %.0f м" % [
			main.timer_label.text,
			str(waterbody.get("name", "-")),
			depth,
			float(tackle_stats.get("fishing_depth", PlayerData.fishing_depth)),
			float(tackle_stats.get("max_fish_weight", 0.0)),
			float(tackle_stats.get("line_strength", 0.0)),
			int(tackle_stats.get("reel_size", 0)),
			float(tackle_stats.get("spool_capacity", 0.0))
		]
	return "%s\n%s\nГлубина %.1f м · снасть %.1f м\nУд. %.1f кг · леска %.1f кг\nКлёв +%d%%" % [
		main.timer_label.text,
		str(waterbody.get("name", "-")),
		depth,
		float(tackle_stats.get("fishing_depth", PlayerData.fishing_depth)),
		float(tackle_stats.get("max_fish_weight", 0.0)),
		float(tackle_stats.get("line_strength", 0.0)),
		roundi((float(tackle_stats.get("bite_detection_bonus", 0.0)) + float(tackle_stats.get("fish_attraction", 0.0))) * 100.0)
	]

	if float(spot.get("bite_chance_modifier", 1.0)) > 1.05:
		activity = "активная"
	elif float(spot.get("bite_chance_modifier", 1.0)) < 0.95:
		activity = "тихая"

	return "Статус: %s\nВодоём: %s\nАктивность: %s\nТочка: %.1f м | снасть: %.1f м\nДно: %s\nСнасть: уд. %.1f кг | леска %.1f кг\nПрочность: уд. %d%% | леска %d%%\nБонус клёва: +%d%%" % [
		main.timer_label.text,
		str(waterbody.get("name", "-")),
		activity,
		depth,
		float(tackle_stats.get("fishing_depth", PlayerData.fishing_depth)),
		bottom_type,
		float(tackle_stats.get("max_fish_weight", 0.0)),
		float(tackle_stats.get("line_strength", 0.0)),
		roundi(PlayerData.get_tackle_condition("rod") * 100.0),
		roundi(PlayerData.get_tackle_condition("line") * 100.0),
		roundi((float(tackle_stats.get("bite_detection_bonus", 0.0)) + float(tackle_stats.get("fish_attraction", 0.0))) * 100.0)
	]


func _reset_reeling_ui() -> void:
	main._last_reeling_state = {
		"fish_name": "-",
		"fish_weight": 0.0,
		"fight_mode": "pole",
		"tension": 0.46,
		"green_min": 0.38,
		"green_max": 0.68,
		"progress": 0.0,
		"catch_progress": 0.0,
		"control": 0.0,
		"difficulty": 1.0,
		"fish_force": 0.0,
		"struggle_power": 0.0,
		"struggle_event": "пауза",
		"feedback_message": "Держи зеленую зону.",
		"behavior": "-",
		"fight_power": 0.0,
		"fish_strength": 0.0,
		"fish_aggression": 0.0,
		"load_kg": 0.0,
		"line_load_ratio": 0.0,
		"rod_load_ratio": 0.0,
		"rod_durability": 1.0,
		"reel_durability": 1.0,
		"reel_name": "",
		"reel_size": 0,
		"drag_value": 0.0,
		"drag_percent": 0.0,
		"retrieve_speed": 0.0,
		"line_out": 0.0,
		"spool_capacity": 0.0,
		"fish_pulling_line_out": false,
		"reel_handle_speed": 0.0,
		"reel_line_out_speed": 0.0,
		"line_durability": 1.0,
		"hook_durability": 1.0,
		"line_strength": 0.0,
		"critical_break_risk": 0.0,
		"break_risk": 0.0,
		"escape_risk": 0.0,
		"input_active": false,
		"status": "green",
		"high_danger": 0.0,
		"low_danger": 0.0
	}
	_update_reeling_ui(main._last_reeling_state)
	main.fight_status_label.text = "Забрось снасть и дождись поклевки."
	main.fight_hint_label.text = "Во время вываживания удерживай кнопку, чтобы поднять натяжение. Отпускай, чтобы дать слабину."


func _get_tension_visual_state(
	tension: float,
	green_min: float,
	green_max: float,
	status: String,
	high_danger: float,
	critical_break_risk: float
) -> Dictionary:
	var critical_min: float = clamp(max(TENSION_VISUAL_CRITICAL_MIN, green_max), green_max, 1.0)
	if tension >= critical_min or high_danger > 0.60 or critical_break_risk > 0.24:
		return {
			"key": "critical",
			"label": "Критично",
			"color": TENSION_COLOR_CRITICAL
		}
	if status == "high" or tension >= max(TENSION_VISUAL_WARNING_MIN, green_max):
		return {
			"key": "warning",
			"label": "Опасно",
			"color": TENSION_COLOR_WARNING
		}
	if status == "low" or tension <= min(TENSION_VISUAL_SLACK_MAX, green_min):
		return {
			"key": "slack",
			"label": "Слабина",
			"color": TENSION_COLOR_SLACK
		}
	return {
		"key": "green",
		"label": "Норма",
		"color": TENSION_COLOR_SAFE
	}

func _layout_tension_zone(zone: ColorRect, start_value: float, end_value: float, track_width: float, track_height: float, color: Color) -> void:
	if zone == null:
		return

	var start: float = clamp(start_value, 0.0, 1.0)
	var finish: float = clamp(end_value, start, 1.0)
	var zone_x: float = floor(track_width * start)
	var zone_end: float = ceil(track_width * finish)
	var inset: float = 1.0
	var left_inset: float = inset if start <= 0.0 else 0.0
	var right_inset: float = inset if finish >= 1.0 else 0.0
	var width: float = max(zone_end - zone_x, 0.0)
	zone.visible = width > 1.0
	zone.position = Vector2(zone_x + left_inset, inset)
	zone.size = Vector2(max(width - left_inset - right_inset, 1.0), max(track_height - inset * 2.0, 1.0))
	zone.color = color

func _update_reeling_ui(state: Dictionary) -> void:
	main._last_reeling_state = state.duplicate(true)

	var tension: float = clamp(float(state.get("tension", 0.0)), 0.0, 1.0)
	var green_min: float = clamp(float(state.get("green_min", 0.38)), 0.0, 1.0)
	var green_max: float = clamp(float(state.get("green_max", 0.68)), green_min, 1.0)
	var progress: float = clamp(float(state.get("progress", 0.0)), 0.0, 1.0)
	var catch_progress: float = clamp(float(state.get("catch_progress", progress)), 0.0, 1.0)
	var critical_break_risk: float = clamp(float(state.get("break_risk", state.get("critical_break_risk", 0.0))), 0.0, 1.0)
	var escape_risk: float = clamp(float(state.get("escape_risk", 0.0)), 0.0, 1.0)
	var fight_power: float = max(float(state.get("fight_power", 0.0)), 0.0)
	var line_strength: float = max(float(state.get("line_strength", 0.0)), 0.0)
	var fish_weight: float = max(float(state.get("fish_weight", 0.0)), 0.0)
	var load_kg: float = max(float(state.get("load_kg", 0.0)), 0.0)
	var line_load_ratio: float = max(float(state.get("line_load_ratio", 0.0)), 0.0)
	var rod_load_ratio: float = max(float(state.get("rod_load_ratio", 0.0)), 0.0)
	var rod_durability: float = clamp(float(state.get("rod_durability", 1.0)), 0.0, 1.0)
	var line_durability: float = clamp(float(state.get("line_durability", 1.0)), 0.0, 1.0)
	var hook_durability: float = clamp(float(state.get("hook_durability", 1.0)), 0.0, 1.0)
	var fish_strength: float = max(float(state.get("fish_strength", 0.0)), 0.0)
	var fish_aggression: float = max(float(state.get("fish_aggression", 0.0)), 0.0)
	var high_danger: float = clamp(float(state.get("high_danger", 0.0)), 0.0, 1.0)
	var low_danger: float = clamp(float(state.get("low_danger", 0.0)), 0.0, 1.0)
	var track_width = max(main.tension_track.size.x, 1.0)
	var track_height = max(main.tension_track.size.y, 1.0)
	var progress_width = max(main.progress_track.size.x, 1.0)
	var status = str(state.get("status", "green"))
	var behavior = str(state.get("behavior", "-"))
	var fish_name = str(state.get("fish_name", "-"))
	var fight_mode = str(state.get("fight_mode", "pole"))
	var is_reel_mode: bool = fight_mode == "reel"
	var reel_name = str(state.get("reel_name", ""))
	var reel_size: int = int(state.get("reel_size", 0))
	var reel_durability: float = clamp(float(state.get("reel_durability", 1.0)), 0.0, 1.0)
	var drag_value: float = max(float(state.get("drag_value", 0.0)), 0.0)
	var drag_percent: float = clamp(float(state.get("drag_percent", 0.0)), 0.0, 1.0)
	var line_out: float = max(float(state.get("line_out", 0.0)), 0.0)
	var spool_capacity: float = max(float(state.get("spool_capacity", 0.0)), 0.0)
	var reel_handle_speed: float = float(state.get("reel_handle_speed", 0.0))
	var struggle_event = str(state.get("struggle_event", "пауза"))
	var feedback_message = str(state.get("feedback_message", "Держи зеленую зону."))
	var critical_min: float = clamp(max(TENSION_VISUAL_CRITICAL_MIN, green_max), green_max, 1.0)
	var visual_state: Dictionary = _get_tension_visual_state(tension, green_min, green_max, status, high_danger, critical_break_risk)
	var visual_key := str(visual_state.get("key", "green"))
	var visual_label := str(visual_state.get("label", "Норма"))
	var visual_color: Color = visual_state.get("color", TENSION_COLOR_SAFE)

	main._ensure_reeling_visual_nodes()
	main._set_reeling_panel_visual_state(visual_key, visual_color)
	main.tension_track.color = Color(0.94, 1.0, 0.96, 0.16)
	main.progress_track.color = Color(0.94, 1.0, 0.96, 0.10)

	_layout_tension_zone(main.tension_slack_zone, 0.0, green_min, track_width, track_height, Color(0.18, 0.36, 0.48, 0.72))
	_layout_tension_zone(main.safe_zone, green_min, green_max, track_width, track_height, Color(0.18, 0.74, 0.34, 0.78))
	_layout_tension_zone(main.tension_warning_zone, green_max, critical_min, track_width, track_height, Color(0.88, 0.58, 0.16, 0.80))
	_layout_tension_zone(main.tension_critical_zone, critical_min, 1.0, track_width, track_height, Color(0.82, 0.18, 0.16, 0.88))

	main.tension_fill.position = Vector2.ZERO
	main.tension_fill.size = Vector2(track_width * tension, track_height)
	main.tension_fill.color = Color(visual_color.r, visual_color.g, visual_color.b, 0.22 if visual_key == "green" else 0.30)

	var marker_width: float = clamp(track_width * 0.016, 4.0, 7.0)
	var marker_x: float = clamp(track_width * tension - marker_width * 0.5, 0.0, max(track_width - marker_width, 0.0))
	main.tension_marker_glow.visible = false
	main.tension_marker.position = Vector2(marker_x, -4.0)
	main.tension_marker.size = Vector2(marker_width, track_height + 8.0)
	main.tension_marker.color = Color(1.0, 1.0, 1.0, 0.96)

	main.progress_fill.position = Vector2.ZERO
	main.progress_fill.size = Vector2(progress_width * progress, main.progress_track.size.y)
	main.progress_fill.color = Color(0.62, 0.92, 0.34, 0.72)

	main.fight_title_label.text = "Вываживание · катушка" if is_reel_mode else "Вываживание"
	main.tension_label.text = "Натяжение: %d%% — %s" % [roundi(tension * 100.0), visual_label]
	main.tension_label.add_theme_color_override("font_color", Color(0.94, 0.98, 0.94, 1.0))
	if is_reel_mode:
		main.progress_label.text = "Прогр. %d%% · %.0fм" % [roundi(catch_progress * 100.0), line_out]
	else:
		main.progress_label.text = "Прогресс: %d%%" % roundi(catch_progress * 100.0)
	main.progress_label.add_theme_color_override("font_color", Color(0.72, 0.82, 0.78, 0.96))
	main.debug_label.text = "fish: %s %.2fkg | behavior: %s\nfight: %.2f | strength: %.2f | aggr: %.2f\nload: %.2fkg | line %.0f%% | rod %.0f%%\ntension: %d%% | green: %d-%d%%\nbreak risk: %d%% | escape risk: %d%%\ndurability: rod %d%% | line %d%% | hook %d%%\ncatch progress: %d%% | event: %s" % [
		fish_name,
		fish_weight,
		behavior,
		fight_power,
		fish_strength,
		fish_aggression,
		load_kg,
		line_load_ratio * 100.0,
		rod_load_ratio * 100.0,
		roundi(tension * 100.0),
		roundi(green_min * 100.0),
		roundi(green_max * 100.0),
		roundi(critical_break_risk * 100.0),
		roundi(escape_risk * 100.0),
		roundi(rod_durability * 100.0),
		roundi(line_durability * 100.0),
		roundi(hook_durability * 100.0),
		roundi(catch_progress * 100.0),
		struggle_event
	]
	if is_reel_mode:
		main.debug_label.text += "\nreel: %s %d | drag %.1fkg (%d%%)\nspool: %.0f/%.0fm | reel %d%% | handle %.1f" % [
			reel_name,
			reel_size,
			drag_value,
			roundi(drag_percent * 100.0),
			line_out,
			spool_capacity,
			roundi(reel_durability * 100.0),
			reel_handle_speed
		]

	if FishingManager.is_reeling:
		main.fight_hint_label.text = feedback_message

	var overload_warning: float = max(max(line_load_ratio - 1.0, rod_load_ratio - 1.0), critical_break_risk)
	main.fight_status_label.add_theme_color_override("font_color", visual_color)
	match visual_key:
		"critical":
			main.fight_status_label.text = "Критично %d%%" % roundi(max(max(high_danger, critical_break_risk), overload_warning) * 100.0)
		"warning":
			main.fight_status_label.text = "Опасно %d%%" % roundi(max(max(high_danger, critical_break_risk), max(line_load_ratio - 1.0, 0.0)) * 100.0)
		"slack":
			main.fight_status_label.text = "Слабина %d%%" % roundi(low_danger * 100.0)
		_:
			if FishingManager.is_reeling:
				main.fight_status_label.text = "Норма"
	if is_reel_mode and FishingManager.is_reeling:
		main.fight_status_label.text = "%s · %.0fм" % [main.fight_status_label.text, line_out]
