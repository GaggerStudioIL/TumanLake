# Coordinates the compact top HUD values without owning gameplay logic.
extends RefCounted

const WeatherUIHelperScript := preload("res://scripts/ui/helpers/WeatherUIHelper.gd")

var root: Control
var main
var _last_weather_icon_path := ""
var _last_weather_icon_texture: Texture2D


func setup(root_ref: Control, main_ref = null) -> void:
	root = root_ref
	main = main_ref if main_ref != null else root_ref


func refresh() -> void:
	update_money()
	update_time()
	update_weather()
	update_wind()
	update_location()
	update_level()


func update_money() -> void:
	if main == null or main.money_label == null:
		return
	main.money_label.visible = true
	main.money_label.text = UIFormatters.format_money_amount(PlayerData.money)


func update_time() -> void:
	if main == null or main.clock_label == null:
		return
	main.clock_label.text = get_clock_text()


func update_weather() -> void:
	if main == null or main.weather_label == null:
		return
	var weather_state := WeatherUIHelperScript.get_current_weather_state(get_time_manager())
	main.weather_label.text = str(weather_state.get("temperature_text", "18°C"))
	var uses_texture_panel: bool = _uses_top_weather_panel_texture()
	if main.weather_hud_icon != null:
		if uses_texture_panel:
			main.weather_hud_icon.visible = true
			if main.has_method("refresh_top_weather_condition_icon"):
				main.refresh_top_weather_condition_icon(weather_state)
		else:
			var icon_path := str(weather_state.get("icon_path", ""))
			if icon_path != _last_weather_icon_path:
				_last_weather_icon_path = icon_path
				_last_weather_icon_texture = load(icon_path) if icon_path != "" else null
			main.weather_hud_icon.texture = _last_weather_icon_texture
			main.weather_hud_icon.visible = _last_weather_icon_texture != null
	main.weather_label.tooltip_text = str(weather_state.get("description", ""))
	if main.weather_effects_controller != null and main.weather_effects_controller.has_method("update_weather_state"):
		main.weather_effects_controller.update_weather_state(weather_state)
	update_wind()


func update_wind() -> void:
	if main == null or main.wind_label == null:
		return
	var wind_manager := get_wind_manager()
	if wind_manager == null:
		main.wind_label.visible = false
		if main.wind_hud_icon != null:
			main.wind_hud_icon.visible = false
		return

	var wind_state := {}
	if wind_manager.has_method("get_effective_wind_state"):
		wind_state = wind_manager.call("get_effective_wind_state", str(PlayerData.current_spot))
	elif wind_manager.has_method("get_wind_state"):
		wind_state = wind_manager.call("get_wind_state")
	if not (wind_state is Dictionary):
		main.wind_label.visible = false
		if main.wind_hud_icon != null:
			main.wind_hud_icon.visible = false
		return

	var speed: float = float((wind_state as Dictionary).get("speed_mps", 0.0))
	var degrees: float = float((wind_state as Dictionary).get("direction_degrees", 0.0))
	var gust_active: bool = bool((wind_state as Dictionary).get("gust_active", false))
	var description: String = str((wind_state as Dictionary).get("description", ""))
	var speed_text: String = "%d м/с" % roundi(speed)
	var uses_texture_panel: bool = _uses_top_weather_panel_texture()
	main.wind_label.text = speed_text
	main.wind_label.visible = true
	main.wind_label.tooltip_text = "%s, %.1f м/с, %.0f°" % [description, speed, degrees]
	main.wind_label.modulate = Color.WHITE if uses_texture_panel else (Color(1.0, 0.92, 0.66, 1.0) if gust_active else Color.WHITE)
	if main.wind_hud_icon != null:
		if uses_texture_panel:
			main.wind_hud_icon.visible = true
			main.wind_hud_icon.modulate = Color(0.88, 1.0, 0.98, 1.0)
		else:
			main.wind_hud_icon.visible = true
			main.wind_hud_icon.modulate = Color(1.0, 0.92, 0.66, 0.96) if gust_active else Color(1.0, 1.0, 1.0, 0.94)


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


func get_wind_manager() -> Node:
	if root == null:
		return null
	return root.get_node_or_null("/root/WindManager")


func _uses_top_weather_panel_texture() -> bool:
	return main != null and main.has_method("is_using_top_weather_panel_texture") and main.is_using_top_weather_panel_texture()


func _get_wind_direction_arrow(degrees: float) -> String:
	var normalized := fposmod(degrees, 360.0)
	if normalized >= 337.5 or normalized < 22.5:
		return "→"
	if normalized < 67.5:
		return "↘"
	if normalized < 112.5:
		return "↓"
	if normalized < 157.5:
		return "↙"
	if normalized < 202.5:
		return "←"
	if normalized < 247.5:
		return "↖"
	if normalized < 292.5:
		return "↑"
	return "↗"


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
