# Handles tackle assembly: tabs, item choice, comparison, and hints.
extends RefCounted

var main
var theme
const TACKLE_ITEMS_PER_PAGE := 7
const TACKLE_COLOR_GOLD := Color(0.94, 0.70, 0.28, 1.0)
const TACKLE_COLOR_TEXT := Color(0.88, 0.96, 0.94, 0.96)
const TACKLE_COLOR_SUCCESS := Color(0.46, 0.95, 0.60, 1.0)
const TACKLE_COLOR_WARNING := Color(1.0, 0.64, 0.28, 1.0)
var _picker_open := false
var _rod_info_open := false
var _texture_cache: Dictionary = {}

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
	_ensure_tackle_ui_nodes()
	_ensure_tackle_pager_nodes()

func open() -> void:
	if main._is_catch_reward_open():
		return

	main.open_modal("tackle")
	main._active_nav_tab = "tackle"
	main.tackle_backdrop.visible = true
	main.tackle_panel.visible = true
	_picker_open = false
	_rod_info_open = false
	main._selected_tackle_item_id = ""
	refresh()
	if main.has_method("refresh_mobile_scroll_helper"):
		main.refresh_mobile_scroll_helper()
	main._refresh_bottom_nav_styles()

func close() -> void:
	if main == null or main.tackle_panel == null:
		return

	main.tackle_panel.visible = false
	main.tackle_backdrop.visible = false
	main.close_modal("tackle")
	main._active_nav_tab = "fish"
	main._refresh_bottom_nav_styles()

func close_item_picker(refresh_ui := true) -> void:
	_picker_open = false
	main._selected_tackle_item_id = ""
	if refresh_ui:
		_update_tackle_ui()

func refresh() -> void:
	_update_tackle_ui()

func refresh_ui() -> void:
	if main.tackle_panel == null:
		return

	_refresh_visible_tackle_items()
	refresh_slots()
	refresh_selected_item()
	refresh_stats()
	refresh_validation_status()

func refresh_slots() -> void:
	main.tackle_title_label.text = "Сборка снасти"
	main.tackle_depth_label.visible = false
	main.tackle_depth_minus_button.visible = false
	main.tackle_depth_plus_button.visible = false

	var slot_buttons: Array = [
		[main.tackle_line_button, "line"],
		[main.tackle_leader_button, "leader"],
		[main.tackle_hook_button, "hook"],
		[main.tackle_float_button, "float"],
		[main.tackle_bait_button, "bait"],
		[main.tackle_bait_2_button, "bait_2"]
	]

	for item in slot_buttons:
		var button: Button = item[0]
		var category: String = item[1]
		button.text = _get_tackle_slot_button_text(category)
		button.icon = _get_tackle_slot_texture(category)
		button.expand_icon = false
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		button.add_theme_constant_override("icon_max_width", 40 if button.icon != null else 0)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.clip_text = true
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		theme.apply_tackle_slot_button_style(button, _get_tackle_slot_state(category))
		button.add_theme_font_size_override("font_size", 12)
		button.add_theme_constant_override("h_separation", 12)

	main.tackle_title_label.text = "Сборка снасти · %s" % PlayerData.get_current_tackle_type_title()
	for legacy_button in [main.tackle_line_button, main.tackle_leader_button, main.tackle_hook_button, main.tackle_float_button, main.tackle_bait_button, main.tackle_bait_2_button]:
		if legacy_button != null:
			legacy_button.visible = false
	_refresh_schema_slot_buttons()

	main.tackle_rod_button.text = ""
	main.tackle_rod_button.tooltip_text = "Выбрать удочку"
	main.tackle_rod_button.icon = _get_rod_button_texture()
	main.tackle_rod_button.expand_icon = main.tackle_rod_button.icon != null
	main.tackle_rod_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.tackle_rod_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	main.tackle_rod_button.add_theme_constant_override("icon_max_width", 999 if main.tackle_rod_button.icon != null else 0)
	main.tackle_rod_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.tackle_rod_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.tackle_rod_button.clip_text = true
	main.tackle_rod_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	theme.apply_tackle_slot_button_style(main.tackle_rod_button, _get_tackle_slot_state("rod"))
	main.tackle_rod_button.add_theme_font_size_override("font_size", 13)
	if main.tackle_rod_name_label != null:
		main.tackle_rod_name_label.text = _get_rod_showcase_title_text()
		main.tackle_rod_name_label.tooltip_text = _get_rod_showcase_name()
	if main.tackle_info_button != null:
		main.tackle_info_button.visible = true
		main.tackle_info_button.text = "×" if _picker_open else "i"
		main.tackle_info_button.tooltip_text = "Закрыть выбор" if _picker_open else "Информация об удочке"
		_apply_info_button_style(main.tackle_info_button, _rod_info_open or _picker_open)
		main.tackle_info_button.add_theme_font_size_override("font_size", 18)
		main.tackle_info_button.add_theme_constant_override("h_separation", 0)
	_refresh_rod_surface_visibility()


func _refresh_schema_slot_buttons() -> void:
	if main.tackle_slot_list == null:
		return

	var active_slots: Dictionary = {}
	var slot_schemas := PlayerData.get_tackle_schema_slots()
	for i in slot_schemas.size():
		var slot_schema: Dictionary = slot_schemas[i]
		var slot_id := str(slot_schema.get("id", ""))
		if slot_id == "":
			continue
		active_slots[slot_id] = true

		var existing_button = main.tackle_slot_buttons.get(slot_id, null)
		var button: Button = existing_button if existing_button is Button else null
		if button == null:
			button = Button.new()
			button.name = "TackleSlot_%s" % slot_id
			button.focus_mode = Control.FOCUS_NONE
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.custom_minimum_size = Vector2(0.0, 70.0)
			button.pressed.connect(_set_tackle_category.bind(slot_id))
			main.tackle_slot_buttons[slot_id] = button

		if button.get_parent() != main.tackle_slot_list:
			if button.get_parent() != null:
				button.get_parent().remove_child(button)
			main.tackle_slot_list.add_child(button)
		main.tackle_slot_list.move_child(button, i)

		button.visible = true
		button.disabled = false
		button.text = _get_tackle_slot_card_text(slot_schema, i + 1)
		button.icon = _get_tackle_slot_texture(slot_id)
		button.expand_icon = false
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		button.add_theme_constant_override("icon_max_width", 42 if button.icon != null else 0)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.clip_text = true
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.tooltip_text = _get_tackle_slot_tooltip(slot_id)
		button.add_theme_font_size_override("font_size", 12)
		button.add_theme_constant_override("h_separation", 12)
		theme.apply_tackle_slot_button_style(button, _get_tackle_slot_state(slot_id))

	for slot_id in main.tackle_slot_buttons.keys():
		if not active_slots.has(str(slot_id)):
			var stale_button = main.tackle_slot_buttons[slot_id]
			if stale_button is Button:
				(stale_button as Button).visible = false


func _get_tackle_slot_card_text(slot_schema: Dictionary, order: int) -> String:
	var slot_id := str(slot_schema.get("id", ""))
	var title := str(slot_schema.get("title", _get_tackle_slot_title(slot_id)))
	var status := _get_tackle_slot_status_text(slot_id)
	var equipped_name := _get_tackle_slot_equipped_name(slot_id)
	var param_text := _get_tackle_slot_param_text(slot_id)
	var marker := "обязательный" if bool(slot_schema.get("required", false)) else "опционально"
	return "%d. %s  %s\n%s\n%s" % [order, title, status, equipped_name, param_text if param_text != "" else marker]


func _get_tackle_slot_tooltip(slot_id: String) -> String:
	if PlayerData.is_tackle_slot_locked(slot_id):
		return PlayerData.get_tackle_slot_lock_reason(slot_id)
	return _get_tackle_slot_title(slot_id)


func _get_tackle_slot_status_text(slot_id: String) -> String:
	var state := _get_tackle_slot_state(slot_id)
	match state:
		"locked":
			return "Требуется навык"
		"selected":
			return "Выбор"
		"filled":
			return "Надето"
		_:
			return "Не выбрано"


func _apply_info_button_style(button: Button, active: bool) -> void:
	button.add_theme_stylebox_override("normal", _make_info_button_style(active, "normal"))
	button.add_theme_stylebox_override("hover", _make_info_button_style(active, "hover"))
	button.add_theme_stylebox_override("pressed", _make_info_button_style(active, "pressed"))
	button.add_theme_stylebox_override("focus", _make_info_button_style(true, "normal"))
	button.add_theme_color_override("font_color", TACKLE_COLOR_GOLD if active else Color(0.76, 0.92, 0.96, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.88, 0.58, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.96, 0.76, 0.42, 1.0))


func _make_info_button_style(active: bool, state: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.018, 0.062, 0.084, 0.92)
	style.border_color = TACKLE_COLOR_GOLD if active else Color(0.44, 0.84, 0.92, 0.64)
	if state == "hover":
		style.bg_color = Color(0.035, 0.095, 0.120, 0.96)
		style.border_color = TACKLE_COLOR_GOLD
	elif state == "pressed":
		style.bg_color = Color(0.060, 0.075, 0.070, 0.98)
	style.set_border_width_all(1)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.24)
	style.shadow_size = 5
	return style

func refresh_selected_item() -> void:
	var selected_item := _get_selected_tackle_item()
	if main._tackle_category == "bait_2" and not PlayerData.can_use_second_bait():
		main.tackle_details_label.text = "Описание\nНаживка 2 открывается навыком «Ловля на бутерброд». До изучения она не участвует в проверке снасти."
	elif _rod_info_open and not _picker_open:
		main.tackle_details_label.text = _get_rod_description_text()
	elif _picker_open and selected_item.is_empty():
		main.tackle_details_label.text = "Описание\nНет предметов для слота «%s». Купите их в магазине или проверьте инвентарь." % _get_tackle_slot_title(main._tackle_category)
	elif _picker_open:
		main.tackle_details_label.text = _get_selected_item_card_text(selected_item)
	else:
		main.tackle_details_label.text = _get_rod_description_text()

func refresh_stats() -> void:
	main.tackle_current_label.text = _get_rod_stats_grid_text()
	main.tackle_compare_label.text = _get_final_tackle_stats_text()
	_refresh_rod_surface_visibility()

func refresh_validation_status() -> void:
	var selected_item: Dictionary = _get_selected_tackle_item()
	var block_reason: String = _get_equip_block_reason(selected_item, main._tackle_category) if not selected_item.is_empty() else ""
	var validation: Dictionary = _get_current_tackle_validation()
	var issues: Array = PlayerData.get_tackle_setup_issues()
	var tackle_valid: bool = bool(validation.get("usable", issues.is_empty())) and issues.is_empty()
	var can_change_tackle: bool = main._fishing_ui_state == FishingUiState.IDLE
	var can_equip_selected: bool = _picker_open and not selected_item.is_empty() and block_reason == "" and not _is_tackle_item_equipped(selected_item) and can_change_tackle

	main.tackle_hint_label.visible = true
	main.tackle_hint_label.text = _get_validation_status_line(issues, tackle_valid)
	main.tackle_hint_label.add_theme_color_override("font_color", TACKLE_COLOR_SUCCESS if tackle_valid else TACKLE_COLOR_WARNING)
	main.tackle_compare_label.add_theme_color_override("font_color", TACKLE_COLOR_TEXT if tackle_valid else Color(0.96, 0.78, 0.54, 0.96))

	main.tackle_equip_button.visible = true
	if _picker_open:
		main.tackle_equip_button.disabled = not can_equip_selected
		if not can_change_tackle:
			main.tackle_equip_button.text = "Только вне ловли"
		elif _is_tackle_item_equipped(selected_item):
			main.tackle_equip_button.text = "Уже экипировано"
		elif main._tackle_category == "bait_2" and not PlayerData.can_use_second_bait():
			main.tackle_equip_button.text = "Закрыто"
		elif selected_item.is_empty():
			main.tackle_equip_button.text = "Нет предметов"
		elif block_reason != "":
			main.tackle_equip_button.text = "Недоступно"
		else:
			main.tackle_equip_button.text = "Экипировать"
	else:
		main.tackle_equip_button.disabled = true
		main.tackle_equip_button.text = "Уже экипировано" if tackle_valid else "Не готово"

	if not _picker_open:
		main.tackle_equip_button.disabled = false
		main.tackle_equip_button.text = "Готово"

	if main.tackle_clear_button != null:
		main.tackle_clear_button.visible = true
		main.tackle_clear_button.disabled = not can_change_tackle or PlayerData.is_tackle_slot_locked(main._tackle_category)
		main.tackle_clear_button.text = "Снять"
	if main.tackle_auto_button != null:
		main.tackle_auto_button.visible = true
		main.tackle_auto_button.disabled = not can_change_tackle
		main.tackle_auto_button.text = "Автосборка"

	var can_repair: bool = _picker_open and not selected_item.is_empty() and _can_repair_item(selected_item)
	var can_discard: bool = _picker_open and not selected_item.is_empty() and _can_discard_item(selected_item)
	if main.tackle_repair_button != null:
		main.tackle_repair_button.visible = can_repair
		main.tackle_repair_button.disabled = not can_repair
		main.tackle_repair_button.text = "Починить"
	if main.tackle_discard_button != null:
		main.tackle_discard_button.visible = can_discard
		main.tackle_discard_button.disabled = not can_discard
		main.tackle_discard_button.text = "Выбросить"

func on_slot_pressed(slot_type: String) -> void:
	_set_tackle_category(slot_type)

func on_equip_pressed() -> void:
	main._on_tackle_equip_button_pressed()

func on_close_pressed() -> void:
	main._on_tackle_close_button_pressed()

func is_open() -> bool:
	return main != null and main.tackle_panel != null and main.tackle_panel.visible

func is_item_picker_open() -> bool:
	return _picker_open

func _refresh_rod_surface_visibility() -> void:
	var locked_second_bait: bool = main._tackle_category == "bait_2" and not PlayerData.can_use_second_bait()
	var show_picker: bool = _picker_open and not locked_second_bait
	var show_info: bool = _rod_info_open and not show_picker
	var show_showcase: bool = not show_info and not show_picker
	main.tackle_rod_button.visible = show_showcase
	if main.tackle_rod_name_label != null:
		main.tackle_rod_name_label.visible = show_showcase
	main.tackle_rod_stats_panel.visible = show_info
	main.tackle_rod_description_panel.visible = show_info
	main.tackle_current_label.visible = show_info
	main.tackle_details_label.visible = show_info
	main.tackle_final_stats_panel.visible = show_info
	main.tackle_compare_label.visible = show_info

func _ensure_tackle_ui_nodes() -> void:
	if main.tackle_panel != null:
		return

	main.tackle_backdrop = ColorRect.new()
	main.tackle_backdrop.name = "TackleBackdrop"
	main.tackle_backdrop.visible = false
	main.tackle_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	main.tackle_backdrop.color = Color(0.0, 0.0, 0.0, 0.54)
	main.add_child(main.tackle_backdrop)

	main.tackle_panel = Panel.new()
	main.tackle_panel.name = "TacklePanel"
	main.tackle_panel.visible = false
	main.tackle_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	main.add_child(main.tackle_panel)

	main.tackle_left_panel = Panel.new()
	main.tackle_left_panel.name = "TackleLeftPanel"
	main.tackle_panel.add_child(main.tackle_left_panel)

	main.tackle_center_panel = Panel.new()
	main.tackle_center_panel.name = "TackleCenterPanel"
	main.tackle_panel.add_child(main.tackle_center_panel)

	main.tackle_right_panel = Panel.new()
	main.tackle_right_panel.name = "TackleRightPanel"
	main.tackle_panel.add_child(main.tackle_right_panel)

	main.tackle_slot_scroll = ScrollContainer.new()
	main.tackle_slot_scroll.name = "TackleSlotScroll"
	main.tackle_slot_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main.tackle_slot_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	main.tackle_panel.add_child(main.tackle_slot_scroll)

	main.tackle_slot_list = VBoxContainer.new()
	main.tackle_slot_list.name = "TackleSlotList"
	main.tackle_slot_list.add_theme_constant_override("separation", 8)
	main.tackle_slot_scroll.add_child(main.tackle_slot_list)

	main.tackle_action_bar_panel = Panel.new()
	main.tackle_action_bar_panel.name = "TackleActionBarPanel"
	main.tackle_panel.add_child(main.tackle_action_bar_panel)

	main.tackle_rod_stats_panel = Panel.new()
	main.tackle_rod_stats_panel.name = "TackleRodStatsPanel"
	main.tackle_panel.add_child(main.tackle_rod_stats_panel)

	main.tackle_rod_description_panel = Panel.new()
	main.tackle_rod_description_panel.name = "TackleRodDescriptionPanel"
	main.tackle_panel.add_child(main.tackle_rod_description_panel)

	main.tackle_final_stats_panel = Panel.new()
	main.tackle_final_stats_panel.name = "TackleFinalStatsPanel"
	main.tackle_panel.add_child(main.tackle_final_stats_panel)

	main.tackle_title_divider_left = ColorRect.new()
	main.tackle_title_divider_left.name = "TackleTitleDividerLeft"
	main.tackle_panel.add_child(main.tackle_title_divider_left)

	main.tackle_title_divider_right = ColorRect.new()
	main.tackle_title_divider_right.name = "TackleTitleDividerRight"
	main.tackle_panel.add_child(main.tackle_title_divider_right)

	main.tackle_title_label = Label.new()
	main.tackle_title_label.name = "TackleTitleLabel"
	main.tackle_title_label.text = "Снасти"
	main.tackle_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.tackle_panel.add_child(main.tackle_title_label)

	main.tackle_current_label = Label.new()
	main.tackle_current_label.name = "TackleCurrentLabel"
	main.tackle_current_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.tackle_panel.add_child(main.tackle_current_label)

	main.tackle_picker_title_label = Label.new()
	main.tackle_picker_title_label.name = "TacklePickerTitleLabel"
	main.tackle_picker_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.tackle_picker_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.tackle_panel.add_child(main.tackle_picker_title_label)

	main.tackle_visual_title_label = Label.new()
	main.tackle_visual_title_label.name = "TackleVisualTitleLabel"
	main.tackle_visual_title_label.text = "Схема снасти"
	main.tackle_visual_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.tackle_visual_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.tackle_panel.add_child(main.tackle_visual_title_label)

	main.tackle_visual_rod_line = Line2D.new()
	main.tackle_visual_rod_line.name = "TackleVisualRodLine"
	main.tackle_visual_rod_line.width = 5.0
	main.tackle_visual_rod_line.default_color = Color(0.80, 0.55, 0.27, 0.95)
	main.tackle_panel.add_child(main.tackle_visual_rod_line)

	main.tackle_visual_main_line = Line2D.new()
	main.tackle_visual_main_line.name = "TackleVisualMainLine"
	main.tackle_visual_main_line.width = 2.0
	main.tackle_visual_main_line.default_color = Color(0.68, 0.86, 0.92, 0.80)
	main.tackle_panel.add_child(main.tackle_visual_main_line)

	main.tackle_visual_leader_line = Line2D.new()
	main.tackle_visual_leader_line.name = "TackleVisualLeaderLine"
	main.tackle_visual_leader_line.width = 2.0
	main.tackle_visual_leader_line.default_color = Color(0.92, 0.78, 0.48, 0.78)
	main.tackle_panel.add_child(main.tackle_visual_leader_line)

	main.tackle_visual_float_marker = ColorRect.new()
	main.tackle_visual_float_marker.name = "TackleVisualFloatMarker"
	main.tackle_panel.add_child(main.tackle_visual_float_marker)

	main.tackle_visual_hook_marker = Label.new()
	main.tackle_visual_hook_marker.name = "TackleVisualHookMarker"
	main.tackle_visual_hook_marker.text = "J"
	main.tackle_visual_hook_marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.tackle_visual_hook_marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.tackle_panel.add_child(main.tackle_visual_hook_marker)

	main.tackle_visual_bait_marker = Label.new()
	main.tackle_visual_bait_marker.name = "TackleVisualBaitMarker"
	main.tackle_visual_bait_marker.text = "•"
	main.tackle_visual_bait_marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.tackle_visual_bait_marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.tackle_panel.add_child(main.tackle_visual_bait_marker)

	main.tackle_visual_bait_2_marker = Label.new()
	main.tackle_visual_bait_2_marker.name = "TackleVisualBait2Marker"
	main.tackle_visual_bait_2_marker.text = "+"
	main.tackle_visual_bait_2_marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.tackle_visual_bait_2_marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.tackle_panel.add_child(main.tackle_visual_bait_2_marker)

	main.tackle_visual_line_label = _create_visual_label("TackleVisualLineLabel")
	main.tackle_visual_float_label = _create_visual_label("TackleVisualFloatLabel")
	main.tackle_visual_leader_label = _create_visual_label("TackleVisualLeaderLabel")
	main.tackle_visual_hook_label = _create_visual_label("TackleVisualHookLabel")
	main.tackle_visual_bait_label = _create_visual_label("TackleVisualBaitLabel")
	main.tackle_visual_bait_2_label = _create_visual_label("TackleVisualBait2Label")

	main.tackle_rod_button = Button.new()
	main.tackle_rod_button.name = "TackleRodButton"
	main.tackle_rod_button.text = "Удочки"
	main.tackle_panel.add_child(main.tackle_rod_button)

	main.tackle_rod_name_label = Label.new()
	main.tackle_rod_name_label.name = "TackleRodNameLabel"
	main.tackle_rod_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.tackle_rod_name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	main.tackle_rod_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.tackle_panel.add_child(main.tackle_rod_name_label)

	main.tackle_line_button = Button.new()
	main.tackle_line_button.name = "TackleLineButton"
	main.tackle_line_button.text = "Лески"
	main.tackle_panel.add_child(main.tackle_line_button)

	main.tackle_leader_button = Button.new()
	main.tackle_leader_button.name = "TackleLeaderButton"
	main.tackle_leader_button.text = "Поводок"
	main.tackle_panel.add_child(main.tackle_leader_button)

	main.tackle_float_button = Button.new()
	main.tackle_float_button.name = "TackleFloatButton"
	main.tackle_float_button.text = "Поплавки"
	main.tackle_panel.add_child(main.tackle_float_button)

	main.tackle_hook_button = Button.new()
	main.tackle_hook_button.name = "TackleHookButton"
	main.tackle_hook_button.text = "Крючки"
	main.tackle_panel.add_child(main.tackle_hook_button)

	main.tackle_bait_button = Button.new()
	main.tackle_bait_button.name = "TackleBaitButton"
	main.tackle_bait_button.text = "Наживки"
	main.tackle_panel.add_child(main.tackle_bait_button)

	main.tackle_bait_2_button = Button.new()
	main.tackle_bait_2_button.name = "TackleBait2Button"
	main.tackle_bait_2_button.text = "Наживка 2"
	main.tackle_panel.add_child(main.tackle_bait_2_button)

	main.tackle_info_button = Button.new()
	main.tackle_info_button.name = "TackleInfoButton"
	main.tackle_info_button.text = "i"
	main.tackle_info_button.focus_mode = Control.FOCUS_NONE
	main.tackle_info_button.mouse_filter = Control.MOUSE_FILTER_STOP
	main.tackle_info_button.pressed.connect(_on_tackle_info_button_pressed)
	main.tackle_panel.add_child(main.tackle_info_button)

	main.tackle_item_list = ItemList.new()
	main.tackle_item_list.name = "TackleItemList"
	main.tackle_item_list.select_mode = ItemList.SELECT_SINGLE
	main.tackle_item_list.allow_reselect = true
	main.tackle_panel.add_child(main.tackle_item_list)

	main.tackle_details_label = Label.new()
	main.tackle_details_label.name = "TackleDetailsLabel"
	main.tackle_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.tackle_panel.add_child(main.tackle_details_label)

	main.tackle_compare_label = Label.new()
	main.tackle_compare_label.name = "TackleCompareLabel"
	main.tackle_compare_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.tackle_panel.add_child(main.tackle_compare_label)

	main.tackle_depth_label = Label.new()
	main.tackle_depth_label.name = "TackleDepthLabel"
	main.tackle_depth_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.tackle_panel.add_child(main.tackle_depth_label)

	main.tackle_depth_minus_button = Button.new()
	main.tackle_depth_minus_button.name = "TackleDepthMinusButton"
	main.tackle_depth_minus_button.text = "-"
	main.tackle_panel.add_child(main.tackle_depth_minus_button)

	main.tackle_depth_plus_button = Button.new()
	main.tackle_depth_plus_button.name = "TackleDepthPlusButton"
	main.tackle_depth_plus_button.text = "+"
	main.tackle_panel.add_child(main.tackle_depth_plus_button)

	main.tackle_hint_label = Label.new()
	main.tackle_hint_label.name = "TackleHintLabel"
	main.tackle_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.tackle_panel.add_child(main.tackle_hint_label)

	main.tackle_equip_button = Button.new()
	main.tackle_equip_button.name = "TackleEquipButton"
	main.tackle_equip_button.text = "Экипировать"
	main.tackle_panel.add_child(main.tackle_equip_button)

	main.tackle_clear_button = Button.new()
	main.tackle_clear_button.name = "TackleClearButton"
	main.tackle_clear_button.text = "Снять"
	main.tackle_clear_button.pressed.connect(_on_tackle_clear_button_pressed)
	main.tackle_panel.add_child(main.tackle_clear_button)

	main.tackle_auto_button = Button.new()
	main.tackle_auto_button.name = "TackleAutoButton"
	main.tackle_auto_button.text = "Автосборка"
	main.tackle_auto_button.pressed.connect(_on_tackle_auto_button_pressed)
	main.tackle_panel.add_child(main.tackle_auto_button)

	main.tackle_repair_button = Button.new()
	main.tackle_repair_button.name = "TackleRepairButton"
	main.tackle_repair_button.text = "Починить"
	main.tackle_panel.add_child(main.tackle_repair_button)

	main.tackle_discard_button = Button.new()
	main.tackle_discard_button.name = "TackleDiscardButton"
	main.tackle_discard_button.text = "Выбросить"
	main.tackle_panel.add_child(main.tackle_discard_button)

	main.tackle_close_button = Button.new()
	main.tackle_close_button.name = "TackleCloseButton"
	main.tackle_close_button.text = "Закрыть"
	main.tackle_panel.add_child(main.tackle_close_button)

	main.toast_label = Label.new()
	main.toast_label.name = "ToastLabel"
	main.toast_label.visible = false
	main.toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.add_child(main.toast_label)


func _create_visual_label(node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(0.84, 0.94, 0.92, 0.94))
	main.tackle_panel.add_child(label)
	return label


func _ensure_tackle_pager_nodes() -> void:
	if main == null or main.tackle_panel == null:
		return

	if main.tackle_prev_page_button == null:
		main.tackle_prev_page_button = Button.new()
		main.tackle_prev_page_button.name = "TacklePrevPageButton"
		main.tackle_prev_page_button.text = "<"
		main.tackle_prev_page_button.focus_mode = Control.FOCUS_NONE
		main.tackle_prev_page_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.tackle_prev_page_button.z_index = 2
		main.tackle_prev_page_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.tackle_panel.add_child(main.tackle_prev_page_button)
		main.tackle_prev_page_button.pressed.connect(_on_tackle_prev_page_pressed)

	if main.tackle_next_page_button == null:
		main.tackle_next_page_button = Button.new()
		main.tackle_next_page_button.name = "TackleNextPageButton"
		main.tackle_next_page_button.text = ">"
		main.tackle_next_page_button.focus_mode = Control.FOCUS_NONE
		main.tackle_next_page_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.tackle_next_page_button.z_index = 2
		main.tackle_next_page_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.tackle_panel.add_child(main.tackle_next_page_button)
		main.tackle_next_page_button.pressed.connect(_on_tackle_next_page_pressed)

	if main.tackle_page_label == null:
		main.tackle_page_label = Label.new()
		main.tackle_page_label.name = "TacklePageLabel"
		main.tackle_page_label.text = ""
		main.tackle_page_label.z_index = 2
		main.tackle_page_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main.tackle_page_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.tackle_panel.add_child(main.tackle_page_label)


func _update_tackle_pager(page_count: int, total_count: int) -> void:
	_ensure_tackle_pager_nodes()
	if main.tackle_prev_page_button == null or main.tackle_next_page_button == null or main.tackle_page_label == null:
		return

	var items_per_page := _get_tackle_items_per_page()
	var has_pages: bool = _picker_open and total_count > items_per_page
	main.tackle_prev_page_button.visible = has_pages
	main.tackle_next_page_button.visible = has_pages
	main.tackle_page_label.visible = has_pages
	main.tackle_prev_page_button.disabled = main._tackle_page <= 0
	main.tackle_next_page_button.disabled = main._tackle_page >= page_count - 1
	main.tackle_page_label.text = "%d / %d" % [main._tackle_page + 1, page_count]


func _update_tackle_ui() -> void:
	if main.tackle_panel == null:
		return

	refresh_ui()


func _refresh_visible_tackle_items() -> void:
	if PlayerData.is_tackle_slot_locked(main._tackle_category):
		main._visible_tackle_items = []
	else:
		main._visible_tackle_items = _get_visible_tackle_items_for_slot(main._tackle_category)
	main.tackle_item_list.clear()
	_configure_tackle_item_list_for_category(main._tackle_category)

	var total_count: int = main._visible_tackle_items.size()
	var items_per_page := _get_tackle_items_per_page()
	var page_count: int = max(ceili(float(total_count) / float(items_per_page)), 1)
	main._tackle_page = clampi(main._tackle_page, 0, page_count - 1)

	var page_start: int = main._tackle_page * items_per_page
	var page_end: int = mini(page_start + items_per_page, total_count)
	var selected_index := -1

	for i in total_count:
		var item: Dictionary = main._visible_tackle_items[i]
		if str(item.get("id", "")) == main._selected_tackle_item_id:
			selected_index = i
			break

	if selected_index < page_start or selected_index >= page_end:
		if _picker_open and page_start < page_end:
			selected_index = page_start
			main._selected_tackle_item_id = str(main._visible_tackle_items[selected_index].get("id", ""))
		else:
			selected_index = -1
			main._selected_tackle_item_id = ""

	for i in range(page_start, page_end):
		var item: Dictionary = main._visible_tackle_items[i]
		main.tackle_item_list.add_item(_get_tackle_item_display_text(item), _get_item_texture(item))
		var list_index = main.tackle_item_list.item_count - 1
		var item_block_reason := _get_equip_block_reason(item, main._tackle_category)
		if item_block_reason != "":
			main.tackle_item_list.set_item_custom_bg_color(list_index, Color(0.10, 0.10, 0.10, 0.36))
			main.tackle_item_list.set_item_custom_fg_color(list_index, Color(0.62, 0.68, 0.66, 0.86))

		if _is_tackle_item_equipped(item):
			main.tackle_item_list.set_item_custom_bg_color(list_index, Color(0.12, 0.34, 0.22, 0.66))
			main.tackle_item_list.set_item_custom_fg_color(list_index, Color(0.80, 1.0, 0.82, 1.0))

	if selected_index >= page_start and selected_index < page_end:
		main.tackle_item_list.select(selected_index - page_start)
	else:
		main._selected_tackle_item_id = ""

	_update_tackle_picker_visibility()
	_update_tackle_pager(page_count, total_count)


func _get_tackle_items_per_page() -> int:
	return 8 if main._tackle_category == "rod" else TACKLE_ITEMS_PER_PAGE


func _configure_tackle_item_list_for_category(category: String) -> void:
	if category == "rod":
		main.tackle_item_list.max_columns = 2
		main.tackle_item_list.icon_mode = ItemList.ICON_MODE_TOP
		main.tackle_item_list.fixed_icon_size = Vector2i(172, 56)
		main.tackle_item_list.fixed_column_width = int(max((main.tackle_item_list.size.x - 14.0) * 0.5, 176.0))
		main.tackle_item_list.max_text_lines = 2
		main.tackle_item_list.same_column_width = true
		main.tackle_item_list.add_theme_constant_override("h_separation", 10)
		main.tackle_item_list.add_theme_constant_override("v_separation", 12)
	else:
		main.tackle_item_list.max_columns = 1
		main.tackle_item_list.icon_mode = ItemList.ICON_MODE_LEFT
		main.tackle_item_list.fixed_icon_size = Vector2i(30, 30)
		main.tackle_item_list.fixed_column_width = 0
		main.tackle_item_list.max_text_lines = 3
		main.tackle_item_list.same_column_width = false
		main.tackle_item_list.add_theme_constant_override("h_separation", 8)
		main.tackle_item_list.add_theme_constant_override("v_separation", 6)


func _get_tackle_slot_button_text(category: String) -> String:
	if category == "bait_2" and not PlayerData.can_use_second_bait():
		return "%s  🔒\nНужен навык «Ловля на бутерброд»\nСлот заблокирован" % _get_tackle_slot_title(category)
	if category == "rod":
		return _get_rod_card_text()
	return "%s  %s\nНадето: %s\n%s" % [
		_get_tackle_slot_title(category),
		_get_tackle_slot_status_icon(category),
		_get_tackle_slot_equipped_name(category),
		_get_tackle_slot_param_text(category)
	]


func _get_rod_card_text() -> String:
	var rod: Dictionary = PlayerData.current_tackle.get("rod", {})
	var rod_name := str(rod.get("name", "Не установлено"))
	var rarity := _get_rarity_title(str(rod.get("rarity", "common")))
	return "Удочка        %s\n%s\n%s" % [
		_get_tackle_slot_status_icon("rod"),
		_short_tackle_slot_text(rod_name, 38),
		rarity
	]


func _get_rod_showcase_name() -> String:
	var rod: Dictionary = PlayerData.current_tackle.get("rod", {})
	return str(rod.get("name", "Удочка не выбрана"))


func _get_rod_showcase_title_text() -> String:
	return "Удочка\n%s" % _short_tackle_slot_text(_get_rod_showcase_name(), 42)


func _get_selected_item_card_text(item: Dictionary) -> String:
	var category_title := _get_tackle_slot_title(main._tackle_category)
	var item_text := _get_tackle_item_details_text(item)
	return "Выбор: %s\n%s" % [category_title, item_text]


func _get_rod_stats_grid_text() -> String:
	var rod: Dictionary = PlayerData.current_tackle.get("rod", {})
	var stats := PlayerData.get_tackle_stats()
	var rarity := _get_rarity_title(str(rod.get("rarity", "common")))
	var rod_class := _format_tackle_stat_value("rod_class", str(rod.get("rod_class", stats.get("rod_class", "medium"))))
	var length := _format_tackle_stat_value("length_m", rod.get("length_m", stats.get("length_m", 0.0)))
	var max_fish := _format_tackle_stat_value("max_fish_weight", rod.get("max_fish_weight", stats.get("max_fish_weight", 0.0)))
	var condition := "%d%%" % roundi(PlayerData.get_tackle_condition("rod") * 100.0)
	var control := _format_tackle_stat_value("control_bonus", stats.get("control_bonus", rod.get("control_bonus", 0.0)))
	return "Редкость: %s        Класс: %s\nДлина: %s        Макс. рыба: %s\nСостояние: %s        Контроль: %s" % [
		rarity,
		rod_class,
		length,
		max_fish,
		condition,
		control
	]


func _get_current_tackle_validation() -> Dictionary:
	var validation_service := _validation_service()
	if validation_service != null and validation_service.has_method("validate_current_tackle"):
		var result = validation_service.call("validate_current_tackle")
		if typeof(result) == TYPE_DICTIONARY:
			return result
	var issues := PlayerData.get_tackle_setup_issues()
	return {
		"usable": issues.is_empty(),
		"reason": "" if issues.is_empty() else PlayerData.get_tackle_block_reason()
	}


func _get_validation_status_line(issues: Array, tackle_valid: bool) -> String:
	if tackle_valid:
		return "Снасть готова к ловле."
	if issues.is_empty():
		return "Снасть не готова"
	return "Снасть не готова: %s" % "; ".join(issues.slice(0, mini(issues.size(), 2)))


func _get_tackle_slot_texture(category: String) -> Texture2D:
	if PlayerData.is_tackle_slot_locked(category):
		return null
	var current: Dictionary = PlayerData.current_tackle.get(category, {})
	var texture := _get_item_texture(current)
	if texture != null:
		return texture
	return _get_slot_placeholder_texture(category)


func _get_rod_button_texture() -> Texture2D:
	var rod: Dictionary = PlayerData.current_tackle.get("rod", {})
	var showcase_path := _get_showcase_rod_image_path(rod)
	if showcase_path != "":
		var showcase_texture := _load_texture_resource(showcase_path)
		if showcase_texture != null:
			return showcase_texture
	var texture := _get_item_texture(rod)
	if texture != null:
		return texture
	return _get_slot_placeholder_texture("rod")


func _get_showcase_rod_image_path(rod: Dictionary) -> String:
	match str(rod.get("id", "")):
		"titan_hook_ultra_match":
			return "res://assets/ui/tackle/rods/titan_hook_ultra_match_full.png"
		_:
			return ""


func _get_slot_placeholder_texture(category: String) -> Texture2D:
	# TODO: add dedicated leader and float slot icons when the final art pass is ready.
	match category:
		"rod":
			return theme.get_icon("rod") if theme != null and theme.has_method("get_icon") else null
		"line":
			return theme.get_icon("line") if theme != null and theme.has_method("get_icon") else null
		"hook":
			return theme.get_icon("hook") if theme != null and theme.has_method("get_icon") else null
		"bait", "bait_2":
			return theme.get_icon("bait") if theme != null and theme.has_method("get_icon") else null
		"lure", "hook_or_lure":
			return theme.get_icon("hook") if theme != null and theme.has_method("get_icon") else null
		_:
			return null


func _get_item_texture(item: Dictionary) -> Texture2D:
	var path := str(item.get("image_path", ""))
	if path == "":
		path = _get_default_item_image_path(item)
	if path == "":
		return null
	if _texture_cache.has(path):
		return _texture_cache[path]

	var texture := _load_texture_resource(path)
	_texture_cache[path] = texture
	return texture


func _load_texture_resource(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var resource: Resource = load(path)
		if resource is Texture2D:
			return resource

	if FileAccess.file_exists(path):
		var image := Image.load_from_file(path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)

	return null


func _get_default_item_image_path(item: Dictionary) -> String:
	var item_id := str(item.get("id", ""))
	var category := str(item.get("category", item.get("type", "")))
	if item_id.is_empty():
		return ""

	var path := ""
	match category:
		"rod":
			path = "res://assets/ui/shop/rods/%s.png" % item_id
		"line":
			path = "res://assets/ui/shop/lines/%s.png" % item_id
		"bait":
			path = "res://assets/ui/shop/baits/%s.png" % item_id
		_:
			path = ""

	if path != "" and ResourceLoader.exists(path):
		return path
	return ""


func _get_tackle_slot_icon(category: String) -> String:
	match category:
		"rod":
			return "⌁"
		"line":
			return "◎"
		"leader":
			return "○"
		"hook":
			return "J"
		"float":
			return "◈"
		"bait", "bait_2":
			return "•"
		_:
			return "□"


func _get_tackle_slot_status_icon(category: String) -> String:
	var state := _get_tackle_slot_state(category)
	match state:
		"locked":
			return "🔒"
		"filled", "selected":
			return "✓"
		_:
			return "+"


func _get_tackle_slot_state(category: String) -> String:
	if PlayerData.is_tackle_slot_locked(category):
		return "locked"
	if category == main._tackle_category and _picker_open:
		return "selected"

	var current: Dictionary = PlayerData.current_tackle.get(category, {})
	var has_item := str(current.get("id", "")) != ""
	if category == "leader" and not has_item:
		return "empty"
	if category == "bait_2" and not has_item:
		return "empty"
	return "filled" if has_item else "empty"


func _get_tackle_slot_param_text(category: String) -> String:
	var current: Dictionary = PlayerData.current_tackle.get(category, {})
	if PlayerData.is_tackle_slot_locked(category):
		return PlayerData.get_tackle_slot_lock_reason(category)
	if current.is_empty() or str(current.get("id", "")) == "":
		return "Не установлено"

	match category:
		"line":
			return "Прочность: %s" % _format_tackle_stat_value("max_load", current.get("max_load", current.get("max_load_kg", 0.0)))
		"leader":
			return "%d см / %s" % [
				int(current.get("length_cm", 0)),
				_format_tackle_stat_value("max_load", current.get("max_load", current.get("max_load_kg", current.get("strength", 0.0))))
			]
		"hook":
			return "Размер: %s" % _format_tackle_stat_value("hook_size", current.get("hook_size", 12))
		"float":
			return "Стабильность: %s" % _format_tackle_stat_value("stability", current.get("stability", 0.0))
		"bait", "bait_2":
			return "Тип: %s" % _format_tackle_stat_value("bait_type", current.get("bait_type", current.get("stats", {}).get("bait_type", "")))
		"rod":
			return "Макс. рыба: %s" % _format_tackle_stat_value("max_fish_weight", current.get("max_fish_weight", 0.0))
		_:
			return ""


func _get_item_category_for_slot(slot_id: String) -> String:
	var categories := PlayerData.get_tackle_slot_item_categories(slot_id)
	if not categories.is_empty():
		return str(categories[0])
	return slot_id


func _get_rod_assembly_summary_text() -> String:
	var rod: Dictionary = PlayerData.current_tackle.get("rod", {})
	var stats := PlayerData.get_tackle_stats()
	return "Характеристики\nРедкость: %s      Класс: %s\nДлина: %.1f м       Макс.: %.1f кг\nСостояние: %d%%    Контроль: %d%%" % [
		_get_rarity_title(str(rod.get("rarity", "common"))),
		_format_tackle_stat_value("rod_class", str(rod.get("rod_class", stats.get("rod_class", "medium")))),
		float(rod.get("length_m", stats.get("rod_length_m", 4.0))),
		float(rod.get("max_fish_weight", stats.get("max_fish_weight", 1.0))),
		roundi(PlayerData.get_tackle_condition("rod") * 100.0),
		roundi(float(stats.get("control_bonus", 0.0)) * 100.0)
	]


func _get_tackle_slot_title(category: String) -> String:
	if PlayerData.has_method("get_tackle_slot_title"):
		return PlayerData.get_tackle_slot_title(category)
	match category:
		"rod":
			return "Удочка"
		"line":
			return "Леска"
		"leader":
			return "Поводок"
		"float":
			return "Поплавок"
		"hook":
			return "Крючок"
		"bait":
			return "Наживка"
		"bait_2":
			return "Наживка 2"
		_:
			return "Слот"


func _get_tackle_slot_equipped_name(category: String) -> String:
	var current: Dictionary = PlayerData.current_tackle.get(category, {})
	if PlayerData.is_tackle_slot_locked(category):
		return "Закрыта"
	if category == "bait_2" and not PlayerData.can_use_second_bait():
		return "Закрыта"
	if str(current.get("id", "")) == "":
		return "Не установлено"
	if category == "leader" and str(current.get("id", "")) == "":
		return "Не установлено"
	if ["bait", "bait_2"].has(category) and str(current.get("id", "")) == "":
		return "Не установлено"
	var equipped_name := str(current.get("name", "-"))

	if category == "bait":
		return _format_tackle_bait_slot_text(category, equipped_name)
	if category == "bait_2":
		return _format_tackle_bait_slot_text(category, equipped_name)

	return _short_tackle_slot_text(equipped_name, 20)

func _format_tackle_bait_slot_text(slot_id: String, equipped_name: String) -> String:
	var quantity := PlayerData.get_current_bait_quantity(slot_id)
	var short_name := _short_tackle_slot_text(equipped_name, 15)
	if quantity <= 0:
		return "%s x0 — закончилась" % short_name
	return "%s x%d" % [short_name, quantity]


func _short_tackle_slot_text(value: String, max_chars: int) -> String:
	if value.length() <= max_chars:
		return value

	return "%s..." % value.substr(0, max(max_chars - 3, 1))


func _update_tackle_picker_visibility() -> void:
	var locked_second_bait: bool = PlayerData.is_tackle_slot_locked(main._tackle_category)
	var picker_visible: bool = _picker_open and not locked_second_bait
	main.tackle_center_panel.visible = picker_visible
	main.tackle_item_list.visible = picker_visible
	main.tackle_picker_title_label.visible = picker_visible
	if main.tackle_slot_scroll != null:
		main.tackle_slot_scroll.visible = not picker_visible
	main.tackle_hint_label.visible = true
	main.tackle_picker_title_label.text = "Выберите: %s" % _get_tackle_slot_title(main._tackle_category)
	main.tackle_picker_title_label.add_theme_color_override("font_color", TACKLE_COLOR_GOLD)

	for node in _get_tackle_visual_nodes():
		if node != null:
			node.visible = false


func _get_tackle_visual_nodes() -> Array:
	return [
		main.tackle_visual_title_label,
		main.tackle_visual_rod_line,
		main.tackle_visual_main_line,
		main.tackle_visual_leader_line,
		main.tackle_visual_float_marker,
		main.tackle_visual_hook_marker,
		main.tackle_visual_bait_marker,
		main.tackle_visual_bait_2_marker,
		main.tackle_visual_line_label,
		main.tackle_visual_float_label,
		main.tackle_visual_leader_label,
		main.tackle_visual_hook_label,
		main.tackle_visual_bait_label,
		main.tackle_visual_bait_2_label
	]


func _update_tackle_visual_scheme() -> void:
	if main.tackle_visual_line_label == null:
		return

	var has_leader: bool = str(PlayerData.current_tackle.get("leader", {}).get("id", "")) != ""
	var has_second_bait: bool = PlayerData.can_use_second_bait() and str(PlayerData.current_tackle.get("bait_2", {}).get("id", "")) != ""
	var visual_visible: bool = not main.tackle_item_list.visible

	main.tackle_visual_line_label.text = "Леска\n%s" % _get_tackle_slot_equipped_name("line")
	main.tackle_visual_float_label.text = "Поплавок\n%s" % _get_tackle_slot_equipped_name("float")
	main.tackle_visual_leader_label.text = "Поводок\n%s" % _get_tackle_slot_equipped_name("leader")
	main.tackle_visual_hook_label.text = "Крючок\n%s" % _get_tackle_slot_equipped_name("hook")
	main.tackle_visual_bait_label.text = "Наживка 1\n%s" % _get_tackle_slot_equipped_name("bait")
	main.tackle_visual_bait_2_label.text = "Наживка 2\n%s" % _get_tackle_slot_equipped_name("bait_2")

	main.tackle_visual_leader_line.default_color = Color(0.92, 0.78, 0.48, 0.78) if has_leader else Color(0.42, 0.50, 0.54, 0.42)
	main.tackle_visual_leader_label.add_theme_color_override("font_color", Color(0.84, 0.94, 0.92, 0.94) if has_leader else Color(0.54, 0.60, 0.62, 0.84))
	main.tackle_visual_bait_2_marker.visible = visual_visible and has_second_bait
	main.tackle_visual_bait_2_label.visible = visual_visible and PlayerData.can_use_second_bait()


func _get_rod_description_text() -> String:
	var rod: Dictionary = PlayerData.current_tackle.get("rod", {})
	var description := str(rod.get("description", "Надёжная маховая снасть для спокойной ловли у берега."))
	description = _short_tackle_slot_text(description, 150)
	var fit_names := _get_fit_fish_names()
	return "Описание\n%s\n\nПодходит для\n%s" % [
		description,
		"  •  ".join(fit_names) if not fit_names.is_empty() else "Подберите место, глубину и наживку"
	]


func _get_final_tackle_stats_text() -> String:
	var stats := PlayerData.get_tackle_stats()
	var issues: Array = PlayerData.get_tackle_setup_issues()
	var status := "В сборке" if issues.is_empty() else "Не готово"
	var bait_text := _get_tackle_slot_equipped_name("bait")
	if PlayerData.can_use_second_bait():
		var bait_2_text := _get_tackle_slot_equipped_name("bait_2")
		if bait_2_text != "Не установлено":
			bait_text = "%s + %s" % [bait_text, bait_2_text]

	return "Итоговые характеристики снасти\nЛеска/поводок: %s / %s\nРазмер крючка: %s\nНаживка: %s\nВидимость: %s\nКонтроль: %s\nСтатус: %s" % [
		_format_tackle_stat_value("max_load", stats.get("line_strength", 0.0)),
		_format_tackle_stat_value("max_load", stats.get("leader_strength", 0.0)),
		_format_tackle_stat_value("hook_size", stats.get("hook_size", 12)),
		bait_text,
		_format_visibility_title(float(stats.get("visibility_penalty", stats.get("visibility", 0.0)))),
		_format_tackle_stat_value("control_bonus", stats.get("control_bonus", 0.0)),
		status
	]


func _format_visibility_title(value: float) -> String:
	if value <= 0.08:
		return "Низкая"
	if value <= 0.18:
		return "Средняя"
	return "Высокая"


func _get_fit_fish_names() -> Array:
	var spot := SpotDatabase.get_spot(PlayerData.current_spot)
	var fish_ids: Array = spot.get("available_fish", [])
	var tackle_stats := PlayerData.get_tackle_stats()
	var hook_size: int = int(tackle_stats.get("hook_size", 12))
	var line_strength: float = float(tackle_stats.get("line_strength", 1.0))
	var max_fish_weight: float = float(tackle_stats.get("max_fish_weight", 1.0))
	var tackle_weight_limit: float = max(max_fish_weight * 1.32, line_strength * 2.25)
	var names: Array = []
	var fallback_names: Array = []
	for fish_id in fish_ids:
		var fish := FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue
		if float(fish.get("min_weight", 0.0)) > tackle_weight_limit:
			continue
		var min_hook_size := int(fish.get("min_hook_size", 0))
		var max_hook_size := int(fish.get("max_hook_size", 99))
		var hook_fits := hook_size >= min_hook_size and hook_size <= max_hook_size
		var bait_fits := _bait_targets_fish(tackle_stats, str(fish_id))
		if hook_fits and bait_fits:
			names.append(str(fish.get("name", "-")))
		elif hook_fits and fallback_names.size() < 4:
			fallback_names.append(str(fish.get("name", "-")))
		if names.size() >= 4:
			break
	if names.is_empty():
		names = fallback_names
	return names


func _set_tackle_category(category: String) -> void:
	if category == main._tackle_category and _picker_open:
		_picker_open = false
		main._selected_tackle_item_id = ""
		_update_tackle_ui()
		return

	main._tackle_category = category
	main._tackle_page = 0
	main._selected_tackle_item_id = ""
	_rod_info_open = false
	_picker_open = not PlayerData.is_tackle_slot_locked(category)
	if not _picker_open and PlayerData.is_tackle_slot_locked(category):
		main._show_toast(PlayerData.get_tackle_slot_lock_reason(category), false)
	elif not _picker_open and category == "bait_2":
		main._show_toast("Нужен навык «Ловля на бутерброд».", false)
	_update_tackle_ui()


func _on_tackle_info_button_pressed() -> void:
	if _picker_open:
		_picker_open = false
		main._selected_tackle_item_id = ""
		_update_tackle_ui()
		return

	_rod_info_open = not _rod_info_open
	_picker_open = false
	main._selected_tackle_item_id = ""
	_update_tackle_ui()


func _on_tackle_clear_button_pressed() -> void:
	if main._fishing_ui_state != FishingUiState.IDLE:
		main._show_toast("Снасть можно менять только перед забросом.", false)
		return
	var slot_id := str(main._tackle_category)
	if slot_id == "" or PlayerData.is_tackle_slot_locked(slot_id):
		main._show_toast(PlayerData.get_tackle_slot_lock_reason(slot_id), false)
		return
	var current := PlayerData.get_current_tackle_slot(slot_id)
	if current.is_empty() or str(current.get("id", "")) == "":
		main._show_toast("В этом слоте ничего не надето.", false)
		return

	PlayerData.clear_current_tackle_slot(slot_id)
	_picker_open = false
	main._selected_tackle_item_id = ""
	_save_tackle_change()
	main._show_toast("Слот очищен: %s" % _get_tackle_slot_title(slot_id), true)
	_update_tackle_ui()
	main._update_ui()


func _on_tackle_auto_button_pressed() -> void:
	if main._fishing_ui_state != FishingUiState.IDLE:
		main._show_toast("Снасть можно менять только перед забросом.", false)
		return
	var tackle_type := PlayerData.get_current_tackle_type()
	if tackle_type != PlayerData.DEFAULT_TACKLE_TYPE:
		main._show_toast("Автосборка для этого типа пока не готова.", false)
		return

	var equipped_count := 0
	for slot_schema in PlayerData.get_tackle_schema_slots(tackle_type):
		var slot_id := str(slot_schema.get("id", ""))
		if slot_id == "" or PlayerData.is_tackle_slot_locked(slot_id) or not bool(slot_schema.get("required", false)):
			continue
		var current := PlayerData.get_current_tackle_slot(slot_id)
		if not current.is_empty() and str(current.get("id", "")) != "":
			if not ["bait", "bait_2"].has(slot_id) or PlayerData.get_current_bait_quantity(slot_id) > 0:
				continue
		var auto_item := _get_first_auto_tackle_item(slot_id)
		if auto_item.is_empty():
			continue
		if PlayerData.set_current_tackle_slot(slot_id, auto_item):
			equipped_count += 1

	if equipped_count <= 0:
		main._show_toast("Подходящие предметы для автосборки не найдены.", false)
		return

	_picker_open = false
	main._selected_tackle_item_id = ""
	_save_tackle_change()
	main._show_toast("Автосборка обновила слоты: %d" % equipped_count, true)
	_update_tackle_ui()
	main._update_ui()


func _get_first_auto_tackle_item(slot_id: String) -> Dictionary:
	for item in _get_visible_tackle_items_for_slot(slot_id):
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var candidate: Dictionary = item
		if PlayerData.get_equip_block_reason(candidate, slot_id) == "":
			return candidate
	return {}


func _save_tackle_change() -> void:
	var save_manager: Node = main.get_node_or_null("/root/SaveManager") if main != null else null
	if save_manager != null and save_manager.has_method("save_game"):
		save_manager.call("save_game")


func _on_tackle_item_selected(index: int) -> void:
	_picker_open = true
	var item_index: int = main._tackle_page * _get_tackle_items_per_page() + index
	if item_index < 0 or item_index >= main._visible_tackle_items.size():
		main._selected_tackle_item_id = ""
	else:
		main._selected_tackle_item_id = str(main._visible_tackle_items[item_index].get("id", ""))

	_update_tackle_ui()


func _on_tackle_item_activated(index: int) -> void:
	var item_index: int = main._tackle_page * _get_tackle_items_per_page() + index
	if item_index < 0 or item_index >= main._visible_tackle_items.size():
		return

	main._selected_tackle_item_id = str(main._visible_tackle_items[item_index].get("id", ""))

	var selected_item: Dictionary = main._visible_tackle_items[item_index]
	var block_reason := _get_equip_block_reason(selected_item, main._tackle_category)
	if main._fishing_ui_state == FishingUiState.IDLE and not _is_tackle_item_equipped(selected_item) and block_reason == "":
		main._on_tackle_equip_button_pressed()
		_picker_open = false
		_update_tackle_ui()
	elif block_reason != "":
		main._show_toast(block_reason, false)


func _on_tackle_prev_page_pressed() -> void:
	if main._tackle_page <= 0:
		return

	main._tackle_page -= 1
	main._selected_tackle_item_id = ""
	_update_tackle_ui()


func _on_tackle_next_page_pressed() -> void:
	var total_count: int = _get_visible_tackle_items_for_slot(main._tackle_category).size()
	var page_count: int = max(ceili(float(total_count) / float(_get_tackle_items_per_page())), 1)
	if main._tackle_page >= page_count - 1:
		return

	main._tackle_page += 1
	main._selected_tackle_item_id = ""
	_update_tackle_ui()

func _get_visible_tackle_items_for_category(category: String) -> Array:
	var items: Array = []
	for item in PlayerData.get_owned_items_for_category(category):
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var typed_item: Dictionary = item
		if _should_show_tackle_item(typed_item):
			items.append(typed_item)
	return items

func _get_visible_tackle_items_for_slot(slot_id: String) -> Array:
	var items: Array = []
	var used_ids: Dictionary = {}
	for category in PlayerData.get_tackle_slot_item_categories(slot_id):
		for item in _get_visible_tackle_items_for_category(str(category)):
			if typeof(item) != TYPE_DICTIONARY:
				continue
			var item_id := str((item as Dictionary).get("id", ""))
			if used_ids.has(item_id):
				continue
			items.append(item)
			used_ids[item_id] = true
	return items

func _should_show_tackle_item(item: Dictionary) -> bool:
	var category := str(item.get("category", ""))
	if ["bait", "consumable", "groundbait"].has(category) and int(item.get("quantity", 0)) <= 0:
		return false
	return true


func _get_selected_tackle_item() -> Dictionary:
	for item in main._visible_tackle_items:
		if str(item.get("id", "")) == main._selected_tackle_item_id:
			return item

	return {}

func _get_item_display_name(item: Dictionary) -> String:
	return str(item.get("display_name_ru", item.get("name", "-")))

func _get_item_description(item: Dictionary) -> String:
	return str(item.get("description_ru", item.get("description", "")))


func _get_tackle_item_display_text(item: Dictionary) -> String:
	var name = _get_item_display_name(item)
	var quantity = int(item.get("quantity", 1))
	var equipped_marker = "  [Надето]" if _is_tackle_item_equipped(item) else ""

	if str(item.get("category", "")) == "bait":
		return "%s x%d%s" % [name, quantity, equipped_marker]

	if str(item.get("category", "")) == "rod":
		return "%s%s" % [_short_tackle_slot_text(name, 24), equipped_marker]

	if ["rod", "line", "leader", "hook"].has(str(item.get("category", ""))):
		var status := PlayerData.get_item_condition_title(item)
		if status != "Исправна":
			return "%s [%s]%s" % [name, status, equipped_marker]

	return "%s%s" % [name, equipped_marker]


func _get_tackle_item_details_text(item: Dictionary) -> String:
	var category = str(item.get("category", "misc"))
	var equipped_line := "Статус: надето в текущей сборке\n" if _is_tackle_item_equipped(item) else ""
	var details = "%s\n%sТип: %s\nРедкость: %s\nЦена: %s\nКоличество: %d" % [
		_get_item_display_name(item),
		equipped_line,
		main._get_inventory_category_title(category),
		_get_rarity_title(str(item.get("rarity", "common"))),
		UIFormatters.format_money(float(item.get("price", 0.0))),
		int(item.get("quantity", 1))
	]
	var description = _get_item_description(item)

	var condition_text := _get_tackle_item_condition_details_text(item)
	if condition_text != "":
		details += "\n\n%s" % condition_text

	if description != "":
		details += "\n%s" % description

	var stats_text = _get_tackle_stats_text(item)
	if stats_text != "":
		details += "\n\n%s" % stats_text

	return details


func _repair_service() -> Node:
	if main != null:
		return main.get_node_or_null("/root/RepairService")
	return null


func _validation_service() -> Node:
	if main != null:
		return main.get_node_or_null("/root/TackleValidationService")
	return null


func _get_equip_block_reason(item: Dictionary, slot_type: String = "") -> String:
	var validation_service := _validation_service()
	if validation_service != null and validation_service.has_method("get_equip_block_reason"):
		return str(validation_service.call("get_equip_block_reason", slot_type, item))
	return PlayerData.get_equip_block_reason(item, slot_type)


func _can_repair_item(item: Dictionary) -> bool:
	var repair_service := _repair_service()
	if repair_service != null and repair_service.has_method("can_repair_item"):
		return bool(repair_service.call("can_repair_item", item))
	return PlayerData.is_item_repairable(item)


func _can_discard_item(item: Dictionary) -> bool:
	var repair_service := _repair_service()
	if repair_service != null and repair_service.has_method("can_discard_item"):
		return bool(repair_service.call("can_discard_item", item))
	return PlayerData.can_discard_item(item)


func _get_item_wear_percent(item: Dictionary) -> int:
	var repair_service := _repair_service()
	if repair_service != null and repair_service.has_method("get_wear_percent"):
		return int(repair_service.call("get_wear_percent", item))
	return PlayerData.get_item_wear_percent(item)


func _get_item_repair_cost(item: Dictionary) -> int:
	var repair_service := _repair_service()
	if repair_service != null and repair_service.has_method("get_repair_cost"):
		return int(repair_service.call("get_repair_cost", item))
	return PlayerData.get_item_repair_cost(item)


func _get_item_condition_title(item: Dictionary) -> String:
	var repair_service := _repair_service()
	if repair_service != null and repair_service.has_method("get_item_condition_title"):
		return str(repair_service.call("get_item_condition_title", item))
	return PlayerData.get_item_condition_title(item)


func _get_tackle_item_condition_details_text(item: Dictionary) -> String:
	var category := str(item.get("category", ""))
	if category == "bait":
		if int(item.get("quantity", 0)) <= 0:
			return "Состояние: закончилась\nПричина: Наживка закончилась."
		return ""
	if not ["rod", "line", "leader", "hook"].has(category):
		return ""

	var wear_percent := _get_item_wear_percent(item)
	var repair_cost := _get_item_repair_cost(item)
	var block_reason := _get_equip_block_reason(item, main._tackle_category)
	var lines: Array = [
		"Состояние: %s" % _get_item_condition_title(item),
		"Износ: %d%%" % wear_percent
	]
	if repair_cost > 0:
		lines.append("Ремонт: %s" % UIFormatters.format_money(float(repair_cost)))
	if block_reason != "":
		lines.append("Причина: %s" % block_reason)
	return "\n".join(lines)


func _get_tackle_stats_text(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {})
	var category = str(item.get("category", item.get("type", "misc")))
	var lines: Array = []

	for key in _get_tackle_stat_keys(category):
		if not stats.has(key):
			continue

		lines.append("%s: %s" % [_get_tackle_stat_title(key), _format_tackle_stat_value(key, stats[key])])

	if category == "bait":
		var target_text := PlayerData.get_bait_target_fish_names(str(item.get("id", "")), 4)
		var secondary_text := PlayerData.get_bait_secondary_fish_names(str(item.get("id", "")), 3)
		if target_text != "":
			lines.append(target_text)
		if secondary_text != "":
			lines.append(secondary_text)

	return "\n".join(lines)


func _get_tackle_compare_text(item: Dictionary) -> String:
	var category = str(item.get("category", "misc"))
	var slot_id: String = str(main._tackle_category)
	var current: Dictionary = PlayerData.current_tackle.get(slot_id, {})
	var stats: Dictionary = item.get("stats", {})

	if current.is_empty():
		return "Сравнение недоступно."

	if str(current.get("id", "")) == str(item.get("id", "")):
		return "Сейчас экипировано.\nЭта снасть уже стоит в текущей маховой сборке."

	var lines: Array = ["Сравнение с текущей снастью:"]

	for key in _get_tackle_stat_keys(category):
		if not stats.has(key) and not current.has(key):
			continue

		var current_value = current.get(key, 0)
		var selected_value = stats.get(key, current_value)
		var diff_text = ""

		if typeof(current_value) in [TYPE_FLOAT, TYPE_INT] and typeof(selected_value) in [TYPE_FLOAT, TYPE_INT]:
			var diff: float = float(selected_value) - float(current_value)
			if abs(diff) >= 0.005:
				diff_text = " (+%.2f)" % diff if diff > 0.0 else " (%.2f)" % diff

		lines.append("%s: %s → %s%s" % [
			_get_tackle_stat_title(key),
			_format_tackle_stat_value(key, current_value),
			_format_tackle_stat_value(key, selected_value),
			diff_text
		])

	return "\n".join(lines)


func _get_tackle_setup_hints_text(max_lines: int = 4) -> String:
	var hints: Array = _get_tackle_setup_hints()
	var visible_hints: Array = []
	var line_count: int = min(max_lines, hints.size())

	for i in line_count:
		visible_hints.append(hints[i])

	return "\n".join(visible_hints)


func _get_tackle_setup_status_or_hints_text() -> String:
	var issues: Array = PlayerData.get_tackle_setup_issues()
	if issues.is_empty():
		return _get_tackle_setup_hints_text(2)

	return "Сборка не готова: %s" % "; ".join(issues)


func _get_tackle_setup_hints() -> Array:
	var hints: Array = []
	var spot = SpotDatabase.get_spot(PlayerData.current_spot)
	var spot_fish: Array = spot.get("available_fish", [])
	var depth = PlayerData.fishing_depth
	var tackle_stats = PlayerData.get_tackle_stats()
	var hook_size: int = int(tackle_stats.get("hook_size", 12))
	var line_strength: float = float(tackle_stats.get("line_strength", 1.0))
	var leader_strength: float = float(tackle_stats.get("leader_strength", line_strength))
	var leader_length_cm: int = int(tackle_stats.get("leader_length_cm", 0))
	var leader_material := str(tackle_stats.get("leader_material", "")).to_lower()
	var depth_candidates: Array = []
	var bait_match_names: Array = []
	var too_big_hook_count = 0
	var too_small_hook_count = 0
	var fitting_hook_count = 0
	var line_warning = false
	var leader_warning = false
	var coarse_leader_warning = false
	var large_fish_nearby = false

	if depth <= 1.1:
		hints.append("На этой глубине чаще клюёт мелкая рыба.")
	elif depth >= 3.2:
		hints.append("Глубина подходит для крупной донной рыбы.")
	else:
		hints.append("Средняя глубина: универсальная настройка.")

	for fish_id in spot_fish:
		var fish = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue

		var min_depth: float = float(fish.get("min_depth", 0.2))
		var max_depth: float = float(fish.get("max_depth", 6.0))
		if depth < min_depth or depth > max_depth:
			continue

		depth_candidates.append(fish)
		var min_hook_size: int = int(fish.get("min_hook_size", 2))
		var max_hook_size: int = int(fish.get("max_hook_size", 18))

		if hook_size < min_hook_size:
			too_big_hook_count += 1
		elif hook_size > max_hook_size:
			too_small_hook_count += 1
		else:
			fitting_hook_count += 1

		var average_weight: float = (float(fish.get("min_weight", 0.0)) + float(fish.get("max_weight", 0.0))) * 0.5
		if average_weight >= 1.2:
			large_fish_nearby = true
		if line_strength < average_weight * 0.85:
			line_warning = true
		if leader_strength > 0.0 and leader_strength < average_weight * 0.85:
			leader_warning = true

		var fish_max_weight: float = float(fish.get("max_weight", average_weight))
		var behavior := str(fish.get("behavior_type", fish.get("behavior", "calm"))).to_lower()
		var cautious_fish := fish_max_weight <= 0.8 or behavior == "calm" or behavior == "cautious" or behavior == "shy"
		if cautious_fish and leader_strength >= max(average_weight * 3.2, 3.0):
			coarse_leader_warning = true
		if cautious_fish and ["steel", "reinforced"].has(leader_material) and fish_max_weight <= 1.5:
			coarse_leader_warning = true
		if cautious_fish and leader_length_cm > 0 and leader_length_cm <= 15:
			coarse_leader_warning = true

		if _bait_targets_fish(tackle_stats, str(fish_id)) and bait_match_names.size() < 4:
			bait_match_names.append(str(fish.get("name", "-")))

	if depth_candidates.is_empty():
		hints.append(_get_no_bite_candidate_reason(PlayerData.current_spot))
	elif too_big_hook_count > fitting_hook_count and depth <= 1.6:
		hints.append("Крючок слишком большой для мелкой рыбы.")
	elif too_small_hook_count > 0 and large_fish_nearby:
		hints.append("Крючок маловат для крупной рыбы: выше риск схода.")

	if line_warning:
		hints.append("Леска слабовата для крупной рыбы.")
	if leader_warning:
		hints.append("Поводок слабоват: при рывке он станет самым слабым элементом.")
	if coarse_leader_warning:
		hints.append("Поводок грубоват для осторожной мелкой рыбы: шанс поклёвки ниже.")

	if bait_match_names.is_empty():
		hints.append("Наживка не лучшая для рыбы на этой глубине.")
	else:
		hints.append("Наживка подходит для: %s." % ", ".join(bait_match_names))

	return hints


func _get_no_bite_candidate_reason(spot_id: String) -> String:
	var spot = SpotDatabase.get_spot(spot_id)

	if spot.is_empty():
		return "Точка ловли не найдена."

	var depth = PlayerData.fishing_depth
	var spot_fish: Array = spot.get("available_fish", [])
	var min_available_depth = 999.0
	var max_available_depth = -1.0
	var depth_fish: Array = []
	var hook_fish: Array = []
	var bait_fish: Array = []
	var tackle_stats = PlayerData.get_tackle_stats()
	var hook_size: int = int(tackle_stats.get("hook_size", 12))

	for fish_id in spot_fish:
		var fish = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue

		var min_depth: float = float(fish.get("min_depth", 0.2))
		var max_depth: float = float(fish.get("max_depth", 6.0))
		min_available_depth = min(min_available_depth, min_depth)
		max_available_depth = max(max_available_depth, max_depth)

		if depth < min_depth or depth > max_depth:
			continue

		depth_fish.append(fish)

		var min_hook_size: int = int(fish.get("min_hook_size", 2))
		var max_hook_size: int = int(fish.get("max_hook_size", 18))
		if hook_size >= min_hook_size and hook_size <= max_hook_size:
			hook_fish.append(fish)

		if _bait_targets_fish(tackle_stats, str(fish_id)):
			bait_fish.append(fish)

	if min_available_depth < 999.0:
		if depth < min_available_depth:
			return "%s: на %.1f м рыба держится глубже. Попробуй от %.1f м или другую точку." % [
				str(spot.get("name", "Точка")),
				depth,
				min_available_depth
			]
		if depth > max_available_depth:
			return "%s: глубина %.1f м слишком большая для этой рыбы. Попробуй до %.1f м." % [
				str(spot.get("name", "Точка")),
				depth,
				max_available_depth
			]

	if depth_fish.is_empty():
		return "На этой глубине в выбранной точке нет подходящей рыбы."

	if hook_fish.is_empty():
		return "Глубина подходит, но крючок не подходит рыбе в этой точке."

	if bait_fish.is_empty():
		return "Глубина и крючок подходят, но наживка слабая для этой рыбы."

	return "На этой глубине и снасти нет подходящей рыбы. Измени глубину, крючок или наживку."


func _bait_targets_fish(tackle_stats: Dictionary, fish_id: String) -> bool:
	var attraction_by_id: Dictionary = tackle_stats.get("fish_attraction_by_id", {})
	if float(attraction_by_id.get(fish_id, 0.0)) > 0.0:
		return true

	var target_fish_ids: Array = tackle_stats.get("target_fish_ids", [])
	if target_fish_ids.has(fish_id):
		return true

	var secondary_fish_ids: Array = tackle_stats.get("secondary_fish_ids", [])
	return secondary_fish_ids.has(fish_id)


func _any_bait_matches(preferred_baits: Array, bait_types: Array) -> bool:
	for bait_type in bait_types:
		if preferred_baits.has(str(bait_type)):
			return true
	return false


func _get_tackle_stat_keys(category: String) -> Array:
	match category:
		"rod":
			return ["length_m", "rod_class", "max_fish_weight", "control_bonus", "handling_bonus", "reach_bonus", "stiffness", "durability", "durability_loss"]
		"line":
			return ["max_load", "break_resistance", "break_chance", "visibility", "durability", "wear_rate"]
		"leader":
			return ["leader_type", "length_cm", "max_load", "visibility", "control_bonus", "cautious_bite_bonus", "small_fish_penalty", "break_resistance", "break_chance", "bite_protection", "durability", "wear_rate"]
		"float":
			return ["sensitivity", "stability", "wind_resistance", "drift_resistance", "cast_distance_bonus", "bite_visibility", "false_bite_resistance", "depth_min", "depth_max", "night_bonus", "vegetation_control", "heavy_bait_support", "hook_timing_bonus", "long_range_accuracy_bonus", "setup_comfort"]
		"hook":
			return ["hook_size", "hook_strength", "hook_chance", "target_fish_size", "fish_escape_modifier", "durability", "wear_rate"]
		"bait":
			return ["bait_type", "fish_attraction"]
		_:
			return []


func _get_tackle_stat_title(key: String) -> String:
	match key:
		"length_m":
			return "Длина"
		"rod_class":
			return "Класс"
		"max_fish_weight":
			return "Макс. рыба"
		"strength":
			return "Прочность"
		"leader_type":
			return "Материал"
		"length_cm":
			return "Длина"
		"cautious_bite_bonus":
			return "Осторожная рыба"
		"small_fish_penalty":
			return "Штраф мелочи"
		"stiffness":
			return "Жёсткость"
		"tension_bonus":
			return "Контроль"
		"control_bonus":
			return "Контроль"
		"handling_bonus":
			return "Управляемость"
		"reach_bonus":
			return "Досягаемость"
		"durability":
			return "Прочность"
		"durability_loss":
			return "Износ удочки"
		"max_load_kg":
			return "Нагрузка"
		"max_load":
			return "Нагрузка"
		"break_resistance":
			return "Защита обрыва"
		"break_chance":
			return "Риск обрыва"
		"wear_rate":
			return "Износ"
		"visibility":
			return "Заметность"
		"sensitivity":
			return "Чувствительность"
		"stability":
			return "Стабильность"
		"bite_protection":
			return "Защита от среза"
		"bite_visibility":
			return "Видимость клёва"
		"wind_resistance":
			return "Ветер"
		"drift_resistance":
			return "Снос"
		"cast_distance_bonus":
			return "Дальность"
		"false_bite_resistance":
			return "Ложные движения"
		"depth_min":
			return "Глубина мин."
		"depth_max":
			return "Глубина макс."
		"night_bonus":
			return "Ночь"
		"vegetation_control":
			return "Камыши/трава"
		"heavy_bait_support":
			return "Тяжёлая наживка"
		"hook_timing_bonus":
			return "Окно подсечки"
		"long_range_accuracy_bonus":
			return "Дальняя точность"
		"setup_comfort":
			return "Удобство настройки"
		"hook_size":
			return "Размер"
		"hook_strength":
			return "Прочность крючка"
		"hook_chance":
			return "Подсечка"
		"target_fish_size":
			return "Размер рыбы"
		"fish_escape_modifier":
			return "Сход рыбы"
		"bait_type":
			return "Тип наживки"
		"fish_attraction":
			return "Привлечение"
		_:
			return key


func _format_tackle_stat_value(key: String, value) -> String:
	match key:
		"hook_size":
			return "№%s" % PlayerData.format_hook_size(int(value))
		"length_m":
			return "%.1f м" % float(value)
		"length_cm":
			return "%d см" % int(value)
		"depth_min", "depth_max":
			return "%.1f м" % float(value)
		"max_fish_weight", "max_load_kg", "max_load":
			return "%.1f кг" % float(value)
		"cast_distance_bonus":
			var percent := roundi(float(value) * 100.0)
			if percent > 0:
				return "+%d%%" % percent
			return "%d%%" % percent
		"tension_bonus", "control_bonus", "handling_bonus", "reach_bonus", "break_resistance", "break_chance", "visibility", "sensitivity", "stability", "bite_visibility", "wind_resistance", "drift_resistance", "false_bite_resistance", "night_bonus", "vegetation_control", "heavy_bait_support", "hook_timing_bonus", "long_range_accuracy_bonus", "setup_comfort", "bite_protection", "hook_chance", "fish_escape_modifier", "fish_attraction", "strength", "stiffness", "durability", "durability_loss", "wear_rate", "hook_strength", "cautious_bite_bonus", "small_fish_penalty":
			return "%d%%" % roundi(float(value) * 100.0)
		"leader_type":
			return _format_leader_material(str(value))
		"rod_class":
			match str(value):
				"ultra_light":
					return "ультра лайт"
				"light":
					return "лайт"
				"medium":
					return "медиум"
				"universal":
					return "универсал"
				"heavy":
					return "тяжёлая"
				"extra_heavy":
					return "экстра тяжёлая"
				_:
					return str(value)
		"target_fish_size":
			match str(value):
				"small":
					return "мелкая"
				"medium":
					return "средняя"
				"large":
					return "крупная"
				_:
					return str(value)
		"bait_type":
			match str(value):
				"worm":
					return "червь"
				"bread":
					return "хлеб"
				"dough":
					return "тесто"
				"maggot":
					return "опарыш"
				_:
					return str(value)
		_:
			return str(value)

func _format_leader_material(value: String) -> String:
	match value.to_lower():
		"nylon", "mono", "monofilament":
			return "нейлон"
		"fluoro", "fluorocarbon":
			return "флюорокарбон"
		"braid", "braided":
			return "плетёный"
		"reinforced":
			return "усиленный"
		"steel":
			return "стальной"
		_:
			return value


func _format_tackle_wear_message(wear: Dictionary) -> String:
	if wear.is_empty():
		return ""

	var lines: Array = []
	var rod_loss: int = max(roundi((float(wear.get("rod_old", 1.0)) - float(wear.get("rod_new", wear.get("rod_old", 1.0)))) * 100.0), 0)
	var line_loss: int = max(roundi((float(wear.get("line_old", 1.0)) - float(wear.get("line_new", wear.get("line_old", 1.0)))) * 100.0), 0)
	var leader_loss: int = max(roundi((float(wear.get("leader_old", 1.0)) - float(wear.get("leader_new", wear.get("leader_old", 1.0)))) * 100.0), 0)
	var hook_loss: int = max(roundi((float(wear.get("hook_old", 1.0)) - float(wear.get("hook_new", wear.get("hook_old", 1.0)))) * 100.0), 0)
	var wear_parts: Array = []

	if rod_loss > 0:
		wear_parts.append("уд. -%d%%" % rod_loss)
	if line_loss > 0:
		wear_parts.append("леска -%d%%" % line_loss)
	if leader_loss > 0:
		wear_parts.append("поводок -%d%%" % leader_loss)
	if hook_loss > 0:
		wear_parts.append("крючок -%d%%" % hook_loss)

	if not wear_parts.is_empty():
		lines.append("Износ: %s" % ", ".join(wear_parts))
	if bool(wear.get("line_broken", false)):
		lines.append("Леска порвана.")
	if bool(wear.get("leader_broken", false)) or bool(wear.get("leader_lost", false)):
		lines.append("Поводок потерян.")
	if bool(wear.get("rod_broken", false)):
		lines.append("Удочка повреждена.")
	if bool(wear.get("hook_lost", false)):
		lines.append("Крючок потерян.")
	if bool(wear.get("float_lost", false)):
		lines.append("Поплавок потерян.")

	return "\n".join(lines)


func _get_rarity_title(rarity: String) -> String:
	match rarity:
		"uncommon":
			return "Необычная"
		"rare":
			return "Редкая"
		"trophy":
			return "Трофейная"
		_:
			return "Обычная"


func _get_rarity_color(rarity: String) -> Color:
	match rarity:
		"trophy":
			return Color(1.0, 0.80, 0.38, 1.0)
		"rare":
			return Color(0.54, 0.86, 1.0, 1.0)
		"uncommon":
			return Color(0.58, 1.0, 0.64, 1.0)
		_:
			return Color(0.72, 0.86, 0.76, 1.0)


func _is_tackle_item_equipped(item: Dictionary) -> bool:
	var category = main._tackle_category

	if not PlayerData.current_tackle.has(category):
		return false

	return str(PlayerData.current_tackle[category].get("id", "")) == str(item.get("id", ""))
