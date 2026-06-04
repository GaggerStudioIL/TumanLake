# Handles the player skill tree modal.
extends RefCounted

var main
var profile_ui
var theme
var backdrop: ColorRect
var panel: Panel
var header_label: Label
var close_button: Button
var back_button: Button
var points_label: Label
var content_root: Control
var selected_tree_id := ""
var selected_skill_id := ""

func setup(main_ref, profile_ref = null) -> void:
	main = main_ref
	profile_ui = profile_ref
	theme = main.ui_theme
	_ensure_ui_nodes()

func open() -> void:
	if main._is_catch_reward_open():
		return

	_ensure_ui_nodes()
	selected_tree_id = ""
	selected_skill_id = ""
	backdrop.visible = true
	panel.visible = true
	main._refresh_modal_input_blocker()
	refresh()

func open_tree(tree_id: String) -> void:
	if main._is_catch_reward_open():
		return

	_ensure_ui_nodes()
	selected_tree_id = tree_id
	selected_skill_id = ""
	backdrop.visible = true
	panel.visible = true
	main._refresh_modal_input_blocker()
	refresh()

func close() -> void:
	if panel == null or backdrop == null:
		return

	panel.visible = false
	backdrop.visible = false
	main._refresh_modal_input_blocker()

func is_open() -> bool:
	return panel != null and panel.visible

func refresh() -> void:
	if content_root == null:
		return

	_clear_children(content_root)
	var skill_database := _get_skill_database()
	if skill_database == null:
		header_label.text = "Навыки"
		points_label.text = "База навыков недоступна"
		_add_empty_label(content_root, "Система навыков сейчас недоступна.")
		return

	points_label.text = "Ур. %d    Очки: %d    Всего: %d" % [
		PlayerData.level,
		PlayerData.skill_points,
		PlayerData.total_skill_points_earned
	]

	if selected_tree_id == "":
		_build_tree_list(skill_database)
	else:
		_build_tree_detail(skill_database)

func _ensure_ui_nodes() -> void:
	if panel != null:
		return

	var parent: Node = main.get_modal_content_root() if main.has_method("get_modal_content_root") else main

	backdrop = ColorRect.new()
	backdrop.name = "SkillTreeBackdrop"
	backdrop.visible = false
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.z_index = main.MENU_BACKDROP_Z + 42
	if theme != null and theme.has_method("apply_modal_backdrop_style"):
		theme.apply_modal_backdrop_style(backdrop)
	backdrop.color = Color(0.0, 0.0, 0.0, 0.82)
	parent.add_child(backdrop)

	panel = Panel.new()
	panel.name = "SkillTreePanel"
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 116.0
	panel.offset_top = 40.0
	panel.offset_right = -116.0
	panel.offset_bottom = -36.0
	panel.z_index = main.MENU_PANEL_Z + 42
	theme.apply_panel_style(panel)
	parent.add_child(panel)

	header_label = Label.new()
	header_label.name = "SkillTreeHeaderLabel"
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header_label.offset_left = 190.0
	header_label.offset_top = 10.0
	header_label.offset_right = -190.0
	header_label.offset_bottom = 46.0
	header_label.add_theme_font_size_override("font_size", 21)
	header_label.add_theme_color_override("font_color", Color(0.91, 0.98, 1.0, 1.0))
	panel.add_child(header_label)

	points_label = Label.new()
	points_label.name = "SkillTreePointsLabel"
	points_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	points_label.offset_left = 18.0
	points_label.offset_top = 12.0
	points_label.offset_right = 260.0
	points_label.offset_bottom = 44.0
	points_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	points_label.add_theme_font_size_override("font_size", 13)
	points_label.add_theme_color_override("font_color", Color(0.75, 0.95, 1.0, 0.96))
	panel.add_child(points_label)

	back_button = Button.new()
	back_button.name = "SkillTreeBackButton"
	back_button.text = "<"
	back_button.visible = false
	back_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	back_button.offset_left = 18.0
	back_button.offset_top = 50.0
	back_button.offset_right = 70.0
	back_button.offset_bottom = 84.0
	main._apply_button_style(back_button, main.STYLE_SECONDARY_BUTTON)
	back_button.pressed.connect(_on_back_pressed)
	panel.add_child(back_button)

	close_button = Button.new()
	close_button.name = "SkillTreeCloseButton"
	close_button.text = "Закрыть"
	close_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close_button.offset_left = -132.0
	close_button.offset_top = 12.0
	close_button.offset_right = -18.0
	close_button.offset_bottom = 44.0
	main._apply_button_style(close_button, main.STYLE_SECONDARY_BUTTON)
	close_button.pressed.connect(close)
	panel.add_child(close_button)

	content_root = Control.new()
	content_root.name = "SkillTreeContentRoot"
	content_root.mouse_filter = Control.MOUSE_FILTER_STOP
	content_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	content_root.offset_left = 18.0
	content_root.offset_top = 88.0
	content_root.offset_right = -18.0
	content_root.offset_bottom = -18.0
	panel.add_child(content_root)

func _build_tree_list(skill_database: Node) -> void:
	header_label.text = "Навыки"
	back_button.visible = false

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	content_root.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)

	for tree_id in skill_database.call("get_tree_ids"):
		_add_tree_row(list, str(tree_id), skill_database)

func _add_tree_row(parent: Control, tree_id: String, skill_database: Node) -> void:
	var tree: Dictionary = skill_database.call("get_skill_tree", tree_id)
	var progress: Dictionary = tree.get("progress", {})
	var row := Button.new()
	row.custom_minimum_size = Vector2(0.0, 54.0)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.text = "%s  %s\n%s     %d/%d рангов, %d/%d очков     >" % [
		_get_tree_icon(str(tree.get("icon", ""))),
		str(tree.get("title", tree_id)),
		str(tree.get("description", "")),
		int(progress.get("rank_points", 0)),
		int(progress.get("max_rank_points", 0)),
		int(progress.get("spent_points", 0)),
		int(progress.get("max_points", 0))
	]
	row.alignment = HORIZONTAL_ALIGNMENT_LEFT
	row.tooltip_text = str(tree.get("description", ""))
	_apply_row_button_style(row, false)
	row.pressed.connect(_open_tree.bind(tree_id))
	parent.add_child(row)

func _build_tree_detail(skill_database: Node) -> void:
	var tree: Dictionary = skill_database.call("get_skill_tree", selected_tree_id)
	header_label.text = "Навыки  >  %s" % str(tree.get("title", selected_tree_id))
	back_button.visible = true

	var split := HBoxContainer.new()
	split.set_anchors_preset(Control.PRESET_FULL_RECT)
	split.add_theme_constant_override("separation", 12)
	content_root.add_child(split)

	var left_panel := Panel.new()
	left_panel.custom_minimum_size = Vector2(390.0, 0.0)
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_card_style(left_panel, false)
	split.add_child(left_panel)

	var skill_scroll := ScrollContainer.new()
	skill_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	skill_scroll.offset_left = 10.0
	skill_scroll.offset_top = 10.0
	skill_scroll.offset_right = -10.0
	skill_scroll.offset_bottom = -10.0
	skill_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	skill_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	skill_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	left_panel.add_child(skill_scroll)

	var skill_list := VBoxContainer.new()
	skill_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_list.add_theme_constant_override("separation", 8)
	skill_scroll.add_child(skill_list)

	var skills: Array = skill_database.call("get_tree_skills", selected_tree_id)
	if selected_skill_id == "" and not skills.is_empty():
		selected_skill_id = str((skills[0] as Dictionary).get("id", ""))

	for skill in skills:
		if skill is Dictionary:
			_add_skill_row(skill_list, skill as Dictionary, skill_database)

	var detail_panel := Panel.new()
	detail_panel.custom_minimum_size = Vector2(300.0, 0.0)
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_card_style(detail_panel, true)
	split.add_child(detail_panel)
	_build_skill_detail_card(detail_panel, skill_database)

func _add_skill_row(parent: Control, skill: Dictionary, skill_database: Node) -> void:
	var skill_id := str(skill.get("id", ""))
	var rank := PlayerData.get_skill_rank(skill_id)
	var max_rank := int(skill.get("max_rank", 5))
	var check: Dictionary = skill_database.call("can_upgrade_skill", skill_id)
	var selected := skill_id == selected_skill_id
	var is_final := bool(skill.get("is_final_skill", false))
	var locked := not bool(check.get("unlocked", false)) and rank <= 0
	var prefix := "[*] " if selected else ""
	if locked:
		prefix = "[L] "
	var row := Button.new()
	row.custom_minimum_size = Vector2(0.0, 48.0)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.text = "%s%s  %s\n%s  %d/%d" % [
		prefix,
		_get_tree_icon(str(skill.get("icon", ""))),
		str(skill.get("title", skill_id)),
		_rank_dots(rank, max_rank),
		rank,
		max_rank
	]
	row.alignment = HORIZONTAL_ALIGNMENT_LEFT
	row.tooltip_text = str(check.get("reason", ""))
	_apply_row_button_style(row, is_final, selected, locked)
	row.pressed.connect(_select_skill.bind(skill_id))
	parent.add_child(row)

func _build_skill_detail_card(parent: Panel, skill_database: Node) -> void:
	var skill: Dictionary = skill_database.call("get_skill", selected_skill_id)
	if skill.is_empty():
		_add_empty_label(parent, "Навык не выбран.")
		return

	var body := VBoxContainer.new()
	body.set_anchors_preset(Control.PRESET_FULL_RECT)
	body.offset_left = 16.0
	body.offset_top = 16.0
	body.offset_right = -16.0
	body.offset_bottom = -16.0
	body.add_theme_constant_override("separation", 9)
	parent.add_child(body)

	var rank := PlayerData.get_skill_rank(selected_skill_id)
	var max_rank := int(skill.get("max_rank", 5))
	var check: Dictionary = skill_database.call("can_upgrade_skill", selected_skill_id)
	var can_upgrade := bool(check.get("can_upgrade", false))
	var cost := int(check.get("cost", skill_database.call("get_next_rank_cost", selected_skill_id)))

	var title := Label.new()
	title.text = "%s %s" % [_get_tree_icon(str(skill.get("icon", ""))), str(skill.get("title", selected_skill_id))]
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 20 if not bool(skill.get("is_final_skill", false)) else 21)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42, 1.0) if bool(skill.get("is_final_skill", false)) else Color(0.92, 0.98, 1.0, 1.0))
	body.add_child(title)

	var rank_label := Label.new()
	rank_label.text = "Ранг %d/%d    %s" % [rank, max_rank, _rank_dots(rank, max_rank)]
	rank_label.add_theme_font_size_override("font_size", 14)
	rank_label.add_theme_color_override("font_color", Color(0.76, 0.92, 1.0, 0.98))
	body.add_child(rank_label)

	var description := Label.new()
	description.text = str(skill.get("description", ""))
	description.custom_minimum_size = Vector2(0.0, 80.0)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 13)
	description.add_theme_color_override("font_color", Color(0.76, 0.86, 0.84, 0.96))
	body.add_child(description)

	var bonus := Label.new()
	bonus.text = _get_bonus_text(skill_database, selected_skill_id, rank)
	bonus.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bonus.add_theme_font_size_override("font_size", 13)
	bonus.add_theme_color_override("font_color", Color(0.50, 1.0, 0.72, 1.0))
	body.add_child(bonus)

	var req := Label.new()
	req.text = _get_requirement_text(skill, check, cost, rank, max_rank)
	req.custom_minimum_size = Vector2(0.0, 66.0)
	req.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	req.add_theme_font_size_override("font_size", 12)
	req.add_theme_color_override("font_color", Color(1.0, 0.78, 0.50, 0.96) if not can_upgrade and rank < max_rank else Color(0.72, 0.84, 0.80, 0.92))
	body.add_child(req)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(spacer)

	var upgrade_button := Button.new()
	upgrade_button.custom_minimum_size = Vector2(0.0, 42.0)
	upgrade_button.text = "Улучшить  %d" % cost if rank < max_rank else "Максимум"
	upgrade_button.disabled = not can_upgrade
	main._apply_button_style(upgrade_button, main.STYLE_PRIMARY_BUTTON if can_upgrade else main.STYLE_SECONDARY_BUTTON)
	upgrade_button.pressed.connect(_on_upgrade_pressed.bind(selected_skill_id))
	body.add_child(upgrade_button)

func _get_bonus_text(skill_database: Node, skill_id: String, rank: int) -> String:
	if rank <= 0:
		return "Текущий бонус: нет"
	var effects: Dictionary = skill_database.call("get_skill_effects_for_rank", skill_id, rank)
	if effects.is_empty():
		return "Текущий бонус: подготовлен как модификатор"
	var parts: Array = []
	for effect_id in effects.keys():
		var value := float(effects[effect_id])
		if abs(value) >= 0.999 and str(effect_id).find("unlock") >= 0:
			parts.append("%s: открыто" % str(effect_id))
		elif abs(value) < 0.009:
			parts.append("%s: %.3f" % [str(effect_id), value])
		else:
			parts.append("%s: %+d%%" % [str(effect_id), roundi(value * 100.0)])
	return "Текущий бонус:\n%s" % "\n".join(parts)

func _get_requirement_text(skill: Dictionary, check: Dictionary, cost: int, rank: int, max_rank: int) -> String:
	if rank >= max_rank:
		return "Навык полностью улучшен."
	var lines: Array = []
	lines.append("Цена следующего ранга: %d" % cost)
	if int(skill.get("required_player_level", 1)) > 1:
		lines.append("Уровень игрока: %d" % int(skill.get("required_player_level", 1)))
	if int(skill.get("required_points_in_tree", 0)) > 0:
		lines.append("Очков в ветке: %d" % int(skill.get("required_points_in_tree", 0)))
	var reason := str(check.get("reason", ""))
	if reason != "":
		lines.append(reason)
	elif PlayerData.skill_points < cost:
		lines.append("Недостаточно очков навыков")
	else:
		lines.append("Можно улучшить")
	return "\n".join(lines)

func _open_tree(tree_id: String) -> void:
	selected_tree_id = tree_id
	selected_skill_id = ""
	refresh()

func _select_skill(skill_id: String) -> void:
	selected_skill_id = skill_id
	refresh()

func _on_back_pressed() -> void:
	selected_tree_id = ""
	selected_skill_id = ""
	refresh()

func _on_upgrade_pressed(skill_id: String) -> void:
	var result := PlayerData.upgrade_skill(skill_id)
	var success := bool(result.get("success", false))
	var message := str(result.get("reason", "Навык улучшен." if success else "Навык недоступен."))
	main._show_toast(message, success)
	if success:
		SaveManager.save_game()
		main._update_ui()
		if profile_ui != null and profile_ui.has_method("refresh"):
			profile_ui.refresh()
	refresh()

func _rank_dots(rank: int, max_rank: int) -> String:
	var dots: Array = []
	for index in max_rank:
		dots.append("●" if index < rank else "○")
	return "".join(dots)

func _get_tree_icon(icon_id: String) -> String:
	match icon_id:
		"float":
			return "~"
		"bottom":
			return "_"
		"spinning":
			return "/"
		"sea":
			return "≈"
		"craft":
			return "#"
		"cooking":
			return "U"
		"survival":
			return "^"
		"master":
			return "*"
		_:
			return "o"

func _apply_row_button_style(button: Button, final_skill: bool = false, selected: bool = false, locked: bool = false) -> void:
	var bg := Color(0.030, 0.055, 0.060, 0.86)
	var border := Color(0.48, 0.76, 0.86, 0.22)
	if locked:
		bg = Color(0.020, 0.030, 0.032, 0.68)
		border = Color(0.42, 0.50, 0.50, 0.18)
	elif final_skill:
		bg = Color(0.18, 0.13, 0.035, 0.88)
		border = Color(1.0, 0.76, 0.22, 0.48)
	elif selected:
		bg = Color(0.035, 0.105, 0.155, 0.92)
		border = Color(0.25, 0.72, 1.0, 0.72)
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", Color(0.90, 0.98, 1.0, 1.0) if not locked else Color(0.55, 0.64, 0.66, 0.95))
	button.add_theme_stylebox_override("normal", _make_style(bg, border, 7, 1))
	button.add_theme_stylebox_override("hover", _make_style(bg.lightened(0.08), border.lightened(0.20), 7, 1))
	button.add_theme_stylebox_override("pressed", _make_style(bg.darkened(0.08), border, 7, 1))
	button.add_theme_stylebox_override("disabled", _make_style(Color(0.02, 0.03, 0.03, 0.55), Color(0.35, 0.45, 0.45, 0.16), 7, 1))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _apply_card_style(card: Panel, accent: bool) -> void:
	card.add_theme_stylebox_override("panel", _make_style(
		Color(0.020, 0.035, 0.038, 0.90) if not accent else Color(0.024, 0.046, 0.052, 0.94),
		Color(0.46, 0.78, 0.88, 0.24) if not accent else Color(0.56, 0.84, 1.0, 0.34),
		8,
		1
	))

func _make_style(bg_color: Color, border_color: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 10.0
	style.content_margin_top = 6.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 6.0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.18)
	style.shadow_size = 2
	return style

func _add_empty_label(parent: Control, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.72, 0.82, 0.80, 0.95))
	parent.add_child(label)

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func _get_skill_database() -> Node:
	if main == null:
		return null
	return main.get_node_or_null("/root/SkillDatabase")
