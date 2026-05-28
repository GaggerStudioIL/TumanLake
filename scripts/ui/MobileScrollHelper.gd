# Adds mobile-style drag scrolling to regular ScrollContainer controls.
extends Node

const RESCAN_INTERVAL := 0.45
const DRAG_DEADZONE := 8.0
const MIN_INERTIA_SPEED := 90.0
const STOP_SPEED := 14.0
const FRICTION_PER_SECOND := 0.055

var root: Node
var _scrolls: Array[Control] = []
var _rescan_timer := 0.0

var _pressed := false
var _dragging := false
var _active_pointer := -1
var _drag_scroll: Control
var _press_position := Vector2.ZERO
var _last_position := Vector2.ZERO
var _last_msec := 0
var _velocity := Vector2.ZERO

var _inertia_scroll: Control
var _inertia_velocity := Vector2.ZERO


func setup(root_node: Node) -> void:
	root = root_node
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)
	set_process_input(true)
	refresh()


func refresh() -> void:
	_scrolls.clear()
	if root == null or not is_instance_valid(root):
		return
	_collect_scrolls(root)


func _collect_scrolls(node: Node) -> void:
	if node is ScrollContainer or node is ItemList:
		var scroll_control := node as Control
		_configure_scroll(scroll_control)
		_scrolls.append(scroll_control)
	for child in node.get_children():
		_collect_scrolls(child)


func _configure_scroll(scroll: Control) -> void:
	if scroll is ScrollContainer:
		var container := scroll as ScrollContainer
		container.clip_contents = true
		container.mouse_filter = Control.MOUSE_FILTER_PASS
	_style_scrollbar(_get_v_bar(scroll), true)
	_style_scrollbar(_get_h_bar(scroll), false)


func _style_scrollbar(bar: ScrollBar, vertical: bool) -> void:
	if bar == null:
		return
	bar.modulate = Color(0.68, 1.0, 0.86, 0.22)
	bar.mouse_filter = Control.MOUSE_FILTER_PASS
	if bar.has_meta("tuman_mobile_scrollbar"):
		return
	bar.set_meta("tuman_mobile_scrollbar", true)
	if vertical:
		bar.custom_minimum_size = Vector2(5.0, 0.0)
		bar.add_theme_constant_override("scroll_width", 5)
	else:
		bar.custom_minimum_size = Vector2(0.0, 5.0)
		bar.add_theme_constant_override("scroll_width", 5)

	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.02, 0.045, 0.042, 0.10)
	track.set_corner_radius_all(3)
	var grabber := StyleBoxFlat.new()
	grabber.bg_color = Color(0.60, 1.0, 0.82, 0.34)
	grabber.set_corner_radius_all(3)
	var grabber_hot := StyleBoxFlat.new()
	grabber_hot.bg_color = Color(0.74, 1.0, 0.90, 0.52)
	grabber_hot.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("scroll", track)
	bar.add_theme_stylebox_override("grabber", grabber)
	bar.add_theme_stylebox_override("grabber_highlight", grabber_hot)
	bar.add_theme_stylebox_override("grabber_pressed", grabber_hot)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_begin_press(touch.position, touch.index)
		elif _pressed and _active_pointer == touch.index:
			_end_press(touch.position)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if _pressed and _active_pointer == drag.index:
			_update_drag(drag.position)
	elif event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_button.pressed:
			_begin_press(mouse_button.position, -1)
		elif _pressed and _active_pointer == -1:
			_end_press(mouse_button.position)
	elif event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if _pressed and _active_pointer == -1 and (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			_update_drag(motion.position)


func _process(delta: float) -> void:
	_rescan_timer -= delta
	if _rescan_timer <= 0.0:
		_rescan_timer = RESCAN_INTERVAL
		refresh()

	_update_inertia(delta)


func _begin_press(position: Vector2, pointer_id: int) -> void:
	var scroll := _find_scroll_at(position)
	if scroll == null:
		return
	_pressed = true
	_dragging = false
	_active_pointer = pointer_id
	_drag_scroll = scroll
	_press_position = position
	_last_position = position
	_last_msec = Time.get_ticks_msec()
	_velocity = Vector2.ZERO
	if _inertia_scroll == scroll:
		_inertia_scroll = null
		_inertia_velocity = Vector2.ZERO


func _update_drag(position: Vector2) -> void:
	if _drag_scroll == null or not is_instance_valid(_drag_scroll):
		_reset_drag()
		return

	var total_delta := position - _press_position
	if not _dragging:
		if total_delta.length() < DRAG_DEADZONE:
			return
		if abs(total_delta.y) < abs(total_delta.x) and not _can_scroll_h(_drag_scroll):
			return
		if abs(total_delta.x) <= abs(total_delta.y) and not _can_scroll_v(_drag_scroll):
			return
		_dragging = true

	var delta := position - _last_position
	var now := Time.get_ticks_msec()
	var dt: float = maxf(float(now - _last_msec) / 1000.0, 1.0 / 120.0)
	_last_position = position
	_last_msec = now

	if _apply_drag_delta(_drag_scroll, delta):
		_velocity = _velocity.lerp(delta / dt, 0.55)
		get_viewport().set_input_as_handled()


func _end_press(_position: Vector2) -> void:
	if _dragging and _drag_scroll != null and is_instance_valid(_drag_scroll):
		if _velocity.length() >= MIN_INERTIA_SPEED:
			_inertia_scroll = _drag_scroll
			_inertia_velocity = _velocity
		get_viewport().set_input_as_handled()
	_reset_drag()


func _reset_drag() -> void:
	_pressed = false
	_dragging = false
	_active_pointer = -1
	_drag_scroll = null
	_velocity = Vector2.ZERO


func _update_inertia(delta: float) -> void:
	if _inertia_scroll == null or not is_instance_valid(_inertia_scroll) or not _inertia_scroll.is_visible_in_tree():
		_inertia_scroll = null
		_inertia_velocity = Vector2.ZERO
		return
	if _inertia_velocity.length() < STOP_SPEED:
		_inertia_scroll = null
		_inertia_velocity = Vector2.ZERO
		return

	var changed := _apply_drag_delta(_inertia_scroll, _inertia_velocity * delta)
	_inertia_velocity *= pow(FRICTION_PER_SECOND, delta)
	if not changed:
		_inertia_scroll = null
		_inertia_velocity = Vector2.ZERO


func _apply_drag_delta(scroll: Control, delta: Vector2) -> bool:
	var changed := false
	if abs(delta.y) > 0.01 and _can_scroll_v(scroll):
		var old_v := _get_scroll_v(scroll)
		var next_v := clampf(old_v - delta.y, 0.0, _max_scroll_v(scroll))
		_set_scroll_v(scroll, next_v)
		changed = changed or not is_equal_approx(_get_scroll_v(scroll), old_v)
	if abs(delta.x) > 0.01 and _can_scroll_h(scroll):
		var old_h := _get_scroll_h(scroll)
		var next_h := clampf(old_h - delta.x, 0.0, _max_scroll_h(scroll))
		_set_scroll_h(scroll, next_h)
		changed = changed or not is_equal_approx(_get_scroll_h(scroll), old_h)
	return changed


func _find_scroll_at(position: Vector2) -> Control:
	var best: Control
	var best_depth := -1
	for scroll in _scrolls:
		if scroll == null or not is_instance_valid(scroll) or not scroll.is_visible_in_tree():
			continue
		if not (_can_scroll_v(scroll) or _can_scroll_h(scroll)):
			continue
		if not scroll.get_global_rect().has_point(position):
			continue
		var depth := _node_depth(scroll)
		if depth >= best_depth:
			best = scroll
			best_depth = depth
	return best


func _node_depth(node: Node) -> int:
	var depth := 0
	var current := node
	while current != null:
		depth += 1
		current = current.get_parent()
	return depth


func _can_scroll_v(scroll: Control) -> bool:
	if scroll is ScrollContainer and (scroll as ScrollContainer).vertical_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED:
		return false
	return _max_scroll_v(scroll) > 0.5


func _can_scroll_h(scroll: Control) -> bool:
	if scroll is ScrollContainer and (scroll as ScrollContainer).horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED:
		return false
	return _max_scroll_h(scroll) > 0.5


func _max_scroll_v(scroll: Control) -> float:
	var bar := _get_v_bar(scroll)
	if bar == null:
		return 0.0
	return maxf(0.0, float(bar.max_value - bar.page))


func _max_scroll_h(scroll: Control) -> float:
	var bar := _get_h_bar(scroll)
	if bar == null:
		return 0.0
	return maxf(0.0, float(bar.max_value - bar.page))


func _get_scroll_v(scroll: Control) -> float:
	if scroll is ScrollContainer:
		return float((scroll as ScrollContainer).scroll_vertical)
	var bar := _get_v_bar(scroll)
	return float(bar.value) if bar != null else 0.0


func _set_scroll_v(scroll: Control, value: float) -> void:
	if scroll is ScrollContainer:
		(scroll as ScrollContainer).scroll_vertical = int(round(value))
		return
	var bar := _get_v_bar(scroll)
	if bar != null:
		bar.value = value


func _get_scroll_h(scroll: Control) -> float:
	if scroll is ScrollContainer:
		return float((scroll as ScrollContainer).scroll_horizontal)
	var bar := _get_h_bar(scroll)
	return float(bar.value) if bar != null else 0.0


func _set_scroll_h(scroll: Control, value: float) -> void:
	if scroll is ScrollContainer:
		(scroll as ScrollContainer).scroll_horizontal = int(round(value))
		return
	var bar := _get_h_bar(scroll)
	if bar != null:
		bar.value = value


func _get_v_bar(scroll: Control) -> ScrollBar:
	if scroll is ScrollContainer:
		return (scroll as ScrollContainer).get_v_scroll_bar()
	if scroll.has_method("get_v_scroll_bar"):
		return scroll.call("get_v_scroll_bar") as ScrollBar
	return null


func _get_h_bar(scroll: Control) -> ScrollBar:
	if scroll is ScrollContainer:
		return (scroll as ScrollContainer).get_h_scroll_bar()
	if scroll.has_method("get_h_scroll_bar"):
		return scroll.call("get_h_scroll_bar") as ScrollBar
	return null
