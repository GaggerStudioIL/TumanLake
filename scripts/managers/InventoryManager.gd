extends Node

var inventory: Array = []
var max_items: int = 20

func add_fish(catch_data: Dictionary) -> bool:
	if inventory.size() >= max_items:
		return false

	inventory.append(FishFreshnessManager.ensure_catch_freshness_metadata(catch_data))
	return true


func remove_fish(catch_data: Dictionary) -> bool:
	for i in range(inventory.size() - 1, -1, -1):
		var item: Dictionary = inventory[i]

		if str(item.get("id", "")) != str(catch_data.get("id", "")):
			continue

		if abs(float(item.get("weight", 0.0)) - float(catch_data.get("weight", 0.0))) > 0.001:
			continue

		if int(item.get("price", 0)) != int(catch_data.get("price", 0)):
			continue

		inventory.remove_at(i)
		return true

	return false


func sell_all() -> int:
	var total_money := 0

	for item in inventory:
		if typeof(item) != TYPE_DICTIONARY:
			continue

		total_money += get_fish_sell_price(item)

	inventory.clear()
	PlayerData.money += total_money

	return total_money


func sell_fish_at(index: int) -> int:
	if index < 0 or index >= inventory.size():
		return 0

	var item = inventory[index]
	if typeof(item) != TYPE_DICTIONARY:
		inventory.remove_at(index)
		return 0

	var price := get_fish_sell_price(item)
	inventory.remove_at(index)
	PlayerData.money += price
	return price


func get_fish_freshness_price(catch_data: Dictionary) -> int:
	return FishFreshnessManager.get_adjusted_price(catch_data)


func get_fish_sell_price(catch_data: Dictionary) -> int:
	return PlayerData.get_skill_adjusted_sell_price(get_fish_freshness_price(catch_data))


func ensure_inventory_freshness_metadata() -> bool:
	var changed := false

	for i in inventory.size():
		if typeof(inventory[i]) != TYPE_DICTIONARY:
			continue

		var item: Dictionary = inventory[i]
		var had_real_time := item.has("caught_at_real_unix_time")
		var had_game_time := item.has("caught_at_total_game_minutes")
		var had_day_index := item.has("caught_at_day_index")
		var had_clock := item.has("caught_at_clock")
		var had_time_of_day := item.has("caught_at_time_of_day")
		var ensured := FishFreshnessManager.ensure_catch_freshness_metadata(item)
		inventory[i] = ensured

		if (
			not had_real_time
			or not had_game_time
			or not had_day_index
			or not had_clock
			or not had_time_of_day
			or bool(ensured.get("freshness_migrated", false))
		):
			changed = true

	return changed


func get_inventory_text() -> String:
	if inventory.is_empty():
		return "Садок пуст."

	var text := "Садок:\n"

	for item in inventory:
		if typeof(item) != TYPE_DICTIONARY:
			continue

		text += "%s | %.2f кг | %d мон. | %s\n" % [
			item["name"],
			item["weight"],
			get_fish_sell_price(item),
			FishFreshnessManager.get_freshness_title(item)
		]

	return text
