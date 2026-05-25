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
	main._update_time_hud()
	main.money_label.text = PlayerData.format_money(PlayerData.money)
	main.tackle_label.text = _get_main_hud_text()
	main.level_label.text = "LVL %d  XP %d/%d" % [
		PlayerData.level,
		PlayerData.current_xp,
		PlayerData.xp_to_next_level
	]
	main.xp_progress_bar.max_value = max(PlayerData.xp_to_next_level, 1)
	main.xp_progress_bar.value = clamp(PlayerData.current_xp, 0, PlayerData.xp_to_next_level)
	main.money_label.text = "%s ₽" % PlayerData.format_money_amount(PlayerData.money)
	main.level_label.text = "LVL %d  %d/%d XP" % [
		PlayerData.level,
		PlayerData.current_xp,
		PlayerData.xp_to_next_level
	]

	var active_hook_input: bool = main._fishing_ui_state == FishingUiState.WAITING and bool(FishingManager.get("use_new_bite_system"))
	var locked_for_result_or_fishing: bool = main._fishing_ui_state != FishingUiState.IDLE or main.is_cast_animating
	main.fish_button.disabled = (main._fishing_ui_state == FishingUiState.WAITING and not active_hook_input) or main.is_cast_animating
	main.spot_option_button.disabled = locked_for_result_or_fishing
	main.basket_button.disabled = main._fishing_ui_state == FishingUiState.WAITING or main._fishing_ui_state == FishingUiState.FIGHTING or main.is_cast_animating
	main.inventory_button.disabled = main._fishing_ui_state == FishingUiState.WAITING or main._fishing_ui_state == FishingUiState.FIGHTING or main.is_cast_animating
	main.tackle_button.disabled = main.inventory_button.disabled
	main.shop_button.disabled = main.inventory_button.disabled
	main.map_button.disabled = main.inventory_button.disabled
	main.bait_button.disabled = main.inventory_button.disabled
	main.reeling_panel.visible = main._fishing_ui_state == FishingUiState.FIGHTING
	main.debug_panel.visible = main.SHOW_DEBUG_PANEL

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
		main._active_nav_tab = "fish"
		main._refresh_modal_input_blocker()

	match main._fishing_ui_state:
		FishingUiState.WAITING:
			main.fish_button.text = "Подсечь" if active_hook_input else "Ожидание"
		FishingUiState.FIGHTING:
			main.fish_button.text = "Тянуть"
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
	elif main.waterbody_panel != null and main.waterbody_panel.visible:
		active_tab = "map"

	var nav_data: Array = [
		[main.basket_button, "sell"],
		[main.inventory_button, "inventory"],
		[main.shop_button, "shop"],
		[main.map_button, "map"],
		[main.profile_button, "profile"]
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
	main._apply_action_button_style(main.auto_button, false)


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
	var struggle_event = str(state.get("struggle_event", "пауза"))
	var feedback_message = str(state.get("feedback_message", "Держи зеленую зону."))

	main.safe_zone.position = Vector2(track_width * green_min, 0.0)
	main.safe_zone.size = Vector2(max(track_width * (green_max - green_min), 4.0), track_height)
	main.safe_zone.color = Color("#2fc466")

	main.tension_fill.position = Vector2.ZERO
	main.tension_fill.size = Vector2(track_width * tension, track_height)

	main.tension_marker.position = Vector2(clamp(track_width * tension - 3.0, 0.0, max(track_width - 6.0, 0.0)), -5.0)
	main.tension_marker.size = Vector2(6.0, track_height + 10.0)

	main.progress_fill.position = Vector2.ZERO
	main.progress_fill.size = Vector2(progress_width * progress, main.progress_track.size.y)

	main.tension_label.text = "Натяжение: %d%%" % roundi(tension * 100.0)
	main.progress_label.text = "Прогресс: %d%%" % roundi(catch_progress * 100.0)
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

	if FishingManager.is_reeling:
		main.fight_hint_label.text = feedback_message

	var overload_warning: float = max(max(line_load_ratio - 1.0, rod_load_ratio - 1.0), critical_break_risk)
	match status:
		"high":
			if overload_warning > 0.22 or high_danger > 0.55:
				main.tension_fill.color = Color("#e65f45", 0.82)
				main.fight_status_label.text = "ОБРЫВ %d%%" % roundi(max(high_danger, critical_break_risk) * 100.0)
			else:
				main.tension_fill.color = Color("#e0b84b", 0.78)
				main.fight_status_label.text = "Перегруз %d%%" % roundi(max(line_load_ratio - 1.0, 0.0) * 100.0)
		"low":
			main.tension_fill.color = Color("#e0b84b", 0.78)
			main.fight_status_label.text = "Сход %d%%" % roundi(low_danger * 100.0)
		_:
			main.tension_fill.color = Color("#36c96e", 0.76)
			if FishingManager.is_reeling:
				main.fight_status_label.text = "Контроль"
