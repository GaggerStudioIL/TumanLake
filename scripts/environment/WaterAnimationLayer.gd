extends Control

const DEFAULT_PROFILE := "calm_pier"
const DISABLED_PROFILE := "disabled"
const FALLBACK_MASK := "default_lake"
const MAX_WATER_OPACITY := 1.0
const MAX_DISTORTION_STRENGTH := 0.64
const MAX_RIPPLE_STRENGTH := 0.82
const MAX_HIGHLIGHT_STRENGTH := 0.38
const MAX_REFLECTION_STRENGTH := 0.70
const MAX_SHORE_SOFTNESS := 0.18
const MAX_WATER_TINT_STRENGTH := 1.0
const DEBUG_OUTLINE_ALPHA := 0.34
const DEBUG_LABEL_ALPHA := 0.88

const WATER_SHADER_CODE := """
shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform sampler2D alpha_mask_texture : repeat_disable, filter_linear;
uniform bool use_alpha_mask = false;
uniform float time = 0.0;
uniform float water_opacity = 0.98;
uniform float motion_speed = 0.42;
uniform float distortion_strength = 0.34;
uniform float ripple_strength = 0.58;
uniform float highlight_strength = 0.24;
uniform float reflection_strength = 0.44;
uniform float shore_softness = 0.060;
uniform float water_tint_strength = 0.50;
uniform float aspect = 1.0;
uniform vec4 far_color : source_color = vec4(0.50, 0.60, 0.49, 1.0);
uniform vec4 near_color : source_color = vec4(0.075, 0.19, 0.20, 1.0);
uniform vec4 deep_color : source_color = vec4(0.030, 0.085, 0.100, 1.0);
uniform vec4 sky_reflection_color : source_color = vec4(0.66, 0.76, 0.68, 1.0);
uniform vec4 warm_highlight_color : source_color = vec4(0.94, 0.88, 0.60, 1.0);

float hash21(vec2 p) {
	p = fract(p * vec2(127.1, 311.7));
	p += dot(p, p + 19.19);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);

	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 4; i++) {
		value += value_noise(p) * amplitude;
		p = p * 2.03 + vec2(17.11, 9.37);
		amplitude *= 0.5;
	}
	return value;
}

float water_cutout(vec2 p) {
	if (!use_alpha_mask) {
		return 1.0;
	}

	return 1.0 - texture(alpha_mask_texture, clamp(p, vec2(0.0), vec2(1.0))).a;
}

void fragment() {
	vec2 uv = UV;
	float cutout = water_cutout(uv);
	float water_mask = smoothstep(0.0, max(shore_softness, 0.001), cutout);

	vec2 shaped_uv = vec2((uv.x - 0.5) * aspect + 0.5, uv.y);
	float near_t = smoothstep(0.38, 0.98, uv.y);
	float far_t = 1.0 - near_t;
	float activity = mix(0.62, 1.34, near_t);

	vec2 flow_a = vec2(time * motion_speed * 0.060, time * motion_speed * 0.020);
	vec2 flow_b = vec2(-time * motion_speed * 0.030, time * motion_speed * 0.045);
	vec2 flow_c = vec2(time * motion_speed * 0.090, -time * motion_speed * 0.032);

	float broad_motion = fbm(vec2(shaped_uv.x * 1.12, shaped_uv.y * 1.42) + flow_a);
	float soft_current = fbm(vec2(shaped_uv.x * 2.2, shaped_uv.y * 2.8) + flow_b);
	vec2 surface_uv = shaped_uv + vec2(broad_motion - 0.5, soft_current - 0.5) * distortion_strength * 0.080 * activity;

	float noise_a = fbm(surface_uv * vec2(2.15, 3.20) + flow_a);
	float noise_b = fbm(surface_uv * vec2(7.40, 10.80) + flow_b);
	float noise_c = fbm(surface_uv * vec2(18.0, 24.0) + flow_c);
	float chop_noise = fbm(surface_uv * vec2(28.0, 36.0) + flow_c * 1.8);
	float long_reflection = fbm(vec2(surface_uv.x * 0.96, surface_uv.y * 2.75) + flow_b * 0.46);

	float wave_frequency = mix(86.0, 36.0, near_t);
	float wave_a = sin(surface_uv.y * wave_frequency + surface_uv.x * (8.0 + noise_a * 7.0) - time * motion_speed * 2.70);
	float wave_b = sin(surface_uv.y * (wave_frequency * 0.56) - surface_uv.x * (12.0 + noise_b * 4.0) - time * motion_speed * 1.65 + noise_a * 3.4);
	float wave_c = sin((surface_uv.x + surface_uv.y * 1.8) * 24.0 + noise_c * 5.5 - time * motion_speed * 1.18);
	float wave_mix = wave_a * 0.48 + wave_b * 0.31 + wave_c * 0.16;
	float broken_wave_mask = smoothstep(0.32, 0.84, fbm(surface_uv * vec2(9.5, 4.2) + flow_a * 1.2));
	float crest = smoothstep(0.46, 0.94, wave_mix * 0.5 + 0.5 + (noise_c - 0.5) * 0.30) * broken_wave_mask;

	float sample_step = max(shore_softness * 1.8, 0.006);
	float around = min(water_cutout(uv + vec2(sample_step, 0.0)), water_cutout(uv - vec2(sample_step, 0.0)));
	around = min(around, water_cutout(uv + vec2(0.0, sample_step)));
	around = min(around, water_cutout(uv - vec2(0.0, sample_step)));
	around = min(around, water_cutout(uv + vec2(sample_step * 0.72, sample_step * 0.72)));
	around = min(around, water_cutout(uv - vec2(sample_step * 0.72, sample_step * 0.72)));
	float shore_proximity = smoothstep(0.08, 0.92, water_mask * (1.0 - around));
	float shore_wave = shore_proximity * smoothstep(0.45, 0.90, sin((surface_uv.x * 38.0 + surface_uv.y * 44.0) - time * motion_speed * 3.2 + noise_b * 5.2) * 0.5 + 0.5);

	float ripple = ((noise_a - 0.5) * 0.42 + (noise_b - 0.5) * 0.26 + (chop_noise - 0.5) * 0.12 + crest * 0.34) * ripple_strength * activity;
	float reflection = smoothstep(0.30, 0.86, long_reflection + noise_a * 0.24 + crest * 0.18) * reflection_strength * (0.52 + far_t * 0.34);
	float highlight = (crest * 0.62 + smoothstep(0.66, 0.97, noise_b + noise_c * 0.24) * 0.36 + shore_wave * 0.52) * highlight_strength * activity;
	float depth_mottle = fbm(surface_uv * vec2(1.35, 2.15) + flow_a * 0.20);

	vec3 shallow = mix(far_color.rgb, near_color.rgb, smoothstep(0.24, 0.98, uv.y));
	vec3 base = mix(shallow, deep_color.rgb, smoothstep(0.55, 1.0, uv.y) * (0.28 + depth_mottle * 0.20));
	vec3 tint_target = mix(base, sky_reflection_color.rgb, 0.20 + reflection * 0.26 + far_t * 0.12);
	vec3 color = mix(base, tint_target, water_tint_strength);
	color += sky_reflection_color.rgb * reflection * 0.20;
	color += warm_highlight_color.rgb * highlight * 0.34;
	color += vec3(ripple) * 0.145;
	color += sky_reflection_color.rgb * shore_wave * 0.105;
	color = mix(color, base, far_t * 0.08);
	color = mix(color, deep_color.rgb, (1.0 - water_mask) * 0.15);

	float shore_fade = smoothstep(0.0, 0.98, water_mask);
	float alpha = water_opacity * shore_fade * (0.96 + highlight * 0.06);
	COLOR = vec4(color, clamp(alpha, 0.0, 1.0) * COLOR.a);
}
"""

const PROFILES := {
	"calm_pier": {
		"water_opacity": 0.99,
		"motion_speed": 0.44,
		"distortion_strength": 0.35,
		"ripple_strength": 0.60,
		"highlight_strength": 0.24,
		"reflection_strength": 0.45,
		"shore_softness": 0.052,
		"water_tint_strength": 0.48,
		"far_color": Color(0.52, 0.61, 0.50, 1.0),
		"near_color": Color(0.075, 0.185, 0.195, 1.0),
		"deep_color": Color(0.030, 0.080, 0.095, 1.0),
		"sky_reflection_color": Color(0.66, 0.76, 0.68, 1.0),
		"warm_highlight_color": Color(0.94, 0.88, 0.60, 1.0)
	}
}

var enabled := true:
	set(value):
		enabled = value
		_refresh_visibility()
var debug_visuals := false

var _profile_id := DEFAULT_PROFILE
var _profile: Dictionary = PROFILES[DEFAULT_PROFILE].duplicate(true)
var _surface_enabled := true
var _surface_visible := false
var _time := 0.0
var _weather_type := "clear"
var _wind_speed_mps := 0.0
var _water_polygons: Array[PackedVector2Array] = []
var _water_mask_id := FALLBACK_MASK
var _last_logged_area_key := ""
var _last_logged_profile := ""
var _surface_polygons: Array[Polygon2D] = []
var _surface_material: ShaderMaterial
var _unit_texture: ImageTexture
var _alpha_mask_texture: Texture2D
var _use_alpha_mask := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_get_surface_material()
	set_debug_visuals(BuildConfig.ENABLE_WATER_DEBUG_VISUALS)
	_apply_profile_settings()
	_refresh_visibility()
	_diagnostic_log("ready size=%s visible=%s mask=%s debug=%s" % [size, visible, _water_mask_id, _is_debug_visuals_enabled()])


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_shader_uniforms()
		queue_redraw()


func set_enabled(value: bool) -> void:
	enabled = value
	_refresh_visibility()


func set_surface_visible(value: bool) -> void:
	if _surface_visible == value:
		return

	_surface_visible = value
	_refresh_visibility()


func set_alpha_mask_texture(texture: Texture2D) -> void:
	_alpha_mask_texture = texture
	_use_alpha_mask = _alpha_mask_texture != null
	_apply_alpha_mask_shader_params()
	_refresh_visibility()


func set_debug_visuals(value: bool) -> void:
	if debug_visuals == value:
		return

	debug_visuals = value
	_diagnostic_log("debug_visuals=%s profile=%s rect=%s size=%s enabled=%s" % [debug_visuals, _profile_id, Rect2(position, size), size, enabled])
	_refresh_visibility()
	queue_redraw()


func set_water_profile(profile_id: String) -> void:
	var normalized_id := profile_id.strip_edges()
	if normalized_id == "off" or normalized_id == DISABLED_PROFILE:
		_profile_id = DISABLED_PROFILE
		_surface_enabled = false
		_refresh_visibility()
		return

	if not PROFILES.has(normalized_id):
		normalized_id = DEFAULT_PROFILE

	_profile_id = normalized_id
	_profile = PROFILES[_profile_id].duplicate(true)
	_surface_enabled = true
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
	_update_shader_uniforms()
	_diagnostic_log("environment weather=%s wind=%.2f" % [_weather_type, _wind_speed_mps])


func set_water_area(area_data) -> void:
	if area_data is Rect2:
		set_water_rect(area_data)
		set_water_polygons([_make_full_rect_polygon(size)])
		return

	if area_data is PackedVector2Array:
		set_water_polygons([area_data])
		return

	if not (area_data is Dictionary):
		_refresh_visibility()
		return

	var data := area_data as Dictionary
	var rect = data.get("rect", Rect2(position, size))
	if rect is Rect2:
		_apply_water_rect(rect)

	_water_mask_id = str(data.get("mask_id", FALLBACK_MASK))
	var polygons: Array[PackedVector2Array] = []
	var raw_polygons = data.get("polygons", [])
	if raw_polygons is Array:
		for raw_polygon in raw_polygons:
			if raw_polygon is PackedVector2Array and raw_polygon.size() >= 3:
				polygons.append(raw_polygon)
	var raw_polygon = data.get("polygon", PackedVector2Array())
	if polygons.is_empty() and raw_polygon is PackedVector2Array and raw_polygon.size() >= 3:
		polygons.append(raw_polygon)
	if polygons.is_empty():
		polygons.append(_make_full_rect_polygon(size))

	_apply_water_polygons(polygons)
	_log_area_if_changed()
	queue_redraw()


func set_water_rect(rect: Rect2) -> void:
	_apply_water_rect(rect)
	if _water_polygons.is_empty():
		_apply_water_polygons([_make_full_rect_polygon(rect.size)])
	_log_area_if_changed()
	queue_redraw()


func set_water_polygon(points: PackedVector2Array) -> void:
	set_water_polygons([points])


func set_water_polygons(polygons: Array) -> void:
	var typed_polygons: Array[PackedVector2Array] = []
	for polygon in polygons:
		if polygon is PackedVector2Array and polygon.size() >= 3:
			typed_polygons.append(polygon)
	_apply_water_polygons(typed_polygons)
	_log_area_if_changed()
	queue_redraw()


func _process(delta: float) -> void:
	if not visible or not enabled or not _surface_enabled or not _surface_visible:
		return

	_time += delta
	if _surface_material != null:
		_surface_material.set_shader_parameter("time", _time)


func _draw() -> void:
	if not _is_debug_visuals_enabled() or size.x <= 1.0 or size.y <= 1.0:
		return

	_draw_debug_water_outline()
	_draw_debug_label()


func _get_unit_texture() -> ImageTexture:
	if _unit_texture != null:
		return _unit_texture

	var image := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	_unit_texture = ImageTexture.create_from_image(image)
	return _unit_texture


func _get_surface_material() -> ShaderMaterial:
	if _surface_material != null:
		return _surface_material

	var shader := Shader.new()
	shader.code = WATER_SHADER_CODE
	_surface_material = ShaderMaterial.new()
	_surface_material.shader = shader
	_apply_alpha_mask_shader_params()
	return _surface_material


func _apply_profile_settings() -> void:
	_update_shader_uniforms()


func _update_shader_uniforms() -> void:
	if _surface_material == null:
		return

	var water_opacity := clampf(float(_profile.get("water_opacity", 0.98)), 0.0, MAX_WATER_OPACITY)
	var motion_speed := clampf(float(_profile.get("motion_speed", 0.34)) * _get_wind_motion_scale() * _get_weather_motion_scale(), 0.0, 1.10)
	var distortion_strength := clampf(float(_profile.get("distortion_strength", 0.18)), 0.0, MAX_DISTORTION_STRENGTH)
	var ripple_strength := clampf(float(_profile.get("ripple_strength", 0.15)) * _get_weather_ripple_scale() * _get_wind_ripple_scale(), 0.0, MAX_RIPPLE_STRENGTH)
	var highlight_strength := clampf(float(_profile.get("highlight_strength", 0.028)) * _get_weather_highlight_scale(), 0.0, MAX_HIGHLIGHT_STRENGTH)
	var reflection_strength := clampf(float(_profile.get("reflection_strength", 0.26)), 0.0, MAX_REFLECTION_STRENGTH)
	var shore_softness := clampf(float(_profile.get("shore_softness", 0.060)), 0.001, MAX_SHORE_SOFTNESS)
	var water_tint_strength := clampf(float(_profile.get("water_tint_strength", 0.62)), 0.0, MAX_WATER_TINT_STRENGTH)
	var far_color: Color = _profile.get("far_color", Color(0.41, 0.54, 0.46, 1.0))
	var near_color: Color = _profile.get("near_color", Color(0.10, 0.22, 0.24, 1.0))
	var deep_color: Color = _profile.get("deep_color", Color(0.040, 0.095, 0.115, 1.0))
	var sky_reflection_color: Color = _profile.get("sky_reflection_color", Color(0.58, 0.70, 0.66, 1.0))
	var warm_highlight_color: Color = _profile.get("warm_highlight_color", Color(0.90, 0.86, 0.62, 1.0))

	_surface_material.set_shader_parameter("water_opacity", water_opacity)
	_surface_material.set_shader_parameter("motion_speed", motion_speed)
	_surface_material.set_shader_parameter("distortion_strength", distortion_strength)
	_surface_material.set_shader_parameter("ripple_strength", ripple_strength)
	_surface_material.set_shader_parameter("highlight_strength", highlight_strength)
	_surface_material.set_shader_parameter("reflection_strength", reflection_strength)
	_surface_material.set_shader_parameter("shore_softness", shore_softness)
	_surface_material.set_shader_parameter("water_tint_strength", water_tint_strength)
	_surface_material.set_shader_parameter("far_color", far_color)
	_surface_material.set_shader_parameter("near_color", near_color)
	_surface_material.set_shader_parameter("deep_color", deep_color)
	_surface_material.set_shader_parameter("sky_reflection_color", sky_reflection_color)
	_surface_material.set_shader_parameter("warm_highlight_color", warm_highlight_color)
	_surface_material.set_shader_parameter("aspect", maxf(size.x / maxf(size.y, 1.0), 1.0))
	_apply_alpha_mask_shader_params()


func _apply_alpha_mask_shader_params() -> void:
	if _surface_material == null:
		return

	_surface_material.set_shader_parameter("use_alpha_mask", _use_alpha_mask)
	if _alpha_mask_texture != null:
		_surface_material.set_shader_parameter("alpha_mask_texture", _alpha_mask_texture)


func _apply_water_rect(rect: Rect2) -> void:
	position = rect.position
	size = rect.size
	custom_minimum_size = Vector2.ZERO
	_update_shader_uniforms()
	_refresh_visibility()


func _apply_water_polygons(polygons: Array[PackedVector2Array]) -> void:
	_water_polygons = polygons
	_rebuild_surface_polygons()
	_refresh_visibility()


func _rebuild_surface_polygons() -> void:
	for surface_polygon in _surface_polygons:
		if is_instance_valid(surface_polygon):
			remove_child(surface_polygon)
			surface_polygon.queue_free()
	_surface_polygons.clear()

	for index in range(_water_polygons.size()):
		var points := _water_polygons[index]
		if points.size() < 3:
			continue

		var surface_polygon := Polygon2D.new()
		surface_polygon.name = "WaterMaskPolygon%d" % (index + 1)
		surface_polygon.polygon = points
		surface_polygon.uv = _make_polygon_uv(points)
		surface_polygon.texture = _get_unit_texture()
		surface_polygon.color = Color.WHITE
		surface_polygon.material = _get_surface_material()
		surface_polygon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		surface_polygon.z_as_relative = true
		surface_polygon.z_index = 0
		add_child(surface_polygon)
		_surface_polygons.append(surface_polygon)


func _make_polygon_uv(points: PackedVector2Array) -> PackedVector2Array:
	var uvs := PackedVector2Array()
	var safe_size := Vector2(maxf(size.x, 1.0), maxf(size.y, 1.0))
	for point in points:
		uvs.append(Vector2(point.x / safe_size.x, point.y / safe_size.y))
	return uvs


func _make_full_rect_polygon(rect_size: Vector2) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2.ZERO,
		Vector2(rect_size.x, 0.0),
		rect_size,
		Vector2(0.0, rect_size.y)
	])


func _refresh_visibility() -> void:
	var has_area := size.x > 1.0 and size.y > 1.0 and not _water_polygons.is_empty()
	var can_draw_surface := enabled and _surface_enabled and _surface_visible and has_area
	var can_draw_debug := enabled and _is_debug_visuals_enabled() and has_area
	visible = can_draw_surface or can_draw_debug
	set_process(can_draw_surface)
	for surface_polygon in _surface_polygons:
		if is_instance_valid(surface_polygon):
			surface_polygon.visible = can_draw_surface
	queue_redraw()


func _draw_debug_water_outline() -> void:
	var color := Color(0.72, 1.0, 0.96, DEBUG_OUTLINE_ALPHA)
	for points in _water_polygons:
		if points.size() < 2:
			continue
		for i in range(points.size()):
			draw_line(points[i], points[(i + 1) % points.size()], color, 1.0, true)


func _draw_debug_label() -> void:
	var font := get_theme_default_font()
	if font == null:
		return

	var text := "Water: profile=%s, mask=%s, polygons=%d, rect=(%d,%d,%d,%d)" % [
		_profile_id,
		_water_mask_id,
		_water_polygons.size(),
		int(position.x),
		int(position.y),
		int(size.x),
		int(size.y)
	]
	var label_pos := Vector2(8.0, minf(18.0, maxf(size.y - 8.0, 8.0)))
	var shadow_color := Color(0.0, 0.0, 0.0, 0.46)
	var label_color := Color(0.82, 1.0, 0.94, DEBUG_LABEL_ALPHA)
	draw_string(font, label_pos + Vector2(1.0, 1.0), text, HORIZONTAL_ALIGNMENT_LEFT, maxf(size.x - 16.0, 1.0), 11, shadow_color)
	draw_string(font, label_pos, text, HORIZONTAL_ALIGNMENT_LEFT, maxf(size.x - 16.0, 1.0), 11, label_color)


func _is_debug_visuals_enabled() -> bool:
	return debug_visuals


func _get_wind_motion_scale() -> float:
	return 1.0 + clampf(_wind_speed_mps / 10.0, 0.0, 0.18)


func _get_wind_ripple_scale() -> float:
	return 1.0 + clampf(_wind_speed_mps / 12.0, 0.0, 0.12)


func _get_weather_motion_scale() -> float:
	match _weather_type:
		"storm":
			return 1.10
		"rain":
			return 1.06
		"cloudy":
			return 0.94
		_:
			return 1.0


func _get_weather_ripple_scale() -> float:
	match _weather_type:
		"storm":
			return 1.18
		"rain":
			return 1.12
		"cloudy":
			return 0.96
		_:
			return 1.0


func _get_weather_highlight_scale() -> float:
	match _weather_type:
		"storm":
			return 0.22
		"rain":
			return 0.34
		"cloudy":
			return 0.64
		_:
			return 1.0


func _normalize_weather_type(weather_type: String) -> String:
	match weather_type.strip_edges().to_lower():
		"storm", "thunderstorm", "rain_with_thunderstorms", "groza", "thunder_rain":
			return "storm"
		"rain", "rainy", "dozhd":
			return "rain"
		"cloudy", "overcast", "fog", "mist", "night_mist", "oblachno", "tuman":
			return "cloudy"
		_:
			return "clear"


func _log_profile_if_changed() -> void:
	if _last_logged_profile == _profile_id:
		return

	_last_logged_profile = _profile_id
	_diagnostic_log("profile=%s enabled=%s visible=%s mask=%s debug=%s" % [_profile_id, enabled, visible, _water_mask_id, _is_debug_visuals_enabled()])


func _log_area_if_changed() -> void:
	var key := "%s|%s|%s|%s" % [_water_mask_id, Rect2(position, size), _water_polygons.size(), visible]
	if key == _last_logged_area_key:
		return

	_last_logged_area_key = key
	_diagnostic_log("area mask=%s rect=%s polygons=%s visible=%s debug=%s" % [_water_mask_id, Rect2(position, size), _water_polygons.size(), visible, _is_debug_visuals_enabled()])


func _diagnostic_log(message: String) -> void:
	if BuildConfig.ENABLE_VERBOSE_LOGS or _is_debug_visuals_enabled():
		print("WaterAnimationLayer: %s" % message)
