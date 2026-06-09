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
var _map_mode := "waterbody"

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	_ensure_waterbody_ui_nodes()
	_ensure_waterbody_spot_pager_nodes()

func open() -> void:
	if main._is_catch_reward_open() or main.map_button.disabled:
		return

	main.open_modal("map")
	main._active_nav_tab = "map"
	main.waterbody_backdrop.visible = true
	main.waterbody_panel.visible = true
	main._selected_waterbody_id = PlayerData.current_waterbody
	main._selected_waterbody_spot_id = PlayerData.current_spot
	_show_waterbody_map(PlayerData.current_waterbody)
	refresh()
	main._refresh_bottom_nav_styles()

func close() -> void:
	if main == null or main.waterbody_panel == null:
		return

	main.waterbody_panel.visible = false
	main.waterbody_backdrop.visible = false
	if global_map_ui != null:
		global_map_ui.visible = false
	if visual_map_ui != null:
		visual_map_ui.visible = false
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
	visual_map_ui.connect("close_requested", Callable(self, "_on_visual_close_requested"))

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
	_map_mode = "global"
	_update_waterbody_ui()

func _show_waterbody_map(waterbody_id: String) -> void:
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
		main._show_toast("Водоём откроется на %d уровне" % int(waterbody.get("required_level", 1)), false)
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
			return "Водоём закрыт: требуется уровень %d" % required_level
		return "Водоём откроется на %d уровне" % required_level
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
		main._show_toast("Водоём откроется на %d уровне" % int(waterbody.get("required_level", 1)), false)
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

func _on_visual_shop_requested() -> void:
	_open_screen_from_map("shop")

func _on_visual_harbor_requested() -> void:
	_open_screen_from_map("harbor")

func _open_screen_from_map(screen_id: String) -> void:
	if main == null:
		return
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
		return "Точка откроется на %d уровне" % required_level
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
