# Minimal proxy for main screen navigation.
extends RefCounted

var main
var active_tab: String = "fish"
var side_menu_controller
var system_menu_controller


func setup(main_ref) -> void:
	main = main_ref
	if main != null:
		active_tab = _normalize_tab(str(main._active_nav_tab))


func set_side_menu_controller(controller) -> void:
	side_menu_controller = controller
	_refresh_linked_menus()


func set_system_menu_controller(controller) -> void:
	system_menu_controller = controller


func open_screen(screen_id: String) -> void:
	var id: String = _normalize_tab(screen_id)
	if id == "":
		return

	if main != null and main.has_method("close_game_panels_before_opening_new_one"):
		main.close_game_panels_before_opening_new_one(id)

	if main != null and main.has_method("_should_ignore_base_ui_press") and main._should_ignore_base_ui_press():
		return

	set_active_tab(id)

	if id == "fish" and main.has_method("_open_fishing_screen"):
		main._open_fishing_screen()
	elif id == "keepnet" and main.has_method("_open_keepnet"):
		main._open_keepnet()
	elif id == "inventory" and main.has_method("_open_inventory"):
		main._open_inventory()
	elif id == "shop" and main.has_method("_open_shop"):
		main._open_shop()
	elif id == "harbor" and main.has_method("_open_harbor"):
		main._open_harbor()
	elif id == "map" and main.has_method("_open_map"):
		main._open_map()
	elif id == "profile" and main.has_method("_open_profile"):
		main._open_profile()
	elif id == "encyclopedia" and main.has_method("_open_encyclopedia"):
		main._open_encyclopedia()
	elif id == "settings" and main.has_method("_open_settings"):
		main._open_settings()


func close_current_screen() -> void:
	if main != null and main.has_method("close_current_modal"):
		main.close_current_modal()


func set_active_tab(tab_id: String) -> void:
	active_tab = _normalize_tab(tab_id)
	if main != null:
		main._active_nav_tab = _to_legacy_tab(active_tab)
	_refresh_linked_menus()


func get_active_tab() -> String:
	return active_tab


func clear_active_tab() -> void:
	active_tab = ""
	if main != null:
		main._active_nav_tab = "fish"
	_refresh_linked_menus()


func _refresh_linked_menus() -> void:
	if side_menu_controller != null and side_menu_controller.has_method("set_active"):
		side_menu_controller.set_active(active_tab)


func _normalize_tab(tab_id: String) -> String:
	var id: String = tab_id.strip_edges().to_lower()
	if id == "basket" or id == "sell" or id == "sadok":
		return "keepnet"
	if id == "inv":
		return "inventory"
	if id == "store":
		return "shop"
	if id == "fish_harbor" or id == "harbour":
		return "harbor"
	if id == "waterbody" or id == "waterbodies":
		return "map"
	if id == "atlas":
		return "encyclopedia"
	return id


func _to_legacy_tab(tab_id: String) -> String:
	var id: String = _normalize_tab(tab_id)
	if id == "keepnet":
		return "sell"
	if id == "inventory" or id == "shop" or id == "harbor" or id == "map":
		return id
	return "fish"
