# Handles the keepnet window: fish cards, stats, and sell requests.
extends RefCounted

var main
var theme
signal sell_fish_requested(fish_index: int)

enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	_ensure_keepnet_ui_nodes()

func open() -> void:
	if main._is_catch_reward_open():
		return

	main.open_modal("keepnet")
	main._active_nav_tab = "sell"
	main.basket_backdrop.visible = true
	main.basket_panel.visible = true
	_show_basket_notice("")
	refresh()
	main._refresh_bottom_nav_styles()

func close() -> void:
	if main == null or main.basket_panel == null:
		return

	main.basket_panel.visible = false
	main.basket_backdrop.visible = false
	main.close_modal("keepnet")
	main._active_nav_tab = "fish"
	main._refresh_bottom_nav_styles()

func refresh() -> void:
	_update_basket_ui()

func is_open() -> bool:
	return main != null and main.basket_panel != null and main.basket_panel.visible

func _on_keepnet_sell_fish_pressed(fish_index: int) -> void:
	sell_fish_requested.emit(fish_index)

func _ensure_keepnet_ui_nodes() -> void:
	if main.basket_backdrop != null:
		return

	main.basket_backdrop = ColorRect.new()
	main.basket_backdrop.name = "BasketBackdrop"
	main.basket_backdrop.visible = false
	theme.apply_modal_backdrop_style(main.basket_backdrop)
	var backdrop_parent: Node = main.basket_panel.get_parent()
	if backdrop_parent == null:
		backdrop_parent = main
	backdrop_parent.add_child(main.basket_backdrop)
	if main.basket_panel.get_parent() == backdrop_parent:
		backdrop_parent.move_child(main.basket_backdrop, main.basket_panel.get_index())

	main.basket_frame_panel = Panel.new()
	main.basket_frame_panel.name = "BasketFramePanel"
	main.basket_frame_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.basket_frame_panel.z_index = 0
	main.basket_panel.add_child(main.basket_frame_panel)

	main.basket_stats_label = Label.new()
	main.basket_stats_label.name = "BasketStatsLabel"
	main.basket_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.basket_stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.basket_stats_label.z_index = 2
	main.basket_panel.add_child(main.basket_stats_label)

	main.basket_scroll = ScrollContainer.new()
	main.basket_scroll.name = "BasketScroll"
	main.basket_scroll.z_index = 2
	main.basket_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	main.basket_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main.basket_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	main.basket_panel.add_child(main.basket_scroll)

	main.basket_cards_grid = GridContainer.new()
	main.basket_cards_grid.name = "BasketCardsGrid"
	main.basket_cards_grid.columns = 2
	main.basket_cards_grid.mouse_filter = Control.MOUSE_FILTER_PASS
	main.basket_scroll.add_child(main.basket_cards_grid)

	main.basket_notice_label = Label.new()
	main.basket_notice_label.name = "BasketNoticeLabel"
	main.basket_notice_label.text = ""
	main.basket_notice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.basket_notice_label.z_index = 2
	main.basket_panel.add_child(main.basket_notice_label)


func _update_basket_ui() -> void:
	var fish_count: int = InventoryManager.inventory.size()
	main.basket_button.text = "Садок"
	var summary = _get_keepnet_summary()
	main.basket_stats_label.text = "%d рыб  |  %.2f кг  |  %d мон." % [
		fish_count,
		float(summary.get("weight", 0.0)),
		int(summary.get("price", 0))
	]
	main.basket_contents_label.text = "Садок пуст.\nПоймай первую рыбу."
	main.basket_contents_label.visible = fish_count == 0
	main.basket_scroll.visible = fish_count > 0
	main.basket_sell_all_button.disabled = fish_count == 0 or main._fishing_ui_state == FishingUiState.WAITING or main._fishing_ui_state == FishingUiState.FIGHTING

	if main.basket_panel.visible:
		_rebuild_keepnet_cards()


func _get_keepnet_summary() -> Dictionary:
	var total_weight = 0.0
	var total_price = 0

	for fish in InventoryManager.inventory:
		if typeof(fish) != TYPE_DICTIONARY:
			continue

		total_weight += float(fish.get("weight", 0.0))
		total_price += InventoryManager.get_fish_sell_price(fish)

	return {
		"weight": total_weight,
		"price": total_price
	}


func _rebuild_keepnet_cards() -> void:
	for child in main.basket_cards_grid.get_children():
		child.queue_free()

	var fish_count: int = InventoryManager.inventory.size()
	if fish_count == 0:
		return

	var columns = 3 if main.basket_scroll.size.x >= 820.0 else 2
	var gap = 10.0
	var card_width: float = (main.basket_scroll.size.x - gap * float(columns - 1)) / float(columns)
	var card_height = 148.0
	main.basket_cards_grid.columns = columns
	main.basket_cards_grid.custom_minimum_size = Vector2(main.basket_scroll.size.x, 0.0)

	for i in fish_count:
		var fish: Dictionary = InventoryManager.inventory[i]
		var card = _create_keepnet_card(fish, i, Vector2(card_width, card_height))
		main.basket_cards_grid.add_child(card)


func _create_keepnet_card(fish: Dictionary, fish_index: int, card_size: Vector2) -> Panel:
	var tier := str(fish.get("catch_rank", "normal"))
	if tier != "trophy" and tier != "rarity":
		tier = "normal"
	var accent = _get_keepnet_tier_color(tier)
	var card = Panel.new()
	card.custom_minimum_size = card_size
	card.size = card_size
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.clip_contents = true
	theme.apply_card_style(card)

	var fish_slot = Panel.new()
	fish_slot.position = Vector2(10.0, 18.0)
	fish_slot.size = Vector2(132.0, 60.0)
	fish_slot.clip_contents = true
	fish_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var slot_rarity: String = "epic" if tier == "rarity" else ("legendary" if tier == "trophy" else "common")
	theme.apply_rarity_slot_style(fish_slot, slot_rarity)
	card.add_child(fish_slot)

	var fish_texture = main._get_reward_fish_texture(str(fish.get("id", "")))
	if fish_texture != null:
		var fish_sprite = Sprite2D.new()
		fish_sprite.texture = fish_texture
		fish_sprite.centered = true
		fish_sprite.position = fish_slot.size * 0.5
		var texture_size = fish_texture.get_size()
		var fit_scale: float = min(
			(fish_slot.size.x - 12.0) / max(texture_size.x, 1.0),
			(fish_slot.size.y - 10.0) / max(texture_size.y, 1.0)
		)
		fish_sprite.scale = Vector2.ONE * fit_scale
		fish_slot.add_child(fish_sprite)
	else:
		var fallback_label = Label.new()
		fallback_label.text = "><>"
		fallback_label.position = Vector2.ZERO
		fallback_label.size = fish_slot.size
		fallback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		fallback_label.add_theme_font_size_override("font_size", 24)
		fallback_label.add_theme_color_override("font_color", Color(accent.r, accent.g, accent.b, 0.84))
		fish_slot.add_child(fallback_label)

	var name_label = Label.new()
	name_label.text = str(fish.get("name", "-"))
	name_label.position = Vector2(154.0, 10.0)
	name_label.size = Vector2(card_size.x - 164.0, 22.0)
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.91, 1.0))
	card.add_child(name_label)

	var badge_label = Label.new()
	badge_label.text = _get_keepnet_tier_label(tier)
	badge_label.visible = tier == "trophy" or tier == "rarity"
	badge_label.position = Vector2(154.0, 34.0)
	badge_label.size = Vector2(112.0, 22.0)
	badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge_label.add_theme_font_size_override("font_size", 12)
	badge_label.add_theme_color_override("font_color", Color(accent.r, accent.g, accent.b, 1.0))
	badge_label.add_theme_stylebox_override(
		"normal",
		main._make_panel_style(Color(accent.r * 0.16, accent.g * 0.20, accent.b * 0.18, 0.62), Color(accent.r, accent.g, accent.b, 0.36), 11, 4, Color(0.0, 0.0, 0.0, 0.10))
	)
	card.add_child(badge_label)

	var weight = float(fish.get("weight", 0.0))
	var length_cm = main._get_catch_length_cm(fish)
	var price = InventoryManager.get_fish_sell_price(fish)
	var freshness_title := FishFreshnessManager.get_freshness_title(fish)
	var status_title := _get_fish_status_title(fish)
	var market_demand := _get_market_demand(fish)
	var supplier_name := _get_best_supplier_name(fish)
	var stats_label = Label.new()
	stats_label.text = "%.2f кг | %.1f см | %s\n%d мон. | спрос x%.2f | %s\n%s" % [
		weight,
		length_cm,
		status_title,
		price,
		market_demand,
		freshness_title,
		supplier_name
	]
	stats_label.position = Vector2(12.0, 82.0)
	stats_label.size = Vector2(card_size.x - 128.0, 56.0)
	stats_label.clip_text = true
	stats_label.add_theme_font_size_override("font_size", 12)
	stats_label.add_theme_color_override("font_color", Color(0.76, 0.88, 0.80, 0.92))
	card.add_child(stats_label)

	var sell_button = Button.new()
	sell_button.text = "Продать"
	sell_button.position = Vector2(card_size.x - 104.0, card_size.y - 48.0)
	sell_button.size = Vector2(92.0, 40.0)
	sell_button.z_index = 10
	sell_button.mouse_filter = Control.MOUSE_FILTER_STOP
	main._apply_button_style(sell_button, main.STYLE_SECONDARY_BUTTON)
	sell_button.size = Vector2(92.0, 40.0)
	sell_button.add_theme_font_size_override("font_size", 12)
	sell_button.pressed.connect(_on_keepnet_sell_fish_pressed.bind(fish_index))
	card.add_child(sell_button)

	return card


func _get_keepnet_tier_color(tier: String) -> Color:
	match tier:
		"rarity":
			return Color(0.82, 0.56, 1.0, 1.0)
		"trophy":
			return Color(1.0, 0.80, 0.38, 1.0)
		"rare":
			return Color(0.54, 0.86, 1.0, 1.0)
		"uncommon":
			return Color(0.58, 1.0, 0.64, 1.0)
		_:
			return Color(0.72, 0.86, 0.76, 1.0)


func _get_keepnet_tier_label(tier: String) -> String:
	match tier:
		"rarity":
			return "Раритет"
		"trophy":
			return "Трофей"
		"rare":
			return "Редкая"
		"uncommon":
			return "Необычная"
		_:
			return "Обычная"


func _get_fish_status_title(fish: Dictionary) -> String:
	if fish.has("fish_status_title"):
		return str(fish.get("fish_status_title", "Незачет"))

	var status_system: Node = main.get_node_or_null("/root/FishStatusSystem")
	if status_system != null and status_system.has_method("get_status_title"):
		return str(status_system.call("get_status_title", str(fish.get("fish_status", "undersized"))))

	return "Незачет"


func _get_market_demand(fish: Dictionary) -> float:
	var market_manager: Node = main.get_node_or_null("/root/DynamicMarketManager")
	if market_manager != null and market_manager.has_method("get_demand_multiplier"):
		return float(market_manager.call("get_demand_multiplier", str(fish.get("id", "")), str(fish.get("waterbody_id", ""))))
	return 1.0


func _get_best_supplier_name(fish: Dictionary) -> String:
	var supplier_manager: Node = main.get_node_or_null("/root/SupplierManager")
	if supplier_manager == null or not supplier_manager.has_method("get_best_supplier_for_catch"):
		return "Местный рынок"

	var supplier_id := str(supplier_manager.call("get_best_supplier_for_catch", fish))
	if supplier_manager.has_method("get_supplier_title"):
		return str(supplier_manager.call("get_supplier_title", supplier_id))
	return supplier_id


func _show_basket_notice(message: String, success: bool = true) -> void:
	if main.basket_notice_label == null:
		return

	main.basket_notice_label.text = message
	main.basket_notice_label.modulate = Color(0.78, 1.0, 0.78, 1.0) if success else Color(1.0, 0.64, 0.54, 1.0)
