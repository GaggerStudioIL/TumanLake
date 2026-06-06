extends Control

const DEFAULT_PROFILE := "calm_pier"
const DISABLED_PROFILE := "disabled"
const FALLBACK_MASK := "default_lake"
const MAX_VISIBLE_STRENGTH := 0.58
const MAX_MOTION_SPEED := 1.65
const MAX_DISTORTION_STRENGTH := 0.16
const MAX_SURFACE_ALPHA := 0.12
const MAX_HIGHLIGHT_ALPHA := 0.065
const DEBUG_WATER_ALPHA_MULT := 2.5
const DEBUG_WATER_LINE_COUNT_MULT := 1.5
const DEBUG_OUTLINE_ALPHA := 0.34
const DEBUG_WAVE_BASE_ALPHA := 0.12
const MAX_NORMAL_WAVE_ALPHA := 0.056
const MAX_NORMAL_RIPPLE_ALPHA := 0.036
const MAX_NORMAL_HIGHLIGHT_ALPHA := 0.030

const PROFILES := {
	"calm_pier": {
		"visible_strength": 0.34,
		"motion_speed": 0.70,
		"distortion_strength": 0.055,
		"surface_alpha": 0.048,
		"highlight_alpha": 0.018,
		"color_tint": Color(0.70, 0.92, 0.86, 1.0),
		"patch_count": 18,
		"wavelet_count": 6,
		"ripple_count": 2,
		"flicker_strength": 0.24
	},
	"open_water": {
		"visible_strength": 0.42,
		"motion_speed": 0.96,
		"distortion_strength": 0.085,
		"surface_alpha": 0.056,
		"highlight_alpha": 0.026,
		"color_tint": Color(0.72, 0.94, 0.92, 1.0),
		"patch_count": 26,
		"wavelet_count": 9,
		"ripple_count": 3,
		"flicker_strength": 0.34
	},
	"reeds": {
		"visible_strength": 0.35,
		"motion_speed": 0.78,
		"distortion_strength": 0.070,
		"surface_alpha": 0.048,
		"highlight_alpha": 0.018,
		"color_tint": Color(0.72, 0.90, 0.76, 1.0),
		"patch_count": 22,
		"wavelet_count": 5,
		"ripple_count": 2,
		"flicker_strength": 0.24
	},
	"duckweed": {
		"visible_strength": 0.24,
		"motion_speed": 0.46,
		"distortion_strength": 0.036,
		"surface_alpha": 0.032,
		"highlight_alpha": 0.008,
		"color_tint": Color(0.66, 0.82, 0.58, 1.0),
		"patch_count": 14,
		"wavelet_count": 2,
		"ripple_count": 2,
		"flicker_strength": 0.14
	},
	"frog_backwater": {
		"visible_strength": 0.28,
		"motion_speed": 0.56,
		"distortion_strength": 0.044,
		"surface_alpha": 0.034,
		"highlight_alpha": 0.008,
		"color_tint": Color(0.68, 0.84, 0.62, 1.0),
		"patch_count": 15,
		"wavelet_count": 2,
		"ripple_count": 3,
		"flicker_strength": 0.20
	},
	"mist": {
		"visible_strength": 0.30,
		"motion_speed": 0.62,
		"distortion_strength": 0.050,
		"surface_alpha": 0.040,
		"highlight_alpha": 0.014,
		"color_tint": Color(0.84, 0.96, 0.92, 1.0),
		"patch_count": 18,
		"wavelet_count": 4,
		"ripple_count": 2,
		"flicker_strength": 0.18
	},
	"deep_water": {
		"visible_strength": 0.34,
		"motion_speed": 0.66,
		"distortion_strength": 0.082,
		"surface_alpha": 0.044,
		"highlight_alpha": 0.016,
		"color_tint": Color(0.58, 0.78, 0.82, 1.0),
		"patch_count": 23,
		"wavelet_count": 6,
		"ripple_count": 2,
		"flicker_strength": 0.20
	},
	"deep_dark": {
		"visible_strength": 0.30,
		"motion_speed": 0.54,
		"distortion_strength": 0.070,
		"surface_alpha": 0.032,
		"highlight_alpha": 0.008,
		"color_tint": Color(0.36, 0.56, 0.60, 1.0),
		"patch_count": 17,
		"wavelet_count": 3,
		"ripple_count": 1,
		"flicker_strength": 0.18
	},
	"cold_water": {
		"visible_strength": 0.32,
		"motion_speed": 0.70,
		"distortion_strength": 0.060,
		"surface_alpha": 0.042,
		"highlight_alpha": 0.016,
		"color_tint": Color(0.78, 0.92, 0.96, 1.0),
		"patch_count": 22,
		"wavelet_count": 7,
		"ripple_count": 2,
		"flicker_strength": 0.22
	},
	"snag_shadow": {
		"visible_strength": 0.28,
		"motion_speed": 0.58,
		"distortion_strength": 0.060,
		"surface_alpha": 0.034,
		"highlight_alpha": 0.008,
		"color_tint": Color(0.46, 0.64, 0.58, 1.0),
		"patch_count": 16,
		"wavelet_count": 3,
		"ripple_count": 2,
		"flicker_strength": 0.18
	}
}

var enabled := true:
	set(value):
		enabled = value
		_refresh_visibility()
var visible_strength := 0.35
var motion_speed := 1.0
var distortion_strength := 0.08
var surface_alpha := 0.10
var highlight_alpha := 0.05
var debug_visible_water_effect := false
var debug_visuals := false

var _profile_id := DEFAULT_PROFILE
var _profile: Dictionary = PROFILES[DEFAULT_PROFILE].duplicate(true)
var _time := 0.0
var _weather_type := "clear"
var _wind_speed_mps := 0.0
var _water_polygon := PackedVector2Array()
var _water_mask_id := FALLBACK_MASK
var _has_polygon := false
var _last_logged_area_key := ""
var _last_logged_profile := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	set_process(true)
	_apply_profile_settings()
	set_debug_visuals(BuildConfig.ENABLE_WATER_DEBUG_VISUALS)
	_refresh_visibility()
	_diagnostic_log("ready size=%s visible=%s mask=%s debug=%s" % [size, visible, _water_mask_id, _is_debug_visuals_enabled()])


func set_enabled(value: bool) -> void:
	enabled = value
	_refresh_visibility()


func set_debug_visuals(value: bool) -> void:
	if debug_visuals == value:
		return

	debug_visuals = value
	_diagnostic_log("debug_visuals=%s profile=%s rect=%s size=%s enabled=%s" % [debug_visuals, _profile_id, Rect2(position, size), size, enabled])
	queue_redraw()


func set_water_profile(profile_id: String) -> void:
	var normalized_id := profile_id.strip_edges()
	if normalized_id == "off" or normalized_id == DISABLED_PROFILE:
		_profile_id = DISABLED_PROFILE
		enabled = false
		_refresh_visibility()
		return

	if not PROFILES.has(normalized_id):
		normalized_id = DEFAULT_PROFILE

	_profile_id = normalized_id
	_profile = PROFILES[_profile_id].duplicate(true)
	enabled = true
	_apply_profile_settings()
	_refresh_visibility()
	_log_profile_if_changed()


func get_water_profile() -> String:
	return _profile_id


func set_weather_context(weather_type: String) -> void:
	set_environment_context(weather_type, _wind_speed_mps)


func set_environment_context(weather_type: String, wind_speed_mps: float = 0.0) -> void:
	var normalized := _normalize_weather_type(weather_type)
	var safe_wind_speed := maxf(wind_speed_mps, 0.0)
	if _weather_type == normalized and is_equal_approx(_wind_speed_mps, safe_wind_speed):
		return

	_weather_type = normalized
	_wind_speed_mps = safe_wind_speed
	_diagnostic_log("environment weather=%s wind=%.2f" % [_weather_type, _wind_speed_mps])
	queue_redraw()


func set_water_area(area_data) -> void:
	if area_data is Rect2:
		set_water_rect(area_data)
		set_water_polygon(PackedVector2Array())
		return

	if area_data is PackedVector2Array:
		set_water_polygon(area_data)
		return

	if not (area_data is Dictionary):
		_refresh_visibility()
		return

	var data := area_data as Dictionary
	var rect = data.get("rect", Rect2(position, size))
	if rect is Rect2:
		_apply_water_rect(rect)

	_water_mask_id = str(data.get("mask_id", FALLBACK_MASK))
	var points = data.get("polygon", PackedVector2Array())
	if points is PackedVector2Array:
		_apply_water_polygon(points)
	else:
		_apply_water_polygon(PackedVector2Array())

	_log_area_if_changed()
	queue_redraw()


func set_water_rect(rect: Rect2) -> void:
	_apply_water_rect(rect)
	_log_area_if_changed()
	queue_redraw()


func set_water_polygon(points: PackedVector2Array) -> void:
	_apply_water_polygon(points)
	_log_area_if_changed()
	queue_redraw()


func _process(delta: float) -> void:
	if not visible or not enabled:
		return

	_time += delta
	queue_redraw()


func _draw() -> void:
	if not enabled or size.x <= 1.0 or size.y <= 1.0:
		return

	if _is_debug_visuals_enabled():
		_draw_debug_visuals()
		return

	var tint: Color = _profile.get("color_tint", Color(0.70, 0.92, 0.86, 1.0))
	var strength := _get_effective_visible_strength()
	_draw_soft_wave_segments(tint, strength)
	_draw_subtle_ripple_segments(tint, strength)
	_draw_soft_highlight_segments(tint, strength)


func _apply_profile_settings() -> void:
	visible_strength = clampf(float(_profile.get("visible_strength", 0.35)), 0.0, MAX_VISIBLE_STRENGTH)
	motion_speed = clampf(float(_profile.get("motion_speed", 1.0)), 0.0, MAX_MOTION_SPEED)
	distortion_strength = clampf(float(_profile.get("distortion_strength", 0.08)), 0.0, MAX_DISTORTION_STRENGTH)
	surface_alpha = clampf(float(_profile.get("surface_alpha", 0.10)), 0.0, MAX_SURFACE_ALPHA)
	highlight_alpha = clampf(float(_profile.get("highlight_alpha", 0.05)), 0.0, MAX_HIGHLIGHT_ALPHA)


func _apply_water_rect(rect: Rect2) -> void:
	position = rect.position
	size = rect.size
	custom_minimum_size = Vector2.ZERO
	_refresh_visibility()


func _apply_water_polygon(points: PackedVector2Array) -> void:
	_water_polygon = points
	_has_polygon = points.size() >= 3
	_refresh_visibility()


func _refresh_visibility() -> void:
	visible = enabled and size.x > 1.0 and size.y > 1.0
	set_process(visible)
	queue_redraw()


func _draw_soft_wave_segments(tint: Color, strength: float) -> void:
	var count := _get_normal_wave_segment_count()
	var speed := _get_motion_scale()
	var alpha_base := surface_alpha * strength * _get_weather_surface_scale() * _get_wind_alpha_scale()

	for i in range(count):
		var seed := float(i + 7)
		var y_ratio := clampf(0.18 + _stable_unit(seed, 1.8) * 0.68, 0.12, 0.88)
		var near_scale := _get_near_visibility_scale(y_ratio)
		var length := clampf(size.x * (0.040 + _stable_unit(seed, 2.9) * 0.060), 20.0, 82.0)
		var amplitude := clampf(size.y * (0.004 + _stable_unit(seed, 3.6) * 0.010), 1.2, 5.2) * maxf(distortion_strength / 0.06, 0.55)
		var points := _make_wave_segment_points(seed, y_ratio, speed, length, amplitude)
		if points.size() < 2 or not _can_draw_shape(points):
			continue

		var alpha_variation := 0.46 + _stable_unit(seed, 4.2) * 0.70
		var alpha := minf(alpha_base * near_scale * alpha_variation * 1.45, MAX_NORMAL_WAVE_ALPHA)
		var color := _make_normal_wave_color(tint, alpha, 0.48)
		var line_width := clampf(0.45 + strength * 0.50 + _stable_unit(seed, 5.1) * 0.10, 0.45, 0.85)
		draw_polyline(points, color, line_width, true)


func _draw_subtle_ripple_segments(tint: Color, strength: float) -> void:
	var count := clampi(int(_profile.get("ripple_count", 2)) + int(round(_get_weather_ripple_bonus())), 0, 5)
	var speed := _get_motion_scale()
	var alpha_base := surface_alpha * strength * _get_weather_ripple_scale() * _get_wind_alpha_scale()

	for i in range(count):
		var seed := float(i + 43)
		var cycle := fposmod(_time * (0.055 + speed * 0.075) + _stable_unit(seed, 6.3), 1.0)
		var center := _make_moving_center(seed, speed * 0.42, 0.30, 0.82)
		var near_scale := _get_near_visibility_scale(center.y / maxf(size.y, 1.0))
		var radius_x := clampf(lerpf(16.0, minf(size.x, size.y) * 0.14, cycle), 14.0, 70.0)
		var radius_y := radius_x * (0.18 + _stable_unit(seed, 7.1) * 0.12)
		var points := _make_ripple_segment_points(center, radius_x, radius_y, seed, cycle)
		if points.size() < 2 or not _can_draw_shape(points):
			continue

		var fade := pow(1.0 - cycle, 1.35)
		var alpha := minf(alpha_base * near_scale * fade * 1.25, MAX_NORMAL_RIPPLE_ALPHA)
		var color := _make_normal_wave_color(tint, alpha, 0.58)
		draw_polyline(points, color, clampf(0.45 + strength * 0.30, 0.45, 0.70), true)


func _draw_soft_highlight_segments(tint: Color, strength: float) -> void:
	if highlight_alpha <= 0.0:
		return

	var count := clampi(int(ceil(float(_get_wavelet_count()) * 0.45)), 0, 6)
	var speed := _get_motion_scale()
	var alpha_base := highlight_alpha * strength * _get_weather_highlight_scale() * _get_wind_alpha_scale()

	for i in range(count):
		var seed := float(i + 89)
		var y_ratio := clampf(0.22 + _stable_unit(seed, 8.8) * 0.58, 0.16, 0.84)
		var near_scale := _get_near_visibility_scale(y_ratio)
		var length := clampf(size.x * (0.026 + _stable_unit(seed, 9.4) * 0.034), 16.0, 48.0)
		var amplitude := clampf(size.y * (0.002 + _stable_unit(seed, 10.5) * 0.004), 0.6, 2.4)
		var points := _make_wave_segment_points(seed, y_ratio, speed * 0.70, length, amplitude)
		if points.size() < 2 or not _can_draw_shape(points):
			continue

		var flicker := 0.48 + 0.52 * (sin(_time * (0.42 + _stable_unit(seed, 11.7) * 0.20) + seed) * 0.5 + 0.5)
		var alpha := minf(alpha_base * near_scale * flicker * 2.10, MAX_NORMAL_HIGHLIGHT_ALPHA)
		var color := Color(1.0, 0.96, 0.80, maxf(alpha, 0.0))
		draw_polyline(points, color, clampf(0.45 + strength * 0.22, 0.45, 0.62), true)


func _draw_debug_visuals() -> void:
	_draw_debug_water_outline()
	_draw_debug_motion_marks()
	_draw_debug_label()


func _draw_debug_water_outline() -> void:
	var outline_points := _get_debug_outline_points()
	if outline_points.size() < 2:
		return

	var color := Color(0.72, 1.0, 0.96, DEBUG_OUTLINE_ALPHA)
	for i in range(outline_points.size()):
		var from_point := outline_points[i]
		var to_point := outline_points[(i + 1) % outline_points.size()]
		_draw_dashed_segment(from_point, to_point, color, 1.15)


func _draw_debug_motion_marks() -> void:
	var count := clampi(int(round(5.0 * DEBUG_WATER_LINE_COUNT_MULT)), 5, 8)
	var debug_alpha := clampf(DEBUG_WAVE_BASE_ALPHA * DEBUG_WATER_ALPHA_MULT, 0.25, 0.34)
	var color := Color(0.92, 1.0, 0.94, debug_alpha)
	var speed := maxf(_get_motion_scale(), 0.35)

	for i in range(count):
		var seed := float(i + 131)
		var center := _make_moving_center(seed, speed * 1.15, 0.22, 0.84)
		var length := clampf(size.x * (0.035 + _stable_unit(seed, 18.8) * 0.060), 18.0, 72.0)
		var amplitude := clampf(size.y * (0.006 + _stable_unit(seed, 19.4) * 0.010), 2.0, 7.0)
		var phase := _time * speed * (1.2 + _stable_unit(seed, 20.1) * 0.8) + seed
		var points := PackedVector2Array()
		for point_index in range(5):
			var t := float(point_index) / 4.0
			var x := center.x - length * 0.5 + length * t
			var y := center.y + sin(t * TAU + phase) * amplitude
			points.append(Vector2(x, y))
		if _can_draw_shape(points):
			draw_polyline(points, color, 1.1, true)


func _draw_debug_label() -> void:
	var font := get_theme_default_font()
	if font == null:
		return

	var text := "Water: profile=%s, rect=(%d,%d,%d,%d)" % [
		_profile_id,
		int(position.x),
		int(position.y),
		int(size.x),
		int(size.y)
	]
	var label_pos := Vector2(8.0, minf(18.0, maxf(size.y - 8.0, 8.0)))
	var shadow_color := Color(0.0, 0.0, 0.0, 0.46)
	var label_color := Color(0.82, 1.0, 0.94, 0.88)
	draw_string(font, label_pos + Vector2(1.0, 1.0), text, HORIZONTAL_ALIGNMENT_LEFT, maxf(size.x - 16.0, 1.0), 11, shadow_color)
	draw_string(font, label_pos, text, HORIZONTAL_ALIGNMENT_LEFT, maxf(size.x - 16.0, 1.0), 11, label_color)


func _get_debug_outline_points() -> PackedVector2Array:
	if _has_polygon:
		return _water_polygon

	return PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0.0),
		size,
		Vector2(0.0, size.y)
	])


func _draw_dashed_segment(from_point: Vector2, to_point: Vector2, color: Color, width: float) -> void:
	var distance := from_point.distance_to(to_point)
	if distance <= 0.1:
		return

	var direction := (to_point - from_point) / distance
	var dash_length := 10.0
	var gap_length := 7.0
	var cursor := 0.0
	while cursor < distance:
		var dash_end := minf(cursor + dash_length, distance)
		draw_line(from_point + direction * cursor, from_point + direction * dash_end, color, width, true)
		cursor += dash_length + gap_length


func _make_wave_segment_points(seed: float, y_ratio: float, speed: float, length: float, amplitude: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var drift := _time * speed * size.x * (0.008 + _stable_unit(seed, 12.2) * 0.010)
	var start_x := fposmod(_stable_unit(seed, 13.4) * (size.x + length) + drift, size.x + length) - length * 0.5
	var base_y := size.y * y_ratio
	var phase := _time * speed * (0.52 + _stable_unit(seed, 14.9) * 0.42) + seed * 0.31

	for point_index in range(5):
		var t := float(point_index) / 4.0
		var x := start_x + length * t
		var y := base_y + sin(t * TAU + phase) * amplitude + sin(t * PI - phase * 0.45) * amplitude * 0.28
		points.append(Vector2(x, y))

	return points


func _make_ripple_segment_points(center: Vector2, radius_x: float, radius_y: float, seed: float, cycle: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var start_angle := PI * (0.10 + _stable_unit(seed, 15.5) * 0.90)
	var sweep := PI * (0.45 + _stable_unit(seed, 16.1) * 0.45)
	var tilt := (_stable_unit(seed, 17.6) - 0.5) * 0.34
	var cos_tilt := cos(tilt)
	var sin_tilt := sin(tilt)

	for point_index in range(8):
		var t := float(point_index) / 7.0
		var angle := start_angle + sweep * t + cycle * 0.10
		var local := Vector2(cos(angle) * radius_x, sin(angle) * radius_y)
		var rotated := Vector2(local.x * cos_tilt - local.y * sin_tilt, local.x * sin_tilt + local.y * cos_tilt)
		points.append(center + rotated)

	return points


func _make_moving_center(seed: float, speed: float, min_y_ratio: float, max_y_ratio: float) -> Vector2:
	var drift_x := _time * speed * (0.012 + _stable_unit(seed, 13.5) * 0.016)
	var drift_y := sin(_time * speed * (0.055 + _stable_unit(seed, 14.2) * 0.045) + seed) * 0.028
	var x := size.x * fposmod(_stable_unit(seed, 15.1) + drift_x, 1.0)
	var y_ratio := clampf(min_y_ratio + (max_y_ratio - min_y_ratio) * fposmod(_stable_unit(seed, 16.7) + drift_y, 1.0), min_y_ratio, max_y_ratio)
	return Vector2(x, size.y * y_ratio)


func _can_draw_shape(points: PackedVector2Array) -> bool:
	for point in points:
		if not _is_point_in_water_area(point):
			return false
	return true


func _is_point_in_water_area(point: Vector2) -> bool:
	if point.x < 0.0 or point.y < 0.0 or point.x > size.x or point.y > size.y:
		return false

	if not _has_polygon:
		return true

	return _point_in_polygon(point, _water_polygon)


func _point_in_polygon(point: Vector2, polygon: PackedVector2Array) -> bool:
	var inside := false
	var j := polygon.size() - 1
	for i in range(polygon.size()):
		var pi := polygon[i]
		var pj := polygon[j]
		var crosses := (pi.y > point.y) != (pj.y > point.y)
		if crosses:
			var denominator := pj.y - pi.y
			if absf(denominator) > 0.001:
				var x_at_y := (pj.x - pi.x) * (point.y - pi.y) / denominator + pi.x
				if point.x < x_at_y:
					inside = not inside
		j = i

	return inside


func _get_normal_wave_segment_count() -> int:
	var wavelets := int(_profile.get("wavelet_count", 5))
	var patches := int(_profile.get("patch_count", 18))
	return clampi(wavelets + int(round(float(patches) * 0.34)), 5, 18)


func _get_wavelet_count() -> int:
	return _scale_debug_count(clampi(int(_profile.get("wavelet_count", 5)), 0, 12), 12)


func _scale_debug_count(count: int, max_count: int) -> int:
	if not _is_debug_visuals_enabled():
		return count

	return clampi(int(ceil(float(count) * DEBUG_WATER_LINE_COUNT_MULT)), count, max_count)


func _get_effective_visible_strength() -> float:
	var multiplier := 1.18 if _is_debug_visuals_enabled() else 1.0
	return clampf(visible_strength * multiplier, 0.0, MAX_VISIBLE_STRENGTH)


func _is_debug_visuals_enabled() -> bool:
	return debug_visuals or debug_visible_water_effect


func _get_motion_scale() -> float:
	var wind_scale := 1.0 + clampf(_wind_speed_mps / 11.0, 0.0, 0.30)
	return clampf(motion_speed * wind_scale * _get_weather_motion_scale(), 0.0, MAX_MOTION_SPEED)


func _get_near_visibility_scale(local_y_ratio: float) -> float:
	var near_t := smoothstep(0.20, 0.86, clampf(local_y_ratio, 0.0, 1.0))
	return lerpf(0.72, 1.24, near_t)


func _get_wind_alpha_scale() -> float:
	return 1.0 + clampf(_wind_speed_mps / 14.0, 0.0, 0.14)


func _get_weather_motion_scale() -> float:
	match _weather_type:
		"storm":
			return 1.18
		"rain":
			return 1.08
		"cloudy":
			return 0.94
		_:
			return 1.0


func _get_weather_surface_scale() -> float:
	match _weather_type:
		"storm":
			return 0.92
		"rain":
			return 1.02
		"cloudy":
			return 0.92
		_:
			return 1.0


func _get_weather_ripple_scale() -> float:
	match _weather_type:
		"storm":
			return 1.28
		"rain":
			return 1.22
		_:
			return 1.0


func _get_weather_ripple_bonus() -> float:
	match _weather_type:
		"storm":
			return 2.0
		"rain":
			return 1.0
		_:
			return 0.0


func _get_weather_highlight_scale() -> float:
	match _weather_type:
		"storm":
			return 0.34
		"rain":
			return 0.48
		"cloudy":
			return 0.68
		_:
			return 1.0


func _make_normal_wave_color(tint: Color, alpha: float, white_mix: float) -> Color:
	var mixed := tint.lerp(Color(0.98, 1.0, 0.94, 1.0), white_mix)
	return Color(mixed.r, mixed.g, mixed.b, maxf(alpha, 0.0))


func _stable_unit(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 12.9898 + salt * 78.233) * 43758.5453123, 1.0)


func _normalize_weather_type(weather_type: String) -> String:
	match weather_type.strip_edges().to_lower():
		"storm", "thunderstorm", "rain_with_thunderstorms", "РіСЂРѕР·Р°", "РґРѕР¶РґСЊ СЃ РіСЂРѕР·РѕР№":
			return "storm"
		"rain", "rainy", "РґРѕР¶РґСЊ":
			return "rain"
		"cloudy", "overcast", "fog", "mist", "night_mist", "РѕР±Р»Р°С‡РЅРѕ", "С‚СѓРјР°РЅ":
			return "cloudy"
		_:
			return "clear"


func _log_profile_if_changed() -> void:
	if _last_logged_profile == _profile_id:
		return

	_last_logged_profile = _profile_id
	_diagnostic_log("profile=%s enabled=%s visible=%s strength=%.2f mask=%s debug=%s" % [_profile_id, enabled, visible, visible_strength, _water_mask_id, _is_debug_visuals_enabled()])


func _log_area_if_changed() -> void:
	var key := "%s|%s|%s|%s" % [_water_mask_id, Rect2(position, size), _water_polygon.size(), visible]
	if key == _last_logged_area_key:
		return

	_last_logged_area_key = key
	_diagnostic_log("area mask=%s rect=%s polygon_points=%s visible=%s debug=%s" % [_water_mask_id, Rect2(position, size), _water_polygon.size(), visible, _is_debug_visuals_enabled()])


func _diagnostic_log(message: String) -> void:
	if BuildConfig.ENABLE_VERBOSE_LOGS or _is_debug_visuals_enabled():
		print("WaterLiveLayer: %s" % message)


func _verbose_log(message: String) -> void:
	if BuildConfig.ENABLE_VERBOSE_LOGS:
		print("WaterLiveLayer: %s" % message)
