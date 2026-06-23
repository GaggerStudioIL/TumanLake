extends Button

const SADOK_EMPTY_TEXTURE := preload("res://assets/ui/ux/fishing_spot/sadok_0.png")
const SADOK_HALF_TEXTURE := preload("res://assets/ui/ux/fishing_spot/sadok_50.png")
const SADOK_FULL_TEXTURE := preload("res://assets/ui/ux/fishing_spot/sadok_full.png")

var icon_rect: TextureRect
var count_label: Label
var progress_value := 0.0
var target_progress_value := 0.0
var fish_count := 0
var capacity := 30
var fallback_icon_texture: Texture2D
var _press_visual_active := false
var _hover_visual_active := false


func _ready() -> void:
	text = ""
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_empty_button_style()
	_ensure_children()
	_layout_children()
	button_down.connect(_set_press_visual.bind(true))
	button_up.connect(_set_press_visual.bind(false))
	mouse_entered.connect(_set_hover_visual.bind(true))
	mouse_exited.connect(_clear_pointer_visual)


func set_icon_texture(texture: Texture2D) -> void:
	_ensure_children()
	fallback_icon_texture = texture
	_refresh_icon_state()


func set_counts(count: int, max_count: int, animate := true) -> void:
	fish_count = max(count, 0)
	capacity = max(max_count, 1)
	target_progress_value = clamp(float(fish_count) / float(capacity), 0.0, 1.0)
	if not animate:
		progress_value = target_progress_value
		set_process(false)
	else:
		set_process(true)
	_update_count_label()
	_refresh_icon_state()
	_layout_children()
	queue_redraw()


func _process(delta: float) -> void:
	progress_value = lerp(progress_value, target_progress_value, clamp(delta * 8.0, 0.0, 1.0))
	if abs(progress_value - target_progress_value) < 0.002:
		progress_value = target_progress_value
		set_process(false)
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_children()
		queue_redraw()


func _draw() -> void:
	pass


func _ensure_children() -> void:
	if icon_rect == null:
		icon_rect = TextureRect.new()
		icon_rect.name = "KeepnetIcon"
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(icon_rect)

	if count_label == null:
		count_label = Label.new()
		count_label.name = "KeepnetCountLabel"
		count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		count_label.add_theme_font_size_override("font_size", 12)
		count_label.add_theme_color_override("font_color", Color(0.94, 0.98, 0.92, 0.98))
		count_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
		count_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.48))
		count_label.add_theme_constant_override("outline_size", 1)
		count_label.add_theme_constant_override("shadow_offset_x", 0)
		count_label.add_theme_constant_override("shadow_offset_y", 1)
		add_child(count_label)
	count_label.visible = false


func _layout_children() -> void:
	_ensure_children()
	pivot_offset = size * 0.5
	_apply_press_scale()
	icon_rect.position = Vector2.ZERO
	icon_rect.size = size
	icon_rect.modulate = Color(1.0, 1.0, 1.0, 0.98 if not disabled else 0.54)

	count_label.visible = false


func _update_count_label() -> void:
	_ensure_children()
	count_label.text = "%d/%d" % [fish_count, capacity]
	count_label.visible = false


func _refresh_icon_state() -> void:
	_ensure_children()
	if target_progress_value >= 0.80:
		icon_rect.texture = SADOK_FULL_TEXTURE
	elif target_progress_value <= 0.35:
		icon_rect.texture = SADOK_EMPTY_TEXTURE
	else:
		icon_rect.texture = SADOK_HALF_TEXTURE
	if icon_rect.texture == null:
		icon_rect.texture = fallback_icon_texture


func _set_press_visual(value: bool) -> void:
	_press_visual_active = value
	_apply_press_scale()


func _set_hover_visual(value: bool) -> void:
	_hover_visual_active = value
	_apply_press_scale()


func _clear_pointer_visual() -> void:
	_hover_visual_active = false
	_press_visual_active = false
	_apply_press_scale()


func _apply_press_scale() -> void:
	var target_scale := 1.0
	if _press_visual_active and not disabled:
		target_scale = 1.08
	elif _hover_visual_active and not disabled:
		target_scale = 1.04
	scale = Vector2.ONE * target_scale


func _apply_empty_button_style() -> void:
	var empty_style := StyleBoxEmpty.new()
	add_theme_stylebox_override("normal", empty_style)
	add_theme_stylebox_override("hover", empty_style)
	add_theme_stylebox_override("pressed", empty_style)
	add_theme_stylebox_override("disabled", empty_style)
	add_theme_stylebox_override("focus", empty_style)
	add_theme_color_override("font_color", Color.TRANSPARENT)
	add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
	add_theme_color_override("font_disabled_color", Color.TRANSPARENT)
	add_theme_color_override("font_focus_color", Color.TRANSPARENT)
	add_theme_constant_override("h_separation", 0)


func _make_style(bg_color: Color, border_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_size = 0
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	return style
