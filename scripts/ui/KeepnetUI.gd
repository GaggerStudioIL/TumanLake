# Handles the keepnet window as a catch viewer. Selling stays in the harbor UI.
extends RefCounted

const EmptyStateCardScript := preload("res://scripts/ui/components/EmptyStateCard.gd")
const FishCardScript := preload("res://scripts/ui/components/FishCard.gd")

var main
var theme
var fish_details_overlay: Control
var empty_state_card: Control
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
	if main.has_method("refresh_mobile_scroll_helper"):
		main.refresh_mobile_scroll_helper()
	main._refresh_bottom_nav_styles()

func close() -> void:
	if main == null or main.basket_panel == null:
		return

	_hide_fish_details()
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
	_hide_fish_details()
	sell_fish_requested.emit(fish_index)
	call_deferred("_hide_fish_details")

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
	main.basket_stats_label.add_theme_stylebox_override(
		"normal",
		main._make_panel_style(Color(0.030, 0.060, 0.056, 0.52), Color(0.58, 0.88, 0.78, 0.20), 14, 2, Color(0.0, 0.0, 0.0, 0.12))
	)
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

	empty_state_card = EmptyStateCardScript.new()
	empty_state_card.name = "BasketEmptyStateCard"
	empty_state_card.visible = false
	empty_state_card.z_index = 2
	empty_state_card.setup("Садок пуст", "Поймайте рыбу, и она появится здесь.")
	main.basket_panel.add_child(empty_state_card)


func _update_basket_ui() -> void:
	if InventoryManager.has_method("purge_zero_value_fish") and int(InventoryManager.call("purge_zero_value_fish")) > 0:
		_hide_fish_details()

	var fish_count: int = InventoryManager.inventory.size()
	if fish_count == 0:
		_hide_fish_details()
	main.basket_button.text = "Садок"
	var summary = _get_keepnet_summary()
	main.basket_stats_label.text = "Рыб: %d/%d    Вес: %s    Оценка: %s" % [
		fish_count,
		InventoryManager.max_items,
		UIFormatters.format_weight_kg(float(summary.get("weight", 0.0))),
		UIFormatters.format_money(float(summary.get("price", 0)))
	]
	main.basket_contents_label.visible = false
	_update_empty_state_card(fish_count)
	main.basket_scroll.visible = fish_count > 0
	main.basket_sell_all_button.visible = false
	main.basket_sell_all_button.disabled = true
	main.basket_sell_all_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if main.basket_panel.visible:
		_rebuild_keepnet_cards()


func _update_empty_state_card(fish_count: int) -> void:
	if empty_state_card == null:
		return
	empty_state_card.visible = fish_count == 0
	empty_state_card.position = main.basket_contents_label.position + Vector2(18.0, 18.0)
	empty_state_card.size = Vector2(
		maxf(main.basket_contents_label.size.x - 36.0, 220.0),
		maxf(main.basket_contents_label.size.y - 36.0, 92.0)
	)
	empty_state_card.custom_minimum_size = empty_state_card.size


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

	var available_width: float = maxf(main.basket_scroll.size.x - 8.0, 240.0)
	var columns := 1
	if available_width >= 1180.0:
		columns = 3
	elif available_width >= 780.0:
		columns = 2
	var gap = 12.0
	var card_width: float = floor((available_width - gap * float(columns - 1)) / float(columns))
	var card_height = 218.0
	main.basket_cards_grid.columns = columns
	main.basket_cards_grid.custom_minimum_size = Vector2(available_width, 0.0)

	var entries: Array = []
	for i in fish_count:
		var fish: Dictionary = InventoryManager.inventory[i]
		entries.append({
			"index": i,
			"fish": fish,
			"price": InventoryManager.get_fish_sell_price(fish)
		})
	entries.sort_custom(func(a, b): return int(a.get("price", 0)) > int(b.get("price", 0)))

	for entry in entries:
		var fish: Dictionary = entry.get("fish", {})
		var card = _create_keepnet_card(fish, int(entry.get("index", 0)), Vector2(card_width, card_height))
		main.basket_cards_grid.add_child(card)


func _create_keepnet_card(fish: Dictionary, fish_index: int, card_size: Vector2) -> Panel:
	var tier := str(fish.get("catch_rank", "normal"))
	var fish_status_id := _get_fish_status_id(fish)
	if fish_status_id == "trophy":
		tier = "trophy"
	if tier != "trophy" and tier != "rarity":
		tier = "normal"
	var price := InventoryManager.get_fish_sell_price(fish)
	var card := FishCardScript.new()
	card.setup({
		"fish_id": str(fish.get("id", fish.get("fish_id", ""))),
		"name": str(fish.get("name", "-")),
		"icon": main._get_reward_fish_texture(str(fish.get("id", fish.get("fish_id", "")))),
		"weight": float(fish.get("weight", 0.0)),
		"status": fish_status_id,
		"rarity": str(fish.get("rarityType", "common")),
		"price": price,
		"length": float(main._get_catch_length_cm(fish)),
		"caught_label": _format_caught_at(fish),
		"bait_label": _format_caught_bait(fish),
		"tackle_label": _format_caught_tackle(fish),
		"spot_label": _format_caught_location(fish),
		"freshness_title": FishFreshnessManager.get_freshness_title(fish),
		"is_trophy": fish_status_id == "trophy",
		"badge_text": _get_keepnet_tier_label(tier) if tier == "trophy" or tier == "rarity" else "",
		"badge_type": "trophy" if tier == "trophy" else ("rare" if tier == "rarity" else ""),
		"card_size": card_size
	}, "keepnet")
	card.set_pressed_callback(_show_fish_details.bind(fish_index))
	return card


func _show_fish_details(fish_index: int) -> void:
	if fish_index < 0 or fish_index >= InventoryManager.inventory.size():
		_show_basket_notice("Рыба уже продана.", false)
		refresh()
		return

	_hide_fish_details()
	var fish: Dictionary = InventoryManager.inventory[fish_index]
	var weight: float = float(fish.get("weight", 0.0))
	var length_cm: float = float(main._get_catch_length_cm(fish))
	var price: int = InventoryManager.get_fish_sell_price(fish)
	var status_title: String = _get_short_fish_status_title(fish)
	var freshness_title: String = FishFreshnessManager.get_freshness_title(fish)
	var rarity_title: String = _get_rarity_title(fish)
	var caught_label := _format_caught_at(fish)
	var bait_label := _format_caught_bait(fish)
	var tackle_label := _format_caught_tackle(fish)
	var location_label := _format_caught_location(fish)

	fish_details_overlay = ColorRect.new()
	fish_details_overlay.name = "BasketFishDetailsOverlay"
	fish_details_overlay.color = Color(0.0, 0.0, 0.0, 0.42)
	fish_details_overlay.position = Vector2.ZERO
	fish_details_overlay.size = main.basket_panel.size
	fish_details_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	fish_details_overlay.z_index = 80
	main.basket_panel.add_child(fish_details_overlay)

	var dialog_size := Vector2(minf(560.0, main.basket_panel.size.x - 56.0), minf(430.0, main.basket_panel.size.y - 56.0))
	var dialog := Panel.new()
	dialog.name = "BasketFishDetailsDialog"
	dialog.position = (main.basket_panel.size - dialog_size) * 0.5
	dialog.size = dialog_size
	dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	dialog.add_theme_stylebox_override(
		"panel",
		main._make_panel_style(Color(0.018, 0.040, 0.042, 0.96), Color(0.58, 0.92, 0.84, 0.42), 18, 10, Color(0.0, 0.0, 0.0, 0.34))
	)
	fish_details_overlay.add_child(dialog)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 18.0
	box.offset_top = 16.0
	box.offset_right = -18.0
	box.offset_bottom = -16.0
	box.add_theme_constant_override("separation", 10)
	dialog.add_child(box)

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0.0, 38.0)
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)

	var title := Label.new()
	title.text = "Информация о рыбе"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.95, 1.0, 0.92, 1.0))
	header.add_child(title)

	var close_button := Button.new()
	close_button.text = "Закрыть"
	close_button.custom_minimum_size = Vector2(116.0, 36.0)
	main._apply_button_style(close_button, main.STYLE_SECONDARY_BUTTON)
	close_button.pressed.connect(_hide_fish_details)
	header.add_child(close_button)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	box.add_child(body)

	var preview := Panel.new()
	preview.custom_minimum_size = Vector2(178.0, 132.0)
	preview.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var tier := str(fish.get("catch_rank", "normal"))
	if _get_fish_status_id(fish) == "trophy":
		tier = "trophy"
	var slot_rarity: String = "epic" if tier == "rarity" else ("legendary" if tier == "trophy" else "common")
	theme.apply_rarity_slot_style(preview, slot_rarity)
	body.add_child(preview)
	_add_fish_preview(preview, fish, Vector2(178.0, 132.0))

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 7)
	body.add_child(info)

	var name_label := Label.new()
	name_label.text = str(fish.get("name", "-"))
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", Color(0.96, 1.0, 0.92, 1.0))
	info.add_child(name_label)

	var stats := Label.new()
	var detail_lines: Array = [
		"Вес: %s" % UIFormatters.format_weight_kg(weight),
		"Длина: %s" % UIFormatters.format_length_cm(length_cm),
		"Статус: %s" % status_title,
		"Редкость: %s" % rarity_title,
		"Свежесть: %s" % freshness_title,
		"Оценка в гавани: %s" % UIFormatters.format_money(float(price))
	]
	if not caught_label.is_empty():
		detail_lines.append("Поймана: %s" % caught_label)
	if not bait_label.is_empty():
		detail_lines.append("Поймано на: %s" % bait_label)
	if not tackle_label.is_empty():
		detail_lines.append("Оснастка: %s" % tackle_label)
	if not location_label.is_empty():
		detail_lines.append("Место: %s" % location_label)
	stats.text = "\n".join(detail_lines)
	stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats.add_theme_font_size_override("font_size", 13)
	stats.add_theme_color_override("font_color", Color(0.78, 0.90, 0.84, 0.96))
	info.add_child(stats)

	var footer := HBoxContainer.new()
	footer.custom_minimum_size = Vector2(0.0, 42.0)
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)
	var hint := Label.new()
	hint.text = "Садок теперь только для просмотра. Продажа улова доступна в Рыбной гавани."
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.66, 0.78, 0.74, 0.90))
	footer.add_child(hint)


func _hide_fish_details() -> void:
	if is_instance_valid(fish_details_overlay):
		if fish_details_overlay.get_parent() != null:
			fish_details_overlay.get_parent().remove_child(fish_details_overlay)
		fish_details_overlay.queue_free()
	fish_details_overlay = null
	_remove_orphan_fish_details_overlays()


func _remove_orphan_fish_details_overlays() -> void:
	if main == null or main.basket_panel == null:
		return
	for child in main.basket_panel.get_children():
		if child != null and child.name == "BasketFishDetailsOverlay":
			main.basket_panel.remove_child(child)
			child.queue_free()


func _add_fish_preview(parent: Control, fish: Dictionary, preview_size: Vector2) -> void:
	var fish_texture = main._get_reward_fish_texture(str(fish.get("id", "")))
	if fish_texture != null:
		var fish_sprite := Sprite2D.new()
		fish_sprite.texture = fish_texture
		fish_sprite.centered = true
		fish_sprite.position = preview_size * 0.5
		var texture_size = fish_texture.get_size()
		var fit_scale: float = min(
			(preview_size.x - 16.0) / max(texture_size.x, 1.0),
			(preview_size.y - 14.0) / max(texture_size.y, 1.0)
		)
		fish_sprite.scale = Vector2.ONE * fit_scale
		parent.add_child(fish_sprite)
		return

	var fallback_label := Label.new()
	fallback_label.text = "><>"
	fallback_label.position = Vector2.ZERO
	fallback_label.size = preview_size
	fallback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fallback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fallback_label.add_theme_font_size_override("font_size", 28)
	fallback_label.add_theme_color_override("font_color", Color(0.72, 0.90, 0.86, 0.88))
	parent.add_child(fallback_label)


func _format_caught_at(fish: Dictionary) -> String:
	var caught_total_minutes := float(fish.get("caught_at_total_game_minutes", -1.0))
	var current_total_minutes := _get_current_total_game_minutes()
	if caught_total_minutes >= 0.0 and current_total_minutes >= caught_total_minutes:
		return _format_elapsed_catch_time(current_total_minutes - caught_total_minutes)

	var caught_real_time := float(fish.get("caught_at_real_unix_time", 0.0))
	if caught_real_time > 0.0:
		var elapsed_real_minutes := maxf((Time.get_unix_time_from_system() - caught_real_time) / 60.0, 0.0)
		return _format_elapsed_catch_time(elapsed_real_minutes)

	var legacy_value := str(fish.get("caught_at", ""))
	if not legacy_value.is_empty():
		return legacy_value

	return ""


func _get_current_total_game_minutes() -> float:
	var time_manager: Node = main.get_node_or_null("/root/TimeManager") if main != null else null
	if time_manager == null:
		return -1.0

	var total_value = time_manager.get("total_game_minutes")
	if total_value != null:
		return float(total_value)

	var current_value = time_manager.get("current_game_minutes")
	if current_value != null:
		return float(current_value)

	return -1.0


func _format_elapsed_catch_time(elapsed_minutes: float) -> String:
	var minutes := maxi(roundi(elapsed_minutes), 0)
	if minutes <= 0:
		return "только что"
	if minutes < 60:
		return "%d %s назад" % [minutes, _plural_ru(minutes, "минуту", "минуты", "минут")]

	var hours := int(floor(float(minutes) / 60.0))
	var remaining_minutes := minutes % 60
	if hours < 24:
		if remaining_minutes <= 0:
			return "%d %s назад" % [hours, _plural_ru(hours, "час", "часа", "часов")]
		return "%d %s %d %s назад" % [
			hours,
			_plural_ru(hours, "час", "часа", "часов"),
			remaining_minutes,
			_plural_ru(remaining_minutes, "минуту", "минуты", "минут")
		]

	var days := int(floor(float(hours) / 24.0))
	return "%d %s назад" % [days, _plural_ru(days, "день", "дня", "дней")]


func _plural_ru(value: int, one: String, few: String, many: String) -> String:
	var abs_value := absi(value)
	var last_two := abs_value % 100
	if last_two >= 11 and last_two <= 14:
		return many
	var last_digit := abs_value % 10
	if last_digit == 1:
		return one
	if last_digit >= 2 and last_digit <= 4:
		return few
	return many


func _format_caught_bait(fish: Dictionary) -> String:
	var labels: Array = []
	var bait_name := str(fish.get("bait_name", fish.get("bait_label", "")))
	if not bait_name.is_empty():
		labels.append(bait_name)

	var bait_types_value = fish.get("bait_types", [])
	if bait_types_value is Array:
		for bait_type in bait_types_value:
			var label := _format_bait_type_name(str(bait_type))
			if not label.is_empty() and not labels.has(label):
				labels.append(label)

	var bait_type := str(fish.get("bait_type", ""))
	if not bait_type.is_empty():
		var bait_label := _format_bait_type_name(bait_type)
		if not bait_label.is_empty() and not labels.has(bait_label):
			labels.append(bait_label)

	var secondary_bait_type := str(fish.get("secondary_bait_type", ""))
	if not secondary_bait_type.is_empty():
		var secondary_label := _format_bait_type_name(secondary_bait_type)
		if not secondary_label.is_empty() and not labels.has(secondary_label):
			labels.append(secondary_label)

	return ", ".join(labels)


func _format_bait_type_name(bait_type: String) -> String:
	match bait_type.strip_edges().to_lower():
		"worm":
			return "червь"
		"bread":
			return "хлеб"
		"dough":
			return "тесто"
		"maggot":
			return "опарыш"
		"bloodworm":
			return "мотыль"
		"corn":
			return "кукуруза"
		_:
			return bait_type


func _format_caught_tackle(fish: Dictionary) -> String:
	var tackle_name := str(fish.get("tackle_name", fish.get("rod_name", "")))
	if not tackle_name.is_empty():
		return tackle_name

	var tackle_type := str(fish.get("tackle_type", fish.get("tackle_kind", ""))).strip_edges().to_lower()
	match tackle_type:
		"float":
			return "поплавочная"
		"feeder":
			return "фидерная"
		"spinning":
			return "спиннинг"
		"bottom":
			return "донная"
		_:
			return tackle_type


func _format_caught_location(fish: Dictionary) -> String:
	var waterbody_name := str(fish.get("waterbody_name", ""))
	var spot_name := str(fish.get("spot_name", ""))
	if not waterbody_name.is_empty() and not spot_name.is_empty():
		return "%s, %s" % [waterbody_name, spot_name]
	if not spot_name.is_empty():
		return spot_name
	return waterbody_name


func _get_buyer_offer_text(fish: Dictionary) -> String:
	var supplier_manager: Node = main.get_node_or_null("/root/SupplierManager")
	if supplier_manager == null or not supplier_manager.has_method("get_buyer_offer"):
		return "%s — %s" % [_get_best_supplier_name(fish), UIFormatters.format_money(float(InventoryManager.get_fish_sell_price(fish)))]

	var supplier_ids: Array = []
	if supplier_manager.has_method("get_primary_supplier_ids"):
		var value = supplier_manager.call("get_primary_supplier_ids")
		if value is Array:
			supplier_ids = value
	if supplier_ids.is_empty() and supplier_manager.has_method("get_available_suppliers"):
		var available = supplier_manager.call("get_available_suppliers")
		if available is Array:
			supplier_ids = available

	var offers: Array = []
	for supplier_id in supplier_ids:
		var offer_value = supplier_manager.call("get_buyer_offer", fish, str(supplier_id))
		if offer_value is Dictionary:
			var offer: Dictionary = offer_value
			if bool(offer.get("accepted", false)):
				offers.append({
					"name": str(offer.get("buyer_name", offer.get("supplier_name", supplier_id))),
					"price": int(offer.get("price", 0))
				})
	offers.sort_custom(func(a, b): return int(a.get("price", 0)) > int(b.get("price", 0)))

	var lines: Array = []
	for i in range(mini(offers.size(), 4)):
		var offer: Dictionary = offers[i]
		lines.append("%s — %s" % [str(offer.get("name", "-")), UIFormatters.format_money(float(offer.get("price", 0)))])
	if lines.is_empty():
		lines.append("%s — %s" % [_get_best_supplier_name(fish), UIFormatters.format_money(float(InventoryManager.get_fish_sell_price(fish)))])
	return "\n".join(lines)


func _apply_transparent_card_button_style(button: Button, accent: Color) -> void:
	button.add_theme_stylebox_override("normal", _make_flat_style(Color.TRANSPARENT, Color.TRANSPARENT, 16))
	button.add_theme_stylebox_override("hover", _make_flat_style(Color(accent.r, accent.g, accent.b, 0.055), Color(accent.r, accent.g, accent.b, 0.16), 16))
	button.add_theme_stylebox_override("pressed", _make_flat_style(Color(accent.r, accent.g, accent.b, 0.10), Color(accent.r, accent.g, accent.b, 0.24), 16))
	button.add_theme_stylebox_override("focus", _make_flat_style(Color.TRANSPARENT, Color(accent.r, accent.g, accent.b, 0.20), 16))


func _make_flat_style(bg: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1 if border.a > 0.0 else 0)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	return style


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


func _get_fish_status_id(fish: Dictionary) -> String:
	var status := str(fish.get("fish_status", ""))
	if status.is_empty():
		var status_system: Node = main.get_node_or_null("/root/FishStatusSystem")
		var fish_data: Dictionary = FishDatabase.get_fish(str(fish.get("id", fish.get("fish_id", ""))))
		if status_system != null and status_system.has_method("get_status") and not fish_data.is_empty():
			status = str(status_system.call("get_status", fish_data, float(fish.get("weight", 0.0))))
	if status.is_empty():
		return "undersized"
	return status


func _get_short_fish_status_title(fish: Dictionary) -> String:
	var status := str(fish.get("fish_status", ""))
	if status.is_empty():
		var status_system: Node = main.get_node_or_null("/root/FishStatusSystem")
		var fish_data: Dictionary = FishDatabase.get_fish(str(fish.get("id", fish.get("fish_id", ""))))
		if status_system != null and status_system.has_method("get_status") and not fish_data.is_empty():
			status = str(status_system.call("get_status", fish_data, float(fish.get("weight", 0.0))))
	return UIFormatters.format_fish_status(status)


func _get_rarity_title(fish: Dictionary) -> String:
	var fish_id := str(fish.get("id", fish.get("fish_id", "")))
	var fish_data: Dictionary = FishDatabase.get_fish(fish_id)
	var rarity_type := str(fish.get("rarityType", fish_data.get("rarityType", fish_data.get("rarity", "common"))))
	var price_calculator: Node = main.get_node_or_null("/root/FishPriceCalculator")
	if price_calculator != null and price_calculator.has_method("get_rarity_title"):
		return str(price_calculator.call("get_rarity_title", rarity_type))
	match rarity_type:
		"rare":
			return "Редкий вид"
		"legendary_species":
			return "Легендарный вид"
		_:
			return "Обычный вид"


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
