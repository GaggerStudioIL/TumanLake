extends Node

var fish_data := {
	"bleak": {
		"id": "bleak",
		"name": "Уклейка",
		"rarity": "common",
		"behavior": "calm",
		"behavior_type": "calm",
		"base_fight_power": 0.34,
		"strength": 0.28,
		"aggression": 0.18,
		"stamina": 0.46,
		"escape_risk": 0.28,
		"escape_chance": 0.28,
		"weight_difficulty_multiplier": 0.45,
		"base_xp": 3,
		"xp": 3,
		"min_weight": 0.01,
		"max_weight": 0.08,
		"price_per_kg": 12,
		"base_price": 1,
		"min_depth": 0.2,
		"max_depth": 1.2,
		"preferred_depth": 0.6,
		"preferred_baits": ["bread", "maggot", "dough"],
		"min_hook_size": 10,
		"max_hook_size": 18,
		"active_time_start": 300,
		"active_time_end": 1020,
		"peak_time": 480,
		"icon_path": "",
		"description": "Мелкая верховая рыба. Лучше всего берёт на хлеб, опарыша и тесто."
	},
	"roach": {
		"id": "roach",
		"name": "Плотва",
		"rarity": "common",
		"behavior": "calm",
		"behavior_type": "calm",
		"base_fight_power": 0.55,
		"strength": 0.48,
		"aggression": 0.22,
		"stamina": 0.75,
		"escape_risk": 0.18,
		"escape_chance": 0.18,
		"weight_difficulty_multiplier": 0.65,
		"base_xp": 5,
		"xp": 5,
		"min_weight": 0.05,
		"max_weight": 0.8,
		"price_per_kg": 12,
		"base_price": 1,
		"min_depth": 0.5,
		"max_depth": 2.0,
		"preferred_depth": 1.1,
		"preferred_baits": ["bread", "worm", "maggot", "dough"],
		"min_hook_size": 8,
		"max_hook_size": 16,
		"active_time_start": 300,
		"active_time_end": 1200,
		"peak_time": 420,
		"icon_path": "",
		"description": "Спокойная белая рыба. Хороший базовый улов для первого озера."
	},
	"rudd": {
		"id": "rudd",
		"name": "Краснопёрка",
		"rarity": "common",
		"behavior": "calm",
		"behavior_type": "calm",
		"base_fight_power": 0.50,
		"strength": 0.44,
		"aggression": 0.26,
		"stamina": 0.68,
		"escape_risk": 0.22,
		"escape_chance": 0.22,
		"weight_difficulty_multiplier": 0.62,
		"base_xp": 6,
		"xp": 6,
		"min_weight": 0.05,
		"max_weight": 0.7,
		"price_per_kg": 13,
		"base_price": 1,
		"min_depth": 0.3,
		"max_depth": 1.5,
		"preferred_depth": 0.8,
		"preferred_baits": ["bread", "maggot", "dough"],
		"min_hook_size": 10,
		"max_hook_size": 16,
		"active_time_start": 360,
		"active_time_end": 1140,
		"peak_time": 900,
		"icon_path": "",
		"description": "Держится у травы и ряски. Предпочитает мелкие крючки."
	},
	"rotan": {
		"id": "rotan",
		"name": "Ротан",
		"rarity": "common",
		"behavior": "aggressive",
		"behavior_type": "aggressive",
		"base_fight_power": 0.78,
		"strength": 0.68,
		"aggression": 0.74,
		"stamina": 0.80,
		"escape_risk": 0.30,
		"escape_chance": 0.30,
		"weight_difficulty_multiplier": 0.75,
		"base_xp": 7,
		"xp": 7,
		"min_weight": 0.05,
		"max_weight": 0.5,
		"price_per_kg": 13,
		"base_price": 1,
		"min_depth": 0.5,
		"max_depth": 3.5,
		"preferred_depth": 1.6,
		"preferred_baits": ["worm", "maggot"],
		"min_hook_size": 8,
		"max_hook_size": 14,
		"active_time_start": 480,
		"active_time_end": 1320,
		"peak_time": 1080,
		"icon_path": "",
		"description": "Небольшой хищник у дна. Часто атакует резко и упрямо."
	},
	"ruffe": {
		"id": "ruffe",
		"name": "Ёрш",
		"rarity": "common",
		"behavior": "calm",
		"behavior_type": "calm",
		"base_fight_power": 0.42,
		"strength": 0.36,
		"aggression": 0.22,
		"stamina": 0.58,
		"escape_risk": 0.22,
		"escape_chance": 0.22,
		"weight_difficulty_multiplier": 0.52,
		"base_xp": 5,
		"xp": 5,
		"min_weight": 0.02,
		"max_weight": 0.2,
		"price_per_kg": 11,
		"base_price": 1,
		"min_depth": 1.0,
		"max_depth": 4.0,
		"preferred_depth": 1.7,
		"preferred_baits": ["worm", "maggot"],
		"min_hook_size": 10,
		"max_hook_size": 16,
		"active_time_start": 360,
		"active_time_end": 1380,
		"peak_time": 1140,
		"icon_path": "",
		"description": "Мелкая донная рыба. Часто попадается на червя и опарыша."
	},
	"silver_crucian": {
		"id": "silver_crucian",
		"name": "Карась серебряный",
		"rarity": "common",
		"behavior": "calm",
		"behavior_type": "calm",
		"base_fight_power": 0.72,
		"strength": 0.62,
		"aggression": 0.22,
		"stamina": 1.00,
		"escape_risk": 0.20,
		"escape_chance": 0.20,
		"weight_difficulty_multiplier": 0.78,
		"base_xp": 8,
		"xp": 8,
		"min_weight": 0.1,
		"max_weight": 1.5,
		"price_per_kg": 14,
		"base_price": 1,
		"min_depth": 0.8,
		"max_depth": 2.5,
		"preferred_depth": 1.3,
		"preferred_baits": ["bread", "dough", "worm"],
		"min_hook_size": 8,
		"max_hook_size": 14,
		"active_time_start": 300,
		"active_time_end": 1260,
		"peak_time": 540,
		"icon_path": "",
		"description": "Осторожный карась, любит тихую воду, траву и мягкую наживку."
	},
	"golden_crucian": {
		"id": "golden_crucian",
		"name": "Карась золотой",
		"rarity": "uncommon",
		"behavior": "calm",
		"behavior_type": "calm",
		"base_fight_power": 0.78,
		"strength": 0.68,
		"aggression": 0.22,
		"stamina": 1.08,
		"escape_risk": 0.18,
		"escape_chance": 0.18,
		"weight_difficulty_multiplier": 0.86,
		"base_xp": 10,
		"xp": 10,
		"min_weight": 0.1,
		"max_weight": 1.2,
		"price_per_kg": 17,
		"base_price": 2,
		"min_depth": 0.8,
		"max_depth": 2.5,
		"preferred_depth": 1.4,
		"preferred_baits": ["bread", "dough", "worm"],
		"min_hook_size": 8,
		"max_hook_size": 14,
		"active_time_start": 360,
		"active_time_end": 1260,
		"peak_time": 1080,
		"icon_path": "",
		"description": "Более редкий золотой карась. Тянет медленно, но настойчиво."
	},
	"perch": {
		"id": "perch",
		"name": "Окунь",
		"rarity": "common",
		"behavior": "erratic",
		"behavior_type": "erratic",
		"base_fight_power": 1.02,
		"strength": 0.95,
		"aggression": 0.70,
		"stamina": 0.95,
		"escape_risk": 0.28,
		"escape_chance": 0.28,
		"weight_difficulty_multiplier": 0.90,
		"base_xp": 10,
		"xp": 10,
		"min_weight": 0.05,
		"max_weight": 1.2,
		"price_per_kg": 16,
		"base_price": 1,
		"min_depth": 1.0,
		"max_depth": 3.5,
		"preferred_depth": 1.8,
		"preferred_baits": ["worm", "maggot"],
		"min_hook_size": 6,
		"max_hook_size": 12,
		"active_time_start": 300,
		"active_time_end": 1320,
		"peak_time": 1080,
		"icon_path": "",
		"description": "Полосатый хищник. Во время вываживания часто даёт резкие смены нагрузки."
	},
	"white_bream": {
		"id": "white_bream",
		"name": "Густера",
		"rarity": "common",
		"behavior": "calm",
		"behavior_type": "calm",
		"base_fight_power": 0.62,
		"strength": 0.56,
		"aggression": 0.20,
		"stamina": 0.82,
		"escape_risk": 0.20,
		"escape_chance": 0.20,
		"weight_difficulty_multiplier": 0.70,
		"base_xp": 7,
		"xp": 7,
		"min_weight": 0.08,
		"max_weight": 0.7,
		"price_per_kg": 13,
		"base_price": 1,
		"min_depth": 1.2,
		"max_depth": 3.5,
		"preferred_depth": 2.0,
		"preferred_baits": ["bread", "dough", "worm", "maggot"],
		"min_hook_size": 8,
		"max_hook_size": 14,
		"active_time_start": 330,
		"active_time_end": 1260,
		"peak_time": 720,
		"icon_path": "",
		"description": "Небольшая донная белая рыба. Лучше держится на средней глубине."
	},
	"skimmer_bream": {
		"id": "skimmer_bream",
		"name": "Подлещик",
		"rarity": "uncommon",
		"behavior": "calm",
		"behavior_type": "calm",
		"base_fight_power": 0.78,
		"strength": 0.72,
		"aggression": 0.18,
		"stamina": 1.05,
		"escape_risk": 0.18,
		"escape_chance": 0.18,
		"weight_difficulty_multiplier": 0.88,
		"base_xp": 12,
		"xp": 12,
		"min_weight": 0.2,
		"max_weight": 1.2,
		"price_per_kg": 20,
		"base_price": 2,
		"min_depth": 1.5,
		"max_depth": 4.0,
		"preferred_depth": 2.6,
		"preferred_baits": ["dough", "worm", "bread"],
		"min_hook_size": 6,
		"max_hook_size": 10,
		"active_time_start": 360,
		"active_time_end": 1380,
		"peak_time": 1140,
		"icon_path": "",
		"description": "Молодой лещ. Требует средней глубины и аккуратной снасти."
	},
	"tench": {
		"id": "tench",
		"name": "Линь",
		"rarity": "uncommon",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 1.05,
		"strength": 1.04,
		"aggression": 0.34,
		"stamina": 1.35,
		"escape_risk": 0.20,
		"escape_chance": 0.20,
		"weight_difficulty_multiplier": 1.00,
		"base_xp": 16,
		"xp": 16,
		"min_weight": 0.2,
		"max_weight": 2.0,
		"price_per_kg": 28,
		"base_price": 2,
		"min_depth": 0.8,
		"max_depth": 2.5,
		"preferred_depth": 1.7,
		"preferred_baits": ["worm", "dough"],
		"min_hook_size": 6,
		"max_hook_size": 10,
		"active_time_start": 300,
		"active_time_end": 600,
		"peak_time": 360,
		"icon_path": "",
		"description": "Сильная рыба травяных заводей. Давит медленно и тяжело."
	},
	"bream": {
		"id": "bream",
		"name": "Лещ",
		"rarity": "uncommon",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 1.12,
		"strength": 1.12,
		"aggression": 0.32,
		"stamina": 1.40,
		"escape_risk": 0.16,
		"escape_chance": 0.16,
		"weight_difficulty_multiplier": 1.10,
		"base_xp": 18,
		"xp": 18,
		"min_weight": 0.5,
		"max_weight": 3.5,
		"price_per_kg": 30,
		"base_price": 2,
		"min_depth": 2.0,
		"max_depth": 6.0,
		"preferred_depth": 3.7,
		"preferred_baits": ["dough", "worm", "bread"],
		"min_hook_size": 6,
		"max_hook_size": 10,
		"active_time_start": 360,
		"active_time_end": 1380,
		"peak_time": 1200,
		"icon_path": "",
		"description": "Тяжёлая донная рыба. На слабой леске быстро становится опасной."
	},
	"topmouth_gudgeon": {
		"id": "topmouth_gudgeon",
		"name": "Верховка",
		"rarity": "common",
		"behavior": "calm",
		"behavior_type": "calm",
		"base_fight_power": 0.24,
		"strength": 0.22,
		"aggression": 0.16,
		"stamina": 0.38,
		"escape_risk": 0.28,
		"escape_chance": 0.28,
		"weight_difficulty_multiplier": 0.38,
		"base_xp": 2,
		"xp": 2,
		"min_weight": 0.005,
		"max_weight": 0.04,
		"price_per_kg": 9,
		"base_price": 1,
		"min_depth": 0.2,
		"max_depth": 1.0,
		"preferred_depth": 0.45,
		"preferred_baits": ["bread", "maggot"],
		"min_hook_size": 12,
		"max_hook_size": 18,
		"active_time_start": 300,
		"active_time_end": 1080,
		"peak_time": 540,
		"icon_path": "",
		"description": "Совсем мелкая верховая рыбка. Помогает понять мелководные точки."
	},
	"gudgeon": {
		"id": "gudgeon",
		"name": "Пескарь",
		"rarity": "common",
		"behavior": "calm",
		"behavior_type": "calm",
		"base_fight_power": 0.32,
		"strength": 0.30,
		"aggression": 0.18,
		"stamina": 0.48,
		"escape_risk": 0.22,
		"escape_chance": 0.22,
		"weight_difficulty_multiplier": 0.44,
		"base_xp": 3,
		"xp": 3,
		"min_weight": 0.02,
		"max_weight": 0.15,
		"price_per_kg": 10,
		"base_price": 1,
		"min_depth": 0.5,
		"max_depth": 2.0,
		"preferred_depth": 1.0,
		"preferred_baits": ["worm", "maggot", "bread"],
		"min_hook_size": 10,
		"max_hook_size": 16,
		"active_time_start": 360,
		"active_time_end": 1140,
		"peak_time": 780,
		"icon_path": "",
		"description": "Мелкая донная рыба на песчаных участках."
	},
	"young_chub": {
		"id": "young_chub",
		"name": "Голавль молодой",
		"rarity": "uncommon",
		"behavior": "erratic",
		"behavior_type": "erratic",
		"base_fight_power": 0.86,
		"strength": 0.82,
		"aggression": 0.68,
		"stamina": 0.90,
		"escape_risk": 0.30,
		"escape_chance": 0.30,
		"weight_difficulty_multiplier": 0.88,
		"base_xp": 12,
		"xp": 12,
		"min_weight": 0.1,
		"max_weight": 1.0,
		"price_per_kg": 24,
		"base_price": 2,
		"min_depth": 0.5,
		"max_depth": 2.5,
		"preferred_depth": 1.2,
		"preferred_baits": ["bread", "worm", "maggot"],
		"min_hook_size": 8,
		"max_hook_size": 14,
		"active_time_start": 300,
		"active_time_end": 1080,
		"peak_time": 420,
		"icon_path": "",
		"description": "Пугливый, но резкий молодой голавль."
	},
	"young_pike": {
		"id": "young_pike",
		"name": "Щука молодая",
		"rarity": "rare",
		"behavior": "aggressive",
		"behavior_type": "aggressive",
		"base_fight_power": 1.28,
		"strength": 1.34,
		"aggression": 0.86,
		"stamina": 1.12,
		"escape_risk": 0.32,
		"escape_chance": 0.32,
		"weight_difficulty_multiplier": 1.12,
		"base_xp": 24,
		"xp": 24,
		"min_weight": 0.5,
		"max_weight": 3.0,
		"price_per_kg": 34,
		"base_price": 4,
		"min_depth": 1.5,
		"max_depth": 4.5,
		"preferred_depth": 2.4,
		"preferred_baits": ["worm"],
		"min_hook_size": 2,
		"max_hook_size": 8,
		"active_time_start": 240,
		"active_time_end": 600,
		"peak_time": 330,
		"icon_path": "",
		"description": "Первая опасная хищница Агамима. Слабая снасть быстро оказывается на пределе."
	},
	"ide": {
		"id": "ide",
		"name": "Язь",
		"rarity": "rare",
		"behavior": "erratic",
		"behavior_type": "erratic",
		"base_fight_power": 1.05,
		"strength": 1.08,
		"aggression": 0.64,
		"stamina": 1.12,
		"escape_risk": 0.28,
		"escape_chance": 0.28,
		"weight_difficulty_multiplier": 1.05,
		"base_xp": 26,
		"xp": 26,
		"min_weight": 0.3,
		"max_weight": 2.5,
		"price_per_kg": 38,
		"base_price": 4,
		"min_depth": 1.0,
		"max_depth": 3.5,
		"preferred_depth": 2.0,
		"preferred_baits": ["bread", "worm", "dough"],
		"min_hook_size": 6,
		"max_hook_size": 10,
		"active_time_start": 300,
		"active_time_end": 1140,
		"peak_time": 900,
		"icon_path": "",
		"description": "Редкая сильная белая рыба. Любит уверенную подачу на средней глубине."
	},
	"young_grass_carp": {
		"id": "young_grass_carp",
		"name": "Белый амур молодой",
		"rarity": "rare",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 1.18,
		"strength": 1.22,
		"aggression": 0.36,
		"stamina": 1.38,
		"escape_risk": 0.20,
		"escape_chance": 0.20,
		"weight_difficulty_multiplier": 1.15,
		"base_xp": 28,
		"xp": 28,
		"min_weight": 0.5,
		"max_weight": 3.0,
		"price_per_kg": 42,
		"base_price": 4,
		"min_depth": 0.8,
		"max_depth": 3.0,
		"preferred_depth": 1.8,
		"preferred_baits": ["bread", "dough"],
		"min_hook_size": 4,
		"max_hook_size": 10,
		"active_time_start": 420,
		"active_time_end": 1140,
		"peak_time": 720,
		"icon_path": "",
		"description": "Молодой амур. Тянет мощно, но без частых рывков."
	},
	"young_mirror_carp": {
		"id": "young_mirror_carp",
		"name": "Карп зеркальный молодой",
		"rarity": "rare",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 1.24,
		"strength": 1.32,
		"aggression": 0.40,
		"stamina": 1.45,
		"escape_risk": 0.22,
		"escape_chance": 0.22,
		"weight_difficulty_multiplier": 1.20,
		"base_xp": 30,
		"xp": 30,
		"min_weight": 0.5,
		"max_weight": 4.0,
		"price_per_kg": 45,
		"base_price": 5,
		"min_depth": 1.0,
		"max_depth": 3.5,
		"preferred_depth": 2.2,
		"preferred_baits": ["dough", "bread", "worm"],
		"min_hook_size": 4,
		"max_hook_size": 10,
		"active_time_start": 360,
		"active_time_end": 1260,
		"peak_time": 540,
		"icon_path": "",
		"description": "Редкий молодой карп. Даёт первый настоящий тест снасти."
	},
	"small_catfish": {
		"id": "small_catfish",
		"name": "Сомик",
		"rarity": "rare",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 1.36,
		"strength": 1.48,
		"aggression": 0.38,
		"stamina": 1.60,
		"escape_risk": 0.16,
		"escape_chance": 0.16,
		"weight_difficulty_multiplier": 1.25,
		"base_xp": 34,
		"xp": 34,
		"min_weight": 0.5,
		"max_weight": 5.0,
		"price_per_kg": 46,
		"base_price": 5,
		"min_depth": 3.0,
		"max_depth": 6.0,
		"preferred_depth": 4.8,
		"preferred_baits": ["worm"],
		"min_hook_size": 2,
		"max_hook_size": 6,
		"active_time_start": 1260,
		"active_time_end": 360,
		"peak_time": 60,
		"icon_path": "",
		"description": "Ночной донный хищник. Даже молодой сомик серьёзно грузит снасть."
	},
	"frog": {
		"id": "frog",
		"name": "Лягушка",
		"rarity": "uncommon",
		"behavior": "erratic",
		"behavior_type": "erratic",
		"base_fight_power": 0.38,
		"strength": 0.32,
		"aggression": 0.72,
		"stamina": 0.45,
		"escape_risk": 0.36,
		"escape_chance": 0.36,
		"weight_difficulty_multiplier": 0.45,
		"base_xp": 5,
		"xp": 5,
		"min_weight": 0.02,
		"max_weight": 0.15,
		"price_per_kg": 8,
		"base_price": 1,
		"min_depth": 0.2,
		"max_depth": 1.2,
		"preferred_depth": 0.6,
		"preferred_baits": ["worm", "maggot"],
		"min_hook_size": 10,
		"max_hook_size": 16,
		"active_time_start": 300,
		"active_time_end": 1260,
		"peak_time": 900,
		"icon_path": "",
		"description": "Не рыба, но вполне реальный сюрприз заросшей мелководной точки."
	},
	"loach": {
		"id": "loach",
		"name": "Вьюн",
		"rarity": "uncommon",
		"behavior": "erratic",
		"behavior_type": "erratic",
		"base_fight_power": 0.48,
		"strength": 0.42,
		"aggression": 0.80,
		"stamina": 0.62,
		"escape_risk": 0.40,
		"escape_chance": 0.40,
		"weight_difficulty_multiplier": 0.58,
		"base_xp": 7,
		"xp": 7,
		"min_weight": 0.03,
		"max_weight": 0.25,
		"price_per_kg": 18,
		"base_price": 1,
		"min_depth": 0.5,
		"max_depth": 4.0,
		"preferred_depth": 1.5,
		"preferred_baits": ["worm"],
		"min_hook_size": 10,
		"max_hook_size": 16,
		"active_time_start": 600,
		"active_time_end": 360,
		"peak_time": 1260,
		"icon_path": "",
		"description": "Скользкий донный обитатель. На леске ведёт себя непредсказуемо."
	},
	"goby": {
		"id": "goby",
		"name": "Бычок",
		"rarity": "common",
		"behavior": "aggressive",
		"behavior_type": "aggressive",
		"base_fight_power": 0.52,
		"strength": 0.48,
		"aggression": 0.76,
		"stamina": 0.56,
		"escape_risk": 0.30,
		"escape_chance": 0.30,
		"weight_difficulty_multiplier": 0.58,
		"base_xp": 4,
		"xp": 4,
		"min_weight": 0.03,
		"max_weight": 0.25,
		"price_per_kg": 11,
		"base_price": 1,
		"min_depth": 0.5,
		"max_depth": 3.0,
		"preferred_depth": 1.5,
		"preferred_baits": ["worm", "maggot"],
		"min_hook_size": 10,
		"max_hook_size": 16,
		"active_time_start": 360,
		"active_time_end": 1320,
		"peak_time": 1020,
		"icon_path": "",
		"description": "Небольшой донный хищник у коряг и старой лодки."
	},
	"crayfish": {
		"id": "crayfish",
		"name": "Речной рак",
		"rarity": "uncommon",
		"behavior": "calm",
		"behavior_type": "calm",
		"base_fight_power": 0.30,
		"strength": 0.30,
		"aggression": 0.10,
		"stamina": 0.52,
		"escape_risk": 0.18,
		"escape_chance": 0.18,
		"weight_difficulty_multiplier": 0.45,
		"base_xp": 6,
		"xp": 6,
		"min_weight": 0.03,
		"max_weight": 0.2,
		"price_per_kg": 22,
		"base_price": 2,
		"min_depth": 0.5,
		"max_depth": 3.0,
		"preferred_depth": 1.8,
		"preferred_baits": ["worm"],
		"min_hook_size": 8,
		"max_hook_size": 14,
		"active_time_start": 1080,
		"active_time_end": 420,
		"peak_time": 1320,
		"icon_path": "",
		"description": "Редкая донная находка на червя."
	},
	"water_turtle": {
		"id": "water_turtle",
		"name": "Водяная черепаха",
		"rarity": "very_rare",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 0.95,
		"strength": 1.05,
		"aggression": 0.16,
		"stamina": 1.25,
		"escape_risk": 0.16,
		"escape_chance": 0.16,
		"weight_difficulty_multiplier": 0.95,
		"base_xp": 18,
		"xp": 18,
		"min_weight": 0.3,
		"max_weight": 2.0,
		"price_per_kg": 20,
		"base_price": 4,
		"min_depth": 0.5,
		"max_depth": 2.5,
		"preferred_depth": 1.2,
		"preferred_baits": ["worm"],
		"min_hook_size": 6,
		"max_hook_size": 10,
		"active_time_start": 420,
		"active_time_end": 1140,
		"peak_time": 780,
		"icon_path": "",
		"description": "Очень редкая неожиданная поклёвка на спокойной воде."
	},
	"crucian": {
		"id": "crucian",
		"name": "Карась",
		"rarity": "common",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 0.82,
		"strength": 0.78,
		"aggression": 0.24,
		"stamina": 1.10,
		"escape_risk": 0.18,
		"escape_chance": 0.18,
		"weight_difficulty_multiplier": 0.84,
		"base_xp": 8,
		"xp": 8,
		"min_weight": 0.2,
		"max_weight": 1.5,
		"price_per_kg": 14,
		"base_price": 1,
		"min_depth": 0.7,
		"max_depth": 2.8,
		"preferred_depth": 1.4,
		"preferred_baits": ["worm", "dough", "bread"],
		"min_hook_size": 8,
		"max_hook_size": 14,
		"active_time_start": 330,
		"active_time_end": 1260,
		"peak_time": 540,
		"icon_path": "",
		"description": "Базовый карась для старых сохранений и будущих общих точек."
	},
	"pike": {
		"id": "pike",
		"name": "Щука",
		"rarity": "uncommon",
		"behavior": "erratic",
		"behavior_type": "erratic",
		"base_fight_power": 1.35,
		"strength": 1.48,
		"aggression": 0.86,
		"stamina": 1.25,
		"escape_risk": 0.30,
		"escape_chance": 0.30,
		"weight_difficulty_multiplier": 1.20,
		"base_xp": 22,
		"xp": 22,
		"min_weight": 0.8,
		"max_weight": 5.0,
		"price_per_kg": 34,
		"base_price": 4,
		"min_depth": 1.0,
		"max_depth": 4.5,
		"preferred_depth": 2.4,
		"preferred_baits": ["worm"],
		"min_hook_size": 2,
		"max_hook_size": 8,
		"active_time_start": 240,
		"active_time_end": 600,
		"peak_time": 330,
		"icon_path": "",
		"description": "Сильная хищница. Для стартовой снасти уже опасна."
	},
	"catfish": {
		"id": "catfish",
		"name": "Сом",
		"rarity": "rare",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 1.65,
		"strength": 1.95,
		"aggression": 0.38,
		"stamina": 1.80,
		"escape_risk": 0.14,
		"escape_chance": 0.14,
		"weight_difficulty_multiplier": 1.45,
		"base_xp": 45,
		"xp": 45,
		"min_weight": 3.0,
		"max_weight": 18.0,
		"price_per_kg": 55,
		"base_price": 8,
		"min_depth": 3.0,
		"max_depth": 6.0,
		"preferred_depth": 5.0,
		"preferred_baits": ["worm"],
		"min_hook_size": 2,
		"max_hook_size": 6,
		"active_time_start": 1260,
		"active_time_end": 360,
		"peak_time": 60,
		"icon_path": "",
		"description": "Старый хозяин тёмного дна."
	},
	"eel": {
		"id": "eel",
		"name": "Угорь",
		"rarity": "rare",
		"behavior": "erratic",
		"behavior_type": "erratic",
		"base_fight_power": 1.15,
		"strength": 1.05,
		"aggression": 0.88,
		"stamina": 0.90,
		"escape_risk": 0.45,
		"escape_chance": 0.45,
		"weight_difficulty_multiplier": 1.00,
		"base_xp": 34,
		"xp": 34,
		"min_weight": 0.4,
		"max_weight": 2.2,
		"price_per_kg": 60,
		"base_price": 5,
		"min_depth": 1.5,
		"max_depth": 4.8,
		"preferred_depth": 3.0,
		"preferred_baits": ["worm"],
		"min_hook_size": 4,
		"max_hook_size": 10,
		"active_time_start": 1140,
		"active_time_end": 300,
		"peak_time": 1380,
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
		"strength": 1.42,
		"aggression": 0.78,
		"stamina": 1.20,
		"escape_risk": 0.34,
		"escape_chance": 0.34,
		"weight_difficulty_multiplier": 1.20,
		"base_xp": 38,
		"xp": 38,
		"min_weight": 1.0,
		"max_weight": 6.0,
		"price_per_kg": 50,
		"base_price": 6,
		"min_depth": 2.0,
		"max_depth": 5.5,
		"preferred_depth": 3.8,
		"preferred_baits": ["worm", "maggot"],
		"min_hook_size": 2,
		"max_hook_size": 8,
		"active_time_start": 1080,
		"active_time_end": 420,
		"peak_time": 1260,
		"icon_path": "",
		"description": "Глубинный хищник для более поздних водоёмов."
	},
	"mist_carp": {
		"id": "mist_carp",
		"name": "Туманный карп",
		"rarity": "legendary",
		"behavior": "erratic",
		"behavior_type": "erratic",
		"base_fight_power": 1.75,
		"strength": 2.05,
		"aggression": 0.72,
		"stamina": 1.90,
		"escape_risk": 0.38,
		"escape_chance": 0.38,
		"weight_difficulty_multiplier": 1.55,
		"base_xp": 95,
		"xp": 95,
		"min_weight": 4.0,
		"max_weight": 20.0,
		"price_per_kg": 120,
		"base_price": 20,
		"min_depth": 2.5,
		"max_depth": 6.0,
		"preferred_depth": 4.2,
		"preferred_baits": ["dough", "worm"],
		"min_hook_size": 4,
		"max_hook_size": 8,
		"active_time_start": 300,
		"active_time_end": 540,
		"peak_time": 420,
		"icon_path": "",
		"description": "Редчайшая рыба туманной воды."
	},
	"moon_catfish": {
		"id": "moon_catfish",
		"name": "Лунный сом",
		"rarity": "legendary",
		"behavior": "heavy",
		"behavior_type": "heavy",
		"base_fight_power": 2.00,
		"strength": 2.35,
		"aggression": 0.42,
		"stamina": 2.20,
		"escape_risk": 0.20,
		"escape_chance": 0.20,
		"weight_difficulty_multiplier": 1.70,
		"base_xp": 120,
		"xp": 120,
		"min_weight": 8.0,
		"max_weight": 30.0,
		"price_per_kg": 150,
		"base_price": 30,
		"min_depth": 4.0,
		"max_depth": 6.0,
		"preferred_depth": 5.6,
		"preferred_baits": ["worm"],
		"min_hook_size": 2,
		"max_hook_size": 6,
		"active_time_start": 1320,
		"active_time_end": 240,
		"peak_time": 60,
		"icon_path": "",
		"description": "Легендарная ночная рыба глубокой воды."
	}
}

const FISH_RULES := {}
const FISH_ACTIVITY := {}
const CATCH_WEIGHT_CURVE := 2.85
const CATCH_WEIGHT_PEAK_BIAS_STRENGTH := 0.45
const CATCH_RANK_WEIGHTS := {
	"bleak": {"trophy_weight": 0.06, "rarity_weight": 0.075},
	"roach": {"trophy_weight": 0.6, "rarity_weight": 0.75},
	"rudd": {"trophy_weight": 0.55, "rarity_weight": 0.66},
	"rotan": {"trophy_weight": 0.38, "rarity_weight": 0.47},
	"ruffe": {"trophy_weight": 0.15, "rarity_weight": 0.19},
	"silver_crucian": {"trophy_weight": 1.1, "rarity_weight": 1.35},
	"golden_crucian": {"trophy_weight": 0.9, "rarity_weight": 1.1},
	"perch": {"trophy_weight": 0.9, "rarity_weight": 1.1},
	"white_bream": {"trophy_weight": 0.55, "rarity_weight": 0.66},
	"skimmer_bream": {"trophy_weight": 0.95, "rarity_weight": 1.15},
	"tench": {"trophy_weight": 1.55, "rarity_weight": 1.85},
	"bream": {"trophy_weight": 2.7, "rarity_weight": 3.25},
	"topmouth_gudgeon": {"trophy_weight": 0.03, "rarity_weight": 0.038},
	"gudgeon": {"trophy_weight": 0.11, "rarity_weight": 0.14},
	"young_chub": {"trophy_weight": 0.8, "rarity_weight": 0.95},
	"young_pike": {"trophy_weight": 2.3, "rarity_weight": 2.8},
	"ide": {"trophy_weight": 1.9, "rarity_weight": 2.35},
	"young_grass_carp": {"trophy_weight": 2.3, "rarity_weight": 2.8},
	"young_mirror_carp": {"trophy_weight": 3.1, "rarity_weight": 3.75},
	"small_catfish": {"trophy_weight": 3.8, "rarity_weight": 4.7},
	"frog": {"trophy_weight": 0.11, "rarity_weight": 0.14},
	"loach": {"trophy_weight": 0.19, "rarity_weight": 0.24},
	"goby": {"trophy_weight": 0.19, "rarity_weight": 0.24},
	"crayfish": {"trophy_weight": 0.15, "rarity_weight": 0.19},
	"water_turtle": {"trophy_weight": 1.5, "rarity_weight": 1.9},
	"crucian": {"trophy_weight": 1.1, "rarity_weight": 1.35},
	"pike": {"trophy_weight": 3.9, "rarity_weight": 4.8},
	"catfish": {"trophy_weight": 13.5, "rarity_weight": 17.0},
	"eel": {"trophy_weight": 1.7, "rarity_weight": 2.1},
	"zander": {"trophy_weight": 4.7, "rarity_weight": 5.8},
	"mist_carp": {"trophy_weight": 15.5, "rarity_weight": 19.0},
	"moon_catfish": {"trophy_weight": 23.5, "rarity_weight": 29.0}
}

const FISH_ICON_PATHS := {
	"bleak": "res://assets/fish/species/bleak.png",
	"roach": "res://assets/fish/species/roach.png",
	"rudd": "res://assets/fish/species/rudd.png",
	"rotan": "res://assets/fish/species/rotan.png",
	"ruffe": "res://assets/fish/species/ruffe.png",
	"silver_crucian": "res://assets/fish/species/silver_crucian.png",
	"golden_crucian": "res://assets/fish/species/golden_crucian.png",
	"perch": "res://assets/fish/species/perch.png",
	"white_bream": "res://assets/fish/species/white_bream.png",
	"skimmer_bream": "res://assets/fish/species/skimmer_bream.png",
	"tench": "res://assets/fish/species/tench.png",
	"bream": "res://assets/fish/species/bream.png",
	"topmouth_gudgeon": "res://assets/fish/species/topmouth_gudgeon.png",
	"gudgeon": "res://assets/fish/species/gudgeon.png",
	"young_chub": "res://assets/fish/species/young_chub.png",
	"young_pike": "res://assets/fish/species/young_pike.png",
	"ide": "res://assets/fish/species/ide.png",
	"young_grass_carp": "res://assets/fish/species/young_grass_carp.png",
	"young_mirror_carp": "res://assets/fish/species/young_mirror_carp.png",
	"small_catfish": "res://assets/fish/species/small_catfish.png",
	"frog": "res://assets/fish/species/frog.png",
	"loach": "res://assets/fish/species/loach.png",
	"goby": "res://assets/fish/species/goby.png",
	"crayfish": "res://assets/fish/species/crayfish.png",
	"water_turtle": "res://assets/fish/species/water_turtle.png",
	"crucian": "res://assets/fish/species/crucian.png",
	"pike": "res://assets/fish/species/pike.png",
	"catfish": "res://assets/fish/species/catfish.png",
	"eel": "res://assets/fish/species/eel.png",
	"zander": "res://assets/fish/species/zander.png",
	"mist_carp": "res://assets/fish/species/mist_carp.png",
	"moon_catfish": "res://assets/fish/species/moon_catfish.png"
}

var _fish_rules_applied := false

const SPECIES_RARITY_TYPES := {
	"young_pike": "rare",
	"ide": "rare",
	"young_grass_carp": "rare",
	"young_mirror_carp": "rare",
	"small_catfish": "rare",
	"water_turtle": "rare",
	"pike": "rare",
	"catfish": "rare",
	"eel": "rare",
	"zander": "rare",
	"mist_carp": "legendary_species",
	"moon_catfish": "legendary_species"
}

const PREDATOR_FISH_IDS := ["rotan", "perch", "young_pike", "small_catfish", "pike", "catfish", "eel", "zander", "moon_catfish"]
const VEGETATION_FISH_IDS := ["rudd", "tench", "young_grass_carp", "water_turtle", "mist_carp"]
const SURFACE_FISH_IDS := ["bleak", "topmouth_gudgeon", "young_chub", "rudd"]
const BOTTOM_FISH_IDS := ["ruffe", "gudgeon", "loach", "goby", "crayfish", "bream", "skimmer_bream", "white_bream"]

func _ensure_fish_rules() -> void:
	if _fish_rules_applied:
		return

	for fish_id in FISH_RULES.keys():
		var rule: Dictionary = FISH_RULES[fish_id]

		if not fish_data.has(fish_id) and rule.has("fish"):
			fish_data[fish_id] = rule["fish"].duplicate(true)

		if not fish_data.has(fish_id):
			continue

		for key in rule.keys():
			if key == "fish":
				continue

			fish_data[fish_id][key] = rule[key]

	for fish_id in fish_data.keys():
		var fish_entry: Dictionary = fish_data[fish_id]

		if not fish_entry.has("behavior_type"):
			fish_entry["behavior_type"] = fish_entry.get("behavior", "calm")
		if FISH_ACTIVITY.has(fish_id):
			fish_entry.merge(FISH_ACTIVITY[fish_id], true)
		if str(fish_entry.get("icon_path", "")).is_empty() and FISH_ICON_PATHS.has(fish_id):
			fish_entry["icon_path"] = FISH_ICON_PATHS[fish_id]

		var behavior := str(fish_entry.get("behavior_type", fish_entry.get("behavior", "calm")))
		var base_fight_power: float = float(fish_entry.get("base_fight_power", 1.0))
		var max_weight: float = float(fish_entry.get("max_weight", 1.0))
		var default_aggression := _get_default_aggression_for_behavior(behavior)
		var default_strength: float = clamp(
			base_fight_power * 0.70
			+ pow(max(max_weight, 0.05), 0.34) * 0.22
			+ default_aggression * 0.16,
			0.25,
			3.30
		)

		if not fish_entry.has("aggression"):
			fish_entry["aggression"] = default_aggression
		if not fish_entry.has("strength"):
			fish_entry["strength"] = default_strength
		if not fish_entry.has("escape_chance"):
			fish_entry["escape_chance"] = fish_entry.get("escape_risk", 0.25)
		if not fish_entry.has("strength_label"):
			fish_entry["strength_label"] = _get_strength_label(float(fish_entry["strength"]))
		if CATCH_RANK_WEIGHTS.has(fish_id):
			var rank_weights: Dictionary = CATCH_RANK_WEIGHTS[fish_id]
			fish_entry["trophy_weight"] = float(rank_weights.get("trophy_weight", max_weight * 0.80))
			fish_entry["rarity_weight"] = float(rank_weights.get("rarity_weight", max_weight * 0.92))
		else:
			if not fish_entry.has("trophy_weight"):
				fish_entry["trophy_weight"] = max_weight * 0.80
			if not fish_entry.has("rarity_weight"):
				fish_entry["rarity_weight"] = max_weight * 0.92

		var min_weight: float = float(fish_entry.get("min_weight", 0.01))
		var trophy_weight: float = float(fish_entry.get("trophy_weight", max_weight * 0.80))
		var record_weight: float = float(fish_entry.get("rarity_weight", max_weight * 0.92))
		var keeper_weight: float = _get_default_keeper_weight(fish_id, fish_entry, min_weight, max_weight, trophy_weight)
		var rarity_type: String = _get_default_species_rarity_type(fish_id, fish_entry)

		fish_entry["minWeight"] = min_weight
		fish_entry["maxWeight"] = max_weight
		fish_entry["keeper_weight"] = keeper_weight
		fish_entry["keeperWeight"] = keeper_weight
		fish_entry["trophyWeight"] = trophy_weight
		fish_entry["record_weight"] = record_weight
		fish_entry["recordWeight"] = record_weight
		fish_entry["basePricePerKg"] = float(fish_entry.get("basePricePerKg", fish_entry.get("price_per_kg", 1.0)))
		fish_entry["rarityType"] = rarity_type
		fish_entry["difficulty"] = _get_default_difficulty(fish_entry)
		fish_entry["habitat"] = str(fish_entry.get("habitat", _get_default_habitat(fish_id, fish_entry)))
		fish_entry["activityTime"] = _get_activity_time(fish_entry)
		fish_entry["preferredWeather"] = _get_preferred_weather(fish_id, fish_entry)

		fish_data[fish_id] = fish_entry

	_fish_rules_applied = true

func _get_default_aggression_for_behavior(behavior: String) -> float:
	match behavior:
		"aggressive":
			return 0.78
		"erratic":
			return 0.88
		"heavy":
			return 0.42
		_:
			return 0.24

func _get_strength_label(strength: float) -> String:
	if strength < 0.45:
		return "very_low"
	if strength < 0.75:
		return "low"
	if strength < 1.15:
		return "medium"
	if strength < 1.65:
		return "high"
	return "very_high"

func _get_default_keeper_weight(fish_id: String, fish_entry: Dictionary, min_weight: float, max_weight: float, trophy_weight: float) -> float:
	if fish_entry.has("keeperWeight"):
		return max(float(fish_entry.get("keeperWeight", min_weight)), min_weight)
	if fish_entry.has("keeper_weight"):
		return max(float(fish_entry.get("keeper_weight", min_weight)), min_weight)

	var ratio := 0.30
	if fish_id in ["bleak", "topmouth_gudgeon", "ruffe", "gudgeon", "goby", "loach", "crayfish", "frog"]:
		ratio = 0.22
	elif fish_id in ["pike", "catfish", "zander", "mist_carp", "moon_catfish"]:
		ratio = 0.34

	var default_weight: float = max(min_weight, trophy_weight * ratio)
	var upper_limit: float = max(min_weight, min(trophy_weight - 0.01, max_weight))
	return snappedf(clamp(default_weight, min_weight, upper_limit), 0.01)


func _get_default_species_rarity_type(fish_id: String, fish_entry: Dictionary) -> String:
	if fish_entry.has("rarityType"):
		return str(fish_entry.get("rarityType", "common"))
	if SPECIES_RARITY_TYPES.has(fish_id):
		return str(SPECIES_RARITY_TYPES[fish_id])

	var old_rarity: String = str(fish_entry.get("rarity", "common"))
	if old_rarity == "rare" or old_rarity == "very_rare" or old_rarity == "trophy":
		return "rare"
	if old_rarity == "legendary" or old_rarity == "mythic":
		return "legendary_species"
	return "common"


func _get_default_difficulty(fish_entry: Dictionary) -> float:
	var base_fight_power: float = float(fish_entry.get("base_fight_power", 1.0))
	var strength: float = float(fish_entry.get("strength", 1.0))
	var aggression: float = float(fish_entry.get("aggression", 0.3))
	var max_weight: float = float(fish_entry.get("max_weight", 1.0))
	return snappedf(clamp(base_fight_power * 0.42 + strength * 0.34 + aggression * 0.16 + pow(max(max_weight, 0.05), 0.22) * 0.18, 0.20, 5.0), 0.01)


func _get_default_habitat(fish_id: String, fish_entry: Dictionary) -> String:
	if fish_id in PREDATOR_FISH_IDS:
		return "predator"
	if fish_id in VEGETATION_FISH_IDS:
		return "vegetation"
	if fish_id in SURFACE_FISH_IDS:
		return "surface"
	if fish_id in BOTTOM_FISH_IDS:
		return "bottom"

	var preferred_depth: float = float(fish_entry.get("preferred_depth", 1.0))
	if preferred_depth >= 2.4:
		return "deep"
	if preferred_depth <= 0.7:
		return "surface"
	return "lake"


func _get_activity_time(fish_entry: Dictionary) -> Dictionary:
	return {
		"start": int(fish_entry.get("active_time_start", 300)),
		"end": int(fish_entry.get("active_time_end", 1320)),
		"peak": int(fish_entry.get("peak_time", 720))
	}


func _get_preferred_weather(fish_id: String, fish_entry: Dictionary) -> Array:
	if fish_entry.has("preferredWeather") and fish_entry.get("preferredWeather", []) is Array:
		return fish_entry.get("preferredWeather", [])
	if fish_id in ["catfish", "eel", "loach", "moon_catfish"]:
		return ["overcast", "rain", "night_mist"]
	if fish_id in ["pike", "zander", "perch", "young_pike"]:
		return ["overcast", "wind", "cool"]
	if fish_id in ["young_grass_carp", "rudd", "bleak", "topmouth_gudgeon"]:
		return ["clear", "warm"]
	return ["clear", "overcast"]

func get_fish(fish_id: String) -> Dictionary:
	_ensure_fish_rules()
	return fish_data.get(fish_id, {})

func get_all_fish_ids() -> Array:
	_ensure_fish_rules()
	return fish_data.keys()

func get_all_fish() -> Dictionary:
	_ensure_fish_rules()
	return fish_data.duplicate(true)

func get_catch_rank(fish: Dictionary, weight: float) -> String:
	var rarity_weight := float(fish.get("rarity_weight", fish.get("max_weight", 999.0) * 0.92))
	var trophy_weight := float(fish.get("trophy_weight", fish.get("max_weight", 999.0) * 0.80))

	if weight >= rarity_weight:
		return "rarity"
	if weight >= trophy_weight:
		return "trophy"
	return "normal"

func get_random_fish_id(available_fish: Array, rare_chance_modifier: float) -> String:
	_ensure_fish_rules()
	var weighted_list: Array = []

	for fish_id in available_fish:
		var fish := get_fish(fish_id)
		if fish.is_empty():
			continue

		var rarity: String = fish["rarity"]
		var weight := 10

		if rarity == "common":
			weight = 70
		elif rarity == "uncommon":
			weight = 25
		elif rarity == "rare":
			weight = int(7 * rare_chance_modifier)
		elif rarity == "very_rare":
			weight = int(3 * rare_chance_modifier)
		elif rarity == "legendary":
			weight = int(1 * rare_chance_modifier)

		for i in weight:
			weighted_list.append(fish_id)

	if weighted_list.is_empty():
		return ""

	return str(weighted_list.pick_random())

func create_catch(fish_id: String, weight_bias: float = 0.0) -> Dictionary:
	_ensure_fish_rules()
	var fish := get_fish(fish_id)
	if fish.is_empty():
		return {}

	var weight_roll: float = _roll_catch_weight_ratio(weight_bias)
	var weight: float = snapped(lerp(float(fish["min_weight"]), float(fish["max_weight"]), weight_roll), 0.01)
	var price: int = max(round(weight * fish["price_per_kg"]) + int(fish.get("base_price", 0)), 1)
	var length_cm: float = snapped(_estimate_length_cm(weight), 0.1)
	var catch_rank := get_catch_rank(fish, weight)
	var trophy_weight := float(fish.get("trophy_weight", fish.get("max_weight", 999.0) * 0.80))
	var rarity_weight := float(fish.get("rarity_weight", fish.get("max_weight", 999.0) * 0.92))

	var catch_data := {
		"id": fish["id"],
		"name": fish["name"],
		"rarity": fish["rarity"],
		"rarityType": str(fish.get("rarityType", "common")),
		"catch_rank": catch_rank,
		"is_trophy": catch_rank == "trophy" or catch_rank == "rarity",
		"is_rarity": catch_rank == "rarity",
		"minWeight": float(fish.get("minWeight", fish.get("min_weight", 0.0))),
		"maxWeight": float(fish.get("maxWeight", fish.get("max_weight", 0.0))),
		"keeper_weight": float(fish.get("keeper_weight", fish.get("keeperWeight", 0.0))),
		"keeperWeight": float(fish.get("keeperWeight", fish.get("keeper_weight", 0.0))),
		"trophy_weight": trophy_weight,
		"rarity_weight": rarity_weight,
		"trophyWeight": float(fish.get("trophyWeight", trophy_weight)),
		"recordWeight": float(fish.get("recordWeight", rarity_weight)),
		"basePricePerKg": float(fish.get("basePricePerKg", fish.get("price_per_kg", 1.0))),
		"difficulty": float(fish.get("difficulty", 1.0)),
		"habitat": str(fish.get("habitat", "lake")),
		"activityTime": fish.get("activityTime", {}),
		"preferredWeather": fish.get("preferredWeather", []),
		"behavior": fish.get("behavior_type", fish.get("behavior", "calm")),
		"behavior_type": fish.get("behavior_type", fish.get("behavior", "calm")),
		"base_fight_power": fish.get("base_fight_power", 1.0),
		"strength": fish.get("strength", 1.0),
		"strength_label": fish.get("strength_label", "medium"),
		"aggression": fish.get("aggression", 0.5),
		"stamina": fish.get("stamina", 1.0),
		"escape_risk": fish.get("escape_risk", 0.25),
		"escape_chance": fish.get("escape_chance", fish.get("escape_risk", 0.25)),
		"active_time_start": fish.get("active_time_start", 300),
		"active_time_end": fish.get("active_time_end", 1320),
		"peak_time": fish.get("peak_time", 480),
		"weight_difficulty_multiplier": fish.get("weight_difficulty_multiplier", 1.0),
		"base_xp": fish.get("base_xp", fish.get("xp", 5)),
		"weight": weight,
		"length_cm": length_cm,
		"price": price,
		"icon_path": str(fish.get("icon_path", "")),
		"description": fish["description"]
	}

	var status_system: Node = get_node_or_null("/root/FishStatusSystem")
	if status_system != null and status_system.has_method("decorate_catch"):
		var status_value = status_system.call("decorate_catch", fish, catch_data)
		if status_value is Dictionary:
			catch_data = status_value as Dictionary

	var trophy_system: Node = get_node_or_null("/root/TrophySystem")
	if trophy_system != null and trophy_system.has_method("decorate_catch"):
		var trophy_value = trophy_system.call("decorate_catch", catch_data)
		if trophy_value is Dictionary:
			catch_data = trophy_value as Dictionary

	var price_calculator: Node = get_node_or_null("/root/FishPriceCalculator")
	if price_calculator != null and price_calculator.has_method("calculate_catch_base_price"):
		catch_data["price"] = int(price_calculator.call("calculate_catch_base_price", catch_data))
		if price_calculator.has_method("calculate_breakdown"):
			var breakdown_value = price_calculator.call("calculate_breakdown", catch_data, "", false)
			if breakdown_value is Dictionary:
				catch_data["economy_price_breakdown"] = breakdown_value

	return catch_data

func _roll_catch_weight_ratio(weight_bias: float = 0.0) -> float:
	var roll: float = pow(randf(), CATCH_WEIGHT_CURVE)
	var bias: float = clamp(weight_bias, 0.0, 1.0)
	if bias > 0.0:
		roll = pow(roll, 1.0 / (1.0 + bias * CATCH_WEIGHT_PEAK_BIAS_STRENGTH))
	return clamp(roll, 0.0, 1.0)

func _estimate_length_cm(weight: float) -> float:
	var length: float = 12.0 + pow(max(weight, 0.05), 0.42) * 23.0 + randf_range(-1.4, 1.6)
	return max(length, 8.0)
