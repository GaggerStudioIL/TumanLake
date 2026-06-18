extends Control

const TARGET_SCENE_PATH := "res://scenes/main/Main.tscn"
const DESIGN_SIZE := Vector2(1920.0, 1080.0)
const FADE_DURATION := 1.7
const TITLE_FADE_DURATION := 1.4
const INTRO_INPUT_ARM_DELAY := 0.35
const FINAL_INPUT_ARM_DELAY := 0.35
const IntroFxLayerScript := preload("res://scripts/intro/IntroFxLayer.gd")

@export var change_scene_on_finish := true

var scene_defs: Array = []
var intro_texture_cache: Dictionary = {}

var base_black_rect: ColorRect
var scene_root: Control
var image_layer: TextureRect
var vignette_layer: ColorRect
var color_grade_layer: ColorRect
var fx_layer
var overlay_canvas: CanvasLayer
var subtitle_label: Label
var studio_label: Label
var presents_label: Label
var final_text_label: Label
var logo_layer: TextureRect
var press_label: Label
var skip_button: Button
var start_button: Button
var fade_rect: ColorRect
var animation_player: AnimationPlayer
var final_start_enabled := false
var finishing := false
var intro_running := false
var active_scene_index := 0
var active_scene_time := 0.0
var input_armed_at_msec := 0
var final_input_armed_at_msec := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process_input(true)
	set_process_unhandled_input(true)
	if change_scene_on_finish and not _should_play_intro():
		call_deferred("_change_to_target_scene")
		return
	_build_scene_defs()
	_build_nodes()
	_setup_animation_player()
	_start_intro_sequence()

func _process(delta: float) -> void:
	if not intro_running or finishing:
		return
	_update_intro_sequence(delta)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_fullscreen_layout()

func _input(event: InputEvent) -> void:
	var viewport := get_viewport()
	if _handle_intro_input(event) and viewport != null:
		viewport.set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	_handle_intro_input(event)

func _handle_intro_input(event: InputEvent) -> bool:
	if finishing:
		return false
	if not _is_input_armed():
		return false
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo:
			if _is_final_scene() and final_start_enabled and (key_event.keycode == KEY_ENTER or key_event.keycode == KEY_SPACE):
				_finish_intro()
				return true
			if not _is_final_scene() and key_event.keycode == KEY_ESCAPE:
				_request_skip()
				return true
	return false

func _is_input_armed() -> bool:
	return Time.get_ticks_msec() >= input_armed_at_msec

func _arm_input(delay_seconds: float) -> void:
	input_armed_at_msec = Time.get_ticks_msec() + int(delay_seconds * 1000.0)

func _should_play_intro() -> bool:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null and save_manager.has_method("is_intro_enabled"):
		return bool(save_manager.call("is_intro_enabled"))
	return true

func _build_scene_defs() -> void:
	scene_defs = [
		{
			"kind": "studio",
			"duration": 7.2
		},
		{
			"image": "res://assets/intro/intro_1.png",
			"subtitle": "Много лет я был обыкновенным офисным планктоном.",
			"duration": 10.5,
			"effect": "none",
			"zoom_from": 1.02,
			"zoom_to": 1.05,
			"drift": Vector2(-8.0, -4.0),
			"ambient": "city"
		},
		{
			"image": "res://assets/intro/intro_2.png",
			"subtitle": "Я любил городскую суету и мир стальных машин.",
			"duration": 10.5,
			"effect": "city",
			"zoom_from": 1.02,
			"zoom_to": 1.055,
			"drift": Vector2(0.0, -7.0),
			"ambient": "city"
		},
		{
			"image": "res://assets/intro/intro_3.png",
			"subtitle": "Но однажды, быть может с возрастом, мне захотелось тишины, природы и спокойствия.",
			"duration": 12.0,
			"effect": "balcony",
			"zoom_from": 1.015,
			"zoom_to": 1.055,
			"drift": Vector2(-10.0, -5.0),
			"ambient": "city"
		},
		{
			"image": "res://assets/intro/intro_4.png",
			"subtitle": "Я вспомнил, как мой дедушка Дима когда-то ловил со мной рыбу.",
			"duration": 12.5,
			"effect": "lake_memory",
			"zoom_from": 1.015,
			"zoom_to": 1.045,
			"drift": Vector2(5.0, -5.0),
			"ambient": "water"
		},
		{
			"image": "res://assets/intro/intro_5.png",
			"subtitle": "И я решил оставить старую жизнь позади, переехать к озеру и снова услышать тишину.",
			"duration": 10.5,
			"effect": "road",
			"zoom_from": 1.02,
			"zoom_to": 1.045,
			"drift": Vector2(-12.0, 4.0),
			"ambient": "water"
		},
		{
			"image": "res://assets/intro/intro_6.png",
			"subtitle": "Теперь у меня есть только вода, небо, удочка и время для себя.",
			"duration": 12.5,
			"effect": "lake",
			"zoom_from": 1.015,
			"zoom_to": 1.045,
			"drift": Vector2(6.0, -5.0),
			"ambient": "water"
		},
		{
			"kind": "final",
			"image": "res://assets/intro/rybnoe_mesto_final_start.png",
			"duration": 10.5,
			"effect": "final",
			"ambient": "water"
		}
	]

func _build_nodes() -> void:
	base_black_rect = ColorRect.new()
	base_black_rect.name = "BaseBlack"
	base_black_rect.color = Color.BLACK
	base_black_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base_black_rect)

	scene_root = Control.new()
	scene_root.name = "ParallaxSceneRoot"
	add_child(scene_root)

	image_layer = TextureRect.new()
	image_layer.name = "BackgroundLayer"
	image_layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image_layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scene_root.add_child(image_layer)

	color_grade_layer = ColorRect.new()
	color_grade_layer.name = "ColorGradeLayer"
	color_grade_layer.color = Color(1.0, 0.68, 0.36, 0.055)
	color_grade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scene_root.add_child(color_grade_layer)

	fx_layer = IntroFxLayerScript.new()
	fx_layer.name = "OverlayFxLayer"
	fx_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scene_root.add_child(fx_layer)

	vignette_layer = ColorRect.new()
	vignette_layer.name = "VignetteLayer"
	vignette_layer.color = Color(0.0, 0.0, 0.0, 0.28)
	vignette_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scene_root.add_child(vignette_layer)

	overlay_canvas = CanvasLayer.new()
	overlay_canvas.name = "OverlayCanvas"
	add_child(overlay_canvas)

	subtitle_label = _make_label("SubtitleLabel", 24, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	subtitle_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_canvas.add_child(subtitle_label)

	studio_label = _make_label("StudioLabel", 38, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	studio_label.text = "Gagger Studio"
	studio_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	overlay_canvas.add_child(studio_label)

	presents_label = _make_label("PresentsLabel", 22, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	presents_label.text = "Presents"
	presents_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	overlay_canvas.add_child(presents_label)

	final_text_label = _make_label("FinalTextLabel", 24, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	final_text_label.text = "Добро пожаловать в мир уюта, природы и спокойствия."
	final_text_label.modulate = Color(1.0, 0.88, 0.66, 0.0)
	final_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_canvas.add_child(final_text_label)

	logo_layer = TextureRect.new()
	logo_layer.name = "LogoLayer"
	logo_layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo_layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo_layer.modulate = Color(1.0, 1.0, 1.0, 0.0)
	overlay_canvas.add_child(logo_layer)

	press_label = _make_label("PressLabel", 20, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	press_label.text = "Нажмите, чтобы начать"
	press_label.modulate = Color(1.0, 0.90, 0.72, 0.0)
	overlay_canvas.add_child(press_label)

	skip_button = Button.new()
	skip_button.name = "SkipButton"
	skip_button.text = "Пропустить"
	skip_button.focus_mode = Control.FOCUS_NONE
	skip_button.visible = false
	skip_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_intro_button_style(skip_button, false)
	skip_button.pressed.connect(_on_skip_button_pressed)
	overlay_canvas.add_child(skip_button)

	start_button = Button.new()
	start_button.name = "StartButton"
	start_button.text = "Начать игру"
	start_button.focus_mode = Control.FOCUS_NONE
	start_button.visible = false
	start_button.disabled = true
	start_button.modulate = Color(1.0, 1.0, 1.0, 0.0)
	start_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_intro_button_style(start_button, true)
	start_button.pressed.connect(_on_start_button_pressed)
	overlay_canvas.add_child(start_button)

	fade_rect = ColorRect.new()
	fade_rect.name = "FadeRect"
	fade_rect.color = Color.BLACK
	fade_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_canvas.add_child(fade_rect)

	animation_player = AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	add_child(animation_player)

	_apply_fullscreen_layout()

func _apply_intro_button_style(button: Button, primary: bool) -> void:
	var normal_bg := Color(0.035, 0.060, 0.060, 0.72)
	var hover_bg := Color(0.060, 0.110, 0.095, 0.88)
	var pressed_bg := Color(0.025, 0.070, 0.060, 0.94)
	var border := Color(0.84, 0.94, 0.82, 0.28)
	var shadow := Color(0.0, 0.0, 0.0, 0.22)
	var radius := 18
	var font_size := 16
	if primary:
		normal_bg = Color(0.135, 0.290, 0.145, 0.94)
		hover_bg = Color(0.185, 0.390, 0.190, 1.0)
		pressed_bg = Color(0.090, 0.210, 0.115, 1.0)
		border = Color(0.96, 0.76, 0.32, 0.62)
		shadow = Color(0.82, 0.54, 0.12, 0.20)
		radius = 26
		font_size = 22

	button.add_theme_stylebox_override("normal", _make_button_style(normal_bg, border, radius, 6, shadow))
	button.add_theme_stylebox_override("hover", _make_button_style(hover_bg, Color(border.r, border.g, border.b, minf(border.a + 0.14, 1.0)), radius, 8, shadow))
	button.add_theme_stylebox_override("pressed", _make_button_style(pressed_bg, Color(border.r, border.g, border.b, minf(border.a + 0.18, 1.0)), radius, 3, Color(0.0, 0.0, 0.0, 0.18)))
	button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.040, 0.045, 0.045, 0.46), Color(0.60, 0.65, 0.62, 0.16), radius, 1, Color.TRANSPARENT))
	button.add_theme_color_override("font_color", Color(0.98, 1.0, 0.92, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.95, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.86, 1.0, 0.82, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.72, 0.76, 0.72, 0.54))
	button.add_theme_font_size_override("font_size", font_size)

func _make_button_style(
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
	style.content_margin_left = 24.0
	style.content_margin_right = 24.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	return style

func _make_label(label_name: String, font_size: int, h_align: int, v_align: int) -> Label:
	var label := Label.new()
	label.name = label_name
	label.horizontal_alignment = h_align
	label.vertical_alignment = v_align
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _apply_fullscreen_layout() -> void:
	if scene_root == null or fade_rect == null:
		return
	var viewport_size := _get_layout_size()
	_set_full_rect(self)
	_set_full_rect(base_black_rect)
	_set_full_rect(scene_root)
	_set_full_rect(image_layer)
	_set_full_rect(color_grade_layer)
	_set_full_rect(fx_layer)
	_set_full_rect(vignette_layer)
	_set_full_rect(fade_rect)

	scene_root.pivot_offset = viewport_size * 0.5

	subtitle_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	var subtitle_margin := maxf(viewport_size.x * 0.18, 80.0)
	subtitle_label.offset_left = subtitle_margin
	subtitle_label.offset_right = -subtitle_margin
	subtitle_label.offset_top = -118.0
	subtitle_label.offset_bottom = -34.0

	studio_label.set_anchors_preset(Control.PRESET_CENTER)
	studio_label.size = Vector2(520.0, 56.0)
	studio_label.position = viewport_size * 0.5 - studio_label.size * 0.5 + Vector2(0.0, -28.0)

	presents_label.set_anchors_preset(Control.PRESET_CENTER)
	presents_label.size = Vector2(360.0, 42.0)
	presents_label.position = viewport_size * 0.5 - presents_label.size * 0.5 + Vector2(0.0, 32.0)

	final_text_label.set_anchors_preset(Control.PRESET_CENTER)
	final_text_label.size = Vector2(minf(viewport_size.x * 0.76, 980.0), 110.0)
	final_text_label.position = viewport_size * 0.5 - final_text_label.size * 0.5 + Vector2(0.0, -178.0)

	logo_layer.set_anchors_preset(Control.PRESET_CENTER)
	logo_layer.size = Vector2(minf(viewport_size.x * 0.78, 950.0), minf(viewport_size.y * 0.44, 420.0))
	logo_layer.position = viewport_size * 0.5 - logo_layer.size * 0.5 + Vector2(0.0, 14.0)

	press_label.set_anchors_preset(Control.PRESET_CENTER)
	press_label.size = Vector2(420.0, 42.0)
	press_label.position = viewport_size * 0.5 - press_label.size * 0.5 + Vector2(0.0, minf(viewport_size.y * 0.34, 250.0))

	if skip_button != null:
		skip_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		skip_button.size = Vector2(152.0, 42.0)
		skip_button.position = Vector2(viewport_size.x - skip_button.size.x - 24.0, 22.0)

	if start_button != null:
		start_button.set_anchors_preset(Control.PRESET_CENTER)
		var start_width: float = clampf(viewport_size.x * 0.34, 340.0, 500.0)
		var start_height: float = clampf(viewport_size.y * 0.075, 74.0, 92.0)
		start_button.size = Vector2(start_width, start_height)
		start_button.custom_minimum_size = start_button.size
		start_button.position = viewport_size * 0.5 - start_button.size * 0.5 + Vector2(0.0, minf(viewport_size.y * 0.38, 330.0))

func _get_layout_size() -> Vector2:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 1.0 or viewport_size.y <= 1.0:
		return DESIGN_SIZE
	return viewport_size

func _set_full_rect(control: Control, rect_size: Vector2 = Vector2.ZERO) -> void:
	if control == null:
		return
	if rect_size != Vector2.ZERO:
		control.set_anchors_preset(Control.PRESET_TOP_LEFT)
		control.offset_left = 0.0
		control.offset_top = 0.0
		control.offset_right = rect_size.x
		control.offset_bottom = rect_size.y
		return
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0

func _setup_animation_player() -> void:
	animation_player.root_node = NodePath("..")

func _start_intro_sequence() -> void:
	active_scene_index = 0
	active_scene_time = 0.0
	intro_running = true
	finishing = false
	final_start_enabled = false
	final_input_armed_at_msec = 0
	_arm_input(INTRO_INPUT_ARM_DELAY)
	_update_intro_buttons()
	_enter_active_scene()

func _update_intro_sequence(delta: float) -> void:
	active_scene_time += delta
	var scene_def: Dictionary = scene_defs[active_scene_index]
	var duration := float(scene_def.get("duration", 6.0))

	if active_scene_index == 0:
		_update_studio_scene(duration)
	elif str(scene_def.get("kind", "")) == "final":
		_update_final_scene(scene_def, duration)
	else:
		_update_art_scene(scene_def, duration)

	if active_scene_time >= duration and not _is_final_scene():
		_go_to_next_scene()

func _enter_active_scene() -> void:
	active_scene_time = 0.0
	_arm_input(INTRO_INPUT_ARM_DELAY)
	var scene_def: Dictionary = scene_defs[active_scene_index]

	if active_scene_index == 0:
		final_start_enabled = false
		_clear_scene_visuals()
		fx_layer.configure("none")
		studio_label.modulate.a = 0.0
		presents_label.modulate.a = 0.0
		fade_rect.modulate.a = 1.0
		_update_intro_buttons()
		return

	if str(scene_def.get("kind", "")) == "final":
		final_start_enabled = false
		final_input_armed_at_msec = Time.get_ticks_msec() + int(FINAL_INPUT_ARM_DELAY * 1000.0)
		_set_intro_ambient(str(scene_def.get("ambient", "")))
		_setup_image_scene({
			"image": str(scene_def.get("image", "res://assets/intro/rybnoe_mesto_final_start.png")),
			"effect": str(scene_def.get("effect", "final")),
			"zoom_from": 1.0,
			"zoom_to": 1.018,
			"drift": Vector2(2.0, -3.0)
		})
		image_layer.modulate.a = 0.0
		_update_intro_buttons()
		return

	final_start_enabled = false
	_set_intro_ambient(str(scene_def.get("ambient", "")))
	_setup_image_scene(scene_def)
	subtitle_label.text = str(scene_def.get("subtitle", ""))
	_update_intro_buttons()

func _update_studio_scene(duration: float) -> void:
	fade_rect.modulate.a = _get_scene_fade_alpha(duration)
	var text_in := _smooth01(active_scene_time / TITLE_FADE_DURATION)
	var text_out := 1.0 - _smooth01((active_scene_time - (duration - 1.4)) / 1.0)
	var studio_alpha: float = clampf(minf(text_in, text_out), 0.0, 1.0)
	var presents_in := _smooth01((active_scene_time - 2.4) / 1.1)
	studio_label.modulate.a = studio_alpha
	presents_label.modulate.a = clampf(presents_in * text_out, 0.0, 1.0)

func _update_art_scene(scene_def: Dictionary, duration: float) -> void:
	fade_rect.modulate.a = _get_scene_fade_alpha(duration)
	var subtitle_in := _smooth01((active_scene_time - 0.45) / 1.0)
	var subtitle_out := 1.0 - _smooth01((active_scene_time - (duration - 1.6)) / 0.8)
	subtitle_label.modulate.a = clampf(minf(subtitle_in, subtitle_out), 0.0, 1.0)
	_apply_camera_progress(scene_def, duration)

func _update_final_scene(scene_def: Dictionary, duration: float) -> void:
	fade_rect.modulate.a = 1.0 - _smooth01(active_scene_time / FADE_DURATION)
	final_text_label.modulate.a = 0.0
	image_layer.modulate.a = _smooth01((active_scene_time - 0.15) / 0.65)
	var press_base := _smooth01((active_scene_time - 0.55) / 0.55)
	press_label.modulate.a = 0.0
	final_start_enabled = active_scene_time >= 1.0 and Time.get_ticks_msec() >= final_input_armed_at_msec
	if start_button != null:
		start_button.visible = true
		start_button.disabled = not final_start_enabled
		start_button.modulate.a = press_base
	_apply_camera_progress({
		"zoom_from": 1.0,
		"zoom_to": 1.018,
		"drift": Vector2(2.0, -3.0)
	}, duration)

func _apply_camera_progress(scene_def: Dictionary, duration: float) -> void:
	var progress := _smooth01(active_scene_time / maxf(duration, 0.001))
	var zoom_from := float(scene_def.get("zoom_from", 1.0))
	var zoom_to := float(scene_def.get("zoom_to", 1.0))
	var drift_vector := Vector2.ZERO
	var drift = scene_def.get("drift", Vector2.ZERO)
	if drift is Vector2:
		drift_vector = drift as Vector2
	scene_root.scale = Vector2.ONE * lerpf(zoom_from, zoom_to, progress)
	scene_root.position = (-drift_vector * 0.5).lerp(drift_vector, progress)

func _get_scene_fade_alpha(duration: float) -> float:
	if active_scene_time < FADE_DURATION:
		return 1.0 - _smooth01(active_scene_time / FADE_DURATION)
	if active_scene_time > duration - FADE_DURATION:
		return _smooth01((active_scene_time - (duration - FADE_DURATION)) / FADE_DURATION)
	return 0.0

func _go_to_next_scene() -> void:
	active_scene_index += 1
	if active_scene_index >= scene_defs.size():
		_finish_intro()
		return
	_enter_active_scene()

func _is_final_scene() -> bool:
	if active_scene_index < 0 or active_scene_index >= scene_defs.size():
		return false
	return str((scene_defs[active_scene_index] as Dictionary).get("kind", "")) == "final"

func _jump_to_final_scene() -> void:
	for index in range(scene_defs.size()):
		var scene_def := scene_defs[index] as Dictionary
		if str(scene_def.get("kind", "")) == "final":
			active_scene_index = index
			_enter_active_scene()
			return

func _smooth01(value: float) -> float:
	var t := clampf(value, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func _setup_image_scene(scene_def: Dictionary) -> void:
	_reset_overlay_text()
	var texture := _load_intro_texture(str(scene_def.get("image", "")))
	image_layer.texture = texture
	image_layer.modulate.a = 1.0
	fx_layer.configure(str(scene_def.get("effect", "none")))
	scene_root.scale = Vector2.ONE * float(scene_def.get("zoom_from", 1.0))
	scene_root.position = Vector2.ZERO
	color_grade_layer.color = _get_color_grade_for_effect(str(scene_def.get("effect", "none")))

func _load_intro_texture(path: String) -> Texture2D:
	if intro_texture_cache.has(path):
		return intro_texture_cache[path] as Texture2D

	if path.is_empty() or not ResourceLoader.exists(path):
		push_warning("IntroCinematic: missing intro image: " + path)
		return null

	var imported_texture := load(path) as Texture2D
	if imported_texture == null:
		push_warning("IntroCinematic: cannot load intro image: " + path)
		return null

	var image := imported_texture.get_image()
	if image == null:
		intro_texture_cache[path] = imported_texture
		return imported_texture

	var texture := ImageTexture.create_from_image(image)
	intro_texture_cache[path] = texture
	return texture

func _clear_scene_visuals() -> void:
	image_layer.texture = null
	image_layer.modulate.a = 1.0
	logo_layer.texture = null
	scene_root.scale = Vector2.ONE
	scene_root.position = Vector2.ZERO
	_reset_overlay_text()

func _reset_overlay_text() -> void:
	subtitle_label.text = ""
	subtitle_label.modulate.a = 0.0
	studio_label.modulate.a = 0.0
	presents_label.modulate.a = 0.0
	final_text_label.modulate.a = 0.0
	logo_layer.modulate.a = 0.0
	press_label.modulate.a = 0.0
	if start_button != null:
		start_button.visible = false
		start_button.disabled = true
		start_button.modulate.a = 0.0

func _get_color_grade_for_effect(effect_name: String) -> Color:
	match effect_name:
		"rain":
			return Color(0.09, 0.12, 0.17, 0.12)
		"city":
			return Color(0.11, 0.10, 0.16, 0.11)
		"balcony":
			return Color(1.0, 0.58, 0.24, 0.08)
		"road", "lake", "lake_memory", "final":
			return Color(1.0, 0.70, 0.32, 0.055)
		_:
			return Color.TRANSPARENT

func _request_skip() -> void:
	if _is_final_scene():
		if final_start_enabled:
			_finish_intro()
		return
	_jump_to_final_scene()

func _on_skip_button_pressed() -> void:
	if finishing or _is_final_scene():
		return
	_request_skip()

func _on_start_button_pressed() -> void:
	if finishing or not _is_final_scene() or not final_start_enabled:
		return
	_finish_intro()

func _update_intro_buttons() -> void:
	if skip_button != null:
		skip_button.visible = intro_running and not finishing and not _is_final_scene()
		skip_button.disabled = finishing or _is_final_scene()
	if start_button != null and not _is_final_scene():
		start_button.visible = false
		start_button.disabled = true
		start_button.modulate.a = 0.0

func _finish_intro() -> void:
	if finishing:
		return
	finishing = true
	intro_running = false
	subtitle_label.modulate.a = 0.0
	press_label.modulate.a = 0.0
	if skip_button != null:
		skip_button.visible = false
	if start_button != null:
		start_button.disabled = true
		start_button.visible = false
	fade_rect.modulate.a = 1.0
	if not change_scene_on_finish:
		queue_free()
		return
	_change_to_target_scene()

func _change_to_target_scene() -> void:
	get_tree().change_scene_to_file(TARGET_SCENE_PATH)

func _set_intro_ambient(ambient_key: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager == null:
		return
	if ambient_key == "water" and audio_manager.has_method("play_water_ambient_loop"):
		audio_manager.call("play_water_ambient_loop")
