extends Node

var fish_data := {
	"roach": {
		"id": "roach",
		"name": "Плотва",
		"rarity": "common",
		"behavior": "calm",
		"behavior_type": "calm",
		"base_fight_power": 0.55,
		"stamina": 0.75,
		"escape_risk": 0.18,
		"weight_difficulty_multiplier": 0.65,
		"base_xp": 5,
		"min_weight": 0.1,
		"max_weight": 0.8,
		"price_per_kg": 12,
		"icon_path": "",
		"description": "Небольшая спокойная рыба туманного озера."
	},
	"perch": {
		"id": "perch",
		"name": "Окунь",
		"rarity": "common",
		"behavior": "aggressive",
		"behavior_type": "aggressive",
		"base_fight_power": 1.05,
		"stamina": 0.95,
		"escape_risk": 0.28,
		"weight_difficulty_multiplier": 0.90,
		"base_xp": 10,
		"min_weight": 0.2,
		"max_weight": 1.2,
		"price_per_kg": 16,
		"icon_path": "",
		"description": "Полосатый хищник у старых свай."
	},
	"crucian": {
		"id": "crucian",
		"name": "Карась",
		"rarity": "common",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 0.85,
		"stamina": 1.15,
		"escape_risk": 0.18,
		"weight_difficulty_multiplier": 0.85,
		"base_xp": 8,
		"min_weight": 0.2,
		"max_weight": 1.5,
		"price_per_kg": 14,
		"icon_path": "",
		"description": "Уютная классика тихой рыбалки."
	},
	"rudd": {
		"id": "rudd",
		"name": "Краснопёрка",
		"rarity": "common",
		"behavior": "erratic",
		"behavior_type": "erratic",
		"base_fight_power": 0.72,
		"stamina": 0.80,
		"escape_risk": 0.32,
		"weight_difficulty_multiplier": 0.75,
		"base_xp": 6,
		"min_weight": 0.1,
		"max_weight": 0.7,
		"price_per_kg": 13,
		"icon_path": "",
		"description": "Мелькает у камышей красным плавником."
	},
	"tench": {
		"id": "tench",
		"name": "Линь",
		"rarity": "uncommon",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 1.05,
		"stamina": 1.35,
		"escape_risk": 0.20,
		"weight_difficulty_multiplier": 1.00,
		"base_xp": 16,
		"min_weight": 0.5,
		"max_weight": 2.5,
		"price_per_kg": 28,
		"icon_path": "",
		"description": "Любит ил, тишину и старые заводи."
	},
	"pike": {
		"id": "pike",
		"name": "Щука",
		"rarity": "uncommon",
		"behavior": "erratic",
		"behavior_type": "erratic",
		"base_fight_power": 1.35,
		"stamina": 1.25,
		"escape_risk": 0.30,
		"weight_difficulty_multiplier": 1.20,
		"base_xp": 22,
		"min_weight": 0.8,
		"max_weight": 5.0,
		"price_per_kg": 34,
		"icon_path": "",
		"description": "Холодная тень среди водорослей."
	},
	"bream": {
		"id": "bream",
		"name": "Лещ",
		"rarity": "uncommon",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 1.12,
		"stamina": 1.40,
		"escape_risk": 0.16,
		"weight_difficulty_multiplier": 1.10,
		"base_xp": 18,
		"min_weight": 0.7,
		"max_weight": 4.0,
		"price_per_kg": 30,
		"icon_path": "",
		"description": "Тяжелая рыба глубокой воды."
	},
	"catfish": {
		"id": "catfish",
		"name": "Сом",
		"rarity": "rare",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 1.65,
		"stamina": 1.80,
		"escape_risk": 0.14,
		"weight_difficulty_multiplier": 1.45,
		"base_xp": 45,
		"min_weight": 3.0,
		"max_weight": 18.0,
		"price_per_kg": 55,
		"icon_path": "",
		"description": "Старый хозяин темного дна."
	},
	"eel": {
		"id": "eel",
		"name": "Угорь",
		"rarity": "rare",
		"behavior": "erratic",
		"behavior_type": "erratic",
		"base_fight_power": 1.15,
		"stamina": 0.90,
		"escape_risk": 0.45,
		"weight_difficulty_multiplier": 1.00,
		"base_xp": 34,
		"min_weight": 0.4,
		"max_weight": 2.2,
		"price_per_kg": 60,
		"icon_path": "",
		"description": "Скользкая ночная находка."
	},
	"zander": {
		"id": "zander",
		"name": "Судак",
		"rarity": "rare",
		"behavior": "aggressive",
		"behavior_type": "aggressive",
		"base_fight_power": 1.40,
		"stamina": 1.20,
		"escape_risk": 0.34,
		"weight_difficulty_multiplier": 1.20,
		"base_xp": 38,
		"min_weight": 1.0,
		"max_weight": 6.0,
		"price_per_kg": 50,
		"icon_path": "",
		"description": "Охотится в глубине и тумане."
	},
	"mist_carp": {
		"id": "mist_carp",
		"name": "Туманный карп",
		"rarity": "legendary",
		"behavior": "erratic",
		"behavior_type": "erratic",
		"base_fight_power": 1.75,
		"stamina": 1.90,
		"escape_risk": 0.38,
		"weight_difficulty_multiplier": 1.55,
		"base_xp": 95,
		"min_weight": 4.0,
		"max_weight": 20.0,
		"price_per_kg": 120,
		"icon_path": "",
		"description": "Рыба, которую видели только в густом тумане."
	},
	"moon_catfish": {
		"id": "moon_catfish",
		"name": "Лунный сом",
		"rarity": "legendary",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 2.00,
		"stamina": 2.20,
		"escape_risk": 0.20,
		"weight_difficulty_multiplier": 1.70,
		"base_xp": 120,
		"min_weight": 8.0,
		"max_weight": 30.0,
		"price_per_kg": 150,
		"icon_path": "",
		"description": "Говорят, он всплывает только под луной."
	}
}

func get_fish(fish_id: String) -> Dictionary:
	return fish_data.get(fish_id, {})

func get_random_fish_id(available_fish: Array, rare_chance_modifier: float) -> String:
	var weighted_list: Array = []

	for fish_id in available_fish:
		var fish := get_fish(fish_id)
		var rarity: String = fish["rarity"]
		var weight := 10

		if rarity == "common":
			weight = 70
		elif rarity == "uncommon":
			weight = 25
		elif rarity == "rare":
			weight = int(7 * rare_chance_modifier)
		elif rarity == "legendary":
			weight = int(1 * rare_chance_modifier)

		for i in weight:
			weighted_list.append(fish_id)

	return weighted_list.pick_random()

func create_catch(fish_id: String) -> Dictionary:
	var fish := get_fish(fish_id)
	var weight: float = snapped(randf_range(fish["min_weight"], fish["max_weight"]), 0.01)
	var price: int = round(weight * fish["price_per_kg"])

	return {
		"id": fish["id"],
		"name": fish["name"],
		"rarity": fish["rarity"],
		"behavior": fish.get("behavior_type", fish.get("behavior", "calm")),
		"behavior_type": fish.get("behavior_type", fish.get("behavior", "calm")),
		"base_fight_power": fish.get("base_fight_power", 1.0),
		"stamina": fish.get("stamina", 1.0),
		"escape_risk": fish.get("escape_risk", 0.25),
		"weight_difficulty_multiplier": fish.get("weight_difficulty_multiplier", 1.0),
		"base_xp": fish.get("base_xp", 5),
		"weight": weight,
		"price": price,
		"description": fish["description"]
	}
