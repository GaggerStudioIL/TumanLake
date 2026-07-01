extends Control

signal spot_pressed(waterbody_id: String, spot_id: String)
signal info_pressed(waterbody_id: String, spot_id: String)

var waterbody_id := ""
var spot_id := ""
var spot_data: Dictionary = {}
var unlocked := true
var current := false
var selected := false
var baked_map_controls := false
var map_order := 0

var marker_button: Button
var info_button: Button
var lock_badge: Label
var current_label: Label

const BAKED_INFO_TOUCH_MIN_SIZE := 72.0
const BAKED_INFO_TOUCH_MAX_SIZE := 98.0
const BAKED_INFO_TOUCH_SCALE := 2.7
const TAP_DRAG_THRESHOLD := 14.0

var _current_arrow_start := Vector2.ZERO
var _current_arrow_tip := Vector2.ZERO
var _current_marker_position := Vector2.ZERO
var _current_marker_radius := 0.0
var _tap_tracking := false
var _tap_cancelled := false
var _tap_press_position := Vector2.ZERO

func set_baked_map_controls(value: bool) -> void:
	baked_map_controls = value
	if marker_button != null:
		_refresh_state()

func set_selected(value: bool) -> void:
	selected = value
	if marker_button != null:
		_refresh_state()
		queue_redraw()

func setup_marker(new_waterbody_id: String, new_spot: Dictionary, is_unlocked: bool, is_current: bool) -> void:
	waterbody_id = new_waterbody_id
	spot_data = new_spot.duplicate(true)
	spot_id = str(spot_data.get("id", ""))
	map_order = int(spot_data.get("map_order", 0))
	unlocked = is_unlocked
	current = is_current
	_ensure_nodes()
	_refresh_state()

func layout_marker(map_rect: Rect2, marker_size: float, info_size: float) -> void:
	position = map_rect.position
	size = map_rect.size

	var marker_position := _get_normalized_position("map_position", Vector2(0.5, 0.5)) * map_rect.size
	var info_position := _get_normalized_position("info_position", _get_default_info_position()) * map_rect.size
	_current_marker_position = marker_position
	_current_marker_radius = marker_size * 0.5
	if baked_map_controls:
		var marker_hitbox_edge := clampf(marker_size * 0.95, 42.0, 58.0)
		var marker_hitbox_size := Vector2(marker_hitbox_edge, marker_hitbox_edge)
		marker_button.position = marker_position + Vector2(0.0, marker_size * 0.28) - marker_hitbox_size * 0.5
		marker_button.size = marker_hitbox_size
	else:
		var marker_edge := clampf(marker_size, 72.0, 84.0)
		var marker_hitbox_size := Vector2(marker_edge, marker_edge)
		marker_button.position = marker_position - marker_hitbox_size * 0.5
		marker_button.size = marker_hitbox_size
	lock_badge.position = marker_button.position + Vector2(marker_button.size.x - 25.0, -2.0)
	lock_badge.size = Vector2(27.0, 20.0)
	var info_hitbox_size := Vector2(info_size, info_size)
	if baked_map_controls:
		var info_hitbox_edge := clampf(info_size * BAKED_INFO_TOUCH_SCALE, BAKED_INFO_TOUCH_MIN_SIZE, BAKED_INFO_TOUCH_MAX_SIZE)
		info_hitbox_size = Vector2(info_hitbox_edge, info_hitbox_edge)
	info_button.position = info_position - info_hitbox_size * 0.5
	info_button.size = info_hitbox_size
	_layout_current_indicator(marker_position, marker_size)
	queue_redraw()

func _ensure_nodes() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = false

	if marker_button == null:
		marker_button = Button.new()
		marker_button.name = "MarkerButton"
		marker_button.focus_mode = Control.FOCUS_NONE
		marker_button.mouse_filter = Control.MOUSE_FILTER_PASS
		marker_button.text = ""
		marker_button.z_index = 0
		add_child(marker_button)
		marker_button.gui_input.connect(_on_marker_button_gui_input)
		marker_button.pressed.connect(_on_marker_pressed)

	if info_button == null:
		info_button = Button.new()
		info_button.name = "InfoButton"
		info_button.focus_mode = Control.FOCUS_NONE
		info_button.mouse_filter = Control.MOUSE_FILTER_STOP
		info_button.text = "i"
		info_button.z_index = 30
		add_child(info_button)
		info_button.pressed.connect(_on_info_pressed)

	if lock_badge == null:
		lock_badge = Label.new()
		lock_badge.name = "LockBadge"
		lock_badge.text = "🔒"
		lock_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lock_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lock_badge.z_index = 20
		add_child(lock_badge)

	if current_label == null:
		current_label = Label.new()
		current_label.name = "CurrentLocationLabel"
		current_label.text = "Вы тут"
		current_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		current_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		current_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		current_label.visible = false
		current_label.z_index = 20
		add_child(current_label)

func _refresh_state() -> void:
	var spot_name := str(spot_data.get("name", spot_id))
	marker_button.tooltip_text = spot_name
	info_button.tooltip_text = "Информация: %s" % spot_name
	lock_badge.visible = not unlocked and not baked_map_controls
	current_label.visible = current and not baked_map_controls
	z_index = 10 if selected else (6 if current else 0)

	var transparent_style := _make_transparent_style()
	if baked_map_controls:
		# The legacy map already contains marker art, so these controls are only touch targets.
		marker_button.text = ""
		marker_button.add_theme_stylebox_override("normal", transparent_style)
		marker_button.add_theme_stylebox_override("hover", transparent_style)
		marker_button.add_theme_stylebox_override("pressed", transparent_style)
		marker_button.add_theme_stylebox_override("disabled", transparent_style)
		marker_button.add_theme_font_size_override("font_size", 1)
		marker_button.add_theme_color_override("font_color", Color.TRANSPARENT)
		info_button.text = ""
		info_button.visible = true
		info_button.add_theme_font_size_override("font_size", 1)
		info_button.add_theme_color_override("font_color", Color.TRANSPARENT)
		info_button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
		info_button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
		info_button.add_theme_stylebox_override("normal", transparent_style)
		info_button.add_theme_stylebox_override("hover", transparent_style)
		info_button.add_theme_stylebox_override("pressed", transparent_style)
		info_button.add_theme_stylebox_override("disabled", transparent_style)
	else:
		var label := str(map_order) if map_order > 0 else ""
		marker_button.text = label
		marker_button.disabled = false
		marker_button.add_theme_font_size_override("font_size", 22 if label.length() <= 1 else 19)
		marker_button.add_theme_color_override("font_color", Color(1.0, 0.90, 0.58, 1.0) if unlocked else Color(0.78, 0.72, 0.62, 0.82))
		marker_button.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 0.72, 1.0))
		marker_button.add_theme_color_override("font_pressed_color", Color(1.0, 0.82, 0.38, 1.0))
		marker_button.add_theme_color_override("font_disabled_color", Color(0.58, 0.58, 0.54, 0.70))
		var base_fill := Color(0.055, 0.045, 0.030, 0.96) if unlocked else Color(0.030, 0.032, 0.030, 0.72)
		var base_border := Color(1.0, 0.74, 0.30, 0.95) if selected or current else Color(0.78, 0.58, 0.28, 0.88)
		var base_shadow := Color(1.0, 0.65, 0.20, 0.34) if selected else Color(0.0, 0.0, 0.0, 0.40)
		marker_button.add_theme_stylebox_override("normal", _make_circle_style(base_fill, base_border, 3, 12 if selected else 6, base_shadow))
		marker_button.add_theme_stylebox_override("hover", _make_circle_style(Color(0.105, 0.080, 0.038, 1.0), Color(1.0, 0.86, 0.44, 1.0), 4, 14, Color(1.0, 0.70, 0.20, 0.38)))
		marker_button.add_theme_stylebox_override("pressed", _make_circle_style(Color(0.035, 0.030, 0.022, 0.98), Color(1.0, 0.64, 0.22, 1.0), 2, 8, Color(1.0, 0.58, 0.16, 0.30)))
		marker_button.add_theme_stylebox_override("disabled", _make_circle_style(Color(0.030, 0.032, 0.030, 0.66), Color(0.50, 0.44, 0.34, 0.56), 2, 4, Color(0.0, 0.0, 0.0, 0.28)))
		info_button.visible = false

	lock_badge.add_theme_font_size_override("font_size", 12)
	lock_badge.add_theme_color_override("font_color", Color(1.0, 0.86, 0.58, 1.0))
	lock_badge.add_theme_stylebox_override("normal", _make_circle_style(Color(0.15, 0.08, 0.05, 0.94), Color(1.0, 0.74, 0.36, 0.86), 1, 4, Color(0.0, 0.0, 0.0, 0.36)))

	current_label.add_theme_font_size_override("font_size", 13)
	current_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.70, 1.0))
	current_label.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.01, 0.92))
	current_label.add_theme_constant_override("outline_size", 2)
	current_label.add_theme_stylebox_override("normal", _make_current_label_style())

func _draw() -> void:
	if baked_map_controls:
		return
	if not current or current_label == null or not current_label.visible:
		return

	var arrow_color := Color(1.0, 0.78, 0.28, 0.92)
	var shadow_color := Color(0.0, 0.0, 0.0, 0.44)

	if _current_arrow_start.distance_squared_to(_current_arrow_tip) <= 1.0:
		return

	draw_line(_current_arrow_start + Vector2(1.5, 2.0), _current_arrow_tip + Vector2(1.5, 2.0), shadow_color, 4.0, true)
	draw_line(_current_arrow_start, _current_arrow_tip, arrow_color, 2.4, true)
	_draw_arrow_head(_current_arrow_tip + Vector2(1.5, 2.0), _current_arrow_start + Vector2(1.5, 2.0), shadow_color)
	_draw_arrow_head(_current_arrow_tip, _current_arrow_start, arrow_color)

func _layout_current_indicator(marker_position: Vector2, marker_size: float) -> void:
	if current_label == null:
		return

	current_label.visible = current and not baked_map_controls
	if not current or baked_map_controls:
		return

	var label_size := Vector2(clampf(marker_size * 1.52, 66.0, 84.0), clampf(marker_size * 0.52, 22.0, 28.0))
	var margin := maxf(8.0, marker_size * 0.16)
	var side := 1.0 if marker_position.x < size.x * 0.70 else -1.0
	var label_x := marker_position.x + marker_size * 0.34 if side > 0.0 else marker_position.x - marker_size * 0.34 - label_size.x
	var label_y := marker_position.y - marker_size * 0.90 - label_size.y
	var label_above := label_y >= margin
	if not label_above:
		label_y = marker_position.y + marker_size * 0.66

	label_x = clampf(label_x, margin, maxf(margin, size.x - label_size.x - margin))
	label_y = clampf(label_y, margin, maxf(margin, size.y - label_size.y - margin))
	current_label.position = Vector2(label_x, label_y)
	current_label.size = label_size

	var label_anchor_x := label_x + (label_size.x * 0.18 if side > 0.0 else label_size.x * 0.82)
	var label_anchor_y := label_y + (label_size.y if label_above else 0.0)
	_current_arrow_start = Vector2(label_anchor_x, label_anchor_y)
	_current_arrow_tip = marker_position + Vector2(side * marker_size * 0.22, -marker_size * 0.12 if label_above else marker_size * 0.18)

func _draw_arrow_head(tip: Vector2, from: Vector2, color: Color) -> void:
	var direction := tip - from
	if direction.length_squared() <= 0.01:
		return
	direction = direction.normalized()
	var normal := Vector2(-direction.y, direction.x)
	var head_length := 9.0
	var head_width := 5.5
	var points := PackedVector2Array([
		tip,
		tip - direction * head_length + normal * head_width,
		tip - direction * head_length - normal * head_width
	])
	draw_colored_polygon(points, color)

func _get_normalized_position(key: String, fallback: Vector2) -> Vector2:
	var value = spot_data.get(key, fallback)
	if value is Vector2:
		var point := value as Vector2
		return Vector2(clampf(point.x, 0.0, 1.0), clampf(point.y, 0.0, 1.0))
	return fallback

func _get_default_info_position() -> Vector2:
	var marker_position := _get_normalized_position("map_position", Vector2(0.5, 0.5))
	return Vector2(clampf(marker_position.x + 0.035, 0.04, 0.96), clampf(marker_position.y - 0.040, 0.04, 0.96))

func _make_circle_style(fill: Color, border: Color, border_width: int, shadow_size: int = 5, shadow_color: Color = Color(0.0, 0.0, 0.0, 0.32)) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 64
	style.corner_radius_top_right = 64
	style.corner_radius_bottom_left = 64
	style.corner_radius_bottom_right = 64
	style.shadow_color = shadow_color
	style.shadow_size = shadow_size
	return style

func _make_transparent_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	style.border_color = Color(0.0, 0.0, 0.0, 0.0)
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	return style

func _make_current_label_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.045, 0.018, 0.88)
	style.border_color = Color(1.0, 0.78, 0.30, 0.86)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.40)
	style.shadow_size = 4
	return style

func _on_marker_pressed() -> void:
	if _tap_cancelled:
		_tap_tracking = false
		_tap_cancelled = false
		return
	spot_pressed.emit(waterbody_id, spot_id)

func _on_info_pressed() -> void:
	info_pressed.emit(waterbody_id, spot_id)

func _on_marker_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_event.pressed:
			_tap_tracking = true
			_tap_cancelled = false
			_tap_press_position = mouse_event.position
		else:
			_tap_tracking = false
	elif event is InputEventMouseMotion and _tap_tracking:
		var motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		if motion_event.position.distance_to(_tap_press_position) > TAP_DRAG_THRESHOLD:
			_tap_cancelled = true
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			_tap_tracking = true
			_tap_cancelled = false
			_tap_press_position = touch_event.position
		else:
			_tap_tracking = false
	elif event is InputEventScreenDrag and _tap_tracking:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		if drag_event.position.distance_to(_tap_press_position) > TAP_DRAG_THRESHOLD:
			_tap_cancelled = true
