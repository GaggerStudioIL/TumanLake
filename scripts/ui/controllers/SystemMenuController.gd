# Thin wrapper around the existing top-right SystemMenuUI.
extends RefCounted

var main
var navigation_controller
var menu_ui


func setup(main_ref, navigation_ref, menu_ui_ref = null) -> void:
	main = main_ref
	navigation_controller = navigation_ref
	if navigation_controller != null and navigation_controller.has_method("set_system_menu_controller"):
		navigation_controller.set_system_menu_controller(self)
	if menu_ui_ref != null:
		attach_menu_ui(menu_ui_ref)


func attach_menu_ui(menu_ui_ref) -> void:
	menu_ui = menu_ui_ref
	if menu_ui != null and menu_ui.has_method("set_navigation_controller"):
		menu_ui.set_navigation_controller(navigation_controller)


func build_menu(parent: Control) -> void:
	if menu_ui != null and menu_ui.has_method("setup") and main != null:
		menu_ui.setup(main)


func toggle() -> void:
	if menu_ui == null:
		return
	if is_open():
		close()
	else:
		open()


func open() -> void:
	if menu_ui == null:
		return
	if menu_ui.has_method("open_menu"):
		menu_ui.open_menu()
	elif not is_open() and menu_ui.has_method("_on_menu_button_pressed"):
		menu_ui._on_menu_button_pressed()


func close() -> void:
	if menu_ui != null and menu_ui.has_method("close_menu"):
		menu_ui.close_menu()


func is_open() -> bool:
	return menu_ui != null and menu_ui.has_method("is_menu_open") and menu_ui.is_menu_open()


func layout(screen_size: Vector2) -> void:
	if menu_ui != null and menu_ui.has_method("layout"):
		menu_ui.layout(screen_size)


func set_disabled(disabled: bool) -> void:
	if menu_ui != null and menu_ui.has_method("set_disabled"):
		menu_ui.set_disabled(disabled)


func is_settings_open() -> bool:
	return menu_ui != null and menu_ui.has_method("is_settings_open") and menu_ui.is_settings_open()


func open_settings() -> void:
	if menu_ui != null and menu_ui.has_method("open_settings"):
		menu_ui.open_settings()
	elif menu_ui != null and menu_ui.has_method("_on_settings_pressed"):
		menu_ui._on_settings_pressed()


func close_settings(reset_nav: bool = true) -> void:
	if menu_ui != null and menu_ui.has_method("close_settings"):
		menu_ui.close_settings(reset_nav)
