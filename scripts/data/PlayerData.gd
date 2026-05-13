extends Node

var money: int = 0
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 175
var current_spot: String = "north_pier"
var unlocked_spots: Array = ["north_pier"]
var upgrades: Array = []
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
			"allowed_rarities": ["common", "uncommon", "rare"]
		}
	}

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
		"allowed_rarities": bait.get("allowed_rarities", [])
	}

func get_tackle_text() -> String:
	return "Текущая снасть:\nУдочка: %s\nЛеска: %s\nПоплавок: %s\nКрючок: %s\nНаживка: %s" % [
		current_tackle.get("rod", {}).get("name", "-"),
		current_tackle.get("line", {}).get("name", "-"),
		current_tackle.get("float", {}).get("name", "-"),
		current_tackle.get("hook", {}).get("name", "-"),
		current_tackle.get("bait", {}).get("name", "-")
	]
