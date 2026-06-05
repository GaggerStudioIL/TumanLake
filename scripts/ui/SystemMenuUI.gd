# Top-right system menu for profile, fish atlas, and settings.
extends RefCounted

const WeatherUIHelperScript := preload("res://scripts/ui/helpers/WeatherUIHelper.gd")
const MENU_WEATHER_ICON := preload("res://assets/ui/icons/menu_weather.png")

const BUTTON_BASE_SIZE := Vector2(62.0, 54.0)
const PANEL_BASE_WIDTH := 258.0
const ITEM_BASE_HEIGHT := 58.0
const ITEM_ICON_BASE_SIZE := 44.0

var main
var root: Control
var outside_close: ColorRect
var menu_button: Button
var dropdown_panel: Panel
var menu_items_box: VBoxContainer
var build_version_label: Label
var profile_item: Button
var atlas_item: Button
var forecast_item: Button
var settings_item: Button
var bug_report_item: Button
var settings_backdrop: ColorRect
var settings_panel: Panel
var settings_title: Label
var settings_message: Label
var settings_music_label: Label
var settings_music_slider: HSlider
var settings_music_value_label: Label
var settings_radio_label: Label
var settings_radio_slider: HSlider
var settings_radio_value_label: Label
var settings_sfx_label: Label
var settings_sfx_slider: HSlider
var settings_sfx_value_label: Label
var settings_vibration_label: Label
var settings_vibration_toggle: CheckBox
var settings_intro_label: Label
var settings_intro_toggle: CheckBox
var settings_source_label: Label
var settings_source_option: OptionButton
var settings_close_button: Button
var forecast_backdrop: ColorRect
var forecast_panel: Panel
var forecast_title: Label
var forecast_scroll: ScrollContainer
var forecast_list: VBoxContainer
var forecast_close_button: Button
var bug_report_backdrop: ColorRect
var bug_report_panel: Panel
var bug_report_title: Label
var bug_report_scroll: ScrollContainer
var bug_report_body: Label
var bug_report_close_button: Button
var _is_disabled := false
var _menu_tween: Tween
var _menu_open_position := Vector2.ZERO
var _settings_dirty := false
var _syncing_settings_controls := false


func setup(main_ref) -> void:
	main = main_ref
	_ensure_menu_nodes()
	_ensure_settings_nodes()
	_ensure_forecast_nodes()
	_ensure_bug_report_nodes()
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
	var items_height: float = item_height * float(item_count) + item_gap * float(maxi(item_count - 1, 0))
	var footer_gap: float = clampf(8.0 * ui_scale, 7.0, 10.0)
	var footer_height: float = clampf(42.0 * ui_scale, 38.0, 48.0)
	var panel_height: float = items_height + footer_gap + footer_height + panel_padding * 2.0
	var button_x: float = screen_size.x - margin_x - button_size.x
	var button_y: float = margin_y
	var icon_size: int = int(clampf(ITEM_ICON_BASE_SIZE * ui_scale, 38.0, 52.0))

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
	menu_items_box.size = Vector2(panel_width - panel_padding * 2.0, items_height)
	menu_items_box.add_theme_constant_override("separation", int(item_gap))

	build_version_label.position = Vector2(panel_padding, panel_padding + items_height + footer_gap)
	build_version_label.size = Vector2(panel_width - panel_padding * 2.0, footer_height)
	build_version_label.text = _get_build_version_label()
	build_version_label.add_theme_font_size_override("font_size", int(clampf(10.0 * ui_scale, 10.0, 12.0)))
	build_version_label.add_theme_color_override("font_color", Color(0.66, 0.76, 0.72, 0.82))

	for item in [profile_item, atlas_item, forecast_item, settings_item, bug_report_item]:
		item.custom_minimum_size = Vector2(menu_items_box.size.x, item_height)
		item.add_theme_font_size_override("font_size", int(clampf(16.0 * ui_scale, 15.0, 19.0)))
		item.add_theme_constant_override("icon_max_width", icon_size)
		item.add_theme_constant_override("h_separation", int(clampf(13.0 * ui_scale, 12.0, 16.0)))
		_apply_menu_item_style(item)

	if settings_panel != null:
		var panel_size := Vector2(clampf(536.0 * ui_scale, 476.0, 568.0), clampf(536.0 * ui_scale, 500.0, 560.0))
		settings_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
		settings_backdrop.position = Vector2.ZERO
		settings_backdrop.size = screen_size
		settings_panel.position = (screen_size - panel_size) * 0.5
		settings_panel.size = panel_size
		settings_panel.custom_minimum_size = panel_size
		_apply_panel_style(settings_panel)
		settings_title.position = Vector2(28.0, 18.0)
		settings_title.size = Vector2(panel_size.x - 56.0, 40.0)
		settings_title.add_theme_font_size_override("font_size", int(clampf(26.0 * ui_scale, 24.0, 30.0)))
		settings_source_label.position = Vector2(32.0, 76.0)
		settings_source_label.size = Vector2(160.0, 36.0)
		settings_source_label.add_theme_font_size_override("font_size", int(clampf(17.0 * ui_scale, 16.0, 20.0)))
		settings_source_option.position = Vector2(200.0, 70.0)
		settings_source_option.size = Vector2(panel_size.x - 232.0, 48.0)
		settings_source_option.add_theme_font_size_override("font_size", int(clampf(16.0 * ui_scale, 15.0, 19.0)))
		_apply_option_button_style(settings_source_option)

		_layout_settings_slider_row(
			settings_music_label,
			settings_music_slider,
			settings_music_value_label,
			Vector2(32.0, 124.0),
			panel_size.x - 64.0,
			ui_scale
		)
		_layout_settings_slider_row(
			settings_radio_label,
			settings_radio_slider,
			settings_radio_value_label,
			Vector2(32.0, 198.0),
			panel_size.x - 64.0,
			ui_scale
		)
		_layout_settings_slider_row(
			settings_sfx_label,
			settings_sfx_slider,
			settings_sfx_value_label,
			Vector2(32.0, 272.0),
			panel_size.x - 64.0,
			ui_scale
		)
		_layout_settings_toggle_row(
			settings_vibration_label,
			settings_vibration_toggle,
			Vector2(32.0, 350.0),
			panel_size.x - 64.0,
			ui_scale
		)
		_layout_settings_toggle_row(
			settings_intro_label,
			settings_intro_toggle,
			Vector2(32.0, 400.0),
			panel_size.x - 64.0,
			ui_scale
		)
		settings_message.position = Vector2(32.0, panel_size.y - 86.0)
		settings_message.size = Vector2(panel_size.x - 64.0, 28.0)
		settings_message.add_theme_font_size_override("font_size", int(clampf(14.0 * ui_scale, 13.0, 16.0)))
		settings_close_button.position = Vector2(panel_size.x - 158.0, panel_size.y - 58.0)
		settings_close_button.size = Vector2(130.0, 44.0)
		settings_close_button.custom_minimum_size = settings_close_button.size
		settings_close_button.add_theme_font_size_override("font_size", int(clampf(16.0 * ui_scale, 15.0, 19.0)))
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

	if bug_report_panel != null:
		var bug_size := Vector2(clampf(520.0 * ui_scale, 430.0, 560.0), clampf(462.0 * ui_scale, 404.0, 500.0))
		var bug_padding: float = clampf(24.0 * ui_scale, 18.0, 28.0)
		var close_size := Vector2(132.0 * ui_scale, 40.0 * ui_scale)
		var close_y: float = bug_size.y - close_size.y - 18.0 * ui_scale
		bug_report_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
		bug_report_backdrop.position = Vector2.ZERO
		bug_report_backdrop.size = screen_size
		bug_report_panel.position = (screen_size - bug_size) * 0.5
		bug_report_panel.size = bug_size
		bug_report_panel.custom_minimum_size = bug_size
		_apply_bug_report_panel_style(bug_report_panel)
		bug_report_title.position = Vector2(bug_padding, 18.0 * ui_scale)
		bug_report_title.size = Vector2(bug_size.x - bug_padding * 2.0, 36.0 * ui_scale)
		bug_report_title.add_theme_font_size_override("font_size", int(clampf(22.0 * ui_scale, 20.0, 25.0)))
		bug_report_scroll.position = Vector2(bug_padding, 66.0 * ui_scale)
		bug_report_scroll.size = Vector2(bug_size.x - bug_padding * 2.0, close_y - bug_report_scroll.position.y - 18.0 * ui_scale)
		bug_report_body.position = Vector2.ZERO
		bug_report_body.size = bug_report_scroll.size
		bug_report_body.custom_minimum_size = Vector2(bug_report_scroll.size.x, 0.0)
		bug_report_body.add_theme_font_size_override("font_size", int(clampf(15.0 * ui_scale, 14.0, 17.0)))
		bug_report_close_button.position = Vector2(bug_size.x - close_size.x - bug_padding, close_y)
		bug_report_close_button.size = close_size
		bug_report_close_button.custom_minimum_size = close_size
		bug_report_close_button.add_theme_font_size_override("font_size", int(clampf(15.0 * ui_scale, 14.0, 17.0)))
		_apply_menu_item_style(bug_report_close_button)


func is_menu_open() -> bool:
	return dropdown_panel != null and dropdown_panel.visible


func is_settings_open() -> bool:
	return settings_panel != null and settings_panel.visible


func is_forecast_open() -> bool:
	return forecast_panel != null and forecast_panel.visible

func is_bug_report_open() -> bool:
	return bug_report_panel != null and bug_report_panel.visible


func _layout_settings_slider_row(title_label: Label, slider: HSlider, value_label: Label, pos: Vector2, width: float, ui_scale: float) -> void:
	if title_label == null or slider == null or value_label == null:
		return
	title_label.position = pos
	title_label.size = Vector2(width * 0.62, 30.0)
	title_label.add_theme_font_size_override("font_size", int(clampf(18.0 * ui_scale, 16.0, 21.0)))
	value_label.position = pos + Vector2(width - 92.0, 0.0)
	value_label.size = Vector2(92.0, 30.0)
	value_label.add_theme_font_size_override("font_size", int(clampf(17.0 * ui_scale, 16.0, 20.0)))
	slider.position = pos + Vector2(0.0, 36.0)
	slider.size = Vector2(width, 34.0)
	slider.custom_minimum_size = slider.size
	_apply_settings_slider_style(slider)

func _layout_settings_toggle_row(title_label: Label, toggle: CheckBox, pos: Vector2, width: float, ui_scale: float) -> void:
	if title_label == null or toggle == null:
		return
	title_label.position = pos
	title_label.size = Vector2(width * 0.62, 42.0)
	title_label.add_theme_font_size_override("font_size", int(clampf(18.0 * ui_scale, 16.0, 21.0)))
	toggle.position = pos + Vector2(width - 136.0, -3.0)
	toggle.size = Vector2(136.0, 44.0)
	toggle.custom_minimum_size = toggle.size
	toggle.add_theme_font_size_override("font_size", int(clampf(16.0 * ui_scale, 15.0, 19.0)))
	_apply_settings_toggle_style(toggle)


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
	_refresh_main_depth_controls()


func close_settings(reset_nav: bool = true) -> void:
	if settings_panel == null or settings_backdrop == null:
		return

	_save_settings_if_dirty()
	settings_panel.visible = false
	settings_backdrop.visible = false
	if main != null:
		main.close_modal("settings")
		if reset_nav:
			main._active_nav_tab = "fish"
			main._refresh_bottom_nav_styles()
	_refresh_main_depth_controls()


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
	_refresh_main_depth_controls()

func close_bug_report(reset_nav: bool = true) -> void:
	if bug_report_panel == null or bug_report_backdrop == null:
		return

	bug_report_panel.visible = false
	bug_report_backdrop.visible = false
	if main != null:
		main.close_modal("bug_report")
		if reset_nav:
			main._active_nav_tab = "fish"
			main._refresh_bottom_nav_styles()
	_refresh_main_depth_controls()


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
	root.z_index = 340
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

	build_version_label = Label.new()
	build_version_label.name = "BuildVersionLabel"
	build_version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	build_version_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	build_version_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	build_version_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dropdown_panel.add_child(build_version_label)

	profile_item = _create_menu_item("Профиль", "profile")
	atlas_item = _create_menu_item("Атлас рыб", "encyclopedia")
	forecast_item = _create_menu_item("Прогноз погоды", "weather")
	settings_item = _create_menu_item("Настройки", "settings")
	bug_report_item = _create_menu_item("Сообщить о баге", "bug_report")
	menu_items_box.add_child(profile_item)
	menu_items_box.add_child(atlas_item)
	menu_items_box.add_child(forecast_item)
	menu_items_box.add_child(settings_item)
	menu_items_box.add_child(bug_report_item)

	profile_item.pressed.connect(_on_profile_pressed)
	atlas_item.pressed.connect(_on_atlas_pressed)
	forecast_item.pressed.connect(_on_forecast_pressed)
	settings_item.pressed.connect(_on_settings_pressed)
	bug_report_item.pressed.connect(_on_bug_report_pressed)

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
	settings_message.text = "Tuman FM отключает игровую музыку и включает отдельное радио у воды."

	settings_source_label = Label.new()
	settings_source_label.name = "SettingsSourceLabel"
	settings_source_label.text = "Источник"
	settings_source_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	settings_source_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	settings_panel.add_child(settings_source_label)

	settings_source_option = OptionButton.new()
	settings_source_option.name = "SettingsMusicSourceOption"
	settings_source_option.focus_mode = Control.FOCUS_NONE
	settings_source_option.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_source_option.add_item("Музыка игры", 0)
	settings_source_option.add_item("Tuman FM", 1)
	settings_source_option.item_selected.connect(_on_music_source_selected)
	settings_panel.add_child(settings_source_option)

	settings_music_label = Label.new()
	settings_music_label.name = "SettingsMusicLabel"
	settings_music_label.text = "Музыка"
	settings_music_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	settings_music_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	settings_panel.add_child(settings_music_label)

	settings_music_value_label = Label.new()
	settings_music_value_label.name = "SettingsMusicValueLabel"
	settings_music_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	settings_music_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	settings_music_value_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.52, 1.0))
	settings_panel.add_child(settings_music_value_label)

	settings_music_slider = HSlider.new()
	settings_music_slider.name = "SettingsMusicSlider"
	settings_music_slider.min_value = 0.0
	settings_music_slider.max_value = 100.0
	settings_music_slider.step = 1.0
	settings_music_slider.focus_mode = Control.FOCUS_NONE
	settings_music_slider.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_music_slider.value_changed.connect(_on_music_volume_changed)
	settings_panel.add_child(settings_music_slider)

	settings_radio_label = Label.new()
	settings_radio_label.name = "SettingsRadioLabel"
	settings_radio_label.text = "Tuman FM"
	settings_radio_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	settings_radio_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	settings_panel.add_child(settings_radio_label)

	settings_radio_value_label = Label.new()
	settings_radio_value_label.name = "SettingsRadioValueLabel"
	settings_radio_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	settings_radio_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	settings_radio_value_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.52, 1.0))
	settings_panel.add_child(settings_radio_value_label)

	settings_radio_slider = HSlider.new()
	settings_radio_slider.name = "SettingsRadioSlider"
	settings_radio_slider.min_value = 0.0
	settings_radio_slider.max_value = 100.0
	settings_radio_slider.step = 1.0
	settings_radio_slider.focus_mode = Control.FOCUS_NONE
	settings_radio_slider.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_radio_slider.value_changed.connect(_on_radio_volume_changed)
	settings_panel.add_child(settings_radio_slider)

	settings_sfx_label = Label.new()
	settings_sfx_label.name = "SettingsSfxLabel"
	settings_sfx_label.text = "Звуки"
	settings_sfx_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	settings_sfx_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	settings_panel.add_child(settings_sfx_label)

	settings_sfx_value_label = Label.new()
	settings_sfx_value_label.name = "SettingsSfxValueLabel"
	settings_sfx_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	settings_sfx_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	settings_sfx_value_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.52, 1.0))
	settings_panel.add_child(settings_sfx_value_label)

	settings_sfx_slider = HSlider.new()
	settings_sfx_slider.name = "SettingsSfxSlider"
	settings_sfx_slider.min_value = 0.0
	settings_sfx_slider.max_value = 100.0
	settings_sfx_slider.step = 1.0
	settings_sfx_slider.focus_mode = Control.FOCUS_NONE
	settings_sfx_slider.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	settings_panel.add_child(settings_sfx_slider)

	settings_vibration_label = Label.new()
	settings_vibration_label.name = "SettingsVibrationLabel"
	settings_vibration_label.text = "Вибрация"
	settings_vibration_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	settings_vibration_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	settings_panel.add_child(settings_vibration_label)

	settings_vibration_toggle = CheckBox.new()
	settings_vibration_toggle.name = "SettingsVibrationToggle"
	settings_vibration_toggle.text = "Вкл"
	settings_vibration_toggle.focus_mode = Control.FOCUS_NONE
	settings_vibration_toggle.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_vibration_toggle.button_pressed = true
	settings_vibration_toggle.toggled.connect(_on_vibration_toggled)
	settings_panel.add_child(settings_vibration_toggle)

	settings_intro_label = Label.new()
	settings_intro_label.name = "SettingsIntroLabel"
	settings_intro_label.text = "Интро"
	settings_intro_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	settings_intro_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	settings_panel.add_child(settings_intro_label)

	settings_intro_toggle = CheckBox.new()
	settings_intro_toggle.name = "SettingsIntroToggle"
	settings_intro_toggle.text = "Вкл"
	settings_intro_toggle.focus_mode = Control.FOCUS_NONE
	settings_intro_toggle.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_intro_toggle.button_pressed = true
	settings_intro_toggle.toggled.connect(_on_intro_toggled)
	settings_panel.add_child(settings_intro_toggle)

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

func _ensure_bug_report_nodes() -> void:
	if bug_report_panel != null:
		return

	var parent: Node = main.get_modal_content_root() if main.has_method("get_modal_content_root") else main

	bug_report_backdrop = ColorRect.new()
	bug_report_backdrop.name = "BugReportBackdrop"
	bug_report_backdrop.color = Color(0.0, 0.0, 0.0, 0.62)
	bug_report_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	bug_report_backdrop.visible = false
	parent.add_child(bug_report_backdrop)

	bug_report_panel = Panel.new()
	bug_report_panel.name = "BugReportPanel"
	bug_report_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	bug_report_panel.visible = false
	parent.add_child(bug_report_panel)

	bug_report_title = Label.new()
	bug_report_title.name = "BugReportTitle"
	bug_report_title.text = "Как сообщить о баге"
	bug_report_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bug_report_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bug_report_title.add_theme_color_override("font_color", Color(0.92, 1.0, 0.96, 1.0))
	bug_report_panel.add_child(bug_report_title)

	bug_report_scroll = ScrollContainer.new()
	bug_report_scroll.name = "BugReportScroll"
	bug_report_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	bug_report_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	bug_report_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	bug_report_panel.add_child(bug_report_scroll)

	bug_report_body = Label.new()
	bug_report_body.name = "BugReportBody"
	bug_report_body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	bug_report_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bug_report_body.add_theme_color_override("font_color", Color(0.78, 0.90, 0.86, 0.96))
	bug_report_scroll.add_child(bug_report_body)

	bug_report_close_button = Button.new()
	bug_report_close_button.name = "BugReportCloseButton"
	bug_report_close_button.text = "Закрыть"
	bug_report_close_button.focus_mode = Control.FOCUS_NONE
	bug_report_close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	bug_report_panel.add_child(bug_report_close_button)
	bug_report_close_button.pressed.connect(_on_bug_report_close_pressed)


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
	_refresh_main_depth_controls()
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


func _refresh_main_depth_controls() -> void:
	if main == null:
		return
	if main.has_method("_request_depth_hud_refresh"):
		main.call("_request_depth_hud_refresh")
	elif main.has_method("_refresh_depth_hud_controls"):
		main.call_deferred("_refresh_depth_hud_controls")


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

func _on_bug_report_pressed() -> void:
	close_menu()
	if main == null:
		return

	_ensure_bug_report_nodes()
	_refresh_bug_report_text()
	main.open_modal("bug_report")
	bug_report_backdrop.visible = true
	bug_report_panel.visible = true
	main._active_nav_tab = "fish"
	main._refresh_modal_input_blocker()
	main._refresh_bottom_nav_styles()


func _get_audio_manager() -> Node:
	if main == null:
		return null
	return main.get_node_or_null("/root/AudioManager")


func _get_radio_manager() -> Node:
	if main == null:
		return null
	return main.get_node_or_null("/root/RadioManager")

func _get_fishing_manager() -> Node:
	if main == null:
		return null
	return main.get_node_or_null("/root/FishingManager")

func _get_save_manager() -> Node:
	if main == null:
		return null
	return main.get_node_or_null("/root/SaveManager")


func _sync_settings_controls_from_audio_manager() -> void:
	var audio_manager := _get_audio_manager()
	var radio_manager: Node = _get_radio_manager()
	var fishing_manager: Node = _get_fishing_manager()
	var save_manager: Node = _get_save_manager()
	var settings: Dictionary = {}
	if audio_manager != null and audio_manager.has_method("get_volume_settings"):
		var value = audio_manager.call("get_volume_settings")
		if value is Dictionary:
			settings = value as Dictionary
	var radio_settings: Dictionary = {}
	if radio_manager != null and radio_manager.has_method("get_radio_settings"):
		var radio_settings_value = radio_manager.call("get_radio_settings")
		if radio_settings_value is Dictionary:
			radio_settings = radio_settings_value as Dictionary

	var music_value := float(settings.get("music_volume", 0.55))
	var radio_volume_value := float(radio_settings.get("music_volume", 0.55))
	var sfx_value := maxf(float(settings.get("sfx_volume", 0.75)), float(settings.get("ambient_volume", 0.72)))
	var source := str(settings.get("music_source", "game"))
	var radio_enabled := bool(radio_settings.get("radio_enabled", source == "radio"))
	var vibration_enabled := true
	if fishing_manager != null and fishing_manager.has_method("is_vibration_enabled"):
		vibration_enabled = bool(fishing_manager.call("is_vibration_enabled"))
	var intro_enabled := true
	if save_manager != null and save_manager.has_method("is_intro_enabled"):
		intro_enabled = bool(save_manager.call("is_intro_enabled"))

	_syncing_settings_controls = true
	if settings_music_slider != null:
		settings_music_slider.set_value_no_signal(roundi(clampf(music_value, 0.0, 1.0) * 100.0))
	if settings_radio_slider != null:
		settings_radio_slider.set_value_no_signal(roundi(clampf(radio_volume_value, 0.0, 1.0) * 100.0))
	if settings_sfx_slider != null:
		settings_sfx_slider.set_value_no_signal(roundi(clampf(sfx_value, 0.0, 1.0) * 100.0))
	if settings_source_option != null:
		settings_source_option.select(1 if source == "radio" or radio_enabled else 0)
	if settings_vibration_toggle != null:
		settings_vibration_toggle.set_pressed_no_signal(vibration_enabled)
	if settings_intro_toggle != null:
		settings_intro_toggle.set_pressed_no_signal(intro_enabled)
	_syncing_settings_controls = false
	_update_settings_value_labels()
	_settings_dirty = false


func _update_settings_value_labels() -> void:
	if settings_music_value_label != null and settings_music_slider != null:
		settings_music_value_label.text = "%d%%" % roundi(settings_music_slider.value)
	if settings_radio_value_label != null and settings_radio_slider != null:
		settings_radio_value_label.text = "%d%%" % roundi(settings_radio_slider.value)
	if settings_sfx_value_label != null and settings_sfx_slider != null:
		settings_sfx_value_label.text = "%d%%" % roundi(settings_sfx_slider.value)
	if settings_vibration_toggle != null:
		settings_vibration_toggle.text = "Вкл" if settings_vibration_toggle.button_pressed else "Выкл"
	if settings_intro_toggle != null:
		settings_intro_toggle.text = "Вкл" if settings_intro_toggle.button_pressed else "Выкл"


func _on_music_volume_changed(value: float) -> void:
	_update_settings_value_labels()
	if _syncing_settings_controls:
		return
	var audio_manager := _get_audio_manager()
	if audio_manager != null and audio_manager.has_method("set_music_volume"):
		audio_manager.call("set_music_volume", clampf(value / 100.0, 0.0, 1.0))
	_settings_dirty = true


func _on_radio_volume_changed(value: float) -> void:
	_update_settings_value_labels()
	if _syncing_settings_controls:
		return
	var radio_manager: Node = _get_radio_manager()
	if radio_manager != null and radio_manager.has_method("set_music_volume"):
		radio_manager.call("set_music_volume", clampf(value / 100.0, 0.0, 1.0))
	_settings_dirty = true


func _on_sfx_volume_changed(value: float) -> void:
	_update_settings_value_labels()
	if _syncing_settings_controls:
		return
	var normalized := clampf(value / 100.0, 0.0, 1.0)
	var audio_manager := _get_audio_manager()
	if audio_manager != null and audio_manager.has_method("set_volume_settings"):
		audio_manager.call("set_volume_settings", {
			"sfx_volume": normalized,
			"ambient_volume": normalized
		})
	_settings_dirty = true

func _on_vibration_toggled(enabled: bool) -> void:
	_update_settings_value_labels()
	if _syncing_settings_controls:
		return
	var fishing_manager: Node = _get_fishing_manager()
	if fishing_manager != null and fishing_manager.has_method("set_vibration_enabled"):
		fishing_manager.call("set_vibration_enabled", enabled)
	_settings_dirty = true

func _on_intro_toggled(enabled: bool) -> void:
	_update_settings_value_labels()
	if _syncing_settings_controls:
		return
	var save_manager: Node = _get_save_manager()
	if save_manager != null and save_manager.has_method("set_intro_enabled"):
		save_manager.call("set_intro_enabled", enabled)
	_settings_dirty = true


func _on_music_source_selected(index: int) -> void:
	if _syncing_settings_controls:
		return
	var source := "radio" if index == 1 else "game"
	var audio_manager := _get_audio_manager()
	var radio_manager: Node = _get_radio_manager()
	if audio_manager != null and audio_manager.has_method("set_music_source"):
		audio_manager.call("set_music_source", source)
	if radio_manager != null:
		if radio_manager.has_method("set_music_volume") and settings_radio_slider != null:
			radio_manager.call("set_music_volume", clampf(settings_radio_slider.value / 100.0, 0.0, 1.0))
		if radio_manager.has_method("set_radio_enabled"):
			radio_manager.call("set_radio_enabled", source == "radio")
	_settings_dirty = true


func _save_settings_if_dirty() -> void:
	if not _settings_dirty:
		return
	if main != null:
		var save_manager: Node = main.get_node_or_null("/root/SaveManager")
		if save_manager != null and save_manager.has_method("save_game"):
			save_manager.call("save_game")
	_settings_dirty = false


func _on_settings_pressed() -> void:
	close_menu()
	if main == null:
		return

	_ensure_settings_nodes()
	_sync_settings_controls_from_audio_manager()
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

func _on_bug_report_close_pressed() -> void:
	close_bug_report(true)


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

func _refresh_bug_report_text() -> void:
	if bug_report_body == null:
		return
	bug_report_body.text = _get_bug_report_text()


func _get_bug_report_text() -> String:
	return "Чтобы мы быстро нашли и исправили ошибку, пришлите:\n\n" \
		+ "1. Что вы делали перед багом.\n" \
		+ "2. Что должно было произойти.\n" \
		+ "3. Что произошло на самом деле.\n" \
		+ "4. Можно ли повторить баг.\n" \
		+ "5. Скриншот или видео, если возможно.\n" \
		+ "6. Версию билда.\n" \
		+ "7. Устройство и разрешение экрана.\n\n" \
		+ "Версия билда:\n%s" % _get_build_version_label()


func _get_build_version_label() -> String:
	var version_node: Node = null
	if main != null:
		version_node = main.get_node_or_null("/root/GameVersion")
	if version_node != null and version_node.has_method("get_version_label"):
		return str(version_node.call("get_version_label"))
	return "v0.1.0-beta.1"


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


func _apply_option_button_style(button: OptionButton) -> void:
	button.add_theme_stylebox_override("normal", _make_menu_row_style(Color(0.052, 0.074, 0.068, 0.72), Color(0.78, 1.0, 0.86, 0.24), 14, 3, Color(0.0, 0.0, 0.0, 0.16), 1))
	button.add_theme_stylebox_override("hover", _make_menu_row_style(Color(0.070, 0.118, 0.098, 0.86), Color(1.0, 0.84, 0.42, 0.42), 14, 4, Color(0.16, 0.66, 0.48, 0.12), 1))
	button.add_theme_stylebox_override("pressed", _make_menu_row_style(Color(0.056, 0.142, 0.112, 0.92), Color(1.0, 0.84, 0.42, 0.50), 14, 2, Color.TRANSPARENT, 1))
	button.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.72, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.84, 0.52, 1.0))


func _apply_settings_slider_style(slider: HSlider) -> void:
	var track := _make_style(Color(0.035, 0.060, 0.058, 0.96), Color(0.78, 1.0, 0.86, 0.22), 10, 1, Color.TRANSPARENT)
	track.content_margin_top = 8.0
	track.content_margin_bottom = 8.0
	var fill := _make_style(Color(0.82, 0.58, 0.22, 0.90), Color(1.0, 0.84, 0.42, 0.36), 10, 3, Color(0.92, 0.58, 0.18, 0.18))
	fill.content_margin_top = 8.0
	fill.content_margin_bottom = 8.0
	slider.add_theme_stylebox_override("slider", track)
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill)

func _apply_settings_toggle_style(toggle: CheckBox) -> void:
	toggle.add_theme_stylebox_override("normal", _make_menu_row_style(Color(0.052, 0.074, 0.068, 0.54), Color(0.78, 1.0, 0.86, 0.20), 12, 1, Color.TRANSPARENT, 1))
	toggle.add_theme_stylebox_override("hover", _make_menu_row_style(Color(0.070, 0.118, 0.098, 0.82), Color(1.0, 0.84, 0.42, 0.42), 12, 3, Color(0.16, 0.66, 0.48, 0.10), 1))
	toggle.add_theme_stylebox_override("pressed", _make_menu_row_style(Color(0.056, 0.142, 0.112, 0.90), Color(1.0, 0.84, 0.42, 0.48), 12, 1, Color.TRANSPARENT, 1))
	toggle.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	toggle.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.72, 1.0))
	toggle.add_theme_color_override("font_pressed_color", Color(1.0, 0.84, 0.52, 1.0))
	toggle.add_theme_constant_override("h_separation", 8)


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

func _apply_bug_report_panel_style(panel: Panel) -> void:
	panel.add_theme_stylebox_override(
		"panel",
		_make_style(Color(0.015, 0.030, 0.030, 0.94), Color(0.74, 0.94, 0.78, 0.34), 16, 12, Color(0.0, 0.0, 0.0, 0.34))
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
