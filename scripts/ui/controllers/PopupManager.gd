# Shows small game notifications while keeping toast animation out of Main.gd.
extends RefCounted

var main
var _toast_tween: Tween


func setup(main_ref) -> void:
	main = main_ref


func show_info(title: String, text: String = "") -> void:
	_show_message(_compose_message(title, text), true)


func show_success(title: String, text: String = "") -> void:
	_show_message(_compose_message(title, text), true)


func show_warning(title: String, text: String = "") -> void:
	_show_message(_compose_message(title, text), false)


func show_error(title: String, text: String = "") -> void:
	_show_message(_compose_message(title, text), false)


func show_toast(message: String, success: bool = true) -> void:
	_show_message(message, success)


func clear() -> void:
	if is_instance_valid(_toast_tween):
		_toast_tween.kill()
	_toast_tween = null
	if main != null and main.toast_label != null:
		main.toast_label.visible = false


func layout(screen_size: Vector2, margin: float) -> void:
	if main == null or main.toast_label == null:
		return

	var toast_width: float = min(screen_size.x - margin * 4.0, 520.0)
	main.toast_label.position = Vector2((screen_size.x - toast_width) * 0.5, screen_size.y - 132.0)
	main.toast_label.size = Vector2(toast_width, 64.0)
	main.toast_label.z_index = 220
	main.toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.toast_label.add_theme_font_size_override("font_size", 14)
	main.toast_label.add_theme_color_override("font_color", Color(0.90, 1.0, 0.90, 1.0))
	main.toast_label.add_theme_stylebox_override(
		"normal",
		main._make_panel_style(Color(0.045, 0.105, 0.086, 0.92), Color(0.68, 1.0, 0.76, 0.36), 18, 10, Color(0.0, 0.0, 0.0, 0.24))
	)


func _show_message(message: String, success: bool) -> void:
	if main == null or main.toast_label == null or message == "":
		return

	if is_instance_valid(_toast_tween):
		_toast_tween.kill()

	main.toast_label.text = message
	main.toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.toast_label.visible = true
	main.toast_label.modulate = Color(0.78, 1.0, 0.78, 0.0) if success else Color(1.0, 0.68, 0.58, 0.0)

	_toast_tween = main.create_tween()
	_toast_tween.tween_property(main.toast_label, "modulate:a", 1.0, 0.12)
	_toast_tween.tween_interval(2.1)
	_toast_tween.tween_property(main.toast_label, "modulate:a", 0.0, 0.28)
	_toast_tween.tween_callback(func() -> void:
		if main != null and main.toast_label != null:
			main.toast_label.visible = false
	)


func _compose_message(title: String, text: String) -> String:
	if text == "":
		return title
	return "%s\n%s" % [title, text]
