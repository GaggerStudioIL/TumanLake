# Handles the player's intent after a successful catch.
extends RefCounted


func handle_keep(catch_data: Dictionary) -> Dictionary:
	var result := _base_result(catch_data)
	if catch_data.is_empty():
		result["success"] = false
		result["message"] = "Рыба в садке."
		return result

	PlayerData.register_catch_stats(catch_data)
	result["success"] = true
	result["message"] = "Рыба в садке: %s\nНажми “Вытянуть”, чтобы закончить цикл." % str(catch_data.get("name", "-"))
	return result


func handle_release(catch_data: Dictionary) -> Dictionary:
	var result := _base_result(catch_data)
	if not catch_data.is_empty() and InventoryManager.remove_fish(catch_data):
		result["success"] = true
		result["message"] = "Рыба отпущена: %s\nXP за поимку сохранён. Нажми “Вытянуть”." % str(catch_data.get("name", "-"))
		return result

	result["success"] = false
	result["message"] = "Рыба отпущена.\nНажми “Вытянуть”, чтобы закончить цикл."
	return result


func _base_result(catch_data: Dictionary) -> Dictionary:
	return {
		"success": false,
		"message": "",
		"catch_data": catch_data
	}
