extends Node2D

const StarsLayerScript := preload("res://scripts/environment/StarsLayer.gd")

const SHOW_ENVIRONMENT_DEBUG := false

@export var sun_size: float = 72.0
@export var show_dynamic_sun: bool = true
@export var remove_static_sun_from_art: bool = true
@export var moon_size: float = 54.0
@export var sun_arc_height: float = 0.28
@export var moon_arc_height: float = 0.24
@export var night_tint_strength: float = 0.48
@export var sunset_tint_strength: float = 0.30
@export var max_stars_alpha: float = 0.40
@export var star_count: int = 58
@export var horizon_y_ratio: float = 0.60
@export var sun_horizon_y_ratio: float = 0.44
@export var sun_start_x_ratio: float = 0.36
@export var sun_end_x_ratio: float = 0.88
@export var moon_horizon_y_ratio: float = 0.37
@export var moon_start_x_ratio: float = 0.42
@export var moon_end_x_ratio: float = 0.82
@export var sky_padding_ratio: float = 0.10

const SKY_PATH := "res://assets/environment/lake/sky_morning_no_sun.png"
const SUN_PATH := "res://assets/environment/lake/sun.png"
const MOON_PATH := "res://assets/environment/lake/moon.png"
const MOUNTAINS_PATH := "res://assets/environment/lake/mountains_morning.png.png"
const FOREST_PATH := "res://assets/environment/lake/forest_morning.png.png"
const WATER_PATH := "res://assets/environment/lake/Water_morning.png.png"
const LIGHT_OVERLAY_PATH := "res://assets/environment/lake/Light_overlay.png.png"
const FOREGROUND_GRASS_PATH := "res://assets/environment/lake/Foregraund_grass.png.png"
const OLD_OAK_PIER_ASSET_ROOT := "res://assets/environment/agamin_lake/spots/old_oak_pier"
const QUIET_WATER_PIER_ASSET_ROOT := "res://assets/environment/agamin_lake/spots/quiet_water_pier"
const MORNING_PIER_ASSET_ROOT := "res://assets/environment/agamin_lake/spots/morning_pier"
const OLD_BOAT_PIER_ASSET_ROOT := "res://assets/environment/agamin_lake/spots/old_boat_pier"
const DEEP_PIER_ASSET_ROOT := "res://assets/environment/agamin_lake/spots/deep_pier"
const COLD_WATER_ASSET_ROOT := "res://assets/environment/agamin_lake/spots/cold_water"
const DARK_HOLE_ASSET_ROOT := "res://assets/environment/agamin_lake/spots/dark_hole"
const MIST_PIER_ASSET_ROOT := "res://assets/environment/agamin_lake/spots/mist_pier"
const REEDS_PIER_ASSET_ROOT := "res://assets/environment/agamin_lake/spots/reeds_pier"
const GREEN_DUCKWEED_ASSET_ROOT := "res://assets/environment/agamin_lake/spots/green_duckweed"
const FROG_BACKWATER_ASSET_ROOT := "res://assets/environment/agamin_lake/spots/frog_backwater"
const OLD_OAK_PIER_VISUAL_PROFILE := {
	"profile_key": "old_oak_pier",
	"spot_id": "old_oak_pier",
	"visual_tag": "old_oak",
	"sky": OLD_OAK_PIER_ASSET_ROOT + "/old_oak_pier_sky.png",
	"background": OLD_OAK_PIER_ASSET_ROOT + "/old_oak_pier_scene.png",
	"show_water": false,
	"show_forest": false,
	"show_light_overlay": false,
	"show_foreground": false,
	"mist_enabled": false,
	"sky_rect": [0.05, 0.04, 0.90, 0.52],
	"horizon_y": 0.56,
	"sun_path_start": Vector2(0.12, 0.59),
	"sun_path_end": Vector2(0.90, 0.58),
	"moon_path_start": Vector2(0.18, 0.58),
	"moon_path_end": Vector2(0.84, 0.57),
	"sun_arc_height": 0.30,
	"moon_arc_height": 0.24
}
const QUIET_WATER_PIER_VISUAL_PROFILE := {
	"profile_key": "quiet_water_pier",
	"spot_id": "quiet_water_pier",
	"visual_tag": "quiet_water",
	"sky": QUIET_WATER_PIER_ASSET_ROOT + "/quiet_water_pier_sky.png",
	"background": QUIET_WATER_PIER_ASSET_ROOT + "/quiet_water_pier_scene.png",
	"water_shimmer": QUIET_WATER_PIER_ASSET_ROOT + "/quiet_water_pier_water.png",
	"foreground": QUIET_WATER_PIER_ASSET_ROOT + "/quiet_water_pier_foreground.png",
	"show_water": true,
	"show_forest": false,
	"show_light_overlay": false,
	"show_foreground": true,
	"mist_enabled": false,
	"sky_rect": [0.05, 0.05, 0.90, 0.53],
	"horizon_y": 0.58,
	"sun_path_start": Vector2(0.10, 0.61),
	"sun_path_end": Vector2(0.90, 0.60),
	"moon_path_start": Vector2(0.16, 0.60),
	"moon_path_end": Vector2(0.84, 0.58),
	"sun_arc_height": 0.31,
	"moon_arc_height": 0.24
}
const MORNING_PIER_VISUAL_PROFILE := {
	"profile_key": "morning_pier",
	"spot_id": "morning_pier",
	"visual_tag": "open_water",
	"sky": MORNING_PIER_ASSET_ROOT + "/morning_pier_sky.png",
	"background": MORNING_PIER_ASSET_ROOT + "/morning_pier_scene.png",
	"water_shimmer": MORNING_PIER_ASSET_ROOT + "/morning_pier_water.png",
	"foreground": MORNING_PIER_ASSET_ROOT + "/morning_pier_foreground.png",
	"show_water": true,
	"show_forest": false,
	"show_light_overlay": false,
	"show_foreground": true,
	"foreground_z": 5,
	"mist_enabled": false,
	"sky_rect": [0.04, 0.04, 0.92, 0.56],
	"horizon_y": 0.60,
	"sun_path_start": Vector2(0.08, 0.63),
	"sun_path_end": Vector2(0.92, 0.62),
	"moon_path_start": Vector2(0.14, 0.61),
	"moon_path_end": Vector2(0.86, 0.60),
	"sun_arc_height": 0.32,
	"moon_arc_height": 0.25
}
const OLD_BOAT_PIER_VISUAL_PROFILE := {
	"profile_key": "old_boat_pier",
	"spot_id": "old_boat_pier",
	"visual_tag": "snag_boat",
	"sky": OLD_BOAT_PIER_ASSET_ROOT + "/old_boat_pier_sky.png",
	"background": OLD_BOAT_PIER_ASSET_ROOT + "/old_boat_pier_scene.png",
	"water_shimmer": OLD_BOAT_PIER_ASSET_ROOT + "/old_boat_pier_water.png",
	"foreground": OLD_BOAT_PIER_ASSET_ROOT + "/old_boat_pier_foreground.png",
	"show_water": true,
	"show_forest": false,
	"show_light_overlay": false,
	"show_foreground": true,
	"foreground_z": 5,
	"mist_enabled": false,
	"sky_rect": [0.05, 0.05, 0.90, 0.52],
	"horizon_y": 0.57,
	"sun_path_start": Vector2(0.10, 0.60),
	"sun_path_end": Vector2(0.88, 0.59),
	"moon_path_start": Vector2(0.16, 0.58),
	"moon_path_end": Vector2(0.84, 0.57),
	"sun_arc_height": 0.30,
	"moon_arc_height": 0.24
}
const DEEP_PIER_VISUAL_PROFILE := {
	"profile_key": "deep_pier",
	"spot_id": "deep_pier",
	"visual_tag": "deep",
	"sky": DEEP_PIER_ASSET_ROOT + "/deep_pier_sky.png",
	"background": DEEP_PIER_ASSET_ROOT + "/deep_pier_scene.png",
	"water_shimmer": DEEP_PIER_ASSET_ROOT + "/deep_pier_water.png",
	"foreground": DEEP_PIER_ASSET_ROOT + "/deep_pier_foreground.png",
	"show_water": true,
	"show_forest": false,
	"show_light_overlay": false,
	"show_foreground": true,
	"foreground_z": 5,
	"celestial_z": 1,
	"sun_horizon_y_ratio": 0.37,
	"sun_size": 54.0,
	"mist_enabled": false,
	"sky_rect": [0.06, 0.04, 0.86, 0.48],
	"horizon_y": 0.52,
	"sun_path_start": Vector2(0.14, 0.55),
	"sun_path_end": Vector2(0.84, 0.53),
	"moon_path_start": Vector2(0.20, 0.53),
	"moon_path_end": Vector2(0.80, 0.51),
	"sun_arc_height": 0.28,
	"moon_arc_height": 0.22
}
const COLD_WATER_VISUAL_PROFILE := {
	"profile_key": "cold_water",
	"spot_id": "cold_water",
	"visual_tag": "cold_water",
	"sky": COLD_WATER_ASSET_ROOT + "/cold_water_sky.png",
	"background": COLD_WATER_ASSET_ROOT + "/cold_water_scene.png",
	"water_shimmer": COLD_WATER_ASSET_ROOT + "/cold_water_water.png",
	"foreground": COLD_WATER_ASSET_ROOT + "/cold_water_foreground.png",
	"show_water": true,
	"show_forest": false,
	"show_light_overlay": false,
	"show_foreground": true,
	"foreground_z": 5,
	"mist_enabled": false,
	"sky_rect": [0.05, 0.04, 0.90, 0.52],
	"horizon_y": 0.56,
	"sun_path_start": Vector2(0.10, 0.59),
	"sun_path_end": Vector2(0.88, 0.58),
	"moon_path_start": Vector2(0.16, 0.58),
	"moon_path_end": Vector2(0.84, 0.56),
	"sun_arc_height": 0.30,
	"moon_arc_height": 0.23
}
const DARK_HOLE_VISUAL_PROFILE := {
	"profile_key": "dark_hole",
	"spot_id": "dark_hole",
	"visual_tag": "deep_hole",
	"sky": DARK_HOLE_ASSET_ROOT + "/dark_hole_sky.png",
	"background": DARK_HOLE_ASSET_ROOT + "/dark_hole_scene.png",
	"water_shimmer": DARK_HOLE_ASSET_ROOT + "/dark_hole_water.png",
	"foreground": DARK_HOLE_ASSET_ROOT + "/dark_hole_foreground.png",
	"show_water": true,
	"show_forest": false,
	"show_light_overlay": false,
	"show_foreground": true,
	"foreground_z": 5,
	"mist_enabled": false,
	"sky_rect": [0.07, 0.04, 0.84, 0.50],
	"horizon_y": 0.54,
	"sun_path_start": Vector2(0.14, 0.57),
	"sun_path_end": Vector2(0.84, 0.56),
	"moon_path_start": Vector2(0.20, 0.55),
	"moon_path_end": Vector2(0.78, 0.53),
	"sun_arc_height": 0.28,
	"moon_arc_height": 0.22
}
const MIST_PIER_VISUAL_PROFILE := {
	"profile_key": "mist_pier",
	"spot_id": "mist_pier",
	"visual_tag": "mist",
	"sky": MIST_PIER_ASSET_ROOT + "/mostik_tuman_sky.png",
	"background": MIST_PIER_ASSET_ROOT + "/mostik_tuman_background.png",
	"foreground": MIST_PIER_ASSET_ROOT + "/mostik_tuman_foreground.png",
	"show_water": false,
	"show_forest": false,
	"show_light_overlay": false,
	"show_foreground": true,
	"foreground_z": 5,
	"mist_enabled": false,
	"sky_rect": [0.08, 0.05, 0.84, 0.52],
	"horizon_y": 0.57,
	"sun_path_start": Vector2(0.16, 0.60),
	"sun_path_end": Vector2(0.84, 0.59),
	"moon_path_start": Vector2(0.22, 0.58),
	"moon_path_end": Vector2(0.78, 0.56),
	"sun_arc_height": 0.27,
	"moon_arc_height": 0.22
}
const REEDS_PIER_VISUAL_PROFILE := {
	"profile_key": "reeds_pier",
	"spot_id": "reeds_pier",
	"visual_tag": "reeds",
	"sky": REEDS_PIER_ASSET_ROOT + "/kamishovi_most_sky.png",
	"background": REEDS_PIER_ASSET_ROOT + "/kamishovi_most_background.png",
	"foreground": REEDS_PIER_ASSET_ROOT + "/kamishovi_most_foreground.png",
	"show_water": false,
	"show_forest": false,
	"show_light_overlay": false,
	"show_foreground": true,
	"foreground_z": 5,
	"mist_enabled": false,
	"sky_rect": [0.05, 0.04, 0.90, 0.52],
	"horizon_y": 0.56,
	"sun_path_start": Vector2(0.10, 0.59),
	"sun_path_end": Vector2(0.90, 0.58),
	"moon_path_start": Vector2(0.16, 0.57),
	"moon_path_end": Vector2(0.84, 0.55),
	"sun_arc_height": 0.30,
	"moon_arc_height": 0.23
}
const GREEN_DUCKWEED_VISUAL_PROFILE := {
	"profile_key": "green_duckweed",
	"spot_id": "green_duckweed",
	"visual_tag": "duckweed",
	"sky": GREEN_DUCKWEED_ASSET_ROOT + "/green_duckweed_sky.png",
	"background": GREEN_DUCKWEED_ASSET_ROOT + "/green_duckweed_scene.png",
	"show_water": false,
	"show_forest": false,
	"show_light_overlay": false,
	"show_foreground": false,
	"celestial_z": 1,
	"sun_start_x_ratio": 0.56,
	"sun_end_x_ratio": 1.05,
	"sun_horizon_y_ratio": 0.30,
	"sun_size": 58.0,
	"moon_start_x_ratio": 0.54,
	"moon_end_x_ratio": 0.98,
	"moon_horizon_y_ratio": 0.31,
	"mist_enabled": false,
	"sky_rect": [0.34, 0.04, 0.62, 0.41],
	"horizon_y": 0.45,
	"sun_path_start": Vector2(0.38, 0.48),
	"sun_path_end": Vector2(0.98, 0.47),
	"moon_path_start": Vector2(0.36, 0.47),
	"moon_path_end": Vector2(0.94, 0.45),
	"sun_arc_height": 0.24,
	"moon_arc_height": 0.20
}
const FROG_BACKWATER_VISUAL_PROFILE := {
	"profile_key": "frog_backwater",
	"spot_id": "frog_backwater",
	"visual_tag": "frog_backwater",
	"sky": FROG_BACKWATER_ASSET_ROOT + "/frog_backwater_sky.png",
	"background": FROG_BACKWATER_ASSET_ROOT + "/frog_backwater_scene.png",
	"show_water": false,
	"show_forest": false,
	"show_light_overlay": false,
	"show_foreground": false,
	"mist_enabled": false,
	"sky_rect": [0.06, 0.04, 0.86, 0.50],
	"horizon_y": 0.54,
	"sun_path_start": Vector2(0.12, 0.57),
	"sun_path_end": Vector2(0.84, 0.56),
	"moon_path_start": Vector2(0.18, 0.55),
	"moon_path_end": Vector2(0.80, 0.53),
	"sun_arc_height": 0.28,
	"moon_arc_height": 0.22
}
const SPOT_VISUAL_PROFILES := {
	"old_oak_pier": OLD_OAK_PIER_VISUAL_PROFILE,
	"quiet_water_pier": QUIET_WATER_PIER_VISUAL_PROFILE,
	"morning_pier": MORNING_PIER_VISUAL_PROFILE,
	"old_boat_pier": OLD_BOAT_PIER_VISUAL_PROFILE,
	"deep_pier": DEEP_PIER_VISUAL_PROFILE,
	"cold_water": COLD_WATER_VISUAL_PROFILE,
	"dark_hole": DARK_HOLE_VISUAL_PROFILE,
	"mist_pier": MIST_PIER_VISUAL_PROFILE,
	"reeds_pier": REEDS_PIER_VISUAL_PROFILE,
	"green_duckweed": GREEN_DUCKWEED_VISUAL_PROFILE,
	"frog_backwater": FROG_BACKWATER_VISUAL_PROFILE
}
const VISUAL_TAG_VISUAL_PROFILES := {
	"old_oak": OLD_OAK_PIER_VISUAL_PROFILE,
	"quiet_water": QUIET_WATER_PIER_VISUAL_PROFILE,
	"open_water": MORNING_PIER_VISUAL_PROFILE,
	"snag_boat": OLD_BOAT_PIER_VISUAL_PROFILE,
	"deep": DEEP_PIER_VISUAL_PROFILE,
	"cold_water": COLD_WATER_VISUAL_PROFILE,
	"deep_hole": DARK_HOLE_VISUAL_PROFILE,
	"mist": MIST_PIER_VISUAL_PROFILE,
	"reeds": REEDS_PIER_VISUAL_PROFILE,
	"duckweed": GREEN_DUCKWEED_VISUAL_PROFILE,
	"frog_backwater": FROG_BACKWATER_VISUAL_PROFILE
}

const MINUTES_PER_DAY := 1440.0
const DAWN_START := 300.0
const DAY_START := 480.0
const SUNSET_START := 1080.0
const NIGHT_START := 1260.0
const CELESTIAL_LAYER_Z := 1
const STARS_LAYER_Z := 0
const MOON_SPRITE_Z := 0
const SUN_SPRITE_Z := 0
const MOUNTAINS_LAYER_Z := 2
const SKY_REFERENCE_SIZE := Vector2(960.0, 540.0)
const CELESTIAL_HORIZON_FADE_RATIO := 0.065
const CELESTIAL_HORIZON_CLAMP_MARGIN_RATIO := 0.012
const SKY_DEBUG_RECT_Z := 18
const HORIZON_DEBUG_LINE_Z := 19

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
var _light_overlay_layer: TextureRect
var _night_tint_overlay: ColorRect
var _sunset_tint_overlay: ColorRect
var _foreground_grass_layer: TextureRect
var _sky_debug_rect: Panel
var _horizon_debug_line: ColorRect
var _last_debug_phase := ""
var _last_debug_viewport := Vector2.ZERO
var _warned_missing_visual_paths := {}

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
	z_as_relative = false
	z_index = -110

	for rect in [
		_sky_layer,
		_mountains_layer,
		_forest_layer,
		_water_layer,
		_light_overlay_layer,
		_night_tint_overlay,
		_sunset_tint_overlay,
		_foreground_grass_layer
	]:
		if rect == null:
			continue
		rect.position = Vector2.ZERO
		rect.size = screen_size
		if rect is TextureRect:
			(rect as TextureRect).expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			(rect as TextureRect).stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

	var visual_profile := _get_current_visual_profile()
	_apply_visual_profile_layout(visual_profile, screen_size)

	if _stars_layer != null and _stars_layer.has_method("set_viewport_size"):
		_stars_layer.call("set_viewport_size", screen_size)
	if _stars_layer != null and _stars_layer.has_method("set_horizon_y_ratio"):
		_stars_layer.call("set_horizon_y_ratio", _get_sky_horizon_y_ratio(visual_profile))

	_update_sky_debug_overlay(visual_profile)
	_debug_print_layout()
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
	_update_sky_debug_overlay(_get_current_visual_profile())

func update_sun_position(minutes: float) -> void:
	if not show_dynamic_sun:
		_sun_sprite.visible = false
		return

	var sun_t: float = clampf((minutes - DAWN_START) / maxf(NIGHT_START - DAWN_START, 1.0), 0.0, 1.0)
	var sun_alpha: float = _fade_between(minutes, DAWN_START, DAWN_START + 105.0) * (1.0 - _fade_between(minutes, NIGHT_START - 120.0, NIGHT_START))
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
	var visual_profile := _get_current_visual_profile()
	var profile_sun_arc_height := _get_profile_float(visual_profile, "sun_arc_height", sun_arc_height)
	var profile_sun_size := _get_profile_float(visual_profile, "sun_size", sun_size)
	var screen_scale: float = clampf(_viewport_size.y / 540.0, 0.82, 1.35)
	var target_size: float = profile_sun_size * screen_scale
	var position_data: Dictionary = _get_celestial_position_data(sun_t, profile_sun_arc_height, false, visual_profile, target_size)
	var position: Vector2 = position_data["position"] as Vector2
	var horizon_alpha: float = float(position_data.get("horizon_alpha", 1.0))
	var sun_color := Color(1.10, lerpf(1.04, 0.82, sun_warmth), lerpf(0.92, 0.54, sun_warmth), 1.0)
	var halo_color := Color(1.0, lerpf(0.92, 0.70, sun_warmth), lerpf(0.66, 0.36, sun_warmth), 1.0)
	var material := _sun_sprite.material as ShaderMaterial
	if material != null:
		material.set_shader_parameter("light_color", sun_color)
		material.set_shader_parameter("halo_color", halo_color)
		material.set_shader_parameter("texture_mix", lerpf(0.0, 0.010, sun_warmth))
		material.set_shader_parameter("halo_strength", lerpf(0.78, 0.92, sun_warmth))
		material.set_shader_parameter("ray_strength", lerpf(0.12, 0.18, sun_warmth))

	_sun_sprite.position = position
	_sun_sprite.scale = _get_sprite_uniform_scale(_sun_sprite, target_size)
	_sun_sprite.visible = sun_alpha * horizon_alpha > 0.01
	_sun_sprite.modulate = Color(
		1.0,
		1.0,
		1.0,
		sun_alpha * disk_visibility * horizon_alpha
	)

func update_moon_position(minutes: float) -> void:
	var night_length: float = MINUTES_PER_DAY - NIGHT_START + DAWN_START
	var moon_minutes: float = minutes - NIGHT_START if minutes >= NIGHT_START else minutes + MINUTES_PER_DAY - NIGHT_START
	var moon_t: float = clampf(moon_minutes / maxf(night_length, 1.0), 0.0, 1.0)
	var moon_alpha: float = _fade_between(moon_minutes, 0.0, 105.0) * (1.0 - _fade_between(moon_minutes, night_length - 105.0, night_length))
	var visual_profile := _get_current_visual_profile()
	var profile_moon_arc_height := _get_profile_float(visual_profile, "moon_arc_height", moon_arc_height)
	var profile_moon_size := _get_profile_float(visual_profile, "moon_size", moon_size)
	var screen_scale: float = clampf(_viewport_size.y / 540.0, 0.82, 1.35)
	var target_size: float = profile_moon_size * screen_scale
	var position_data: Dictionary = _get_celestial_position_data(moon_t, profile_moon_arc_height, true, visual_profile, target_size)
	var position: Vector2 = position_data["position"] as Vector2
	var horizon_alpha: float = float(position_data.get("horizon_alpha", 1.0))

	_moon_sprite.position = position
	_moon_sprite.scale = _get_sprite_uniform_scale(_moon_sprite, target_size)
	_moon_sprite.visible = moon_alpha * horizon_alpha > 0.01
	_moon_sprite.modulate = Color(0.80, 0.90, 1.0, moon_alpha * horizon_alpha * 0.92)

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
	var light_warmth: float = clampf(sunset_strength, 0.0, 1.0)
	_light_overlay_layer.modulate = Color(1.0, lerpf(0.96, 0.82, light_warmth), lerpf(0.82, 0.58, light_warmth), light_alpha)
	_foreground_grass_layer.modulate = land_modulate.lerp(Color(0.28, 0.40, 0.52, 1.0), night_strength * 0.18)
	_apply_sunset_tint(sunset_strength)
	_apply_night_tint(night_strength)
	_debug_print_visual_state(minutes, _phase, night_strength, sunset_strength, light_alpha)

func _apply_sunset_tint(sunset_strength: float) -> void:
	var strength: float = clampf(sunset_strength * sunset_tint_strength, 0.0, 1.0)
	var active_horizon_y: float = _get_sky_horizon_y_ratio(_get_current_visual_profile())
	var material := _sunset_tint_overlay.material as ShaderMaterial
	if material != null:
		material.set_shader_parameter("tint_color", Color(1.0, 0.46, 0.16, 1.0))
		material.set_shader_parameter("strength", strength)
		material.set_shader_parameter("horizon_y", active_horizon_y)
		_sunset_tint_overlay.color = Color.WHITE
		return

	_sunset_tint_overlay.color = Color(1.0, 0.46, 0.16, strength * 0.42)

func _apply_night_tint(night_strength: float) -> void:
	var strength: float = clampf(night_strength * night_tint_strength, 0.0, 1.0)
	var active_horizon_y: float = _get_sky_horizon_y_ratio(_get_current_visual_profile())
	var material := _night_tint_overlay.material as ShaderMaterial
	if material != null:
		material.set_shader_parameter("tint_color", Color(0.02, 0.05, 0.13, 1.0))
		material.set_shader_parameter("strength", strength)
		material.set_shader_parameter("horizon_y", active_horizon_y)
		material.set_shader_parameter("water_relief", 0.86)
		_night_tint_overlay.color = Color.WHITE
		return

	_night_tint_overlay.color = Color(0.02, 0.05, 0.13, strength * 0.88)

func get_time_phase(minutes: float = -1.0) -> String:
	var current_minutes: float = _get_current_game_minutes() if minutes < 0.0 else fposmod(minutes, MINUTES_PER_DAY)
	if current_minutes >= DAWN_START and current_minutes < DAY_START:
		return "dawn"
	if current_minutes >= DAY_START and current_minutes < SUNSET_START:
		return "day"
	if current_minutes >= SUNSET_START and current_minutes < NIGHT_START:
		return "sunset"
	return "night"

func get_celestial_position(
	phase_t: float,
	arc_height: float,
	moon: bool = false,
	profile: Dictionary = {}
) -> Vector2:
	var data: Dictionary = _get_celestial_position_data(phase_t, arc_height, moon, profile)
	return data["position"] as Vector2

func _get_celestial_position_data(
	phase_t: float,
	arc_height: float,
	moon: bool = false,
	profile: Dictionary = {},
	target_size: float = 0.0
) -> Dictionary:
	if _viewport_size == Vector2.ZERO:
		_viewport_size = get_viewport_rect().size

	var active_profile := profile
	if active_profile.is_empty():
		active_profile = _get_current_visual_profile()
	var safe_t: float = clampf(phase_t, 0.0, 1.0)
	var old_horizon_ratio := _get_profile_float(
		active_profile,
		"moon_horizon_y_ratio" if moon else "sun_horizon_y_ratio",
		moon_horizon_y_ratio if moon else sun_horizon_y_ratio
	)
	var start_x_ratio := _get_profile_float(
		active_profile,
		"moon_start_x_ratio" if moon else "sun_start_x_ratio",
		moon_start_x_ratio if moon else sun_start_x_ratio
	)
	var end_x_ratio := _get_profile_float(
		active_profile,
		"moon_end_x_ratio" if moon else "sun_end_x_ratio",
		moon_end_x_ratio if moon else sun_end_x_ratio
	)
	var horizon_y: float = _get_sky_horizon_y(active_profile)
	var sky_rect: Rect2 = _get_sky_rect(active_profile)
	var start_point: Vector2 = _get_celestial_path_point(
		active_profile,
		"moon_path_start" if moon else "sun_path_start",
		start_x_ratio,
		old_horizon_ratio,
		sky_rect,
		horizon_y
	)
	var end_point: Vector2 = _get_celestial_path_point(
		active_profile,
		"moon_path_end" if moon else "sun_path_end",
		end_x_ratio,
		old_horizon_ratio,
		sky_rect,
		horizon_y
	)
	var raw_position: Vector2 = start_point.lerp(end_point, safe_t)
	var arc: float = sin(safe_t * PI)
	var arc_pixels: float = minf(_viewport_size.y * arc_height, maxf(sky_rect.size.y * 0.92, 1.0))
	raw_position.y -= arc * arc_pixels
	if moon:
		raw_position.y -= minf(_viewport_size.y * 0.035, sky_rect.size.y * 0.12)

	var horizon_alpha: float = _get_celestial_horizon_visibility(raw_position.y, horizon_y, target_size)
	var position: Vector2 = raw_position
	position.x = clampf(position.x, sky_rect.position.x, sky_rect.end.x)
	var top_limit: float = sky_rect.position.y + maxf(target_size * 0.18, _viewport_size.y * 0.015)
	var bottom_limit: float = minf(horizon_y - maxf(1.0, target_size * 0.10), sky_rect.end.y - 1.0)
	if bottom_limit < top_limit:
		bottom_limit = top_limit
	position.y = clampf(position.y, top_limit, bottom_limit)
	return {
		"position": position,
		"raw_position": raw_position,
		"horizon_alpha": horizon_alpha,
		"sky_rect": sky_rect,
		"horizon_y": horizon_y
	}

func _get_celestial_horizon_visibility(raw_y: float, profile_horizon_y: float, target_size: float) -> float:
	var fade_distance: float = maxf(_viewport_size.y * CELESTIAL_HORIZON_FADE_RATIO, target_size * 0.85)
	var fade_start: float = profile_horizon_y - maxf(target_size * 0.32, _viewport_size.y * CELESTIAL_HORIZON_CLAMP_MARGIN_RATIO)
	var fade_end: float = profile_horizon_y + fade_distance
	return 1.0 - _fade_between(raw_y, fade_start, fade_end)

func _get_celestial_path_point(
	profile: Dictionary,
	key: String,
	fallback_x_ratio: float,
	fallback_y_ratio: float,
	sky_rect: Rect2,
	profile_horizon_y: float
) -> Vector2:
	var point := Vector2(_viewport_size.x * fallback_x_ratio, _viewport_size.y * fallback_y_ratio)
	if profile.has(key):
		var raw_value: Variant = profile.get(key)
		if raw_value is Vector2:
			point = _scale_sky_point(raw_value as Vector2)
		elif raw_value is Array:
			var raw_array := raw_value as Array
			if raw_array.size() >= 2:
				point = _scale_sky_point(Vector2(float(raw_array[0]), float(raw_array[1])))

	var lower_limit: float = profile_horizon_y + maxf(_viewport_size.y * CELESTIAL_HORIZON_FADE_RATIO, 1.0)
	point.x = clampf(point.x, sky_rect.position.x, sky_rect.end.x)
	point.y = clampf(point.y, sky_rect.position.y, lower_limit)
	return point

func _get_sky_rect(profile: Dictionary) -> Rect2:
	var horizon_y: float = _get_sky_horizon_y(profile)
	var sky_top: float = _viewport_size.y * 0.04
	var default_rect := Rect2(
		Vector2(_viewport_size.x * sky_padding_ratio, sky_top),
		Vector2(_viewport_size.x * maxf(1.0 - sky_padding_ratio * 2.0, 0.20), maxf(horizon_y - sky_top, _viewport_size.y * 0.24))
	)
	var rect := default_rect
	if profile.has("sky_rect"):
		var raw_value: Variant = profile.get("sky_rect")
		if raw_value is Rect2:
			rect = _scale_sky_rect(raw_value as Rect2)
		elif raw_value is Array:
			var raw_array := raw_value as Array
			if raw_array.size() >= 4:
				rect = _scale_sky_rect(Rect2(
					Vector2(float(raw_array[0]), float(raw_array[1])),
					Vector2(float(raw_array[2]), float(raw_array[3]))
				))

	rect.position.x = clampf(rect.position.x, 0.0, maxf(_viewport_size.x - 1.0, 0.0))
	rect.position.y = clampf(rect.position.y, 0.0, maxf(_viewport_size.y - 1.0, 0.0))
	rect.size.x = clampf(rect.size.x, _viewport_size.x * 0.12, _viewport_size.x - rect.position.x)
	rect.size.y = clampf(rect.size.y, _viewport_size.y * 0.12, _viewport_size.y - rect.position.y)
	var horizon_bottom: float = minf(horizon_y, _viewport_size.y)
	if rect.end.y > horizon_bottom:
		rect.size.y = maxf(horizon_bottom - rect.position.y, _viewport_size.y * 0.12)
	return rect

func _get_sky_horizon_y(profile: Dictionary) -> float:
	return _viewport_size.y * _get_sky_horizon_y_ratio(profile)

func _get_sky_horizon_y_ratio(profile: Dictionary) -> float:
	if profile.has("horizon_y"):
		var raw_horizon: float = float(profile.get("horizon_y"))
		if raw_horizon <= 1.5:
			return clampf(raw_horizon, 0.20, 0.86)
		var screen_height: float = _viewport_size.y if _viewport_size.y > 0.0 else get_viewport_rect().size.y
		return clampf(raw_horizon / maxf(screen_height, 1.0), 0.20, 0.86)
	return clampf(_get_profile_float(profile, "horizon_y_ratio", horizon_y_ratio), 0.20, 0.86)

func _scale_sky_point(point: Vector2) -> Vector2:
	if absf(point.x) <= 1.5 and absf(point.y) <= 1.5:
		return Vector2(point.x * _viewport_size.x, point.y * _viewport_size.y)
	return Vector2(point.x * _viewport_size.x / SKY_REFERENCE_SIZE.x, point.y * _viewport_size.y / SKY_REFERENCE_SIZE.y)

func _scale_sky_rect(rect: Rect2) -> Rect2:
	var position := _scale_sky_point(rect.position)
	var size: Vector2
	if absf(rect.size.x) <= 1.5 and absf(rect.size.y) <= 1.5:
		size = Vector2(rect.size.x * _viewport_size.x, rect.size.y * _viewport_size.y)
	else:
		size = Vector2(rect.size.x * _viewport_size.x / SKY_REFERENCE_SIZE.x, rect.size.y * _viewport_size.y / SKY_REFERENCE_SIZE.y)
	return Rect2(position, size)

func _ensure_nodes() -> void:
	z_as_relative = false
	z_index = -110

	if _environment_root == null:
		_environment_root = Node2D.new()
		_environment_root.name = "EnvironmentRoot"
		add_child(_environment_root)

	var visual_profile := _get_current_visual_profile()
	var sky_path := _get_profile_texture_path(visual_profile, "sky", SKY_PATH, "sky")
	var background_path := _get_profile_texture_path(visual_profile, "background", MOUNTAINS_PATH, "background")
	var forest_path := _get_profile_texture_path(visual_profile, "forest", FOREST_PATH, "forest")
	var water_path := _get_profile_texture_path(visual_profile, "water_shimmer", WATER_PATH, "water_shimmer")
	var light_overlay_path := _get_profile_texture_path(visual_profile, "light_overlay", LIGHT_OVERLAY_PATH, "light_overlay")
	var foreground_path := _get_profile_texture_path(
		visual_profile,
		"foreground",
		FOREGROUND_GRASS_PATH,
		"foreground"
	)

	_sky_layer = _ensure_texture_layer(_sky_layer, "SkyLayer", sky_path, 0)

	if _celestial_layer == null:
		_celestial_layer = Node2D.new()
		_celestial_layer.name = "CelestialLayer"
		_environment_root.add_child(_celestial_layer)
	_celestial_layer.z_as_relative = true
	_celestial_layer.z_index = int(visual_profile.get("celestial_z", CELESTIAL_LAYER_Z))

	if _stars_layer == null:
		_stars_layer = StarsLayerScript.new()
		_stars_layer.name = "StarsLayer"
		_stars_layer.set("star_count", star_count)
		_stars_layer.set("max_alpha", 1.0)
		_celestial_layer.add_child(_stars_layer)
	_stars_layer.z_as_relative = true
	_stars_layer.z_index = STARS_LAYER_Z

	if _sun_sprite == null:
		_sun_sprite = _ensure_sprite("SunSprite", SUN_PATH, SUN_SPRITE_Z)
		_sun_sprite.material = _make_sun_disc_material()
	_sun_sprite.z_as_relative = true
	_sun_sprite.z_index = SUN_SPRITE_Z

	if _moon_sprite == null:
		_moon_sprite = _ensure_sprite("MoonSprite", MOON_PATH, MOON_SPRITE_Z)
	_moon_sprite.z_as_relative = true
	_moon_sprite.z_index = MOON_SPRITE_Z

	_mountains_layer = _ensure_texture_layer(_mountains_layer, "MountainsLayer", background_path, MOUNTAINS_LAYER_Z)
	_forest_layer = _ensure_texture_layer(_forest_layer, "ForestLayer", forest_path, 3)
	_water_layer = _ensure_texture_layer(_water_layer, "WaterLayer", water_path, 4)
	_light_overlay_layer = _ensure_texture_layer(_light_overlay_layer, "LightOverlayLayer", light_overlay_path, 5)
	_sunset_tint_overlay = _ensure_color_layer(_sunset_tint_overlay, "SunsetTintOverlay", 7)
	_night_tint_overlay = _ensure_color_layer(_night_tint_overlay, "NightTintOverlay", 8)
	_foreground_grass_layer = _ensure_texture_layer(_foreground_grass_layer, "ForegroundGrassLayer", foreground_path, 9)
	_apply_visual_profile_state(visual_profile)
	if _viewport_size != Vector2.ZERO:
		_apply_visual_profile_layout(visual_profile, _viewport_size)
	if _sunset_tint_overlay.material == null:
		_sunset_tint_overlay.material = _make_sunset_tint_material()
	if _night_tint_overlay.material == null:
		_night_tint_overlay.material = _make_night_tint_material()

func _ensure_texture_layer(layer: TextureRect, layer_name: String, path: String, z: int) -> TextureRect:
	if layer == null:
		layer = TextureRect.new()
		layer.name = layer_name
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_environment_root.add_child(layer)

	layer.z_as_relative = true
	layer.z_index = z
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	var current_path := str(layer.get_meta("environment_texture_path", ""))
	if layer.texture == null or current_path != path:
		layer.texture = _load_texture(path)
		layer.set_meta("environment_texture_path", path)
		if layer.texture == null:
			push_warning("Environment texture is missing: %s" % path)

	layer.visible = layer.texture != null

	return layer

func _ensure_color_layer(layer: ColorRect, layer_name: String, z: int) -> ColorRect:
	if layer == null:
		layer = ColorRect.new()
		layer.name = layer_name
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.color = Color.TRANSPARENT
		_environment_root.add_child(layer)

	layer.z_as_relative = true
	layer.z_index = z
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

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

func _get_current_visual_profile() -> Dictionary:
	var spot := _get_current_spot_data()
	var spot_id := str(spot.get("id", ""))
	if SPOT_VISUAL_PROFILES.has(spot_id):
		return (SPOT_VISUAL_PROFILES[spot_id] as Dictionary).duplicate(true)

	var visual_tag := str(spot.get("visual_tag", ""))
	if VISUAL_TAG_VISUAL_PROFILES.has(visual_tag):
		return (VISUAL_TAG_VISUAL_PROFILES[visual_tag] as Dictionary).duplicate(true)

	return {
		"profile_key": "default",
		"show_forest": true,
		"show_light_overlay": true,
		"mist_enabled": false
	}

func _get_current_spot_data() -> Dictionary:
	var player_data := get_node_or_null("/root/PlayerData")
	var spot_database := get_node_or_null("/root/SpotDatabase")
	var spot_id := ""
	if player_data != null:
		spot_id = str(player_data.get("current_spot"))

	if spot_database != null and spot_database.has_method("get_spot") and spot_id != "":
		var raw_spot = spot_database.call("get_spot", spot_id)
		if typeof(raw_spot) == TYPE_DICTIONARY:
			return raw_spot

	return {"id": spot_id}

func _get_profile_float(profile: Dictionary, key: String, default_value: float) -> float:
	if profile.has(key):
		return float(profile.get(key))

	return default_value

func _get_profile_texture_path(
	profile: Dictionary,
	key: String,
	default_path: String,
	label: String,
	extra_fallbacks: Array = []
) -> String:
	var requested_path := str(profile.get(key, ""))
	var candidates := []
	if requested_path != "":
		candidates.append(requested_path)
	for fallback_path in extra_fallbacks:
		candidates.append(str(fallback_path))
	candidates.append(default_path)

	var resolved_path := _resolve_texture_path(candidates)
	if requested_path != "" and resolved_path != requested_path:
		_warn_missing_visual_asset(label, requested_path, resolved_path)

	return resolved_path

func _warn_missing_visual_asset(label: String, requested_path: String, fallback_path: String) -> void:
	var warning_key := "%s|%s" % [label, requested_path]
	if _warned_missing_visual_paths.has(warning_key):
		return

	_warned_missing_visual_paths[warning_key] = true
	push_warning(
		"Missing environment asset for %s: %s. Using fallback: %s" %
		[label, requested_path, fallback_path]
	)

func _apply_visual_profile_state(profile: Dictionary) -> void:
	var profile_key := str(profile.get("profile_key", "default"))
	var uses_spot_profile := profile_key != "default"

	if _forest_layer != null:
		_forest_layer.visible = _forest_layer.texture != null and bool(profile.get("show_forest", true))
	if _water_layer != null:
		_water_layer.visible = _water_layer.texture != null and bool(profile.get("show_water", true))
	if _light_overlay_layer != null:
		_light_overlay_layer.visible = _light_overlay_layer.texture != null and bool(profile.get("show_light_overlay", true))
	if _foreground_grass_layer != null:
		_foreground_grass_layer.visible = _foreground_grass_layer.texture != null and bool(profile.get("show_foreground", true))

	if remove_static_sun_from_art and not uses_spot_profile:
		_set_static_sun_layer_material(_mountains_layer, "static_sun_mountains", "mountains")
		_set_static_sun_layer_material(_water_layer, "static_sun_water", "water")
		_set_static_sun_layer_material(_light_overlay_layer, "static_sun_light", "light")
	else:
		_set_layer_material(_mountains_layer, "none", null)
		_set_layer_material(_water_layer, "none", null)
		_set_layer_material(_light_overlay_layer, "none", null)

	if str(profile.get("foreground_material", "")) == "mist_pier_cutout":
		_set_mist_pier_foreground_material(_foreground_grass_layer)
	elif str(profile.get("foreground_material", "")) == "reeds_foreground_cutout":
		_set_reeds_foreground_material(_foreground_grass_layer)
	else:
		_set_layer_material(_foreground_grass_layer, "none", null)

func _apply_visual_profile_layout(profile: Dictionary, screen_size: Vector2) -> void:
	if _foreground_grass_layer != null:
		_foreground_grass_layer.z_index = int(profile.get("foreground_z", 9))
		if bool(profile.get("foreground_stretch_scale", false)):
			_foreground_grass_layer.stretch_mode = TextureRect.STRETCH_SCALE

	if _water_layer == null or not profile.has("water_rect"):
		return

	var rect_data: Array = profile.get("water_rect", [])
	if rect_data.size() < 4:
		return

	_water_layer.position = Vector2(float(rect_data[0]) * screen_size.x, float(rect_data[1]) * screen_size.y)
	_water_layer.size = Vector2(float(rect_data[2]) * screen_size.x, float(rect_data[3]) * screen_size.y)
	_water_layer.z_as_relative = true
	_water_layer.z_index = int(profile.get("water_z", _water_layer.z_index))
	if bool(profile.get("water_under_spot_layers", false)):
		_move_water_under_spot_layers()
	if bool(profile.get("water_stretch_scale", false)):
		_water_layer.stretch_mode = TextureRect.STRETCH_SCALE

func _is_sky_debug_enabled() -> bool:
	return BuildConfig.ENABLE_DEBUG_PANEL or (SHOW_ENVIRONMENT_DEBUG and BuildConfig.ENABLE_VERBOSE_LOGS)

func _ensure_sky_debug_nodes() -> void:
	if _environment_root == null:
		return
	if _sky_debug_rect == null:
		_sky_debug_rect = Panel.new()
		_sky_debug_rect.name = "SkyDebugRect"
		_sky_debug_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_sky_debug_rect.z_as_relative = true
		_sky_debug_rect.z_index = SKY_DEBUG_RECT_Z
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.20, 0.58, 1.0, 0.06)
		style.border_color = Color(0.42, 0.78, 1.0, 0.50)
		style.set_border_width_all(2)
		_sky_debug_rect.add_theme_stylebox_override("panel", style)
		_environment_root.add_child(_sky_debug_rect)
	if _horizon_debug_line == null:
		_horizon_debug_line = ColorRect.new()
		_horizon_debug_line.name = "HorizonDebugLine"
		_horizon_debug_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_horizon_debug_line.color = Color(1.0, 0.74, 0.24, 0.70)
		_horizon_debug_line.z_as_relative = true
		_horizon_debug_line.z_index = HORIZON_DEBUG_LINE_Z
		_environment_root.add_child(_horizon_debug_line)

func _update_sky_debug_overlay(profile: Dictionary) -> void:
	if not _is_sky_debug_enabled():
		if _sky_debug_rect != null:
			_sky_debug_rect.visible = false
		if _horizon_debug_line != null:
			_horizon_debug_line.visible = false
		return
	if _viewport_size == Vector2.ZERO:
		_viewport_size = get_viewport_rect().size
	_ensure_sky_debug_nodes()
	if _sky_debug_rect == null or _horizon_debug_line == null:
		return
	var sky_rect: Rect2 = _get_sky_rect(profile)
	var horizon_y: float = _get_sky_horizon_y(profile)
	_sky_debug_rect.position = sky_rect.position
	_sky_debug_rect.size = sky_rect.size
	_sky_debug_rect.visible = true
	_horizon_debug_line.position = Vector2(0.0, horizon_y)
	_horizon_debug_line.size = Vector2(_viewport_size.x, maxf(2.0, _viewport_size.y * 0.003))
	_horizon_debug_line.visible = true

func _move_water_under_spot_layers() -> void:
	if _environment_root == null or _sky_layer == null or _water_layer == null:
		return
	if _water_layer.get_parent() != _environment_root or _sky_layer.get_parent() != _environment_root:
		return

	if _water_layer.get_index() != 0:
		_environment_root.move_child(_water_layer, 0)

func _set_static_sun_layer_material(layer: CanvasItem, material_key: String, layer_kind: String) -> void:
	if layer == null:
		return
	if str(layer.get_meta("environment_material_key", "")) == material_key:
		return

	_set_layer_material(layer, material_key, _make_static_sun_removal_material(layer_kind))

func _set_mist_pier_foreground_material(layer: CanvasItem) -> void:
	if layer == null:
		return
	var material_key := "mist_pier_foreground_cutout"
	if str(layer.get_meta("environment_material_key", "")) == material_key:
		return

	_set_layer_material(layer, material_key, _make_mist_pier_foreground_material())

func _set_reeds_foreground_material(layer: CanvasItem) -> void:
	if layer == null:
		return
	var material_key := "reeds_foreground_cutout"
	if str(layer.get_meta("environment_material_key", "")) == material_key:
		return

	_set_layer_material(layer, material_key, _make_reeds_foreground_material())

func _set_layer_material(layer: CanvasItem, material_key: String, material: Material) -> void:
	if layer == null:
		return
	if str(layer.get_meta("environment_material_key", "")) == material_key:
		return

	layer.material = material
	layer.set_meta("environment_material_key", material_key)

func _make_sun_disc_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
		shader_type canvas_item;

		uniform vec4 light_color : source_color = vec4(1.0, 0.84, 0.50, 1.0);
		uniform vec4 halo_color : source_color = vec4(1.0, 0.78, 0.42, 1.0);
		uniform float texture_mix = 0.02;
		uniform float halo_strength = 0.62;
		uniform float ray_strength = 0.10;

		void fragment() {
			vec4 vertex_color = COLOR;
			vec4 tex = texture(TEXTURE, UV);
			vec2 centered = UV * 2.0 - 1.0;
			float dist = length(centered);
			float white_core = 1.0 - smoothstep(0.00, 0.23, dist);
			float soft_body = 1.0 - smoothstep(0.10, 0.54, dist);
			float soft_halo = 1.0 - smoothstep(0.22, 1.02, dist);
			float outer_glow = 1.0 - smoothstep(0.45, 1.22, dist);
			float horizontal_ray = (1.0 - smoothstep(0.0, 0.13, abs(centered.y))) * (1.0 - smoothstep(0.20, 1.08, abs(centered.x)));
			float diagonal_ray = (1.0 - smoothstep(0.0, 0.10, abs(centered.x + centered.y * 0.72))) * (1.0 - smoothstep(0.12, 0.98, dist));
			float ray = (horizontal_ray * 0.45 + diagonal_ray * 0.20) * ray_strength;
			vec3 texture_detail = mix(vec3(1.0), tex.rgb, texture_mix * (1.0 - white_core * 0.80));
			vec3 body_color = mix(halo_color.rgb, light_color.rgb, clamp(white_core + soft_body * 0.44, 0.0, 1.0));
			vec3 color = body_color * texture_detail + halo_color.rgb * (soft_halo * 0.18 + outer_glow * 0.16 + ray * 0.22);
			float alpha = clamp(white_core * 0.88 + soft_body * 0.62 + soft_halo * halo_strength * 0.38 + outer_glow * 0.20 + ray, 0.0, 1.0);
			COLOR = vec4(color * vertex_color.rgb, alpha * vertex_color.a * light_color.a);
		}
	"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _make_static_sun_removal_material(layer_kind: String) -> ShaderMaterial:
	var shader := Shader.new()
	match layer_kind:
		"mountains":
			shader.code = """
				shader_type canvas_item;

				void fragment() {
					vec4 vertex_color = COLOR;
					vec4 tex = texture(TEXTURE, UV);
					vec2 sun_uv = vec2(0.255, 0.535);
					vec2 to_sun = (UV - sun_uv) * vec2(1.0, 1.32);
					float disk = 1.0 - smoothstep(0.010, 0.050, length(to_sun));
					float glow = 1.0 - smoothstep(0.035, 0.230, length(to_sun));
					float horizon_wash = 1.0 - smoothstep(0.0, 0.360, abs(UV.x - sun_uv.x));
					horizon_wash *= 1.0 - smoothstep(0.0, 0.125, abs(UV.y - sun_uv.y));
					float mask = clamp(max(disk, glow * 0.82) + horizon_wash * 0.42, 0.0, 1.0);
					float luminance = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
					float max_channel = max(tex.r, max(tex.g, tex.b));
					float min_channel = min(tex.r, min(tex.g, tex.b));
					float saturation = (max_channel - min_channel) / max(max_channel, 0.001);
					float lower_artifact = smoothstep(0.62, 0.72, UV.y) * smoothstep(0.28, 0.58, luminance) * smoothstep(0.18, 0.46, saturation);
					vec3 cooled = mix(vec3(luminance) * vec3(0.66, 0.72, 0.80), vec3(0.38, 0.47, 0.54), 0.38);
					tex.rgb = mix(tex.rgb, cooled, mask * 0.88);
					tex.a *= 1.0 - clamp(disk * 0.98 + glow * 0.70 + horizon_wash * 0.28, 0.0, 0.96);
					tex.a *= 1.0 - clamp(lower_artifact * 0.96, 0.0, 0.96);
					COLOR = tex * vertex_color;
				}
			"""
		"water":
			shader.code = """
				shader_type canvas_item;

				void fragment() {
					vec4 vertex_color = COLOR;
					vec4 tex = texture(TEXTURE, UV);
					float water_area = smoothstep(0.700, 0.755, UV.y);
					float lane = 1.0 - smoothstep(0.0, 0.175, abs(UV.x - 0.415));
					lane *= smoothstep(0.610, 0.710, UV.y) * (1.0 - smoothstep(0.930, 1.0, UV.y));
					float source_glow = 1.0 - smoothstep(0.0, 0.200, distance((UV - vec2(0.410, 0.735)) * vec2(1.0, 0.58)));
					float mask = clamp(max(lane * 0.78, source_glow * 0.64), 0.0, 1.0);
					float luminance = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
					vec3 cooled = mix(tex.rgb * vec3(0.58, 0.70, 0.84), vec3(luminance) * vec3(0.62, 0.70, 0.78), 0.45);
					tex.rgb = mix(tex.rgb, cooled, mask * 0.78);
					tex.a *= water_area * (1.0 - mask * 0.16);
					COLOR = tex * vertex_color;
				}
			"""
		_:
			shader.code = """
				shader_type canvas_item;

				void fragment() {
					vec4 vertex_color = COLOR;
					vec4 tex = texture(TEXTURE, UV);
					float source = 1.0 - smoothstep(0.0, 0.330, distance(UV, vec2(0.055, 0.080)));
					float ray_band = 1.0 - smoothstep(0.0, 0.250, abs((UV.y - 0.08) - UV.x * 0.28));
					ray_band *= 1.0 - smoothstep(0.0, 0.520, UV.x);
					float mask = clamp(max(source * 0.90, ray_band * 0.34), 0.0, 1.0);
					tex.a *= 0.72;
					tex.a *= 1.0 - mask * 0.96;
					COLOR = tex * vertex_color;
				}
			"""

	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _make_mist_pier_foreground_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
		shader_type canvas_item;

		void fragment() {
			vec4 vertex_color = COLOR;
			vec4 tex = texture(TEXTURE, UV);
			float luminance = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
			float max_channel = max(tex.r, max(tex.g, tex.b));
			float min_channel = min(tex.r, min(tex.g, tex.b));
			float saturation = (max_channel - min_channel) / max(max_channel, 0.001);
			float dark_detail = 1.0 - smoothstep(0.18, 0.46, luminance);
			float color_detail = smoothstep(0.20, 0.48, saturation);
			float detail = clamp(max(dark_detail, color_detail * 0.72), 0.0, 1.0);
			float left_edge = 1.0 - smoothstep(0.18, 0.36, UV.x);
			float right_edge = smoothstep(0.72, 0.90, UV.x);
			float lower_edge = smoothstep(0.70, 0.86, UV.y);
			float hanging_edge = (1.0 - smoothstep(0.00, 0.18, UV.y)) * (1.0 - smoothstep(0.16, 0.42, UV.x));
			float lower_posts = dark_detail * smoothstep(0.54, 0.66, UV.y) * (1.0 - smoothstep(0.80, 0.92, UV.y));
			float edge_keep = clamp(max(max(left_edge, right_edge), max(lower_edge, hanging_edge)), 0.0, 1.0);
			float keep_alpha = clamp(edge_keep * detail + lower_posts * 0.86, 0.0, 1.0);
			tex.a *= keep_alpha;
			if (tex.a < 0.01) {
				discard;
			}
			COLOR = tex * vertex_color;
		}
	"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _make_reeds_foreground_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
		shader_type canvas_item;

		void fragment() {
			vec4 vertex_color = COLOR;
			vec4 tex = texture(TEXTURE, UV);
			float luminance = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
			float max_channel = max(tex.r, max(tex.g, tex.b));
			float min_channel = min(tex.r, min(tex.g, tex.b));
			float saturation = (max_channel - min_channel) / max(max_channel, 0.001);
			float black_matte = 1.0 - smoothstep(0.015, 0.075, luminance);
			float white_halo = smoothstep(0.84, 0.98, luminance) * (1.0 - smoothstep(0.08, 0.24, saturation));
			tex.a *= 1.0 - clamp(black_matte + white_halo * 0.82, 0.0, 1.0);
			if (tex.a < 0.01) {
				discard;
			}
			COLOR = tex * vertex_color;
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

func _resolve_texture_path(paths: Array) -> String:
	for path_value in paths:
		var path := str(path_value)
		if ResourceLoader.exists(path) or FileAccess.file_exists(path):
			return path

	return str(paths.front()) if not paths.is_empty() else ""

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

func _debug_print_layout() -> void:
	if not SHOW_ENVIRONMENT_DEBUG or not BuildConfig.ENABLE_VERBOSE_LOGS:
		return
	if _last_debug_viewport.is_equal_approx(_viewport_size):
		return
	_last_debug_viewport = _viewport_size
	print("Environment layout: viewport=%s layers=%s" % [_viewport_size, _get_layer_debug_summary()])

func _debug_print_visual_state(
	minutes: float,
	phase: String,
	night_strength: float,
	sunset_strength: float,
	light_alpha: float
) -> void:
	if not SHOW_ENVIRONMENT_DEBUG or not BuildConfig.ENABLE_VERBOSE_LOGS:
		return
	var phase_key := "%s:%d" % [phase, int(minutes / 30.0)]
	if phase_key == _last_debug_phase:
		return
	_last_debug_phase = phase_key
	print(
		"Environment state: phase=%s minutes=%.1f night=%.2f sunset=%.2f light=%.2f viewport=%s" %
		[phase, minutes, night_strength, sunset_strength, light_alpha, _viewport_size]
	)

func _get_layer_debug_summary() -> Array[String]:
	var summary: Array[String] = []
	for node in [
		_sky_layer,
		_stars_layer,
		_sun_sprite,
		_moon_sprite,
		_mountains_layer,
		_forest_layer,
		_water_layer,
		_light_overlay_layer,
		_sunset_tint_overlay,
		_night_tint_overlay,
		_foreground_grass_layer
	]:
		if node == null:
			continue
		var item := str(node.name)
		if node is TextureRect:
			var texture := (node as TextureRect).texture
			item += "=" + ("ok" if texture != null else "missing")
		elif node is Sprite2D:
			var texture := (node as Sprite2D).texture
			item += "=" + ("ok" if texture != null else "missing")
		else:
			item += "=ok"
		summary.append(item)
	return summary
