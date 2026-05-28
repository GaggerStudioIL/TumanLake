extends Node

const MIN_FINAL_PRICE := 1

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


func calculate_base_price(fish_instance: Dictionary) -> int:
	var prepared := prepare_price_fish(fish_instance)
	return maxi(roundi(_calculate_base_value(prepared)), MIN_FINAL_PRICE)


func calculate_status_multiplier(fish_instance: Dictionary) -> float:
	var prepared := prepare_price_fish(fish_instance)
	var fish_id: String = str(prepared.get("id", prepared.get("fish_id", "")))
	var rarity_type: String = str(prepared.get("rarityType", "common"))
	var mass_common := _is_mass_common_fish(fish_id, rarity_type)
	var status: String = str(prepared.get("fish_status", "undersized"))
	return _get_adjusted_quality_multiplier(status, FishStatusSystem.get_quality_multiplier(status), mass_common)


func calculate_rarity_multiplier(fish_instance: Dictionary) -> float:
	var prepared := prepare_price_fish(fish_instance)
	return get_rarity_multiplier(str(prepared.get("rarityType", "common")))


func calculate_market_multiplier(fish_id: String, waterbody_id: String = "", fish_instance: Dictionary = {}) -> float:
	var prepared := prepare_price_fish(fish_instance) if not fish_instance.is_empty() else {"id": fish_id, "rarityType": "common", "fish_status": "undersized"}
	var rarity_type: String = str(prepared.get("rarityType", "common"))
	var status: String = str(prepared.get("fish_status", "undersized"))
	var mass_common := _is_mass_common_fish(fish_id, rarity_type)
	var raw_market_multiplier: float = DynamicMarketManager.get_demand_multiplier(fish_id, waterbody_id)
	return _get_adjusted_market_multiplier(status, raw_market_multiplier, mass_common)


func calculate_buyer_multiplier(buyer_id: String, fish_instance: Dictionary = {}) -> float:
	if buyer_id.is_empty():
		return 1.0
	if fish_instance.is_empty():
		var supplier := _get_supplier(buyer_id)
		var base_multiplier := float(supplier.get("price_multiplier", 1.0))
		var reputation_bonus := _get_supplier_reputation_bonus(buyer_id)
		return snappedf(clamp(base_multiplier + reputation_bonus, 0.5, 1.85), 0.01)

	var prepared := prepare_price_fish(fish_instance)
	var fish_id: String = str(prepared.get("id", prepared.get("fish_id", "")))
	var rarity_type: String = str(prepared.get("rarityType", "common"))
	var status: String = str(prepared.get("fish_status", "undersized"))
	var mass_common := _is_mass_common_fish(fish_id, rarity_type)
	var raw_multiplier: float = SupplierManager.get_supplier_bonus_multiplier(prepared, buyer_id)
	return _get_adjusted_supplier_multiplier(status, raw_multiplier, mass_common)


func calculate_final_price(fish_instance: Dictionary, buyer_id: String = "local_market") -> int:
	return calculate_price(fish_instance, buyer_id, true)


func calculate_catch_base_price(catch_data: Dictionary, buyer_id: String = "") -> int:
	return calculate_price(catch_data, buyer_id, false)


func calculate_sell_price(catch_data: Dictionary, buyer_id: String = "") -> int:
	return calculate_price(catch_data, buyer_id, true)


func calculate_price(catch_data: Dictionary, buyer_id: String = "", include_freshness: bool = true) -> int:
	var breakdown := calculate_breakdown(catch_data, buyer_id, include_freshness)
	return maxi(roundi(float(breakdown.get("final_price", 0.0))), MIN_FINAL_PRICE)


func calculate_breakdown(catch_data: Dictionary, buyer_id: String = "", include_freshness: bool = true) -> Dictionary:
	var prepared := prepare_price_fish(catch_data)
	var fish_id: String = str(prepared.get("id", prepared.get("fish_id", "")))
	var weight_kg: float = maxf(float(prepared.get("weight", 0.0)), 0.0)
	var raw_base_price_per_kg: float = _get_raw_base_price_per_kg(prepared)
	var rarity_type: String = str(prepared.get("rarityType", "common"))
	var status: String = str(prepared.get("fish_status", "undersized"))
	var target_buyer_id := buyer_id if not buyer_id.is_empty() else "local_market"

	var mass_common := _is_mass_common_fish(fish_id, rarity_type)
	var base_price_per_kg: float = _get_adjusted_base_price_per_kg(fish_id, raw_base_price_per_kg, mass_common)
	var base_value: float = base_price_per_kg * weight_kg
	var rarity_multiplier: float = get_rarity_multiplier(rarity_type)
	var quality_multiplier: float = _get_adjusted_quality_multiplier(status, FishStatusSystem.get_quality_multiplier(status), mass_common)
	var raw_market_multiplier: float = DynamicMarketManager.get_demand_multiplier(fish_id, str(prepared.get("waterbody_id", "")))
	var market_multiplier: float = _get_adjusted_market_multiplier(status, raw_market_multiplier, mass_common)
	var raw_buyer_multiplier: float = SupplierManager.get_supplier_bonus_multiplier(prepared, target_buyer_id)
	if raw_buyer_multiplier <= 0.0:
		raw_buyer_multiplier = 1.0
	var buyer_multiplier: float = _get_adjusted_supplier_multiplier(status, raw_buyer_multiplier, mass_common)
	var raw_freshness_multiplier: float = FishFreshnessManager.get_price_multiplier(prepared) if include_freshness else 1.0
	var freshness_multiplier: float = _get_adjusted_freshness_multiplier(raw_freshness_multiplier, mass_common)
	var final_price: float = maxf(base_value * rarity_multiplier * quality_multiplier * market_multiplier * buyer_multiplier * freshness_multiplier, float(MIN_FINAL_PRICE))

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
		"supplier_id": target_buyer_id,
		"supplier_name": SupplierManager.get_supplier_title(target_buyer_id),
		"supplierBonusMultiplier": buyer_multiplier,
		"raw_freshnessMultiplier": raw_freshness_multiplier,
		"freshnessMultiplier": freshness_multiplier,
		"final_price": final_price
	}


func prepare_price_fish(fish_instance: Dictionary) -> Dictionary:
	var access_service := _buyer_access_service()
	if access_service != null and access_service.has_method("prepare_fish_for_access"):
		var value = access_service.call("prepare_fish_for_access", fish_instance)
		if value is Dictionary:
			return value

	var result := fish_instance.duplicate(true)
	var fish_id := str(result.get("id", result.get("fish_id", "")))
	var fish: Dictionary = FishDatabase.get_fish(fish_id)
	if not fish.is_empty():
		result["rarityType"] = str(result.get("rarityType", fish.get("rarityType", fish.get("rarity", "common"))))
		if not result.has("fish_status") or str(result.get("fish_status", "")).is_empty():
			result["fish_status"] = FishStatusSystem.get_status(fish, float(result.get("weight", 0.0)))
	else:
		result["rarityType"] = str(result.get("rarityType", "common"))
		result["fish_status"] = str(result.get("fish_status", "undersized"))
	return result


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


func _calculate_base_value(prepared: Dictionary) -> float:
	var fish_id: String = str(prepared.get("id", prepared.get("fish_id", "")))
	var rarity_type: String = str(prepared.get("rarityType", "common"))
	var mass_common := _is_mass_common_fish(fish_id, rarity_type)
	var base_price_per_kg: float = _get_adjusted_base_price_per_kg(fish_id, _get_raw_base_price_per_kg(prepared), mass_common)
	return base_price_per_kg * maxf(float(prepared.get("weight", 0.0)), 0.0)


func _get_raw_base_price_per_kg(prepared: Dictionary) -> float:
	var fish_id := str(prepared.get("id", prepared.get("fish_id", "")))
	var fish: Dictionary = FishDatabase.get_fish(fish_id)
	return float(prepared.get("basePricePerKg", fish.get("basePricePerKg", fish.get("price_per_kg", 1.0))))


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


func _get_supplier(buyer_id: String) -> Dictionary:
	var supplier_manager := get_node_or_null("/root/SupplierManager")
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


func _get_supplier_reputation_bonus(buyer_id: String) -> float:
	if SupplierManager != null and SupplierManager.has_method("get_supplier_reputation_bonus"):
		return float(SupplierManager.call("get_supplier_reputation_bonus", buyer_id))
	return minf(float(_get_reputation(buyer_id)) / 1000.0, 0.18)


func _buyer_access_service() -> Node:
	return get_node_or_null("/root/BuyerAccessService")
