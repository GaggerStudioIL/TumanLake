# Fish encyclopedia modal: species atlas, in-game baits, depths, and rank weights.
extends RefCounted

const RARITY_LABELS := {
	"common": "обычный вид",
	"rare": "редкий вид",
	"legendary_species": "легендарный вид"
}

const HABITAT_LABELS := {
	"surface": "поверхностная зона",
	"vegetation": "трава и прибрежные заросли",
	"bottom": "донные участки",
	"deep": "глубокие ямы",
	"predator": "охотничьи бровки",
	"lake": "озёрная толща"
}

const BEHAVIOR_LABELS := {
	"calm": "осторожная и ровная",
	"aggressive": "резкая и силовая",
	"erratic": "нервная, с короткими рывками",
	"heavy": "тяжёлая и упорная"
}

const WEATHER_LABELS := {
	"clear": "ясно",
	"warm": "тепло",
	"overcast": "пасмурно",
	"rain": "дождь",
	"night_mist": "ночной туман",
	"wind": "ветер",
	"cool": "прохлада"
}

var main
var theme
var backdrop: ColorRect
var panel: Panel
var title_label: Label
var close_button: Button
var scroll: ScrollContainer
var content: VBoxContainer

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	_ensure_nodes()

func open() -> void:
	if main._is_catch_reward_open():
		return

	main.open_modal("encyclopedia")
	main._active_nav_tab = "encyclopedia"
	backdrop.visible = true
	panel.visible = true
	refresh()
	main._refresh_bottom_nav_styles()

func close(reset_nav: bool = true) -> void:
	if panel == null or backdrop == null:
		return

	panel.visible = false
	backdrop.visible = false
	main.close_modal("encyclopedia")
	if reset_nav:
		main._active_nav_tab = "fish"
		main._refresh_bottom_nav_styles()

func is_open() -> bool:
	return panel != null and panel.visible

func is_any_modal_open() -> bool:
	return is_open()

func refresh() -> void:
	if content == null:
		return

	for child in content.get_children():
		child.queue_free()

	var fish_ids: Array = FishDatabase.get_all_fish_ids()
	fish_ids.sort_custom(func(a, b) -> bool:
		var fish_a: Dictionary = FishDatabase.get_fish(str(a))
		var fish_b: Dictionary = FishDatabase.get_fish(str(b))
		return str(fish_a.get("name", a)) < str(fish_b.get("name", b))
	)

	for fish_id in fish_ids:
		var fish: Dictionary = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue
		_add_fish_card(fish)

func _ensure_nodes() -> void:
	if panel != null:
		return

	var parent: Node = main.get_modal_content_root() if main.has_method("get_modal_content_root") else main

	backdrop = ColorRect.new()
	backdrop.name = "EncyclopediaBackdrop"
	backdrop.visible = false
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.z_index = main.MENU_BACKDROP_Z + 34
	theme.apply_modal_backdrop_style(backdrop)
	backdrop.color = Color(0.0, 0.0, 0.0, 0.84)
	parent.add_child(backdrop)

	panel = Panel.new()
	panel.name = "EncyclopediaPanel"
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 42.0
	panel.offset_top = 34.0
	panel.offset_right = -42.0
	panel.offset_bottom = -34.0
	panel.z_index = main.MENU_PANEL_Z + 34
	theme.apply_panel_style(panel)
	parent.add_child(panel)

	title_label = Label.new()
	title_label.name = "EncyclopediaTitleLabel"
	title_label.text = "Энциклопедия рыб"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title_label.offset_left = 210.0
	title_label.offset_top = 16.0
	title_label.offset_right = -210.0
	title_label.offset_bottom = 56.0
	title_label.add_theme_font_size_override("font_size", 25)
	title_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))
	panel.add_child(title_label)

	close_button = Button.new()
	close_button.name = "EncyclopediaCloseButton"
	close_button.text = "Закрыть"
	close_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close_button.offset_left = -164.0
	close_button.offset_top = 16.0
	close_button.offset_right = -24.0
	close_button.offset_bottom = 56.0
	main._apply_button_style(close_button, main.STYLE_SECONDARY_BUTTON)
	close_button.pressed.connect(close)
	panel.add_child(close_button)

	scroll = ScrollContainer.new()
	scroll.name = "EncyclopediaScroll"
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 24.0
	scroll.offset_top = 74.0
	scroll.offset_right = -24.0
	scroll.offset_bottom = -22.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_child(scroll)

	content = VBoxContainer.new()
	content.name = "EncyclopediaContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)

func _add_fish_card(fish: Dictionary) -> void:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, 270.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	theme.apply_card_style(card)
	content.add_child(card)

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 16.0
	row.offset_top = 14.0
	row.offset_right = -16.0
	row.offset_bottom = -14.0
	row.add_theme_constant_override("separation", 18)
	card.add_child(row)

	var image := TextureRect.new()
	image.custom_minimum_size = Vector2(270.0, 178.0)
	image.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture = main._get_reward_fish_texture(str(fish.get("id", "")))
	row.add_child(image)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 6)
	row.add_child(info)

	var title := Label.new()
	title.text = str(fish.get("name", fish.get("id", "")))
	title.clip_text = true
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.96, 1.0, 0.92, 1.0))
	info.add_child(title)

	var rarity := Label.new()
	rarity.text = _get_rarity_label(str(fish.get("rarityType", "common")))
	rarity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity.custom_minimum_size = Vector2(180.0, 24.0)
	rarity.add_theme_font_size_override("font_size", 12)
	rarity.add_theme_color_override("font_color", _get_rarity_color(str(fish.get("rarityType", "common"))))
	rarity.add_theme_stylebox_override("normal", main._make_panel_style(Color(0.036, 0.066, 0.058, 0.78), Color(0.72, 0.90, 0.70, 0.24), 10, 2))
	info.add_child(rarity)

	_add_info_label(info, _build_weight_line(fish), 13, Color(0.90, 0.96, 0.88, 0.96))
	_add_info_label(info, _build_depth_line(fish), 13, Color(0.72, 0.84, 0.80, 0.96))
	_add_info_label(info, _build_bait_line(fish), 13, Color(0.88, 0.96, 0.78, 0.96))
	_add_info_label(info, _build_activity_line(fish), 12, Color(0.68, 0.78, 0.76, 0.92))
	_add_info_label(info, _build_description(fish), 12, Color(0.78, 0.86, 0.80, 0.96))

func _add_info_label(parent: Control, text: String, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)

func _build_weight_line(fish: Dictionary) -> String:
	return "Зачёт: %s | Трофей: %s | Редкий экз.: %s" % [
		_format_weight(float(fish.get("keeperWeight", fish.get("keeper_weight", 0.0)))),
		_format_weight(float(fish.get("trophyWeight", fish.get("trophy_weight", 0.0)))),
		_format_weight(float(fish.get("recordWeight", fish.get("record_weight", 0.0))))
	]

func _build_depth_line(fish: Dictionary) -> String:
	return "Глубина в игре: %.1f-%.1f м, лучше около %.1f м" % [
		float(fish.get("min_depth", 0.0)),
		float(fish.get("max_depth", 0.0)),
		float(fish.get("preferred_depth", 0.0))
	]

func _build_bait_line(fish: Dictionary) -> String:
	var fish_id := str(fish.get("id", ""))
	var bait_names := PlayerData.get_fish_bait_names(fish_id, 8) if PlayerData.has_method("get_fish_bait_names") else ""
	if bait_names.is_empty():
		bait_names = _get_preferred_bait_types(fish)
	return "Клюёт в игре: %s" % (bait_names if not bait_names.is_empty() else "точные наживки не указаны")

func _build_activity_line(fish: Dictionary) -> String:
	return "Активность: %s | Погода: %s" % [
		_format_activity_time(fish),
		_format_weather_list(fish.get("preferredWeather", []))
	]

func _build_description(fish: Dictionary) -> String:
	var habitat_key := str(fish.get("habitat", "lake"))
	var behavior_key := str(fish.get("behavior_type", fish.get("behavior", "calm")))
	var habitat := str(HABITAT_LABELS.get(habitat_key, habitat_key))
	var behavior := str(BEHAVIOR_LABELS.get(behavior_key, behavior_key))
	var base := str(fish.get("description", "")).strip_edges()
	if base.is_empty():
		base = "Вид хорошо заметен по своей форме и повадкам."
	return "%s В Tuman Lake держится как %s рыба, чаще выбирает %s; на вываживании ведёт себя %s." % [
		base,
		_get_rarity_label(str(fish.get("rarityType", "common"))),
		habitat,
		behavior
	]

func _get_preferred_bait_types(fish: Dictionary) -> String:
	var bait_types: Array = fish.get("preferred_baits", []) if typeof(fish.get("preferred_baits", [])) == TYPE_ARRAY else []
	var names: Array = []
	for bait_type in bait_types:
		match str(bait_type):
			"worm":
				names.append("черви")
			"bread":
				names.append("хлеб")
			"dough":
				names.append("тесто")
			"maggot":
				names.append("личинки")
			_:
				names.append(str(bait_type))
	return ", ".join(names)

func _format_activity_time(fish: Dictionary) -> String:
	var activity: Dictionary = fish.get("activityTime", {}) if typeof(fish.get("activityTime", {})) == TYPE_DICTIONARY else {}
	var start_minutes := int(fish.get("active_time_start", activity.get("start", 300)))
	var end_minutes := int(fish.get("active_time_end", activity.get("end", 1320)))
	return "%s-%s" % [_format_clock(start_minutes), _format_clock(end_minutes)]

func _format_clock(minutes: int) -> String:
	var wrapped: int = ((minutes % 1440) + 1440) % 1440
	return "%02d:%02d" % [int(wrapped / 60), wrapped % 60]

func _format_weather_list(value) -> String:
	var weather_ids: Array = value if typeof(value) == TYPE_ARRAY else []
	if weather_ids.is_empty():
		return "любая"

	var names: Array = []
	for weather_id in weather_ids:
		names.append(str(WEATHER_LABELS.get(str(weather_id), str(weather_id))))
	return ", ".join(names)

func _get_rarity_label(rarity_type: String) -> String:
	return str(RARITY_LABELS.get(rarity_type, rarity_type))

func _get_rarity_color(rarity_type: String) -> Color:
	match rarity_type:
		"legendary_species":
			return Color(1.0, 0.78, 0.36, 1.0)
		"rare":
			return Color(0.58, 0.78, 1.0, 1.0)
		_:
			return Color(0.72, 0.95, 0.70, 1.0)

func _format_weight(value: float) -> String:
	if value <= 0.0:
		return "-"
	if value < 1.0:
		return "%d г" % int(round(value * 1000.0))
	return "%.2f кг" % value
