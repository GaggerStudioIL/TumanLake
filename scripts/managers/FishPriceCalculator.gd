extends Node

const RARITY_MULTIPLIERS := {
	"common": 1.0,
	"rare": 1.5,
	"legendary_species": 3.0
}

const MASS_COMMON_PRICE_PER_KG_CAPS := {
	"bleak": 6.0,
	"topmouth_gudgeon": 5.0,
	"gudgeon": 6.0,
	"ruffe": 7.0,
	"roach": 8.0,
	"rudd": 8.0,
	"rotan": 8.0,
	"perch": 9.0,
	"white_bream": 8.0,
	"crucian": 9.0,
	"silver_crucian": 9.0,
	"golden_crucian": 11.0,
	"skimmer_bream": 12.0,
	"bream": 16.0
}

func calculate_catch_base_price(catch_data: Dictionary, supplier_id: String = "") -> int:
	var service := _fish_price_service()
	if service != null and service.has_method("calculate_catch_base_price"):
		return int(service.call("calculate_catch_base_price", catch_data, supplier_id))
	return calculate_price(catch_data, supplier_id, false)


func calculate_sell_price(catch_data: Dictionary, supplier_id: String = "") -> int:
	var service := _fish_price_service()
	if service != null and service.has_method("calculate_sell_price"):
		return int(service.call("calculate_sell_price", catch_data, supplier_id))
	return calculate_price(catch_data, supplier_id, true)


func calculate_price(catch_data: Dictionary, supplier_id: String = "", include_freshness: bool = true) -> int:
	var service := _fish_price_service()
	if service != null and service.has_method("calculate_price"):
		return int(service.call("calculate_price", catch_data, supplier_id, include_freshness))
	var breakdown: Dictionary = calculate_breakdown(catch_data, supplier_id, include_freshness)
	return max(roundi(float(breakdown.get("final_price", 0.0))), 1)


func calculate_breakdown(catch_data: Dictionary, supplier_id: String = "", include_freshness: bool = true) -> Dictionary:
	var service := _fish_price_service()
	if service != null and service.has_method("calculate_breakdown"):
		var service_value = service.call("calculate_breakdown", catch_data, supplier_id, include_freshness)
		if service_value is Dictionary:
			return service_value

	var fish_id: String = str(catch_data.get("id", catch_data.get("fish_id", "")))
	var fish: Dictionary = FishDatabase.get_fish(fish_id)
	var weight_kg: float = max(float(catch_data.get("weight", 0.0)), 0.0)
	var raw_base_price_per_kg: float = float(catch_data.get("basePricePerKg", fish.get("basePricePerKg", fish.get("price_per_kg", 1.0))))
	var rarity_type: String = str(catch_data.get("rarityType", fish.get("rarityType", "common")))
	var status: String = str(catch_data.get("fish_status", ""))
	if status.is_empty() and not fish.is_empty():
		status = FishStatusSystem.get_status(fish, weight_kg)
	if status.is_empty():
		status = "undersized"

	var target_supplier_id: String = supplier_id
	if target_supplier_id.is_empty():
		target_supplier_id = SupplierManager.get_best_supplier_for_catch(_with_status(catch_data, status, rarity_type))

	var mass_common := _is_mass_common_fish(fish_id, rarity_type)
	var base_price_per_kg: float = _get_adjusted_base_price_per_kg(fish_id, raw_base_price_per_kg, mass_common)
	var base_value: float = base_price_per_kg * weight_kg
	var rarity_multiplier: float = get_rarity_multiplier(rarity_type)
	var quality_multiplier: float = _get_adjusted_quality_multiplier(status, FishStatusSystem.get_quality_multiplier(status), mass_common)
	var raw_market_multiplier: float = DynamicMarketManager.get_demand_multiplier(fish_id, str(catch_data.get("waterbody_id", "")))
	var market_multiplier: float = _get_adjusted_market_multiplier(status, raw_market_multiplier, mass_common)
	var supplier_multiplier: float = SupplierManager.get_supplier_bonus_multiplier(_with_status(catch_data, status, rarity_type), target_supplier_id)
	if supplier_multiplier <= 0.0:
		supplier_multiplier = 1.0
		target_supplier_id = "local_market"
	supplier_multiplier = _get_adjusted_supplier_multiplier(status, supplier_multiplier, mass_common)

	var raw_freshness_multiplier: float = FishFreshnessManager.get_price_multiplier(catch_data) if include_freshness else 1.0
	var freshness_multiplier: float = _get_adjusted_freshness_multiplier(raw_freshness_multiplier, mass_common)
	var final_price: float = maxf(base_value * rarity_multiplier * quality_multiplier * market_multiplier * supplier_multiplier * freshness_multiplier, 1.0)

	return {
		"fish_id": fish_id,
		"weight_kg": weight_kg,
		"raw_base_price_per_kg": raw_base_price_per_kg,
		"base_price_per_kg": base_price_per_kg,
		"base_value": base_value,
		"rarityType": rarity_type,
		"rarity_multiplier": rarity_multiplier,
		"fish_status": status,
		"quality_multiplier": quality_multiplier,
		"raw_marketDemandMultiplier": raw_market_multiplier,
		"marketDemandMultiplier": market_multiplier,
		"supplier_id": target_supplier_id,
		"supplier_name": SupplierManager.get_supplier_title(target_supplier_id),
		"supplierBonusMultiplier": supplier_multiplier,
		"raw_freshnessMultiplier": raw_freshness_multiplier,
		"freshnessMultiplier": freshness_multiplier,
		"final_price": final_price
	}


func get_rarity_multiplier(rarity_type: String) -> float:
	var service := _fish_price_service()
	if service != null and service.has_method("get_rarity_multiplier"):
		return float(service.call("get_rarity_multiplier", rarity_type))
	return float(RARITY_MULTIPLIERS.get(rarity_type, 1.0))


func get_rarity_title(rarity_type: String) -> String:
	var service := _fish_price_service()
	if service != null and service.has_method("get_rarity_title"):
		return str(service.call("get_rarity_title", rarity_type))
	match rarity_type:
		"rare":
			return "Редкий вид"
		"legendary_species":
			return "Легендарный вид"
		_:
			return "Обычный вид"


func _is_mass_common_fish(fish_id: String, rarity_type: String) -> bool:
	return rarity_type == "common" and MASS_COMMON_PRICE_PER_KG_CAPS.has(fish_id)


func _get_adjusted_base_price_per_kg(fish_id: String, raw_price_per_kg: float, mass_common: bool) -> float:
	if not mass_common:
		return raw_price_per_kg
	return minf(raw_price_per_kg, float(MASS_COMMON_PRICE_PER_KG_CAPS.get(fish_id, raw_price_per_kg)))


func _get_adjusted_quality_multiplier(status: String, raw_multiplier: float, mass_common: bool) -> float:
	if not mass_common:
		return raw_multiplier
	match status:
		"keeper":
			return minf(raw_multiplier, 2.35)
		"trophy":
			return minf(raw_multiplier, 4.35)
		_:
			return minf(raw_multiplier, 0.70)


func _get_adjusted_market_multiplier(status: String, raw_multiplier: float, mass_common: bool) -> float:
	if not mass_common:
		return raw_multiplier
	match status:
		"trophy":
			return minf(raw_multiplier, 1.65)
		"keeper":
			return minf(raw_multiplier, 1.55)
		_:
			return minf(raw_multiplier, 1.25)


func _get_adjusted_supplier_multiplier(status: String, raw_multiplier: float, mass_common: bool) -> float:
	if not mass_common:
		return raw_multiplier
	return minf(raw_multiplier, 1.35 if status == "trophy" else 1.22)


func _get_adjusted_freshness_multiplier(raw_multiplier: float, mass_common: bool) -> float:
	return minf(raw_multiplier, 1.10) if mass_common else raw_multiplier


func _with_status(catch_data: Dictionary, status: String, rarity_type: String) -> Dictionary:
	var result: Dictionary = catch_data.duplicate(true)
	result["fish_status"] = status
	result["rarityType"] = rarity_type
	return result


func _fish_price_service() -> Node:
	return get_node_or_null("/root/FishPriceService")
