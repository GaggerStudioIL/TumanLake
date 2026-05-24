# Handles the shop window: categories, item cards, and buy requests.
extends RefCounted

var main
var theme
signal buy_requested(item_id: String)

const SHOP_ITEMS_PER_PAGE := 8
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
	"maggot": 8
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

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	_ensure_shop_ui_nodes()
	_ensure_shop_pager_nodes()

func open() -> void:
	if main._is_catch_reward_open() or main.shop_button.disabled:
		return
	if main._shop_category == SHOP_CATEGORY_TACKLE:
		main._shop_category = SHOP_CATEGORY_ROD

	main._active_nav_tab = "shop"
	main.basket_panel.visible = false
	main.basket_backdrop.visible = false
	main.inventory_panel.visible = false
	main.inventory_backdrop.visible = false
	main.tackle_panel.visible = false
	main.tackle_backdrop.visible = false
	main.waterbody_panel.visible = false
	main.waterbody_backdrop.visible = false
	main.shop_backdrop.visible = true
	main.shop_panel.visible = true
	refresh()
	main._refresh_bottom_nav_styles()

func close() -> void:
	if main == null or main.shop_panel == null:
		return

	main.shop_panel.visible = false
	main.shop_backdrop.visible = false
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

func _get_tackle_shop_items_for_type(category: String) -> Array:
	var items: Array = []
	for item in PlayerData.get_tackle_shop_items():
		var item_category := str(item.get("type", item.get("category", "")))
		if item_category == category:
			items.append(item.duplicate(true))
	return items

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


func _update_shop_pager(page_count: int, total_count: int) -> void:
	_ensure_shop_pager_nodes()
	if main.shop_prev_page_button == null or main.shop_next_page_button == null or main.shop_page_label == null:
		return

	var has_pages := total_count > SHOP_ITEMS_PER_PAGE
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


func _rebuild_shop_cards() -> void:
	for child in main.shop_items_container.get_children():
		child.queue_free()

	main._shop_card_nodes.clear()
	var all_items = _get_shop_items_for_category(main._shop_category)
	var total_count: int = all_items.size()
	var page_count: int = max(ceili(float(total_count) / float(SHOP_ITEMS_PER_PAGE)), 1)
	main._shop_page = clampi(main._shop_page, 0, page_count - 1)
	var page_start: int = main._shop_page * SHOP_ITEMS_PER_PAGE
	var page_end: int = mini(page_start + SHOP_ITEMS_PER_PAGE, total_count)
	var items := all_items.slice(page_start, page_end)
	var viewport_size: Vector2 = main.shop_items_scroll.size if main.shop_items_scroll != null else main.shop_items_container.size
	var content_width: float = max(viewport_size.x - 12.0, 1.0)
	main.shop_items_container.position = Vector2.ZERO
	main.shop_items_container.size = Vector2(content_width, viewport_size.y)
	var columns = 2
	var gap = 10.0

	var card_width: float = (content_width - gap * float(columns - 1)) / float(columns)
	var rows: int = max(ceil(float(items.size()) / float(columns)), 1)
	var card_min_height = 60.0
	var card_max_height = 68.0

	var card_height: float = min(max((main.shop_items_container.size.y - gap * float(rows - 1)) / float(rows), card_min_height), card_max_height)
	var content_height: float = max(viewport_size.y, float(rows) * card_height + gap * float(max(rows - 1, 0)))
	main.shop_items_container.size = Vector2(content_width, content_height)
	main.shop_items_container.custom_minimum_size = main.shop_items_container.size
	_update_shop_pager(page_count, total_count)

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

	if true:
		var compact_icon_size := 30.0
		var compact_icon_y := (card_size.y - compact_icon_size) * 0.5
		var compact_content_x := 50.0
		var compact_buy_width := 58.0
		var compact_buy_height := 28.0
		var compact_buy_x := card_size.x - compact_buy_width - 12.0
		var compact_text_width: float = maxf(compact_buy_x - compact_content_x - 18.0, 140.0)

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
		compact_name_label.position = Vector2(compact_content_x, 7.0)
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
		compact_meta_label.position = Vector2(compact_content_x, 29.0)
		compact_meta_label.size = Vector2(compact_text_width, 17.0)
		compact_meta_label.clip_text = true
		compact_meta_label.add_theme_font_size_override("font_size", 10)
		compact_meta_label.add_theme_color_override("font_color", Color(0.74, 0.88, 0.78, 0.92))
		card.add_child(compact_meta_label)

		var compact_owned_label = Label.new()
		compact_owned_label.text = "Есть %d" % compact_owned
		compact_owned_label.position = Vector2(compact_buy_x - 58.0, 8.0)
		compact_owned_label.size = Vector2(48.0, 16.0)
		compact_owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		compact_owned_label.clip_text = true
		compact_owned_label.add_theme_font_size_override("font_size", 9)
		compact_owned_label.add_theme_color_override("font_color", Color(0.62, 0.76, 0.68, 0.78))
		card.add_child(compact_owned_label)

		var compact_buy_button = Button.new()
		compact_buy_button.text = "Купить"
		compact_buy_button.position = Vector2(compact_buy_x, (card_size.y - compact_buy_height) * 0.5)
		compact_buy_button.size = Vector2(compact_buy_width, compact_buy_height)
		_apply_shop_buy_button_style(compact_buy_button)
		compact_buy_button.pressed.connect(_on_shop_buy_pressed.bind(item_id))
		card.add_child(compact_buy_button)
		return card

	return card

func _apply_shop_buy_button_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", main._make_panel_style(Color(0.24, 0.52, 0.16, 0.96), Color(0.68, 1.0, 0.58, 0.44), 8, 3, Color(0.0, 0.0, 0.0, 0.16)))
	button.add_theme_stylebox_override("hover", main._make_panel_style(Color(0.30, 0.64, 0.20, 1.0), Color(0.78, 1.0, 0.66, 0.62), 8, 4, Color(0.18, 0.68, 0.22, 0.18)))
	button.add_theme_stylebox_override("pressed", main._make_panel_style(Color(0.18, 0.40, 0.12, 1.0), Color(0.58, 0.88, 0.48, 0.52), 8, 1, Color(0.0, 0.0, 0.0, 0.12)))
	button.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.86, 1.0, 0.82, 1.0))
	button.add_theme_font_size_override("font_size", 11)
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


func _get_owned_shop_item_quantity(item_id: String) -> int:
	var owned_item = PlayerData.get_owned_item(item_id)

	if owned_item.is_empty():
		return 0

	return int(owned_item.get("quantity", 0))


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
	var page_count: int = max(ceili(float(total_count) / float(SHOP_ITEMS_PER_PAGE)), 1)
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
