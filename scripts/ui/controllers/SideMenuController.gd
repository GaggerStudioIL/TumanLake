# Passive controller for the left gameplay menu.
extends RefCounted

var main
var navigation_controller
var _active_tab: String = ""


func setup(main_ref, navigation_ref, connect_buttons: bool = false) -> void:
	main = main_ref
	navigation_controller = navigation_ref
	if navigation_controller != null and navigation_controller.has_method("set_side_menu_controller"):
		navigation_controller.set_side_menu_controller(self)
	if connect_buttons:
		_connect_menu_signals()
	refresh()


func build_menu(parent: Control) -> void:
	if parent == null:
		return
	_reparent_button(_get_button("inventory"), parent)
	_reparent_button(_get_button("map"), parent)
	refresh()


func set_active(tab_id: String) -> void:
	_active_tab = _normalize_tab(tab_id)
	refresh()


func clear_active() -> void:
	_active_tab = ""
	refresh()


func refresh() -> void:
	if main == null:
		return
	_refresh_button("inventory", "inventory")
	_refresh_button("map", "map")
	_hide_button(_get_button("shop"))
	_hide_button(_get_button("harbor"))
	if main.basket_button != null:
		main.basket_button.visible = false
		main.basket_button.disabled = true
		main.basket_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if main.nav_fish_button != null:
		main.nav_fish_button.visible = false


func _connect_menu_signals() -> void:
	_connect_button("inventory")
	_connect_button("map")


func _connect_button(screen_id: String) -> void:
	var button := _get_button(screen_id)
	if button == null:
		return
	var callback := Callable(self, "_on_menu_button_pressed").bind(screen_id)
	if not button.pressed.is_connected(callback):
		button.pressed.connect(callback)


func _on_menu_button_pressed(screen_id: String) -> void:
	if navigation_controller != null and navigation_controller.has_method("open_screen"):
		navigation_controller.open_screen(screen_id)


func _refresh_button(id: String, legacy_id: String) -> void:
	var button := _get_button(id)
	if button != null and main.has_method("_refresh_side_menu_button_state"):
		main._refresh_side_menu_button_state(button, _is_item_active(id, legacy_id))


func _reparent_button(button: Button, parent: Control) -> void:
	if button != null and button.get_parent() != parent and main != null and main.has_method("_reparent_node"):
		main._reparent_node(button, parent)

func _hide_button(button: Button) -> void:
	if button == null:
		return
	button.visible = false
	button.disabled = true
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _get_button(id: String) -> Button:
	if main == null:
		return null
	if id == "inventory":
		return main.inventory_button
	if id == "shop":
		return main.shop_button
	if id == "harbor":
		return main.harbor_button
	if id == "map":
		return main.map_button
	return null


func _is_item_active(id: String, legacy_id: String) -> bool:
	var normalized_active: String = _normalize_tab(_active_tab)
	return normalized_active == id or normalized_active == legacy_id


func _normalize_tab(tab_id: String) -> String:
	var id: String = tab_id.strip_edges().to_lower()
	if id == "basket" or id == "sell" or id == "sadok":
		return "keepnet"
	if id == "fish" or id == "profile" or id == "encyclopedia" or id == "settings":
		return ""
	return id
