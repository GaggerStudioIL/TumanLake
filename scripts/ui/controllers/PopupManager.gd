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


func close_secondary_popups_for_priority_modal() -> void:
	if main == null:
		return

	_hide_control(main.basket_panel)
	_hide_control(main.basket_backdrop)
	_hide_control(main.inventory_panel)
	_hide_control(main.inventory_backdrop)
	_hide_control(main.shop_panel)
	_hide_control(main.shop_backdrop)
	_hide_control(main.tackle_panel)
	_hide_control(main.tackle_backdrop)
	_hide_control(main.waterbody_panel)
	_hide_control(main.waterbody_backdrop)

	if main.fish_harbor_ui != null:
		main.fish_harbor_ui.visible = false
	if main.system_menu_ui != null:
		main.system_menu_ui.close_menu()
		main.system_menu_ui.close_settings(false)

	main._active_nav_tab = "fish"


func prepare_for_menu_open(menu_name: String) -> void:
	if main == null:
		return

	var menu_id := _normalize_menu_name(menu_name)
	if menu_id == "":
		return

	if main.system_menu_ui != null:
		main.system_menu_ui.close_menu()
		main.system_menu_ui.close_settings(false)

	if menu_id != "basket":
		_hide_control(main.basket_panel)
		_hide_control(main.basket_backdrop)
	if menu_id != "inventory":
		_hide_control(main.inventory_panel)
		_hide_control(main.inventory_backdrop)
	if menu_id != "shop":
		_hide_control(main.shop_panel)
		_hide_control(main.shop_backdrop)
	if menu_id != "tackle":
		_hide_control(main.tackle_panel)
		_hide_control(main.tackle_backdrop)
	if menu_id != "waterbody":
		_hide_control(main.waterbody_panel)
		_hide_control(main.waterbody_backdrop)

	if menu_id != "harbor" and main.fish_harbor_ui != null:
		main.fish_harbor_ui.visible = false
	if menu_id != "profile" and main.profile_ui != null:
		main.profile_ui.close(false)
	if menu_id != "encyclopedia" and main.encyclopedia_ui != null:
		main.encyclopedia_ui.close(false)


func layout(screen_size: Vector2, margin: float) -> void:
	if main == null or main.toast_label == null:
		return

	_ensure_toast_above_modals()
	var toast_width: float = min(screen_size.x - margin * 4.0, 520.0)
	main.toast_label.position = Vector2((screen_size.x - toast_width) * 0.5, screen_size.y - 142.0)
	main.toast_label.size = Vector2(toast_width, 76.0)
	main.toast_label.z_index = 900
	main.toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
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

	_ensure_toast_above_modals()
	_layout_toast_for_message(message, success)
	main.toast_label.text = message
	main.toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.toast_label.visible = true
	main.toast_label.modulate = Color(0.78, 1.0, 0.78, 0.0) if success else Color(1.0, 0.68, 0.58, 0.0)

	_toast_tween = main.create_tween()
	_toast_tween.tween_property(main.toast_label, "modulate:a", 1.0, 0.12)
	_toast_tween.tween_interval(3.0 if message.contains("\n") else 2.2)
	_toast_tween.tween_property(main.toast_label, "modulate:a", 0.0, 0.28)
	_toast_tween.tween_callback(func() -> void:
		if main != null and main.toast_label != null:
			main.toast_label.visible = false
	)


func _layout_toast_for_message(message: String, success: bool) -> void:
	if main == null or main.toast_label == null:
		return

	var screen_size: Vector2 = main.get_viewport_rect().size
	var margin: float = 18.0
	var line_count: int = maxi(message.split("\n", false).size(), 1)
	var toast_width: float = min(screen_size.x - margin * 4.0, 560.0)
	var toast_height: float = clampf(50.0 + float(line_count) * 18.0, 72.0, 124.0)
	main.toast_label.position = Vector2((screen_size.x - toast_width) * 0.5, screen_size.y - toast_height - 72.0)
	main.toast_label.size = Vector2(toast_width, toast_height)
	main.toast_label.z_index = 900
	main.toast_label.add_theme_font_size_override("font_size", 14)
	main.toast_label.add_theme_color_override(
		"font_color",
		Color(0.90, 1.0, 0.90, 1.0) if success else Color(1.0, 0.86, 0.80, 1.0)
	)
	var bg_color: Color = Color(0.035, 0.092, 0.074, 0.94) if success else Color(0.115, 0.052, 0.044, 0.94)
	var border_color: Color = Color(0.66, 1.0, 0.76, 0.44) if success else Color(1.0, 0.62, 0.50, 0.44)
	var shadow_color: Color = Color(0.0, 0.0, 0.0, 0.28)
	main.toast_label.add_theme_stylebox_override(
		"normal",
		main._make_panel_style(bg_color, border_color, 18, 12, shadow_color)
	)


func _ensure_toast_above_modals() -> void:
	if main == null or main.toast_label == null:
		return

	var target_parent: Node = main
	if main.has_method("get_modal_content_root"):
		var modal_root = main.call("get_modal_content_root")
		if modal_root is Node:
			target_parent = modal_root

	if main.toast_label.get_parent() != target_parent:
		var old_parent: Node = main.toast_label.get_parent()
		if old_parent != null:
			old_parent.remove_child(main.toast_label)
		target_parent.add_child(main.toast_label)
	main.toast_label.z_index = 900


func _compose_message(title: String, text: String) -> String:
	if text == "":
		return title
	return "%s\n%s" % [title, text]


func _normalize_menu_name(menu_name: String) -> String:
	var id := menu_name.strip_edges().to_lower()
	if id == "keepnet" or id == "sell" or id == "sadok":
		return "basket"
	if id == "map" or id == "waterbodies":
		return "waterbody"
	if id == "fish_harbor" or id == "harbour":
		return "harbor"
	return id


func _hide_control(control) -> void:
	if control != null:
		control.visible = false
