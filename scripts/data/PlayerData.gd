extends Node

var money: int = 0
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 175
var current_spot: String = "north_pier"
var unlocked_spots: Array = ["north_pier"]
var upgrades: Array = []
var owned_items: Array = get_default_owned_items()
var current_tackle: Dictionary = {
	"rod": {
		"id": "simple_pole_rod_4m",
		"name": "Простая маховая удочка 4 м",
		"control_bonus": 0.08,
		"durability": 1.0,
		"max_fish_weight": 4.0
	},
	"line": {
		"id": "mono_1_2kg",
		"name": "Моно 1.2 кг",
		"strength": 1.2,
		"break_resistance": 0.92,
		"visibility_penalty": 0.08
	},
	"float": {
		"id": "light_float",
		"name": "Лёгкий поплавок",
		"bite_detection_bonus": 0.12,
		"stability": 0.10
	},
	"hook": {
		"id": "small_hook_12",
		"name": "Малый крючок №12",
		"hook_size": 12,
		"hook_success_bonus": 0.08,
		"fish_escape_modifier": 0.92
	},
	"bait": {
		"id": "worm",
		"name": "Червь",
		"bait_type": "worm",
		"fish_attraction": 0.14,
		"fish_attraction_by_id": {
			"roach": 0.28,
			"perch": 0.22,
			"crucian": 0.24
		},
		"allowed_rarities": ["common", "uncommon", "rare"]
	}
}

func get_xp_to_next_level(for_level: int) -> int:
	return 100 + 50 * for_level + 25 * for_level * for_level

func add_xp(amount: int) -> Dictionary:
	var gained_xp: int = max(amount, 0)
	var levels_gained: int = 0

	current_xp += gained_xp

	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		level += 1
		levels_gained += 1
		xp_to_next_level = get_xp_to_next_level(level)

	return {
		"gained_xp": gained_xp,
		"levels_gained": levels_gained,
		"leveled_up": levels_gained > 0,
		"level": level,
		"current_xp": current_xp,
		"xp_to_next_level": xp_to_next_level
	}

func set_progression(saved_level: int, saved_xp: int) -> void:
	level = max(saved_level, 1)
	xp_to_next_level = get_xp_to_next_level(level)
	current_xp = max(saved_xp, 0)

	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		level += 1
		xp_to_next_level = get_xp_to_next_level(level)

func get_default_tackle() -> Dictionary:
	return {
		"rod": {
			"id": "simple_pole_rod_4m",
			"name": "Простая маховая удочка 4 м",
			"control_bonus": 0.08,
			"durability": 1.0,
			"max_fish_weight": 4.0
		},
		"line": {
			"id": "mono_1_2kg",
			"name": "Моно 1.2 кг",
			"strength": 1.2,
			"break_resistance": 0.92,
			"visibility_penalty": 0.08
		},
		"float": {
			"id": "light_float",
			"name": "Лёгкий поплавок",
			"bite_detection_bonus": 0.12,
			"stability": 0.10
		},
		"hook": {
			"id": "small_hook_12",
			"name": "Малый крючок №12",
			"hook_size": 12,
			"hook_success_bonus": 0.08,
			"fish_escape_modifier": 0.92
		},
		"bait": {
			"id": "worm",
			"name": "Червь",
			"bait_type": "worm",
			"fish_attraction": 0.14,
			"fish_attraction_by_id": {
				"roach": 0.28,
				"perch": 0.22,
				"crucian": 0.24
			},
			"allowed_rarities": ["common", "uncommon", "rare"]
		}
	}

func get_default_owned_items() -> Array:
	return [
		{
			"id": "simple_pole_rod_4m",
			"name": "Простая маховая удочка 4 м",
			"category": "rod",
			"quantity": 1,
			"description": "Стартовое удилище для маховой поплавочной ловли.",
			"stats": {
				"control_bonus": 0.08,
				"durability": 1.0,
				"max_fish_weight": 4.0
			}
		},
		{
			"id": "mono_1_2kg",
			"name": "Моно 1.2 кг",
			"category": "line",
			"quantity": 1,
			"description": "Тонкая монофильная леска для небольшой рыбы.",
			"stats": {
				"strength": 1.2,
				"break_resistance": 0.92,
				"visibility_penalty": 0.08
			}
		},
		{
			"id": "light_float",
			"name": "Лёгкий поплавок",
			"category": "float",
			"quantity": 1,
			"description": "Чувствительный поплавок для спокойной воды.",
			"stats": {
				"bite_detection_bonus": 0.12,
				"stability": 0.10
			}
		},
		{
			"id": "small_hook_12",
			"name": "Малый крючок №12",
			"category": "hook",
			"quantity": 1,
			"description": "Малый крючок для плотвы, краснопёрки и карася.",
			"stats": {
				"hook_size": 12,
				"hook_success_bonus": 0.08,
				"fish_escape_modifier": 0.92
			}
		},
		{
			"id": "worm",
			"name": "Червь",
			"category": "bait",
			"quantity": 30,
			"description": "Универсальная наживка. Хорошо работает по плотве, окуню и карасю.",
			"stats": {
				"bait_type": "worm",
				"fish_attraction": 0.14,
				"fish_attraction_by_id": {
					"roach": 0.28,
					"perch": 0.22,
					"crucian": 0.24
				},
				"allowed_rarities": ["common", "uncommon", "rare"]
			}
		}
	]

func set_current_tackle(saved_tackle: Dictionary) -> void:
	var default_tackle := get_default_tackle()
	current_tackle = default_tackle.duplicate(true)

	for slot in ["rod", "line", "float", "hook", "bait"]:
		if not saved_tackle.has(slot):
			continue

		var saved_component = saved_tackle[slot]
		if typeof(saved_component) != TYPE_DICTIONARY:
			continue

		var merged_component: Dictionary = current_tackle[slot].duplicate(true)
		merged_component.merge(saved_component, true)
		current_tackle[slot] = merged_component

func set_owned_items(saved_items: Array) -> void:
	if saved_items.is_empty():
		owned_items = get_default_owned_items()
		return

	owned_items = []

	for item in saved_items:
		if typeof(item) != TYPE_DICTIONARY:
			continue

		var raw_stats = item.get("stats", {})
		var stats: Dictionary = {}
		if typeof(raw_stats) == TYPE_DICTIONARY:
			stats = raw_stats.duplicate(true)

		var normalized_item: Dictionary = {
			"id": str(item.get("id", "")),
			"name": str(item.get("name", "-")),
			"category": str(item.get("category", "misc")),
			"quantity": max(int(item.get("quantity", 1)), 0),
			"description": str(item.get("description", "")),
			"stats": stats
		}

		if normalized_item["id"] == "":
			continue

		owned_items.append(normalized_item)

	if owned_items.is_empty():
		owned_items = get_default_owned_items()

func get_owned_items_for_category(category_filter: String) -> Array:
	if category_filter == "all":
		return owned_items

	var items: Array = []

	for item in owned_items:
		if str(item.get("category", "misc")) == category_filter:
			items.append(item)

	return items

func can_equip_item(item: Dictionary) -> bool:
	return ["rod", "line", "float", "hook", "bait"].has(str(item.get("category", ""))) and int(item.get("quantity", 0)) > 0

func equip_item(item_id: String) -> bool:
	var item := get_owned_item(item_id)

	if item.is_empty() or not can_equip_item(item):
		return false

	var category := str(item["category"])
	var component: Dictionary = item.get("stats", {}).duplicate(true)
	component["id"] = item["id"]
	component["name"] = item["name"]

	if category == "bait":
		component["quantity"] = int(item.get("quantity", 0))

	current_tackle[category] = component
	return true

func get_owned_item(item_id: String) -> Dictionary:
	for item in owned_items:
		if str(item.get("id", "")) == item_id:
			return item

	return {}

func get_current_bait_quantity() -> int:
	var bait_id := str(current_tackle.get("bait", {}).get("id", ""))

	for item in owned_items:
		if str(item.get("id", "")) == bait_id:
			return int(item.get("quantity", 0))

	return 0

func has_current_bait() -> bool:
	return get_current_bait_quantity() > 0

func consume_current_bait(amount: int = 1) -> bool:
	var bait_id := str(current_tackle.get("bait", {}).get("id", ""))

	for item in owned_items:
		if str(item.get("id", "")) != bait_id:
			continue

		var quantity: int = int(item.get("quantity", 0))
		if quantity < amount:
			return false

		item["quantity"] = quantity - amount
		current_tackle["bait"]["quantity"] = item["quantity"]
		return true

	return false

func get_tackle_stats() -> Dictionary:
	var rod: Dictionary = current_tackle.get("rod", {})
	var line: Dictionary = current_tackle.get("line", {})
	var float_part: Dictionary = current_tackle.get("float", {})
	var hook: Dictionary = current_tackle.get("hook", {})
	var bait: Dictionary = current_tackle.get("bait", {})

	return {
		"control_bonus": float(rod.get("control_bonus", 0.0)),
		"durability": float(rod.get("durability", 1.0)),
		"max_fish_weight": float(rod.get("max_fish_weight", 1.0)),
		"line_strength": float(line.get("strength", 1.0)),
		"break_resistance": float(line.get("break_resistance", 1.0)),
		"visibility_penalty": float(line.get("visibility_penalty", 0.0)),
		"bite_detection_bonus": float(float_part.get("bite_detection_bonus", 0.0)),
		"stability": float(float_part.get("stability", 0.0)),
		"hook_size": int(hook.get("hook_size", 12)),
		"hook_success_bonus": float(hook.get("hook_success_bonus", 0.0)),
		"fish_escape_modifier": float(hook.get("fish_escape_modifier", 1.0)),
		"bait_type": str(bait.get("bait_type", "worm")),
		"fish_attraction": float(bait.get("fish_attraction", 0.0)),
		"fish_attraction_by_id": bait.get("fish_attraction_by_id", {}),
		"allowed_rarities": bait.get("allowed_rarities", [])
	}

func get_tackle_text() -> String:
	return "Текущая снасть:\nУдочка: %s\nЛеска: %s\nПоплавок: %s\nКрючок: %s\nНаживка: %s x%d" % [
		current_tackle.get("rod", {}).get("name", "-"),
		current_tackle.get("line", {}).get("name", "-"),
		current_tackle.get("float", {}).get("name", "-"),
		current_tackle.get("hook", {}).get("name", "-"),
		current_tackle.get("bait", {}).get("name", "-"),
		get_current_bait_quantity()
	]
