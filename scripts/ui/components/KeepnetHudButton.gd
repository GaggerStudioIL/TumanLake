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
	var radius: float = edge * 0.5 - 5.0
	var ring_width: float = maxf(edge * 0.052, 4.0)
	var inner_radius: float = maxf(radius - ring_width * 1.55, 2.0)

	draw_circle(center, radius + 1.5, Color(0.0, 0.0, 0.0, 0.22 * alpha))
	draw_circle(center, inner_radius, Color(0.018, 0.040, 0.040, 0.54 * alpha))
	draw_arc(center, radius, 0.0, TAU, 96, Color(0.84, 1.0, 0.92, 0.26 * alpha), ring_width, true)

	var progress_color := Color(0.48, 0.95, 0.66, 0.95 * alpha)
	if target_progress_value >= 0.85:
		progress_color = Color(1.0, 0.74, 0.30, 0.96 * alpha)
	if target_progress_value >= 0.98:
		progress_color = Color(1.0, 0.36, 0.28, 0.98 * alpha)

	if progress_value > 0.001:
		var start_angle := -PI * 0.5
		var end_angle := start_angle + TAU * progress_value
		draw_arc(center, radius, start_angle, end_angle, 96, progress_color, ring_width, true)

	draw_circle(center, edge * 0.34, Color(0.02, 0.07, 0.065, 0.34 * alpha))


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
		count_label.add_theme_font_size_override("font_size", 11)
		count_label.add_theme_color_override("font_color", Color(0.92, 1.0, 0.88, 0.96))
		count_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
		count_label.add_theme_constant_override("shadow_offset_x", 1)
		count_label.add_theme_constant_override("shadow_offset_y", 1)
		add_child(count_label)


func _layout_children() -> void:
	_ensure_children()
	var edge: float = min(size.x, size.y)
	pivot_offset = size * 0.5
	_apply_press_scale()
	var icon_size := Vector2(edge * 0.47, edge * 0.47)
	icon_rect.position = Vector2((size.x - icon_size.x) * 0.5, edge * 0.22)
	icon_rect.size = icon_size
	icon_rect.modulate = Color(0.88, 1.0, 0.86, 0.98 if not disabled else 0.58)

	count_label.position = Vector2(edge * 0.12, edge * 0.62)
	count_label.size = Vector2(edge * 0.76, edge * 0.20)


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
