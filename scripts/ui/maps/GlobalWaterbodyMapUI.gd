extends Control

signal waterbody_selected(waterbody_id: String)
signal close_requested

const GLOBAL_MAP_ASSET := "res://assets/ui/maps/world_map_tumannye_vody.png"

var main
var waterbodies: Array = []
var marker_buttons: Array = []
var _has_world_map_texture := false

var background: ColorRect
var map_texture: TextureRect
var marker_layer: Control
var title_label: Label
var hint_label: Label
var close_button: Button
var info_panel: Panel
var info_title_label: Label
var info_region_label: Label
var info_status_label: Label
var info_description_label: Label

func setup(owner) -> void:
	main = owner
	_ensure_nodes()
	visible = false

func show_global(new_waterbodies: Array) -> void:
	_ensure_nodes()
	waterbodies = new_waterbodies.duplicate(true)
	visible = true
	_apply_map_texture()
	_rebuild_markers()
	layout_global()

func show_waterbody_info(waterbody: Dictionary, reason: String = "") -> void:
	_ensure_nodes()
	if waterbody.is_empty():
		return

	info_title_label.text = str(waterbody.get("name", "-"))
	info_region_label.text = str(waterbody.get("region", ""))
	info_status_label.text = _build_info_status(waterbody, reason)
	info_description_label.text = str(waterbody.get("description", ""))
	info_panel.visible = true
	layout_global()

func layout_global() -> void:
	if background == null:
		return

	var view_size: Vector2 = size
	background.position = Vector2.ZERO
	background.size = view_size
	map_texture.position = Vector2.ZERO
	map_texture.size = view_size
	marker_layer.position = Vector2.ZERO
	marker_layer.size = view_size

	var top_margin: float = maxf(12.0, view_size.y * 0.024)
	close_button.position = Vector2(view_size.x - 112.0, top_margin + 2.0)
	close_button.size = Vector2(94.0, 38.0)

	title_label.visible = not _has_world_map_texture
	hint_label.visible = not _has_world_map_texture
	if title_label.visible:
		title_label.position = Vector2(view_size.x * 0.5 - 220.0, top_margin)
		title_label.size = Vector2(440.0, 42.0)
		hint_label.position = Vector2(view_size.x * 0.5 - 260.0, top_margin + 48.0)
		hint_label.size = Vector2(520.0, 24.0)

	var map_rect := _get_drawn_map_rect(view_size)
	var hitbox_size: float = clampf(map_rect.size.x * 0.036, 38.0, 64.0)
	for button in marker_buttons:
		if button == null:
			continue
		var data = button.get_meta("waterbody_data", {})
		if not (data is Dictionary):
			continue
		var point := _get_waterbody_position(data as Dictionary)
		var target := map_rect.position + Vector2(map_rect.size.x * point.x, map_rect.size.y * point.y)
		button.position = target - Vector2(hitbox_size, hitbox_size) * 0.5
		button.size = Vector2(hitbox_size, hitbox_size)

	_layout_info_panel(view_size)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		layout_global()

func _ensure_nodes() -> void:
	if background != null:
		return

	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)

	background = ColorRect.new()
	background.name = "GlobalWaterbodyMapBackground"
	background.color = Color(0.010, 0.024, 0.026, 1.0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	map_texture = TextureRect.new()
	map_texture.name = "GlobalWaterbodyMapTexture"
	map_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	map_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_texture.modulate = Color(1.0, 1.0, 1.0, 1.0)
	add_child(map_texture)

	marker_layer = Control.new()
	marker_layer.name = "GlobalWaterbodyMarkerLayer"
	marker_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(marker_layer)

	title_label = Label.new()
	title_label.name = "GlobalWaterbodyMapTitle"
	title_label.text = "Водоёмы"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color(0.98, 0.94, 0.72, 1.0))
	add_child(title_label)

	hint_label = Label.new()
	hint_label.name = "GlobalWaterbodyHint"
	hint_label.text = "Выберите водоём, чтобы открыть его карту"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 15)
	hint_label.add_theme_color_override("font_color", Color(0.78, 0.95, 0.82, 0.92))
	add_child(hint_label)

	close_button = Button.new()
	close_button.name = "CloseGlobalWaterbodyMapButton"
	close_button.text = "Закрыть"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(func(): close_requested.emit())
	add_child(close_button)
	_apply_close_button_style(close_button)

	_create_info_panel()
	_apply_map_texture()

func _create_info_panel() -> void:
	info_panel = Panel.new()
	info_panel.name = "WaterbodyWorldInfoPanel"
	info_panel.visible = false
	info_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	info_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.025, 0.052, 0.048, 0.94), Color(0.78, 0.94, 0.72, 0.50), 8, 2))
	add_child(info_panel)

	info_title_label = Label.new()
	info_title_label.name = "WaterbodyWorldInfoTitle"
	info_title_label.add_theme_font_size_override("font_size", 20)
	info_title_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.56, 1.0))
	info_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info_panel.add_child(info_title_label)

	info_region_label = Label.new()
	info_region_label.name = "WaterbodyWorldInfoRegion"
	info_region_label.add_theme_font_size_override("font_size", 14)
	info_region_label.add_theme_color_override("font_color", Color(0.78, 0.96, 0.82, 0.95))
	info_region_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info_panel.add_child(info_region_label)

	info_status_label = Label.new()
	info_status_label.name = "WaterbodyWorldInfoStatus"
	info_status_label.add_theme_font_size_override("font_size", 14)
	info_status_label.add_theme_color_override("font_color", Color(0.94, 0.82, 0.56, 1.0))
	info_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info_panel.add_child(info_status_label)

	info_description_label = Label.new()
	info_description_label.name = "WaterbodyWorldInfoDescription"
	info_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_description_label.add_theme_font_size_override("font_size", 13)
	info_description_label.add_theme_color_override("font_color", Color(0.88, 0.95, 0.88, 0.92))
	info_panel.add_child(info_description_label)

func _apply_map_texture() -> void:
	var texture: Texture2D = null
	if ResourceLoader.exists(GLOBAL_MAP_ASSET) or FileAccess.file_exists(GLOBAL_MAP_ASSET):
		texture = load(GLOBAL_MAP_ASSET) as Texture2D

	_has_world_map_texture = texture != null
	map_texture.texture = texture
	map_texture.visible = _has_world_map_texture
	background.color = Color(0.010, 0.024, 0.026, 1.0) if _has_world_map_texture else Color(0.030, 0.060, 0.058, 1.0)

func _rebuild_markers() -> void:
	for button in marker_buttons:
		if button != null:
			button.queue_free()
	marker_buttons.clear()

	for waterbody in waterbodies:
		if not (waterbody is Dictionary):
			continue
		var data := (waterbody as Dictionary)
		var waterbody_id := str(data.get("id", ""))
		var button := Button.new()
		button.name = "WorldWaterbodyMarker_%s" % waterbody_id
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.text = ""
		button.flat = true
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.tooltip_text = _build_tooltip(data)
		button.set_meta("waterbody_data", data.duplicate(true))
		button.pressed.connect(_on_marker_pressed.bind(waterbody_id))
		marker_layer.add_child(button)
		_apply_marker_style(button, data)
		marker_buttons.append(button)

func _on_marker_pressed(waterbody_id: String) -> void:
	waterbody_selected.emit(waterbody_id)

func _get_waterbody_position(waterbody: Dictionary) -> Vector2:
	var raw_position = waterbody.get("world_map_position", waterbody.get("global_map_position", Vector2(0.5, 0.5)))
	if raw_position is Vector2:
		var point := raw_position as Vector2
		return Vector2(clampf(point.x, 0.0, 1.0), clampf(point.y, 0.0, 1.0))
	return Vector2(0.5, 0.5)

func _get_drawn_map_rect(view_size: Vector2) -> Rect2:
	if not _has_world_map_texture or map_texture.texture == null:
		return Rect2(Vector2.ZERO, view_size)

	var texture_size := Vector2(map_texture.texture.get_width(), map_texture.texture.get_height())
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Rect2(Vector2.ZERO, view_size)

	var scale_factor: float = minf(view_size.x / texture_size.x, view_size.y / texture_size.y)
	var drawn_size: Vector2 = texture_size * scale_factor
	var offset: Vector2 = (view_size - drawn_size) * 0.5
	return Rect2(offset, drawn_size)

func _layout_info_panel(view_size: Vector2) -> void:
	if info_panel == null or not info_panel.visible:
		return

	var panel_width: float = clampf(view_size.x * 0.30, 260.0, 380.0)
	var panel_height: float = clampf(view_size.y * 0.22, 128.0, 180.0)
	info_panel.size = Vector2(panel_width, panel_height)
	info_panel.position = Vector2(
		view_size.x - panel_width - maxf(14.0, view_size.x * 0.018),
		maxf(62.0, view_size.y * 0.105)
	)

	var padding := 14.0
	info_title_label.position = Vector2(padding, 10.0)
	info_title_label.size = Vector2(panel_width - padding * 2.0, 28.0)
	info_region_label.position = Vector2(padding, 40.0)
	info_region_label.size = Vector2(panel_width - padding * 2.0, 22.0)
	info_status_label.position = Vector2(padding, 63.0)
	info_status_label.size = Vector2(panel_width - padding * 2.0, 24.0)
	info_description_label.position = Vector2(padding, 92.0)
	info_description_label.size = Vector2(panel_width - padding * 2.0, maxf(panel_height - 102.0, 26.0))

func _build_tooltip(waterbody: Dictionary) -> String:
	return "%s\n%s\n%s" % [
		str(waterbody.get("name", "-")),
		str(waterbody.get("region", "")),
		_get_status_text(waterbody)
	]

func _build_info_status(waterbody: Dictionary, reason: String) -> String:
	if reason != "":
		return reason
	return "Статус: %s" % _get_status_text(waterbody)

func _get_status_text(waterbody: Dictionary) -> String:
	var waterbody_id := str(waterbody.get("id", ""))
	var status := str(waterbody.get("status", "locked"))
	if waterbody_id == PlayerData.current_waterbody and PlayerData.can_use_waterbody(waterbody_id):
		return "Текущий"
	if status == "open" and PlayerData.can_use_waterbody(waterbody_id):
		return "Открыто"
	if status == "beta_or_soon":
		return "Скоро / в разработке"
	return "Закрыто"

func _apply_marker_style(button: Button, _waterbody: Dictionary) -> void:
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 0.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 0.0))
	var hitbox_style := _make_marker_hitbox_style()
	button.add_theme_stylebox_override("normal", hitbox_style)
	button.add_theme_stylebox_override("hover", hitbox_style)
	button.add_theme_stylebox_override("pressed", hitbox_style)
	button.add_theme_stylebox_override("focus", hitbox_style)
	button.add_theme_stylebox_override("disabled", hitbox_style)

func _apply_close_button_style(button: Button) -> void:
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color(0.92, 1.0, 0.90, 1.0))
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.025, 0.050, 0.045, 0.88), Color(0.70, 0.95, 0.72, 0.48), 8, 2))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.060, 0.160, 0.100, 0.96), Color(0.86, 1.0, 0.76, 0.78), 8, 2))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.035, 0.105, 0.065, 0.98), Color(0.62, 0.92, 0.62, 0.82), 8, 2))

func _make_marker_hitbox_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 1.0, 1.0, 0.0)
	style.border_color = Color(1.0, 1.0, 1.0, 0.0)
	style.shadow_color = Color(1.0, 1.0, 1.0, 0.0)
	return style

func _make_panel_style(fill: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.34)
	style.shadow_size = 8
	return style
