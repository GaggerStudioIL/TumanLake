extends Node

const PRIMARY_SUPPLIER_IDS := [
	"local_market",
	"fish_shop",
	"cannery",
	"restaurant",
	"wholesale_buyer",
	"collector",
	"export_company"
]

const DEFAULT_REPUTATION_BONUS_CAP := 0.18
const SUPPLIER_REPUTATION_BONUS_CAPS := {
	"local_market": 0.0,
	"fish_shop": 0.02,
	"cannery": 0.03
}

const ACCESS_TOTAL_REPUTATION_REQUIREMENTS := {
	"local_market": 0,
	"fish_shop": 0,
	"cannery": 10,
	"restaurant": 30,
	"wholesale_buyer": 60,
	"collector": 120,
	"export_company": 180
}

const SUPPLIERS := {
	"local_market": {
		"name": "Местный рынок",
		"description": "Безопасный покупатель для любого улова. Платит ровно, без особых бонусов.",
		"price_multiplier": 1.00,
		"min_status": "undersized",
		"min_reputation": 0,
		"accepted_fish_ids": [],
		"accepted_rarity_types": [],
		"accepts_text": "Почти все виды, включая незачётную рыбу.",
		"contracts_text": "Простые поставки по весу и количеству.",
		"unlock_text": "Открыт сразу."
	},
	"fish_shop": {
		"name": "Рыбная лавка",
		"description": "Берёт свежую ходовую рыбу для витрины. Чуть лучше рынка, но без трофейных переплат.",
		"price_multiplier": 1.10,
		"min_status": "undersized",
		"min_reputation": 0,
		"accepted_fish_ids": [],
		"accepted_rarity_types": ["common", "rare"],
		"accepts_text": "Обычные и редкие виды, свежий мелкий улов тоже берёт.",
		"contracts_text": "Заказы на ходовую свежую рыбу.",
		"unlock_text": "Открыта сразу."
	},
	"cannery": {
		"name": "Консервный завод",
		"description": "Принимает даже старую рыбу. Платит меньше за свежую, но лучше остальных за несвежую.",
		"price_multiplier": 0.85,
		"min_status": "undersized",
		"min_reputation": 10,
		"accepted_fish_ids": [],
		"accepted_rarity_types": [],
		"freshness_price_floor": 0.50,
		"max_freshness_age_hours": -1.0,
		"accepts_text": "Почти любая рыба, включая несвежую и почти испорченную.",
		"contracts_text": "Массовые партии дешёвой и старой рыбы.",
		"unlock_text": "Откроется при общей репутации 10."
	},
	"restaurant": {
		"name": "Ресторан",
		"description": "Платит выше за свежую зачётную рыбу ресторанных видов. Мелочь не принимает.",
		"price_multiplier": 1.26,
		"min_status": "keeper",
		"min_reputation": 30,
		"accepted_fish_ids": ["bream", "zander", "pike", "catfish", "tench", "perch", "crucian", "eel"],
		"accepted_rarity_types": [],
		"accepts_text": "Свежую зачётную рыбу ресторанных видов.",
		"contracts_text": "Поставки в трактир и праздничные заказы.",
		"unlock_text": "Откроется при общей репутации 30."
	},
	"wholesale_buyer": {
		"name": "Коптильня",
		"description": "Берёт массовую обычную рыбу среднего размера. Хороша для партий без редких бонусов.",
		"price_multiplier": 1.14,
		"min_status": "keeper",
		"min_reputation": 60,
		"accepted_fish_ids": ["roach", "rudd", "perch", "crucian", "silver_crucian", "golden_crucian", "bream", "white_bream", "skimmer_bream", "tench"],
		"accepted_rarity_types": ["common"],
		"min_weight_kg": 0.4,
		"accepts_text": "Обычную зачётную рыбу от 0.4 кг для копчения.",
		"contracts_text": "Партии средней рыбы по общему весу.",
		"unlock_text": "Откроется при общей репутации 60."
	},
	"collector": {
		"name": "Трофейный коллекционер",
		"description": "Охотится за трофеями и редкими экземплярами. Обычную мелочь не берёт.",
		"price_multiplier": 1.68,
		"min_status": "undersized",
		"min_reputation": 120,
		"accepted_fish_ids": [],
		"accepted_rarity_types": ["rare", "legendary_species"],
		"accepts_trophy_or_rare": true,
		"accepts_text": "Редкие виды и любые трофейные экземпляры.",
		"contracts_text": "Редкие заявки и трофейные поручения.",
		"unlock_text": "Откроется при общей репутации 120."
	},
	"export_company": {
		"name": "Редкий торговец",
		"description": "Покупает зачётные редкие виды для дальних заказов. Требует надёжную репутацию.",
		"price_multiplier": 1.50,
		"min_status": "keeper",
		"min_reputation": 180,
		"accepted_fish_ids": [],
		"accepted_rarity_types": ["rare", "legendary_species"],
		"accepts_text": "Зачётные редкие и легендарные виды.",
		"contracts_text": "Редкие поставки с высоким чеком.",
		"unlock_text": "Откроется при общей репутации 180."
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
	var supplier: Dictionary = (SUPPLIERS.get(supplier_id, {}) as Dictionary).duplicate(true)
	_apply_supplier_freshness_defaults(supplier_id, supplier)
	return supplier


func _apply_supplier_freshness_defaults(supplier_id: String, supplier: Dictionary) -> void:
	if supplier.is_empty():
		return
	match supplier_id:
		"local_market":
			if not supplier.has("max_freshness_age_hours"):
				supplier["max_freshness_age_hours"] = -1.0
		"fish_shop":
			if not supplier.has("max_freshness_age_hours"):
				supplier["max_freshness_age_hours"] = 24.0
		"restaurant":
			if not supplier.has("max_freshness_age_hours"):
				supplier["max_freshness_age_hours"] = 12.0
		"wholesale_buyer":
			if not supplier.has("max_freshness_age_hours"):
				supplier["max_freshness_age_hours"] = 36.0
		"collector":
			if not supplier.has("max_freshness_age_hours"):
				supplier["max_freshness_age_hours"] = 48.0
		"export_company":
			if not supplier.has("max_freshness_age_hours"):
				supplier["max_freshness_age_hours"] = 24.0


func get_supplier_ids() -> Array:
	var result: Array = []

	for supplier_id in SUPPLIERS.keys():
		var supplier: Dictionary = SUPPLIERS.get(supplier_id, {})
		if bool(supplier.get("legacy", false)):
			continue
		result.append(str(supplier_id))

	return result


func get_primary_supplier_ids() -> Array:
	return PRIMARY_SUPPLIER_IDS.duplicate()


func get_supplier_title(supplier_id: String) -> String:
	var supplier: Dictionary = get_supplier(supplier_id)
	return str(supplier.get("name", supplier_id))


func get_required_total_reputation(supplier_id: String) -> int:
	return _get_required_total_reputation(supplier_id, get_supplier(supplier_id))


func get_supplier_lock_reason(supplier_id: String) -> String:
	return _get_total_reputation_lock_text(supplier_id, get_supplier(supplier_id))


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

	if not _meets_freshness_requirement(supplier, catch_data):
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
		offer["reason"] = _get_total_reputation_lock_text(buyer_id, supplier)
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
	var reputation_bonus: float = get_supplier_reputation_bonus(target_supplier_id)
	return snappedf(clamp(base_multiplier + reputation_bonus, 0.5, 1.85), 0.01)


func get_supplier_reputation_bonus(supplier_id: String, reputation_override: int = -1) -> float:
	var cap := float(SUPPLIER_REPUTATION_BONUS_CAPS.get(supplier_id, DEFAULT_REPUTATION_BONUS_CAP))
	if cap <= 0.0:
		return 0.0
	var reputation := reputation_override if reputation_override >= 0 else _get_reputation(supplier_id)
	return minf(float(maxi(reputation, 0)) / 1000.0, cap)


func get_supplier_summary(limit: int = 0) -> Array:
	var items: Array = []
	var total_reputation := _get_total_reputation()
	for supplier_id in PRIMARY_SUPPLIER_IDS:
		var supplier: Dictionary = get_supplier(str(supplier_id))
		var required_total := _get_required_total_reputation(str(supplier_id), supplier)
		var unlocked := _is_supplier_unlocked(str(supplier_id))
		items.append({
			"id": str(supplier_id),
			"name": str(supplier.get("name", supplier_id)),
			"description": str(supplier.get("description", "")),
			"reputation": _get_reputation(str(supplier_id)),
			"unlocked": unlocked,
			"min_reputation": required_total,
			"required_total_reputation": required_total,
			"total_reputation": total_reputation,
			"price_multiplier": float(supplier.get("price_multiplier", 1.0)),
			"accepts_text": str(supplier.get("accepts_text", "Любой улов.")),
			"contracts_text": str(supplier.get("contracts_text", "Поставки улова.")),
			"unlock_text": _get_supplier_unlock_text(str(supplier_id), supplier, unlocked, total_reputation)
		})

	items.sort_custom(func(a, b): return int(a.get("required_total_reputation", 0)) < int(b.get("required_total_reputation", 0)))
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
		return _get_total_reputation_lock_text(supplier_id, supplier)
	if can_buy(catch_data, supplier_id):
		return "Готово к продаже"
	return _get_rejection_reason(catch_data, supplier_id)


func _is_supplier_unlocked(supplier_id: String) -> bool:
	var supplier: Dictionary = get_supplier(supplier_id)
	if supplier.is_empty():
		return false
	var required_total_reputation := _get_required_total_reputation(supplier_id, supplier)
	if required_total_reputation <= 0:
		return true
	return _get_total_reputation() >= required_total_reputation


func _get_required_total_reputation(supplier_id: String, supplier: Dictionary = {}) -> int:
	if ACCESS_TOTAL_REPUTATION_REQUIREMENTS.has(supplier_id):
		return int(ACCESS_TOTAL_REPUTATION_REQUIREMENTS[supplier_id])
	if not supplier.is_empty() and supplier.has("unlock_total_reputation"):
		return int(supplier.get("unlock_total_reputation", 0))
	return int(supplier.get("min_reputation", 0)) if not supplier.is_empty() else 0


func _get_supplier_unlock_text(supplier_id: String, supplier: Dictionary, unlocked: bool, total_reputation: int = -1) -> String:
	var required_total := _get_required_total_reputation(supplier_id, supplier)
	if required_total <= 0:
		return str(supplier.get("unlock_text", "Открыт сразу."))
	var current_total := _get_total_reputation() if total_reputation < 0 else total_reputation
	if unlocked:
		return "Открыт: общая репутация %d / %d." % [current_total, required_total]
	return "Откроется при общей репутации %d.\nОбщая репутация: %d / %d." % [required_total, current_total, required_total]


func _get_total_reputation_lock_text(supplier_id: String, supplier: Dictionary = {}) -> String:
	var data := supplier if not supplier.is_empty() else get_supplier(supplier_id)
	var required_total := _get_required_total_reputation(supplier_id, data)
	var current_total := _get_total_reputation()
	if required_total <= 0:
		return "Открыт сразу."
	return "Откроется при общей репутации %d.\nОбщая репутация: %d / %d." % [required_total, current_total, required_total]


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


func _meets_freshness_requirement(supplier: Dictionary, catch_data: Dictionary) -> bool:
	var max_freshness_age_hours := float(supplier.get("max_freshness_age_hours", -1.0))
	if max_freshness_age_hours < 0.0:
		return true
	return FishFreshnessManager.get_fish_age_game_hours(catch_data) <= max_freshness_age_hours


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
