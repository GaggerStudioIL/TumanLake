extends Button

var icon_rect: TextureRect
var count_label: Label
var progress_value := 0.0
var target_progress_value := 0.0
var fish_count := 0
var capacity := 30
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
	icon_rect.texture = texture


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
	var edge: float = min(size.x, size.y)
	if edge <= 2.0:
		return

	var center := size * 0.5
	var alpha := 0.58 if disabled else 1.0
	var radius: float = edge * 0.5 - 4.0
	var ring_width: float = maxf(edge * 0.045, 3.0)
	var inner_radius: float = maxf(radius - ring_width * 1.70, 2.0)

	draw_circle(center, radius + 2.0, Color(0.0, 0.0, 0.0, 0.22 * alpha))
	draw_circle(center, radius, Color(0.018, 0.034, 0.036, 0.70 * alpha))
	draw_circle(center, inner_radius, Color(0.020, 0.048, 0.046, 0.54 * alpha))
	draw_arc(center, radius, 0.0, TAU, 112, Color(0.70, 0.86, 0.80, 0.28 * alpha), ring_width, true)

	var progress_color := Color(0.48, 0.95, 0.66, 0.95 * alpha)
	if target_progress_value >= 0.85:
		progress_color = Color(1.0, 0.74, 0.30, 0.96 * alpha)
	if target_progress_value >= 0.98:
		progress_color = Color(1.0, 0.36, 0.28, 0.98 * alpha)

	if progress_value > 0.001:
		var start_angle := -PI * 0.5
		var end_angle := start_angle + TAU * progress_value
		draw_arc(center, radius, start_angle, end_angle, 96, progress_color, ring_width, true)

	if _hover_visual_active and not disabled:
		draw_arc(center, radius - ring_width * 1.6, 0.0, TAU, 96, Color(0.66, 1.0, 0.72, 0.16), 2.0, true)

	var count_bg_rect := Rect2(Vector2(edge * 0.18, edge * 0.68), Vector2(edge * 0.64, edge * 0.23))
	draw_style_box(_make_style(Color(0.010, 0.020, 0.022, 0.64 * alpha), Color(0.72, 0.86, 0.78, 0.18 * alpha), 8), count_bg_rect)


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


func _layout_children() -> void:
	_ensure_children()
	var edge: float = min(size.x, size.y)
	pivot_offset = size * 0.5
	_apply_press_scale()
	var icon_size := Vector2(edge * 0.56, edge * 0.56)
	icon_rect.position = Vector2((size.x - icon_size.x) * 0.5, edge * 0.12)
	icon_rect.size = icon_size
	icon_rect.modulate = Color(0.88, 1.0, 0.90, 0.94 if not disabled else 0.54)

	count_label.position = Vector2(edge * 0.18, edge * 0.68)
	count_label.size = Vector2(edge * 0.64, edge * 0.23)
	count_label.add_theme_font_size_override("font_size", int(clampf(edge * 0.145, 10.0, 13.0)))


func _update_count_label() -> void:
	_ensure_children()
	count_label.text = "%d/%d" % [fish_count, capacity]


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
