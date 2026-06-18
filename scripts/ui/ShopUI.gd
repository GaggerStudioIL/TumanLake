# Handles the shop window: categories, item cards, and buy requests.
extends RefCounted

var main
var theme
var _texture_cache: Dictionary = {}
var _details_backdrop: ColorRect
var _details_panel: Panel
var _details_title_label: Label
var _details_image: TextureRect
var _details_description_label: Label
var _details_stats_label: Label
var _details_owned_label: Label
var _details_buy_button: Button
var _details_close_button: Button
var _shop_money_row: HBoxContainer
var _details_item_id := ""
var _shop_card_trimmed_texture_cache: Dictionary = {}
signal buy_requested(item_id: String)

const SHOP_SCROLL_BOTTOM_PADDING := 72.0
const SHOP_LINE_IMAGE_SIZE := Vector2(75.0, 75.0)
const SHOP_CATEGORY_BAIT := "bait"
const SHOP_CATEGORY_CONSUMABLE := "consumable"
const SHOP_CATEGORY_FOOD := "food"
const SHOP_CATEGORY_CLOTHING := "clothing"
const SHOP_CATEGORY_TACKLE := "tackle"
const SHOP_CATEGORY_ROD := "rod"
const SHOP_CATEGORY_LINE := "line"
const SHOP_CATEGORY_LEADER := "leader"
const SHOP_CATEGORY_HOOK := "hook"
const SHOP_CATEGORY_FLOAT := "float"
const SHOP_TAB_ICON_BAIT: Texture2D = preload("res://assets/ui/shop/baits/cherv.png")
const SHOP_TAB_ICON_FOOD: Texture2D = preload("res://assets/ui/shop/survival/food/bread.png")
const SHOP_TAB_ICON_CLOTHING: Texture2D = preload("res://assets/ui/shop/survival/clothing/basic_tshirt.png")
const SHOP_TAB_ICON_LINE: Texture2D = preload("res://assets/ui/shop/lines/basiclinenylon2_5kg.png")
const SHOP_TAB_ICON_LEADER: Texture2D = preload("res://assets/ui/shop/leaders/nylon_leader_15cm_1kg.png")
const SHOP_TAB_ICON_HOOK: Texture2D = preload("res://assets/ui/shop/hooks/riverstart_basic_hook_12.png")
const SHOP_TAB_ICON_FLOAT: Texture2D = preload("res://assets/ui/tackle/floats/float_drop.png")
const SHOP_CATEGORIES := [
	SHOP_CATEGORY_BAIT,
	SHOP_CATEGORY_FOOD,
	SHOP_CATEGORY_CLOTHING,
	SHOP_CATEGORY_CONSUMABLE,
	SHOP_CATEGORY_ROD,
	SHOP_CATEGORY_LINE,
	SHOP_CATEGORY_LEADER,
	SHOP_CATEGORY_HOOK,
	SHOP_CATEGORY_FLOAT
]
const BAIT_PACK_QUANTITIES := {
	"worm": 10,
	"bread": 12,
	"dough": 10,
	"maggot": 8,
	"cherv_moskovskiy": 10,
	"cherv_surskiy": 10,
	"kaster": 10,
	"lichinka_podenki": 8,
	"lichinka_vesnyanki": 8,
	"motil": 12,
	"krabovoe_myaso": 6,
	"cherv_navozni": 10,
	"piyavka": 6,
	"goroshek": 12,
	"kartofelniy_kubik": 10,
	"cherv_astrahanskiy": 10,
	"myaso_dreiseni": 8,
	"rucheinik": 8,
	"puchok_vodorosley": 8,
	"ovsyanaya_kasha": 10,
	"sverchok": 8,
	"syrni_kubik": 10,
	"kuznechik": 8,
	"sladkoe_testo": 10,
	"lichinka_koroeda": 8,
	"podenka": 8,
	"chesnochnoye_testo": 10,
	"mannaya_kasha": 10,
	"cherv_volhovskiy": 10,
	"ikra": 6,
	"gorohovaya_kasha": 10,
	"bokoplav": 8,
	"kukuruznaya_kasha": 10,
	"yaichonoe_testo": 10,
	"muha": 8,
	"maiskiy_zhuk": 6,
	"zerna_phenici": 12,
	"myaso_perlovici": 8,
	"ovod": 8,
	"lichinka_zhukanosoroga": 6,
	"slepen": 8,
	"rakovaia_sheika": 6,
	"zerna_kukuruzi": 12,
	"cherv_leningradskiy": 10,
	"kapustni_list": 10,
	"kusochki_ryby": 8,
	"tvorozhnoye_testo": 10,
	"perlovaya_kasha": 10,
	"zhuk_navozni": 6,
	"medovoye_testo": 10,
	"medvedka": 6,
	"lichinka_mayskogozhuka": 6,
	"zhuk_plavunec": 6,
	"vipolzok": 6,
	"fish_piece": 6,
	"small_live_bait": 5,
	"frog_bait": 5,
	"shrimp": 8,
	"snail": 8,
	"boilie_simple": 6
}
const CONSUMABLE_ITEMS := [
	{
		"id": "groundbait_light",
		"shop_category": SHOP_CATEGORY_CONSUMABLE,
		"icon": "G",
		"name": "Прикормка",
		"category": "misc",
		"quantity": 3,
		"price": 45,
		"description": "Базовая прикормка. Пока расходник для будущей механики.",
		"stats": {
			"effect": "groundbait",
			"bite_bonus": 0.12
		}
	}
]
const ROD_CARD_TEXTURE_PATHS := {
	"green_line_xs_light": "res://assets/ui/shop/rods/green_line_xs_light.png",
	"green_line_breeze_pole": "res://assets/ui/shop/rods/green_line_breeze_pole.png",
	"green_line_river_pro": "res://assets/ui/shop/rods/green_line_river_pro.png",
	"green_line_silver_flow": "res://assets/ui/shop/rods/green_line_silver_flow.png",
	"green_line_xh_master": "res://assets/ui/shop/rods/green_line_xh_master.png",
	"nordriver_ice_reed": "res://assets/ui/shop/rods/nordriver_ice_reed.png",
	"nordriver_arctic_pole": "res://assets/ui/shop/rods/nordriver_arctic_pole.png",
	"nordriver_stream_hunter": "res://assets/ui/shop/rods/nordriver_stream_hunter.png",
	"nordriver_white_pike": "res://assets/ui/shop/rods/nordriver_white_pike.png",
	"nordriver_carbon_wind": "res://assets/ui/shop/rods/nordriver_carbon_wind.png",
	"sakura_fish_hana_light": "res://assets/ui/shop/rods/sakura_fish_hana_light.png",
	"sakura_fish_koi_master": "res://assets/ui/shop/rods/sakura_fish_koi_master.png",
	"sakura_fish_red_moon": "res://assets/ui/shop/rods/sakura_fish_red_moon.png",
	"sakura_fish_silent_river": "res://assets/ui/shop/rods/sakura_fish_silent_river.png",
	"titan_hook_iron_flex": "res://assets/ui/shop/rods/titan_hook_iron_flex.png",
	"titan_hook_black_carbon": "res://assets/ui/shop/rods/titan_hook_black_carbon.png",
	"titan_hook_predator_x": "res://assets/ui/shop/rods/titan_hook_predator_x.png",
	"titan_hook_storm_pole": "res://assets/ui/shop/rods/titan_hook_storm_pole.png",
	"titan_hook_ultra_match": "res://assets/ui/shop/rods/titan_hook_ultra_match.png"
}
const ROD_CARD_BADGE_NUMBERS := {
	"green_line_xs_light": 1,
	"green_line_river_pro": 2,
	"green_line_breeze_pole": 3,
	"green_line_silver_flow": 4,
	"green_line_xh_master": 5,
	"nordriver_ice_reed": 6,
	"nordriver_arctic_pole": 7,
	"nordriver_stream_hunter": 8,
	"nordriver_white_pike": 9,
	"nordriver_carbon_wind": 10,
	"sakura_fish_hana_light": 11,
	"sakura_fish_koi_master": 12,
	"sakura_fish_red_moon": 13,
	"sakura_fish_silent_river": 14,
	"titan_hook_iron_flex": 15,
	"titan_hook_black_carbon": 16,
	"titan_hook_predator_x": 17,
	"titan_hook_storm_pole": 18,
	"titan_hook_ultra_match": 19
}

func _format_shop_money_amount(value: float) -> String:
	return UIFormatters.format_money_amount(value)


func _add_shop_price_row(
	parent: Control,
	value: float,
	rect: Rect2,
	font_size: int = 11,
	icon_size: Vector2 = Vector2(15.0, 15.0),
	align_end: bool = true,
	text_color: Color = Color(0.94, 1.0, 0.91, 1.0),
	row_name: String = "ShopPriceRow"
) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = row_name
	row.position = rect.position
	row.size = rect.size
	row.custom_minimum_size = rect.size
	row.clip_contents = true
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 4)
	parent.add_child(row)
	_set_shop_price_row(row, value, rect.size, font_size, icon_size, align_end, text_color)
	return row


func _set_shop_price_row(
	row: HBoxContainer,
	value: float,
	row_size: Vector2,
	font_size: int,
	icon_size: Vector2,
	align_end: bool,
	text_color: Color
) -> void:
	if row == null:
		return

	row.size = row_size
	row.custom_minimum_size = row_size
	row.clip_contents = true
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_END if align_end else BoxContainer.ALIGNMENT_BEGIN
	row.add_theme_constant_override("separation", 4)

	var label := row.get_node_or_null("PriceLabel") as Label
	if label == null:
		label = Label.new()
		label.name = "PriceLabel"
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(label)
	label.text = _format_shop_money_amount(value)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if align_end else HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = align_end
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL if align_end else Control.SIZE_SHRINK_BEGIN
	label.custom_minimum_size = Vector2(maxf(row_size.x - icon_size.x - 5.0, 18.0), row_size.y) if align_end else Vector2(0.0, row_size.y)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", text_color)

	var icon_slot := row.get_node_or_null("MoneyIconSlot") as Control
	if icon_slot == null:
		icon_slot = Control.new()
		icon_slot.name = "MoneyIconSlot"
		icon_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_slot.clip_contents = true
		icon_slot.size_flags_horizontal = Control.SIZE_SHRINK_END
		row.add_child(icon_slot)
	icon_slot.custom_minimum_size = icon_size
	icon_slot.size = icon_size

	var icon := icon_slot.get_node_or_null("MoneyIcon") as TextureRect
	if icon == null:
		icon = TextureRect.new()
		icon.name = "MoneyIcon"
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		icon_slot.add_child(icon)
	icon.texture = theme.get_icon("money")
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 0.0
	icon.offset_top = 0.0
	icon.offset_right = 0.0
	icon.offset_bottom = 0.0
	icon.custom_minimum_size = icon_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.modulate = Color(0.78, 0.84, 0.80, 0.95)

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	_ensure_shop_ui_nodes()
	_hide_shop_pager()
	_ensure_shop_details_nodes()

func _is_beta_consumable_shop_hidden() -> bool:
	return BuildConfig.IS_BETA_BUILD

func open() -> void:
	if main._is_catch_reward_open():
		return
	if main.shop_button != null and main.shop_button.visible and main.shop_button.disabled:
		return
	if main._shop_category == SHOP_CATEGORY_TACKLE:
		main._shop_category = SHOP_CATEGORY_ROD
	if _is_beta_consumable_shop_hidden() and main._shop_category == SHOP_CATEGORY_CONSUMABLE:
		main._shop_category = SHOP_CATEGORY_BAIT

	main.open_modal("shop")
	main._active_nav_tab = "shop"
	main.shop_backdrop.visible = true
	main.shop_panel.visible = true
	refresh()
	if main.has_method("refresh_mobile_scroll_helper"):
		main.refresh_mobile_scroll_helper()
	main._refresh_bottom_nav_styles()

func close() -> void:
	if main == null or main.shop_panel == null:
		return

	main.shop_panel.visible = false
	main.shop_backdrop.visible = false
	_hide_shop_details()
	main.close_modal("shop")
	if main.has_method("_restore_map_after_screen_close") and main._restore_map_after_screen_close("shop"):
		return
	main._active_nav_tab = "fish"
	main._refresh_bottom_nav_styles()

func refresh() -> void:
	_update_shop_ui()

func is_open() -> bool:
	return main != null and main.shop_panel != null and main.shop_panel.visible

func _on_shop_buy_pressed(item_id: String) -> void:
	buy_requested.emit(item_id)

func _get_shop_items_for_category(category: String) -> Array:
	if category == SHOP_CATEGORY_TACKLE:
		return _get_tackle_shop_items_for_type(SHOP_CATEGORY_ROD)
	if [SHOP_CATEGORY_ROD, SHOP_CATEGORY_LINE, SHOP_CATEGORY_LEADER, SHOP_CATEGORY_HOOK, SHOP_CATEGORY_FLOAT].has(category):
		return _get_tackle_shop_items_for_type(category)
	if category == SHOP_CATEGORY_BAIT:
		return _get_bait_shop_items()
	if category == SHOP_CATEGORY_FOOD or category == SHOP_CATEGORY_CLOTHING:
		return PlayerData.get_survival_shop_items(category)
	if category == SHOP_CATEGORY_CONSUMABLE and _is_beta_consumable_shop_hidden():
		return []

	var items: Array = []
	for item in CONSUMABLE_ITEMS:
		if str(item.get("shop_category", "")) == category:
			items.append(item.duplicate(true))
	return items

func _get_tackle_shop_items_for_type(category: String) -> Array:
	var items: Array = []
	for item in PlayerData.get_tackle_shop_items():
		var item_category := str(item.get("type", item.get("category", "")))
		if item_category == category:
			items.append(item.duplicate(true))
	if category == SHOP_CATEGORY_ROD:
		items.sort_custom(_sort_rod_shop_items)
	return items

func _sort_rod_shop_items(a: Dictionary, b: Dictionary) -> bool:
	var series_a := _get_rod_series_order(str(a.get("id", "")))
	var series_b := _get_rod_series_order(str(b.get("id", "")))
	if series_a != series_b:
		return series_a < series_b

	var number_a := _get_rod_display_number(str(a.get("id", "")))
	var number_b := _get_rod_display_number(str(b.get("id", "")))
	if number_a != number_b:
		return number_a < number_b

	return float(a.get("price", 0.0)) < float(b.get("price", 0.0))

func _get_rod_series_order(item_id: String) -> int:
	if item_id.begins_with("green_line_"):
		return 0
	if item_id.begins_with("nordriver_"):
		return 1
	if item_id.begins_with("sakura_fish_"):
		return 2
	if item_id.begins_with("titan_hook_"):
		return 3
	return 9

func _get_rod_display_number(item_id: String) -> int:
	if ROD_CARD_BADGE_NUMBERS.has(item_id):
		return int(ROD_CARD_BADGE_NUMBERS[item_id])
	return 999

func _get_bait_shop_items() -> Array:
	var items: Array = []
	for catalog_item in PlayerData.get_tackle_catalog_items("bait"):
		var item: Dictionary = catalog_item.duplicate(true)
		var item_id = str(item.get("id", ""))
		if not BAIT_PACK_QUANTITIES.has(item_id):
			continue
		item["shop_category"] = SHOP_CATEGORY_BAIT
		item["quantity"] = int(BAIT_PACK_QUANTITIES[item_id])
		item["icon"] = str(item.get("name", "?")).substr(0, 1).to_upper()
		items.append(item)
	return items

func _get_shop_item(item_id: String) -> Dictionary:
	for category in SHOP_CATEGORIES:
		for item in _get_shop_items_for_category(category):
			if str(item.get("id", "")) == item_id:
				return item
	return {}

func _get_shop_inventory_item(shop_item: Dictionary) -> Dictionary:
	var stats: Dictionary = shop_item.get("stats", {}).duplicate(true)
	return {
		"id": str(shop_item.get("id", "")),
		"name": str(shop_item.get("name", "-")),
		"type": str(shop_item.get("type", shop_item.get("category", "misc"))),
		"category": str(shop_item.get("category", "misc")),
		"rarity": str(shop_item.get("rarity", "common")),
		"price": float(shop_item.get("price", 0.0)),
		"quantity": int(shop_item.get("quantity", 1)),
		"image_path": str(shop_item.get("image_path", "")),
		"description": str(shop_item.get("description", "")),
		"display_name_ru": str(shop_item.get("display_name_ru", shop_item.get("name", "-"))),
		"description_ru": str(shop_item.get("description_ru", shop_item.get("description", ""))),
		"stats": stats
	}

func _ensure_shop_ui_nodes() -> void:
	if main.shop_panel != null:
		return

	main.shop_backdrop = ColorRect.new()
	main.shop_backdrop.name = "ShopBackdrop"
	main.shop_backdrop.visible = false
	theme.apply_modal_backdrop_style(main.shop_backdrop)
	main.add_child(main.shop_backdrop)

	main.shop_panel = Panel.new()
	main.shop_panel.name = "ShopPanel"
	main.shop_panel.visible = false
	main.shop_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	main.add_child(main.shop_panel)

	main.shop_title_label = Label.new()
	main.shop_title_label.name = "ShopTitleLabel"
	main.shop_title_label.text = "Магазин"
	main.shop_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.shop_panel.add_child(main.shop_title_label)

	main.shop_money_label = Label.new()
	main.shop_money_label.name = "ShopMoneyLabel"
	main.shop_money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	main.shop_panel.add_child(main.shop_money_label)

	main.shop_bait_category_button = Button.new()
	main.shop_bait_category_button.name = "ShopBaitCategoryButton"
	main.shop_bait_category_button.text = "Наживки"
	main.shop_panel.add_child(main.shop_bait_category_button)

	main.shop_consumable_category_button = Button.new()
	main.shop_consumable_category_button.name = "ShopConsumableCategoryButton"
	main.shop_consumable_category_button.text = "Еда"
	main.shop_panel.add_child(main.shop_consumable_category_button)

	main.shop_clothing_category_button = Button.new()
	main.shop_clothing_category_button.name = "ShopClothingCategoryButton"
	main.shop_clothing_category_button.text = "Одежда"
	main.shop_panel.add_child(main.shop_clothing_category_button)

	main.shop_tackle_category_button = Button.new()
	main.shop_tackle_category_button.name = "ShopTackleCategoryButton"
	main.shop_tackle_category_button.text = "Снасти"
	main.shop_panel.add_child(main.shop_tackle_category_button)
	main.shop_tackle_category_button.text = "Удочки"

	main.shop_line_category_button = Button.new()
	main.shop_line_category_button.name = "ShopLineCategoryButton"
	main.shop_line_category_button.text = "Лески"
	main.shop_panel.add_child(main.shop_line_category_button)

	main.shop_leader_category_button = Button.new()
	main.shop_leader_category_button.name = "ShopLeaderCategoryButton"
	main.shop_leader_category_button.text = "Поводки"
	main.shop_panel.add_child(main.shop_leader_category_button)

	main.shop_hook_category_button = Button.new()
	main.shop_hook_category_button.name = "ShopHookCategoryButton"
	main.shop_hook_category_button.text = "Крючки"
	main.shop_panel.add_child(main.shop_hook_category_button)

	main.shop_float_category_button = Button.new()
	main.shop_float_category_button.name = "ShopFloatCategoryButton"
	main.shop_float_category_button.text = "Поплавки"
	main.shop_panel.add_child(main.shop_float_category_button)

	main.shop_items_scroll = ScrollContainer.new()
	main.shop_items_scroll.name = "ShopItemsScroll"
	main.shop_items_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	main.shop_items_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main.shop_panel.add_child(main.shop_items_scroll)

	main.shop_items_container = Control.new()
	main.shop_items_container.name = "ShopItemsContainer"
	main.shop_items_scroll.add_child(main.shop_items_container)

	main.shop_notice_label = Label.new()
	main.shop_notice_label.name = "ShopNoticeLabel"
	main.shop_notice_label.text = ""
	main.shop_notice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.shop_panel.add_child(main.shop_notice_label)

	main.shop_close_button = Button.new()
	main.shop_close_button.name = "ShopCloseButton"
	main.shop_close_button.text = "Закрыть"
	main.shop_panel.add_child(main.shop_close_button)

	main.shop_buy_audio = AudioStreamPlayer.new()
	main.shop_buy_audio.name = "ShopBuyAudio"
	main.add_child(main.shop_buy_audio)

	main.shop_error_audio = AudioStreamPlayer.new()
	main.shop_error_audio.name = "ShopErrorAudio"
	main.add_child(main.shop_error_audio)


func _ensure_shop_details_nodes() -> void:
	if main == null or main.shop_panel == null:
		return
	if _details_panel != null and is_instance_valid(_details_panel):
		return

	_details_backdrop = ColorRect.new()
	_details_backdrop.name = "ShopRodDetailsBackdrop"
	_details_backdrop.visible = false
	_details_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_details_backdrop.color = Color(0.0, 0.0, 0.0, 0.58)
	_details_backdrop.z_index = 40
	main.shop_panel.add_child(_details_backdrop)

	_details_panel = Panel.new()
	_details_panel.name = "ShopRodDetailsPanel"
	_details_panel.visible = false
	_details_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_details_panel.z_index = 41
	theme.apply_popup_window_style(_details_panel)
	main.shop_panel.add_child(_details_panel)

	_details_title_label = Label.new()
	_details_title_label.name = "ShopRodDetailsTitle"
	_details_title_label.clip_text = true
	_details_title_label.add_theme_font_size_override("font_size", 21)
	_details_title_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))
	_details_panel.add_child(_details_title_label)

	_details_image = TextureRect.new()
	_details_image.name = "ShopRodDetailsImage"
	_details_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_details_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_details_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_details_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_details_panel.add_child(_details_image)

	_details_description_label = Label.new()
	_details_description_label.name = "ShopRodDetailsDescription"
	_details_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_details_description_label.clip_text = true
	_details_description_label.add_theme_font_size_override("font_size", 12)
	_details_description_label.add_theme_color_override("font_color", Color(0.78, 0.89, 0.80, 0.90))
	_details_panel.add_child(_details_description_label)

	_details_stats_label = Label.new()
	_details_stats_label.name = "ShopRodDetailsStats"
	_details_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_details_stats_label.clip_text = true
	_details_stats_label.add_theme_font_size_override("font_size", 12)
	_details_stats_label.add_theme_color_override("font_color", Color(0.88, 0.98, 0.88, 0.95))
	_details_panel.add_child(_details_stats_label)

	_details_owned_label = Label.new()
	_details_owned_label.name = "ShopRodDetailsOwned"
	_details_owned_label.add_theme_font_size_override("font_size", 11)
	_details_owned_label.add_theme_color_override("font_color", Color(0.68, 0.84, 0.72, 0.86))
	_details_panel.add_child(_details_owned_label)

	_details_buy_button = Button.new()
	_details_buy_button.name = "ShopRodDetailsBuyButton"
	_details_buy_button.text = "Купить"
	_apply_shop_buy_button_style(_details_buy_button)
	_details_buy_button.pressed.connect(_on_shop_details_buy_pressed)
	_details_panel.add_child(_details_buy_button)

	_details_close_button = Button.new()
	_details_close_button.name = "ShopRodDetailsCloseButton"
	_details_close_button.text = "Закрыть"
	theme.apply_close_button_style(_details_close_button)
	_details_close_button.pressed.connect(_hide_shop_details)
	_details_panel.add_child(_details_close_button)

	_layout_shop_details_nodes()


func _layout_shop_details_nodes() -> void:
	if _details_panel == null or not is_instance_valid(_details_panel):
		return

	var root_size: Vector2 = main.shop_panel.size
	_details_backdrop.position = Vector2.ZERO
	_details_backdrop.size = root_size

	var item := _get_shop_item(_details_item_id)
	var category := str(item.get("category", item.get("type", "misc")))
	var is_bait := category == SHOP_CATEGORY_BAIT
	var panel_width := minf(maxf(root_size.x - 74.0, 460.0), 680.0)
	var panel_height := minf(maxf(root_size.y - 70.0, 340.0), 430.0)
	if is_bait:
		panel_width = minf(maxf(root_size.x - 150.0, 480.0), 560.0)
		panel_height = minf(maxf(root_size.y - 120.0, 352.0), 372.0)
	_details_panel.position = Vector2((root_size.x - panel_width) * 0.5, maxf((root_size.y - panel_height) * 0.5 - (10.0 if is_bait else 0.0), 16.0))
	_details_panel.size = Vector2(panel_width, panel_height)

	var padding := 22.0
	var inner_width := panel_width - padding * 2.0
	_details_title_label.position = Vector2(padding, 18.0)
	_details_title_label.size = Vector2(inner_width - 118.0, 30.0)

	_details_close_button.position = Vector2(panel_width - padding - 104.0, 16.0)
	_details_close_button.size = Vector2(104.0, 34.0)
	_details_close_button.add_theme_font_size_override("font_size", 12)

	var image_y := 62.0
	var image_height := minf(inner_width / 3.69, 148.0) if _details_image.visible else 0.0
	var image_width := inner_width
	if is_bait and _details_image.visible:
		image_width = minf(inner_width, 132.0)
		image_height = 78.0
	_details_image.position = Vector2(padding + (inner_width - image_width) * 0.5, image_y)
	_details_image.size = Vector2(image_width, image_height)

	var description_y := image_y + image_height + (10.0 if _details_image.visible else 4.0)
	var description_height := 38.0 if is_bait else 54.0
	_details_description_label.position = Vector2(padding, description_y)
	_details_description_label.size = Vector2(inner_width, description_height)
	_details_description_label.add_theme_font_size_override("font_size", 11 if is_bait else 12)

	var action_y := panel_height - 50.0
	var stats_y := description_y + description_height + 10.0
	_details_stats_label.position = Vector2(padding, stats_y)
	_details_stats_label.size = Vector2(inner_width, maxf(action_y - stats_y - 12.0, 46.0))
	_details_stats_label.add_theme_font_size_override("font_size", 11 if is_bait else 12)

	_details_owned_label.position = Vector2(padding, panel_height - 45.0)
	_details_owned_label.size = Vector2(180.0, 26.0)

	_details_buy_button.position = Vector2(panel_width - padding - 104.0, action_y)
	_details_buy_button.size = Vector2(104.0, 36.0)
	_details_buy_button.add_theme_font_size_override("font_size", 12)


func _show_shop_details(item_id: String) -> void:
	var item := _get_shop_item(item_id)
	if item.is_empty():
		return

	_ensure_shop_details_nodes()
	_details_item_id = item_id
	_details_title_label.text = _get_item_display_name(item)
	var details_texture := _get_shop_card_texture(item)
	_details_image.texture = details_texture
	_details_image.visible = details_texture != null
	_details_description_label.text = _get_item_description(item)
	_details_stats_label.text = _get_shop_details_stats_text(item)
	_details_owned_label.text = "Есть: %d" % _get_owned_shop_item_quantity(item_id)
	_layout_shop_details_nodes()
	_details_backdrop.visible = true
	_details_panel.visible = true
	main.shop_panel.move_child(_details_backdrop, main.shop_panel.get_child_count() - 1)
	main.shop_panel.move_child(_details_panel, main.shop_panel.get_child_count() - 1)


func _hide_shop_details() -> void:
	_details_item_id = ""
	if _details_backdrop != null and is_instance_valid(_details_backdrop):
		_details_backdrop.visible = false
	if _details_panel != null and is_instance_valid(_details_panel):
		_details_panel.visible = false


func _on_shop_details_buy_pressed() -> void:
	if _details_item_id == "":
		return

	var item_id := _details_item_id
	_hide_shop_details()
	_on_shop_buy_pressed(item_id)


func _hide_shop_pager() -> void:
	if main == null:
		return
	if main.shop_prev_page_button != null:
		main.shop_prev_page_button.visible = false
		main.shop_prev_page_button.disabled = true
	if main.shop_next_page_button != null:
		main.shop_next_page_button.visible = false
		main.shop_next_page_button.disabled = true
	if main.shop_page_label != null:
		main.shop_page_label.visible = false
		main.shop_page_label.text = ""


func _reset_shop_scroll_to_top() -> void:
	if main == null or main.shop_items_scroll == null:
		return
	main.shop_items_scroll.scroll_vertical = 0
	main.shop_items_scroll.set_deferred("scroll_vertical", 0)


func _clear_shop_item_cards(content_width: float) -> void:
	for child in main.shop_items_container.get_children():
		main.shop_items_container.remove_child(child)
		child.queue_free()

	main._shop_card_nodes.clear()
	main.shop_items_container.position = Vector2.ZERO
	main.shop_items_container.size = Vector2(content_width, 0.0)
	main.shop_items_container.custom_minimum_size = Vector2(content_width, 0.0)
	main.shop_items_container.update_minimum_size()
	if main.shop_items_scroll != null:
		main.shop_items_scroll.queue_sort()


func _apply_shop_items_content_height(content_width: float, content_height: float) -> void:
	var target_size := Vector2(content_width, maxf(content_height, 1.0))
	main.shop_items_container.size = target_size
	main.shop_items_container.custom_minimum_size = target_size
	main.shop_items_container.update_minimum_size()
	if main.shop_items_scroll != null:
		main.shop_items_scroll.queue_sort()


func _update_shop_ui() -> void:
	if main.shop_panel == null:
		return

	_update_shop_money_display()
	var hide_consumables := _is_beta_consumable_shop_hidden()
	if hide_consumables and main._shop_category == SHOP_CATEGORY_CONSUMABLE:
		main._shop_category = SHOP_CATEGORY_BAIT
	main.shop_consumable_category_button.visible = true
	main.shop_consumable_category_button.disabled = false
	if main.shop_clothing_category_button != null:
		main.shop_clothing_category_button.visible = true
		main.shop_clothing_category_button.disabled = false
	theme.apply_tab_button_style(main.shop_bait_category_button, main._shop_category == SHOP_CATEGORY_BAIT)
	theme.apply_tab_button_style(main.shop_consumable_category_button, main._shop_category == SHOP_CATEGORY_FOOD)
	if main.shop_clothing_category_button != null:
		theme.apply_tab_button_style(main.shop_clothing_category_button, main._shop_category == SHOP_CATEGORY_CLOTHING)
	theme.apply_tab_button_style(main.shop_tackle_category_button, main._shop_category == SHOP_CATEGORY_ROD)
	theme.apply_tab_button_style(main.shop_line_category_button, main._shop_category == SHOP_CATEGORY_LINE)
	theme.apply_tab_button_style(main.shop_leader_category_button, main._shop_category == SHOP_CATEGORY_LEADER)
	theme.apply_tab_button_style(main.shop_hook_category_button, main._shop_category == SHOP_CATEGORY_HOOK)
	theme.apply_tab_button_style(main.shop_float_category_button, main._shop_category == SHOP_CATEGORY_FLOAT)
	_apply_shop_category_tab_icon(main.shop_bait_category_button, SHOP_CATEGORY_BAIT)
	_apply_shop_category_tab_icon(main.shop_consumable_category_button, SHOP_CATEGORY_FOOD)
	if main.shop_clothing_category_button != null:
		_apply_shop_category_tab_icon(main.shop_clothing_category_button, SHOP_CATEGORY_CLOTHING)
	_apply_shop_category_tab_icon(main.shop_tackle_category_button, SHOP_CATEGORY_ROD)
	_apply_shop_category_tab_icon(main.shop_line_category_button, SHOP_CATEGORY_LINE)
	_apply_shop_category_tab_icon(main.shop_leader_category_button, SHOP_CATEGORY_LEADER)
	_apply_shop_category_tab_icon(main.shop_hook_category_button, SHOP_CATEGORY_HOOK)
	_apply_shop_category_tab_icon(main.shop_float_category_button, SHOP_CATEGORY_FLOAT, 10)
	_hide_shop_pager()
	_rebuild_shop_cards()
	_layout_shop_details_nodes()


func _apply_shop_category_tab_icon(button: Button, category: String, font_size: int = 11) -> void:
	if button == null:
		return
	button.icon = _get_shop_category_tab_icon(category)
	button.expand_icon = false
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.add_theme_constant_override("icon_max_width", 22)
	button.add_theme_constant_override("h_separation", 8)
	button.add_theme_font_size_override("font_size", font_size)


func _get_shop_category_tab_icon(category: String) -> Texture2D:
	match category:
		SHOP_CATEGORY_BAIT:
			return SHOP_TAB_ICON_BAIT
		SHOP_CATEGORY_FOOD:
			return SHOP_TAB_ICON_FOOD
		SHOP_CATEGORY_CLOTHING:
			return SHOP_TAB_ICON_CLOTHING
		SHOP_CATEGORY_ROD:
			return theme.get_icon("rod") if theme != null else null
		SHOP_CATEGORY_LINE:
			return SHOP_TAB_ICON_LINE
		SHOP_CATEGORY_LEADER:
			return SHOP_TAB_ICON_LEADER
		SHOP_CATEGORY_HOOK:
			return SHOP_TAB_ICON_HOOK
		SHOP_CATEGORY_FLOAT:
			return SHOP_TAB_ICON_FLOAT
		_:
			return null


func _update_shop_money_display() -> void:
	if main.shop_money_label == null:
		return

	main.shop_money_label.visible = false
	var row_rect := Rect2(
		Vector2(main.shop_panel.size.x - 32.0 - 156.0, main.shop_money_label.position.y),
		Vector2(156.0, main.shop_money_label.size.y)
	)
	if _shop_money_row == null or not is_instance_valid(_shop_money_row):
		_shop_money_row = _add_shop_price_row(
			main.shop_panel,
			PlayerData.money,
			row_rect,
			14,
			Vector2(18.0, 18.0),
			true,
			Color(0.82, 0.94, 0.84, 0.92),
			"ShopMoneyRow"
		)
		_shop_money_row.z_index = main.shop_money_label.z_index + 1
	else:
		_shop_money_row.position = row_rect.position
		_set_shop_price_row(
			_shop_money_row,
			PlayerData.money,
			row_rect.size,
			14,
			Vector2(18.0, 18.0),
			true,
			Color(0.82, 0.94, 0.84, 0.92)
		)
	_shop_money_row.visible = main.shop_panel.visible


func _rebuild_shop_cards() -> void:
	var all_items = _get_shop_items_for_category(main._shop_category)
	var is_bait_category: bool = str(main._shop_category) == SHOP_CATEGORY_BAIT
	var items: Array = all_items
	var viewport_size: Vector2 = main.shop_items_scroll.size if main.shop_items_scroll != null else main.shop_items_container.size
	var content_width: float = max(viewport_size.x - 12.0, 1.0)
	_clear_shop_item_cards(content_width)

	var columns := 5 if is_bait_category else 2
	var gap := 12.0
	var is_rod_category: bool = str(main._shop_category) == SHOP_CATEGORY_ROD
	var is_line_category: bool = str(main._shop_category) == SHOP_CATEGORY_LINE
	var is_leader_category: bool = str(main._shop_category) == SHOP_CATEGORY_LEADER
	var is_image_category: bool = is_rod_category or str(main._shop_category) == SHOP_CATEGORY_BAIT

	var card_width: float = (content_width - gap * float(columns - 1)) / float(columns)
	var rows: int = int(ceil(float(items.size()) / float(columns))) if not items.is_empty() else 0
	var card_min_height := 178.0 if is_bait_category else (148.0 if is_image_category else 60.0)
	var card_max_height := 178.0 if is_bait_category else (160.0 if is_image_category else 68.0)
	if is_rod_category:
		card_min_height = 294.0
		card_max_height = 326.0
	if is_line_category or is_leader_category:
		card_min_height = 100.0
		card_max_height = 104.0

	var card_height: float = card_min_height
	if rows > 0:
		card_height = min(max((viewport_size.y - gap * float(rows - 1)) / float(rows), card_min_height), card_max_height)
	var content_height: float = SHOP_SCROLL_BOTTOM_PADDING
	if rows > 0:
		content_height += float(rows) * card_height + gap * float(max(rows - 1, 0))
	_apply_shop_items_content_height(content_width, content_height)
	_hide_shop_pager()

	for i in items.size():
		var item: Dictionary = items[i]
		var column: int = i % columns
		var row: int = int(i / columns)
		var card = _create_shop_card(item, Vector2(card_width, card_height))
		card.position = Vector2(float(column) * (card_width + gap), float(row) * (card_height + gap))
		main.shop_items_container.add_child(card)
		main._shop_card_nodes[str(item.get("id", ""))] = card


func _create_shop_card(item: Dictionary, card_size: Vector2) -> Panel:
	var card = Panel.new()
	card.size = card_size
	card.clip_contents = true
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.mouse_entered.connect(_on_shop_card_hovered.bind(str(item.get("id", "")), true))
	card.mouse_exited.connect(_on_shop_card_hovered.bind(str(item.get("id", "")), false))
	theme.apply_card_style(card)

	var item_id = str(item.get("id", ""))
	var rarity = str(item.get("rarity", "common"))
	var rarity_color = main._get_rarity_color(rarity)
	theme.apply_shop_row_style(card, rarity)

	var card_texture := _get_shop_card_texture(item)
	var category := str(item.get("category", item.get("type", "misc")))
	if category == SHOP_CATEGORY_LINE:
		_populate_line_shop_card(card, item, card_size, card_texture, rarity_color)
		return card

	if category == SHOP_CATEGORY_LEADER:
		_populate_leader_shop_card(card, item, card_size, card_texture, rarity_color)
		return card

	if category == SHOP_CATEGORY_BAIT:
		_populate_bait_shop_card(card, item, card_size, card_texture, rarity_color)
		return card

	if card_texture != null and category == SHOP_CATEGORY_ROD:
		_populate_rod_image_card(card, item, card_size, card_texture, rarity_color)
		return card

	if true:
		var compact_has_texture := card_texture != null
		var is_line_item := category == SHOP_CATEGORY_LINE
		var is_survival_item := ["food", "drink", "clothing", "shelter"].has(category)
		var compact_icon_size := 64.0 if compact_has_texture and is_line_item else (56.0 if compact_has_texture and is_survival_item else (40.0 if compact_has_texture else 30.0))
		var compact_icon_y := (card_size.y - compact_icon_size) * 0.5
		var compact_content_x := 92.0 if compact_has_texture and is_line_item else (84.0 if compact_has_texture and is_survival_item else (68.0 if compact_has_texture else 50.0))
		var compact_buy_width := 58.0
		var compact_buy_height := 28.0
		var compact_details_width := 86.0
		var compact_details_gap := 10.0
		var compact_action_font_size := 10 if card_size.x < 440.0 else 11
		var is_rod_item := str(item.get("category", item.get("type", "misc"))) == SHOP_CATEGORY_ROD
		var is_details_item := is_rod_item or is_survival_item
		var compact_buy_x := card_size.x - compact_buy_width - 12.0
		var compact_action_x := compact_buy_x
		if is_details_item:
			compact_action_x = compact_buy_x - compact_details_gap - compact_details_width
		var compact_text_y := maxf(7.0, (card_size.y - 43.0) * 0.5)
		var compact_text_width: float = maxf(compact_action_x - compact_content_x - 18.0, 140.0)

		if compact_has_texture:
			_add_compact_shop_texture(
				card,
				card_texture,
				Rect2(Vector2(14.0, compact_icon_y), Vector2(compact_icon_size, compact_icon_size)),
				is_survival_item,
				0.92 if is_survival_item else 1.0
			)
		else:
			var compact_icon_label = Label.new()
			compact_icon_label.text = str(item.get("icon", "?"))
			compact_icon_label.position = Vector2(10.0, compact_icon_y)
			compact_icon_label.size = Vector2(compact_icon_size, compact_icon_size)
			compact_icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			compact_icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			compact_icon_label.add_theme_font_size_override("font_size", 15)
			compact_icon_label.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.98))
			compact_icon_label.add_theme_stylebox_override(
				"normal",
				main._make_panel_style(Color(0.10, 0.22, 0.17, 0.72), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.32), 10, 3, Color(0.0, 0.0, 0.0, 0.10))
			)
			card.add_child(compact_icon_label)

		var compact_name_label = Label.new()
		compact_name_label.text = _get_item_display_name(item)
		compact_name_label.position = Vector2(compact_content_x, compact_text_y)
		compact_name_label.size = Vector2(compact_text_width, 19.0)
		compact_name_label.clip_text = true
		compact_name_label.add_theme_font_size_override("font_size", 12)
		compact_name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.91, 1.0))
		card.add_child(compact_name_label)

		var compact_quantity = int(item.get("quantity", 1))
		var compact_owned = _get_owned_shop_item_quantity(item_id)
		var compact_price_width := 54.0
		var compact_price_x: float = compact_action_x - compact_price_width - 8.0
		var compact_meta_width: float = maxf(compact_price_x - compact_content_x - 6.0, 70.0)
		var compact_meta_label = Label.new()
		compact_meta_label.text = _get_shop_compact_stat_text(item)
		if compact_quantity > 1:
			compact_meta_label.text = "%s  |  x%d" % [
				_get_shop_compact_stat_text(item),
				compact_quantity
			]
		compact_meta_label.position = Vector2(compact_content_x, compact_text_y + 22.0)
		compact_meta_label.size = Vector2(compact_meta_width, 17.0)
		compact_meta_label.clip_text = true
		compact_meta_label.add_theme_font_size_override("font_size", 10)
		compact_meta_label.add_theme_color_override("font_color", Color(0.74, 0.88, 0.78, 0.92))
		card.add_child(compact_meta_label)

		_add_shop_price_row(
			card,
			float(item.get("price", 0.0)),
			Rect2(Vector2(compact_price_x, compact_text_y + 22.0), Vector2(compact_price_width, 17.0)),
			10,
			Vector2(13.0, 13.0),
			true,
			Color(0.94, 1.0, 0.91, 0.96)
		)

		var compact_owned_label = Label.new()
		compact_owned_label.text = "Есть %d" % compact_owned
		compact_owned_label.position = Vector2(compact_action_x - 58.0, compact_text_y + 1.0)
		compact_owned_label.size = Vector2(48.0, 16.0)
		compact_owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		compact_owned_label.clip_text = true
		compact_owned_label.add_theme_font_size_override("font_size", 9)
		compact_owned_label.add_theme_color_override("font_color", Color(0.62, 0.76, 0.68, 0.78))
		card.add_child(compact_owned_label)

		if is_details_item:
			var compact_details_button = Button.new()
			compact_details_button.text = "Подробнее"
			compact_details_button.position = Vector2(compact_action_x, (card_size.y - compact_buy_height) * 0.5)
			compact_details_button.size = Vector2(compact_details_width, compact_buy_height)
			_apply_shop_details_button_style(compact_details_button)
			compact_details_button.add_theme_font_size_override("font_size", compact_action_font_size)
			compact_details_button.pressed.connect(_show_shop_details.bind(item_id))
			card.add_child(compact_details_button)

		var compact_buy_button = Button.new()
		compact_buy_button.text = "Купить"
		compact_buy_button.position = Vector2(compact_buy_x, (card_size.y - compact_buy_height) * 0.5)
		compact_buy_button.size = Vector2(compact_buy_width, compact_buy_height)
		_apply_shop_buy_button_style(compact_buy_button)
		compact_buy_button.add_theme_font_size_override("font_size", compact_action_font_size)
		compact_buy_button.pressed.connect(_on_shop_buy_pressed.bind(item_id))
		card.add_child(compact_buy_button)
		return card

	return card

func _populate_line_shop_card(card: Panel, item: Dictionary, card_size: Vector2, texture: Texture2D, rarity_color: Color) -> void:
	var item_id := str(item.get("id", ""))
	var image_pos := Vector2(14.0, (card_size.y - SHOP_LINE_IMAGE_SIZE.y) * 0.5)
	var content_x := image_pos.x + SHOP_LINE_IMAGE_SIZE.x + 14.0
	var buy_width := 66.0
	var buy_height := 32.0
	var right_padding := 12.0
	var buy_x := card_size.x - right_padding - buy_width
	var text_right := buy_x - 76.0
	var text_width: float = maxf(text_right - content_x, 150.0)
	var title_y := 10.0

	if texture != null:
		_add_compact_shop_texture(card, texture, Rect2(image_pos, SHOP_LINE_IMAGE_SIZE))
	else:
		var fallback_icon_label := Label.new()
		fallback_icon_label.text = str(item.get("icon", "L"))
		fallback_icon_label.position = image_pos + Vector2(11.0, 11.0)
		fallback_icon_label.size = Vector2(53.0, 53.0)
		fallback_icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback_icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		fallback_icon_label.add_theme_font_size_override("font_size", 20)
		fallback_icon_label.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.98))
		fallback_icon_label.add_theme_stylebox_override(
			"normal",
			main._make_panel_style(Color(0.10, 0.22, 0.17, 0.72), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.32), 11, 3, Color(0.0, 0.0, 0.0, 0.10))
		)
		card.add_child(fallback_icon_label)

	var name_label := Label.new()
	name_label.text = _get_item_display_name(item)
	name_label.position = Vector2(content_x, title_y)
	name_label.size = Vector2(text_width, 20.0)
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.91, 1.0))
	card.add_child(name_label)

	var line_values := _get_line_display_values(item)
	var stat_line_a := Label.new()
	stat_line_a.text = "Длина: %s   Диаметр: %s" % [
		str(line_values.get("length", "100 м")),
		str(line_values.get("diameter", "-"))
	]
	stat_line_a.position = Vector2(content_x, title_y + 24.0)
	stat_line_a.size = Vector2(text_width, 18.0)
	stat_line_a.clip_text = true
	stat_line_a.add_theme_font_size_override("font_size", 10)
	stat_line_a.add_theme_color_override("font_color", Color(0.76, 0.90, 0.80, 0.92))
	card.add_child(stat_line_a)

	var stat_line_b := Label.new()
	stat_line_b.text = "Прочность: %s   Материал: %s" % [
		str(line_values.get("strength", "-")),
		str(line_values.get("material", "нейлон"))
	]
	stat_line_b.position = Vector2(content_x, title_y + 43.0)
	stat_line_b.size = Vector2(text_width, 18.0)
	stat_line_b.clip_text = true
	stat_line_b.add_theme_font_size_override("font_size", 10)
	stat_line_b.add_theme_color_override("font_color", Color(0.70, 0.84, 0.76, 0.86))
	card.add_child(stat_line_b)

	_add_shop_price_row(
		card,
		float(item.get("price", 0.0)),
		Rect2(Vector2(content_x, title_y + 63.0), Vector2(78.0, 17.0)),
		10,
		Vector2(14.0, 14.0),
		false,
		Color(0.88, 0.96, 0.80, 0.90)
	)

	var owned_label := Label.new()
	owned_label.text = "Есть: %d" % _get_owned_shop_item_quantity(item_id)
	owned_label.position = Vector2(buy_x - 68.0, title_y + 4.0)
	owned_label.size = Vector2(58.0, 18.0)
	owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	owned_label.clip_text = true
	owned_label.add_theme_font_size_override("font_size", 9)
	owned_label.add_theme_color_override("font_color", Color(0.62, 0.76, 0.68, 0.78))
	card.add_child(owned_label)

	var buy_button := Button.new()
	buy_button.text = "Купить"
	buy_button.position = Vector2(buy_x, (card_size.y - buy_height) * 0.5)
	buy_button.size = Vector2(buy_width, buy_height)
	_apply_shop_buy_button_style(buy_button)
	buy_button.pressed.connect(_on_shop_buy_pressed.bind(item_id))
	card.add_child(buy_button)

func _populate_leader_shop_card(card: Panel, item: Dictionary, card_size: Vector2, texture: Texture2D, rarity_color: Color) -> void:
	var item_id := str(item.get("id", ""))
	var has_texture := texture != null
	var icon_size := 72.0 if has_texture else 42.0
	var icon_pos := Vector2(12.0, (card_size.y - icon_size) * 0.5)
	var content_x := icon_pos.x + icon_size + 12.0
	var buy_width := 66.0
	var buy_height := 32.0
	var right_padding := 12.0
	var buy_x := card_size.x - right_padding - buy_width
	var text_width: float = maxf(buy_x - content_x - 16.0, 118.0)
	var title_y := 9.0

	if has_texture:
		_add_compact_shop_texture(card, texture, Rect2(icon_pos, Vector2(icon_size, icon_size)))
	else:
		var icon_label := Label.new()
		icon_label.text = str(item.get("icon", "L"))
		icon_label.position = icon_pos
		icon_label.size = Vector2(icon_size, icon_size)
		icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon_label.add_theme_font_size_override("font_size", 17)
		icon_label.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.98))
		icon_label.add_theme_stylebox_override(
			"normal",
			main._make_panel_style(Color(0.10, 0.22, 0.17, 0.72), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.32), 10, 3, Color(0.0, 0.0, 0.0, 0.10))
		)
		card.add_child(icon_label)

	var name_label := Label.new()
	name_label.text = _get_item_display_name(item)
	name_label.position = Vector2(content_x, title_y)
	name_label.size = Vector2(text_width, 19.0)
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.91, 1.0))
	card.add_child(name_label)

	var leader_values := _get_leader_display_values(item)
	var stat_line_a := Label.new()
	stat_line_a.text = "Материал: %s   Длина: %s" % [
		str(leader_values.get("material", "нейлон")),
		str(leader_values.get("length", "20 см"))
	]
	stat_line_a.position = Vector2(content_x, title_y + 22.0)
	stat_line_a.size = Vector2(text_width, 18.0)
	stat_line_a.clip_text = true
	stat_line_a.add_theme_font_size_override("font_size", 10)
	stat_line_a.add_theme_color_override("font_color", Color(0.76, 0.90, 0.80, 0.92))
	card.add_child(stat_line_a)

	var stat_line_b := Label.new()
	stat_line_b.text = "Тест: %s   %s" % [
		str(leader_values.get("test", "-")),
		_get_leader_bonus_summary(item)
	]
	stat_line_b.position = Vector2(content_x, title_y + 41.0)
	stat_line_b.size = Vector2(text_width, 18.0)
	stat_line_b.clip_text = true
	stat_line_b.add_theme_font_size_override("font_size", 10)
	stat_line_b.add_theme_color_override("font_color", Color(0.70, 0.84, 0.76, 0.86))
	card.add_child(stat_line_b)

	_add_shop_price_row(
		card,
		float(item.get("price", 0.0)),
		Rect2(Vector2(content_x, title_y + 61.0), Vector2(78.0, 17.0)),
		10,
		Vector2(14.0, 14.0),
		false,
		Color(0.88, 0.96, 0.80, 0.90)
	)

	var owned_label := Label.new()
	owned_label.text = "Есть: %d" % _get_owned_shop_item_quantity(item_id)
	owned_label.position = Vector2(buy_x - 68.0, title_y + 4.0)
	owned_label.size = Vector2(58.0, 18.0)
	owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	owned_label.clip_text = true
	owned_label.add_theme_font_size_override("font_size", 9)
	owned_label.add_theme_color_override("font_color", Color(0.62, 0.76, 0.68, 0.78))
	card.add_child(owned_label)

	var buy_button := Button.new()
	buy_button.text = "Купить"
	buy_button.position = Vector2(buy_x, (card_size.y - buy_height) * 0.5)
	buy_button.size = Vector2(buy_width, buy_height)
	_apply_shop_buy_button_style(buy_button)
	buy_button.pressed.connect(_on_shop_buy_pressed.bind(item_id))
	card.add_child(buy_button)

func _add_compact_shop_texture(parent: Control, texture: Texture2D, slot_rect: Rect2, trim_transparent_margins := false, fill_scale := 1.0) -> void:
	var slot := Control.new()
	slot.name = "ShopCompactImageSlot"
	slot.position = slot_rect.position
	slot.size = slot_rect.size
	slot.clip_contents = true
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(slot)

	var display_texture := _get_trimmed_shop_card_texture(texture) if trim_transparent_margins else texture
	var texture_size := display_texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	var sprite := Sprite2D.new()
	sprite.name = "ShopCompactImage"
	sprite.texture = display_texture
	sprite.centered = true
	sprite.position = slot_rect.size * 0.5
	sprite.scale = Vector2.ONE * minf(slot_rect.size.x / texture_size.x, slot_rect.size.y / texture_size.y) * clampf(fill_scale, 0.1, 1.5)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	slot.add_child(sprite)

func _get_trimmed_shop_card_texture(texture: Texture2D) -> Texture2D:
	if texture == null:
		return texture

	var cache_key := str(texture.get_instance_id())
	if _shop_card_trimmed_texture_cache.has(cache_key):
		return _shop_card_trimmed_texture_cache[cache_key]

	var image := texture.get_image()
	if image == null or image.is_empty():
		_shop_card_trimmed_texture_cache[cache_key] = texture
		return texture

	var width := image.get_width()
	var height := image.get_height()
	if width <= 0 or height <= 0:
		_shop_card_trimmed_texture_cache[cache_key] = texture
		return texture

	var sample_step: int = maxi(1, int(float(maxi(width, height)) / 256.0))
	var min_x := width
	var min_y := height
	var max_x := -1
	var max_y := -1

	for y in range(0, height, sample_step):
		for x in range(0, width, sample_step):
			if image.get_pixel(x, y).a <= 0.04:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)

	if max_x < min_x or max_y < min_y:
		_shop_card_trimmed_texture_cache[cache_key] = texture
		return texture

	var visible_width := max_x - min_x + 1
	var visible_height := max_y - min_y + 1
	if visible_width >= int(float(width) * 0.92) and visible_height >= int(float(height) * 0.92):
		_shop_card_trimmed_texture_cache[cache_key] = texture
		return texture

	var padding := maxi(4, int(float(maxi(visible_width, visible_height)) * 0.045))
	var region_x := maxi(min_x - padding, 0)
	var region_y := maxi(min_y - padding, 0)
	var region_right := mini(max_x + padding, width - 1)
	var region_bottom := mini(max_y + padding, height - 1)
	var region := Rect2(
		float(region_x),
		float(region_y),
		float(region_right - region_x + 1),
		float(region_bottom - region_y + 1)
	)

	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = texture
	atlas_texture.region = region
	_shop_card_trimmed_texture_cache[cache_key] = atlas_texture
	return atlas_texture


func _populate_bait_shop_card(card: Panel, item: Dictionary, card_size: Vector2, texture: Texture2D, rarity_color: Color) -> void:
	var item_id := str(item.get("id", ""))
	var padding := 8.0
	var image_area_height := 76.0
	var info_y := padding + image_area_height + 6.0
	var info_height: float = maxf(card_size.y - info_y - padding, 74.0)
	var inner_width: float = maxf(card_size.x - padding * 2.0, 1.0)

	var image_area := Panel.new()
	image_area.name = "BaitCardImageArea"
	image_area.position = Vector2(padding, padding)
	image_area.size = Vector2(inner_width, image_area_height)
	image_area.clip_contents = true
	image_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image_area.add_theme_stylebox_override(
		"panel",
		main._make_panel_style(Color(0.012, 0.032, 0.035, 0.72), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.18), 7, 2, Color(0.0, 0.0, 0.0, 0.10))
	)
	card.add_child(image_area)

	if texture != null:
		_add_compact_shop_texture(
			image_area,
			texture,
			Rect2(Vector2.ZERO, image_area.size),
			true,
			0.88
		)
	else:
		var icon_label := Label.new()
		icon_label.text = str(item.get("icon", "?"))
		icon_label.position = Vector2((image_area.size.x - 42.0) * 0.5, 17.0)
		icon_label.size = Vector2(42.0, 42.0)
		icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon_label.add_theme_font_size_override("font_size", 18)
		icon_label.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.98))
		image_area.add_child(icon_label)

	var info_area := Panel.new()
	info_area.name = "BaitCardInfoArea"
	info_area.position = Vector2(padding, info_y)
	info_area.size = Vector2(inner_width, info_height)
	info_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_area.add_theme_stylebox_override(
		"panel",
		main._make_panel_style(Color(0.012, 0.040, 0.034, 0.78), Color(0.58, 0.76, 0.66, 0.16), 7, 1, Color(0.0, 0.0, 0.0, 0.08))
	)
	card.add_child(info_area)

	var info_padding := 8.0
	var price_width := 70.0
	var name_width: float = maxf(info_area.size.x - info_padding * 2.0 - price_width - 8.0, 70.0)
	var name_label := Label.new()
	name_label.name = "BaitCardNameLabel"
	name_label.text = _get_item_display_name(item)
	name_label.position = Vector2(info_padding, 6.0)
	name_label.size = Vector2(name_width, 20.0)
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.91, 1.0))
	info_area.add_child(name_label)

	_add_shop_price_row(
		info_area,
		float(item.get("price", 0.0)),
		Rect2(Vector2(info_area.size.x - info_padding - price_width, 6.0), Vector2(price_width, 20.0)),
		11,
		Vector2(15.0, 15.0),
		true,
		Color(0.92, 1.0, 0.90, 0.96),
		"BaitCardPriceRow"
	)

	var owned_label := Label.new()
	owned_label.name = "BaitCardOwnedLabel"
	owned_label.text = "Есть: %d" % _get_owned_shop_item_quantity(item_id)
	owned_label.position = Vector2(info_padding, 28.0)
	owned_label.size = Vector2(info_area.size.x - info_padding * 2.0, 18.0)
	owned_label.clip_text = true
	owned_label.add_theme_font_size_override("font_size", 10)
	owned_label.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.92))
	info_area.add_child(owned_label)

	var action_gap := 10.0
	var action_height := 28.0
	var action_y: float = info_area.size.y - action_height - 6.0
	var action_width: float = maxf((info_area.size.x - info_padding * 2.0 - action_gap) * 0.5, 54.0)
	var action_font_size := 9 if action_width < 72.0 else 10
	var details_button := Button.new()
	details_button.name = "BaitCardDetailsButton"
	details_button.text = "Подробнее"
	details_button.position = Vector2(info_padding, action_y)
	details_button.size = Vector2(action_width, action_height)
	_apply_shop_details_button_style(details_button)
	details_button.add_theme_font_size_override("font_size", action_font_size)
	details_button.pressed.connect(_show_shop_details.bind(item_id))
	info_area.add_child(details_button)

	var buy_button := Button.new()
	buy_button.name = "BaitCardBuyButton"
	buy_button.text = "Купить"
	buy_button.position = Vector2(info_area.size.x - info_padding - action_width, action_y)
	buy_button.size = Vector2(action_width, action_height)
	_apply_shop_buy_button_style(buy_button)
	buy_button.add_theme_font_size_override("font_size", action_font_size)
	buy_button.pressed.connect(_on_shop_buy_pressed.bind(item_id))
	info_area.add_child(buy_button)


func _populate_rod_image_card(card: Panel, item: Dictionary, card_size: Vector2, texture: Texture2D, rarity_color: Color) -> void:
	var item_id := str(item.get("id", ""))
	var category := str(item.get("category", item.get("type", "misc")))
	var stats: Dictionary = item.get("stats", {}) if item.get("stats", {}) is Dictionary else {}
	var padding := 12.0
	var image_area_height: float = clampf(card_size.y * 0.38, 82.0, 98.0)
	var content_y: float = padding + image_area_height + 8.0
	var image_area_size := Vector2(maxf(card_size.x - padding * 2.0, 1.0), image_area_height)
	_apply_rod_shop_card_style(card, rarity_color)

	var image_area := Panel.new()
	image_area.name = "RodCardImageArea"
	image_area.position = Vector2(padding, padding)
	image_area.size = image_area_size
	image_area.clip_contents = true
	image_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image_area.add_theme_stylebox_override(
		"panel",
		main._make_panel_style(Color(0.010, 0.027, 0.030, 0.30), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.16), 8, 0, Color.TRANSPARENT)
	)
	card.add_child(image_area)

	var image := TextureRect.new()
	image.name = "RodCardImage"
	image.texture = _get_rod_display_texture(texture) if category == SHOP_CATEGORY_ROD else texture
	image.position = Vector2(-image_area_size.x * 0.035, -8.0)
	image.size = image_area_size + Vector2(image_area_size.x * 0.07, 16.0)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	image_area.add_child(image)

	var badge := Label.new()
	badge.name = "ShopCardBadge"
	badge.text = "Lv.%d" % int(ROD_CARD_BADGE_NUMBERS.get(item_id, 1))
	badge.position = Vector2(8.0, 8.0)
	badge.size = Vector2(58.0, 28.0)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 14)
	badge.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 1.0))
	badge.add_theme_stylebox_override(
		"normal",
		main._make_panel_style(Color(0.020, 0.050, 0.044, 0.88), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.70), 7, 2, Color(0.0, 0.0, 0.0, 0.16))
	)
	image_area.add_child(badge)

	var class_chip := Label.new()
	class_chip.name = "RodCardClassChip"
	class_chip.text = _get_rod_class_chip_text(stats)
	class_chip.position = Vector2(card_size.x - padding - 118.0, image_area.position.y + 8.0)
	class_chip.size = Vector2(110.0, 24.0)
	class_chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	class_chip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	class_chip.clip_text = true
	class_chip.add_theme_font_size_override("font_size", 12)
	class_chip.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 1.0))
	card.add_child(class_chip)

	var name_label := Label.new()
	name_label.name = "RodCardNameLabel"
	name_label.text = _get_item_display_name(item)
	name_label.position = Vector2(padding + 4.0, content_y)
	name_label.size = Vector2(card_size.x - padding * 2.0 - 124.0, 26.0)
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.add_theme_font_size_override("font_size", 17)
	name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.91, 1.0))
	card.add_child(name_label)

	var type_label := Label.new()
	type_label.name = "RodCardTypeLabel"
	type_label.text = _get_rod_type_display_text(item)
	type_label.position = Vector2(padding + 4.0, content_y + 25.0)
	type_label.size = Vector2(card_size.x - padding * 2.0 - 152.0, 20.0)
	type_label.clip_text = true
	type_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	type_label.add_theme_font_size_override("font_size", 12)
	type_label.add_theme_color_override("font_color", Color(0.74, 0.84, 0.76, 0.92))
	card.add_child(type_label)

	_add_shop_price_row(
		card,
		float(item.get("price", 0.0)),
		Rect2(Vector2(card_size.x - padding - 116.0, content_y + 27.0), Vector2(112.0, 19.0)),
		13,
		Vector2(16.0, 16.0),
		true,
		Color(0.93, 1.0, 0.82, 0.98),
		"RodCardPriceRow"
	)

	var separator := ColorRect.new()
	separator.name = "RodCardSeparator"
	separator.color = Color(0.70, 0.90, 0.78, 0.16)
	separator.position = Vector2(padding + 4.0, content_y + 51.0)
	separator.size = Vector2(card_size.x - padding * 2.0 - 8.0, 1.0)
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(separator)

	var stats_y: float = content_y + 61.0
	var left_x: float = padding + 4.0
	var right_x: float = card_size.x * 0.52
	var left_width: float = maxf(right_x - left_x - 10.0, 86.0)
	var right_width: float = maxf(card_size.x - right_x - padding, 96.0)
	_add_rod_stat_label(card, Vector2(left_x, stats_y), Vector2(left_width, 18.0), "Длина:", "%.1f м" % float(stats.get("length_m", 0.0)))
	_add_rod_stat_label(card, Vector2(left_x, stats_y + 22.0), Vector2(left_width, 18.0), "Тест:", _get_rod_test_text(stats))
	_add_rod_stat_label(card, Vector2(left_x, stats_y + 44.0), Vector2(left_width, 18.0), "Рыба:", _get_rod_fish_capacity_text(stats))
	_add_rod_star_row(card, Vector2(right_x, stats_y), Vector2(right_width, 18.0), "Контроль:", _get_rod_control_rating(stats))
	_add_rod_star_row(card, Vector2(right_x, stats_y + 22.0), Vector2(right_width, 18.0), "Чувств.:", _get_rod_sensitivity_rating(stats))

	var owned_count: int = _get_owned_shop_item_quantity(item_id)
	if owned_count > 0:
		var owned_label := Label.new()
		owned_label.name = "RodCardOwnedLabel"
		owned_label.text = "Есть: %d" % owned_count
		owned_label.position = Vector2(right_x, stats_y + 44.0)
		owned_label.size = Vector2(right_width, 18.0)
		owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		owned_label.clip_text = true
		owned_label.add_theme_font_size_override("font_size", 10)
		owned_label.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.82))
		card.add_child(owned_label)

	var actions_height := 34.0
	var action_gap := 10.0
	var button_width: float = clampf((card_size.x - padding * 2.0 - action_gap) * 0.5, 112.0, 150.0)
	var actions_y: float = card_size.y - padding - actions_height
	var buy_x: float = card_size.x - padding - button_width
	var details_x: float = buy_x - action_gap - button_width

	var details_button := Button.new()
	details_button.name = "RodCardDetailsButton"
	details_button.text = "Подробнее"
	details_button.position = Vector2(details_x, actions_y)
	details_button.size = Vector2(button_width, actions_height)
	_apply_shop_details_button_style(details_button)
	details_button.add_theme_font_size_override("font_size", 12)
	details_button.pressed.connect(_show_shop_details.bind(item_id))
	card.add_child(details_button)

	var buy_button := Button.new()
	buy_button.name = "RodCardBuyButton"
	buy_button.text = "Купить"
	buy_button.position = Vector2(buy_x, actions_y)
	buy_button.size = Vector2(button_width, actions_height)
	_apply_shop_buy_button_style(buy_button)
	buy_button.add_theme_font_size_override("font_size", 12)
	buy_button.pressed.connect(_on_shop_buy_pressed.bind(item_id))
	card.add_child(buy_button)


func _apply_rod_shop_card_style(card: Panel, rarity_color: Color) -> void:
	card.add_theme_stylebox_override(
		"panel",
		main._make_panel_style(
			Color(0.013, 0.034, 0.036, 0.91),
			Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.48),
			10,
			5,
			Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.10)
		)
	)


func _add_rod_stat_label(parent: Control, position: Vector2, size: Vector2, title: String, value: String) -> void:
	var label := Label.new()
	label.position = position
	label.size = size
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.text = "%s %s" % [title, value]
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(0.76, 0.86, 0.78, 0.94))
	parent.add_child(label)


func _add_rod_star_row(parent: Control, position: Vector2, size: Vector2, title: String, rating: int) -> void:
	var title_label := Label.new()
	title_label.position = position
	title_label.size = Vector2(minf(76.0, size.x * 0.48), size.y)
	title_label.clip_text = true
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 11)
	title_label.add_theme_color_override("font_color", Color(0.76, 0.86, 0.78, 0.94))
	parent.add_child(title_label)

	var stars_label := Label.new()
	stars_label.position = Vector2(position.x + title_label.size.x, position.y - 1.0)
	stars_label.size = Vector2(maxf(size.x - title_label.size.x, 1.0), size.y + 2.0)
	stars_label.clip_text = true
	stars_label.text = _format_star_rating(rating)
	stars_label.add_theme_font_size_override("font_size", 13)
	stars_label.add_theme_color_override("font_color", Color(1.0, 0.74, 0.25, 0.98))
	parent.add_child(stars_label)


func _format_star_rating(rating: int) -> String:
	var clamped_rating: int = clampi(rating, 1, 5)
	var result := ""
	for index in range(5):
		result += "★" if index < clamped_rating else "☆"
	return result


func _get_rod_class_chip_text(stats: Dictionary) -> String:
	var rod_class := str(stats.get("rod_class", "medium"))
	match rod_class:
		"ultra_light":
			return "УЛЬТРАЛАЙТ"
		"light":
			return "ЛАЙТ"
		"medium":
			return "СРЕДНИЙ"
		"universal":
			return "УНИВЕРСАЛ"
		"heavy":
			return "ТЯЖЁЛЫЙ"
		"extra_heavy":
			return "ЭКСТРА"
		_:
			return rod_class.to_upper()


func _get_rod_type_display_text(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {}) if item.get("stats", {}) is Dictionary else {}
	var rod_class := _get_rod_class_title(str(stats.get("rod_class", "medium")))
	var rod_type := str(stats.get("rod_type", item.get("rod_type", item.get("tackle_type", "")))).to_lower()
	var requires_reel := bool(stats.get("requires_reel", item.get("requires_reel", false)))
	if requires_reel or rod_type == "spinning":
		return "%s спиннинг" % rod_class
	return "%s удочка" % rod_class


func _get_rod_class_title(rod_class: String) -> String:
	match rod_class:
		"ultra_light":
			return "Ультралайт"
		"light":
			return "Лайт"
		"medium":
			return "Средняя"
		"universal":
			return "Универсальная"
		"heavy":
			return "Тяжёлая"
		"extra_heavy":
			return "Экстра-хэви"
		_:
			return rod_class.capitalize()


func _get_rod_test_text(stats: Dictionary) -> String:
	if stats.has("test_min") or stats.has("test_max"):
		return "%.0f-%.0f г" % [
			float(stats.get("test_min", 0.0)),
			float(stats.get("test_max", stats.get("max_fish_weight", 1.0)))
		]
	var rod_class := str(stats.get("rod_class", "medium"))
	match rod_class:
		"ultra_light":
			return "0.5-7 г"
		"light":
			return "1-10 г"
		"medium":
			return "3-18 г"
		"universal":
			return "5-24 г"
		"heavy":
			return "12-40 г"
		"extra_heavy":
			return "25-80 г"
		_:
			return "3-18 г"


func _get_rod_fish_capacity_text(stats: Dictionary) -> String:
	var max_weight: float = float(stats.get("max_fish_weight", 0.0))
	return "до %.1f кг, %s" % [max_weight, _get_rod_fish_size_label(max_weight)]


func _get_rod_fish_size_label(max_weight: float) -> String:
	if max_weight <= 1.2:
		return "мелкая"
	if max_weight <= 3.0:
		return "средняя"
	if max_weight <= 6.0:
		return "крупная"
	return "трофейная"


func _get_rod_control_rating(stats: Dictionary) -> int:
	var control: float = float(stats.get("control_bonus", stats.get("tension_bonus", 0.0)))
	var handling: float = float(stats.get("handling_bonus", 0.0))
	return clampi(roundi(1.6 + control * 13.0 + maxf(handling, 0.0) * 7.0), 1, 5)


func _get_rod_sensitivity_rating(stats: Dictionary) -> int:
	var control: float = float(stats.get("control_bonus", stats.get("tension_bonus", 0.0)))
	var handling: float = float(stats.get("handling_bonus", 0.0))
	var stiffness: float = float(stats.get("stiffness", stats.get("strength", 1.0)))
	var class_bonus: float = 0.0
	match str(stats.get("rod_class", "medium")):
		"ultra_light":
			class_bonus = 0.8
		"light":
			class_bonus = 0.45
		"universal":
			class_bonus = 0.15
		"heavy", "extra_heavy":
			class_bonus = -0.25
	var rating_value: float = 1.8 + control * 10.0 + handling * 9.0 + class_bonus - maxf(stiffness - 1.35, 0.0) * 0.7
	return clampi(roundi(rating_value), 1, 5)


func _populate_rod_image_card_legacy(card: Panel, item: Dictionary, card_size: Vector2, texture: Texture2D, rarity_color: Color) -> void:
	var item_id := str(item.get("id", ""))
	var category := str(item.get("category", item.get("type", "misc")))
	var padding := 8.0
	var info_gap := 6.0
	var info_area_height := clampf(card_size.y * 0.36, 54.0, 56.0)
	var image_area_height := maxf(card_size.y - padding * 2.0 - info_gap - info_area_height, 74.0)
	var info_area_y := padding + image_area_height + info_gap
	var image_area_size := Vector2(maxf(card_size.x - padding * 2.0, 1.0), image_area_height)

	var image_area := Panel.new()
	image_area.name = "RodCardImageArea"
	image_area.position = Vector2(padding, padding)
	image_area.size = image_area_size
	image_area.clip_contents = true
	image_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image_area.add_theme_stylebox_override(
		"panel",
		main._make_panel_style(Color(0.012, 0.032, 0.035, 0.72), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.18), 7, 2, Color(0.0, 0.0, 0.0, 0.10))
	)
	card.add_child(image_area)

	var image := TextureRect.new()
	image.name = "RodCardImage"
	image.texture = _get_rod_display_texture(texture) if category == SHOP_CATEGORY_ROD else texture
	image.position = Vector2.ZERO
	image.size = image_area_size
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	image_area.add_child(image)

	if category == SHOP_CATEGORY_ROD:
		var badge := Label.new()
		badge.name = "ShopCardBadge"
		badge.text = str(ROD_CARD_BADGE_NUMBERS.get(item_id, 1))
		badge.position = Vector2(8.0, image_area_size.y - 39.0)
		badge.size = Vector2(34.0, 34.0)
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.add_theme_font_size_override("font_size", 16)
		badge.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 1.0))
		badge.add_theme_stylebox_override(
			"normal",
			main._make_panel_style(Color(0.025, 0.052, 0.047, 0.86), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.64), 7, 3, Color(0.0, 0.0, 0.0, 0.18))
		)
		image_area.add_child(badge)

	var info_area := Panel.new()
	info_area.name = "RodCardInfoArea"
	info_area.position = Vector2(padding, info_area_y)
	info_area.size = Vector2(maxf(card_size.x - padding * 2.0, 1.0), info_area_height)
	info_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_area.add_theme_stylebox_override(
		"panel",
		main._make_panel_style(Color(0.012, 0.040, 0.034, 0.78), Color(0.58, 0.76, 0.66, 0.16), 7, 1, Color(0.0, 0.0, 0.0, 0.08))
	)
	card.add_child(info_area)

	var info_padding := 8.0
	var actions_height := 28.0
	var action_gap := 10.0
	var buy_width := 68.0
	var details_width := 94.0
	var action_font_size := 10 if info_area.size.x < 330.0 else 11
	var actions_y := maxf(21.0, info_area_height - 6.0 - actions_height)
	var buy_x := info_area.size.x - info_padding - buy_width
	var details_x := buy_x - action_gap - details_width
	var actions_width := details_width + action_gap + buy_width
	var left_width := maxf(details_x - info_padding - 14.0, 120.0)

	_add_shop_price_row(
		info_area,
		float(item.get("price", 0.0)),
		Rect2(Vector2(details_x, 3.0), Vector2(actions_width, 16.0)),
		12,
		Vector2(15.0, 15.0),
		true,
		Color(0.92, 1.0, 0.90, 0.96),
		"RodCardPriceRow"
	)

	var name_label := Label.new()
	name_label.name = "RodCardNameLabel"
	name_label.text = _get_item_display_name(item)
	name_label.position = Vector2(info_padding, 6.0)
	name_label.size = Vector2(left_width, 19.0)
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.91, 1.0))
	info_area.add_child(name_label)

	var owned_label := Label.new()
	owned_label.name = "RodCardOwnedLabel"
	owned_label.text = "Есть: %d" % _get_owned_shop_item_quantity(item_id)
	owned_label.position = Vector2(info_padding, 28.0)
	owned_label.size = Vector2(left_width, 18.0)
	owned_label.clip_text = true
	owned_label.add_theme_font_size_override("font_size", 10)
	owned_label.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.92))
	info_area.add_child(owned_label)

	var details_button := Button.new()
	details_button.name = "RodCardDetailsButton"
	details_button.text = "Подробнее"
	details_button.position = Vector2(details_x, actions_y)
	details_button.size = Vector2(details_width, actions_height)
	_apply_shop_details_button_style(details_button)
	details_button.add_theme_font_size_override("font_size", action_font_size)
	details_button.pressed.connect(_show_shop_details.bind(item_id))
	info_area.add_child(details_button)

	var buy_button := Button.new()
	buy_button.name = "RodCardBuyButton"
	buy_button.text = "Купить"
	buy_button.position = Vector2(buy_x, actions_y)
	buy_button.size = Vector2(buy_width, actions_height)
	_apply_shop_buy_button_style(buy_button)
	buy_button.add_theme_font_size_override("font_size", action_font_size)
	buy_button.pressed.connect(_on_shop_buy_pressed.bind(item_id))
	info_area.add_child(buy_button)

func _apply_shop_buy_button_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", main._make_panel_style(Color(0.24, 0.52, 0.16, 0.96), Color(0.68, 1.0, 0.58, 0.44), 8, 3, Color(0.0, 0.0, 0.0, 0.16)))
	button.add_theme_stylebox_override("hover", main._make_panel_style(Color(0.30, 0.64, 0.20, 1.0), Color(0.78, 1.0, 0.66, 0.62), 8, 4, Color(0.18, 0.68, 0.22, 0.18)))
	button.add_theme_stylebox_override("pressed", main._make_panel_style(Color(0.18, 0.40, 0.12, 1.0), Color(0.58, 0.88, 0.48, 0.52), 8, 1, Color(0.0, 0.0, 0.0, 0.12)))
	button.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.86, 1.0, 0.82, 1.0))
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_constant_override("h_separation", 0)

func _apply_shop_details_button_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", main._make_panel_style(Color(0.05, 0.13, 0.12, 0.92), Color(0.58, 0.78, 0.68, 0.34), 8, 3, Color(0.0, 0.0, 0.0, 0.12)))
	button.add_theme_stylebox_override("hover", main._make_panel_style(Color(0.08, 0.19, 0.16, 0.98), Color(0.72, 0.98, 0.76, 0.48), 8, 4, Color(0.18, 0.68, 0.22, 0.10)))
	button.add_theme_stylebox_override("pressed", main._make_panel_style(Color(0.03, 0.10, 0.08, 1.0), Color(0.48, 0.74, 0.58, 0.42), 8, 1, Color(0.0, 0.0, 0.0, 0.12)))
	button.add_theme_color_override("font_color", Color(0.86, 0.96, 0.88, 0.95))
	button.add_theme_color_override("font_hover_color", Color(0.96, 1.0, 0.92, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.78, 0.94, 0.80, 1.0))
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_constant_override("h_separation", 0)

func _get_line_display_values(item: Dictionary) -> Dictionary:
	var stats: Dictionary = item.get("stats", {})
	var length_m := float(stats.get("length_m", 100.0))
	var strength_kg := float(stats.get("max_load_kg", stats.get("strength", stats.get("max_load", 0.0))))
	return {
		"length": "%d м" % roundi(length_m),
		"diameter": "%.2f мм" % _get_line_diameter_mm(item),
		"strength": "%.1f кг" % strength_kg,
		"material": _get_line_material_name(item)
	}

func _get_line_diameter_mm(item: Dictionary) -> float:
	var stats: Dictionary = item.get("stats", {})
	if stats.has("diameter_mm"):
		return float(stats.get("diameter_mm", 0.0))
	if stats.has("diameter"):
		return float(stats.get("diameter", 0.0))

	match str(item.get("id", "")):
		"lakeline_nylon_basic_1_5kg":
			return 0.15
		"lakeline_nylon_basic_2kg":
			return 0.17
		"lakeline_nylon_basic_2_5kg":
			return 0.19
		"lakeline_nylon_basic_3kg":
			return 0.20
		"lakeline_nylon_basic_4kg":
			return 0.22
		"lakeline_nylon_basic_5kg":
			return 0.25
		"lakeline_nylon_basic_6kg":
			return 0.28
		"lakeline_nylon_basic_8kg":
			return 0.30
		"lakeline_nylon_basic_10kg":
			return 0.35
		"lakeline_nylon_basic_12kg":
			return 0.37
		"lakeline_nylon_basic_15kg":
			return 0.40
		"lakeline_nylon_basic_18kg":
			return 0.45
		"lakeline_nylon_basic_20kg":
			return 0.50
		"mono_2_5kg", "mono_5kg":
			return 0.20

	var strength_kg := float(stats.get("max_load_kg", stats.get("strength", stats.get("max_load", 0.0))))
	if strength_kg <= 1.5:
		return 0.15
	if strength_kg <= 2.0:
		return 0.17
	if strength_kg <= 3.0:
		return 0.20
	if strength_kg <= 5.0:
		return 0.25
	if strength_kg <= 8.0:
		return 0.30
	if strength_kg <= 12.0:
		return 0.37
	if strength_kg <= 18.0:
		return 0.45
	return 0.50

func _get_line_material_name(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {})
	var line_type := str(stats.get("line_type", "nylon")).to_lower()
	match line_type:
		"nylon", "mono", "monofilament":
			return "нейлон"
		"fluoro", "fluorocarbon":
			return "флюорокарбон"
		"braid", "braided":
			return "плетёнка"
		_:
			return line_type if line_type != "" else "нейлон"

func _get_line_details_stats_text(item: Dictionary) -> String:
	var line_values := _get_line_display_values(item)
	return "Длина: %s\nДиаметр: %s\nПрочность: %s\nМатериал: %s\nЦена: %s" % [
		str(line_values.get("length", "100 м")),
		str(line_values.get("diameter", "-")),
		str(line_values.get("strength", "-")),
		str(line_values.get("material", "нейлон")),
		_format_shop_money_amount(float(item.get("price", 0.0)))
	]

func _get_leader_display_values(item: Dictionary) -> Dictionary:
	var stats: Dictionary = item.get("stats", {})
	var length_cm := int(stats.get("length_cm", 20))
	var test_kg := float(stats.get("max_load_kg", stats.get("max_load", stats.get("strength", 1.0))))
	return {
		"material": _get_leader_material_name(item),
		"length": "%d см" % length_cm,
		"test": "%.1f кг" % test_kg
	}

func _get_leader_material_name(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {})
	var leader_type := str(stats.get("material", stats.get("leader_type", "nylon"))).to_lower()
	match leader_type:
		"nylon", "mono", "monofilament":
			return "нейлон"
		"fluoro", "fluorocarbon":
			return "флюорокарбон"
		"braid", "braided":
			return "плетёный"
		"reinforced":
			return "усиленный"
		"steel":
			return "стальной"
		_:
			return leader_type if leader_type != "" else "нейлон"

func _get_leader_bonus_summary(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {})
	var parts := PackedStringArray()
	var control_bonus := float(stats.get("control_bonus", 0.0))
	var cautious_bonus := float(stats.get("cautious_bite_bonus", 0.0))
	var small_penalty := float(stats.get("small_fish_penalty", 0.0))
	var bite_protection := float(stats.get("bite_protection", 0.0))
	if abs(control_bonus) >= 0.005:
		parts.append("контр. %s" % _format_signed_percent(control_bonus))
	if abs(cautious_bonus) >= 0.005:
		parts.append("остор. %s" % _format_signed_percent(cautious_bonus))
	if small_penalty >= 0.005:
		parts.append("мелочь -%d%%" % roundi(small_penalty * 100.0))
	if bite_protection >= 0.005:
		parts.append("срез +%d%%" % roundi(bite_protection * 100.0))
	if parts.is_empty():
		return "универсальный"
	return " / ".join(parts)

func _get_leader_details_stats_text(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {})
	var leader_values := _get_leader_display_values(item)
	var lines: Array = [
		"Материал: %s" % str(leader_values.get("material", "нейлон")),
		"Длина: %s" % str(leader_values.get("length", "20 см")),
		"Тест: %s" % str(leader_values.get("test", "-")),
		"Цена: %s" % _format_shop_money_amount(float(item.get("price", 0.0))),
		"Контроль: %s" % _format_signed_percent(float(stats.get("control_bonus", 0.0))),
		"Осторожная рыба: %s" % _format_signed_percent(float(stats.get("cautious_bite_bonus", 0.0))),
		"Штраф мелкой рыбе: %s" % _format_signed_percent(-float(stats.get("small_fish_penalty", 0.0))),
		"Защита от обрыва: %d%%" % roundi(float(stats.get("break_resistance", 1.0)) * 100.0),
		"Риск обрыва: %d%%" % roundi(float(stats.get("break_chance", 0.0)) * 100.0)
	]
	if float(stats.get("bite_protection", 0.0)) > 0.0:
		lines.append("Защита от среза: +%d%%" % roundi(float(stats.get("bite_protection", 0.0)) * 100.0))
	return "\n".join(lines)

func _get_shop_compact_stat_text(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {})
	var category = str(item.get("category", item.get("type", "misc")))

	match category:
		"rod":
			return "%.1f м / %.1f кг / контр. +%d%%" % [
				float(stats.get("length_m", 4.0)),
				float(stats.get("max_fish_weight", 0.0)),
				roundi((float(stats.get("tension_bonus", stats.get("control_bonus", 0.0))) + float(stats.get("handling_bonus", 0.0))) * 100.0)
			]
		"line":
			var line_values := _get_line_display_values(item)
			return "%s / %s / %s" % [
				str(line_values.get("length", "100 м")),
				str(line_values.get("diameter", "-")),
				str(line_values.get("strength", "-"))
			]
		"leader":
			var leader_values := _get_leader_display_values(item)
			return "%s / %s / %s" % [
				str(leader_values.get("material", "нейлон")),
				str(leader_values.get("length", "20 см")),
				str(leader_values.get("test", "-"))
			]
		"float":
			return "Чувств. %d%% / ветер %d%% / %.1f-%.1f м" % [
				roundi(float(stats.get("sensitivity", 0.0)) * 100.0),
				roundi(float(stats.get("wind_resistance", 0.0)) * 100.0),
				float(stats.get("depth_min", 0.2)),
				float(stats.get("depth_max", 2.5))
			]
		"hook":
			return "№%s / %s / +%d%%" % [
				PlayerData.format_hook_size(int(stats.get("hook_size", 0))),
				main._format_tackle_stat_value("target_fish_size", stats.get("target_fish_size", "small")),
				roundi(float(stats.get("hook_chance", stats.get("hook_success_bonus", 0.0))) * 100.0)
			]
		"bait":
			var target_text := PlayerData.get_bait_target_fish_names(str(item.get("id", "")), 3)
			return target_text if target_text != "" else "Общий клёв +%d%%" % roundi(float(stats.get("fish_attraction", 0.0)) * 100.0)
		_:
			if stats.has("bite_bonus"):
				return "Бонус клёва +%d%%" % roundi(float(stats.get("bite_bonus", 0.0)) * 100.0)
			return "Расходник"


func _get_rod_details_stats_text(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {})
	return "Длина: %s   |   Класс: %s\nРыба до: %s   |   Цена: %s\nКонтроль: %s   |   Обращение: %s\nДальность: %s   |   Жёсткость: %s\nПрочность: %s" % [
		main._format_tackle_stat_value("length_m", stats.get("length_m", 0.0)),
		main._format_tackle_stat_value("rod_class", stats.get("rod_class", "medium")),
		main._format_tackle_stat_value("max_fish_weight", stats.get("max_fish_weight", 0.0)),
		_format_shop_money_amount(float(item.get("price", 0.0))),
		_format_signed_percent(float(stats.get("control_bonus", stats.get("tension_bonus", 0.0)))),
		_format_signed_percent(float(stats.get("handling_bonus", 0.0))),
		_format_signed_percent(float(stats.get("reach_bonus", 0.0))),
		main._format_tackle_stat_value("stiffness", stats.get("stiffness", 0.0)),
		main._format_tackle_stat_value("strength", stats.get("strength", 0.0))
	]


func _get_shop_details_stats_text(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {})
	var category := str(item.get("category", item.get("type", "misc")))

	match category:
		"rod":
			return _get_rod_details_stats_text(item)
		"bait":
			var target_text := PlayerData.get_bait_target_fish_names(str(item.get("id", "")), 4).replace("Лучше для:", "Лучше:")
			var secondary_text := PlayerData.get_bait_secondary_fish_names(str(item.get("id", "")), 3).replace("Также берёт:", "Также:")
			var lines: Array = [
				"Тип: %s   Бонус: +%d%%   Пачка: x%d" % [
					_format_bait_type_name(str(stats.get("bait_type", "worm"))),
					roundi(float(stats.get("fish_attraction", 0.0)) * 100.0),
					int(item.get("quantity", 1))
				],
				"Цена: %s" % _format_shop_money_amount(float(item.get("price", 0.0)))
			]
			if target_text != "":
				lines.append(target_text)
			if secondary_text != "":
				lines.append(secondary_text)
			return "\n".join(lines)
		"line":
			return _get_line_details_stats_text(item)
		"leader":
			return _get_leader_details_stats_text(item)
		"float":
			return _get_float_details_stats_text(item)
		"food", "drink", "clothing", "shelter":
			var lines: Array = []
			if PlayerData.has_method("get_survival_item_effect_lines"):
				lines = PlayerData.get_survival_item_effect_lines(item)
			lines.append("Цена: %s" % _format_shop_money_amount(float(item.get("price", 0.0))))
			return "\n".join(lines)
		_:
			return "%s\nЦена: %s" % [
				_get_shop_key_stat_text(item),
				_format_shop_money_amount(float(item.get("price", 0.0)))
			]

func _format_bait_type_name(bait_type: String) -> String:
	match bait_type:
		"bread":
			return "хлебная"
		"dough":
			return "тесто/каша"
		"maggot":
			return "личинки и насекомые"
		_:
			return "червь/животная"

func _format_signed_percent(value: float) -> String:
	var percent := roundi(value * 100.0)
	if percent > 0:
		return "+%d%%" % percent
	return "%d%%" % percent

func _get_item_display_name(item: Dictionary) -> String:
	return str(item.get("display_name_ru", item.get("name", "-")))

func _get_item_description(item: Dictionary) -> String:
	return str(item.get("description_ru", item.get("description", "")))


func _get_float_details_stats_text(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {})
	var lines: Array = [
		"Чувствительность: %d%%" % roundi(float(stats.get("sensitivity", 0.0)) * 100.0),
		"Устойчивость: %d%%" % roundi(float(stats.get("stability", 0.0)) * 100.0),
		"Ветер: %d%%" % roundi(float(stats.get("wind_resistance", 0.0)) * 100.0),
		"Дальность: %s" % _format_signed_percent(float(stats.get("cast_distance_bonus", 0.0))),
		"Камыши/трава: %d%%" % roundi(float(stats.get("vegetation_control", 0.0)) * 100.0),
		"Тяжёлая наживка: %d%%" % roundi(float(stats.get("heavy_bait_support", 0.0)) * 100.0),
		"Рабочая глубина: %.1f-%.1f м" % [float(stats.get("depth_min", 0.2)), float(stats.get("depth_max", 2.5))],
		"Цена: %s" % _format_shop_money_amount(float(item.get("price", 0.0)))
	]
	if float(stats.get("night_bonus", 0.0)) > 0.0:
		lines.append("Ночной бонус: +%d%% к видимости поклёвки" % roundi(float(stats.get("night_bonus", 0.0)) * 100.0))
	if float(stats.get("hook_timing_bonus", 0.0)) > 0.0:
		lines.append("Окно подсечки: +%d%%" % roundi(float(stats.get("hook_timing_bonus", 0.0)) * 100.0))
	if float(stats.get("long_range_accuracy_bonus", 0.0)) > 0.0:
		lines.append("Дальняя точность: +%d%%" % roundi(float(stats.get("long_range_accuracy_bonus", 0.0)) * 100.0))
	if float(stats.get("setup_comfort", 0.0)) > 0.0:
		lines.append("Удобство настройки: +%d%%" % roundi(float(stats.get("setup_comfort", 0.0)) * 100.0))
	var tags: Array = stats.get("bonus_tags", item.get("bonus_tags", []))
	if not tags.is_empty():
		var tag_strings := PackedStringArray()
		for tag in tags:
			tag_strings.append(str(tag))
		lines.append("Лучше всего: %s" % ", ".join(tag_strings))
	return "\n".join(lines)


func _get_owned_shop_item_quantity(item_id: String) -> int:
	var owned_item = PlayerData.get_owned_item(item_id)

	if owned_item.is_empty():
		return 0

	return int(owned_item.get("quantity", 0))

func _get_rod_display_texture(source_texture: Texture2D) -> Texture2D:
	if source_texture == null:
		return null

	var source_size := source_texture.get_size()
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		return source_texture

	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = source_texture
	atlas_texture.region = Rect2(0.0, 0.0, source_size.x, maxf(source_size.y * 0.56, 1.0))
	return atlas_texture

func _get_shop_card_texture(item: Dictionary) -> Texture2D:
	var item_id := str(item.get("id", ""))
	var path := str(item.get("image_path", ""))
	if path == "" and ROD_CARD_TEXTURE_PATHS.has(item_id):
		path = str(ROD_CARD_TEXTURE_PATHS[item_id])
	if path == "":
		return null

	if _texture_cache.has(path):
		return _texture_cache[path]

	var texture := _load_texture_resource(path)
	_texture_cache[path] = texture
	return texture

func _load_texture_resource(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var resource: Resource = load(path)
		if resource is Texture2D:
			return resource

	if FileAccess.file_exists(path):
		var image: Image = Image.load_from_file(path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)

	return null


func _get_shop_key_stat_text(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {})
	var category = str(item.get("category", item.get("type", "misc")))

	match category:
		"rod":
			return "%.1f м  |  рыба %.1f кг  |  контроль +%d%%" % [
				float(stats.get("length_m", 4.0)),
				float(stats.get("max_fish_weight", 0.0)),
				roundi((float(stats.get("tension_bonus", stats.get("control_bonus", 0.0))) + float(stats.get("handling_bonus", 0.0))) * 100.0)
			]
		"line":
			var line_values := _get_line_display_values(item)
			return "Длина: %s  |  Диаметр: %s  |  Прочность: %s  |  Материал: %s" % [
				str(line_values.get("length", "100 м")),
				str(line_values.get("diameter", "-")),
				str(line_values.get("strength", "-")),
				str(line_values.get("material", "нейлон"))
			]
		"leader":
			var leader_values := _get_leader_display_values(item)
			return "Материал: %s  |  Длина: %s  |  Тест: %s  |  %s" % [
				str(leader_values.get("material", "нейлон")),
				str(leader_values.get("length", "20 см")),
				str(leader_values.get("test", "-")),
				_get_leader_bonus_summary(item)
			]
		"float":
			return "Чувств. %d%%  |  Устойчивость %d%%  |  Ветер %d%%  |  %.1f-%.1f м" % [
				roundi(float(stats.get("sensitivity", 0.0)) * 100.0),
				roundi(float(stats.get("stability", 0.0)) * 100.0),
				roundi(float(stats.get("wind_resistance", 0.0)) * 100.0),
				float(stats.get("depth_min", 0.2)),
				float(stats.get("depth_max", 2.5))
			]
		"hook":
			return "№%s  |  %s  |  подсечка +%d%%" % [
				PlayerData.format_hook_size(int(stats.get("hook_size", 0))),
				main._format_tackle_stat_value("target_fish_size", stats.get("target_fish_size", "small")),
				roundi(float(stats.get("hook_chance", stats.get("hook_success_bonus", 0.0))) * 100.0)
			]
		"bait":
			var target_text := PlayerData.get_bait_target_fish_names(str(item.get("id", "")), 4)
			if target_text != "":
				return "%s  |  пачка x%d" % [target_text, int(item.get("quantity", 1))]
			return "Общий клёв +%d%%  |  пачка x%d" % [
				roundi(float(stats.get("fish_attraction", 0.0)) * 100.0),
				int(item.get("quantity", 1))
			]
		"food", "drink", "clothing", "shelter":
			if PlayerData.has_method("get_survival_item_effect_lines"):
				var lines: Array = PlayerData.get_survival_item_effect_lines(item)
				if not lines.is_empty():
					return str(lines[0])
			return _get_item_display_name(item)
		_:
			if stats.has("bite_bonus"):
				return "Бонус клёва +%d%%" % roundi(float(stats.get("bite_bonus", 0.0)) * 100.0)
			return "Расходник"


func _set_shop_category(category: String) -> void:
	if category == SHOP_CATEGORY_CONSUMABLE and _is_beta_consumable_shop_hidden():
		category = SHOP_CATEGORY_BAIT
	main._shop_category = category
	main._shop_page = 0
	_reset_shop_scroll_to_top()
	_show_shop_notice("", true)
	_update_shop_ui()
	_reset_shop_scroll_to_top()


func _show_shop_notice(message: String, success: bool) -> void:
	if main.shop_notice_label == null:
		return

	main.shop_notice_label.text = message
	main.shop_notice_label.modulate = Color(0.78, 1.0, 0.78, 1.0) if success else Color(1.0, 0.64, 0.54, 1.0)

	if message == "":
		return

	if is_instance_valid(main._shop_feedback_tween):
		main._shop_feedback_tween.kill()

	main._shop_feedback_tween = main.create_tween()
	main._shop_feedback_tween.tween_property(main.shop_notice_label, "modulate:a", 1.0, 0.05)
	main._shop_feedback_tween.tween_property(main.shop_notice_label, "modulate:a", 0.82, 1.25)


func _play_shop_card_feedback(item_id: String, success: bool) -> void:
	if not main._shop_card_nodes.has(item_id):
		return

	var card = main._shop_card_nodes[item_id] as Control
	if card == null:
		return

	var flash = Color(1.0, 1.0, 1.0, 1.0)

	if success:
		flash = Color(1.18, 1.35, 1.18, 1.0)
	else:
		flash = Color(1.35, 0.82, 0.72, 1.0)

	var tween = main.create_tween()
	tween.tween_property(card, "modulate", flash, 0.08)
	tween.tween_property(card, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.18)


func _on_shop_card_hovered(item_id: String, hovered: bool) -> void:
	if not main._shop_card_nodes.has(item_id):
		return

	var card = main._shop_card_nodes[item_id] as Control
	if card == null:
		return

	var target = Color(1.08, 1.12, 1.06, 1.0) if hovered else Color(1.0, 1.0, 1.0, 1.0)
	var tween = main.create_tween()
	tween.tween_property(card, "modulate", target, 0.10)
