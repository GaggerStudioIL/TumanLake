# Tuman Lake shared UI Kit v1 adapter.
extends RefCounted

const BASE_SIZE := Vector2(1320.0, 540.0)
const ASSET_ROOT := "res://assets/ui/tuman_lake_ui_kit_v1/"

const TEXT_PRIMARY := Color(0.93, 0.98, 0.93, 1.0)
const TEXT_SECONDARY := Color(0.72, 0.86, 0.78, 0.94)
const TEXT_MUTED := Color(0.55, 0.68, 0.62, 0.88)
const TEXT_GREEN := Color(0.70, 0.96, 0.55, 1.0)
const TEXT_DANGER := Color(1.0, 0.78, 0.72, 1.0)

const MIN_GRID_COLUMNS := 5
const MAX_GRID_COLUMNS := 6

static func texture(asset_name: String) -> Texture2D:
	var path := "%s%s.png" % [ASSET_ROOT, asset_name]
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


static func style(asset_name: String, texture_margins := Vector4(18.0, 18.0, 18.0, 18.0), content_margins := Vector4.ZERO) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture(asset_name)
	style.texture_margin_left = texture_margins.x
	style.texture_margin_top = texture_margins.y
	style.texture_margin_right = texture_margins.z
	style.texture_margin_bottom = texture_margins.w
	style.content_margin_left = content_margins.x
	style.content_margin_top = content_margins.y
	style.content_margin_right = content_margins.z
	style.content_margin_bottom = content_margins.w
	style.draw_center = true
	return style


static func apply_full_rect(control: Control, size: Vector2) -> void:
	if control == null:
		return
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.position = Vector2.ZERO
	control.size = size
	control.custom_minimum_size = Vector2.ZERO


static func get_window_rect(viewport_size: Vector2) -> Rect2:
	return Rect2(Vector2.ZERO, viewport_size)


static func get_metrics(window_size: Vector2) -> Dictionary:
	var x_scale := window_size.x / BASE_SIZE.x
	var y_scale := window_size.y / BASE_SIZE.y
	var ui_scale := minf(x_scale, y_scale)
	return {
		"x_scale": x_scale,
		"y_scale": y_scale,
		"scale": ui_scale,
		"gap": maxf(8.0 * ui_scale, 5.0),
		"padding_x": 16.0 * x_scale,
		"padding_y": 8.0 * y_scale,
		"close_size": 34.0 * ui_scale,
		"tab_button_width": 126.0 * x_scale,
		"tab_button_height": 34.0 * y_scale,
		"chip_width": 104.0 * x_scale,
		"chip_height": 28.0 * y_scale,
		"footer_button_width": 170.0 * x_scale,
		"footer_button_height": 26.0 * y_scale
	}


static func get_inventory_content_layout(window_size: Vector2) -> Dictionary:
	var sx := window_size.x / BASE_SIZE.x
	var sy := window_size.y / BASE_SIZE.y
	return {
		"header_pos": Vector2(18.0 * sx, 4.0 * sy),
		"header_size": Vector2(1284.0 * sx, 32.0 * sy),
		"close_pos": Vector2(1272.0 * sx, 8.0 * sy),
		"close_size": Vector2(34.0 * sx, 34.0 * sy),
		"tab_pos": Vector2(18.0 * sx, 42.0 * sy),
		"tab_size": Vector2(1284.0 * sx, 38.0 * sy),
		"toolbar_pos": Vector2(16.0 * sx, 88.0 * sy),
		"toolbar_size": Vector2(948.0 * sx, 40.0 * sy),
		"grid_pos": Vector2(16.0 * sx, 136.0 * sy),
		"grid_size": Vector2(948.0 * sx, 358.0 * sy),
		"details_pos": Vector2(976.0 * sx, 88.0 * sy),
		"details_size": Vector2(326.0 * sx, 406.0 * sy),
		"footer_pos": Vector2(16.0 * sx, 500.0 * sy),
		"footer_size": Vector2(1286.0 * sx, 32.0 * sy)
	}


static func get_grid_columns(viewport_width: float) -> int:
	if viewport_width <= 1.0:
		return MIN_GRID_COLUMNS
	var columns := int(floor(viewport_width / 112.0))
	return clampi(columns, MIN_GRID_COLUMNS, MAX_GRID_COLUMNS)


static func get_grid_card_size(viewport_width: float, columns: int, gap: float) -> Vector2:
	columns = clampi(columns, MIN_GRID_COLUMNS, MAX_GRID_COLUMNS)
	var width_scale: float = clampf(viewport_width / 932.0, 0.68, 1.0)
	var width: float = floor(clampf(136.0 * width_scale, 92.0, 136.0))
	var max_width: float = floor((viewport_width - float(columns - 1) * gap) / float(columns))
	width = minf(width, max_width)
	var height: float = floor(clampf(94.0 * width_scale, 78.0, 94.0))
	return Vector2(width, height)


static func apply_window(panel: Panel) -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override("panel", style("window_large", Vector4(34.0, 34.0, 34.0, 34.0)))


static func apply_panel(panel: Panel, asset_name: String, margins := Vector4(18.0, 18.0, 18.0, 18.0), content := Vector4.ZERO) -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override("panel", style(asset_name, margins, content))


static func apply_button_states(
	button: Button,
	normal_asset: String,
	hover_asset: String,
	pressed_asset: String,
	disabled_asset := "btn_disabled",
	margins := Vector4(18.0, 18.0, 18.0, 18.0),
	font_size := 13
) -> void:
	if button == null:
		return
	button.add_theme_stylebox_override("normal", style(normal_asset, margins))
	button.add_theme_stylebox_override("hover", style(hover_asset, margins))
	button.add_theme_stylebox_override("pressed", style(pressed_asset, margins))
	button.add_theme_stylebox_override("disabled", style(disabled_asset, margins))
	button.add_theme_color_override("font_color", TEXT_PRIMARY)
	button.add_theme_color_override("font_hover_color", TEXT_PRIMARY)
	button.add_theme_color_override("font_pressed_color", Color(0.86, 0.98, 0.82, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.54, 0.60, 0.58, 0.78))
	button.add_theme_font_size_override("font_size", font_size)


static func apply_close_button(button: Button) -> void:
	apply_button_states(button, "square_button_normal", "square_button_hover", "square_button_primary", "square_button_normal", Vector4(18.0, 18.0, 18.0, 18.0), 18)
	button.text = "X"
	button.add_theme_color_override("font_color", TEXT_PRIMARY)
	button.add_theme_color_override("font_hover_color", TEXT_PRIMARY)
	button.add_theme_color_override("font_pressed_color", TEXT_GREEN)


static func apply_tab_button(button: Button, active: bool, font_size := 12) -> void:
	if active:
		apply_button_states(button, "tab_active", "tab_active", "tab_active", "tab_active", Vector4(22.0, 22.0, 22.0, 22.0), font_size)
	else:
		apply_button_states(button, "tab_inactive", "tab_hover", "tab_hover", "tab_inactive", Vector4(22.0, 22.0, 22.0, 22.0), font_size)


static func apply_filter_button(button: Button, active: bool, font_size := 12) -> void:
	if active:
		apply_button_states(button, "btn_primary_normal", "btn_primary_hover", "btn_primary_pressed", "btn_disabled", Vector4(18.0, 18.0, 18.0, 18.0), font_size)
	else:
		apply_button_states(button, "btn_secondary_normal", "btn_secondary_hover", "btn_secondary_pressed", "btn_disabled", Vector4(18.0, 18.0, 18.0, 18.0), font_size)


static func apply_sort_option(option: OptionButton, font_size := 12) -> void:
	if option == null:
		return
	option.add_theme_stylebox_override("normal", style("dropdown_panel", Vector4(18.0, 18.0, 18.0, 18.0)))
	option.add_theme_stylebox_override("hover", style("dropdown_panel", Vector4(18.0, 18.0, 18.0, 18.0)))
	option.add_theme_stylebox_override("pressed", style("dropdown_panel", Vector4(18.0, 18.0, 18.0, 18.0)))
	option.add_theme_stylebox_override("disabled", style("btn_disabled", Vector4(18.0, 18.0, 18.0, 18.0)))
	option.add_theme_color_override("font_color", TEXT_PRIMARY)
	option.add_theme_color_override("font_hover_color", TEXT_PRIMARY)
	option.add_theme_font_size_override("font_size", font_size)


static func apply_item_card(button: Button, selected: bool, font_size := 11) -> void:
	var normal := "slot_selected" if selected else "slot_normal"
	var hover := "slot_selected" if selected else "slot_hover"
	apply_button_states(button, normal, hover, "slot_selected", "slot_empty_locked", Vector4(22.0, 22.0, 22.0, 22.0), font_size)


static func apply_badge_label(label: Label, badge_name: String, font_size := 10) -> void:
	if label == null:
		return
	label.add_theme_stylebox_override("normal", style(badge_name, Vector4(16.0, 16.0, 16.0, 16.0)))
	label.add_theme_color_override("font_color", TEXT_PRIMARY)
	label.add_theme_font_size_override("font_size", font_size)


static func apply_chip_label(label: Label, font_size := 11) -> void:
	if label == null:
		return
	label.add_theme_stylebox_override("normal", style("small_input_panel", Vector4(16.0, 16.0, 16.0, 16.0)))
	label.add_theme_color_override("font_color", TEXT_GREEN)
	label.add_theme_font_size_override("font_size", font_size)


static func apply_details_panel(panel: Panel) -> void:
	apply_panel(panel, "details_panel", Vector4(26.0, 26.0, 26.0, 26.0), Vector4(14.0, 12.0, 14.0, 12.0))


static func apply_preview_panel(panel: Panel) -> void:
	apply_panel(panel, "preview_panel_wide", Vector4(20.0, 20.0, 20.0, 20.0), Vector4(10.0, 10.0, 10.0, 10.0))


static func apply_description_panel(panel: Panel) -> void:
	apply_panel(panel, "description_panel", Vector4(20.0, 20.0, 20.0, 20.0), Vector4(10.0, 10.0, 10.0, 10.0))


static func apply_action_button(button: Button, variant: String, font_size := 12) -> void:
	match variant:
		"primary":
			apply_button_states(button, "btn_primary_normal", "btn_primary_hover", "btn_primary_pressed", "btn_disabled", Vector4(18.0, 18.0, 18.0, 18.0), font_size)
		"danger":
			apply_button_states(button, "btn_danger_normal", "btn_danger_hover", "btn_danger_pressed", "btn_disabled", Vector4(18.0, 18.0, 18.0, 18.0), font_size)
		_:
			apply_button_states(button, "btn_secondary_normal", "btn_secondary_hover", "btn_secondary_pressed", "btn_disabled", Vector4(18.0, 18.0, 18.0, 18.0), font_size)


static func apply_pager_button(button: Button, active := false, font_size := 13) -> void:
	if active:
		apply_button_states(button, "page_active", "page_active", "page_active", "page_active", Vector4(18.0, 18.0, 18.0, 18.0), font_size)
	else:
		apply_button_states(button, "page_normal", "square_button_hover", "square_button_primary", "page_normal", Vector4(18.0, 18.0, 18.0, 18.0), font_size)


static func apply_square_button(button: Button, font_size := 16) -> void:
	apply_button_states(button, "square_button_normal", "square_button_hover", "square_button_primary", "square_button_normal", Vector4(18.0, 18.0, 18.0, 18.0), font_size)
