extends Node

var spots := {
	"old_oak_pier": {
		"id": "old_oak_pier",
		"waterbody_id": "agamin_lake",
		"name": "Мостик \"Старый Дуб\"",
		"type": "wooden_pier",
		"spot_type": "деревянный мостик",
		"description": "Мелкий старый мостик у нависающего дуба. Здесь часто держится верховая и мелкая белая рыба.",
		"min_depth": 0.5,
		"max_depth": 1.2,
		"preferred_depth": 0.8,
		"depth": 0.8,
		"fish_pool": ["bleak", "rudd", "roach", "topmouth_gudgeon", "gudgeon"],
		"available_fish": ["bleak", "rudd", "roach", "topmouth_gudgeon", "gudgeon"],
		"unlock_level": 1,
		"required_level": 1,
		"visual_tag": "old_oak",
		"water_profile": "calm_pier",
		"water_mask": "default_lake",
		"map_position": Vector2(0.343, 0.308),
		"info_position": Vector2(0.380, 0.273),
		"map_icon": "oak",
		"recommended_tackle": ["Перо", "Гусиное перо", "Капля"],
		"recommended_bait": ["Хлеб", "Червь"],
		"special_features": ["Мелкая вода", "Осторожная белая рыба", "Тень старого дуба"],
		"bite_chance_modifier": 1.05,
		"rare_chance_modifier": 0.85,
		"wind_shelter": 0.85,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"quiet_water_pier": {
		"id": "quiet_water_pier",
		"waterbody_id": "agamin_lake",
		"name": "Мостик \"Тихая Вода\"",
		"type": "wooden_pier",
		"spot_type": "деревянный мостик",
		"description": "Ровная тихая вода со средним перепадом глубины. Хорошая учебная точка для плотвы, карася и окуня.",
		"min_depth": 1.0,
		"max_depth": 1.8,
		"preferred_depth": 1.4,
		"depth": 1.4,
		"fish_pool": ["roach", "silver_crucian", "golden_crucian", "perch", "ruffe", "gudgeon"],
		"available_fish": ["roach", "silver_crucian", "golden_crucian", "perch", "ruffe", "gudgeon"],
		"unlock_level": 1,
		"required_level": 1,
		"visual_tag": "quiet_water",
		"water_profile": "calm_pier",
		"water_mask": "default_lake",
		"map_position": Vector2(0.833, 0.483),
		"info_position": Vector2(0.870, 0.448),
		"map_icon": "quiet_water",
		"recommended_tackle": ["Капля", "Веретено", "Вагглер"],
		"recommended_bait": ["Червь", "Хлеб"],
		"special_features": ["Спокойная вода", "Учебная точка", "Средняя глубина"],
		"bite_chance_modifier": 1.0,
		"rare_chance_modifier": 1.0,
		"wind_shelter": 0.90,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"reeds_pier": {
		"id": "reeds_pier",
		"waterbody_id": "agamin_lake",
		"name": "Мостик \"Камышовый\"",
		"type": "reeds_pier",
		"spot_type": "камышовый мостик",
		"description": "Камыш, ил и спокойная вода. Карась и линь подходят близко, но снасть лучше держать аккуратно.",
		"min_depth": 0.8,
		"max_depth": 2.0,
		"preferred_depth": 1.3,
		"depth": 1.3,
		"fish_pool": ["silver_crucian", "golden_crucian", "tench", "rotan", "rudd", "young_grass_carp", "young_mirror_carp"],
		"available_fish": ["silver_crucian", "golden_crucian", "tench", "rotan", "rudd", "young_grass_carp", "young_mirror_carp"],
		"unlock_level": 1,
		"required_level": 1,
		"visual_tag": "reeds",
		"water_profile": "reeds",
		"water_mask": "default_lake",
		"map_position": Vector2(0.828, 0.290),
		"info_position": Vector2(0.865, 0.255),
		"map_icon": "reeds",
		"recommended_tackle": ["Камышовая капля", "Бочонок", "Капля"],
		"recommended_bait": ["Червь", "Тесто"],
		"special_features": ["Густые камыши", "Ил", "Карась и линь подходят близко"],
		"bite_chance_modifier": 1.08,
		"rare_chance_modifier": 1.08,
		"wind_shelter": 0.75,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"morning_pier": {
		"id": "morning_pier",
		"waterbody_id": "agamin_lake",
		"name": "Мостик \"Утренний\"",
		"type": "open_water_pier",
		"spot_type": "открытая вода",
		"description": "Открытая точка с прохладной водой. Утром и вечером тут заметно активнее окунь и густера.",
		"min_depth": 1.5,
		"max_depth": 2.5,
		"preferred_depth": 2.0,
		"depth": 2.0,
		"fish_pool": ["perch", "white_bream", "skimmer_bream", "roach", "ruffe", "young_chub", "ide"],
		"available_fish": ["perch", "white_bream", "skimmer_bream", "roach", "ruffe", "young_chub", "ide"],
		"unlock_level": 1,
		"required_level": 1,
		"visual_tag": "open_water",
		"water_profile": "open_water",
		"water_mask": "default_lake",
		"map_position": Vector2(0.825, 0.770),
		"info_position": Vector2(0.862, 0.735),
		"map_icon": "morning",
		"recommended_tackle": ["Вагглер", "Дальнобойный вагглер", "Капля"],
		"recommended_bait": ["Червь", "Мотыль"],
		"special_features": ["Открытая вода", "Лучше утром и вечером", "Хорошо для дальнего заброса"],
		"bite_chance_modifier": 0.98,
		"rare_chance_modifier": 1.05,
		"wind_shelter": 1.05,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"mist_pier": {
		"id": "mist_pier",
		"waterbody_id": "agamin_lake",
		"name": "Мостик \"Туман\"",
		"type": "deep_pier",
		"spot_type": "глубокий мостик",
		"description": "Переход в глубину под утренним туманом. Больше донной рыбы и шанс на хороший вес.",
		"min_depth": 2.0,
		"max_depth": 3.5,
		"preferred_depth": 2.8,
		"depth": 2.8,
		"fish_pool": ["skimmer_bream", "bream", "perch", "white_bream", "silver_crucian", "ide", "young_mirror_carp"],
		"available_fish": ["skimmer_bream", "bream", "perch", "white_bream", "silver_crucian", "ide", "young_mirror_carp"],
		"unlock_level": 1,
		"required_level": 1,
		"visual_tag": "mist",
		"water_profile": "mist",
		"water_mask": "default_lake",
		"map_position": Vector2(0.212, 0.482),
		"info_position": Vector2(0.249, 0.447),
		"map_icon": "mist",
		"recommended_tackle": ["Скользящий", "Вагглер", "Светящееся перо"],
		"recommended_bait": ["Червь", "Мотыль"],
		"special_features": ["Туманная заводь", "Переход в глубину", "Больше донной рыбы"],
		"bite_chance_modifier": 0.95,
		"rare_chance_modifier": 1.18,
		"wind_shelter": 0.80,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"old_boat_pier": {
		"id": "old_boat_pier",
		"waterbody_id": "agamin_lake",
		"name": "Мостик \"Старая Лодка\"",
		"type": "snag_pier",
		"spot_type": "коряжник",
		"description": "Старая лодка, коряги и тень. Много хищной мелочи, но иногда подходит молодая щука.",
		"min_depth": 1.5,
		"max_depth": 3.0,
		"preferred_depth": 2.2,
		"depth": 2.2,
		"fish_pool": ["rotan", "perch", "young_pike", "ruffe", "goby", "crayfish"],
		"available_fish": ["rotan", "perch", "young_pike", "ruffe", "goby", "crayfish"],
		"unlock_level": 1,
		"required_level": 1,
		"visual_tag": "snag_boat",
		"water_profile": "snag_shadow",
		"water_mask": "default_lake",
		"map_position": Vector2(0.118, 0.592),
		"info_position": Vector2(0.155, 0.557),
		"map_icon": "old_boat",
		"recommended_tackle": ["Бочонок", "Камышовая капля", "Капля"],
		"recommended_bait": ["Червь", "Бокоплав"],
		"special_features": ["Старая лодка", "Коряги", "Хищная мелочь"],
		"bite_chance_modifier": 0.92,
		"rare_chance_modifier": 1.35,
		"wind_shelter": 0.88,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"deep_pier": {
		"id": "deep_pier",
		"waterbody_id": "agamin_lake",
		"name": "Мостик \"Глубокий\"",
		"type": "deep_pier",
		"spot_type": "глубокий мостик",
		"description": "Самый простой доступ к глубине на Агамиме. Тут уже нужна леска и удочка увереннее стартовых.",
		"min_depth": 3.0,
		"max_depth": 5.0,
		"preferred_depth": 4.0,
		"depth": 4.0,
		"fish_pool": ["bream", "golden_crucian", "small_catfish", "skimmer_bream", "perch"],
		"available_fish": ["bream", "golden_crucian", "small_catfish", "skimmer_bream", "perch"],
		"unlock_level": 1,
		"required_level": 1,
		"visual_tag": "deep",
		"water_profile": "deep_water",
		"water_mask": "default_lake",
		"map_position": Vector2(0.500, 0.519),
		"info_position": Vector2(0.537, 0.484),
		"map_icon": "deep",
		"recommended_tackle": ["Скользящий", "Вагглер", "Усиленный бочонок"],
		"recommended_bait": ["Червь", "Мотыль"],
		"special_features": ["Глубокий мостик", "Нужна уверенная снасть", "Крупнее средняя рыба"],
		"bite_chance_modifier": 0.88,
		"rare_chance_modifier": 1.42,
		"wind_shelter": 0.95,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"green_duckweed": {
		"id": "green_duckweed",
		"waterbody_id": "agamin_lake",
		"name": "Зелёная Ряска",
		"type": "duckweed",
		"spot_type": "ряска",
		"description": "Мелкая заросшая вода. Отличается странными поклёвками: ротан, краснопёрка, вьюн и иногда лягушка.",
		"min_depth": 0.3,
		"max_depth": 1.0,
		"preferred_depth": 0.6,
		"depth": 0.6,
		"fish_pool": ["frog", "rotan", "rudd", "loach", "water_turtle"],
		"available_fish": ["frog", "rotan", "rudd", "loach", "water_turtle"],
		"unlock_level": 1,
		"required_level": 1,
		"visual_tag": "duckweed",
		"water_profile": "duckweed",
		"water_mask": "default_lake",
		"map_position": Vector2(0.134, 0.272),
		"info_position": Vector2(0.171, 0.237),
		"map_icon": "duckweed",
		"recommended_tackle": ["Перо", "Гусиное перо", "Камышовая капля"],
		"recommended_bait": ["Хлеб", "Червь"],
		"special_features": ["Ряска", "Мелкая заросшая вода", "Необычные поклёвки"],
		"bite_chance_modifier": 1.12,
		"rare_chance_modifier": 1.18,
		"wind_shelter": 0.72,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"frog_backwater": {
		"id": "frog_backwater",
		"waterbody_id": "agamin_lake",
		"name": "Лягушачья Заводь",
		"type": "duckweed_shallow",
		"spot_type": "мелкая заводь",
		"description": "Заросшая заводь с мягким дном. Хорошее место для линя, ротана и необычного мелкого улова.",
		"min_depth": 0.5,
		"max_depth": 1.3,
		"preferred_depth": 0.9,
		"depth": 0.9,
		"fish_pool": ["frog", "silver_crucian", "tench", "rotan", "loach", "crayfish", "water_turtle"],
		"available_fish": ["frog", "silver_crucian", "tench", "rotan", "loach", "crayfish", "water_turtle"],
		"unlock_level": 1,
		"required_level": 1,
		"visual_tag": "frog_backwater",
		"water_profile": "frog_backwater",
		"water_mask": "default_lake",
		"map_position": Vector2(0.530, 0.245),
		"info_position": Vector2(0.567, 0.210),
		"map_icon": "frog_backwater",
		"recommended_tackle": ["Камышовая капля", "Перо", "Капля"],
		"recommended_bait": ["Червь", "Хлеб"],
		"special_features": ["Мягкое дно", "Заросшая заводь", "Линь, ротан и мелкий необычный улов"],
		"bite_chance_modifier": 1.02,
		"rare_chance_modifier": 1.22,
		"wind_shelter": 0.70,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"dark_hole": {
		"id": "dark_hole",
		"waterbody_id": "agamin_lake",
		"name": "Тёмная Яма",
		"type": "deep_hole",
		"spot_type": "глубокая яма",
		"description": "Холодная глубокая яма. Поклёвки реже, зато рыба тяжелее и снасти получают настоящий стресс.",
		"min_depth": 4.0,
		"max_depth": 6.0,
		"preferred_depth": 5.0,
		"depth": 5.0,
		"fish_pool": ["bream", "small_catfish", "perch", "skimmer_bream", "loach"],
		"available_fish": ["bream", "small_catfish", "perch", "skimmer_bream", "loach"],
		"unlock_level": 1,
		"required_level": 1,
		"visual_tag": "deep_hole",
		"water_profile": "deep_dark",
		"water_mask": "default_lake",
		"map_position": Vector2(0.623, 0.824),
		"info_position": Vector2(0.660, 0.789),
		"map_icon": "dark_hole",
		"recommended_tackle": ["Скользящий", "Ночной бочонок", "Усиленный бочонок"],
		"recommended_bait": ["Червь", "Бокоплав"],
		"special_features": ["Глубокая тёмная вода", "Редкие поклёвки", "Тяжёлая рыба"],
		"bite_chance_modifier": 0.78,
		"rare_chance_modifier": 1.55,
		"wind_shelter": 0.95,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"cold_water": {
		"id": "cold_water",
		"waterbody_id": "agamin_lake",
		"name": "Холодная Вода",
		"type": "cold_deep_water",
		"spot_type": "холодная глубина",
		"description": "Более холодная часть озера. Здесь держится густера, подлещик и осторожная молодая щука.",
		"min_depth": 3.0,
		"max_depth": 5.5,
		"preferred_depth": 4.3,
		"depth": 4.3,
		"fish_pool": ["skimmer_bream", "white_bream", "young_pike", "bream", "perch"],
		"available_fish": ["skimmer_bream", "white_bream", "young_pike", "bream", "perch"],
		"unlock_level": 1,
		"required_level": 1,
		"visual_tag": "cold_water",
		"water_profile": "cold_water",
		"water_mask": "default_lake",
		"map_position": Vector2(0.267, 0.829),
		"info_position": Vector2(0.304, 0.794),
		"map_icon": "cold_water",
		"recommended_tackle": ["Скользящий", "Вагглер", "Бочонок"],
		"recommended_bait": ["Мотыль", "Червь"],
		"special_features": ["Холодная протока", "Камни", "Глубина у воды"],
		"bite_chance_modifier": 0.84,
		"rare_chance_modifier": 1.38,
		"wind_shelter": 1.0,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"forest_old_pier": {
		"id": "forest_old_pier",
		"name": "Старый пирс",
		"waterbody_id": "forest_lake",
		"legacy": true,
		"type": "wooden_pier",
		"spot_type": "пирс",
		"description": "Лесной пирс с первой серьезной хищной рыбой.",
		"min_depth": 1.2,
		"max_depth": 4.0,
		"preferred_depth": 2.6,
		"depth": 2.6,
		"fish_pool": ["roach", "rotan", "ruffe", "perch", "silver_crucian", "golden_crucian", "tench", "pike"],
		"available_fish": ["roach", "rotan", "ruffe", "perch", "silver_crucian", "golden_crucian", "tench", "pike"],
		"unlock_level": 3,
		"required_level": 3,
		"visual_tag": "forest_pier",
		"bite_chance_modifier": 1.0,
		"rare_chance_modifier": 1.18,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"river_deep_hole": {
		"id": "river_deep_hole",
		"name": "Речная яма",
		"waterbody_id": "river_backwater",
		"legacy": true,
		"type": "deep_hole",
		"spot_type": "глубокая зона",
		"description": "Глубокая речная заводь с сильной рыбой.",
		"min_depth": 2.5,
		"max_depth": 6.0,
		"preferred_depth": 4.4,
		"depth": 4.4,
		"fish_pool": ["rotan", "ruffe", "perch", "pike", "bream", "zander", "eel", "catfish", "mist_carp", "moon_catfish"],
		"available_fish": ["rotan", "ruffe", "perch", "pike", "bream", "zander", "eel", "catfish", "mist_carp", "moon_catfish"],
		"unlock_level": 5,
		"required_level": 5,
		"visual_tag": "river_hole",
		"bite_chance_modifier": 0.9,
		"rare_chance_modifier": 1.55,
		"unlock_cost": 0,
		"is_unlocked": true
	}
}

func get_spot(spot_id: String) -> Dictionary:
	if not spots.has(spot_id):
		return {}

	return _with_waterbody_data(spots[spot_id])

func get_all_spots() -> Array:
	var all_spots: Array = []

	for spot_id in spots.keys():
		var spot := get_spot(spot_id)
		if bool(spot.get("legacy", false)):
			continue
		all_spots.append(spot)

	return all_spots

func get_spots_for_waterbody(waterbody_id: String) -> Array:
	var waterbody_spots: Array = []

	for spot_id in spots.keys():
		var spot: Dictionary = spots[spot_id]
		if bool(spot.get("legacy", false)):
			continue
		if str(spot.get("waterbody_id", "agamin_lake")) != waterbody_id:
			continue

		waterbody_spots.append(_with_waterbody_data(spot))

	waterbody_spots.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("preferred_depth", a.get("depth", 0.0))) < float(b.get("preferred_depth", b.get("depth", 0.0)))
	)

	return waterbody_spots

func _with_waterbody_data(raw_spot: Dictionary) -> Dictionary:
	var spot := raw_spot.duplicate(true)
	var waterbody_id := str(spot.get("waterbody_id", "agamin_lake"))
	var depth_modifier := 1.0
	var waterbody_db := _get_waterbody_database()
	var waterbody_fish_pool: Array = []

	if waterbody_db != null:
		var raw_waterbody = waterbody_db.call("get_waterbody", waterbody_id)
		if typeof(raw_waterbody) == TYPE_DICTIONARY and not raw_waterbody.is_empty():
			var waterbody: Dictionary = raw_waterbody
			spot["waterbody_name"] = str(waterbody.get("name", "Озеро"))
			spot["waterbody_description"] = str(waterbody.get("description", ""))
			depth_modifier = float(waterbody.get("depth_modifier", 1.0))
			spot["bite_chance_modifier"] = float(spot.get("bite_chance_modifier", 1.0)) * float(waterbody.get("weather_modifier", 1.0))
			spot["rare_chance_modifier"] = float(spot.get("rare_chance_modifier", 1.0)) * float(waterbody.get("rare_chance_modifier", 1.0))

		var raw_fish_pool = waterbody_db.call("get_fish_pool", waterbody_id)
		if typeof(raw_fish_pool) == TYPE_ARRAY:
			waterbody_fish_pool = raw_fish_pool

	var min_depth := float(spot.get("min_depth", spot.get("depth", 1.0))) * depth_modifier
	var max_depth := float(spot.get("max_depth", spot.get("depth", 1.0))) * depth_modifier
	var preferred_depth := float(spot.get("preferred_depth", (min_depth + max_depth) * 0.5)) * depth_modifier

	spot["min_depth"] = min(min_depth, max_depth)
	spot["max_depth"] = max(min_depth, max_depth)
	spot["preferred_depth"] = clamp(preferred_depth, float(spot["min_depth"]), float(spot["max_depth"]))
	spot["depth"] = spot["preferred_depth"]

	var spot_fish: Array = spot.get("fish_pool", spot.get("available_fish", []))
	var merged_fish: Array = []

	for fish_id in spot_fish:
		var id := str(fish_id)
		if waterbody_fish_pool.is_empty() or waterbody_fish_pool.has(id):
			merged_fish.append(id)

	if merged_fish.is_empty() and spot_fish.is_empty():
		merged_fish = waterbody_fish_pool

	spot["fish_pool"] = merged_fish
	spot["available_fish"] = merged_fish
	return spot

func _get_waterbody_database() -> Node:
	return get_node_or_null("/root/WaterbodyDatabase")
