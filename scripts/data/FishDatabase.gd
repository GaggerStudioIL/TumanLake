extends Node

var fish_data := {
	"roach": {
		"id": "roach",
		"name": "Плотва",
		"rarity": "common",
		"behavior": "calm",
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
		"behavior": "calm",
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
		"behavior": fish.get("behavior", "calm"),
		"weight": weight,
		"price": price,
		"description": fish["description"]
	}
