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
var _details_item_id := ""
signal buy_requested(item_id: String)

const SHOP_ITEMS_PER_PAGE := 8
const SHOP_ROD_ITEMS_PER_PAGE := 4
const SHOP_BAIT_ITEMS_PER_PAGE := 4
const SHOP_CATEGORY_BAIT := "bait"
const SHOP_CATEGORY_CONSUMABLE := "consumable"
const SHOP_CATEGORY_TACKLE := "tackle"
const SHOP_CATEGORY_ROD := "rod"
const SHOP_CATEGORY_LINE := "line"
const SHOP_CATEGORY_HOOK := "hook"
const SHOP_CATEGORY_FLOAT := "float"
const SHOP_CATEGORIES := [
	SHOP_CATEGORY_BAIT,
	SHOP_CATEGORY_CONSUMABLE,
	SHOP_CATEGORY_ROD,
	SHOP_CATEGORY_LINE,
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
	"vipolzok": 6
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

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	_ensure_shop_ui_nodes()
	_ensure_shop_pager_nodes()
	_ensure_shop_details_nodes()

func open() -> void:
	if main._is_catch_reward_open() or main.shop_button.disabled:
		return
	if main._shop_category == SHOP_CATEGORY_TACKLE:
		main._shop_category = SHOP_CATEGORY_ROD

	main.open_modal("shop")
	main._active_nav_tab = "shop"
	main.shop_backdrop.visible = true
	main.shop_panel.visible = true
	refresh()
	main._refresh_bottom_nav_styles()

func close() -> void:
	if main == null or main.shop_panel == null:
		return

	main.shop_panel.visible = false
	main.shop_backdrop.visible = false
	_hide_shop_details()
	main.close_modal("shop")
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
	if [SHOP_CATEGORY_ROD, SHOP_CATEGORY_LINE, SHOP_CATEGORY_HOOK, SHOP_CATEGORY_FLOAT].has(category):
		return _get_tackle_shop_items_for_type(category)
	if category == SHOP_CATEGORY_BAIT:
		return _get_bait_shop_items()

	var items: Array = []
	for item in CONSUMABLE_ITEMS:
		if str(item.get("shop_category", "")) == category:
			items.append(item.duplicate(true))
	return items

func _get_shop_items_per_page(category: String) -> int:
	if category == SHOP_CATEGORY_ROD or category == SHOP_CATEGORY_TACKLE:
		return SHOP_ROD_ITEMS_PER_PAGE
	if category == SHOP_CATEGORY_BAIT:
		return SHOP_BAIT_ITEMS_PER_PAGE

	return SHOP_ITEMS_PER_PAGE

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
	main.shop_consumable_category_button.text = "Расходники"
	main.shop_panel.add_child(main.shop_consumable_category_button)

	main.shop_tackle_category_button = Button.new()
	main.shop_tackle_category_button.name = "ShopTackleCategoryButton"
	main.shop_tackle_category_button.text = "Снасти"
	main.shop_panel.add_child(main.shop_tackle_category_button)
	main.shop_tackle_category_button.text = "Удочки"

	main.shop_line_category_button = Button.new()
	main.shop_line_category_button.name = "ShopLineCategoryButton"
	main.shop_line_category_button.text = "Лески"
	main.shop_panel.add_child(main.shop_line_category_button)

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


func _ensure_shop_pager_nodes() -> void:
	if main == null or main.shop_panel == null:
		return

	if main.shop_prev_page_button == null:
		main.shop_prev_page_button = Button.new()
		main.shop_prev_page_button.name = "ShopPrevPageButton"
		main.shop_prev_page_button.text = "<"
		main.shop_prev_page_button.focus_mode = Control.FOCUS_NONE
		main.shop_prev_page_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.shop_prev_page_button.z_index = 2
		main.shop_prev_page_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.shop_panel.add_child(main.shop_prev_page_button)
		main.shop_prev_page_button.pressed.connect(_on_shop_prev_page_pressed)

	if main.shop_next_page_button == null:
		main.shop_next_page_button = Button.new()
		main.shop_next_page_button.name = "ShopNextPageButton"
		main.shop_next_page_button.text = ">"
		main.shop_next_page_button.focus_mode = Control.FOCUS_NONE
		main.shop_next_page_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.shop_next_page_button.z_index = 2
		main.shop_next_page_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.shop_panel.add_child(main.shop_next_page_button)
		main.shop_next_page_button.pressed.connect(_on_shop_next_page_pressed)

	if main.shop_page_label == null:
		main.shop_page_label = Label.new()
		main.shop_page_label.name = "ShopPageLabel"
		main.shop_page_label.text = ""
		main.shop_page_label.z_index = 2
		main.shop_page_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main.shop_page_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.shop_panel.add_child(main.shop_page_label)


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
	_details_description_label.add_theme_font_size_override("font_size", 12)
	_details_description_label.add_theme_color_override("font_color", Color(0.78, 0.89, 0.80, 0.90))
	_details_panel.add_child(_details_description_label)

	_details_stats_label = Label.new()
	_details_stats_label.name = "ShopRodDetailsStats"
	_details_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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

	var panel_width := minf(maxf(root_size.x - 74.0, 460.0), 680.0)
	var panel_height := minf(maxf(root_size.y - 70.0, 340.0), 430.0)
	_details_panel.position = Vector2((root_size.x - panel_width) * 0.5, (root_size.y - panel_height) * 0.5)
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
	_details_image.position = Vector2(padding, image_y)
	_details_image.size = Vector2(inner_width, image_height)

	var description_y := image_y + image_height + (14.0 if _details_image.visible else 4.0)
	_details_description_label.position = Vector2(padding, description_y)
	_details_description_label.size = Vector2(inner_width, 54.0)

	var stats_y := description_y + 64.0
	_details_stats_label.position = Vector2(padding, stats_y)
	_details_stats_label.size = Vector2(inner_width, maxf(panel_height - stats_y - 70.0, 50.0))

	_details_owned_label.position = Vector2(padding, panel_height - 45.0)
	_details_owned_label.size = Vector2(180.0, 26.0)

	_details_buy_button.position = Vector2(panel_width - padding - 104.0, panel_height - 50.0)
	_details_buy_button.size = Vector2(104.0, 36.0)
	_details_buy_button.add_theme_font_size_override("font_size", 12)


func _show_shop_details(item_id: String) -> void:
	var item := _get_shop_item(item_id)
	if item.is_empty():
		return

	_ensure_shop_details_nodes()
	_details_item_id = item_id
	_details_title_label.text = str(item.get("name", "-"))
	var details_texture := _get_shop_card_texture(item)
	_details_image.texture = details_texture
	_details_image.visible = details_texture != null
	_details_description_label.text = str(item.get("description", ""))
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


func _update_shop_pager(page_count: int, total_count: int, page_size: int) -> void:
	_ensure_shop_pager_nodes()
	if main.shop_prev_page_button == null or main.shop_next_page_button == null or main.shop_page_label == null:
		return

	var has_pages := total_count > page_size
	main.shop_prev_page_button.visible = has_pages
	main.shop_next_page_button.visible = has_pages
	main.shop_page_label.visible = has_pages
	main.shop_prev_page_button.disabled = main._shop_page <= 0
	main.shop_next_page_button.disabled = main._shop_page >= page_count - 1
	main.shop_page_label.text = "%d / %d" % [main._shop_page + 1, page_count]


func _update_shop_ui() -> void:
	if main.shop_panel == null:
		return

	main.shop_money_label.text = PlayerData.format_money(PlayerData.money)
	theme.apply_tab_button_style(main.shop_bait_category_button, main._shop_category == SHOP_CATEGORY_BAIT)
	theme.apply_tab_button_style(main.shop_consumable_category_button, main._shop_category == SHOP_CATEGORY_CONSUMABLE)
	theme.apply_tab_button_style(main.shop_tackle_category_button, main._shop_category == SHOP_CATEGORY_ROD)
	theme.apply_tab_button_style(main.shop_line_category_button, main._shop_category == SHOP_CATEGORY_LINE)
	theme.apply_tab_button_style(main.shop_hook_category_button, main._shop_category == SHOP_CATEGORY_HOOK)
	theme.apply_tab_button_style(main.shop_float_category_button, main._shop_category == SHOP_CATEGORY_FLOAT)
	_rebuild_shop_cards()
	_layout_shop_details_nodes()


func _rebuild_shop_cards() -> void:
	for child in main.shop_items_container.get_children():
		child.queue_free()

	main._shop_card_nodes.clear()
	var all_items = _get_shop_items_for_category(main._shop_category)
	var total_count: int = all_items.size()
	var page_size := _get_shop_items_per_page(main._shop_category)
	var page_count: int = max(ceili(float(total_count) / float(page_size)), 1)
	main._shop_page = clampi(main._shop_page, 0, page_count - 1)
	var page_start: int = main._shop_page * page_size
	var page_end: int = mini(page_start + page_size, total_count)
	var items := all_items.slice(page_start, page_end)
	var viewport_size: Vector2 = main.shop_items_scroll.size if main.shop_items_scroll != null else main.shop_items_container.size
	var content_width: float = max(viewport_size.x - 12.0, 1.0)
	main.shop_items_container.position = Vector2.ZERO
	main.shop_items_container.size = Vector2(content_width, viewport_size.y)
	var columns := 2
	var gap := 12.0
	var is_rod_category: bool = str(main._shop_category) == SHOP_CATEGORY_ROD
	var is_image_category: bool = is_rod_category or str(main._shop_category) == SHOP_CATEGORY_BAIT

	var card_width: float = (content_width - gap * float(columns - 1)) / float(columns)
	var rows: int = max(ceil(float(items.size()) / float(columns)), 1)
	var card_min_height := 148.0 if is_image_category else 60.0
	var card_max_height := 160.0 if is_image_category else 68.0

	var card_height: float = min(max((main.shop_items_container.size.y - gap * float(rows - 1)) / float(rows), card_min_height), card_max_height)
	var content_height: float = max(viewport_size.y, float(rows) * card_height + gap * float(max(rows - 1, 0)))
	main.shop_items_container.size = Vector2(content_width, content_height)
	main.shop_items_container.custom_minimum_size = main.shop_items_container.size
	_update_shop_pager(page_count, total_count, page_size)

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

	var rod_card_texture := _get_shop_card_texture(item)
	if rod_card_texture != null:
		_populate_rod_image_card(card, item, card_size, rod_card_texture, rarity_color)
		return card

	if true:
		var compact_icon_size := 30.0
		var compact_icon_y := (card_size.y - compact_icon_size) * 0.5
		var compact_content_x := 50.0
		var compact_buy_width := 58.0
		var compact_buy_height := 28.0
		var compact_details_width := 86.0
		var compact_details_gap := 6.0
		var is_rod_item := str(item.get("category", item.get("type", "misc"))) == SHOP_CATEGORY_ROD
		var compact_buy_x := card_size.x - compact_buy_width - 12.0
		var compact_action_x := compact_buy_x
		if is_rod_item:
			compact_action_x = compact_buy_x - compact_details_gap - compact_details_width
		var compact_text_y := maxf(7.0, (card_size.y - 43.0) * 0.5)
		var compact_text_width: float = maxf(compact_action_x - compact_content_x - 18.0, 140.0)

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
		compact_name_label.text = str(item.get("name", "-"))
		compact_name_label.position = Vector2(compact_content_x, compact_text_y)
		compact_name_label.size = Vector2(compact_text_width, 19.0)
		compact_name_label.clip_text = true
		compact_name_label.add_theme_font_size_override("font_size", 12)
		compact_name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.91, 1.0))
		card.add_child(compact_name_label)

		var compact_quantity = int(item.get("quantity", 1))
		var compact_owned = _get_owned_shop_item_quantity(item_id)
		var compact_meta_label = Label.new()
		compact_meta_label.text = "%s  |  %s" % [
			_get_shop_compact_stat_text(item),
			PlayerData.format_money(float(item.get("price", 0.0)))
		]
		if compact_quantity > 1:
			compact_meta_label.text = "%s  |  x%d  |  %s" % [
				_get_shop_compact_stat_text(item),
				compact_quantity,
				PlayerData.format_money(float(item.get("price", 0.0)))
			]
		compact_meta_label.position = Vector2(compact_content_x, compact_text_y + 22.0)
		compact_meta_label.size = Vector2(compact_text_width, 17.0)
		compact_meta_label.clip_text = true
		compact_meta_label.add_theme_font_size_override("font_size", 10)
		compact_meta_label.add_theme_color_override("font_color", Color(0.74, 0.88, 0.78, 0.92))
		card.add_child(compact_meta_label)

		var compact_owned_label = Label.new()
		compact_owned_label.text = "Есть %d" % compact_owned
		compact_owned_label.position = Vector2(compact_action_x - 58.0, compact_text_y + 1.0)
		compact_owned_label.size = Vector2(48.0, 16.0)
		compact_owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		compact_owned_label.clip_text = true
		compact_owned_label.add_theme_font_size_override("font_size", 9)
		compact_owned_label.add_theme_color_override("font_color", Color(0.62, 0.76, 0.68, 0.78))
		card.add_child(compact_owned_label)

		if is_rod_item:
			var compact_details_button = Button.new()
			compact_details_button.text = "Подробнее"
			compact_details_button.position = Vector2(compact_action_x, (card_size.y - compact_buy_height) * 0.5)
			compact_details_button.size = Vector2(compact_details_width, compact_buy_height)
			_apply_shop_details_button_style(compact_details_button)
			compact_details_button.pressed.connect(_show_shop_details.bind(item_id))
			card.add_child(compact_details_button)

		var compact_buy_button = Button.new()
		compact_buy_button.text = "Купить"
		compact_buy_button.position = Vector2(compact_buy_x, (card_size.y - compact_buy_height) * 0.5)
		compact_buy_button.size = Vector2(compact_buy_width, compact_buy_height)
		_apply_shop_buy_button_style(compact_buy_button)
		compact_buy_button.pressed.connect(_on_shop_buy_pressed.bind(item_id))
		card.add_child(compact_buy_button)
		return card

	return card

func _populate_rod_image_card(card: Panel, item: Dictionary, card_size: Vector2, texture: Texture2D, rarity_color: Color) -> void:
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

	var badge := Label.new()
	badge.name = "ShopCardBadge"
	badge.text = str(ROD_CARD_BADGE_NUMBERS.get(item_id, 1)) if category == SHOP_CATEGORY_ROD else str(item.get("icon", "B")).substr(0, 1).to_upper()
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
	var action_gap := 8.0
	var buy_width := 68.0
	var details_width := 94.0
	var actions_y := maxf(21.0, info_area_height - 6.0 - actions_height)
	var buy_x := info_area.size.x - info_padding - buy_width
	var details_x := buy_x - action_gap - details_width
	var actions_width := details_width + action_gap + buy_width
	var left_width := maxf(details_x - info_padding - 14.0, 120.0)

	var price_label := Label.new()
	price_label.name = "RodCardPriceLabel"
	price_label.text = PlayerData.format_money(float(item.get("price", 0.0)))
	price_label.position = Vector2(details_x, 3.0)
	price_label.size = Vector2(actions_width, 16.0)
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	price_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	price_label.clip_text = true
	price_label.add_theme_font_size_override("font_size", 12)
	price_label.add_theme_color_override("font_color", Color(0.92, 1.0, 0.90, 0.96))
	info_area.add_child(price_label)

	var name_label := Label.new()
	name_label.name = "RodCardNameLabel"
	name_label.text = str(item.get("name", "-"))
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
	details_button.add_theme_font_size_override("font_size", 11)
	details_button.pressed.connect(_show_shop_details.bind(item_id))
	info_area.add_child(details_button)

	var buy_button := Button.new()
	buy_button.name = "RodCardBuyButton"
	buy_button.text = "Купить"
	buy_button.position = Vector2(buy_x, actions_y)
	buy_button.size = Vector2(buy_width, actions_height)
	_apply_shop_buy_button_style(buy_button)
	buy_button.add_theme_font_size_override("font_size", 11)
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
			return "Нагрузка %.1f кг / обрыв %d%%" % [
				float(stats.get("max_load_kg", stats.get("strength", 0.0))),
				roundi(float(stats.get("break_resistance", 1.0)) * 100.0)
			]
		"float":
			return "Клёв +%d%% / стабильн. +%d%%" % [
				roundi((float(stats.get("sensitivity", stats.get("bite_detection_bonus", 0.0))) + float(stats.get("bite_visibility", 0.0)) * 0.5) * 100.0),
				roundi(float(stats.get("stability", 0.0)) * 100.0)
			]
		"hook":
			return "№%s / %s / +%d%%" % [
				PlayerData.format_hook_size(int(stats.get("hook_size", 0))),
				main._format_tackle_stat_value("target_fish_size", stats.get("target_fish_size", "small")),
				roundi(float(stats.get("hook_chance", stats.get("hook_success_bonus", 0.0))) * 100.0)
			]
		"bait":
			return "Клёв +%d%%" % roundi(float(stats.get("fish_attraction", 0.0)) * 100.0)
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
		PlayerData.format_money(float(item.get("price", 0.0))),
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
			return "Тип: %s\nБонус клёва: +%d%%\nПачка: x%d\nЦена: %s" % [
				_format_bait_type_name(str(stats.get("bait_type", "worm"))),
				roundi(float(stats.get("fish_attraction", 0.0)) * 100.0),
				int(item.get("quantity", 1)),
				PlayerData.format_money(float(item.get("price", 0.0)))
			]
		_:
			return "%s\nЦена: %s" % [
				_get_shop_key_stat_text(item),
				PlayerData.format_money(float(item.get("price", 0.0)))
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
			return "Нагрузка %.1f кг  |  обрыв %d%%" % [
				float(stats.get("max_load_kg", stats.get("strength", 0.0))),
				roundi(float(stats.get("break_resistance", 1.0)) * 100.0)
			]
		"float":
			return "Клёв +%d%%  |  стабильн. +%d%%" % [
				roundi((float(stats.get("sensitivity", stats.get("bite_detection_bonus", 0.0))) + float(stats.get("bite_visibility", 0.0)) * 0.5) * 100.0),
				roundi(float(stats.get("stability", 0.0)) * 100.0)
			]
		"hook":
			return "№%s  |  %s  |  подсечка +%d%%" % [
				PlayerData.format_hook_size(int(stats.get("hook_size", 0))),
				main._format_tackle_stat_value("target_fish_size", stats.get("target_fish_size", "small")),
				roundi(float(stats.get("hook_chance", stats.get("hook_success_bonus", 0.0))) * 100.0)
			]
		"bait":
			return "Клёв +%d%%  |  пачка x%d" % [
				roundi(float(stats.get("fish_attraction", 0.0)) * 100.0),
				int(item.get("quantity", 1))
			]
		_:
			if stats.has("bite_bonus"):
				return "Бонус клёва +%d%%" % roundi(float(stats.get("bite_bonus", 0.0)) * 100.0)
			return "Расходник"


func _set_shop_category(category: String) -> void:
	main._shop_category = category
	main._shop_page = 0
	_show_shop_notice("", true)
	_update_shop_ui()


func _on_shop_prev_page_pressed() -> void:
	if main._shop_page <= 0:
		return

	main._shop_page -= 1
	_show_shop_notice("", true)
	_update_shop_ui()


func _on_shop_next_page_pressed() -> void:
	var total_count: int = _get_shop_items_for_category(main._shop_category).size()
	var page_size := _get_shop_items_per_page(main._shop_category)
	var page_count: int = max(ceili(float(total_count) / float(page_size)), 1)
	if main._shop_page >= page_count - 1:
		return

	main._shop_page += 1
	_show_shop_notice("", true)
	_update_shop_ui()


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
