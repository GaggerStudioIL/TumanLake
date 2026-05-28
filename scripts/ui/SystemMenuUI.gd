# Top-right system menu for profile, fish atlas, and settings.
extends RefCounted

const BUTTON_BASE_SIZE := Vector2(60.0, 50.0)
const PANEL_BASE_WIDTH := 210.0
const ITEM_BASE_HEIGHT := 54.0

var main
var root: Control
var outside_close: ColorRect
var menu_button: Button
var dropdown_panel: Panel
var menu_items_box: VBoxContainer
var profile_item: Button
var atlas_item: Button
var settings_item: Button
var settings_backdrop: ColorRect
var settings_panel: Panel
var settings_title: Label
var settings_message: Label
var settings_close_button: Button
var _is_disabled := false


func setup(main_ref) -> void:
	main = main_ref
	_ensure_menu_nodes()
	_ensure_settings_nodes()
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
	var panel_width: float = clampf(PANEL_BASE_WIDTH * ui_scale, 188.0, 224.0)
	var item_height: float = clampf(ITEM_BASE_HEIGHT * ui_scale, 48.0, 56.0)
	var panel_height: float = item_height * 3.0 + 18.0 * ui_scale
	var button_x: float = screen_size.x - margin_x - button_size.x
	var button_y: float = margin_y

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

	dropdown_panel.position = Vector2(screen_size.x - margin_x - panel_width, button_y + button_size.y + 8.0 * ui_scale)
	dropdown_panel.size = Vector2(panel_width, panel_height)
	dropdown_panel.custom_minimum_size = dropdown_panel.size
	_apply_panel_style(dropdown_panel)

	menu_items_box.position = Vector2(9.0 * ui_scale, 9.0 * ui_scale)
	menu_items_box.size = Vector2(panel_width - 18.0 * ui_scale, panel_height - 18.0 * ui_scale)
	menu_items_box.add_theme_constant_override("separation", int(5.0 * ui_scale))

	for item in [profile_item, atlas_item, settings_item]:
		item.custom_minimum_size = Vector2(menu_items_box.size.x, item_height)
		item.add_theme_font_size_override("font_size", int(16.0 * ui_scale))
		item.add_theme_constant_override("icon_max_width", int(32.0 * ui_scale))
		item.add_theme_constant_override("h_separation", int(12.0 * ui_scale))
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


func is_menu_open() -> bool:
	return dropdown_panel != null and dropdown_panel.visible


func is_settings_open() -> bool:
	return settings_panel != null and settings_panel.visible


func close_menu() -> void:
	if dropdown_panel != null:
		dropdown_panel.visible = false
	if outside_close != null:
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
	outside_close.color = Color(0.0, 0.0, 0.0, 0.0)
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
	settings_item = _create_menu_item("Настройки", "settings")
	menu_items_box.add_child(profile_item)
	menu_items_box.add_child(atlas_item)
	menu_items_box.add_child(settings_item)

	profile_item.pressed.connect(_on_profile_pressed)
	atlas_item.pressed.connect(_on_atlas_pressed)
	settings_item.pressed.connect(_on_settings_pressed)

	menu_button = Button.new()
	menu_button.name = "HamburgerMenuButton"
	menu_button.text = "☰"
	menu_button.tooltip_text = "Меню"
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


func _create_menu_item(text: String, icon_name: String) -> Button:
	var item := Button.new()
	item.text = text
	item.focus_mode = Control.FOCUS_NONE
	item.mouse_filter = Control.MOUSE_FILTER_STOP
	item.clip_text = true
	if main.ui_theme != null:
		item.icon = main.ui_theme.get_icon(icon_name)
		item.expand_icon = true
		item.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		item.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		item.add_theme_constant_override("icon_max_width", 32)
		item.add_theme_constant_override("h_separation", 12)
	return item


func _on_menu_button_pressed() -> void:
	if _is_disabled:
		return
	if is_menu_open():
		close_menu()
	else:
		outside_close.visible = true
		dropdown_panel.visible = true


func _on_profile_pressed() -> void:
	close_menu()
	if main != null and main.has_method("_on_profile_button_pressed"):
		main._on_profile_button_pressed()


func _on_atlas_pressed() -> void:
	close_menu()
	if main != null and main.has_method("_on_encyclopedia_button_pressed"):
		main._on_encyclopedia_button_pressed()


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


func _on_outside_close_gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event != null and mouse_event.pressed:
		close_menu()
		if main != null:
			main.get_viewport().set_input_as_handled()


func _apply_menu_button_style() -> void:
	var normal := _make_style(Color(0.035, 0.058, 0.060, 0.82), Color(0.68, 0.94, 0.88, 0.32), 14, 5, Color(0.0, 0.0, 0.0, 0.24))
	var hover := _make_style(Color(0.054, 0.098, 0.096, 0.92), Color(0.78, 1.0, 0.95, 0.52), 14, 7, Color(0.22, 0.86, 0.82, 0.14))
	var pressed := _make_style(Color(0.040, 0.130, 0.118, 0.96), Color(0.80, 1.0, 0.92, 0.64), 14, 3, Color(0.0, 0.0, 0.0, 0.16))
	var disabled := _make_style(Color(0.030, 0.040, 0.042, 0.46), Color(0.58, 0.64, 0.62, 0.14), 14, 1, Color.TRANSPARENT)
	menu_button.add_theme_stylebox_override("normal", normal)
	menu_button.add_theme_stylebox_override("hover", hover)
	menu_button.add_theme_stylebox_override("pressed", pressed)
	menu_button.add_theme_stylebox_override("disabled", disabled)
	menu_button.add_theme_color_override("font_color", Color(0.90, 1.0, 0.96, 1.0))
	menu_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	menu_button.add_theme_color_override("font_pressed_color", Color(0.80, 1.0, 0.92, 1.0))
	menu_button.add_theme_color_override("font_disabled_color", Color(0.62, 0.70, 0.68, 0.54))


func _apply_panel_style(panel: Panel) -> void:
	panel.add_theme_stylebox_override(
		"panel",
		_make_style(Color(0.020, 0.036, 0.038, 0.88), Color(0.66, 0.92, 0.86, 0.28), 12, 8, Color(0.0, 0.0, 0.0, 0.34))
	)


func _apply_menu_item_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _make_style(Color(0.052, 0.080, 0.078, 0.72), Color(0.66, 0.86, 0.80, 0.18), 10, 2, Color.TRANSPARENT))
	button.add_theme_stylebox_override("hover", _make_style(Color(0.074, 0.130, 0.122, 0.90), Color(0.78, 1.0, 0.92, 0.42), 10, 5, Color(0.18, 0.72, 0.68, 0.12)))
	button.add_theme_stylebox_override("pressed", _make_style(Color(0.060, 0.160, 0.132, 0.96), Color(0.84, 1.0, 0.90, 0.56), 10, 1, Color.TRANSPARENT))
	button.add_theme_stylebox_override("disabled", _make_style(Color(0.040, 0.050, 0.052, 0.46), Color(0.58, 0.64, 0.62, 0.14), 10, 1, Color.TRANSPARENT))
	button.add_theme_color_override("font_color", Color(0.90, 0.98, 0.94, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.84, 1.0, 0.90, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.60, 0.68, 0.65, 0.62))
	button.add_theme_color_override("icon_normal_color", Color(0.94, 0.96, 0.86, 0.94))
	button.add_theme_color_override("icon_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	button.add_theme_color_override("icon_pressed_color", Color(0.84, 1.0, 0.90, 1.0))
	button.add_theme_color_override("icon_disabled_color", Color(0.60, 0.64, 0.58, 0.48))


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
