# Handles the waterbody window: waterbody list, spots, and preview.
extends RefCounted

var main
enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

func setup(main_ref) -> void:
	main = main_ref
	_ensure_waterbody_ui_nodes()

func open() -> void:
	if main._is_catch_reward_open() or main.map_button.disabled:
		return

	main._active_nav_tab = "map"
	main.basket_panel.visible = false
	main.basket_backdrop.visible = false
	main.inventory_panel.visible = false
	main.inventory_backdrop.visible = false
	main.tackle_panel.visible = false
	main.tackle_backdrop.visible = false
	main.shop_panel.visible = false
	main.shop_backdrop.visible = false
	main.waterbody_backdrop.visible = true
	main.waterbody_panel.visible = true
	main._selected_waterbody_id = PlayerData.current_waterbody
	refresh()
	main._refresh_bottom_nav_styles()

func close() -> void:
	if main == null or main.waterbody_panel == null:
		return

	main.waterbody_panel.visible = false
	main.waterbody_backdrop.visible = false
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
	main.waterbody_backdrop.color = Color(0.0, 0.0, 0.0, 0.54)
	main.add_child(main.waterbody_backdrop)

	main.waterbody_panel = Panel.new()
	main.waterbody_panel.name = "WaterbodyPanel"
	main.waterbody_panel.visible = false
	main.waterbody_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	main.add_child(main.waterbody_panel)

	main.waterbody_title_label = Label.new()
	main.waterbody_title_label.name = "WaterbodyTitleLabel"
	main.waterbody_title_label.text = "Водоёмы"
	main.waterbody_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.waterbody_panel.add_child(main.waterbody_title_label)

	main.waterbody_item_list = ItemList.new()
	main.waterbody_item_list.name = "WaterbodyItemList"
	main.waterbody_item_list.select_mode = ItemList.SELECT_SINGLE
	main.waterbody_item_list.allow_reselect = true
	main.waterbody_panel.add_child(main.waterbody_item_list)

	main.waterbody_preview = ColorRect.new()
	main.waterbody_preview.name = "WaterbodyPreview"
	main.waterbody_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.waterbody_panel.add_child(main.waterbody_preview)

	main.waterbody_details_label = Label.new()
	main.waterbody_details_label.name = "WaterbodyDetailsLabel"
	main.waterbody_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.waterbody_panel.add_child(main.waterbody_details_label)

	main.waterbody_spot_list = ItemList.new()
	main.waterbody_spot_list.name = "WaterbodySpotList"
	main.waterbody_spot_list.select_mode = ItemList.SELECT_SINGLE
	main.waterbody_spot_list.allow_reselect = true
	main.waterbody_panel.add_child(main.waterbody_spot_list)

	main.waterbody_spot_details_label = Label.new()
	main.waterbody_spot_details_label.name = "WaterbodySpotDetailsLabel"
	main.waterbody_spot_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.waterbody_panel.add_child(main.waterbody_spot_details_label)

	main.waterbody_select_button = Button.new()
	main.waterbody_select_button.name = "WaterbodySelectButton"
	main.waterbody_select_button.text = "Перейти"
	main.waterbody_panel.add_child(main.waterbody_select_button)

	main.waterbody_close_button = Button.new()
	main.waterbody_close_button.name = "WaterbodyCloseButton"
	main.waterbody_close_button.text = "Закрыть"
	main.waterbody_panel.add_child(main.waterbody_close_button)


func _update_waterbody_ui() -> void:
	if main.waterbody_panel == null:
		return

	PlayerData.refresh_waterbody_unlocks()
	main._visible_waterbodies = main._get_all_waterbodies()
	main.waterbody_item_list.clear()

	var selected_index = -1
	for i in main._visible_waterbodies.size():
		var waterbody: Dictionary = main._visible_waterbodies[i]
		var waterbody_id = str(waterbody.get("id", ""))
		var required_level = int(waterbody.get("required_level", 1))
		var unlocked = PlayerData.can_use_waterbody(waterbody_id)
		var label = "%s" % str(waterbody.get("name", "-"))
		if not unlocked:
			label = "%s  |  LVL %d" % [label, required_level]
		elif waterbody_id == PlayerData.current_waterbody:
			label = "%s  |  текущий" % label

		main.waterbody_item_list.add_item(label)
		var list_index = main.waterbody_item_list.item_count - 1
		if unlocked:
			main.waterbody_item_list.set_item_custom_fg_color(list_index, Color(0.84, 0.98, 0.86, 1.0))
		else:
			main.waterbody_item_list.set_item_custom_fg_color(list_index, Color(0.52, 0.62, 0.58, 0.88))
		if waterbody_id == PlayerData.current_waterbody:
			main.waterbody_item_list.set_item_custom_bg_color(list_index, Color(0.12, 0.34, 0.22, 0.66))

		if waterbody_id == main._selected_waterbody_id:
			selected_index = i

	if selected_index < 0 and not main._visible_waterbodies.is_empty():
		selected_index = 0
		main._selected_waterbody_id = str(main._visible_waterbodies[0].get("id", ""))

	if selected_index >= 0:
		main.waterbody_item_list.select(selected_index)

	var selected_waterbody = _get_selected_waterbody()
	_update_waterbody_spot_picker(selected_waterbody)
	var can_select = not selected_waterbody.is_empty() and PlayerData.can_use_waterbody(str(selected_waterbody.get("id", "")))
	var selected_spot = _get_selected_waterbody_spot()
	var is_current = str(selected_waterbody.get("id", "")) == PlayerData.current_waterbody and str(selected_spot.get("id", "")) == PlayerData.current_spot
	main.waterbody_details_label.text = _get_waterbody_details_text(selected_waterbody)
	main.waterbody_preview.color = _get_waterbody_preview_color(str(selected_waterbody.get("id", "")))
	main.waterbody_select_button.disabled = not can_select or selected_spot.is_empty() or is_current or main._fishing_ui_state != FishingUiState.IDLE
	main.waterbody_select_button.text = "Текущая точка" if is_current else "Ловить здесь"


func _get_selected_waterbody() -> Dictionary:
	for waterbody in main._visible_waterbodies:
		if str(waterbody.get("id", "")) == main._selected_waterbody_id:
			return waterbody

	return {}


func _update_waterbody_spot_picker(waterbody: Dictionary) -> void:
	if main.waterbody_spot_list == null:
		return

	main.waterbody_spot_list.clear()
	main._visible_waterbody_spots = []

	if waterbody.is_empty():
		main.waterbody_spot_details_label.text = "Точка ловли не выбрана."
		main._selected_waterbody_spot_id = ""
		return

	var waterbody_id = str(waterbody.get("id", ""))
	main._visible_waterbody_spots = SpotDatabase.get_spots_for_waterbody(waterbody_id)
	var selected_index = -1

	for i in main._visible_waterbody_spots.size():
		var spot: Dictionary = main._visible_waterbody_spots[i]
		var spot_id = str(spot.get("id", ""))
		var label = "%s  %.1f-%.1f м" % [
			str(spot.get("name", "-")),
			float(spot.get("min_depth", 0.2)),
			float(spot.get("max_depth", 6.0))
		]
		if waterbody_id == PlayerData.current_waterbody and spot_id == PlayerData.current_spot:
			label = "%s  |  текущая" % label

		main.waterbody_spot_list.add_item(label)
		var list_index = main.waterbody_spot_list.item_count - 1
		if waterbody_id == PlayerData.current_waterbody and spot_id == PlayerData.current_spot:
			main.waterbody_spot_list.set_item_custom_bg_color(list_index, Color(0.12, 0.34, 0.22, 0.66))
			main.waterbody_spot_list.set_item_custom_fg_color(list_index, Color(0.80, 1.0, 0.82, 1.0))

		if spot_id == main._selected_waterbody_spot_id:
			selected_index = i

	if selected_index < 0 and not main._visible_waterbody_spots.is_empty():
		selected_index = 0
		if waterbody_id == PlayerData.current_waterbody:
			for i in main._visible_waterbody_spots.size():
				if str(main._visible_waterbody_spots[i].get("id", "")) == PlayerData.current_spot:
					selected_index = i
					break
		main._selected_waterbody_spot_id = str(main._visible_waterbody_spots[selected_index].get("id", ""))

	if selected_index >= 0:
		main.waterbody_spot_list.select(selected_index)

	main.waterbody_spot_details_label.text = _get_waterbody_spot_details_text(_get_selected_waterbody_spot())


func _get_selected_waterbody_spot() -> Dictionary:
	for spot in main._visible_waterbody_spots:
		if str(spot.get("id", "")) == main._selected_waterbody_spot_id:
			return spot

	return {}


func _get_waterbody_spot_details_text(spot: Dictionary) -> String:
	if spot.is_empty():
		return "Точка ловли не выбрана."

	var fish_names: Array = []
	var fish_pool: Array = spot.get("fish_pool", spot.get("available_fish", []))
	for fish_id in fish_pool:
		var fish = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue

		fish_names.append(str(fish.get("name", fish_id)))
		if fish_names.size() >= 7:
			break

	return "%s\n%s\nГлубина: %.1f-%.1f м  |  лучше %.1f м\nРыба: %s\n\n%s" % [
		str(spot.get("name", "-")),
		str(spot.get("spot_type", spot.get("type", "-"))),
		float(spot.get("min_depth", 0.2)),
		float(spot.get("max_depth", 6.0)),
		float(spot.get("preferred_depth", spot.get("depth", 1.0))),
		", ".join(fish_names),
		str(spot.get("description", ""))
	]


func _get_waterbody_details_text(waterbody: Dictionary) -> String:
	if waterbody.is_empty():
		return "Водоём не выбран."

	var waterbody_id = str(waterbody.get("id", ""))
	var required_level = int(waterbody.get("required_level", 1))
	var unlocked = PlayerData.can_use_waterbody(waterbody_id)
	var status = "Доступен" if unlocked else "Требуется LVL %d" % required_level
	var spots = SpotDatabase.get_spots_for_waterbody(waterbody_id)
	var spot_names: Array = []
	for spot in spots:
		spot_names.append(str(spot.get("name", "-")))

	return "%s\n%s\n\n%s\n\nОсновная рыба: %s\nТочки: %s\nФон: %s" % [
		str(waterbody.get("name", "-")),
		status,
		str(waterbody.get("description", "")),
		main._get_waterbody_fish_names(waterbody_id, 7),
		", ".join(spot_names),
		str(waterbody.get("background", "-"))
	]


func _get_waterbody_preview_color(waterbody_id: String) -> Color:
	match waterbody_id:
		"forest_lake":
			return Color(0.08, 0.22, 0.15, 0.88)
		"river_backwater":
			return Color(0.08, 0.16, 0.23, 0.88)
		_:
			return Color(0.12, 0.30, 0.27, 0.88)


func _on_waterbody_item_selected(index: int) -> void:
	if index < 0 or index >= main._visible_waterbodies.size():
		main._selected_waterbody_id = ""
	else:
		main._selected_waterbody_id = str(main._visible_waterbodies[index].get("id", ""))
		main._selected_waterbody_spot_id = ""

	_update_waterbody_ui()


func _on_waterbody_spot_item_selected(index: int) -> void:
	if index < 0 or index >= main._visible_waterbody_spots.size():
		main._selected_waterbody_spot_id = ""
	else:
		main._selected_waterbody_spot_id = str(main._visible_waterbody_spots[index].get("id", ""))

	_update_waterbody_ui()
