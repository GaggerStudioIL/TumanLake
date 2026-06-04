extends Node

const MAX_ACTIVE_CONTRACTS := 9
const CONTRACTS_PER_DIFFICULTY := 3
const CONTRACT_DURATION_DAYS := 3
const DIFFICULTY_ORDER := ["easy", "medium", "hard"]
const DIFFICULTY_INFO := {
	"easy": {
		"label": "Лёгкий",
		"min_reward": 60,
		"money_multiplier": 1.45,
		"rep_min": 4,
		"rep_max": 7
	},
	"medium": {
		"label": "Средний",
		"min_reward": 160,
		"money_multiplier": 2.15,
		"rep_min": 9,
		"rep_max": 14
	},
	"hard": {
		"label": "Сложный",
		"min_reward": 420,
		"money_multiplier": 3.45,
		"rep_min": 18,
		"rep_max": 30
	}
}
const CONTRACT_PATTERNS := {
	"easy": [
		{"type": "count", "required_status": "keeper", "count_min": 3, "count_max": 5},
		{"type": "weight", "required_status": "keeper", "weight_min": 1.2, "weight_max": 2.6, "fish_weight_factor": 3.0},
		{"type": "count", "required_status": "keeper", "count_min": 4, "count_max": 6}
	],
	"medium": [
		{"type": "weight", "required_status": "keeper", "weight_min": 3.0, "weight_max": 6.5, "fish_weight_factor": 5.0},
		{"type": "count", "required_status": "keeper", "count_min": 6, "count_max": 9},
		{"type": "trophy_count", "required_status": "trophy", "count_min": 1, "count_max": 1}
	],
	"hard": [
		{"type": "weight", "required_status": "keeper", "weight_min": 7.0, "weight_max": 14.0, "fish_weight_factor": 8.0},
		{"type": "trophy_count", "required_status": "trophy", "count_min": 1, "count_max": 2},
		{"type": "rarity_count", "required_status": "rarity", "count_min": 1, "count_max": 1}
	]
}

var active_contracts: Array = []
var completed_contracts: Array = []
var last_generated_day: int = -1

func _ready() -> void:
	pass


func refresh_contracts(force: bool = false) -> void:
	var day_index: int = _get_day_index()
	if force:
		active_contracts.clear()
	else:
		_remove_expired_contracts(day_index)

	_normalize_active_contracts()
	_trim_overfilled_difficulties()
	if not force and day_index == last_generated_day and _has_full_contract_set():
		return

	var rng := RandomNumberGenerator.new()
	rng.seed = abs(hash("contracts:%s:%s" % [day_index, ReputationSystem.get_total_reputation()])) + 313

	for difficulty in DIFFICULTY_ORDER:
		var generated_for_difficulty: int = _get_active_contract_count_by_difficulty(str(difficulty))
		var guard := 0
		while generated_for_difficulty < CONTRACTS_PER_DIFFICULTY and active_contracts.size() < MAX_ACTIVE_CONTRACTS and guard < 30:
			active_contracts.append(_generate_contract(day_index, rng, str(difficulty), generated_for_difficulty))
			generated_for_difficulty += 1
			guard += 1

	_sort_active_contracts()
	if active_contracts.size() > MAX_ACTIVE_CONTRACTS:
		active_contracts = active_contracts.slice(0, MAX_ACTIVE_CONTRACTS)

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


func _generate_contract(day_index: int, rng: RandomNumberGenerator, difficulty: String = "medium", slot_index: int = 0) -> Dictionary:
	difficulty = _normalize_difficulty(difficulty)
	var pattern: Dictionary = _get_contract_pattern(difficulty, slot_index)
	var contract_type := str(pattern.get("type", "weight"))
	var required_status := str(pattern.get("required_status", "keeper"))
	var fish_id := _pick_fish_id_for_contract(difficulty, rng)
	var fish: Dictionary = FishDatabase.get_fish(fish_id)
	var fish_name: String = str(fish.get("name", fish_id))
	var supplier_id: String = _pick_supplier_id(rng)

	var target_weight: float = _roll_target_weight(pattern, fish, rng)
	var target_count: int = _roll_target_count(pattern, rng)
	if contract_type == "weight":
		target_count = 0
	else:
		target_weight = 0.0

	var estimated_weight: float = _estimate_required_weight(contract_type, target_weight, target_count, fish)
	var demand: float = DynamicMarketManager.get_demand_multiplier(fish_id)
	var base_price: float = float(fish.get("basePricePerKg", fish.get("price_per_kg", 1.0)))
	var reward_money: int = _calculate_reward_money(difficulty, contract_type, base_price, estimated_weight, demand)
	var reward_reputation: int = _calculate_reward_reputation(difficulty, contract_type, rng)

	return {
		"id": "contract_%s_%d_%d" % [difficulty, day_index, rng.randi()],
		"title": _build_contract_title(contract_type, fish_name, target_weight, target_count, required_status),
		"type": contract_type,
		"difficulty": difficulty,
		"difficulty_label": _get_difficulty_label(difficulty),
		"requirement_text": _build_requirement_text(contract_type, target_weight, target_count, required_status),
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


func _get_contract_pattern(difficulty: String, slot_index: int) -> Dictionary:
	var patterns: Array = CONTRACT_PATTERNS.get(difficulty, CONTRACT_PATTERNS["medium"])
	if patterns.is_empty():
		return {}
	return (patterns[slot_index % patterns.size()] as Dictionary).duplicate(true)


func _pick_supplier_id(rng: RandomNumberGenerator) -> String:
	var suppliers: Array = SupplierManager.get_available_suppliers()
	if suppliers.is_empty():
		return "local_market"
	return str(suppliers[rng.randi_range(0, suppliers.size() - 1)])


func _pick_fish_id_for_contract(difficulty: String, rng: RandomNumberGenerator) -> String:
	var market_items: Array = DynamicMarketManager.get_market_snapshot(30)
	var candidates: Array = []
	for item in market_items:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var fish_id := str((item as Dictionary).get("fish_id", ""))
		if fish_id != "":
			candidates.append(fish_id)

	if candidates.is_empty():
		candidates = FishDatabase.get_all_fish_ids()

	var weighted: Array = []
	for fish_id in candidates:
		var fish: Dictionary = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty() or not _fish_matches_difficulty(fish, difficulty):
			continue
		var rarity_weight: int = _get_species_rarity_weight(str(fish.get("rarityType", fish.get("rarity", "common"))))
		var weight := maxi(7 - rarity_weight, 1)
		if difficulty == "hard":
			weight = maxi(rarity_weight + roundi(float(fish.get("difficulty", 1.0))), 2)
		for _i in range(weight):
			weighted.append(str(fish_id))

	if weighted.is_empty():
		weighted = candidates
	return str(weighted[rng.randi_range(0, weighted.size() - 1)])


func _fish_matches_difficulty(fish: Dictionary, difficulty: String) -> bool:
	var rarity_weight: int = _get_species_rarity_weight(str(fish.get("rarityType", fish.get("rarity", "common"))))
	var fish_difficulty: float = float(fish.get("difficulty", 1.0))
	match difficulty:
		"easy":
			return rarity_weight <= 2 and fish_difficulty <= 1.6
		"medium":
			return rarity_weight <= 3 and fish_difficulty <= 2.7
		"hard":
			return rarity_weight >= 2 or fish_difficulty >= 1.4
	return true


func _get_species_rarity_weight(rarity: String) -> int:
	match rarity:
		"uncommon":
			return 2
		"rare":
			return 3
		"very_rare":
			return 4
		"legendary", "mythic":
			return 5
		_:
			return 1


func _roll_target_weight(pattern: Dictionary, fish: Dictionary, rng: RandomNumberGenerator) -> float:
	var min_weight: float = float(pattern.get("weight_min", 1.0))
	var max_weight: float = float(pattern.get("weight_max", 3.0))
	var keeper_weight: float = max(float(fish.get("keeperWeight", fish.get("keeper_weight", fish.get("min_weight", 0.1)))), 0.1)
	var fish_weight_factor: float = float(pattern.get("fish_weight_factor", 3.0))
	max_weight = max(max_weight, keeper_weight * fish_weight_factor)
	return snappedf(rng.randf_range(min_weight, max_weight), 0.1)


func _roll_target_count(pattern: Dictionary, rng: RandomNumberGenerator) -> int:
	var min_count: int = maxi(int(pattern.get("count_min", 1)), 1)
	var max_count: int = maxi(int(pattern.get("count_max", min_count)), min_count)
	return rng.randi_range(min_count, max_count)


func _estimate_required_weight(contract_type: String, target_weight: float, target_count: int, fish: Dictionary) -> float:
	if contract_type == "weight":
		return max(target_weight, 0.1)

	var keeper_weight: float = max(float(fish.get("keeperWeight", fish.get("keeper_weight", fish.get("min_weight", 0.1)))), 0.1)
	if contract_type == "rarity_count":
		return max(float(fish.get("rarity_weight", fish.get("recordWeight", keeper_weight * 3.0))) * float(target_count), keeper_weight)
	if contract_type == "trophy_count":
		return max(float(fish.get("trophy_weight", fish.get("trophyWeight", keeper_weight * 2.0))) * float(target_count), keeper_weight)
	return max(keeper_weight * float(target_count), 0.2)


func _calculate_reward_money(difficulty: String, contract_type: String, base_price: float, estimated_weight: float, demand: float) -> int:
	var difficulty_info: Dictionary = DIFFICULTY_INFO.get(difficulty, DIFFICULTY_INFO["medium"])
	var type_multiplier := 1.0
	match contract_type:
		"weight":
			type_multiplier = 1.12
		"trophy_count":
			type_multiplier = 1.95
		"rarity_count":
			type_multiplier = 2.75
	var raw_reward: float = base_price * estimated_weight * demand * float(difficulty_info.get("money_multiplier", 1.0)) * type_multiplier
	return maxi(roundi(raw_reward), int(difficulty_info.get("min_reward", 25)))


func _calculate_reward_reputation(difficulty: String, contract_type: String, rng: RandomNumberGenerator) -> int:
	var difficulty_info: Dictionary = DIFFICULTY_INFO.get(difficulty, DIFFICULTY_INFO["medium"])
	var reward: int = rng.randi_range(int(difficulty_info.get("rep_min", 5)), int(difficulty_info.get("rep_max", 10)))
	if contract_type == "trophy_count":
		reward += 3
	elif contract_type == "rarity_count":
		reward += 7
	return reward


func _build_contract_title(contract_type: String, fish_name: String, target_weight: float, target_count: int, _required_status: String) -> String:
	match contract_type:
		"rarity_count":
			return "Доставить раритет: %s" % fish_name
		"trophy_count":
			return "Доставить %d %s: %s" % [target_count, _plural_ru(target_count, "трофей", "трофея", "трофеев"), fish_name]
		"count":
			return "Поймать %d зачётных: %s" % [target_count, fish_name]
		_:
			return "Поставить %.1f кг: %s" % [target_weight, fish_name]


func _build_requirement_text(contract_type: String, target_weight: float, target_count: int, required_status: String) -> String:
	match contract_type:
		"weight":
			return "Вес: %.1f кг, минимум: %s" % [target_weight, _get_status_label(required_status)]
		"rarity_count":
			return "Редкость: раритетная рыба, %d шт." % target_count
		"trophy_count":
			return "Редкость: трофейная рыба, %d шт." % target_count
		_:
			return "Количество: %d шт., минимум: %s" % [target_count, _get_status_label(required_status)]


func _get_status_label(status: String) -> String:
	match status:
		"rarity":
			return "раритет"
		FishStatusSystem.STATUS_TROPHY:
			return "трофей"
		FishStatusSystem.STATUS_KEEPER:
			return "зачёт"
		_:
			return "любой"


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

	var required_status: String = str(contract.get("required_status", "keeper"))
	if required_status == "rarity":
		return bool(catch_data.get("is_rarity", false)) or str(catch_data.get("catch_rank", "")) == "rarity"

	var status: String = str(catch_data.get("fish_status", "undersized"))
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


func _normalize_active_contracts() -> void:
	var normalized: Array = []
	for value in active_contracts:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var contract: Dictionary = (value as Dictionary).duplicate(true)
		_normalize_contract_fields(contract)
		normalized.append(contract)
	active_contracts = normalized


func _normalize_contract_fields(contract: Dictionary) -> void:
	var difficulty := _normalize_difficulty(str(contract.get("difficulty", "medium")))
	contract["difficulty"] = difficulty
	contract["difficulty_label"] = _get_difficulty_label(difficulty)
	if not contract.has("requirement_text"):
		contract["requirement_text"] = _build_requirement_text(
			str(contract.get("type", "weight")),
			float(contract.get("target_weight_kg", 0.0)),
			int(contract.get("target_count", 0)),
			str(contract.get("required_status", "keeper"))
		)
	if not contract.has("progress_weight_kg"):
		contract["progress_weight_kg"] = 0.0
	if not contract.has("progress_count"):
		contract["progress_count"] = 0


func _trim_overfilled_difficulties() -> void:
	var retained: Array = []
	var counts: Dictionary = {}
	for difficulty in DIFFICULTY_ORDER:
		counts[str(difficulty)] = 0

	for value in active_contracts:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var contract: Dictionary = value
		var difficulty := _normalize_difficulty(str(contract.get("difficulty", "medium")))
		var current_count := int(counts.get(difficulty, 0))
		if current_count >= CONTRACTS_PER_DIFFICULTY:
			continue
		counts[difficulty] = current_count + 1
		retained.append(contract)
	active_contracts = retained


func _get_active_contract_count_by_difficulty(difficulty: String) -> int:
	var count := 0
	for value in active_contracts:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		if _normalize_difficulty(str((value as Dictionary).get("difficulty", "medium"))) == difficulty:
			count += 1
	return count


func _has_full_contract_set() -> bool:
	if active_contracts.size() < MAX_ACTIVE_CONTRACTS:
		return false
	for difficulty in DIFFICULTY_ORDER:
		if _get_active_contract_count_by_difficulty(str(difficulty)) < CONTRACTS_PER_DIFFICULTY:
			return false
	return true


func _sort_active_contracts() -> void:
	active_contracts.sort_custom(func(a, b):
		var contract_a: Dictionary = a if a is Dictionary else {}
		var contract_b: Dictionary = b if b is Dictionary else {}
		var diff_a := _difficulty_index(str(contract_a.get("difficulty", "medium")))
		var diff_b := _difficulty_index(str(contract_b.get("difficulty", "medium")))
		if diff_a == diff_b:
			return str(contract_a.get("id", "")) < str(contract_b.get("id", ""))
		return diff_a < diff_b
	)


func _normalize_difficulty(difficulty: String) -> String:
	match difficulty:
		"easy", "light", "легкий", "лёгкий":
			return "easy"
		"hard", "difficult", "сложный":
			return "hard"
		_:
			return "medium"


func _get_difficulty_label(difficulty: String) -> String:
	var info: Dictionary = DIFFICULTY_INFO.get(_normalize_difficulty(difficulty), DIFFICULTY_INFO["medium"])
	return str(info.get("label", "Средний"))


func _difficulty_index(difficulty: String) -> int:
	var index := DIFFICULTY_ORDER.find(_normalize_difficulty(difficulty))
	return index if index >= 0 else 1


func _get_day_index() -> int:
	var time_manager: Node = get_node_or_null("/root/TimeManager")
	if time_manager != null:
		return maxi(int(time_manager.get("day_index")), 1)
	return 1
