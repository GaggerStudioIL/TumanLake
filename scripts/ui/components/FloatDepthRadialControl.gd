extends Control
class_name FloatDepthRadialControl

signal center_down
signal center_up
signal depth_changed(value: float)
signal depth_change_committed(value: float)

enum CastButtonState {
	READY_TO_CAST,
	CASTED_WAITING,
	HOOKED_REELING,
	DISABLED
}

const CAST_BUTTON_BASE := preload("res://assets/ui/cast_depth/cast_control_circle.png")
const CAST_BUTTON_HANDLE := preload("res://assets/ui/cast_depth/cast_control_pointstart.png")
const METER_FILL_SEGMENT_COUNT := 16
const METER_FILL_TEXTURES := [
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_00.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_01.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_02.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_03.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_04.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_05.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_06.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_07.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_08.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_09.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_10.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_11.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_12.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_13.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_14.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_15.png"),
	preload("res://assets/ui/cast_depth/meter_fill/cast_control_meter_fill_16.png")
]

const SOURCE_CANVAS_SIZE := Vector2(1171.0, 1171.0)
const HANDLE_SOURCE_RECT := Rect2(279.0, 787.0, 174.0, 189.0)
const HANDLE_SOURCE_CENTER := Vector2(362.0, 870.0)

@export var invert_depth_mapping := true
@export var min_depth := 0.2
@export var max_depth := 6.0
@export var depth_step := 0.1

var depth_value := 1.2
var hook_texture: Texture2D
var center_icon_texture: Texture2D
var draw_depth_text := true
var depth_adjust_enabled := true
var depth_controls_visible := true
var integer_value_display := false
var button_state: int = CastButtonState.READY_TO_CAST

var _dragging_depth := false
var _center_pointer_down := false
var _is_pressed_visual := false
var _arc_start_angle := deg_to_rad(128.0)
var _arc_end_angle := deg_to_rad(266.0)
var _arc_radius_ratio := 0.309


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	set_process(false)


func set_hook_texture(texture: Texture2D) -> void:
	hook_texture = texture
	queue_redraw()


func set_center_icon_texture(texture: Texture2D) -> void:
	center_icon_texture = texture
	queue_redraw()


func set_draw_depth_text(enabled: bool) -> void:
	draw_depth_text = enabled
	queue_redraw()


func set_integer_value_display(enabled: bool) -> void:
	integer_value_display = enabled
	queue_redraw()


func set_depth_controls_visible(enabled: bool) -> void:
	depth_controls_visible = enabled
	if not enabled:
		_dragging_depth = false
	queue_redraw()


func set_depth_adjust_enabled(enabled: bool) -> void:
	depth_adjust_enabled = enabled
	if not enabled:
		_dragging_depth = false
	queue_redraw()


func set_button_state(state: int) -> void:
	button_state = state
	if button_state == CastButtonState.DISABLED:
		_dragging_depth = false
		_center_pointer_down = false
	queue_redraw()


func set_pressed_visual(enabled: bool) -> void:
	_is_pressed_visual = enabled
	queue_redraw()


func cancel_press() -> void:
	_center_pointer_down = false
	_is_pressed_visual = false
	queue_redraw()


func set_depth_range(min_value: float, max_value: float) -> void:
	min_depth = minf(min_value, max_value)
	max_depth = maxf(min_value, max_value)
	set_depth_value(depth_value, false)


func set_depth_step(value: float) -> void:
	depth_step = maxf(value, 0.0)
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
	return _dragging_depth


func is_depth_gesture_global_point(global_point: Vector2) -> bool:
	return is_visible_in_tree() and is_depth_gesture_point(global_point - global_position)


func is_depth_gesture_point(point: Vector2) -> bool:
	if not depth_controls_visible or not depth_adjust_enabled:
		return false
	return _is_depth_handle_point(point)


func angle_to_depth(angle: float) -> float:
	var normalized := fposmod(angle, TAU)
	var clamped_angle := clampf(normalized, _arc_start_angle, _arc_end_angle)
	var ratio := (clamped_angle - _arc_start_angle) / maxf(_arc_end_angle - _arc_start_angle, 0.001)
	if invert_depth_mapping:
		ratio = 1.0 - ratio
	return lerpf(min_depth, max_depth, clampf(ratio, 0.0, 1.0))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if _handle_pointer_button(mouse_event.position, mouse_event.pressed):
			accept_event()
	elif event is InputEventMouseMotion:
		if _dragging_depth:
			_update_depth_from_point((event as InputEventMouseMotion).position)
			accept_event()
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if _handle_pointer_button(touch_event.position, touch_event.pressed):
			accept_event()
	elif event is InputEventScreenDrag:
		if _dragging_depth:
			_update_depth_from_point((event as InputEventScreenDrag).position)
			accept_event()


func _handle_pointer_button(point: Vector2, pressed: bool) -> bool:
	if pressed:
		_center_pointer_down = false
		if depth_adjust_enabled and is_depth_gesture_point(point):
			_dragging_depth = true
			_update_depth_from_point(point)
			return true
		if _is_center_action_point(point) and _is_center_action_enabled():
			_center_pointer_down = true
			_is_pressed_visual = true
			center_down.emit()
			queue_redraw()
			return true
		return false

	if _dragging_depth:
		_dragging_depth = false
		depth_change_committed.emit(depth_value)
		queue_redraw()
		return true

	if _center_pointer_down:
		_center_pointer_down = false
		_is_pressed_visual = false
		center_up.emit()
		queue_redraw()
		return true

	return false


func _draw() -> void:
	var rect := _get_visual_rect()
	if rect.size.x <= 1.0 or rect.size.y <= 1.0:
		return

	var control_alpha := 0.48 if button_state == CastButtonState.DISABLED else 1.0
	_draw_canvas_texture(CAST_BUTTON_BASE, rect, Color(1.0, 1.0, 1.0, control_alpha))
	if depth_controls_visible:
		_draw_meter_fill_layer(rect, control_alpha)
		_draw_depth_text_layer(rect, control_alpha)
		_draw_handle_layer(rect, control_alpha)
	if _is_pressed_visual:
		_draw_pressed_overlay(rect)


func _draw_canvas_texture(texture: Texture2D, rect: Rect2, tint: Color = Color.WHITE) -> void:
	if texture == null:
		return
	draw_texture_rect(texture, rect, false, tint)


func _draw_meter_fill_layer(rect: Rect2, control_alpha: float) -> void:
	var fill_texture := _get_meter_fill_texture()
	if fill_texture == null:
		return
	var alpha := (0.96 if depth_adjust_enabled else 0.55) * control_alpha
	draw_texture_rect(fill_texture, rect, false, Color(1.0, 1.0, 1.0, alpha))


func _get_meter_fill_texture() -> Texture2D:
	var depth_ratio := inverse_lerp(min_depth, max_depth, clampf(depth_value, min_depth, max_depth))
	var fill_index := floori(clampf(depth_ratio, 0.0, 1.0) * float(METER_FILL_SEGMENT_COUNT))
	return METER_FILL_TEXTURES[clampi(fill_index, 0, METER_FILL_SEGMENT_COUNT)]


func _draw_depth_text_layer(rect: Rect2, control_alpha: float) -> void:
	if not draw_depth_text:
		return

	var font := get_theme_default_font()
	var edge := rect.size.x
	var font_size := int(clampf(edge * 0.130, 16.0, 26.0))
	var text := str(roundi(depth_value)) if integer_value_display else "%.1f" % depth_value
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	var text_pos := rect.position + Vector2((edge - text_size.x) * 0.5, edge * 0.385)
	for shadow_offset in [Vector2(-1.0, 0.0), Vector2(1.0, 0.0), Vector2(0.0, -1.0), Vector2(0.0, 1.0), Vector2(1.0, 1.0)]:
		draw_string(font, text_pos + shadow_offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(0.0, 0.0, 0.0, 0.82 * control_alpha))
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(0.92, 1.0, 0.98, 0.98 * control_alpha))


func _draw_handle_layer(rect: Rect2, control_alpha: float) -> void:
	if CAST_BUTTON_HANDLE == null:
		return
	var scale := rect.size.x / SOURCE_CANVAS_SIZE.x
	var handle_pos := _get_handle_position()
	var source_offset := (HANDLE_SOURCE_CENTER - HANDLE_SOURCE_RECT.position) * scale
	var dest_rect := Rect2(handle_pos - source_offset, HANDLE_SOURCE_RECT.size * scale)
	var alpha := (1.0 if depth_adjust_enabled else 0.48) * control_alpha
	draw_texture_rect_region(CAST_BUTTON_HANDLE, dest_rect, HANDLE_SOURCE_RECT, Color(1.0, 1.0, 1.0, alpha))


func _draw_pressed_overlay(rect: Rect2) -> void:
	var center := _get_visual_center()
	var radius := rect.size.x * 0.225
	draw_circle(center, radius, Color(0.32, 0.95, 1.0, 0.10))
	draw_arc(center, radius, 0.0, TAU, 72, Color(0.78, 1.0, 0.95, 0.34), maxf(rect.size.x * 0.018, 2.0), true)


func _update_depth_from_point(point: Vector2) -> void:
	var center := _get_visual_center()
	var angle := atan2(point.y - center.y, point.x - center.x)
	update_depth_from_angle(angle, true)


func _depth_to_angle(value: float) -> float:
	var ratio := inverse_lerp(min_depth, max_depth, clampf(value, min_depth, max_depth))
	if invert_depth_mapping:
		ratio = 1.0 - ratio
	return lerpf(_arc_start_angle, _arc_end_angle, clampf(ratio, 0.0, 1.0))


func _is_center_action_point(point: Vector2) -> bool:
	var rect := _get_visual_rect()
	if rect.size.x <= 1.0:
		return false
	var hit_radius_ratio := 0.265 if depth_controls_visible and depth_adjust_enabled else 0.455
	return point.distance_to(_get_visual_center()) <= rect.size.x * hit_radius_ratio


func _is_center_action_enabled() -> bool:
	return button_state != CastButtonState.DISABLED


func _is_depth_handle_point(point: Vector2) -> bool:
	var rect := _get_visual_rect()
	if rect.size.x <= 1.0:
		return false
	var hit_radius := maxf(rect.size.x * 0.240, 28.0)
	return point.distance_to(_get_handle_position()) <= hit_radius


func _is_depth_arc_point(point: Vector2) -> bool:
	var rect := _get_visual_rect()
	if rect.size.x <= 1.0:
		return false
	var center := _get_visual_center()
	var vector := point - center
	var distance := vector.length()
	var radius := rect.size.x * _arc_radius_ratio
	var band_width := maxf(rect.size.x * 0.120, 18.0)
	var angle := fposmod(atan2(vector.y, vector.x), TAU)
	return distance >= radius - band_width and distance <= radius + band_width and angle >= _arc_start_angle and angle <= _arc_end_angle


func _snap_depth(value: float) -> float:
	if depth_step <= 0.0:
		return value
	return snappedf(value, depth_step)


func _get_visual_rect() -> Rect2:
	var edge := minf(size.x, size.y)
	return Rect2((size - Vector2(edge, edge)) * 0.5, Vector2(edge, edge))


func _get_visual_center() -> Vector2:
	var rect := _get_visual_rect()
	return rect.position + rect.size * 0.5


func _get_handle_position() -> Vector2:
	var rect := _get_visual_rect()
	var center := rect.position + rect.size * 0.5
	return center + Vector2(cos(_depth_to_angle(depth_value)), sin(_depth_to_angle(depth_value))) * (rect.size.x * _arc_radius_ratio)


func _get_center_icon_alpha() -> float:
	if button_state == CastButtonState.DISABLED:
		return 0.42
	if button_state == CastButtonState.CASTED_WAITING:
		return 0.72
	return 0.96
