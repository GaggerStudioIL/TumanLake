extends Node

const LEVEL_THRESHOLDS := [0, 50, 150, 350, 700]
const LEVEL_TITLES := ["Новичок", "Надежный", "Партнер", "Известный", "Профи"]

var supplier_reputation: Dictionary = {}

func _ready() -> void:
	_ensure_supplier_keys()


func get_reputation(supplier_id: String) -> int:
	_ensure_supplier_keys()
	return max(int(supplier_reputation.get(supplier_id, 0)), 0)


func add_reputation(supplier_id: String, amount: int) -> int:
	_ensure_supplier_keys()
	var current_value: int = get_reputation(supplier_id)
	var next_value: int = max(current_value + amount, 0)
	supplier_reputation[supplier_id] = next_value
	return next_value


func register_sale(supplier_id: String, catch_data: Dictionary, sale_price: int) -> int:
	var status: String = str(catch_data.get("fish_status", "undersized"))
	var base_gain: int = 1
	if status == "keeper":
		base_gain = 2
	elif status == "trophy":
		base_gain = 6

	var price_gain: int = int(floor(float(max(sale_price, 0)) / 250.0))
	return add_reputation(supplier_id, clamp(base_gain + price_gain, 1, 14))


func get_reputation_level(supplier_id: String) -> int:
	var value: int = get_reputation(supplier_id)
	var level := 0
	for i in LEVEL_THRESHOLDS.size():
		if value >= int(LEVEL_THRESHOLDS[i]):
			level = i
	return level


func get_reputation_title(supplier_id: String) -> String:
	var level: int = clamp(get_reputation_level(supplier_id), 0, LEVEL_TITLES.size() - 1)
	return str(LEVEL_TITLES[level])


func get_total_reputation() -> int:
	_ensure_supplier_keys()
	var total := 0
	for value in supplier_reputation.values():
		total += max(int(value), 0)
	return total


func get_summary(limit: int = 6) -> Array:
	_ensure_supplier_keys()
	var items: Array = []
	for supplier_id in supplier_reputation.keys():
		items.append({
			"id": str(supplier_id),
			"name": SupplierManager.get_supplier_title(str(supplier_id)),
			"reputation": get_reputation(str(supplier_id)),
			"level": get_reputation_level(str(supplier_id)),
			"title": get_reputation_title(str(supplier_id))
		})

	items.sort_custom(func(a, b): return int(a.get("reputation", 0)) > int(b.get("reputation", 0)))
	if limit > 0 and items.size() > limit:
		return items.slice(0, limit)
	return items


func get_save_data() -> Dictionary:
	_ensure_supplier_keys()
	return {
		"supplier_reputation": supplier_reputation.duplicate(true)
	}


func load_save_data(save_data: Dictionary) -> void:
	if save_data.get("supplier_reputation", {}) is Dictionary:
		supplier_reputation = (save_data.get("supplier_reputation", {}) as Dictionary).duplicate(true)
	_ensure_supplier_keys()


func _ensure_supplier_keys() -> void:
	var supplier_manager: Node = get_node_or_null("/root/SupplierManager")
	if supplier_manager == null or not supplier_manager.has_method("get_supplier_ids"):
		if not supplier_reputation.has("local_market"):
			supplier_reputation["local_market"] = 0
		return

	var supplier_ids: Array = []
	var supplier_ids_value = supplier_manager.call("get_supplier_ids")
	if supplier_ids_value is Array:
		supplier_ids = supplier_ids_value
	for supplier_id in supplier_ids:
		var key: String = str(supplier_id)
		if not supplier_reputation.has(key):
			supplier_reputation[key] = 0
