# Handles the player profile window: stats, trophies, and personal records.
extends RefCounted

const SkillTreeUIScript := preload("res://scripts/ui/SkillTreeUI.gd")

var main
var theme
var backdrop: ColorRect
var panel: Panel
var title_label: Label
var close_button: Button
var scroll: ScrollContainer
var content: VBoxContainer
var skill_tree_ui

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	_ensure_profile_ui_nodes()
	if skill_tree_ui == null:
		skill_tree_ui = SkillTreeUIScript.new()
		skill_tree_ui.setup(main, self)

func open() -> void:
	if main._is_catch_reward_open():
		return

	main.open_modal("profile")
	main._active_nav_tab = "profile"
	backdrop.visible = true
	panel.visible = true
	refresh()
	main._refresh_bottom_nav_styles()

func close(reset_nav: bool = true) -> void:
	if panel == null or backdrop == null:
		return

	panel.visible = false
	backdrop.visible = false
	if skill_tree_ui != null:
		skill_tree_ui.close()
	main.close_modal("profile")
	if reset_nav:
		main._active_nav_tab = "fish"
		main._refresh_bottom_nav_styles()

func is_open() -> bool:
	return panel != null and panel.visible

func is_any_modal_open() -> bool:
	return is_open() or (skill_tree_ui != null and skill_tree_ui.is_open())

func refresh() -> void:
	if content == null:
		return

	for child in content.get_children():
		child.queue_free()

	_add_summary_section()
	_add_skill_tree_entry()
	_add_stats_section()
	_add_rescue_section()
	_add_trophies_section()
	_add_records_section()

func _ensure_profile_ui_nodes() -> void:
	if panel != null:
		return

	var parent: Node = main.get_modal_content_root() if main.has_method("get_modal_content_root") else main

	backdrop = ColorRect.new()
	backdrop.name = "ProfileBackdrop"
	backdrop.visible = false
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.z_index = main.MENU_BACKDROP_Z + 30
	theme.apply_modal_backdrop_style(backdrop)
	backdrop.color = Color(0.0, 0.0, 0.0, 0.84)
	parent.add_child(backdrop)

	panel = Panel.new()
	panel.name = "ProfilePanel"
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 48.0
	panel.offset_top = 38.0
	panel.offset_right = -48.0
	panel.offset_bottom = -38.0
	panel.z_index = main.MENU_PANEL_Z + 30
	theme.apply_panel_style(panel)
	parent.add_child(panel)

	title_label = Label.new()
	title_label.name = "ProfileTitleLabel"
	title_label.text = "Профиль"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title_label.offset_left = 220.0
	title_label.offset_top = 18.0
	title_label.offset_right = -220.0
	title_label.offset_bottom = 58.0
	title_label.add_theme_font_size_override("font_size", 25)
	title_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))
	panel.add_child(title_label)

	close_button = Button.new()
	close_button.name = "ProfileCloseButton"
	close_button.text = "Закрыть"
	close_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close_button.offset_left = -164.0
	close_button.offset_top = 18.0
	close_button.offset_right = -24.0
	close_button.offset_bottom = 58.0
	main._apply_button_style(close_button, main.STYLE_SECONDARY_BUTTON)
	close_button.pressed.connect(close)
	panel.add_child(close_button)

	scroll = ScrollContainer.new()
	scroll.name = "ProfileScroll"
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 28.0
	scroll.offset_top = 76.0
	scroll.offset_right = -28.0
	scroll.offset_bottom = -24.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_child(scroll)

	content = VBoxContainer.new()
	content.name = "ProfileContent"
	content.custom_minimum_size = Vector2(0.0, 0.0)
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)

func _close_other_panels() -> void:
	main.basket_panel.visible = false
	main.basket_backdrop.visible = false
	main.inventory_panel.visible = false
	main.inventory_backdrop.visible = false
	main.tackle_panel.visible = false
	main.tackle_backdrop.visible = false
	main.waterbody_panel.visible = false
	main.waterbody_backdrop.visible = false
	main.shop_panel.visible = false
	main.shop_backdrop.visible = false

func _add_summary_section() -> void:
	_add_section_title("Основная информация")
	var grid := _make_grid(4)
	content.add_child(grid)
	_add_stat_card(grid, "Имя", PlayerData.player_name)
	_add_stat_card(grid, "Уровень", "LVL %d" % PlayerData.level)
	_add_stat_card(grid, "Опыт", "%d / %d" % [PlayerData.current_xp, PlayerData.xp_to_next_level])
	_add_stat_card(grid, "Деньги", PlayerData.format_money(PlayerData.money))

func _add_skill_tree_entry() -> void:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, 82.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	theme.apply_card_style(card)
	content.add_child(card)

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 16.0
	row.offset_top = 12.0
	row.offset_right = -16.0
	row.offset_bottom = -12.0
	row.add_theme_constant_override("separation", 14)
	card.add_child(row)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 4)
	row.add_child(text_box)

	var title := Label.new()
	title.text = "Навыки"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	text_box.add_child(title)

	var points := Label.new()
	points.text = "Очки навыков: %d" % PlayerData.skill_points
	points.add_theme_font_size_override("font_size", 13)
	points.add_theme_color_override("font_color", Color(0.74, 0.86, 0.78, 0.96))
	text_box.add_child(points)

	var skill_button := Button.new()
	skill_button.text = "Навыки"
	skill_button.custom_minimum_size = Vector2(132.0, 42.0)
	main._apply_button_style(skill_button, main.STYLE_PRIMARY_BUTTON)
	skill_button.pressed.connect(open_skill_tree)
	row.add_child(skill_button)

func open_skill_tree() -> void:
	if skill_tree_ui == null:
		skill_tree_ui = SkillTreeUIScript.new()
		skill_tree_ui.setup(main, self)

	skill_tree_ui.open()

func _add_stats_section() -> void:
	_add_section_title("Статистика")
	var grid := _make_grid(3)
	content.add_child(grid)
	_add_stat_card(grid, "Всего поймано", "%d" % PlayerData.total_fish_caught)
	_add_stat_card(grid, "Трофеи", "%d" % PlayerData.total_trophies_caught)
	_add_stat_card(grid, "Раритеты", "%d" % PlayerData.total_rarity_caught)
	_add_stat_card(grid, "Самая крупная", _format_short_record(PlayerData.biggest_fish))
	_add_stat_card(grid, "Самая дорогая", _format_short_record(_get_most_expensive_catch()))
	_add_stat_card(grid, "Рекорды видов", "%d" % PlayerData.personal_records.size())

func _add_rescue_section() -> void:
	_add_section_title("Помощь")

	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, 118.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	theme.apply_card_style(card)
	content.add_child(card)

	var body := VBoxContainer.new()
	body.set_anchors_preset(Control.PRESET_FULL_RECT)
	body.offset_left = 16.0
	body.offset_top = 12.0
	body.offset_right = -16.0
	body.offset_bottom = -12.0
	body.add_theme_constant_override("separation", 10)
	card.add_child(body)

	var description := Label.new()
	description.text = "Если вы остались без денег и без рабочих снастей, можно получить базовый набор для продолжения ловли."
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size = Vector2(0.0, 34.0)
	description.add_theme_font_size_override("font_size", 13)
	description.add_theme_color_override("font_color", Color(0.74, 0.86, 0.78, 0.96))
	body.add_child(description)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(row)

	var check: Dictionary = PlayerData.can_claim_rescue_kit()
	var status_label := Label.new()
	status_label.text = str(check.get("reason", ""))
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color(0.88, 0.98, 0.88, 1.0))
	row.add_child(status_label)

	var rescue_button := Button.new()
	rescue_button.text = "Получить базовый набор"
	rescue_button.custom_minimum_size = Vector2(210.0, 42.0)
	rescue_button.disabled = not bool(check.get("allowed", false))
	main._apply_button_style(rescue_button, main.STYLE_PRIMARY_BUTTON if bool(check.get("allowed", false)) else main.STYLE_SECONDARY_BUTTON)
	rescue_button.pressed.connect(_on_rescue_kit_button_pressed.bind(status_label, rescue_button))
	row.add_child(rescue_button)

func _on_rescue_kit_button_pressed(status_label: Label, rescue_button: Button) -> void:
	rescue_button.disabled = true
	var result: Dictionary = PlayerData.claim_rescue_kit()
	var success := bool(result.get("success", false))
	var message := str(result.get("message", result.get("reason", "Базовый набор сейчас недоступен.")))
	status_label.text = message
	main._update_ui()
	main._show_toast(message, success)
	refresh()

func _add_trophies_section() -> void:
	_add_section_title("Последние трофеи")
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 8)
	content.add_child(list)

	if PlayerData.trophy_catches.is_empty():
		_add_empty_label(list)
		return

	var start_index: int = max(PlayerData.trophy_catches.size() - 8, 0)
	for i in range(PlayerData.trophy_catches.size() - 1, start_index - 1, -1):
		var record: Dictionary = PlayerData.trophy_catches[i]
		_add_record_card(list, record, true)

func _add_records_section() -> void:
	_add_section_title("Личные рекорды")
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 8)
	content.add_child(list)

	if PlayerData.personal_records.is_empty():
		_add_empty_label(list)
		return

	var records := PlayerData.personal_records.values()
	records.sort_custom(func(a, b): return float(a.get("weight", 0.0)) > float(b.get("weight", 0.0)))
	var limit: int = mini(records.size(), 16)
	for i in limit:
		_add_record_card(list, records[i], false)

func _add_section_title(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.92, 1.0, 0.86, 1.0))
	content.add_child(label)

func _make_grid(columns: int) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return grid

func _add_stat_card(parent: Control, label_text: String, value_text: String) -> void:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(190.0, 68.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	theme.apply_card_style(card)
	parent.add_child(card)

	var label := Label.new()
	label.text = label_text
	label.position = Vector2(14.0, 8.0)
	label.size = Vector2(168.0, 20.0)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.68, 0.78, 0.72, 0.92))
	card.add_child(label)

	var value := Label.new()
	value.text = value_text
	value.position = Vector2(14.0, 30.0)
	value.size = Vector2(168.0, 28.0)
	value.clip_text = true
	value.add_theme_font_size_override("font_size", 15)
	value.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	card.add_child(value)

func _add_record_card(parent: Control, record: Dictionary, compact: bool) -> void:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, 76.0 if compact else 90.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	theme.apply_card_style(card)
	parent.add_child(card)

	var name_label := Label.new()
	name_label.text = str(record.get("fish_name", record.get("name", "-")))
	name_label.position = Vector2(14.0, 8.0)
	name_label.size = Vector2(260.0, 24.0)
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))
	card.add_child(name_label)

	var rank := str(record.get("catch_rank", "normal"))
	var rank_label := Label.new()
	rank_label.text = _get_rank_label(rank)
	rank_label.position = Vector2(286.0, 9.0)
	rank_label.size = Vector2(100.0, 22.0)
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rank_label.add_theme_font_size_override("font_size", 12)
	rank_label.add_theme_color_override("font_color", _get_rank_color(rank))
	rank_label.add_theme_stylebox_override("normal", main._make_panel_style(Color(0.035, 0.075, 0.062, 0.74), Color(_get_rank_color(rank).r, _get_rank_color(rank).g, _get_rank_color(rank).b, 0.34), 10, 3))
	card.add_child(rank_label)

	var main_line := Label.new()
	main_line.text = "%.2f кг  |  %.1f см  |  %s" % [
		float(record.get("weight", 0.0)),
		float(record.get("length_cm", 0.0)),
		str(record.get("spot_name", "-"))
	]
	main_line.position = Vector2(14.0, 36.0)
	main_line.size = Vector2(560.0, 22.0)
	main_line.clip_text = true
	main_line.add_theme_font_size_override("font_size", 13)
	main_line.add_theme_color_override("font_color", Color(0.78, 0.90, 0.82, 0.95))
	card.add_child(main_line)

	var extra := Label.new()
	extra.text = "%s  |  наживка: %s" % [
		str(record.get("waterbody_name", "-")),
		str(record.get("bait", "-"))
	]
	if not compact:
		extra.text += "  |  %s" % str(record.get("caught_at", ""))
	extra.position = Vector2(14.0, 58.0)
	extra.size = Vector2(760.0, 22.0)
	extra.clip_text = true
	extra.add_theme_font_size_override("font_size", 12)
	extra.add_theme_color_override("font_color", Color(0.62, 0.72, 0.68, 0.92))
	card.add_child(extra)

func _add_empty_label(parent: Control) -> void:
	var label := Label.new()
	label.text = "Пока нет данных"
	label.custom_minimum_size = Vector2(0.0, 34.0)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.68, 0.76, 0.72, 0.90))
	parent.add_child(label)

func _format_short_record(record: Dictionary) -> String:
	if record.is_empty():
		return "Пока нет данных"
	return "%s %.2f кг" % [
		str(record.get("fish_name", record.get("name", "-"))),
		float(record.get("weight", 0.0))
	]

func _get_most_expensive_catch() -> Dictionary:
	var best := {}
	for record in PlayerData.personal_records.values():
		if typeof(record) != TYPE_DICTIONARY:
			continue
		if best.is_empty() or int(record.get("price", 0)) > int(best.get("price", 0)):
			best = record
	return best

func _get_rank_label(rank: String) -> String:
	match rank:
		"rarity":
			return "раритет"
		"trophy":
			return "трофей"
		_:
			return "обычная"

func _get_rank_color(rank: String) -> Color:
	match rank:
		"rarity":
			return Color(0.80, 0.56, 1.0, 1.0)
		"trophy":
			return Color(1.0, 0.82, 0.40, 1.0)
		_:
			return Color(0.72, 0.86, 0.76, 1.0)
