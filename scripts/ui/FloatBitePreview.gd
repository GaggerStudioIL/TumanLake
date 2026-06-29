extends Control

const FLOAT_TEXTURE_PATH := "res://assets/art/fishing/float_marker.png"
const RIPPLE_TEXTURE_PATH := "res://assets/art/fishing/water_ripple.png"
const FLOAT_TEXTURE_REGION := Rect2(520.0, 72.0, 220.0, 1110.0)
const RIPPLE_TEXTURE_REGION := Rect2(104.0, 386.0, 1060.0, 520.0)
const DEFAULT_SIZE := Vector2(176.0, 176.0)

var _panel: Panel
var _window_style: StyleBoxFlat
var _water_style: StyleBoxFlat
var _ripple_texture_rect: TextureRect
var _float_texture_rect: TextureRect
var _move_tween: Tween
var _fade_tween: Tween
var _phase := "hidden"
var _time := 0.0
var _base_float_pos := Vector2.ZERO
var _rings: Array[Dictionary] = []
var _float_texture_path := ""
var _float_texture_uses_custom := false
var _texture_cache: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_build_nodes()
	_layout_nodes()
	reset_float()
	hide_preview()
	set_process(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_nodes()
		if _phase == "idle" or _phase == "hidden":
			reset_float()


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta
	_update_rings(delta)
	if visible and (_phase == "idle" or _phase == "interest"):
		_apply_idle_motion()
	queue_redraw()


func _draw() -> void:
	if not visible:
		return
	var view_size := _get_view_size()
	var water_top := _get_waterline_y()
	var center := view_size * 0.5
	var radius: float = min(view_size.x, view_size.y) * 0.5 - 2.0
	draw_circle(center, radius, Color(0.012, 0.032, 0.036, 0.58))
	_draw_circular_water(center, radius, water_top)
	var border_alpha := 0.42
	var border_color := Color(0.57, 0.91, 0.83, border_alpha)
	if _phase == "take" or _phase == "submerge" or _phase == "aggressive_take" or _phase == "heavy_take" or _phase == "erratic_take" or _phase == "hook_ready":
		var pulse := 0.62 + sin(_time * 7.0) * 0.22
		border_color = Color(0.86, 1.0, 0.70, clampf(pulse, 0.35, 0.86))
		draw_arc(center, radius - 7.0, 0.0, TAU, 96, Color(0.74, 1.0, 0.66, 0.18 + pulse * 0.12), 3.2, true)
	draw_arc(center, radius, 0.0, TAU, 128, border_color, 2.0, true)
	draw_line(Vector2(center.x - radius * 0.82, water_top), Vector2(center.x + radius * 0.82, water_top + sin(_time * 1.0) * 0.9), Color(0.74, 0.98, 0.92, 0.24), 1.4, true)
	for index in range(4):
		var y: float = water_top + 8.0 + float(index) * view_size.y * 0.070 + sin(_time * 0.75 + float(index)) * 1.3
		var color := Color(0.50, 0.82, 0.86, 0.13 - float(index) * 0.018)
		var half_width := sqrt(max(radius * radius - pow(y - center.y, 2.0), 0.0)) * 0.84
		draw_line(Vector2(center.x - half_width, y), Vector2(center.x + half_width, y + sin(_time + float(index)) * 2.0), color, 1.0, true)
	var surface_point := _get_surface_point()
	var pull_depth := view_size.y * 0.22 + sin(_time * 2.0) * 1.4
	draw_line(surface_point + Vector2(0.0, 2.0), surface_point + Vector2(sin(_time * 1.7) * 6.0, pull_depth), Color(0.62, 0.92, 0.88, 0.12), 1.0, true)

	for ring in _rings:
		var age := float(ring.get("age", 0.0))
		var duration: float = max(float(ring.get("duration", 0.6)), 0.1)
		var t := clampf(age / duration, 0.0, 1.0)
		var strength := clampf(float(ring.get("strength", 0.4)), 0.0, 1.0)
		var ring_center := _get_surface_point() + Vector2(float(ring.get("offset_x", 0.0)), float(ring.get("offset_y", 0.0)))
		var ring_radius := lerpf(8.0, min(radius * 0.66, 48.0), t) * (0.65 + strength * 0.55)
		var alpha := (1.0 - t) * (0.14 + strength * 0.18)
		draw_arc(ring_center, ring_radius, 0.0, TAU, 72, Color(0.70, 0.94, 0.95, alpha), 1.6, true)
		draw_arc(ring_center, ring_radius * 0.58, 0.0, TAU, 72, Color(0.86, 1.0, 0.92, alpha * 0.55), 1.0, true)


func _draw_circular_water(center: Vector2, radius: float, water_top: float) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var top_steps := 26
	for index in range(top_steps + 1):
		var t := float(index) / float(top_steps)
		var x := lerpf(center.x - radius * 0.88, center.x + radius * 0.88, t)
		var wave := sin(_time * 1.15 + t * TAU) * 1.8
		points.append(Vector2(x, water_top + wave))

	var arc_steps := 34
	var water_ratio := clampf((water_top - center.y) / radius, -0.95, 0.95)
	var right_angle := asin(water_ratio)
	var left_angle := PI - right_angle
	for index in range(arc_steps + 1):
		var angle := lerpf(right_angle, left_angle, float(index) / float(arc_steps))
		var arc_x := center.x + cos(angle) * radius * 0.98
		var arc_y := center.y + sin(angle) * radius * 0.98
		points.append(Vector2(arc_x, arc_y))

	draw_colored_polygon(points, Color(0.020, 0.145, 0.165, 0.58))


func show_preview() -> void:
	if _panel == null:
		return
	visible = true
	set_process(true)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _fade_tween != null:
		_fade_tween.kill()
	if modulate.a < 0.95:
		_fade_tween = create_tween()
		_fade_tween.tween_property(self, "modulate:a", 1.0, 0.12)


func hide_preview() -> void:
	_kill_move_tween()
	if _fade_tween != null:
		_fade_tween.kill()
	_phase = "hidden"
	visible = false
	set_process(false)
	modulate.a = 0.0
	_rings.clear()
	queue_redraw()


func reset_float() -> void:
	if _float_texture_rect == null:
		return
	_base_float_pos = _get_float_base_position()
	_float_texture_rect.position = _base_float_pos
	_float_texture_rect.rotation = 0.0
	_float_texture_rect.scale = Vector2.ONE
	_float_texture_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if _ripple_texture_rect != null:
		_ripple_texture_rect.modulate = Color(1.0, 1.0, 1.0, 0.32)


func set_idle() -> void:
	if not visible:
		return
	_kill_move_tween()
	_phase = "idle"
	_float_texture_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_ripple_texture_rect.modulate = Color(1.0, 1.0, 1.0, 0.32)
	_add_ring(0.12, 0.70)


func refresh_current_float_texture() -> void:
	if _float_texture_rect == null:
		return

	var desired_path := _get_current_float_texture_path()
	if desired_path == _float_texture_path and _float_texture_rect.texture != null:
		return

	var texture := _load_texture_resource(desired_path)
	_float_texture_uses_custom = desired_path != FLOAT_TEXTURE_PATH and texture != null
	if _float_texture_uses_custom:
		_float_texture_path = desired_path
		_float_texture_rect.texture = texture
	else:
		_float_texture_path = FLOAT_TEXTURE_PATH
		_float_texture_rect.texture = _make_atlas_texture(FLOAT_TEXTURE_PATH, FLOAT_TEXTURE_REGION)

	_layout_nodes()
	reset_float()
	queue_redraw()


func play_wind_nudge(data: Dictionary = {}) -> void:
	show_preview()
	var strength := clampf(float(data.get("strength", 0.24)), 0.08, 0.62)
	var duration := clampf(float(data.get("duration", 0.44)), 0.30, 1.05)
	var direction := -1.0 if randf() < 0.5 else 1.0
	_phase = "wind_nudge"
	_add_ring(strength * 0.45, duration + 0.20, Vector2(direction * 10.0, 2.0))
	_start_move_tween()
	_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos + Vector2(direction * (4.0 + strength * 6.0), -1.0), duration * 0.44).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_move_tween.parallel().tween_property(_float_texture_rect, "rotation", direction * (0.018 + strength * 0.020), duration * 0.44)
	_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos, duration * 0.58).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_move_tween.parallel().tween_property(_float_texture_rect, "rotation", 0.0, duration * 0.58)
	_move_tween.tween_callback(Callable(self, "set_idle"))


func play_interest(data: Dictionary = {}) -> void:
	show_preview()
	_phase = "interest"
	var strength := clampf(float(data.get("strength", 0.12)), 0.05, 0.34)
	_add_ring(strength, clampf(float(data.get("duration", 0.65)), 0.35, 1.4), Vector2(0.0, 2.0))
	_start_move_tween()
	_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos + Vector2(0.8, 2.0 + strength * 5.5), 0.38).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos, 0.52).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_move_tween.tween_callback(Callable(self, "set_idle"))


func play_nibble(data: Dictionary = {}) -> void:
	_play_tap_sequence(data, 2, 1.0, false)


func play_cautious_nibble(data: Dictionary = {}) -> void:
	_play_tap_sequence(data, 3, 0.65, false)


func play_small_fish_taps(data: Dictionary = {}) -> void:
	_play_tap_sequence(data, 5, 0.46, true)


func play_aggressive_take(data: Dictionary = {}) -> void:
	_play_take(data, Vector2(0.0, _get_take_drop_distance(1.0)), 0.20, 0.05, "aggressive_take")


func play_heavy_take(data: Dictionary = {}) -> void:
	_play_take(data, Vector2(0.0, _get_take_drop_distance(0.92)), 0.56, 0.05, "heavy_take")


func play_erratic_take(data: Dictionary = {}) -> void:
	show_preview()
	_phase = "erratic_take"
	var strength := clampf(float(data.get("strength", 0.74)), 0.30, 1.0)
	_add_ring(strength, 0.84, Vector2(6.0, 3.0))
	_start_move_tween()
	_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos + Vector2(6.0, 5.0), 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_move_tween.parallel().tween_property(_float_texture_rect, "rotation", 0.045, 0.16)
	_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos + Vector2(0.0, _get_take_drop_distance(1.0)), 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_move_tween.parallel().tween_property(_float_texture_rect, "modulate:a", 0.05, 0.26)
	_move_tween.parallel().tween_property(_float_texture_rect, "rotation", -0.015, 0.26)


func play_submerge(data: Dictionary = {}) -> void:
	_play_take(data, Vector2(0.0, _get_take_drop_distance(0.96)), 0.40, 0.05, "submerge")


func play_hook_ready(data: Dictionary = {}) -> void:
	show_preview()
	if _phase == "take" or _phase == "submerge" or _phase == "aggressive_take" or _phase == "heavy_take" or _phase == "erratic_take":
		_phase = "hook_ready"
		_add_ring(0.88, 0.95)
		return
	_play_take(data, Vector2(0.0, _get_take_drop_distance(1.0)), 0.18, 0.05, "hook_ready")


func play_lost_interest(data: Dictionary = {}) -> void:
	show_preview()
	_phase = "lost_interest"
	_add_ring(clampf(float(data.get("strength", 0.12)), 0.05, 0.28), 0.55)
	_start_move_tween()
	_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos + Vector2(0.0, -1.4), 0.26).set_trans(Tween.TRANS_SINE)
	_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos, 0.44).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_move_tween.tween_callback(Callable(self, "set_idle"))


func play_bait_stolen(data: Dictionary = {}) -> void:
	show_preview()
	_phase = "bait_stolen"
	var strength := clampf(float(data.get("strength", 0.56)), 0.22, 0.90)
	_add_ring(strength, 0.70)
	_start_move_tween()
	_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos + Vector2(-3.0, 16.0 + strength * 18.0), 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_move_tween.parallel().tween_property(_float_texture_rect, "rotation", -0.035, 0.32)
	_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos + Vector2(1.0, 2.0), 0.36).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_move_tween.parallel().tween_property(_float_texture_rect, "rotation", 0.012, 0.36)
	_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos, 0.30)
	_move_tween.parallel().tween_property(_float_texture_rect, "rotation", 0.0, 0.30)
	_move_tween.tween_callback(Callable(self, "set_idle"))


func _build_nodes() -> void:
	_window_style = _make_window_style()
	_water_style = _make_water_style()

	_panel = Panel.new()
	_panel.name = "PreviewPanel"
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_theme_stylebox_override("panel", _make_panel_style())
	add_child(_panel)

	_ripple_texture_rect = TextureRect.new()
	_ripple_texture_rect.name = "RippleTexture"
	_ripple_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ripple_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_ripple_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	_ripple_texture_rect.texture = _make_atlas_texture(RIPPLE_TEXTURE_PATH, RIPPLE_TEXTURE_REGION)
	_ripple_texture_rect.modulate = Color(1.0, 1.0, 1.0, 0.32)
	_panel.add_child(_ripple_texture_rect)

	_float_texture_rect = TextureRect.new()
	_float_texture_rect.name = "FloatTexture"
	_float_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_float_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_float_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_float_texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_float_texture_rect.texture = _make_atlas_texture(FLOAT_TEXTURE_PATH, FLOAT_TEXTURE_REGION)
	_float_texture_path = FLOAT_TEXTURE_PATH
	_panel.add_child(_float_texture_rect)
	_panel.move_child(_ripple_texture_rect, _panel.get_child_count() - 1)


func _layout_nodes() -> void:
	var view_size := _get_view_size()
	size = view_size
	custom_minimum_size = view_size
	if _panel == null:
		return
	_panel.position = Vector2.ZERO
	_panel.size = view_size
	var waterline := _get_waterline_y()
	_ripple_texture_rect.size = Vector2(view_size.x * 0.50, view_size.y * 0.20)
	_ripple_texture_rect.position = Vector2((view_size.x - _ripple_texture_rect.size.x) * 0.5, waterline - _ripple_texture_rect.size.y * 0.52)
	var float_height: float = clampf(view_size.y * 0.49, 52.0, 68.0)
	if _float_texture_uses_custom:
		var texture_size := _get_float_texture_size()
		var max_float_size := Vector2(view_size.x * 0.42, view_size.y * 0.58)
		var texture_scale: float = minf(
			max_float_size.x / maxf(texture_size.x, 1.0),
			max_float_size.y / maxf(texture_size.y, 1.0)
		)
		_float_texture_rect.size = texture_size * maxf(texture_scale, 0.01)
	else:
		_float_texture_rect.size = Vector2(float_height * 0.24, float_height)
	_float_texture_rect.pivot_offset = _float_texture_rect.size * 0.5
	_base_float_pos = _get_float_base_position()


func _get_view_size() -> Vector2:
	if size.x > 8.0 and size.y > 8.0:
		return size
	if custom_minimum_size.x > 8.0 and custom_minimum_size.y > 8.0:
		return custom_minimum_size
	return DEFAULT_SIZE


func _get_float_base_position() -> Vector2:
	var view_size := _get_view_size()
	var float_size: Vector2 = _float_texture_rect.size if _float_texture_rect != null else Vector2(30.0, 118.0)
	return Vector2((view_size.x - float_size.x) * 0.5, _get_waterline_y() - float_size.y * 0.68)


func _get_take_drop_distance(multiplier: float = 1.0) -> float:
	var float_height: float = _float_texture_rect.size.y if _float_texture_rect != null else _get_view_size().y * 0.52
	return max(float_height * 0.86 * multiplier, _get_view_size().y * 0.36)


func _get_float_center() -> Vector2:
	if _float_texture_rect == null:
		return _get_view_size() * 0.5
	return _float_texture_rect.position + _float_texture_rect.size * 0.5


func _get_float_texture_size() -> Vector2:
	if _float_texture_rect != null and _float_texture_rect.texture != null:
		return _float_texture_rect.texture.get_size()
	return FLOAT_TEXTURE_REGION.size


func _get_waterline_y() -> float:
	return _get_view_size().y * 0.58


func _get_water_rect() -> Rect2:
	var view_size := _get_view_size()
	var waterline: float = _get_waterline_y()
	return Rect2(
		Vector2(6.0, waterline),
		Vector2(max(view_size.x - 12.0, 1.0), max(view_size.y - waterline - 6.0, 1.0))
	)


func _get_surface_point() -> Vector2:
	return Vector2(_get_view_size().x * 0.5, _get_waterline_y())


func _apply_idle_motion() -> void:
	if _float_texture_rect == null:
		return
	var bob := Vector2(sin(_time * 1.18) * 0.9, sin(_time * 1.72) * 1.4)
	if _phase == "interest":
		bob *= 0.55
	_float_texture_rect.position = _base_float_pos + bob
	_float_texture_rect.rotation = sin(_time * 0.96) * 0.014


func _play_tap_sequence(data: Dictionary, tap_count: int, scale: float, rapid: bool) -> void:
	show_preview()
	_phase = "nibble"
	var strength := clampf(float(data.get("strength", 0.32)) * scale, 0.08, 0.72)
	var duration := clampf(float(data.get("duration", 0.34)), 0.24, 0.70)
	_add_ring(strength, 0.58)
	_start_move_tween()
	for index in range(max(tap_count, 1)):
		var side := -1.0 if index % 2 == 0 else 1.0
		var down := 2.0 + strength * (7.0 if rapid else 10.0)
		var step_duration: float = max(duration * (0.42 if rapid else 0.52), 0.11)
		_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos + Vector2(side * strength * 2.4, down), step_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_move_tween.parallel().tween_property(_float_texture_rect, "rotation", side * strength * 0.018, step_duration)
		_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos + Vector2(0.0, -0.4), step_duration * 0.92).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_move_tween.parallel().tween_property(_float_texture_rect, "rotation", 0.0, step_duration)
	_move_tween.tween_callback(Callable(self, "set_idle"))


func _play_take(data: Dictionary, offset: Vector2, down_time: float, fade_alpha: float, phase_name: String) -> void:
	show_preview()
	_phase = phase_name
	var strength := clampf(float(data.get("strength", 0.72)), 0.28, 1.0)
	var speed_multiplier := clampf(float(data.get("submerge_speed", 1.0)), 0.65, 1.35)
	var duration := clampf(float(data.get("duration", down_time)) / speed_multiplier, 0.16, 0.72)
	_add_ring(strength, 0.82)
	_start_move_tween()
	_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos + Vector2(0.0, 4.0 + strength * 3.5), duration * 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_move_tween.parallel().tween_property(_float_texture_rect, "rotation", 0.0, duration * 0.24)
	_move_tween.tween_property(_float_texture_rect, "position", _base_float_pos + offset * (0.82 + strength * 0.18), duration * 0.76).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_move_tween.parallel().tween_property(_float_texture_rect, "modulate:a", fade_alpha, duration)
	if _ripple_texture_rect != null:
		_move_tween.parallel().tween_property(_ripple_texture_rect, "modulate:a", 0.16, duration)


func _start_move_tween() -> void:
	_kill_move_tween()
	reset_float()
	_move_tween = create_tween()


func _kill_move_tween() -> void:
	if _move_tween != null:
		_move_tween.kill()
		_move_tween = null


func _add_ring(strength: float, duration: float, offset: Vector2 = Vector2.ZERO) -> void:
	_rings.append({
		"age": 0.0,
		"duration": duration,
		"strength": strength,
		"offset_x": offset.x,
		"offset_y": offset.y
	})
	if _rings.size() > 7:
		_rings.pop_front()


func _update_rings(delta: float) -> void:
	for index in range(_rings.size() - 1, -1, -1):
		var ring: Dictionary = _rings[index]
		ring["age"] = float(ring.get("age", 0.0)) + delta
		_rings[index] = ring
		if float(ring.get("age", 0.0)) >= float(ring.get("duration", 0.5)):
			_rings.remove_at(index)


func _make_atlas_texture(path: String, region: Rect2) -> Texture2D:
	var texture := _load_texture_resource(path)
	if texture is Texture2D:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = region
		return atlas
	return null


func _get_current_float_texture_path() -> String:
	var float_data := _get_current_float_data()
	var path := str(float_data.get("image_path", ""))
	if path != "" and (ResourceLoader.exists(path) or FileAccess.file_exists(path)):
		return path
	return FLOAT_TEXTURE_PATH


func _get_current_float_data() -> Dictionary:
	if PlayerData != null and PlayerData.has_method("get_current_float_data"):
		var data = PlayerData.call("get_current_float_data")
		if data is Dictionary:
			return (data as Dictionary).duplicate(true)
	return {}


func _load_texture_resource(path: String) -> Texture2D:
	if path == "":
		return null
	if _texture_cache.has(path):
		return _texture_cache[path]
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		_texture_cache[path] = null
		return null

	if ResourceLoader.exists(path):
		var resource := load(path)
		if resource is Texture2D:
			_texture_cache[path] = resource
			return resource

	var image := Image.load_from_file(path)
	if image != null and not image.is_empty():
		var texture := ImageTexture.create_from_image(image)
		_texture_cache[path] = texture
		return texture

	_texture_cache[path] = null
	return null


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = Color.TRANSPARENT
	style.set_border_width_all(0)
	style.set_corner_radius_all(0)
	style.shadow_size = 0
	return style


func _make_window_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.012, 0.032, 0.036, 0.48)
	style.border_color = Color(0.57, 0.91, 0.83, 0.30)
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.shadow_size = 0
	return style


func _make_water_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.020, 0.140, 0.160, 0.54)
	style.border_color = Color.TRANSPARENT
	style.set_border_width_all(0)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.shadow_size = 0
	return style
