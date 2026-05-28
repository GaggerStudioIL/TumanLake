# Handles the catch popup: fish visual, button lock, and animations.
extends RefCounted

const StatusBadgeScript := preload("res://scripts/ui/components/StatusBadge.gd")

var main
var theme
var progress_label: Label
var progress_track: Panel
var progress_fill: ColorRect
var reward_badge_row: HBoxContainer
var _species_texture_cache: Dictionary = {}
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
	_ensure_progress_nodes()

func _ensure_progress_nodes() -> void:
	if progress_label != null:
		return

	reward_badge_row = HBoxContainer.new()
	reward_badge_row.name = "CatchRewardBadgeRow"
	reward_badge_row.z_index = 6
	reward_badge_row.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_badge_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reward_badge_row.add_theme_constant_override("separation", 8)
	main.catch_popup_panel.add_child(reward_badge_row)

	progress_label = Label.new()
	progress_label.name = "CatchRankProgressLabel"
	progress_label.z_index = 5
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	progress_label.add_theme_font_size_override("font_size", 11)
	progress_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.92))
	main.catch_popup_panel.add_child(progress_label)

	progress_track = Panel.new()
	progress_track.name = "CatchRankProgressTrack"
	progress_track.z_index = 5
	progress_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_track.clip_contents = false
	progress_track.add_theme_stylebox_override(
		"panel",
		main._make_panel_style(Color(0.028, 0.044, 0.042, 0.76), Color(0.74, 0.90, 0.78, 0.18), 5, 2, Color(0.0, 0.0, 0.0, 0.12))
	)
	main.catch_popup_panel.add_child(progress_track)

	progress_fill = ColorRect.new()
	progress_fill.name = "CatchRankProgressFill"
	progress_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_fill.color = Color(0.42, 0.72, 0.22, 0.72)
	progress_track.add_child(progress_fill)

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
	var parent: Node = main.catch_popup_panel.get_parent() if main.catch_popup_panel != null else null
	if parent == null:
		return
	if main.catch_popup_backdrop != null and main.catch_popup_backdrop.get_parent() == parent:
		parent.move_child(main.catch_popup_backdrop, parent.get_child_count() - 1)
	if main.catch_popup_panel != null and main.catch_popup_panel.get_parent() == parent:
		parent.move_child(main.catch_popup_panel, parent.get_child_count() - 1)


func _close_secondary_popups_for_reward() -> void:
	if main.popup_manager != null and main.popup_manager.has_method("close_secondary_popups_for_priority_modal"):
		main.popup_manager.close_secondary_popups_for_priority_modal()
		return

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
	if main.fish_harbor_ui != null:
		main.fish_harbor_ui.visible = false
	if main.system_menu_ui != null:
		main.system_menu_ui.close_menu()
		main.system_menu_ui.close_settings(false)
	main._active_nav_tab = "fish"


func _show_catch_reward_popup(catch_data: Dictionary) -> void:
	main._pending_reward_catch = catch_data.duplicate(true)
	_close_secondary_popups_for_reward()
	main.open_modal("catch_reward")
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
	main.catch_popup_backdrop.z_index = main.MENU_BACKDROP_Z + 60
	main.catch_popup_panel.z_index = main.MENU_PANEL_Z + 60
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
	if reward_badge_row != null:
		reward_badge_row.modulate = Color(1.0, 1.0, 1.0, 0.0)
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
	if reward_badge_row != null and reward_badge_row.visible:
		main._catch_popup_tween.parallel().tween_property(reward_badge_row, "modulate:a", 1.0, 0.20).set_delay(0.20)
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
	var catch_rank := str(catch_data.get("catch_rank", "normal"))
	var fish_status := _get_catch_status(catch_data, catch_rank)
	var rarity := str(catch_data.get("species_rarity", catch_data.get("rarityType", catch_data.get("rarity", "common"))))
	var price := int(catch_data.get("price", 0))
	var trophy_weight := float(catch_data.get("trophy_weight", 0.0))
	var rarity_weight := float(catch_data.get("rarity_weight", 0.0))
	var record_messages: Array = []
	if bool(catch_data.get("is_new_personal_record", false)):
		record_messages.append("Новый личный рекорд!")
	if bool(catch_data.get("is_new_species_record", false)):
		record_messages.append("Новый рекорд вида!")
	_set_reward_fish_texture(str(catch_data.get("id", "")))

	main.catch_popup_title_label.text = "Поймана рыба"
	main.catch_popup_badge_label.visible = false
	main.catch_popup_badge_label.text = ""
	main.catch_popup_name_label.text = str(catch_data.get("name", "-"))
	main.catch_trophy_banner_label.visible = false
	main.catch_trophy_banner_label.text = ""
	_update_reward_badges(catch_rank, record_messages, colors, fish_status, rarity)
	main.catch_popup_stats_label.text = _build_catch_info_text(weight, length_cm, gained_xp, price)
	_update_rank_progress(catch_data, weight, trophy_weight, rarity_weight, catch_rank, colors)

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


func _build_catch_info_text(weight: float, length_cm: float, gained_xp: int, price: int) -> String:
	return "Вес: %s (%s)\nЦена: %s\nXP: +%d" % [
		UIFormatters.format_weight_kg(weight),
		UIFormatters.format_length_cm(length_cm),
		UIFormatters.format_money(float(price)),
		gained_xp
	]


func _update_reward_badges(catch_rank: String, record_messages: Array, _colors: Dictionary, fish_status: String, rarity: String) -> void:
	if reward_badge_row == null:
		return
	for child in reward_badge_row.get_children():
		reward_badge_row.remove_child(child)
		child.queue_free()

	var panel_width: float = main.catch_popup_panel.size.x
	var row_width: float = min(panel_width - 72.0, 430.0)
	reward_badge_row.position = Vector2((panel_width - row_width) * 0.5, 90.0)
	reward_badge_row.size = Vector2(row_width, 24.0)

	_add_reward_badge(_get_status_badge_label(fish_status), Color(0.0, 0.0, 0.0, 0.0), Color(0.0, 0.0, 0.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), _get_status_badge_type(fish_status))

	if catch_rank == "trophy":
		if fish_status != "trophy":
			_add_reward_badge("Трофей", Color(0.32, 0.22, 0.075, 0.86), Color(1.0, 0.78, 0.34, 0.60), Color(1.0, 0.88, 0.50, 1.0))
	elif catch_rank == "rarity":
		_add_reward_badge("Раритет", Color(0.18, 0.075, 0.28, 0.86), Color(0.86, 0.58, 1.0, 0.58), Color(0.90, 0.76, 1.0, 1.0))
	elif rarity == "rare" or rarity == "legendary_species":
		_add_reward_badge(UIFormatters.format_rarity(rarity), Color(0.18, 0.075, 0.28, 0.86), Color(0.86, 0.58, 1.0, 0.58), Color(0.90, 0.76, 1.0, 1.0), "rare")

	if record_messages.has("Новый личный рекорд!"):
		_add_reward_badge("Личный рекорд", Color(0.055, 0.20, 0.255, 0.84), Color(0.46, 0.88, 1.0, 0.48), Color(0.74, 0.94, 1.0, 1.0))
	if record_messages.has("Новый рекорд вида!"):
		_add_reward_badge("Рекорд вида", Color(0.22, 0.145, 0.04, 0.84), Color(1.0, 0.70, 0.26, 0.52), Color(1.0, 0.86, 0.48, 1.0))

	reward_badge_row.visible = reward_badge_row.get_child_count() > 0
	main.catch_trophy_banner_label.visible = false


func _add_reward_badge(text: String, bg: Color, border: Color, font_color: Color, badge_type: String = "") -> void:
	var type := badge_type if badge_type != "" else _get_reward_badge_type(text)
	var badge := StatusBadgeScript.create_badge(text, type)
	reward_badge_row.add_child(badge)


func _get_reward_badge_type(text: String) -> String:
	match text:
		"Трофей":
			return "trophy"
		"Раритет":
			return "rare"
		"Личный рекорд", "Рекорд вида":
			return "best"
		_:
			return "normal"


func _get_catch_status(catch_data: Dictionary, catch_rank: String) -> String:
	var status := str(catch_data.get("fish_status", catch_data.get("status", "")))
	if status != "":
		return status
	if catch_rank == "trophy" or bool(catch_data.get("is_trophy_status", catch_data.get("is_trophy", false))):
		return "trophy"
	if bool(catch_data.get("is_keeper", false)):
		return "keeper"
	return "undersized"


func _get_status_badge_label(status: String) -> String:
	return UIFormatters.format_fish_status(status)


func _get_status_badge_type(status: String) -> String:
	return StatusBadgeScript.type_for_fish_status(status)


func _get_personal_best_weight(catch_data: Dictionary, current_weight: float) -> float:
	var previous_weight := float(catch_data.get("previous_species_record_weight", 0.0))
	if previous_weight <= 0.0 or bool(catch_data.get("is_new_species_record", false)):
		return maxf(previous_weight, current_weight)
	return previous_weight


func _get_record_scale_weight(catch_data: Dictionary, rarity_weight: float) -> float:
	var fish := FishDatabase.get_fish(str(catch_data.get("id", catch_data.get("fish_id", ""))))
	if not fish.is_empty():
		var status_system: Node = main.get_node_or_null("/root/FishStatusSystem")
		if status_system != null and status_system.has_method("get_record_weight"):
			return float(status_system.call("get_record_weight", fish))
	return maxf(float(catch_data.get("recordWeight", catch_data.get("record_weight", 0.0))), rarity_weight)


func _update_weight_progress_track(weight: float, personal_best_weight: float, trophy_weight: float, record_weight: float, accent: Color) -> void:
	if progress_track == null or progress_fill == null:
		return
	for child in progress_track.get_children():
		if child != progress_fill:
			progress_track.remove_child(child)
			child.queue_free()

	var max_weight: float = maxf(maxf(weight, personal_best_weight), maxf(trophy_weight, record_weight))
	max_weight = maxf(max_weight * 1.1, 0.1)
	var usable_width: float = maxf(progress_track.size.x, 1.0)
	var center_y: float = progress_track.size.y * 0.5
	var track_height := 6.0
	var caught_pos := clampf(weight / max_weight, 0.0, 1.0)

	progress_fill.position = Vector2(0.0, center_y - track_height * 0.5)
	progress_fill.size = Vector2(usable_width * caught_pos, track_height)
	progress_fill.color = Color(accent.r, accent.g, accent.b, 0.50)

	if record_weight > 0.0:
		_add_weight_marker("RecordMarker", usable_width * clampf(record_weight / max_weight, 0.0, 1.0), Color(0.86, 0.52, 1.0, 0.82), "✦", 16)
	if trophy_weight > 0.0:
		_add_weight_marker("TrophyMarker", usable_width * clampf(trophy_weight / max_weight, 0.0, 1.0), Color(1.0, 0.78, 0.34, 0.86), "★", 16)
	if personal_best_weight > 0.0:
		_add_weight_marker("PersonalMarker", usable_width * clampf(personal_best_weight / max_weight, 0.0, 1.0), Color(0.38, 0.86, 1.0, 0.80), "◆", 15)
	_add_caught_weight_marker(usable_width * caught_pos)


func _add_weight_marker(marker_name: String, center_x: float, color: Color, marker_text: String, font_size: int) -> void:
	var marker := Label.new()
	marker.name = marker_name
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.text = marker_text
	marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marker.add_theme_font_size_override("font_size", font_size)
	marker.add_theme_color_override("font_color", color)
	var marker_size := float(font_size + 8)
	marker.size = Vector2(marker_size, marker_size)
	marker.position = Vector2(
		clampf(center_x - marker_size * 0.5, 0.0, maxf(progress_track.size.x - marker_size, 0.0)),
		progress_track.size.y * 0.5 - marker_size * 0.5
	)
	progress_track.add_child(marker)


func _add_caught_weight_marker(center_x: float) -> void:
	var marker := Panel.new()
	marker.name = "CaughtMarker"
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var marker_size := 10.0
	var marker_style := StyleBoxFlat.new()
	marker_style.bg_color = Color(0.94, 1.0, 0.88, 1.0)
	marker_style.border_color = Color(0.04, 0.10, 0.07, 0.70)
	marker_style.set_border_width_all(1)
	marker_style.set_corner_radius_all(roundi(marker_size * 0.5))
	marker.add_theme_stylebox_override("panel", marker_style)
	marker.size = Vector2(marker_size, marker_size)
	marker.position = Vector2(
		clampf(center_x - marker_size * 0.5, 0.0, maxf(progress_track.size.x - marker_size, 0.0)),
		progress_track.size.y * 0.5 - marker_size * 0.5
	)
	progress_track.add_child(marker)


func _update_rank_progress(catch_data: Dictionary, weight: float, trophy_weight: float, rarity_weight: float, _catch_rank: String, colors: Dictionary) -> void:
	if progress_label == null or progress_track == null:
		return

	var personal_best_weight := _get_personal_best_weight(catch_data, weight)
	var record_weight := _get_record_scale_weight(catch_data, rarity_weight)
	var panel_size: Vector2 = main.catch_popup_panel.size
	var track_width: float = min(panel_size.x - 120.0, 430.0)
	var track_height := 8.0
	var track_x: float = (panel_size.x - track_width) * 0.5
	var track_y: float = panel_size.y - 116.0

	progress_label.visible = false
	progress_track.visible = true
	progress_label.text = ""
	progress_track.position = Vector2(track_x, track_y)
	progress_track.size = Vector2(track_width, track_height)
	_update_weight_progress_track(weight, personal_best_weight, trophy_weight, record_weight, colors.get("glow", Color(0.55, 0.95, 0.78, 1.0)))


func _format_weight(value: float) -> String:
	return "%.2f кг" % value


func _set_reward_fish_texture(fish_id: String) -> void:
	var texture = _get_reward_fish_texture(fish_id)
	main.catch_fish_visual.texture = texture
	main.catch_fish_shadow.texture = texture


func _get_reward_fish_texture(fish_id: String) -> Texture2D:
	var species_texture := _get_species_fish_texture(fish_id)
	if species_texture != null:
		return species_texture

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


func _get_species_fish_texture(fish_id: String) -> Texture2D:
	var fish: Dictionary = FishDatabase.get_fish(fish_id)
	if fish.is_empty():
		return null

	var path := str(fish.get("icon_path", ""))
	if path.is_empty():
		return null

	if _species_texture_cache.has(path):
		return _species_texture_cache[path]

	if not ResourceLoader.exists(path):
		push_warning("CatchPopupUI: missing fish species image: " + path)
		return null

	var texture := load(path) as Texture2D
	if texture == null:
		push_warning("CatchPopupUI: cannot load fish species image: " + path)
		return null

	_species_texture_cache[path] = texture
	return texture


func _play_catch_reward_sound(tier: String) -> void:
	main._play_audio_hook(main.catch_popup_open_audio)

	match tier:
		"trophy":
			main._play_audio_hook(main.catch_trophy_audio)
		"rarity", "rare":
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
	if reward_badge_row != null:
		reward_badge_row.modulate = Color(1.0, 1.0, 1.0, 1.0)
		reward_badge_row.visible = false
	main.catch_popup_name_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.catch_trophy_banner_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.catch_popup_stats_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.catch_keep_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	main.catch_release_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if progress_label != null:
		progress_label.visible = false
	if progress_track != null:
		progress_track.visible = false
	main.close_modal("catch_reward")


func _get_reward_tier(catch_data: Dictionary) -> String:
	var catch_rank := str(catch_data.get("catch_rank", "normal"))
	if catch_rank == "rarity":
		return "rarity"
	if catch_rank == "trophy" or str(catch_data.get("fish_status", "")) == "trophy" or bool(catch_data.get("is_trophy_status", catch_data.get("is_trophy", false))):
		return "trophy"
	return "common"

func _get_reward_colors(tier: String) -> Dictionary:
	match tier:
		"rarity":
			return {
				"label": "Раритет",
				"text": Color(0.88, 0.74, 1.0, 1.0),
				"badge_bg": Color(0.18, 0.075, 0.28, 0.92),
				"panel_bg": Color(0.075, 0.055, 0.115, 0.91),
				"border": Color(0.86, 0.58, 1.0, 0.52),
				"shadow": Color(0.54, 0.24, 0.86, 0.20),
				"glow": Color(0.82, 0.42, 1.0, 1.0),
				"focus_color": Color(0.045, 0.020, 0.070, 1.0),
				"particle": Color(0.90, 0.76, 1.0, 1.0),
				"sparkle_power": 0.34,
				"fish_rim": Color(0.92, 0.72, 1.0, 1.0),
				"fish_shimmer": Color(1.0, 0.90, 0.72, 1.0),
				"shimmer_strength": 0.24
			}
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
		"rarity":
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
