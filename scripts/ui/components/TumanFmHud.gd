extends Control

const BASE_SIZE := Vector2(124.0, 34.0)
const BASE_MENU_SIZE := Vector2(62.0, 54.0)

var main
var panel: Panel
var status_label: Label
var _radio_manager: Node
var _pulse_tween: Tween


func setup(main_ref) -> void:
	main = main_ref
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 116
	_ensure_nodes()
	_connect_radio_manager()
	refresh()


func layout(screen_size: Vector2) -> void:
	_ensure_nodes()
	var sx: float = screen_size.x / 960.0
	var sy: float = screen_size.y / 540.0
	var ui_scale: float = clampf(min(sx, sy), 0.88, 1.18)
	var margin_x: float = clampf(24.0 * sx, 18.0, 30.0)
	var margin_y: float = clampf(18.0 * sy, 14.0, 24.0)
	var menu_size := Vector2(
		clampf(BASE_MENU_SIZE.x * ui_scale, 56.0, 68.0),
		clampf(BASE_MENU_SIZE.y * ui_scale, 48.0, 58.0)
	)
	var indicator_size := Vector2(
		clampf(BASE_SIZE.x * ui_scale, 112.0, 138.0),
		clampf(BASE_SIZE.y * ui_scale, 30.0, 38.0)
	)

	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2(
		screen_size.x - margin_x - indicator_size.x,
		margin_y + menu_size.y + 8.0 * ui_scale
	)
	size = indicator_size
	custom_minimum_size = indicator_size

	panel.position = Vector2.ZERO
	panel.size = indicator_size
	status_label.position = Vector2(10.0 * ui_scale, 0.0)
	status_label.size = Vector2(indicator_size.x - 20.0 * ui_scale, indicator_size.y)
	status_label.add_theme_font_size_override("font_size", int(clampf(14.0 * ui_scale, 13.0, 16.0)))


func refresh() -> void:
	_connect_radio_manager()
	var enabled := false
	var broadcasting := false
	if _radio_manager != null:
		if _radio_manager.has_method("is_radio_enabled"):
			enabled = bool(_radio_manager.call("is_radio_enabled"))
		else:
			enabled = bool(_radio_manager.get("radio_enabled"))
		if _radio_manager.has_method("is_broadcasting"):
			broadcasting = bool(_radio_manager.call("is_broadcasting"))

	visible = enabled
	_apply_broadcast_state(broadcasting, "Радиоэфир" if broadcasting else "Tuman FM")


func _ensure_nodes() -> void:
	if panel == null:
		panel = Panel.new()
		panel.name = "TumanFmHudPanel"
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(panel)

	if status_label == null:
		status_label = Label.new()
		status_label.name = "TumanFmStatusLabel"
		status_label.text = "Tuman FM"
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		status_label.clip_text = true
		status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(status_label)


func _connect_radio_manager() -> void:
	var manager := _get_radio_manager()
	if manager == null or manager == _radio_manager:
		return
	_radio_manager = manager

	if _radio_manager.has_signal("radio_state_changed"):
		var radio_callable := Callable(self, "_on_radio_state_changed")
		if not _radio_manager.is_connected("radio_state_changed", radio_callable):
			_radio_manager.connect("radio_state_changed", radio_callable)
	if _radio_manager.has_signal("broadcast_state_changed"):
		var broadcast_callable := Callable(self, "_on_broadcast_state_changed")
		if not _radio_manager.is_connected("broadcast_state_changed", broadcast_callable):
			_radio_manager.connect("broadcast_state_changed", broadcast_callable)


func _get_radio_manager() -> Node:
	if main != null and main is Node:
		return (main as Node).get_node_or_null("/root/RadioManager")
	return get_node_or_null("/root/RadioManager")


func _on_radio_state_changed(enabled: bool) -> void:
	visible = enabled
	if enabled:
		_apply_broadcast_state(false, "Tuman FM")
	else:
		_stop_pulse()


func _on_broadcast_state_changed(active: bool, status_text: String) -> void:
	_apply_broadcast_state(active, status_text)


func _apply_broadcast_state(active: bool, status_text: String) -> void:
	if status_label == null or panel == null:
		return

	status_label.text = status_text if status_text != "" else ("Радиоэфир" if active else "Tuman FM")
	if active:
		_apply_panel_style(Color(0.075, 0.118, 0.105, 0.88), Color(1.0, 0.82, 0.40, 0.54))
		status_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.68, 1.0))
		_start_pulse()
	else:
		_apply_panel_style(Color(0.022, 0.044, 0.048, 0.74), Color(0.72, 0.96, 0.86, 0.26))
		status_label.add_theme_color_override("font_color", Color(0.88, 1.0, 0.94, 0.96))
		_stop_pulse()


func _start_pulse() -> void:
	if _pulse_tween != null and _pulse_tween.is_valid():
		return
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	_pulse_tween = create_tween()
	_pulse_tween.set_loops()
	_pulse_tween.tween_property(self, "modulate:a", 0.72, 0.58).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(self, "modulate:a", 1.0, 0.58).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _stop_pulse() -> void:
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_pulse_tween = null
	modulate = Color(1.0, 1.0, 1.0, 1.0)


func _apply_panel_style(bg_color: Color, border_color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.shadow_size = 4
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.18)
	style.content_margin_left = 8.0
	style.content_margin_top = 4.0
	style.content_margin_right = 8.0
	style.content_margin_bottom = 4.0
	panel.add_theme_stylebox_override("panel", style)
