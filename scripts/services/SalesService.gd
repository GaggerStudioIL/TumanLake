extends Node

var last_sale_summary: Dictionary = {}


func get_available_buyers_for_fish(fish_instance: Dictionary) -> Array:
	var result: Array = []
	for buyer_id in _get_primary_buyer_ids():
		if can_sell_to_buyer(fish_instance, str(buyer_id)):
			result.append(str(buyer_id))
	return result


func get_best_buyer_for_fish(fish_instance: Dictionary) -> String:
	var best_buyer_id := ""
	var best_price := -1
	for buyer_id in _get_primary_buyer_ids():
		var offer := get_offer_for_buyer(fish_instance, str(buyer_id))
		if bool(offer.get("accepted", false)) and int(offer.get("price", 0)) > best_price:
			best_price = int(offer.get("price", 0))
			best_buyer_id = str(buyer_id)

	if best_buyer_id.is_empty():
		var fallback_offer := get_offer_for_buyer(fish_instance, "local_market")
		if bool(fallback_offer.get("accepted", false)):
			return "local_market"
	return best_buyer_id


func get_best_offer_for_fish(fish_instance: Dictionary) -> Dictionary:
	var best_buyer_id := get_best_buyer_for_fish(fish_instance)
	if best_buyer_id.is_empty():
		return _make_rejected_offer("", fish_instance, "Нет доступного покупателя.")
	return get_offer_for_buyer(fish_instance, best_buyer_id)


func get_offer_for_buyer(fish_instance: Dictionary, buyer_id: String) -> Dictionary:
	var prepared := prepare_sale_catch_data(fish_instance)
	var supplier: Dictionary = _get_supplier(buyer_id)
	var offer := _make_rejected_offer(buyer_id, prepared, "Неизвестный покупатель")

	if supplier.is_empty():
		return offer

	offer["buyer_name"] = str(supplier.get("name", buyer_id))
	offer["supplier_name"] = str(supplier.get("name", buyer_id))
	offer["fish_status"] = str(prepared.get("fish_status", "undersized"))

	var access_service := _buyer_access_service()
	if access_service != null:
		if access_service.has_method("is_buyer_unlocked") and not bool(access_service.call("is_buyer_unlocked", buyer_id)):
			offer["reason"] = str(access_service.call("get_buyer_lock_reason", buyer_id)) if access_service.has_method("get_buyer_lock_reason") else "Покупатель закрыт"
			return offer
		if access_service.has_method("can_buyer_accept_fish") and not bool(access_service.call("can_buyer_accept_fish", buyer_id, prepared)):
			offer["reason"] = str(access_service.call("get_buyer_rejection_reason", buyer_id, prepared)) if access_service.has_method("get_buyer_rejection_reason") else "Покупатель не принимает эту рыбу"
			return offer

	var price_before_skill := _calculate_price_before_skill(prepared, buyer_id)
	var final_price := price_before_skill
	if PlayerData.has_method("get_skill_adjusted_sell_price"):
		final_price = int(PlayerData.call("get_skill_adjusted_sell_price", price_before_skill))
	final_price = maxi(final_price, 1)

	var breakdown := _calculate_price_breakdown(prepared, buyer_id)
	var base_value: float = maxf(float(breakdown.get("base_value", prepared.get("price", 1.0))), 1.0)
	var final_multiplier: float = snappedf(float(final_price) / base_value, 0.01)

	offer["accepted"] = true
	offer["price"] = final_price
	offer["multiplier"] = final_multiplier
	offer["buyer_multiplier"] = float(breakdown.get("supplierBonusMultiplier", 1.0))
	offer["market_multiplier"] = float(breakdown.get("marketDemandMultiplier", 1.0))
	offer["freshness_multiplier"] = float(breakdown.get("freshnessMultiplier", 1.0))
	offer["quality_multiplier"] = float(breakdown.get("quality_multiplier", 1.0))
	offer["reason"] = "Готово к продаже"
	return offer


func can_sell_to_buyer(fish_instance: Dictionary, buyer_id: String) -> bool:
	var access_service := _buyer_access_service()
	if access_service != null and access_service.has_method("can_buyer_accept_fish"):
		return bool(access_service.call("can_buyer_accept_fish", buyer_id, fish_instance))
	return buyer_id == "local_market"


func sell_fish(fish_instance_id, buyer_id: String = "") -> int:
	var index := _find_inventory_index(fish_instance_id)
	if index < 0:
		_set_error_summary(buyer_id, "Рыба уже продана.")
		return 0
	return sell_fish_at(index, buyer_id)


func sell_fish_at(index: int, buyer_id: String = "") -> int:
	var inventory := _inventory()
	if index < 0 or index >= inventory.size():
		_set_error_summary(buyer_id, "Рыба уже продана.")
		return 0
	if typeof(inventory[index]) != TYPE_DICTIONARY:
		inventory.remove_at(index)
		_set_error_summary(buyer_id, "Некорректная запись рыбы удалена из садка.")
		return 0

	var catch_data: Dictionary = prepare_sale_catch_data(inventory[index])
	var target_buyer_id := buyer_id if not buyer_id.is_empty() else get_best_buyer_for_fish(catch_data)
	var offer := get_offer_for_buyer(catch_data, target_buyer_id)
	if not bool(offer.get("accepted", false)):
		last_sale_summary = {
			"sale_total": 0,
			"contract_reward_total": 0,
			"completed_contracts": [],
			"supplier_id": target_buyer_id,
			"supplier_name": str(offer.get("supplier_name", target_buyer_id)),
			"error": str(offer.get("reason", "Покупатель не принимает эту рыбу."))
		}
		return 0

	var price := int(offer.get("price", 0))
	var economy_result := _register_economy_sale(catch_data, price, target_buyer_id)
	var contract_reward := int(economy_result.get("contract_reward", 0))
	inventory.remove_at(index)
	PlayerData.money += price + contract_reward
	last_sale_summary = {
		"sale_total": price,
		"contract_reward_total": contract_reward,
		"completed_contracts": economy_result.get("completed_contracts", []),
		"supplier_id": str(economy_result.get("supplier_id", target_buyer_id)),
		"supplier_name": str(economy_result.get("supplier_name", offer.get("supplier_name", target_buyer_id))),
		"sold_count": 1
	}
	return price + contract_reward


func sell_fish_to_buyer(fish_instance: Dictionary, buyer_id: String) -> int:
	return sell_fish(fish_instance, buyer_id)


func sell_selected_fish(fish_ids: Array) -> int:
	var requests := _normalize_sale_requests(fish_ids)
	requests.sort_custom(func(a, b): return int(a.get("index", -1)) > int(b.get("index", -1)))
	return _sell_requests(requests)


func sell_all_fish_best_offer() -> int:
	var requests: Array = []
	var inventory := _inventory()
	for index in range(inventory.size() - 1, -1, -1):
		if typeof(inventory[index]) != TYPE_DICTIONARY:
			inventory.remove_at(index)
			continue
		var fish: Dictionary = inventory[index]
		requests.append({
			"index": index,
			"buyer_id": get_best_buyer_for_fish(fish)
		})
	return _sell_requests(requests)


func get_rejection_reason(fish_instance: Dictionary, buyer_id: String) -> String:
	var access_service := _buyer_access_service()
	if access_service != null and access_service.has_method("get_buyer_rejection_reason"):
		return str(access_service.call("get_buyer_rejection_reason", buyer_id, fish_instance))
	var offer := get_offer_for_buyer(fish_instance, buyer_id)
	return str(offer.get("reason", "Покупатель не принимает эту рыбу."))


func get_fish_sell_price(fish_instance: Dictionary) -> int:
	var offer := get_best_offer_for_fish(fish_instance)
	return int(offer.get("price", 0)) if bool(offer.get("accepted", false)) else 0


func get_fish_sell_price_for_buyer(fish_instance: Dictionary, buyer_id: String) -> int:
	var offer := get_offer_for_buyer(fish_instance, buyer_id)
	return int(offer.get("price", 0)) if bool(offer.get("accepted", false)) else 0


func get_last_sale_summary() -> Dictionary:
	return last_sale_summary.duplicate(true)


func prepare_sale_catch_data(catch_data: Dictionary) -> Dictionary:
	var access_service := _buyer_access_service()
	if access_service != null and access_service.has_method("prepare_fish_for_access"):
		var value = access_service.call("prepare_fish_for_access", catch_data)
		if value is Dictionary:
			return value
	var result := catch_data.duplicate(true)
	var fish_id := str(result.get("id", result.get("fish_id", "")))
	var fish: Dictionary = FishDatabase.get_fish(fish_id)
	if not fish.is_empty():
		result["rarityType"] = str(result.get("rarityType", fish.get("rarityType", "common")))
		if not result.has("fish_status") or str(result.get("fish_status", "")).is_empty():
			result["fish_status"] = FishStatusSystem.get_status(fish, float(result.get("weight", 0.0)))
		if not result.has("fish_status_title") or str(result.get("fish_status_title", "")).is_empty():
			result["fish_status_title"] = FishStatusSystem.get_status_title(str(result.get("fish_status", "undersized")))
	return result


func _sell_requests(requests: Array) -> int:
	var inventory := _inventory()
	var total_sale_money := 0
	var total_contract_reward := 0
	var completed_contracts: Array = []
	var supplier_totals: Dictionary = {}
	var sold_count := 0
	var skipped_count := 0
	var errors: Array = []

	for request in requests:
		var index := int(request.get("index", -1))
		if index < 0 or index >= inventory.size():
			skipped_count += 1
			continue
		if typeof(inventory[index]) != TYPE_DICTIONARY:
			inventory.remove_at(index)
			skipped_count += 1
			continue

		var catch_data: Dictionary = prepare_sale_catch_data(inventory[index])
		var buyer_id := str(request.get("buyer_id", ""))
		if buyer_id.is_empty():
			buyer_id = get_best_buyer_for_fish(catch_data)
		var offer := get_offer_for_buyer(catch_data, buyer_id)
		if not bool(offer.get("accepted", false)):
			skipped_count += 1
			errors.append(str(offer.get("reason", "Покупатель не принимает эту рыбу.")))
			continue

		var sale_price := int(offer.get("price", 0))
		var economy_result := _register_economy_sale(catch_data, sale_price, buyer_id)
		var contract_reward := int(economy_result.get("contract_reward", 0))
		var supplier_id := str(economy_result.get("supplier_id", buyer_id))
		total_sale_money += sale_price
		total_contract_reward += contract_reward
		sold_count += 1
		completed_contracts.append_array(economy_result.get("completed_contracts", []))
		supplier_totals[supplier_id] = int(supplier_totals.get(supplier_id, 0)) + sale_price
		inventory.remove_at(index)

	PlayerData.money += total_sale_money + total_contract_reward
	last_sale_summary = {
		"sale_total": total_sale_money,
		"contract_reward_total": total_contract_reward,
		"completed_contracts": completed_contracts,
		"supplier_totals": supplier_totals,
		"sold_count": sold_count,
		"skipped_count": skipped_count,
		"errors": errors
	}
	return total_sale_money + total_contract_reward


func _normalize_sale_requests(values: Array) -> Array:
	var requests: Array = []
	for value in values:
		var index := -1
		var buyer_id := ""
		if typeof(value) == TYPE_INT:
			index = int(value)
		elif typeof(value) == TYPE_DICTIONARY:
			var entry: Dictionary = value
			index = int(entry.get("inventory_index", entry.get("index", -1)))
			buyer_id = str(entry.get("buyer_id", entry.get("supplier_id", "")))
			if index < 0 and entry.has("fish"):
				var fish_value = entry.get("fish", {})
				if fish_value is Dictionary:
					index = _find_inventory_index(fish_value)
		elif typeof(value) == TYPE_STRING or typeof(value) == TYPE_STRING_NAME:
			index = _find_inventory_index(str(value))

		if index >= 0:
			requests.append({"index": index, "buyer_id": buyer_id})
	return requests


func _register_economy_sale(catch_data: Dictionary, sale_price: int, buyer_id: String) -> Dictionary:
	var sale_catch_data := prepare_sale_catch_data(catch_data)
	var supplier_id := buyer_id if not buyer_id.is_empty() else "local_market"
	var supplier_name := _get_supplier_title(supplier_id)

	var reputation_system := get_node_or_null("/root/ReputationSystem")
	if reputation_system != null and reputation_system.has_method("register_sale"):
		reputation_system.call("register_sale", supplier_id, sale_catch_data, sale_price)

	var contract_reward := 0
	var completed_contracts: Array = []
	var contract_manager := get_node_or_null("/root/ContractManager")
	if contract_manager != null and contract_manager.has_method("register_sold_fish"):
		var contract_result = contract_manager.call("register_sold_fish", sale_catch_data, supplier_id, sale_price)
		if contract_result is Dictionary:
			contract_reward = int(contract_result.get("reward_money", 0))
			completed_contracts = contract_result.get("completed_contracts", [])

	return {
		"supplier_id": supplier_id,
		"supplier_name": supplier_name,
		"contract_reward": contract_reward,
		"completed_contracts": completed_contracts
	}


func _calculate_price_before_skill(fish_instance: Dictionary, buyer_id: String) -> int:
	var price_service := _fish_price_service()
	if price_service != null and price_service.has_method("calculate_final_price"):
		return int(price_service.call("calculate_final_price", fish_instance, buyer_id))
	var price_calculator := get_node_or_null("/root/FishPriceCalculator")
	if price_calculator != null and price_calculator.has_method("calculate_sell_price"):
		return int(price_calculator.call("calculate_sell_price", fish_instance, buyer_id))
	return maxi(int(fish_instance.get("price", 1)), 1)


func _calculate_price_breakdown(fish_instance: Dictionary, buyer_id: String) -> Dictionary:
	var price_service := _fish_price_service()
	if price_service != null and price_service.has_method("calculate_breakdown"):
		var service_value = price_service.call("calculate_breakdown", fish_instance, buyer_id, true)
		if service_value is Dictionary:
			return service_value
	var price_calculator := get_node_or_null("/root/FishPriceCalculator")
	if price_calculator != null and price_calculator.has_method("calculate_breakdown"):
		var calculator_value = price_calculator.call("calculate_breakdown", fish_instance, buyer_id, true)
		if calculator_value is Dictionary:
			return calculator_value
	return {"base_value": maxf(float(fish_instance.get("price", 1.0)), 1.0)}


func _find_inventory_index(value) -> int:
	var inventory := _inventory()
	if typeof(value) == TYPE_INT:
		var index := int(value)
		return index if index >= 0 and index < inventory.size() else -1
	if typeof(value) == TYPE_DICTIONARY:
		var catch_data: Dictionary = value
		for i in range(inventory.size() - 1, -1, -1):
			if typeof(inventory[i]) != TYPE_DICTIONARY:
				continue
			if _fish_matches(inventory[i], catch_data):
				return i
		return -1

	var id_value := str(value)
	if id_value.is_empty():
		return -1
	for i in range(inventory.size() - 1, -1, -1):
		if typeof(inventory[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = inventory[i]
		if str(item.get("instance_id", item.get("uid", item.get("catch_id", "")))) == id_value:
			return i
	return -1


func _fish_matches(left_value, right: Dictionary) -> bool:
	if typeof(left_value) != TYPE_DICTIONARY:
		return false
	var left: Dictionary = left_value
	if str(left.get("id", "")) != str(right.get("id", right.get("fish_id", ""))):
		return false
	if abs(float(left.get("weight", 0.0)) - float(right.get("weight", 0.0))) > 0.001:
		return false
	if int(left.get("price", 0)) != int(right.get("price", 0)):
		return false
	return true


func _make_rejected_offer(buyer_id: String, fish_instance: Dictionary, reason: String) -> Dictionary:
	var supplier: Dictionary = _get_supplier(buyer_id)
	return {
		"buyer_id": buyer_id,
		"supplier_id": buyer_id,
		"buyer_name": str(supplier.get("name", buyer_id)),
		"supplier_name": str(supplier.get("name", buyer_id)),
		"accepted": false,
		"price": 0,
		"multiplier": 0.0,
		"buyer_multiplier": 0.0,
		"reason": reason,
		"fish_status": str(fish_instance.get("fish_status", "undersized"))
	}


func _set_error_summary(buyer_id: String, message: String) -> void:
	last_sale_summary = {
		"sale_total": 0,
		"contract_reward_total": 0,
		"completed_contracts": [],
		"supplier_id": buyer_id,
		"supplier_name": _get_supplier_title(buyer_id),
		"error": message
	}


func _get_primary_buyer_ids() -> Array:
	var access_service := _buyer_access_service()
	if access_service != null and access_service.has_method("get_primary_buyer_ids"):
		var value = access_service.call("get_primary_buyer_ids")
		if value is Array:
			return value
	var supplier_manager := get_node_or_null("/root/SupplierManager")
	if supplier_manager != null and supplier_manager.has_method("get_primary_supplier_ids"):
		var supplier_value = supplier_manager.call("get_primary_supplier_ids")
		if supplier_value is Array:
			return supplier_value
	return ["local_market"]


func _get_supplier(buyer_id: String) -> Dictionary:
	var supplier_manager := get_node_or_null("/root/SupplierManager")
	if supplier_manager != null and supplier_manager.has_method("get_supplier"):
		var value = supplier_manager.call("get_supplier", buyer_id)
		if value is Dictionary:
			return value
	return {}


func _get_supplier_title(buyer_id: String) -> String:
	if buyer_id.is_empty():
		return ""
	var supplier_manager := get_node_or_null("/root/SupplierManager")
	if supplier_manager != null and supplier_manager.has_method("get_supplier_title"):
		return str(supplier_manager.call("get_supplier_title", buyer_id))
	return buyer_id


func _inventory() -> Array:
	if InventoryManager == null:
		return []
	return InventoryManager.inventory


func _buyer_access_service() -> Node:
	return get_node_or_null("/root/BuyerAccessService")


func _fish_price_service() -> Node:
	return get_node_or_null("/root/FishPriceService")
