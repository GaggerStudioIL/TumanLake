# Handles fishing presence visuals: water, rod, line, and float.
extends RefCounted

var main
var theme
var _rod_texture: Texture2D
const LAKE_BG_BASE_PATHS := [
	"res://assets/environment/lake_bg_base.png",
	"res://assets/environment/lake/lake_bg_base.png.png"
]
const LAKE_BG_VERTICAL_BIAS := 0.12
const ROD_TEXTURE_SIZE := Vector2i(760, 104)

enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	_ensure_environment_scene_nodes()

func open() -> void:
	pass

func close() -> void:
	pass

func refresh(delta: float = 0.0) -> void:
	_update_fishing_presence(delta)

func is_open() -> bool:
	return main != null

func _ensure_environment_scene_nodes() -> void:
	if main.environment_layer != null:
		main.environment_layer.visible = false
		for child in main.environment_layer.get_children():
			if child is CanvasItem:
				child.visible = false

	main.environment_sprites = {}
	_ensure_lake_background_rect()


func _resolve_lake_background_path() -> String:
	for path in LAKE_BG_BASE_PATHS:
		if ResourceLoader.exists(str(path)):
			return str(path)

	return ""


func _layout_environment_scene(screen_size: Vector2) -> void:
	_ensure_environment_scene_nodes()
	_hide_procedural_environment_layers()
	_layout_lake_background_rect(screen_size)


func _layout_lake_art_background(screen_size: Vector2) -> void:
	_layout_environment_scene(screen_size)


func _ensure_lake_background_rect() -> void:
	if main.lake_bg_base_rect == null:
		main.lake_bg_base_rect = TextureRect.new()
		main.lake_bg_base_rect.name = "lake_bg_base"
		main.lake_bg_base_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main.lake_bg_base_rect.z_as_relative = false
		main.lake_bg_base_rect.z_index = -100
		main.add_child(main.lake_bg_base_rect)

	var path := _resolve_lake_background_path()
	if path == "":
		push_warning("Missing lake base background PNG")
		return

	if main.lake_bg_base_rect.texture == null or main.lake_bg_base_rect.texture.resource_path != path:
		var texture = load(path)
		if texture is Texture2D:
			main.lake_bg_base_rect.texture = texture
	_ensure_lake_background_material()


func _ensure_lake_background_material() -> void:
	var material := main.lake_bg_base_rect.material as ShaderMaterial
	if material == null:
		var shader := Shader.new()
		shader.code = """
			shader_type canvas_item;
			uniform float vertical_bias = 0.12;

			void fragment() {
				vec2 uv = UV;
				uv.y = mix(vertical_bias, 1.0, uv.y);
				COLOR = texture(TEXTURE, uv);
			}
		"""
		material = ShaderMaterial.new()
		material.shader = shader
		main.lake_bg_base_rect.material = material

	material.set_shader_parameter("vertical_bias", LAKE_BG_VERTICAL_BIAS)


func _layout_lake_background_rect(screen_size: Vector2) -> void:
	if main.lake_bg_base_rect == null:
		return

	main.lake_bg_base_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	main.lake_bg_base_rect.offset_left = 0.0
	main.lake_bg_base_rect.offset_top = 0.0
	main.lake_bg_base_rect.offset_right = 0.0
	main.lake_bg_base_rect.offset_bottom = 0.0
	main.lake_bg_base_rect.z_as_relative = false
	main.lake_bg_base_rect.z_index = -100
	main.lake_bg_base_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	main.lake_bg_base_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	main.lake_bg_base_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.lake_bg_base_rect.visible = main.lake_bg_base_rect.texture != null


func _hide_procedural_environment_layers() -> void:
	for procedural_layer in [
		main.scene_gradient,
		main.sun_glow_layer,
		main.far_forest_layer,
		main.mid_forest_layer,
		main.lake_layer,
		main.reflection_layer,
		main.mist_layer,
		main.foreground_mist_layer,
		main.noise_layer,
		main.vignette_layer
	]:
		procedural_layer.visible = false

func _ensure_rod_sprite_nodes() -> void:
	if _rod_texture == null:
		_rod_texture = _create_rod_texture()

	if main.rod_shadow_sprite == null:
		main.rod_shadow_sprite = Sprite2D.new()
		main.rod_shadow_sprite.name = "RodSpriteShadow"
		main.rod_shadow_sprite.centered = false
		main.rod_shadow_sprite.z_as_relative = false
		main.rod_shadow_sprite.z_index = 18
		main.fishing_presence_layer.add_child(main.rod_shadow_sprite)

	if main.rod_sprite == null:
		main.rod_sprite = Sprite2D.new()
		main.rod_sprite.name = "RodSprite"
		main.rod_sprite.centered = false
		main.rod_sprite.z_as_relative = false
		main.rod_sprite.z_index = 21
		main.fishing_presence_layer.add_child(main.rod_sprite)

	for sprite in [main.rod_shadow_sprite, main.rod_sprite]:
		sprite.texture = _rod_texture
		sprite.centered = false
		sprite.offset = Vector2(0.0, -float(ROD_TEXTURE_SIZE.y) * 0.5)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sprite.visible = true

	main.rod_shadow_sprite.modulate = Color(0.0, 0.0, 0.0, 0.22)
	main.rod_sprite.modulate = Color(1.0, 1.0, 1.0, 0.98)


func _create_rod_texture() -> Texture2D:
	var image := Image.create(ROD_TEXTURE_SIZE.x, ROD_TEXTURE_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var center_y: float = float(ROD_TEXTURE_SIZE.y) * 0.50

	for x in range(ROD_TEXTURE_SIZE.x):
		var t: float = float(x) / float(ROD_TEXTURE_SIZE.x - 1)
		var blank_radius: float = lerp(5.6, 1.15, pow(max((t - 0.62) / 0.38, 0.0), 1.08))
		var handle_radius: float = lerp(16.0, 6.0, clamp(t / 0.62, 0.0, 1.0))
		var radius: float = handle_radius if t < 0.62 else blank_radius
		var base_color: Color = Color(0.115, 0.082, 0.050, 1.0)

		if t >= 0.62:
			base_color = Color(0.090, 0.080, 0.056, 1.0).lerp(Color(0.045, 0.058, 0.050, 1.0), clamp((t - 0.62) / 0.38, 0.0, 1.0))
		elif t < 0.18:
			base_color = Color(0.082, 0.058, 0.040, 1.0)

		for y in range(ROD_TEXTURE_SIZE.y):
			var dy: float = abs(float(y) - center_y)
			if dy > radius + 1.2:
				continue

			var edge_alpha: float = clamp(radius + 1.2 - dy, 0.0, 1.0)
			var shade: float = clamp((float(y) - (center_y - radius)) / max(radius * 2.0, 1.0), 0.0, 1.0)
			var color: Color = base_color
			color = color.lerp(Color(0.018, 0.018, 0.016, 1.0), shade * 0.48)
			var highlight: float = 1.0 - smoothstep(0.0, radius * 0.34, abs(float(y) - (center_y - radius * 0.36)))
			color = color.lerp(Color(0.62, 0.54, 0.36, 1.0), highlight * 0.18)
			color.a = edge_alpha
			image.set_pixel(x, y, color)

	for ring_t in [0.66, 0.78, 0.90]:
		_draw_rod_ring(image, int(round(float(ROD_TEXTURE_SIZE.x) * ring_t)), center_y)

	_draw_reel_on_rod_texture(image, center_y)
	return ImageTexture.create_from_image(image)


func _draw_rod_ring(image: Image, ring_x: int, center_y: float) -> void:
	for x in range(max(ring_x - 2, 0), min(ring_x + 3, ROD_TEXTURE_SIZE.x)):
		for y in range(max(int(center_y - 11.0), 0), min(int(center_y + 12.0), ROD_TEXTURE_SIZE.y)):
			var dy: float = abs(float(y) - center_y)
			if dy > 10.0:
				continue
			var alpha: float = 0.28 * (1.0 - dy / 12.0)
			image.set_pixel(x, y, Color(0.58, 0.50, 0.34, alpha))


func _draw_reel_on_rod_texture(image: Image, center_y: float) -> void:
	var reel_center: Vector2 = Vector2(float(ROD_TEXTURE_SIZE.x) * 0.28, center_y + 22.0)
	for x in range(max(int(reel_center.x - 24.0), 0), min(int(reel_center.x + 30.0), ROD_TEXTURE_SIZE.x)):
		for y in range(max(int(reel_center.y - 18.0), 0), min(int(reel_center.y + 18.0), ROD_TEXTURE_SIZE.y)):
			var p: Vector2 = Vector2(float(x), float(y))
			var ellipse: float = pow((p.x - reel_center.x) / 21.0, 2.0) + pow((p.y - reel_center.y) / 13.0, 2.0)
			if ellipse > 1.0:
				continue
			var highlight: float = 1.0 - clamp(p.distance_to(reel_center + Vector2(-6.0, -5.0)) / 19.0, 0.0, 1.0)
			var color: Color = Color(0.31, 0.36, 0.32, 0.76).lerp(Color(0.82, 0.88, 0.72, 0.88), highlight * 0.35)
			image.set_pixel(x, y, color)

	var stem_x: int = int(reel_center.x - 13.0)
	for x in range(max(stem_x - 2, 0), min(stem_x + 3, ROD_TEXTURE_SIZE.x)):
		for y in range(int(center_y + 4.0), min(int(reel_center.y), ROD_TEXTURE_SIZE.y)):
			image.set_pixel(x, y, Color(0.33, 0.32, 0.24, 0.72))

func _configure_fishing_presence_style() -> void:
	_ensure_rod_sprite_nodes()
	main.fishing_presence_layer.z_as_relative = false
	main.fishing_presence_layer.z_index = 20

	for rod_line in [
		main.rod_shadow,
		main.rod_handle_shadow,
		main.rod_handle,
		main.rod_handle_wrap_a,
		main.rod_handle_wrap_b,
		main.rod_blank,
		main.rod_near_section,
		main.rod_mid_section,
		main.rod_tip_section,
		main.rod_highlight,
		main.rod_ferrule_near,
		main.rod_ferrule_mid,
		main.rod_ferrule_tip,
		main.rod_reel_stem,
		main.rod_reel_spool,
		main.rod_reel_handle
	]:
		rod_line.joint_mode = Line2D.LINE_JOINT_ROUND
		rod_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		rod_line.end_cap_mode = Line2D.LINE_CAP_ROUND
		rod_line.visible = false

	main.rod_shadow.width = 4.8
	main.rod_shadow.default_color = Color(0.0, 0.0, 0.0, 0.14)
	main.rod_shadow.antialiased = true

	main.rod_handle_shadow.width = 7.4
	main.rod_handle_shadow.default_color = Color(0.0, 0.0, 0.0, 0.13)
	main.rod_handle_shadow.antialiased = true

	main.rod_handle.width = 6.6
	main.rod_handle.default_color = Color(0.12, 0.078, 0.047, 0.88)
	main.rod_handle.antialiased = true

	main.rod_handle_wrap_a.width = 1.3
	main.rod_handle_wrap_a.default_color = Color(0.86, 0.64, 0.34, 0.46)
	main.rod_handle_wrap_a.antialiased = true

	main.rod_handle_wrap_b.width = 1.3
	main.rod_handle_wrap_b.default_color = Color(0.86, 0.64, 0.34, 0.38)
	main.rod_handle_wrap_b.antialiased = true

	main.rod_blank.width = 2.9
	main.rod_blank.default_color = Color(0.13, 0.105, 0.065, 0.86)
	main.rod_blank.antialiased = true

	main.rod_near_section.width = 3.9
	main.rod_near_section.default_color = Color(0.29, 0.185, 0.090, 0.86)
	main.rod_near_section.antialiased = true

	main.rod_mid_section.width = 2.2
	main.rod_mid_section.default_color = Color(0.25, 0.165, 0.082, 0.82)
	main.rod_mid_section.antialiased = true

	main.rod_tip_section.width = 0.9
	main.rod_tip_section.default_color = Color(0.19, 0.130, 0.075, 0.78)
	main.rod_tip_section.antialiased = true

	main.rod_highlight.width = 0.8
	main.rod_highlight.default_color = Color(0.92, 0.78, 0.48, 0.26)
	main.rod_highlight.antialiased = true

	main.rod_ferrule_near.width = 1.3
	main.rod_ferrule_near.default_color = Color(0.92, 0.78, 0.50, 0.38)
	main.rod_ferrule_near.antialiased = true

	main.rod_ferrule_mid.width = 1.1
	main.rod_ferrule_mid.default_color = Color(0.92, 0.78, 0.50, 0.34)
	main.rod_ferrule_mid.antialiased = true

	main.rod_ferrule_tip.width = 0.8
	main.rod_ferrule_tip.default_color = Color(0.92, 0.78, 0.50, 0.30)
	main.rod_ferrule_tip.antialiased = true

	main.rod_reel_stem.width = 2.0
	main.rod_reel_stem.default_color = Color(0.17, 0.18, 0.15, 0.66)
	main.rod_reel_stem.antialiased = true

	main.rod_reel_spool.width = 1.8
	main.rod_reel_spool.default_color = Color(0.52, 0.58, 0.50, 0.54)
	main.rod_reel_spool.antialiased = true

	main.rod_reel_handle.width = 1.3
	main.rod_reel_handle.default_color = Color(0.52, 0.58, 0.50, 0.50)
	main.rod_reel_handle.antialiased = true

	main.fishing_line_glow.width = 0.9
	main.fishing_line_glow.default_color = Color(0.72, 1.0, 0.88, 0.06)
	main.fishing_line_glow.antialiased = true

	main.fishing_line.width = 0.45
	main.fishing_line.default_color = Color(0.88, 1.0, 0.96, 0.48)
	main.fishing_line.antialiased = true


func _update_rod_sprite(rod_butt: Vector2, rod_tip: Vector2, scene_scale: float, intensity: float) -> void:
	_ensure_rod_sprite_nodes()
	var direction: Vector2 = rod_tip - rod_butt
	var length: float = max(direction.length(), 1.0)
	var angle: float = direction.angle()
	var texture_width: float = float(ROD_TEXTURE_SIZE.x)
	var texture_height: float = float(ROD_TEXTURE_SIZE.y)
	var thickness_scale: float = clamp(scene_scale * (0.62 + intensity * 0.045), 0.54, 0.74)

	main.rod_sprite.position = rod_butt
	main.rod_sprite.rotation = angle
	main.rod_sprite.scale = Vector2(length / texture_width, thickness_scale)
	main.rod_sprite.offset = Vector2(0.0, -texture_height * 0.5)
	main.rod_sprite.z_index = 21
	main.rod_sprite.visible = true
	main.rod_sprite.modulate = Color(1.0, 1.0, 1.0, 0.98)

	main.rod_shadow_sprite.position = rod_butt + Vector2(2.6, 3.4) * scene_scale
	main.rod_shadow_sprite.rotation = angle
	main.rod_shadow_sprite.scale = Vector2(length / texture_width, thickness_scale * 1.10)
	main.rod_shadow_sprite.offset = Vector2(0.0, -texture_height * 0.5)
	main.rod_shadow_sprite.z_index = 18
	main.rod_shadow_sprite.visible = true
	main.rod_shadow_sprite.modulate = Color(0.0, 0.0, 0.0, 0.20)


func _get_line_normal(from: Vector2, to: Vector2, prefer_down: bool = false) -> Vector2:
	var direction = (to - from).normalized()

	if direction == Vector2.ZERO:
		direction = Vector2.LEFT

	var normal = Vector2(-direction.y, direction.x)

	if prefer_down and normal.y < 0.0:
		normal = -normal

	return normal


func _make_ellipse_points(center: Vector2, radius: Vector2, steps: int = 16) -> PackedVector2Array:
	var points = PackedVector2Array()
	var safe_steps: int = max(steps, 8)

	for index in range(safe_steps + 1):
		var angle = TAU * float(index) / float(safe_steps)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))

	return points


func _set_short_cross_line(line: Line2D, center: Vector2, direction_to_tip: Vector2, length: float) -> void:
	var normal = _get_line_normal(center, direction_to_tip)
	line.points = PackedVector2Array([
		center - normal * length,
		center + normal * length
	])


func _cubic_bezier_point(start: Vector2, control_a: Vector2, control_b: Vector2, end: Vector2, t: float) -> Vector2:
	var safe_t: float = clamp(t, 0.0, 1.0)
	var inv_t: float = 1.0 - safe_t
	return (
		start * inv_t * inv_t * inv_t
		+ control_a * 3.0 * inv_t * inv_t * safe_t
		+ control_b * 3.0 * inv_t * safe_t * safe_t
		+ end * safe_t * safe_t * safe_t
	)


func _sample_cubic_curve(
	start: Vector2,
	control_a: Vector2,
	control_b: Vector2,
	end: Vector2,
	from_t: float = 0.0,
	to_t: float = 1.0,
	steps: int = 12
) -> PackedVector2Array:
	var points = PackedVector2Array()
	var safe_steps: int = max(steps, 1)

	for index in range(safe_steps + 1):
		var local_t: float = float(index) / float(safe_steps)
		var curve_t: float = lerp(from_t, to_t, local_t)
		points.append(_cubic_bezier_point(start, control_a, control_b, end, curve_t))

	return points


func _get_presence_state() -> String:
	if main._presence_bite_timer > 0.0:
		return "bite"

	match main._fishing_ui_state:
		FishingUiState.WAITING:
			return "waiting"
		FishingUiState.FIGHTING:
			return "reeling"
		FishingUiState.CAUGHT:
			return "caught"
		_:
			return "idle"


func _get_presence_reeling_intensity() -> float:
	var tension: float = clamp(float(main._last_reeling_state.get("tension", 0.0)), 0.0, 1.0)
	var fish_force: float = clamp(float(main._last_reeling_state.get("fish_force", 0.0)) * 0.7, 0.0, 1.0)
	var struggle_power: float = clamp(float(main._last_reeling_state.get("struggle_power", 0.0)) * 0.6, 0.0, 1.0)
	var risk: float = max(
		clamp(float(main._last_reeling_state.get("break_risk", 0.0)), 0.0, 1.0),
		clamp(float(main._last_reeling_state.get("escape_risk", 0.0)), 0.0, 1.0)
	)
	return clamp(tension * 0.42 + fish_force * 0.28 + struggle_power * 0.22 + risk * 0.18, 0.0, 1.0)


func _offset_points(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var shifted = PackedVector2Array()

	for point in points:
		shifted.append(point + offset)

	return shifted


func _set_float_presence(center: Vector2, state: String, intensity: float) -> void:
	var ripple_scale = 1.0
	var glow_scale = 1.0
	var reflection_scale = 1.0
	var marker_height = 20.0
	var marker_width = 4.5
	var marker_sink = 0.0
	var marker_tilt = sin(main._presence_time * 0.9) * 1.2
	var ripple_alpha = 0.86
	var glow_alpha = 1.0
	var reflection_alpha = 0.74
	var surface_y: float = clamp(center.y, main._water_zone_top, main._water_zone_bottom)

	match state:
		"bite":
			var bite_pulse: float = abs(sin(main._presence_time * 18.0))
			ripple_scale = 1.20 + bite_pulse * 0.14
			glow_scale = 1.20
			reflection_scale = 1.12 + bite_pulse * 0.10
			marker_height = 15.0
			marker_width = 4.9
			marker_sink = 4.0 + bite_pulse * 3.0
			marker_tilt = sin(main._presence_time * 22.0) * 6.5
			ripple_alpha = 1.0
			glow_alpha = 1.18
			reflection_alpha = 1.0
		"reeling":
			ripple_scale = 1.07 + intensity * 0.22 + sin(main._presence_time * 3.5) * 0.03
			glow_scale = 1.10 + intensity * 0.18
			reflection_scale = 1.04 + intensity * 0.12
			marker_height = 19.0 - intensity * 2.5
			marker_width = 4.7
			marker_sink = intensity * 1.8 + sin(main._presence_time * 5.0) * 0.8
			marker_tilt = sin(main._presence_time * 6.4) * (2.0 + intensity * 4.0)
			ripple_alpha = 0.92 + intensity * 0.18
			glow_alpha = 1.05 + intensity * 0.18
			reflection_alpha = 0.82 + intensity * 0.14
		"caught":
			ripple_scale = 1.08
			glow_scale = 1.16
			reflection_scale = 1.08
			marker_sink = -3.0 + sin(main._presence_time * 2.0) * 1.2
			marker_tilt = sin(main._presence_time * 1.4) * 1.4
		_:
			ripple_scale = 1.0 + sin(main._presence_time * 1.25) * 0.025
			glow_scale = 1.0 + sin(main._presence_time * 1.1) * 0.035
			reflection_scale = 1.0 + sin(main._presence_time * 1.0) * 0.018

	var ripple_size = Vector2(32.0, 11.5) * ripple_scale
	main.float_ripple.size = ripple_size
	main.float_ripple.position = Vector2(center.x - ripple_size.x * 0.5, surface_y - ripple_size.y * 0.5)
	main.float_ripple.modulate = Color(1.0, 1.0, 1.0, ripple_alpha)
	main.float_ripple.visible = true

	var reflection_size = Vector2(23.0, 7.5) * reflection_scale
	main.float_reflection.size = reflection_size
	main.float_reflection.position = Vector2(center.x - reflection_size.x * 0.5, surface_y - reflection_size.y * 0.5 + 1.0)
	main.float_reflection.modulate = Color(1.0, 1.0, 1.0, reflection_alpha)

	var glow_size = Vector2(26.0, 26.0) * glow_scale
	main.float_glow.size = glow_size
	main.float_glow.position = Vector2(center.x - glow_size.x * 0.5, surface_y - glow_size.y * 0.5 - 1.0)
	main.float_glow.modulate = Color(1.0, 1.0, 1.0, glow_alpha * 0.92)

	main.float_marker.size = Vector2(marker_width, marker_height)
	main.float_marker.pivot_offset = main.float_marker.size * Vector2(0.5, 0.72)
	main.float_marker.position = Vector2(center.x - marker_width * 0.5, surface_y - marker_height * 0.58 + marker_sink)
	main.float_marker.rotation = deg_to_rad(marker_tilt)
	main.float_marker.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _update_fishing_presence(delta: float) -> void:
	if not main._presence_has_layout:
		return

	main._presence_time += delta
	main._presence_bite_timer = max(main._presence_bite_timer - delta, 0.0)
	main._presence_caught_timer = max(main._presence_caught_timer - delta, 0.0)

	var state = _get_presence_state()
	var intensity = _get_presence_reeling_intensity()

	if state == "bite":
		intensity = max(intensity, 0.9)
	elif state == "caught":
		intensity = max(intensity, 0.35 + main._presence_caught_timer * 0.15)
	elif state == "idle":
		intensity *= 0.2
	elif state == "waiting":
		intensity *= 0.35

	var screen_size = main.get_viewport_rect().size
	var scene_breath = Vector2(sin(main._presence_time * 0.34) * 1.0, sin(main._presence_time * 0.27) * 0.6)
	var mist_alpha: float = 0.92 + sin(main._presence_time * 0.28) * 0.05
	var light_alpha: float = 0.96 + sin(main._presence_time * 0.22) * 0.04
	main.foreground_mist_layer.modulate = Color(1.0, 1.0, 1.0, mist_alpha)
	main.reflection_layer.modulate = Color(1.0, 1.0, 1.0, light_alpha)
	main.sun_glow_layer.modulate = Color(1.0, 1.0, 1.0, light_alpha)

	var idle_wave = Vector2(sin(main._presence_time * 1.1) * 2.2, sin(main._presence_time * 1.55) * 2.0)
	var float_offset = idle_wave

	match state:
		"bite":
			float_offset += Vector2(sin(main._presence_time * 22.0) * 7.0, 14.0 + abs(sin(main._presence_time * 18.0)) * 9.0)
		"reeling":
			float_offset += Vector2(sin(main._presence_time * 7.7) * (2.0 + intensity * 3.5), sin(main._presence_time * 6.3) * (2.0 + intensity * 3.0))
		"caught":
			float_offset += Vector2(sin(main._presence_time * 1.8) * 1.4, -4.0 + sin(main._presence_time * 2.1) * 1.0)

	var target_float_center = main._float_base_center + float_offset + scene_breath * 0.35
	target_float_center.x = clamp(target_float_center.x, screen_size.x * 0.26, screen_size.x * 0.74)
	target_float_center.y = clamp(target_float_center.y, main._water_zone_top, main._water_zone_bottom)
	var float_follow = 7.0

	if state == "bite":
		float_follow = 13.0
	elif state == "reeling":
		float_follow = 9.0

	main._float_visual_center = main._float_visual_center.lerp(target_float_center, clamp(delta * float_follow, 0.0, 1.0))
	_set_float_presence(main._float_visual_center, state, intensity)

	var scene_scale: float = clamp(screen_size.y / 540.0, 0.86, 1.26)
	var rod_butt = main._rod_anchor_pos + scene_breath
	var rod_tip_rest = main._rod_target_pos
	var tip_pull_direction = (main._float_visual_center - rod_tip_rest).normalized()

	if tip_pull_direction == Vector2.ZERO:
		tip_pull_direction = Vector2(-0.68, 0.74)

	var rod_tip_target = rod_tip_rest

	match state:
		"bite":
			var bite_pull: float = 12.0 + abs(sin(main._presence_time * 12.0)) * 7.0
			var bite_shake: Vector2 = _get_line_normal(rod_tip_rest, main._float_visual_center) * sin(main._presence_time * 18.0) * 1.8
			rod_tip_target += tip_pull_direction * bite_pull + bite_shake
		"reeling":
			var fight_pull: float = 8.0 + intensity * 26.0
			var fight_pulse: Vector2 = tip_pull_direction * sin(main._presence_time * 4.2) * (0.7 + intensity * 1.5)
			rod_tip_target += tip_pull_direction * fight_pull + fight_pulse
		"caught":
			rod_tip_target += tip_pull_direction * 4.0 + Vector2(-3.0, -3.0 + sin(main._presence_time * 1.8) * 1.1)
		_:
			rod_tip_target += Vector2(sin(main._presence_time * 0.55) * 0.8, 3.0 + sin(main._presence_time * 0.72) * 0.7)

	var rod_tip_follow = 4.4

	if state == "bite":
		rod_tip_follow = 7.5
	elif state == "reeling":
		rod_tip_follow = 5.2

	main._rod_tip_visual = main._rod_tip_visual.lerp(rod_tip_target, clamp(delta * rod_tip_follow, 0.0, 1.0))

	var line_end = main._float_visual_center + Vector2(0.0, -14.0 * scene_scale)
	var line_pull_direction = (line_end - main._rod_tip_visual).normalized()

	if line_pull_direction == Vector2.ZERO:
		line_pull_direction = tip_pull_direction

	var rod_bend_direction = _get_line_normal(rod_butt, main._rod_tip_visual, true)

	if rod_bend_direction.dot(line_pull_direction) < 0.0:
		rod_bend_direction = -rod_bend_direction

	if state == "idle" or state == "waiting":
		rod_bend_direction = rod_bend_direction.lerp(Vector2.DOWN, 0.34).normalized()

	var bend_direction_follow = 3.8

	if state == "bite":
		bend_direction_follow = 6.0
	elif state == "reeling":
		bend_direction_follow = 4.6

	main._rod_bend_direction_visual = main._rod_bend_direction_visual.lerp(rod_bend_direction, clamp(delta * bend_direction_follow, 0.0, 1.0))

	if main._rod_bend_direction_visual == Vector2.ZERO:
		main._rod_bend_direction_visual = rod_bend_direction
	else:
		main._rod_bend_direction_visual = main._rod_bend_direction_visual.normalized()

	var tension: float = clamp(float(main._last_reeling_state.get("tension", 0.0)), 0.0, 1.0)
	var target_bend_amount = 2.2

	match state:
		"bite":
			target_bend_amount = 5.0 + abs(sin(main._presence_time * 8.0)) * 1.6
		"reeling":
			var load: float = clamp(tension * 0.62 + intensity * 0.34, 0.0, 1.0)
			target_bend_amount = lerp(2.8, 13.0, load)
		"caught":
			target_bend_amount = 2.6
		_:
			target_bend_amount = 1.9

	target_bend_amount = clamp(target_bend_amount, 1.0, 14.0)

	var bend_amount_follow = 2.8

	if state == "bite":
		bend_amount_follow = 5.0
	elif state == "reeling":
		bend_amount_follow = 3.6

	main._rod_bend_amount_visual = lerp(main._rod_bend_amount_visual, target_bend_amount, clamp(delta * bend_amount_follow, 0.0, 1.0))

	var rod_highlight_direction = -main._rod_bend_direction_visual
	var bend_amount = main._rod_bend_amount_visual
	var cast_direction = (main._rod_tip_visual - rod_butt).normalized()
	var rod_lift = Vector2(-cast_direction.y, cast_direction.x)
	if rod_lift.y > 0.0:
		rod_lift = -rod_lift
	var rod_control_near = rod_butt.lerp(main._rod_tip_visual, 0.26) + rod_lift * (10.0 * scene_scale) + main._rod_bend_direction_visual * (bend_amount * 0.06)
	var rod_control_tip = rod_butt.lerp(main._rod_tip_visual, 0.78) + rod_lift * (5.0 * scene_scale) + main._rod_bend_direction_visual * (bend_amount * 0.42)
	var rod_points = _sample_cubic_curve(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.0, 1.0, 14)
	_update_rod_sprite(rod_butt, main._rod_tip_visual, scene_scale, intensity)
	main.rod_shadow.points = _offset_points(rod_points, main._rod_bend_direction_visual * 1.8 + Vector2(0.8, 0.8))
	main.rod_blank.points = rod_points
	main.rod_near_section.points = _sample_cubic_curve(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.0, 0.52, 6)
	main.rod_mid_section.points = _sample_cubic_curve(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.48, 0.80, 5)
	main.rod_tip_section.points = _sample_cubic_curve(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.76, 1.0, 5)
	main.rod_highlight.points = _offset_points(rod_points, rod_highlight_direction * 0.9 + Vector2(-0.2, -0.2))
	main.rod_blank.width = 2.8 + intensity * 0.18
	main.rod_near_section.width = 3.9 + intensity * 0.18
	main.rod_mid_section.width = 2.2 + intensity * 0.10
	main.rod_tip_section.width = 0.9 + intensity * 0.06

	var rod_ring_near = _cubic_bezier_point(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.32)
	var rod_ring_mid = _cubic_bezier_point(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.60)
	var rod_ring_tip = _cubic_bezier_point(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.84)
	_set_short_cross_line(main.rod_ferrule_near, rod_ring_near, main._rod_tip_visual, 4.2)
	_set_short_cross_line(main.rod_ferrule_mid, rod_ring_mid, main._rod_tip_visual, 3.0)
	_set_short_cross_line(main.rod_ferrule_tip, rod_ring_tip, main._rod_tip_visual, 2.0)

	var handle_end = rod_butt + Vector2(screen_size.x * 0.070, screen_size.y * 0.050)
	var handle_points = PackedVector2Array([handle_end, rod_butt])
	main.rod_handle_shadow.points = _offset_points(handle_points, Vector2(1.8, 2.4))
	main.rod_handle.points = handle_points
	_set_short_cross_line(main.rod_handle_wrap_a, handle_end.lerp(rod_butt, 0.34), rod_butt, 4.2)
	_set_short_cross_line(main.rod_handle_wrap_b, handle_end.lerp(rod_butt, 0.66), rod_butt, 3.6)

	var reel_mount = _cubic_bezier_point(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.16)
	var reel_center = reel_mount + main._rod_bend_direction_visual * ((12.0 + intensity * 1.4) * scene_scale)
	main.rod_reel_stem.points = PackedVector2Array([reel_mount, reel_center])
	main.rod_reel_spool.points = _make_ellipse_points(reel_center, Vector2(8.0, 5.0) * scene_scale, 18)
	main.rod_reel_handle.points = PackedVector2Array([
		reel_center + Vector2(5.5, -2.0) * scene_scale,
		reel_center + Vector2(14.0, -0.6) * scene_scale,
		reel_center + Vector2(16.5, 3.0) * scene_scale
	])

	var sag = 20.0

	if state == "reeling":
		sag = lerp(8.0, 1.2, intensity)
	elif state == "bite":
		sag = 2.5
	elif state == "caught":
		sag = 22.0

	var line_start = main._rod_tip_visual
	var line_mid_a = line_start.lerp(line_end, 0.34) + Vector2(
		sin(main._presence_time * 2.6) * (1.4 + intensity * 1.2),
		sag * 0.58 + sin(main._presence_time * 3.0) * (1.1 + intensity)
	)
	var line_mid_b = line_start.lerp(line_end, 0.68) + Vector2(
		sin(main._presence_time * 3.1 + 0.8) * (1.0 + intensity),
		sag + sin(main._presence_time * 3.6) * (0.9 + intensity)
	)
	var line_points = PackedVector2Array([line_start, line_mid_a, line_mid_b, line_end])
	main.fishing_line.points = line_points
	main.fishing_line_glow.points = line_points

	var line_alpha = 0.42
	var glow_alpha = 0.025
	var line_width = 0.42

	if state == "waiting":
		line_alpha = 0.48
		glow_alpha = 0.035
		line_width = 0.46
	elif state == "bite":
		line_alpha = 0.60
		glow_alpha = 0.08
		line_width = 0.58
	elif state == "reeling":
		line_alpha = 0.50 + intensity * 0.10
		glow_alpha = 0.04 + intensity * 0.06
		line_width = 0.48 + intensity * 0.08
	elif state == "caught":
		line_alpha = 0.46
		glow_alpha = 0.03
		line_width = 0.42

	main.fishing_line.width = line_width
	main.fishing_line_glow.width = line_width + 0.35
	main.fishing_line.default_color = Color(0.88, 1.0, 0.96, line_alpha)
	main.fishing_line_glow.default_color = Color(0.72, 1.0, 0.88, glow_alpha)
