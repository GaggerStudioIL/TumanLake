extends Node

var inventory: Array = []
var max_items: int = 30
var last_sale_summary: Dictionary = {}
var last_zero_value_cleanup_count := 0

const ZERO_VALUE_CHECK_BUYERS := [
	"local_market",
	"fish_shop",
	"cannery",
	"restaurant",
	"wholesale_buyer",
	"collector",
	"export_company"
]

func add_fish(catch_data: Dictionary) -> bool:
	if inventory.size() >= max_items:
		return false

	inventory.append(FishFreshnessManager.ensure_catch_freshness_metadata(catch_data))
	return true


func remove_fish(catch_data: Dictionary) -> bool:
	for i in range(inventory.size() - 1, -1, -1):
		var item: Dictionary = inventory[i]

		if str(item.get("id", "")) != str(catch_data.get("id", "")):
			continue

		if abs(float(item.get("weight", 0.0)) - float(catch_data.get("weight", 0.0))) > 0.001:
			continue

		if int(item.get("price", 0)) != int(catch_data.get("price", 0)):
			continue

		inventory.remove_at(i)
		return true

	return false


func purge_zero_value_fish() -> int:
	var removed_count := 0

	for index in range(inventory.size() - 1, -1, -1):
		var item = inventory[index]
		if typeof(item) != TYPE_DICTIONARY:
			inventory.remove_at(index)
			removed_count += 1
			continue

		var catch_data: Dictionary = _prepare_sale_catch_data(item)
		if _is_invalid_fish_record(catch_data):
			inventory.remove_at(index)
			removed_count += 1

	last_zero_value_cleanup_count = removed_count
	if removed_count > 0:
		print("Removed invalid fish records from keepnet: %d" % removed_count)
	return removed_count


func remove_zero_value_fish() -> int:
	return purge_zero_value_fish()


func is_zero_value_fish(catch_data: Dictionary) -> bool:
	if catch_data.is_empty():
		return true

	return _get_best_positive_cleanup_price(catch_data) <= 0


func _is_invalid_fish_record(catch_data: Dictionary) -> bool:
	if catch_data.is_empty():
		return true

	var fish_id := str(catch_data.get("id", catch_data.get("fish_id", ""))).strip_edges()
	if fish_id.is_empty():
		return true
	if FishDatabase.get_fish(fish_id).is_empty():
		return true
	if float(catch_data.get("weight", 0.0)) <= 0.0:
		return true

	return false


func _get_best_positive_cleanup_price(catch_data: Dictionary) -> int:
	var best_price := 0

	for buyer_id_value in _get_zero_value_check_buyers():
		var buyer_id := str(buyer_id_value)
		var offer: Dictionary = _get_cleanup_offer_for_buyer(catch_data, buyer_id)
		if bool(offer.get("accepted", false)):
			best_price = maxi(best_price, int(offer.get("price", 0)))

	return best_price


func _get_zero_value_check_buyers() -> Array:
	var result: Array = []
	var supplier_manager: Node = get_node_or_null("/root/SupplierManager")
	if supplier_manager != null and supplier_manager.has_method("get_primary_supplier_ids"):
		var value = supplier_manager.call("get_primary_supplier_ids")
		if value is Array:
			result = value.duplicate()

	if result.is_empty():
		result = ZERO_VALUE_CHECK_BUYERS.duplicate()

	if not result.has("cannery"):
		result.append("cannery")
	return result


func _get_cleanup_offer_for_buyer(catch_data: Dictionary, buyer_id: String) -> Dictionary:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_offer_for_buyer"):
		var service_value = sales_service.call("get_offer_for_buyer", catch_data, buyer_id)
		if service_value is Dictionary:
			return service_value

	var supplier_manager: Node = get_node_or_null("/root/SupplierManager")
	if supplier_manager != null and supplier_manager.has_method("get_buyer_offer"):
		var supplier_value = supplier_manager.call("get_buyer_offer", catch_data, buyer_id)
		if supplier_value is Dictionary:
			return supplier_value

	if buyer_id == "local_market":
		return {
			"buyer_id": buyer_id,
			"supplier_id": buyer_id,
			"accepted": true,
			"price": get_fish_sell_price(catch_data)
		}

	return {
		"buyer_id": buyer_id,
		"supplier_id": buyer_id,
		"accepted": false,
		"price": 0
	}


func sell_all() -> int:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("sell_all_fish_best_offer"):
		return int(sales_service.call("sell_all_fish_best_offer"))

	var total_sale_money := 0
	var total_contract_reward := 0
	var completed_contracts: Array = []
	var supplier_totals: Dictionary = {}
	var sold_count := 0

	for index in range(inventory.size() - 1, -1, -1):
		var item = inventory[index]
		if typeof(item) != TYPE_DICTIONARY:
			inventory.remove_at(index)
			continue

		var catch_data: Dictionary = _prepare_sale_catch_data(item)
		var offer: Dictionary = _get_best_sale_offer(catch_data)
		if not bool(offer.get("accepted", false)):
			continue

		var sale_price := int(offer.get("price", 0))
		var supplier_id_from_offer := str(offer.get("supplier_id", offer.get("buyer_id", "")))
		var economy_result: Dictionary = _register_economy_sale(catch_data, sale_price, supplier_id_from_offer)
		var contract_reward: int = int(economy_result.get("contract_reward", 0))
		var supplier_id: String = str(economy_result.get("supplier_id", "local_market"))
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
		"sold_count": sold_count
	}

	return total_sale_money + total_contract_reward


func sell_all_fish_best_offer() -> int:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("sell_all_fish_best_offer"):
		return int(sales_service.call("sell_all_fish_best_offer"))
	return sell_all()


func sell_fish_at(index: int) -> int:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("sell_fish_at"):
		return int(sales_service.call("sell_fish_at", index))

	if index < 0 or index >= inventory.size():
		return 0

	var item = inventory[index]
	if typeof(item) != TYPE_DICTIONARY:
		inventory.remove_at(index)
		return 0

	var catch_data: Dictionary = _prepare_sale_catch_data(item)
	var offer: Dictionary = _get_best_sale_offer(catch_data)
	if not bool(offer.get("accepted", false)):
		last_sale_summary = {
			"sale_total": 0,
			"contract_reward_total": 0,
			"completed_contracts": [],
			"supplier_id": "",
			"supplier_name": "",
			"error": str(offer.get("reason", "Нет доступного покупателя."))
		}
		return 0

	var price := int(offer.get("price", 0))
	var buyer_id := str(offer.get("supplier_id", offer.get("buyer_id", "")))
	var economy_result: Dictionary = _register_economy_sale(catch_data, price, buyer_id)
	var contract_reward: int = int(economy_result.get("contract_reward", 0))
	inventory.remove_at(index)
	PlayerData.money += price + contract_reward
	last_sale_summary = {
		"sale_total": price,
		"contract_reward_total": contract_reward,
		"completed_contracts": economy_result.get("completed_contracts", []),
		"supplier_id": str(economy_result.get("supplier_id", "local_market")),
		"supplier_name": str(economy_result.get("supplier_name", "Местный рынок"))
	}
	return price + contract_reward


func sell_fish_at_to_buyer(index: int, buyer_id: String) -> int:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("sell_fish_at"):
		return int(sales_service.call("sell_fish_at", index, buyer_id))

	if index < 0 or index >= inventory.size():
		return 0

	var item = inventory[index]
	if typeof(item) != TYPE_DICTIONARY:
		inventory.remove_at(index)
		return 0

	var catch_data: Dictionary = _prepare_sale_catch_data(item)
	var offer: Dictionary = get_buyer_offer(catch_data, buyer_id)
	if not bool(offer.get("accepted", false)):
		last_sale_summary = {
			"sale_total": 0,
			"contract_reward_total": 0,
			"completed_contracts": [],
			"supplier_id": buyer_id,
			"supplier_name": str(offer.get("supplier_name", buyer_id)),
			"error": str(offer.get("reason", "Покупатель не принимает эту рыбу."))
		}
		return 0

	var price := int(offer.get("price", 0))
	var economy_result: Dictionary = _register_economy_sale(catch_data, price, buyer_id)
	var contract_reward: int = int(economy_result.get("contract_reward", 0))
	inventory.remove_at(index)
	PlayerData.money += price + contract_reward
	last_sale_summary = {
		"sale_total": price,
		"contract_reward_total": contract_reward,
		"completed_contracts": economy_result.get("completed_contracts", []),
		"supplier_id": str(economy_result.get("supplier_id", buyer_id)),
		"supplier_name": str(economy_result.get("supplier_name", offer.get("supplier_name", buyer_id)))
	}
	return price + contract_reward


func sell_fish_to_buyer(fish_instance: Dictionary, buyer_id: String) -> int:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("sell_fish_to_buyer"):
		return int(sales_service.call("sell_fish_to_buyer", fish_instance, buyer_id))
	return sell_fish_at_to_buyer(_find_fish_index(fish_instance), buyer_id)


func sell_selected_fish(selected_fish: Array, buyer_rules: Dictionary = {}) -> int:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("sell_selected_fish"):
		var requests := selected_fish.duplicate(true)
		if not buyer_rules.is_empty():
			for i in requests.size():
				if typeof(requests[i]) == TYPE_INT:
					var index := int(requests[i])
					requests[i] = {"index": index, "buyer_id": str(buyer_rules.get(index, ""))}
		return int(sales_service.call("sell_selected_fish", requests))

	var requests: Array = []
	for value in selected_fish:
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
					index = _find_fish_index(fish_value)
		if buyer_id.is_empty():
			buyer_id = str(buyer_rules.get(index, ""))
		if buyer_id.is_empty() and index >= 0 and index < inventory.size():
			buyer_id = get_best_buyer_for_fish(inventory[index])
		if index >= 0:
			requests.append({"index": index, "buyer_id": buyer_id})

	requests.sort_custom(func(a, b): return int(a.get("index", -1)) > int(b.get("index", -1)))

	var total_sale_money := 0
	var total_contract_reward := 0
	var completed_contracts: Array = []
	var supplier_totals: Dictionary = {}
	var sold_count := 0

	for request in requests:
		var index := int(request.get("index", -1))
		var buyer_id := str(request.get("buyer_id", ""))
		if index < 0 or index >= inventory.size():
			continue
		var catch_data: Dictionary = _prepare_sale_catch_data(inventory[index])
		var offer: Dictionary = get_buyer_offer(catch_data, buyer_id)
		if not bool(offer.get("accepted", false)):
			continue

		var sale_price := int(offer.get("price", 0))
		var economy_result: Dictionary = _register_economy_sale(catch_data, sale_price, buyer_id)
		var contract_reward: int = int(economy_result.get("contract_reward", 0))
		var supplier_id: String = str(economy_result.get("supplier_id", buyer_id))
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
		"sold_count": sold_count
	}
	return total_sale_money + total_contract_reward


func get_fish_freshness_price(catch_data: Dictionary) -> int:
	var price_service := get_node_or_null("/root/FishPriceService")
	if price_service != null and price_service.has_method("calculate_sell_price"):
		return int(price_service.call("calculate_sell_price", catch_data, "local_market"))
	var price_calculator: Node = get_node_or_null("/root/FishPriceCalculator")
	if price_calculator != null and price_calculator.has_method("calculate_sell_price"):
		return int(price_calculator.call("calculate_sell_price", catch_data))
	return FishFreshnessManager.get_adjusted_price(catch_data)


func get_fish_sell_price(catch_data: Dictionary) -> int:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_fish_sell_price"):
		return int(sales_service.call("get_fish_sell_price", catch_data))
	return max(PlayerData.get_skill_adjusted_sell_price(get_fish_freshness_price(catch_data)), 1)


func get_fish_sell_price_for_buyer(catch_data: Dictionary, buyer_id: String) -> int:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_fish_sell_price_for_buyer"):
		return int(sales_service.call("get_fish_sell_price_for_buyer", catch_data, buyer_id))
	var offer: Dictionary = get_buyer_offer(catch_data, buyer_id)
	if bool(offer.get("accepted", false)):
		return int(offer.get("price", 0))
	return 0


func get_available_buyers_for_fish(fish_instance: Dictionary) -> Array:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_available_buyers_for_fish"):
		var service_value = sales_service.call("get_available_buyers_for_fish", fish_instance)
		if service_value is Array:
			return service_value

	var supplier_manager: Node = get_node_or_null("/root/SupplierManager")
	if supplier_manager != null and supplier_manager.has_method("get_available_buyers_for_fish"):
		var value = supplier_manager.call("get_available_buyers_for_fish", _prepare_sale_catch_data(fish_instance))
		if value is Array:
			return value
	return ["local_market"]


func get_buyer_offer(fish_instance: Dictionary, buyer_id: String) -> Dictionary:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_offer_for_buyer"):
		var service_value = sales_service.call("get_offer_for_buyer", fish_instance, buyer_id)
		if service_value is Dictionary:
			return service_value

	var supplier_manager: Node = get_node_or_null("/root/SupplierManager")
	if supplier_manager != null and supplier_manager.has_method("get_buyer_offer"):
		var value = supplier_manager.call("get_buyer_offer", _prepare_sale_catch_data(fish_instance), buyer_id)
		if value is Dictionary:
			return value
	return {
		"buyer_id": buyer_id,
		"supplier_id": buyer_id,
		"supplier_name": buyer_id,
		"accepted": buyer_id == "local_market",
		"price": get_fish_sell_price(fish_instance) if buyer_id == "local_market" else 0,
		"multiplier": 1.0,
		"reason": "Готово к продаже" if buyer_id == "local_market" else "Покупатель недоступен"
	}


func get_best_buyer_for_fish(fish_instance: Dictionary) -> String:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_best_buyer_for_fish"):
		return str(sales_service.call("get_best_buyer_for_fish", fish_instance))

	var supplier_manager: Node = get_node_or_null("/root/SupplierManager")
	if supplier_manager != null and supplier_manager.has_method("get_best_buyer_for_fish"):
		return str(supplier_manager.call("get_best_buyer_for_fish", _prepare_sale_catch_data(fish_instance)))
	return "local_market"


func _get_best_sale_offer(catch_data: Dictionary) -> Dictionary:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_best_offer_for_fish"):
		var service_value = sales_service.call("get_best_offer_for_fish", catch_data)
		if service_value is Dictionary:
			return service_value

	var prepared: Dictionary = _prepare_sale_catch_data(catch_data)
	var buyer_id := get_best_buyer_for_fish(prepared)
	if not buyer_id.is_empty():
		var offer: Dictionary = get_buyer_offer(prepared, buyer_id)
		if bool(offer.get("accepted", false)):
			return offer

	var fallback_offer: Dictionary = get_buyer_offer(prepared, "local_market")
	if bool(fallback_offer.get("accepted", false)):
		return fallback_offer

	return {
		"buyer_id": "",
		"supplier_id": "",
		"supplier_name": "",
		"accepted": false,
		"price": 0,
		"reason": "Нет доступного покупателя."
	}


func get_last_sale_summary() -> Dictionary:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("get_last_sale_summary"):
		var service_value = sales_service.call("get_last_sale_summary")
		if service_value is Dictionary:
			return service_value
	return last_sale_summary.duplicate(true)


func _register_economy_sale(catch_data: Dictionary, sale_price: int, supplier_id_override: String = "") -> Dictionary:
	var sale_catch_data: Dictionary = _prepare_sale_catch_data(catch_data)
	var supplier_id := supplier_id_override
	var supplier_name := "Местный рынок"
	var supplier_manager: Node = get_node_or_null("/root/SupplierManager")
	if supplier_manager != null and not supplier_id.is_empty() and supplier_manager.has_method("get_buyer_offer"):
		var offer_value = supplier_manager.call("get_buyer_offer", sale_catch_data, supplier_id)
		if offer_value is Dictionary:
			var override_offer: Dictionary = offer_value
			if not bool(override_offer.get("accepted", false)):
				supplier_id = ""
	if supplier_id.is_empty():
		if supplier_manager != null and supplier_manager.has_method("get_best_supplier_for_catch"):
			supplier_id = str(supplier_manager.call("get_best_supplier_for_catch", sale_catch_data))
		else:
			supplier_id = "local_market"
	if supplier_manager != null:
		if supplier_manager.has_method("get_supplier_title"):
			supplier_name = str(supplier_manager.call("get_supplier_title", supplier_id))

	var reputation_system: Node = get_node_or_null("/root/ReputationSystem")
	if reputation_system != null and reputation_system.has_method("register_sale"):
		reputation_system.call("register_sale", supplier_id, sale_catch_data, sale_price)

	var contract_reward := 0
	var completed_contracts: Array = []
	var contract_manager: Node = get_node_or_null("/root/ContractManager")
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


func _prepare_sale_catch_data(catch_data: Dictionary) -> Dictionary:
	var sales_service := _sales_service()
	if sales_service != null and sales_service.has_method("prepare_sale_catch_data"):
		var service_value = sales_service.call("prepare_sale_catch_data", catch_data)
		if service_value is Dictionary:
			return service_value

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


func _find_fish_index(catch_data: Dictionary) -> int:
	for i in range(inventory.size() - 1, -1, -1):
		if typeof(inventory[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = inventory[i]
		if str(item.get("id", "")) != str(catch_data.get("id", "")):
			continue
		if abs(float(item.get("weight", 0.0)) - float(catch_data.get("weight", 0.0))) > 0.001:
			continue
		if int(item.get("price", 0)) != int(catch_data.get("price", 0)):
			continue
		return i
	return -1


func ensure_inventory_freshness_metadata() -> bool:
	var changed := false

	for i in inventory.size():
		if typeof(inventory[i]) != TYPE_DICTIONARY:
			continue

		var item: Dictionary = inventory[i]
		var had_real_time := item.has("caught_at_real_unix_time")
		var had_game_time := item.has("caught_at_total_game_minutes")
		var had_day_index := item.has("caught_at_day_index")
		var had_clock := item.has("caught_at_clock")
		var had_time_of_day := item.has("caught_at_time_of_day")
		var ensured := FishFreshnessManager.ensure_catch_freshness_metadata(item)
		inventory[i] = ensured

		if (
			not had_real_time
			or not had_game_time
			or not had_day_index
			or not had_clock
			or not had_time_of_day
			or bool(ensured.get("freshness_migrated", false))
		):
			changed = true

	return changed


func get_inventory_text() -> String:
	if inventory.is_empty():
		return "Садок пуст."

	var text := "Садок:\n"

	for item in inventory:
		if typeof(item) != TYPE_DICTIONARY:
			continue

		text += "%s | %s | %s | %s\n" % [
			item["name"],
			_format_weight_kg(float(item["weight"])),
			_format_money(float(get_fish_sell_price(item))),
			FishFreshnessManager.get_freshness_title(item)
		]

	return text


func _format_money(value: float) -> String:
	var formatters := get_node_or_null("/root/UIFormatters")
	if formatters != null and formatters.has_method("format_money"):
		return str(formatters.call("format_money", value))
	return "%s мон." % str(int(round(value)))


func _format_weight_kg(value: float) -> String:
	var formatters := get_node_or_null("/root/UIFormatters")
	if formatters != null and formatters.has_method("format_weight_kg"):
		return str(formatters.call("format_weight_kg", value))
	return "%.2f кг" % maxf(value, 0.0)


func _sales_service() -> Node:
	return get_node_or_null("/root/SalesService")
