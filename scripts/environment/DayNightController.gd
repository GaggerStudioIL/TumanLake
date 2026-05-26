extends Node2D

const StarsLayerScript := preload("res://scripts/environment/StarsLayer.gd")

@export var sun_size: float = 44.0
@export var show_dynamic_sun: bool = false
@export var moon_size: float = 54.0
@export var sun_arc_height: float = 0.48
@export var moon_arc_height: float = 0.34
@export var night_tint_strength: float = 0.64
@export var sunset_tint_strength: float = 0.38
@export var max_stars_alpha: float = 0.46
@export var star_count: int = 58
@export var horizon_y_ratio: float = 0.60
@export var sky_padding_ratio: float = 0.10
@export var midday_mist_alpha: float = 0.008
@export var morning_mist_alpha: float = 0.56
@export var evening_mist_alpha: float = 0.24
@export var night_mist_alpha: float = 0.16

const SKY_PATH := "res://assets/environment/lake/sky_morning_no_sun.png"
const SUN_PATH := "res://assets/environment/lake/sun.png"
const MOON_PATH := "res://assets/environment/lake/moon.png"
const MOUNTAINS_PATH := "res://assets/environment/lake/mountains_morning.png.png"
const FOREST_PATH := "res://assets/environment/lake/forest_morning.png.png"
const WATER_PATH := "res://assets/environment/lake/Water_morning.png.png"
const MIST_PATH := "res://assets/environment/lake/Mist_01.png.png"
const LIGHT_OVERLAY_PATH := "res://assets/environment/lake/Light_overlay.png.png"
const FOREGROUND_GRASS_PATH := "res://assets/environment/lake/Foreground_grass.png.png"

const MINUTES_PER_DAY := 1440.0
const DAWN_START := 300.0
const DAY_START := 480.0
const SUNSET_START := 1080.0
const NIGHT_START := 1260.0

var _time_manager: Node
var _viewport_size: Vector2 = Vector2.ZERO
var _environment_root: Node2D
var _sky_layer: TextureRect
var _celestial_layer: Node2D
var _sun_sprite: Sprite2D
var _moon_sprite: Sprite2D
var _stars_layer: Node2D
var _mountains_layer: TextureRect
var _forest_layer: TextureRect
var _water_layer: TextureRect
var _mist_layer: TextureRect
var _light_overlay_layer: TextureRect
var _night_tint_overlay: ColorRect
var _sunset_tint_overlay: ColorRect
var _foreground_grass_layer: TextureRect

func _ready() -> void:
	_ensure_nodes()
	_connect_time_manager()
	layout_environment(get_viewport_rect().size)
	update_day_night_visuals()

func _process(_delta: float) -> void:
	update_day_night_visuals()

func set_time_manager(time_manager: Node) -> void:
	_time_manager = time_manager
	_connect_time_manager()
	update_day_night_visuals()

func layout_environment(screen_size: Vector2) -> void:
	_ensure_nodes()
	_viewport_size = screen_size
	position = Vector2.ZERO

	for rect in [
		_sky_layer,
		_mountains_layer,
		_forest_layer,
		_water_layer,
		_mist_layer,
		_light_overlay_layer,
		_night_tint_overlay,
		_sunset_tint_overlay,
		_foreground_grass_layer
	]:
		if rect == null:
			continue
		rect.position = Vector2.ZERO
		rect.size = screen_size

	if _stars_layer != null and _stars_layer.has_method("set_viewport_size"):
		_stars_layer.call("set_viewport_size", screen_size)
	if _stars_layer != null and _stars_layer.has_method("set_horizon_y_ratio"):
		_stars_layer.call("set_horizon_y_ratio", horizon_y_ratio)

	update_day_night_visuals()

func update_day_night_visuals(_time_state: Dictionary = {}) -> void:
	_ensure_nodes()
	if _viewport_size == Vector2.ZERO:
		_viewport_size = get_viewport_rect().size

	var minutes: float = _get_current_game_minutes(_time_state)
	var phase: String = get_time_phase(minutes)
	update_sun_position(minutes)
	update_moon_position(minutes)
	update_stars_visibility(minutes)
	update_scene_tint(minutes, phase)

func update_sun_position(minutes: float) -> void:
	if not show_dynamic_sun:
		_sun_sprite.visible = false
		return

	var sun_t: float = clampf((minutes - DAWN_START) / maxf(NIGHT_START - DAWN_START, 1.0), 0.0, 1.0)
	var sun_arc: float = sin(sun_t * PI)
	var sun_alpha: float = _fade_between(minutes, DAWN_START, DAWN_START + 65.0) * (1.0 - _fade_between(minutes, NIGHT_START - 80.0, NIGHT_START))
	var disk_visibility: float = _sample_time_value(minutes, [
		[DAWN_START, 0.0],
		[390.0, 0.18],
		[450.0, 0.76],
		[570.0, 0.90],
		[960.0, 0.92],
		[1110.0, 0.82],
		[1170.0, 0.58],
		[NIGHT_START, 0.20],
		[MINUTES_PER_DAY, 0.0]
	])
	var sun_warmth: float = _sample_time_value(minutes, [
		[DAWN_START, 0.72],
		[390.0, 0.68],
		[570.0, 0.24],
		[720.0, 0.02],
		[960.0, 0.03],
		[1050.0, 0.10],
		[1080.0, 0.32],
		[1170.0, 0.76],
		[NIGHT_START, 0.70],
		[MINUTES_PER_DAY, 0.0]
	])
	var position: Vector2 = get_celestial_position(sun_t, sun_arc_height)
	var screen_scale: float = clampf(_viewport_size.y / 540.0, 0.82, 1.35)
	var sun_color := Color(1.04, lerpf(0.98, 0.70, sun_warmth), lerpf(0.86, 0.44, sun_warmth), 1.0)
	var material := _sun_sprite.material as ShaderMaterial
	if material != null:
		material.set_shader_parameter("light_color", sun_color)
		material.set_shader_parameter("texture_mix", lerpf(0.04, 0.12, sun_warmth))
		material.set_shader_parameter("halo_strength", lerpf(0.32, 0.24, sun_warmth))

	_sun_sprite.position = position
	_sun_sprite.scale = _get_sprite_uniform_scale(_sun_sprite, sun_size * screen_scale)
	_sun_sprite.visible = sun_alpha > 0.01
	_sun_sprite.modulate = Color(
		1.0,
		1.0,
		1.0,
		sun_alpha * disk_visibility
	)

func update_moon_position(minutes: float) -> void:
	var night_length: float = MINUTES_PER_DAY - NIGHT_START + DAWN_START
	var moon_minutes: float = minutes - NIGHT_START if minutes >= NIGHT_START else minutes + MINUTES_PER_DAY - NIGHT_START
	var moon_t: float = clampf(moon_minutes / maxf(night_length, 1.0), 0.0, 1.0)
	var moon_arc: float = sin(moon_t * PI)
	var moon_alpha: float = _fade_between(moon_minutes, 0.0, 75.0) * (1.0 - _fade_between(moon_minutes, night_length - 75.0, night_length))
	var position: Vector2 = get_celestial_position(moon_t, moon_arc_height, true)
	var screen_scale: float = clampf(_viewport_size.y / 540.0, 0.82, 1.35)

	_moon_sprite.position = position
	_moon_sprite.scale = _get_sprite_uniform_scale(_moon_sprite, moon_size * screen_scale)
	_moon_sprite.visible = moon_alpha > 0.01
	_moon_sprite.modulate = Color(0.80, 0.90, 1.0, moon_alpha * 0.92)

func update_stars_visibility(minutes: float) -> void:
	var stars_alpha: float = _sample_time_value(minutes, [
		[0.0, 0.82],
		[DAWN_START, 0.70],
		[DAWN_START + 75.0, 0.0],
		[SUNSET_START + 40.0, 0.0],
		[NIGHT_START, 0.45],
		[NIGHT_START + 120.0, 0.92],
		[MINUTES_PER_DAY, 0.82]
	]) * max_stars_alpha

	if _stars_layer != null and _stars_layer.has_method("set_star_alpha"):
		_stars_layer.call("set_star_alpha", stars_alpha)

func update_scene_tint(minutes: float, _phase: String = "") -> void:
	var night_strength: float = _sample_time_value(minutes, [
		[0.0, 0.62],
		[DAWN_START, 0.55],
		[DAWN_START + 85.0, 0.18],
		[DAY_START, 0.0],
		[SUNSET_START, 0.0],
		[NIGHT_START - 60.0, 0.20],
		[NIGHT_START, 0.58],
		[MINUTES_PER_DAY, 0.62]
	])
	var sunset_strength: float = _sample_time_value(minutes, [
		[0.0, 0.0],
		[DAWN_START, 0.12],
		[DAWN_START + 90.0, 0.32],
		[DAY_START + 60.0, 0.0],
		[SUNSET_START - 30.0, 0.10],
		[SUNSET_START + 30.0, 0.56],
		[SUNSET_START + 90.0, 0.70],
		[SUNSET_START + 150.0, 0.34],
		[NIGHT_START, 0.10],
		[MINUTES_PER_DAY, 0.0]
	])
	var sky_modulate: Color = _sample_time_color(minutes, [
		[0.0, Color(0.36, 0.46, 0.66, 1.0)],
		[DAWN_START, Color(0.46, 0.52, 0.70, 1.0)],
		[DAWN_START + 95.0, Color(1.08, 0.88, 0.70, 1.0)],
		[DAY_START + 180.0, Color(1.02, 1.04, 1.0, 1.0)],
		[990.0, Color(1.02, 1.04, 1.0, 1.0)],
		[SUNSET_START, Color(1.03, 1.00, 0.94, 1.0)],
		[SUNSET_START + 110.0, Color(1.08, 0.72, 0.52, 1.0)],
		[NIGHT_START, Color(0.34, 0.42, 0.64, 1.0)],
		[MINUTES_PER_DAY, Color(0.36, 0.46, 0.66, 1.0)]
	])
	var land_modulate: Color = _sample_time_color(minutes, [
		[0.0, Color(0.38, 0.48, 0.62, 1.0)],
		[DAWN_START + 85.0, Color(0.96, 0.78, 0.62, 1.0)],
		[DAY_START + 180.0, Color(1.02, 1.02, 0.96, 1.0)],
		[990.0, Color(1.02, 1.02, 0.96, 1.0)],
		[SUNSET_START, Color(1.00, 0.94, 0.84, 1.0)],
		[SUNSET_START + 100.0, Color(1.00, 0.70, 0.52, 1.0)],
		[NIGHT_START, Color(0.34, 0.44, 0.58, 1.0)],
		[MINUTES_PER_DAY, Color(0.38, 0.48, 0.62, 1.0)]
	])
	var water_modulate: Color = _sample_time_color(minutes, [
		[0.0, Color(0.34, 0.50, 0.68, 1.0)],
		[DAWN_START + 85.0, Color(0.92, 0.78, 0.64, 1.0)],
		[DAY_START + 160.0, Color(0.98, 1.06, 1.02, 1.0)],
		[990.0, Color(0.98, 1.06, 1.02, 1.0)],
		[SUNSET_START, Color(0.96, 0.98, 0.92, 1.0)],
		[SUNSET_START + 105.0, Color(0.92, 0.66, 0.52, 1.0)],
		[NIGHT_START, Color(0.30, 0.48, 0.64, 1.0)],
		[MINUTES_PER_DAY, Color(0.34, 0.50, 0.68, 1.0)]
	])
	var mist_alpha: float = _sample_time_value(minutes, [
		[0.0, night_mist_alpha],
		[240.0, morning_mist_alpha * 0.82],
		[300.0, morning_mist_alpha],
		[390.0, morning_mist_alpha * 0.72],
		[510.0, 0.12],
		[600.0, 0.035],
		[720.0, midday_mist_alpha],
		[990.0, midday_mist_alpha],
		[1050.0, 0.035],
		[1110.0, 0.10],
		[1230.0, evening_mist_alpha],
		[NIGHT_START, night_mist_alpha],
		[MINUTES_PER_DAY, night_mist_alpha]
	])
	var light_alpha: float = _sample_time_value(minutes, [
		[0.0, 0.0],
		[DAWN_START + 60.0, 0.34],
		[DAY_START + 180.0, 0.18],
		[960.0, 0.13],
		[SUNSET_START - 30.0, 0.18],
		[SUNSET_START + 90.0, 0.54],
		[SUNSET_START + 160.0, 0.34],
		[NIGHT_START, 0.08],
		[MINUTES_PER_DAY, 0.0]
	])

	_sky_layer.modulate = sky_modulate
	_mountains_layer.modulate = land_modulate
	_forest_layer.modulate = land_modulate.lerp(Color(0.78, 0.92, 0.92, 1.0), 0.06)
	_water_layer.modulate = water_modulate
	_apply_mist_alpha(mist_alpha)
	var light_warmth: float = clampf(sunset_strength, 0.0, 1.0)
	_light_overlay_layer.modulate = Color(1.0, lerpf(0.96, 0.82, light_warmth), lerpf(0.82, 0.58, light_warmth), light_alpha)
	_foreground_grass_layer.modulate = land_modulate.lerp(Color(0.28, 0.40, 0.52, 1.0), night_strength * 0.18)
	_apply_sunset_tint(sunset_strength)
	_apply_night_tint(night_strength)

func _apply_sunset_tint(sunset_strength: float) -> void:
	var strength: float = clampf(sunset_strength * sunset_tint_strength, 0.0, 1.0)
	var material := _sunset_tint_overlay.material as ShaderMaterial
	if material != null:
		material.set_shader_parameter("tint_color", Color(1.0, 0.46, 0.16, 1.0))
		material.set_shader_parameter("strength", strength)
		material.set_shader_parameter("horizon_y", horizon_y_ratio)
		_sunset_tint_overlay.color = Color.WHITE
		return

	_sunset_tint_overlay.color = Color(1.0, 0.46, 0.16, strength * 0.42)

func _apply_night_tint(night_strength: float) -> void:
	var strength: float = clampf(night_strength * night_tint_strength, 0.0, 1.0)
	var material := _night_tint_overlay.material as ShaderMaterial
	if material != null:
		material.set_shader_parameter("tint_color", Color(0.02, 0.05, 0.13, 1.0))
		material.set_shader_parameter("strength", strength)
		material.set_shader_parameter("horizon_y", horizon_y_ratio)
		material.set_shader_parameter("water_relief", 0.86)
		_night_tint_overlay.color = Color.WHITE
		return

	_night_tint_overlay.color = Color(0.02, 0.05, 0.13, strength * 0.88)

func _apply_mist_alpha(mist_alpha: float) -> void:
	var alpha: float = clampf(mist_alpha, 0.0, 1.0)
	var material := _mist_layer.material as ShaderMaterial
	if material != null:
		material.set_shader_parameter("alpha_factor", alpha)
		material.set_shader_parameter("horizon_y", horizon_y_ratio)
		var center_water_clear: float = lerpf(0.98, 0.74, clampf(alpha / maxf(morning_mist_alpha, 0.01), 0.0, 1.0))
		material.set_shader_parameter("center_water_clear", center_water_clear)
		_mist_layer.modulate = Color.WHITE
		return

	_mist_layer.modulate = Color(0.86, 0.95, 1.0, alpha)

func get_time_phase(minutes: float = -1.0) -> String:
	var current_minutes: float = _get_current_game_minutes() if minutes < 0.0 else fposmod(minutes, MINUTES_PER_DAY)
	if current_minutes >= DAWN_START and current_minutes < DAY_START:
		return "dawn"
	if current_minutes >= DAY_START and current_minutes < SUNSET_START:
		return "day"
	if current_minutes >= SUNSET_START and current_minutes < NIGHT_START:
		return "sunset"
	return "night"

func get_celestial_position(phase_t: float, arc_height: float, moon: bool = false) -> Vector2:
	if _viewport_size == Vector2.ZERO:
		_viewport_size = get_viewport_rect().size

	var safe_t: float = clampf(phase_t, 0.0, 1.0)
	var padding_x: float = _viewport_size.x * sky_padding_ratio
	var horizon_y: float = _viewport_size.y * horizon_y_ratio
	var x: float = lerpf(padding_x, _viewport_size.x - padding_x, safe_t)
	var arc: float = sin(safe_t * PI)
	var y: float = horizon_y - arc * _viewport_size.y * arc_height
	if moon:
		y -= _viewport_size.y * 0.035
	return Vector2(x, y)

func _ensure_nodes() -> void:
	if _environment_root == null:
		_environment_root = Node2D.new()
		_environment_root.name = "EnvironmentRoot"
		add_child(_environment_root)

	_sky_layer = _ensure_texture_layer(_sky_layer, "SkyLayer", SKY_PATH, 0)

	if _celestial_layer == null:
		_celestial_layer = Node2D.new()
		_celestial_layer.name = "CelestialLayer"
		_celestial_layer.z_index = 1
		_environment_root.add_child(_celestial_layer)

	if _stars_layer == null:
		_stars_layer = StarsLayerScript.new()
		_stars_layer.name = "StarsLayer"
		_stars_layer.z_index = 0
		_stars_layer.set("star_count", star_count)
		_stars_layer.set("max_alpha", 1.0)
		_celestial_layer.add_child(_stars_layer)

	if _sun_sprite == null:
		_sun_sprite = _ensure_sprite("SunSprite", SUN_PATH, 1)
		_sun_sprite.material = _make_sun_disc_material()

	if _moon_sprite == null:
		_moon_sprite = _ensure_sprite("MoonSprite", MOON_PATH, 2)

	_mountains_layer = _ensure_texture_layer(_mountains_layer, "MountainsLayer", MOUNTAINS_PATH, 2)
	_forest_layer = _ensure_texture_layer(_forest_layer, "ForestLayer", FOREST_PATH, 3)
	_water_layer = _ensure_texture_layer(_water_layer, "WaterLayer", WATER_PATH, 4)
	_mist_layer = _ensure_texture_layer(_mist_layer, "MistLayer", MIST_PATH, 5)
	_light_overlay_layer = _ensure_texture_layer(_light_overlay_layer, "LightOverlayLayer", LIGHT_OVERLAY_PATH, 6)
	_sunset_tint_overlay = _ensure_color_layer(_sunset_tint_overlay, "SunsetTintOverlay", 7)
	_foreground_grass_layer = _ensure_texture_layer(_foreground_grass_layer, "ForegroundGrassLayer", FOREGROUND_GRASS_PATH, 8)
	_night_tint_overlay = _ensure_color_layer(_night_tint_overlay, "NightTintOverlay", 9)
	if _mist_layer.material == null:
		_mist_layer.material = _make_mist_material()
	if _sunset_tint_overlay.material == null:
		_sunset_tint_overlay.material = _make_sunset_tint_material()
	if _night_tint_overlay.material == null:
		_night_tint_overlay.material = _make_night_tint_material()

func _ensure_texture_layer(layer: TextureRect, layer_name: String, path: String, z: int) -> TextureRect:
	if layer == null:
		layer = TextureRect.new()
		layer.name = layer_name
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.z_as_relative = true
		layer.z_index = z
		layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_environment_root.add_child(layer)

	if layer.texture == null:
		layer.texture = _load_texture(path)

	return layer

func _ensure_color_layer(layer: ColorRect, layer_name: String, z: int) -> ColorRect:
	if layer == null:
		layer = ColorRect.new()
		layer.name = layer_name
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.z_as_relative = true
		layer.z_index = z
		layer.color = Color.TRANSPARENT
		_environment_root.add_child(layer)

	return layer

func _ensure_sprite(sprite_name: String, path: String, z: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = sprite_name
	sprite.centered = true
	sprite.z_as_relative = true
	sprite.z_index = z
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.texture = _load_texture(path)
	sprite.visible = false
	_celestial_layer.add_child(sprite)
	return sprite

func _make_sun_disc_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
		shader_type canvas_item;

		uniform vec4 light_color : source_color = vec4(1.0, 0.84, 0.50, 1.0);
		uniform float texture_mix = 0.16;
		uniform float halo_strength = 0.24;

		void fragment() {
			vec4 vertex_color = COLOR;
			vec4 tex = texture(TEXTURE, UV);
			vec2 centered = UV * 2.0 - 1.0;
			float dist = length(centered);
			float soft_disk = 1.0 - smoothstep(0.52, 0.92, dist);
			float soft_halo = 1.0 - smoothstep(0.20, 1.08, dist);
			vec3 color = mix(light_color.rgb, tex.rgb, texture_mix);
			float alpha = tex.a * vertex_color.a * (soft_disk * 0.74 + soft_halo * halo_strength);
			COLOR = vec4(color * vertex_color.rgb, alpha * light_color.a);
		}
	"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _make_mist_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
		shader_type canvas_item;

		uniform float alpha_factor = 0.18;
		uniform float horizon_y = 0.60;
		uniform float center_water_clear = 0.72;

		void fragment() {
			vec4 tex = texture(TEXTURE, UV);
			float center_clear = 1.0 - smoothstep(0.0, 0.42, abs(UV.x - 0.52));
			float water_contact = smoothstep(horizon_y - 0.05, horizon_y + 0.18, UV.y);
			water_contact *= 1.0 - smoothstep(horizon_y + 0.16, 0.98, UV.y);
			float lower_softening = smoothstep(horizon_y + 0.04, 1.0, UV.y) * 0.14;
			float contact_relief = 1.0 - center_clear * water_contact * center_water_clear - lower_softening;
			vec3 mist_color = tex.rgb * vec3(0.92, 0.98, 1.0);
			float alpha = tex.a * alpha_factor * clamp(contact_relief, 0.04, 1.0);
			COLOR = vec4(mist_color, alpha);
		}
	"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _make_sunset_tint_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
		shader_type canvas_item;

		uniform vec4 tint_color : source_color = vec4(1.0, 0.46, 0.16, 1.0);
		uniform float strength = 0.0;
		uniform float horizon_y = 0.60;

		void fragment() {
			float horizon_band = 1.0 - smoothstep(0.0, 0.21, abs(UV.y - horizon_y));
			float lower_glow = smoothstep(horizon_y - 0.04, horizon_y + 0.20, UV.y);
			lower_glow *= 1.0 - smoothstep(horizon_y + 0.22, 1.0, UV.y);
			float sky_warmth = (1.0 - smoothstep(0.0, horizon_y + 0.08, UV.y)) * 0.18;
			float alpha = clamp((horizon_band * 0.82 + lower_glow * 0.36 + sky_warmth) * strength, 0.0, 0.45);
			COLOR = vec4(tint_color.rgb, alpha);
		}
	"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _make_night_tint_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
		shader_type canvas_item;

		uniform vec4 tint_color : source_color = vec4(0.02, 0.05, 0.13, 1.0);
		uniform float strength = 0.0;
		uniform float horizon_y = 0.60;
		uniform float water_relief = 0.86;

		void fragment() {
			float water_mask = smoothstep(horizon_y - 0.03, 1.0, UV.y);
			float top_weight = 1.0 - smoothstep(0.0, horizon_y * 0.72, UV.y) * 0.08;
			float relief = mix(1.0, water_relief, water_mask);
			float alpha = clamp(strength * relief * top_weight, 0.0, 0.62);
			COLOR = vec4(tint_color.rgb, alpha);
		}
	"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _connect_time_manager() -> void:
	if _time_manager == null:
		_time_manager = get_node_or_null("/root/TimeManager")
	if _time_manager == null:
		return

	var time_callable := Callable(self, "_on_time_changed")
	if _time_manager.has_signal("time_changed") and not _time_manager.is_connected("time_changed", time_callable):
		_time_manager.connect("time_changed", time_callable)

	var period_callable := Callable(self, "_on_period_changed")
	if _time_manager.has_signal("period_changed") and not _time_manager.is_connected("period_changed", period_callable):
		_time_manager.connect("period_changed", period_callable)

func _on_time_changed(time_state: Dictionary) -> void:
	update_day_night_visuals(time_state)

func _on_period_changed(_time_of_day: String) -> void:
	update_day_night_visuals()

func _get_current_game_minutes(time_state: Dictionary = {}) -> float:
	if time_state.has("current_game_minutes"):
		return fposmod(float(time_state.get("current_game_minutes", 525.0)), MINUTES_PER_DAY)
	if time_state.has("day_progress"):
		return fposmod(float(time_state.get("day_progress", 0.0)) * MINUTES_PER_DAY, MINUTES_PER_DAY)
	if _time_manager != null:
		var raw_minutes: Variant = _time_manager.get("current_game_minutes")
		if raw_minutes != null:
			return fposmod(float(raw_minutes), MINUTES_PER_DAY)
		var raw_progress: Variant = _time_manager.get("day_progress")
		if raw_progress != null:
			return fposmod(float(raw_progress) * MINUTES_PER_DAY, MINUTES_PER_DAY)
	return 525.0

func _get_sprite_uniform_scale(sprite: Sprite2D, target_size: float) -> Vector2:
	if sprite == null or sprite.texture == null:
		return Vector2.ONE
	var texture_size: Vector2 = sprite.texture.get_size()
	var max_side: float = maxf(maxf(texture_size.x, texture_size.y), 1.0)
	var scale: float = target_size / max_side
	return Vector2(scale, scale)

func _load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var texture: Resource = load(path)
		if texture is Texture2D:
			return texture

	if FileAccess.file_exists(path):
		var image: Image = Image.load_from_file(path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)

	return null

func _fade_between(value: float, from_value: float, to_value: float) -> float:
	if is_equal_approx(from_value, to_value):
		return 1.0
	var t: float = clampf((value - from_value) / (to_value - from_value), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func _sample_time_value(minutes: float, anchors: Array) -> float:
	if anchors.is_empty():
		return 0.0

	var wrapped_minutes: float = fposmod(minutes, MINUTES_PER_DAY)
	var previous: Array = anchors[0]

	for index in range(1, anchors.size()):
		var current: Array = anchors[index]
		var current_minute := float(current[0])
		if wrapped_minutes <= current_minute:
			var previous_minute := float(previous[0])
			var span: float = max(current_minute - previous_minute, 0.001)
			var t: float = _fade_between(wrapped_minutes, previous_minute, previous_minute + span)
			return lerpf(float(previous[1]), float(current[1]), t)
		previous = current

	return float(anchors[anchors.size() - 1][1])

func _sample_time_color(minutes: float, anchors: Array) -> Color:
	if anchors.is_empty():
		return Color.WHITE

	var wrapped_minutes: float = fposmod(minutes, MINUTES_PER_DAY)
	var previous: Array = anchors[0]

	for index in range(1, anchors.size()):
		var current: Array = anchors[index]
		var current_minute := float(current[0])
		if wrapped_minutes <= current_minute:
			var previous_minute := float(previous[0])
			var span: float = max(current_minute - previous_minute, 0.001)
			var t: float = _fade_between(wrapped_minutes, previous_minute, previous_minute + span)
			var previous_color: Color = previous[1]
			var current_color: Color = current[1]
			return previous_color.lerp(current_color, t)
		previous = current

	return anchors[anchors.size() - 1][1]
