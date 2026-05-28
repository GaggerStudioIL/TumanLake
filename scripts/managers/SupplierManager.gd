extends Node

const PRIMARY_SUPPLIER_IDS := [
	"local_market",
	"fish_shop",
	"restaurant",
	"wholesale_buyer",
	"collector",
	"export_company"
]

const SUPPLIERS := {
	"local_market": {
		"name": "Местный рынок",
		"description": "Покупает почти любой улов по стабильной цене.",
		"price_multiplier": 1.00,
		"min_status": "undersized",
		"min_reputation": 0,
		"accepted_fish_ids": [],
		"accepted_rarity_types": [],
		"accepts_text": "Все виды и любой размер.",
		"contracts_text": "Простые поставки по весу и количеству.",
		"unlock_text": "Открыт сразу."
	},
	"fish_shop": {
		"name": "Рыбная лавка",
		"description": "Покупает свежую рыбу, лучше платит за обычную рыбу.",
		"price_multiplier": 1.10,
		"min_status": "undersized",
		"min_reputation": 0,
		"accepted_fish_ids": [],
		"accepted_rarity_types": ["common", "rare"],
		"accepts_text": "Обычные и редкие виды, включая мелкий улов.",
		"contracts_text": "Заказы на ходовую рыбу.",
		"unlock_text": "Открыта сразу."
	},
	"restaurant": {
		"name": "Ресторан",
		"description": "Покупает только качественную зачётную рыбу.",
		"price_multiplier": 1.22,
		"min_status": "keeper",
		"min_reputation": 50,
		"accepted_fish_ids": ["bream", "zander", "pike", "catfish", "tench", "perch", "crucian", "eel"],
		"accepted_rarity_types": [],
		"accepts_text": "Зачётную рыбу ресторанных видов.",
		"contracts_text": "Поставки в трактир и праздничные заказы.",
		"unlock_text": "Нужна репутация у ресторана: 50."
	},
	"wholesale_buyer": {
		"name": "Оптовик",
		"description": "Покупает крупные партии по весу.",
		"price_multiplier": 1.16,
		"min_status": "keeper",
		"min_reputation": 80,
		"accepted_fish_ids": [],
		"accepted_rarity_types": [],
		"min_weight_kg": 1.2,
		"accepts_text": "Зачётную рыбу от 1.2 кг или большие партии.",
		"contracts_text": "Партии по общему весу.",
		"unlock_text": "Нужна репутация у оптовика: 80."
	},
	"collector": {
		"name": "Коллекционер",
		"description": "Покупает редкие виды и трофеи.",
		"price_multiplier": 1.72,
		"min_status": "undersized",
		"min_reputation": 320,
		"accepted_fish_ids": [],
		"accepted_rarity_types": ["rare", "legendary_species"],
		"accepts_trophy_or_rare": true,
		"accepts_text": "Редкие виды и любые трофейные экземпляры.",
		"contracts_text": "Редкие заявки и трофейные поручения.",
		"unlock_text": "Нужна репутация у коллекционера: 320."
	},
	"export_company": {
		"name": "Экспортёр",
		"description": "Дорогой покупатель для поздней стадии игры.",
		"price_multiplier": 1.56,
		"min_status": "keeper",
		"min_reputation": 500,
		"accepted_fish_ids": [],
		"accepted_rarity_types": ["rare", "legendary_species"],
		"accepts_text": "Зачётные редкие и легендарные виды.",
		"contracts_text": "Дорогие экспортные поставки.",
		"unlock_text": "Нужна репутация у экспортёра: 500."
	},
	"factory": {
		"name": "Переработка",
		"description": "Старый покупатель из ранних сохранений.",
		"price_multiplier": 0.88,
		"min_status": "undersized",
		"min_reputation": 80,
		"accepted_fish_ids": ["bleak", "roach", "rudd", "crucian", "silver_crucian", "golden_crucian", "bream", "white_bream", "skimmer_bream"],
		"accepted_rarity_types": ["common"],
		"legacy": true,
		"accepts_text": "Мелкая обычная рыба.",
		"contracts_text": "Старые контракты.",
		"unlock_text": "Оставлено для совместимости сохранений."
	},
	"elite_restaurant": {
		"name": "Элитный ресторан",
		"description": "Старый покупатель из ранних сохранений.",
		"price_multiplier": 1.36,
		"min_status": "trophy",
		"min_reputation": 180,
		"accepted_fish_ids": [],
		"accepted_rarity_types": ["rare", "legendary_species"],
		"legacy": true,
		"accepts_text": "Трофеи и редкие виды.",
		"contracts_text": "Старые контракты.",
		"unlock_text": "Оставлено для совместимости сохранений."
	}
}

func get_supplier(supplier_id: String) -> Dictionary:
	return (SUPPLIERS.get(supplier_id, {}) as Dictionary).duplicate(true)


func get_supplier_ids() -> Array:
	return SUPPLIERS.keys()


func get_primary_supplier_ids() -> Array:
	return PRIMARY_SUPPLIER_IDS.duplicate()


func get_supplier_title(supplier_id: String) -> String:
	var supplier: Dictionary = get_supplier(supplier_id)
	return str(supplier.get("name", supplier_id))


func is_buyer_unlocked(buyer_id: String) -> bool:
	var access_service := _buyer_access_service()
	if access_service != null and access_service.has_method("is_buyer_unlocked"):
		return bool(access_service.call("is_buyer_unlocked", buyer_id))
	return _is_supplier_unlocked(buyer_id)


func can_sell_to_buyer(buyer_id: String, fish_data: Dictionary) -> bool:
	var access_service := _buyer_access_service()
	if access_service != null and access_service.has_method("can_buyer_accept_fish"):
		return bool(access_service.call("can_buyer_accept_fish", buyer_id, fish_data))
	return can_buy(fish_data, buyer_id)


func get_available_suppliers() -> Array:
	var result: Array = []
	for supplier_id in PRIMARY_SUPPLIER_IDS:
		if _is_supplier_unlocked(str(supplier_id)):
			result.append(str(supplier_id))
	return result


func can_buy(catch_data: Dictionary, supplier_id: String) -> bool:
	var access_service := _buyer_access_service()
	if access_service != null and access_service.has_method("can_buyer_accept_fish"):
		return bool(access_service.call("can_buyer_accept_fish", supplier_id, catch_data))

	var supplier: Dictionary = get_supplier(supplier_id)
	if supplier.is_empty() or not _is_supplier_unlocked(supplier_id):
		return false

	var fish_id: String = str(catch_data.get("id", catch_data.get("fish_id", "")))
	var fish: Dictionary = FishDatabase.get_fish(fish_id)
	var rarity_type: String = str(catch_data.get("rarityType", fish.get("rarityType", "common")))
	var status: String = str(catch_data.get("fish_status", _get_status_for_catch(fish, catch_data)))
	var accepts_trophy_or_rare: bool = bool(supplier.get("accepts_trophy_or_rare", false))
	var accepted_rarity_types: Array = supplier.get("accepted_rarity_types", [])
	var rare_or_trophy: bool = status == FishStatusSystem.STATUS_TROPHY or accepted_rarity_types.has(rarity_type)
	if not accepts_trophy_or_rare or not rare_or_trophy:
		var min_status: String = str(supplier.get("min_status", "undersized"))
		if not FishStatusSystem.meets_min_status(status, min_status):
			return false

	var min_weight_kg: float = float(supplier.get("min_weight_kg", 0.0))
	if min_weight_kg > 0.0 and float(catch_data.get("weight", 0.0)) < min_weight_kg:
		return false

	var accepted_fish_ids: Array = supplier.get("accepted_fish_ids", [])
	if not accepted_fish_ids.is_empty() and not accepted_fish_ids.has(fish_id):
		return false

	if not accepted_rarity_types.is_empty() and not accepted_rarity_types.has(rarity_type):
		if not accepts_trophy_or_rare or status != FishStatusSystem.STATUS_TROPHY:
			return false

	return true


func get_available_buyers_for_fish(fish_instance: Dictionary) -> Array:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_available_buyers_for_fish"):
		var service_value = sales_service.call("get_available_buyers_for_fish", fish_instance)
		if service_value is Array:
			return service_value

	var result: Array = []
	for supplier_id in get_available_suppliers():
		if can_buy(fish_instance, str(supplier_id)):
			result.append(str(supplier_id))
	return result


func get_buyer_offer(fish_instance: Dictionary, buyer_id: String) -> Dictionary:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_offer_for_buyer"):
		var service_value = sales_service.call("get_offer_for_buyer", fish_instance, buyer_id)
		if service_value is Dictionary:
			return service_value

	var supplier: Dictionary = get_supplier(buyer_id)
	var fish: Dictionary = FishDatabase.get_fish(str(fish_instance.get("id", fish_instance.get("fish_id", ""))))
	var rarity_type: String = str(fish_instance.get("rarityType", fish.get("rarityType", "common")))
	var status: String = str(fish_instance.get("fish_status", _get_status_for_catch(fish, fish_instance)))
	var prepared := fish_instance.duplicate(true)
	prepared["fish_status"] = status
	prepared["rarityType"] = rarity_type

	var offer := {
		"buyer_id": buyer_id,
		"supplier_id": buyer_id,
		"buyer_name": str(supplier.get("name", buyer_id)),
		"supplier_name": str(supplier.get("name", buyer_id)),
		"accepted": false,
		"price": 0,
		"multiplier": 0.0,
		"buyer_multiplier": 0.0,
		"reason": "Неизвестный покупатель",
		"fish_status": status
	}

	if supplier.is_empty():
		return offer

	if not _is_supplier_unlocked(buyer_id):
		offer["reason"] = "Откроется при репутации %d" % int(supplier.get("min_reputation", 0))
		return offer

	if not can_buy(prepared, buyer_id):
		offer["reason"] = _get_rejection_reason(prepared, buyer_id)
		return offer

	var price_before_skill := 0
	var breakdown: Dictionary = {}
	var price_calculator: Node = get_node_or_null("/root/FishPriceCalculator")
	if price_calculator != null and price_calculator.has_method("calculate_sell_price"):
		price_before_skill = int(price_calculator.call("calculate_sell_price", prepared, buyer_id))
		if price_calculator.has_method("calculate_breakdown"):
			var breakdown_value = price_calculator.call("calculate_breakdown", prepared, buyer_id, true)
			if breakdown_value is Dictionary:
				breakdown = breakdown_value
	else:
		var base_price := int(prepared.get("price", 0))
		price_before_skill = maxi(roundi(float(base_price) * get_supplier_bonus_multiplier(prepared, buyer_id)), 0)

	var final_price := price_before_skill
	var player_data: Node = get_node_or_null("/root/PlayerData")
	if player_data != null and player_data.has_method("get_skill_adjusted_sell_price"):
		final_price = int(player_data.call("get_skill_adjusted_sell_price", price_before_skill))
	final_price = maxi(final_price, 1)

	var base_value: float = maxf(float(breakdown.get("base_value", prepared.get("price", 1.0))), 1.0)
	var final_multiplier: float = snappedf(float(final_price) / base_value, 0.01)
	offer["accepted"] = true
	offer["price"] = final_price
	offer["multiplier"] = final_multiplier
	offer["buyer_multiplier"] = float(breakdown.get("supplierBonusMultiplier", get_supplier_bonus_multiplier(prepared, buyer_id)))
	offer["market_multiplier"] = float(breakdown.get("marketDemandMultiplier", 1.0))
	offer["freshness_multiplier"] = float(breakdown.get("freshnessMultiplier", 1.0))
	offer["quality_multiplier"] = float(breakdown.get("quality_multiplier", 1.0))
	offer["reason"] = "Готово к продаже"
	return offer


func get_best_buyer_for_fish(fish_instance: Dictionary) -> String:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_best_buyer_for_fish"):
		return str(sales_service.call("get_best_buyer_for_fish", fish_instance))

	var best_buyer_id := ""
	var best_price := -1

	for supplier_id in PRIMARY_SUPPLIER_IDS:
		var offer: Dictionary = get_buyer_offer(fish_instance, str(supplier_id))
		if bool(offer.get("accepted", false)) and int(offer.get("price", 0)) > best_price:
			best_price = int(offer.get("price", 0))
			best_buyer_id = str(supplier_id)

	if best_buyer_id.is_empty():
		var fallback_offer: Dictionary = get_buyer_offer(fish_instance, "local_market")
		if bool(fallback_offer.get("accepted", false)):
			return "local_market"

	return best_buyer_id


func get_best_supplier_for_catch(catch_data: Dictionary) -> String:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_best_buyer_for_fish"):
		return str(sales_service.call("get_best_buyer_for_fish", catch_data))
	return get_best_buyer_for_fish(catch_data)


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
	for supplier_id in PRIMARY_SUPPLIER_IDS:
		var supplier: Dictionary = get_supplier(str(supplier_id))
		items.append({
			"id": str(supplier_id),
			"name": str(supplier.get("name", supplier_id)),
			"description": str(supplier.get("description", "")),
			"reputation": _get_reputation(str(supplier_id)),
			"unlocked": _is_supplier_unlocked(str(supplier_id)),
			"min_reputation": int(supplier.get("min_reputation", 0)),
			"price_multiplier": float(supplier.get("price_multiplier", 1.0)),
			"accepts_text": str(supplier.get("accepts_text", "Любой улов.")),
			"contracts_text": str(supplier.get("contracts_text", "Поставки улова.")),
			"unlock_text": str(supplier.get("unlock_text", "Открыт."))
		})

	items.sort_custom(func(a, b): return int(a.get("min_reputation", 0)) < int(b.get("min_reputation", 0)))
	if limit > 0 and items.size() > limit:
		return items.slice(0, limit)
	return items


func get_rejection_reason(catch_data: Dictionary, supplier_id: String) -> String:
	var access_service := _buyer_access_service()
	if access_service != null and access_service.has_method("get_buyer_rejection_reason"):
		return str(access_service.call("get_buyer_rejection_reason", supplier_id, catch_data))

	var supplier: Dictionary = get_supplier(supplier_id)
	if supplier.is_empty():
		return "Не принимает этот вид"
	if not _is_supplier_unlocked(supplier_id):
		return "Репутация %d" % int(supplier.get("min_reputation", 0))
	if can_buy(catch_data, supplier_id):
		return "Готово к продаже"
	return _get_rejection_reason(catch_data, supplier_id)


func _is_supplier_unlocked(supplier_id: String) -> bool:
	var supplier: Dictionary = get_supplier(supplier_id)
	if supplier.is_empty():
		return false
	var required_reputation := int(supplier.get("min_reputation", 0))
	if required_reputation <= 0:
		return true
	return _get_reputation(supplier_id) >= required_reputation


func _get_rejection_reason(catch_data: Dictionary, supplier_id: String) -> String:
	var supplier: Dictionary = get_supplier(supplier_id)
	var fish_id: String = str(catch_data.get("id", catch_data.get("fish_id", "")))
	var fish: Dictionary = FishDatabase.get_fish(fish_id)
	var rarity_type: String = str(catch_data.get("rarityType", fish.get("rarityType", "common")))
	var status: String = str(catch_data.get("fish_status", _get_status_for_catch(fish, catch_data)))
	var status_title := FishStatusSystem.get_status_title(status)
	var min_status := str(supplier.get("min_status", "undersized"))
	var accepted_rarity_types: Array = supplier.get("accepted_rarity_types", [])

	if bool(supplier.get("accepts_trophy_or_rare", false)) and status != FishStatusSystem.STATUS_TROPHY and not accepted_rarity_types.has(rarity_type):
		return "Нужен редкий вид или трофей"
	if not FishStatusSystem.meets_min_status(status, min_status):
		return "Нужен статус: %s" % FishStatusSystem.get_status_title(min_status)
	if float(supplier.get("min_weight_kg", 0.0)) > 0.0 and float(catch_data.get("weight", 0.0)) < float(supplier.get("min_weight_kg", 0.0)):
		return "Нужен вес от %.1f кг" % float(supplier.get("min_weight_kg", 0.0))
	var accepted_fish_ids: Array = supplier.get("accepted_fish_ids", [])
	if not accepted_fish_ids.is_empty() and not accepted_fish_ids.has(fish_id):
		return "Этот вид не принимается"
	if not accepted_rarity_types.is_empty() and not accepted_rarity_types.has(rarity_type):
		return "Нужна подходящая редкость"
	return "Не принимается: %s" % status_title


func _get_reputation(supplier_id: String) -> int:
	var reputation_system: Node = get_node_or_null("/root/ReputationSystem")
	if reputation_system != null and reputation_system.has_method("get_reputation"):
		return int(reputation_system.call("get_reputation", supplier_id))
	return 0


func _get_total_reputation() -> int:
	var reputation_system: Node = get_node_or_null("/root/ReputationSystem")
	if reputation_system != null and reputation_system.has_method("get_total_reputation"):
		return int(reputation_system.call("get_total_reputation"))
	return 0


func _get_status_for_catch(fish: Dictionary, catch_data: Dictionary) -> String:
	if fish.is_empty():
		return "undersized"
	return FishStatusSystem.get_status(fish, float(catch_data.get("weight", 0.0)))


func _buyer_access_service() -> Node:
	return get_node_or_null("/root/BuyerAccessService")


func _sales_service() -> Node:
	return get_node_or_null("/root/SalesService")
