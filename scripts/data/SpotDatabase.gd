extends Node

var spots := {
	"north_pier": {
		"id": "north_pier",
		"name": "Северный пирс",
		"spot_type": "пирс",
		"required_level": 1,
		"depth": 2.0,
		"available_fish": ["roach", "perch", "crucian", "pike"],
		"bite_chance_modifier": 1.0,
		"rare_chance_modifier": 1.0,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"reed_zone": {
		"id": "reed_zone",
		"name": "Камышовая зона",
		"spot_type": "берег",
		"required_level": 1,
		"depth": 1.2,
		"available_fish": ["roach", "rudd", "crucian", "tench"],
		"bite_chance_modifier": 1.1,
		"rare_chance_modifier": 1.0,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"deep_hole": {
		"id": "deep_hole",
		"name": "Глубокая яма",
		"spot_type": "глубокая зона",
		"required_level": 1,
		"depth": 8.5,
		"available_fish": ["bream", "catfish", "zander", "moon_catfish"],
		"bite_chance_modifier": 0.9,
		"rare_chance_modifier": 2.0,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"island": {
		"id": "island",
		"name": "Остров",
		"spot_type": "редкая зона",
		"required_level": 1,
		"depth": 4.0,
		"available_fish": ["perch", "pike", "eel", "mist_carp"],
		"bite_chance_modifier": 1.0,
		"rare_chance_modifier": 1.8,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"west_bank": {
		"id": "west_bank",
		"name": "Западный берег",
		"spot_type": "берег",
		"required_level": 1,
		"depth": 1.8,
		"available_fish": ["roach", "crucian", "rudd", "perch"],
		"bite_chance_modifier": 1.2,
		"rare_chance_modifier": 0.8,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"south_bay": {
		"id": "south_bay",
		"name": "Южный залив",
		"spot_type": "берег",
		"required_level": 1,
		"depth": 2.5,
		"available_fish": ["crucian", "tench", "bream", "eel"],
		"bite_chance_modifier": 1.0,
		"rare_chance_modifier": 1.2,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"boat_zone": {
		"id": "boat_zone",
		"name": "Лодочная зона",
		"spot_type": "лодка",
		"required_level": 1,
		"depth": 5.0,
		"available_fish": ["perch", "pike", "zander", "catfish"],
		"bite_chance_modifier": 0.95,
		"rare_chance_modifier": 1.6,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"old_pier": {
		"id": "old_pier",
		"name": "Старый пирс",
		"spot_type": "пирс",
		"required_level": 1,
		"depth": 3.0,
		"available_fish": ["roach", "perch", "bream", "eel"],
		"bite_chance_modifier": 1.0,
		"rare_chance_modifier": 1.3,
		"unlock_cost": 0,
		"is_unlocked": true
	},
	"misty_backwater": {
		"id": "misty_backwater",
		"name": "Туманная заводь",
		"spot_type": "редкая зона",
		"required_level": 1,
		"depth": 3.5,
		"available_fish": ["tench", "eel", "mist_carp", "moon_catfish"],
		"bite_chance_modifier": 0.85,
		"rare_chance_modifier": 2.5,
		"unlock_cost": 0,
		"is_unlocked": true
	}
}

func get_spot(spot_id: String) -> Dictionary:
	return spots.get(spot_id, {})

func get_all_spots() -> Array:
	return spots.values()
