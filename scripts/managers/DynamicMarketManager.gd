extends Node

signal market_updated(snapshot: Array)

const MIN_DEMAND := 0.50
const MAX_DEMAND := 3.00
const HISTORY_DAYS := 10

var _current_day_index: int = -1
var _current_waterbody_id: String = ""
var _demand_by_fish_id: Dictionary = {}

func _ready() -> void:
	pass


func refresh_market(force: bool = false) -> void:
	var day_index: int = _get_day_index()
	var waterbody_id: String = _get_current_waterbody_id()
	if not force and day_index == _current_day_index and waterbody_id == _current_waterbody_id and not _demand_by_fish_id.is_empty():
		return

	_current_day_index = day_index
	_current_waterbody_id = waterbody_id
	_demand_by_fish_id = _build_market_for_day(day_index, waterbody_id)
	market_updated.emit(get_market_snapshot(8))


func get_demand_multiplier(fish_id: String, waterbody_id: String = "") -> float:
	var target_waterbody: String = waterbody_id if not waterbody_id.is_empty() else _get_current_waterbody_id()
	if target_waterbody == _get_current_waterbody_id():
		refresh_market(false)
		return float(_demand_by_fish_id.get(fish_id, 1.0))

	return _calculate_demand_for_fish(fish_id, _get_day_index(), target_waterbody)


func get_market_snapshot(limit: int = 8) -> Array:
	refresh_market(false)
	var items: Array = []

	for fish_id in _demand_by_fish_id.keys():
		var fish: Dictionary = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue

		items.append({
			"fish_id": str(fish_id),
			"fish_name": str(fish.get("name", fish_id)),
			"rarityType": str(fish.get("rarityType", "common")),
			"demand": float(_demand_by_fish_id.get(fish_id, 1.0)),
			"basePricePerKg": float(fish.get("basePricePerKg", fish.get("price_per_kg", 1.0))),
			"waterbody_id": _current_waterbody_id,
			"day_index": _current_day_index
		})

	items.sort_custom(func(a, b): return float(a.get("demand", 1.0)) > float(b.get("demand", 1.0)))
	if limit > 0 and items.size() > limit:
		return items.slice(0, limit)
	return items


func get_price_history(fish_id: String, days: int = HISTORY_DAYS) -> Array:
	var result: Array = []
	var day_index: int = _get_day_index()
	var waterbody_id: String = _get_current_waterbody_id()
	var count: int = max(days, 1)

	for offset in range(count - 1, -1, -1):
		var history_day: int = max(day_index - offset, 1)
		result.append({
			"day_index": history_day,
			"demand": _calculate_demand_for_fish(fish_id, history_day, waterbody_id)
		})

	return result


func get_save_data() -> Dictionary:
	refresh_market(false)
	return {
		"day_index": _current_day_index,
		"waterbody_id": _current_waterbody_id,
		"demand_by_fish_id": _demand_by_fish_id.duplicate(true)
	}


func load_save_data(save_data: Dictionary) -> void:
	_current_day_index = int(save_data.get("day_index", -1))
	_current_waterbody_id = str(save_data.get("waterbody_id", ""))
	if save_data.get("demand_by_fish_id", {}) is Dictionary:
		_demand_by_fish_id = (save_data.get("demand_by_fish_id", {}) as Dictionary).duplicate(true)
	refresh_market(false)


func _build_market_for_day(day_index: int, waterbody_id: String) -> Dictionary:
	var result: Dictionary = {}
	for fish_id in FishDatabase.get_all_fish_ids():
		result[str(fish_id)] = _calculate_demand_for_fish(str(fish_id), day_index, waterbody_id)
	return result


func _calculate_demand_for_fish(fish_id: String, day_index: int, waterbody_id: String) -> float:
	var fish: Dictionary = FishDatabase.get_fish(fish_id)
	if fish.is_empty():
		return 1.0

	var rng := RandomNumberGenerator.new()
	rng.seed = _make_seed("%s:%s:%s:%s" % [day_index, waterbody_id, _get_season_id(day_index), fish_id])

	var rarity_type: String = str(fish.get("rarityType", "common"))
	var low := 0.78
	var high := 1.58
	var spike_chance := 0.08
	var slump_chance := 0.10
	match rarity_type:
		"rare":
			low = 0.68
			high = 1.88
			spike_chance = 0.14
			slump_chance = 0.12
		"legendary_species":
			low = 0.56
			high = 2.15
			spike_chance = 0.18
			slump_chance = 0.14

	var demand: float = rng.randf_range(low, high)
	if rng.randf() < spike_chance:
		demand += rng.randf_range(0.45, 0.95)
	if rng.randf() < slump_chance:
		demand *= rng.randf_range(0.62, 0.84)

	demand *= _get_season_multiplier(fish, day_index)
	demand *= _get_waterbody_market_bias(fish_id, waterbody_id)
	return snappedf(clamp(demand, MIN_DEMAND, MAX_DEMAND), 0.01)


func _get_season_multiplier(fish: Dictionary, day_index: int) -> float:
	var season_id: String = _get_season_id(day_index)
	var habitat: String = str(fish.get("habitat", "lake"))
	if season_id == "summer" and (habitat == "vegetation" or habitat == "surface"):
		return 1.12
	if season_id == "autumn" and (habitat == "predator" or habitat == "deep"):
		return 1.14
	if season_id == "winter" and habitat == "surface":
		return 0.82
	return 1.0


func _get_waterbody_market_bias(fish_id: String, waterbody_id: String) -> float:
	if waterbody_id == "agamin_lake":
		if fish_id in ["roach", "crucian", "silver_crucian", "perch", "bream"]:
			return 1.08
		if fish_id in ["mist_carp", "moon_catfish"]:
			return 0.92
	return 1.0


func _get_season_id(day_index: int) -> String:
	var season_index: int = int(floor(float(max(day_index - 1, 0)) / 30.0)) % 4
	match season_index:
		0:
			return "spring"
		1:
			return "summer"
		2:
			return "autumn"
		_:
			return "winter"


func _get_day_index() -> int:
	var time_manager: Node = get_node_or_null("/root/TimeManager")
	if time_manager != null:
		return max(int(time_manager.get("day_index")), 1)
	return 1


func _get_current_waterbody_id() -> String:
	var player_data: Node = get_node_or_null("/root/PlayerData")
	if player_data != null:
		return str(player_data.get("current_waterbody"))
	return "agamin_lake"


func _make_seed(value: String) -> int:
	return abs(hash(value)) + 1009
