# Handles the catch popup: fish visual, button lock, and animations.
extends RefCounted

var main
var theme
signal catch_keep_requested
signal catch_release_requested

const FISH_REWARD_ATLAS_PATH := "res://assets/fish/fish_reward_atlas.png"
const SMALL_FISH_ATLAS_PATH := "res://assets/fish/small_fish_atlas.png"
const FISH_REWARD_ATLAS_REGIONS := {
	"roach": Rect2(45, 68, 438, 204),
	"perch": Rect2(503, 61, 420, 211),
	"crucian": Rect2(966, 63, 418, 209),
	"rudd": Rect2(30, 322, 426, 197),
	"tench": Rect2(494, 317, 406, 200),
	"pike": Rect2(957, 347, 464, 165),
	"bream": Rect2(30, 544, 414, 225),
	"white_bream": Rect2(30, 544, 414, 225),
	"skimmer_bream": Rect2(30, 544, 414, 225),
	"catfish": Rect2(482, 575, 469, 176),
	"small_catfish": Rect2(482, 575, 469, 176),
	"eel": Rect2(957, 613, 458, 100),
	"loach": Rect2(957, 613, 458, 100),
	"zander": Rect2(29, 810, 445, 206),
	"young_pike": Rect2(957, 347, 464, 165),
	"ide": Rect2(30, 322, 426, 197),
	"young_chub": Rect2(30, 322, 426, 197),
	"young_grass_carp": Rect2(966, 63, 418, 209),
	"young_mirror_carp": Rect2(506, 821, 415, 205),
	"mist_carp": Rect2(506, 821, 415, 205),
	"moon_catfish": Rect2(957, 848, 460, 169)
}
const SMALL_FISH_ATLAS_REGIONS := {
	"bleak": Rect2(0, 0, 512, 256),
	"topmouth_gudgeon": Rect2(0, 0, 512, 256),
	"gudgeon": Rect2(0, 0, 512, 256),
	"rotan": Rect2(512, 0, 512, 256),
	"goby": Rect2(512, 0, 512, 256),
	"frog": Rect2(512, 0, 512, 256),
	"crayfish": Rect2(512, 0, 512, 256),
	"water_turtle": Rect2(512, 0, 512, 256),
	"silver_crucian": Rect2(1024, 0, 512, 256),
	"golden_crucian": Rect2(0, 256, 512, 256),
	"ruffe": Rect2(512, 256, 512, 256)
}

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme

func open(catch_data: Dictionary = {}) -> void:
	if not catch_data.is_empty():
		_show_catch_reward_popup(catch_data)

func close() -> void:
	_hide_catch_reward_popup()

func refresh() -> void:
	if not main._pending_reward_catch.is_empty() and is_open():
		_update_catch_reward_popup(main._pending_reward_catch)

func is_open() -> bool:
	return _is_catch_reward_open()

func request_keep() -> void:
	catch_keep_requested.emit()

func request_release() -> void:
	catch_release_requested.emit()

func _is_catch_reward_open() -> bool:
	return main.catch_popup_panel != null and main.catch_popup_panel.visible


func _bring_catch_reward_to_front() -> void:
	if main.catch_popup_backdrop != null and main.catch_popup_backdrop.get_parent() == main:
		main.move_child(main.catch_popup_backdrop, main.get_child_count() - 1)
	if main.catch_popup_panel != null and main.catch_popup_panel.get_parent() == main:
		main.move_child(main.catch_popup_panel, main.get_child_count() - 1)


func _close_secondary_popups_for_reward() -> void:
	if main.basket_panel != null:
		main.basket_panel.visible = false
	if main.basket_backdrop != null:
		main.basket_backdrop.visible = false
	if main.inventory_panel != null:
		main.inventory_panel.visible = false
	if main.inventory_backdrop != null:
		main.inventory_backdrop.visible = false
	if main.shop_panel != null:
		main.shop_panel.visible = false
	if main.shop_backdrop != null:
		main.shop_backdrop.visible = false
	if main.tackle_panel != null:
		main.tackle_panel.visible = false
	if main.tackle_backdrop != null:
		main.tackle_backdrop.visible = false
	if main.waterbody_panel != null:
		main.waterbody_panel.visible = false
	if main.waterbody_backdrop != null:
		main.waterbody_backdrop.visible = false
	main._active_nav_tab = "fish"


func _show_catch_reward_popup(catch_data: Dictionary) -> void:
	main._pending_reward_catch = catch_data.duplicate(true)
	_close_secondary_popups_for_reward()
	_bring_catch_reward_to_front()
	_update_catch_reward_popup(catch_data)
	var tier = _get_reward_tier(catch_data)
	var feedback = _get_reward_feedback_tuning(tier)
	var fish_start_scale = float(feedback["fish_start_scale"])
	var fish_reveal_scale = float(feedback["fish_reveal_scale"])
	var fish_delay = float(feedback["fish_delay"])
	var fish_reveal_duration = float(feedback["fish_reveal_duration"])
	var panel_duration = float(feedback["panel_duration"])

	if is_instance_valid(main._catch_popup_tween):
		main._catch_popup_tween.kill()
	if is_instance_valid(main._catch_fish_tween):
		main._catch_fish_tween.kill()

	main.catch_popup_backdrop.visible = true
	main.catch_popup_panel.visible = true
	main.catch_popup_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	main.catch_popup_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	main.catch_popup_backdrop.z_index = 40
	main.catch_popup_panel.z_index = 41
	main.catch_popup_backdrop.modulate = Color(1.0, 1.0, 1.0, 0.0)
	main.catch_popup_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	main.catch_popup_panel.scale = Vector2(0.92, 0.92)
	main.catch_fish_visual.position = main._catch_fish_base_position
	main.catch_fish_shadow.position = main._catch_shadow_base_position
	main.catch_fish_visual.pivot_offset = main.catch_fish_visual.size * 0.5
	main.catch_fish_shadow.pivot_offset = main.catch_fish_shadow.size * 0.5
	main.catch_fish_visual.scale = Vector2(fish_start_scale, fish_start_scale)
	main.catch_fish_shadow.scale = Vector2(fish_start_scale * 1.02, fish_start_scale * 1.02)
	main.catch_fish_visual.rotation = -0.018
	main.catch_fish_shadow.rotation = -0.018
	main.catch_fish_visual.modulate = Color(1.0, 1.0, 1.0, 0.0)
	main.catch_fish_shadow.modulate = Color(0.0, 0.0, 0.0, 0.0)
	main.catch_popup_particles.modulate = Color(1.0, 1.0, 1.0, 0.0)
	main.catch_popup_glow.modulate = Color(1.0, 1.0, 1.0, 0.0)
	main.catch_popup_title_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	main.catch_popup_badge_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	main.catch_popup_name_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	main.catch_trophy_banner_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	main.catch_popup_stats_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	main.catch_keep_button.modulate = Color(1.0, 1.0, 1.0, 0.0)
	main.catch_release_button.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_lock_catch_reward_buttons()
	main._catch_reward_unlock_after_msec = Time.get_ticks_msec() + 1200

	_play_catch_reward_sound(tier)

	main._catch_popup_tween = main.create_tween()
	main._catch_popup_tween.tween_property(main.catch_popup_backdrop, "modulate:a", 1.0, 0.20)
	main._catch_popup_tween.parallel().tween_property(main.catch_popup_panel, "modulate:a", 1.0, panel_duration)
	main._catch_popup_tween.parallel().tween_property(main.catch_popup_panel, "scale", Vector2.ONE, panel_duration + 0.06).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	main._catch_popup_tween.parallel().tween_property(main.catch_popup_glow, "modulate:a", 1.0, 0.28).set_delay(0.06)
	main._catch_popup_tween.parallel().tween_property(main.catch_popup_particles, "modulate:a", 1.0, 0.36).set_delay(0.10)
	main._catch_popup_tween.parallel().tween_property(main.catch_popup_title_label, "modulate:a", 1.0, 0.16).set_delay(0.08)
	main._catch_popup_tween.parallel().tween_property(main.catch_popup_badge_label, "modulate:a", 1.0, 0.18).set_delay(0.13)
	main._catch_popup_tween.parallel().tween_property(main.catch_popup_name_label, "modulate:a", 1.0, 0.22).set_delay(0.17)
	if main.catch_trophy_banner_label.visible:
		main._catch_popup_tween.parallel().tween_property(main.catch_trophy_banner_label, "modulate:a", 1.0, 0.24).set_delay(0.22)
	main._catch_popup_tween.parallel().tween_property(main.catch_fish_visual, "modulate:a", 1.0, 0.18).set_delay(fish_delay)
	main._catch_popup_tween.parallel().tween_property(main.catch_fish_shadow, "modulate:a", float(feedback["shadow_alpha"]), 0.20).set_delay(fish_delay)
	main._catch_popup_tween.parallel().tween_property(main.catch_fish_visual, "scale", Vector2(fish_reveal_scale, fish_reveal_scale), fish_reveal_duration).set_delay(fish_delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	main._catch_popup_tween.parallel().tween_property(main.catch_fish_shadow, "scale", Vector2(fish_reveal_scale, fish_reveal_scale), fish_reveal_duration).set_delay(fish_delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	main._catch_popup_tween.parallel().tween_property(main.catch_fish_visual, "rotation", 0.0, fish_reveal_duration).set_delay(fish_delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	main._catch_popup_tween.parallel().tween_property(main.catch_fish_shadow, "rotation", 0.0, fish_reveal_duration).set_delay(fish_delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	main._catch_popup_tween.parallel().tween_property(main.catch_popup_stats_label, "modulate:a", 1.0, 0.22).set_delay(fish_delay + 0.18)
	main._catch_popup_tween.parallel().tween_property(main.catch_keep_button, "modulate:a", 1.0, 0.20).set_delay(fish_delay + 0.27)
	main._catch_popup_tween.parallel().tween_property(main.catch_release_button, "modulate:a", 1.0, 0.20).set_delay(fish_delay + 0.30)
	main._catch_popup_tween.tween_callback(Callable(self, "_start_catch_fish_idle_motion").bind(feedback))


func _lock_catch_reward_buttons() -> void:
	main._catch_reward_buttons_ready = false
	main.catch_keep_button.disabled = true
	main.catch_release_button.disabled = true
	main.catch_keep_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.catch_release_button.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _update_catch_reward_input_lock() -> void:
	if not _is_catch_reward_open() or main._catch_reward_buttons_ready:
		return
	if Time.get_ticks_msec() < main._catch_reward_unlock_after_msec:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return

	_unlock_catch_reward_buttons()


func _unlock_catch_reward_buttons() -> void:
	if not _is_catch_reward_open():
		return

	main._catch_reward_buttons_ready = true
	main.catch_keep_button.disabled = false
	main.catch_release_button.disabled = false
	main.catch_keep_button.mouse_filter = Control.MOUSE_FILTER_STOP
	main.catch_release_button.mouse_filter = Control.MOUSE_FILTER_STOP


func _start_catch_fish_idle_motion(feedback: Dictionary) -> void:
	var fish_base_y = main._catch_fish_base_position.y
	var shadow_base_y = main._catch_shadow_base_position.y
	var float_y = float(feedback["float_y"])
	var float_duration = float(feedback["float_duration"])
	var breath_scale = float(feedback["breath_scale"])

	if is_instance_valid(main._catch_fish_tween):
		main._catch_fish_tween.kill()

	main._catch_fish_tween = main.create_tween().set_loops()
	main._catch_fish_tween.tween_property(main.catch_fish_visual, "position:y", fish_base_y - float_y, float_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	main._catch_fish_tween.parallel().tween_property(main.catch_fish_shadow, "position:y", shadow_base_y + float_y * 0.45, float_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	main._catch_fish_tween.parallel().tween_property(main.catch_fish_visual, "scale", Vector2(1.0 + breath_scale, 1.0 + breath_scale), float_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	main._catch_fish_tween.parallel().tween_property(main.catch_fish_shadow, "scale", Vector2(1.0 + breath_scale * 0.55, 1.0 + breath_scale * 0.55), float_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	main._catch_fish_tween.tween_property(main.catch_fish_visual, "position:y", fish_base_y + float_y, float_duration * 1.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	main._catch_fish_tween.parallel().tween_property(main.catch_fish_shadow, "position:y", shadow_base_y - float_y * 0.25, float_duration * 1.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	main._catch_fish_tween.parallel().tween_property(main.catch_fish_visual, "scale", Vector2(1.0 - breath_scale * 0.35, 1.0 - breath_scale * 0.35), float_duration * 1.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	main._catch_fish_tween.parallel().tween_property(main.catch_fish_shadow, "scale", Vector2(1.0 - breath_scale * 0.20, 1.0 - breath_scale * 0.20), float_duration * 1.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _update_catch_reward_popup(catch_data: Dictionary) -> void:
	var tier = _get_reward_tier(catch_data)
	var colors = _get_reward_colors(tier)
	var feedback = _get_reward_feedback_tuning(tier)
	var xp_result: Dictionary = catch_data.get("xp_result", {})
	var gained_xp = int(xp_result.get("gained_xp", 0))
	var weight = float(catch_data.get("weight", 0.0))
	var length_cm = _get_catch_length_cm(catch_data)
	var price = int(catch_data.get("price", 0))
	_set_reward_fish_texture(str(catch_data.get("id", "")))

	main.catch_popup_title_label.text = "Поймана рыба"
	main.catch_popup_badge_label.text = str(colors["label"])
	main.catch_popup_name_label.text = str(catch_data.get("name", "-"))
	main.catch_trophy_banner_label.visible = tier == "trophy"
	main.catch_trophy_banner_label.text = "ТРОФЕЙНЫЙ УЛОВ"
	main.catch_popup_stats_label.text = "Вес: %.2f кг   Длина: %.1f см\nXP: +%d   Стоимость: %d мон." % [
		weight,
		length_cm,
		gained_xp,
		price
	]

	main.catch_popup_badge_label.add_theme_color_override("font_color", colors["text"])
	main.catch_popup_badge_label.add_theme_stylebox_override(
		"normal",
		main._make_panel_style(colors["badge_bg"], colors["border"], 14, 6, colors["shadow"])
	)
	main.catch_popup_panel.add_theme_stylebox_override(
		"panel",
		main._make_panel_style(colors["panel_bg"], colors["border"], 22, 18, Color(0.0, 0.0, 0.0, 0.36))
	)

	var backdrop_material = main.catch_popup_backdrop.material as ShaderMaterial
	if backdrop_material:
		backdrop_material.set_shader_parameter("focus_strength", float(feedback["focus_strength"]))
		backdrop_material.set_shader_parameter("edge_strength", float(feedback["edge_strength"]))
		backdrop_material.set_shader_parameter("focus_color", colors["focus_color"])

	var glow_material = main.catch_popup_glow.material as ShaderMaterial
	if glow_material:
		glow_material.set_shader_parameter("glow_color", colors["glow"])
		glow_material.set_shader_parameter("glow_power", float(feedback["glow_power"]))
		glow_material.set_shader_parameter("pulse_speed", float(feedback["pulse_speed"]))

	var particle_material = main.catch_popup_particles.material as ShaderMaterial
	if particle_material:
		particle_material.set_shader_parameter("particle_color", colors["particle"])
		particle_material.set_shader_parameter("sparkle_power", float(colors["sparkle_power"]))
		particle_material.set_shader_parameter("drift_speed", float(feedback["particle_drift"]))
		particle_material.set_shader_parameter("particle_scale", float(feedback["particle_scale"]))

	var fish_material = main.catch_fish_visual.material as ShaderMaterial
	if fish_material:
		fish_material.set_shader_parameter("rim_color", colors["fish_rim"])
		fish_material.set_shader_parameter("shimmer_color", colors["fish_shimmer"])
		fish_material.set_shader_parameter("shimmer_strength", float(colors["shimmer_strength"]))
		fish_material.set_shader_parameter("shimmer_speed", float(feedback["shimmer_speed"]))


func _set_reward_fish_texture(fish_id: String) -> void:
	var texture = _get_reward_fish_texture(fish_id)
	main.catch_fish_visual.texture = texture
	main.catch_fish_shadow.texture = texture


func _get_reward_fish_texture(fish_id: String) -> Texture2D:
	if SMALL_FISH_ATLAS_REGIONS.has(fish_id):
		if main._small_fish_atlas == null:
			main._small_fish_atlas = load(SMALL_FISH_ATLAS_PATH) as Texture2D

			if main._small_fish_atlas == null:
				var small_image = Image.load_from_file(SMALL_FISH_ATLAS_PATH)
				if small_image:
					main._small_fish_atlas = ImageTexture.create_from_image(small_image)

		if main._small_fish_atlas != null:
			var small_atlas_texture = AtlasTexture.new()
			small_atlas_texture.atlas = main._small_fish_atlas
			small_atlas_texture.region = SMALL_FISH_ATLAS_REGIONS[fish_id]
			return small_atlas_texture

	if main._fish_reward_atlas == null:
		main._fish_reward_atlas = load(FISH_REWARD_ATLAS_PATH) as Texture2D

		if main._fish_reward_atlas == null:
			var image = Image.load_from_file(FISH_REWARD_ATLAS_PATH)
			if image:
				main._fish_reward_atlas = ImageTexture.create_from_image(image)

	if main._fish_reward_atlas == null:
		return null

	var atlas_region: Rect2 = FISH_REWARD_ATLAS_REGIONS.get(fish_id, FISH_REWARD_ATLAS_REGIONS["roach"])
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = main._fish_reward_atlas
	atlas_texture.region = atlas_region

	return atlas_texture


func _play_catch_reward_sound(tier: String) -> void:
	main._play_audio_hook(main.catch_popup_open_audio)

	match tier:
		"trophy":
			main._play_audio_hook(main.catch_trophy_audio)
		"rare":
			main._play_audio_hook(main.catch_rare_audio)
		_:
			main._play_audio_hook(main.catch_reward_audio)


func _hide_catch_reward_popup(animated: bool = true) -> void:
	main._catch_reward_unlock_after_msec = 0
	_lock_catch_reward_buttons()

	if is_instance_valid(main._catch_popup_tween):
		main._catch_popup_tween.kill()
	if is_instance_valid(main._catch_fish_tween):
		main._catch_fish_tween.kill()

	if not animated:
		_set_catch_popup_hidden()
		return

	main._catch_popup_tween = main.create_tween()
	main._catch_popup_tween.tween_property(main.catch_popup_panel, "modulate:a", 0.0, 0.12)
	main._catch_popup_tween.parallel().tween_property(main.catch_popup_backdrop, "modulate:a", 0.0, 0.12)
	main._catch_popup_tween.tween_callback(Callable(self, "_set_catch_popup_hidden"))


func _set_catch_popup_hidden() -> void:
	main.catch_popup_backdrop.visible = false
	main.catch_popup_panel.visible = false
	main.catch_popup_panel.scale = Vector2.ONE
	main.catch_fish_visual.position = main._catch_fish_base_position
	main.catch_fish_shadow.position = main._catch_shadow_base_position
	main.catch_fish_visual.scale = Vector2.ONE
	main.catch_fish_shadow.scale = Vector2.ONE
	main.catch_fish_visual.rotation = 0.0
	main.catch_fish_shadow.rotation = 0.0
	main.catch_fish_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.catch_fish_shadow.modulate = Color(0.0, 0.0, 0.0, 0.26)
	main.catch_popup_particles.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.catch_popup_glow.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.catch_popup_title_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.catch_popup_badge_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.catch_popup_name_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.catch_trophy_banner_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.catch_popup_stats_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.catch_keep_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.catch_release_button.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _get_reward_tier(catch_data: Dictionary) -> String:
	var rarity = str(catch_data.get("rarity", "common"))
	var fish = FishDatabase.get_fish(str(catch_data.get("id", "")))
	var weight_ratio = 0.0

	if not fish.is_empty():
		var min_weight = float(fish.get("min_weight", 0.0))
		var max_weight = float(fish.get("max_weight", min_weight + 1.0))
		weight_ratio = clamp((float(catch_data.get("weight", 0.0)) - min_weight) / max(max_weight - min_weight, 0.01), 0.0, 1.0)

	if rarity == "legendary" or weight_ratio >= 0.88:
		return "trophy"
	if rarity == "rare" or rarity == "very_rare" or weight_ratio >= 0.70:
		return "rare"
	if rarity == "uncommon" or weight_ratio >= 0.48:
		return "uncommon"

	return "common"


func _get_reward_colors(tier: String) -> Dictionary:
	match tier:
		"trophy":
			return {
				"label": "Трофейная",
				"text": Color(1.0, 0.90, 0.56, 1.0),
				"badge_bg": Color(0.34, 0.235, 0.08, 0.90),
				"panel_bg": Color(0.095, 0.095, 0.082, 0.91),
				"border": Color(1.0, 0.78, 0.38, 0.56),
				"shadow": Color(0.86, 0.54, 0.16, 0.22),
				"glow": Color(1.0, 0.72, 0.32, 1.0),
				"focus_color": Color(0.080, 0.060, 0.030, 1.0),
				"particle": Color(1.0, 0.88, 0.52, 1.0),
				"sparkle_power": 0.36,
				"fish_rim": Color(1.0, 0.88, 0.46, 1.0),
				"fish_shimmer": Color(1.0, 0.96, 0.66, 1.0),
				"shimmer_strength": 0.24
			}
		"rare":
			return {
				"label": "Редкая",
				"text": Color(0.74, 0.94, 1.0, 1.0),
				"badge_bg": Color(0.075, 0.220, 0.285, 0.90),
				"panel_bg": Color(0.055, 0.115, 0.135, 0.90),
				"border": Color(0.58, 0.90, 1.0, 0.46),
				"shadow": Color(0.18, 0.58, 0.78, 0.18),
				"glow": Color(0.34, 0.84, 1.0, 1.0),
				"focus_color": Color(0.020, 0.060, 0.080, 1.0),
				"particle": Color(0.58, 0.92, 1.0, 1.0),
				"sparkle_power": 0.28,
				"fish_rim": Color(0.62, 0.92, 1.0, 1.0),
				"fish_shimmer": Color(0.90, 0.98, 1.0, 1.0),
				"shimmer_strength": 0.20
			}
		"uncommon":
			return {
				"label": "Необычная",
				"text": Color(0.78, 1.0, 0.74, 1.0),
				"badge_bg": Color(0.075, 0.255, 0.150, 0.90),
				"panel_bg": Color(0.050, 0.125, 0.105, 0.90),
				"border": Color(0.58, 1.0, 0.64, 0.42),
				"shadow": Color(0.18, 0.72, 0.32, 0.16),
				"glow": Color(0.38, 0.98, 0.56, 1.0),
				"focus_color": Color(0.020, 0.070, 0.050, 1.0),
				"particle": Color(0.62, 1.0, 0.68, 1.0),
				"sparkle_power": 0.23,
				"fish_rim": Color(0.70, 1.0, 0.68, 1.0),
				"fish_shimmer": Color(0.90, 1.0, 0.76, 1.0),
				"shimmer_strength": 0.17
			}
		_:
			return {
				"label": "Обычная",
				"text": Color(0.84, 1.0, 0.82, 1.0),
				"badge_bg": Color(0.105, 0.245, 0.145, 0.88),
				"panel_bg": Color(0.060, 0.115, 0.120, 0.88),
				"border": Color(0.80, 1.0, 0.82, 0.34),
				"shadow": Color(0.22, 0.78, 0.34, 0.14),
				"glow": Color(0.38, 0.92, 0.50, 1.0),
				"focus_color": Color(0.015, 0.045, 0.044, 1.0),
				"particle": Color(0.74, 1.0, 0.74, 1.0),
				"sparkle_power": 0.15,
				"fish_rim": Color(0.80, 1.0, 0.76, 1.0),
				"fish_shimmer": Color(0.96, 0.86, 0.44, 1.0),
				"shimmer_strength": 0.12
			}


func _get_reward_feedback_tuning(tier: String) -> Dictionary:
	match tier:
		"trophy":
			return {
				"panel_duration": 0.36,
				"fish_delay": 0.20,
				"fish_reveal_duration": 0.52,
				"fish_start_scale": 0.58,
				"fish_reveal_scale": 1.04,
				"shadow_alpha": 0.34,
				"float_y": 6.5,
				"float_duration": 1.65,
				"breath_scale": 0.020,
				"focus_strength": 0.66,
				"edge_strength": 0.26,
				"glow_power": 0.60,
				"pulse_speed": 0.82,
				"particle_drift": 0.13,
				"particle_scale": 1.25,
				"shimmer_speed": 0.24
			}
		"rare":
			return {
				"panel_duration": 0.32,
				"fish_delay": 0.17,
				"fish_reveal_duration": 0.46,
				"fish_start_scale": 0.64,
				"fish_reveal_scale": 1.025,
				"shadow_alpha": 0.30,
				"float_y": 5.5,
				"float_duration": 1.80,
				"breath_scale": 0.017,
				"focus_strength": 0.62,
				"edge_strength": 0.22,
				"glow_power": 0.52,
				"pulse_speed": 0.92,
				"particle_drift": 0.11,
				"particle_scale": 1.12,
				"shimmer_speed": 0.21
			}
		"uncommon":
			return {
				"panel_duration": 0.30,
				"fish_delay": 0.15,
				"fish_reveal_duration": 0.40,
				"fish_start_scale": 0.70,
				"fish_reveal_scale": 1.015,
				"shadow_alpha": 0.27,
				"float_y": 4.5,
				"float_duration": 1.95,
				"breath_scale": 0.014,
				"focus_strength": 0.59,
				"edge_strength": 0.20,
				"glow_power": 0.46,
				"pulse_speed": 1.02,
				"particle_drift": 0.09,
				"particle_scale": 1.00,
				"shimmer_speed": 0.18
			}
		_:
			return {
				"panel_duration": 0.28,
				"fish_delay": 0.13,
				"fish_reveal_duration": 0.36,
				"fish_start_scale": 0.74,
				"fish_reveal_scale": 1.0,
				"shadow_alpha": 0.24,
				"float_y": 3.8,
				"float_duration": 2.10,
				"breath_scale": 0.011,
				"focus_strength": 0.56,
				"edge_strength": 0.18,
				"glow_power": 0.40,
				"pulse_speed": 1.12,
				"particle_drift": 0.07,
				"particle_scale": 0.90,
				"shimmer_speed": 0.15
			}


func _get_catch_length_cm(catch_data: Dictionary) -> float:
	if catch_data.has("length_cm"):
		return float(catch_data.get("length_cm", 0.0))

	var weight = float(catch_data.get("weight", 0.0))
	return max(12.0 + pow(max(weight, 0.05), 0.42) * 23.0, 8.0)
