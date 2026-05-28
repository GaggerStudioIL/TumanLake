# Coordinates the compact top HUD values without owning gameplay logic.
extends RefCounted

var root: Control
var main


func setup(root_ref: Control, main_ref = null) -> void:
	root = root_ref
	main = main_ref if main_ref != null else root_ref


func refresh() -> void:
	update_money()
	update_time()
	update_weather()
	update_location()
	update_level()


func update_money() -> void:
	if main == null or main.money_label == null:
		return
	main.money_label.text = UIFormatters.format_money(PlayerData.money)


func update_time() -> void:
	if main == null or main.clock_label == null:
		return
	main.clock_label.text = get_clock_text()


func update_weather() -> void:
	if main == null or main.weather_label == null:
		return
	main.weather_label.text = get_time_of_day_title()


func update_location() -> void:
	if main == null or main.tackle_label == null:
		return
	if main.fishing_hud_ui != null and main.fishing_hud_ui.has_method("_get_main_hud_text"):
		main.tackle_label.text = main.fishing_hud_ui._get_main_hud_text()


func update_level() -> void:
	if main == null:
		return
	if main.level_label != null:
		main.level_label.text = "LVL %d  %d/%d XP" % [
			PlayerData.level,
			PlayerData.current_xp,
			PlayerData.xp_to_next_level
		]
	if main.xp_progress_bar != null:
		main.xp_progress_bar.max_value = max(PlayerData.xp_to_next_level, 1)
		main.xp_progress_bar.value = clamp(PlayerData.current_xp, 0, PlayerData.xp_to_next_level)


func get_time_manager() -> Node:
	if root == null:
		return null
	return root.get_node_or_null("/root/TimeManager")


func get_clock_text() -> String:
	var time_manager := get_time_manager()
	if time_manager != null and time_manager.has_method("get_clock_text"):
		return str(time_manager.call("get_clock_text"))
	return "08:45"


func get_time_of_day_title() -> String:
	var time_manager := get_time_manager()
	if time_manager != null and time_manager.has_method("get_time_of_day_title"):
		return str(time_manager.call("get_time_of_day_title"))
	return "Утро"


func get_atmosphere_settings() -> Dictionary:
	var time_manager := get_time_manager()
	if time_manager != null and time_manager.has_method("get_atmosphere_settings"):
		var raw_settings = time_manager.call("get_atmosphere_settings")
		if typeof(raw_settings) == TYPE_DICTIONARY:
			return raw_settings

	return {
		"background": Color("#153d3f"),
		"scene": Color(1.10, 1.03, 0.90, 1.0),
		"sun": Color(1.16, 0.92, 0.58, 0.88),
		"water": Color(0.90, 1.02, 0.96, 1.0),
		"mist": Color(1.03, 0.98, 0.86, 0.82),
		"vignette": Color(0.62, 0.68, 0.72, 0.82)
	}
