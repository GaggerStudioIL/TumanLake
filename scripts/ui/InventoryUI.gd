# Handles the inventory window: categories, item list, and item details.
extends RefCounted

var main
enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

func setup(main_ref) -> void:
	main = main_ref

func open() -> void:
	if main._is_catch_reward_open():
		return

	main._active_nav_tab = "inventory"
	main.basket_panel.visible = false
	main.basket_backdrop.visible = false
	main.tackle_panel.visible = false
	main.tackle_backdrop.visible = false
	main.shop_panel.visible = false
	main.shop_backdrop.visible = false
	main.waterbody_panel.visible = false
	main.waterbody_backdrop.visible = false
	main.inventory_backdrop.visible = true
	main.inventory_panel.visible = true
	refresh()
	main._refresh_bottom_nav_styles()

func close() -> void:
	if main == null or main.inventory_panel == null:
		return

	main.inventory_panel.visible = false
	main.inventory_backdrop.visible = false
	main._active_nav_tab = "fish"
	main._refresh_bottom_nav_styles()

func refresh() -> void:
	_update_inventory_ui()

func is_open() -> bool:
	return main != null and main.inventory_panel != null and main.inventory_panel.visible

func _update_inventory_ui() -> void:
	main._visible_inventory_items = _get_visible_inventory_items()
	main.inventory_title_label.text = "Инвентарь"
	main.inventory_tackle_label.text = _get_current_tackle_inventory_text()
	main.inventory_item_list.clear()

	var selected_index = -1
	for i in main._visible_inventory_items.size():
		var item: Dictionary = main._visible_inventory_items[i]
		main.inventory_item_list.add_item(_get_inventory_item_display_text(item))

		if str(item.get("id", "")) == main._selected_inventory_item_id:
			selected_index = i

	if selected_index >= 0:
		main.inventory_item_list.select(selected_index)
	else:
		main._selected_inventory_item_id = ""

	var selected_item = _get_selected_inventory_item()
	if selected_item.is_empty():
		if main._visible_inventory_items.is_empty():
			main.inventory_details_label.text = "В этой категории пока пусто."
		else:
			main.inventory_details_label.text = "Выбери предмет."
	else:
		main.inventory_details_label.text = _get_inventory_item_details_text(selected_item)

	var can_equip = not selected_item.is_empty() and PlayerData.can_equip_item(selected_item)
	var details_bottom_padding = 24.0

	if can_equip:
		details_bottom_padding = 76.0

	main.inventory_details_label.size = Vector2(
		main.inventory_details_label.size.x,
		max(main.inventory_details_card.size.y - details_bottom_padding, 48.0)
	)
	main.inventory_equip_button.disabled = not can_equip or main._fishing_ui_state != FishingUiState.IDLE
	main.inventory_equip_button.visible = can_equip


func _get_visible_inventory_items() -> Array:
	var items: Array = []

	if main._inventory_category == "all":
		items.append_array(PlayerData.owned_items)
	elif main._inventory_category != "fish":
		items.append_array(PlayerData.get_owned_items_for_category(main._inventory_category))

	if main._inventory_category == "all" or main._inventory_category == "fish":
		for i in InventoryManager.inventory.size():
			var fish: Dictionary = InventoryManager.inventory[i]
			items.append({
				"id": "basket_fish_%d" % i,
				"name": str(fish.get("name", "-")),
				"category": "fish",
				"quantity": 1,
				"description": "Рыба в садке.",
				"stats": {
					"weight": float(fish.get("weight", 0.0)),
					"price": int(fish.get("price", 0)),
					"rarity": str(fish.get("rarity", "-"))
				}
			})

	return items


func _get_selected_inventory_item() -> Dictionary:
	for item in main._visible_inventory_items:
		if str(item.get("id", "")) == main._selected_inventory_item_id:
			return item

	return {}


func _get_inventory_item_display_text(item: Dictionary) -> String:
	var category = str(item.get("category", "misc"))
	var name = str(item.get("name", "-"))
	var quantity = int(item.get("quantity", 1))

	if category == "fish":
		var stats: Dictionary = item.get("stats", {})
		return "%s %.2f кг" % [name, float(stats.get("weight", 0.0))]

	if quantity > 1:
		return "%s x%d" % [name, quantity]

	return name


func _get_inventory_item_details_text(item: Dictionary) -> String:
	var category = str(item.get("category", "misc"))
	var name = str(item.get("name", "-"))
	var quantity = int(item.get("quantity", 1))
	var description = str(item.get("description", ""))
	var stats: Dictionary = item.get("stats", {})

	if category == "fish":
		return "%s\nКатегория: Рыба / Садок\nВес: %.2f кг\nЦена: %d мон.\nРедкость: %s" % [
			name,
			float(stats.get("weight", 0.0)),
			int(stats.get("price", 0)),
			str(stats.get("rarity", "-"))
		]

	var details = "%s\nКатегория: %s\nКоличество: %d" % [
		name,
		_get_inventory_category_title(category),
		quantity
	]

	if description != "":
		details += "\n%s" % description

	var stats_text = _get_inventory_stats_text(stats)
	if stats_text != "":
		details += "\n\n%s" % stats_text

	return details


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


func _get_current_tackle_inventory_text() -> String:
	return "Текущая маховая снасть\nУдилище: %s\nЛеска: %s | Поплавок: %s\nКрючок: %s | Наживка: %s x%d\nПрочность: уд. %d%% | леска %d%% | крючок %d%%" % [
		PlayerData.current_tackle.get("rod", {}).get("name", "-"),
		PlayerData.current_tackle.get("line", {}).get("name", "-"),
		PlayerData.current_tackle.get("float", {}).get("name", "-"),
		PlayerData.current_tackle.get("hook", {}).get("name", "-"),
		PlayerData.current_tackle.get("bait", {}).get("name", "-"),
		PlayerData.get_current_bait_quantity(),
		roundi(PlayerData.get_tackle_condition("rod") * 100.0),
		roundi(PlayerData.get_tackle_condition("line") * 100.0),
		roundi(PlayerData.get_tackle_condition("hook") * 100.0)
	]


func _get_tackle_build_summary_text() -> String:
	return "Текущая сборка: %s | %s | %s\n%s | %s x%d | глубина %.1f м\nПрочность: уд. %d%% | леска %d%% | крючок %d%%" % [
		PlayerData.current_tackle.get("rod", {}).get("name", "-"),
		PlayerData.current_tackle.get("line", {}).get("name", "-"),
		PlayerData.current_tackle.get("float", {}).get("name", "-"),
		PlayerData.current_tackle.get("hook", {}).get("name", "-"),
		PlayerData.current_tackle.get("bait", {}).get("name", "-"),
		PlayerData.get_current_bait_quantity(),
		PlayerData.fishing_depth,
		roundi(PlayerData.get_tackle_condition("rod") * 100.0),
		roundi(PlayerData.get_tackle_condition("line") * 100.0),
		roundi(PlayerData.get_tackle_condition("hook") * 100.0)
	]


func _get_inventory_category_title(category: String) -> String:
	match category:
		"all":
			return "Все"
		"rod":
			return "Удилища"
		"line":
			return "Лески"
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
	main._selected_inventory_item_id = ""
	_update_inventory_ui()


func _on_inventory_item_selected(index: int) -> void:
	if index < 0 or index >= main._visible_inventory_items.size():
		main._selected_inventory_item_id = ""
	else:
		main._selected_inventory_item_id = str(main._visible_inventory_items[index].get("id", ""))

	_update_inventory_ui()
