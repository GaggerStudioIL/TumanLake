extends RefCounted

const DEFAULT_BUYER_IDS := [
	"local_market",
	"fish_shop",
	"cannery",
	"restaurant",
	"wholesale_buyer",
	"collector",
	"export_company"
]

const TEST_FISH_CASES := [
	{"fish_id": "roach", "weight": 0.12, "status": "undersized", "label": "small_roach"},
	{"fish_id": "roach", "weight": 0.32, "status": "keeper", "label": "keeper_roach"},
	{"fish_id": "roach", "weight": 0.58, "status": "trophy", "label": "trophy_roach"},
	{"fish_id": "bream", "weight": 1.20, "status": "keeper", "label": "keeper_bream"},
	{"fish_id": "bream", "weight": 2.80, "status": "trophy", "label": "trophy_bream"},
	{"fish_id": "young_pike", "weight": 1.10, "status": "keeper", "label": "rare_young_pike"},
	{"fish_id": "mist_carp", "weight": 8.00, "status": "keeper", "label": "legendary_mist_carp"},
	{"fish_id": "bleak", "weight": 0.03, "status": "undersized", "label": "tiny_bleak"},
	{"fish_id": "ruffe", "weight": 0.06, "status": "undersized", "label": "tiny_ruffe"}
]

const SIMULATED_REPUTATION_LEVELS := [0, 30, 120, 180, 250]


func print_report() -> void:
	if BuildConfig.ENABLE_VERBOSE_LOGS:
		print(build_report())


func build_report() -> String:
	var lines: Array = []
	var samples := _build_test_fish_samples()

	_append_report_block(lines, "Current Reputation", samples, -1)
	for reputation in SIMULATED_REPUTATION_LEVELS:
		_append_report_block(lines, "Simulated Reputation %d" % int(reputation), samples, int(reputation))

	return _join_lines(lines)


func _append_report_block(lines: Array, title: String, samples: Array, reputation_override: int) -> void:
	lines.append("=== Economy Buyer Price Debug: %s ===" % title)
	lines.append("")
	for fish in samples:
		lines.append(_format_fish_header(fish))
		for buyer_id in _get_buyer_ids():
			lines.append("%s: %s" % [_get_buyer_title(buyer_id), _format_offer(fish, buyer_id, reputation_override)])
		lines.append("")
	lines.append("")


func _build_test_fish_samples() -> Array:
	var result: Array = []
	for item in TEST_FISH_CASES:
		if not (item is Dictionary):
			continue
		var sample := _make_test_fish(item)
		if not sample.is_empty():
			result.append(sample)
	return result


func _make_test_fish(case_data: Dictionary) -> Dictionary:
	var fish_id := str(case_data.get("fish_id", ""))
	var fish_data: Dictionary = FishDatabase.get_fish(fish_id)
	if fish_data.is_empty():
		return {}

	var weight := float(case_data.get("weight", fish_data.get("min_weight", 0.01)))
	var status := str(case_data.get("status", ""))
	if status.is_empty():
		status = FishStatusSystem.get_status(fish_data, weight)

	var rarity_type := str(fish_data.get("rarityType", fish_data.get("rarity", "common")))
	var base_price_per_kg := float(fish_data.get("basePricePerKg", fish_data.get("price_per_kg", 1.0)))
	var sample := fish_data.duplicate(true)
	sample["id"] = fish_id
	sample["fish_id"] = fish_id
	sample["name"] = str(fish_data.get("name", fish_id))
	sample["weight"] = weight
	sample["length"] = float(case_data.get("length", maxf(weight * 28.0, 6.0)))
	sample["rarityType"] = rarity_type
	sample["fish_status"] = status
	sample["fish_status_title"] = FishStatusSystem.get_status_title(status)
	sample["basePricePerKg"] = base_price_per_kg
	sample["price"] = maxi(roundi(weight * base_price_per_kg), 1)
	sample["is_trophy_status"] = status == FishStatusSystem.STATUS_TROPHY
	sample["debug_label"] = str(case_data.get("label", fish_id))
	return sample


func _format_fish_header(fish: Dictionary) -> String:
	var watch_suffix := " [LEGENDARY PRICE WATCH]" if str(fish.get("id", "")) == "mist_carp" else ""
	return "Fish: %s (%s), %.2f кг, %s, %s%s" % [
		str(fish.get("name", fish.get("id", "-"))),
		str(fish.get("id", "-")),
		float(fish.get("weight", 0.0)),
		str(fish.get("fish_status", "undersized")),
		str(fish.get("rarityType", "common")),
		watch_suffix
	]


func _format_offer(fish: Dictionary, buyer_id: String, reputation_override: int) -> String:
	if reputation_override < 0:
		return _format_current_offer(fish, buyer_id)

	var access := _get_simulated_access_result(fish, buyer_id, reputation_override)
	if not bool(access.get("unlocked", false)):
		return "blocked / %s" % str(access.get("reason", "buyer locked"))
	if not bool(access.get("accepted", false)):
		return "blocked / %s" % str(access.get("reason", "buyer does not accept this fish"))

	var breakdown := _calculate_simulated_price_breakdown(fish, buyer_id, reputation_override)
	var price := int(breakdown.get("final_price", fish.get("price", 1)))
	var details := _format_breakdown_details(breakdown)
	if details.is_empty():
		return str(price)
	return "%d (%s)" % [price, details]


func _format_current_offer(fish: Dictionary, buyer_id: String) -> String:
	var access_service := _buyer_access_service()
	var price_service := _fish_price_service()
	if access_service != null:
		if access_service.has_method("is_buyer_unlocked") and not bool(access_service.call("is_buyer_unlocked", buyer_id)):
			return "blocked / %s" % _get_lock_reason(access_service, buyer_id)
		if access_service.has_method("can_buyer_accept_fish") and not bool(access_service.call("can_buyer_accept_fish", buyer_id, fish)):
			return "blocked / %s" % _get_rejection_reason(access_service, buyer_id, fish)

	var price := 0
	var breakdown: Dictionary = {}
	if price_service != null and price_service.has_method("calculate_breakdown"):
		var value = price_service.call("calculate_breakdown", fish, buyer_id, true)
		if value is Dictionary:
			breakdown = value
			price = maxi(roundi(float(breakdown.get("final_price", 0.0))), 1)
	if price <= 0:
		price = maxi(int(fish.get("price", 1)), 1)

	var details := _format_breakdown_details(breakdown)
	if details.is_empty():
		return str(price)
	return "%d (%s)" % [price, details]


func _format_price_details(fish: Dictionary, buyer_id: String) -> String:
	var price_service := _fish_price_service()
	if price_service == null or not price_service.has_method("calculate_breakdown"):
		return ""

	var value = price_service.call("calculate_breakdown", fish, buyer_id, true)
	if not (value is Dictionary):
		return ""
	var breakdown: Dictionary = value
	return _format_breakdown_details(breakdown)


func _format_breakdown_details(breakdown: Dictionary) -> String:
	if breakdown.is_empty():
		return ""
	return "status x%.2f, fresh x%.2f, buyer x%.2f" % [
		float(breakdown.get("quality_multiplier", 1.0)),
		float(breakdown.get("freshnessMultiplier", 1.0)),
		float(breakdown.get("supplierBonusMultiplier", 1.0))
	]


func _get_simulated_access_result(fish: Dictionary, buyer_id: String, reputation_override: int) -> Dictionary:
	var supplier := _get_supplier(buyer_id)
	if supplier.is_empty():
		return {"unlocked": false, "accepted": false, "reason": "Неизвестный покупатель"}

	var min_reputation := int(supplier.get("min_reputation", 0))
	if reputation_override < min_reputation:
		return {
			"unlocked": false,
			"accepted": false,
			"reason": "Нужна репутация: %d" % min_reputation
		}

	var reason := _get_simulated_rejection_reason(supplier, fish)
	return {
		"unlocked": true,
		"accepted": reason.is_empty(),
		"reason": "Готово к продаже" if reason.is_empty() else reason
	}


func _get_simulated_rejection_reason(supplier: Dictionary, fish: Dictionary) -> String:
	var fish_id: String = str(fish.get("id", fish.get("fish_id", "")))
	var rarity_type: String = str(fish.get("rarityType", "common"))
	var status: String = str(fish.get("fish_status", "undersized"))
	var accepted_rarity_types := _as_array(supplier.get("accepted_rarity_types", []))
	var accepts_trophy_or_rare := bool(supplier.get("accepts_trophy_or_rare", false))
	var rare_or_trophy := status == FishStatusSystem.STATUS_TROPHY or accepted_rarity_types.has(rarity_type)

	if not accepts_trophy_or_rare or not rare_or_trophy:
		var min_status := str(supplier.get("min_status", "undersized"))
		if not FishStatusSystem.meets_min_status(status, min_status):
			return "Нужен статус: %s" % FishStatusSystem.get_status_title(min_status)

	var min_weight_kg := float(supplier.get("min_weight_kg", 0.0))
	if min_weight_kg > 0.0 and float(fish.get("weight", 0.0)) < min_weight_kg:
		return "Нужен вес от %.1f кг" % min_weight_kg

	var accepted_fish_ids := _as_array(supplier.get("accepted_fish_ids", []))
	if not accepted_fish_ids.is_empty() and not accepted_fish_ids.has(fish_id):
		return "Этот вид не принимается"

	if not accepted_rarity_types.is_empty() and not accepted_rarity_types.has(rarity_type):
		if not accepts_trophy_or_rare or status != FishStatusSystem.STATUS_TROPHY:
			return "Нужна подходящая редкость"

	return ""


func _calculate_simulated_price_breakdown(fish: Dictionary, buyer_id: String, reputation_override: int) -> Dictionary:
	var price_service := _fish_price_service()
	if price_service == null or not price_service.has_method("calculate_breakdown"):
		return {"final_price": maxi(int(fish.get("price", 1)), 1)}

	var value = price_service.call("calculate_breakdown", fish, buyer_id, true)
	if not (value is Dictionary):
		return {"final_price": maxi(int(fish.get("price", 1)), 1)}

	var breakdown: Dictionary = (value as Dictionary).duplicate(true)
	var simulated_buyer_multiplier := _calculate_simulated_buyer_multiplier(fish, buyer_id, reputation_override)
	var base_value := float(breakdown.get("base_value", 1.0))
	var rarity_multiplier := float(breakdown.get("rarity_multiplier", 1.0))
	var quality_multiplier := float(breakdown.get("quality_multiplier", 1.0))
	var market_multiplier := float(breakdown.get("marketDemandMultiplier", 1.0))
	var freshness_multiplier := float(breakdown.get("freshnessMultiplier", 1.0))
	var final_price := maxf(base_value * rarity_multiplier * quality_multiplier * market_multiplier * simulated_buyer_multiplier * freshness_multiplier, 1.0)

	breakdown["supplier_id"] = buyer_id
	breakdown["supplier_name"] = _get_buyer_title(buyer_id)
	breakdown["supplierBonusMultiplier"] = simulated_buyer_multiplier
	breakdown["final_price"] = maxi(roundi(final_price), 1)
	return breakdown


func _calculate_simulated_buyer_multiplier(fish: Dictionary, buyer_id: String, reputation_override: int) -> float:
	var supplier := _get_supplier(buyer_id)
	var base_multiplier := float(supplier.get("price_multiplier", 1.0))
	var reputation_bonus := _get_simulated_reputation_bonus(buyer_id, reputation_override)
	var raw_multiplier := snappedf(clampf(base_multiplier + reputation_bonus, 0.5, 1.85), 0.01)
	var price_service := _fish_price_service()
	if price_service != null and price_service.has_method("_get_adjusted_supplier_multiplier") and price_service.has_method("_is_mass_common_fish"):
		var fish_id := str(fish.get("id", fish.get("fish_id", "")))
		var rarity_type := str(fish.get("rarityType", "common"))
		var status := str(fish.get("fish_status", "undersized"))
		var mass_common := bool(price_service.call("_is_mass_common_fish", fish_id, rarity_type))
		return float(price_service.call("_get_adjusted_supplier_multiplier", status, raw_multiplier, mass_common))
	return raw_multiplier


func _get_simulated_reputation_bonus(buyer_id: String, reputation_override: int) -> float:
	var supplier_manager := _supplier_manager()
	if supplier_manager != null and supplier_manager.has_method("get_supplier_reputation_bonus"):
		return float(supplier_manager.call("get_supplier_reputation_bonus", buyer_id, reputation_override))
	return minf(float(maxi(reputation_override, 0)) / 1000.0, 0.18)


func _get_buyer_ids() -> Array:
	var supplier_manager := _supplier_manager()
	if supplier_manager != null and supplier_manager.has_method("get_primary_supplier_ids"):
		var value = supplier_manager.call("get_primary_supplier_ids")
		if value is Array:
			return value.duplicate()
	return DEFAULT_BUYER_IDS.duplicate()


func _get_buyer_title(buyer_id: String) -> String:
	var supplier_manager := _supplier_manager()
	if supplier_manager != null and supplier_manager.has_method("get_supplier_title"):
		return str(supplier_manager.call("get_supplier_title", buyer_id))
	return buyer_id


func _get_supplier(buyer_id: String) -> Dictionary:
	var supplier_manager := _supplier_manager()
	if supplier_manager != null and supplier_manager.has_method("get_supplier"):
		var value = supplier_manager.call("get_supplier", buyer_id)
		if value is Dictionary:
			return value
	return {}


func _get_lock_reason(access_service: Node, buyer_id: String) -> String:
	if access_service.has_method("get_buyer_lock_reason"):
		return str(access_service.call("get_buyer_lock_reason", buyer_id))
	return "buyer locked"


func _get_rejection_reason(access_service: Node, buyer_id: String, fish: Dictionary) -> String:
	if access_service.has_method("get_buyer_rejection_reason"):
		return str(access_service.call("get_buyer_rejection_reason", buyer_id, fish))
	return "buyer does not accept this fish"


func _buyer_access_service() -> Node:
	return _autoload("/root/BuyerAccessService")


func _fish_price_service() -> Node:
	return _autoload("/root/FishPriceService")


func _supplier_manager() -> Node:
	return _autoload("/root/SupplierManager")


func _as_array(value) -> Array:
	if value is Array:
		return value.duplicate()
	return []


func _autoload(path: String) -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return null
	return tree.root.get_node_or_null(path)


func _join_lines(lines: Array) -> String:
	var result := ""
	for line in lines:
		result += str(line) + "\n"
	return result.strip_edges(false, true)
