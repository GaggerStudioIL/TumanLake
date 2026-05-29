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
	var bg_color: Color = Color(0.012, 0.026, 0.026, 0.72 + flash_alpha * 0.08)
	var border_color: Color = Color(0.58, 0.96, 0.82, 0.22 + flash_alpha * 0.28)
	var fill_color: Color = Color(0.38, 0.95, 0.62, 0.82)
	var glow_color: Color = Color(0.64, 1.0, 0.72, 0.18 + flash_alpha * 0.30)

	draw_rect(rect, bg_color, true)
	draw_rect(Rect2(Vector2.ZERO, Vector2(rect.size.x, 1.0)), border_color, true)

	var fill_width: float = floorf(rect.size.x * clampf(display_ratio, 0.0, 1.0))
	if fill_width > 0.0:
		draw_rect(Rect2(Vector2.ZERO, Vector2(fill_width, rect.size.y)), Color(fill_color.r, fill_color.g, fill_color.b, 0.38), true)
		draw_rect(Rect2(Vector2(0.0, rect.size.y - 3.0), Vector2(fill_width, 3.0)), fill_color, true)
		draw_rect(Rect2(Vector2(0.0, 1.0), Vector2(fill_width, maxf(rect.size.y - 2.0, 1.0))), glow_color, true)

	if flash_alpha > 0.01:
		draw_rect(rect, Color(0.78, 1.0, 0.62, flash_alpha * 0.14), true)


func _ensure_children() -> void:
	if level_label == null:
		level_label = Label.new()
		level_label.name = "LevelLabel"
		level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		level_label.add_theme_font_size_override("font_size", 11)
		level_label.add_theme_color_override("font_color", Color(0.92, 1.0, 0.88, 0.98))
		level_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
		level_label.add_theme_constant_override("shadow_offset_x", 1)
		level_label.add_theme_constant_override("shadow_offset_y", 1)
		add_child(level_label)

	if xp_label == null:
		xp_label = Label.new()
		xp_label.name = "XpLabel"
		xp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		xp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		xp_label.add_theme_font_size_override("font_size", 11)
		xp_label.add_theme_color_override("font_color", Color(0.86, 1.0, 0.88, 0.95))
		xp_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
		xp_label.add_theme_constant_override("shadow_offset_x", 1)
		xp_label.add_theme_constant_override("shadow_offset_y", 1)
		add_child(xp_label)


func _layout_children() -> void:
	_ensure_children()
	var padding_x: float = maxf(size.x * 0.018, 12.0)
	level_label.position = Vector2(padding_x, 0.0)
	level_label.size = Vector2(108.0, size.y)
	xp_label.position = Vector2(size.x * 0.5, 0.0)
	xp_label.size = Vector2(size.x * 0.5 - padding_x, size.y)


func _update_labels() -> void:
	_ensure_children()
	level_label.text = "Lv. %d" % level
	xp_label.text = "%d / %d XP" % [current_xp, xp_to_next_level]
