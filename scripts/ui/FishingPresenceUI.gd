# Handles fishing presence visuals: water, rod, line, and float.
extends RefCounted

signal cast_visual_finished

var main
var theme
var _rod_texture: Texture2D
var _rod_uses_external_texture := false
var _float_texture: Texture2D
var _ripple_texture: Texture2D
var _drop_splash_texture: Texture2D
var _regular_splash_texture: Texture2D
var _float_sprite: Sprite2D
var _ripple_sprite: Sprite2D
var _drop_splash_sprite: Sprite2D
var _regular_splash_sprite: Sprite2D
var _bobber_ripple: Node2D
var _bobber_contact_waterline: Node2D
var _cast_timer := 0.0
var _drop_splash_timer := 0.0
var _float_nudge_timer := 0.0
var _float_nudge_duration := 0.0
var _float_nudge_strength := 0.0
var _cast_landed := false
var is_cast_animating := false
var rod_visual_state: int = 0
@export var bobber_waterline_offset: Vector2 = Vector2(0.0, 34.0)
const LAKE_BG_BASE_PATHS := [
	"res://assets/environment/lake_bg_base.png",
	"res://assets/environment/lake/lake_bg_base.png.png"
]
const LAKE_BG_VERTICAL_BIAS := 0.12
const ROD_TEXTURE_PATH := "res://assets/art/fishing/rod_first_person.png"
const FLOAT_TEXTURE_PATH := "res://assets/art/fishing/float_marker.png"
const RIPPLE_TEXTURE_PATH := "res://assets/art/fishing/water_ripple.png"
const DROP_SPLASH_TEXTURE_PATH := "res://assets/art/fishing/splash_on_drop.png"
const REGULAR_SPLASH_TEXTURE_PATH := "res://assets/art/fishing/regular_splash.png"
const BOBBER_RIPPLE_SCRIPT := preload("res://scripts/bobber_ripple.gd")
const BOBBER_CONTACT_WATERLINE_SCRIPT := preload("res://scripts/bobber_contact_waterline.gd")
const DAY_NIGHT_CONTROLLER_SCRIPT := preload("res://scripts/environment/DayNightController.gd")
const BOBBER_CONTACT_OFFSET_RATIO := 1.10
const ROD_TEXTURE_SIZE := Vector2i(760, 104)
const ROD_ASSET_TIP_RATIO := Vector2(0.294, 0.042)
const ROD_ASSET_BUTT_RATIO := Vector2(0.843, 0.990)
const FLOAT_TEXTURE_REGION := Rect2(520.0, 72.0, 220.0, 1110.0)
const RIPPLE_TEXTURE_REGION := Rect2(104.0, 386.0, 1060.0, 520.0)
const CAST_VISUAL_DURATION := 1.05
const DROP_SPLASH_DURATION := 0.32
const CAST_WINDUP_END_PROGRESS := 0.21
const CAST_FORWARD_END_PROGRESS := 0.43
const CAST_LANDING_START_PROGRESS := 0.86
const CAST_ROD_IDLE_BASE := Vector2(900.0, 520.0)
const CAST_ROD_IDLE_TIP := Vector2(555.0, 330.0)
const CAST_ROD_WINDUP_BASE := Vector2(930.0, 525.0)
const CAST_ROD_WINDUP_TIP := Vector2(720.0, 250.0)
const CAST_ROD_FORWARD_BASE := Vector2(900.0, 520.0)
const CAST_ROD_FORWARD_TIP := Vector2(510.0, 290.0)
const CAST_FLOAT_START := Vector2(835.0, 455.0)
const CAST_FLOAT_PEAK := Vector2(620.0, 210.0)
const CAST_FLOAT_TARGET := Vector2(500.0, 402.0)
const BOBBER_LINE_ATTACH_OFFSET := Vector2(0.0, -8.0)

enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

enum RodVisualState {
	UNCASTED,
	CASTING,
	FLOAT_IN_WATER,
	BITE,
	REELING,
	LANDED
}

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	rod_visual_state = RodVisualState.UNCASTED
	_ensure_environment_scene_nodes()

func open() -> void:
	pass

func close() -> void:
	pass

func refresh(delta: float = 0.0) -> void:
	_update_fishing_presence(delta)

func is_open() -> bool:
	return main != null

func start_cast_visual() -> void:
	rod_visual_state = RodVisualState.CASTING
	_cast_timer = CAST_VISUAL_DURATION
	_drop_splash_timer = 0.0
	_float_nudge_timer = 0.0
	_float_nudge_duration = 0.0
	_float_nudge_strength = 0.0
	_cast_landed = false
	is_cast_animating = true
	if _drop_splash_sprite != null:
		_drop_splash_sprite.visible = false
	if _bobber_ripple != null:
		_bobber_ripple.visible = false
	if _bobber_contact_waterline != null:
		_bobber_contact_waterline.visible = false

func stop_cast_visual() -> void:
	rod_visual_state = RodVisualState.UNCASTED
	_cast_timer = 0.0
	_drop_splash_timer = 0.0
	_float_nudge_timer = 0.0
	_float_nudge_duration = 0.0
	_float_nudge_strength = 0.0
	_cast_landed = false
	is_cast_animating = false
	if _drop_splash_sprite != null:
		_drop_splash_sprite.visible = false
	if _bobber_ripple != null:
		_bobber_ripple.visible = false
	if _bobber_contact_waterline != null:
		_bobber_contact_waterline.visible = false
	_hide_float_and_line_visuals()

func set_rod_uncasted() -> void:
	rod_visual_state = RodVisualState.UNCASTED
	reset_float_visuals()

func set_float_in_water(active: bool) -> void:
	if active:
		rod_visual_state = RodVisualState.FLOAT_IN_WATER
	else:
		set_rod_uncasted()

func set_rod_visual_state(state_name: String) -> void:
	match state_name:
		"casting":
			rod_visual_state = RodVisualState.CASTING
		"float_in_water", "waiting":
			rod_visual_state = RodVisualState.FLOAT_IN_WATER
		"bite":
			rod_visual_state = RodVisualState.BITE
		"reeling":
			rod_visual_state = RodVisualState.REELING
		"landed":
			rod_visual_state = RodVisualState.LANDED
			reset_float_visuals()
		_:
			set_rod_uncasted()

func reset_float_visuals() -> void:
	_cast_timer = 0.0
	_drop_splash_timer = 0.0
	_float_nudge_timer = 0.0
	_float_nudge_duration = 0.0
	_float_nudge_strength = 0.0
	_cast_landed = false
	is_cast_animating = false
	if main != null:
		main._presence_bite_timer = 0.0
		main._presence_caught_timer = 0.0
	_hide_float_and_line_visuals()

func reset_after_landing() -> void:
	rod_visual_state = RodVisualState.LANDED
	reset_float_visuals()

func _hide_float_and_line_visuals() -> void:
	if main == null:
		return
	for node in [
		main.float_marker,
		main.float_glow,
		main.float_ripple,
		main.float_reflection,
		main.fishing_line,
		main.fishing_line_glow,
		_float_sprite,
		_ripple_sprite,
		_drop_splash_sprite,
		_regular_splash_sprite,
		_bobber_ripple,
		_bobber_contact_waterline
	]:
		if node != null:
			node.visible = false

func play_float_nudge(data: Dictionary) -> void:
	if rod_visual_state == RodVisualState.UNCASTED or rod_visual_state == RodVisualState.LANDED:
		return
	_float_nudge_duration = max(float(data.get("duration", 0.35)), 0.1)
	_float_nudge_timer = _float_nudge_duration
	_float_nudge_strength = clamp(float(data.get("strength", 0.25)), 0.0, 1.0)

func play_bite_signal(data: Dictionary) -> void:
	rod_visual_state = RodVisualState.BITE
	if main != null:
		main._presence_bite_timer = max(float(data.get("bite_window_seconds", 1.4)), 0.8)
	play_float_nudge({
		"strength": float(data.get("strength", 0.75)),
		"duration": min(float(data.get("bite_window_seconds", 1.4)), 0.9)
	})

func play_hook_result(success: bool, reason: String = "") -> void:
	if success:
		rod_visual_state = RodVisualState.REELING
		play_float_nudge({"strength": 0.75, "duration": 0.36})
		return

	rod_visual_state = RodVisualState.FLOAT_IN_WATER
	var strength := 0.45
	if reason == "too_early":
		strength = 0.30
	elif reason == "late_hook" or reason == "missed_bite":
		strength = 0.62
	play_float_nudge({"strength": strength, "duration": 0.44})

func _ensure_environment_scene_nodes() -> void:
	if main.environment_layer != null:
		main.environment_layer.visible = false
		for child in main.environment_layer.get_children():
			if child is CanvasItem:
				child.visible = false

	main.environment_sprites = {}
	_ensure_day_night_controller()
	if main.day_night_controller == null:
		_ensure_lake_background_rect()
	elif main.lake_bg_base_rect != null:
		main.lake_bg_base_rect.visible = false


func _resolve_lake_background_path() -> String:
	for path in LAKE_BG_BASE_PATHS:
		if ResourceLoader.exists(str(path)):
			return str(path)

	return ""


func _layout_environment_scene(screen_size: Vector2) -> void:
	_ensure_environment_scene_nodes()
	_hide_procedural_environment_layers()
	if main.day_night_controller != null and main.day_night_controller.has_method("layout_environment"):
		main.day_night_controller.call("layout_environment", screen_size)
	else:
		_layout_lake_background_rect(screen_size)


func _layout_lake_art_background(screen_size: Vector2) -> void:
	_layout_environment_scene(screen_size)


func _ensure_day_night_controller() -> void:
	if main.day_night_controller != null:
		main.day_night_controller.visible = true
		return

	var controller := DAY_NIGHT_CONTROLLER_SCRIPT.new() as Node2D
	if controller == null:
		return

	controller.name = "DayNightController"
	controller.z_as_relative = false
	controller.z_index = -110
	main.add_child(controller)
	main.day_night_controller = controller

	if controller.has_method("set_time_manager"):
		controller.call("set_time_manager", main._get_time_manager())


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
		_rod_texture = _load_rod_texture()

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
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sprite.visible = true

	main.rod_shadow_sprite.modulate = Color(0.0, 0.0, 0.0, 0.22)
	main.rod_sprite.modulate = Color(1.0, 1.0, 1.0, 0.98)


func _ensure_float_sprite_nodes() -> void:
	if _float_texture == null:
		_float_texture = _load_texture_resource(FLOAT_TEXTURE_PATH)

	if _ripple_texture == null:
		_ripple_texture = _load_texture_resource(RIPPLE_TEXTURE_PATH)

	if _drop_splash_texture == null:
		_drop_splash_texture = _load_texture_resource(DROP_SPLASH_TEXTURE_PATH)

	if _regular_splash_texture == null:
		_regular_splash_texture = _load_texture_resource(REGULAR_SPLASH_TEXTURE_PATH)

	if _ripple_texture != null and _ripple_sprite == null:
		_ripple_sprite = Sprite2D.new()
		_ripple_sprite.name = "GameplayRippleSprite"
		_ripple_sprite.centered = true
		_ripple_sprite.region_enabled = true
		_ripple_sprite.region_rect = RIPPLE_TEXTURE_REGION
		_ripple_sprite.z_as_relative = false
		_ripple_sprite.z_index = 23
		_ripple_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		main.fishing_presence_layer.add_child(_ripple_sprite)

	if _float_texture != null and _float_sprite == null:
		_float_sprite = Sprite2D.new()
		_float_sprite.name = "GameplayFloatSprite"
		_float_sprite.centered = true
		_float_sprite.region_enabled = true
		_float_sprite.region_rect = FLOAT_TEXTURE_REGION
		_float_sprite.z_as_relative = false
		_float_sprite.z_index = 25
		_float_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		main.fishing_presence_layer.add_child(_float_sprite)

	if _regular_splash_texture != null and _regular_splash_sprite == null:
		_regular_splash_sprite = Sprite2D.new()
		_regular_splash_sprite.name = "RegularSplashSprite"
		_regular_splash_sprite.centered = true
		_regular_splash_sprite.z_as_relative = false
		_regular_splash_sprite.z_index = 24
		_regular_splash_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		main.fishing_presence_layer.add_child(_regular_splash_sprite)

	if _drop_splash_texture != null and _drop_splash_sprite == null:
		_drop_splash_sprite = Sprite2D.new()
		_drop_splash_sprite.name = "DropSplashSprite"
		_drop_splash_sprite.centered = true
		_drop_splash_sprite.z_as_relative = false
		_drop_splash_sprite.z_index = 28
		_drop_splash_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		main.fishing_presence_layer.add_child(_drop_splash_sprite)

	_ensure_bobber_ripple_node()

	if _ripple_sprite != null:
		_ripple_sprite.texture = _ripple_texture
		_ripple_sprite.region_rect = RIPPLE_TEXTURE_REGION

	if _float_sprite != null:
		_float_sprite.texture = _float_texture
		_float_sprite.region_rect = FLOAT_TEXTURE_REGION

	if _regular_splash_sprite != null:
		_regular_splash_sprite.texture = _regular_splash_texture

	if _drop_splash_sprite != null:
		_drop_splash_sprite.texture = _drop_splash_texture

	_ensure_bobber_contact_waterline_node()


func _ensure_bobber_ripple_node() -> void:
	if _bobber_ripple != null:
		return

	var ripple := BOBBER_RIPPLE_SCRIPT.new() as Node2D
	if ripple == null:
		return

	_bobber_ripple = ripple
	_bobber_ripple.name = "BobberRipple"
	_bobber_ripple.z_as_relative = false
	_bobber_ripple.z_index = 24
	_bobber_ripple.visible = false
	main.fishing_presence_layer.add_child(_bobber_ripple)


func _ensure_bobber_contact_waterline_node() -> void:
	if _bobber_contact_waterline != null:
		return

	var contact_waterline := BOBBER_CONTACT_WATERLINE_SCRIPT.new() as Node2D
	if contact_waterline == null:
		return

	_bobber_contact_waterline = contact_waterline
	_bobber_contact_waterline.name = "BobberContactWaterline"
	_bobber_contact_waterline.z_as_relative = false
	_bobber_contact_waterline.z_index = 26
	_bobber_contact_waterline.visible = false
	main.fishing_presence_layer.add_child(_bobber_contact_waterline)


func _load_rod_texture() -> Texture2D:
	var texture := _load_texture_resource(ROD_TEXTURE_PATH)
	if texture != null:
		_rod_uses_external_texture = true
		return texture

	_rod_uses_external_texture = false
	return _create_rod_texture()


func _load_texture_resource(path: String) -> Texture2D:
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		return null

	if ResourceLoader.exists(path):
		var texture := load(path)
		if texture is Texture2D:
			return texture

	var image := Image.load_from_file(path)
	if image != null and not image.is_empty():
		return ImageTexture.create_from_image(image)

	return null


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
	_ensure_float_sprite_nodes()
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

	main.fishing_line_glow.width = 0.55
	main.fishing_line_glow.default_color = Color(0.66, 0.82, 0.78, 0.025)
	main.fishing_line_glow.antialiased = true
	main.fishing_line_glow.z_as_relative = false
	main.fishing_line_glow.z_index = 26

	main.fishing_line.width = 0.32
	main.fishing_line.default_color = Color(0.76, 0.86, 0.82, 0.34)
	main.fishing_line.antialiased = true
	main.fishing_line.z_as_relative = false
	main.fishing_line.z_index = 27


func _update_rod_sprite(rod_butt: Vector2, rod_tip: Vector2, scene_scale: float, intensity: float) -> void:
	_ensure_rod_sprite_nodes()
	if _rod_uses_external_texture:
		_update_external_rod_sprite(rod_butt, rod_tip, scene_scale, intensity)
		return

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


func _update_external_rod_sprite(rod_butt: Vector2, rod_tip: Vector2, scene_scale: float, intensity: float) -> void:
	var texture_size: Vector2 = _rod_texture.get_size()
	var asset_butt: Vector2 = Vector2(texture_size.x * ROD_ASSET_BUTT_RATIO.x, texture_size.y * ROD_ASSET_BUTT_RATIO.y)
	var asset_tip: Vector2 = Vector2(texture_size.x * ROD_ASSET_TIP_RATIO.x, texture_size.y * ROD_ASSET_TIP_RATIO.y)
	var asset_direction: Vector2 = asset_tip - asset_butt
	var target_direction: Vector2 = rod_tip - rod_butt
	var asset_length: float = max(asset_direction.length(), 1.0)
	var target_length: float = max(target_direction.length(), 1.0)
	var sprite_scale: float = (target_length / asset_length) * 1.01
	var sprite_rotation: float = target_direction.angle() - asset_direction.angle()

	main.rod_sprite.position = rod_butt
	main.rod_sprite.rotation = sprite_rotation
	main.rod_sprite.scale = Vector2(sprite_scale, sprite_scale)
	main.rod_sprite.offset = -asset_butt
	main.rod_sprite.z_index = 21
	main.rod_sprite.visible = true
	main.rod_sprite.modulate = Color(1.0, 1.0, 1.0, 0.98)

	main.rod_shadow_sprite.position = rod_butt + Vector2(2.8, 3.8) * scene_scale
	main.rod_shadow_sprite.rotation = sprite_rotation
	main.rod_shadow_sprite.scale = Vector2(sprite_scale * 1.012, sprite_scale * 1.012)
	main.rod_shadow_sprite.offset = -asset_butt
	main.rod_shadow_sprite.z_index = 18
	main.rod_shadow_sprite.visible = true
	main.rod_shadow_sprite.modulate = Color(0.0, 0.0, 0.0, 0.24 + intensity * 0.04)


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

func _bezier2(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	var safe_t: float = clamp(t, 0.0, 1.0)
	return a.lerp(b, safe_t).lerp(b.lerp(c, safe_t), safe_t)

func _scale_cast_point(point: Vector2) -> Vector2:
	var screen_size: Vector2 = main.get_viewport_rect().size
	return Vector2(
		point.x * screen_size.x / 960.0,
		point.y * screen_size.y / 540.0
	)

func _ease_in_cubic(value: float) -> float:
	var t: float = clamp(value, 0.0, 1.0)
	return t * t * t

func _ease_out_back(value: float) -> float:
	var t: float = clamp(value, 0.0, 1.0) - 1.0
	var c1 := 1.70158
	var c3 := c1 + 1.0
	return 1.0 + c3 * t * t * t + c1 * t * t


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
	if _cast_timer > 0.0:
		return "casting"

	if rod_visual_state == RodVisualState.UNCASTED or rod_visual_state == RodVisualState.LANDED:
		return "uncasted"
	if rod_visual_state == RodVisualState.CASTING:
		return "casting"
	if rod_visual_state == RodVisualState.BITE:
		return "bite"
	if rod_visual_state == RodVisualState.REELING:
		return "reeling"

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


func _get_cast_progress() -> float:
	if _cast_timer <= 0.0:
		return 1.0

	return clamp(1.0 - _cast_timer / CAST_VISUAL_DURATION, 0.0, 1.0)


func _get_cast_sweep_offset(scene_scale: float) -> Vector2:
	return _get_cast_sweep_offset_for_progress(_get_cast_progress(), scene_scale)


func _get_cast_sweep_offset_for_progress(cast_t: float, scene_scale: float) -> Vector2:
	return Vector2.ZERO


func _smooth_unit(value: float) -> float:
	var t: float = clamp(value, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)


func _ease_out_sine(value: float) -> float:
	return sin(clamp(value, 0.0, 1.0) * PI * 0.5)


func _ease_in_out_sine(value: float) -> float:
	return 0.5 - cos(clamp(value, 0.0, 1.0) * PI) * 0.5


func _get_cast_float_center(target_center: Vector2, scene_scale: float) -> Vector2:
	var cast_t: float = _get_cast_progress()
	var float_start := _scale_cast_point(CAST_FLOAT_START)
	var float_peak := _scale_cast_point(CAST_FLOAT_PEAK)
	var float_target := _scale_cast_point(CAST_FLOAT_TARGET)

	if cast_t < CAST_FORWARD_END_PROGRESS:
		var prepare_t: float = _ease_in_out_sine(cast_t / CAST_FORWARD_END_PROGRESS)
		return float_start + Vector2(-10.0, -8.0) * scene_scale * prepare_t

	if cast_t < CAST_LANDING_START_PROGRESS:
		var flight_t: float = _ease_in_out_sine((cast_t - CAST_FORWARD_END_PROGRESS) / (CAST_LANDING_START_PROGRESS - CAST_FORWARD_END_PROGRESS))
		return _bezier2(float_start, float_peak, float_target, flight_t)

	var landing_t: float = _ease_out_back((cast_t - CAST_LANDING_START_PROGRESS) / (1.0 - CAST_LANDING_START_PROGRESS))
	return float_target + Vector2(0.0, -4.0 * scene_scale * (1.0 - clamp(landing_t, 0.0, 1.0)))

func _get_cast_float_rotation_degrees() -> float:
	var cast_t: float = _get_cast_progress()
	if cast_t < CAST_FORWARD_END_PROGRESS:
		return -8.0 * _ease_in_out_sine(cast_t / CAST_FORWARD_END_PROGRESS)
	if cast_t < CAST_LANDING_START_PROGRESS:
		var flight_t: float = _ease_in_out_sine((cast_t - CAST_FORWARD_END_PROGRESS) / (CAST_LANDING_START_PROGRESS - CAST_FORWARD_END_PROGRESS))
		return lerp(-18.0, 8.0, flight_t)
	return lerp(8.0, 0.0, _ease_out_sine((cast_t - CAST_LANDING_START_PROGRESS) / (1.0 - CAST_LANDING_START_PROGRESS)))

func _get_bobber_waterline_offset_weight(state: String) -> float:
	if state != "casting":
		return 1.0

	var landing_t: float = clamp((_get_cast_progress() - CAST_LANDING_START_PROGRESS) / (1.0 - CAST_LANDING_START_PROGRESS), 0.0, 1.0)
	return _smooth_unit(landing_t)

func _get_bobber_visual_center(center: Vector2, state: String) -> Vector2:
	return center + bobber_waterline_offset * _get_bobber_waterline_offset_weight(state)

func _get_bobber_contact_point(center: Vector2, surface_y: float, state: String, marker_sink: float = 0.0) -> Vector2:
	var offset_weight := _get_bobber_waterline_offset_weight(state)
	var bobber_center := _get_bobber_visual_center(center, state)
	var contact_y: float = surface_y + bobber_waterline_offset.y * BOBBER_CONTACT_OFFSET_RATIO * offset_weight + marker_sink * 0.32
	return Vector2(bobber_center.x, contact_y)

func _get_bobber_line_attach_point(center: Vector2, state: String, scene_scale: float) -> Vector2:
	return _get_bobber_visual_center(center, state) + BOBBER_LINE_ATTACH_OFFSET * scene_scale


func _get_cast_rod_tip_target(rest_tip: Vector2, scene_scale: float) -> Vector2:
	return _get_cast_rod_tip_for_progress(_get_cast_progress(), rest_tip, scene_scale)


func _get_cast_rod_tip_for_progress(cast_t: float, rest_tip: Vector2, scene_scale: float) -> Vector2:
	var idle_tip := _get_cast_idle_tip(scene_scale)
	var windup_tip := _get_cast_windup_tip(scene_scale)
	var forward_tip := _get_cast_forward_tip(scene_scale)
	var recoil_tip := idle_tip.lerp(forward_tip, 0.22) + Vector2(12.0, -12.0) * scene_scale

	if cast_t < CAST_WINDUP_END_PROGRESS:
		return idle_tip.lerp(windup_tip, _ease_out_sine(cast_t / CAST_WINDUP_END_PROGRESS))

	if cast_t < CAST_FORWARD_END_PROGRESS:
		return windup_tip.lerp(forward_tip, _ease_in_cubic((cast_t - CAST_WINDUP_END_PROGRESS) / (CAST_FORWARD_END_PROGRESS - CAST_WINDUP_END_PROGRESS)))

	if cast_t < CAST_LANDING_START_PROGRESS:
		var settle_t: float = _ease_in_out_sine((cast_t - CAST_FORWARD_END_PROGRESS) / (CAST_LANDING_START_PROGRESS - CAST_FORWARD_END_PROGRESS))
		return forward_tip.lerp(recoil_tip, min(settle_t * 1.55, 1.0)).lerp(idle_tip, max((settle_t - 0.45) / 0.55, 0.0) * 0.72)

	return recoil_tip.lerp(idle_tip, _ease_out_sine((cast_t - CAST_LANDING_START_PROGRESS) / (1.0 - CAST_LANDING_START_PROGRESS)))

func _get_cast_rod_base_for_progress(cast_t: float, scene_scale: float) -> Vector2:
	var idle_base := _get_cast_idle_base(scene_scale)
	var windup_base := _get_cast_windup_base(scene_scale)
	var forward_base := _get_cast_forward_base(scene_scale)

	if cast_t < CAST_WINDUP_END_PROGRESS:
		return idle_base.lerp(windup_base, _ease_out_sine(cast_t / CAST_WINDUP_END_PROGRESS))

	if cast_t < CAST_FORWARD_END_PROGRESS:
		return windup_base.lerp(forward_base, _ease_in_cubic((cast_t - CAST_WINDUP_END_PROGRESS) / (CAST_FORWARD_END_PROGRESS - CAST_WINDUP_END_PROGRESS)))

	return forward_base.lerp(idle_base, _ease_out_sine((cast_t - CAST_FORWARD_END_PROGRESS) / (1.0 - CAST_FORWARD_END_PROGRESS))) + Vector2(sin(cast_t * PI) * 3.0, 0.0) * scene_scale

func _get_cast_idle_base(_scene_scale: float) -> Vector2:
	return main._rod_anchor_pos

func _get_cast_idle_tip(_scene_scale: float) -> Vector2:
	return main._rod_target_pos

func _get_cast_windup_base(scene_scale: float) -> Vector2:
	return main._rod_anchor_pos + Vector2(34.0, -4.0) * scene_scale

func _get_cast_windup_tip(scene_scale: float) -> Vector2:
	var screen_size: Vector2 = main.get_viewport_rect().size
	return Vector2(screen_size.x * 0.740, screen_size.y * 0.440) + Vector2(0.0, -8.0) * scene_scale

func _get_cast_forward_base(scene_scale: float) -> Vector2:
	return main._rod_anchor_pos + Vector2(-10.0, -18.0) * scene_scale

func _get_cast_forward_tip(scene_scale: float) -> Vector2:
	var screen_size: Vector2 = main.get_viewport_rect().size
	return Vector2(screen_size.x * 0.585, screen_size.y * 0.570) + Vector2(0.0, -4.0) * scene_scale


func _trigger_drop_splash() -> void:
	_drop_splash_timer = DROP_SPLASH_DURATION
	_cast_landed = true


func _set_float_presence(center: Vector2, state: String, intensity: float) -> void:
	if state == "uncasted":
		_hide_float_and_line_visuals()
		return

	_ensure_float_sprite_nodes()
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
	var surface_y: float = center.y if state == "casting" else clamp(center.y, main._water_zone_top, main._water_zone_bottom)
	var bobber_center := _get_bobber_visual_center(center, state)

	match state:
		"casting":
			var cast_progress: float = _get_cast_progress()
			var cast_pulse: float = sin(cast_progress * PI)
			var landing_t: float = clamp((cast_progress - CAST_LANDING_START_PROGRESS) / (1.0 - CAST_LANDING_START_PROGRESS), 0.0, 1.0)
			ripple_scale = lerp(0.40, 1.0, _smooth_unit(landing_t))
			glow_scale = 0.82 + cast_pulse * 0.12
			reflection_scale = 0.78
			marker_height = 18.0
			marker_width = 4.7
			marker_sink = -cast_pulse * 3.0
			marker_tilt = _get_cast_float_rotation_degrees()
			ripple_alpha = lerp(0.80, 0.35, _smooth_unit(landing_t)) if _cast_landed else 0.0
			reflection_alpha = 0.0 if not _cast_landed else ripple_alpha * 0.55
			glow_alpha = 0.58
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

	var bobber_contact := _get_bobber_contact_point(center, surface_y, state, marker_sink)
	var ripple_size = Vector2(34.0, 12.5) * ripple_scale
	main.float_ripple.size = ripple_size
	main.float_ripple.position = Vector2(bobber_contact.x - ripple_size.x * 0.5, bobber_contact.y - ripple_size.y * 0.5)
	main.float_ripple.modulate = Color(1.0, 1.0, 1.0, ripple_alpha)
	main.float_ripple.visible = _ripple_sprite == null and _regular_splash_sprite == null and ripple_alpha > 0.01

	var reflection_size = Vector2(23.0, 7.5) * reflection_scale
	main.float_reflection.size = reflection_size
	main.float_reflection.position = Vector2(bobber_contact.x - reflection_size.x * 0.5, bobber_contact.y - reflection_size.y * 0.5 + 1.0)
	main.float_reflection.modulate = Color(1.0, 1.0, 1.0, reflection_alpha)
	main.float_reflection.visible = _ripple_sprite == null and _regular_splash_sprite == null and reflection_alpha > 0.01

	var glow_size = Vector2(26.0, 26.0) * glow_scale
	main.float_glow.size = glow_size
	main.float_glow.position = Vector2(bobber_center.x - glow_size.x * 0.5, bobber_contact.y - glow_size.y * 0.5 - 2.0)
	main.float_glow.modulate = Color(1.0, 1.0, 1.0, glow_alpha * 0.92)
	main.float_glow.visible = true

	main.float_marker.size = Vector2(marker_width, marker_height)
	main.float_marker.pivot_offset = main.float_marker.size * Vector2(0.5, 0.72)
	main.float_marker.position = Vector2(bobber_center.x - marker_width * 0.5, surface_y - marker_height * 0.58 + marker_sink + bobber_center.y - center.y)
	main.float_marker.rotation = deg_to_rad(marker_tilt)
	main.float_marker.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.float_marker.visible = _float_sprite == null

	if _ripple_sprite != null:
		var ripple_display_size := Vector2(ripple_size.x * 1.38, ripple_size.y * 1.56)
		_ripple_sprite.position = bobber_contact + Vector2(0.0, 1.0)
		_ripple_sprite.scale = Vector2(
			ripple_display_size.x / RIPPLE_TEXTURE_REGION.size.x,
			ripple_display_size.y / RIPPLE_TEXTURE_REGION.size.y
		)
		_ripple_sprite.rotation = 0.0
		_ripple_sprite.visible = _regular_splash_sprite == null and ripple_alpha > 0.01
		_ripple_sprite.modulate = Color(0.90, 0.96, 0.98, clamp(ripple_alpha * 0.38, 0.16, 0.52))

	if _regular_splash_sprite != null:
		var regular_active: bool = (state != "idle" and state != "casting") or (state == "casting" and _cast_landed)
		var regular_phase: float = sin(main._presence_time * 1.55)
		var regular_display_size: Vector2 = Vector2(126.0, 58.0) * (ripple_scale + regular_phase * 0.03)
		_regular_splash_sprite.position = bobber_contact + Vector2(0.0, 1.5)
		_regular_splash_sprite.scale = Vector2(
			regular_display_size.x / max(_regular_splash_texture.get_width(), 1),
			regular_display_size.y / max(_regular_splash_texture.get_height(), 1)
		)
		_regular_splash_sprite.rotation = sin(main._presence_time * 0.42) * 0.025
		_regular_splash_sprite.visible = regular_active
		_regular_splash_sprite.modulate = Color(0.54, 0.66, 0.70, clamp(ripple_alpha * 0.30, 0.18, 0.38) if regular_active else 0.0)

	if _float_sprite != null:
		var float_display_size := Vector2(marker_width * 1.78, marker_height * 1.50)
		_float_sprite.position = Vector2(bobber_center.x, surface_y + marker_sink + bobber_center.y - center.y)
		_float_sprite.scale = Vector2(
			float_display_size.x / FLOAT_TEXTURE_REGION.size.x,
			float_display_size.y / FLOAT_TEXTURE_REGION.size.y
		)
		_float_sprite.offset = Vector2(0.0, -FLOAT_TEXTURE_REGION.size.y * 0.080)
		_float_sprite.rotation = deg_to_rad(marker_tilt)
		_float_sprite.visible = true
		_float_sprite.modulate = Color(1.0, 1.0, 1.0, 0.98)

	_update_bobber_ripple_node(center, surface_y, state, ripple_scale, ripple_alpha, marker_sink)
	_update_bobber_contact_waterline(bobber_contact, state, ripple_scale, ripple_alpha)
	_update_splash_sprites(bobber_contact, bobber_contact.y)


func _update_bobber_ripple_node(center: Vector2, surface_y: float, state: String, ripple_scale: float, ripple_alpha: float, marker_sink: float = 0.0) -> void:
	_ensure_bobber_ripple_node()
	if _bobber_ripple == null:
		return

	var active: bool = ripple_alpha > 0.01 and (state != "casting" or _cast_landed)
	_bobber_ripple.visible = active
	if not active:
		return

	var contact_point := _get_bobber_contact_point(center, surface_y, state, marker_sink)
	_bobber_ripple.position = contact_point
	_bobber_ripple.rotation = 0.0
	_bobber_ripple.scale = Vector2.ONE * clamp(0.96 + ripple_scale * 0.14, 0.96, 1.16)
	_bobber_ripple.modulate = Color(1.0, 1.0, 1.0, clamp(ripple_alpha * 1.10, 0.0, 1.0))


func _update_bobber_contact_waterline(contact_point: Vector2, state: String, ripple_scale: float, ripple_alpha: float) -> void:
	_ensure_bobber_contact_waterline_node()
	if _bobber_contact_waterline == null:
		return

	var active: bool = ripple_alpha > 0.01 and (state != "casting" or _cast_landed)
	_bobber_contact_waterline.visible = active
	if not active:
		return

	_bobber_contact_waterline.position = contact_point + Vector2(0.0, -1.0)
	_bobber_contact_waterline.rotation = 0.0
	_bobber_contact_waterline.scale = Vector2.ONE * clamp(0.92 + ripple_scale * 0.12, 0.92, 1.14)
	_bobber_contact_waterline.modulate = Color(1.0, 1.0, 1.0, clamp(ripple_alpha * 0.95, 0.0, 1.0))


func _update_splash_sprites(center: Vector2, surface_y: float) -> void:
	if _drop_splash_sprite == null:
		return

	if _drop_splash_timer <= 0.0:
		_drop_splash_sprite.visible = false
		return

	var t: float = clamp(1.0 - _drop_splash_timer / DROP_SPLASH_DURATION, 0.0, 1.0)
	var eased: float = _smooth_unit(t)
	var splash_display_size: Vector2 = Vector2(86.0, 76.0) * lerp(0.84, 1.14, eased)
	_drop_splash_sprite.position = Vector2(center.x, surface_y - 13.0)
	_drop_splash_sprite.scale = Vector2(
		splash_display_size.x / max(_drop_splash_texture.get_width(), 1),
		splash_display_size.y / max(_drop_splash_texture.get_height(), 1)
	)
	_drop_splash_sprite.rotation = sin(main._presence_time * 6.0) * 0.02
	_drop_splash_sprite.visible = true
	_drop_splash_sprite.modulate = Color(0.62, 0.76, 0.80, (1.0 - eased) * 0.58)


func _update_fishing_presence(delta: float) -> void:
	if not main._presence_has_layout:
		return

	main._presence_time += delta
	main._presence_bite_timer = max(main._presence_bite_timer - delta, 0.0)
	main._presence_caught_timer = max(main._presence_caught_timer - delta, 0.0)
	_float_nudge_timer = max(_float_nudge_timer - delta, 0.0)
	if _cast_timer > 0.0:
		var was_casting := _cast_timer > 0.0
		_cast_timer = max(_cast_timer - delta, 0.0)
		if not _cast_landed and _get_cast_progress() >= CAST_LANDING_START_PROGRESS:
			_trigger_drop_splash()
		if was_casting and _cast_timer <= 0.0:
			is_cast_animating = false
			rod_visual_state = RodVisualState.FLOAT_IN_WATER
			cast_visual_finished.emit()
	_drop_splash_timer = max(_drop_splash_timer - delta, 0.0)

	var state = _get_presence_state()
	var intensity = _get_presence_reeling_intensity()

	if state == "casting":
		intensity = max(intensity, 0.55)
	elif state == "bite":
		intensity = max(intensity, 0.9)
	elif state == "caught":
		intensity = max(intensity, 0.35 + main._presence_caught_timer * 0.15)
	elif state == "idle":
		intensity *= 0.2
	elif state == "uncasted":
		intensity *= 0.12
	elif state == "waiting":
		intensity *= 0.35

	var screen_size = main.get_viewport_rect().size
	var scene_scale: float = clamp(screen_size.y / 540.0, 0.86, 1.26)
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

	if state == "waiting" and _float_nudge_timer > 0.0 and _float_nudge_duration > 0.0:
		var nudge_t: float = clamp(1.0 - _float_nudge_timer / _float_nudge_duration, 0.0, 1.0)
		var nudge_pulse: float = sin(nudge_t * PI)
		float_offset += Vector2(
			sin(main._presence_time * 25.0) * 5.0 * _float_nudge_strength,
			(5.0 + _float_nudge_strength * 8.0) * nudge_pulse
		)

	var target_float_center = main._float_base_center + float_offset + scene_breath * 0.35
	target_float_center.x = clamp(target_float_center.x, screen_size.x * 0.26, screen_size.x * 0.74)
	target_float_center.y = clamp(target_float_center.y, main._water_zone_top, main._water_zone_bottom)
	var float_follow = 7.0

	if state == "casting":
		target_float_center = _get_cast_float_center(main._float_base_center + scene_breath * 0.35, scene_scale)
		float_follow = 1.0
	elif state == "bite":
		float_follow = 13.0
	elif state == "reeling":
		float_follow = 9.0

	if state == "casting":
		main._float_visual_center = target_float_center
	else:
		main._float_visual_center = main._float_visual_center.lerp(target_float_center, clamp(delta * float_follow, 0.0, 1.0))
	_set_float_presence(main._float_visual_center, state, intensity)

	var cast_sweep_offset: Vector2 = _get_cast_sweep_offset(scene_scale) if state == "casting" else Vector2.ZERO
	var rod_butt: Vector2 = main._rod_anchor_pos + scene_breath + cast_sweep_offset * 0.55
	var rod_tip_rest: Vector2 = main._rod_target_pos + cast_sweep_offset
	var tip_pull_direction = (main._float_visual_center - rod_tip_rest).normalized()

	if state == "casting":
		rod_butt = _get_cast_rod_base_for_progress(_get_cast_progress(), scene_scale)
		rod_tip_rest = _get_cast_idle_tip(scene_scale)
		tip_pull_direction = (main._float_visual_center - rod_tip_rest).normalized()

	if tip_pull_direction == Vector2.ZERO:
		tip_pull_direction = Vector2(-0.68, 0.74)

	var rod_tip_target = rod_tip_rest

	match state:
		"casting":
			rod_tip_target = _get_cast_rod_tip_target(rod_tip_rest, scene_scale)
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

	if state == "casting":
		rod_tip_follow = 10.0
	elif state == "bite":
		rod_tip_follow = 7.5
	elif state == "reeling":
		rod_tip_follow = 5.2

	if state == "casting":
		main._rod_tip_visual = rod_tip_target
	else:
		main._rod_tip_visual = main._rod_tip_visual.lerp(rod_tip_target, clamp(delta * rod_tip_follow, 0.0, 1.0))

	var line_end = _get_bobber_line_attach_point(main._float_visual_center, state, scene_scale)
	if state == "uncasted":
		line_end = main._rod_tip_visual
	var line_pull_direction = (line_end - main._rod_tip_visual).normalized()

	if line_pull_direction == Vector2.ZERO:
		line_pull_direction = tip_pull_direction

	var rod_bend_direction = _get_line_normal(rod_butt, main._rod_tip_visual, true)

	if rod_bend_direction.dot(line_pull_direction) < 0.0:
		rod_bend_direction = -rod_bend_direction

	if state == "idle" or state == "waiting" or state == "uncasted":
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
		"casting":
			target_bend_amount = 8.0 + sin(_get_cast_progress() * PI) * 3.4
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

	if state == "casting":
		bend_amount_follow = 7.0
	elif state == "bite":
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

	if state == "casting":
		var cast_progress := _get_cast_progress()
		if cast_progress < CAST_FORWARD_END_PROGRESS:
			sag = 8.0
		elif cast_progress < CAST_LANDING_START_PROGRESS:
			var flight_t: float = (cast_progress - CAST_FORWARD_END_PROGRESS) / (CAST_LANDING_START_PROGRESS - CAST_FORWARD_END_PROGRESS)
			sag = 12.0 + sin(flight_t * PI) * 24.0
		else:
			sag = 18.0
	elif state == "reeling":
		sag = lerp(8.0, 1.2, intensity)
	elif state == "bite":
		sag = 7.0
	elif state == "caught":
		sag = 22.0

	var line_start: Vector2 = main._rod_tip_visual
	var line_sway: float = sin(main._presence_time * 2.0) * (1.0 + intensity * 0.8)
	var line_control_a: Vector2 = line_start.lerp(line_end, 0.30) + Vector2(
		line_sway,
		sag * 0.35 + sin(main._presence_time * 2.4) * (0.8 + intensity * 0.6)
	)
	var line_control_b: Vector2 = line_start.lerp(line_end, 0.72) + Vector2(
		-line_sway * 0.8,
		sag + sin(main._presence_time * 2.8 + 0.7) * (0.7 + intensity * 0.8)
	)

	if state == "casting":
		var flight_t: float = clamp((_get_cast_progress() - CAST_FORWARD_END_PROGRESS) / (CAST_LANDING_START_PROGRESS - CAST_FORWARD_END_PROGRESS), 0.0, 1.0)
		var loose_sway: float = sin(flight_t * PI) * 8.0 * scene_scale
		line_control_a += Vector2(loose_sway * 0.20, sag * 0.18)
		line_control_b += Vector2(-loose_sway * 0.38, sag * 0.24)

	var line_points: PackedVector2Array = _sample_cubic_curve(line_start, line_control_a, line_control_b, line_end, 0.0, 1.0, 20)
	main.fishing_line.points = line_points
	main.fishing_line_glow.points = line_points

	var line_alpha = 0.32
	var glow_alpha = 0.012
	var line_width = 0.32

	if state == "casting":
		var cast_progress := _get_cast_progress()
		line_alpha = 0.06 if cast_progress < CAST_FORWARD_END_PROGRESS else 0.34
		glow_alpha = 0.0 if cast_progress < CAST_FORWARD_END_PROGRESS else 0.018
		line_width = 0.28 if cast_progress < CAST_FORWARD_END_PROGRESS else 0.34
	elif state == "uncasted":
		line_alpha = 0.0
		glow_alpha = 0.0
		line_width = 0.0
	elif state == "waiting":
		line_alpha = 0.34
		glow_alpha = 0.016
		line_width = 0.34
	elif state == "bite":
		line_alpha = 0.44
		glow_alpha = 0.035
		line_width = 0.44
	elif state == "reeling":
		line_alpha = 0.38 + intensity * 0.07
		glow_alpha = 0.018 + intensity * 0.035
		line_width = 0.36 + intensity * 0.06
	elif state == "caught":
		line_alpha = 0.34
		glow_alpha = 0.014
		line_width = 0.32

	main.fishing_line.width = line_width
	main.fishing_line_glow.width = line_width + 0.22
	main.fishing_line.default_color = Color(0.74, 0.84, 0.82, line_alpha)
	main.fishing_line_glow.default_color = Color(0.58, 0.76, 0.72, glow_alpha)
	main.fishing_line.visible = line_alpha > 0.01
	main.fishing_line_glow.visible = glow_alpha > 0.001
