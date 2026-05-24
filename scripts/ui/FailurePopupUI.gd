# Non-blocking fishing failure notification.
extends RefCounted

var main
var theme
var panel: Panel
var title_label: Label
var message_label: Label
var hint_label: Label
var _hide_tween: Tween

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	_ensure_nodes()

func show(failure_data: Dictionary) -> void:
	_ensure_nodes()

	title_label.text = str(failure_data.get("title", "Неудачная попытка"))
	message_label.text = str(failure_data.get("message", "Рыба ушла."))
	hint_label.text = str(failure_data.get("hint", ""))
	hint_label.visible = hint_label.text != ""

	panel.visible = true
	panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	panel.move_to_front()

	if is_instance_valid(_hide_tween):
		_hide_tween.kill()
	_hide_tween = panel.create_tween()
	_hide_tween.tween_property(panel, "modulate:a", 1.0, 0.14)
	_hide_tween.tween_interval(4.0)
	_hide_tween.tween_property(panel, "modulate:a", 0.0, 0.22)
	_hide_tween.tween_callback(close)

func close() -> void:
	if is_instance_valid(_hide_tween):
		_hide_tween.kill()
	_hide_tween = null
	if panel != null:
		panel.visible = false

func is_open() -> bool:
	return panel != null and panel.visible

func _ensure_nodes() -> void:
	if panel != null:
		return

	var parent: Node = main.ui_canvas_layer if main.ui_canvas_layer != null else main

	panel = Panel.new()
	panel.name = "FailureNotification"
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = -205.0
	panel.offset_top = 88.0
	panel.offset_right = 205.0
	panel.offset_bottom = 170.0
	panel.z_index = main.MENU_PANEL_Z + 70
	theme.apply_popup_window_style(panel)
	parent.add_child(panel)

	var content := VBoxContainer.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 13.0
	content.offset_top = 9.0
	content.offset_right = -13.0
	content.offset_bottom = -9.0
	content.add_theme_constant_override("separation", 4)
	panel.add_child(content)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", Color(0.96, 1.0, 0.90, 1.0))
	title_label.clip_text = true
	content.add_child(title_label)

	message_label = Label.new()
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size = Vector2(0.0, 24.0)
	message_label.add_theme_font_size_override("font_size", 12)
	message_label.add_theme_color_override("font_color", Color(0.76, 0.86, 0.80, 0.90))
	content.add_child(message_label)

	hint_label = Label.new()
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.custom_minimum_size = Vector2(0.0, 22.0)
	hint_label.add_theme_font_size_override("font_size", 11)
	hint_label.add_theme_color_override("font_color", Color(0.62, 0.78, 0.66, 0.82))
	content.add_child(hint_label)
