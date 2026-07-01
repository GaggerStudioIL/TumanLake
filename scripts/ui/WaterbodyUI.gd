# Handles the waterbody map window: global waterbody map, visual lake map, and spot selection.
extends RefCounted

const GlobalWaterbodyMapUIScript := preload("res://scripts/ui/maps/GlobalWaterbodyMapUI.gd")
const WaterbodyVisualMapUIScript := preload("res://scripts/ui/maps/WaterbodyVisualMapUI.gd")
const WATERBODY_PREVIEW_DEFAULT: Texture2D = preload("res://assets/environment/lake/lake_bg_base.png.png")

enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

var main
var theme
var global_map_ui
var visual_map_ui
var fisher_home_backdrop: ColorRect
var fisher_home_panel: Panel
var fisher_home_title_label: Label
var fisher_home_body_label: Label
var fisher_home_rest_button: Button
var fisher_home_close_button: Button
var _map_mode := "waterbody"

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	_ensure_waterbody_ui_nodes()
	_ensure_waterbody_spot_pager_nodes()

func open() -> void:
	open_waterbody_map(PlayerData.current_waterbody, PlayerData.current_spot)

func open_waterbody_map(waterbody_id: String = "", spot_id: String = "", ignore_button_disabled: bool = false) -> bool:
	if main._is_catch_reward_open() or (not ignore_button_disabled and main.map_button.disabled):
		return false

	main.open_modal("map")
	main._active_nav_tab = "map"
	main.waterbody_backdrop.visible = true
	main.waterbody_panel.visible = true
	var target_waterbody_id := waterbody_id if waterbody_id != "" else PlayerData.current_waterbody
	main._selected_waterbody_id = target_waterbody_id
	main._selected_waterbody_spot_id = spot_id if spot_id != "" else PlayerData.current_spot
	_show_waterbody_map(target_waterbody_id)
	refresh()
	main._refresh_bottom_nav_styles()
	return true

func close() -> void:
	if main == null or main.waterbody_panel == null:
		return

	main.waterbody_panel.visible = false
	main.waterbody_backdrop.visible = false
	if global_map_ui != null:
		global_map_ui.visible = false
	if visual_map_ui != null:
		visual_map_ui.visible = false
	_hide_fisher_home_panel()
	main.close_modal("map")
	main._active_nav_tab = "fish"
	main._refresh_bottom_nav_styles()

func refresh() -> void:
	_update_waterbody_ui()

func is_open() -> bool:
	return main != null and main.waterbody_panel != null and main.waterbody_panel.visible

func _ensure_waterbody_ui_nodes() -> void:
	if main.waterbody_panel != null:
		return

	main.waterbody_backdrop = ColorRect.new()
	main.waterbody_backdrop.name = "WaterbodyBackdrop"
	main.waterbody_backdrop.visible = false
	main.waterbody_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	main.waterbody_backdrop.color = Color(0.0, 0.0, 0.0, 0.84)
	main.add_child(main.waterbody_backdrop)

	main.waterbody_panel = Panel.new()
	main.waterbody_panel.name = "WaterbodyPanel"
	main.waterbody_panel.visible = false
	main.waterbody_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	main.waterbody_panel.clip_contents = true
	main.add_child(main.waterbody_panel)

	_create_legacy_nodes()

	global_map_ui = GlobalWaterbodyMapUIScript.new()
	global_map_ui.name = "GlobalWaterbodyMapUI"
	main.waterbody_panel.add_child(global_map_ui)
	global_map_ui.call("setup", main)
	global_map_ui.connect("waterbody_selected", Callable(self, "_on_global_waterbody_selected"))
	global_map_ui.connect("close_requested", Callable(self, "_on_visual_close_requested"))

	visual_map_ui = WaterbodyVisualMapUIScript.new()
	visual_map_ui.name = "WaterbodyVisualMapUI"
	main.waterbody_panel.add_child(visual_map_ui)
	visual_map_ui.call("setup", main)
	visual_map_ui.connect("spot_selected", Callable(self, "_on_visual_spot_selected"))
	visual_map_ui.connect("global_requested", Callable(self, "_show_global_map"))
	visual_map_ui.connect("shop_requested", Callable(self, "_on_visual_shop_requested"))
	visual_map_ui.connect("harbor_requested", Callable(self, "_on_visual_harbor_requested"))
	visual_map_ui.connect("fisher_home_requested", Callable(self, "_on_visual_fisher_home_requested"))
	visual_map_ui.connect("close_requested", Callable(self, "_on_visual_close_requested"))
	_ensure_fisher_home_nodes()

func _ensure_fisher_home_nodes() -> void:
	if fisher_home_panel != null:
		return

	fisher_home_backdrop = ColorRect.new()
	fisher_home_backdrop.name = "FisherHomeBackdrop"
	fisher_home_backdrop.visible = false
	fisher_home_backdrop.color = Color(0.0, 0.0, 0.0, 0.22)
	fisher_home_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	fisher_home_backdrop.z_index = 30
	main.waterbody_panel.add_child(fisher_home_backdrop)
	fisher_home_backdrop.gui_input.connect(_on_fisher_home_backdrop_gui_input)

	fisher_home_panel = Panel.new()
	fisher_home_panel.name = "FisherHomePanel"
	fisher_home_panel.visible = false
	fisher_home_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	fisher_home_panel.z_index = 31
	main.waterbody_panel.add_child(fisher_home_panel)

	fisher_home_title_label = Label.new()
	fisher_home_title_label.name = "FisherHomeTitle"
	fisher_home_title_label.text = "Дом рыбака"
	fisher_home_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fisher_home_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fisher_home_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fisher_home_panel.add_child(fisher_home_title_label)

	fisher_home_body_label = Label.new()
	fisher_home_body_label.name = "FisherHomeBody"
	fisher_home_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fisher_home_body_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	fisher_home_body_label.clip_text = true
	fisher_home_body_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fisher_home_panel.add_child(fisher_home_body_label)

	fisher_home_rest_button = Button.new()
	fisher_home_rest_button.name = "FisherHomeRestButton"
	fisher_home_rest_button.text = "Отдыхать"
	fisher_home_rest_button.focus_mode = Control.FOCUS_NONE
	fisher_home_panel.add_child(fisher_home_rest_button)
	fisher_home_rest_button.pressed.connect(_on_fisher_home_rest_pressed)

	fisher_home_close_button = Button.new()
	fisher_home_close_button.name = "FisherHomeCloseButton"
	fisher_home_close_button.text = "Закрыть"
	fisher_home_close_button.focus_mode = Control.FOCUS_NONE
	fisher_home_panel.add_child(fisher_home_close_button)
	fisher_home_close_button.pressed.connect(_hide_fisher_home_panel)

	_apply_fisher_home_panel_style()

func _create_legacy_nodes() -> void:
	main.waterbody_title_label = Label.new()
	main.waterbody_title_label.name = "WaterbodyTitleLabel"
	main.waterbody_title_label.visible = false
	main.waterbody_panel.add_child(main.waterbody_title_label)

	main.waterbody_item_list = ItemList.new()
	main.waterbody_item_list.name = "WaterbodyItemList"
	main.waterbody_item_list.visible = false
	main.waterbody_item_list.select_mode = ItemList.SELECT_SINGLE
	main.waterbody_item_list.allow_reselect = true
	main.waterbody_panel.add_child(main.waterbody_item_list)

	main.waterbody_preview_frame = Panel.new()
	main.waterbody_preview_frame.name = "WaterbodyPreviewFrame"
	main.waterbody_preview_frame.visible = false
	main.waterbody_preview_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.waterbody_panel.add_child(main.waterbody_preview_frame)

	main.waterbody_preview = TextureRect.new()
	main.waterbody_preview.name = "WaterbodyPreview"
	main.waterbody_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.waterbody_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	main.waterbody_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	main.waterbody_preview.texture = WATERBODY_PREVIEW_DEFAULT
	main.waterbody_preview_frame.add_child(main.waterbody_preview)

	main.waterbody_details_label = Label.new()
	main.waterbody_details_label.name = "WaterbodyDetailsLabel"
	main.waterbody_details_label.visible = false
	main.waterbody_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.waterbody_panel.add_child(main.waterbody_details_label)

	main.waterbody_spot_list = ItemList.new()
	main.waterbody_spot_list.name = "WaterbodySpotList"
	main.waterbody_spot_list.visible = false
	main.waterbody_spot_list.select_mode = ItemList.SELECT_SINGLE
	main.waterbody_spot_list.allow_reselect = true
	main.waterbody_panel.add_child(main.waterbody_spot_list)

	main.waterbody_spot_details_label = Label.new()
	main.waterbody_spot_details_label.name = "WaterbodySpotDetailsLabel"
	main.waterbody_spot_details_label.visible = false
	main.waterbody_spot_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.waterbody_panel.add_child(main.waterbody_spot_details_label)

	main.waterbody_select_button = Button.new()
	main.waterbody_select_button.name = "WaterbodySelectButton"
	main.waterbody_select_button.visible = false
	main.waterbody_select_button.text = "Перейти"
	main.waterbody_panel.add_child(main.waterbody_select_button)

	main.waterbody_close_button = Button.new()
	main.waterbody_close_button.name = "WaterbodyCloseButton"
	main.waterbody_close_button.visible = false
	main.waterbody_close_button.text = "Закрыть"
	main.waterbody_panel.add_child(main.waterbody_close_button)

	main.waterbody_spot_buttons = []

func _ensure_waterbody_spot_pager_nodes() -> void:
	if main == null or main.waterbody_panel == null:
		return

	if main.waterbody_spot_prev_page_button == null:
		main.waterbody_spot_prev_page_button = Button.new()
		main.waterbody_spot_prev_page_button.name = "WaterbodySpotPrevPageButton"
		main.waterbody_spot_prev_page_button.visible = false
		main.waterbody_spot_prev_page_button.text = "<"
		main.waterbody_panel.add_child(main.waterbody_spot_prev_page_button)
		main.waterbody_spot_prev_page_button.pressed.connect(_on_waterbody_spot_prev_page_pressed)

	if main.waterbody_spot_next_page_button == null:
		main.waterbody_spot_next_page_button = Button.new()
		main.waterbody_spot_next_page_button.name = "WaterbodySpotNextPageButton"
		main.waterbody_spot_next_page_button.visible = false
		main.waterbody_spot_next_page_button.text = ">"
		main.waterbody_panel.add_child(main.waterbody_spot_next_page_button)
		main.waterbody_spot_next_page_button.pressed.connect(_on_waterbody_spot_next_page_pressed)

	if main.waterbody_spot_page_label == null:
		main.waterbody_spot_page_label = Label.new()
		main.waterbody_spot_page_label.name = "WaterbodySpotPageLabel"
		main.waterbody_spot_page_label.visible = false
		main.waterbody_panel.add_child(main.waterbody_spot_page_label)

func _update_waterbody_ui() -> void:
	if main.waterbody_panel == null:
		return

	PlayerData.refresh_waterbody_unlocks()
	main._visible_waterbodies = main._get_all_waterbodies()
	if main._selected_waterbody_id == "":
		main._selected_waterbody_id = PlayerData.current_waterbody
	_update_waterbody_spot_picker(_get_selected_waterbody())
	_layout_visual_roots()

	if _map_mode == "global":
		global_map_ui.call("show_global", main._visible_waterbodies)
		visual_map_ui.visible = false
	else:
		var selected_waterbody := _get_selected_waterbody()
		if selected_waterbody.is_empty():
			selected_waterbody = main._get_waterbody(PlayerData.current_waterbody)
			main._selected_waterbody_id = str(selected_waterbody.get("id", PlayerData.current_waterbody))
		visual_map_ui.call("show_waterbody", selected_waterbody)
		global_map_ui.visible = false

	_hide_legacy_nodes()

func _layout_visual_roots() -> void:
	var screen_size: Vector2 = main.get_viewport_rect().size
	main.waterbody_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	main.waterbody_backdrop.offset_left = 0.0
	main.waterbody_backdrop.offset_top = 0.0
	main.waterbody_backdrop.offset_right = 0.0
	main.waterbody_backdrop.offset_bottom = 0.0
	main.waterbody_panel.position = Vector2.ZERO
	main.waterbody_panel.size = screen_size

	for root in [global_map_ui, visual_map_ui]:
		if root == null:
			continue
		root.position = Vector2.ZERO
		root.size = screen_size
		if root.has_method("layout_global"):
			root.call("layout_global")
		if root.has_method("layout_map"):
			root.call("layout_map")
	_layout_fisher_home_panel(screen_size)

func _layout_fisher_home_panel(screen_size: Vector2) -> void:
	if fisher_home_panel == null:
		return

	if fisher_home_backdrop != null:
		fisher_home_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
		fisher_home_backdrop.position = Vector2.ZERO
		fisher_home_backdrop.size = screen_size
		fisher_home_backdrop.offset_left = 0.0
		fisher_home_backdrop.offset_top = 0.0
		fisher_home_backdrop.offset_right = 0.0
		fisher_home_backdrop.offset_bottom = 0.0

	var ui_scale: float = clampf(min(screen_size.x / 960.0, screen_size.y / 540.0), 0.86, 1.16)
	var panel_size := Vector2(
		clampf(screen_size.x * 0.44, 360.0, 560.0),
		clampf(screen_size.y * 0.40, 270.0, 340.0)
	)
	fisher_home_panel.position = (screen_size - panel_size) * 0.5
	fisher_home_panel.size = panel_size
	fisher_home_panel.custom_minimum_size = panel_size
	_apply_fisher_home_panel_style()

	var padding := clampf(22.0 * ui_scale, 18.0, 26.0)
	var button_height := clampf(42.0 * ui_scale, 38.0, 46.0)
	var button_gap := clampf(12.0 * ui_scale, 10.0, 14.0)
	var close_width := clampf(118.0 * ui_scale, 108.0, 132.0)
	var rest_width := clampf(156.0 * ui_scale, 138.0, 178.0)
	var footer_y := panel_size.y - padding - button_height
	var body_y := 62.0 * ui_scale

	fisher_home_title_label.position = Vector2(padding, 14.0 * ui_scale)
	fisher_home_title_label.size = Vector2(panel_size.x - padding * 2.0, 38.0 * ui_scale)
	fisher_home_title_label.add_theme_font_size_override("font_size", int(clampf(24.0 * ui_scale, 22.0, 28.0)))
	fisher_home_title_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))
	fisher_home_title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
	fisher_home_title_label.add_theme_constant_override("shadow_offset_x", 1)
	fisher_home_title_label.add_theme_constant_override("shadow_offset_y", 1)

	fisher_home_body_label.position = Vector2(padding, body_y)
	fisher_home_body_label.size = Vector2(panel_size.x - padding * 2.0, maxf(footer_y - body_y - 14.0, 120.0))
	fisher_home_body_label.add_theme_font_size_override("font_size", int(clampf(15.0 * ui_scale, 14.0, 17.0)))
	fisher_home_body_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.96))

	var actions_width := rest_width + button_gap + close_width
	var actions_x := panel_size.x - padding - actions_width
	fisher_home_rest_button.position = Vector2(actions_x, footer_y)
	fisher_home_rest_button.size = Vector2(rest_width, button_height)
	fisher_home_rest_button.add_theme_font_size_override("font_size", int(clampf(15.0 * ui_scale, 14.0, 17.0)))
	_apply_fisher_home_button_style(fisher_home_rest_button, true)

	fisher_home_close_button.position = Vector2(actions_x + rest_width + button_gap, footer_y)
	fisher_home_close_button.size = Vector2(close_width, button_height)
	fisher_home_close_button.add_theme_font_size_override("font_size", int(clampf(15.0 * ui_scale, 14.0, 17.0)))
	_apply_fisher_home_button_style(fisher_home_close_button, false)


func _apply_fisher_home_panel_style() -> void:
	if fisher_home_panel == null or main == null:
		return
	fisher_home_panel.add_theme_stylebox_override(
		"panel",
		main._make_panel_style(Color(0.018, 0.046, 0.040, 0.96), Color(0.70, 0.95, 0.72, 0.40), 12, 2, Color(0.0, 0.0, 0.0, 0.22))
	)


func _apply_fisher_home_button_style(button: Button, primary: bool) -> void:
	if button == null or main == null:
		return
	if primary:
		button.add_theme_stylebox_override("normal", main._make_panel_style(Color(0.24, 0.52, 0.16, 0.96), Color(0.68, 1.0, 0.58, 0.44), 8, 3, Color(0.0, 0.0, 0.0, 0.16)))
		button.add_theme_stylebox_override("hover", main._make_panel_style(Color(0.30, 0.64, 0.20, 1.0), Color(0.78, 1.0, 0.66, 0.62), 8, 4, Color(0.18, 0.68, 0.22, 0.18)))
		button.add_theme_stylebox_override("pressed", main._make_panel_style(Color(0.18, 0.40, 0.12, 1.0), Color(0.58, 0.88, 0.48, 0.52), 8, 1, Color(0.0, 0.0, 0.0, 0.12)))
	else:
		button.add_theme_stylebox_override("normal", main._make_panel_style(Color(0.05, 0.13, 0.12, 0.92), Color(0.58, 0.78, 0.68, 0.34), 8, 3, Color(0.0, 0.0, 0.0, 0.12)))
		button.add_theme_stylebox_override("hover", main._make_panel_style(Color(0.08, 0.19, 0.16, 0.98), Color(0.72, 0.98, 0.76, 0.48), 8, 4, Color(0.18, 0.68, 0.22, 0.10)))
		button.add_theme_stylebox_override("pressed", main._make_panel_style(Color(0.03, 0.10, 0.08, 1.0), Color(0.48, 0.74, 0.58, 0.42), 8, 1, Color(0.0, 0.0, 0.0, 0.12)))
	button.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.86, 1.0, 0.82, 1.0))


func _refresh_fisher_home_text() -> void:
	if fisher_home_body_label == null:
		return
	var state := {
		"health": float(PlayerData.health),
		"body_temperature": float(PlayerData.body_temperature),
		"hunger": float(PlayerData.hunger)
	}
	var condition_manager: Node = main.get_node_or_null("/root/PlayerConditionManager") if main != null else null
	if condition_manager != null and condition_manager.has_method("get_condition_state"):
		var raw_state = condition_manager.call("get_condition_state")
		if raw_state is Dictionary:
			state = (raw_state as Dictionary).duplicate(true)
	var wellbeing := clampf(float(state.get("wellbeing", state.get("health", 100.0))), 0.0, 100.0)
	var wellbeing_label := str(state.get("wellbeing_label", _get_fisher_home_wellbeing_label(wellbeing)))
	fisher_home_body_label.text = "Здесь можно восстановиться перед следующей рыбалкой.\n\nСамочувствие: %s\nТемпература: %.1f°C\nГолод: %d%%" % [
		wellbeing_label,
		float(state.get("body_temperature", 36.6)),
		roundi(float(state.get("hunger", 100.0)))
	]


func _get_fisher_home_wellbeing_label(value: float) -> String:
	if value < 20.0:
		return "Вымотан"
	if value < 40.0:
		return "Плохо"
	if value < 65.0:
		return "Устал"
	if value < 90.0:
		return "Нормально"
	return "Отлично"


func _show_fisher_home_panel() -> void:
	_ensure_fisher_home_nodes()
	_layout_fisher_home_panel(main.get_viewport_rect().size)
	_refresh_fisher_home_text()
	if fisher_home_backdrop != null:
		fisher_home_backdrop.visible = true
		fisher_home_backdrop.move_to_front()
	if fisher_home_panel != null:
		fisher_home_panel.visible = true
		fisher_home_panel.move_to_front()


func _hide_fisher_home_panel() -> void:
	if fisher_home_backdrop != null:
		fisher_home_backdrop.visible = false
	if fisher_home_panel != null:
		fisher_home_panel.visible = false


func _on_fisher_home_backdrop_gui_input(event: InputEvent) -> void:
	var should_close := false
	if event is InputEventMouseButton:
		should_close = event.pressed
	elif event is InputEventScreenTouch:
		should_close = event.pressed
	if should_close:
		_hide_fisher_home_panel()
		if main != null:
			main.get_viewport().set_input_as_handled()

func _hide_legacy_nodes() -> void:
	for node in [
		main.waterbody_title_label,
		main.waterbody_item_list,
		main.waterbody_preview_frame,
		main.waterbody_details_label,
		main.waterbody_spot_list,
		main.waterbody_spot_details_label,
		main.waterbody_select_button,
		main.waterbody_close_button,
		main.waterbody_spot_prev_page_button,
		main.waterbody_spot_next_page_button,
		main.waterbody_spot_page_label
	]:
		if node != null:
			node.visible = false

func _show_global_map() -> void:
	_hide_fisher_home_panel()
	_map_mode = "global"
	_update_waterbody_ui()

func _show_waterbody_map(waterbody_id: String) -> void:
	_hide_fisher_home_panel()
	_map_mode = "waterbody"
	main._selected_waterbody_id = waterbody_id
	if main._selected_waterbody_spot_id == "":
		main._selected_waterbody_spot_id = PlayerData.current_spot
	_update_waterbody_ui()

func _on_global_waterbody_selected(waterbody_id: String) -> void:
	var waterbody: Dictionary = main._get_waterbody(waterbody_id)
	if waterbody.is_empty():
		return
	var reason := _get_world_waterbody_unavailable_reason(waterbody)
	if reason != "":
		if global_map_ui != null and global_map_ui.has_method("show_waterbody_info"):
			global_map_ui.call("show_waterbody_info", waterbody, reason)
		main._show_toast(reason, false)
		return
	if not PlayerData.can_use_waterbody(waterbody_id):
		main._show_toast("Водоём откроется на LVL %d" % int(waterbody.get("required_level", 1)), false)
		return
	_show_waterbody_map(waterbody_id)

func _get_world_waterbody_unavailable_reason(waterbody: Dictionary) -> String:
	var waterbody_id := str(waterbody.get("id", ""))
	var status := str(waterbody.get("status", "locked"))
	if status == "beta_or_soon":
		return "Карта водоёма в разработке"
	if not PlayerData.can_use_waterbody(waterbody_id):
		var required_level := int(waterbody.get("required_level", 1))
		if status == "locked":
			return "Водоём закрыт: требуется LVL %d" % required_level
		return "Водоём откроется на LVL %d" % required_level
	var spots := SpotDatabase.get_spots_for_waterbody(waterbody_id)
	if spots.is_empty() or str(waterbody.get("map_asset", "")) == "":
		return "Карта водоёма в разработке"
	return ""

func _on_visual_spot_selected(waterbody_id: String, spot_id: String) -> void:
	var waterbody: Dictionary = main._get_waterbody(waterbody_id)
	var spot: Dictionary = SpotDatabase.get_spot(spot_id)
	if waterbody.is_empty() or spot.is_empty():
		return
	if not PlayerData.can_use_waterbody(waterbody_id):
		main._show_toast("Водоём откроется на LVL %d" % int(waterbody.get("required_level", 1)), false)
		return
	if PlayerData.has_method("can_use_spot") and not bool(PlayerData.call("can_use_spot", spot_id)):
		main._show_toast(_get_spot_lock_reason(spot), false)
		_update_waterbody_ui()
		return

	main._selected_waterbody_id = waterbody_id
	main._selected_waterbody_spot_id = spot_id
	main._visible_waterbodies = main._get_all_waterbodies()
	main._visible_waterbody_spots = SpotDatabase.get_spots_for_waterbody(waterbody_id)
	main._on_waterbody_select_button_pressed()

func _on_visual_close_requested() -> void:
	main._on_waterbody_close_button_pressed()

func _on_visual_fisher_home_requested() -> void:
	_show_fisher_home_panel()

func _on_visual_shop_requested() -> void:
	_hide_fisher_home_panel()
	_open_screen_from_map("shop")

func _on_visual_harbor_requested() -> void:
	_hide_fisher_home_panel()
	_open_screen_from_map("harbor")

func _on_fisher_home_rest_pressed() -> void:
	if main == null:
		return

	var fishing_manager: Node = main.get_node_or_null("/root/FishingManager")
	if fishing_manager != null and bool(fishing_manager.get("is_fishing")):
		main._show_toast("Сначала закончите текущую ловлю", false)
		return

	var condition_manager: Node = main.get_node_or_null("/root/PlayerConditionManager")
	if condition_manager != null and condition_manager.has_method("rest_at_agamim_cabin"):
		var result: Dictionary = condition_manager.call("rest_at_agamim_cabin")
		var success := bool(result.get("success", false))
		var message := str(result.get("message", "Отдых сейчас недоступен."))
		main._show_toast(message, success)
		if success:
			SaveManager.save_game()
		main._update_ui()
		_refresh_fisher_home_text()
		return

	main._show_toast("Отдых сейчас недоступен", false)

func _open_screen_from_map(screen_id: String) -> void:
	if main == null:
		return
	if main.has_method("_set_map_return_target_for_screen"):
		main._set_map_return_target_for_screen(screen_id, main._selected_waterbody_id, main._selected_waterbody_spot_id)
	if main.has_method("_open_screen_via_navigation") and main._open_screen_via_navigation(screen_id):
		return
	if main.has_method("close_game_panels_before_opening_new_one"):
		main.close_game_panels_before_opening_new_one(screen_id)
	if screen_id == "shop" and main.has_method("_open_shop"):
		main._open_shop()
	elif screen_id == "harbor" and main.has_method("_open_harbor"):
		main._open_harbor()

func _get_selected_waterbody() -> Dictionary:
	for waterbody in main._visible_waterbodies:
		if str(waterbody.get("id", "")) == main._selected_waterbody_id:
			return waterbody
	return {}

func _update_waterbody_spot_picker(waterbody: Dictionary) -> void:
	if waterbody.is_empty():
		main._visible_waterbody_spots = []
		main._selected_waterbody_spot_id = ""
		return

	var waterbody_id := str(waterbody.get("id", ""))
	main._visible_waterbody_spots = SpotDatabase.get_spots_for_waterbody(waterbody_id)
	if main._selected_waterbody_spot_id == "":
		main._selected_waterbody_spot_id = PlayerData.current_spot
	if _get_selected_waterbody_spot().is_empty() and not main._visible_waterbody_spots.is_empty():
		main._selected_waterbody_spot_id = str(main._visible_waterbody_spots[0].get("id", ""))

func _get_selected_waterbody_spot() -> Dictionary:
	for spot in main._visible_waterbody_spots:
		if str(spot.get("id", "")) == main._selected_waterbody_spot_id:
			return spot
	return {}

func _get_visible_waterbody_spot_index(spot_id: String) -> int:
	for i in main._visible_waterbody_spots.size():
		if str(main._visible_waterbody_spots[i].get("id", "")) == spot_id:
			return i
	return -1

func _get_waterbody_spot_details_text(spot: Dictionary) -> String:
	if spot.is_empty():
		return "Точка ловли не выбрана."

	var fish_names: Array = []
	var fish_pool: Array = spot.get("fish_pool", spot.get("available_fish", []))
	for fish_id in fish_pool:
		var fish: Dictionary = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue
		fish_names.append(str(fish.get("name", fish_id)))
		if fish_names.size() >= 7:
			break

	return "%s\n%s\nГлубина: %.1f-%.1f м\nРабочая глубина: %.1f м\nРыба: %s\n\n%s" % [
		str(spot.get("name", "-")),
		str(spot.get("spot_type", spot.get("type", "-"))),
		float(spot.get("min_depth", spot.get("depth", 0.0))),
		float(spot.get("max_depth", spot.get("depth", 0.0))),
		float(spot.get("preferred_depth", spot.get("depth", 0.0))),
		", ".join(fish_names),
		str(spot.get("description", ""))
	]

func _get_waterbody_details_text(waterbody: Dictionary) -> String:
	if waterbody.is_empty():
		return "Водоём не выбран."

	var waterbody_id := str(waterbody.get("id", ""))
	var status := "Доступен" if PlayerData.can_use_waterbody(waterbody_id) else "Требуется LVL %d" % int(waterbody.get("required_level", 1))
	return "%s\n%s\n\n%s\n\nОсновная рыба: %s" % [
		str(waterbody.get("name", "-")),
		status,
		str(waterbody.get("description", "")),
		main._get_waterbody_fish_names(waterbody_id, 7)
	]

func _get_waterbody_preview_color(waterbody_id: String) -> Color:
	match waterbody_id:
		"forest_lake":
			return Color(0.08, 0.22, 0.15, 0.88)
		"river_backwater":
			return Color(0.08, 0.16, 0.23, 0.88)
		_:
			return Color(0.12, 0.30, 0.27, 0.88)

func _get_waterbody_preview_texture(_waterbody_id: String) -> Texture2D:
	return WATERBODY_PREVIEW_DEFAULT

func _get_waterbody_spot_button_text(spot: Dictionary) -> String:
	return "%s  до %.1f м" % [
		str(spot.get("name", "-")),
		float(spot.get("max_depth", spot.get("depth", 6.0)))
	]

func _get_spot_lock_reason(spot: Dictionary) -> String:
	var required_level := int(spot.get("required_level", spot.get("unlock_level", 1)))
	if PlayerData.level < required_level:
		return "Точка откроется на LVL %d" % required_level
	return "Точка пока закрыта"

func _on_waterbody_item_selected(index: int) -> void:
	if index < 0 or index >= main._visible_waterbodies.size():
		main._selected_waterbody_id = ""
	else:
		main._selected_waterbody_id = str(main._visible_waterbodies[index].get("id", ""))
		main._selected_waterbody_spot_id = ""
	_show_waterbody_map(main._selected_waterbody_id)

func _on_waterbody_spot_item_selected(index: int) -> void:
	if index < 0 or index >= main._visible_waterbody_spots.size():
		main._selected_waterbody_spot_id = ""
	else:
		main._selected_waterbody_spot_id = str(main._visible_waterbody_spots[index].get("id", ""))
	_update_waterbody_ui()

func _on_waterbody_spot_prev_page_pressed() -> void:
	main._waterbody_spot_page = max(main._waterbody_spot_page - 1, 0)
	_update_waterbody_ui()

func _on_waterbody_spot_next_page_pressed() -> void:
	main._waterbody_spot_page += 1
	_update_waterbody_ui()

func _update_waterbody_spot_pager(_page_count: int, _total_count: int) -> void:
	_hide_legacy_nodes()

func _update_waterbody_spot_buttons(_page_labels: Array, _page_current_flags: Array, _selected_page_index: int, _page_start: int) -> void:
	pass
