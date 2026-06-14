extends Control

const TRACK_TEXTURE: Texture2D = preload("res://assets/ui/sprites/hud/progress_track.png")
const FILL_TEXTURE: Texture2D = preload("res://assets/ui/sprites/hud/progress_fill_green.png")

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
	var bar_height: float = clampf(rect.size.y * 0.22, 6.0, 8.0)
	var bar_y: float = rect.size.y - bar_height - 1.0
	var bar_rect := Rect2(Vector2.ZERO, Vector2(rect.size.x, bar_height))
	bar_rect.position.y = bar_y

	draw_texture_rect(TRACK_TEXTURE, bar_rect, false, Color(0.78, 1.0, 0.86, 0.86 + flash_alpha * 0.10))
	draw_rect(Rect2(Vector2(0.0, bar_y - 1.0), Vector2(rect.size.x, 1.0)), Color(0.48, 0.90, 0.68, 0.16 + flash_alpha * 0.18), true)

	var fill_width: float = floorf(rect.size.x * clampf(display_ratio, 0.0, 1.0))
	if fill_width > 0.0:
		var fill_rect := Rect2(bar_rect.position, Vector2(fill_width, bar_rect.size.y))
		draw_texture_rect(FILL_TEXTURE, fill_rect, false, Color(0.64, 1.0, 0.72, 0.90))
		draw_rect(Rect2(Vector2(0.0, bar_y), Vector2(fill_width, 1.0)), Color(0.88, 1.0, 0.78, 0.24 + flash_alpha * 0.22), true)

	if flash_alpha > 0.01:
		draw_texture_rect(TRACK_TEXTURE, bar_rect.grow(1.0), false, Color(0.78, 1.0, 0.62, flash_alpha * 0.16))


func _ensure_children() -> void:
	if level_label == null:
		level_label = Label.new()
		level_label.name = "LevelLabel"
		level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		level_label.add_theme_font_size_override("font_size", 12)
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
		xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		xp_label.add_theme_font_size_override("font_size", 12)
		xp_label.add_theme_color_override("font_color", Color(0.86, 1.0, 0.88, 0.95))
		xp_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
		xp_label.add_theme_constant_override("shadow_offset_x", 1)
		xp_label.add_theme_constant_override("shadow_offset_y", 1)
		add_child(xp_label)


func _layout_children() -> void:
	_ensure_children()
	var label_height: float = maxf(size.y - 10.0, 16.0)
	var label_width: float = minf(size.x - 24.0, 286.0)
	var level_width: float = 82.0
	var gap: float = 8.0
	var start_x: float = maxf((size.x - label_width) * 0.5, 12.0)
	level_label.position = Vector2(start_x, 0.0)
	level_label.size = Vector2(level_width, label_height)
	xp_label.position = Vector2(start_x + level_width + gap, 0.0)
	xp_label.size = Vector2(maxf(label_width - level_width - gap, 120.0), label_height)


func _update_labels() -> void:
	_ensure_children()
	level_label.text = "Lv. %d" % level
	xp_label.text = "%d / %d XP" % [current_xp, xp_to_next_level]
