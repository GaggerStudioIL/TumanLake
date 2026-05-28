extends Panel

const TumanPanelScript := preload("res://scripts/ui/components/TumanPanel.gd")
const TumanButtonScript := preload("res://scripts/ui/components/TumanButton.gd")
const StatusBadgeScript := preload("res://scripts/ui/components/StatusBadge.gd")
const PriceLabelScript := preload("res://scripts/ui/components/PriceLabel.gd")

var display_data: Dictionary = {}
var mode := "compact"
var _selected := false
var _action_callback := Callable()
var _press_callback := Callable()


func setup(data: Dictionary, card_mode: String) -> void:
	display_data = data.duplicate(true)
	mode = card_mode
	_selected = bool(display_data.get("is_selected", false))
	if display_data.has("card_size") and display_data.get("card_size") is Vector2:
		custom_minimum_size = display_data.get("card_size")
		size = display_data.get("card_size")
	refresh()


func set_selected(value: bool) -> void:
	_selected = value
	display_data["is_selected"] = value
	refresh()


func set_action_button(text: String, callback: Callable) -> void:
	display_data["action_text"] = text
	_action_callback = callback
	refresh()


func set_pressed_callback(callback: Callable) -> void:
	_press_callback = callback
	refresh()


func refresh() -> void:
	_clear_children()
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_PASS
	TumanPanelScript.apply_style(self, _panel_variant(), 10, 0)
	match mode:
		"keepnet":
			_build_keepnet()
		"harbor_sell":
			_build_harbor_sell()
		"encyclopedia_tile":
			_build_encyclopedia_tile()
		"catch_preview":
			_build_catch_preview()
		_:
			_build_compact()


func _build_keepnet() -> void:
	var card_size := _card_size(Vector2(360.0, 150.0))
	_add_pressed_overlay()
	var accent := _accent_color()
	var fish_slot := _make_fish_slot(Rect2(Vector2(12.0, 14.0), Vector2(108.0, 58.0)), accent)
	add_child(fish_slot)

	var badge_type := str(display_data.get("badge_type", ""))
	var badge_text := str(display_data.get("badge_text", ""))
	var badge_visible := not badge_text.is_empty()
	var text_x := 132.0
	var badge_width := 96.0
	var title_right_gap := badge_width + 22.0 if badge_visible else 12.0
	var text_width := maxf(card_size.x - text_x - title_right_gap, 120.0)

	var name_label := _make_label(str(display_data.get("name", "-")), 15, Color(0.94, 1.0, 0.91, 1.0))
	name_label.position = Vector2(text_x, 12.0)
	name_label.size = Vector2(text_width, 24.0)
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	add_child(name_label)

	if badge_visible:
		var badge := StatusBadgeScript.create_badge(badge_text, badge_type)
		badge.position = Vector2(card_size.x - badge_width - 14.0, 14.0)
		badge.size = Vector2(badge_width, 20.0)
		add_child(badge)

	var status := str(display_data.get("status", "undersized"))
	var stats_label := _make_label("%s | %s" % [
		UIFormatters.format_weight_kg(float(display_data.get("weight", 0.0))),
		UIFormatters.format_fish_status(status)
	], 12, Color(0.76, 0.88, 0.80, 0.92))
	stats_label.position = Vector2(text_x, 42.0)
	stats_label.size = Vector2(card_size.x - text_x - 12.0, 18.0)
	stats_label.clip_text = true
	add_child(stats_label)

	var price_label := _make_label("", 12, Color(1.0, 0.86, 0.48, 1.0))
	price_label.position = Vector2(text_x, 62.0)
	price_label.size = Vector2(card_size.x - text_x - 12.0, 20.0)
	PriceLabelScript.set_price(price_label, float(display_data.get("price", 0)))
	add_child(price_label)

	var buyer_label := _make_label(str(display_data.get("buyer_name", "")), 12, Color(0.84, 0.96, 0.88, 0.96))
	buyer_label.position = Vector2(12.0, 102.0)
	buyer_label.size = Vector2(card_size.x - 122.0, 34.0)
	buyer_label.clip_text = true
	buyer_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	buyer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(buyer_label)

	_add_action_button(Rect2(Vector2(card_size.x - 104.0, card_size.y - 46.0), Vector2(92.0, 36.0)))


func _build_harbor_sell() -> void:
	_build_compact()


func _build_encyclopedia_tile() -> void:
	var card_size := _card_size(Vector2(160.0, 190.0))
	var fish_slot := _make_fish_slot(Rect2(Vector2(12.0, 12.0), Vector2(card_size.x - 24.0, 104.0)), _accent_color())
	add_child(fish_slot)
	var name_label := _make_label(str(display_data.get("name", "-")), 13, Color(0.94, 1.0, 0.91, 1.0))
	name_label.position = Vector2(12.0, 124.0)
	name_label.size = Vector2(card_size.x - 24.0, 22.0)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.clip_text = true
	add_child(name_label)
	var rarity_label := _make_label(UIFormatters.format_rarity(str(display_data.get("rarity", "common"))), 11, Color(0.72, 0.84, 0.78, 0.94))
	rarity_label.position = Vector2(12.0, 150.0)
	rarity_label.size = Vector2(card_size.x - 24.0, 20.0)
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(rarity_label)


func _build_catch_preview() -> void:
	var card_size := _card_size(Vector2(240.0, 180.0))
	var fish_slot := _make_fish_slot(Rect2(Vector2(12.0, 12.0), Vector2(card_size.x - 24.0, card_size.y - 64.0)), _accent_color())
	add_child(fish_slot)
	var name_label := _make_label(str(display_data.get("name", "-")), 18, Color(0.96, 1.0, 0.92, 1.0))
	name_label.position = Vector2(12.0, card_size.y - 44.0)
	name_label.size = Vector2(card_size.x - 24.0, 28.0)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.clip_text = true
	add_child(name_label)


func _build_compact() -> void:
	var card_size := _card_size(Vector2(260.0, 72.0))
	var fish_slot := _make_fish_slot(Rect2(Vector2(10.0, 10.0), Vector2(58.0, 52.0)), _accent_color())
	add_child(fish_slot)
	var name_label := _make_label(str(display_data.get("name", "-")), 13, Color(0.94, 1.0, 0.91, 1.0))
	name_label.position = Vector2(78.0, 12.0)
	name_label.size = Vector2(card_size.x - 90.0, 22.0)
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	add_child(name_label)
	var details_label := _make_label(UIFormatters.format_weight_kg(float(display_data.get("weight", 0.0))), 11, Color(0.76, 0.88, 0.80, 0.92))
	details_label.position = Vector2(78.0, 38.0)
	details_label.size = Vector2(card_size.x - 90.0, 18.0)
	add_child(details_label)


func _add_pressed_overlay() -> void:
	if not _press_callback.is_valid():
		return
	var overlay := Button.new()
	overlay.text = ""
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_PASS
	overlay.focus_mode = Control.FOCUS_NONE
	overlay.z_index = 1
	overlay.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	overlay.add_theme_stylebox_override("hover", TumanPanelScript.make_style(Color(0.50, 0.92, 0.82, 0.045), Color(0.54, 0.92, 0.84, 0.16), 10, 0, 0, Color.TRANSPARENT))
	overlay.add_theme_stylebox_override("pressed", TumanPanelScript.make_style(Color(0.50, 0.92, 0.82, 0.085), Color(0.54, 0.92, 0.84, 0.24), 10, 0, 0, Color.TRANSPARENT))
	overlay.pressed.connect(_press_callback)
	add_child(overlay)


func _add_action_button(rect: Rect2) -> void:
	var text := str(display_data.get("action_text", ""))
	if text.is_empty() or not _action_callback.is_valid():
		return
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.z_index = 10
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	TumanButtonScript.apply_button_style(button, "default")
	button.add_theme_font_size_override("font_size", 12)
	button.pressed.connect(_action_callback)
	add_child(button)


func _make_fish_slot(rect: Rect2, accent: Color) -> Panel:
	var slot := Panel.new()
	slot.position = rect.position
	slot.size = rect.size
	slot.clip_contents = true
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.z_index = 2
	slot.add_theme_stylebox_override("panel", TumanPanelScript.make_style(
		Color(accent.r * 0.08, accent.g * 0.10, accent.b * 0.09, 0.58),
		Color(accent.r, accent.g, accent.b, 0.30),
		9,
		4,
		2,
		Color(0.0, 0.0, 0.0, 0.12)
	))

	var texture_value = display_data.get("icon", null)
	if texture_value is Texture2D:
		var image := TextureRect.new()
		image.set_anchors_preset(Control.PRESET_FULL_RECT)
		image.offset_left = 5.0
		image.offset_top = 5.0
		image.offset_right = -5.0
		image.offset_bottom = -5.0
		image.texture = texture_value
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(image)
	else:
		var fallback := _make_label("><>", 22, Color(accent.r, accent.g, accent.b, 0.84))
		fallback.set_anchors_preset(Control.PRESET_FULL_RECT)
		fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot.add_child(fallback)
	return slot


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 2
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _panel_variant() -> String:
	if bool(display_data.get("is_locked", false)):
		return "locked"
	if _selected:
		return "active"
	if str(display_data.get("status", "")) == "trophy" or bool(display_data.get("is_trophy", false)):
		return "gold"
	return "default"


func _accent_color() -> Color:
	var badge_type := str(display_data.get("badge_type", "normal"))
	if badge_type == "rare":
		return Color(0.82, 0.56, 1.0, 1.0)
	if badge_type == "trophy" or str(display_data.get("status", "")) == "trophy":
		return Color(1.0, 0.80, 0.38, 1.0)
	if str(display_data.get("status", "")) == "keeper":
		return Color(0.58, 1.0, 0.64, 1.0)
	return Color(0.72, 0.86, 0.76, 1.0)


func _card_size(fallback: Vector2) -> Vector2:
	if size.x > 1.0 and size.y > 1.0:
		return size
	if custom_minimum_size.x > 1.0 and custom_minimum_size.y > 1.0:
		return custom_minimum_size
	return fallback


func _clear_children() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
