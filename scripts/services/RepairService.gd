extends Node


func get_item_condition(item: Dictionary) -> String:
	var wear_percent := get_wear_percent(item)
	if wear_percent >= 100:
		return "broken"
	if wear_percent >= 85:
		return "worn"
	if wear_percent >= 30:
		return "used"
	return "new"


func get_item_condition_title(item: Dictionary) -> String:
	if PlayerData.has_method("get_item_condition_title"):
		return str(PlayerData.call("get_item_condition_title", item))
	match get_item_condition(item):
		"broken":
			return "Сломана"
		"worn":
			return "Изношена"
		"used":
			return "Рабочая"
		_:
			return "Исправна"


func get_wear_percent(item: Dictionary) -> int:
	if PlayerData.has_method("get_item_wear_percent"):
		return int(PlayerData.call("get_item_wear_percent", item))
	return 0


func can_repair_item(item: Dictionary) -> bool:
	if PlayerData.has_method("is_item_repairable"):
		return bool(PlayerData.call("is_item_repairable", item))
	return false


func get_repair_cost(item: Dictionary) -> int:
	if PlayerData.has_method("get_item_repair_cost"):
		return int(PlayerData.call("get_item_repair_cost", item))
	return 0


func repair_item(item_id: String) -> Dictionary:
	if PlayerData.has_method("repair_owned_item"):
		var value = PlayerData.call("repair_owned_item", item_id)
		if value is Dictionary:
			return value
	return {"success": false, "message": "Ремонт недоступен."}


func can_discard_item(item: Dictionary) -> bool:
	if PlayerData.has_method("can_discard_item"):
		return bool(PlayerData.call("can_discard_item", item))
	return false


func discard_item(item_id: String) -> Dictionary:
	if PlayerData.has_method("discard_owned_item"):
		var value = PlayerData.call("discard_owned_item", item_id)
		if value is Dictionary:
			return value
	return {"success": false, "message": "Не удалось выбросить предмет."}
