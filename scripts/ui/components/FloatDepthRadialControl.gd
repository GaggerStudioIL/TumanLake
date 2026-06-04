class_name FloatDepthRadialControl
extends Control

signal depth_changed(value: float)
signal depth_change_committed(value: float)

@export var invert_depth_mapping := false
@export var min_depth := 0.2
@export var max_depth := 6.0
@export var depth_step := 0.1

var depth_value := 1.2
var hook_texture: Texture2D
var draw_depth_text := true

var _dragging := false
var _arc_top_angle := deg_to_rad(228.0)
var _arc_bottom_angle := deg_to_rad(132.0)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	set_process(false)


func set_hook_texture(texture: Texture2D) -> void:
	hook_texture = texture
	queue_redraw()


func set_draw_depth_text(enabled: bool) -> void:
	draw_depth_text = enabled
	queue_redraw()


func set_depth_range(min_value: float, max_value: float) -> void:
	min_depth = minf(min_value, max_value)
	max_depth = maxf(min_value, max_value)
	set_depth_value(depth_value, false)


func set_depth_value(value: float, emit_update := false) -> void:
	var previous := depth_value
	depth_value = _snap_depth(clampf(value, min_depth, max_depth))
	update_depth_display()
	refresh_depth_visual()
	if emit_update and not is_equal_approx(previous, depth_value):
		depth_changed.emit(depth_value)


func update_depth_display() -> void:
	queue_redraw()


func refresh_depth_visual() -> void:
	queue_redraw()


func update_depth_from_angle(angle: float, emit_update := true) -> void:
	set_depth_value(angle_to_depth(angle), emit_update)


func is_adjusting_depth() -> bool:
	return _dragging


func is_depth_gesture_global_point(global_point: Vector2) -> bool:
	return is_visible_in_tree() and is_depth_gesture_point(global_point - global_position)


func is_depth_gesture_point(point: Vector2) -> bool:
	var edge := minf(size.x, size.y)
	if edge <= 1.0:
		return false
	var center := _get_visual_center(edge)
	var vector := point - center
	var distance := vector.length()
	var radius := edge * 0.43
	var band_width := maxf(edge * 0.15, 18.0)
	var angle := fposmod(atan2(vector.y, vector.x), TAU)
	return distance >= radius - band_width and distance <= radius + band_width and _is_angle_in_depth_arc(angle)


func angle_to_depth(angle: float) -> float:
	var normalized := fposmod(angle, TAU)
	var clamped_angle := clampf(normalized, _arc_bottom_angle, _arc_top_angle)
	var ratio := (_arc_top_angle - clamped_angle) / maxf(_arc_top_angle - _arc_bottom_angle, 0.001)
	if invert_depth_mapping:
		ratio = 1.0 - ratio
	return lerpf(min_depth, max_depth, clampf(ratio, 0.0, 1.0))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_event.pressed:
			if _is_interaction_point(mouse_event.position):
				_dragging = true
				_update_depth_from_point(mouse_event.position)
				accept_event()
		elif _dragging:
			_dragging = false
			depth_change_committed.emit(depth_value)
			accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_update_depth_from_point((event as InputEventMouseMotion).position)
		accept_event()
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			if _is_interaction_point(touch_event.position):
				_dragging = true
				_update_depth_from_point(touch_event.position)
				accept_event()
		elif _dragging:
			_dragging = false
			depth_change_committed.emit(depth_value)
			accept_event()
	elif event is InputEventScreenDrag and _dragging:
		_update_depth_from_point((event as InputEventScreenDrag).position)
		accept_event()


func _draw() -> void:
	var edge := minf(size.x, size.y)
	if edge <= 1.0:
		return

	var center := _get_visual_center(edge)
	var radius := edge * 0.43
	var inner_radius := edge * 0.315
	var ring_width := maxf(edge * 0.075, 7.0)

	draw_circle(center, radius + ring_width * 0.42, Color(0.0, 0.0, 0.0, 0.22))
	draw_circle(center, inner_radius, Color(0.020, 0.042, 0.046, 0.68))
	_draw_hook_icon(center + Vector2(edge * 0.006, edge * 0.085), edge)
	draw_arc(center, radius, _arc_bottom_angle, _arc_top_angle, 44, Color(0.92, 1.0, 0.96, 0.28), maxf(ring_width * 0.46, 3.0), true)
	draw_arc(center, radius, _arc_bottom_angle, _arc_top_angle, 44, Color(1.0, 1.0, 1.0, 0.96), ring_width, true)
	draw_arc(center, inner_radius, 0.0, TAU, 72, Color(0.78, 0.94, 0.90, 0.62), maxf(edge * 0.014, 1.5), true)

	var knob_angle := _depth_to_angle(depth_value)
	var knob_pos := center + Vector2(cos(knob_angle), sin(knob_angle)) * radius
	draw_circle(knob_pos, maxf(edge * 0.052, 6.0), Color(1.0, 1.0, 1.0, 0.98))
	draw_circle(knob_pos, maxf(edge * 0.030, 3.5), Color(0.18, 0.28, 0.28, 0.92))

	_draw_wave_icon(center + Vector2(0.0, -edge * 0.145), edge)
	if draw_depth_text:
		_draw_depth_text(center, edge)


func _update_depth_from_point(point: Vector2) -> void:
	var edge := minf(size.x, size.y)
	var center := _get_visual_center(edge)
	var angle := atan2(point.y - center.y, point.x - center.x)
	update_depth_from_angle(angle, true)


func _depth_to_angle(value: float) -> float:
	var ratio := inverse_lerp(min_depth, max_depth, clampf(value, min_depth, max_depth))
	if invert_depth_mapping:
		ratio = 1.0 - ratio
	return lerpf(_arc_top_angle, _arc_bottom_angle, clampf(ratio, 0.0, 1.0))


func _is_interaction_point(point: Vector2) -> bool:
	return is_depth_gesture_point(point)


func _is_angle_in_depth_arc(angle: float) -> bool:
	return angle >= _arc_bottom_angle and angle <= _arc_top_angle


func _snap_depth(value: float) -> float:
	if depth_step <= 0.0:
		return value
	return snappedf(value, depth_step)


func _get_visual_center(edge: float) -> Vector2:
	return Vector2(size.x * 0.5, edge * 0.5)


func _draw_depth_text(center: Vector2, edge: float) -> void:
	var font := get_theme_default_font()
	var font_size := int(clamp(edge * 0.155, 16.0, 22.0))
	var text := "%.1f м" % depth_value
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	var pos := center + Vector2(-text_size.x * 0.5, edge * 0.680)
	draw_string(font, pos + Vector2(1.0, 1.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(0.0, 0.0, 0.0, 0.70))
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(0.95, 1.0, 0.92, 1.0))


func _draw_wave_icon(center: Vector2, edge: float) -> void:
	var width := edge * 0.20
	var amplitude := edge * 0.014
	var color := Color(0.84, 1.0, 0.95, 0.92)
	for row in range(2):
		var points := PackedVector2Array()
		var y_offset := float(row) * edge * 0.036
		for i in range(18):
			var t := float(i) / 17.0
			var x := center.x - width * 0.5 + width * t
			var y := center.y + y_offset + sin(t * TAU * 1.25) * amplitude
			points.append(Vector2(x, y))
		draw_polyline(points, color, maxf(edge * 0.014, 1.4), true)


func _draw_hook_icon(center: Vector2, edge: float) -> void:
	if hook_texture != null:
		var texture_size := hook_texture.get_size()
		var aspect := texture_size.x / maxf(texture_size.y, 1.0)
		var icon_height := clampf(edge * 0.245, 24.0, 34.0)
		var icon_size := Vector2(icon_height * aspect, icon_height)
		draw_texture_rect(hook_texture, Rect2(center - icon_size * 0.5, icon_size), false, Color(0.96, 1.0, 0.96, 0.82))
		return

	var scale := edge / 128.0
	var points := PackedVector2Array([
		center + Vector2(0.0, -42.0) * scale,
		center + Vector2(0.0, 22.0) * scale,
		center + Vector2(-20.0, 38.0) * scale,
		center + Vector2(-38.0, 18.0) * scale,
		center + Vector2(-24.0, 0.0) * scale
	])
	draw_polyline(points, Color(0.96, 1.0, 0.96, 0.84), maxf(9.0 * scale, 5.0), true)
