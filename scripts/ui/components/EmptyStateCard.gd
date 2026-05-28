extends PanelContainer

const TumanPanelScript := preload("res://scripts/ui/components/TumanPanel.gd")

var _icon_rect: TextureRect
var _title_label: Label
var _description_label: Label


func _ready() -> void:
	if _title_label == null:
		setup("", "")


func setup(title: String, description: String, icon: Texture2D = null) -> void:
	_clear_children()
	TumanPanelScript.apply_style(self, "locked", 10, 14)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 7)
	add_child(box)

	if icon != null:
		_icon_rect = TextureRect.new()
		_icon_rect.texture = icon
		_icon_rect.custom_minimum_size = Vector2(42.0, 34.0)
		_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		box.add_child(_icon_rect)

	_title_label = Label.new()
	_title_label.text = title
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title_label.add_theme_font_size_override("font_size", 16)
	_title_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	box.add_child(_title_label)

	_description_label = Label.new()
	_description_label.text = description
	_description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description_label.add_theme_font_size_override("font_size", 12)
	_description_label.add_theme_color_override("font_color", Color(0.72, 0.84, 0.78, 0.94))
	box.add_child(_description_label)
	_set_mouse_filter_recursive(self, Control.MOUSE_FILTER_IGNORE)


func _clear_children() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()


func _set_mouse_filter_recursive(node: Node, filter: int) -> void:
	if node is Control:
		(node as Control).mouse_filter = filter
	for child in node.get_children():
		_set_mouse_filter_recursive(child, filter)
