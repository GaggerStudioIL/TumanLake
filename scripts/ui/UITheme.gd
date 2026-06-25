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
const CAST_BUTTON_REGULAR := preload("res://assets/ui/buttons/cast/button_cast_regular.png")
const CAST_BUTTON_HOVER := preload("res://assets/ui/buttons/cast/button_cast_active.png")
const CAST_BUTTON_PRESSED := preload("res://assets/ui/buttons/cast/button_cast_pressed.png")
const CAST_BUTTON_DISABLED := preload("res://assets/ui/buttons/cast/button_cast_disable.png")
const PULL_BUTTON_REGULAR := preload("res://assets/ui/buttons/pull/button_pull_regular.png")
const PULL_BUTTON_HOVER := preload("res://assets/ui/buttons/pull/button_pull_active.png")
const PULL_BUTTON_PRESSED := preload("res://assets/ui/buttons/pull/button_pull_pressed.png")
const PULL_BUTTON_DISABLED := preload("res://assets/ui/buttons/pull/button_pull_disable.png")
const PROGRESS_TRACK_STYLE := preload("res://assets/ui/hud/progress_track.tres")
const PROGRESS_FILL_GREEN_STYLE := preload("res://assets/ui/hud/progress_fill_green.tres")
const HUD_BADGE_STYLE := preload("res://assets/ui/hud/hud_badge.tres")
const INVENTORY_SLOT_STYLE := preload("res://assets/ui/inventory/inventory_slot.tres")
const RARITY_UNCOMMON_STYLE := preload("res://assets/ui/inventory/rarity_uncommon.tres")
const RARITY_RARE_STYLE := preload("res://assets/ui/inventory/rarity_rare.tres")
const RARITY_EPIC_STYLE := preload("res://assets/ui/inventory/rarity_epic.tres")
const RARITY_LEGENDARY_STYLE := preload("res://assets/ui/inventory/rarity_legendary.tres")

const ICON_FISH := preload("res://assets/ui/icons/icon_fish.png")
const ICON_FISH_ATLAS := preload("res://assets/ui/icons/icon_fish_atlas.png")
const ICON_BAIT := preload("res://assets/ui/icons/icon_bait.png")
const ICON_ROD := preload("res://assets/ui/icons/icon_rod.png")
const ICON_SHOP := preload("res://assets/ui/icons/icon_shop.png")
const ICON_HARBOR := preload("res://assets/ui/icons/icon_harbor.png")
const ICON_INVENTORY := preload("res://assets/ui/icons/icon_inventory.png")
const ICON_KEEPNET := preload("res://assets/ui/icons/icon_keepnet.png")
const ICON_MAP := preload("res://assets/ui/icons/icon_map.png")
const ICON_PROFILE := preload("res://assets/ui/icons/icon_profile.png")
const ICON_MONEY := preload("res://assets/ui/icons/icon_money.png")
const ICON_TIME := preload("res://assets/ui/icons/icon_time.png")
const ICON_WEATHER_CLEAR := preload("res://assets/ui/icons/icon_weather_clear.png")
const ICON_WEATHER_CLOUDY := preload("res://assets/ui/icons/icon_weather_cloudy.png")
const ICON_WEATHER_RAINY := preload("res://assets/ui/icons/icon_weather_rainy.png")
const ICON_WEATHER_STORM := preload("res://assets/ui/icons/icon_weather_storm.png")
const ICON_WEATHER_FOG := preload("res://assets/ui/icons/icon_weather_fog.png")
const ICON_HOOK := preload("res://assets/ui/icons/icon_hook.png")
const ICON_LOCATION := preload("res://assets/ui/icons/icon_location.png")
const ICON_SETTINGS := preload("res://assets/ui/icons/icon_settings.png")
const ICON_LINE := preload("res://assets/ui/icons/icon_line.png")
const HUD_ICON_ACTION_CAST := preload("res://assets/ui/icons/hud/action_throw_away.png")
const HUD_ICON_ACTION_HOOK := preload("res://assets/ui/icons/hud/action_hook_new.png")
const HUD_ICON_ACTION_PULL := preload("res://assets/ui/icons/hud/action_pull_fish.png")
const HUD_ICON_ACTION_PULL_OUT := preload("res://assets/ui/icons/hud/action_pull_out.png")
const HUD_ICON_FEED := preload("res://assets/ui/icons/hud/feed.svg")
const HUD_ICON_BAIT := preload("res://assets/ui/icons/hud/bait.svg")
const HUD_ICON_TACKLE := preload("res://assets/ui/icons/hud/tackle.svg")
const SIDE_MENU_ICON_KEEPNET := preload("res://assets/ui/icons/side_menu/optimized/sadok.png")
const SIDE_MENU_ICON_INVENTORY := preload("res://assets/ui/icons/side_menu/optimized/inventory.png")
const SIDE_MENU_ICON_SHOP := preload("res://assets/ui/icons/side_menu/optimized/shop.png")
const SIDE_MENU_ICON_HARBOR := preload("res://assets/ui/icons/side_menu/optimized/harbor.png")
const SIDE_MENU_ICON_MAP := preload("res://assets/ui/icons/side_menu/optimized/map.png")
const SIDE_MENU_ICON_PROFILE := preload("res://assets/ui/icons/side_menu/optimized/profile.png")
const SIDE_MENU_ICON_FISH_ATLAS := preload("res://assets/ui/icons/side_menu/optimized/fish_atlas.png")
const SIDE_MENU_ICON_SETTINGS := preload("res://assets/ui/icons/side_menu/optimized/settings.png")
const UX_ICON_KEEPNET := preload("res://assets/ui/ux/fishing_spot/keepnet.png")
const UX_ICON_CART := preload("res://assets/ui/ux/fishing_spot/cart.png")
const UX_ICON_SHOP_CHEST := preload("res://assets/ui/ux/fishing_spot/shop_chest.png")
const UX_ICON_BACKPACK := preload("res://assets/ui/ux/fishing_spot/backpack.png")
const UX_ICON_MAP_PIN := preload("res://assets/ui/ux/fishing_spot/map_pin.png")
const UX_ICON_FISH_ATLAS_BOOK := preload("res://assets/ui/ux/fishing_spot/fish_atlas_book.png")
const UX_ICON_ATLAS := preload("res://assets/ui/ux/fishing_spot/atlas.png")
const UX_ICON_HARBOR_CHEST := preload("res://assets/ui/ux/fishing_spot/gavan.png")
const UX_ICON_SETTINGS_GEAR := preload("res://assets/ui/ux/fishing_spot/settings_gear.png")
const UX_ICON_MONEY_COIN := preload("res://assets/ui/ux/fishing_spot/money_coin.png")
const UX_ICON_WEATHER_CLOUD := preload("res://assets/ui/ux/fishing_spot/weather_cloud.png")
const UX_ICON_TEMPERATURE := preload("res://assets/ui/ux/fishing_spot/temperature_neon.png")
const UX_ICON_WIND := preload("res://assets/ui/ux/fishing_spot/wind_neon.png")

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
const DANGER := Color(0.42, 0.085, 0.070, 0.95)
const DANGER_HOVER := Color(0.56, 0.110, 0.090, 1.0)
const DANGER_PRESSED := Color(0.30, 0.060, 0.052, 1.0)
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

func get_window_v1_style() -> StyleBoxFlat:
	var style := make_style(Color(0.012, 0.024, 0.026, 0.92), Color(0.70, 0.88, 0.76, 0.38), 8, 12, Color(0.0, 0.0, 0.0, 0.42))
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	return style

func get_window_v1_section_style(variant: String = "default") -> StyleBoxFlat:
	var bg := Color(0.020, 0.034, 0.036, 0.62)
	var border := Color(0.62, 0.80, 0.74, 0.18)
	var shadow := Color(0.0, 0.0, 0.0, 0.16)
	if variant == "details":
		bg = Color(0.014, 0.028, 0.030, 0.78)
		border = Color(0.64, 0.86, 0.72, 0.34)
		shadow = Color(0.0, 0.0, 0.0, 0.24)
	elif variant == "footer":
		bg = Color(0.018, 0.030, 0.030, 0.66)
		border = Color(0.58, 0.78, 0.68, 0.20)
	var style := make_style(bg, border, 7, 5, shadow)
	style.content_margin_left = 10.0
	style.content_margin_top = 7.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 7.0
	return style

func get_item_card_v1_style(active := false, equipped := false, dimmed := false, rarity := "common") -> StyleBoxFlat:
	var style := get_shop_row_style(rarity)
	style.set_corner_radius_all(7)
	style.content_margin_left = 8.0
	style.content_margin_top = 8.0
	style.content_margin_right = 8.0
	style.content_margin_bottom = 8.0
	style.shadow_size = 4
	if active:
		style.bg_color = Color(0.058, 0.118, 0.074, 0.82)
		style.border_color = Color(0.70, 1.0, 0.62, 0.58)
		style.shadow_color = Color(0.20, 0.72, 0.24, 0.18)
		style.shadow_size = 7
	elif equipped:
		style.bg_color = Color(0.048, 0.094, 0.066, 0.74)
		style.border_color = Color(0.58, 0.92, 0.56, 0.38)
	elif dimmed:
		style.bg_color = Color(0.034, 0.040, 0.040, 0.64)
		style.border_color = Color(0.58, 0.62, 0.60, 0.14)
	return style

func get_item_image_slot_v1_style(active := false, rarity := "common") -> StyleBoxFlat:
	var style := get_inventory_slot_style(active, rarity)
	style.set_corner_radius_all(6)
	style.shadow_size = 3
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	return style

func get_status_badge_v1_style(variant: String = "equipped") -> StyleBoxFlat:
	var bg := Color(0.08, 0.26, 0.10, 0.94)
	var border := Color(0.62, 1.0, 0.52, 0.48)
	if variant == "danger":
		bg = Color(0.35, 0.060, 0.052, 0.92)
		border = Color(1.0, 0.42, 0.35, 0.42)
	elif variant == "muted":
		bg = Color(0.050, 0.060, 0.060, 0.82)
		border = Color(0.58, 0.66, 0.62, 0.18)
	return make_style(bg, border, 5, 0, Color(0.0, 0.0, 0.0, 0.14))

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
		"danger":
			bg = DANGER
			border = Color(1.0, 0.42, 0.35, 0.42)
			shadow = Color(0.75, 0.10, 0.06, 0.18)
			radius = 9
			shadow_size = 6
			if state == "hover":
				bg = DANGER_HOVER
				border = Color(1.0, 0.50, 0.42, 0.58)
			elif state == "pressed":
				bg = DANGER_PRESSED
				shadow_size = 3
			elif state == "disabled":
				bg = Color(0.070, 0.050, 0.050, 0.52)
				border = Color(0.56, 0.44, 0.42, 0.14)
				shadow = Color(0.0, 0.0, 0.0, 0.08)
		"disabled":
			bg = Color(0.045, 0.055, 0.056, 0.42)
			border = Color(0.58, 0.64, 0.62, 0.12)
			shadow = Color(0.0, 0.0, 0.0, 0.10)
			radius = 8
			shadow_size = 2
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

func get_tackle_panel_style(strong := false) -> StyleBoxFlat:
	var bg := Color(0.012, 0.036, 0.052, 0.94) if strong else Color(0.020, 0.072, 0.092, 0.76)
	var border := Color(0.42, 0.84, 0.94, 0.38)
	var style := make_style(bg, border, 7, 8, Color(0.0, 0.0, 0.0, 0.34))
	style.content_margin_left = 12.0
	style.content_margin_top = 10.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 10.0
	return style

func get_tackle_slot_style(state: String = "empty") -> StyleBoxFlat:
	var bg := Color(0.020, 0.078, 0.098, 0.82)
	var border := Color(0.42, 0.84, 0.94, 0.34)
	var shadow := Color(0.0, 0.0, 0.0, 0.22)
	var shadow_size := 5

	match state:
		"selected":
			bg = Color(0.056, 0.118, 0.126, 0.94)
			border = Color(0.96, 0.72, 0.28, 0.88)
			shadow = Color(0.92, 0.56, 0.12, 0.22)
			shadow_size = 8
		"filled":
			bg = Color(0.022, 0.110, 0.100, 0.84)
			border = Color(0.45, 0.90, 0.58, 0.56)
			shadow = Color(0.18, 0.65, 0.34, 0.16)
		"locked":
			bg = Color(0.034, 0.045, 0.052, 0.66)
			border = Color(0.46, 0.50, 0.52, 0.24)
			shadow = Color(0.0, 0.0, 0.0, 0.12)
			shadow_size = 2
		"hover":
			bg = Color(0.050, 0.135, 0.150, 0.84)
			border = Color(0.76, 0.90, 0.80, 0.44)
		"pressed":
			bg = Color(0.035, 0.100, 0.096, 0.90)
			border = Color(0.84, 0.66, 0.30, 0.68)

	var style := make_style(bg, border, 8, shadow_size, shadow)
	style.content_margin_left = 12.0
	style.content_margin_top = 8.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 8.0
	return style

func get_tackle_primary_action_style(state: String = "normal") -> StyleBoxFlat:
	var bg := Color(0.52, 0.36, 0.10, 0.95)
	var border := Color(0.95, 0.73, 0.28, 0.78)
	var shadow := Color(0.82, 0.50, 0.10, 0.24)
	var shadow_size := 9
	if state == "hover":
		bg = Color(0.66, 0.45, 0.13, 1.0)
		border = Color(1.0, 0.82, 0.34, 0.92)
	elif state == "pressed":
		bg = Color(0.38, 0.26, 0.08, 1.0)
		shadow_size = 4
	elif state == "disabled":
		bg = Color(0.11, 0.14, 0.14, 0.62)
		border = Color(0.58, 0.62, 0.58, 0.16)
		shadow = Color.TRANSPARENT
	return make_style(bg, border, 8, shadow_size, shadow)

func get_icon(icon_name: String) -> Texture2D:
	match icon_name:
		"hud_cast":
			return HUD_ICON_ACTION_CAST
		"hud_hook":
			return HUD_ICON_ACTION_HOOK
		"hud_pull":
			return HUD_ICON_ACTION_PULL
		"hud_pull_out":
			return HUD_ICON_ACTION_PULL_OUT
		"hud_feed":
			return HUD_ICON_FEED
		"hud_bait":
			return HUD_ICON_BAIT
		"hud_tackle":
			return HUD_ICON_TACKLE
		"hook", "cast":
			return ICON_HOOK
		"fish", "fishing":
			return ICON_FISH
		"encyclopedia", "atlas", "fish_atlas":
			return ICON_FISH_ATLAS
		"basket", "keepnet":
			return UX_ICON_KEEPNET
		"bait":
			return ICON_BAIT
		"rod", "tackle":
			return ICON_ROD
		"gear", "settings":
			return ICON_SETTINGS
		"cart", "shop":
			return UX_ICON_CART
		"harbor", "fish_harbor":
			return ICON_HARBOR
		"money":
			return UX_ICON_MONEY_COIN
		"location":
			return ICON_LOCATION
		"profile":
			return ICON_PROFILE
		"inventory":
			return ICON_INVENTORY
		"map":
			return ICON_MAP
		"weather", "weather_clear":
			return UX_ICON_WEATHER_CLOUD
		"weather_cloudy":
			return UX_ICON_WEATHER_CLOUD
		"weather_rainy":
			return ICON_WEATHER_RAINY
		"weather_storm":
			return ICON_WEATHER_STORM
		"weather_fog":
			return ICON_WEATHER_FOG
		"time":
			return ICON_TIME
		"temperature":
			return UX_ICON_TEMPERATURE
		"wind":
			return UX_ICON_WIND
		"line":
			return ICON_LINE
		_:
			return null

func get_cast_button_size() -> Vector2:
	return CAST_BUTTON_REGULAR.get_size()

func get_cast_button_texture(state: String = "regular") -> Texture2D:
	match state:
		"hover", "active":
			return CAST_BUTTON_HOVER
		"pressed":
			return CAST_BUTTON_PRESSED
		"disabled":
			return CAST_BUTTON_DISABLED
		_:
			return CAST_BUTTON_REGULAR

func get_pull_button_size() -> Vector2:
	return PULL_BUTTON_REGULAR.get_size()

func get_pull_button_texture(state: String = "regular") -> Texture2D:
	match state:
		"hover", "active":
			return PULL_BUTTON_HOVER
		"pressed":
			return PULL_BUTTON_PRESSED
		"disabled":
			return PULL_BUTTON_DISABLED
		_:
			return PULL_BUTTON_REGULAR

func apply_cast_button_hitbox_style(button: Button, target_size: Vector2 = Vector2.ZERO) -> void:
	var button_size := get_cast_button_size() if target_size == Vector2.ZERO else target_size
	button.custom_minimum_size = button_size
	button.size = button_size
	button.icon = null
	button.expand_icon = false
	var empty_style := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty_style)
	button.add_theme_stylebox_override("hover", empty_style)
	button.add_theme_stylebox_override("pressed", empty_style)
	button.add_theme_stylebox_override("disabled", empty_style)
	button.add_theme_stylebox_override("focus", empty_style)
	button.add_theme_color_override("font_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_disabled_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_focus_color", Color.TRANSPARENT)
	button.add_theme_constant_override("h_separation", 0)
	button.add_theme_constant_override("icon_max_width", 0)
	_bind_button_feedback(button)

func apply_cast_button_style(button: Button, target_size: Vector2 = Vector2.ZERO) -> void:
	apply_cast_button_hitbox_style(button, target_size)

func apply_pull_button_hitbox_style(button: Button, target_size: Vector2 = Vector2.ZERO) -> void:
	var button_size := get_pull_button_size() if target_size == Vector2.ZERO else target_size
	apply_cast_button_hitbox_style(button, button_size)

func apply_pull_button_style(button: Button, target_size: Vector2 = Vector2.ZERO) -> void:
	apply_pull_button_hitbox_style(button, target_size)

func get_atlas_icon(icon_name: String) -> Texture2D:
	match icon_name:
		_:
			return null

func get_side_menu_icon(icon_name: String) -> Texture2D:
	match icon_name:
		"keepnet", "basket", "sadok":
			return UX_ICON_KEEPNET
		"inventory":
			return UX_ICON_BACKPACK
		"shop":
			return UX_ICON_CART
		"harbor", "fish_harbor":
			return UX_ICON_HARBOR_CHEST
		"map":
			return UX_ICON_MAP_PIN
		"profile":
			return SIDE_MENU_ICON_PROFILE
		"encyclopedia", "atlas":
			return UX_ICON_ATLAS
		"settings":
			return UX_ICON_SETTINGS_GEAR
		_:
			return null

func get_side_menu_button_style(state: String = "normal") -> StyleBoxFlat:
	var bg := Color(0.010, 0.020, 0.022, 0.78)
	var border := Color(0.82, 0.94, 0.92, 0.42)
	var shadow := Color(0.0, 0.0, 0.0, 0.36)
	var shadow_size := 5

	match state:
		"hover":
			bg = Color(0.020, 0.054, 0.056, 0.88)
			border = Color(0.68, 0.98, 1.0, 0.70)
			shadow = Color(0.08, 0.72, 0.84, 0.18)
			shadow_size = 8
		"pressed":
			bg = Color(0.018, 0.042, 0.044, 0.94)
			border = Color(0.56, 0.86, 0.92, 0.62)
			shadow = Color(0.0, 0.0, 0.0, 0.22)
			shadow_size = 3
		"active":
			bg = Color(0.026, 0.076, 0.078, 0.90)
			border = Color(0.64, 1.0, 1.0, 0.78)
			shadow = Color(0.08, 0.78, 0.92, 0.22)
			shadow_size = 9
		"disabled":
			bg = Color(0.018, 0.024, 0.026, 0.44)
			border = Color(0.68, 0.76, 0.74, 0.16)
			shadow = Color(0.0, 0.0, 0.0, 0.12)
			shadow_size = 1

	var style := make_style(bg, border, 12, shadow_size, shadow)
	style.set_border_width_all(2)
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	return style

func apply_side_menu_button_style(button: Button, active := false) -> void:
	var empty_style := StyleBoxEmpty.new()
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", get_side_menu_button_style("active" if active else "normal"))
	button.add_theme_stylebox_override("hover", get_side_menu_button_style("hover"))
	button.add_theme_stylebox_override("pressed", get_side_menu_button_style("pressed"))
	button.add_theme_stylebox_override("disabled", get_side_menu_button_style("disabled"))
	button.add_theme_stylebox_override("focus", empty_style)
	button.add_theme_color_override("font_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_disabled_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_focus_color", Color.TRANSPARENT)
	button.add_theme_constant_override("h_separation", 0)
	button.add_theme_constant_override("icon_max_width", 0)
	_bind_button_feedback(button)

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

func apply_window_v1_style(control) -> void:
	if control is Panel:
		control.add_theme_stylebox_override("panel", get_window_v1_style())
	elif control is ColorRect:
		control.color = Color(0.012, 0.024, 0.026, 0.92)

func apply_window_v1_section_style(control, variant: String = "default") -> void:
	if control is Panel:
		control.add_theme_stylebox_override("panel", get_window_v1_section_style(variant))
	elif control is ColorRect:
		control.color = Color(0.020, 0.034, 0.036, 0.62)

func apply_item_card_v1_style(control, active := false, equipped := false, dimmed := false, rarity := "common") -> void:
	if control is Button:
		var button := control as Button
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_stylebox_override("normal", get_item_card_v1_style(active, equipped, dimmed, rarity))
		button.add_theme_stylebox_override("hover", _brighten_card_style(get_item_card_v1_style(active, equipped, dimmed, rarity)))
		button.add_theme_stylebox_override("pressed", _press_card_style(get_item_card_v1_style(active, equipped, dimmed, rarity)))
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.add_theme_color_override("font_color", Color.TRANSPARENT)
		button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
		button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
	elif control is Panel:
		control.add_theme_stylebox_override("panel", get_item_card_v1_style(active, equipped, dimmed, rarity))

func apply_item_image_slot_v1_style(control, active := false, rarity := "common") -> void:
	if control is Panel:
		control.add_theme_stylebox_override("panel", get_item_image_slot_v1_style(active, rarity))

func apply_status_badge_v1_style(label: Label, variant: String = "equipped") -> void:
	if label == null:
		return
	label.add_theme_stylebox_override("normal", get_status_badge_v1_style(variant))
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_color", TEXT_PRIMARY)

func apply_button_variant_style(button: Button, variant: String = "secondary") -> void:
	match variant:
		"primary":
			apply_primary_button_style(button)
		"danger":
			_apply_button(button, "danger", 44.0, 14)
		"disabled":
			_apply_button(button, "disabled", 44.0, 14)
		_:
			apply_secondary_button_style(button)

func apply_filter_button_style(button: Button, active := false) -> void:
	_apply_button(button, "tab_active" if active else "tab", 30.0, 12)

func apply_sort_option_style(button: Button) -> void:
	_apply_button(button, "secondary", 30.0, 12)

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

func apply_tackle_panel_style(control, strong := false) -> void:
	if control is Panel:
		control.add_theme_stylebox_override("panel", get_tackle_panel_style(strong))
	elif control is ColorRect:
		control.color = Color(0.022, 0.060, 0.082, 0.90) if strong else Color(0.028, 0.083, 0.110, 0.72)

func apply_tackle_slot_button_style(button: Button, state: String = "empty") -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", get_tackle_slot_style(state))
	button.add_theme_stylebox_override("hover", get_tackle_slot_style("hover" if state != "locked" else "locked"))
	button.add_theme_stylebox_override("pressed", get_tackle_slot_style("pressed" if state != "locked" else "locked"))
	button.add_theme_stylebox_override("disabled", get_tackle_slot_style("locked"))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", TEXT_PRIMARY if state != "locked" else Color(0.58, 0.64, 0.66, 0.88))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.91, 0.66, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.92, 0.78, 0.46, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.50, 0.56, 0.58, 0.78))
	button.add_theme_constant_override("h_separation", 6)
	_bind_button_feedback(button)

func apply_tackle_primary_action_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", get_tackle_primary_action_style("normal"))
	button.add_theme_stylebox_override("hover", get_tackle_primary_action_style("hover"))
	button.add_theme_stylebox_override("pressed", get_tackle_primary_action_style("pressed"))
	button.add_theme_stylebox_override("disabled", get_tackle_primary_action_style("disabled"))
	button.add_theme_color_override("font_color", Color(1.0, 0.96, 0.86, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.92, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.95, 0.86, 0.66, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.62, 0.66, 0.64, 0.70))
	button.add_theme_font_size_override("font_size", 15)
	_bind_button_feedback(button)

func apply_meter_track_style(track: ColorRect, fill: ColorRect = null, accent: Color = GREEN_HOVER) -> void:
	track.color = Color(0.10, 0.145, 0.145, 0.92)
	if fill != null:
		fill.color = Color(accent.r, accent.g, accent.b, 0.78)

func apply_modal_backdrop_style(control) -> void:
	if control is ColorRect:
		control.color = BACKDROP_BG
	control.mouse_filter = Control.MOUSE_FILTER_STOP

func _make_texture_style(texture: Texture2D) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	return style

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

func _brighten_card_style(style: StyleBoxFlat) -> StyleBoxFlat:
	style.bg_color = Color(
		minf(style.bg_color.r + 0.022, 1.0),
		minf(style.bg_color.g + 0.030, 1.0),
		minf(style.bg_color.b + 0.022, 1.0),
		style.bg_color.a
	)
	style.border_color = Color(0.82, 0.98, 0.84, maxf(style.border_color.a, 0.38))
	style.shadow_size = max(style.shadow_size, 5)
	return style

func _press_card_style(style: StyleBoxFlat) -> StyleBoxFlat:
	style.bg_color = Color(
		maxf(style.bg_color.r - 0.014, 0.0),
		maxf(style.bg_color.g - 0.012, 0.0),
		maxf(style.bg_color.b - 0.014, 0.0),
		style.bg_color.a
	)
	style.shadow_size = 2
	return style

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

func _bind_button_feedback(button: BaseButton) -> void:
	button.focus_mode = Control.FOCUS_NONE
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

func _animate_button_scale(button: BaseButton, target_scale: Vector2, duration: float) -> void:
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
