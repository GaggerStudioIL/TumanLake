extends Node

var inventory: Array = []
var max_items: int = 20

func add_fish(catch_data: Dictionary) -> bool:
	if inventory.size() >= max_items:
		return false

	inventory.append(catch_data)
	return true

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
