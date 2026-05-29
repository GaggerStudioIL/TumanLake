# Top-right system menu for profile, fish atlas, and settings.
extends RefCounted

const WeatherUIHelperScript := preload("res://scripts/ui/helpers/WeatherUIHelper.gd")
const MENU_WEATHER_ICON := preload("res://assets/ui/icons/menu_weather.png")

const BUTTON_BASE_SIZE := Vector2(58.0, 50.0)
const PANEL_BASE_WIDTH := 238.0
const ITEM_BASE_HEIGHT := 52.0
const ITEM_ICON_BASE_SIZE := 38.0

var main
var root: Control
var outside_close: ColorRect
var menu_button: Button
var dropdown_panel: Panel
var menu_items_box: VBoxContainer
var profile_item: Button
var atlas_item: Button
var forecast_item: Button
var settings_item: Button
var settings_backdrop: ColorRect
var settings_panel: Panel
var settings_title: Label
var settings_message: Label
var settings_close_button: Button
var forecast_backdrop: ColorRect
var forecast_panel: Panel
var forecast_title: Label
var forecast_scroll: ScrollContainer
var forecast_list: VBoxContainer
var forecast_close_button: Button
var _is_disabled := false
var _menu_tween: Tween
var _menu_open_position := Vector2.ZERO


func setup(main_ref) -> void:
	main = main_ref
	_ensure_menu_nodes()
	_ensure_settings_nodes()
	_ensure_forecast_nodes()
	layout(main.get_viewport_rect().size)


func layout(screen_size: Vector2) -> void:
	if root == null:
		return

	var sx: float = screen_size.x / 960.0
	var sy: float = screen_size.y / 540.0
	var ui_scale: float = clampf(min(sx, sy), 0.88, 1.18)
	var margin_x: float = clampf(24.0 * sx, 18.0, 30.0)
	var margin_y: float = clampf(18.0 * sy, 14.0, 24.0)
	var button_size := Vector2(
		clampf(BUTTON_BASE_SIZE.x * ui_scale, 56.0, 68.0),
		clampf(BUTTON_BASE_SIZE.y * ui_scale, 48.0, 58.0)
	)
	var panel_width: float = clampf(PANEL_BASE_WIDTH * ui_scale, 220.0, 266.0)
	var item_height: float = clampf(ITEM_BASE_HEIGHT * ui_scale, 50.0, 58.0)
	var item_gap: float = clampf(5.0 * ui_scale, 4.0, 7.0)
	var item_count: int = menu_items_box.get_child_count() if menu_items_box != null else 4
	var panel_padding: float = clampf(10.0 * ui_scale, 9.0, 13.0)
	var panel_height: float = item_height * float(item_count) + panel_padding * 2.0 + item_gap * float(maxi(item_count - 1, 0))
	var button_x: float = screen_size.x - margin_x - button_size.x
	var button_y: float = margin_y
	var icon_size: int = int(clampf(ITEM_ICON_BASE_SIZE * ui_scale, 34.0, 44.0))

	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.position = Vector2.ZERO
	root.size = screen_size
	root.offset_left = 0.0
	root.offset_top = 0.0
	root.offset_right = 0.0
	root.offset_bottom = 0.0

	outside_close.set_anchors_preset(Control.PRESET_FULL_RECT)
	outside_close.position = Vector2.ZERO
	outside_close.size = screen_size
	outside_close.offset_left = 0.0
	outside_close.offset_top = 0.0
	outside_close.offset_right = 0.0
	outside_close.offset_bottom = 0.0

	menu_button.position = Vector2(button_x, button_y)
	menu_button.size = button_size
	menu_button.custom_minimum_size = button_size
	menu_button.add_theme_font_size_override("font_size", int(28.0 * ui_scale))
	_apply_menu_button_style()

	_menu_open_position = Vector2(screen_size.x - margin_x - panel_width, button_y + button_size.y + 8.0 * ui_scale)
	dropdown_panel.position = _menu_open_position
	dropdown_panel.size = Vector2(panel_width, panel_height)
	dropdown_panel.custom_minimum_size = dropdown_panel.size
	_apply_panel_style(dropdown_panel)
	dropdown_panel.pivot_offset = Vector2(dropdown_panel.size.x, 0.0)

	menu_items_box.position = Vector2(panel_padding, panel_padding)
	menu_items_box.size = Vector2(panel_width - panel_padding * 2.0, panel_height - panel_padding * 2.0)
	menu_items_box.add_theme_constant_override("separation", int(item_gap))

	for item in [profile_item, atlas_item, forecast_item, settings_item]:
		item.custom_minimum_size = Vector2(menu_items_box.size.x, item_height)
		item.add_theme_font_size_override("font_size", int(clampf(15.0 * ui_scale, 14.0, 17.0)))
		item.add_theme_constant_override("icon_max_width", icon_size)
		item.add_theme_constant_override("h_separation", int(clampf(13.0 * ui_scale, 12.0, 16.0)))
		_apply_menu_item_style(item)

	if settings_panel != null:
		var panel_size := Vector2(clampf(380.0 * ui_scale, 340.0, 430.0), clampf(188.0 * ui_scale, 172.0, 210.0))
		settings_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
		settings_backdrop.position = Vector2.ZERO
		settings_backdrop.size = screen_size
		settings_panel.position = (screen_size - panel_size) * 0.5
		settings_panel.size = panel_size
		settings_panel.custom_minimum_size = panel_size
		_apply_panel_style(settings_panel)
		settings_title.position = Vector2(24.0, 22.0)
		settings_title.size = Vector2(panel_size.x - 48.0, 32.0)
		settings_title.add_theme_font_size_override("font_size", int(22.0 * ui_scale))
		settings_message.position = Vector2(24.0, 68.0)
		settings_message.size = Vector2(panel_size.x - 48.0, 52.0)
		settings_message.add_theme_font_size_override("font_size", int(15.0 * ui_scale))
		settings_close_button.position = Vector2(panel_size.x - 148.0, panel_size.y - 58.0)
		settings_close_button.size = Vector2(124.0, 42.0)
		settings_close_button.custom_minimum_size = settings_close_button.size
		settings_close_button.add_theme_font_size_override("font_size", int(15.0 * ui_scale))
		_apply_menu_item_style(settings_close_button)

	if forecast_panel != null:
		var forecast_size := Vector2(clampf(500.0 * ui_scale, 410.0, 540.0), clampf(486.0 * ui_scale, 438.0, 500.0))
		var forecast_padding: float = 22.0 * ui_scale
		var close_size := Vector2(124.0 * ui_scale, 40.0 * ui_scale)
		var close_y: float = forecast_size.y - close_size.y - 16.0 * ui_scale
		forecast_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
		forecast_backdrop.position = Vector2.ZERO
		forecast_backdrop.size = screen_size
		forecast_panel.position = (screen_size - forecast_size) * 0.5
		forecast_panel.size = forecast_size
		forecast_panel.custom_minimum_size = forecast_size
		_apply_panel_style(forecast_panel)
		forecast_title.position = Vector2(forecast_padding, 18.0 * ui_scale)
		forecast_title.size = Vector2(forecast_size.x - forecast_padding * 2.0, 34.0 * ui_scale)
		forecast_title.add_theme_font_size_override("font_size", int(22.0 * ui_scale))
		forecast_scroll.position = Vector2(forecast_padding, 62.0 * ui_scale)
		forecast_scroll.size = Vector2(forecast_size.x - forecast_padding * 2.0, close_y - forecast_scroll.position.y - 18.0 * ui_scale)
		forecast_list.position = Vector2.ZERO
		forecast_list.size = forecast_scroll.size
		forecast_list.custom_minimum_size = Vector2(forecast_scroll.size.x, 0.0)
		forecast_list.add_theme_constant_override("separation", int(4.0 * ui_scale))
		forecast_close_button.position = Vector2(forecast_size.x - close_size.x - forecast_padding, close_y)
		forecast_close_button.size = close_size
		forecast_close_button.custom_minimum_size = forecast_close_button.size
		forecast_close_button.add_theme_font_size_override("font_size", int(15.0 * ui_scale))
		_apply_menu_item_style(forecast_close_button)


func is_menu_open() -> bool:
	return dropdown_panel != null and dropdown_panel.visible


func is_settings_open() -> bool:
	return settings_panel != null and settings_panel.visible


func is_forecast_open() -> bool:
	return forecast_panel != null and forecast_panel.visible


func close_menu() -> void:
	if is_instance_valid(_menu_tween):
		_menu_tween.kill()
	if dropdown_panel != null:
		dropdown_panel.visible = false
		dropdown_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
		dropdown_panel.scale = Vector2.ONE
		dropdown_panel.position = _menu_open_position
	if outside_close != null:
		outside_close.modulate = Color(1.0, 1.0, 1.0, 1.0)
		outside_close.visible = false


func close_settings(reset_nav: bool = true) -> void:
	if settings_panel == null or settings_backdrop == null:
		return

	settings_panel.visible = false
	settings_backdrop.visible = false
	if main != null:
		main.close_modal("settings")
		if reset_nav:
			main._active_nav_tab = "fish"
			main._refresh_bottom_nav_styles()


func close_forecast(reset_nav: bool = true) -> void:
	if forecast_panel == null or forecast_backdrop == null:
		return

	forecast_panel.visible = false
	forecast_backdrop.visible = false
	if main != null:
		main.close_modal("weather_forecast")
		if reset_nav:
			main._active_nav_tab = "fish"
			main._refresh_bottom_nav_styles()


func set_disabled(disabled: bool) -> void:
	_is_disabled = disabled
	if menu_button != null:
		menu_button.disabled = disabled
	if disabled:
		close_menu()


func _ensure_menu_nodes() -> void:
	if root != null:
		return

	var parent: Node = main.ui_canvas_layer if main.ui_canvas_layer != null else main

	root = Control.new()
	root.name = "SystemMenuUI"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.z_index = 190
	parent.add_child(root)

	outside_close = ColorRect.new()
	outside_close.name = "SystemMenuOutsideClose"
	outside_close.color = Color(0.0, 0.0, 0.0, 0.055)
	outside_close.mouse_filter = Control.MOUSE_FILTER_STOP
	outside_close.visible = false
	outside_close.z_index = 0
	root.add_child(outside_close)
	outside_close.gui_input.connect(_on_outside_close_gui_input)

	dropdown_panel = Panel.new()
	dropdown_panel.name = "SystemMenuDropdown"
	dropdown_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	dropdown_panel.visible = false
	dropdown_panel.z_index = 2
	root.add_child(dropdown_panel)

	menu_items_box = VBoxContainer.new()
	menu_items_box.name = "SystemMenuItems"
	menu_items_box.mouse_filter = Control.MOUSE_FILTER_PASS
	dropdown_panel.add_child(menu_items_box)

	profile_item = _create_menu_item("Профиль", "profile")
	atlas_item = _create_menu_item("Атлас рыб", "encyclopedia")
	forecast_item = _create_menu_item("Прогноз погоды", "weather")
	settings_item = _create_menu_item("Настройки", "settings")
	menu_items_box.add_child(profile_item)
	menu_items_box.add_child(atlas_item)
	menu_items_box.add_child(forecast_item)
	menu_items_box.add_child(settings_item)

	profile_item.pressed.connect(_on_profile_pressed)
	atlas_item.pressed.connect(_on_atlas_pressed)
	forecast_item.pressed.connect(_on_forecast_pressed)
	settings_item.pressed.connect(_on_settings_pressed)

	menu_button = Button.new()
	menu_button.name = "HamburgerMenuButton"
	menu_button.text = "☰"
	menu_button.tooltip_text = ""
	menu_button.focus_mode = Control.FOCUS_NONE
	menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_button.z_index = 3
	root.add_child(menu_button)
	menu_button.pressed.connect(_on_menu_button_pressed)


func _ensure_settings_nodes() -> void:
	if settings_panel != null:
		return

	var parent: Node = main.get_modal_content_root() if main.has_method("get_modal_content_root") else main

	settings_backdrop = ColorRect.new()
	settings_backdrop.name = "SettingsBackdrop"
	settings_backdrop.color = Color(0.0, 0.0, 0.0, 0.50)
	settings_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_backdrop.visible = false
	parent.add_child(settings_backdrop)

	settings_panel = Panel.new()
	settings_panel.name = "SettingsPlaceholderPanel"
	settings_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_panel.visible = false
	parent.add_child(settings_panel)

	settings_title = Label.new()
	settings_title.name = "SettingsTitle"
	settings_title.text = "Настройки"
	settings_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	settings_title.add_theme_color_override("font_color", Color(0.92, 1.0, 0.96, 1.0))
	settings_panel.add_child(settings_title)

	settings_message = Label.new()
	settings_message.name = "SettingsMessage"
	settings_message.text = "Настройки будут добавлены позже"
	settings_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	settings_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	settings_message.add_theme_color_override("font_color", Color(0.78, 0.90, 0.86, 0.96))
	settings_panel.add_child(settings_message)

	settings_close_button = Button.new()
	settings_close_button.name = "SettingsCloseButton"
	settings_close_button.text = "Закрыть"
	settings_close_button.focus_mode = Control.FOCUS_NONE
	settings_close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_panel.add_child(settings_close_button)
	settings_close_button.pressed.connect(_on_settings_close_pressed)


func _ensure_forecast_nodes() -> void:
	if forecast_panel != null:
		return

	var parent: Node = main.get_modal_content_root() if main.has_method("get_modal_content_root") else main

	forecast_backdrop = ColorRect.new()
	forecast_backdrop.name = "WeatherForecastBackdrop"
	forecast_backdrop.color = Color(0.0, 0.0, 0.0, 0.56)
	forecast_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	forecast_backdrop.visible = false
	parent.add_child(forecast_backdrop)

	forecast_panel = Panel.new()
	forecast_panel.name = "WeatherForecastPanel"
	forecast_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	forecast_panel.visible = false
	parent.add_child(forecast_panel)

	forecast_title = Label.new()
	forecast_title.name = "WeatherForecastTitle"
	forecast_title.text = "Прогноз погоды"
	forecast_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	forecast_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	forecast_title.add_theme_color_override("font_color", Color(0.92, 1.0, 0.96, 1.0))
	forecast_panel.add_child(forecast_title)

	forecast_scroll = ScrollContainer.new()
	forecast_scroll.name = "WeatherForecastScroll"
	forecast_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	forecast_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	forecast_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	forecast_panel.add_child(forecast_scroll)

	forecast_list = VBoxContainer.new()
	forecast_list.name = "WeatherForecastList"
	forecast_list.mouse_filter = Control.MOUSE_FILTER_PASS
	forecast_scroll.add_child(forecast_list)

	forecast_close_button = Button.new()
	forecast_close_button.name = "WeatherForecastCloseButton"
	forecast_close_button.text = "Закрыть"
	forecast_close_button.focus_mode = Control.FOCUS_NONE
	forecast_close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	forecast_panel.add_child(forecast_close_button)
	forecast_close_button.pressed.connect(_on_forecast_close_pressed)


func _get_menu_item_icon(icon_name: String) -> Texture2D:
	if main == null or main.ui_theme == null:
		return null

	var texture: Texture2D = null
	match icon_name:
		"profile", "encyclopedia", "atlas", "settings":
			if main.ui_theme.has_method("get_side_menu_icon"):
				texture = main.ui_theme.get_side_menu_icon(icon_name)
		"weather":
			texture = MENU_WEATHER_ICON

	if texture == null and main.ui_theme.has_method("get_icon"):
		texture = main.ui_theme.get_icon(icon_name)
	return texture


func _create_menu_item(text: String, icon_name: String) -> Button:
	var item := Button.new()
	item.text = text
	item.alignment = HORIZONTAL_ALIGNMENT_LEFT
	item.focus_mode = Control.FOCUS_NONE
	item.mouse_filter = Control.MOUSE_FILTER_STOP
	item.clip_text = false
	item.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	if main.ui_theme != null:
		item.icon = _get_menu_item_icon(icon_name)
		item.expand_icon = true
		item.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		item.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		item.add_theme_constant_override("icon_max_width", int(ITEM_ICON_BASE_SIZE))
		item.add_theme_constant_override("h_separation", 14)
	return item


func _on_menu_button_pressed() -> void:
	if _is_disabled:
		return
	if is_menu_open():
		close_menu()
	else:
		_open_menu()


func _open_menu() -> void:
	if outside_close == null or dropdown_panel == null:
		return

	if is_instance_valid(_menu_tween):
		_menu_tween.kill()

	outside_close.visible = true
	outside_close.modulate = Color(1.0, 1.0, 1.0, 0.0)
	dropdown_panel.visible = true
	dropdown_panel.position = _menu_open_position + Vector2(0.0, -6.0)
	dropdown_panel.scale = Vector2(0.985, 0.985)
	dropdown_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)

	if main != null:
		_menu_tween = main.create_tween()
		_menu_tween.set_parallel(true)
		_menu_tween.tween_property(outside_close, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_menu_tween.tween_property(dropdown_panel, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_menu_tween.tween_property(dropdown_panel, "position", _menu_open_position, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_menu_tween.tween_property(dropdown_panel, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		outside_close.modulate = Color(1.0, 1.0, 1.0, 1.0)
		dropdown_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
		dropdown_panel.position = _menu_open_position
		dropdown_panel.scale = Vector2.ONE


func _on_profile_pressed() -> void:
	close_menu()
	if main != null and main.has_method("_on_profile_button_pressed"):
		main._on_profile_button_pressed()


func _on_atlas_pressed() -> void:
	close_menu()
	if main != null and main.has_method("_on_encyclopedia_button_pressed"):
		main._on_encyclopedia_button_pressed()


func _on_forecast_pressed() -> void:
	close_menu()
	if main == null:
		return

	_ensure_forecast_nodes()
	_build_forecast_content()
	main.open_modal("weather_forecast")
	forecast_backdrop.visible = true
	forecast_panel.visible = true
	main._active_nav_tab = "fish"
	main._refresh_modal_input_blocker()
	main._refresh_bottom_nav_styles()


func _on_settings_pressed() -> void:
	close_menu()
	if main == null:
		return

	_ensure_settings_nodes()
	main.open_modal("settings")
	settings_backdrop.visible = true
	settings_panel.visible = true
	main._active_nav_tab = "fish"
	main._refresh_modal_input_blocker()
	main._refresh_bottom_nav_styles()


func _on_settings_close_pressed() -> void:
	close_settings(true)


func _on_forecast_close_pressed() -> void:
	close_forecast(true)


func _on_outside_close_gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event != null and mouse_event.pressed:
		close_menu()
		if main != null:
			main.get_viewport().set_input_as_handled()


func _build_forecast_content() -> void:
	if forecast_list == null:
		return

	_clear_children(forecast_list)
	var forecast := WeatherUIHelperScript.get_forecast(_get_time_manager(), 7)
	for day_data in forecast:
		forecast_list.add_child(_create_forecast_row(day_data))


func _create_forecast_row(day_data: Dictionary) -> Panel:
	var row := Panel.new()
	row.custom_minimum_size = Vector2(0.0, 46.0)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_stylebox_override(
		"panel",
		_make_style(Color(0.040, 0.064, 0.066, 0.62), Color(0.72, 0.94, 0.88, 0.16), 10, 2, Color.TRANSPARENT)
	)

	var hbox := HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.offset_left = 14.0
	hbox.offset_top = 4.0
	hbox.offset_right = -14.0
	hbox.offset_bottom = -4.0
	hbox.add_theme_constant_override("separation", 12)
	row.add_child(hbox)

	var day_label := Label.new()
	day_label.text = str(day_data.get("label", "День"))
	day_label.custom_minimum_size = Vector2(126.0, 36.0)
	day_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	day_label.clip_text = true
	day_label.add_theme_font_size_override("font_size", 14)
	day_label.add_theme_color_override("font_color", Color(0.92, 1.0, 0.96, 1.0))
	hbox.add_child(day_label)

	var icon := TextureRect.new()
	var icon_path := str(day_data.get("icon_path", ""))
	icon.texture = load(icon_path) if icon_path != "" else null
	icon.custom_minimum_size = Vector2(42.0, 38.0)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
	hbox.add_child(icon)

	var temp_label := Label.new()
	temp_label.text = str(day_data.get("temperature_text", "18°C"))
	temp_label.custom_minimum_size = Vector2(70.0, 36.0)
	temp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	temp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	temp_label.add_theme_font_size_override("font_size", 16)
	temp_label.add_theme_color_override("font_color", Color(0.84, 1.0, 0.92, 1.0))
	hbox.add_child(temp_label)

	var description_label := Label.new()
	description_label.text = str(day_data.get("description", "Ясно"))
	description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description_label.custom_minimum_size = Vector2(120.0, 36.0)
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	description_label.clip_text = true
	description_label.add_theme_font_size_override("font_size", 14)
	description_label.add_theme_color_override("font_color", Color(0.72, 0.84, 0.80, 0.94))
	hbox.add_child(description_label)

	return row


func _get_time_manager() -> Node:
	if main == null:
		return null
	return main.get_node_or_null("/root/TimeManager")


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


func _apply_menu_button_style() -> void:
	var normal := _make_style(Color(0.026, 0.044, 0.044, 0.78), Color(0.74, 0.96, 0.86, 0.32), 15, 5, Color(0.0, 0.0, 0.0, 0.22))
	var hover := _make_style(Color(0.046, 0.082, 0.076, 0.88), Color(0.84, 1.0, 0.88, 0.54), 15, 7, Color(0.18, 0.66, 0.48, 0.13))
	var pressed := _make_style(Color(0.038, 0.112, 0.092, 0.94), Color(0.82, 1.0, 0.86, 0.62), 15, 3, Color(0.0, 0.0, 0.0, 0.16))
	var disabled := _make_style(Color(0.030, 0.040, 0.042, 0.44), Color(0.58, 0.64, 0.62, 0.12), 15, 1, Color.TRANSPARENT)
	menu_button.add_theme_stylebox_override("normal", normal)
	menu_button.add_theme_stylebox_override("hover", hover)
	menu_button.add_theme_stylebox_override("pressed", pressed)
	menu_button.add_theme_stylebox_override("disabled", disabled)
	menu_button.add_theme_color_override("font_color", Color(0.88, 1.0, 0.94, 1.0))
	menu_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	menu_button.add_theme_color_override("font_pressed_color", Color(0.80, 1.0, 0.92, 1.0))
	menu_button.add_theme_color_override("font_disabled_color", Color(0.62, 0.70, 0.68, 0.54))


func _apply_panel_style(panel: Panel) -> void:
	panel.add_theme_stylebox_override(
		"panel",
		_make_style(Color(0.018, 0.034, 0.034, 0.78), Color(0.74, 0.94, 0.78, 0.26), 16, 10, Color(0.0, 0.0, 0.0, 0.28))
	)


func _apply_menu_item_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _make_menu_row_style(Color(0.052, 0.074, 0.068, 0.36), Color.TRANSPARENT, 12, 0, Color.TRANSPARENT, 0))
	button.add_theme_stylebox_override("hover", _make_menu_row_style(Color(0.070, 0.118, 0.098, 0.76), Color(0.78, 1.0, 0.86, 0.32), 12, 4, Color(0.16, 0.66, 0.48, 0.12), 1))
	button.add_theme_stylebox_override("pressed", _make_menu_row_style(Color(0.056, 0.142, 0.112, 0.88), Color(0.82, 1.0, 0.86, 0.44), 12, 1, Color.TRANSPARENT, 1))
	button.add_theme_stylebox_override("disabled", _make_menu_row_style(Color(0.040, 0.050, 0.052, 0.36), Color.TRANSPARENT, 12, 0, Color.TRANSPARENT, 0))
	button.add_theme_color_override("font_color", Color(0.90, 0.98, 0.92, 0.98))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.84, 1.0, 0.90, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.60, 0.68, 0.65, 0.62))
	button.add_theme_color_override("icon_normal_color", Color(0.98, 1.0, 0.86, 0.98))
	button.add_theme_color_override("icon_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	button.add_theme_color_override("icon_pressed_color", Color(0.84, 1.0, 0.90, 1.0))
	button.add_theme_color_override("icon_disabled_color", Color(0.60, 0.64, 0.58, 0.48))


func _make_menu_row_style(
	bg_color: Color,
	border_color: Color,
	radius: int,
	shadow_size: int = 0,
	shadow_color: Color = Color.TRANSPARENT,
	border_width: int = 1
) -> StyleBoxFlat:
	var style := _make_style(bg_color, border_color, radius, shadow_size, shadow_color)
	style.set_border_width_all(border_width)
	style.content_margin_left = 14.0
	style.content_margin_top = 0.0
	style.content_margin_right = 14.0
	style.content_margin_bottom = 0.0
	return style


func _make_style(
	bg_color: Color,
	border_color: Color,
	radius: int,
	shadow_size: int = 0,
	shadow_color: Color = Color.TRANSPARENT
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_size = shadow_size
	style.shadow_color = shadow_color
	style.content_margin_left = 10.0
	style.content_margin_top = 6.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 6.0
	return style
