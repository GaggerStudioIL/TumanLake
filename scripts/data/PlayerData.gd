extends Node

const TACKLE_CATALOG := {
	"simple_pole_rod_4m": {
		"id": "simple_pole_rod_4m",
		"name": "Простая маховая удочка 4 м",
		"type": "rod",
		"category": "rod",
		"rarity": "common",
		"price": 0,
		"description": "Стартовое маховое удилище. Подходит для небольшой рыбы у берега.",
		"stats": {
			"max_fish_weight": 2.0,
			"strength": 0.85,
			"stiffness": 0.85,
			"tension_bonus": 0.05,
			"control_bonus": 0.05,
			"durability": 1.0,
			"durability_loss": 0.012
		}
	},
	"shore_pole_rod_5m": {
		"id": "shore_pole_rod_5m",
		"name": "Береговая удочка 5 м",
		"type": "rod",
		"category": "rod",
		"rarity": "uncommon",
		"price": 220,
		"description": "Более длинное и упругое удилище. Лучше держит среднюю рыбу.",
		"stats": {
			"max_fish_weight": 3.6,
			"strength": 1.08,
			"stiffness": 1.08,
			"tension_bonus": 0.10,
			"control_bonus": 0.10,
			"durability": 1.0,
			"durability_loss": 0.010
		}
	},
	"reinforced_pole_rod_6m": {
		"id": "reinforced_pole_rod_6m",
		"name": "Усиленная удочка 6 м",
		"type": "rod",
		"category": "rod",
		"rarity": "rare",
		"price": 540,
		"description": "Жёсткий бланк для крупной рыбы. Даёт больше контроля при вываживании.",
		"stats": {
			"max_fish_weight": 6.0,
			"strength": 1.35,
			"stiffness": 1.35,
			"tension_bonus": 0.16,
			"control_bonus": 0.16,
			"durability": 1.0,
			"durability_loss": 0.008
		}
	},
	"mono_1_2kg": {
		"id": "mono_1_2kg",
		"name": "Леска 1.2 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 55,
		"description": "Тонкая леска для осторожной небольшой рыбы.",
		"stats": {
			"max_load_kg": 1.2,
			"max_load": 1.2,
			"break_resistance": 0.88,
			"break_chance": 0.18,
			"visibility": 0.07,
			"durability": 1.0,
			"wear_rate": 0.025
		}
	},
	"mono_2_5kg": {
		"id": "mono_2_5kg",
		"name": "Леска 2.5 кг",
		"type": "line",
		"category": "line",
		"rarity": "uncommon",
		"price": 145,
		"description": "Универсальная леска для средней рыбы. Чуть заметнее, но надёжнее.",
		"stats": {
			"max_load_kg": 2.5,
			"max_load": 2.5,
			"break_resistance": 1.02,
			"break_chance": 0.13,
			"visibility": 0.10,
			"durability": 1.0,
			"wear_rate": 0.020
		}
	},
	"mono_5kg": {
		"id": "mono_5kg",
		"name": "Леска 5 кг",
		"type": "line",
		"category": "line",
		"rarity": "rare",
		"price": 360,
		"description": "Прочная леска для крупной рыбы. Заметнее в воде, зато прощает ошибки.",
		"stats": {
			"max_load_kg": 5.0,
			"max_load": 5.0,
			"break_resistance": 1.16,
			"break_chance": 0.09,
			"visibility": 0.15,
			"durability": 1.0,
			"wear_rate": 0.016
		}
	},
	"lakeline_nylon_basic_1_5kg": {
		"id": "lakeline_nylon_basic_1_5kg",
		"name": "LakeLine Nylon Basic 1.5 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 4,
		"description": "Бюджетная нейлоновая леска 100 м. Стартовый вариант для мелкой рыбы.",
		"stats": {
			"line_type": "nylon",
			"length_m": 100,
			"max_load_kg": 1.5,
			"max_load": 1.5,
			"strength": 1.5,
			"break_resistance": 0.74,
			"break_chance": 0.24,
			"visibility": 0.08,
			"durability": 1.0,
			"wear_rate": 0.034
		}
	},
	"lakeline_nylon_basic_2kg": {
		"id": "lakeline_nylon_basic_2kg",
		"name": "LakeLine Nylon Basic 2 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 5,
		"description": "Бюджетная нейлоновая леска 100 м. Дешёвая и заметная, но доступная с начала игры.",
		"stats": {
			"line_type": "nylon",
			"length_m": 100,
			"max_load_kg": 2.0,
			"max_load": 2.0,
			"strength": 2.0,
			"break_resistance": 0.76,
			"break_chance": 0.23,
			"visibility": 0.09,
			"durability": 1.0,
			"wear_rate": 0.033
		}
	},
	"lakeline_nylon_basic_2_5kg": {
		"id": "lakeline_nylon_basic_2_5kg",
		"name": "LakeLine Nylon Basic 2.5 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 6,
		"description": "Бюджетная нейлоновая леска 100 м для лёгкой маховой снасти.",
		"stats": {
			"line_type": "nylon",
			"length_m": 100,
			"max_load_kg": 2.5,
			"max_load": 2.5,
			"strength": 2.5,
			"break_resistance": 0.78,
			"break_chance": 0.22,
			"visibility": 0.10,
			"durability": 1.0,
			"wear_rate": 0.032
		}
	},
	"lakeline_nylon_basic_3kg": {
		"id": "lakeline_nylon_basic_3kg",
		"name": "LakeLine Nylon Basic 3 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 8,
		"description": "Бюджетная нейлоновая леска 100 м для начальной ловли на озере.",
		"stats": {
			"line_type": "nylon",
			"length_m": 100,
			"max_load_kg": 3.0,
			"max_load": 3.0,
			"strength": 3.0,
			"break_resistance": 0.80,
			"break_chance": 0.21,
			"visibility": 0.11,
			"durability": 1.0,
			"wear_rate": 0.031
		}
	},
	"lakeline_nylon_basic_4kg": {
		"id": "lakeline_nylon_basic_4kg",
		"name": "LakeLine Nylon Basic 4 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 11,
		"description": "Недорогая нейлоновая леска 100 м. Подходит для осторожного апгрейда снасти.",
		"stats": {
			"line_type": "nylon",
			"length_m": 100,
			"max_load_kg": 4.0,
			"max_load": 4.0,
			"strength": 4.0,
			"break_resistance": 0.83,
			"break_chance": 0.20,
			"visibility": 0.13,
			"durability": 1.0,
			"wear_rate": 0.030
		}
	},
	"lakeline_nylon_basic_5kg": {
		"id": "lakeline_nylon_basic_5kg",
		"name": "LakeLine Nylon Basic 5 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 14,
		"description": "Бюджетная нейлоновая леска 100 м. Более прочная, но заметнее в воде.",
		"stats": {
			"line_type": "nylon",
			"length_m": 100,
			"max_load_kg": 5.0,
			"max_load": 5.0,
			"strength": 5.0,
			"break_resistance": 0.86,
			"break_chance": 0.19,
			"visibility": 0.15,
			"durability": 1.0,
			"wear_rate": 0.029
		}
	},
	"lakeline_nylon_basic_6kg": {
		"id": "lakeline_nylon_basic_6kg",
		"name": "LakeLine Nylon Basic 6 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 18,
		"description": "Бюджетная нейлоновая леска 100 м для рыбы покрупнее.",
		"stats": {
			"line_type": "nylon",
			"length_m": 100,
			"max_load_kg": 6.0,
			"max_load": 6.0,
			"strength": 6.0,
			"break_resistance": 0.89,
			"break_chance": 0.18,
			"visibility": 0.17,
			"durability": 1.0,
			"wear_rate": 0.028
		}
	},
	"lakeline_nylon_basic_8kg": {
		"id": "lakeline_nylon_basic_8kg",
		"name": "LakeLine Nylon Basic 8 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 25,
		"description": "Бюджетная нейлоновая леска 100 м. Сильнее, но уже заметно грубее.",
		"stats": {
			"line_type": "nylon",
			"length_m": 100,
			"max_load_kg": 8.0,
			"max_load": 8.0,
			"strength": 8.0,
			"break_resistance": 0.93,
			"break_chance": 0.16,
			"visibility": 0.21,
			"durability": 1.0,
			"wear_rate": 0.027
		}
	},
	"lakeline_nylon_basic_10kg": {
		"id": "lakeline_nylon_basic_10kg",
		"name": "LakeLine Nylon Basic 10 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 32,
		"description": "Простая нейлоновая леска 100 м для тяжёлой бюджетной оснастки.",
		"stats": {
			"line_type": "nylon",
			"length_m": 100,
			"max_load_kg": 10.0,
			"max_load": 10.0,
			"strength": 10.0,
			"break_resistance": 0.97,
			"break_chance": 0.15,
			"visibility": 0.25,
			"durability": 1.0,
			"wear_rate": 0.026
		}
	},
	"lakeline_nylon_basic_12kg": {
		"id": "lakeline_nylon_basic_12kg",
		"name": "LakeLine Nylon Basic 12 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 40,
		"description": "Бюджетная нейлоновая леска 100 м. Прочная, но грубая для осторожной рыбы.",
		"stats": {
			"line_type": "nylon",
			"length_m": 100,
			"max_load_kg": 12.0,
			"max_load": 12.0,
			"strength": 12.0,
			"break_resistance": 1.00,
			"break_chance": 0.14,
			"visibility": 0.29,
			"durability": 1.0,
			"wear_rate": 0.025
		}
	},
	"lakeline_nylon_basic_15kg": {
		"id": "lakeline_nylon_basic_15kg",
		"name": "LakeLine Nylon Basic 15 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 52,
		"description": "Толстая бюджетная нейлоновая леска 100 м для силовой ловли.",
		"stats": {
			"line_type": "nylon",
			"length_m": 100,
			"max_load_kg": 15.0,
			"max_load": 15.0,
			"strength": 15.0,
			"break_resistance": 1.05,
			"break_chance": 0.13,
			"visibility": 0.34,
			"durability": 1.0,
			"wear_rate": 0.024
		}
	},
	"lakeline_nylon_basic_18kg": {
		"id": "lakeline_nylon_basic_18kg",
		"name": "LakeLine Nylon Basic 18 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 62,
		"description": "Толстая бюджетная нейлоновая леска 100 м. Дешёвая сила ценой заметности.",
		"stats": {
			"line_type": "nylon",
			"length_m": 100,
			"max_load_kg": 18.0,
			"max_load": 18.0,
			"strength": 18.0,
			"break_resistance": 1.10,
			"break_chance": 0.12,
			"visibility": 0.39,
			"durability": 1.0,
			"wear_rate": 0.023
		}
	},
	"lakeline_nylon_basic_20kg": {
		"id": "lakeline_nylon_basic_20kg",
		"name": "LakeLine Nylon Basic 20 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 70,
		"description": "Самая прочная леска LakeLine Nylon Basic 100 м. Бюджетная, толстая и хорошо заметная.",
		"stats": {
			"line_type": "nylon",
			"length_m": 100,
			"max_load_kg": 20.0,
			"max_load": 20.0,
			"strength": 20.0,
			"break_resistance": 1.13,
			"break_chance": 0.11,
			"visibility": 0.43,
			"durability": 1.0,
			"wear_rate": 0.022
		}
	},
	"light_float": {
		"id": "light_float",
		"name": "Лёгкий поплавок",
		"type": "float",
		"category": "float",
		"rarity": "common",
		"price": 35,
		"description": "Чувствительный поплавок для спокойной воды и аккуратных поклёвок.",
		"stats": {
			"sensitivity": 0.14,
			"stability": 0.06,
			"bite_visibility": 0.12
		}
	},
	"medium_float": {
		"id": "medium_float",
		"name": "Средний поплавок",
		"type": "float",
		"category": "float",
		"rarity": "uncommon",
		"price": 95,
		"description": "Стабильный поплавок. Меньше шумит в мини-игре при рывках.",
		"stats": {
			"sensitivity": 0.10,
			"stability": 0.18,
			"bite_visibility": 0.10
		}
	},
	"night_float": {
		"id": "night_float",
		"name": "Ночной поплавок",
		"type": "float",
		"category": "float",
		"rarity": "rare",
		"price": 190,
		"description": "Хорошо заметен в тумане и сумерках. Помогает быстрее увидеть поклёвку.",
		"stats": {
			"sensitivity": 0.09,
			"stability": 0.15,
			"bite_visibility": 0.24
		}
	},
	"small_hook_12": {
		"id": "small_hook_12",
		"name": "Крючок малый №12",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 24,
		"description": "Малый крючок для плотвы, краснопёрки и карася.",
		"stats": {
			"hook_size": 12,
			"hook_strength": 0.75,
			"hook_chance": 0.08,
			"target_fish_size": "small",
			"fish_escape_modifier": 0.92,
			"durability": 1.0,
			"wear_rate": 0.028
		}
	},
	"medium_hook_8": {
		"id": "medium_hook_8",
		"name": "Крючок средний №8",
		"type": "hook",
		"category": "hook",
		"rarity": "uncommon",
		"price": 70,
		"description": "Универсальный крючок для средней рыбы.",
		"stats": {
			"hook_size": 8,
			"hook_strength": 1.05,
			"hook_chance": 0.11,
			"target_fish_size": "medium",
			"fish_escape_modifier": 0.86,
			"durability": 1.0,
			"wear_rate": 0.024
		}
	},
	"large_hook_4": {
		"id": "large_hook_4",
		"name": "Крючок крупный №4",
		"type": "hook",
		"category": "hook",
		"rarity": "rare",
		"price": 155,
		"description": "Крупный крючок для сильной рыбы. Мелочь клюёт хуже.",
		"stats": {
			"hook_size": 4,
			"hook_strength": 1.35,
			"hook_chance": 0.12,
			"target_fish_size": "large",
			"fish_escape_modifier": 0.82,
			"durability": 1.0,
			"wear_rate": 0.022
		}
	},
	"worm": {
		"id": "worm",
		"name": "Червь",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 12,
		"description": "Универсальная наживка. Хорошо работает по плотве, окуню и карасю.",
		"stats": {
			"bait_type": "worm",
			"fish_attraction": 0.14,
			"fish_attraction_by_id": {
				"roach": 0.28,
				"rotan": 0.20,
				"ruffe": 0.18,
				"perch": 0.22,
				"crucian": 0.24,
				"silver_crucian": 0.22,
				"golden_crucian": 0.18
			},
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"bread": {
		"id": "bread",
		"name": "Хлеб",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 10,
		"description": "Дешёвая наживка для спокойной белой рыбы.",
		"stats": {
			"bait_type": "bread",
			"fish_attraction": 0.08,
			"fish_attraction_by_id": {
				"bleak": 0.28,
				"roach": 0.22,
				"rudd": 0.20,
				"silver_crucian": 0.16,
				"golden_crucian": 0.12,
				"bream": 0.12
			},
			"allowed_rarities": ["common", "uncommon"]
		}
	},
	"dough": {
		"id": "dough",
		"name": "Тесто",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 14,
		"description": "Мягкая наживка для карася, плотвы и краснопёрки.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.11,
			"fish_attraction_by_id": {
				"crucian": 0.26,
				"silver_crucian": 0.24,
				"golden_crucian": 0.26,
				"roach": 0.16,
				"rudd": 0.18
			},
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"maggot": {
		"id": "maggot",
		"name": "Опарыш",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 18,
		"description": "Активная наживка. Лучше провоцирует окуня и мелкую рыбу.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.15,
			"fish_attraction_by_id": {
				"bleak": 0.24,
				"rotan": 0.20,
				"ruffe": 0.22,
				"perch": 0.26,
				"roach": 0.18,
				"rudd": 0.16
			},
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	}
}
const TACKLE_SLOTS := ["rod", "line", "float", "hook", "bait"]

var money: float = 0.0
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 175
var current_waterbody: String = "agamin_lake"
var unlocked_waterbodies: Array = ["agamin_lake"]
var current_spot: String = "old_oak_pier"
var unlocked_spots: Array = ["old_oak_pier"]
var upgrades: Array = []
var fishing_depth: float = 1.2
var owned_items: Array = get_default_owned_items()
var current_tackle: Dictionary = get_default_tackle()

func format_money_amount(value: float) -> String:
	var rounded_value: float = round(value * 100.0) / 100.0

	if abs(rounded_value - round(rounded_value)) < 0.005:
		return "%d" % int(round(rounded_value))
	if abs(rounded_value * 10.0 - round(rounded_value * 10.0)) < 0.005:
		return "%.1f" % rounded_value
	return "%.2f" % rounded_value

func format_money(value: float, suffix: String = "мон.") -> String:
	return "%s %s" % [format_money_amount(value), suffix]

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

	if levels_gained > 0:
		refresh_waterbody_unlocks()

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

	refresh_waterbody_unlocks()

func refresh_waterbody_unlocks() -> void:
	for waterbody in _get_all_waterbodies():
		var waterbody_id := str(waterbody.get("id", ""))
		if level >= int(waterbody.get("required_level", 1)) and not unlocked_waterbodies.has(waterbody_id):
			unlocked_waterbodies.append(waterbody_id)

	if not unlocked_waterbodies.has("agamin_lake"):
		unlocked_waterbodies.append("agamin_lake")

	if not unlocked_waterbodies.has(current_waterbody):
		current_waterbody = "agamin_lake"

func set_unlocked_waterbodies(saved_waterbodies: Array) -> void:
	unlocked_waterbodies = []

	for waterbody_id in saved_waterbodies:
		var id := str(waterbody_id)
		if id != "" and _get_waterbody(id).is_empty() == false and not unlocked_waterbodies.has(id):
			unlocked_waterbodies.append(id)

	refresh_waterbody_unlocks()

func can_use_waterbody(waterbody_id: String) -> bool:
	var waterbody_db := _get_waterbody_database()
	if waterbody_db == null:
		return waterbody_id == "agamin_lake"

	return unlocked_waterbodies.has(waterbody_id) and bool(waterbody_db.call("is_unlocked", waterbody_id, level))

func set_current_waterbody(waterbody_id: String) -> bool:
	if not can_use_waterbody(waterbody_id):
		return false

	current_waterbody = waterbody_id
	var spot := SpotDatabase.get_spot(current_spot)
	if spot.is_empty() or str(spot.get("waterbody_id", "")) != current_waterbody:
		current_spot = _get_primary_waterbody_spot(current_waterbody)

	clamp_fishing_depth_to_current_spot()
	return true

func set_current_spot(spot_id: String) -> bool:
	var spot := SpotDatabase.get_spot(spot_id)

	if spot.is_empty():
		return false
	if str(spot.get("waterbody_id", current_waterbody)) != current_waterbody:
		return false

	current_spot = spot_id
	clamp_fishing_depth_to_current_spot()
	return true

func _get_waterbody_database() -> Node:
	return get_node_or_null("/root/WaterbodyDatabase")

func _get_all_waterbodies() -> Array:
	var waterbody_db := _get_waterbody_database()

	if waterbody_db == null:
		return [{"id": "agamin_lake", "required_level": 1}]

	var raw_waterbodies = waterbody_db.call("get_all_waterbodies")
	if typeof(raw_waterbodies) == TYPE_ARRAY:
		return raw_waterbodies

	return [{"id": "agamin_lake", "required_level": 1}]

func _get_waterbody(waterbody_id: String) -> Dictionary:
	var waterbody_db := _get_waterbody_database()

	if waterbody_db == null:
		if waterbody_id == "agamin_lake":
			return {"id": "agamin_lake", "required_level": 1}
		return {}

	var raw_waterbody = waterbody_db.call("get_waterbody", waterbody_id)
	if typeof(raw_waterbody) == TYPE_DICTIONARY:
		return raw_waterbody

	return {}

func _get_primary_waterbody_spot(waterbody_id: String) -> String:
	var waterbody_db := _get_waterbody_database()

	if waterbody_db == null:
		return "old_oak_pier"

	return str(waterbody_db.call("get_primary_spot", waterbody_id))

func set_fishing_depth(value: float) -> void:
	var depth_range := get_current_spot_depth_range()
	fishing_depth = snapped(clamp(value, float(depth_range["min"]), float(depth_range["max"])), 0.1)

func adjust_fishing_depth(delta: float) -> void:
	set_fishing_depth(fishing_depth + delta)

func clamp_fishing_depth_to_current_spot() -> void:
	set_fishing_depth(fishing_depth)

func get_current_spot_depth_range() -> Dictionary:
	var spot := SpotDatabase.get_spot(current_spot)

	if spot.is_empty():
		return {"min": 0.2, "max": 6.0, "preferred": clamp(fishing_depth, 0.2, 6.0)}

	return {
		"min": float(spot.get("min_depth", 0.2)),
		"max": float(spot.get("max_depth", 6.0)),
		"preferred": float(spot.get("preferred_depth", spot.get("depth", 1.2)))
	}

func get_tackle_catalog_item(item_id: String) -> Dictionary:
	var item: Dictionary = TACKLE_CATALOG.get(item_id, {})

	if item.is_empty():
		return {}

	return item.duplicate(true)

func get_tackle_catalog_items(type_filter: String = "all") -> Array:
	var items: Array = []

	for item_id in TACKLE_CATALOG.keys():
		var item: Dictionary = TACKLE_CATALOG[item_id].duplicate(true)
		var item_type := str(item.get("type", item.get("category", "misc")))

		if type_filter == "all" or item_type == type_filter:
			items.append(item)

	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var category_order := {"rod": 0, "line": 1, "float": 2, "hook": 3, "bait": 4}
		var type_a := str(a.get("type", a.get("category", "misc")))
		var type_b := str(b.get("type", b.get("category", "misc")))
		var order_a: int = int(category_order.get(type_a, 9))
		var order_b: int = int(category_order.get(type_b, 9))
		if order_a == order_b:
			return float(a.get("price", 0.0)) < float(b.get("price", 0.0))
		return order_a < order_b
	)

	return items

func get_tackle_shop_items() -> Array:
	var items: Array = []
	var starter_ids := {
		"simple_pole_rod_4m": true,
		"mono_1_2kg": true,
		"light_float": true,
		"small_hook_12": true
	}

	for item in get_tackle_catalog_items("all"):
		if starter_ids.has(str(item.get("id", ""))):
			continue

		if float(item.get("price", 0.0)) > 0.0 and str(item.get("type", "")) != "bait":
			var shop_item: Dictionary = item.duplicate(true)
			shop_item["shop_category"] = "tackle"
			shop_item["quantity"] = 1
			shop_item["icon"] = _get_item_icon(str(shop_item.get("type", shop_item.get("category", ""))))
			items.append(shop_item)

	return items

func _make_tackle_component(item_id: String) -> Dictionary:
	var item := get_tackle_catalog_item(item_id)

	if item.is_empty():
		return {}

	var component: Dictionary = item.get("stats", {}).duplicate(true)
	var item_type := str(item.get("type", item.get("category", "misc")))
	var category := str(item.get("category", item_type))
	component = _normalize_equipment_stats(component, category)
	component["id"] = item["id"]
	component["name"] = item["name"]
	component["type"] = item_type
	component["category"] = category
	component["rarity"] = item.get("rarity", "common")
	component["price"] = float(item.get("price", 0.0))
	component["description"] = str(item.get("description", ""))
	return component

func _make_owned_catalog_item(item_id: String, quantity: int = 1) -> Dictionary:
	var item := get_tackle_catalog_item(item_id)

	if item.is_empty():
		return {}

	item["quantity"] = max(quantity, 1)
	return _normalize_owned_item(item)

func _get_item_icon(item_type: String) -> String:
	match item_type:
		"rod":
			return "R"
		"line":
			return "L"
		"float":
			return "F"
		"hook":
			return "H"
		"bait":
			return "B"
		_:
			return "?"

func _normalize_equipment_stats(stats: Dictionary, category: String) -> Dictionary:
	var normalized := stats.duplicate(true)

	match category:
		"rod":
			if not normalized.has("control_bonus"):
				normalized["control_bonus"] = float(normalized.get("tension_bonus", 0.0))
			if not normalized.has("tension_bonus"):
				normalized["tension_bonus"] = float(normalized.get("control_bonus", 0.0))
			if not normalized.has("stiffness"):
				normalized["stiffness"] = float(normalized.get("strength", 1.0))
			if not normalized.has("strength"):
				normalized["strength"] = float(normalized.get("stiffness", 1.0))
			if not normalized.has("max_fish_weight"):
				normalized["max_fish_weight"] = 1.0
			if not normalized.has("durability"):
				normalized["durability"] = 1.0
			if not normalized.has("durability_loss"):
				normalized["durability_loss"] = 0.012
			normalized["durability"] = clamp(float(normalized["durability"]), 0.0, 1.0)
		"line":
			var max_load: float = float(normalized.get("max_load", normalized.get("max_load_kg", normalized.get("strength", 1.0))))
			normalized["max_load"] = max_load
			normalized["max_load_kg"] = max_load
			if not normalized.has("strength"):
				normalized["strength"] = max_load
			if not normalized.has("break_resistance"):
				normalized["break_resistance"] = 1.0
			if not normalized.has("break_chance"):
				normalized["break_chance"] = 0.15
			if not normalized.has("wear_rate"):
				normalized["wear_rate"] = 0.022
			if not normalized.has("visibility") and normalized.has("visibility_penalty"):
				normalized["visibility"] = normalized["visibility_penalty"]
			if not normalized.has("visibility"):
				normalized["visibility"] = 0.08
			if not normalized.has("durability"):
				normalized["durability"] = 1.0
			normalized["durability"] = clamp(float(normalized["durability"]), 0.0, 1.0)
		"hook":
			if not normalized.has("hook_chance") and normalized.has("hook_success_bonus"):
				normalized["hook_chance"] = normalized["hook_success_bonus"]
			if not normalized.has("hook_chance"):
				normalized["hook_chance"] = 0.08
			if not normalized.has("target_fish_size"):
				normalized["target_fish_size"] = "small"
			if not normalized.has("hook_strength"):
				match str(normalized.get("target_fish_size", "small")):
					"large":
						normalized["hook_strength"] = 1.35
					"medium":
						normalized["hook_strength"] = 1.05
					_:
						normalized["hook_strength"] = 0.75
			if not normalized.has("fish_escape_modifier"):
				normalized["fish_escape_modifier"] = 1.0
			if not normalized.has("wear_rate"):
				normalized["wear_rate"] = 0.026
			if not normalized.has("durability"):
				normalized["durability"] = 1.0
			normalized["durability"] = clamp(float(normalized["durability"]), 0.0, 1.0)

	return normalized

func _normalize_owned_item(item: Dictionary) -> Dictionary:
	var item_id := str(item.get("id", ""))
	var catalog_item := get_tackle_catalog_item(item_id)
	var item_type := str(item.get("type", item.get("category", catalog_item.get("type", catalog_item.get("category", "misc")))))
	var category := str(item.get("category", catalog_item.get("category", item_type)))
	var catalog_stats: Dictionary = {}
	var catalog_raw_stats = catalog_item.get("stats", {})
	if typeof(catalog_raw_stats) == TYPE_DICTIONARY:
		catalog_stats = catalog_raw_stats.duplicate(true)
	var raw_stats = item.get("stats", catalog_stats)
	var stats: Dictionary = catalog_stats.duplicate(true)
	if typeof(raw_stats) == TYPE_DICTIONARY:
		stats.merge(raw_stats, true)
	stats = _normalize_equipment_stats(stats, category)

	return {
		"id": item_id,
		"name": str(item.get("name", catalog_item.get("name", "-"))),
		"type": item_type,
		"category": category,
		"rarity": str(item.get("rarity", catalog_item.get("rarity", "common"))),
		"price": float(item.get("price", catalog_item.get("price", 0.0))),
		"quantity": max(int(item.get("quantity", 1)), 0),
		"description": str(item.get("description", catalog_item.get("description", ""))),
		"stats": stats
	}

func get_default_tackle() -> Dictionary:
	return {
		"rod": _make_tackle_component("simple_pole_rod_4m"),
		"line": _make_tackle_component("mono_1_2kg"),
		"float": _make_tackle_component("light_float"),
		"hook": _make_tackle_component("small_hook_12"),
		"bait": _make_tackle_component("worm")
	}

func get_default_owned_items() -> Array:
	return [
		_make_owned_catalog_item("simple_pole_rod_4m", 1),
		_make_owned_catalog_item("mono_1_2kg", 1),
		_make_owned_catalog_item("light_float", 1),
		_make_owned_catalog_item("small_hook_12", 1),
		_make_owned_catalog_item("worm", 30)
	]

func set_current_tackle(saved_tackle: Dictionary) -> void:
	var default_tackle := get_default_tackle()
	current_tackle = default_tackle.duplicate(true)

	for slot in TACKLE_SLOTS:
		if not saved_tackle.has(slot):
			continue

		var saved_component = saved_tackle[slot]
		if typeof(saved_component) != TYPE_DICTIONARY:
			continue

		var merged_component: Dictionary = current_tackle[slot].duplicate(true)
		merged_component.merge(saved_component, true)
		merged_component["type"] = slot
		merged_component["category"] = slot

		if slot == "rod":
			if not merged_component.has("tension_bonus") and merged_component.has("control_bonus"):
				merged_component["tension_bonus"] = merged_component["control_bonus"]
			if not merged_component.has("strength"):
				merged_component["strength"] = 1.0
		elif slot == "line":
			if not merged_component.has("max_load_kg") and merged_component.has("strength"):
				merged_component["max_load_kg"] = merged_component["strength"]
			if not merged_component.has("visibility") and merged_component.has("visibility_penalty"):
				merged_component["visibility"] = merged_component["visibility_penalty"]
		elif slot == "float":
			if not merged_component.has("sensitivity") and merged_component.has("bite_detection_bonus"):
				merged_component["sensitivity"] = merged_component["bite_detection_bonus"]
			if not merged_component.has("bite_visibility"):
				merged_component["bite_visibility"] = 0.0
		elif slot == "hook":
			if not merged_component.has("hook_chance") and merged_component.has("hook_success_bonus"):
				merged_component["hook_chance"] = merged_component["hook_success_bonus"]
			if not merged_component.has("target_fish_size"):
				merged_component["target_fish_size"] = "small"

		merged_component = _normalize_equipment_stats(merged_component, slot)
		current_tackle[slot] = merged_component

func set_owned_items(saved_items: Array) -> void:
	if saved_items.is_empty():
		owned_items = get_default_owned_items()
		return

	owned_items = []

	for item in saved_items:
		if typeof(item) != TYPE_DICTIONARY:
			continue

		var normalized_item := _normalize_owned_item(item)

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
	var category := str(item.get("category", ""))

	if not TACKLE_SLOTS.has(category) or int(item.get("quantity", 0)) <= 0:
		return false

	if ["rod", "line", "hook"].has(category):
		var stats: Dictionary = item.get("stats", {})
		return float(stats.get("durability", 1.0)) > 0.05

	return true

func equip_item(item_id: String) -> bool:
	var item := get_owned_item(item_id)

	if item.is_empty() or not can_equip_item(item):
		return false

	var category := str(item["category"])
	var component: Dictionary = _normalize_equipment_stats(item.get("stats", {}).duplicate(true), category)
	component["id"] = item["id"]
	component["name"] = item["name"]
	component["type"] = item.get("type", category)
	component["category"] = category
	component["rarity"] = item.get("rarity", "common")
	component["price"] = float(item.get("price", 0.0))
	component["description"] = str(item.get("description", ""))

	if category == "bait":
		component["quantity"] = int(item.get("quantity", 0))

	current_tackle[category] = component
	return true

func get_owned_item(item_id: String) -> Dictionary:
	for item in owned_items:
		if str(item.get("id", "")) == item_id:
			return item

	return {}

func add_owned_item(item: Dictionary, amount: int = 1) -> void:
	var item_id := str(item.get("id", ""))

	if item_id == "":
		return

	var quantity_to_add: int = max(amount, 1)
	var item_category := str(item.get("category", "misc"))
	var normalized_item := _normalize_owned_item(item)

	for owned_item in owned_items:
		if str(owned_item.get("id", "")) != item_id:
			continue

		owned_item["quantity"] = max(int(owned_item.get("quantity", 0)), 0) + quantity_to_add
		owned_item["name"] = str(normalized_item.get("name", owned_item.get("name", "-")))
		owned_item["type"] = str(normalized_item.get("type", owned_item.get("type", item_category)))
		owned_item["category"] = str(normalized_item.get("category", owned_item.get("category", item_category)))
		owned_item["rarity"] = str(normalized_item.get("rarity", owned_item.get("rarity", "common")))
		owned_item["price"] = float(normalized_item.get("price", owned_item.get("price", 0.0)))
		owned_item["description"] = str(normalized_item.get("description", owned_item.get("description", "")))

		if ["rod", "line", "hook"].has(item_category):
			var refreshed_stats: Dictionary = normalized_item.get("stats", {}).duplicate(true)
			var owned_stats: Dictionary = owned_item.get("stats", {})
			refreshed_stats["durability"] = max(
				float(refreshed_stats.get("durability", 1.0)),
				float(owned_stats.get("durability", 0.0))
			)
			owned_item["stats"] = refreshed_stats
		else:
			owned_item["stats"] = normalized_item.get("stats", {}).duplicate(true)

		if current_tackle.has(item_category) and str(current_tackle[item_category].get("id", "")) == item_id:
			_refresh_current_tackle_from_owned_item(owned_item)

		return

	normalized_item["quantity"] = quantity_to_add
	owned_items.append(normalized_item)

func _refresh_current_tackle_from_owned_item(owned_item: Dictionary) -> void:
	var category := str(owned_item.get("category", ""))

	if not current_tackle.has(category):
		return

	if str(current_tackle[category].get("id", "")) != str(owned_item.get("id", "")):
		return

	var stats: Dictionary = _normalize_equipment_stats(owned_item.get("stats", {}).duplicate(true), category)
	for key in stats.keys():
		current_tackle[category][key] = stats[key]

	current_tackle[category]["quantity"] = int(owned_item.get("quantity", 0))

func _change_owned_item_quantity(item_id: String, delta: int) -> int:
	for item in owned_items:
		if str(item.get("id", "")) != item_id:
			continue

		item["quantity"] = max(int(item.get("quantity", 0)) + delta, 0)
		_refresh_current_tackle_from_owned_item(item)
		return int(item["quantity"])

	return 0

func _set_owned_item_durability(item_id: String, durability: float) -> void:
	for item in owned_items:
		if str(item.get("id", "")) != item_id:
			continue

		var category := str(item.get("category", ""))
		var stats: Dictionary = _normalize_equipment_stats(item.get("stats", {}).duplicate(true), category)
		stats["durability"] = clamp(durability, 0.0, 1.0)
		item["stats"] = stats
		_refresh_current_tackle_from_owned_item(item)
		return

func get_tackle_condition(slot: String) -> float:
	if not current_tackle.has(slot):
		return 0.0

	return clamp(float(current_tackle[slot].get("durability", 1.0)), 0.0, 1.0)

func get_tackle_block_reason() -> String:
	var rod_condition := get_tackle_condition("rod")
	var line_condition := get_tackle_condition("line")
	var hook_condition := get_tackle_condition("hook")

	if rod_condition <= 0.08:
		return "Удочка повреждена. Экипируй другую удочку."

	var line_id := str(current_tackle.get("line", {}).get("id", ""))
	if _get_owned_item_quantity(line_id) <= 0 or line_condition <= 0.08:
		return "Леска порвана. Купи или экипируй другую леску."

	var hook_id := str(current_tackle.get("hook", {}).get("id", ""))
	if _get_owned_item_quantity(hook_id) <= 0 or hook_condition <= 0.08:
		return "Крючок потерян или поврежден. Экипируй другой крючок."

	return ""

func _get_owned_item_quantity(item_id: String) -> int:
	for item in owned_items:
		if str(item.get("id", "")) == item_id:
			return int(item.get("quantity", 0))

	return 0

func apply_tackle_wear(wear: Dictionary) -> Dictionary:
	var result := {
		"rod_broken": bool(wear.get("rod_broken", false)),
		"line_broken": bool(wear.get("line_broken", false)),
		"hook_lost": bool(wear.get("hook_lost", false)),
		"rod_old": get_tackle_condition("rod"),
		"line_old": get_tackle_condition("line"),
		"hook_old": get_tackle_condition("hook")
	}

	for slot in ["rod", "line", "hook"]:
		if not current_tackle.has(slot):
			continue

		var item_id := str(current_tackle[slot].get("id", ""))
		var old_condition: float = get_tackle_condition(slot)
		var new_condition: float = clamp(old_condition - max(float(wear.get(slot, 0.0)), 0.0), 0.0, 1.0)

		if slot == "rod" and bool(wear.get("rod_broken", false)):
			new_condition = min(new_condition, 0.04)
		elif slot == "line" and bool(wear.get("line_broken", false)):
			var remaining_lines := _change_owned_item_quantity(item_id, -1)
			new_condition = 1.0 if remaining_lines > 0 else 0.0
		elif slot == "hook" and bool(wear.get("hook_lost", false)):
			var remaining_hooks := _change_owned_item_quantity(item_id, -1)
			new_condition = 1.0 if remaining_hooks > 0 else 0.0

		current_tackle[slot]["durability"] = new_condition
		_set_owned_item_durability(item_id, new_condition)
		result["%s_new" % slot] = new_condition

	return result

func get_current_tackle_save_data() -> Dictionary:
	return current_tackle.duplicate(true)

func get_owned_items_save_data() -> Array:
	var items: Array = []

	for item in owned_items:
		items.append(item.duplicate(true))

	return items

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
	var rod: Dictionary = _normalize_equipment_stats(current_tackle.get("rod", {}).duplicate(true), "rod")
	var line: Dictionary = _normalize_equipment_stats(current_tackle.get("line", {}).duplicate(true), "line")
	var float_part: Dictionary = current_tackle.get("float", {})
	var hook: Dictionary = _normalize_equipment_stats(current_tackle.get("hook", {}).duplicate(true), "hook")
	var bait: Dictionary = current_tackle.get("bait", {})
	var rod_durability: float = clamp(float(rod.get("durability", 1.0)), 0.0, 1.0)
	var line_durability: float = clamp(float(line.get("durability", 1.0)), 0.0, 1.0)
	var hook_durability: float = clamp(float(hook.get("durability", 1.0)), 0.0, 1.0)
	var rod_condition: float = lerp(0.45, 1.0, rod_durability)
	var line_condition: float = lerp(0.45, 1.0, line_durability)
	var hook_condition: float = lerp(0.35, 1.0, hook_durability)
	var raw_rod_control: float = float(rod.get("control_bonus", rod.get("tension_bonus", 0.0)))
	var rod_tension_bonus: float = raw_rod_control * rod_condition
	var raw_rod_stiffness: float = float(rod.get("stiffness", rod.get("strength", 1.0)))
	var rod_strength: float = raw_rod_stiffness * lerp(0.55, 1.0, rod_durability)
	var raw_line_strength: float = float(line.get("max_load", line.get("max_load_kg", line.get("strength", 1.0))))
	var line_strength: float = raw_line_strength * line_condition
	var line_visibility: float = float(line.get("visibility", line.get("visibility_penalty", 0.0)))
	var float_sensitivity: float = float(float_part.get("sensitivity", float_part.get("bite_detection_bonus", 0.0)))
	var float_stability: float = float(float_part.get("stability", 0.0))
	var float_bite_visibility: float = float(float_part.get("bite_visibility", 0.0))
	var hook_chance: float = float(hook.get("hook_chance", hook.get("hook_success_bonus", 0.0))) * hook_condition
	var hook_strength: float = float(hook.get("hook_strength", 1.0)) * hook_condition
	var raw_escape_modifier: float = float(hook.get("fish_escape_modifier", 1.0))

	return {
		"control_bonus": rod_tension_bonus,
		"tension_bonus": rod_tension_bonus,
		"durability": rod_durability,
		"rod_durability": rod_durability,
		"line_durability": line_durability,
		"hook_durability": hook_durability,
		"max_fish_weight": float(rod.get("max_fish_weight", 1.0)) * lerp(0.60, 1.0, rod_durability),
		"rod_strength": rod_strength,
		"stiffness": rod_strength,
		"durability_loss": float(rod.get("durability_loss", 0.012)),
		"line_strength": line_strength,
		"max_load_kg": line_strength,
		"max_load": line_strength,
		"raw_line_strength": raw_line_strength,
		"break_resistance": float(line.get("break_resistance", 1.0)) * lerp(0.35, 1.0, line_durability),
		"break_chance": float(line.get("break_chance", 0.15)) / max(lerp(0.45, 1.0, line_durability), 0.1),
		"line_wear_rate": float(line.get("wear_rate", 0.022)),
		"wear_rate": float(line.get("wear_rate", 0.022)),
		"visibility": line_visibility,
		"visibility_penalty": line_visibility,
		"sensitivity": float_sensitivity,
		"bite_visibility": float_bite_visibility,
		"bite_detection_bonus": float_sensitivity + float_bite_visibility * 0.50,
		"stability": float_stability,
		"hook_size": int(hook.get("hook_size", 12)),
		"hook_chance": hook_chance,
		"hook_success_bonus": hook_chance,
		"hook_strength": hook_strength,
		"hook_wear_rate": float(hook.get("wear_rate", 0.026)),
		"target_fish_size": str(hook.get("target_fish_size", "small")),
		"fish_escape_modifier": raw_escape_modifier * lerp(1.45, 1.0, hook_durability),
		"bait_type": str(bait.get("bait_type", "worm")),
		"fishing_depth": fishing_depth,
		"fish_attraction": float(bait.get("fish_attraction", 0.0)),
		"fish_attraction_by_id": bait.get("fish_attraction_by_id", {}),
		"allowed_rarities": bait.get("allowed_rarities", [])
	}

func get_tackle_text() -> String:
	return "Текущая снасть:\nУдочка: %s\nЛеска: %s\nПоплавок: %s\nКрючок: %s\nНаживка: %s x%d\nГлубина: %.1f м\nПрочность: уд. %d%% | леска %d%% | крючок %d%%" % [
		current_tackle.get("rod", {}).get("name", "-"),
		current_tackle.get("line", {}).get("name", "-"),
		current_tackle.get("float", {}).get("name", "-"),
		current_tackle.get("hook", {}).get("name", "-"),
		current_tackle.get("bait", {}).get("name", "-"),
		get_current_bait_quantity(),
		fishing_depth,
		roundi(get_tackle_condition("rod") * 100.0),
		roundi(get_tackle_condition("line") * 100.0),
		roundi(get_tackle_condition("hook") * 100.0)
	]
