extends Panel

signal select_requested(waterbody_id: String, spot_id: String)
signal close_requested

var waterbody_id := ""
var spot_id := ""
var waterbody_data: Dictionary = {}
var spot_data: Dictionary = {}
var unlocked := true
var lock_reason := ""

var title_label: Label
var subtitle_label: Label
var details_scroll: ScrollContainer
var details_label: Label
var select_button: Button
var close_button: Button

func setup_panel() -> void:
	_ensure_nodes()
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 50
	add_theme_stylebox_override("panel", _make_panel_style(Color(0.025, 0.045, 0.040, 0.94), Color(0.70, 0.95, 0.72, 0.46), 12, 2))

func show_spot(new_waterbody: Dictionary, new_spot: Dictionary, is_unlocked: bool, new_lock_reason: String = "") -> void:
	_ensure_nodes()
	waterbody_data = new_waterbody.duplicate(true)
	spot_data = new_spot.duplicate(true)
	waterbody_id = str(waterbody_data.get("id", ""))
	spot_id = str(spot_data.get("id", ""))
	unlocked = is_unlocked
	lock_reason = new_lock_reason

	title_label.text = str(spot_data.get("name", spot_id))
	subtitle_label.text = str(waterbody_data.get("name", waterbody_id))
	details_label.text = _build_details_text()
	select_button.disabled = not unlocked
	select_button.text = "Выбрать точку" if unlocked else "Недоступно"
	visible = true

func layout_panel(view_size: Vector2) -> void:
	var panel_width: float = minf(view_size.x * 0.78, 720.0)
	var panel_height: float = minf(view_size.y * 0.78, 410.0)
	size = Vector2(panel_width, panel_height)
	position = (view_size - size) * 0.5

	var padding := 18.0
	title_label.position = Vector2(padding, 14.0)
	title_label.size = Vector2(panel_width - padding * 2.0, 30.0)
	subtitle_label.position = Vector2(padding, 45.0)
	subtitle_label.size = Vector2(panel_width - padding * 2.0, 22.0)
	details_scroll.position = Vector2(padding, 76.0)
	details_scroll.size = Vector2(panel_width - padding * 2.0, panel_height - 142.0)
	details_label.custom_minimum_size = Vector2(details_scroll.size.x - 10.0, 0.0)
	select_button.position = Vector2(panel_width - padding - 176.0, panel_height - 54.0)
	select_button.size = Vector2(176.0, 42.0)
	close_button.position = Vector2(padding, panel_height - 51.0)
	close_button.size = Vector2(132.0, 38.0)

func _ensure_nodes() -> void:
	if title_label != null:
		return

	title_label = Label.new()
	title_label.name = "SpotInfoTitle"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color(0.96, 1.0, 0.88, 1.0))
	add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.name = "SpotInfoSubtitle"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", Color(0.78, 0.95, 0.82, 0.92))
	add_child(subtitle_label)

	details_scroll = ScrollContainer.new()
	details_scroll.name = "SpotInfoDetailsScroll"
	details_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(details_scroll)

	details_label = Label.new()
	details_label.name = "SpotInfoDetails"
	details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_label.add_theme_font_size_override("font_size", 14)
	details_label.add_theme_color_override("font_color", Color(0.88, 0.96, 0.88, 0.96))
	details_scroll.add_child(details_label)

	select_button = Button.new()
	select_button.name = "SpotInfoSelectButton"
	select_button.focus_mode = Control.FOCUS_NONE
	select_button.pressed.connect(_on_select_pressed)
	add_child(select_button)

	close_button = Button.new()
	close_button.name = "SpotInfoCloseButton"
	close_button.text = "Закрыть"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(_on_close_pressed)
	add_child(close_button)

	_apply_button_style(select_button, true)
	_apply_button_style(close_button, false)

func _build_details_text() -> String:
	var fish_names := _get_fish_names(7)
	var features := _array_to_text(spot_data.get("special_features", []))
	var tackle := _array_to_text(spot_data.get("recommended_tackle", []))
	var bait := _array_to_text(spot_data.get("recommended_bait", []))
	var locked_text := ""
	if not unlocked:
		locked_text = "\n\n%s" % (lock_reason if lock_reason != "" else "Эта точка пока закрыта.")

	return "%s\n\nГлубина: %.1f-%.1f м, рабочая %.1f м\nТип места: %s\nРыба: %s\nРекомендуемые поплавки: %s\nНаживка: %s\nОсобенности: %s%s" % [
		str(spot_data.get("description", "")),
		float(spot_data.get("min_depth", spot_data.get("depth", 0.0))),
		float(spot_data.get("max_depth", spot_data.get("depth", 0.0))),
		float(spot_data.get("preferred_depth", spot_data.get("depth", 0.0))),
		str(spot_data.get("spot_type", spot_data.get("type", "-"))),
		fish_names,
		tackle,
		bait,
		features,
		locked_text
	]

func _get_fish_names(limit: int) -> String:
	var names: Array = []
	var fish_pool: Array = spot_data.get("fish_pool", spot_data.get("available_fish", []))
	for fish_id in fish_pool:
		var fish: Dictionary = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue
		names.append(str(fish.get("name", fish_id)))
		if names.size() >= limit:
			break

	return ", ".join(names) if not names.is_empty() else "-"

func _array_to_text(value) -> String:
	if value is Array:
		var parts: Array = []
		for item in value:
			parts.append(str(item))
		return ", ".join(parts) if not parts.is_empty() else "-"
	return str(value) if str(value) != "" else "-"

func _apply_button_style(button: Button, primary: bool) -> void:
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	var fill := Color(0.06, 0.22, 0.12, 0.92) if primary else Color(0.03, 0.06, 0.055, 0.88)
	var border := Color(0.72, 1.0, 0.70, 0.62) if primary else Color(0.62, 0.78, 0.68, 0.42)
	button.add_theme_stylebox_override("normal", _make_panel_style(fill, border, 10, 2))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.08, 0.28, 0.16, 0.96), Color(0.86, 1.0, 0.78, 0.78), 10, 2))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.04, 0.15, 0.09, 0.98), Color(0.62, 0.92, 0.62, 0.80), 10, 2))
	button.add_theme_stylebox_override("disabled", _make_panel_style(Color(0.05, 0.055, 0.052, 0.72), Color(0.48, 0.52, 0.48, 0.36), 10, 1))

func _make_panel_style(fill: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.34)
	style.shadow_size = 8
	return style

func _on_select_pressed() -> void:
	select_requested.emit(waterbody_id, spot_id)

func _on_close_pressed() -> void:
	visible = false
	close_requested.emit()
