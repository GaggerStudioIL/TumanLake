extends Node

const RARITY_MULTIPLIERS := {
	"common": 1.0,
	"rare": 2.0,
	"legendary_species": 5.0
}

func calculate_catch_base_price(catch_data: Dictionary, supplier_id: String = "") -> int:
	return calculate_price(catch_data, supplier_id, false)


func calculate_sell_price(catch_data: Dictionary, supplier_id: String = "") -> int:
	return calculate_price(catch_data, supplier_id, true)


func calculate_price(catch_data: Dictionary, supplier_id: String = "", include_freshness: bool = true) -> int:
	var breakdown: Dictionary = calculate_breakdown(catch_data, supplier_id, include_freshness)
	return max(roundi(float(breakdown.get("final_price", 0.0))), 0)


func calculate_breakdown(catch_data: Dictionary, supplier_id: String = "", include_freshness: bool = true) -> Dictionary:
	var fish_id: String = str(catch_data.get("id", catch_data.get("fish_id", "")))
	var fish: Dictionary = FishDatabase.get_fish(fish_id)
	var weight_kg: float = max(float(catch_data.get("weight", 0.0)), 0.0)
	var base_price_per_kg: float = float(catch_data.get("basePricePerKg", fish.get("basePricePerKg", fish.get("price_per_kg", 1.0))))
	var rarity_type: String = str(catch_data.get("rarityType", fish.get("rarityType", "common")))
	var status: String = str(catch_data.get("fish_status", ""))
	if status.is_empty() and not fish.is_empty():
		status = FishStatusSystem.get_status(fish, weight_kg)
	if status.is_empty():
		status = "undersized"

	var target_supplier_id: String = supplier_id
	if target_supplier_id.is_empty():
		target_supplier_id = SupplierManager.get_best_supplier_for_catch(_with_status(catch_data, status, rarity_type))

	var base_value: float = base_price_per_kg * weight_kg
	var rarity_multiplier: float = get_rarity_multiplier(rarity_type)
	var quality_multiplier: float = FishStatusSystem.get_quality_multiplier(status)
	var market_multiplier: float = DynamicMarketManager.get_demand_multiplier(fish_id, str(catch_data.get("waterbody_id", "")))
	var supplier_multiplier: float = SupplierManager.get_supplier_bonus_multiplier(_with_status(catch_data, status, rarity_type), target_supplier_id)
	if supplier_multiplier <= 0.0:
		supplier_multiplier = 1.0
		target_supplier_id = "local_market"

	var freshness_multiplier: float = FishFreshnessManager.get_price_multiplier(catch_data) if include_freshness else 1.0
	var final_price: float = base_value * rarity_multiplier * quality_multiplier * market_multiplier * supplier_multiplier * freshness_multiplier

	return {
		"fish_id": fish_id,
		"weight_kg": weight_kg,
		"base_price_per_kg": base_price_per_kg,
		"base_value": base_value,
		"rarityType": rarity_type,
		"rarity_multiplier": rarity_multiplier,
		"fish_status": status,
		"quality_multiplier": quality_multiplier,
		"marketDemandMultiplier": market_multiplier,
		"supplier_id": target_supplier_id,
		"supplier_name": SupplierManager.get_supplier_title(target_supplier_id),
		"supplierBonusMultiplier": supplier_multiplier,
		"freshnessMultiplier": freshness_multiplier,
		"final_price": final_price
	}


func get_rarity_multiplier(rarity_type: String) -> float:
	return float(RARITY_MULTIPLIERS.get(rarity_type, 1.0))


func get_rarity_title(rarity_type: String) -> String:
	match rarity_type:
		"rare":
			return "Редкий вид"
		"legendary_species":
			return "Легендарный вид"
		_:
			return "Обычный вид"


func _with_status(catch_data: Dictionary, status: String, rarity_type: String) -> Dictionary:
	var result: Dictionary = catch_data.duplicate(true)
	result["fish_status"] = status
	result["rarityType"] = rarity_type
	return result
