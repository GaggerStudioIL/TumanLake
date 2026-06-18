extends Control

var level_label: Label
var xp_label: Label
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 1
var display_ratio: float = 0.0
var target_ratio: float = 0.0
var flash_timer: float = 0.0
var _has_values: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ensure_children()
	_layout_children()


func set_progress(new_level: int, new_current_xp: int, new_xp_to_next_level: int, animate := true) -> void:
	var previous_level: int = level
	level = max(new_level, 1)
	current_xp = max(new_current_xp, 0)
	xp_to_next_level = max(new_xp_to_next_level, 1)
	target_ratio = clampf(float(current_xp) / float(xp_to_next_level), 0.0, 1.0)

	if _has_values and level > previous_level:
		flash_timer = 1.35
		display_ratio = 0.0
		set_process(true)
	elif not _has_values or not animate:
		display_ratio = target_ratio
		set_process(false)
	else:
		set_process(true)

	_has_values = true
	_update_labels()
	queue_redraw()


func _process(delta: float) -> void:
	display_ratio = lerpf(display_ratio, target_ratio, clampf(delta * 7.5, 0.0, 1.0))
	if flash_timer > 0.0:
		flash_timer = maxf(flash_timer - delta, 0.0)

	if abs(display_ratio - target_ratio) < 0.002 and flash_timer <= 0.0:
		display_ratio = target_ratio
		set_process(false)

	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_children()
		queue_redraw()


func _draw() -> void:
	var rect: Rect2 = Rect2(Vector2.ZERO, size)
	if rect.size.x <= 2.0 or rect.size.y <= 2.0:
		return

	var flash_alpha: float = clampf(flash_timer / 1.35, 0.0, 1.0)
	var card_style := _make_style(
		Color(0.016, 0.032, 0.034, 0.70),
		Color(0.70, 0.86, 0.80, 0.24 + flash_alpha * 0.20),
		14,
		4,
		Color(0.0, 0.0, 0.0, 0.24)
	)
	draw_style_box(card_style, rect.grow(-1.0))

	var bar_rect := _get_bar_rect()
	var track_style := _make_style(Color(0.030, 0.052, 0.052, 0.86), Color(0.72, 0.86, 0.78, 0.18), 6, 0, Color.TRANSPARENT)
	draw_style_box(track_style, bar_rect)

	var fill_width: float = floorf(bar_rect.size.x * clampf(display_ratio, 0.0, 1.0))
	if fill_width > 0.0:
		var fill_rect := Rect2(bar_rect.position, Vector2(fill_width, bar_rect.size.y))
		var fill_style := _make_style(Color(0.42, 0.78, 0.30, 0.92), Color(0.78, 1.0, 0.58, 0.24), 6, 0, Color.TRANSPARENT)
		draw_style_box(fill_style, fill_rect)
		draw_rect(Rect2(fill_rect.position + Vector2(2.0, 1.0), Vector2(maxf(fill_rect.size.x - 4.0, 0.0), 1.0)), Color(0.92, 1.0, 0.74, 0.26 + flash_alpha * 0.20), true)

	if flash_alpha > 0.01:
		draw_style_box(_make_style(Color(0.50, 0.90, 0.28, flash_alpha * 0.10), Color(0.84, 1.0, 0.52, flash_alpha * 0.28), 14, 8, Color(0.42, 0.90, 0.30, flash_alpha * 0.16)), rect.grow(-1.0))


func _ensure_children() -> void:
	if level_label == null:
		level_label = Label.new()
		level_label.name = "LevelLabel"
		level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		level_label.add_theme_font_size_override("font_size", 13)
		level_label.add_theme_color_override("font_color", Color(0.94, 0.98, 0.92, 0.98))
		level_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.78))
		level_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.44))
		level_label.add_theme_constant_override("outline_size", 1)
		level_label.add_theme_constant_override("shadow_offset_x", 0)
		level_label.add_theme_constant_override("shadow_offset_y", 1)
		add_child(level_label)

	if xp_label == null:
		xp_label = Label.new()
		xp_label.name = "XpLabel"
		xp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		xp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		xp_label.add_theme_font_size_override("font_size", 12)
		xp_label.add_theme_color_override("font_color", Color(0.82, 0.92, 0.86, 0.96))
		xp_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.78))
		xp_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.44))
		xp_label.add_theme_constant_override("outline_size", 1)
		xp_label.add_theme_constant_override("shadow_offset_x", 0)
		xp_label.add_theme_constant_override("shadow_offset_y", 1)
		add_child(xp_label)


func _layout_children() -> void:
	_ensure_children()
	var padding_x: float = 12.0
	var label_height: float = maxf(size.y - 8.0, 20.0)
	var level_width: float = 58.0
	var xp_width: float = 112.0
	level_label.position = Vector2(padding_x, 4.0)
	level_label.size = Vector2(level_width, label_height)
	xp_label.position = Vector2(maxf(size.x - padding_x - xp_width, padding_x + level_width), 4.0)
	xp_label.size = Vector2(xp_width, label_height)


func _update_labels() -> void:
	_ensure_children()
	level_label.text = "Lv. %d" % level
	xp_label.text = "%d / %d XP" % [current_xp, xp_to_next_level]


func _get_bar_rect() -> Rect2:
	var padding_x: float = 12.0
	var level_width: float = 58.0
	var xp_width: float = 112.0
	var gap: float = 10.0
	var bar_height: float = clampf(size.y * 0.28, 8.0, 12.0)
	var bar_x: float = padding_x + level_width + gap
	var bar_right: float = maxf(size.x - padding_x - xp_width - gap, bar_x + 1.0)
	var bar_y: float = (size.y - bar_height) * 0.5
	return Rect2(Vector2(bar_x, bar_y), Vector2(maxf(bar_right - bar_x, 1.0), bar_height))


func _make_style(
	bg_color: Color,
	border_color: Color,
	radius: int,
	shadow_size: int,
	shadow_color: Color
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_size = shadow_size
	style.shadow_color = shadow_color
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	return style
