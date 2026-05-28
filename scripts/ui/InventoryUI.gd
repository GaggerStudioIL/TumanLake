# Handles the inventory window: categories, item list, and item details.
extends RefCounted

var main
var theme
const INVENTORY_ITEMS_PER_PAGE := 8
var _texture_cache: Dictionary = {}

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
	_ensure_inventory_action_nodes()
	_ensure_inventory_pager_nodes()

func open() -> void:
	if main._is_catch_reward_open():
		return

	main.open_modal("inventory")
	main._active_nav_tab = "inventory"
	main.inventory_backdrop.visible = true
	main.inventory_panel.visible = true
	refresh()
	main._refresh_bottom_nav_styles()

func close() -> void:
	if main == null or main.inventory_panel == null:
		return

	main.inventory_panel.visible = false
	main.inventory_backdrop.visible = false
	main.close_modal("inventory")
	main._active_nav_tab = "fish"
	main._refresh_bottom_nav_styles()

func refresh() -> void:
	_update_inventory_ui()

func is_open() -> bool:
	return main != null and main.inventory_panel != null and main.inventory_panel.visible

func _ensure_inventory_action_nodes() -> void:
	if main == null or main.inventory_panel == null:
		return

	if main.inventory_repair_button == null:
		main.inventory_repair_button = Button.new()
		main.inventory_repair_button.name = "InventoryRepairButton"
		main.inventory_repair_button.text = "Починить"
		main.inventory_repair_button.focus_mode = Control.FOCUS_NONE
		main.inventory_repair_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.inventory_repair_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.inventory_panel.add_child(main.inventory_repair_button)

	if main.inventory_discard_button == null:
		main.inventory_discard_button = Button.new()
		main.inventory_discard_button.name = "InventoryDiscardButton"
		main.inventory_discard_button.text = "Выбросить"
		main.inventory_discard_button.focus_mode = Control.FOCUS_NONE
		main.inventory_discard_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.inventory_discard_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.inventory_panel.add_child(main.inventory_discard_button)

func _update_inventory_ui() -> void:
	main._visible_inventory_items = _get_visible_inventory_items()
	main.inventory_title_label.text = "Инвентарь"
	main.inventory_tackle_label.text = _get_current_tackle_inventory_text()
	main.inventory_item_list.clear()

	var total_count: int = main._visible_inventory_items.size()
	var page_count: int = max(ceili(float(total_count) / float(INVENTORY_ITEMS_PER_PAGE)), 1)
	main._inventory_page = clampi(main._inventory_page, 0, page_count - 1)

	var page_start: int = main._inventory_page * INVENTORY_ITEMS_PER_PAGE
	var page_end: int = mini(page_start + INVENTORY_ITEMS_PER_PAGE, total_count)
	var selected_index := -1

	for i in total_count:
		var item: Dictionary = main._visible_inventory_items[i]
		if str(item.get("id", "")) == main._selected_inventory_item_id:
			selected_index = i
			break

	if selected_index < page_start or selected_index >= page_end:
		if page_start < page_end:
			selected_index = page_start
			main._selected_inventory_item_id = str(main._visible_inventory_items[selected_index].get("id", ""))
		else:
			selected_index = -1
			main._selected_inventory_item_id = ""

	for i in range(page_start, page_end):
		var item: Dictionary = main._visible_inventory_items[i]
		main.inventory_item_list.add_item(_get_inventory_item_display_text(item), _get_item_texture(item))
		var list_index = main.inventory_item_list.item_count - 1
		var item_block_reason := PlayerData.get_equip_block_reason(item)
		if _is_equippable_inventory_item(item) and item_block_reason != "":
			main.inventory_item_list.set_item_custom_bg_color(list_index, Color(0.10, 0.10, 0.10, 0.36))
			main.inventory_item_list.set_item_custom_fg_color(list_index, Color(0.62, 0.68, 0.66, 0.86))
		if _is_inventory_item_equipped(item):
			main.inventory_item_list.set_item_custom_bg_color(list_index, Color(0.12, 0.34, 0.22, 0.66))
			main.inventory_item_list.set_item_custom_fg_color(list_index, Color(0.80, 1.0, 0.82, 1.0))

	if selected_index >= page_start and selected_index < page_end:
		main.inventory_item_list.select(selected_index - page_start)
	else:
		main._selected_inventory_item_id = ""

	_update_inventory_pager(page_count, total_count)

	var selected_item = _get_selected_inventory_item()
	if selected_item.is_empty():
		if main._visible_inventory_items.is_empty():
			main.inventory_details_label.text = "В этой категории пока пусто."
		else:
			main.inventory_details_label.text = "Выбери предмет."
	else:
		main.inventory_details_label.text = _get_inventory_item_details_text(selected_item)

	var is_equippable := not selected_item.is_empty() and _is_equippable_inventory_item(selected_item)
	var block_reason := PlayerData.get_equip_block_reason(selected_item) if is_equippable else ""
	var can_equip = is_equippable and block_reason == ""
	var is_equipped := is_equippable and _is_inventory_item_equipped(selected_item)
	var can_repair := not selected_item.is_empty() and PlayerData.is_item_repairable(selected_item)
	var can_discard := not selected_item.is_empty() and PlayerData.can_discard_item(selected_item)
	var details_bottom_padding = 24.0

	if is_equippable or can_repair or can_discard:
		details_bottom_padding = 76.0

	main.inventory_details_label.size = Vector2(
		main.inventory_details_label.size.x,
		max(main.inventory_details_card.size.y - details_bottom_padding, 48.0)
	)
	main.inventory_equip_button.disabled = not can_equip or is_equipped or main._fishing_ui_state != FishingUiState.IDLE
	main.inventory_equip_button.visible = is_equippable
	if main.inventory_repair_button != null:
		main.inventory_repair_button.visible = can_repair
		main.inventory_repair_button.disabled = not can_repair
		main.inventory_repair_button.text = "Починить"
	if main.inventory_discard_button != null:
		main.inventory_discard_button.visible = can_discard
		main.inventory_discard_button.disabled = not can_discard
		main.inventory_discard_button.text = "Выбросить"
	if is_equipped:
		main.inventory_equip_button.text = "Надето"
	elif main._fishing_ui_state != FishingUiState.IDLE and can_equip:
		main.inventory_equip_button.text = "Только вне ловли"
	elif block_reason != "":
		main.inventory_equip_button.text = "Недоступно"
	else:
		main.inventory_equip_button.text = "Экипировать"
	_refresh_inventory_category_buttons()


func _ensure_inventory_pager_nodes() -> void:
	if main == null or main.inventory_panel == null:
		return

	if main.inventory_prev_page_button == null:
		main.inventory_prev_page_button = Button.new()
		main.inventory_prev_page_button.name = "InventoryPrevPageButton"
		main.inventory_prev_page_button.text = "<"
		main.inventory_prev_page_button.focus_mode = Control.FOCUS_NONE
		main.inventory_prev_page_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.inventory_prev_page_button.z_index = 2
		main.inventory_prev_page_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.inventory_panel.add_child(main.inventory_prev_page_button)
		main.inventory_prev_page_button.pressed.connect(_on_inventory_prev_page_pressed)

	if main.inventory_next_page_button == null:
		main.inventory_next_page_button = Button.new()
		main.inventory_next_page_button.name = "InventoryNextPageButton"
		main.inventory_next_page_button.text = ">"
		main.inventory_next_page_button.focus_mode = Control.FOCUS_NONE
		main.inventory_next_page_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.inventory_next_page_button.z_index = 2
		main.inventory_next_page_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.inventory_panel.add_child(main.inventory_next_page_button)
		main.inventory_next_page_button.pressed.connect(_on_inventory_next_page_pressed)

	if main.inventory_page_label == null:
		main.inventory_page_label = Label.new()
		main.inventory_page_label.name = "InventoryPageLabel"
		main.inventory_page_label.text = ""
		main.inventory_page_label.z_index = 2
		main.inventory_page_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main.inventory_page_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.inventory_panel.add_child(main.inventory_page_label)


func _update_inventory_pager(page_count: int, total_count: int) -> void:
	_ensure_inventory_pager_nodes()
	if main.inventory_prev_page_button == null or main.inventory_next_page_button == null or main.inventory_page_label == null:
		return

	var has_pages := total_count > INVENTORY_ITEMS_PER_PAGE
	main.inventory_prev_page_button.visible = has_pages
	main.inventory_next_page_button.visible = has_pages
	main.inventory_page_label.visible = has_pages
	main.inventory_prev_page_button.disabled = main._inventory_page <= 0
	main.inventory_next_page_button.disabled = main._inventory_page >= page_count - 1
	main.inventory_page_label.text = "%d / %d" % [main._inventory_page + 1, page_count]


func _refresh_inventory_category_buttons() -> void:
	var category_buttons: Array = [
		[main.category_all_button, "all"],
		[main.category_rods_button, "rod"],
		[main.category_lines_button, "line"],
		[main.category_floats_button, "float"],
		[main.category_hooks_button, "hook"],
		[main.category_baits_button, "bait"],
		[main.category_fish_button, "fish"],
		[main.category_misc_button, "misc"]
	]

	for item in category_buttons:
		var button: Button = item[0]
		var category: String = item[1]
		theme.apply_tab_button_style(button, category == main._inventory_category)


func _get_visible_inventory_items() -> Array:
	var items: Array = []

	if main._inventory_category == "all":
		items.append_array(PlayerData.owned_items)
	elif main._inventory_category != "fish":
		items.append_array(PlayerData.get_owned_items_for_category(main._inventory_category))

	var filtered_items: Array = []
	for item in items:
		if typeof(item) == TYPE_DICTIONARY and _should_show_inventory_item(item):
			filtered_items.append(item)
	items = filtered_items

	if main._inventory_category == "all" or main._inventory_category == "fish":
		for i in InventoryManager.inventory.size():
			var fish: Dictionary = InventoryManager.inventory[i]
			var base_price := int(fish.get("price", 0))
			items.append({
				"id": "basket_fish_%d" % i,
				"name": str(fish.get("name", "-")),
				"category": "fish",
				"quantity": 1,
				"description": "Рыба в садке.",
				"stats": {
					"weight": float(fish.get("weight", 0.0)),
					"price": base_price,
					"sell_price": InventoryManager.get_fish_sell_price(fish),
					"freshness_price": InventoryManager.get_fish_freshness_price(fish),
					"freshness_title": FishFreshnessManager.get_freshness_title(fish),
					"freshness_ratio": FishFreshnessManager.get_freshness_ratio(fish),
					"rarity": str(fish.get("rarity", "-"))
				}
			})

	return items

func _should_show_inventory_item(item: Dictionary) -> bool:
	var category := str(item.get("category", "misc"))
	if ["bait", "consumable", "groundbait"].has(category) and int(item.get("quantity", 0)) <= 0:
		return false
	return true

func _is_equippable_inventory_item(item: Dictionary) -> bool:
	var category := str(item.get("category", ""))
	return PlayerData.TACKLE_SLOT_ITEM_CATEGORIES.values().has(category)


func _get_selected_inventory_item() -> Dictionary:
	for item in main._visible_inventory_items:
		if str(item.get("id", "")) == main._selected_inventory_item_id:
			return item

	return {}


func _get_inventory_item_display_text(item: Dictionary) -> String:
	var category = str(item.get("category", "misc"))
	var name = str(item.get("name", "-"))
	var quantity = int(item.get("quantity", 1))
	var equipped_marker := "  [Надето]" if _is_inventory_item_equipped(item) else ""

	if category == "fish":
		var stats: Dictionary = item.get("stats", {})
		return "%s | %.2f кг | %d мон. | %s" % [
			name,
			float(stats.get("weight", 0.0)),
			int(stats.get("sell_price", stats.get("price", 0))),
			str(stats.get("freshness_title", "-"))
		]

	if ["rod", "line", "leader", "hook"].has(category):
		var status := PlayerData.get_item_condition_title(item)
		if status != "Исправна":
			return "%s [%s]%s" % [name, status, equipped_marker]

	if quantity > 1:
		return "%s x%d%s" % [name, quantity, equipped_marker]

	return "%s%s" % [name, equipped_marker]


func _get_inventory_item_details_text(item: Dictionary) -> String:
	var category = str(item.get("category", "misc"))
	var name = str(item.get("name", "-"))
	var quantity = int(item.get("quantity", 1))
	var description = str(item.get("description", ""))
	var stats: Dictionary = item.get("stats", {})

	if category == "fish":
		return "%s\nКатегория: Рыба / Садок\nВес: %.2f кг\nСвежесть: %s\nЦена продажи: %d мон.\nБазовая цена: %d мон.\nРедкость: %s" % [
			name,
			float(stats.get("weight", 0.0)),
			str(stats.get("freshness_title", "-")),
			int(stats.get("sell_price", stats.get("price", 0))),
			int(stats.get("price", 0)),
			str(stats.get("rarity", "-"))
		]

	var equipped_line := "Статус: надето в текущей сборке\n" if _is_inventory_item_equipped(item) else ""
	var details = "%s\n%sКатегория: %s\nКоличество: %d" % [
		name,
		equipped_line,
		_get_inventory_category_title(category),
		quantity
	]

	var condition_text := _get_item_condition_details_text(item, "")
	if condition_text != "":
		details += "\n\n%s" % condition_text

	if description != "":
		details += "\n%s" % description

	var stats_text = _get_inventory_stats_text(stats)
	if stats_text != "":
		details += "\n\n%s" % stats_text

	return details


func _get_item_texture(item: Dictionary) -> Texture2D:
	var path := str(item.get("image_path", ""))
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
		var image := Image.load_from_file(path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)

	return null


func _get_inventory_stats_text(stats: Dictionary) -> String:
	var stats_text = ""

	for key in stats.keys():
		var value = stats[key]

		if typeof(value) == TYPE_DICTIONARY or typeof(value) == TYPE_ARRAY:
			continue

		if stats_text != "":
			stats_text += "\n"

		stats_text += "%s: %s" % [str(key), str(value)]

	return stats_text

func _get_item_condition_details_text(item: Dictionary, slot_type: String = "") -> String:
	var category := str(item.get("category", ""))
	if not ["rod", "line", "leader", "hook", "bait"].has(category):
		return ""

	if category == "bait":
		if int(item.get("quantity", 0)) <= 0:
			return "Состояние: закончилась\nПричина: Наживка закончилась."
		return ""

	var wear_percent := PlayerData.get_item_wear_percent(item)
	var repair_cost := PlayerData.get_item_repair_cost(item)
	var block_reason := PlayerData.get_equip_block_reason(item, slot_type)
	var lines: Array = [
		"Состояние: %s" % PlayerData.get_item_condition_title(item),
		"Износ: %d%%" % wear_percent
	]
	if repair_cost > 0:
		lines.append("Ремонт: %s" % PlayerData.format_money(float(repair_cost)))
	if block_reason != "":
		lines.append("Причина: %s" % block_reason)
	return "\n".join(lines)


func _get_current_tackle_inventory_text() -> String:
	var bait_2_text := "закрыта"
	if PlayerData.can_use_second_bait():
		bait_2_text = _format_current_bait_slot("bait_2")

	return "ТЕКУЩАЯ СНАСТЬ\nУдочка: %s\nЛеска: %s | Поводок: %s | Поплавок: %s\nКрючок: %s | Наживка 1: %s | Наживка 2: %s\nГлубина %.1f м | Состояние: уд.%d%% / леска %d%% / крючок %d%%\n%s" % [
		PlayerData.current_tackle.get("rod", {}).get("name", "-"),
		PlayerData.current_tackle.get("line", {}).get("name", "-"),
		PlayerData.current_tackle.get("leader", {}).get("name", "-"),
		PlayerData.current_tackle.get("float", {}).get("name", "-"),
		PlayerData.current_tackle.get("hook", {}).get("name", "-"),
		_format_current_bait_slot("bait"),
		bait_2_text,
		PlayerData.fishing_depth,
		roundi(PlayerData.get_tackle_condition("rod") * 100.0),
		roundi(PlayerData.get_tackle_condition("line") * 100.0),
		roundi(PlayerData.get_tackle_condition("hook") * 100.0),
		_get_tackle_setup_status_inline()
	]

func _format_current_bait_slot(slot_id: String) -> String:
	var current: Dictionary = PlayerData.current_tackle.get(slot_id, {})
	if str(current.get("id", "")) == "":
		return "не установлена"
	var name := str(current.get("name", "-"))
	var quantity := PlayerData.get_current_bait_quantity(slot_id)
	if quantity <= 0:
		return "%s x0 — закончилась" % name
	return "%s x%d" % [name, quantity]

func _get_current_tackle_inventory_text_legacy() -> String:
	return "СЕЙЧАС НАДЕТО В СБОРКЕ\nУдочка: %s\nЛеска: %s  |  Поплавок: %s\nКрючок: %s  |  Наживка: %s x%d\nГлубина %.1f м  |  Состояние: уд.%d%% / леска %d%% / крючок %d%%\n%s" % [
		PlayerData.current_tackle.get("rod", {}).get("name", "-"),
		PlayerData.current_tackle.get("line", {}).get("name", "-"),
		PlayerData.current_tackle.get("float", {}).get("name", "-"),
		PlayerData.current_tackle.get("hook", {}).get("name", "-"),
		PlayerData.current_tackle.get("bait", {}).get("name", "-"),
		PlayerData.get_current_bait_quantity(),
		PlayerData.fishing_depth,
		roundi(PlayerData.get_tackle_condition("rod") * 100.0),
		roundi(PlayerData.get_tackle_condition("line") * 100.0),
		roundi(PlayerData.get_tackle_condition("hook") * 100.0),
		_get_tackle_setup_status_inline()
	]


func _get_tackle_build_summary_text() -> String:
	return _get_current_tackle_inventory_text()

func _get_tackle_build_summary_text_legacy() -> String:
	return "СЕЙЧАС НАДЕТО В СБОРКЕ\nУдочка: %s\nЛеска: %s  |  Поплавок: %s\nКрючок: %s  |  Наживка: %s x%d\nГлубина %.1f м  |  Состояние: уд.%d%% / леска %d%% / крючок %d%%\n%s" % [
		PlayerData.current_tackle.get("rod", {}).get("name", "-"),
		PlayerData.current_tackle.get("line", {}).get("name", "-"),
		PlayerData.current_tackle.get("float", {}).get("name", "-"),
		PlayerData.current_tackle.get("hook", {}).get("name", "-"),
		PlayerData.current_tackle.get("bait", {}).get("name", "-"),
		PlayerData.get_current_bait_quantity(),
		PlayerData.fishing_depth,
		roundi(PlayerData.get_tackle_condition("rod") * 100.0),
		roundi(PlayerData.get_tackle_condition("line") * 100.0),
		roundi(PlayerData.get_tackle_condition("hook") * 100.0),
		_get_tackle_setup_status_inline()
	]


func _get_tackle_setup_status_inline() -> String:
	var issues: Array = PlayerData.get_tackle_setup_issues()
	if issues.is_empty():
		return "Статус: сборка готова."

	return "Проблемы: %s" % "; ".join(issues)


func _is_inventory_item_equipped(item: Dictionary) -> bool:
	var category := str(item.get("category", ""))
	if not PlayerData.current_tackle.has(category):
		return false

	return str(PlayerData.current_tackle[category].get("id", "")) == str(item.get("id", ""))


func _get_inventory_category_title(category: String) -> String:
	match category:
		"all":
			return "Все"
		"rod":
			return "Удилища"
		"line":
			return "Лески"
		"leader":
			return "Поводки"
		"float":
			return "Поплавки"
		"hook":
			return "Крючки"
		"bait":
			return "Наживки"
		"fish":
			return "Рыба"
		_:
			return "Разное"


func _set_inventory_category(category: String) -> void:
	main._inventory_category = category
	main._inventory_page = 0
	main._selected_inventory_item_id = ""
	_update_inventory_ui()


func _on_inventory_item_selected(index: int) -> void:
	var item_index: int = main._inventory_page * INVENTORY_ITEMS_PER_PAGE + index
	if item_index < 0 or item_index >= main._visible_inventory_items.size():
		main._selected_inventory_item_id = ""
	else:
		main._selected_inventory_item_id = str(main._visible_inventory_items[item_index].get("id", ""))

	_update_inventory_ui()


func _on_inventory_prev_page_pressed() -> void:
	if main._inventory_page <= 0:
		return

	main._inventory_page -= 1
	main._selected_inventory_item_id = ""
	_update_inventory_ui()


func _on_inventory_next_page_pressed() -> void:
	var total_count: int = _get_visible_inventory_items().size()
	var page_count: int = max(ceili(float(total_count) / float(INVENTORY_ITEMS_PER_PAGE)), 1)
	if main._inventory_page >= page_count - 1:
		return

	main._inventory_page += 1
	main._selected_inventory_item_id = ""
	_update_inventory_ui()
