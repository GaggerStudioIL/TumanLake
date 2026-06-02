extends Node

const RAIN_AUDIO_PATH := "res://assets/audio/weather/pouring-rain.ogg"
const STORM_AUDIO_PATH := "res://assets/audio/weather/thunderstorm-and-pouring-rain.ogg"
const SILENCE_DB := -80.0
const RAIN_TARGET_VOLUME := 0.34
const STORM_TARGET_VOLUME := 0.38
const AUDIO_FADE_SECONDS := 1.4
const VISUAL_FADE_SECONDS := 1.2

var main
var _weather_layer: CanvasLayer
var _rain_rect: ColorRect
var _lightning_rect: ColorRect
var _audio_player: AudioStreamPlayer
var _audio_tween: Tween
var _lightning_tween: Tween
var _rng := RandomNumberGenerator.new()
var _current_effect_type := ""
var _current_audio_path := ""
var _target_rain_intensity := 0.0
var _rain_intensity := 0.0
var _next_lightning_seconds := 10.0


func _ready() -> void:
	_rng.randomize()
	set_process(true)


func setup(main_ref) -> void:
	main = main_ref
	_ensure_nodes()
	update_weather_state({})


func update_weather_state(weather_state: Dictionary) -> void:
	_ensure_nodes()
	var weather_type := str(weather_state.get("weather_type", "clear"))
	var effect_type := _get_weather_effect_type(weather_type)
	if effect_type == _current_effect_type:
		return

	_current_effect_type = effect_type
	match effect_type:
		"rain":
			_set_rain_target(0.58)
			_switch_weather_audio(RAIN_AUDIO_PATH, RAIN_TARGET_VOLUME)
			_schedule_next_lightning()
		"thunderstorm":
			_set_rain_target(0.82)
			_switch_weather_audio(STORM_AUDIO_PATH, STORM_TARGET_VOLUME)
			_schedule_next_lightning(3.0, 8.0)
		_:
			_set_rain_target(0.0)
			_stop_weather_audio()
			_stop_lightning()


func _process(delta: float) -> void:
	if _rain_rect == null:
		return

	_update_rain_intensity(delta)
	_update_lightning(delta)


func _ensure_nodes() -> void:
	if _weather_layer == null:
		_weather_layer = CanvasLayer.new()
		_weather_layer.name = "WeatherEffectsLayer"
		_weather_layer.layer = 10
		add_child(_weather_layer)

	if _rain_rect == null:
		_rain_rect = ColorRect.new()
		_rain_rect.name = "RainOverlay"
		_rain_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_rain_rect.color = Color.WHITE
		_rain_rect.visible = false
		_rain_rect.material = _make_rain_material()
		_weather_layer.add_child(_rain_rect)
		_fill_screen(_rain_rect)

	if _lightning_rect == null:
		_lightning_rect = ColorRect.new()
		_lightning_rect.name = "LightningFlash"
		_lightning_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_lightning_rect.color = Color(0.70, 0.86, 1.0, 0.0)
		_lightning_rect.visible = false
		_weather_layer.add_child(_lightning_rect)
		_fill_screen(_lightning_rect)

	if _audio_player == null:
		_audio_player = AudioStreamPlayer.new()
		_audio_player.name = "WeatherAudioPlayer"
		_audio_player.bus = _get_audio_bus_name("Ambience")
		_audio_player.volume_db = SILENCE_DB
		add_child(_audio_player)


func _fill_screen(control: Control) -> void:
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0


func _set_rain_target(value: float) -> void:
	_target_rain_intensity = clampf(value, 0.0, 1.0)
	if _rain_rect != null and _target_rain_intensity > 0.01:
		_rain_rect.visible = true


func _update_rain_intensity(delta: float) -> void:
	var step := delta / maxf(VISUAL_FADE_SECONDS, 0.01)
	_rain_intensity = move_toward(_rain_intensity, _target_rain_intensity, step)
	if _rain_rect.material is ShaderMaterial:
		(_rain_rect.material as ShaderMaterial).set_shader_parameter("intensity", _rain_intensity)
	_rain_rect.visible = _rain_intensity > 0.01


func _update_lightning(delta: float) -> void:
	if _current_effect_type != "thunderstorm" or _target_rain_intensity <= 0.0:
		return
	if _lightning_tween != null and _lightning_tween.is_valid():
		return

	_next_lightning_seconds -= delta
	if _next_lightning_seconds <= 0.0:
		_start_lightning_flash()
		_schedule_next_lightning()


func _schedule_next_lightning(min_seconds: float = 6.0, max_seconds: float = 18.0) -> void:
	_next_lightning_seconds = _rng.randf_range(min_seconds, max_seconds)


func _start_lightning_flash() -> void:
	if _lightning_rect == null:
		return

	_lightning_rect.visible = true
	_lightning_rect.color = Color(0.70, 0.86, 1.0, 0.0)
	if _lightning_tween != null and _lightning_tween.is_valid():
		_lightning_tween.kill()

	var peak_alpha := _rng.randf_range(0.12, 0.22)
	var tween := create_tween()
	tween.tween_property(_lightning_rect, "color", Color(0.74, 0.88, 1.0, peak_alpha), _rng.randf_range(0.035, 0.065))
	tween.tween_property(_lightning_rect, "color", Color(0.74, 0.88, 1.0, 0.03), _rng.randf_range(0.08, 0.14))
	if _rng.randf() < 0.35:
		tween.tween_interval(_rng.randf_range(0.05, 0.11))
		tween.tween_property(_lightning_rect, "color", Color(0.78, 0.90, 1.0, peak_alpha * 0.58), 0.035)
		tween.tween_property(_lightning_rect, "color", Color(0.74, 0.88, 1.0, 0.02), 0.10)
	tween.tween_property(_lightning_rect, "color", Color(0.70, 0.86, 1.0, 0.0), 0.22)
	tween.tween_callback(Callable(self, "_hide_lightning_rect"))
	_lightning_tween = tween


func _hide_lightning_rect() -> void:
	if _lightning_rect != null:
		_lightning_rect.visible = false


func _stop_lightning() -> void:
	if _lightning_tween != null and _lightning_tween.is_valid():
		_lightning_tween.kill()
	_lightning_tween = null
	if _lightning_rect != null:
		_lightning_rect.color = Color(0.70, 0.86, 1.0, 0.0)
		_lightning_rect.visible = false


func _switch_weather_audio(path: String, target_volume: float) -> void:
	if path == "":
		_stop_weather_audio()
		return
	if _current_audio_path == path and _audio_player != null and _audio_player.playing:
		_fade_audio_to(_get_target_db(target_volume), AUDIO_FADE_SECONDS)
		return

	if _audio_player == null:
		return

	if _audio_tween != null and _audio_tween.is_valid():
		_audio_tween.kill()
		_audio_tween = null

	var stream := _load_audio_stream(path)
	if stream == null:
		push_warning("Weather audio is missing: %s" % path)
		return

	_current_audio_path = path
	_audio_player.stop()
	_audio_player.stream = stream
	_set_stream_loop(stream, true)
	_audio_player.volume_db = SILENCE_DB
	_audio_player.play()
	_fade_audio_to(_get_target_db(target_volume), AUDIO_FADE_SECONDS)


func _stop_weather_audio() -> void:
	if _audio_player == null:
		return
	_current_audio_path = ""
	if not _audio_player.playing:
		return

	if _audio_tween != null and _audio_tween.is_valid():
		_audio_tween.kill()
	var tween := create_tween()
	tween.tween_property(_audio_player, "volume_db", SILENCE_DB, AUDIO_FADE_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "_clear_weather_audio_after_fade"))
	_audio_tween = tween


func _clear_weather_audio_after_fade() -> void:
	if _audio_player != null:
		_audio_player.stop()
		_audio_player.stream = null


func _fade_audio_to(target_db: float, duration: float) -> void:
	if _audio_player == null:
		return
	if _audio_tween != null and _audio_tween.is_valid():
		_audio_tween.kill()
	var tween := create_tween()
	tween.tween_property(_audio_player, "volume_db", target_db, maxf(duration, 0.01)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_audio_tween = tween


func _get_target_db(effect_volume: float) -> float:
	var master := 1.0
	var ambience := 0.72
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null and audio_manager.has_method("get_volume_settings"):
		var settings = audio_manager.call("get_volume_settings")
		if settings is Dictionary:
			master = float((settings as Dictionary).get("master_volume", master))
			ambience = float((settings as Dictionary).get("ambient_volume", ambience))
	return _volume_to_db(master * ambience * effect_volume)


func _get_weather_effect_type(weather_type: String) -> String:
	var normalized := weather_type.strip_edges().to_lower()
	match normalized:
		"thunderstorm", "storm", "rain_with_thunderstorms", "гроза", "дождь с грозой":
			return "thunderstorm"
		"rain", "rainy", "дождь":
			return "rain"
		_:
			return "clear"


func _make_rain_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
		shader_type canvas_item;

		uniform float intensity = 0.0;
		uniform vec4 rain_color : source_color = vec4(0.70, 0.86, 0.96, 1.0);

		float rand(vec2 value) {
			return fract(sin(dot(value, vec2(12.9898, 78.233))) * 43758.5453);
		}

		float rain_layer(vec2 uv, float columns, float rows, float speed, float width, float length, float seed) {
			uv.x += uv.y * 0.30;
			uv.y += TIME * speed;
			vec2 grid = vec2(uv.x * columns, uv.y * rows);
			vec2 cell = floor(grid);
			vec2 local = fract(grid);
			float mask = step(0.42, rand(cell + vec2(seed, seed * 3.17)));
			float streak_x = 1.0 - smoothstep(width, width * 2.6, abs(local.x - 0.52));
			float streak_y = 1.0 - smoothstep(length, length + 0.16, local.y);
			float head = smoothstep(0.03, 0.22, local.y);
			return streak_x * streak_y * head * mask;
		}

		void fragment() {
			vec2 uv = UV;
			float near_rain = rain_layer(uv, 78.0, 14.0, 1.65, 0.018, 0.42, 11.0);
			float far_rain = rain_layer(uv + vec2(0.19, 0.07), 52.0, 10.0, 1.20, 0.014, 0.34, 23.0);
			float alpha = clamp((near_rain * 0.135 + far_rain * 0.075) * intensity, 0.0, 0.24);
			COLOR = vec4(rain_color.rgb, alpha);
		}
	"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("intensity", 0.0)
	return material


func _load_audio_stream(path: String) -> AudioStream:
	if path.get_extension().to_lower() == "ogg":
		var ogg_stream := AudioStreamOggVorbis.load_from_file(path)
		if ogg_stream != null:
			return ogg_stream
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	return null


func _set_stream_loop(stream: AudioStream, enabled: bool) -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = enabled
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = enabled


func _get_audio_bus_name(preferred_bus: String, fallback_bus: String = "Master") -> String:
	if AudioServer.get_bus_index(preferred_bus) >= 0:
		return preferred_bus
	if AudioServer.get_bus_index(fallback_bus) >= 0:
		return fallback_bus
	return "Master"


func _volume_to_db(value: float) -> float:
	var volume := clampf(value, 0.0, 1.0)
	if volume <= 0.001:
		return SILENCE_DB
	return linear_to_db(volume)
