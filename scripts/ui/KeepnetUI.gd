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

	main._active_nav_tab = "sell"
	main.inventory_panel.visible = false
	main.inventory_backdrop.visible = false
	main.tackle_panel.visible = false
	main.tackle_backdrop.visible = false
	main.waterbody_panel.visible = false
	main.waterbody_backdrop.visible = false
	main.shop_panel.visible = false
	main.shop_backdrop.visible = false
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
		total_price += int(fish.get("price", 0))

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
	var card_height = 128.0
	main.basket_cards_grid.columns = columns
	main.basket_cards_grid.custom_minimum_size = Vector2(main.basket_scroll.size.x, 0.0)

	for i in fish_count:
		var fish: Dictionary = InventoryManager.inventory[i]
		var card = _create_keepnet_card(fish, i, Vector2(card_width, card_height))
		main.basket_cards_grid.add_child(card)


func _create_keepnet_card(fish: Dictionary, fish_index: int, card_size: Vector2) -> Panel:
	var tier = main._get_reward_tier(fish)
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
	var slot_rarity: String = "legendary" if tier == "trophy" else tier
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
	var price = int(fish.get("price", 0))
	var stats_label = Label.new()
	stats_label.text = "%.2f кг  |  %.1f см\n%d мон." % [weight, length_cm, price]
	stats_label.position = Vector2(12.0, 86.0)
	stats_label.size = Vector2(card_size.x - 128.0, 34.0)
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
		"trophy":
			return "Трофей"
		"rare":
			return "Редкая"
		"uncommon":
			return "Необычная"
		_:
			return "Обычная"


func _show_basket_notice(message: String, success: bool = true) -> void:
	if main.basket_notice_label == null:
		return

	main.basket_notice_label.text = message
	main.basket_notice_label.modulate = Color(0.78, 1.0, 0.78, 1.0) if success else Color(1.0, 0.64, 0.54, 1.0)
