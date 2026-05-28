extends Node

const MAX_ACTIVE_CONTRACTS := 3
const CONTRACT_DURATION_DAYS := 3

var active_contracts: Array = []
var completed_contracts: Array = []
var last_generated_day: int = -1

func _ready() -> void:
	pass


func refresh_contracts(force: bool = false) -> void:
	var day_index: int = _get_day_index()
	if not force and day_index == last_generated_day and active_contracts.size() >= MAX_ACTIVE_CONTRACTS:
		return

	_remove_expired_contracts(day_index)
	var rng := RandomNumberGenerator.new()
	rng.seed = abs(hash("contracts:%s:%s" % [day_index, ReputationSystem.get_total_reputation()])) + 313

	while active_contracts.size() < MAX_ACTIVE_CONTRACTS:
		active_contracts.append(_generate_contract(day_index, rng))

	last_generated_day = day_index


func get_active_contracts() -> Array:
	refresh_contracts(false)
	return active_contracts.duplicate(true)


func get_completed_contracts(limit: int = 12) -> Array:
	var result: Array = completed_contracts.duplicate(true)
	if limit > 0 and result.size() > limit:
		return result.slice(result.size() - limit)
	return result


func register_sold_fish(catch_data: Dictionary, supplier_id: String, sale_price: int) -> Dictionary:
	refresh_contracts(false)
	var completed_now: Array = []
	var contract_reward_total := 0
	var updated_contracts: Array = []

	for value in active_contracts:
		if typeof(value) != TYPE_DICTIONARY:
			continue

		var contract: Dictionary = (value as Dictionary).duplicate(true)
		if _catch_matches_contract(catch_data, supplier_id, contract):
			_apply_progress(contract, catch_data)

		if _is_contract_complete(contract):
			var reward_money: int = int(contract.get("reward_money", 0))
			var reward_reputation: int = int(contract.get("reward_reputation", 0))
			contract["completed_day_index"] = _get_day_index()
			contract["sale_price_at_completion"] = sale_price
			contract_reward_total += reward_money
			ReputationSystem.add_reputation(str(contract.get("supplier_id", "local_market")), reward_reputation)
			completed_now.append(contract.duplicate(true))
			completed_contracts.append(contract.duplicate(true))
		else:
			updated_contracts.append(contract)

	active_contracts = updated_contracts
	if completed_contracts.size() > 40:
		completed_contracts = completed_contracts.slice(completed_contracts.size() - 40)

	return {
		"reward_money": contract_reward_total,
		"completed_contracts": completed_now
	}


func get_save_data() -> Dictionary:
	refresh_contracts(false)
	return {
		"active_contracts": active_contracts.duplicate(true),
		"completed_contracts": completed_contracts.duplicate(true),
		"last_generated_day": last_generated_day
	}


func load_save_data(save_data: Dictionary) -> void:
	if save_data.get("active_contracts", []) is Array:
		active_contracts = (save_data.get("active_contracts", []) as Array).duplicate(true)
	if save_data.get("completed_contracts", []) is Array:
		completed_contracts = (save_data.get("completed_contracts", []) as Array).duplicate(true)
	last_generated_day = int(save_data.get("last_generated_day", -1))
	refresh_contracts(false)


func _generate_contract(day_index: int, rng: RandomNumberGenerator) -> Dictionary:
	var suppliers: Array = SupplierManager.get_available_suppliers()
	if suppliers.is_empty():
		suppliers = ["local_market"]

	var supplier_id: String = str(suppliers[rng.randi_range(0, suppliers.size() - 1)])
	var market_items: Array = DynamicMarketManager.get_market_snapshot(12)
	var fish_id := "roach"
	if not market_items.is_empty():
		var picked: Dictionary = market_items[rng.randi_range(0, market_items.size() - 1)]
		fish_id = str(picked.get("fish_id", fish_id))

	var fish: Dictionary = FishDatabase.get_fish(fish_id)
	var fish_name: String = str(fish.get("name", fish_id))
	var reputation_total: int = ReputationSystem.get_total_reputation()
	var type_roll: float = rng.randf()
	var contract_type := "weight"
	var required_status := "keeper"
	if type_roll > 0.78 and reputation_total >= 120:
		contract_type = "trophy_count"
		required_status = "trophy"
	elif type_roll > 0.48:
		contract_type = "count"

	var target_weight: float = snappedf(rng.randf_range(2.0, 6.0 + float(reputation_total) / 120.0), 0.1)
	var target_count: int = rng.randi_range(4, 10 + int(float(reputation_total) / 120.0))
	if contract_type == "trophy_count":
		target_count = rng.randi_range(1, 2 + int(float(reputation_total) / 350.0))

	var estimated_weight: float = target_weight
	if contract_type != "weight":
		estimated_weight = max(float(fish.get("keeperWeight", fish.get("keeper_weight", fish.get("min_weight", 0.1)))) * float(target_count), 0.2)

	var demand: float = DynamicMarketManager.get_demand_multiplier(fish_id)
	var base_price: float = float(fish.get("basePricePerKg", fish.get("price_per_kg", 1.0)))
	var reward_money: int = max(roundi(base_price * estimated_weight * demand * (2.8 if contract_type == "trophy_count" else 1.35)), 15)
	var reward_reputation: int = 12 if contract_type == "trophy_count" else 6

	return {
		"id": "contract_%d_%d" % [day_index, rng.randi()],
		"title": _build_contract_title(contract_type, fish_name, target_weight, target_count, required_status),
		"type": contract_type,
		"supplier_id": supplier_id,
		"supplier_name": SupplierManager.get_supplier_title(supplier_id),
		"fish_id": fish_id,
		"fish_name": fish_name,
		"required_status": required_status,
		"target_weight_kg": target_weight,
		"target_count": target_count,
		"progress_weight_kg": 0.0,
		"progress_count": 0,
		"reward_money": reward_money,
		"reward_reputation": reward_reputation,
		"created_day_index": day_index,
		"expires_day_index": day_index + CONTRACT_DURATION_DAYS
	}


func _build_contract_title(contract_type: String, fish_name: String, target_weight: float, target_count: int, required_status: String) -> String:
	if contract_type == "trophy_count":
		return "Доставить %d %s: %s" % [target_count, _plural_ru(target_count, "трофей", "трофея", "трофеев"), fish_name]
	if contract_type == "count":
		return "Поймать %d зачётных: %s" % [target_count, fish_name]
	return "Поставить %.1f кг: %s" % [target_weight, fish_name]


func _plural_ru(count: int, one: String, few: String, many: String) -> String:
	var value: int = absi(count)
	var last_two: int = value % 100
	if last_two >= 11 and last_two <= 14:
		return many
	var last: int = value % 10
	if last == 1:
		return one
	if last >= 2 and last <= 4:
		return few
	return many


func _catch_matches_contract(catch_data: Dictionary, supplier_id: String, contract: Dictionary) -> bool:
	if str(catch_data.get("id", "")) != str(contract.get("fish_id", "")):
		return false
	var contract_supplier_id: String = str(contract.get("supplier_id", "local_market"))
	if supplier_id != contract_supplier_id and not SupplierManager.can_buy(catch_data, contract_supplier_id):
		return false

	var status: String = str(catch_data.get("fish_status", "undersized"))
	var required_status: String = str(contract.get("required_status", "keeper"))
	return FishStatusSystem.meets_min_status(status, required_status)


func _apply_progress(contract: Dictionary, catch_data: Dictionary) -> void:
	contract["progress_weight_kg"] = snappedf(float(contract.get("progress_weight_kg", 0.0)) + float(catch_data.get("weight", 0.0)), 0.01)
	contract["progress_count"] = int(contract.get("progress_count", 0)) + 1


func _is_contract_complete(contract: Dictionary) -> bool:
	var contract_type: String = str(contract.get("type", "weight"))
	if contract_type == "weight":
		return float(contract.get("progress_weight_kg", 0.0)) >= float(contract.get("target_weight_kg", 1.0))
	return int(contract.get("progress_count", 0)) >= int(contract.get("target_count", 1))


func _remove_expired_contracts(day_index: int) -> void:
	var retained: Array = []
	for value in active_contracts:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var contract: Dictionary = value
		if int(contract.get("expires_day_index", day_index + 1)) >= day_index:
			retained.append(contract)
	active_contracts = retained


func _get_day_index() -> int:
	var time_manager: Node = get_node_or_null("/root/TimeManager")
	if time_manager != null:
		return maxi(int(time_manager.get("day_index")), 1)
	return 1
