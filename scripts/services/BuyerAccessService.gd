extends Node

const DEFAULT_BUYER_IDS := [
	"local_market",
	"fish_shop",
	"cannery",
	"restaurant",
	"wholesale_buyer",
	"collector",
	"export_company"
]


func get_primary_buyer_ids() -> Array:
	var supplier_manager := _supplier_manager()
	if supplier_manager != null and supplier_manager.has_method("get_primary_supplier_ids"):
		var value = supplier_manager.call("get_primary_supplier_ids")
		if value is Array:
			return value.duplicate()
	return DEFAULT_BUYER_IDS.duplicate()


func is_buyer_unlocked(buyer_id: String) -> bool:
	var supplier: Dictionary = _get_supplier(buyer_id)
	if supplier.is_empty():
		return false
	var required_reputation := int(supplier.get("min_reputation", 0))
	if required_reputation <= 0:
		return true
	return _get_reputation(buyer_id) >= required_reputation


func can_buyer_accept_fish(buyer_id: String, fish_instance: Dictionary) -> bool:
	var supplier: Dictionary = _get_supplier(buyer_id)
	if supplier.is_empty() or not is_buyer_unlocked(buyer_id):
		return false
	var prepared := prepare_fish_for_access(fish_instance)
	return _can_accept_prepared_fish(supplier, buyer_id, prepared)


func get_buyer_lock_reason(buyer_id: String) -> String:
	var supplier: Dictionary = _get_supplier(buyer_id)
	if supplier.is_empty():
		return "Неизвестный покупатель"
	if is_buyer_unlocked(buyer_id):
		return "Открыт"
	var unlock_text := str(supplier.get("unlock_text", ""))
	if not unlock_text.is_empty():
		return unlock_text
	return "Откроется при репутации %d" % int(supplier.get("min_reputation", 0))


func get_buyer_rejection_reason(buyer_id: String, fish_instance: Dictionary) -> String:
	var supplier: Dictionary = _get_supplier(buyer_id)
	if supplier.is_empty():
		return "Неизвестный покупатель"
	if not is_buyer_unlocked(buyer_id):
		return get_buyer_lock_reason(buyer_id)
	var prepared := prepare_fish_for_access(fish_instance)
	if _can_accept_prepared_fish(supplier, buyer_id, prepared):
		return "Готово к продаже"

	var fish_id: String = str(prepared.get("id", prepared.get("fish_id", "")))
	var rarity_type: String = str(prepared.get("rarityType", "common"))
	var status: String = str(prepared.get("fish_status", "undersized"))
	var min_status: String = str(supplier.get("min_status", "undersized"))
	var accepted_rarity_types: Array = _as_array(supplier.get("accepted_rarity_types", []))

	if bool(supplier.get("accepts_trophy_or_rare", false)) and status != FishStatusSystem.STATUS_TROPHY and not accepted_rarity_types.has(rarity_type):
		return "Нужен редкий вид или трофей"
	if not FishStatusSystem.meets_min_status(status, min_status):
		return "Нужен статус: %s" % FishStatusSystem.get_status_title(min_status)
	if float(supplier.get("min_weight_kg", 0.0)) > 0.0 and float(prepared.get("weight", 0.0)) < float(supplier.get("min_weight_kg", 0.0)):
		return "Нужен вес от %.1f кг" % float(supplier.get("min_weight_kg", 0.0))

	var freshness_reason := _get_freshness_rejection_reason(supplier, prepared)
	if not freshness_reason.is_empty():
		return freshness_reason

	var accepted_fish_ids: Array = _as_array(supplier.get("accepted_fish_ids", []))
	if not accepted_fish_ids.is_empty() and not accepted_fish_ids.has(fish_id):
		return "Этот вид не принимается"
	if not accepted_rarity_types.is_empty() and not accepted_rarity_types.has(rarity_type):
		return "Нужна подходящая редкость"
	return "Не принимается: %s" % FishStatusSystem.get_status_title(status)


func prepare_fish_for_access(fish_instance: Dictionary) -> Dictionary:
	var result := FishFreshnessManager.ensure_catch_freshness_metadata(fish_instance)
	var fish_id := str(result.get("id", result.get("fish_id", "")))
	var fish: Dictionary = FishDatabase.get_fish(fish_id)
	if fish.is_empty():
		if not result.has("fish_status") or str(result.get("fish_status", "")).is_empty():
			result["fish_status"] = "undersized"
		if not result.has("rarityType") or str(result.get("rarityType", "")).is_empty():
			result["rarityType"] = "common"
		return result

	result["rarityType"] = str(result.get("rarityType", fish.get("rarityType", fish.get("rarity", "common"))))
	if not result.has("fish_status") or str(result.get("fish_status", "")).is_empty():
		result["fish_status"] = FishStatusSystem.get_status(fish, float(result.get("weight", 0.0)))
	if not result.has("fish_status_title") or str(result.get("fish_status_title", "")).is_empty():
		result["fish_status_title"] = FishStatusSystem.get_status_title(str(result.get("fish_status", "undersized")))
	return result


func _can_accept_prepared_fish(supplier: Dictionary, _buyer_id: String, prepared: Dictionary) -> bool:
	var fish_id: String = str(prepared.get("id", prepared.get("fish_id", "")))
	var rarity_type: String = str(prepared.get("rarityType", "common"))
	var status: String = str(prepared.get("fish_status", "undersized"))
	var accepted_rarity_types: Array = _as_array(supplier.get("accepted_rarity_types", []))
	var accepts_trophy_or_rare: bool = bool(supplier.get("accepts_trophy_or_rare", false))
	var rare_or_trophy: bool = status == FishStatusSystem.STATUS_TROPHY or accepted_rarity_types.has(rarity_type)

	if not accepts_trophy_or_rare or not rare_or_trophy:
		var min_status: String = str(supplier.get("min_status", "undersized"))
		if not FishStatusSystem.meets_min_status(status, min_status):
			return false

	var min_weight_kg: float = float(supplier.get("min_weight_kg", 0.0))
	if min_weight_kg > 0.0 and float(prepared.get("weight", 0.0)) < min_weight_kg:
		return false

	var accepted_fish_ids: Array = _as_array(supplier.get("accepted_fish_ids", []))
	if not accepted_fish_ids.is_empty() and not accepted_fish_ids.has(fish_id):
		return false

	if not accepted_rarity_types.is_empty() and not accepted_rarity_types.has(rarity_type):
		if not accepts_trophy_or_rare or status != FishStatusSystem.STATUS_TROPHY:
			return false

	if not _meets_freshness_requirement(supplier, prepared):
		return false

	return true


func _meets_freshness_requirement(supplier: Dictionary, prepared: Dictionary) -> bool:
	var max_freshness_age_hours := float(supplier.get("max_freshness_age_hours", -1.0))
	if max_freshness_age_hours < 0.0:
		return true
	return FishFreshnessManager.get_fish_age_game_hours(prepared) <= max_freshness_age_hours


func _get_freshness_rejection_reason(supplier: Dictionary, prepared: Dictionary) -> String:
	if _meets_freshness_requirement(supplier, prepared):
		return ""
	var freshness_title := FishFreshnessManager.get_freshness_title(prepared)
	return "Рыба слишком старая: %s" % freshness_title


func _get_supplier(buyer_id: String) -> Dictionary:
	var supplier_manager := _supplier_manager()
	if supplier_manager != null and supplier_manager.has_method("get_supplier"):
		var value = supplier_manager.call("get_supplier", buyer_id)
		if value is Dictionary:
			return value
	return {}


func _get_reputation(buyer_id: String) -> int:
	var reputation_system := get_node_or_null("/root/ReputationSystem")
	if reputation_system != null and reputation_system.has_method("get_reputation"):
		return int(reputation_system.call("get_reputation", buyer_id))
	return 0


func _supplier_manager() -> Node:
	return get_node_or_null("/root/SupplierManager")


func _as_array(value) -> Array:
	if value is Array:
		return value.duplicate()
	return []
