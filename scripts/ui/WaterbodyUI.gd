# Handles the waterbody window: waterbody list, spots, and preview.
extends RefCounted

var main
var theme
const WATERBODY_SPOTS_PER_PAGE := 4
const WATERBODY_PREVIEW_DEFAULT: Texture2D = preload("res://assets/environment/lake/lake_bg_base.png.png")

enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	_ensure_waterbody_ui_nodes()
	_ensure_waterbody_spot_pager_nodes()

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
	main._selected_waterbody_spot_id = PlayerData.current_spot
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

	main.waterbody_preview_frame = Panel.new()
	main.waterbody_preview_frame.name = "WaterbodyPreviewFrame"
	main.waterbody_preview_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.waterbody_preview_frame.clip_contents = true
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
	main.waterbody_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.waterbody_panel.add_child(main.waterbody_details_label)

	main.waterbody_spot_list = ItemList.new()
	main.waterbody_spot_list.name = "WaterbodySpotList"
	main.waterbody_spot_list.select_mode = ItemList.SELECT_SINGLE
	main.waterbody_spot_list.allow_reselect = true
	main.waterbody_spot_list.max_columns = 2
	main.waterbody_spot_list.same_column_width = true
	main.waterbody_panel.add_child(main.waterbody_spot_list)
	main.waterbody_spot_list.visible = false

	main.waterbody_spot_buttons = []
	for i in WATERBODY_SPOTS_PER_PAGE:
		var spot_button := Button.new()
		spot_button.name = "WaterbodySpotButton%d" % i
		spot_button.visible = false
		spot_button.focus_mode = Control.FOCUS_NONE
		spot_button.clip_text = true
		spot_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.waterbody_panel.add_child(spot_button)
		main.waterbody_spot_buttons.append(spot_button)
		spot_button.pressed.connect(_on_waterbody_spot_item_selected.bind(i))

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


func _ensure_waterbody_spot_pager_nodes() -> void:
	if main == null or main.waterbody_panel == null:
		return

	if main.waterbody_spot_prev_page_button == null:
		main.waterbody_spot_prev_page_button = Button.new()
		main.waterbody_spot_prev_page_button.name = "WaterbodySpotPrevPageButton"
		main.waterbody_spot_prev_page_button.text = "<"
		main.waterbody_spot_prev_page_button.focus_mode = Control.FOCUS_NONE
		main.waterbody_spot_prev_page_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.waterbody_spot_prev_page_button.z_index = 2
		main.waterbody_spot_prev_page_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.waterbody_panel.add_child(main.waterbody_spot_prev_page_button)
		main.waterbody_spot_prev_page_button.pressed.connect(_on_waterbody_spot_prev_page_pressed)

	if main.waterbody_spot_next_page_button == null:
		main.waterbody_spot_next_page_button = Button.new()
		main.waterbody_spot_next_page_button.name = "WaterbodySpotNextPageButton"
		main.waterbody_spot_next_page_button.text = ">"
		main.waterbody_spot_next_page_button.focus_mode = Control.FOCUS_NONE
		main.waterbody_spot_next_page_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.waterbody_spot_next_page_button.z_index = 2
		main.waterbody_spot_next_page_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.waterbody_panel.add_child(main.waterbody_spot_next_page_button)
		main.waterbody_spot_next_page_button.pressed.connect(_on_waterbody_spot_next_page_pressed)

	if main.waterbody_spot_page_label == null:
		main.waterbody_spot_page_label = Label.new()
		main.waterbody_spot_page_label.name = "WaterbodySpotPageLabel"
		main.waterbody_spot_page_label.text = ""
		main.waterbody_spot_page_label.z_index = 2
		main.waterbody_spot_page_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main.waterbody_spot_page_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.waterbody_panel.add_child(main.waterbody_spot_page_label)


func _update_waterbody_spot_pager(page_count: int, total_count: int) -> void:
	_ensure_waterbody_spot_pager_nodes()
	if main.waterbody_spot_prev_page_button == null or main.waterbody_spot_next_page_button == null or main.waterbody_spot_page_label == null:
		return

	var has_pages := total_count > WATERBODY_SPOTS_PER_PAGE
	main.waterbody_spot_prev_page_button.visible = has_pages
	main.waterbody_spot_next_page_button.visible = has_pages
	main.waterbody_spot_page_label.visible = has_pages
	main.waterbody_spot_prev_page_button.disabled = main._waterbody_spot_page <= 0
	main.waterbody_spot_next_page_button.disabled = main._waterbody_spot_page >= page_count - 1
	main.waterbody_spot_page_label.text = "%d / %d" % [main._waterbody_spot_page + 1, page_count]


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
	var can_change_spot: bool = main._fishing_ui_state == FishingUiState.IDLE or main._fishing_ui_state == FishingUiState.FAILED
	var has_selectable_spot: bool = can_select and not selected_spot.is_empty()
	main.waterbody_details_label.text = _get_waterbody_details_text(selected_waterbody)
	main.waterbody_preview.texture = _get_waterbody_preview_texture(str(selected_waterbody.get("id", "")))
	main.waterbody_select_button.disabled = not has_selectable_spot or (not is_current and not can_change_spot)
	if not has_selectable_spot:
		main.waterbody_select_button.text = "Выберите точку"
	elif is_current and not can_change_spot:
		main.waterbody_select_button.text = "Вернуться к ловле"
	elif is_current:
		main.waterbody_select_button.text = "Ловить здесь"
	elif not can_change_spot:
		main.waterbody_select_button.text = "Закончите ловлю"
	else:
		main.waterbody_select_button.text = "Ловить здесь"


func _get_selected_waterbody() -> Dictionary:
	for waterbody in main._visible_waterbodies:
		if str(waterbody.get("id", "")) == main._selected_waterbody_id:
			return waterbody

	return {}


func _update_waterbody_spot_picker(waterbody: Dictionary) -> void:
	if main.waterbody_spot_list == null:
		return

	main.waterbody_spot_list.clear()
	_update_waterbody_spot_buttons([], [], -1, 0)
	main._visible_waterbody_spots = []

	if waterbody.is_empty():
		main.waterbody_spot_details_label.text = "Точка ловли не выбрана."
		main._selected_waterbody_spot_id = ""
		_update_waterbody_spot_pager(1, 0)
		return

	var waterbody_id = str(waterbody.get("id", ""))
	main._visible_waterbody_spots = SpotDatabase.get_spots_for_waterbody(waterbody_id)
	var total_count: int = main._visible_waterbody_spots.size()
	var page_count: int = max(ceili(float(total_count) / float(WATERBODY_SPOTS_PER_PAGE)), 1)
	main._waterbody_spot_page = clampi(main._waterbody_spot_page, 0, page_count - 1)
	var selected_index := -1
	var spot_labels: Array = []
	var spot_current_flags: Array = []

	for i in total_count:
		var spot: Dictionary = main._visible_waterbody_spots[i]
		var spot_id = str(spot.get("id", ""))
		var label = "%s  %.1f-%.1f м" % [
			str(spot.get("name", "-")),
			float(spot.get("min_depth", 0.2)),
			float(spot.get("max_depth", 6.0))
		]
		if waterbody_id == PlayerData.current_waterbody and spot_id == PlayerData.current_spot:
			label = "%s  |  текущая" % label
		spot_labels.append(label)
		spot_current_flags.append(waterbody_id == PlayerData.current_waterbody and spot_id == PlayerData.current_spot)

		main.waterbody_spot_list.add_item(str(spot_labels[i]))
		var list_index = main.waterbody_spot_list.item_count - 1
		if bool(spot_current_flags[i]):
			main.waterbody_spot_list.set_item_custom_bg_color(list_index, Color(0.12, 0.34, 0.22, 0.66))
			main.waterbody_spot_list.set_item_custom_fg_color(list_index, Color(0.80, 1.0, 0.82, 1.0))

		if spot_id == main._selected_waterbody_spot_id:
			selected_index = i

	if selected_index < 0 and not main._visible_waterbody_spots.is_empty():
		selected_index = mini(main._waterbody_spot_page * WATERBODY_SPOTS_PER_PAGE, total_count - 1)
		main._selected_waterbody_spot_id = str(main._visible_waterbody_spots[selected_index].get("id", ""))

	if selected_index >= 0:
		main._waterbody_spot_page = int(selected_index / WATERBODY_SPOTS_PER_PAGE)

	var page_start: int = main._waterbody_spot_page * WATERBODY_SPOTS_PER_PAGE
	var page_end: int = mini(page_start + WATERBODY_SPOTS_PER_PAGE, total_count)
	main.waterbody_spot_list.clear()
	var page_labels: Array = []
	var page_current_flags: Array = []

	for i in range(page_start, page_end):
		var spot: Dictionary = main._visible_waterbody_spots[i]
		var spot_id = str(spot.get("id", ""))
		var label = "%s  %.1f-%.1f м" % [
			str(spot.get("name", "-")),
			float(spot.get("min_depth", 0.2)),
			float(spot.get("max_depth", 6.0))
		]
		if waterbody_id == PlayerData.current_waterbody and spot_id == PlayerData.current_spot:
			label = "%s  |  текущая" % label
		page_labels.append(label)
		page_current_flags.append(waterbody_id == PlayerData.current_waterbody and spot_id == PlayerData.current_spot)

		main.waterbody_spot_list.add_item(str(page_labels[page_labels.size() - 1]))
		var list_index = main.waterbody_spot_list.item_count - 1
		if bool(page_current_flags[page_current_flags.size() - 1]):
			main.waterbody_spot_list.set_item_custom_bg_color(list_index, Color(0.12, 0.34, 0.22, 0.66))
			main.waterbody_spot_list.set_item_custom_fg_color(list_index, Color(0.80, 1.0, 0.82, 1.0))

	if selected_index >= page_start and selected_index < page_end:
		main.waterbody_spot_list.select(selected_index - page_start)

	_update_waterbody_spot_buttons(page_labels, page_current_flags, selected_index - page_start, page_start)
	_update_waterbody_spot_pager(page_count, total_count)

	main.waterbody_spot_details_label.text = _get_waterbody_spot_details_text(_get_selected_waterbody_spot())


func _update_waterbody_spot_buttons(page_labels: Array, page_current_flags: Array, selected_page_index: int, _page_start: int) -> void:
	for i in main.waterbody_spot_buttons.size():
		var button := main.waterbody_spot_buttons[i] as Button
		if button == null:
			continue

		var has_item: bool = i < page_labels.size()
		button.visible = has_item
		button.disabled = not has_item
		if not has_item:
			button.text = ""
			continue

		var is_selected: bool = i == selected_page_index
		var is_current: bool = bool(page_current_flags[i])
		button.text = str(page_labels[i])
		button.add_theme_font_size_override("font_size", 15)
		button.add_theme_color_override("font_color", Color(0.90, 1.0, 0.90, 1.0))
		button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(0.82, 0.98, 0.82, 1.0))
		button.add_theme_color_override("font_disabled_color", Color(0.56, 0.64, 0.60, 0.82))
		button.add_theme_stylebox_override(
			"normal",
			main._make_panel_style(
				Color(0.035, 0.060, 0.058, 0.82) if not is_selected else Color(0.095, 0.260, 0.150, 0.90),
				Color(0.62, 0.95, 0.66, 0.42) if is_selected or is_current else Color(0.64, 0.78, 0.70, 0.22),
				12,
				5,
				Color(0.0, 0.0, 0.0, 0.22)
			)
		)
		button.add_theme_stylebox_override(
			"hover",
			main._make_panel_style(Color(0.075, 0.185, 0.112, 0.94), Color(0.72, 1.0, 0.74, 0.58), 12, 6, Color(0.0, 0.0, 0.0, 0.24))
		)
		button.add_theme_stylebox_override(
			"pressed",
			main._make_panel_style(Color(0.040, 0.118, 0.072, 0.96), Color(0.62, 0.92, 0.62, 0.64), 12, 4, Color(0.0, 0.0, 0.0, 0.18))
		)


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


func _get_waterbody_preview_texture(_waterbody_id: String) -> Texture2D:
	return WATERBODY_PREVIEW_DEFAULT


func _on_waterbody_item_selected(index: int) -> void:
	if index < 0 or index >= main._visible_waterbodies.size():
		main._selected_waterbody_id = ""
	else:
		main._selected_waterbody_id = str(main._visible_waterbodies[index].get("id", ""))
		main._waterbody_spot_page = 0
		main._selected_waterbody_spot_id = ""

	_update_waterbody_ui()


func _on_waterbody_spot_item_selected(index: int) -> void:
	var spot_index: int = main._waterbody_spot_page * WATERBODY_SPOTS_PER_PAGE + index
	if spot_index < 0 or spot_index >= main._visible_waterbody_spots.size():
		main._selected_waterbody_spot_id = ""
	else:
		main._selected_waterbody_spot_id = str(main._visible_waterbody_spots[spot_index].get("id", ""))

	_update_waterbody_ui()


func _on_waterbody_spot_prev_page_pressed() -> void:
	if main._waterbody_spot_page <= 0:
		return

	main._waterbody_spot_page -= 1
	main._selected_waterbody_spot_id = ""
	_update_waterbody_ui()


func _on_waterbody_spot_next_page_pressed() -> void:
	var total_count: int = main._visible_waterbody_spots.size()
	var page_count: int = max(ceili(float(total_count) / float(WATERBODY_SPOTS_PER_PAGE)), 1)
	if main._waterbody_spot_page >= page_count - 1:
		return

	main._waterbody_spot_page += 1
	main._selected_waterbody_spot_id = ""
	_update_waterbody_ui()
