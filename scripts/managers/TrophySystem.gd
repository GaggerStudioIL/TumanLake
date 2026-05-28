extends Node

func decorate_catch(catch_data: Dictionary) -> Dictionary:
	var result: Dictionary = catch_data.duplicate(true)
	var weight_kg: float = float(result.get("weight", 0.0))
	var trophy_weight: float = float(result.get("trophyWeight", result.get("trophy_weight", 0.0)))
	var record_weight: float = float(result.get("recordWeight", result.get("rarity_weight", 0.0)))
	var status: String = str(result.get("fish_status", "undersized"))

	result["trophy_margin_kg"] = max(weight_kg - trophy_weight, 0.0)
	result["record_margin_kg"] = max(weight_kg - record_weight, 0.0)
	result["is_trophy_status"] = status == "trophy"
	result["is_record_weight"] = record_weight > 0.0 and weight_kg >= record_weight
	return result


func get_trophy_notification(catch_data: Dictionary) -> String:
	if bool(catch_data.get("is_record_weight", false)):
		return "Рекордный экземпляр"
	if bool(catch_data.get("is_trophy_status", false)):
		return "трофей"
	if bool(catch_data.get("is_keeper", false)):
		return "зачёт"
	return "незачёт"
