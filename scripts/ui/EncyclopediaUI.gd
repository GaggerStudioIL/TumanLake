# Fish encyclopedia modal: compact collection grid with per-species details.
extends RefCounted

const FILTER_ALL := "all"
const FILTER_CAUGHT := "caught"
const FILTER_MISSING := "missing"
const FILTER_COMMON := "common"
const FILTER_RARE := "rare"
const FILTER_LEGENDARY := "legendary"

const FILTERS := [
	{"id": FILTER_ALL, "label": "Все"},
	{"id": FILTER_CAUGHT, "label": "Пойманные"},
	{"id": FILTER_MISSING, "label": "Не пойманные"},
	{"id": FILTER_COMMON, "label": "Обычные"},
	{"id": FILTER_RARE, "label": "Редкие"},
	{"id": FILTER_LEGENDARY, "label": "Легендарные"}
]

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
	"cool": "прохладно"
}

var main
var theme
var backdrop: ColorRect
var panel: Panel
var title_label: Label
var close_button: Button
var filter_bar: HBoxContainer
var filter_buttons: Dictionary = {}
var scroll: ScrollContainer
var grid: GridContainer
var stats_label: Label
var empty_label: Label
var details_overlay: ColorRect
var details_panel: Panel
var details_title_label: Label
var details_close_button: Button
var details_scroll: ScrollContainer
var details_content: VBoxContainer
var _active_filter := FILTER_ALL


func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	_ensure_nodes()


func open() -> void:
	if main._is_catch_reward_open():
		return

	main.open_modal("encyclopedia")
	main._active_nav_tab = "fish"
	backdrop.visible = true
	panel.visible = true
	_hide_details()
	refresh()
	if main.has_method("refresh_mobile_scroll_helper"):
		main.refresh_mobile_scroll_helper()
	main._refresh_bottom_nav_styles()


func close(reset_nav: bool = true) -> void:
	if panel == null or backdrop == null:
		return

	if details_overlay != null and details_overlay.visible:
		_hide_details()
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
	if grid == null:
		return

	_layout_collection()
	_refresh_filter_buttons()
	_clear_children(grid)

	var fish_ids: Array = FishDatabase.get_all_fish_ids()
	fish_ids.sort_custom(func(a, b) -> bool:
		var fish_a: Dictionary = FishDatabase.get_fish(str(a))
		var fish_b: Dictionary = FishDatabase.get_fish(str(b))
		return str(fish_a.get("name", a)) < str(fish_b.get("name", b))
	)

	var total_count := 0
	var caught_count := 0
	var trophy_count := int(PlayerData.total_trophies_caught)
	var rare_count := 0
	var visible_count := 0

	for raw_id in fish_ids:
		var fish_id := str(raw_id)
		var fish: Dictionary = FishDatabase.get_fish(fish_id)
		if fish.is_empty():
			continue

		total_count += 1
		var caught := _has_caught_species(fish_id)
		if caught:
			caught_count += 1
		if _is_rare_species(fish):
			rare_count += 1
		if not _passes_filter(fish, caught):
			continue

		_add_fish_tile(fish, caught)
		visible_count += 1

	stats_label.text = "Поймано: %d / %d    Трофеи: %d    Редкие виды: %d" % [
		caught_count,
		total_count,
		trophy_count,
		rare_count
	]
	empty_label.visible = visible_count == 0


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
	panel.offset_top = 30.0
	panel.offset_right = -42.0
	panel.offset_bottom = -30.0
	panel.z_index = main.MENU_PANEL_Z + 34
	theme.apply_panel_style(panel)
	parent.add_child(panel)

	title_label = Label.new()
	title_label.name = "EncyclopediaTitleLabel"
	title_label.text = "Энциклопедия рыб"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title_label.offset_left = 190.0
	title_label.offset_top = 14.0
	title_label.offset_right = -190.0
	title_label.offset_bottom = 52.0
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))
	panel.add_child(title_label)

	close_button = Button.new()
	close_button.name = "EncyclopediaCloseButton"
	close_button.text = "Закрыть"
	close_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close_button.offset_left = -154.0
	close_button.offset_top = 14.0
	close_button.offset_right = -18.0
	close_button.offset_bottom = 54.0
	close_button.add_theme_font_size_override("font_size", 15)
	main._apply_button_style(close_button, main.STYLE_SECONDARY_BUTTON)
	close_button.pressed.connect(close)
	panel.add_child(close_button)

	filter_bar = HBoxContainer.new()
	filter_bar.name = "EncyclopediaFilters"
	filter_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	filter_bar.offset_left = 22.0
	filter_bar.offset_top = 66.0
	filter_bar.offset_right = -22.0
	filter_bar.offset_bottom = 106.0
	filter_bar.add_theme_constant_override("separation", 8)
	panel.add_child(filter_bar)

	for filter in FILTERS:
		var filter_id := str(filter.get("id", FILTER_ALL))
		var button := Button.new()
		button.text = str(filter.get("label", filter_id))
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(112.0, 38.0)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.add_theme_font_size_override("font_size", 13)
		button.pressed.connect(_set_filter.bind(filter_id))
		filter_bar.add_child(button)
		filter_buttons[filter_id] = button

	scroll = ScrollContainer.new()
	scroll.name = "EncyclopediaScroll"
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 22.0
	scroll.offset_top = 116.0
	scroll.offset_right = -22.0
	scroll.offset_bottom = -50.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_child(scroll)

	grid = GridContainer.new()
	grid.name = "EncyclopediaGrid"
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(grid)

	empty_label = Label.new()
	empty_label.name = "EncyclopediaEmptyLabel"
	empty_label.text = "В этом фильтре пока нет рыб."
	empty_label.visible = false
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	empty_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	empty_label.offset_top = 116.0
	empty_label.offset_bottom = -50.0
	empty_label.add_theme_font_size_override("font_size", 18)
	empty_label.add_theme_color_override("font_color", Color(0.78, 0.88, 0.82, 0.92))
	panel.add_child(empty_label)

	stats_label = Label.new()
	stats_label.name = "EncyclopediaStatsLabel"
	stats_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	stats_label.offset_left = 24.0
	stats_label.offset_top = -42.0
	stats_label.offset_right = -24.0
	stats_label.offset_bottom = -12.0
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 13)
	stats_label.add_theme_color_override("font_color", Color(0.74, 0.86, 0.80, 0.94))
	panel.add_child(stats_label)

	_ensure_details_nodes()


func _ensure_details_nodes() -> void:
	details_overlay = ColorRect.new()
	details_overlay.name = "EncyclopediaFishDetails"
	details_overlay.visible = false
	details_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	details_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	details_overlay.color = Color(0.0, 0.0, 0.0, 0.56)
	details_overlay.z_index = 20
	panel.add_child(details_overlay)

	details_panel = Panel.new()
	details_panel.name = "FishDetailsPanel"
	details_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	details_panel.offset_left = 44.0
	details_panel.offset_top = 34.0
	details_panel.offset_right = -44.0
	details_panel.offset_bottom = -34.0
	details_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	theme.apply_panel_style(details_panel)
	details_overlay.add_child(details_panel)

	details_title_label = Label.new()
	details_title_label.name = "FishDetailsTitle"
	details_title_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	details_title_label.offset_left = 130.0
	details_title_label.offset_top = 16.0
	details_title_label.offset_right = -130.0
	details_title_label.offset_bottom = 56.0
	details_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	details_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	details_title_label.add_theme_font_size_override("font_size", 22)
	details_title_label.add_theme_color_override("font_color", Color(0.96, 1.0, 0.92, 1.0))
	details_panel.add_child(details_title_label)

	details_close_button = Button.new()
	details_close_button.name = "FishDetailsCloseButton"
	details_close_button.text = "Назад"
	details_close_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	details_close_button.offset_left = -126.0
	details_close_button.offset_top = 16.0
	details_close_button.offset_right = -18.0
	details_close_button.offset_bottom = 54.0
	details_close_button.add_theme_font_size_override("font_size", 15)
	main._apply_button_style(details_close_button, main.STYLE_SECONDARY_BUTTON)
	details_close_button.pressed.connect(_hide_details)
	details_panel.add_child(details_close_button)

	details_scroll = ScrollContainer.new()
	details_scroll.name = "FishDetailsScroll"
	details_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	details_scroll.offset_left = 22.0
	details_scroll.offset_top = 70.0
	details_scroll.offset_right = -22.0
	details_scroll.offset_bottom = -22.0
	details_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	details_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	details_panel.add_child(details_scroll)

	details_content = VBoxContainer.new()
	details_content.name = "FishDetailsContent"
	details_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details_content.add_theme_constant_override("separation", 12)
	details_scroll.add_child(details_content)


func _layout_collection() -> void:
	var screen_size: Vector2 = main.get_viewport_rect().size
	var columns := 4
	if screen_size.x < 860.0:
		columns = 3
	if screen_size.x < 660.0:
		columns = 2
	grid.columns = columns


func _set_filter(filter_id: String) -> void:
	_active_filter = filter_id
	refresh()


func _refresh_filter_buttons() -> void:
	for filter_id in filter_buttons.keys():
		var button := filter_buttons[filter_id] as Button
		if button == null:
			continue
		var active := str(filter_id) == _active_filter
		if active:
			button.add_theme_stylebox_override("normal", main._make_panel_style(Color(0.070, 0.160, 0.135, 0.96), Color(0.68, 1.0, 0.88, 0.58), 12, 6, Color(0.15, 0.70, 0.62, 0.18)))
			button.add_theme_color_override("font_color", Color(0.96, 1.0, 0.92, 1.0))
		else:
			main._apply_button_style(button, main.STYLE_SECONDARY_BUTTON)


func _add_fish_tile(fish: Dictionary, caught: bool) -> void:
	var fish_id := str(fish.get("id", ""))
	var rarity_type := str(fish.get("rarityType", "common"))
	var rarity_color := _get_rarity_color(rarity_type)

	var tile := Button.new()
	tile.name = "FishTile_%s" % fish_id
	tile.text = ""
	tile.focus_mode = Control.FOCUS_NONE
	tile.mouse_filter = Control.MOUSE_FILTER_STOP
	tile.custom_minimum_size = Vector2(164.0, 176.0)
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.clip_text = true
	_apply_tile_style(tile, rarity_color, caught)
	tile.pressed.connect(_show_fish_details.bind(fish_id))
	grid.add_child(tile)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 10.0
	box.offset_top = 10.0
	box.offset_right = -10.0
	box.offset_bottom = -10.0
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 6)
	tile.add_child(box)

	var image_frame := Panel.new()
	image_frame.custom_minimum_size = Vector2(0.0, 86.0)
	image_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	image_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image_frame.add_theme_stylebox_override("panel", main._make_panel_style(Color(0.012, 0.030, 0.034, 0.56), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.18), 10, 2, Color(0.0, 0.0, 0.0, 0.12)))
	box.add_child(image_frame)

	var image := TextureRect.new()
	image.set_anchors_preset(Control.PRESET_FULL_RECT)
	image.offset_left = 8.0
	image.offset_top = 8.0
	image.offset_right = -8.0
	image.offset_bottom = -8.0
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture = _get_fish_texture(fish_id)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.modulate = Color(1.0, 1.0, 1.0, 1.0) if caught else Color(0.18, 0.22, 0.23, 0.68)
	image_frame.add_child(image)

	var name_label := Label.new()
	name_label.text = str(fish.get("name", fish_id)) if caught else "???"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0) if caught else Color(0.56, 0.64, 0.62, 0.92))
	box.add_child(name_label)

	var badge := Label.new()
	badge.text = _get_rarity_label(rarity_type) if caught else "неизвестно"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.custom_minimum_size = Vector2(0.0, 24.0)
	badge.add_theme_font_size_override("font_size", 11)
	badge.add_theme_color_override("font_color", rarity_color if caught else Color(0.58, 0.66, 0.64, 0.94))
	badge.add_theme_stylebox_override("normal", main._make_panel_style(Color(rarity_color.r * 0.12, rarity_color.g * 0.14, rarity_color.b * 0.14, 0.70), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.34), 9, 2, Color.TRANSPARENT))
	box.add_child(badge)

	var status := Label.new()
	status.text = "поймана" if caught else "не поймана"
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status.custom_minimum_size = Vector2(0.0, 22.0)
	status.add_theme_font_size_override("font_size", 11)
	status.add_theme_color_override("font_color", Color(0.56, 1.0, 0.66, 0.96) if caught else Color(0.62, 0.68, 0.66, 0.78))
	box.add_child(status)


func _apply_tile_style(tile: Button, rarity_color: Color, caught: bool) -> void:
	var alpha := 0.86 if caught else 0.62
	tile.add_theme_stylebox_override("normal", main._make_panel_style(Color(0.028, 0.048, 0.050, alpha), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.24), 12, 4, Color(0.0, 0.0, 0.0, 0.24)))
	tile.add_theme_stylebox_override("hover", main._make_panel_style(Color(0.042, 0.082, 0.078, 0.94), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.52), 12, 8, Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.12)))
	tile.add_theme_stylebox_override("pressed", main._make_panel_style(Color(0.055, 0.120, 0.106, 0.98), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.62), 12, 2, Color.TRANSPARENT))
	tile.add_theme_stylebox_override("focus", tile.get_theme_stylebox("hover"))


func _show_fish_details(fish_id: String) -> void:
	var fish := FishDatabase.get_fish(fish_id)
	if fish.is_empty():
		return

	var caught := _has_caught_species(fish_id)
	details_title_label.text = str(fish.get("name", fish_id)) if caught else "Неизвестная рыба"
	_clear_children(details_content)
	_add_details_header(fish, caught)
	if caught:
		_add_details_stats(fish)
	else:
		_add_unknown_details()
	details_overlay.visible = true


func _add_details_header(fish: Dictionary, caught: bool) -> void:
	var rarity_type := str(fish.get("rarityType", "common"))
	var rarity_color := _get_rarity_color(rarity_type)
	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_constant_override("separation", 18)
	details_content.add_child(header)

	var image_frame := Panel.new()
	image_frame.custom_minimum_size = Vector2(270.0, 158.0)
	image_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	image_frame.add_theme_stylebox_override("panel", main._make_panel_style(Color(0.012, 0.030, 0.034, 0.62), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.24), 12, 4, Color(0.0, 0.0, 0.0, 0.18)))
	header.add_child(image_frame)

	var image := TextureRect.new()
	image.set_anchors_preset(Control.PRESET_FULL_RECT)
	image.offset_left = 12.0
	image.offset_top = 12.0
	image.offset_right = -12.0
	image.offset_bottom = -12.0
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture = _get_fish_texture(str(fish.get("id", "")))
	image.modulate = Color.WHITE if caught else Color(0.16, 0.20, 0.22, 0.72)
	image_frame.add_child(image)

	var summary := VBoxContainer.new()
	summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary.add_theme_constant_override("separation", 8)
	header.add_child(summary)

	_add_badge(summary, _get_rarity_label(rarity_type) if caught else "неизвестно", rarity_color if caught else Color(0.62, 0.68, 0.66, 0.92))
	_add_detail_label(summary, _build_description(fish) if caught else "Поймайте эту рыбу, чтобы открыть её описание и игровые данные.", 14, Color(0.82, 0.92, 0.86, 0.96))

	var record := _get_species_record(str(fish.get("id", "")))
	if caught and not record.is_empty():
		_add_detail_label(summary, "Личный рекорд: %s, %s" % [
			_format_weight(float(record.get("weight", 0.0))),
			str(record.get("waterbody_name", record.get("spot_name", "-")))
		], 13, Color(0.92, 0.98, 0.78, 0.96))


func _add_details_stats(fish: Dictionary) -> void:
	var stat_grid := GridContainer.new()
	stat_grid.columns = 2
	stat_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_grid.add_theme_constant_override("h_separation", 10)
	stat_grid.add_theme_constant_override("v_separation", 10)
	details_content.add_child(stat_grid)

	_add_stat_card(stat_grid, "Диапазон веса", "%s - %s" % [_format_weight(float(fish.get("minWeight", fish.get("min_weight", 0.0)))), _format_weight(float(fish.get("maxWeight", fish.get("max_weight", 0.0))))])
	_add_stat_card(stat_grid, "Зачётный вес", _format_weight(float(fish.get("keeperWeight", fish.get("keeper_weight", 0.0)))))
	_add_stat_card(stat_grid, "Трофейный вес", _format_weight(float(fish.get("trophyWeight", fish.get("trophy_weight", 0.0)))))
	_add_stat_card(stat_grid, "Рекордный вес", _format_weight(float(fish.get("recordWeight", fish.get("record_weight", fish.get("rarity_weight", 0.0))))))
	_add_stat_card(stat_grid, "Глубина", "%.1f - %.1f м, лучше %.1f м" % [
		float(fish.get("min_depth", 0.0)),
		float(fish.get("max_depth", 0.0)),
		float(fish.get("preferred_depth", 0.0))
	])
	_add_stat_card(stat_grid, "Активное время", _format_activity_time(fish))
	_add_stat_card(stat_grid, "Погода", _format_weather_list(fish.get("preferredWeather", [])))
	_add_stat_card(stat_grid, "Наживки", _build_bait_line(fish).replace("Клюёт в игре: ", ""))
	_add_stat_card(stat_grid, "Поведение", _get_behavior_text(fish))
	_add_stat_card(stat_grid, "Места ловли", _get_waterbody_names_for_fish(str(fish.get("id", ""))))


func _add_unknown_details() -> void:
	var card := Panel.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0.0, 108.0)
	card.add_theme_stylebox_override("panel", main._make_panel_style(Color(0.030, 0.042, 0.044, 0.82), Color(0.64, 0.72, 0.68, 0.20), 12, 4, Color(0.0, 0.0, 0.0, 0.18)))
	details_content.add_child(card)

	var label := Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 18.0
	label.offset_top = 14.0
	label.offset_right = -18.0
	label.offset_bottom = -14.0
	label.text = "Данные скрыты. Рыба появится в коллекции после первой поимки."
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(0.74, 0.84, 0.80, 0.92))
	card.add_child(label)


func _add_stat_card(parent: Control, title: String, value: String) -> void:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, 72.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", main._make_panel_style(Color(0.026, 0.046, 0.048, 0.78), Color(0.72, 0.92, 0.84, 0.20), 10, 3, Color(0.0, 0.0, 0.0, 0.16)))
	parent.add_child(card)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 14.0
	box.offset_top = 9.0
	box.offset_right = -14.0
	box.offset_bottom = -9.0
	box.add_theme_constant_override("separation", 3)
	card.add_child(box)

	_add_detail_label(box, title, 12, Color(0.56, 0.72, 0.68, 0.94))
	_add_detail_label(box, value, 14, Color(0.92, 0.98, 0.90, 0.98))


func _add_badge(parent: Control, text: String, color: Color) -> void:
	var badge := Label.new()
	badge.text = text
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.custom_minimum_size = Vector2(190.0, 30.0)
	badge.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	badge.add_theme_font_size_override("font_size", 12)
	badge.add_theme_color_override("font_color", color)
	badge.add_theme_stylebox_override("normal", main._make_panel_style(Color(color.r * 0.12, color.g * 0.14, color.b * 0.14, 0.76), Color(color.r, color.g, color.b, 0.38), 10, 3, Color.TRANSPARENT))
	parent.add_child(badge)


func _add_detail_label(parent: Control, text: String, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)


func _hide_details() -> void:
	if details_overlay != null:
		details_overlay.visible = false


func _passes_filter(fish: Dictionary, caught: bool) -> bool:
	match _active_filter:
		FILTER_CAUGHT:
			return caught
		FILTER_MISSING:
			return not caught
		FILTER_COMMON:
			return str(fish.get("rarityType", "common")) == "common"
		FILTER_RARE:
			return str(fish.get("rarityType", "common")) == "rare"
		FILTER_LEGENDARY:
			return str(fish.get("rarityType", "common")) == "legendary_species"
		_:
			return true


func _has_caught_species(fish_id: String) -> bool:
	if PlayerData.has_method("has_caught_species"):
		return bool(PlayerData.call("has_caught_species", fish_id))
	return PlayerData.personal_records.has(fish_id)


func _get_species_record(fish_id: String) -> Dictionary:
	if PlayerData.personal_records.has(fish_id):
		return PlayerData.personal_records[fish_id]
	if PlayerData.biggest_fish_by_species.has(fish_id):
		return PlayerData.biggest_fish_by_species[fish_id]
	return {}


func _is_rare_species(fish: Dictionary) -> bool:
	var rarity_type := str(fish.get("rarityType", "common"))
	return rarity_type == "rare" or rarity_type == "legendary_species"


func _get_fish_texture(fish_id: String) -> Texture2D:
	if main != null and main.has_method("_get_reward_fish_texture"):
		var texture = main._get_reward_fish_texture(fish_id)
		if texture is Texture2D:
			return texture

	var fish := FishDatabase.get_fish(fish_id)
	var path := str(fish.get("icon_path", ""))
	if not path.is_empty() and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _build_bait_line(fish: Dictionary) -> String:
	var fish_id := str(fish.get("id", ""))
	var bait_names := PlayerData.get_fish_bait_names(fish_id, 8) if PlayerData.has_method("get_fish_bait_names") else ""
	if bait_names.is_empty():
		bait_names = _get_preferred_bait_types(fish)
	return "Клюёт в игре: %s" % (bait_names if not bait_names.is_empty() else "точные наживки не указаны")


func _build_description(fish: Dictionary) -> String:
	var habitat_key := str(fish.get("habitat", "lake"))
	var behavior_key := str(fish.get("behavior_type", fish.get("behavior", "calm")))
	var habitat := str(HABITAT_LABELS.get(habitat_key, habitat_key))
	var behavior := str(BEHAVIOR_LABELS.get(behavior_key, behavior_key))
	var base := str(fish.get("description", "")).strip_edges()
	if base.is_empty():
		base = "Вид хорошо заметен по форме и повадкам."
	return "%s В Tuman Lake чаще выбирает %s; на вываживании ведёт себя как %s рыба." % [
		base,
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


func _get_behavior_text(fish: Dictionary) -> String:
	var behavior_key := str(fish.get("behavior_type", fish.get("behavior", "calm")))
	return str(BEHAVIOR_LABELS.get(behavior_key, behavior_key))


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


func _get_waterbody_names_for_fish(fish_id: String) -> String:
	if WaterbodyDatabase.has_method("get_all_waterbodies"):
		var names: Array = []
		for waterbody in WaterbodyDatabase.get_all_waterbodies():
			if typeof(waterbody) != TYPE_DICTIONARY:
				continue
			var waterbody_id := str(waterbody.get("id", ""))
			var pool: Array = WaterbodyDatabase.get_fish_pool(waterbody_id) if WaterbodyDatabase.has_method("get_fish_pool") else []
			if pool.has(fish_id):
				names.append(str(waterbody.get("name", waterbody_id)))
		if not names.is_empty():
			return ", ".join(names)
	return "данные по водоёмам пока не указаны"


func _get_rarity_label(rarity_type: String) -> String:
	return str(RARITY_LABELS.get(rarity_type, rarity_type))


func _get_rarity_color(rarity_type: String) -> Color:
	match rarity_type:
		"legendary_species":
			return Color(1.0, 0.78, 0.36, 1.0)
		"rare":
			return Color(0.45, 0.86, 1.0, 1.0)
		_:
			return Color(0.72, 0.95, 0.70, 1.0)


func _format_weight(value: float) -> String:
	if value <= 0.0:
		return "-"
	if value < 1.0:
		return "%d г" % int(round(value * 1000.0))
	return "%.2f кг" % value


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
