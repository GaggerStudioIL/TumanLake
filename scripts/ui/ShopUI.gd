# Handles the shop window: categories, item cards, and buy requests.
extends RefCounted

var main
var theme
signal buy_requested(item_id: String)

const SHOP_CATEGORY_BAIT := "bait"
const SHOP_CATEGORY_CONSUMABLE := "consumable"
const SHOP_CATEGORY_TACKLE := "tackle"
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

func open() -> void:
	if main._is_catch_reward_open() or main.shop_button.disabled:
		return

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
		return PlayerData.get_tackle_shop_items()
	if category == SHOP_CATEGORY_BAIT:
		return _get_bait_shop_items()

	var items: Array = []
	for item in CONSUMABLE_ITEMS:
		if str(item.get("shop_category", "")) == category:
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
	for category in [SHOP_CATEGORY_BAIT, SHOP_CATEGORY_CONSUMABLE, SHOP_CATEGORY_TACKLE]:
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
		"price": int(shop_item.get("price", 0)),
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

	main.shop_items_container = Control.new()
	main.shop_items_container.name = "ShopItemsContainer"
	main.shop_panel.add_child(main.shop_items_container)

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


func _update_shop_ui() -> void:
	if main.shop_panel == null:
		return

	main.shop_money_label.text = "%d мон." % PlayerData.money
	theme.apply_tab_button_style(main.shop_bait_category_button, main._shop_category == SHOP_CATEGORY_BAIT)
	theme.apply_tab_button_style(main.shop_consumable_category_button, main._shop_category == SHOP_CATEGORY_CONSUMABLE)
	theme.apply_tab_button_style(main.shop_tackle_category_button, main._shop_category == SHOP_CATEGORY_TACKLE)
	_rebuild_shop_cards()


func _rebuild_shop_cards() -> void:
	for child in main.shop_items_container.get_children():
		child.queue_free()

	main._shop_card_nodes.clear()
	var items = _get_shop_items_for_category(main._shop_category)
	var columns = 3 if main.shop_items_container.size.x >= 820.0 else 2
	var gap = 10.0

	var card_width: float = (main.shop_items_container.size.x - gap * float(columns - 1)) / float(columns)
	var rows: int = max(ceil(float(items.size()) / float(columns)), 1)
	var card_min_height = 96.0
	var card_max_height = 112.0

	if main._shop_category == SHOP_CATEGORY_TACKLE:
		gap = 8.0
		columns = 3 if main.shop_items_container.size.x >= 760.0 else 2
		card_width = (main.shop_items_container.size.x - gap * float(columns - 1)) / float(columns)
		card_min_height = 64.0
		card_max_height = 74.0

	var card_height: float = min(max((main.shop_items_container.size.y - gap * float(rows - 1)) / float(rows), card_min_height), card_max_height)

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
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.mouse_entered.connect(_on_shop_card_hovered.bind(str(item.get("id", "")), true))
	card.mouse_exited.connect(_on_shop_card_hovered.bind(str(item.get("id", "")), false))
	theme.apply_card_style(card)

	var item_id = str(item.get("id", ""))
	var rarity = str(item.get("rarity", "common"))
	var rarity_color = main._get_rarity_color(rarity)
	theme.apply_shop_row_style(card, rarity)
	var compact = card_size.y <= 80.0
	var content_x = 52.0 if compact else 56.0
	var button_width = 92.0 if compact else 96.0
	var button_height = 56.0
	var button_x = card_size.x - button_width - 12.0
	var icon_size = 32.0 if compact else 36.0
	var icon_y = (card_size.y - icon_size) * 0.5
	var name_font_size = 13 if compact else 14
	var stat_font_size = 10 if compact else 11
	var meta_font_size = 10 if compact else 11
	var price_font_size = 12 if compact else 13
	var badge_font_size = 9 if compact else 10

	var icon_label = Label.new()
	icon_label.text = str(item.get("icon", "?"))
	icon_label.position = Vector2(10.0, icon_y)
	icon_label.size = Vector2(icon_size, icon_size)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 17 if compact else 18)
	icon_label.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.98))
	icon_label.add_theme_stylebox_override(
		"normal",
		main._make_panel_style(Color(0.10, 0.22, 0.17, 0.72), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.32), 12, 4, Color(0.0, 0.0, 0.0, 0.10))
	)
	card.add_child(icon_label)

	if not compact:
		var badge_label = Label.new()
		badge_label.text = main._get_rarity_title(rarity)
		badge_label.position = Vector2(button_x, 7.0)
		badge_label.size = Vector2(button_width, 20.0)
		badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge_label.clip_text = true
		badge_label.add_theme_font_size_override("font_size", badge_font_size)
		badge_label.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 1.0))
		badge_label.add_theme_stylebox_override(
			"normal",
			main._make_panel_style(Color(rarity_color.r * 0.12, rarity_color.g * 0.16, rarity_color.b * 0.14, 0.64), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.34), 10, 2, Color(0.0, 0.0, 0.0, 0.08))
		)
		card.add_child(badge_label)

	var name_label = Label.new()
	name_label.text = str(item.get("name", "-"))
	name_label.position = Vector2(content_x, 7.0)
	name_label.size = Vector2(max(button_x - content_x - 10.0, 96.0), 19.0)
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", name_font_size)
	name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.91, 1.0))
	card.add_child(name_label)

	var quantity = int(item.get("quantity", 1))
	var owned = _get_owned_shop_item_quantity(item_id)
	var stat_label = Label.new()
	stat_label.text = _get_shop_key_stat_text(item)
	stat_label.position = Vector2(content_x, 27.0)
	stat_label.size = Vector2(max(button_x - content_x - 10.0, 96.0), 16.0)
	stat_label.clip_text = true
	stat_label.add_theme_font_size_override("font_size", stat_font_size)
	stat_label.add_theme_color_override("font_color", Color(0.74, 0.88, 0.78, 0.92))
	card.add_child(stat_label)

	var owned_label = Label.new()
	owned_label.text = "Есть: %d  +%d" % [owned, quantity]
	owned_label.position = Vector2(content_x, card_size.y - 23.0)
	owned_label.size = Vector2(88.0, 17.0)
	owned_label.clip_text = true
	owned_label.add_theme_font_size_override("font_size", meta_font_size)
	owned_label.add_theme_color_override("font_color", Color(0.64, 0.78, 0.70, 0.84))
	card.add_child(owned_label)

	var price_label = Label.new()
	price_label.text = "%d мон." % int(item.get("price", 0))
	price_label.position = Vector2(content_x + 92.0, card_size.y - 24.0)
	price_label.size = Vector2(max(button_x - content_x - 102.0, 54.0), 18.0)
	price_label.clip_text = true
	price_label.add_theme_font_size_override("font_size", price_font_size)
	price_label.add_theme_color_override("font_color", Color(0.92, 0.96, 0.74, 0.95))
	card.add_child(price_label)

	var buy_button = Button.new()
	buy_button.text = "Купить"
	buy_button.position = Vector2(button_x, max(6.0, card_size.y - button_height - 8.0))
	buy_button.size = Vector2(button_width, button_height)
	main._apply_button_style(buy_button, main.STYLE_PRIMARY_BUTTON)
	buy_button.pressed.connect(_on_shop_buy_pressed.bind(item_id))
	card.add_child(buy_button)

	return card


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
			return "Рыба %.1f кг  |  контроль +%d%%" % [
				float(stats.get("max_fish_weight", 0.0)),
				roundi(float(stats.get("tension_bonus", stats.get("control_bonus", 0.0))) * 100.0)
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
			return "№%d  |  %s  |  подсечка +%d%%" % [
				int(stats.get("hook_size", 0)),
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
