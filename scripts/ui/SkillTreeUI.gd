# Handles the player skill tree modal.
extends RefCounted

var main
var profile_ui
var theme
var backdrop: ColorRect
var panel: Panel
var title_label: Label
var close_button: Button
var points_label: Label
var scroll: ScrollContainer
var content: VBoxContainer

func setup(main_ref, profile_ref = null) -> void:
	main = main_ref
	profile_ui = profile_ref
	theme = main.ui_theme
	_ensure_ui_nodes()

func open() -> void:
	if main._is_catch_reward_open():
		return

	_ensure_ui_nodes()
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
	if content == null:
		return

	for child in content.get_children():
		child.queue_free()

	points_label.text = "Очки навыков: %d" % PlayerData.skill_points

	var skill_database := _get_skill_database()
	if skill_database == null:
		_add_empty_label(content, "База навыков недоступна.")
		return

	var branch_grid := GridContainer.new()
	branch_grid.columns = 2
	branch_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	branch_grid.add_theme_constant_override("h_separation", 14)
	branch_grid.add_theme_constant_override("v_separation", 18)
	content.add_child(branch_grid)

	for branch_id in skill_database.call("get_branch_ids"):
		_add_branch(branch_grid, str(branch_id), skill_database)

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
	theme.apply_modal_backdrop_style(backdrop)
	backdrop.color = Color(0.0, 0.0, 0.0, 0.86)
	parent.add_child(backdrop)

	panel = Panel.new()
	panel.name = "SkillTreePanel"
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 72.0
	panel.offset_top = 42.0
	panel.offset_right = -72.0
	panel.offset_bottom = -42.0
	panel.z_index = main.MENU_PANEL_Z + 42
	theme.apply_panel_style(panel)
	parent.add_child(panel)

	title_label = Label.new()
	title_label.name = "SkillTreeTitleLabel"
	title_label.text = "Навыки"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title_label.offset_left = 180.0
	title_label.offset_top = 16.0
	title_label.offset_right = -180.0
	title_label.offset_bottom = 54.0
	title_label.add_theme_font_size_override("font_size", 25)
	title_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))
	panel.add_child(title_label)

	close_button = Button.new()
	close_button.name = "SkillTreeCloseButton"
	close_button.text = "Закрыть"
	close_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close_button.offset_left = -156.0
	close_button.offset_top = 16.0
	close_button.offset_right = -22.0
	close_button.offset_bottom = 54.0
	main._apply_button_style(close_button, main.STYLE_SECONDARY_BUTTON)
	close_button.pressed.connect(close)
	panel.add_child(close_button)

	points_label = Label.new()
	points_label.name = "SkillTreePointsLabel"
	points_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	points_label.offset_left = 26.0
	points_label.offset_top = 20.0
	points_label.offset_right = 220.0
	points_label.offset_bottom = 50.0
	points_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	points_label.add_theme_font_size_override("font_size", 16)
	points_label.add_theme_color_override("font_color", Color(0.72, 0.95, 0.43, 1.0))
	panel.add_child(points_label)

	scroll = ScrollContainer.new()
	scroll.name = "SkillTreeScroll"
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 24.0
	scroll.offset_top = 70.0
	scroll.offset_right = -24.0
	scroll.offset_bottom = -22.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_child(scroll)

	content = VBoxContainer.new()
	content.name = "SkillTreeContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)

func _add_branch(parent: Control, branch_id: String, skill_database: Node) -> void:
	var branch_box := VBoxContainer.new()
	branch_box.custom_minimum_size = Vector2(330.0, 0.0)
	branch_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	branch_box.add_theme_constant_override("separation", 8)
	parent.add_child(branch_box)

	var branch_title := Label.new()
	branch_title.text = str(skill_database.call("get_branch_title", branch_id))
	branch_title.add_theme_font_size_override("font_size", 18)
	branch_title.add_theme_color_override("font_color", Color(0.92, 1.0, 0.86, 1.0))
	branch_box.add_child(branch_title)

	for skill in skill_database.call("get_branch_skills", branch_id):
		if typeof(skill) == TYPE_DICTIONARY:
			_add_skill_card(branch_box, skill)

func _add_skill_card(parent: Control, skill: Dictionary) -> void:
	var skill_id := str(skill.get("id", ""))
	var learned := PlayerData.has_skill(skill_id)
	var check := PlayerData.can_learn_skill(skill_id)
	var can_learn := bool(check.get("can_learn", false))
	var status_text := "заблокирован"
	var status_color := Color(0.58, 0.64, 0.62, 0.92)

	if learned:
		status_text = "изучен"
		status_color = Color(0.72, 0.95, 0.43, 1.0)
	elif can_learn:
		status_text = "доступен"
		status_color = Color(0.88, 0.98, 0.74, 1.0)

	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, 118.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	theme.apply_card_style(card)
	parent.add_child(card)

	var body := VBoxContainer.new()
	body.set_anchors_preset(Control.PRESET_FULL_RECT)
	body.offset_left = 12.0
	body.offset_top = 9.0
	body.offset_right = -12.0
	body.offset_bottom = -9.0
	body.add_theme_constant_override("separation", 5)
	card.add_child(body)

	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_constant_override("separation", 6)
	body.add_child(header)

	var name_label := Label.new()
	name_label.text = str(skill.get("name", skill_id))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	header.add_child(name_label)

	var status_label := Label.new()
	status_label.text = status_text
	status_label.custom_minimum_size = Vector2(82.0, 22.0)
	status_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 10)
	status_label.add_theme_color_override("font_color", status_color)
	status_label.add_theme_stylebox_override("normal", _make_compact_style(Color(0.035, 0.075, 0.062, 0.58), Color(status_color.r, status_color.g, status_color.b, 0.30), 7))
	header.add_child(status_label)

	var description := Label.new()
	description.text = str(skill.get("description", ""))
	description.custom_minimum_size = Vector2(0.0, 32.0)
	description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 12)
	description.add_theme_color_override("font_color", Color(0.74, 0.86, 0.78, 0.96))
	body.add_child(description)

	var bottom := HBoxContainer.new()
	bottom.custom_minimum_size = Vector2(0.0, 28.0)
	bottom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_theme_constant_override("separation", 6)
	body.add_child(bottom)

	var cost_label := Label.new()
	cost_label.text = "Стоимость: %d" % int(skill.get("cost", 0))
	cost_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_label.add_theme_font_size_override("font_size", 11)
	cost_label.add_theme_color_override("font_color", Color(0.72, 0.82, 0.76, 0.94))
	bottom.add_child(cost_label)

	var learn_button := Button.new()
	learn_button.text = "Изучить"
	learn_button.custom_minimum_size = Vector2(78.0, 26.0)
	learn_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	learn_button.disabled = learned or not can_learn
	learn_button.tooltip_text = str(check.get("reason", "")) if learn_button.disabled and not learned else ""
	_apply_compact_learn_button_style(learn_button, can_learn and not learned)
	learn_button.pressed.connect(_on_learn_pressed.bind(skill_id))
	bottom.add_child(learn_button)

func _apply_compact_learn_button_style(button: Button, active: bool) -> void:
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0) if active else Color(0.55, 0.62, 0.60, 0.95))
	button.add_theme_color_override("font_disabled_color", Color(0.46, 0.52, 0.50, 0.86))
	button.add_theme_stylebox_override("normal", _make_compact_style(
		Color(0.19, 0.42, 0.08, 0.82) if active else Color(0.025, 0.040, 0.040, 0.58),
		Color(0.66, 1.0, 0.32, 0.38) if active else Color(0.76, 0.88, 0.82, 0.16),
		7
	))
	button.add_theme_stylebox_override("hover", _make_compact_style(
		Color(0.23, 0.50, 0.10, 0.88) if active else Color(0.035, 0.055, 0.055, 0.64),
		Color(0.72, 1.0, 0.40, 0.46) if active else Color(0.76, 0.88, 0.82, 0.20),
		7
	))
	button.add_theme_stylebox_override("pressed", _make_compact_style(
		Color(0.14, 0.31, 0.06, 0.90) if active else Color(0.020, 0.032, 0.032, 0.70),
		Color(0.58, 0.92, 0.28, 0.42) if active else Color(0.76, 0.88, 0.82, 0.14),
		7
	))
	button.add_theme_stylebox_override("disabled", _make_compact_style(
		Color(0.018, 0.030, 0.030, 0.46),
		Color(0.76, 0.88, 0.82, 0.12),
		7
	))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _make_compact_style(bg_color: Color, border_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.14)
	style.shadow_size = 1
	style.content_margin_left = 5.0
	style.content_margin_top = 2.0
	style.content_margin_right = 5.0
	style.content_margin_bottom = 2.0
	return style

func _on_learn_pressed(skill_id: String) -> void:
	var result := PlayerData.learn_skill(skill_id)
	var success := bool(result.get("success", false))
	var message := str(result.get("reason", "Навык изучен." if success else "Навык сейчас недоступен."))
	main._show_toast(message, success)

	if success:
		SaveManager.save_game()
		main._update_ui()
		if profile_ui != null and profile_ui.has_method("refresh"):
			profile_ui.refresh()

	refresh()

func _add_empty_label(parent: Control, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(0.0, 36.0)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.68, 0.76, 0.72, 0.90))
	parent.add_child(label)

func _get_skill_database() -> Node:
	if main == null:
		return null

	return main.get_node_or_null("/root/SkillDatabase")
