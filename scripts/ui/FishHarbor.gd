# Trading hub UI: sale offers, suppliers, contracts, market prices, and reputation.
extends Control

signal closed

const BACKGROUND_PATH := "res://assets/ui/backgrounds/fish_harbor.png"
const SECTION_SALE := "sale"
const SECTION_SUPPLIERS := "suppliers"
const SECTION_CONTRACTS := "contracts"
const SECTION_MARKET := "market"
const SECTION_REPUTATION := "reputation"
const REPUTATION_THRESHOLDS := [0, 50, 150, 350, 700, 1100]
const SHOW_ECONOMY_DEBUG_REPORT := false
const EconomyDebugReportScript := preload("res://scripts/dev/EconomyDebugReport.gd")
const MarketHistoryChartScript := preload("res://scripts/ui/MarketHistoryChart.gd")
const EmptyStateCardScript := preload("res://scripts/ui/components/EmptyStateCard.gd")
const PriceLabelScript := preload("res://scripts/ui/components/PriceLabel.gd")
const StatusBadgeScript := preload("res://scripts/ui/components/StatusBadge.gd")

var main
var current_section := SECTION_SALE
var selected_fish: Dictionary = {}
var selected_buyers: Dictionary = {}
var selected_bulk_buyer_id := ""

var background_texture: TextureRect
var dim_layer: ColorRect
var title_label: Label
var close_button: Button
var tabs_container: VBoxContainer
var section_title_label: Label
var section_scroll: ScrollContainer
var section_content: VBoxContainer
var sidebar_panel: Panel
var sidebar_scroll: ScrollContainer
var sidebar_content: VBoxContainer
var footer_panel: Panel
var buyer_popup_panel: Panel
var market_history_popup: Panel
var _ui_ready := false

func _ready() -> void:
	if main != null:
		_ensure_nodes()
	visible = false


func setup(main_ref) -> void:
	main = main_ref
	_ensure_nodes()


func open() -> void:
	if main != null and main.has_method("_is_catch_reward_open") and main._is_catch_reward_open():
		return

	_ensure_nodes()
	if main != null and main.has_method("open_modal"):
		main.open_modal("fish_harbor")
		main._active_nav_tab = "harbor"
	visible = true
	refresh()
	_maybe_print_economy_debug_report()
	if main != null and main.has_method("refresh_mobile_scroll_helper"):
		main.refresh_mobile_scroll_helper()
	if main != null and main.has_method("_refresh_bottom_nav_styles"):
		main._refresh_bottom_nav_styles()


func close(reset_nav: bool = true) -> void:
	_hide_buyer_popup()
	_close_market_history_popup()
	visible = false
	if main != null and main.has_method("close_modal"):
		main.close_modal("fish_harbor")
	if reset_nav and main != null:
		main._active_nav_tab = "fish"
		if main.has_method("_refresh_bottom_nav_styles"):
			main._refresh_bottom_nav_styles()
	closed.emit()


func _maybe_print_economy_debug_report() -> void:
	if not SHOW_ECONOMY_DEBUG_REPORT:
		return
	var report = EconomyDebugReportScript.new()
	if report != null and report.has_method("print_report"):
		report.print_report()


func is_open() -> bool:
	return visible


func refresh() -> void:
	_ensure_nodes()
	_hide_buyer_popup()
	if current_section != SECTION_MARKET:
		_close_market_history_popup()
	_sanitize_selection()
	_refresh_tabs()
	_clear_children(section_content)
	_clear_children(sidebar_content)
	section_title_label.text = _get_section_title(current_section)
	footer_panel.visible = current_section == SECTION_SALE
	if sidebar_panel != null:
		sidebar_panel.visible = true

	match current_section:
		SECTION_SALE:
			_build_sale_section()
			_build_buyers_sidebar()
			_refresh_sale_footer()
		SECTION_SUPPLIERS:
			_build_suppliers_section()
			_build_harbor_sidebar("Поставщики", "Репутация открывает новых покупателей и повышает бонус к цене.")
		SECTION_CONTRACTS:
			_build_contracts_section()
			_build_harbor_sidebar("Контракты", "Прогресс контрактов засчитывается при продаже подходящей рыбы нужному покупателю.")
		SECTION_MARKET:
			_build_market_section()
			_build_harbor_sidebar("Рынок", "Высокий спрос усиливает цену до расчёта бонусов покупателя и свежести.")
		SECTION_REPUTATION:
			_build_reputation_section()
			_build_harbor_sidebar("Репутация", "Каждая продажа приносит репутацию покупателю. Зачёт и трофей ценятся выше.")
	if main != null and main.has_method("refresh_mobile_scroll_helper"):
		main.refresh_mobile_scroll_helper()


func _ensure_nodes() -> void:
	if _ui_ready:
		return

	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 360

	background_texture = get_node_or_null("BackgroundTexture") as TextureRect
	if background_texture == null:
		background_texture = TextureRect.new()
		background_texture.name = "BackgroundTexture"
		add_child(background_texture)
	background_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_texture.texture = _load_background_texture()
	background_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

	dim_layer = get_node_or_null("DimLayer") as ColorRect
	if dim_layer == null:
		dim_layer = ColorRect.new()
		dim_layer.name = "DimLayer"
		add_child(dim_layer)
	dim_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim_layer.color = Color(0.0, 0.0, 0.0, 0.56)

	var margin := MarginContainer.new()
	margin.name = "HarborMargin"
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	var root := VBoxContainer.new()
	root.name = "HarborRoot"
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	var header := HBoxContainer.new()
	header.name = "HarborHeader"
	header.custom_minimum_size = Vector2(0.0, 54.0)
	header.add_theme_constant_override("separation", 12)
	root.add_child(header)

	var header_spacer_left := Control.new()
	header_spacer_left.custom_minimum_size = Vector2(160.0, 1.0)
	header.add_child(header_spacer_left)

	title_label = Label.new()
	title_label.name = "HarborTitle"
	title_label.text = "Рыбная гавань"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.add_theme_color_override("font_color", Color(0.95, 1.0, 0.94, 1.0))
	header.add_child(title_label)

	close_button = Button.new()
	close_button.name = "HarborCloseButton"
	close_button.text = "Закрыть"
	close_button.custom_minimum_size = Vector2(152.0, 44.0)
	_apply_button(close_button, false)
	close_button.pressed.connect(close)
	header.add_child(close_button)

	var body := HBoxContainer.new()
	body.name = "HarborBody"
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	root.add_child(body)

	var nav_panel := Panel.new()
	nav_panel.name = "HarborNavPanel"
	nav_panel.custom_minimum_size = Vector2(174.0, 0.0)
	nav_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_panel(nav_panel, true)
	body.add_child(nav_panel)

	tabs_container = VBoxContainer.new()
	tabs_container.name = "HarborTabs"
	tabs_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	tabs_container.offset_left = 10.0
	tabs_container.offset_top = 12.0
	tabs_container.offset_right = -10.0
	tabs_container.offset_bottom = -12.0
	tabs_container.add_theme_constant_override("separation", 9)
	nav_panel.add_child(tabs_container)

	var center := VBoxContainer.new()
	center.name = "HarborCenter"
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 10)
	body.add_child(center)

	var center_panel := Panel.new()
	center_panel.name = "HarborContentPanel"
	center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_panel.custom_minimum_size = Vector2(420.0, 0.0)
	_apply_panel(center_panel, true)
	center.add_child(center_panel)

	var center_inner := VBoxContainer.new()
	center_inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	center_inner.offset_left = 14.0
	center_inner.offset_top = 12.0
	center_inner.offset_right = -14.0
	center_inner.offset_bottom = -12.0
	center_inner.add_theme_constant_override("separation", 8)
	center_panel.add_child(center_inner)

	section_title_label = Label.new()
	section_title_label.name = "HarborSectionTitle"
	section_title_label.add_theme_font_size_override("font_size", 19)
	section_title_label.add_theme_color_override("font_color", Color(0.92, 1.0, 0.90, 1.0))
	center_inner.add_child(section_title_label)

	section_scroll = ScrollContainer.new()
	section_scroll.name = "HarborSectionScroll"
	section_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	section_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	section_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	center_inner.add_child(section_scroll)

	section_content = VBoxContainer.new()
	section_content.name = "HarborSectionContent"
	section_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section_content.add_theme_constant_override("separation", 9)
	section_scroll.add_child(section_content)

	footer_panel = Panel.new()
	footer_panel.name = "HarborSaleFooter"
	footer_panel.custom_minimum_size = Vector2(0.0, 104.0)
	footer_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_panel(footer_panel, true)
	center.add_child(footer_panel)

	sidebar_panel = Panel.new()
	sidebar_panel.name = "HarborSidebarPanel"
	sidebar_panel.custom_minimum_size = Vector2(230.0, 0.0)
	sidebar_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_panel(sidebar_panel, true)
	body.add_child(sidebar_panel)

	sidebar_scroll = ScrollContainer.new()
	sidebar_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	sidebar_scroll.offset_left = 10.0
	sidebar_scroll.offset_top = 12.0
	sidebar_scroll.offset_right = -10.0
	sidebar_scroll.offset_bottom = -12.0
	sidebar_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sidebar_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	sidebar_panel.add_child(sidebar_scroll)

	sidebar_content = VBoxContainer.new()
	sidebar_content.name = "HarborSidebarContent"
	sidebar_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_content.add_theme_constant_override("separation", 8)
	sidebar_scroll.add_child(sidebar_content)

	_ui_ready = true


func _refresh_tabs() -> void:
	_clear_children(tabs_container)
	var tabs := [
		[SECTION_SALE, "Продажа улова"],
		[SECTION_SUPPLIERS, "Поставщики"],
		[SECTION_CONTRACTS, "Контракты"],
		[SECTION_MARKET, "Цены рынка"],
		[SECTION_REPUTATION, "Репутация"]
	]
	for tab in tabs:
		var button := Button.new()
		button.text = str(tab[1])
		button.custom_minimum_size = Vector2(0.0, 48.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.clip_text = true
		_apply_button(button, str(tab[0]) == current_section)
		button.pressed.connect(_set_section.bind(str(tab[0])))
		tabs_container.add_child(button)


func _set_section(section_id: String) -> void:
	current_section = section_id
	refresh()


func _build_sale_section() -> void:
	var inventory: Array = _inventory_items()
	if inventory.is_empty():
		_add_empty_card(section_content, "Садок пуст", "Поймайте рыбу, и она появится здесь для продажи разным покупателям.")
		return

	for i in inventory.size():
		if typeof(inventory[i]) != TYPE_DICTIONARY:
			continue
		section_content.add_child(_create_sale_row(inventory[i], i))


func _create_sale_row(fish: Dictionary, fish_index: int) -> Panel:
	var prepared := _prepare_fish(fish)
	var best_buyer_id := _get_best_buyer(prepared)
	var buyer_id := str(selected_buyers.get(fish_index, best_buyer_id))
	var offer := _get_offer(prepared, buyer_id)
	if not bool(offer.get("accepted", false)):
		buyer_id = best_buyer_id
		selected_buyers[fish_index] = buyer_id
		offer = _get_offer(prepared, buyer_id)

	var selected := bool(selected_fish.get(fish_index, false))
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, 122.0 if selected else 104.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_card(card)

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 12.0
	row.offset_top = 10.0
	row.offset_right = -12.0
	row.offset_bottom = -10.0
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)

	var checkbox := CheckBox.new()
	checkbox.button_pressed = selected
	checkbox.custom_minimum_size = Vector2(36.0, 48.0)
	checkbox.toggled.connect(_on_fish_selection_toggled.bind(fish_index))
	row.add_child(checkbox)

	var fish_slot := Panel.new()
	fish_slot.custom_minimum_size = Vector2(76.0, 68.0)
	_apply_card(fish_slot, _get_status_color(str(prepared.get("fish_status", "undersized"))))
	row.add_child(fish_slot)

	var fish_texture := _get_fish_texture(str(prepared.get("id", "")))
	if fish_texture != null:
		var fish_image := TextureRect.new()
		fish_image.set_anchors_preset(Control.PRESET_FULL_RECT)
		fish_image.offset_left = 4.0
		fish_image.offset_top = 4.0
		fish_image.offset_right = -4.0
		fish_image.offset_bottom = -4.0
		fish_image.texture = fish_texture
		fish_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		fish_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		fish_slot.add_child(fish_image)
	else:
		var fallback := _make_label("><>", 20, Color(0.72, 0.90, 0.86, 0.88))
		fallback.set_anchors_preset(Control.PRESET_FULL_RECT)
		fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		fish_slot.add_child(fallback)

	var info := VBoxContainer.new()
	info.custom_minimum_size = Vector2(150.0, 0.0)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 3)
	row.add_child(info)

	var name_label := _make_label(str(prepared.get("name", "-")), 15, Color(0.96, 1.0, 0.94, 1.0))
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	info.add_child(name_label)

	var details_label := _make_label("%s  |  %s" % [
		UIFormatters.format_weight_kg(float(prepared.get("weight", 0.0))),
		_get_status_title(str(prepared.get("fish_status", "undersized")))
	], 12, _get_status_color(str(prepared.get("fish_status", "undersized"))))
	details_label.clip_text = true
	info.add_child(details_label)

	var rarity_label := _make_label(_get_rarity_title(str(prepared.get("rarityType", "common"))), 12, Color(0.68, 0.82, 0.78, 0.92))
	rarity_label.clip_text = true
	info.add_child(rarity_label)
	if selected:
		var price_hint := _make_label(_format_price_explanation(prepared, offer), 11, Color(0.72, 0.88, 0.82, 0.94))
		price_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		price_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_child(price_hint)

	var buyer_button := Button.new()
	buyer_button.name = "BuyerChoice_%d" % fish_index
	buyer_button.custom_minimum_size = Vector2(220.0, 68.0)
	buyer_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buyer_button.text = _get_buyer_button_text(prepared, buyer_id, best_buyer_id, offer)
	buyer_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	buyer_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	buyer_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_apply_buyer_button_style(buyer_button, buyer_id == best_buyer_id and bool(offer.get("accepted", false)))
	buyer_button.pressed.connect(_show_buyer_popup.bind(fish_index, prepared, buyer_button))
	row.add_child(buyer_button)

	var price_box := VBoxContainer.new()
	price_box.custom_minimum_size = Vector2(82.0, 0.0)
	price_box.add_theme_constant_override("separation", 2)
	row.add_child(price_box)

	var price_label := _make_label("", 15, Color(1.0, 0.84, 0.46, 1.0))
	PriceLabelScript.set_price(price_label, float(offer.get("price", 0)))
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	price_box.add_child(price_label)
	var multiplier_label := _make_label(UIFormatters.format_market_multiplier(float(offer.get("multiplier", 0.0))), 11, Color(0.76, 0.88, 0.84, 0.92))
	multiplier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	price_box.add_child(multiplier_label)
	if buyer_id == best_buyer_id and bool(offer.get("accepted", false)):
		var best_badge := StatusBadgeScript.create_badge("Лучшее", "best")
		best_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		price_box.add_child(best_badge)

	return card


func _get_buyer_button_text(fish: Dictionary, buyer_id: String, best_buyer_id: String, offer: Dictionary) -> String:
	var buyer_name := str(offer.get("supplier_name", offer.get("buyer_name", buyer_id)))
	var selected_line := "%s — %s" % [buyer_name, UIFormatters.format_money(float(offer.get("price", 0)))]
	if not bool(offer.get("accepted", false)):
		selected_line = "%s — %s" % [buyer_name, _short_rejection_reason(str(offer.get("reason", "не принимает")))]
	if buyer_id == best_buyer_id and bool(offer.get("accepted", false)):
		return "Лучшее: %s" % selected_line

	var best_offer := _get_offer(fish, best_buyer_id)
	var best_name := str(best_offer.get("supplier_name", best_offer.get("buyer_name", best_buyer_id)))
	if bool(best_offer.get("accepted", false)):
		return "%s\nЛучшее: %s — %s" % [selected_line, best_name, UIFormatters.format_money(float(best_offer.get("price", 0)))]
	return selected_line


func _format_price_explanation(fish: Dictionary, offer: Dictionary) -> String:
	if not bool(offer.get("accepted", false)):
		return "Цена: %s" % _short_rejection_reason(str(offer.get("reason", "покупатель не принимает")))
	var status := str(fish.get("fish_status", "undersized"))
	var quality_multiplier := float(offer.get("quality_multiplier", 1.0))
	var freshness_multiplier := float(offer.get("freshness_multiplier", 1.0))
	var buyer_multiplier := float(offer.get("buyer_multiplier", 1.0))
	return "%s x%.2f | свеж. x%.2f\nпокупатель x%.2f | итог %s" % [
		_get_status_title(status),
		quality_multiplier,
		freshness_multiplier,
		buyer_multiplier,
		UIFormatters.format_money(float(offer.get("price", 0)))
	]


func _show_buyer_popup(fish_index: int, fish: Dictionary, anchor: Control) -> void:
	_hide_buyer_popup()
	var prepared := _prepare_fish(fish)
	var best_buyer_id := _get_best_buyer(prepared)
	var selected_buyer_id := str(selected_buyers.get(fish_index, best_buyer_id))

	buyer_popup_panel = Panel.new()
	buyer_popup_panel.name = "BuyerChoicePopup"
	buyer_popup_panel.custom_minimum_size = Vector2(340.0, 0.0)
	buyer_popup_panel.size = Vector2(340.0, 404.0)
	buyer_popup_panel.z_index = 40
	buyer_popup_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	buyer_popup_panel.add_theme_stylebox_override("panel", _make_style(Color(0.014, 0.032, 0.036, 0.96), Color(0.58, 0.96, 0.90, 0.38), 12, 10, Color(0.0, 0.0, 0.0, 0.36)))
	add_child(buyer_popup_panel)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 10.0
	box.offset_top = 10.0
	box.offset_right = -10.0
	box.offset_bottom = -10.0
	box.add_theme_constant_override("separation", 7)
	buyer_popup_panel.add_child(box)

	var title := _make_label("Покупатели для: %s" % str(prepared.get("name", "-")), 13, Color(0.94, 1.0, 0.92, 1.0))
	title.clip_text = true
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.custom_minimum_size = Vector2(0.0, 26.0)
	box.add_child(title)

	for raw_buyer_id in _get_primary_supplier_ids():
		var buyer_id := str(raw_buyer_id)
		var offer := _get_offer(prepared, buyer_id)
		box.add_child(_create_buyer_popup_option(fish_index, buyer_id, offer, buyer_id == best_buyer_id, buyer_id == selected_buyer_id))

	var anchor_rect := anchor.get_global_rect()
	var popup_size := Vector2(340.0, 404.0)
	var viewport_size := get_viewport_rect().size
	var target_position := anchor_rect.position + Vector2(0.0, anchor_rect.size.y + 6.0)
	if target_position.y + popup_size.y > viewport_size.y - 16.0:
		target_position.y = anchor_rect.position.y - popup_size.y - 6.0
	target_position.x = clampf(target_position.x, 16.0, maxf(16.0, viewport_size.x - popup_size.x - 16.0))
	target_position.y = clampf(target_position.y, 16.0, maxf(16.0, viewport_size.y - popup_size.y - 16.0))
	buyer_popup_panel.global_position = target_position


func _create_buyer_popup_option(fish_index: int, buyer_id: String, offer: Dictionary, best: bool, selected: bool) -> Button:
	var accepted := bool(offer.get("accepted", false))
	var buyer_name := str(offer.get("supplier_name", offer.get("buyer_name", buyer_id)))
	var button := Button.new()
	button.custom_minimum_size = Vector2(0.0, 50.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.clip_text = false
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.disabled = not accepted
	if accepted:
		if best:
			button.text = "%s — %s\nЛучшее" % [buyer_name, UIFormatters.format_money(float(offer.get("price", 0)))]
		else:
			button.text = "%s — %s" % [buyer_name, UIFormatters.format_money(float(offer.get("price", 0)))]
		button.pressed.connect(_on_custom_buyer_selected.bind(fish_index, buyer_id))
	else:
		button.text = "Закрыто: %s\n%s" % [buyer_name, _short_rejection_reason(str(offer.get("reason", "не принимает")))]
	_apply_buyer_option_style(button, accepted, best, selected)
	return button


func _on_custom_buyer_selected(fish_index: int, buyer_id: String) -> void:
	selected_buyers[fish_index] = buyer_id
	selected_bulk_buyer_id = buyer_id
	_hide_buyer_popup()
	refresh()


func _hide_buyer_popup() -> void:
	if buyer_popup_panel == null:
		return
	if is_instance_valid(buyer_popup_panel):
		if buyer_popup_panel.get_parent() != null:
			buyer_popup_panel.get_parent().remove_child(buyer_popup_panel)
		buyer_popup_panel.queue_free()
	buyer_popup_panel = null


func _on_fish_selection_toggled(pressed: bool, fish_index: int) -> void:
	_hide_buyer_popup()
	selected_fish[fish_index] = pressed
	_refresh_sale_footer()


func _refresh_sale_footer() -> void:
	_clear_children(footer_panel)
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 16.0
	row.offset_top = 12.0
	row.offset_right = -16.0
	row.offset_bottom = -12.0
	row.add_theme_constant_override("separation", 14)
	footer_panel.add_child(row)

	var summary := _get_selected_sale_summary()
	var summary_box := VBoxContainer.new()
	summary_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	summary_box.alignment = BoxContainer.ALIGNMENT_CENTER
	summary_box.add_theme_constant_override("separation", 4)
	row.add_child(summary_box)

	var total_label := _make_label("", 18, Color(1.0, 0.88, 0.58, 1.0))
	PriceLabelScript.set_total_price(total_label, float(summary.get("price", 0)))
	total_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	summary_box.add_child(total_label)

	var selected_label := _make_label("Выбрано: %d | %s" % [
		int(summary.get("selected_count", summary.get("count", 0))),
		UIFormatters.format_weight_kg(float(summary.get("weight", 0.0)))
	], 12, Color(0.76, 0.88, 0.82, 0.94))
	selected_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	summary_box.add_child(selected_label)

	var buttons_box := HBoxContainer.new()
	buttons_box.custom_minimum_size = Vector2(410.0, 0.0)
	buttons_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	buttons_box.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons_box.add_theme_constant_override("separation", 10)
	row.add_child(buttons_box)

	var sell_selected_button := Button.new()
	sell_selected_button.text = "Продать выбранное"
	sell_selected_button.custom_minimum_size = Vector2(198.0, 46.0)
	sell_selected_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sell_selected_button.disabled = int(summary.get("count", 0)) <= 0 or int(summary.get("price", 0)) <= 0 or int(summary.get("count", 0)) < int(summary.get("selected_count", 0))
	_apply_button(sell_selected_button, true)
	sell_selected_button.pressed.connect(_on_sell_selected_pressed)
	buttons_box.add_child(sell_selected_button)

	var sell_all_summary := _get_sell_all_selected_buyer_summary()
	var sell_all_button := Button.new()
	sell_all_button.text = "Продать всё подходящее"
	sell_all_button.custom_minimum_size = Vector2(198.0, 46.0)
	sell_all_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sell_all_button.disabled = int(sell_all_summary.get("inventory_count", 0)) <= 0
	_apply_button(sell_all_button, false)
	sell_all_button.pressed.connect(_on_sell_all_pressed)
	buttons_box.add_child(sell_all_button)


func _get_selected_sale_summary() -> Dictionary:
	var count := 0
	var weight := 0.0
	var price := 0
	var requests: Array = []
	var inventory: Array = _inventory_items()
	var selected_count := 0
	for key in selected_fish.keys():
		var index := int(key)
		if not bool(selected_fish.get(key, false)) or index < 0 or index >= inventory.size():
			continue
		selected_count += 1
		var fish: Dictionary = _prepare_fish(inventory[index])
		var buyer_id := str(selected_buyers.get(index, _get_best_buyer(fish)))
		var offer := _get_offer(fish, buyer_id)
		if not bool(offer.get("accepted", false)):
			buyer_id = _get_best_buyer(fish)
			selected_buyers[index] = buyer_id
			offer = _get_offer(fish, buyer_id)
		if not bool(offer.get("accepted", false)):
			continue
		count += 1
		weight += float(fish.get("weight", 0.0))
		price += int(offer.get("price", 0))
		requests.append({"index": index, "buyer_id": buyer_id})
	return {"count": count, "selected_count": selected_count, "weight": weight, "price": price, "requests": requests}


func _get_sell_all_selected_buyer_summary() -> Dictionary:
	var count := 0
	var price := 0
	var rejected_count := 0
	var inventory_count := 0
	var buyer_id := selected_bulk_buyer_id
	if buyer_id.is_empty():
		return {
			"count": 0,
			"price": 0,
			"rejected_count": 0,
			"inventory_count": _inventory_items().size(),
			"buyer_id": ""
		}

	for item in _inventory_items():
		if typeof(item) != TYPE_DICTIONARY:
			continue
		inventory_count += 1
		var fish := _prepare_fish(item)
		var offer := _get_offer(fish, buyer_id)
		if bool(offer.get("accepted", false)):
			count += 1
			price += int(offer.get("price", 0))
		else:
			rejected_count += 1
	return {
		"count": count,
		"price": price,
		"rejected_count": rejected_count,
		"inventory_count": inventory_count,
		"buyer_id": buyer_id
	}


func _on_sell_selected_pressed() -> void:
	var summary := _get_selected_sale_summary()
	var requests: Array = summary.get("requests", [])
	if requests.is_empty():
		_show_notice("Выберите рыбу для продажи.", false)
		return
	var inventory_manager := _inventory_manager()
	var sales_service := _sales_service()
	var earned := 0
	if requests.size() == 1 and sales_service != null and sales_service.has_method("sell_fish_to_buyer_result"):
		_after_single_sale_result(_sell_single_selected_fish(requests[0], sales_service))
		return
	if requests.size() > 1 and sales_service != null and sales_service.has_method("sell_fish_batch_to_buyer_result"):
		_after_batch_sale_result(_sell_selected_fish_batch(requests, sales_service))
		return
	if sales_service != null and sales_service.has_method("sell_selected_fish"):
		earned = int(sales_service.call("sell_selected_fish", requests))
	elif inventory_manager != null and inventory_manager.has_method("sell_selected_fish"):
		earned = int(inventory_manager.call("sell_selected_fish", requests, {}))
	_after_sale(_format_sale_result_message("Продано выбранное", earned, _get_last_sale_summary()), earned > 0)


func _on_sell_all_pressed() -> void:
	var sales_service := _sales_service()
	if selected_bulk_buyer_id.is_empty():
		_show_notice("Выберите покупателя.", false)
		return
	if not _is_buyer_unlocked(selected_bulk_buyer_id):
		_show_notice("Покупатель пока недоступен: %s" % _short_rejection_reason(_get_buyer_lock_reason(selected_bulk_buyer_id, _get_supplier_data(selected_bulk_buyer_id))), false)
		return
	if sales_service == null or not sales_service.has_method("sell_fish_batch_to_buyer_result"):
		_show_notice("Продажа через гавань сейчас недоступна.", false)
		return

	var batch_data := _get_sell_all_matching_batch(selected_bulk_buyer_id)
	var batch: Array = batch_data.get("batch", [])
	var rejected_count := int(batch_data.get("rejected_count", 0))
	var first_rejection := str(batch_data.get("first_rejection", ""))
	if batch.is_empty():
		var message := "Нет подходящей рыбы для этого покупателя."
		if not first_rejection.is_empty():
			message += " %s" % _short_rejection_reason(first_rejection)
		_show_notice(message, false)
		return

	var result_value = sales_service.call("sell_fish_batch_to_buyer_result", batch, selected_bulk_buyer_id)
	if result_value is Dictionary:
		var result: Dictionary = result_value
		result["not_eligible_count"] = rejected_count
		_after_sell_all_matching_result(result)
		return

	_show_notice("Продажа подходящей рыбы не удалась.", false)


func _after_sale(message: String, success: bool) -> void:
	selected_fish.clear()
	selected_buyers.clear()
	if main != null:
		main.result_label.text = message
		if main.has_method("_update_ui"):
			main._update_ui()
	_show_notice(message, success)
	var save_manager: Node = get_node_or_null("/root/SaveManager")
	if save_manager != null and save_manager.has_method("save_game"):
		save_manager.call("save_game")
	refresh()


func _sell_selected_fish_batch(requests: Array, sales_service: Node) -> Dictionary:
	var batch: Array = []
	var inventory: Array = _inventory_items()
	for value in requests:
		if not (value is Dictionary):
			continue
		var entry: Dictionary = value
		var index := int(entry.get("index", entry.get("inventory_index", -1)))
		if index < 0 or index >= inventory.size() or typeof(inventory[index]) != TYPE_DICTIONARY:
			batch.append({
				"index": index,
				"buyer_id": str(entry.get("buyer_id", "")),
				"fish": {}
			})
			continue
		batch.append({
			"index": index,
			"buyer_id": str(entry.get("buyer_id", "")),
			"fish": (inventory[index] as Dictionary).duplicate(true)
		})

	var result_value = sales_service.call("sell_fish_batch_to_buyer_result", batch, "")
	if result_value is Dictionary:
		return result_value

	return {
		"success": false,
		"sold_count": 0,
		"failed_count": batch.size(),
		"total_price": 0,
		"message": "Продажа выбранной рыбы не удалась.",
		"errors": ["Продажа выбранной рыбы не удалась."],
		"sold_fish": [],
		"failed_fish": []
	}


func _after_batch_sale_result(result: Dictionary) -> void:
	var sold_count := int(result.get("sold_count", 0))
	var message := str(result.get("message", ""))
	if message.is_empty():
		message = _format_batch_sale_result_message(result)

	if sold_count > 0:
		selected_fish.clear()
		selected_buyers.clear()
		_restore_failed_batch_selection(result.get("failed_fish", []))

	if main != null:
		main.result_label.text = message
		if main.has_method("_update_ui"):
			main._update_ui()
	_show_notice(message, sold_count > 0)

	if sold_count > 0:
		var save_manager: Node = get_node_or_null("/root/SaveManager")
		if save_manager != null and save_manager.has_method("save_game"):
			save_manager.call("save_game")
	refresh()


func _get_sell_all_matching_batch(buyer_id: String) -> Dictionary:
	var batch: Array = []
	var rejected_count := 0
	var first_rejection := ""
	var inventory: Array = _inventory_items()

	for i in inventory.size():
		if typeof(inventory[i]) != TYPE_DICTIONARY:
			continue
		var fish: Dictionary = _prepare_fish(inventory[i])
		var offer := _get_offer(fish, buyer_id)
		if bool(offer.get("accepted", false)):
			batch.append({
				"index": i,
				"buyer_id": buyer_id,
				"fish": (inventory[i] as Dictionary).duplicate(true)
			})
		else:
			rejected_count += 1
			if first_rejection.is_empty():
				first_rejection = str(offer.get("reason", _get_buyer_rejection_reason(buyer_id, fish)))

	return {
		"batch": batch,
		"rejected_count": rejected_count,
		"first_rejection": first_rejection
	}


func _after_sell_all_matching_result(result: Dictionary) -> void:
	var sold_count := int(result.get("sold_count", 0))
	var message := _format_sell_all_matching_result_message(result)

	if sold_count > 0:
		selected_fish.clear()
		selected_buyers.clear()

	if main != null:
		main.result_label.text = message
		if main.has_method("_update_ui"):
			main._update_ui()
	_show_notice(message, sold_count > 0)

	if sold_count > 0:
		var save_manager: Node = get_node_or_null("/root/SaveManager")
		if save_manager != null and save_manager.has_method("save_game"):
			save_manager.call("save_game")
	refresh()


func _sell_single_selected_fish(request, sales_service: Node) -> Dictionary:
	var entry: Dictionary = request if request is Dictionary else {}
	var index := int(entry.get("index", entry.get("inventory_index", -1)))
	var inventory: Array = _inventory_items()
	if index < 0 or index >= inventory.size() or typeof(inventory[index]) != TYPE_DICTIONARY:
		return {
			"success": false,
			"message": "Рыба уже продана.",
			"error": "Рыба уже продана.",
			"price": 0,
			"total": 0,
			"buyer_id": str(entry.get("buyer_id", "")),
			"buyer_name": "",
			"fish": {}
		}

	var fish: Dictionary = (inventory[index] as Dictionary).duplicate(true)
	var prepared := _prepare_fish(fish)
	var buyer_id := str(entry.get("buyer_id", ""))
	if buyer_id.is_empty():
		buyer_id = _get_best_buyer(prepared)

	var result_value = sales_service.call("sell_fish_to_buyer_result", fish, buyer_id)
	if result_value is Dictionary:
		return result_value

	return {
		"success": false,
		"message": "Продажа не удалась.",
		"error": "Продажа не удалась.",
		"price": 0,
		"total": 0,
		"buyer_id": buyer_id,
		"buyer_name": buyer_id,
		"fish": fish
	}


func _after_single_sale_result(result: Dictionary) -> void:
	var success := bool(result.get("success", false))
	var message := _format_single_sale_result_message(result)
	if success:
		selected_fish.clear()
		selected_buyers.clear()

	if main != null:
		main.result_label.text = message
		if main.has_method("_update_ui"):
			main._update_ui()
	_show_notice(message, success)

	if success:
		var save_manager: Node = get_node_or_null("/root/SaveManager")
		if save_manager != null and save_manager.has_method("save_game"):
			save_manager.call("save_game")
	refresh()


func _get_last_sale_summary() -> Dictionary:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_last_sale_summary"):
		var service_value = sales_service.call("get_last_sale_summary")
		if service_value is Dictionary:
			return service_value
	var inventory_manager := _inventory_manager()
	if inventory_manager != null and inventory_manager.has_method("get_last_sale_summary"):
		var inventory_value = inventory_manager.call("get_last_sale_summary")
		if inventory_value is Dictionary:
			return inventory_value
	return {}


func _format_sale_result_message(title: String, earned: int, summary: Dictionary) -> String:
	if earned <= 0:
		var error := str(summary.get("error", "Нет подходящей рыбы для продажи."))
		return error if not error.is_empty() else "Нет подходящей рыбы для продажи."

	var sold_count := int(summary.get("sold_count", 0))
	var sale_total := int(summary.get("sale_total", earned))
	var contract_reward := int(summary.get("contract_reward_total", maxi(earned - sale_total, 0)))
	var prefix := title
	if sold_count > 0:
		prefix = "%s: %d шт." % [title, sold_count]

	var message := "%s | +%s" % [prefix, UIFormatters.format_money(float(earned))]
	if contract_reward > 0:
		message += " (контракты +%s)" % UIFormatters.format_money(float(contract_reward))

	var completed_contracts = summary.get("completed_contracts", [])
	if completed_contracts is Array and not completed_contracts.is_empty():
		message += "\nЗакрыто контрактов: %d" % completed_contracts.size()
	return message


func _format_single_sale_result_message(result: Dictionary) -> String:
	var success := bool(result.get("success", false))
	if not success:
		var error := str(result.get("message", result.get("error", "Продажа не удалась.")))
		return error if not error.is_empty() else "Продажа не удалась."

	var fish_value = result.get("fish", {})
	var fish_name := "Рыба"
	if fish_value is Dictionary:
		fish_name = str((fish_value as Dictionary).get("name", fish_name))
	var buyer_name := str(result.get("buyer_name", result.get("supplier_name", result.get("buyer_id", "покупатель"))))
	var total := int(result.get("total", result.get("price", 0)))
	var contract_reward := int(result.get("contract_reward", 0))
	var message := "%s → %s: +%s" % [fish_name, buyer_name, UIFormatters.format_money(float(total))]
	if contract_reward > 0:
		message += " (контракты +%s)" % UIFormatters.format_money(float(contract_reward))

	var summary_value = result.get("summary", {})
	if summary_value is Dictionary:
		var completed_contracts = (summary_value as Dictionary).get("completed_contracts", [])
		if completed_contracts is Array and not completed_contracts.is_empty():
			message += "\nЗакрыто контрактов: %d" % completed_contracts.size()
	return message


func _format_batch_sale_result_message(result: Dictionary) -> String:
	var sold_count := int(result.get("sold_count", 0))
	var failed_count := int(result.get("failed_count", 0))
	var total := int(result.get("total_price", result.get("total", 0)))
	var contract_reward := int(result.get("contract_reward_total", 0))
	if sold_count <= 0:
		var errors = result.get("errors", [])
		if errors is Array and not errors.is_empty():
			return str(errors[0])
		return "Выбранную рыбу не удалось продать."

	var message := "Продано выбранное: %d шт. | +%s" % [
		sold_count,
		UIFormatters.format_money(float(total))
	]
	if contract_reward > 0:
		message += " (контракты +%s)" % UIFormatters.format_money(float(contract_reward))
	if failed_count > 0:
		message += "\nНе продано: %d" % failed_count
	return message


func _format_sell_all_matching_result_message(result: Dictionary) -> String:
	var sold_count := int(result.get("sold_count", 0))
	var total := int(result.get("total_price", result.get("total", 0)))
	var buyer_name := str(result.get("buyer_name", result.get("buyer_id", "покупатель")))
	var not_eligible_count := int(result.get("not_eligible_count", 0))
	var failed_count := int(result.get("failed_count", 0))
	if sold_count <= 0:
		var errors = result.get("errors", [])
		if errors is Array and not errors.is_empty():
			return str(errors[0])
		return "Нет подходящей рыбы для этого покупателя."

	var message := "Продано %d рыб покупателю %s. Получено: %s" % [
		sold_count,
		buyer_name,
		UIFormatters.format_money(float(total))
	]
	var skipped := not_eligible_count + failed_count
	if skipped > 0:
		message += "\nНе подошло: %d" % skipped
	return message


func _restore_failed_batch_selection(failed_results) -> void:
	if not (failed_results is Array):
		return

	for value in failed_results:
		if not (value is Dictionary):
			continue
		var failed: Dictionary = value
		var fish_value = failed.get("fish", {})
		if not (fish_value is Dictionary):
			continue
		var index := _find_inventory_index_for_selection(fish_value)
		if index < 0:
			continue
		selected_fish[index] = true
		var buyer_id := str(failed.get("requested_buyer_id", failed.get("buyer_id", "")))
		if not buyer_id.is_empty():
			selected_buyers[index] = buyer_id


func _find_inventory_index_for_selection(fish_value) -> int:
	if not (fish_value is Dictionary):
		return -1
	var fish: Dictionary = fish_value
	var inventory: Array = _inventory_items()
	for i in inventory.size():
		if typeof(inventory[i]) != TYPE_DICTIONARY:
			continue
		if _fish_matches_selection(inventory[i], fish):
			return i
	return -1


func _fish_matches_selection(left_value, right: Dictionary) -> bool:
	if typeof(left_value) != TYPE_DICTIONARY:
		return false
	var left: Dictionary = left_value
	if str(left.get("id", left.get("fish_id", ""))) != str(right.get("id", right.get("fish_id", ""))):
		return false
	if abs(float(left.get("weight", 0.0)) - float(right.get("weight", 0.0))) > 0.001:
		return false
	if int(left.get("price", 0)) != int(right.get("price", 0)):
		return false
	return true


func _build_buyers_sidebar() -> void:
	_add_sidebar_title("Покупатели")
	_add_selected_buyer_summary_card()
	var summary := _get_selected_sale_summary()
	var selected_count := int(summary.get("selected_count", summary.get("count", 0)))
	var inventory: Array = _inventory_items()
	for buyer_id in _get_primary_supplier_ids():
		var buyer_key := str(buyer_id)
		var supplier := _get_supplier_data(buyer_key)
		var total := 0
		var accepted := 0
		var first_rejection := ""
		var unlocked := _is_buyer_unlocked(buyer_key)
		if selected_count > 0:
			for key in selected_fish.keys():
				var index := int(key)
				if not bool(selected_fish.get(key, false)) or index < 0 or index >= inventory.size():
					continue
				var prepared_fish := _prepare_fish(inventory[index])
				var offer := _get_offer(prepared_fish, buyer_key)
				if bool(offer.get("accepted", false)):
					accepted += 1
					total += int(offer.get("price", 0))
				elif first_rejection.is_empty():
					first_rejection = str(offer.get("reason", _get_buyer_rejection_reason(buyer_key, prepared_fish)))
		var lines: Array = ["x%.2f" % float(supplier.get("price_multiplier", 1.0))]
		var locked := not unlocked
		if locked:
			lines.append("Закрыто: %s" % _short_rejection_reason(_get_buyer_lock_reason(buyer_key, supplier)))
		elif selected_count > 0:
			lines.append("Принимает: %d/%d" % [accepted, selected_count])
			if accepted > 0:
				lines.append("Итог: %s" % UIFormatters.format_money(float(total)))
			elif not first_rejection.is_empty():
				lines.append(_short_rejection_reason(first_rejection))
			else:
				lines.append("Нет подходящей рыбы")
		else:
			lines.append(str(supplier.get("accepts_text", "")))
		if selected_bulk_buyer_id == buyer_key:
			lines.append("Выбран для продажи всего")
		_add_buyer_sidebar_card(
			str(supplier.get("name", buyer_key)),
			lines,
			selected_bulk_buyer_id == buyer_key or buyer_key == _get_best_sidebar_buyer(),
			locked,
			buyer_key
		)
	_add_sidebar_card("Цены обновятся через", _get_market_refresh_text(), false)


func _add_selected_buyer_summary_card() -> void:
	if selected_bulk_buyer_id.is_empty():
		_add_sidebar_card("Продажа всего", "Выберите покупателя ниже.\nКнопка продаст только подходящую рыбу.", false)
		return

	var supplier := _get_supplier_data(selected_bulk_buyer_id)
	if supplier.is_empty():
		_add_sidebar_card("Покупатель", "Неизвестный покупатель.", false)
		return

	var unlocked := _is_buyer_unlocked(selected_bulk_buyer_id)
	var summary := _get_buyer_inventory_summary(selected_bulk_buyer_id)
	var accepted_count := int(summary.get("accepted_count", 0))
	var inventory_count := int(summary.get("inventory_count", 0))
	var total_price := int(summary.get("total_price", 0))
	var rejected_count := int(summary.get("rejected_count", 0))
	var lines: Array = []
	lines.append(str(supplier.get("description", "")))
	lines.append("Бонус: x%.2f | принимает: %s" % [
		float(supplier.get("price_multiplier", 1.0)),
		_short_supplier_accepts(selected_bulk_buyer_id, str(supplier.get("accepts_text", "")))
	])
	if unlocked:
		lines.append("Подходит из садка: %d/%d | %s" % [
			accepted_count,
			inventory_count,
			UIFormatters.format_money(float(total_price))
		])
		if rejected_count > 0:
			lines.append("Не подходит: %d" % rejected_count)
	else:
		lines.append("Недоступен: %s" % _short_rejection_reason(_get_buyer_lock_reason(selected_bulk_buyer_id, supplier)))
	_add_selected_buyer_card(str(supplier.get("name", selected_bulk_buyer_id)), lines, unlocked)


func _add_selected_buyer_card(title: String, lines: Array, unlocked: bool) -> void:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, 160.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_card(card, Color(0.64, 0.96, 0.86, 1.0) if unlocked else Color(0.70, 0.58, 0.48, 0.88))
	sidebar_content.add_child(card)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 10.0
	box.offset_top = 9.0
	box.offset_right = -10.0
	box.offset_bottom = -9.0
	box.add_theme_constant_override("separation", 4)
	card.add_child(box)

	var title_label_node := _make_label("Выбран: %s" % title, 13, Color(0.95, 1.0, 0.92, 1.0) if unlocked else Color(0.78, 0.72, 0.66, 0.92))
	title_label_node.clip_text = true
	title_label_node.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(title_label_node)

	for i in mini(lines.size(), 4):
		var line := _make_label(str(lines[i]), 11, Color(0.76, 0.90, 0.84, 0.94) if unlocked else Color(0.62, 0.66, 0.62, 0.88))
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_child(line)


func _get_buyer_inventory_summary(buyer_id: String) -> Dictionary:
	var inventory: Array = _inventory_items()
	var accepted_count := 0
	var rejected_count := 0
	var total_price := 0
	var first_rejection := ""

	for item in inventory:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var prepared := _prepare_fish(item)
		var offer := _get_offer(prepared, buyer_id)
		if bool(offer.get("accepted", false)):
			accepted_count += 1
			total_price += int(offer.get("price", 0))
		else:
			rejected_count += 1
			if first_rejection.is_empty():
				first_rejection = str(offer.get("reason", _get_buyer_rejection_reason(buyer_id, prepared)))

	return {
		"accepted_count": accepted_count,
		"rejected_count": rejected_count,
		"inventory_count": inventory.size(),
		"total_price": total_price,
		"first_rejection": first_rejection
	}


func _get_best_sidebar_buyer() -> String:
	var summary := _get_selected_sale_summary()
	var requests: Array = summary.get("requests", [])
	if requests.size() != 1:
		return ""
	return str(requests[0].get("buyer_id", ""))


func _build_suppliers_section() -> void:
	var items: Array = []
	var supplier_manager := _supplier_manager()
	if supplier_manager != null and supplier_manager.has_method("get_supplier_summary"):
		var value = supplier_manager.call("get_supplier_summary", 0)
		if value is Array:
			items = value
	for item in items:
		if typeof(item) == TYPE_DICTIONARY:
			section_content.add_child(_create_supplier_card(item))


func _create_supplier_card(item: Dictionary) -> Panel:
	var unlocked := bool(item.get("unlocked", true))
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, 166.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_card(card, Color(0.58, 0.86, 0.80, 0.94) if unlocked else Color(0.48, 0.56, 0.54, 0.76))

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 14.0
	box.offset_top = 10.0
	box.offset_right = -14.0
	box.offset_bottom = -10.0
	box.add_theme_constant_override("separation", 4)
	card.add_child(box)

	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)

	var title := _make_label(str(item.get("name", "-")), 17, Color(0.95, 1.0, 0.92, 1.0) if unlocked else Color(0.68, 0.76, 0.72, 0.88))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.clip_text = true
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	header.add_child(title)

	if not unlocked:
		var lock_label := _make_label("Закрыто", 12, Color(1.0, 0.72, 0.48, 0.96))
		lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		header.add_child(lock_label)

	var rep := _get_reputation_info(str(item.get("id", "")))
	var rep_label := _make_label("%s | уровень %d | бонус +%d%%" % [
		str(rep.get("title", "Новичок")),
		int(rep.get("level", 0)),
		roundi((float(item.get("price_multiplier", 1.0)) - 1.0) * 100.0)
	], 12, Color(0.72, 0.90, 0.82, 0.96) if unlocked else Color(0.56, 0.66, 0.62, 0.84))
	box.add_child(rep_label)

	var description := _make_label(str(item.get("description", "")), 12, Color(0.78, 0.88, 0.82, 0.94) if unlocked else Color(0.58, 0.66, 0.62, 0.84))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(description)

	var accepts := _short_supplier_accepts(str(item.get("id", "")), str(item.get("accepts_text", "")))
	var contracts := _short_supplier_contracts(str(item.get("id", "")), str(item.get("contracts_text", "")))
	var unlock_text := "Открыт: сразу" if unlocked else str(item.get("unlock_text", "Откроется: репутация %d" % int(item.get("min_reputation", 0))))
	var body := _make_label("Принимает: %s\nКонтракты: %s\n%s" % [accepts, contracts, unlock_text], 12, Color(0.78, 0.88, 0.82, 0.95) if unlocked else Color(0.58, 0.66, 0.62, 0.86))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(body)
	return card


func _build_contracts_section() -> void:
	_add_section_subtitle("Активные контракты")
	var active := _get_active_contracts()
	if active.is_empty():
		_add_empty_card(section_content, "Нет активных контрактов", "Новые заявки появятся после обновления игрового дня.")
	else:
		for contract in active:
			if typeof(contract) == TYPE_DICTIONARY:
				section_content.add_child(_create_contract_card(contract, false))

	_add_section_subtitle("Доступные контракты")
	_add_empty_card(section_content, "Доступные заявки", "Новые заявки появляются автоматически. Выполняйте активные через продажу улова.")

	_add_section_subtitle("Выполненные контракты")
	var completed := _get_completed_contracts()
	if completed.is_empty():
		_add_empty_card(section_content, "Пока нет выполненных контрактов", "Первый закрытый контракт появится здесь.")
	else:
		var start: int = maxi(completed.size() - 8, 0)
		for i in range(completed.size() - 1, start - 1, -1):
			if typeof(completed[i]) == TYPE_DICTIONARY:
				section_content.add_child(_create_contract_card(completed[i], true))


func _create_contract_card(contract: Dictionary, completed: bool) -> Panel:
	var card := _make_content_card(152.0)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 14.0
	box.offset_top = 10.0
	box.offset_right = -14.0
	box.offset_bottom = -10.0
	box.add_theme_constant_override("separation", 5)
	card.add_child(box)

	var title := _make_label(_format_contract_title(contract), 15, Color(0.95, 1.0, 0.92, 1.0))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.custom_minimum_size = Vector2(0.0, 38.0)
	box.add_child(title)

	var progress_text := _format_contract_progress(contract)
	var details := _make_label("Рыба: %s | Поставщик: %s\nПрогресс: %s\nНаграда: %s | Репутация +%d%s" % [
		str(contract.get("fish_name", "-")),
		str(contract.get("supplier_name", "Покупатель")),
		progress_text,
		UIFormatters.format_money(float(contract.get("reward_money", 0))),
		int(contract.get("reward_reputation", 0)),
		_get_contract_deadline_text(contract, completed)
	], 12, Color(0.78, 0.88, 0.82, 0.95))
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(details)

	var progress_bar := ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(0.0, 8.0)
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_bar.max_value = 1.0
	progress_bar.value = _get_contract_progress_ratio(contract)
	progress_bar.show_percentage = false
	_apply_progress_bar_style(progress_bar, Color(0.52, 0.92, 0.72, 1.0) if not completed else Color(0.58, 0.82, 1.0, 1.0))
	box.add_child(progress_bar)

	var status := _make_label("Выполнен" if completed else "Выполняется через продажу улова", 11, Color(0.58, 0.90, 1.0, 0.94) if completed else Color(0.70, 0.84, 0.80, 0.90))
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	box.add_child(status)
	return card


func _build_market_section() -> void:
	var timer := _make_label("Цены обновятся через: %s" % _get_market_refresh_text(), 14, Color(0.74, 0.92, 0.88, 0.98))
	timer.custom_minimum_size = Vector2(0.0, 26.0)
	section_content.add_child(timer)

	var market_manager: Node = get_node_or_null("/root/DynamicMarketManager")
	var items: Array = []
	if market_manager != null and market_manager.has_method("get_market_snapshot"):
		var value = market_manager.call("get_market_snapshot", 30)
		if value is Array:
			items = value
	if items.is_empty():
		_add_empty_card(section_content, "Рынок пока пуст", "Данные спроса появятся после инициализации рынка.")
		return

	for item in items:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var fish_id := str(item.get("fish_id", ""))
		var today := float(item.get("demand", 1.0))
		var yesterday := _get_previous_market_demand(fish_id)
		var trend_key := _get_market_trend_key(today, yesterday)
		var color := _get_market_trend_color(trend_key)
		section_content.add_child(_create_market_card(fish_id, str(item.get("fish_name", fish_id)), today, yesterday, trend_key, color))


func _create_market_card(fish_id: String, fish_name: String, today: float, yesterday: float, trend_key: String, trend_color: Color) -> Button:
	var card := Button.new()
	card.text = ""
	card.custom_minimum_size = Vector2(0.0, 88.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.focus_mode = Control.FOCUS_NONE
	_apply_market_card_style(card, trend_color)
	card.pressed.connect(_open_market_history_popup.bind(fish_id, fish_name, today, yesterday))

	var title := _make_label(fish_name, 16, Color(0.95, 1.0, 0.92, 1.0))
	title.position = Vector2(14.0, 10.0)
	title.size = Vector2(300.0, 24.0)
	title.clip_text = true
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	card.add_child(title)
	var data := _make_label("Сегодня: x%.2f\nВчера: x%.2f" % [today, yesterday], 13, Color(0.78, 0.90, 0.84, 0.96))
	data.position = Vector2(14.0, 40.0)
	data.size = Vector2(320.0, 34.0)
	data.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(data)
	var trend_icon := _create_market_trend_icon(trend_key, trend_color)
	trend_icon.anchor_left = 1.0
	trend_icon.anchor_right = 1.0
	trend_icon.offset_left = -56.0
	trend_icon.offset_top = 24.0
	trend_icon.offset_right = -22.0
	trend_icon.offset_bottom = 58.0
	card.add_child(trend_icon)

	var hint := _make_label("История", 11, Color(0.60, 0.78, 0.74, 0.88))
	hint.anchor_left = 1.0
	hint.anchor_right = 1.0
	hint.offset_left = -106.0
	hint.offset_top = 58.0
	hint.offset_right = -20.0
	hint.offset_bottom = 78.0
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(hint)
	return card


func _get_market_trend_key(today: float, yesterday: float) -> String:
	if today > yesterday + 0.03:
		return "up"
	if today < yesterday - 0.03:
		return "down"
	return "flat"


func _get_market_trend_color(trend_key: String) -> Color:
	match trend_key:
		"up":
			return Color(0.48, 0.94, 0.66, 1.0)
		"down":
			return Color(0.96, 0.58, 0.46, 1.0)
		_:
			return Color(0.62, 0.82, 0.82, 0.96)


func _create_market_trend_icon(trend_key: String, trend_color: Color) -> Panel:
	var icon := Panel.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.add_theme_stylebox_override("panel", _make_style(
		Color(trend_color.r * 0.12, trend_color.g * 0.12, trend_color.b * 0.12, 0.74),
		Color(trend_color.r, trend_color.g, trend_color.b, 0.42),
		17,
		5,
		Color(trend_color.r, trend_color.g, trend_color.b, 0.12)
	))

	var symbol := "→"
	if trend_key == "up":
		symbol = "↑"
	elif trend_key == "down":
		symbol = "↓"
	var label := _make_label(symbol, 22, trend_color)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.add_child(label)
	return icon


func _build_reputation_section() -> void:
	var items: Array = []
	var supplier_manager := _supplier_manager()
	if supplier_manager != null and supplier_manager.has_method("get_supplier_summary"):
		var value = supplier_manager.call("get_supplier_summary", 0)
		if value is Array:
			items = value
	for item in items:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var supplier_id := str(item.get("id", ""))
		var rep := _get_reputation_info(supplier_id)
		var current := int(rep.get("reputation", 0))
		var level := int(rep.get("level", 0))
		var next_threshold := _get_next_reputation_threshold(level)
		var previous_threshold := _get_previous_reputation_threshold(level)
		var progress: float = 1.0 if next_threshold <= previous_threshold else clampf(float(current - previous_threshold) / float(next_threshold - previous_threshold), 0.0, 1.0)
		section_content.add_child(_create_reputation_card(item, rep, current, next_threshold, progress))


func _create_reputation_card(item: Dictionary, rep: Dictionary, current: int, next_threshold: int, progress: float) -> Panel:
	var card := _make_content_card(140.0)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 14.0
	box.offset_top = 10.0
	box.offset_right = -14.0
	box.offset_bottom = -10.0
	box.add_theme_constant_override("separation", 5)
	card.add_child(box)

	var title := _make_label(str(item.get("name", "-")), 16, Color(0.95, 1.0, 0.92, 1.0))
	title.clip_text = true
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(title)
	var rank := _make_label("Ранг: %s | уровень %d" % [str(rep.get("title", "Новичок")), int(rep.get("level", 0))], 12, Color(0.76, 0.90, 0.84, 0.96))
	box.add_child(rank)
	var progress_label := _make_label("Прогресс: %d / %d" % [current, next_threshold], 12, Color(0.68, 0.82, 0.78, 0.92))
	box.add_child(progress_label)
	var progress_bar := ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(0.0, 8.0)
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_bar.max_value = 1.0
	progress_bar.value = progress
	progress_bar.show_percentage = false
	_apply_progress_bar_style(progress_bar, Color(0.52, 0.92, 0.72, 1.0))
	box.add_child(progress_bar)
	var bonus := _make_label("Бонус: +%d%% к цене\nДальше: выше цена и новые контракты" % roundi((float(item.get("price_multiplier", 1.0)) - 1.0) * 100.0), 12, Color(0.78, 0.88, 0.82, 0.95))
	bonus.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(bonus)
	return card


func _build_harbor_sidebar(title: String, body: String) -> void:
	_add_sidebar_title(title)
	var inventory: Array = _inventory_items()
	_add_sidebar_card("Садок", "%d рыб\n%.2f кг" % [inventory.size(), _get_inventory_weight()], false)
	_add_sidebar_card("Деньги", _format_player_money(), false)
	_add_sidebar_card("Подсказка", _short_sidebar_hint(title, body), false)


func _sanitize_selection() -> void:
	var inventory: Array = _inventory_items()
	for key in selected_fish.keys():
		var index := int(key)
		if index < 0 or index >= inventory.size():
			selected_fish.erase(key)
	for i in inventory.size():
		if typeof(inventory[i]) != TYPE_DICTIONARY:
			continue
		var prepared := _prepare_fish(inventory[i])
		var buyer_id := str(selected_buyers.get(i, ""))
		if buyer_id.is_empty() or not bool(_get_offer(prepared, buyer_id).get("accepted", false)):
			selected_buyers[i] = _get_best_buyer(prepared)


func _prepare_fish(fish: Dictionary) -> Dictionary:
	var inventory_manager := _inventory_manager()
	if inventory_manager != null and inventory_manager.has_method("_prepare_sale_catch_data"):
		var prepared_value = inventory_manager.call("_prepare_sale_catch_data", fish)
		if prepared_value is Dictionary:
			return prepared_value
	var result := fish.duplicate(true)
	var fish_data := _get_fish_data(str(result.get("id", "")))
	if not fish_data.is_empty() and not result.has("fish_status"):
		var status_system := _fish_status_system()
		if status_system != null and status_system.has_method("get_status"):
			result["fish_status"] = str(status_system.call("get_status", fish_data, float(result.get("weight", 0.0))))
	return result


func _get_offer(fish: Dictionary, buyer_id: String) -> Dictionary:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_offer_for_buyer"):
		var service_value = sales_service.call("get_offer_for_buyer", fish, buyer_id)
		if service_value is Dictionary:
			return service_value

	var inventory_manager := _inventory_manager()
	if inventory_manager != null and inventory_manager.has_method("get_buyer_offer"):
		var value = inventory_manager.call("get_buyer_offer", fish, buyer_id)
		if value is Dictionary:
			return value
	return {}


func _get_best_buyer(fish: Dictionary) -> String:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_best_buyer_for_fish"):
		return str(sales_service.call("get_best_buyer_for_fish", fish))

	var inventory_manager := _inventory_manager()
	if inventory_manager != null and inventory_manager.has_method("get_best_buyer_for_fish"):
		return str(inventory_manager.call("get_best_buyer_for_fish", fish))
	return "local_market"


func _get_primary_supplier_ids() -> Array:
	var supplier_manager := _supplier_manager()
	if supplier_manager != null and supplier_manager.has_method("get_primary_supplier_ids"):
		var value = supplier_manager.call("get_primary_supplier_ids")
		if value is Array:
			return value
	return ["local_market", "fish_shop", "restaurant", "wholesale_buyer", "collector", "export_company"]


func _get_reputation_info(supplier_id: String) -> Dictionary:
	var reputation_system: Node = get_node_or_null("/root/ReputationSystem")
	if reputation_system == null:
		return {"reputation": 0, "level": 0, "title": "Новичок"}
	return {
		"reputation": int(reputation_system.call("get_reputation", supplier_id)) if reputation_system.has_method("get_reputation") else 0,
		"level": int(reputation_system.call("get_reputation_level", supplier_id)) if reputation_system.has_method("get_reputation_level") else 0,
		"title": str(reputation_system.call("get_reputation_title", supplier_id)) if reputation_system.has_method("get_reputation_title") else "Новичок"
	}


func _is_buyer_unlocked(buyer_id: String) -> bool:
	var access_service := _buyer_access_service()
	if access_service != null and access_service.has_method("is_buyer_unlocked"):
		return bool(access_service.call("is_buyer_unlocked", buyer_id))

	var supplier_manager := _supplier_manager()
	if supplier_manager != null and supplier_manager.has_method("is_buyer_unlocked"):
		return bool(supplier_manager.call("is_buyer_unlocked", buyer_id))
	if supplier_manager != null and supplier_manager.has_method("get_supplier"):
		var supplier_value = supplier_manager.call("get_supplier", buyer_id)
		if supplier_value is Dictionary:
			return int((supplier_value as Dictionary).get("min_reputation", 0)) <= 0
	return buyer_id == "local_market"


func _get_supplier_data(buyer_id: String) -> Dictionary:
	var supplier_manager := _supplier_manager()
	if supplier_manager != null and supplier_manager.has_method("get_supplier"):
		var supplier_value = supplier_manager.call("get_supplier", buyer_id)
		if supplier_value is Dictionary:
			return supplier_value
	return {}


func _get_buyer_lock_reason(buyer_id: String, supplier: Dictionary) -> String:
	var access_service := _buyer_access_service()
	if access_service != null and access_service.has_method("get_buyer_lock_reason"):
		return str(access_service.call("get_buyer_lock_reason", buyer_id))
	return str(supplier.get("unlock_text", "Покупатель пока недоступен"))


func _get_buyer_rejection_reason(buyer_id: String, fish: Dictionary) -> String:
	var access_service := _buyer_access_service()
	if access_service != null and access_service.has_method("get_buyer_rejection_reason"):
		return str(access_service.call("get_buyer_rejection_reason", buyer_id, fish))

	var supplier_manager := _supplier_manager()
	if supplier_manager != null and supplier_manager.has_method("get_rejection_reason"):
		return str(supplier_manager.call("get_rejection_reason", fish, buyer_id))
	return "Этот покупатель не принимает такую рыбу"


func _short_supplier_accepts(supplier_id: String, fallback: String) -> String:
	match supplier_id:
		"local_market":
			return "все виды"
		"fish_shop":
			return "обычные и редкие виды"
		"restaurant":
			return "зачётную рыбу"
		"wholesale_buyer":
			return "обычную от 0.4 кг"
		"collector":
			return "редкие виды и трофеи"
		"export_company":
			return "зачётные редкие виды"
		_:
			return fallback


func _short_supplier_contracts(supplier_id: String, fallback: String) -> String:
	match supplier_id:
		"local_market":
			return "вес / количество"
		"fish_shop":
			return "ходовая рыба"
		"restaurant":
			return "зачётные поставки"
		"wholesale_buyer":
			return "копчёные партии"
		"collector":
			return "редкости / трофеи"
		"export_company":
			return "редкие заявки"
		_:
			return fallback


func _get_active_contracts() -> Array:
	var contract_manager: Node = get_node_or_null("/root/ContractManager")
	if contract_manager != null and contract_manager.has_method("get_active_contracts"):
		var value = contract_manager.call("get_active_contracts")
		if value is Array:
			return value
	return []


func _get_completed_contracts() -> Array:
	var contract_manager: Node = get_node_or_null("/root/ContractManager")
	if contract_manager == null:
		return []
	if contract_manager.has_method("get_completed_contracts"):
		var value = contract_manager.call("get_completed_contracts")
		if value is Array:
			return value
	var raw_value = contract_manager.get("completed_contracts")
	if raw_value is Array:
		return raw_value
	return []


func _format_contract_progress(contract: Dictionary) -> String:
	if str(contract.get("type", "weight")) == "weight":
		return "%.1f / %.1f кг" % [
			float(contract.get("progress_weight_kg", 0.0)),
			float(contract.get("target_weight_kg", 0.0))
		]
	return "%d / %d шт." % [
		int(contract.get("progress_count", 0)),
		int(contract.get("target_count", 0))
	]


func _format_contract_title(contract: Dictionary) -> String:
	var contract_type := str(contract.get("type", "weight"))
	var fish_name := str(contract.get("fish_name", "-"))
	match contract_type:
		"trophy_count":
			var count := int(contract.get("target_count", 0))
			return "Доставить %d %s: %s" % [count, _plural_ru(count, "трофей", "трофея", "трофеев"), fish_name]
		"count":
			return "Поймать %d зачётных: %s" % [int(contract.get("target_count", 0)), fish_name]
		"weight":
			return "Поставить %.1f кг: %s" % [float(contract.get("target_weight_kg", 0.0)), fish_name]
		_:
			return str(contract.get("title", "Контракт"))


func _get_contract_progress_ratio(contract: Dictionary) -> float:
	if str(contract.get("type", "weight")) == "weight":
		var target_weight := maxf(float(contract.get("target_weight_kg", 0.0)), 0.01)
		return clampf(float(contract.get("progress_weight_kg", 0.0)) / target_weight, 0.0, 1.0)
	var target_count := maxi(int(contract.get("target_count", 0)), 1)
	return clampf(float(int(contract.get("progress_count", 0))) / float(target_count), 0.0, 1.0)


func _get_contract_deadline_text(contract: Dictionary, completed: bool) -> String:
	if completed:
		return ""
	var expires_day := int(contract.get("expires_day_index", -1))
	if expires_day < 0:
		return ""
	var days_left: int = maxi(expires_day - _get_day_index() + 1, 0)
	return " | срок: %d д." % days_left


func _plural_ru(count: int, one: String, few: String, many: String) -> String:
	var value: int = absi(count)
	var last_two: int = value % 100
	if last_two >= 11 and last_two <= 14:
		return many
	var last: int = value % 10
	if last == 1:
		return one
	if last >= 2 and last <= 4:
		return few
	return many


func _get_previous_market_demand(fish_id: String) -> float:
	var market_manager: Node = get_node_or_null("/root/DynamicMarketManager")
	if market_manager == null or not market_manager.has_method("get_price_history"):
		return 1.0
	var history_value = market_manager.call("get_price_history", fish_id, 2)
	if not (history_value is Array):
		return 1.0
	var history: Array = history_value
	if history.is_empty() or typeof(history[0]) != TYPE_DICTIONARY:
		return 1.0
	return float((history[0] as Dictionary).get("demand", 1.0))


func _open_market_history_popup(fish_id: String, fish_name: String, today: float, yesterday: float) -> void:
	_close_market_history_popup()

	market_history_popup = Panel.new()
	market_history_popup.name = "MarketHistoryOverlay"
	market_history_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	market_history_popup.z_index = 80
	var overlay_style := StyleBoxFlat.new()
	overlay_style.bg_color = Color(0.0, 0.0, 0.0, 0.20)
	market_history_popup.add_theme_stylebox_override("panel", overlay_style)
	add_child(market_history_popup)
	market_history_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	market_history_popup.offset_left = 0.0
	market_history_popup.offset_top = 0.0
	market_history_popup.offset_right = 0.0
	market_history_popup.offset_bottom = 0.0

	var viewport_size := get_viewport_rect().size
	var dialog_size := Vector2(maxf(360.0, minf(440.0, viewport_size.x - 56.0)), maxf(322.0, minf(372.0, viewport_size.y - 44.0)))
	var dialog := Panel.new()
	dialog.name = "MarketHistoryDialog"
	dialog.size = dialog_size
	dialog.position = (viewport_size - dialog_size) * 0.5
	dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	dialog.add_theme_stylebox_override("panel", _make_style(Color(0.018, 0.040, 0.044, 0.96), Color(0.55, 0.92, 0.88, 0.42), 12, 10, Color(0.0, 0.0, 0.0, 0.38)))
	market_history_popup.add_child(dialog)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 16.0
	box.offset_top = 14.0
	box.offset_right = -16.0
	box.offset_bottom = -14.0
	box.add_theme_constant_override("separation", 8)
	dialog.add_child(box)

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0.0, 34.0)
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 0)
	header.add_child(title_box)

	var title := _make_label("История цен", 18, Color(0.95, 1.0, 0.92, 1.0))
	title_box.add_child(title)
	var subtitle := _make_label(fish_name, 12, Color(0.70, 0.88, 0.82, 0.94))
	subtitle.clip_text = true
	subtitle.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title_box.add_child(subtitle)

	var top_close := Button.new()
	top_close.text = "Закрыть"
	top_close.custom_minimum_size = Vector2(104.0, 34.0)
	_apply_button(top_close, false)
	top_close.pressed.connect(_close_market_history_popup)
	header.add_child(top_close)

	var history := _get_market_history(fish_id, 7, today, yesterday)
	var values := _get_market_history_values(history)
	var stats := _get_market_history_stats(values, today)

	var stats_label := _make_label("Сегодня: x%.2f   Вчера: x%.2f\nМин: x%.2f   Макс: x%.2f   Среднее: x%.2f" % [
		today,
		yesterday,
		float(stats.get("min", today)),
		float(stats.get("max", today)),
		float(stats.get("avg", today))
	], 13, Color(0.80, 0.92, 0.86, 0.98))
	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats_label.custom_minimum_size = Vector2(0.0, 42.0)
	box.add_child(stats_label)

	var chart := MarketHistoryChartScript.new()
	chart.custom_minimum_size = Vector2(0.0, 132.0)
	chart.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chart.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chart.set_history(history)
	box.add_child(chart)

	var axis := HBoxContainer.new()
	axis.custom_minimum_size = Vector2(0.0, 18.0)
	box.add_child(axis)
	var left_axis := _make_label("7 дней", 11, Color(0.56, 0.72, 0.70, 0.90))
	left_axis.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	axis.add_child(left_axis)
	var right_axis := _make_label("Сегодня", 11, Color(0.56, 0.72, 0.70, 0.90))
	right_axis.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right_axis.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	axis.add_child(right_axis)

	var advice := _make_label(_get_market_history_advice(today, float(stats.get("avg", today))), 13, Color(0.88, 1.0, 0.90, 0.96))
	advice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advice.custom_minimum_size = Vector2(0.0, 36.0)
	box.add_child(advice)


func _close_market_history_popup() -> void:
	if market_history_popup == null:
		return
	if is_instance_valid(market_history_popup):
		if market_history_popup.get_parent() != null:
			market_history_popup.get_parent().remove_child(market_history_popup)
		market_history_popup.queue_free()
	market_history_popup = null


func _get_market_history(fish_id: String, days: int, today: float, yesterday: float) -> Array:
	var history: Array = []
	var market_manager: Node = get_node_or_null("/root/DynamicMarketManager")
	if market_manager != null and market_manager.has_method("get_price_history"):
		var value = market_manager.call("get_price_history", fish_id, days)
		if value is Array:
			for entry in value:
				if typeof(entry) == TYPE_DICTIONARY:
					history.append((entry as Dictionary).duplicate(true))
	if history.is_empty():
		history.append({"day_index": _get_day_index() - 1, "demand": yesterday})
		history.append({"day_index": _get_day_index(), "demand": today})
	elif history.size() == 1:
		history.insert(0, {"day_index": _get_day_index() - 1, "demand": yesterday})
	if history.size() > days:
		history = history.slice(history.size() - days, history.size())
	return history


func _get_market_history_values(history: Array) -> Array:
	var values: Array = []
	for entry in history:
		if typeof(entry) == TYPE_DICTIONARY:
			values.append(float((entry as Dictionary).get("demand", 1.0)))
		elif typeof(entry) == TYPE_FLOAT or typeof(entry) == TYPE_INT:
			values.append(float(entry))
	return values


func _get_market_history_stats(values: Array, fallback: float) -> Dictionary:
	if values.is_empty():
		return {"min": fallback, "max": fallback, "avg": fallback}
	var min_value := float(values[0])
	var max_value := float(values[0])
	var total := 0.0
	for value in values:
		var demand := float(value)
		min_value = minf(min_value, demand)
		max_value = maxf(max_value, demand)
		total += demand
	return {
		"min": min_value,
		"max": max_value,
		"avg": total / float(values.size())
	}


func _get_market_history_advice(today: float, average: float) -> String:
	if today >= average * 1.15:
		return "Спрос высокий — выгодно продавать."
	if today <= average * 0.85:
		return "Спрос ниже среднего — можно подождать."
	return "Спрос стабильный."


func _get_market_refresh_text() -> String:
	var time_manager: Node = get_node_or_null("/root/TimeManager")
	if time_manager == null:
		return "23:47"
	var current_minutes := float(time_manager.get("current_game_minutes"))
	var remaining := int(ceil(1440.0 - fposmod(current_minutes, 1440.0)))
	var hours := int(remaining / 60)
	var minutes := remaining % 60
	return "%02d:%02d" % [hours, minutes]


func _get_day_index() -> int:
	var time_manager: Node = get_node_or_null("/root/TimeManager")
	if time_manager != null:
		return maxi(int(time_manager.get("day_index")), 1)
	return 1


func _get_inventory_weight() -> float:
	var total := 0.0
	for fish in _inventory_items():
		if typeof(fish) == TYPE_DICTIONARY:
			total += float((fish as Dictionary).get("weight", 0.0))
	return total


func _get_next_reputation_threshold(level: int) -> int:
	var index: int = clampi(level + 1, 0, REPUTATION_THRESHOLDS.size() - 1)
	return int(REPUTATION_THRESHOLDS[index])


func _get_previous_reputation_threshold(level: int) -> int:
	var index: int = clampi(level, 0, REPUTATION_THRESHOLDS.size() - 1)
	return int(REPUTATION_THRESHOLDS[index])


func _short_sidebar_hint(title: String, body: String) -> String:
	if title == "Поставщики":
		return "Репутация открывает новых покупателей."
	if title == "Контракты":
		return "Продавайте нужную рыбу покупателю."
	if title == "Рынок":
		return "Спрос меняет цену каждый день."
	if title == "Репутация":
		return "Продажи повышают цену и контракты."
	var text := body.strip_edges()
	if text.length() > 74:
		return text.substr(0, 71) + "..."
	return text


func _short_rejection_reason(reason: String) -> String:
	var text := reason.strip_edges()
	if text.is_empty():
		return "не принимает"
	var reputation_prefix := "Откроется при репутации "
	if text.begins_with(reputation_prefix):
		return "Репутация %s" % text.substr(reputation_prefix.length())
	if text.contains("зач") or text.contains("статус: зач"):
		return "Только зачёт"
	if text.contains("троф"):
		return "Только трофеи"
	if text.contains("редк"):
		return "Только редкие виды"
	if text.contains("вид не принимается"):
		return "Не принимает этот вид"
	if text.length() > 28:
		return text.substr(0, 27) + "..."
	return text


func _get_sale_status_text(selected: bool, buyer_id: String, best_buyer_id: String, offer: Dictionary) -> String:
	if not selected:
		return "Не выбрано"
	if not bool(offer.get("accepted", false)):
		return "Не принимается"
	if buyer_id == best_buyer_id:
		return "Лучшее предложение"
	return "Готово к продаже"


func _get_sale_status_color(selected: bool, buyer_id: String, best_buyer_id: String, offer: Dictionary) -> Color:
	if not selected:
		return Color(0.62, 0.68, 0.66, 0.86)
	if not bool(offer.get("accepted", false)):
		return Color(0.96, 0.60, 0.52, 1.0)
	if buyer_id == best_buyer_id:
		return Color(0.42, 0.78, 1.0, 1.0)
	return Color(0.54, 0.94, 0.66, 1.0)


func _get_status_title(status: String) -> String:
	return UIFormatters.format_fish_status(status)


func _get_status_color(status: String) -> Color:
	match status:
		"keeper":
			return Color(0.56, 0.95, 0.68, 1.0)
		"trophy":
			return Color(1.0, 0.78, 0.36, 1.0)
		_:
			return Color(0.70, 0.78, 0.76, 0.95)


func _get_rarity_title(rarity_type: String) -> String:
	var price_calculator: Node = get_node_or_null("/root/FishPriceCalculator")
	if price_calculator != null and price_calculator.has_method("get_rarity_title"):
		return str(price_calculator.call("get_rarity_title", rarity_type))
	match rarity_type:
		"rare":
			return "Редкий вид"
		"legendary_species":
			return "Легендарный вид"
		_:
			return "Обычный вид"


func _get_section_title(section_id: String) -> String:
	match section_id:
		SECTION_SUPPLIERS:
			return "Поставщики"
		SECTION_CONTRACTS:
			return "Контракты"
		SECTION_MARKET:
			return "Цены рынка"
		SECTION_REPUTATION:
			return "Репутация"
		_:
			return "Продажа улова"


func _get_fish_texture(fish_id: String) -> Texture2D:
	if main != null and main.has_method("_get_reward_fish_texture"):
		var texture = main._get_reward_fish_texture(fish_id)
		if texture is Texture2D:
			return texture
	var fish := _get_fish_data(fish_id)
	var path := str(fish.get("icon_path", ""))
	if not path.is_empty() and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _load_background_texture() -> Texture2D:
	var image = Image.load_from_file(BACKGROUND_PATH)
	if image:
		return ImageTexture.create_from_image(image)
	if ResourceLoader.exists(BACKGROUND_PATH):
		return load(BACKGROUND_PATH) as Texture2D
	return null


func _add_section_subtitle(text: String) -> void:
	var label := _make_label(text, 15, Color(0.90, 1.0, 0.88, 1.0))
	label.custom_minimum_size = Vector2(0.0, 26.0)
	section_content.add_child(label)


func _add_sidebar_title(text: String) -> void:
	var label := _make_label(text, 16, Color(0.95, 1.0, 0.92, 1.0))
	label.custom_minimum_size = Vector2(0.0, 26.0)
	sidebar_content.add_child(label)


func _add_sidebar_card(title: String, body: String, active: bool) -> void:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, 82.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_card(card, Color(0.54, 0.94, 0.98, 1.0) if active else Color(0.62, 0.76, 0.72, 0.92))
	sidebar_content.add_child(card)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 12.0
	box.offset_top = 8.0
	box.offset_right = -12.0
	box.offset_bottom = -8.0
	box.add_theme_constant_override("separation", 3)
	card.add_child(box)

	var title_label_node := _make_label(title, 13, Color(0.94, 1.0, 0.92, 1.0))
	title_label_node.clip_text = true
	title_label_node.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(title_label_node)
	var body_label := _make_label(body, 11, Color(0.76, 0.86, 0.80, 0.94))
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(body_label)


func _add_buyer_sidebar_card(title: String, lines: Array, active: bool, locked: bool, buyer_id: String = "") -> void:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, 102.0 if lines.size() >= 3 else 90.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_STOP if not buyer_id.is_empty() and not locked else Control.MOUSE_FILTER_PASS
	if not buyer_id.is_empty() and not locked:
		card.gui_input.connect(_on_buyer_sidebar_card_gui_input.bind(buyer_id))
	var accent := Color(0.54, 0.94, 0.98, 1.0) if active else Color(0.62, 0.76, 0.72, 0.92)
	if locked:
		accent = Color(0.50, 0.58, 0.56, 0.70)
	_apply_card(card, accent)
	sidebar_content.add_child(card)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 12.0
	box.offset_top = 8.0
	box.offset_right = -12.0
	box.offset_bottom = -8.0
	box.add_theme_constant_override("separation", 3)
	card.add_child(box)

	var title_label_node := _make_label(title, 13, Color(0.94, 1.0, 0.92, 1.0) if not locked else Color(0.62, 0.70, 0.68, 0.86))
	title_label_node.clip_text = true
	title_label_node.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(title_label_node)

	for i in lines.size():
		var line := _make_label(str(lines[i]), 11, Color(0.76, 0.90, 0.84, 0.94) if not locked else Color(0.54, 0.62, 0.60, 0.82))
		line.clip_text = i == 0
		line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(line)


func _on_buyer_sidebar_card_gui_input(event: InputEvent, buyer_id: String) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event != null and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		_select_bulk_buyer(buyer_id)
		get_viewport().set_input_as_handled()
		return

	var touch_event := event as InputEventScreenTouch
	if touch_event != null and touch_event.pressed:
		_select_bulk_buyer(buyer_id)
		get_viewport().set_input_as_handled()


func _select_bulk_buyer(buyer_id: String) -> void:
	if buyer_id.is_empty():
		return
	selected_bulk_buyer_id = buyer_id
	refresh()


func _add_empty_card(parent: Control, title: String, body: String) -> void:
	var card := EmptyStateCardScript.new()
	card.custom_minimum_size = Vector2(0.0, 92.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.setup(title, body)
	parent.add_child(card)


func _make_content_card(height: float) -> Panel:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0.0, height)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_card(card)
	return card


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _apply_panel(panel: Panel, strong: bool = false) -> void:
	var bg := Color(0.018, 0.038, 0.043, 0.78 if strong else 0.62)
	var border := Color(0.55, 0.88, 0.86, 0.24)
	panel.add_theme_stylebox_override("panel", _make_style(bg, border, 10, 7, Color(0.0, 0.0, 0.0, 0.32)))


func _apply_card(panel: Panel, accent: Color = Color(0.58, 0.86, 0.80, 0.94)) -> void:
	panel.add_theme_stylebox_override(
		"panel",
		_make_style(Color(0.020, 0.046, 0.050, 0.70), Color(accent.r, accent.g, accent.b, 0.22), 8, 4, Color(0.0, 0.0, 0.0, 0.18))
	)


func _apply_button(button: BaseButton, active: bool) -> void:
	if main != null and main.has_method("_apply_button_style") and button is Button:
		main._apply_button_style(button, main.STYLE_PRIMARY_BUTTON if active else main.STYLE_SECONDARY_BUTTON)
	else:
		var normal := _make_style(Color(0.045, 0.095, 0.092, 0.92), Color(0.50, 0.86, 0.82, 0.34), 8, 3, Color(0.0, 0.0, 0.0, 0.18))
		button.add_theme_stylebox_override("normal", normal)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))


func _apply_buyer_button_style(button: Button, best: bool) -> void:
	var accent := Color(0.48, 1.0, 0.88, 1.0) if best else Color(0.58, 0.86, 0.80, 0.94)
	button.add_theme_stylebox_override("normal", _make_style(Color(0.024, 0.050, 0.052, 0.82), Color(accent.r, accent.g, accent.b, 0.34), 9, 4, Color(0.0, 0.0, 0.0, 0.18)))
	button.add_theme_stylebox_override("hover", _make_style(Color(0.040, 0.095, 0.086, 0.94), Color(accent.r, accent.g, accent.b, 0.58), 9, 7, Color(accent.r, accent.g, accent.b, 0.12)))
	button.add_theme_stylebox_override("pressed", _make_style(Color(0.032, 0.130, 0.112, 0.98), Color(accent.r, accent.g, accent.b, 0.68), 9, 2, Color.TRANSPARENT))
	button.add_theme_stylebox_override("focus", _make_style(Color(0.044, 0.110, 0.096, 0.94), Color(accent.r, accent.g, accent.b, 0.70), 9, 5, Color(accent.r, accent.g, accent.b, 0.10)))
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))


func _apply_buyer_option_style(button: Button, accepted: bool, best: bool, selected: bool) -> void:
	var accent := Color(0.45, 0.98, 0.88, 1.0) if best else Color(0.62, 0.82, 0.78, 0.94)
	if selected:
		accent = Color(0.88, 1.0, 0.70, 1.0)
	if not accepted:
		accent = Color(0.48, 0.56, 0.54, 0.78)
	var bg_alpha := 0.90 if accepted else 0.48
	button.add_theme_stylebox_override("normal", _make_style(Color(0.028, 0.054, 0.056, bg_alpha), Color(accent.r, accent.g, accent.b, 0.30), 8, 2, Color.TRANSPARENT))
	button.add_theme_stylebox_override("hover", _make_style(Color(0.050, 0.112, 0.100, 0.96), Color(accent.r, accent.g, accent.b, 0.54), 8, 5, Color(accent.r, accent.g, accent.b, 0.10)))
	button.add_theme_stylebox_override("pressed", _make_style(Color(0.040, 0.145, 0.125, 0.98), Color(accent.r, accent.g, accent.b, 0.62), 8, 1, Color.TRANSPARENT))
	button.add_theme_stylebox_override("disabled", _make_style(Color(0.024, 0.034, 0.036, 0.60), Color(accent.r, accent.g, accent.b, 0.16), 8, 1, Color.TRANSPARENT))
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", Color(0.92, 1.0, 0.92, 1.0) if accepted else Color(0.58, 0.66, 0.64, 0.88))
	button.add_theme_color_override("font_disabled_color", Color(0.54, 0.62, 0.60, 0.88))


func _apply_market_card_style(button: Button, accent: Color) -> void:
	button.add_theme_stylebox_override("normal", _make_style(Color(0.020, 0.046, 0.050, 0.72), Color(accent.r, accent.g, accent.b, 0.24), 8, 4, Color(0.0, 0.0, 0.0, 0.18)))
	button.add_theme_stylebox_override("hover", _make_style(Color(0.034, 0.074, 0.074, 0.86), Color(accent.r, accent.g, accent.b, 0.46), 8, 6, Color(accent.r, accent.g, accent.b, 0.10)))
	button.add_theme_stylebox_override("pressed", _make_style(Color(0.028, 0.108, 0.096, 0.92), Color(accent.r, accent.g, accent.b, 0.56), 8, 2, Color.TRANSPARENT))
	button.add_theme_stylebox_override("focus", _make_style(Color(0.034, 0.086, 0.082, 0.90), Color(accent.r, accent.g, accent.b, 0.54), 8, 4, Color(accent.r, accent.g, accent.b, 0.08)))


func _apply_progress_bar_style(progress_bar: ProgressBar, accent: Color) -> void:
	progress_bar.add_theme_stylebox_override("background", _make_progress_style(Color(0.018, 0.030, 0.032, 0.82), Color(0.48, 0.66, 0.62, 0.22), 4, 1))
	progress_bar.add_theme_stylebox_override("fill", _make_progress_style(Color(accent.r, accent.g, accent.b, 0.78), Color(accent.r, accent.g, accent.b, 0.0), 4, 0))


func _make_progress_style(bg: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	return style


func _make_style(bg: Color, border: Color, radius: int, shadow_size: int, shadow: Color) -> StyleBoxFlat:
	if main != null and main.has_method("_make_panel_style"):
		return main._make_panel_style(bg, border, radius, shadow_size, shadow)
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_size = shadow_size
	style.shadow_color = shadow
	style.content_margin_left = 10.0
	style.content_margin_top = 8.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 8.0
	return style


func _clear_children(node: Node) -> void:
	if node == null:
		return
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


func _show_notice(message: String, success: bool) -> void:
	if main != null and main.has_method("_show_toast"):
		main._show_toast(message, success)


func _inventory_manager() -> Node:
	return get_node_or_null("/root/InventoryManager")


func _sales_service() -> Node:
	return get_node_or_null("/root/SalesService")


func _supplier_manager() -> Node:
	return get_node_or_null("/root/SupplierManager")


func _buyer_access_service() -> Node:
	return get_node_or_null("/root/BuyerAccessService")


func _fish_status_system() -> Node:
	return get_node_or_null("/root/FishStatusSystem")


func _inventory_items() -> Array:
	var inventory_manager := _inventory_manager()
	if inventory_manager == null:
		return []
	var value = inventory_manager.get("inventory")
	if value is Array:
		return value
	return []


func _get_fish_data(fish_id: String) -> Dictionary:
	var fish_database: Node = get_node_or_null("/root/FishDatabase")
	if fish_database != null and fish_database.has_method("get_fish"):
		var value = fish_database.call("get_fish", fish_id)
		if value is Dictionary:
			return value
	return {}


func _format_player_money() -> String:
	var player_data: Node = get_node_or_null("/root/PlayerData")
	if player_data != null:
		return UIFormatters.format_money(float(player_data.get("money")))
	return UIFormatters.format_money(0.0)
