extends Node

var inventory: Array = []
var max_items: int = 20
var last_sale_summary: Dictionary = {}

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


func sell_all() -> int:
	var total_sale_money := 0
	var total_contract_reward := 0
	var completed_contracts: Array = []
	var supplier_totals: Dictionary = {}

	for item in inventory:
		if typeof(item) != TYPE_DICTIONARY:
			continue

		var catch_data: Dictionary = item
		var sale_price: int = get_fish_sell_price(catch_data)
		var economy_result: Dictionary = _register_economy_sale(catch_data, sale_price)
		var contract_reward: int = int(economy_result.get("contract_reward", 0))
		var supplier_id: String = str(economy_result.get("supplier_id", "local_market"))
		total_sale_money += sale_price
		total_contract_reward += contract_reward
		completed_contracts.append_array(economy_result.get("completed_contracts", []))
		supplier_totals[supplier_id] = int(supplier_totals.get(supplier_id, 0)) + sale_price

	inventory.clear()
	PlayerData.money += total_sale_money + total_contract_reward
	last_sale_summary = {
		"sale_total": total_sale_money,
		"contract_reward_total": total_contract_reward,
		"completed_contracts": completed_contracts,
		"supplier_totals": supplier_totals
	}

	return total_sale_money + total_contract_reward


func sell_fish_at(index: int) -> int:
	if index < 0 or index >= inventory.size():
		return 0

	var item = inventory[index]
	if typeof(item) != TYPE_DICTIONARY:
		inventory.remove_at(index)
		return 0

	var price := get_fish_sell_price(item)
	var economy_result: Dictionary = _register_economy_sale(item, price)
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


func get_fish_freshness_price(catch_data: Dictionary) -> int:
	var price_calculator: Node = get_node_or_null("/root/FishPriceCalculator")
	if price_calculator != null and price_calculator.has_method("calculate_sell_price"):
		return int(price_calculator.call("calculate_sell_price", catch_data))
	return FishFreshnessManager.get_adjusted_price(catch_data)


func get_fish_sell_price(catch_data: Dictionary) -> int:
	return PlayerData.get_skill_adjusted_sell_price(get_fish_freshness_price(catch_data))


func get_last_sale_summary() -> Dictionary:
	return last_sale_summary.duplicate(true)


func _register_economy_sale(catch_data: Dictionary, sale_price: int) -> Dictionary:
	var supplier_id := "local_market"
	var supplier_name := "Местный рынок"
	var supplier_manager: Node = get_node_or_null("/root/SupplierManager")
	if supplier_manager != null and supplier_manager.has_method("get_best_supplier_for_catch"):
		supplier_id = str(supplier_manager.call("get_best_supplier_for_catch", catch_data))
		if supplier_manager.has_method("get_supplier_title"):
			supplier_name = str(supplier_manager.call("get_supplier_title", supplier_id))

	var reputation_system: Node = get_node_or_null("/root/ReputationSystem")
	if reputation_system != null and reputation_system.has_method("register_sale"):
		reputation_system.call("register_sale", supplier_id, catch_data, sale_price)

	var contract_reward := 0
	var completed_contracts: Array = []
	var contract_manager: Node = get_node_or_null("/root/ContractManager")
	if contract_manager != null and contract_manager.has_method("register_sold_fish"):
		var contract_result = contract_manager.call("register_sold_fish", catch_data, supplier_id, sale_price)
		if contract_result is Dictionary:
			contract_reward = int(contract_result.get("reward_money", 0))
			completed_contracts = contract_result.get("completed_contracts", [])

	return {
		"supplier_id": supplier_id,
		"supplier_name": supplier_name,
		"contract_reward": contract_reward,
		"completed_contracts": completed_contracts
	}


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

		text += "%s | %.2f кг | %d мон. | %s\n" % [
			item["name"],
			item["weight"],
			get_fish_sell_price(item),
			FishFreshnessManager.get_freshness_title(item)
		]

	return text
