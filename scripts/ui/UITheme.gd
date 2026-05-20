# Shared visual foundation for HUD, modals, buttons, labels, and cards.
extends RefCounted

const PANEL_STYLE := preload("res://assets/ui/panels/glass_panel.tres")
const CARD_STYLE := preload("res://assets/ui/panels/card_panel.tres")
const POPUP_STYLE := preload("res://assets/ui/panels/popup_panel.tres")
const SHOP_ROW_STYLE := preload("res://assets/ui/panels/shop_row.tres")
const PRIMARY_BUTTON_STYLE := preload("res://assets/ui/buttons/primary_button.tres")
const SECONDARY_BUTTON_STYLE := preload("res://assets/ui/buttons/secondary_button.tres")
const NAV_BUTTON_STYLE := preload("res://assets/ui/buttons/nav_button.tres")
const NAV_ACTIVE_STYLE := preload("res://assets/ui/buttons/nav_button_active.tres")
const TAB_BUTTON_STYLE := preload("res://assets/ui/buttons/tab_button.tres")
const PROGRESS_TRACK_STYLE := preload("res://assets/ui/hud/progress_track.tres")
const PROGRESS_FILL_GREEN_STYLE := preload("res://assets/ui/hud/progress_fill_green.tres")
const HUD_BADGE_STYLE := preload("res://assets/ui/hud/hud_badge.tres")
const INVENTORY_SLOT_STYLE := preload("res://assets/ui/inventory/inventory_slot.tres")
const RARITY_UNCOMMON_STYLE := preload("res://assets/ui/inventory/rarity_uncommon.tres")
const RARITY_RARE_STYLE := preload("res://assets/ui/inventory/rarity_rare.tres")
const RARITY_EPIC_STYLE := preload("res://assets/ui/inventory/rarity_epic.tres")
const RARITY_LEGENDARY_STYLE := preload("res://assets/ui/inventory/rarity_legendary.tres")

const ICON_HOOK := preload("res://assets/ui/icons/hook.png")
const ICON_FISH := preload("res://assets/ui/icons/fish.png")
const ICON_BASKET := preload("res://assets/ui/icons/bag.png")
const ICON_BAIT := preload("res://assets/ui/icons/bait.png")
const ICON_ROD := preload("res://assets/ui/icons/rod.png")
const ICON_GEAR := preload("res://assets/ui/sprites/icons/gear.png")
const ICON_CART := preload("res://assets/ui/icons/shop.png")
const ICON_MONEY := preload("res://assets/ui/sprites/icons/money.png")
const ICON_LOCATION := preload("res://assets/ui/sprites/icons/location.png")
const ICON_PROFILE := preload("res://assets/ui/icons/profile.png")
const ICON_INVENTORY := preload("res://assets/ui/icons/bag.png")
const ICON_MAP := preload("res://assets/ui/icons/map.png")
const ICON_WEATHER := preload("res://assets/ui/sprites/icons/weather.png")
const ICON_TIME := preload("res://assets/ui/sprites/icons/time.png")
const ICON_AUTO := preload("res://assets/ui/sprites/icons/auto.png")

const ICON_HOOK_REGION := Rect2(600, 214, 329, 526)
const ICON_FISH_REGION := Rect2(398, 250, 737, 433)
const ICON_BAG_REGION := Rect2(378, 220, 774, 503)
const ICON_BAIT_REGION := Rect2(364, 212, 795, 586)
const ICON_ROD_REGION := Rect2(135, 82, 1251, 773)
const ICON_SHOP_REGION := Rect2(438, 211, 663, 564)
const ICON_MAP_REGION := Rect2(406, 189, 732, 507)
const ICON_PROFILE_REGION := Rect2(484, 211, 573, 565)

const GLASS_BG := Color(0.030, 0.043, 0.046, 0.72)
const GLASS_BG_STRONG := Color(0.028, 0.038, 0.040, 0.86)
const PANEL_BG := Color(0.035, 0.055, 0.062, 0.74)
const CARD_BG := Color(0.045, 0.075, 0.075, 0.70)
const SLOT_BG := Color(0.044, 0.056, 0.056, 0.68)
const FIELD_BG := Color(0.050, 0.075, 0.080, 0.64)
const BACKDROP_BG := Color(0.0, 0.0, 0.0, 0.58)
const BORDER_SOFT := Color(0.76, 0.88, 0.82, 0.24)
const BORDER_FAINT := Color(0.76, 0.88, 0.82, 0.14)
const BORDER_BRIGHT := Color(0.80, 1.0, 0.72, 0.48)
const GREEN := Color(0.32, 0.58, 0.18, 0.96)
const GREEN_HOVER := Color(0.40, 0.68, 0.22, 1.0)
const GREEN_PRESSED := Color(0.23, 0.43, 0.15, 1.0)
const GREEN_SOFT := Color(0.45, 0.78, 0.24, 0.28)
const TEXT_PRIMARY := Color(0.94, 0.98, 0.92, 1.0)
const TEXT_BODY := Color(0.76, 0.84, 0.80, 0.96)
const TEXT_MUTED := Color(0.56, 0.64, 0.62, 0.92)
const TEXT_ACCENT := Color(0.72, 0.95, 0.43, 1.0)
const BLUE_RARE := Color(0.31, 0.72, 0.98, 1.0)
const PURPLE_EPIC := Color(0.72, 0.38, 1.0, 1.0)
const GOLD_LEGENDARY := Color(1.0, 0.68, 0.14, 1.0)

func make_style(
	bg_color: Color,
	border_color: Color = BORDER_SOFT,
	radius: int = 14,
	shadow_size: int = 8,
	shadow_color: Color = Color(0.0, 0.0, 0.0, 0.26)
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = shadow_color
	style.shadow_size = shadow_size
	style.content_margin_left = 10.0
	style.content_margin_top = 8.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 8.0
	return style

func get_panel_style() -> StyleBoxFlat:
	return _clone_style(PANEL_STYLE) as StyleBoxFlat

func get_card_style() -> StyleBoxFlat:
	return _clone_style(CARD_STYLE) as StyleBoxFlat

func get_inventory_slot_style(active := false, rarity := "common") -> StyleBoxFlat:
	return get_inventory_slot_flat_style(active, rarity)

func get_inventory_slot_flat_style(active := false, rarity := "common") -> StyleBoxFlat:
	var rarity_color := get_rarity_color(rarity)
	var style := _clone_style(_get_rarity_slot_resource(rarity)) as StyleBoxFlat

	if active:
		style.bg_color = Color(0.075, 0.145, 0.090, 0.78)
		style.border_color = Color(0.70, 1.0, 0.66, 0.46)
		style.shadow_color = Color(0.20, 0.72, 0.24, 0.18)
		style.shadow_size = 6
	elif rarity != "common":
		style.border_color = Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.36)
		style.shadow_color = Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.11)
		style.shadow_size = 5

	return style

func get_hud_badge_style(active := false) -> StyleBoxFlat:
	var bg := Color(0.028, 0.040, 0.044, 0.70)
	var border := BORDER_FAINT
	var shadow := Color(0.0, 0.0, 0.0, 0.18)
	if active:
		bg = Color(0.075, 0.145, 0.090, 0.78)
		border = Color(0.68, 1.0, 0.66, 0.36)
		shadow = Color(0.20, 0.72, 0.24, 0.16)
	return make_style(bg, border, 12, 5, shadow)

func get_popup_window_style() -> StyleBoxFlat:
	return _clone_style(POPUP_STYLE) as StyleBoxFlat

func get_shop_row_style(rarity := "common") -> StyleBoxFlat:
	var style := _clone_style(SHOP_ROW_STYLE) as StyleBoxFlat
	if rarity != "common":
		var rarity_color := get_rarity_color(rarity)
		style.border_color = Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.34)
		style.shadow_color = Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.10)
	return style

func get_progress_background_style() -> StyleBoxFlat:
	return _clone_style(PROGRESS_TRACK_STYLE) as StyleBoxFlat

func get_progress_fill_style(accent: Color = GREEN_HOVER) -> StyleBoxFlat:
	if accent == GREEN_HOVER:
		return _clone_style(PROGRESS_FILL_GREEN_STYLE) as StyleBoxFlat
	return make_style(Color(accent.r, accent.g, accent.b, 0.94), Color.TRANSPARENT, 8, 0, Color.TRANSPARENT)

func get_rarity_color(rarity: String) -> Color:
	match rarity:
		"legendary":
			return GOLD_LEGENDARY
		"very_rare", "epic":
			return PURPLE_EPIC
		"rare":
			return BLUE_RARE
		"uncommon":
			return TEXT_ACCENT
		_:
			return BORDER_SOFT

func get_button_style(kind: String = "secondary", state: String = "normal") -> StyleBoxFlat:
	var bg := FIELD_BG
	var border := BORDER_SOFT
	var shadow := Color(0.0, 0.0, 0.0, 0.18)
	var radius := 12
	var shadow_size := 4

	match kind:
		"primary":
			bg = GREEN
			border = BORDER_BRIGHT
			shadow = Color(0.25, 0.78, 0.24, 0.26)
			radius = 14
			shadow_size = 10
			if state == "hover":
				bg = GREEN_HOVER
				border = Color(0.86, 1.0, 0.72, 0.64)
			elif state == "pressed":
				bg = GREEN_PRESSED
				shadow_size = 5
			elif state == "disabled":
				bg = Color(0.09, 0.15, 0.12, 0.56)
				border = Color(0.55, 0.62, 0.58, 0.16)
				shadow = Color(0.0, 0.0, 0.0, 0.10)
		"nav_active":
			bg = Color(0.16, 0.30, 0.19, 0.88)
			border = Color(0.70, 1.0, 0.72, 0.42)
			shadow = Color(0.20, 0.64, 0.22, 0.18)
			radius = 12
			shadow_size = 5
		"tab_active":
			bg = Color(0.11, 0.22, 0.12, 0.86)
			border = Color(0.70, 1.0, 0.58, 0.44)
			shadow = Color(0.22, 0.70, 0.20, 0.16)
			radius = 10
			shadow_size = 4
		"tab":
			bg = Color(0.035, 0.047, 0.050, 0.58)
			border = BORDER_FAINT
			radius = 10
			shadow_size = 2
			if state == "hover":
				bg = Color(0.060, 0.084, 0.080, 0.72)
			elif state == "pressed":
				bg = Color(0.080, 0.135, 0.095, 0.82)
		"nav":
			bg = Color(0.040, 0.060, 0.066, 0.62)
			border = Color(0.76, 0.86, 0.82, 0.20)
			if state == "hover":
				bg = Color(0.065, 0.095, 0.095, 0.78)
			elif state == "pressed":
				bg = Color(0.09, 0.18, 0.12, 0.86)
			elif state == "disabled":
				bg = Color(0.040, 0.050, 0.052, 0.44)
				border = Color(0.62, 0.66, 0.64, 0.12)
		_:
			if state == "hover":
				bg = Color(0.070, 0.105, 0.105, 0.78)
				border = Color(0.82, 0.94, 0.86, 0.30)
			elif state == "pressed":
				bg = Color(0.080, 0.155, 0.110, 0.86)
			elif state == "disabled":
				bg = Color(0.045, 0.055, 0.056, 0.42)
				border = Color(0.58, 0.64, 0.62, 0.12)

	return make_style(bg, border, radius, shadow_size, shadow)

func get_icon(icon_name: String) -> Texture2D:
	match icon_name:
		"hook", "cast":
			return _make_atlas_texture(ICON_HOOK, ICON_HOOK_REGION)
		"fish", "fishing":
			return _make_atlas_texture(ICON_FISH, ICON_FISH_REGION)
		"basket", "keepnet":
			return _make_atlas_texture(ICON_BASKET, ICON_BAG_REGION)
		"bait":
			return _make_atlas_texture(ICON_BAIT, ICON_BAIT_REGION)
		"rod", "tackle":
			return _make_atlas_texture(ICON_ROD, ICON_ROD_REGION)
		"gear", "settings":
			return ICON_GEAR
		"cart", "shop":
			return _make_atlas_texture(ICON_CART, ICON_SHOP_REGION)
		"money":
			return ICON_MONEY
		"location":
			return ICON_LOCATION
		"profile":
			return _make_atlas_texture(ICON_PROFILE, ICON_PROFILE_REGION)
		"inventory":
			return _make_atlas_texture(ICON_INVENTORY, ICON_BAG_REGION)
		"map":
			return _make_atlas_texture(ICON_MAP, ICON_MAP_REGION)
		"weather":
			return ICON_WEATHER
		"time":
			return ICON_TIME
		"auto":
			return ICON_AUTO
		_:
			return null

func apply_panel_style(control) -> void:
	if control is Panel:
		control.add_theme_stylebox_override("panel", get_panel_style())
	elif control is ColorRect:
		control.color = PANEL_BG

func apply_card_style(control) -> void:
	if control is Panel:
		control.add_theme_stylebox_override("panel", get_card_style())
	elif control is ColorRect:
		control.color = CARD_BG

func apply_inventory_slot_style(control) -> void:
	if control is Panel:
		control.add_theme_stylebox_override("panel", get_inventory_slot_style())
	elif control is ColorRect:
		control.color = SLOT_BG

func apply_rarity_slot_style(control, rarity := "common", active := false) -> void:
	var style := get_inventory_slot_style(active, rarity)
	if control is Panel:
		control.add_theme_stylebox_override("panel", style)
	elif control is ColorRect:
		var rarity_color := get_rarity_color(rarity)
		control.color = Color(rarity_color.r * 0.16, rarity_color.g * 0.18, rarity_color.b * 0.18, 0.42) if rarity != "common" else SLOT_BG

func apply_shop_row_style(control, rarity := "common") -> void:
	if control is Panel:
		control.add_theme_stylebox_override("panel", get_shop_row_style(rarity))
	elif control is ColorRect:
		control.color = Color(0.040, 0.066, 0.068, 0.70)

func apply_hud_badge_style(control, active := false) -> void:
	if control is Panel:
		control.add_theme_stylebox_override("panel", get_hud_badge_style(active))
	elif control is ColorRect:
		control.color = Color(0.075, 0.145, 0.090, 0.78) if active else Color(0.028, 0.040, 0.044, 0.70)

func apply_popup_window_style(control) -> void:
	if control is Panel:
		control.add_theme_stylebox_override("panel", get_popup_window_style())
	elif control is ColorRect:
		control.color = GLASS_BG_STRONG

func apply_primary_button_style(button: Button) -> void:
	_apply_button(button, "primary", 56.0, 16)

func apply_secondary_button_style(button: Button) -> void:
	_apply_button(button, "secondary", 44.0, 14)

func apply_nav_button_style(button: Button, active := false) -> void:
	_apply_button(button, "nav_active" if active else "nav", 44.0, 13)

func apply_tab_button_style(button: Button, active := false) -> void:
	_apply_button(button, "tab_active" if active else "tab", 44.0, 13)

func apply_close_button_style(button: Button) -> void:
	_apply_button(button, "secondary", 44.0, 13)

func apply_label_style(label: Label, role := "body") -> void:
	match role:
		"title":
			_ensure_label_font_size(label, 24)
			label.add_theme_color_override("font_color", TEXT_PRIMARY)
			label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.32))
			label.add_theme_constant_override("shadow_offset_x", 0)
			label.add_theme_constant_override("shadow_offset_y", 1)
		"caption":
			_ensure_label_font_size(label, 12)
			label.add_theme_color_override("font_color", TEXT_MUTED)
		"accent":
			_ensure_label_font_size(label, 14)
			label.add_theme_color_override("font_color", TEXT_ACCENT)
		"hud":
			_ensure_label_font_size(label, 15)
			label.add_theme_color_override("font_color", TEXT_PRIMARY)
		_:
			_ensure_label_font_size(label, 14)
			label.add_theme_color_override("font_color", TEXT_BODY)

func apply_progress_bar_style(progress_bar: ProgressBar, accent: Color = GREEN_HOVER) -> void:
	progress_bar.add_theme_stylebox_override("background", get_progress_background_style())
	progress_bar.add_theme_stylebox_override("fill", get_progress_fill_style(accent))
	progress_bar.add_theme_color_override("font_color", TEXT_PRIMARY)
	progress_bar.add_theme_font_size_override("font_size", 12)

func apply_item_list_style(item_list: ItemList) -> void:
	item_list.add_theme_stylebox_override("panel", get_card_style())
	item_list.add_theme_stylebox_override("selected", get_inventory_slot_style(true))
	item_list.add_theme_stylebox_override("selected_focus", get_inventory_slot_style(true))
	item_list.add_theme_color_override("font_color", Color(0.84, 0.94, 0.86, 0.96))
	item_list.add_theme_color_override("font_selected_color", TEXT_PRIMARY)
	item_list.add_theme_color_override("guide_color", Color(0.76, 0.88, 0.82, 0.10))
	item_list.add_theme_font_size_override("font_size", 13)

func apply_meter_track_style(track: ColorRect, fill: ColorRect = null, accent: Color = GREEN_HOVER) -> void:
	track.color = Color(0.10, 0.145, 0.145, 0.92)
	if fill != null:
		fill.color = Color(accent.r, accent.g, accent.b, 0.78)

func apply_modal_backdrop_style(control) -> void:
	if control is ColorRect:
		control.color = BACKDROP_BG
	control.mouse_filter = Control.MOUSE_FILTER_STOP

func _make_atlas_texture(texture: Texture2D, region: Rect2) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = region
	return atlas

func _apply_button(button: Button, kind: String, min_height: float, font_size: int) -> void:
	button.custom_minimum_size = Vector2(button.custom_minimum_size.x, max(button.custom_minimum_size.y, min_height))
	if button.size.y > 0.0:
		button.size.y = max(button.size.y, min_height)
	button.add_theme_stylebox_override("normal", _tune_button_style(get_button_style(kind, "normal"), kind))
	button.add_theme_stylebox_override("hover", _tune_button_style(get_button_style(kind, "hover"), kind))
	button.add_theme_stylebox_override("pressed", _tune_button_style(get_button_style(kind, "pressed"), kind))
	button.add_theme_stylebox_override("disabled", _tune_button_style(get_button_style(kind, "disabled"), kind))
	button.add_theme_font_size_override("font_size", max(button.get_theme_font_size("font_size"), font_size))
	button.add_theme_color_override("font_color", TEXT_PRIMARY)
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.86, 0.96, 0.82, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.58, 0.64, 0.62, 0.72))
	_bind_button_feedback(button)

func _clone_style(style: StyleBox) -> StyleBox:
	return style.duplicate() as StyleBox

func _tune_button_style(style: StyleBox, kind: String) -> StyleBox:
	var flat_style := style as StyleBoxFlat
	if flat_style == null:
		return style

	var radius := 8
	var top_margin := 7.0
	var side_margin := 10.0

	if kind == "primary":
		radius = 9
		top_margin = 9.0
		side_margin = 14.0

	flat_style.set_corner_radius_all(radius)
	flat_style.content_margin_left = side_margin
	flat_style.content_margin_top = top_margin
	flat_style.content_margin_right = side_margin
	flat_style.content_margin_bottom = top_margin
	flat_style.shadow_size = min(flat_style.shadow_size, 7)
	return flat_style

func _get_rarity_slot_resource(rarity: String) -> StyleBoxFlat:
	match rarity:
		"legendary":
			return RARITY_LEGENDARY_STYLE
		"very_rare", "epic":
			return RARITY_EPIC_STYLE
		"rare":
			return RARITY_RARE_STYLE
		"uncommon":
			return RARITY_UNCOMMON_STYLE
		_:
			return make_style(SLOT_BG, BORDER_FAINT, 10, 4, Color(0.0, 0.0, 0.0, 0.16))

func _bind_button_feedback(button: Button) -> void:
	if button.has_meta("_tuman_feedback_bound"):
		return

	button.set_meta("_tuman_feedback_bound", true)
	button.mouse_entered.connect(func() -> void:
		_animate_button_scale(button, Vector2(1.012, 1.012), 0.08)
	)
	button.mouse_exited.connect(func() -> void:
		_animate_button_scale(button, Vector2.ONE, 0.10)
	)
	button.button_down.connect(func() -> void:
		_animate_button_scale(button, Vector2(0.982, 0.982), 0.045)
	)
	button.button_up.connect(func() -> void:
		_animate_button_scale(button, Vector2.ONE, 0.08)
	)

func _animate_button_scale(button: Button, target_scale: Vector2, duration: float) -> void:
	if not is_instance_valid(button) or button.disabled:
		return

	button.pivot_offset = button.size * 0.5
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, duration)

func _ensure_label_font_size(label: Label, font_size: int) -> void:
	if not label.has_theme_font_size_override("font_size"):
		label.add_theme_font_size_override("font_size", font_size)
