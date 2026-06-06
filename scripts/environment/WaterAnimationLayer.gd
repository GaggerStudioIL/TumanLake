extends Control

const DEFAULT_PROFILE := "calm_pier"
const DISABLED_PROFILE := "disabled"
const SAFE_ALPHA_SCALE := 0.55
const DEBUG_ALPHA_SCALE := 2.0
const MAX_WAVE_ALPHA := 0.014
const MAX_RIPPLE_ALPHA := 0.013
const MAX_HIGHLIGHT_ALPHA := 0.010
const DEBUG_MAX_WAVE_ALPHA := 0.045
const DEBUG_MAX_RIPPLE_ALPHA := 0.040
const DEBUG_MAX_HIGHLIGHT_ALPHA := 0.038

const PROFILES := {
	"calm_pier": {
		"intensity": 0.20,
		"wave_count": 2,
		"wave_speed": 0.15,
		"wave_alpha": 0.024,
		"ripple_count": 2,
		"ripple_alpha": 0.024,
		"highlight_alpha": 0.006,
		"color_tint": Color(0.70, 0.92, 0.86, 1.0),
		"movement_scale": 0.54
	},
	"open_water": {
		"intensity": 0.30,
		"wave_count": 4,
		"wave_speed": 0.26,
		"wave_alpha": 0.036,
		"ripple_count": 3,
		"ripple_alpha": 0.030,
		"highlight_alpha": 0.018,
		"color_tint": Color(0.72, 0.94, 0.92, 1.0),
		"movement_scale": 0.82
	},
	"reeds": {
		"intensity": 0.24,
		"wave_count": 3,
		"wave_speed": 0.18,
		"wave_alpha": 0.028,
		"ripple_count": 2,
		"ripple_alpha": 0.026,
		"highlight_alpha": 0.010,
		"color_tint": Color(0.72, 0.90, 0.76, 1.0),
		"movement_scale": 0.52
	},
	"duckweed": {
		"intensity": 0.14,
		"wave_count": 0,
		"wave_speed": 0.08,
		"wave_alpha": 0.000,
		"ripple_count": 2,
		"ripple_alpha": 0.024,
		"highlight_alpha": 0.000,
		"color_tint": Color(0.64, 0.82, 0.58, 1.0),
		"movement_scale": 0.34
	},
	"frog_backwater": {
		"intensity": 0.16,
		"wave_count": 1,
		"wave_speed": 0.10,
		"wave_alpha": 0.012,
		"ripple_count": 3,
		"ripple_alpha": 0.026,
		"highlight_alpha": 0.000,
		"color_tint": Color(0.68, 0.84, 0.62, 1.0),
		"movement_scale": 0.38
	},
	"mist": {
		"intensity": 0.18,
		"wave_count": 2,
		"wave_speed": 0.12,
		"wave_alpha": 0.020,
		"ripple_count": 2,
		"ripple_alpha": 0.022,
		"highlight_alpha": 0.006,
		"color_tint": Color(0.84, 0.96, 0.92, 1.0),
		"movement_scale": 0.48
	},
	"deep_water": {
		"intensity": 0.24,
		"wave_count": 3,
		"wave_speed": 0.14,
		"wave_alpha": 0.026,
		"ripple_count": 2,
		"ripple_alpha": 0.020,
		"highlight_alpha": 0.008,
		"color_tint": Color(0.58, 0.78, 0.82, 1.0),
		"movement_scale": 0.66
	},
	"deep_dark": {
		"intensity": 0.18,
		"wave_count": 2,
		"wave_speed": 0.12,
		"wave_alpha": 0.018,
		"ripple_count": 1,
		"ripple_alpha": 0.014,
		"highlight_alpha": 0.004,
		"color_tint": Color(0.36, 0.56, 0.60, 1.0),
		"movement_scale": 0.48
	},
	"cold_water": {
		"intensity": 0.24,
		"wave_count": 3,
		"wave_speed": 0.20,
		"wave_alpha": 0.028,
		"ripple_count": 2,
		"ripple_alpha": 0.022,
		"highlight_alpha": 0.014,
		"color_tint": Color(0.72, 0.92, 1.00, 1.0),
		"movement_scale": 0.64
	},
	"snag_shadow": {
		"intensity": 0.17,
		"wave_count": 2,
		"wave_speed": 0.11,
		"wave_alpha": 0.016,
		"ripple_count": 2,
		"ripple_alpha": 0.018,
		"highlight_alpha": 0.004,
		"color_tint": Color(0.46, 0.64, 0.58, 1.0),
		"movement_scale": 0.42
	}
}

var _profile_id := DEFAULT_PROFILE
var _profile: Dictionary = PROFILES[DEFAULT_PROFILE].duplicate(true)
var _time := 0.0
var _effect_enabled := true
var debug_visible_water_effect := false
var _weather_type := "clear"
var _last_logged_rect := Rect2()
var _has_logged_rect := false
var _last_logged_profile := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	set_process(true)
	_verbose_log("ready debug_visible=%s size=%s visible=%s" % [debug_visible_water_effect, size, visible])


func set_water_profile(profile_id: String) -> void:
	var normalized_id := profile_id.strip_edges()
	if normalized_id == "off" or normalized_id == DISABLED_PROFILE:
		_profile_id = DISABLED_PROFILE
		_effect_enabled = false
		visible = false
		queue_redraw()
		return

	if not PROFILES.has(normalized_id):
		normalized_id = DEFAULT_PROFILE

	_profile_id = normalized_id
	_profile = PROFILES[_profile_id].duplicate(true)
	_effect_enabled = true
	visible = size.x > 1.0 and size.y > 1.0
	_log_profile_if_changed()
	queue_redraw()


func get_water_profile() -> String:
	return _profile_id


func set_weather_context(weather_type: String) -> void:
	var normalized := _normalize_weather_type(weather_type)
	if _weather_type == normalized:
		return

	_weather_type = normalized
	_verbose_log("weather_type=%s" % _weather_type)
	queue_redraw()


func set_water_rect(rect: Rect2) -> void:
	position = rect.position
	size = rect.size
	custom_minimum_size = Vector2.ZERO
	visible = _effect_enabled and rect.size.x > 1.0 and rect.size.y > 1.0
	_log_rect_if_changed()
	queue_redraw()


func _process(delta: float) -> void:
	if not visible or not _effect_enabled:
		return

	_time += delta
	queue_redraw()


func _draw() -> void:
	if not _effect_enabled or size.x <= 1.0 or size.y <= 1.0:
		return

	var intensity := _get_draw_intensity()
	var tint: Color = _profile.get("color_tint", Color(0.70, 0.92, 0.86, 1.0))
	# Safe prototype: no fills, only faint strokes over the water zone.
	_draw_wave_lines(tint, intensity)
	_draw_ripples(tint, intensity)
	_draw_highlights(tint, intensity)


func _draw_wave_lines(tint: Color, intensity: float) -> void:
	var wave_count := _get_wave_count()
	var wave_speed := float(_profile.get("wave_speed", 0.2)) * (1.28 if debug_visible_water_effect else 1.0)
	var wave_alpha := float(_profile.get("wave_alpha", 0.04))
	var movement_scale := float(_profile.get("movement_scale", 0.7)) * (1.25 if debug_visible_water_effect else 1.0)
	var line_width := clampf(0.42 + intensity * (0.82 if debug_visible_water_effect else 0.52), 0.42, 1.05 if debug_visible_water_effect else 0.70)
	var step := maxf(size.x / 54.0, 13.0)

	for i in range(wave_count):
		var progress := _get_wave_progress(i, wave_count)
		var segment_count := 2 if debug_visible_water_effect and wave_count > 2 else 1
		for segment_index in range(segment_count):
			var points := _make_wave_segment_points(i, segment_index, progress, wave_speed, movement_scale, step)
			if points.size() < 2:
				continue

			var alpha_variation := 0.54 + _stable_unit(float(i * 13 + segment_index * 7), 4.2) * 0.34
			var alpha := minf(wave_alpha * intensity * alpha_variation * _get_alpha_scale() * _get_weather_wave_scale(), _get_max_wave_alpha())
			var color := _make_water_stroke_color(tint, alpha)
			draw_polyline(points, color, line_width, true)


func _draw_ripples(tint: Color, intensity: float) -> void:
	var ripple_count := _get_ripple_count()
	var ripple_alpha := float(_profile.get("ripple_alpha", 0.04))
	var wave_speed := float(_profile.get("wave_speed", 0.2)) * (1.24 if debug_visible_water_effect else 1.0)
	var movement_scale := float(_profile.get("movement_scale", 0.7)) * (1.20 if debug_visible_water_effect else 1.0)

	for i in range(ripple_count):
		var cycle := fmod(_time * (0.14 + wave_speed * 0.26) + float(i) * 0.37, 1.0)
		var seed := float(i + 1)
		var center := Vector2(
			size.x * (0.22 + 0.58 * fposmod(sin(seed * 5.31) * 0.5 + 0.5 + cycle * 0.08, 1.0)),
			size.y * (0.30 + 0.46 * (sin(seed * 3.77 + _time * 0.04) * 0.5 + 0.5))
		)
		var max_radius := maxf(18.0, minf(size.x, size.y) * (0.13 + 0.04 * movement_scale))
		var radius := lerpf(6.0, max_radius, cycle)
		var fade := 1.0 - cycle
		var alpha := minf(ripple_alpha * intensity * fade * _get_alpha_scale() * _get_weather_ripple_scale(), _get_max_ripple_alpha())
		var color := _make_water_stroke_color(tint, alpha)
		draw_arc(center, radius, PI * 0.10, PI * 1.18, 28, color, 0.85 if debug_visible_water_effect else 0.65, true)
		draw_arc(center, radius * 0.64, PI * 1.08, PI * 1.78, 20, color * Color(1.0, 1.0, 1.0, 0.72), 0.70 if debug_visible_water_effect else 0.55, true)


func _draw_highlights(tint: Color, intensity: float) -> void:
	var highlight_alpha := float(_profile.get("highlight_alpha", 0.03))
	if highlight_alpha <= 0.0:
		return

	var movement_scale := float(_profile.get("movement_scale", 0.7))
	var highlight_count: int = _get_highlight_count()

	for i in range(highlight_count):
		var seed := float(i + 1)
		var x := size.x * fposmod(0.19 * seed + _time * 0.018 * movement_scale, 1.0)
		var y := size.y * (0.20 + 0.60 * fposmod(sin(seed * 2.41) * 0.5 + 0.5, 1.0))
		var length := clampf(size.x * (0.045 + 0.012 * sin(seed)), 18.0, 58.0)
		var alpha := minf(highlight_alpha * intensity * (0.55 + 0.45 * sin(_time * 0.7 + seed)) * _get_alpha_scale() * _get_weather_highlight_scale(), _get_max_highlight_alpha())
		var color := Color(1.0, 0.96, 0.78, maxf(alpha, 0.0))
		draw_line(Vector2(x, y), Vector2(minf(x + length, size.x), y + sin(_time + seed) * 1.2), color, 0.90 if debug_visible_water_effect else 0.65, true)


func _make_wave_segment_points(wave_index: int, segment_index: int, progress: float, wave_speed: float, movement_scale: float, step: float) -> PackedVector2Array:
	var seed := float(wave_index * 31 + segment_index * 17 + 3)
	var y_jitter := (_stable_unit(seed, 1.7) - 0.5) * 0.11
	var y := lerpf(size.y * 0.18, size.y * 0.76, clampf(progress + y_jitter, 0.0, 1.0))
	var phase := _time * wave_speed * (0.56 + _stable_unit(seed, 2.1) * 0.28) + seed * 0.37
	var amplitude := (0.9 + _stable_unit(seed, 3.9) * 1.35) * movement_scale * maxf(size.y / 260.0, 0.62)
	var segment_length := size.x * (0.22 + _stable_unit(seed, 5.4) * (0.22 if debug_visible_water_effect else 0.16))
	var drift := _time * wave_speed * size.x * 0.018 * (0.7 + _stable_unit(seed, 6.8))
	var start_x := fposmod(_stable_unit(seed, 7.1) * (size.x + segment_length) + drift, size.x + segment_length) - segment_length * 0.5
	var end_x := minf(start_x + segment_length, size.x + step)
	var points := PackedVector2Array()
	var x := maxf(start_x, -step)

	while x <= end_x:
		var wave_y := y + sin(x * 0.018 + phase) * amplitude + sin(x * 0.006 - phase * 0.72) * amplitude * 0.42
		points.append(Vector2(x, wave_y))
		x += step

	return points


func _get_draw_intensity() -> float:
	var intensity := float(_profile.get("intensity", 0.25))
	if debug_visible_water_effect:
		return minf(intensity * 1.35, 0.62)

	return intensity


func _get_alpha_scale() -> float:
	return DEBUG_ALPHA_SCALE if debug_visible_water_effect else SAFE_ALPHA_SCALE


func _get_weather_wave_scale() -> float:
	match _weather_type:
		"storm":
			return 0.42
		"rain":
			return 0.56
		"cloudy":
			return 0.82
		_:
			return 1.0


func _get_weather_ripple_scale() -> float:
	match _weather_type:
		"storm":
			return 0.72
		"rain":
			return 0.82
		_:
			return 1.0


func _get_weather_highlight_scale() -> float:
	match _weather_type:
		"storm":
			return 0.16
		"rain":
			return 0.28
		"cloudy":
			return 0.58
		_:
			return 1.0


func _get_max_wave_alpha() -> float:
	return DEBUG_MAX_WAVE_ALPHA if debug_visible_water_effect else MAX_WAVE_ALPHA


func _get_max_ripple_alpha() -> float:
	return DEBUG_MAX_RIPPLE_ALPHA if debug_visible_water_effect else MAX_RIPPLE_ALPHA


func _get_max_highlight_alpha() -> float:
	return DEBUG_MAX_HIGHLIGHT_ALPHA if debug_visible_water_effect else MAX_HIGHLIGHT_ALPHA


func _get_wave_count() -> int:
	var base_count := int(_profile.get("wave_count", 4))
	if not debug_visible_water_effect:
		return base_count
	if _profile_id == "duckweed":
		return maxi(base_count, 3)
	if _profile_id == "frog_backwater":
		return maxi(base_count, 5)

	return mini(maxi(base_count * 2, 10), 16)


func _get_ripple_count() -> int:
	var base_count := int(_profile.get("ripple_count", 2))
	if not debug_visible_water_effect:
		return base_count
	if _profile_id == "duckweed" or _profile_id == "frog_backwater":
		return maxi(base_count, 4)

	return mini(maxi(base_count + 1, 3), 5)


func _get_highlight_count() -> int:
	var base_count := maxi(1, int(ceil(float(_profile.get("wave_count", 4)) * 0.42)))
	if float(_profile.get("highlight_alpha", 0.0)) <= 0.0:
		return 0
	if not debug_visible_water_effect:
		return base_count
	if _profile_id == "duckweed" or _profile_id == "frog_backwater":
		return base_count

	return maxi(base_count, 4)


func _make_water_stroke_color(tint: Color, alpha: float) -> Color:
	var mixed := tint.lerp(Color.WHITE, 0.34 if debug_visible_water_effect else 0.12)
	return Color(mixed.r, mixed.g, mixed.b, maxf(alpha, 0.0))


func _get_wave_progress(index: int, wave_count: int) -> float:
	if wave_count <= 1:
		return 0.42

	var spread := 0.66
	var base := float(index) / float(maxi(wave_count - 1, 1))
	return clampf(0.14 + base * spread + (_stable_unit(float(index), 8.4) - 0.5) * 0.08, 0.10, 0.86)


func _stable_unit(seed: float, salt: float) -> float:
	return fposmod(sin(seed * 12.9898 + salt * 78.233) * 43758.5453123, 1.0)


func _normalize_weather_type(weather_type: String) -> String:
	match weather_type.strip_edges().to_lower():
		"storm", "thunderstorm", "rain_with_thunderstorms", "гроза", "дождь с грозой":
			return "storm"
		"rain", "rainy", "дождь":
			return "rain"
		"cloudy", "overcast", "fog", "mist", "night_mist", "облачно", "туман":
			return "cloudy"
		_:
			return "clear"


func _log_profile_if_changed() -> void:
	if _last_logged_profile == _profile_id:
		return

	_last_logged_profile = _profile_id
	_verbose_log("profile_id=%s visible=%s enabled=%s size=%s debug_visible=%s" % [_profile_id, visible, _effect_enabled, size, debug_visible_water_effect])


func _log_rect_if_changed() -> void:
	var rect := Rect2(position, size)
	if _has_logged_rect and _rects_equal(_last_logged_rect, rect):
		return

	_has_logged_rect = true
	_last_logged_rect = rect
	_verbose_log("water_rect=%s size=%s visible=%s enabled=%s profile_id=%s z=%s" % [rect, size, visible, _effect_enabled, _profile_id, z_index])


func _rects_equal(a: Rect2, b: Rect2) -> bool:
	return a.position.is_equal_approx(b.position) and a.size.is_equal_approx(b.size)


func _verbose_log(message: String) -> void:
	if BuildConfig.ENABLE_VERBOSE_LOGS:
		print("WaterAnimationLayer: %s" % message)
