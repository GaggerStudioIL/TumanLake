extends Control

signal pressed

const LevelRankData := preload("res://scripts/data/LevelRankData.gd")
const EXP_BAR_BACKGROUND_TEXTURE := preload("res://assets/ui/ux/fishing_spot/exp_bar_lvl.png")

var level_icon: TextureRect
var level_label: Label
var xp_label: Label
var hit_button: Button
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 1
var display_ratio: float = 0.0
var target_ratio: float = 0.0
var flash_timer: float = 0.0
var _has_values: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
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
	_update_rank_icon()
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
	var fill_margin_x: float = roundf(rect.size.x * 0.078)
	var fill_top_margin: float = roundf(rect.size.y * 0.08)
	var fill_bottom_margin: float = roundf(rect.size.y * 0.16)
	var fill_bounds := Rect2(
		Vector2(fill_margin_x, fill_top_margin),
		Vector2(rect.size.x - fill_margin_x * 2.0, rect.size.y - fill_top_margin - fill_bottom_margin)
	)
	_draw_progress_fill(fill_bounds, clampf(display_ratio, 0.0, 1.0))

	draw_texture_rect(EXP_BAR_BACKGROUND_TEXTURE, rect, false)

	if flash_alpha > 0.01:
		draw_style_box(_make_style(Color(0.50, 0.90, 0.28, flash_alpha * 0.10), Color(0.84, 1.0, 0.52, flash_alpha * 0.28), 14, 8, Color(0.42, 0.90, 0.30, flash_alpha * 0.16)), rect.grow(-1.0))


func _ensure_children() -> void:
	if level_icon == null:
		level_icon = TextureRect.new()
		level_icon.name = "LevelIcon"
		level_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		level_icon.texture = LevelRankData.get_icon_for_level(level)
		level_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		level_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(level_icon)

	if level_label == null:
		level_label = Label.new()
		level_label.name = "LevelLabel"
		level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		level_label.add_theme_font_size_override("font_size", 13)
		level_label.add_theme_color_override("font_color", Color(0.98, 1.0, 0.94, 1.0))
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
		xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		xp_label.add_theme_font_size_override("font_size", 10)
		xp_label.add_theme_color_override("font_color", Color(0.98, 0.48, 1.0, 0.96))
		xp_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.78))
		xp_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.44))
		xp_label.add_theme_constant_override("outline_size", 1)
		xp_label.add_theme_constant_override("shadow_offset_x", 0)
		xp_label.add_theme_constant_override("shadow_offset_y", 1)
		add_child(xp_label)

	if hit_button == null:
		hit_button = Button.new()
		hit_button.name = "HitButton"
		hit_button.text = ""
		hit_button.flat = true
		hit_button.focus_mode = Control.FOCUS_NONE
		hit_button.mouse_filter = Control.MOUSE_FILTER_STOP
		hit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hit_button.tooltip_text = "Таблица уровней"
		_apply_hit_button_style()
		add_child(hit_button)
		hit_button.pressed.connect(_on_hit_button_pressed)
	else:
		_apply_hit_button_style()
		if hit_button.get_parent() != self:
			add_child(hit_button)
		if not hit_button.pressed.is_connected(_on_hit_button_pressed):
			hit_button.pressed.connect(_on_hit_button_pressed)
	move_child(hit_button, get_child_count() - 1)


func _layout_children() -> void:
	_ensure_children()
	var fill_margin_x: float = roundf(size.x * 0.078)
	var fill_top_margin: float = roundf(size.y * 0.08)
	var fill_bottom_margin: float = roundf(size.y * 0.16)
	var fill_height: float = maxf(size.y - fill_top_margin - fill_bottom_margin, 1.0)
	var icon_size: float = clampf(fill_height - 4.0, 28.0, 36.0)
	var icon_center := Vector2(fill_margin_x + fill_height * 0.5, fill_top_margin + fill_height * 0.5)
	if level_icon != null:
		level_icon.position = icon_center - Vector2(icon_size, icon_size) * 0.5
		level_icon.size = Vector2(icon_size, icon_size)
	var text_x: float = icon_center.x + icon_size * 0.5 + 7.0
	var text_w: float = maxf(size.x - text_x - 8.0, 1.0)
	level_label.position = Vector2(text_x, 6.0)
	level_label.size = Vector2(text_w, 17.0)
	xp_label.position = Vector2(text_x, 23.0)
	xp_label.size = Vector2(text_w, 14.0)
	if hit_button != null:
		hit_button.position = Vector2.ZERO
		hit_button.size = size
		hit_button.custom_minimum_size = size


func _on_hit_button_pressed() -> void:
	pressed.emit()


func _apply_hit_button_style() -> void:
	if hit_button == null:
		return
	var empty_style := StyleBoxEmpty.new()
	for style_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		hit_button.add_theme_stylebox_override(style_name, empty_style)
	hit_button.add_theme_color_override("font_color", Color.TRANSPARENT)
	hit_button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	hit_button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
	hit_button.add_theme_color_override("font_focus_color", Color.TRANSPARENT)
	hit_button.add_theme_color_override("font_disabled_color", Color.TRANSPARENT)


func _update_labels() -> void:
	_ensure_children()
	level_label.text = "%d Lvl" % level
	xp_label.text = "%d exp" % current_xp


func _update_rank_icon() -> void:
	if level_icon == null:
		return
	level_icon.texture = LevelRankData.get_icon_for_level(level)


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


func _draw_progress_fill(fill_bounds: Rect2, ratio: float) -> void:
	var safe_bounds := fill_bounds.grow(-1.0)
	var fill_width: float = clampf(safe_bounds.size.x * ratio, 0.0, safe_bounds.size.x)
	if fill_width <= 0.0 or fill_bounds.size.y <= 0.0:
		return

	var radius: float = minf(safe_bounds.size.y * 0.5, fill_width * 0.5)
	var column_count: int = int(ceilf(fill_width))
	for column_index in range(column_count):
		var local_x: float = float(column_index) + 0.5
		var column_width := minf(1.0, fill_width - float(column_index))
		var top := safe_bounds.position.y
		var bottom := safe_bounds.position.y + safe_bounds.size.y

		if local_x < radius:
			var dx := radius - local_x
			var clip := radius - sqrt(maxf(radius * radius - dx * dx, 0.0))
			top += clip
			bottom -= clip
		elif local_x > fill_width - radius:
			var dx := local_x - (fill_width - radius)
			var clip := radius - sqrt(maxf(radius * radius - dx * dx, 0.0))
			top += clip
			bottom -= clip

		var height := bottom - top
		if height <= 0.0:
			continue

		var color_t: float = clampf(float(column_index) / maxf(safe_bounds.size.x - 1.0, 1.0), 0.0, 1.0)
		color_t = color_t * color_t * (3.0 - 2.0 * color_t)
		var fill_color := Color(0.28, 0.82, 0.28, 0.78).lerp(Color(0.90, 0.16, 1.0, 0.84), color_t)
		draw_rect(Rect2(Vector2(safe_bounds.position.x + float(column_index), top), Vector2(column_width, height)), fill_color, true)
