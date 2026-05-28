extends Node

const STATUS_UNDERSIZED := "undersized"
const STATUS_KEEPER := "keeper"
const STATUS_TROPHY := "trophy"

const QUALITY_MULTIPLIERS := {
	STATUS_UNDERSIZED: 0.8,
	STATUS_KEEPER: 3.0,
	STATUS_TROPHY: 8.0
}

func get_status(fish: Dictionary, weight_kg: float) -> String:
	var keeper_weight: float = get_keeper_weight(fish)
	var trophy_weight: float = get_trophy_weight(fish)

	if trophy_weight > 0.0 and weight_kg >= trophy_weight:
		return STATUS_TROPHY
	if keeper_weight > 0.0 and weight_kg >= keeper_weight:
		return STATUS_KEEPER
	return STATUS_UNDERSIZED


func get_keeper_weight(fish: Dictionary) -> float:
	if fish.has("keeperWeight"):
		return max(float(fish.get("keeperWeight", 0.0)), 0.0)
	if fish.has("keeper_weight"):
		return max(float(fish.get("keeper_weight", 0.0)), 0.0)

	var min_weight: float = float(fish.get("minWeight", fish.get("min_weight", 0.01)))
	var max_weight: float = float(fish.get("maxWeight", fish.get("max_weight", 1.0)))
	var trophy_weight: float = get_trophy_weight(fish)
	var default_weight: float = max(min_weight, trophy_weight * 0.28)
	var upper_limit: float = max(min_weight, min(trophy_weight - 0.01, max_weight))
	return snappedf(clamp(default_weight, min_weight, upper_limit), 0.01)


func get_trophy_weight(fish: Dictionary) -> float:
	return max(float(fish.get("trophyWeight", fish.get("trophy_weight", 0.0))), 0.0)


func get_record_weight(fish: Dictionary) -> float:
	var fallback: float = float(fish.get("rarity_weight", fish.get("maxWeight", fish.get("max_weight", 0.0))))
	return max(float(fish.get("recordWeight", fish.get("record_weight", fallback))), 0.0)


func get_quality_multiplier(status: String) -> float:
	return float(QUALITY_MULTIPLIERS.get(status, 1.0))


func get_status_title(status: String) -> String:
	match status:
		STATUS_KEEPER:
			return "Зачет"
		STATUS_TROPHY:
			return "Трофей"
		_:
			return "Незачет"


func meets_min_status(catch_status: String, min_status: String) -> bool:
	return _get_status_order(catch_status) >= _get_status_order(min_status)


func decorate_catch(fish: Dictionary, catch_data: Dictionary) -> Dictionary:
	var result: Dictionary = catch_data.duplicate(true)
	var weight_kg: float = float(result.get("weight", 0.0))
	var status: String = get_status(fish, weight_kg)
	var keeper_weight: float = get_keeper_weight(fish)
	var trophy_weight: float = get_trophy_weight(fish)
	var record_weight: float = get_record_weight(fish)

	result["fish_status"] = status
	result["fish_status_title"] = get_status_title(status)
	result["keeper_weight"] = keeper_weight
	result["keeperWeight"] = keeper_weight
	result["trophyWeight"] = trophy_weight
	result["recordWeight"] = record_weight
	result["qualityMultiplier"] = get_quality_multiplier(status)
	result["is_keeper"] = status == STATUS_KEEPER or status == STATUS_TROPHY
	result["is_trophy_status"] = status == STATUS_TROPHY
	return result


func _get_status_order(status: String) -> int:
	match status:
		STATUS_TROPHY:
			return 2
		STATUS_KEEPER:
			return 1
		_:
			return 0
