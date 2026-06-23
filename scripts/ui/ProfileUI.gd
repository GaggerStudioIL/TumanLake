# Handles the player profile window: identity, skills, help, and records.
extends RefCounted

const SkillTreeUIScript := preload("res://scripts/ui/SkillTreeUI.gd")
const LevelRankData := preload("res://scripts/data/LevelRankData.gd")

const TAB_INFO := "info"
const TAB_SKILLS := "skills"
const TAB_HELP := "help"
const TAB_RECORDS := "records"

var main
var theme
var backdrop: ColorRect
var panel: Panel
var title_label: Label
var close_button: Button
var tabs: HBoxContainer
var scroll: ScrollContainer
var content: VBoxContainer
var skill_tree_ui
var _active_tab := TAB_INFO

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
	if main.has_method("refresh_mobile_scroll_helper"):
		main.refresh_mobile_scroll_helper()
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

	_refresh_tabs()
	_clear_children(content)
	match _active_tab:
		TAB_SKILLS:
			_add_skills_section()
		TAB_HELP:
			_add_help_section()
		TAB_RECORDS:
			_add_records_section()
		_:
			_add_info_section()


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
	title_label.offset_top = 16.0
	title_label.offset_right = -220.0
	title_label.offset_bottom = 56.0
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

	tabs = HBoxContainer.new()
	tabs.name = "ProfileTabs"
	tabs.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tabs.offset_left = 28.0
	tabs.offset_top = 72.0
	tabs.offset_right = -28.0
	tabs.offset_bottom = 116.0
	tabs.add_theme_constant_override("separation", 8)
	panel.add_child(tabs)

	scroll = ScrollContainer.new()
	scroll.name = "ProfileScroll"
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 28.0
	scroll.offset_top = 144.0
	scroll.offset_right = -28.0
	scroll.offset_bottom = -24.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_child(scroll)

	content = VBoxContainer.new()
	content.name = "ProfileContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)


func _refresh_tabs() -> void:
	_clear_children(tabs)
	var data := [
		[TAB_INFO, "Общее"],
		[TAB_SKILLS, "Навыки"],
		[TAB_HELP, "Помощь"],
		[TAB_RECORDS, "Рекорды"]
	]
	for item in data:
		var button := Button.new()
		button.text = str(item[1])
		button.custom_minimum_size = Vector2(0.0, 42.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.clip_text = true
		main._apply_button_style(button, main.STYLE_PRIMARY_BUTTON if str(item[0]) == _active_tab else main.STYLE_SECONDARY_BUTTON)
		button.pressed.connect(_set_active_tab.bind(str(item[0])))
		tabs.add_child(button)


func _set_active_tab(tab_id: String) -> void:
	_active_tab = tab_id
	refresh()


func _add_info_section() -> void:
	var top := HBoxContainer.new()
	top.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_theme_constant_override("separation", 18)
	content.add_child(top)

	var avatar := Panel.new()
	avatar.custom_minimum_size = Vector2(124.0, 124.0)
	avatar.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	avatar.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	theme.apply_card_style(avatar)
	top.add_child(avatar)

	var rank_icon := TextureRect.new()
	rank_icon.name = "ProfileRankIcon"
	rank_icon.texture = LevelRankData.get_icon_for_level(PlayerData.level)
	rank_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rank_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rank_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rank_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	rank_icon.offset_left = 14.0
	rank_icon.offset_top = 10.0
	rank_icon.offset_right = -14.0
	rank_icon.offset_bottom = -10.0
	avatar.add_child(rank_icon)

	var grid := _make_grid(3)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(grid)
	_add_stat_card(grid, "Имя", PlayerData.player_name)
	_add_stat_card(grid, "Уровень", "LVL %d" % PlayerData.level)
	_add_stat_card(grid, "Опыт", "%d / %d" % [PlayerData.current_xp, PlayerData.xp_to_next_level])
	_add_stat_card(grid, "Деньги", UIFormatters.format_money(PlayerData.money))
	_add_stat_card(grid, "Водоём", _get_current_waterbody_name())
	_add_stat_card(grid, "Поймано рыб", "%d" % PlayerData.total_fish_caught)
	_add_stat_card(grid, "Рекорд за сутки", _format_daily_weight_record())
	_add_stat_card(grid, "Самый дорогой улов", _format_short_record(_get_most_expensive_catch(), true))
	_add_stat_card(grid, "Самая крупная рыба", _format_short_record(PlayerData.biggest_fish))
	_add_stat_card(grid, "Трофеи", "%d" % PlayerData.total_trophies_caught)


func _add_skills_section() -> void:
	var intro := Panel.new()
	intro.custom_minimum_size = Vector2(0.0, 68.0)
	intro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	theme.apply_card_style(intro)
	content.add_child(intro)

	var points := _make_label("Очки навыков: %d" % PlayerData.skill_points, 16, Color(0.94, 1.0, 0.92, 1.0))
	points.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	points.offset_left = 16.0
	points.offset_top = 0.0
	points.offset_right = -330.0
	points.offset_bottom = 0.0
	points.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	intro.add_child(points)

	var skill_button := Button.new()
	skill_button.text = "Ветка Навыков"
	skill_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	skill_button.offset_left = -292.0
	skill_button.offset_top = 16.0
	skill_button.offset_right = -26.0
	skill_button.offset_bottom = 52.0
	skill_button.custom_minimum_size = Vector2(0.0, 0.0)
	main._apply_button_style(skill_button, main.STYLE_PRIMARY_BUTTON)
	skill_button.pressed.connect(open_skill_tree)
	intro.add_child(skill_button)

	var skill_database := _get_skill_database()
	if skill_database == null:
		_add_empty_label(content, "Система навыков пока недоступна.")
		return

	var branch_ids: Array = skill_database.call("get_branch_ids") if skill_database.has_method("get_branch_ids") else []
	if branch_ids.is_empty():
		_add_empty_label(content, "Навыки пока не настроены.")
		return

	var grid := GridContainer.new()
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	content.add_child(grid)

	for branch_id in branch_ids:
		_add_skill_branch_card(grid, str(branch_id), skill_database)


func _add_skill_branch_card(parent: Control, branch_id: String, skill_database: Node) -> void:
	var skills: Array = skill_database.call("get_branch_skills", branch_id) if skill_database.has_method("get_branch_skills") else []
	var learned: int = 0
	for skill in skills:
		if typeof(skill) != TYPE_DICTIONARY:
			continue
		var skill_id := str(skill.get("id", ""))
		if PlayerData.has_skill(skill_id):
			learned += 1

	var total: int = maxi(skills.size(), 1)
	var card := Button.new()
	card.text = ""
	card.custom_minimum_size = Vector2(172.0, 92.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.focus_mode = Control.FOCUS_NONE
	main._apply_button_style(card, main.STYLE_SECONDARY_BUTTON)
	card.pressed.connect(_open_skill_branch.bind(branch_id))
	parent.add_child(card)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 10.0
	box.offset_top = 9.0
	box.offset_right = -10.0
	box.offset_bottom = -8.0
	box.add_theme_constant_override("separation", 4)
	card.add_child(box)

	var title := _make_label(str(skill_database.call("get_branch_title", branch_id)), 15, Color(0.94, 1.0, 0.92, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(title)

	var learned_label := _make_label("Изучено %d/%d" % [learned, total], 12, Color(0.74, 0.88, 0.80, 0.95))
	learned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	learned_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(learned_label)


func _open_skill_branch(branch_id: String) -> void:
	if skill_tree_ui == null:
		skill_tree_ui = SkillTreeUIScript.new()
		skill_tree_ui.setup(main, self)
	if skill_tree_ui.has_method("open_tree"):
		skill_tree_ui.open_tree(branch_id)
	else:
		skill_tree_ui.open()


func open_skill_tree() -> void:
	if skill_tree_ui == null:
		skill_tree_ui = SkillTreeUIScript.new()
		skill_tree_ui.setup(main, self)
	skill_tree_ui.open()


func _add_help_section() -> void:
	var sections := [
		["Основы ловли", [
			["Как ловить рыбу", "Выберите водоём и точку, соберите снасть, выставьте глубину и нажмите заброс. Следите за поплавком: при уверенной поклёвке подсекайте и держите натяжение в безопасной зоне."],
			["Глубина и точка", "Разная рыба держится на разной глубине и в разных местах. Если поклёвок мало, смените глубину, наживку или точку ловли."],
			["Вываживание", "Во время вываживания удерживайте натяжение в рабочей зоне. Слишком слабое натяжение повышает шанс схода, слишком сильное увеличивает риск обрыва."],
			["Сход и обрыв", "Если рыба резко дёргает снасть, слабый элемент может не выдержать. Обычно рвётся самый слабый участок: поводок, леска или повреждённая часть оснастки."]
		]],
		["Снасти и сборка", [
			["Полная снасть", "Для маховой ловли нужны: удочка, основная леска, поводок, крючок, поплавок и наживка. Если обязательный элемент не установлен, игра покажет предупреждение."],
			["Поводки", "Поводок ставится между основной леской и крючком. Тонкий поводок лучше для осторожной рыбы, мощный поводок надёжнее на крупной рыбе, но может снижать шанс поклёвки мелочи."],
			["Обрыв поводка", "При обрыве поводка обычно теряются поводок, крючок и наживка. Удочка, основная леска и поплавок остаются. При обрыве основной лески потери могут быть больше."],
			["Наживка и бутерброд", "Навык «Ловля на бутерброд» открывает второй слот наживки для маховой снасти. Если установлены две наживки, система поклёвки учитывает обе, а при поклёвке расходуется по одной единице каждой активной наживки."],
			["Износ снасти", "Снасти изнашиваются при ловле и сильном вываживании. Следите за прочностью: повреждённые элементы чаще ломаются и хуже держат рывки."]
		]],
		["Улов и продажа", [
			["Садок", "Садок хранит пойманную рыбу до продажи или отпускания. Рыба попадает в садок после успешного вылова."],
			["Рыбная гавань", "Рыбная гавань нужна для продажи улова, сравнения покупателей, просмотра контрактов, спроса рынка и репутации."],
			["Покупатели", "У покупателей разные условия: одни ценят вес, другие редкость, качество, конкретные виды или вашу репутацию."],
			["Рынок", "Спрос меняется по игровым дням. Если у вида высокий рыночный множитель, продавать его сегодня выгоднее."],
			["Контракты", "Контракты требуют конкретную рыбу, вес, качество или количество. Прогресс засчитывается при подходящей продаже."],
			["Зачётная и трофейная рыба", "Зачётная рыба достигла минимального полезного веса и стоит дороже мелочи. Трофейная рыба сильно превышает норму вида и получает большой ценовой бонус."]
		]],
		["Развитие", [
			["Навыки", "За повышение уровня игрок получает очки навыков. Ветки развивают разные стили ловли, ремесло, кулинарию и выживание. Финальные навыки требуют вложений в ветку и ключевых умений."],
			["Очки навыков", "Чем выше уровень, тем больше очков даётся за следующий уровень. Обычные навыки имеют ранги, и каждый следующий ранг стоит дороже."],
			["Ремесло", "Ремесленные навыки готовят добычу наживки, создание поводков, прикормки и ремонт снастей. Часть возможностей может открываться позже по мере развития механик."],
			["Кулинария и выживание", "Кулинария готовит еду и будущие бонусы. Выживание снижает влияние холода, жары, ночной рыбалки и расход энергии на сложных водоёмах."]
		]]
	]

	for section in sections:
		_add_help_section_title(str(section[0]))
		for topic in section[1]:
			_add_help_card(str(topic[0]), str(topic[1]))
	_add_rescue_kit_card()


func _add_help_section_title(text: String) -> void:
	var label := _make_label(text, 16, Color(0.92, 1.0, 0.86, 1.0))
	label.custom_minimum_size = Vector2(0.0, 26.0)
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	content.add_child(label)


func _add_help_card(title_text: String, body_text: String) -> void:
	var card := Panel.new()
	var card_height: float = _estimate_help_card_height(title_text, body_text)
	card.custom_minimum_size = Vector2(0.0, card_height)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	theme.apply_card_style(card)
	content.add_child(card)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.offset_left = 14.0
	margin.offset_top = 9.0
	margin.offset_right = -14.0
	margin.offset_bottom = -10.0
	card.add_child(margin)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 7)
	margin.add_child(box)

	var title := _make_label(title_text, 15, Color(0.94, 1.0, 0.92, 1.0))
	title.custom_minimum_size = Vector2(0.0, 24.0)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.clip_text = false
	box.add_child(title)

	var body := _make_label(body_text, 12, Color(0.74, 0.84, 0.80, 0.94))
	body.custom_minimum_size = Vector2(0.0, card_height - 54.0)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.autowrap_mode = TextServer.AUTOWRAP_WORD
	body.clip_text = false
	box.add_child(body)


func _estimate_help_card_height(title_text: String, body_text: String) -> float:
	var body_lines: int = ceili(float(body_text.length()) / 72.0)
	body_lines += body_text.count("\n")
	var title_lines: int = ceili(float(title_text.length()) / 54.0)
	return maxf(86.0, 34.0 + float(maxi(title_lines, 1)) * 20.0 + float(maxi(body_lines, 1)) * 18.0)


func _add_rescue_kit_card() -> void:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, 118.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	theme.apply_card_style(card)
	content.add_child(card)

	var title := _make_label("Базовый набор помощи", 15, Color(0.94, 1.0, 0.92, 1.0))
	title.position = Vector2(14.0, 9.0)
	title.size = Vector2(360.0, 22.0)
	card.add_child(title)

	var check: Dictionary = PlayerData.can_claim_rescue_kit()
	var body := _make_label(str(check.get("reason", "")), 12, Color(0.74, 0.84, 0.80, 0.94))
	body.position = Vector2(14.0, 36.0)
	body.size = Vector2(500.0, 72.0)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.clip_text = false
	card.add_child(body)

	var button := Button.new()
	button.text = "Получить"
	button.disabled = not bool(check.get("allowed", false))
	button.position = Vector2(560.0, 58.0)
	button.size = Vector2(126.0, 40.0)
	main._apply_button_style(button, main.STYLE_PRIMARY_BUTTON if bool(check.get("allowed", false)) else main.STYLE_SECONDARY_BUTTON)
	button.pressed.connect(_on_rescue_kit_button_pressed.bind(body, button))
	card.add_child(button)


func _on_rescue_kit_button_pressed(status_label: Label, rescue_button: Button) -> void:
	rescue_button.disabled = true
	var result: Dictionary = PlayerData.claim_rescue_kit()
	var success := bool(result.get("success", false))
	var message := str(result.get("message", result.get("reason", "Базовый набор сейчас недоступен.")))
	status_label.text = message
	main._update_ui()
	main._show_toast(message, success)
	refresh()


func _add_records_section() -> void:
	var grid := _make_grid(3)
	content.add_child(grid)
	_add_stat_card(grid, "Самая крупная рыба", _format_short_record(PlayerData.biggest_fish))
	_add_stat_card(grid, "Самая дорогая рыба", _format_short_record(_get_most_expensive_catch(), true))
	_add_stat_card(grid, "Трофеи по видам", "%d" % PlayerData.trophy_catches.size())
	_add_stat_card(grid, "Личные рекорды", "%d" % PlayerData.personal_records.size())
	_add_stat_card(grid, "Самый дорогой общий улов", "пока нет данных")
	_add_stat_card(grid, "Трофеи по водоёмам", "пока нет данных")

	_add_section_title("Личные рекорды по видам")
	var records: Array = PlayerData.personal_records.values()
	if records.is_empty():
		_add_empty_label(content, "Пока нет личных рекордов.")
	else:
		records.sort_custom(func(a, b): return float(a.get("weight", 0.0)) > float(b.get("weight", 0.0)))
		for i in mini(records.size(), 18):
			_add_record_card(content, records[i])

	_add_section_title("Последние трофеи")
	if PlayerData.trophy_catches.is_empty():
		_add_empty_label(content, "Трофеев пока нет.")
	else:
		var start_index: int = maxi(PlayerData.trophy_catches.size() - 8, 0)
		for i in range(PlayerData.trophy_catches.size() - 1, start_index - 1, -1):
			_add_record_card(content, PlayerData.trophy_catches[i])


func _add_record_card(parent: Control, record: Dictionary) -> void:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, 82.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	theme.apply_card_style(card)
	parent.add_child(card)

	var name_label := _make_label(str(record.get("fish_name", record.get("name", "-"))), 16, Color(0.94, 1.0, 0.90, 1.0))
	name_label.position = Vector2(14.0, 8.0)
	name_label.size = Vector2(260.0, 24.0)
	name_label.clip_text = true
	card.add_child(name_label)

	var rank := str(record.get("catch_rank", "normal"))
	var rank_label := _make_label(_get_rank_label(rank), 12, _get_rank_color(rank))
	rank_label.position = Vector2(286.0, 9.0)
	rank_label.size = Vector2(100.0, 22.0)
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rank_label.add_theme_stylebox_override("normal", main._make_panel_style(Color(0.035, 0.075, 0.062, 0.74), Color(_get_rank_color(rank).r, _get_rank_color(rank).g, _get_rank_color(rank).b, 0.34), 10, 3))
	card.add_child(rank_label)

	var main_line := _make_label("%s | %s | %s" % [
		UIFormatters.format_weight_kg(float(record.get("weight", 0.0))),
		UIFormatters.format_length_cm(float(record.get("length_cm", 0.0))),
		str(record.get("spot_name", "-"))
	], 13, Color(0.78, 0.90, 0.82, 0.95))
	main_line.position = Vector2(14.0, 36.0)
	main_line.size = Vector2(620.0, 22.0)
	main_line.clip_text = true
	card.add_child(main_line)

	var extra := _make_label("%s | наживка: %s" % [
		str(record.get("waterbody_name", "-")),
		str(record.get("bait", "-"))
	], 12, Color(0.62, 0.72, 0.68, 0.92))
	extra.position = Vector2(14.0, 58.0)
	extra.size = Vector2(660.0, 20.0)
	extra.clip_text = true
	card.add_child(extra)


func _add_section_title(text: String) -> void:
	var label := _make_label(text, 18, Color(0.92, 1.0, 0.86, 1.0))
	content.add_child(label)


func _make_grid(columns: int) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 12)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return grid


func _add_stat_card(parent: Control, label_text: String, value_text: String) -> void:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(178.0, 66.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	theme.apply_card_style(card)
	parent.add_child(card)

	var label := _make_label(label_text, 12, Color(0.68, 0.78, 0.72, 0.92))
	label.position = Vector2(14.0, 8.0)
	label.size = Vector2(150.0, 20.0)
	label.clip_text = true
	card.add_child(label)

	var value := _make_label(value_text, 15, Color(0.94, 1.0, 0.92, 1.0))
	value.position = Vector2(14.0, 31.0)
	value.size = Vector2(150.0, 28.0)
	value.clip_text = true
	card.add_child(value)


func _add_empty_label(parent: Control, text: String = "Пока нет данных") -> void:
	var label := _make_label(text, 14, Color(0.68, 0.76, 0.72, 0.90))
	label.custom_minimum_size = Vector2(0.0, 34.0)
	parent.add_child(label)


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _get_skill_database() -> Node:
	return main.get_node_or_null("/root/SkillDatabase")


func _get_current_waterbody_name() -> String:
	if main != null and main.has_method("_get_waterbody"):
		var waterbody: Dictionary = main._get_waterbody(PlayerData.current_waterbody)
		if not waterbody.is_empty():
			return str(waterbody.get("name", PlayerData.current_waterbody))
	var waterbody_db: Node = main.get_node_or_null("/root/WaterbodyDatabase") if main != null else null
	if waterbody_db != null and waterbody_db.has_method("get_waterbody"):
		var value = waterbody_db.call("get_waterbody", PlayerData.current_waterbody)
		if value is Dictionary:
			return str((value as Dictionary).get("name", PlayerData.current_waterbody))
	return PlayerData.current_waterbody


func _get_player_initials() -> String:
	var name := PlayerData.player_name.strip_edges()
	if name.is_empty():
		return "Р"
	return name.substr(0, 1).to_upper()


func _format_short_record(record: Dictionary, include_price: bool = false) -> String:
	if record.is_empty():
		return "пока нет данных"
	var text := "%s %s" % [
		str(record.get("fish_name", record.get("name", "-"))),
		UIFormatters.format_weight_kg(float(record.get("weight", 0.0)))
	]
	if include_price:
		text += " | %s" % UIFormatters.format_money(float(record.get("price", 0)))
	return text


func _format_daily_weight_record() -> String:
	var weight: float = maxf(float(PlayerData.best_daily_fish_weight), float(PlayerData.daily_fish_weight))
	if weight <= 0.0:
		return "пока нет данных"
	return UIFormatters.format_weight_kg(weight)


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


func _clear_children(node: Node) -> void:
	if node == null:
		return
	for child in node.get_children():
		child.queue_free()
