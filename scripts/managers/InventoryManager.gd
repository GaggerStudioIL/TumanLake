extends Node

var inventory: Array = []
var max_items: int = 20

func add_fish(catch_data: Dictionary) -> bool:
	if inventory.size() >= max_items:
		return false

	inventory.append(catch_data)
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
		total_money += item["price"]

	inventory.clear()
	PlayerData.money += total_money

	return total_money

func get_inventory_text() -> String:
	if inventory.is_empty():
		return "Садок пуст."

	var text := "Садок:\n"

	for item in inventory:
		text += "%s | %.2f кг | %d мон.\n" % [
			item["name"],
			item["weight"],
			item["price"]
		]

	return text
