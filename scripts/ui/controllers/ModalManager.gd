# Owns modal layer routing while preserving current screen controllers.
extends RefCounted

var main
var _registered_modals: Dictionary = {}


func setup(main_ref) -> void:
	main = main_ref


func register_modal(id: String, modal) -> void:
	_registered_modals[id] = modal


func open_modal(id: String) -> void:
	ensure_layer()
	move_roots_to_layer()
	if main.system_menu_ui != null:
		main.system_menu_ui.close_menu()
	hide_modal_roots_except(id)
	main._current_modal_name = id
	main.is_modal_open = true
	if main.modal_input_shield != null:
		main.modal_input_shield.visible = true
		main.modal_input_shield.mouse_filter = Control.MOUSE_FILTER_STOP


func close_modal(id: String = "") -> void:
	var should_close: bool = id == "" or main._current_modal_name == id
	if should_close:
		main._current_modal_name = ""
	refresh_input_blocker()


func close_all() -> void:
	main._current_modal_name = ""
	hide_modal_roots_except("")
	refresh_input_blocker()


func close_current_modal() -> void:
	match main._current_modal_name:
		"shop":
			main.shop_ui.close()
		"inventory":
			main.inventory_ui.close()
		"keepnet":
			main.keepnet_ui.close()
		"tackle":
			main.tackle_ui.close()
		"map":
			main.waterbody_ui.close()
		"profile":
			if main.profile_ui != null:
				main.profile_ui.close()
		"fish_harbor":
			if main.fish_harbor_ui != null and main.fish_harbor_ui.has_method("close"):
				main.fish_harbor_ui.call("close")
		"settings":
			if main.system_menu_ui != null:
				main.system_menu_ui.close_settings()
		"encyclopedia":
			if main.encyclopedia_ui != null:
				main.encyclopedia_ui.close()
		"catch_reward":
			if main.has_method("_block_pending_catch_reward_close_attempt") and main._block_pending_catch_reward_close_attempt():
				return
			main._hide_catch_reward_popup()
		_:
			hide_modal_roots_except("")
			if main.profile_ui != null:
				main.profile_ui.close()
			if main.encyclopedia_ui != null:
				main.encyclopedia_ui.close()
			if main.fish_harbor_ui != null:
				main.fish_harbor_ui.visible = false
			if main.system_menu_ui != null:
				main.system_menu_ui.close_settings()
			refresh_input_blocker()


func is_modal_open(id: String) -> bool:
	return main._current_modal_name == id and is_any_modal_visible()


func get_active_modal() -> String:
	return main._current_modal_name


func ensure_input_shield() -> void:
	ensure_layer()


func ensure_layer() -> void:
	if main.modal_canvas_layer == null:
		main.modal_canvas_layer = CanvasLayer.new()
		main.modal_canvas_layer.name = "ModalLayer"
		main.modal_canvas_layer.layer = 40
		main.add_child(main.modal_canvas_layer)

	if main.modal_input_shield != null:
		layout_modal_layer()
		return

	main.modal_input_shield = ColorRect.new()
	main.modal_input_shield.name = "ModalInputBlocker"
	main.modal_input_shield.visible = false
	main.modal_input_shield.mouse_filter = Control.MOUSE_FILTER_STOP
	main.modal_input_shield.color = Color(0.0, 0.0, 0.0, 0.0)
	main.modal_input_shield.z_index = 0
	main.modal_canvas_layer.add_child(main.modal_input_shield)

	main.modal_content_root = Control.new()
	main.modal_content_root.name = "ModalContentRoot"
	main.modal_content_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.modal_content_root.z_index = 1
	main.modal_canvas_layer.add_child(main.modal_content_root)

	layout_modal_layer()


func get_content_root() -> Control:
	ensure_layer()
	return main.modal_content_root


func layout_modal_layer() -> void:
	var screen_size: Vector2 = main._get_full_ui_viewport_size()
	if main.modal_input_shield != null:
		main.modal_input_shield.set_anchors_preset(Control.PRESET_FULL_RECT)
		main.modal_input_shield.position = Vector2.ZERO
		main.modal_input_shield.size = screen_size
		main.modal_input_shield.scale = Vector2.ONE
		main.modal_input_shield.offset_left = 0.0
		main.modal_input_shield.offset_top = 0.0
		main.modal_input_shield.offset_right = 0.0
		main.modal_input_shield.offset_bottom = 0.0
	if main.modal_content_root != null:
		main.modal_content_root.set_anchors_preset(Control.PRESET_FULL_RECT)
		main.modal_content_root.position = Vector2.ZERO
		main.modal_content_root.size = screen_size
		main.modal_content_root.custom_minimum_size = screen_size
		main.modal_content_root.scale = Vector2.ONE
		main.modal_content_root.offset_left = 0.0
		main.modal_content_root.offset_top = 0.0
		main.modal_content_root.offset_right = 0.0
		main.modal_content_root.offset_bottom = 0.0


func move_roots_to_layer() -> void:
	var root := get_content_root()
	for node in [
		main.basket_backdrop,
		main.basket_panel,
		main.inventory_backdrop,
		main.inventory_panel,
		main.catch_popup_backdrop,
		main.catch_popup_panel,
		main.shop_backdrop,
		main.shop_panel,
		main.tackle_backdrop,
		main.tackle_panel,
		main.waterbody_backdrop,
		main.waterbody_panel,
		main.fish_harbor_ui
	]:
		main._reparent_node(node, root)
		if node is Control:
			(node as Control).mouse_filter = Control.MOUSE_FILTER_STOP


func hide_modal_roots_except(id: String) -> void:
	if id == "":
		main._current_modal_name = ""
	if id != "keepnet":
		if main.basket_panel != null:
			main.basket_panel.visible = false
		if main.basket_backdrop != null:
			main.basket_backdrop.visible = false
	if id != "inventory":
		if main.inventory_panel != null:
			main.inventory_panel.visible = false
		if main.inventory_backdrop != null:
			main.inventory_backdrop.visible = false
	if id != "shop":
		if main.shop_panel != null:
			main.shop_panel.visible = false
		if main.shop_backdrop != null:
			main.shop_backdrop.visible = false
	if id != "tackle":
		if main.tackle_panel != null:
			main.tackle_panel.visible = false
		if main.tackle_backdrop != null:
			main.tackle_backdrop.visible = false
	if id != "map":
		if main.waterbody_panel != null:
			main.waterbody_panel.visible = false
		if main.waterbody_backdrop != null:
			main.waterbody_backdrop.visible = false
	if id != "fish_harbor" and main.fish_harbor_ui != null:
		main.fish_harbor_ui.visible = false
	if id != "catch_reward":
		if main.catch_popup_panel != null:
			main.catch_popup_panel.visible = false
		if main.catch_popup_backdrop != null:
			main.catch_popup_backdrop.visible = false
	if id != "profile" and main.profile_ui != null:
		main.profile_ui.close(false)
	if id != "encyclopedia" and main.encyclopedia_ui != null:
		main.encyclopedia_ui.close(false)
	if id != "settings" and main.system_menu_ui != null:
		main.system_menu_ui.close_settings(false)


func refresh_input_blocker() -> void:
	ensure_layer()
	var has_open_modal := is_any_modal_visible()
	main.is_modal_open = has_open_modal
	if main.modal_input_shield != null:
		main.modal_input_shield.visible = has_open_modal or main._is_modal_tap_guard_active()
		main.modal_input_shield.mouse_filter = Control.MOUSE_FILTER_STOP


func is_any_modal_visible() -> bool:
	for control in [
		main.basket_panel,
		main.inventory_panel,
		main.shop_panel,
		main.tackle_panel,
		main.waterbody_panel,
		main.catch_popup_panel
	]:
		if main._is_visible_ui_control(control):
			return true
	if main.profile_ui != null and main.profile_ui.is_any_modal_open():
		return true
	if main.encyclopedia_ui != null and main.encyclopedia_ui.is_any_modal_open():
		return true
	if main.fish_harbor_ui != null and main.fish_harbor_ui.visible:
		return true
	if main.system_menu_ui != null and main.system_menu_ui.is_settings_open():
		return true
	return false
