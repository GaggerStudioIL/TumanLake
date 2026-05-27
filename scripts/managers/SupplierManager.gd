extends Node

const SUPPLIERS := {
	"local_market": {
		"name": "Местный рынок",
		"price_multiplier": 1.00,
		"min_status": "undersized",
		"min_reputation": 0,
		"accepted_fish_ids": [],
		"accepted_rarity_types": []
	},
	"fish_shop": {
		"name": "Рыбная лавка",
		"price_multiplier": 1.08,
		"min_status": "keeper",
		"min_reputation": 0,
		"accepted_fish_ids": [],
		"accepted_rarity_types": ["common", "rare"]
	},
	"restaurant": {
		"name": "Ресторан",
		"price_multiplier": 1.18,
		"min_status": "keeper",
		"min_reputation": 50,
		"accepted_fish_ids": ["bream", "zander", "pike", "catfish", "tench", "perch", "crucian", "eel"],
		"accepted_rarity_types": []
	},
	"elite_restaurant": {
		"name": "Элитный ресторан",
		"price_multiplier": 1.36,
		"min_status": "trophy",
		"min_reputation": 180,
		"accepted_fish_ids": [],
		"accepted_rarity_types": ["rare", "legendary_species"]
	},
	"factory": {
		"name": "Переработка",
		"price_multiplier": 0.88,
		"min_status": "undersized",
		"min_reputation": 80,
		"accepted_fish_ids": ["bleak", "roach", "rudd", "crucian", "silver_crucian", "golden_crucian", "bream", "white_bream", "skimmer_bream"],
		"accepted_rarity_types": ["common"]
	},
	"collector": {
		"name": "Коллекционер",
		"price_multiplier": 1.68,
		"min_status": "trophy",
		"min_reputation": 320,
		"accepted_fish_ids": [],
		"accepted_rarity_types": ["legendary_species"]
	},
	"export_company": {
		"name": "Экспортная компания",
		"price_multiplier": 1.52,
		"min_status": "keeper",
		"min_reputation": 500,
		"accepted_fish_ids": [],
		"accepted_rarity_types": ["rare", "legendary_species"]
	}
}

func get_supplier(supplier_id: String) -> Dictionary:
	return (SUPPLIERS.get(supplier_id, {}) as Dictionary).duplicate(true)


func get_supplier_ids() -> Array:
	return SUPPLIERS.keys()


func get_supplier_title(supplier_id: String) -> String:
	var supplier: Dictionary = get_supplier(supplier_id)
	return str(supplier.get("name", supplier_id))


func get_available_suppliers() -> Array:
	var result: Array = []
	for supplier_id in SUPPLIERS.keys():
		if _is_supplier_unlocked(str(supplier_id)):
			result.append(str(supplier_id))
	return result


func can_buy(catch_data: Dictionary, supplier_id: String) -> bool:
	var supplier: Dictionary = get_supplier(supplier_id)
	if supplier.is_empty() or not _is_supplier_unlocked(supplier_id):
		return false

	var fish_id: String = str(catch_data.get("id", catch_data.get("fish_id", "")))
	var fish: Dictionary = FishDatabase.get_fish(fish_id)
	var rarity_type: String = str(catch_data.get("rarityType", fish.get("rarityType", "common")))
	var status: String = str(catch_data.get("fish_status", _get_status_for_catch(fish, catch_data)))
	var min_status: String = str(supplier.get("min_status", "undersized"))
	if not FishStatusSystem.meets_min_status(status, min_status):
		return false

	var accepted_fish_ids: Array = supplier.get("accepted_fish_ids", [])
	if not accepted_fish_ids.is_empty() and not accepted_fish_ids.has(fish_id):
		return false

	var accepted_rarity_types: Array = supplier.get("accepted_rarity_types", [])
	if not accepted_rarity_types.is_empty() and not accepted_rarity_types.has(rarity_type):
		return false

	return true


func get_best_supplier_for_catch(catch_data: Dictionary) -> String:
	var best_supplier_id := "local_market"
	var best_multiplier := 0.0

	for supplier_id in get_available_suppliers():
		var multiplier: float = get_supplier_bonus_multiplier(catch_data, str(supplier_id))
		if multiplier > best_multiplier:
			best_multiplier = multiplier
			best_supplier_id = str(supplier_id)

	return best_supplier_id


func get_supplier_bonus_multiplier(catch_data: Dictionary, supplier_id: String = "") -> float:
	var target_supplier_id: String = supplier_id
	if target_supplier_id.is_empty():
		target_supplier_id = get_best_supplier_for_catch(catch_data)

	if not can_buy(catch_data, target_supplier_id):
		return 0.0

	var supplier: Dictionary = get_supplier(target_supplier_id)
	var base_multiplier: float = float(supplier.get("price_multiplier", 1.0))
	var reputation_bonus: float = min(float(_get_reputation(target_supplier_id)) / 1000.0, 0.18)
	return snappedf(clamp(base_multiplier + reputation_bonus, 0.5, 1.85), 0.01)


func get_supplier_summary(limit: int = 6) -> Array:
	var items: Array = []
	for supplier_id in SUPPLIERS.keys():
		var supplier: Dictionary = get_supplier(str(supplier_id))
		items.append({
			"id": str(supplier_id),
			"name": str(supplier.get("name", supplier_id)),
			"reputation": _get_reputation(str(supplier_id)),
			"unlocked": _is_supplier_unlocked(str(supplier_id)),
			"min_reputation": int(supplier.get("min_reputation", 0)),
			"price_multiplier": float(supplier.get("price_multiplier", 1.0))
		})

	items.sort_custom(func(a, b): return int(a.get("reputation", 0)) > int(b.get("reputation", 0)))
	if limit > 0 and items.size() > limit:
		return items.slice(0, limit)
	return items


func _is_supplier_unlocked(supplier_id: String) -> bool:
	var supplier: Dictionary = get_supplier(supplier_id)
	if supplier.is_empty():
		return false
	return _get_reputation(supplier_id) >= int(supplier.get("min_reputation", 0))


func _get_reputation(supplier_id: String) -> int:
	var reputation_system: Node = get_node_or_null("/root/ReputationSystem")
	if reputation_system != null and reputation_system.has_method("get_reputation"):
		return int(reputation_system.call("get_reputation", supplier_id))
	return 0


func _get_status_for_catch(fish: Dictionary, catch_data: Dictionary) -> String:
	if fish.is_empty():
		return "undersized"
	return FishStatusSystem.get_status(fish, float(catch_data.get("weight", 0.0)))
