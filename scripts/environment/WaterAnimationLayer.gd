extends Control

const DEFAULT_PROFILE := "calm_pier"
const DISABLED_PROFILE := "disabled"

const PROFILES := {
	"calm_pier": {
		"intensity": 0.28,
		"wave_count": 4,
		"wave_speed": 0.20,
		"wave_alpha": 0.050,
		"ripple_count": 2,
		"ripple_alpha": 0.045,
		"highlight_alpha": 0.034,
		"color_tint": Color(0.70, 0.92, 0.86, 1.0),
		"movement_scale": 0.78
	},
	"open_water": {
		"intensity": 0.42,
		"wave_count": 7,
		"wave_speed": 0.34,
		"wave_alpha": 0.070,
		"ripple_count": 3,
		"ripple_alpha": 0.052,
		"highlight_alpha": 0.065,
		"color_tint": Color(0.72, 0.94, 0.92, 1.0),
		"movement_scale": 1.12
	},
	"reeds": {
		"intensity": 0.32,
		"wave_count": 5,
		"wave_speed": 0.22,
		"wave_alpha": 0.055,
		"ripple_count": 2,
		"ripple_alpha": 0.046,
		"highlight_alpha": 0.040,
		"color_tint": Color(0.72, 0.90, 0.76, 1.0),
		"movement_scale": 0.72
	},
	"duckweed": {
		"intensity": 0.18,
		"wave_count": 1,
		"wave_speed": 0.10,
		"wave_alpha": 0.018,
		"ripple_count": 2,
		"ripple_alpha": 0.038,
		"highlight_alpha": 0.018,
		"color_tint": Color(0.64, 0.82, 0.58, 1.0),
		"movement_scale": 0.42
	},
	"frog_backwater": {
		"intensity": 0.20,
		"wave_count": 2,
		"wave_speed": 0.12,
		"wave_alpha": 0.024,
		"ripple_count": 3,
		"ripple_alpha": 0.044,
		"highlight_alpha": 0.020,
		"color_tint": Color(0.68, 0.84, 0.62, 1.0),
		"movement_scale": 0.50
	},
	"mist": {
		"intensity": 0.24,
		"wave_count": 4,
		"wave_speed": 0.16,
		"wave_alpha": 0.034,
		"ripple_count": 2,
		"ripple_alpha": 0.032,
		"highlight_alpha": 0.024,
		"color_tint": Color(0.84, 0.96, 0.92, 1.0),
		"movement_scale": 0.64
	},
	"deep_water": {
		"intensity": 0.34,
		"wave_count": 5,
		"wave_speed": 0.18,
		"wave_alpha": 0.046,
		"ripple_count": 2,
		"ripple_alpha": 0.030,
		"highlight_alpha": 0.030,
		"color_tint": Color(0.58, 0.78, 0.82, 1.0),
		"movement_scale": 0.88
	},
	"deep_dark": {
		"intensity": 0.24,
		"wave_count": 4,
		"wave_speed": 0.12,
		"wave_alpha": 0.030,
		"ripple_count": 1,
		"ripple_alpha": 0.022,
		"highlight_alpha": 0.014,
		"color_tint": Color(0.36, 0.56, 0.60, 1.0),
		"movement_scale": 0.62
	},
	"cold_water": {
		"intensity": 0.30,
		"wave_count": 4,
		"wave_speed": 0.24,
		"wave_alpha": 0.046,
		"ripple_count": 2,
		"ripple_alpha": 0.032,
		"highlight_alpha": 0.044,
		"color_tint": Color(0.72, 0.92, 1.00, 1.0),
		"movement_scale": 0.86
	},
	"snag_shadow": {
		"intensity": 0.22,
		"wave_count": 3,
		"wave_speed": 0.14,
		"wave_alpha": 0.026,
		"ripple_count": 2,
		"ripple_alpha": 0.028,
		"highlight_alpha": 0.014,
		"color_tint": Color(0.46, 0.64, 0.58, 1.0),
		"movement_scale": 0.54
	}
}

var _profile_id := DEFAULT_PROFILE
var _profile: Dictionary = PROFILES[DEFAULT_PROFILE].duplicate(true)
var _time := 0.0
var _effect_enabled := true


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	set_process(true)


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
	queue_redraw()


func get_water_profile() -> String:
	return _profile_id


func set_water_rect(rect: Rect2) -> void:
	position = rect.position
	size = rect.size
	custom_minimum_size = Vector2.ZERO
	visible = _effect_enabled and rect.size.x > 1.0 and rect.size.y > 1.0
	queue_redraw()


func _process(delta: float) -> void:
	if not visible or not _effect_enabled:
		return

	_time += delta
	queue_redraw()


func _draw() -> void:
	if not _effect_enabled or size.x <= 1.0 or size.y <= 1.0:
		return

	var intensity := float(_profile.get("intensity", 0.25))
	var tint: Color = _profile.get("color_tint", Color(0.70, 0.92, 0.86, 1.0))
	draw_rect(Rect2(Vector2.ZERO, size), Color(tint.r, tint.g, tint.b, 0.010 * intensity), true)
	_draw_wave_lines(tint, intensity)
	_draw_ripples(tint, intensity)
	_draw_highlights(tint, intensity)


func _draw_wave_lines(tint: Color, intensity: float) -> void:
	var wave_count := int(_profile.get("wave_count", 4))
	var wave_speed := float(_profile.get("wave_speed", 0.2))
	var wave_alpha := float(_profile.get("wave_alpha", 0.04))
	var movement_scale := float(_profile.get("movement_scale", 0.7))
	var line_width := clampf(0.65 + intensity * 1.2, 0.65, 1.2)
	var step := maxf(size.x / 44.0, 16.0)

	for i in range(wave_count):
		var progress := (float(i) + 0.5) / maxf(float(wave_count), 1.0)
		var y := lerpf(size.y * 0.18, size.y * 0.86, progress)
		var phase := _time * wave_speed * (0.65 + float(i) * 0.11) + float(i) * 2.17
		var amplitude := (1.5 + float(i % 3) * 0.55) * movement_scale * maxf(size.y / 220.0, 0.72)
		var points := PackedVector2Array()
		var x := 0.0
		while x <= size.x + step:
			var wave_y := y + sin(x * 0.022 + phase) * amplitude + sin(x * 0.009 - phase * 0.7) * amplitude * 0.55
			points.append(Vector2(x, wave_y))
			x += step

		var alpha := wave_alpha * intensity * (0.72 + progress * 0.36)
		draw_polyline(points, Color(tint.r, tint.g, tint.b, alpha), line_width, true)


func _draw_ripples(tint: Color, intensity: float) -> void:
	var ripple_count := int(_profile.get("ripple_count", 2))
	var ripple_alpha := float(_profile.get("ripple_alpha", 0.04))
	var wave_speed := float(_profile.get("wave_speed", 0.2))
	var movement_scale := float(_profile.get("movement_scale", 0.7))

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
		var color := Color(tint.r, tint.g, tint.b, ripple_alpha * intensity * fade)
		draw_arc(center, radius, PI * 0.10, PI * 1.18, 28, color, 0.9, true)
		draw_arc(center, radius * 0.64, PI * 1.08, PI * 1.78, 20, color * Color(1.0, 1.0, 1.0, 0.72), 0.75, true)


func _draw_highlights(tint: Color, intensity: float) -> void:
	var highlight_alpha := float(_profile.get("highlight_alpha", 0.03))
	if highlight_alpha <= 0.0:
		return

	var movement_scale := float(_profile.get("movement_scale", 0.7))
	var highlight_count: int = maxi(1, int(ceil(float(_profile.get("wave_count", 4)) * 0.42)))

	for i in range(highlight_count):
		var seed := float(i + 1)
		var x := size.x * fposmod(0.19 * seed + _time * 0.018 * movement_scale, 1.0)
		var y := size.y * (0.20 + 0.60 * fposmod(sin(seed * 2.41) * 0.5 + 0.5, 1.0))
		var length := clampf(size.x * (0.045 + 0.012 * sin(seed)), 18.0, 58.0)
		var alpha := highlight_alpha * intensity * (0.55 + 0.45 * sin(_time * 0.7 + seed))
		var color := Color(1.0, 0.96, 0.78, maxf(alpha, 0.0))
		draw_line(Vector2(x, y), Vector2(minf(x + length, size.x), y + sin(_time + seed) * 1.2), color, 0.85, true)
