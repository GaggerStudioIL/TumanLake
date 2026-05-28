extends Panel

const TumanPanelScript := preload("res://scripts/ui/components/TumanPanel.gd")
const TumanButtonScript := preload("res://scripts/ui/components/TumanButton.gd")
const StatusBadgeScript := preload("res://scripts/ui/components/StatusBadge.gd")
const PriceLabelScript := preload("res://scripts/ui/components/PriceLabel.gd")

var display_data: Dictionary = {}
var mode := "inventory"
var _action_callback := Callable()


func setup(data: Dictionary, card_mode: String) -> void:
	display_data = data.duplicate(true)
	mode = card_mode
	if display_data.has("card_size") and display_data.get("card_size") is Vector2:
		custom_minimum_size = display_data.get("card_size")
		size = display_data.get("card_size")
	refresh()


func set_action_button(text: String, callback: Callable) -> void:
	display_data["action_text"] = text
	_action_callback = callback
	refresh()


func refresh() -> void:
	_clear_children()
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_PASS
	var variant := "default"
	if not str(display_data.get("block_reason", "")).is_empty():
		variant = "locked"
	elif str(display_data.get("condition", "")) == "broken":
		variant = "danger"
	TumanPanelScript.apply_style(self, variant, 8, 0)
	_build_card()


func _build_card() -> void:
	var card_size := _card_size(Vector2(360.0, 86.0))
	var icon_rect := Rect2(Vector2(12.0, 12.0), Vector2(58.0, 58.0))
	_add_icon(icon_rect)

	var text_x := 82.0
	var action_width := 92.0 if _action_callback.is_valid() else 0.0
	var text_width := maxf(card_size.x - text_x - action_width - 20.0, 120.0)
	var name_label := _make_label(str(display_data.get("name", "-")), 14, Color(0.94, 1.0, 0.91, 1.0))
	name_label.position = Vector2(text_x, 10.0)
	name_label.size = Vector2(text_width, 22.0)
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	add_child(name_label)

	var meta := "%s" % str(display_data.get("category", mode))
	var quantity := int(display_data.get("quantity", 1))
	if quantity > 1:
		meta += "  x%d" % quantity
	var condition := str(display_data.get("condition", ""))
	if not condition.is_empty():
		meta += "  %s" % condition
	var meta_label := _make_label(meta, 11, Color(0.72, 0.84, 0.78, 0.94))
	meta_label.position = Vector2(text_x, 34.0)
	meta_label.size = Vector2(text_width, 18.0)
	meta_label.clip_text = true
	add_child(meta_label)

	if display_data.has("price"):
		var price_label := _make_label("", 11, Color(1.0, 0.86, 0.48, 1.0))
		price_label.position = Vector2(text_x, 55.0)
		price_label.size = Vector2(text_width, 18.0)
		PriceLabelScript.set_price(price_label, float(display_data.get("price", 0)))
		add_child(price_label)

	var block_reason := str(display_data.get("block_reason", ""))
	if not block_reason.is_empty():
		var badge := StatusBadgeScript.create_badge("Недоступно", "locked")
		badge.position = Vector2(card_size.x - 104.0, 9.0)
		badge.size = Vector2(92.0, 22.0)
		add_child(badge)

	var repair_cost := int(display_data.get("repair_cost", 0))
	if repair_cost > 0:
		var repair_badge := StatusBadgeScript.create_badge("Ремонт", "warning")
		repair_badge.position = Vector2(card_size.x - 104.0, 34.0)
		repair_badge.size = Vector2(92.0, 22.0)
		add_child(repair_badge)

	_add_action_button(Rect2(Vector2(card_size.x - 100.0, card_size.y - 42.0), Vector2(88.0, 32.0)))


func _add_icon(rect: Rect2) -> void:
	var slot := Panel.new()
	slot.position = rect.position
	slot.size = rect.size
	slot.clip_contents = true
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_theme_stylebox_override("panel", TumanPanelScript.make_style(Color(0.012, 0.034, 0.036, 0.72), Color(0.55, 0.80, 0.74, 0.22), 8, 4, 1, Color.TRANSPARENT))
	add_child(slot)

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
		slot.add_child(image)
	else:
		var fallback := _make_label(str(display_data.get("icon_text", "?")), 20, Color(0.72, 0.90, 0.86, 0.88))
		fallback.set_anchors_preset(Control.PRESET_FULL_RECT)
		fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot.add_child(fallback)


func _add_action_button(rect: Rect2) -> void:
	var text := str(display_data.get("action_text", ""))
	if text.is_empty() or not _action_callback.is_valid():
		return
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	TumanButtonScript.apply_button_style(button, "primary" if mode == "shop" else "default")
	button.pressed.connect(_action_callback)
	add_child(button)


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


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
