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
			"length_m": 4.0,
			"rod_class": "light",
			"max_fish_weight": 2.0,
			"strength": 0.85,
			"stiffness": 0.85,
			"tension_bonus": 0.05,
			"control_bonus": 0.05,
			"reach_bonus": 0.00,
			"handling_bonus": 0.01,
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
			"length_m": 5.0,
			"rod_class": "medium",
			"max_fish_weight": 3.6,
			"strength": 1.08,
			"stiffness": 1.08,
			"tension_bonus": 0.10,
			"control_bonus": 0.10,
			"reach_bonus": 0.05,
			"handling_bonus": 0.00,
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
			"length_m": 6.0,
			"rod_class": "heavy",
			"max_fish_weight": 6.0,
			"strength": 1.35,
			"stiffness": 1.35,
			"tension_bonus": 0.16,
			"control_bonus": 0.16,
			"reach_bonus": 0.13,
			"handling_bonus": -0.02,
			"durability": 1.0,
			"durability_loss": 0.008
		}
	},
	"green_line_xs_light": {
		"id": "green_line_xs_light",
		"name": "Green Line XS Light",
		"type": "rod",
		"category": "rod",
		"rarity": "common",
		"price": 48,
		"description": "Короткая народная ultra light удочка для мелкой рыбы у берега. Очень послушная, но не любит перегруз.",
		"stats": {
			"length_m": 3.6,
			"rod_class": "ultra_light",
			"max_fish_weight": 1.2,
			"strength": 0.72,
			"stiffness": 0.70,
			"tension_bonus": 0.12,
			"control_bonus": 0.12,
			"reach_bonus": -0.02,
			"handling_bonus": 0.04,
			"durability": 1.0,
			"durability_loss": 0.013
		}
	},
	"green_line_breeze_pole": {
		"id": "green_line_breeze_pole",
		"name": "Green Line Breeze Pole",
		"type": "rod",
		"category": "rod",
		"rarity": "common",
		"price": 120,
		"description": "Лёгкая ранняя удочка с хорошим контролем. Подходит для плотвы, карася и спокойной учебной ловли.",
		"stats": {
			"length_m": 4.2,
			"rod_class": "light",
			"max_fish_weight": 2.2,
			"strength": 0.92,
			"stiffness": 0.90,
			"tension_bonus": 0.10,
			"control_bonus": 0.10,
			"reach_bonus": 0.01,
			"handling_bonus": 0.03,
			"durability": 1.0,
			"durability_loss": 0.011
		}
	},
	"green_line_river_pro": {
		"id": "green_line_river_pro",
		"name": "Green Line River Pro",
		"type": "rod",
		"category": "rod",
		"rarity": "uncommon",
		"price": 260,
		"description": "Универсальная средняя удочка для первых серьёзных точек. Хорошо держит темп и глубину.",
		"stats": {
			"length_m": 5.0,
			"rod_class": "medium",
			"max_fish_weight": 3.8,
			"strength": 1.10,
			"stiffness": 1.08,
			"tension_bonus": 0.12,
			"control_bonus": 0.12,
			"reach_bonus": 0.06,
			"handling_bonus": 0.01,
			"durability": 1.0,
			"durability_loss": 0.010
		}
	},
	"green_line_silver_flow": {
		"id": "green_line_silver_flow",
		"name": "Green Line Silver Flow",
		"type": "rod",
		"category": "rod",
		"rarity": "rare",
		"price": 430,
		"description": "Длинная универсальная удочка для более рабочей глубины. Сохраняет мягкий народный характер.",
		"stats": {
			"length_m": 5.6,
			"rod_class": "universal",
			"max_fish_weight": 5.0,
			"strength": 1.25,
			"stiffness": 1.20,
			"tension_bonus": 0.14,
			"control_bonus": 0.14,
			"reach_bonus": 0.10,
			"handling_bonus": 0.00,
			"durability": 1.0,
			"durability_loss": 0.009
		}
	},
	"green_line_xh_master": {
		"id": "green_line_xh_master",
		"name": "Green Line XH Master",
		"type": "rod",
		"category": "rod",
		"rarity": "rare",
		"price": 760,
		"description": "Топовая силовая Green Line для крупной рыбы. Длинная, мощная, но требует аккуратного контроля.",
		"stats": {
			"length_m": 6.2,
			"rod_class": "heavy",
			"max_fish_weight": 7.5,
			"strength": 1.48,
			"stiffness": 1.44,
			"tension_bonus": 0.14,
			"control_bonus": 0.14,
			"reach_bonus": 0.15,
			"handling_bonus": -0.01,
			"durability": 1.0,
			"durability_loss": 0.007
		}
	},
	"nordriver_ice_reed": {
		"id": "nordriver_ice_reed",
		"name": "NordRiver Ice Reed",
		"type": "rod",
		"category": "rod",
		"rarity": "common",
		"price": 90,
		"description": "Северная лёгкая удочка с запасом прочности. Спокойнее и надёжнее дешёвых стартовых моделей.",
		"stats": {
			"length_m": 4.0,
			"rod_class": "light",
			"max_fish_weight": 1.8,
			"strength": 0.95,
			"stiffness": 0.94,
			"tension_bonus": 0.07,
			"control_bonus": 0.07,
			"reach_bonus": 0.00,
			"handling_bonus": 0.02,
			"durability": 1.0,
			"durability_loss": 0.010
		}
	},
	"nordriver_arctic_pole": {
		"id": "nordriver_arctic_pole",
		"name": "NordRiver Arctic Pole",
		"type": "rod",
		"category": "rod",
		"rarity": "uncommon",
		"price": 240,
		"description": "Холодная стабильная medium удочка. Хороший вариант для уверенного перехода к средней рыбе.",
		"stats": {
			"length_m": 4.8,
			"rod_class": "medium",
			"max_fish_weight": 3.2,
			"strength": 1.15,
			"stiffness": 1.14,
			"tension_bonus": 0.09,
			"control_bonus": 0.09,
			"reach_bonus": 0.05,
			"handling_bonus": 0.01,
			"durability": 1.0,
			"durability_loss": 0.009
		}
	},
	"nordriver_stream_hunter": {
		"id": "nordriver_stream_hunter",
		"name": "NordRiver Stream Hunter",
		"type": "rod",
		"category": "rod",
		"rarity": "rare",
		"price": 420,
		"description": "Универсальная северная удочка для глубины и течения. Хорошо держит перегруз и не теряет стабильность.",
		"stats": {
			"length_m": 5.4,
			"rod_class": "universal",
			"max_fish_weight": 4.8,
			"strength": 1.32,
			"stiffness": 1.30,
			"tension_bonus": 0.11,
			"control_bonus": 0.11,
			"reach_bonus": 0.09,
			"handling_bonus": 0.00,
			"durability": 1.0,
			"durability_loss": 0.008
		}
	},
	"nordriver_white_pike": {
		"id": "nordriver_white_pike",
		"name": "NordRiver White Pike",
		"type": "rod",
		"category": "rod",
		"rarity": "rare",
		"price": 690,
		"description": "Жёсткая heavy удочка под хищника и крупную рыбу. Прочная, но менее деликатная.",
		"stats": {
			"length_m": 5.8,
			"rod_class": "heavy",
			"max_fish_weight": 6.8,
			"strength": 1.55,
			"stiffness": 1.58,
			"tension_bonus": 0.09,
			"control_bonus": 0.09,
			"reach_bonus": 0.12,
			"handling_bonus": -0.02,
			"durability": 1.0,
			"durability_loss": 0.007
		}
	},
	"nordriver_carbon_wind": {
		"id": "nordriver_carbon_wind",
		"name": "NordRiver Carbon Wind",
		"type": "rod",
		"category": "rod",
		"rarity": "trophy",
		"price": 980,
		"description": "Карбоновая северная удочка pro-класса. Много прочности без грубого ощущения в руках.",
		"stats": {
			"length_m": 6.0,
			"rod_class": "heavy",
			"max_fish_weight": 8.0,
			"strength": 1.68,
			"stiffness": 1.62,
			"tension_bonus": 0.13,
			"control_bonus": 0.13,
			"reach_bonus": 0.14,
			"handling_bonus": 0.00,
			"durability": 1.0,
			"durability_loss": 0.006
		}
	},
	"sakura_fish_hana_light": {
		"id": "sakura_fish_hana_light",
		"name": "Sakura Fish Hana Light",
		"type": "rod",
		"category": "rod",
		"rarity": "common",
		"price": 70,
		"description": "Очень лёгкая finesse удочка для осторожной мелкой рыбы. Максимум контроля, минимум силового запаса.",
		"stats": {
			"length_m": 3.3,
			"rod_class": "ultra_light",
			"max_fish_weight": 0.9,
			"strength": 0.64,
			"stiffness": 0.62,
			"tension_bonus": 0.18,
			"control_bonus": 0.18,
			"reach_bonus": -0.03,
			"handling_bonus": 0.06,
			"durability": 1.0,
			"durability_loss": 0.014
		}
	},
	"sakura_fish_koi_master": {
		"id": "sakura_fish_koi_master",
		"name": "Sakura Fish Koi Master",
		"type": "rod",
		"category": "rod",
		"rarity": "uncommon",
		"price": 260,
		"description": "Точная light удочка для карася, плотвы и аккуратной игры в зелёной зоне.",
		"stats": {
			"length_m": 4.5,
			"rod_class": "light",
			"max_fish_weight": 2.6,
			"strength": 0.96,
			"stiffness": 0.94,
			"tension_bonus": 0.18,
			"control_bonus": 0.18,
			"reach_bonus": 0.03,
			"handling_bonus": 0.04,
			"durability": 1.0,
			"durability_loss": 0.010
		}
	},
	"sakura_fish_red_moon": {
		"id": "sakura_fish_red_moon",
		"name": "Sakura Fish Red Moon",
		"type": "rod",
		"category": "rod",
		"rarity": "rare",
		"price": 460,
		"description": "Средняя японская удочка с высоким контролем. Хороша для точной ловли на вечерних точках.",
		"stats": {
			"length_m": 5.0,
			"rod_class": "medium",
			"max_fish_weight": 3.6,
			"strength": 1.10,
			"stiffness": 1.06,
			"tension_bonus": 0.20,
			"control_bonus": 0.20,
			"reach_bonus": 0.06,
			"handling_bonus": 0.03,
			"durability": 1.0,
			"durability_loss": 0.009
		}
	},
	"sakura_fish_silent_river": {
		"id": "sakura_fish_silent_river",
		"name": "Sakura Fish Silent River",
		"type": "rod",
		"category": "rod",
		"rarity": "trophy",
		"price": 780,
		"description": "Премиальная finesse universal удочка. Не самая силовая, зато отлично держит контроль.",
		"stats": {
			"length_m": 5.5,
			"rod_class": "universal",
			"max_fish_weight": 4.6,
			"strength": 1.20,
			"stiffness": 1.14,
			"tension_bonus": 0.24,
			"control_bonus": 0.24,
			"reach_bonus": 0.09,
			"handling_bonus": 0.04,
			"durability": 1.0,
			"durability_loss": 0.007
		}
	},
	"titan_hook_iron_flex": {
		"id": "titan_hook_iron_flex",
		"name": "Titan Hook Iron Flex",
		"type": "rod",
		"category": "rod",
		"rarity": "uncommon",
		"price": 360,
		"description": "Силовая medium-heavy удочка. Прощает перегруз, но не такая мягкая в контроле.",
		"stats": {
			"length_m": 4.8,
			"rod_class": "medium",
			"max_fish_weight": 4.8,
			"strength": 1.38,
			"stiffness": 1.42,
			"tension_bonus": 0.05,
			"control_bonus": 0.05,
			"reach_bonus": 0.04,
			"handling_bonus": -0.02,
			"durability": 1.0,
			"durability_loss": 0.008
		}
	},
	"titan_hook_black_carbon": {
		"id": "titan_hook_black_carbon",
		"name": "Titan Hook Black Carbon",
		"type": "rod",
		"category": "rod",
		"rarity": "rare",
		"price": 620,
		"description": "Чёрный карбон для тяжёлой рыбы. Большой запас прочности при умеренном контроле.",
		"stats": {
			"length_m": 5.2,
			"rod_class": "heavy",
			"max_fish_weight": 6.4,
			"strength": 1.62,
			"stiffness": 1.68,
			"tension_bonus": 0.07,
			"control_bonus": 0.07,
			"reach_bonus": 0.08,
			"handling_bonus": -0.02,
			"durability": 1.0,
			"durability_loss": 0.007
		}
	},
	"titan_hook_predator_x": {
		"id": "titan_hook_predator_x",
		"name": "Titan Hook Predator X",
		"type": "rod",
		"category": "rod",
		"rarity": "rare",
		"price": 880,
		"description": "Хищная heavy удочка для рывков и крупного сопротивления. Сила важнее деликатности.",
		"stats": {
			"length_m": 5.6,
			"rod_class": "heavy",
			"max_fish_weight": 8.2,
			"strength": 1.85,
			"stiffness": 1.92,
			"tension_bonus": 0.06,
			"control_bonus": 0.06,
			"reach_bonus": 0.11,
			"handling_bonus": -0.03,
			"durability": 1.0,
			"durability_loss": 0.006
		}
	},
	"titan_hook_storm_pole": {
		"id": "titan_hook_storm_pole",
		"name": "Titan Hook Storm Pole",
		"type": "rod",
		"category": "rod",
		"rarity": "trophy",
		"price": 1160,
		"description": "Extra heavy удочка для самой тяжёлой альфа-рыбы. Мощная, но грубая.",
		"stats": {
			"length_m": 6.0,
			"rod_class": "extra_heavy",
			"max_fish_weight": 10.0,
			"strength": 2.10,
			"stiffness": 2.18,
			"tension_bonus": 0.04,
			"control_bonus": 0.04,
			"reach_bonus": 0.14,
			"handling_bonus": -0.04,
			"durability": 1.0,
			"durability_loss": 0.006
		}
	},
	"titan_hook_ultra_match": {
		"id": "titan_hook_ultra_match",
		"name": "Titan Hook Ultra Match",
		"type": "rod",
		"category": "rod",
		"rarity": "trophy",
		"price": 1500,
		"description": "Топовая силовая universal удочка с максимальной длиной и запасом. Для поздней альфы.",
		"stats": {
			"length_m": 6.5,
			"rod_class": "universal",
			"max_fish_weight": 12.0,
			"strength": 2.25,
			"stiffness": 2.20,
			"tension_bonus": 0.10,
			"control_bonus": 0.10,
			"reach_bonus": 0.18,
			"handling_bonus": -0.02,
			"durability": 1.0,
			"durability_loss": 0.005
		}
	},
	"aquanova_crystal_pole": {
		"id": "aquanova_crystal_pole",
		"name": "AquaNova Crystal Pole",
		"type": "rod",
		"category": "rod",
		"rarity": "rare",
		"price": 650,
		"description": "Современная premium medium удочка. Лёгкая, точная и комфортная в долгом вываживании.",
		"stats": {
			"length_m": 4.6,
			"rod_class": "medium",
			"max_fish_weight": 3.4,
			"strength": 1.16,
			"stiffness": 1.10,
			"tension_bonus": 0.22,
			"control_bonus": 0.22,
			"reach_bonus": 0.04,
			"handling_bonus": 0.04,
			"durability": 1.0,
			"durability_loss": 0.007
		}
	},
	"aquanova_neo_river": {
		"id": "aquanova_neo_river",
		"name": "AquaNova Neo River",
		"type": "rod",
		"category": "rod",
		"rarity": "trophy",
		"price": 1050,
		"description": "Премиальная universal удочка для прогресса в поздней альфе. Баланс силы, длины и контроля.",
		"stats": {
			"length_m": 5.4,
			"rod_class": "universal",
			"max_fish_weight": 5.8,
			"strength": 1.45,
			"stiffness": 1.38,
			"tension_bonus": 0.23,
			"control_bonus": 0.23,
			"reach_bonus": 0.10,
			"handling_bonus": 0.04,
			"durability": 1.0,
			"durability_loss": 0.006
		}
	},
	"aquanova_sky_drift": {
		"id": "aquanova_sky_drift",
		"name": "AquaNova Sky Drift",
		"type": "rod",
		"category": "rod",
		"rarity": "trophy",
		"price": 1400,
		"description": "Длинная premium удочка с отличным контролем для глубины. Дальняя рабочая вода без тяжёлого ощущения.",
		"stats": {
			"length_m": 6.2,
			"rod_class": "universal",
			"max_fish_weight": 7.8,
			"strength": 1.70,
			"stiffness": 1.62,
			"tension_bonus": 0.22,
			"control_bonus": 0.22,
			"reach_bonus": 0.16,
			"handling_bonus": 0.03,
			"durability": 1.0,
			"durability_loss": 0.005
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
		"image_path": "res://assets/ui/shop/lines/basiclinenylon2_5kg.png",
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
		"image_path": "res://assets/ui/shop/lines/basiclinenylon5kg.png",
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
		"image_path": "res://assets/ui/shop/lines/lakelinenylon1_5kg.png",
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
		"image_path": "res://assets/ui/shop/lines/lakelinenylon2kg.png",
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
		"image_path": "res://assets/ui/shop/lines/lakelinenylon2_5kg.png",
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
		"image_path": "res://assets/ui/shop/lines/lakelinenylon3kg.png",
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
		"image_path": "res://assets/ui/shop/lines/lakelinenylon4kg.png",
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
		"image_path": "res://assets/ui/shop/lines/lakelinenylon5kg.png",
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
		"image_path": "res://assets/ui/shop/lines/lakelinenylon6kg.png",
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
		"image_path": "res://assets/ui/shop/lines/lakelinenylon8kg.png",
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
		"image_path": "res://assets/ui/shop/lines/lakelinenylon10kg.png",
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
		"image_path": "res://assets/ui/shop/lines/lakelinenylon12kg.png",
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
		"image_path": "res://assets/ui/shop/lines/lakelinenylon15kg.png",
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
		"image_path": "res://assets/ui/shop/lines/lakelinenylon18kg.png",
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
		"image_path": "res://assets/ui/shop/lines/lakelinenylon20kg.png",
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
	"basic_mono_leader_1kg": {
		"id": "basic_mono_leader_1kg",
		"name": "Basic Mono Leader 1 kg",
		"type": "leader",
		"category": "leader",
		"rarity": "common",
		"price": 18,
		"description": "Thin starter leader for cautious small fish.",
		"stats": {
			"leader_type": "mono",
			"strength": 1.0,
			"visibility": 0.04,
			"bite_protection": 0.00,
			"durability": 1.0,
			"wear_rate": 0.020
		}
	},
	"soft_fluoro_leader_2kg": {
		"id": "soft_fluoro_leader_2kg",
		"name": "Soft Fluoro Leader 2 kg",
		"type": "leader",
		"category": "leader",
		"rarity": "uncommon",
		"price": 48,
		"description": "Low-visibility leader for clear water and delicate float rigs.",
		"stats": {
			"leader_type": "fluoro",
			"strength": 2.0,
			"visibility": 0.025,
			"bite_protection": 0.03,
			"durability": 1.0,
			"wear_rate": 0.018
		}
	},
	"strong_braid_leader_4kg": {
		"id": "strong_braid_leader_4kg",
		"name": "Strong Braid Leader 4 kg",
		"type": "leader",
		"category": "leader",
		"rarity": "rare",
		"price": 92,
		"description": "Stronger leader for bigger fish. More visible, but safer under pressure.",
		"stats": {
			"leader_type": "braid",
			"strength": 4.0,
			"visibility": 0.08,
			"bite_protection": 0.07,
			"durability": 1.0,
			"wear_rate": 0.016
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
	"riverstart_basic_hook_24": {
		"id": "riverstart_basic_hook_24",
		"name": "RiverStart Basic Hook №24",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 0.3,
		"description": "Стартовый бюджетный крючок для самой мелкой осторожной рыбы.",
		"stats": {
			"hook_size": 24,
			"hook_size_label": "24",
			"hook_strength": 0.32,
			"hook_chance": 0.03,
			"target_fish_size": "small",
			"fish_escape_modifier": 1.22,
			"durability": 1.0,
			"wear_rate": 0.046
		}
	},
	"riverstart_basic_hook_22": {
		"id": "riverstart_basic_hook_22",
		"name": "RiverStart Basic Hook №22",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 0.4,
		"description": "Дешёвый тонкий крючок для мелкой рыбы.",
		"stats": {
			"hook_size": 22,
			"hook_size_label": "22",
			"hook_strength": 0.34,
			"hook_chance": 0.034,
			"target_fish_size": "small",
			"fish_escape_modifier": 1.21,
			"durability": 1.0,
			"wear_rate": 0.045
		}
	},
	"riverstart_basic_hook_20": {
		"id": "riverstart_basic_hook_20",
		"name": "RiverStart Basic Hook №20",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 0.6,
		"description": "Бюджетный крючок для уклейки и другой небольшой рыбы.",
		"stats": {
			"hook_size": 20,
			"hook_size_label": "20",
			"hook_strength": 0.38,
			"hook_chance": 0.04,
			"target_fish_size": "small",
			"fish_escape_modifier": 1.20,
			"durability": 1.0,
			"wear_rate": 0.044
		}
	},
	"riverstart_basic_hook_18": {
		"id": "riverstart_basic_hook_18",
		"name": "RiverStart Basic Hook №18",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 0.8,
		"description": "Стартовый крючок для лёгкой поплавочной оснастки.",
		"stats": {
			"hook_size": 18,
			"hook_size_label": "18",
			"hook_strength": 0.42,
			"hook_chance": 0.046,
			"target_fish_size": "small",
			"fish_escape_modifier": 1.19,
			"durability": 1.0,
			"wear_rate": 0.043
		}
	},
	"riverstart_basic_hook_16": {
		"id": "riverstart_basic_hook_16",
		"name": "RiverStart Basic Hook №16",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 1.0,
		"description": "Недорогой крючок для мелкой и некрупной белой рыбы.",
		"stats": {
			"hook_size": 16,
			"hook_size_label": "16",
			"hook_strength": 0.47,
			"hook_chance": 0.052,
			"target_fish_size": "small",
			"fish_escape_modifier": 1.18,
			"durability": 1.0,
			"wear_rate": 0.042
		}
	},
	"riverstart_basic_hook_14": {
		"id": "riverstart_basic_hook_14",
		"name": "RiverStart Basic Hook №14",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 1.3,
		"description": "Бюджетный универсальный крючок для ранней ловли.",
		"stats": {
			"hook_size": 14,
			"hook_size_label": "14",
			"hook_strength": 0.52,
			"hook_chance": 0.058,
			"target_fish_size": "small",
			"fish_escape_modifier": 1.17,
			"durability": 1.0,
			"wear_rate": 0.041
		}
	},
	"riverstart_basic_hook_12": {
		"id": "riverstart_basic_hook_12",
		"name": "RiverStart Basic Hook №12",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 1.7,
		"description": "Дешёвый крючок ходового размера. Уступает фирменным крючкам по прочности.",
		"stats": {
			"hook_size": 12,
			"hook_size_label": "12",
			"hook_strength": 0.58,
			"hook_chance": 0.064,
			"target_fish_size": "small",
			"fish_escape_modifier": 1.16,
			"durability": 1.0,
			"wear_rate": 0.040
		}
	},
	"riverstart_basic_hook_10": {
		"id": "riverstart_basic_hook_10",
		"name": "RiverStart Basic Hook №10",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 2.2,
		"description": "Бюджетный крючок для плотвы, карася и окуня.",
		"stats": {
			"hook_size": 10,
			"hook_size_label": "10",
			"hook_strength": 0.65,
			"hook_chance": 0.070,
			"target_fish_size": "small",
			"fish_escape_modifier": 1.15,
			"durability": 1.0,
			"wear_rate": 0.039
		}
	},
	"riverstart_basic_hook_8": {
		"id": "riverstart_basic_hook_8",
		"name": "RiverStart Basic Hook №8",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 3.0,
		"description": "Бюджетный крючок среднего размера для универсальной ловли.",
		"stats": {
			"hook_size": 8,
			"hook_size_label": "8",
			"hook_strength": 0.76,
			"hook_chance": 0.074,
			"target_fish_size": "medium",
			"fish_escape_modifier": 1.14,
			"durability": 1.0,
			"wear_rate": 0.038
		}
	},
	"riverstart_basic_hook_6": {
		"id": "riverstart_basic_hook_6",
		"name": "RiverStart Basic Hook №6",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 4.2,
		"description": "Недорогой средний крючок для рыбы покрупнее.",
		"stats": {
			"hook_size": 6,
			"hook_size_label": "6",
			"hook_strength": 0.86,
			"hook_chance": 0.078,
			"target_fish_size": "medium",
			"fish_escape_modifier": 1.13,
			"durability": 1.0,
			"wear_rate": 0.037
		}
	},
	"riverstart_basic_hook_4": {
		"id": "riverstart_basic_hook_4",
		"name": "RiverStart Basic Hook №4",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 5.8,
		"description": "Крупный бюджетный крючок. Подходит для сильной рыбы, но грубоват.",
		"stats": {
			"hook_size": 4,
			"hook_size_label": "4",
			"hook_strength": 0.98,
			"hook_chance": 0.080,
			"target_fish_size": "large",
			"fish_escape_modifier": 1.12,
			"durability": 1.0,
			"wear_rate": 0.036
		}
	},
	"riverstart_basic_hook_2": {
		"id": "riverstart_basic_hook_2",
		"name": "RiverStart Basic Hook №2",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 7.5,
		"description": "Крупный бюджетный крючок для силовой ловли.",
		"stats": {
			"hook_size": 2,
			"hook_size_label": "2",
			"hook_strength": 1.08,
			"hook_chance": 0.082,
			"target_fish_size": "large",
			"fish_escape_modifier": 1.11,
			"durability": 1.0,
			"wear_rate": 0.035
		}
	},
	"riverstart_basic_hook_1": {
		"id": "riverstart_basic_hook_1",
		"name": "RiverStart Basic Hook №1",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 9.5,
		"description": "Большой бюджетный крючок для крупной рыбы.",
		"stats": {
			"hook_size": 1,
			"hook_size_label": "1",
			"hook_strength": 1.16,
			"hook_chance": 0.084,
			"target_fish_size": "large",
			"fish_escape_modifier": 1.10,
			"durability": 1.0,
			"wear_rate": 0.034
		}
	},
	"riverstart_basic_hook_1_0": {
		"id": "riverstart_basic_hook_1_0",
		"name": "RiverStart Basic Hook №1/0",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 12,
		"description": "Бюджетный крючок 1/0 для крупной рыбы и грубой оснастки.",
		"stats": {
			"hook_size": 0,
			"hook_size_label": "1/0",
			"hook_strength": 1.24,
			"hook_chance": 0.084,
			"target_fish_size": "large",
			"fish_escape_modifier": 1.10,
			"durability": 1.0,
			"wear_rate": 0.033
		}
	},
	"riverstart_basic_hook_2_0": {
		"id": "riverstart_basic_hook_2_0",
		"name": "RiverStart Basic Hook №2/0",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 15,
		"description": "Бюджетный крючок 2/0 для самой крупной рыбы.",
		"stats": {
			"hook_size": -1,
			"hook_size_label": "2/0",
			"hook_strength": 1.34,
			"hook_chance": 0.082,
			"target_fish_size": "large",
			"fish_escape_modifier": 1.11,
			"durability": 1.0,
			"wear_rate": 0.033
		}
	},
	"riverstart_basic_hook_3_0": {
		"id": "riverstart_basic_hook_3_0",
		"name": "RiverStart Basic Hook №3/0",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 19,
		"description": "Крупный бюджетный крючок 3/0. Требует подходящей рыбы и снасти.",
		"stats": {
			"hook_size": -2,
			"hook_size_label": "3/0",
			"hook_strength": 1.46,
			"hook_chance": 0.080,
			"target_fish_size": "large",
			"fish_escape_modifier": 1.12,
			"durability": 1.0,
			"wear_rate": 0.032
		}
	},
	"riverstart_basic_hook_4_0": {
		"id": "riverstart_basic_hook_4_0",
		"name": "RiverStart Basic Hook №4/0",
		"type": "hook",
		"category": "hook",
		"rarity": "common",
		"price": 24,
		"description": "Самый крупный крючок RiverStart Basic Hook. Дешёвый, прочный и грубый.",
		"stats": {
			"hook_size": -3,
			"hook_size_label": "4/0",
			"hook_strength": 1.60,
			"hook_chance": 0.078,
			"target_fish_size": "large",
			"fish_escape_modifier": 1.13,
			"durability": 1.0,
			"wear_rate": 0.032
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
		"image_path": "res://assets/ui/shop/baits/cherv.png",
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
		"image_path": "res://assets/ui/shop/baits/hleb.png",
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
		"image_path": "res://assets/ui/shop/baits/yaichonoe_testo.png",
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
		"image_path": "res://assets/ui/shop/baits/oparish.png",
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
	},
	"cherv_moskovskiy": {
		"id": "cherv_moskovskiy",
		"name": "Московский червь",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 24,
		"image_path": "res://assets/ui/shop/baits/cherv_moskovskiy.png",
		"description": "Плотный универсальный червь для белой рыбы и окуня.",
		"stats": {
			"bait_type": "worm",
			"fish_attraction": 0.15,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"cherv_surskiy": {
		"id": "cherv_surskiy",
		"name": "Сурский червь",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 28,
		"image_path": "res://assets/ui/shop/baits/cherv_surskiy.png",
		"description": "Мясистый речной червь с хорошей заметностью на дне.",
		"stats": {
			"bait_type": "worm",
			"fish_attraction": 0.16,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"kaster": {
		"id": "kaster",
		"name": "Кастер",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 20,
		"image_path": "res://assets/ui/shop/baits/kaster.png",
		"description": "Компактная личиночная наживка для осторожной мелкой рыбы.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.13,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"lichinka_podenki": {
		"id": "lichinka_podenki",
		"name": "Личинка подёнки",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 34,
		"image_path": "res://assets/ui/shop/baits/lichinka_podenki.png",
		"description": "Речная личинка для аккуратной ловли в чистой воде.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.16,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"lichinka_vesnyanki": {
		"id": "lichinka_vesnyanki",
		"name": "Личинка веснянки",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 36,
		"image_path": "res://assets/ui/shop/baits/lichinka_vesnyanki.png",
		"description": "Живая речная наживка для прохладной воды и течения.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.16,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"motil": {
		"id": "motil",
		"name": "Мотыль",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 18,
		"image_path": "res://assets/ui/shop/baits/motil.png",
		"description": "Мелкая яркая наживка для осторожного клёва.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.14,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"krabovoe_myaso": {
		"id": "krabovoe_myaso",
		"name": "Крабовое мясо",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 64,
		"image_path": "res://assets/ui/shop/baits/krabovoe_myaso.png",
		"description": "Ароматная белковая наживка для более требовательной рыбы.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.18,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"cherv_navozni": {
		"id": "cherv_navozni",
		"name": "Навозный червь",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 16,
		"image_path": "res://assets/ui/shop/baits/cherv_navozni.png",
		"description": "Пахучий червь для донной и прибрежной рыбы.",
		"stats": {
			"bait_type": "worm",
			"fish_attraction": 0.14,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"piyavka": {
		"id": "piyavka",
		"name": "Пиявка",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 54,
		"image_path": "res://assets/ui/shop/baits/piyavka.png",
		"description": "Живучая животная наживка для осторожной крупной рыбы.",
		"stats": {
			"bait_type": "worm",
			"fish_attraction": 0.17,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"goroshek": {
		"id": "goroshek",
		"name": "Горошек",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 14,
		"image_path": "res://assets/ui/shop/baits/goroshek.png",
		"description": "Растительная насадка для спокойной белой рыбы.",
		"stats": {
			"bait_type": "bread",
			"fish_attraction": 0.10,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"kartofelniy_kubik": {
		"id": "kartofelniy_kubik",
		"name": "Картофельный кубик",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 16,
		"image_path": "res://assets/ui/shop/baits/kartofelniy_kubik.png",
		"description": "Мягкая растительная насадка для тихой воды.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.10,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"cherv_astrahanskiy": {
		"id": "cherv_astrahanskiy",
		"name": "Астраханский червь",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 48,
		"image_path": "res://assets/ui/shop/baits/cherv_astrahanskiy.png",
		"description": "Крупный червь для уверенной донной подачи.",
		"stats": {
			"bait_type": "worm",
			"fish_attraction": 0.18,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"myaso_dreiseni": {
		"id": "myaso_dreiseni",
		"name": "Мясо дрейсены",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 38,
		"image_path": "res://assets/ui/shop/baits/myaso_dreiseni.png",
		"description": "Мягкая ракушечная насадка с выраженным запахом.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.16,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"rucheinik": {
		"id": "rucheinik",
		"name": "Ручейник",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 34,
		"image_path": "res://assets/ui/shop/baits/rucheinik.png",
		"description": "Естественная речная наживка для рыбы у дна.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.16,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"puchok_vodorosley": {
		"id": "puchok_vodorosley",
		"name": "Пучок водорослей",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 14,
		"image_path": "res://assets/ui/shop/baits/puchok_vodorosley.png",
		"description": "Растительная наживка для травянистых участков.",
		"stats": {
			"bait_type": "bread",
			"fish_attraction": 0.09,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"ovsyanaya_kasha": {
		"id": "ovsyanaya_kasha",
		"name": "Овсяная каша",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 15,
		"image_path": "res://assets/ui/shop/baits/ovsyanaya_kasha.png",
		"description": "Мягкая каша для карася, плотвы и другой мирной рыбы.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.11,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"sverchok": {
		"id": "sverchok",
		"name": "Сверчок",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 32,
		"image_path": "res://assets/ui/shop/baits/sverchok.png",
		"description": "Подвижная поверхностная наживка для активной рыбы.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.15,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"syrni_kubik": {
		"id": "syrni_kubik",
		"name": "Сырный кубик",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 30,
		"image_path": "res://assets/ui/shop/baits/syrni_kubik.png",
		"description": "Плотная ароматная насадка для спокойной подачи.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.13,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"kuznechik": {
		"id": "kuznechik",
		"name": "Кузнечик",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 34,
		"image_path": "res://assets/ui/shop/baits/kuznechik.png",
		"description": "Заметная летняя наживка для активной рыбы у поверхности.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.16,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"sladkoe_testo": {
		"id": "sladkoe_testo",
		"name": "Сладкое тесто",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 18,
		"image_path": "res://assets/ui/shop/baits/sladkoe_testo.png",
		"description": "Сладкая мягкая насадка для мирной рыбы.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.12,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"lichinka_koroeda": {
		"id": "lichinka_koroeda",
		"name": "Личинка короеда",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 36,
		"image_path": "res://assets/ui/shop/baits/lichinka_koroeda.png",
		"description": "Плотная личинка для точечной ловли осторожной рыбы.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.16,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"podenka": {
		"id": "podenka",
		"name": "Подёнка",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 38,
		"image_path": "res://assets/ui/shop/baits/podenka.png",
		"description": "Лёгкая природная наживка для аккуратной летней ловли.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.15,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"chesnochnoye_testo": {
		"id": "chesnochnoye_testo",
		"name": "Чесночное тесто",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 28,
		"image_path": "res://assets/ui/shop/baits/chesnochnoye_testo.png",
		"description": "Ароматное тесто для пассивной белой рыбы.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.14,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"mannaya_kasha": {
		"id": "mannaya_kasha",
		"name": "Манная каша",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 16,
		"image_path": "res://assets/ui/shop/baits/mannaya_kasha.png",
		"description": "Классическая мягкая каша для карася и плотвы.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.11,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"cherv_volhovskiy": {
		"id": "cherv_volhovskiy",
		"name": "Волховский червь",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 52,
		"image_path": "res://assets/ui/shop/baits/cherv_volhovskiy.png",
		"description": "Крупная речная наживка для глубины и донной рыбы.",
		"stats": {
			"bait_type": "worm",
			"fish_attraction": 0.18,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"ikra": {
		"id": "ikra",
		"name": "Икра",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 72,
		"image_path": "res://assets/ui/shop/baits/ikra.png",
		"description": "Яркая деликатная насадка с сильным пищевым сигналом.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.19,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"gorohovaya_kasha": {
		"id": "gorohovaya_kasha",
		"name": "Гороховая каша",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 24,
		"image_path": "res://assets/ui/shop/baits/gorohovaya_kasha.png",
		"description": "Питательная растительная насадка для мирной рыбы.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.13,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"bokoplav": {
		"id": "bokoplav",
		"name": "Бокоплав",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 40,
		"image_path": "res://assets/ui/shop/baits/bokoplav.png",
		"description": "Водная животная наживка для рыбы у дна и камней.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.17,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"kukuruznaya_kasha": {
		"id": "kukuruznaya_kasha",
		"name": "Кукурузная каша",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 26,
		"image_path": "res://assets/ui/shop/baits/kukuruznaya_kasha.png",
		"description": "Сладковатая каша для спокойной белой рыбы.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.13,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"yaichonoe_testo": {
		"id": "yaichonoe_testo",
		"name": "Яичное тесто",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 28,
		"image_path": "res://assets/ui/shop/baits/yaichonoe_testo.png",
		"description": "Плотное питательное тесто, хорошо держится на крючке.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.14,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"muha": {
		"id": "muha",
		"name": "Муха",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 18,
		"image_path": "res://assets/ui/shop/baits/muha.png",
		"description": "Лёгкая животная наживка для поверхностной активности.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.13,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"maiskiy_zhuk": {
		"id": "maiskiy_zhuk",
		"name": "Майский жук",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 58,
		"image_path": "res://assets/ui/shop/baits/maiskiy_zhuk.png",
		"description": "Крупная сезонная наживка для уверенной поклёвки.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.18,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"zerna_phenici": {
		"id": "zerna_phenici",
		"name": "Зёрна пшеницы",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 14,
		"image_path": "res://assets/ui/shop/baits/zerna_phenici.png",
		"description": "Простая зерновая насадка для мирной рыбы.",
		"stats": {
			"bait_type": "bread",
			"fish_attraction": 0.10,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"myaso_perlovici": {
		"id": "myaso_perlovici",
		"name": "Мясо перловицы",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 42,
		"image_path": "res://assets/ui/shop/baits/myaso_perlovici.png",
		"description": "Мягкое мясо моллюска для донной рыбы.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.17,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"ovod": {
		"id": "ovod",
		"name": "Овод",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 34,
		"image_path": "res://assets/ui/shop/baits/ovod.png",
		"description": "Заметная животная наживка для активной рыбы.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.15,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"lichinka_zhukanosoroga": {
		"id": "lichinka_zhukanosoroga",
		"name": "Личинка жука-носорога",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 68,
		"image_path": "res://assets/ui/shop/baits/lichinka_zhukanosoroga.png",
		"description": "Крупная питательная личинка для сильной рыбы.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.19,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"slepen": {
		"id": "slepen",
		"name": "Слепень",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 34,
		"image_path": "res://assets/ui/shop/baits/slepen.png",
		"description": "Летняя наживка для заметной подачи у поверхности.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.15,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"rakovaia_sheika": {
		"id": "rakovaia_sheika",
		"name": "Раковая шейка",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 76,
		"image_path": "res://assets/ui/shop/baits/rakovaia_sheika.png",
		"description": "Крупная белковая насадка для самой уверенной подачи.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.20,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"zerna_kukuruzi": {
		"id": "zerna_kukuruzi",
		"name": "Зёрна кукурузы",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 16,
		"image_path": "res://assets/ui/shop/baits/zerna_kukuruzi.png",
		"description": "Яркая сладкая насадка для мирной рыбы.",
		"stats": {
			"bait_type": "bread",
			"fish_attraction": 0.11,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"cherv_leningradskiy": {
		"id": "cherv_leningradskiy",
		"name": "Ленинградский червь",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 56,
		"image_path": "res://assets/ui/shop/baits/cherv_leningradskiy.png",
		"description": "Крупный тёмный червь для прохладной воды и глубины.",
		"stats": {
			"bait_type": "worm",
			"fish_attraction": 0.19,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"kapustni_list": {
		"id": "kapustni_list",
		"name": "Капустный лист",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 12,
		"image_path": "res://assets/ui/shop/baits/kapustni_list.png",
		"description": "Лёгкая растительная насадка для травянистой воды.",
		"stats": {
			"bait_type": "bread",
			"fish_attraction": 0.08,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"kusochki_ryby": {
		"id": "kusochki_ryby",
		"name": "Кусочки рыбы",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 70,
		"image_path": "res://assets/ui/shop/baits/kusochki_ryby.png",
		"description": "Белковая наживка с сильным запахом для активной рыбы.",
		"stats": {
			"bait_type": "worm",
			"fish_attraction": 0.19,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"tvorozhnoye_testo": {
		"id": "tvorozhnoye_testo",
		"name": "Творожное тесто",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 30,
		"image_path": "res://assets/ui/shop/baits/tvorozhnoye_testo.png",
		"description": "Мягкая ароматная насадка для мирной рыбы.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.14,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"perlovaya_kasha": {
		"id": "perlovaya_kasha",
		"name": "Перловая каша",
		"type": "bait",
		"category": "bait",
		"rarity": "common",
		"price": 18,
		"image_path": "res://assets/ui/shop/baits/perlovaya_kasha.png",
		"description": "Плотная зерновая каша для карася и плотвы.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.12,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"zhuk_navozni": {
		"id": "zhuk_navozni",
		"name": "Навозный жук",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 42,
		"image_path": "res://assets/ui/shop/baits/zhuk_navozni.png",
		"description": "Плотная животная наживка для заметной донной подачи.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.16,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"medovoye_testo": {
		"id": "medovoye_testo",
		"name": "Медовое тесто",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 32,
		"image_path": "res://assets/ui/shop/baits/medovoye_testo.png",
		"description": "Сладкое ароматное тесто для пассивной мирной рыбы.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.15,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"medvedka": {
		"id": "medvedka",
		"name": "Медведка",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 62,
		"image_path": "res://assets/ui/shop/baits/medvedka.png",
		"description": "Крупная животная наживка для сильной рыбы.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.18,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"lichinka_mayskogozhuka": {
		"id": "lichinka_mayskogozhuka",
		"name": "Личинка майского жука",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 66,
		"image_path": "res://assets/ui/shop/baits/lichinka_mayskogozhuka.png",
		"description": "Питательная крупная личинка для донной ловли.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.19,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"zhuk_plavunec": {
		"id": "zhuk_plavunec",
		"name": "Жук-плавунец",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 60,
		"image_path": "res://assets/ui/shop/baits/zhuk_plavunec.png",
		"description": "Водная животная наживка для заметной подачи.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.18,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"vipolzok": {
		"id": "vipolzok",
		"name": "Выползок",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 58,
		"image_path": "res://assets/ui/shop/baits/vipolzok.png",
		"description": "Крупный червь для глубокой и уверенной подачи.",
		"stats": {
			"bait_type": "worm",
			"fish_attraction": 0.19,
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	}
}

const ADDITIONAL_BAIT_CATALOG := {
	"fish_piece": {
		"id": "fish_piece",
		"name": "Живец",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 78,
		"image_path": "res://assets/ui/shop/baits/kusochki_ryby.png",
		"description": "Живая или свежая рыбная насадка для хищника и сомовой рыбы.",
		"stats": {
			"bait_type": "worm",
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare", "legendary"]
		}
	},
	"small_live_bait": {
		"id": "small_live_bait",
		"name": "Малёк",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 86,
		"image_path": "",
		"description": "Подвижная живая насадка для щуки, судака и крупного окуня.",
		"stats": {
			"bait_type": "worm",
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare", "legendary"]
		}
	},
	"frog_bait": {
		"id": "frog_bait",
		"name": "Лягушонок",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 82,
		"image_path": "",
		"description": "Крупная животная насадка для хищной рыбы и сома.",
		"stats": {
			"bait_type": "worm",
			"allowed_rarities": ["uncommon", "rare", "very_rare", "legendary"]
		}
	},
	"shrimp": {
		"id": "shrimp",
		"name": "Креветка",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 46,
		"image_path": "",
		"description": "Пахучая белковая насадка для окуня, судака и донной рыбы.",
		"stats": {
			"bait_type": "maggot",
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"snail": {
		"id": "snail",
		"name": "Улитка",
		"type": "bait",
		"category": "bait",
		"rarity": "uncommon",
		"price": 36,
		"image_path": "",
		"description": "Донная насадка для линя, леща, карася и осторожной рыбы у травы.",
		"stats": {
			"bait_type": "maggot",
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	"boilie_simple": {
		"id": "boilie_simple",
		"name": "Простой бойл",
		"type": "bait",
		"category": "bait",
		"rarity": "rare",
		"price": 74,
		"image_path": "",
		"description": "Плотная ароматная насадка для будущей карповой ловли и крупной мирной рыбы.",
		"stats": {
			"bait_type": "dough",
			"allowed_rarities": ["uncommon", "rare", "very_rare", "legendary"]
		}
	}
}

const BAIT_TARGET_PROFILES := {
	"worm": {"bait_tags": ["animal", "bottom", "universal"], "target_fish_ids": ["roach", "perch", "ruffe", "gudgeon", "crucian", "silver_crucian"], "secondary_fish_ids": ["rotan", "bream", "tench", "ide", "goby", "loach"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.14},
	"bread": {"bait_tags": ["plant", "surface", "soft"], "target_fish_ids": ["bleak", "topmouth_gudgeon", "roach", "rudd"], "secondary_fish_ids": ["silver_crucian", "golden_crucian", "crucian", "white_bream", "bream", "young_chub", "ide"], "fish_attraction": 0.03, "target_bonus": 0.24, "secondary_bonus": 0.12},
	"dough": {"bait_tags": ["plant", "soft", "sweet"], "target_fish_ids": ["crucian", "silver_crucian", "golden_crucian", "white_bream", "roach"], "secondary_fish_ids": ["bream", "skimmer_bream", "tench", "ide", "young_mirror_carp", "mist_carp"], "fish_attraction": 0.04, "target_bonus": 0.25, "secondary_bonus": 0.13},
	"maggot": {"bait_tags": ["animal", "larva", "active"], "target_fish_ids": ["bleak", "topmouth_gudgeon", "ruffe", "perch", "roach", "rudd"], "secondary_fish_ids": ["gudgeon", "rotan", "goby", "white_bream", "young_chub"], "fish_attraction": 0.04, "target_bonus": 0.25, "secondary_bonus": 0.13},
	"cherv_moskovskiy": {"bait_tags": ["animal", "worm", "bottom"], "target_fish_ids": ["roach", "perch", "ruffe", "gudgeon", "crucian", "silver_crucian"], "secondary_fish_ids": ["bream", "tench", "ide", "young_chub"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.14},
	"cherv_surskiy": {"bait_tags": ["animal", "worm", "river", "bottom"], "target_fish_ids": ["gudgeon", "ruffe", "perch", "bream", "skimmer_bream"], "secondary_fish_ids": ["roach", "crucian", "tench", "ide"], "fish_attraction": 0.04, "target_bonus": 0.27, "secondary_bonus": 0.14},
	"cherv_navozni": {"bait_tags": ["animal", "worm", "scent", "bottom"], "target_fish_ids": ["crucian", "silver_crucian", "golden_crucian", "tench", "bream"], "secondary_fish_ids": ["roach", "perch", "ruffe", "gudgeon"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.14},
	"cherv_astrahanskiy": {"bait_tags": ["animal", "worm", "large", "bottom"], "target_fish_ids": ["bream", "tench", "small_catfish", "catfish", "eel"], "secondary_fish_ids": ["perch", "pike", "zander", "young_pike"], "fish_attraction": 0.05, "target_bonus": 0.30, "secondary_bonus": 0.15},
	"cherv_volhovskiy": {"bait_tags": ["animal", "worm", "deep", "bottom"], "target_fish_ids": ["bream", "skimmer_bream", "tench", "eel", "small_catfish"], "secondary_fish_ids": ["ide", "perch", "zander", "moon_catfish"], "fish_attraction": 0.05, "target_bonus": 0.30, "secondary_bonus": 0.15},
	"cherv_leningradskiy": {"bait_tags": ["animal", "worm", "deep", "large"], "target_fish_ids": ["eel", "catfish", "small_catfish", "bream", "tench"], "secondary_fish_ids": ["zander", "pike", "young_pike", "moon_catfish"], "fish_attraction": 0.05, "target_bonus": 0.31, "secondary_bonus": 0.16},
	"vipolzok": {"bait_tags": ["animal", "worm", "large", "deep"], "target_fish_ids": ["catfish", "small_catfish", "eel", "bream", "moon_catfish"], "secondary_fish_ids": ["pike", "zander", "young_pike", "tench"], "fish_attraction": 0.05, "target_bonus": 0.31, "secondary_bonus": 0.16},
	"piyavka": {"bait_tags": ["animal", "leech", "predator", "deep"], "target_fish_ids": ["catfish", "eel", "pike", "zander", "small_catfish"], "secondary_fish_ids": ["perch", "moon_catfish", "water_turtle"], "fish_attraction": 0.05, "target_bonus": 0.31, "secondary_bonus": 0.16},
	"kaster": {"bait_tags": ["animal", "larva", "small_fish"], "target_fish_ids": ["roach", "bleak", "topmouth_gudgeon", "rudd", "white_bream"], "secondary_fish_ids": ["perch", "ruffe", "gudgeon"], "fish_attraction": 0.03, "target_bonus": 0.24, "secondary_bonus": 0.12},
	"motil": {"bait_tags": ["animal", "larva", "small_fish"], "target_fish_ids": ["bleak", "topmouth_gudgeon", "ruffe", "roach", "white_bream"], "secondary_fish_ids": ["perch", "gudgeon", "silver_crucian"], "fish_attraction": 0.03, "target_bonus": 0.24, "secondary_bonus": 0.12},
	"lichinka_podenki": {"bait_tags": ["animal", "larva", "river", "surface"], "target_fish_ids": ["rudd", "roach", "bleak", "topmouth_gudgeon", "young_chub"], "secondary_fish_ids": ["perch", "white_bream", "ide"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"podenka": {"bait_tags": ["animal", "insect", "surface"], "target_fish_ids": ["rudd", "young_chub", "ide", "bleak"], "secondary_fish_ids": ["roach", "topmouth_gudgeon", "perch"], "fish_attraction": 0.04, "target_bonus": 0.27, "secondary_bonus": 0.14},
	"lichinka_vesnyanki": {"bait_tags": ["animal", "larva", "river", "bottom"], "target_fish_ids": ["gudgeon", "ruffe", "perch", "young_chub", "ide"], "secondary_fish_ids": ["roach", "zander"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"rucheinik": {"bait_tags": ["animal", "larva", "river", "bottom"], "target_fish_ids": ["gudgeon", "ruffe", "perch", "young_chub", "ide"], "secondary_fish_ids": ["white_bream", "roach", "zander"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"lichinka_koroeda": {"bait_tags": ["animal", "larva", "wood", "surface"], "target_fish_ids": ["roach", "rudd", "young_chub", "ide"], "secondary_fish_ids": ["perch", "white_bream", "skimmer_bream"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"sverchok": {"bait_tags": ["animal", "insect", "surface"], "target_fish_ids": ["rudd", "young_chub", "ide", "perch"], "secondary_fish_ids": ["roach", "bleak", "topmouth_gudgeon"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"kuznechik": {"bait_tags": ["animal", "insect", "surface"], "target_fish_ids": ["rudd", "young_chub", "ide", "perch"], "secondary_fish_ids": ["roach", "bleak", "pike"], "fish_attraction": 0.04, "target_bonus": 0.27, "secondary_bonus": 0.14},
	"muha": {"bait_tags": ["animal", "insect", "surface", "small_fish"], "target_fish_ids": ["bleak", "topmouth_gudgeon", "rudd", "young_chub"], "secondary_fish_ids": ["roach", "perch"], "fish_attraction": 0.03, "target_bonus": 0.24, "secondary_bonus": 0.12},
	"maiskiy_zhuk": {"bait_tags": ["animal", "insect", "large", "surface"], "target_fish_ids": ["young_chub", "ide", "young_grass_carp", "rudd"], "secondary_fish_ids": ["perch", "pike", "young_pike"], "fish_attraction": 0.05, "target_bonus": 0.29, "secondary_bonus": 0.15},
	"zhuk_navozni": {"bait_tags": ["animal", "insect", "bottom"], "target_fish_ids": ["young_chub", "ide", "perch", "tench"], "secondary_fish_ids": ["bream", "small_catfish", "catfish"], "fish_attraction": 0.04, "target_bonus": 0.27, "secondary_bonus": 0.14},
	"medvedka": {"bait_tags": ["animal", "insect", "large", "bottom"], "target_fish_ids": ["catfish", "small_catfish", "bream", "tench", "young_mirror_carp"], "secondary_fish_ids": ["pike", "zander", "moon_catfish"], "fish_attraction": 0.05, "target_bonus": 0.30, "secondary_bonus": 0.15},
	"lichinka_mayskogozhuka": {"bait_tags": ["animal", "larva", "large", "bottom"], "target_fish_ids": ["tench", "bream", "young_mirror_carp", "young_grass_carp", "catfish"], "secondary_fish_ids": ["ide", "young_chub", "moon_catfish"], "fish_attraction": 0.05, "target_bonus": 0.30, "secondary_bonus": 0.15},
	"lichinka_zhukanosoroga": {"bait_tags": ["animal", "larva", "large", "bottom"], "target_fish_ids": ["tench", "bream", "young_mirror_carp", "catfish", "small_catfish"], "secondary_fish_ids": ["ide", "young_chub", "moon_catfish", "perch"], "fish_attraction": 0.05, "target_bonus": 0.30, "secondary_bonus": 0.15},
	"zhuk_plavunec": {"bait_tags": ["animal", "insect", "water", "predator"], "target_fish_ids": ["perch", "pike", "young_pike", "zander"], "secondary_fish_ids": ["catfish", "small_catfish", "frog"], "fish_attraction": 0.05, "target_bonus": 0.29, "secondary_bonus": 0.15},
	"ovod": {"bait_tags": ["animal", "insect", "surface"], "target_fish_ids": ["rudd", "young_chub", "ide", "perch"], "secondary_fish_ids": ["roach", "bleak", "topmouth_gudgeon"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"slepen": {"bait_tags": ["animal", "insect", "surface"], "target_fish_ids": ["rudd", "young_chub", "ide", "perch"], "secondary_fish_ids": ["roach", "bleak", "topmouth_gudgeon"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"bokoplav": {"bait_tags": ["animal", "crustacean", "bottom"], "target_fish_ids": ["perch", "ruffe", "goby", "gudgeon", "zander"], "secondary_fish_ids": ["roach", "young_chub", "ide"], "fish_attraction": 0.04, "target_bonus": 0.27, "secondary_bonus": 0.14},
	"myaso_dreiseni": {"bait_tags": ["animal", "shellfish", "bottom"], "target_fish_ids": ["bream", "skimmer_bream", "white_bream", "tench", "crucian"], "secondary_fish_ids": ["roach", "ruffe", "goby", "crayfish"], "fish_attraction": 0.04, "target_bonus": 0.27, "secondary_bonus": 0.14},
	"myaso_perlovici": {"bait_tags": ["animal", "shellfish", "bottom"], "target_fish_ids": ["bream", "tench", "skimmer_bream", "catfish", "small_catfish"], "secondary_fish_ids": ["crucian", "white_bream", "eel", "crayfish"], "fish_attraction": 0.04, "target_bonus": 0.28, "secondary_bonus": 0.14},
	"krabovoe_myaso": {"bait_tags": ["animal", "crustacean", "predator", "scent"], "target_fish_ids": ["catfish", "small_catfish", "zander", "perch", "pike"], "secondary_fish_ids": ["bream", "tench", "crayfish", "moon_catfish"], "fish_attraction": 0.05, "target_bonus": 0.30, "secondary_bonus": 0.15},
	"rakovaia_sheika": {"bait_tags": ["animal", "crustacean", "predator", "large"], "target_fish_ids": ["catfish", "small_catfish", "pike", "zander", "perch"], "secondary_fish_ids": ["eel", "moon_catfish", "water_turtle"], "fish_attraction": 0.05, "target_bonus": 0.31, "secondary_bonus": 0.16},
	"kusochki_ryby": {"bait_tags": ["animal", "fish", "predator", "scent"], "target_fish_ids": ["pike", "young_pike", "zander", "catfish", "small_catfish", "perch"], "secondary_fish_ids": ["eel", "moon_catfish"], "fish_attraction": 0.05, "target_bonus": 0.31, "secondary_bonus": 0.16},
	"ikra": {"bait_tags": ["animal", "egg", "scent", "small_fish"], "target_fish_ids": ["perch", "ruffe", "goby", "bleak", "roach"], "secondary_fish_ids": ["zander", "pike", "young_chub"], "fish_attraction": 0.05, "target_bonus": 0.28, "secondary_bonus": 0.14},
	"goroshek": {"bait_tags": ["plant", "grain", "soft"], "target_fish_ids": ["roach", "crucian", "silver_crucian", "golden_crucian", "white_bream"], "secondary_fish_ids": ["bream", "young_grass_carp", "ide"], "fish_attraction": 0.03, "target_bonus": 0.24, "secondary_bonus": 0.12},
	"zerna_phenici": {"bait_tags": ["plant", "grain"], "target_fish_ids": ["roach", "rudd", "white_bream", "crucian", "silver_crucian"], "secondary_fish_ids": ["bream", "young_grass_carp", "ide"], "fish_attraction": 0.03, "target_bonus": 0.24, "secondary_bonus": 0.12},
	"zerna_kukuruzi": {"bait_tags": ["plant", "grain", "corn", "sweet"], "target_fish_ids": ["crucian", "silver_crucian", "golden_crucian", "young_mirror_carp", "young_grass_carp"], "secondary_fish_ids": ["bream", "tench", "ide", "mist_carp"], "fish_attraction": 0.04, "target_bonus": 0.27, "secondary_bonus": 0.14},
	"kapustni_list": {"bait_tags": ["plant", "leaf", "grass"], "target_fish_ids": ["young_grass_carp", "rudd", "crucian"], "secondary_fish_ids": ["silver_crucian", "golden_crucian", "water_turtle"], "fish_attraction": 0.03, "target_bonus": 0.23, "secondary_bonus": 0.11},
	"puchok_vodorosley": {"bait_tags": ["plant", "algae", "grass"], "target_fish_ids": ["young_grass_carp", "rudd", "water_turtle"], "secondary_fish_ids": ["crucian", "silver_crucian", "golden_crucian"], "fish_attraction": 0.03, "target_bonus": 0.24, "secondary_bonus": 0.12},
	"kartofelniy_kubik": {"bait_tags": ["plant", "vegetable", "bottom"], "target_fish_ids": ["crucian", "silver_crucian", "golden_crucian", "young_mirror_carp"], "secondary_fish_ids": ["bream", "tench", "young_grass_carp"], "fish_attraction": 0.03, "target_bonus": 0.24, "secondary_bonus": 0.12},
	"ovsyanaya_kasha": {"bait_tags": ["plant", "porridge", "soft"], "target_fish_ids": ["crucian", "silver_crucian", "roach", "white_bream"], "secondary_fish_ids": ["bream", "skimmer_bream", "golden_crucian"], "fish_attraction": 0.03, "target_bonus": 0.24, "secondary_bonus": 0.12},
	"mannaya_kasha": {"bait_tags": ["plant", "porridge", "soft"], "target_fish_ids": ["crucian", "silver_crucian", "golden_crucian", "roach"], "secondary_fish_ids": ["white_bream", "skimmer_bream", "bream"], "fish_attraction": 0.03, "target_bonus": 0.24, "secondary_bonus": 0.12},
	"gorohovaya_kasha": {"bait_tags": ["plant", "porridge", "pea", "bottom"], "target_fish_ids": ["bream", "skimmer_bream", "crucian", "silver_crucian", "young_grass_carp"], "secondary_fish_ids": ["tench", "ide", "young_mirror_carp"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"kukuruznaya_kasha": {"bait_tags": ["plant", "porridge", "corn", "sweet"], "target_fish_ids": ["crucian", "golden_crucian", "young_mirror_carp", "young_grass_carp"], "secondary_fish_ids": ["bream", "tench", "ide"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"perlovaya_kasha": {"bait_tags": ["plant", "porridge", "grain"], "target_fish_ids": ["roach", "crucian", "silver_crucian", "golden_crucian", "white_bream"], "secondary_fish_ids": ["bream", "skimmer_bream", "tench"], "fish_attraction": 0.03, "target_bonus": 0.24, "secondary_bonus": 0.12},
	"sladkoe_testo": {"bait_tags": ["plant", "dough", "sweet"], "target_fish_ids": ["crucian", "silver_crucian", "golden_crucian", "roach", "rudd"], "secondary_fish_ids": ["white_bream", "bream", "young_mirror_carp"], "fish_attraction": 0.04, "target_bonus": 0.25, "secondary_bonus": 0.13},
	"chesnochnoye_testo": {"bait_tags": ["plant", "dough", "garlic", "scent"], "target_fish_ids": ["bream", "skimmer_bream", "crucian", "silver_crucian"], "secondary_fish_ids": ["tench", "roach", "golden_crucian"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"yaichonoe_testo": {"bait_tags": ["plant", "dough", "protein"], "target_fish_ids": ["crucian", "silver_crucian", "golden_crucian", "bream"], "secondary_fish_ids": ["roach", "white_bream", "tench", "young_mirror_carp"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"tvorozhnoye_testo": {"bait_tags": ["plant", "dough", "dairy", "scent"], "target_fish_ids": ["bream", "skimmer_bream", "crucian", "silver_crucian", "golden_crucian"], "secondary_fish_ids": ["tench", "roach", "white_bream"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"medovoye_testo": {"bait_tags": ["plant", "dough", "honey", "sweet"], "target_fish_ids": ["crucian", "silver_crucian", "golden_crucian", "tench"], "secondary_fish_ids": ["bream", "skimmer_bream", "young_mirror_carp", "mist_carp"], "fish_attraction": 0.04, "target_bonus": 0.27, "secondary_bonus": 0.14},
	"syrni_kubik": {"bait_tags": ["dairy", "scent", "bottom"], "target_fish_ids": ["young_chub", "ide", "bream", "tench"], "secondary_fish_ids": ["crucian", "roach", "young_mirror_carp"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"fish_piece": {"bait_tags": ["animal", "fish", "live_bait", "predator"], "target_fish_ids": ["pike", "young_pike", "zander", "catfish", "small_catfish", "perch", "eel"], "secondary_fish_ids": ["moon_catfish", "goby"], "fish_attraction": 0.05, "target_bonus": 0.32, "secondary_bonus": 0.16},
	"small_live_bait": {"bait_tags": ["animal", "fish", "live_bait", "predator"], "target_fish_ids": ["pike", "young_pike", "zander", "perch", "catfish"], "secondary_fish_ids": ["small_catfish", "eel", "moon_catfish"], "fish_attraction": 0.05, "target_bonus": 0.33, "secondary_bonus": 0.16},
	"frog_bait": {"bait_tags": ["animal", "frog", "predator", "surface"], "target_fish_ids": ["pike", "catfish", "small_catfish", "zander"], "secondary_fish_ids": ["young_pike", "moon_catfish", "water_turtle"], "fish_attraction": 0.05, "target_bonus": 0.31, "secondary_bonus": 0.16},
	"shrimp": {"bait_tags": ["animal", "crustacean", "scent", "bottom"], "target_fish_ids": ["perch", "zander", "catfish", "goby", "crayfish"], "secondary_fish_ids": ["small_catfish", "bream", "ruffe"], "fish_attraction": 0.04, "target_bonus": 0.27, "secondary_bonus": 0.14},
	"snail": {"bait_tags": ["animal", "shellfish", "bottom"], "target_fish_ids": ["tench", "bream", "skimmer_bream", "crucian", "water_turtle"], "secondary_fish_ids": ["silver_crucian", "golden_crucian", "crayfish"], "fish_attraction": 0.04, "target_bonus": 0.26, "secondary_bonus": 0.13},
	"boilie_simple": {"bait_tags": ["plant", "boilie", "carp", "bottom"], "target_fish_ids": ["young_mirror_carp", "mist_carp", "bream", "tench"], "secondary_fish_ids": ["crucian", "silver_crucian", "young_grass_carp"], "fish_attraction": 0.05, "target_bonus": 0.29, "secondary_bonus": 0.15}
}
const TACKLE_SLOTS := ["rod", "line", "leader", "hook", "float", "bait", "bait_2"]
const REQUIRED_TACKLE_SLOTS := ["rod", "line", "hook", "float", "bait"]
const TACKLE_SLOT_ITEM_CATEGORIES := {
	"rod": "rod",
	"line": "line",
	"leader": "leader",
	"hook": "hook",
	"float": "float",
	"bait": "bait",
	"bait_2": "bait"
}
const RESCUE_KIT_MONEY_LIMIT := 10.0
const RESCUE_KIT_LINE_ID := "lakeline_nylon_basic_1_5kg"
const RESCUE_KIT_PRIMARY_HOOK_ID := "riverstart_basic_hook_16"
const RESCUE_KIT_FALLBACK_HOOK_ID := "small_hook_12"
const REPAIR_COST_MULTIPLIER := 0.35
const REPAIR_BLOCK_WEAR_PERCENT := 90
const BROKEN_WEAR_PERCENT := 100

var money: float = 0.0
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 175
var skill_points: int = 0
var learned_skills: Dictionary = {}
var player_name: String = "Рыбак"
var current_waterbody: String = "agamin_lake"
var unlocked_waterbodies: Array = ["agamin_lake"]
var current_spot: String = "old_oak_pier"
var unlocked_spots: Array = ["old_oak_pier"]
var upgrades: Array = []
var fishing_depth: float = 1.2
var owned_items: Array = get_default_owned_items()
var current_tackle: Dictionary = get_default_tackle()
var total_fish_caught := 0
var total_fish_weight: float = 0.0
var total_trophies_caught := 0
var total_rarity_caught := 0
var biggest_fish := {}
var biggest_fish_by_species := {}
var trophy_catches := []
var personal_records := {}
var rescue_kit_claims_total := 0
var rescue_kit_last_claim_day := -1

func format_money_amount(value: float) -> String:
	var rounded_value: float = round(value * 100.0) / 100.0

	if abs(rounded_value - round(rounded_value)) < 0.005:
		return "%d" % int(round(rounded_value))
	if abs(rounded_value * 10.0 - round(rounded_value * 10.0)) < 0.005:
		return "%.1f" % rounded_value
	return "%.2f" % rounded_value

func format_money(value: float, suffix: String = "мон.") -> String:
	return "%s %s" % [format_money_amount(value), suffix]

func format_hook_size(size: int) -> String:
	if size <= 0:
		return "%d/0" % (1 - size)
	return "%d" % size

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
		skill_points += levels_gained
		refresh_waterbody_unlocks()

	return {
		"gained_xp": gained_xp,
		"levels_gained": levels_gained,
		"leveled_up": levels_gained > 0,
		"level": level,
		"current_xp": current_xp,
		"xp_to_next_level": xp_to_next_level
	}

func register_catch_stats(catch_data: Dictionary) -> void:
	if catch_data.is_empty():
		return

	if bool(catch_data.get("stats_registered", false)):
		return

	if not catch_data.has("previous_species_record_weight"):
		var prepared := prepare_record_info(catch_data)
		catch_data.clear()
		catch_data.merge(prepared, true)

	var fish_id := str(catch_data.get("id", ""))
	var weight := float(catch_data.get("weight", 0.0))
	var catch_rank := str(catch_data.get("catch_rank", "normal"))
	var is_new_personal_record := bool(catch_data.get("is_new_personal_record", biggest_fish.is_empty() or weight > float(biggest_fish.get("weight", 0.0))))
	var is_new_species_record := bool(catch_data.get("is_new_species_record", fish_id != "" and (not biggest_fish_by_species.has(fish_id) or weight > float(biggest_fish_by_species[fish_id].get("weight", 0.0)))))

	catch_data["is_new_personal_record"] = is_new_personal_record
	catch_data["is_new_species_record"] = is_new_species_record
	_fill_catch_record_context(catch_data)

	total_fish_caught += 1
	total_fish_weight = snappedf(total_fish_weight + weight, 0.01)

	var record_entry := _build_catch_record_entry(catch_data)
	if catch_rank == "trophy":
		total_trophies_caught += 1
		trophy_catches.append(record_entry.duplicate(true))
	elif catch_rank == "rarity":
		total_trophies_caught += 1
		total_rarity_caught += 1
		trophy_catches.append(record_entry.duplicate(true))

	if trophy_catches.size() > 60:
		trophy_catches = trophy_catches.slice(trophy_catches.size() - 60)

	if is_new_personal_record:
		biggest_fish = record_entry.duplicate(true)

	if is_new_species_record:
		biggest_fish_by_species[fish_id] = record_entry.duplicate(true)
		personal_records[fish_id] = record_entry.duplicate(true)
	catch_data["stats_registered"] = true

func prepare_record_info(catch_data: Dictionary) -> Dictionary:
	var result := catch_data.duplicate(true)
	var fish_id := str(result.get("id", ""))
	var current_weight := float(result.get("weight", 0.0))

	var previous_record := {}
	if personal_records.has(fish_id):
		previous_record = personal_records[fish_id].duplicate(true)

	var previous_weight := float(previous_record.get("weight", 0.0))
	result["previous_species_record_weight"] = previous_weight
	result["previous_species_record_name"] = str(previous_record.get("name", previous_record.get("fish_name", "")))
	result["previous_species_record_length_cm"] = float(previous_record.get("length_cm", 0.0))
	result["previous_species_record_catch_rank"] = str(previous_record.get("catch_rank", "normal"))
	result["is_new_species_record"] = previous_weight <= 0.0 or current_weight > previous_weight
	result["is_new_personal_record"] = biggest_fish.is_empty() or current_weight > float(biggest_fish.get("weight", 0.0))
	_fill_catch_record_context(result)
	return result

func get_catch_stats_save_data() -> Dictionary:
	return {
		"player_name": player_name,
		"total_fish_caught": total_fish_caught,
		"total_fish_weight": total_fish_weight,
		"total_trophies_caught": total_trophies_caught,
		"total_rarity_caught": total_rarity_caught,
		"biggest_fish": biggest_fish.duplicate(true),
		"biggest_fish_by_species": biggest_fish_by_species.duplicate(true),
		"trophy_catches": trophy_catches.duplicate(true),
		"personal_records": personal_records.duplicate(true)
	}

func set_catch_stats_from_save(save_data: Dictionary) -> void:
	player_name = str(save_data.get("player_name", player_name))
	total_fish_caught = max(int(save_data.get("total_fish_caught", 0)), 0)
	total_fish_weight = max(float(save_data.get("total_fish_weight", 0.0)), 0.0)
	total_trophies_caught = max(int(save_data.get("total_trophies_caught", 0)), 0)
	total_rarity_caught = max(int(save_data.get("total_rarity_caught", 0)), 0)
	biggest_fish = _safe_saved_dictionary(save_data.get("biggest_fish", {}))
	biggest_fish_by_species = _safe_saved_dictionary(save_data.get("biggest_fish_by_species", {}))
	trophy_catches = _safe_saved_array(save_data.get("trophy_catches", []))
	personal_records = _safe_saved_dictionary(save_data.get("personal_records", {}))

func has_caught_species(fish_id: String) -> bool:
	return personal_records.has(fish_id) or biggest_fish_by_species.has(fish_id)

func _fill_catch_record_context(catch_data: Dictionary) -> void:
	var spot := SpotDatabase.get_spot(str(catch_data.get("spot_id", current_spot)))
	if spot.is_empty():
		spot = SpotDatabase.get_spot(current_spot)

	var spot_id := str(spot.get("id", catch_data.get("spot_id", current_spot)))
	var waterbody_id := str(spot.get("waterbody_id", catch_data.get("waterbody_id", current_waterbody)))
	var waterbody := _get_waterbody(waterbody_id)
	var spot_name := str(catch_data.get("spot_name", ""))
	if spot_name == "":
		spot_name = str(spot.get("name", "-"))
	var waterbody_name := str(catch_data.get("waterbody_name", ""))
	if waterbody_name == "":
		waterbody_name = str(waterbody.get("name", "-"))

	catch_data["spot_id"] = spot_id
	catch_data["spot_name"] = spot_name
	catch_data["waterbody_id"] = waterbody_id
	catch_data["waterbody_name"] = waterbody_name
	catch_data["bait"] = str(catch_data.get("bait", current_tackle.get("bait", {}).get("name", "-")))
	catch_data["tackle_summary"] = str(catch_data.get("tackle_summary", _get_record_tackle_summary()))
	catch_data["caught_at"] = str(catch_data.get("caught_at", _get_record_caught_at()))

func _build_catch_record_entry(catch_data: Dictionary) -> Dictionary:
	var fish_id := str(catch_data.get("id", ""))
	var fish_name := str(catch_data.get("name", "-"))
	var fish_rarity := str(catch_data.get("rarity", "common"))

	return {
		"player_name": player_name,
		"fish_id": fish_id,
		"id": fish_id,
		"fish_name": fish_name,
		"name": fish_name,
		"weight": float(catch_data.get("weight", 0.0)),
		"length_cm": float(catch_data.get("length_cm", 0.0)),
		"price": int(catch_data.get("price", 0)),
		"fish_rarity": fish_rarity,
		"rarity": fish_rarity,
		"catch_rank": str(catch_data.get("catch_rank", "normal")),
		"is_trophy": bool(catch_data.get("is_trophy", false)),
		"is_rarity": bool(catch_data.get("is_rarity", false)),
		"is_new_personal_record": bool(catch_data.get("is_new_personal_record", false)),
		"is_new_species_record": bool(catch_data.get("is_new_species_record", false)),
		"spot_id": str(catch_data.get("spot_id", "")),
		"spot_name": str(catch_data.get("spot_name", "-")),
		"waterbody_id": str(catch_data.get("waterbody_id", "")),
		"waterbody_name": str(catch_data.get("waterbody_name", "-")),
		"bait": str(catch_data.get("bait", "-")),
		"tackle_summary": str(catch_data.get("tackle_summary", "-")),
		"caught_at": str(catch_data.get("caught_at", ""))
	}

func _get_record_tackle_summary() -> String:
	return "%s | %s | %s | %s" % [
		str(current_tackle.get("rod", {}).get("name", "-")),
		str(current_tackle.get("line", {}).get("name", "-")),
		str(current_tackle.get("float", {}).get("name", "-")),
		str(current_tackle.get("hook", {}).get("name", "-"))
	]

func _get_record_caught_at() -> String:
	var time_manager := get_node_or_null("/root/TimeManager")
	if time_manager != null:
		var minutes := int(time_manager.get("current_game_minutes"))
		var day := int(time_manager.get("day_index"))
		var hour := int(minutes / 60)
		var minute := minutes % 60
		return "День %d, %02d:%02d" % [day, hour, minute]

	return Time.get_datetime_string_from_system(false, true)

func _safe_saved_dictionary(value) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return value.duplicate(true)
	return {}

func _safe_saved_array(value) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return value.duplicate(true)
	return []

func _get_skill_database() -> Node:
	return get_node_or_null("/root/SkillDatabase")

func set_progression(saved_level: int, saved_xp: int) -> void:
	level = max(saved_level, 1)
	xp_to_next_level = get_xp_to_next_level(level)
	current_xp = max(saved_xp, 0)

	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		level += 1
		xp_to_next_level = get_xp_to_next_level(level)

	refresh_waterbody_unlocks()

func has_skill(skill_id: String) -> bool:
	return bool(learned_skills.get(skill_id, false))

func can_learn_skill(skill_id: String) -> Dictionary:
	var skill_database := _get_skill_database()
	if skill_database == null or not skill_database.has_method("get_skill"):
		return {
			"success": false,
			"can_learn": false,
			"reason": "База навыков недоступна."
		}

	var skill: Dictionary = skill_database.call("get_skill", skill_id)
	if skill.is_empty():
		return {
			"success": false,
			"can_learn": false,
			"reason": "Навык не найден."
		}

	if has_skill(skill_id):
		return {
			"success": false,
			"can_learn": false,
			"reason": "Навык уже изучен."
		}

	var cost: int = max(int(skill.get("cost", 0)), 0)
	if skill_points < cost:
		return {
			"success": false,
			"can_learn": false,
			"reason": "Недостаточно очков навыков."
		}

	for required_id in skill.get("requires", []):
		if not has_skill(str(required_id)):
			return {
				"success": false,
				"can_learn": false,
				"reason": "Сначала изучите предыдущий навык."
			}

	return {
		"success": true,
		"can_learn": true,
		"reason": ""
	}

func learn_skill(skill_id: String) -> Dictionary:
	var check := can_learn_skill(skill_id)
	if not bool(check.get("can_learn", false)):
		return check

	var skill_database := _get_skill_database()
	var skill: Dictionary = skill_database.call("get_skill", skill_id)
	var cost: int = max(int(skill.get("cost", 0)), 0)
	skill_points = max(skill_points - cost, 0)
	learned_skills[skill_id] = true

	return {
		"success": true,
		"can_learn": true,
		"reason": "Навык изучен."
	}

func get_skill_effects() -> Dictionary:
	var result := {}
	var skill_database := _get_skill_database()
	if skill_database == null or not skill_database.has_method("get_skill"):
		return result

	for skill_id in learned_skills.keys():
		if not bool(learned_skills.get(skill_id, false)):
			continue

		var skill: Dictionary = skill_database.call("get_skill", str(skill_id))
		if skill.is_empty():
			continue

		var effects: Dictionary = skill.get("effects", {})
		for effect_id in effects.keys():
			result[effect_id] = float(result.get(effect_id, 0.0)) + float(effects[effect_id])

	return result

func get_skill_effect_value(effect_id: String) -> float:
	return float(get_skill_effects().get(effect_id, 0.0))

func get_sell_price_multiplier() -> float:
	return max(1.0 + get_skill_effect_value("sell_price_bonus"), 0.0)

func get_skill_adjusted_sell_price(base_price: int) -> int:
	return max(roundi(float(max(base_price, 0)) * get_sell_price_multiplier()), 0)

func set_skill_state(saved_skill_points: int, saved_learned_skills) -> void:
	skill_points = max(saved_skill_points, 0)
	learned_skills = {}

	var skill_database := _get_skill_database()
	var saved_ids: Array = []

	if typeof(saved_learned_skills) == TYPE_DICTIONARY:
		for skill_id in saved_learned_skills.keys():
			if bool(saved_learned_skills.get(skill_id, false)):
				saved_ids.append(str(skill_id))
	elif typeof(saved_learned_skills) == TYPE_ARRAY:
		for skill_id in saved_learned_skills:
			saved_ids.append(str(skill_id))

	for skill_id in saved_ids:
		if skill_id.is_empty():
			continue
		if skill_database != null and skill_database.has_method("has_skill") and not bool(skill_database.call("has_skill", skill_id)):
			continue
		learned_skills[skill_id] = true

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

func _get_raw_tackle_catalog_item(item_id: String) -> Dictionary:
	if TACKLE_CATALOG.has(item_id):
		return TACKLE_CATALOG[item_id]
	if ADDITIONAL_BAIT_CATALOG.has(item_id):
		return ADDITIONAL_BAIT_CATALOG[item_id]
	return {}

func _normalize_catalog_item(item: Dictionary) -> Dictionary:
	if item.is_empty():
		return {}

	var normalized := item.duplicate(true)
	var item_id := str(normalized.get("id", ""))
	var category := str(normalized.get("category", normalized.get("type", "misc")))
	if category == "bait":
		var stats: Dictionary = normalized.get("stats", {}).duplicate(true) if typeof(normalized.get("stats", {})) == TYPE_DICTIONARY else {}
		normalized["stats"] = _normalize_equipment_stats(stats, "bait", item_id)

	return normalized

func get_tackle_catalog_item(item_id: String) -> Dictionary:
	var item: Dictionary = _get_raw_tackle_catalog_item(item_id)

	if item.is_empty():
		return {}

	return _normalize_catalog_item(item)

func get_tackle_catalog_items(type_filter: String = "all") -> Array:
	var items: Array = []

	for catalog in [TACKLE_CATALOG, ADDITIONAL_BAIT_CATALOG]:
		for item_id in catalog.keys():
			var item: Dictionary = _normalize_catalog_item(catalog[item_id])
			var item_type := str(item.get("type", item.get("category", "misc")))

			if type_filter == "all" or item_type == type_filter:
				items.append(item)

	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var category_order := {"rod": 0, "line": 1, "leader": 2, "hook": 3, "float": 4, "bait": 5}
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
		"basic_mono_leader_1kg": true,
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
	component = _normalize_equipment_stats(component, category, item_id)
	component["id"] = item["id"]
	component["name"] = item["name"]
	component["type"] = item_type
	component["category"] = category
	component["rarity"] = item.get("rarity", "common")
	component["price"] = float(item.get("price", 0.0))
	component["image_path"] = str(item.get("image_path", ""))
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
		"leader":
			return "P"
		"float":
			return "F"
		"hook":
			return "H"
		"bait":
			return "B"
		_:
			return "?"

func _normalize_equipment_stats(stats: Dictionary, category: String, item_id: String = "") -> Dictionary:
	var normalized := stats.duplicate(true)

	match category:
		"rod":
			if not normalized.has("length_m"):
				normalized["length_m"] = 4.0
			if not normalized.has("rod_class"):
				normalized["rod_class"] = _get_default_rod_class(float(normalized["length_m"]))
			if not normalized.has("control_bonus"):
				normalized["control_bonus"] = float(normalized.get("tension_bonus", 0.0))
			if not normalized.has("tension_bonus"):
				normalized["tension_bonus"] = float(normalized.get("control_bonus", 0.0))
			if not normalized.has("reach_bonus"):
				normalized["reach_bonus"] = _get_default_rod_reach_bonus(float(normalized["length_m"]))
			if not normalized.has("handling_bonus"):
				normalized["handling_bonus"] = _get_default_rod_handling_bonus(float(normalized["length_m"]), str(normalized["rod_class"]))
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
			normalized["length_m"] = clamp(float(normalized["length_m"]), 2.7, 7.2)
			normalized["reach_bonus"] = clamp(float(normalized["reach_bonus"]), -0.06, 0.22)
			normalized["handling_bonus"] = clamp(float(normalized["handling_bonus"]), -0.08, 0.08)
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
		"leader":
			if not normalized.has("leader_type"):
				normalized["leader_type"] = "mono"
			if not normalized.has("strength"):
				normalized["strength"] = 1.0
			if not normalized.has("visibility"):
				normalized["visibility"] = 0.05
			if not normalized.has("bite_protection"):
				normalized["bite_protection"] = 0.0
			if not normalized.has("durability"):
				normalized["durability"] = 1.0
			if not normalized.has("wear_rate"):
				normalized["wear_rate"] = 0.020
			normalized["strength"] = max(float(normalized["strength"]), 0.05)
			normalized["visibility"] = clamp(float(normalized["visibility"]), 0.0, 0.45)
			normalized["bite_protection"] = clamp(float(normalized["bite_protection"]), 0.0, 0.30)
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
		"bait":
			var bait_id := item_id
			if bait_id == "":
				bait_id = str(normalized.get("id", normalized.get("bait_id", "")))
			normalized = _apply_bait_target_profile(normalized, bait_id)

	return normalized

func _apply_bait_target_profile(stats: Dictionary, bait_id: String) -> Dictionary:
	var normalized := stats.duplicate(true)
	if bait_id != "":
		normalized["bait_id"] = bait_id
	if not normalized.has("bait_type"):
		normalized["bait_type"] = "worm"

	var profile: Dictionary = BAIT_TARGET_PROFILES.get(bait_id, {})
	if profile.is_empty():
		if not normalized.has("bait_tags"):
			normalized["bait_tags"] = []
		if not normalized.has("target_fish_ids"):
			normalized["target_fish_ids"] = []
		if not normalized.has("secondary_fish_ids"):
			normalized["secondary_fish_ids"] = []
		if not normalized.has("fish_attraction_by_id"):
			normalized["fish_attraction_by_id"] = {}
		normalized["fish_attraction"] = clamp(float(normalized.get("fish_attraction", 0.03)), 0.0, 0.08)
		return normalized

	var target_fish_ids: Array = _to_string_array(profile.get("target_fish_ids", []))
	var secondary_fish_ids: Array = _to_string_array(profile.get("secondary_fish_ids", []))

	for fish_id in target_fish_ids:
		secondary_fish_ids.erase(str(fish_id))

	normalized["bait_tags"] = _to_string_array(profile.get("bait_tags", []))
	normalized["target_fish_ids"] = target_fish_ids
	normalized["secondary_fish_ids"] = secondary_fish_ids
	normalized["fish_attraction"] = clamp(float(profile.get("fish_attraction", normalized.get("fish_attraction", 0.03))), 0.0, 0.08)
	normalized["fish_attraction_by_id"] = _build_bait_attraction_by_id(profile, target_fish_ids, secondary_fish_ids)
	return normalized

func _build_bait_attraction_by_id(profile: Dictionary, target_fish_ids: Array, secondary_fish_ids: Array) -> Dictionary:
	var attraction: Dictionary = {}
	var explicit = profile.get("fish_attraction_by_id", {})
	if typeof(explicit) == TYPE_DICTIONARY:
		for fish_id in explicit.keys():
			attraction[str(fish_id)] = clamp(float(explicit[fish_id]), 0.0, 0.42)

	var target_bonus: float = float(profile.get("target_bonus", 0.24))
	for i in range(target_fish_ids.size()):
		var fish_id := str(target_fish_ids[i])
		var bonus: float = clamp(target_bonus - float(min(i, 4)) * 0.01, 0.20, 0.34)
		attraction[fish_id] = max(float(attraction.get(fish_id, 0.0)), bonus)

	var secondary_bonus: float = float(profile.get("secondary_bonus", 0.12))
	for i in range(secondary_fish_ids.size()):
		var fish_id := str(secondary_fish_ids[i])
		var bonus: float = clamp(secondary_bonus - float(min(i, 4)) * 0.005, 0.08, 0.18)
		attraction[fish_id] = max(float(attraction.get(fish_id, 0.0)), bonus)

	return attraction

func _to_string_array(value) -> Array:
	var result: Array = []
	if typeof(value) != TYPE_ARRAY:
		return result

	for entry in value:
		var text := str(entry)
		if text != "" and not result.has(text):
			result.append(text)

	return result

func _merge_unique_string_arrays(base: Array, extra: Array) -> Array:
	var merged: Array = _to_string_array(base)
	for entry in extra:
		var text := str(entry)
		if text != "" and not merged.has(text):
			merged.append(text)
	return merged

func _get_default_rod_class(length_m: float) -> String:
	if length_m <= 3.8:
		return "ultra_light"
	if length_m <= 4.6:
		return "light"
	if length_m <= 5.2:
		return "medium"
	if length_m <= 5.8:
		return "universal"
	return "heavy"

func _get_default_rod_reach_bonus(length_m: float) -> float:
	return clamp((length_m - 4.0) * 0.045, -0.04, 0.18)

func _get_default_rod_handling_bonus(length_m: float, rod_class: String) -> float:
	var class_bonus := 0.0
	match rod_class:
		"ultra_light":
			class_bonus = 0.035
		"light":
			class_bonus = 0.020
		"medium":
			class_bonus = 0.005
		"extra_heavy":
			class_bonus = -0.030
		"heavy":
			class_bonus = -0.020
		_:
			class_bonus = 0.0
	return clamp(class_bonus - max(length_m - 5.2, 0.0) * 0.018, -0.06, 0.06)

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
	stats = _normalize_equipment_stats(stats, category, item_id)

	return {
		"id": item_id,
		"name": str(item.get("name", catalog_item.get("name", "-"))),
		"type": item_type,
		"category": category,
		"rarity": str(item.get("rarity", catalog_item.get("rarity", "common"))),
		"price": float(item.get("price", catalog_item.get("price", 0.0))),
		"quantity": max(int(item.get("quantity", 1)), 0),
		"image_path": str(item.get("image_path", catalog_item.get("image_path", ""))),
		"description": str(item.get("description", catalog_item.get("description", ""))),
		"stats": stats
	}

func get_default_tackle() -> Dictionary:
	return {
		"rod": _make_tackle_component("simple_pole_rod_4m"),
		"line": _make_tackle_component("mono_1_2kg"),
		"leader": {},
		"hook": _make_tackle_component("small_hook_12"),
		"float": _make_tackle_component("light_float"),
		"bait": _make_tackle_component("worm"),
		"bait_2": {}
	}

func get_default_owned_items() -> Array:
	return [
		_make_owned_catalog_item("simple_pole_rod_4m", 1),
		_make_owned_catalog_item("mono_1_2kg", 1),
		_make_owned_catalog_item("basic_mono_leader_1kg", 1),
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

		var slot_category := _get_tackle_slot_item_category(slot)
		var merged_component: Dictionary = current_tackle[slot].duplicate(true)
		merged_component.merge(saved_component, true)
		if str(merged_component.get("id", "")) == "":
			current_tackle[slot] = {}
			continue
		merged_component["slot"] = slot
		merged_component["type"] = slot_category
		merged_component["category"] = slot_category

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

		merged_component = _normalize_equipment_stats(merged_component, slot_category, str(merged_component.get("id", "")))
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

func _get_tackle_slot_item_category(slot_id: String) -> String:
	return str(TACKLE_SLOT_ITEM_CATEGORIES.get(slot_id, slot_id))

func is_tackle_slot_supported(slot_id: String) -> bool:
	return TACKLE_SLOTS.has(slot_id)

func can_use_second_bait() -> bool:
	return get_skill_effect_value("second_bait_slot") > 0.0 or has_skill("bait_sandwich")

func get_current_tackle_slot(slot_id: String) -> Dictionary:
	if not current_tackle.has(slot_id):
		return {}

	var raw_component = current_tackle.get(slot_id, {})
	if typeof(raw_component) != TYPE_DICTIONARY:
		return {}

	return raw_component.duplicate(true)

func set_current_tackle_slot(slot_id: String, item: Dictionary) -> bool:
	if not is_tackle_slot_supported(slot_id):
		return false
	if slot_id == "bait_2" and not can_use_second_bait():
		return false
	if item.is_empty() or not can_equip_item(item):
		return false

	var slot_category := _get_tackle_slot_item_category(slot_id)
	var item_category := str(item.get("category", item.get("type", "")))
	if item_category != slot_category:
		return false

	var component: Dictionary = _normalize_equipment_stats(item.get("stats", {}).duplicate(true), slot_category, str(item.get("id", "")))
	component["id"] = str(item.get("id", ""))
	component["name"] = str(item.get("name", "-"))
	component["type"] = str(item.get("type", slot_category))
	component["category"] = item_category
	component["slot"] = slot_id
	component["rarity"] = str(item.get("rarity", "common"))
	component["price"] = float(item.get("price", 0.0))
	component["image_path"] = str(item.get("image_path", ""))
	component["description"] = str(item.get("description", ""))

	if slot_category == "bait":
		component["quantity"] = int(item.get("quantity", 0))

	current_tackle[slot_id] = component
	return true

func clear_current_tackle_slot(slot_id: String) -> void:
	if not is_tackle_slot_supported(slot_id):
		return
	current_tackle[slot_id] = {}

func can_equip_item(item: Dictionary) -> bool:
	return get_equip_block_reason(item) == ""

func get_equip_block_reason(item: Dictionary, slot_type: String = "") -> String:
	if item.is_empty():
		return "Предмет не выбран."

	var category := str(item.get("category", ""))
	if slot_type != "":
		if slot_type == "bait_2" and not can_use_second_bait():
			return "Нужен навык «Бутерброд»."
		var expected_category := _get_tackle_slot_item_category(slot_type)
		if category != expected_category:
			return "Не подходит к этой снасти."

	if not TACKLE_SLOT_ITEM_CATEGORIES.values().has(category):
		return "Не подходит к этой снасти."

	if _is_durable_tackle_category(category):
		var wear_percent := get_item_wear_percent(item)
		if wear_percent >= BROKEN_WEAR_PERCENT:
			return "Предмет сломан."
		if wear_percent >= REPAIR_BLOCK_WEAR_PERCENT:
			return "%s требует ремонта." % _get_tackle_slot_title(category)

	if int(item.get("quantity", 0)) <= 0:
		if category == "bait":
			return "Наживка закончилась."
		return "Предмет отсутствует."

	return ""

func is_item_repairable(item: Dictionary) -> bool:
	if item.is_empty():
		return false
	var category := str(item.get("category", ""))
	if not _is_durable_tackle_category(category):
		return false
	var wear_percent := get_item_wear_percent(item)
	return wear_percent > 0 and wear_percent < BROKEN_WEAR_PERCENT

func can_discard_item(item: Dictionary) -> bool:
	return not item.is_empty() and _is_durable_tackle_category(str(item.get("category", ""))) and get_item_wear_percent(item) >= BROKEN_WEAR_PERCENT

func get_item_wear_percent(item: Dictionary) -> int:
	if item.is_empty():
		return 0
	var category := str(item.get("category", ""))
	if not _is_durable_tackle_category(category):
		return 0
	var stats: Dictionary = item.get("stats", {}) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}
	var durability: float = clamp(float(stats.get("durability", item.get("durability", 1.0))), 0.0, 1.0)
	return clampi(roundi((1.0 - durability) * 100.0), 0, 100)

func get_item_condition_title(item: Dictionary) -> String:
	var wear_percent := get_item_wear_percent(item)
	if wear_percent >= BROKEN_WEAR_PERCENT:
		return "Сломана"
	if wear_percent >= REPAIR_BLOCK_WEAR_PERCENT:
		return "Требует ремонта"
	if wear_percent >= 65:
		return "Сильно изношена"
	if wear_percent >= 30:
		return "Изношена"
	return "Исправна"

func get_item_repair_cost(item: Dictionary) -> int:
	if not is_item_repairable(item):
		return 0
	var wear_ratio: float = float(get_item_wear_percent(item)) / 100.0
	var base_price: float = max(float(item.get("price", 0.0)), 25.0)
	return maxi(roundi(base_price * wear_ratio * REPAIR_COST_MULTIPLIER), 1)

func repair_owned_item(item_id: String) -> Dictionary:
	var item := get_owned_item(item_id)
	if item.is_empty():
		return {"success": false, "message": "Предмет не найден."}
	if get_item_wear_percent(item) >= BROKEN_WEAR_PERCENT:
		return {"success": false, "message": "Предмет полностью сломан. Его можно только выбросить."}
	if not is_item_repairable(item):
		return {"success": false, "message": "Ремонт не требуется."}

	var cost := get_item_repair_cost(item)
	if money < float(cost):
		return {"success": false, "message": "Недостаточно монет для ремонта."}

	money -= float(cost)
	_set_owned_item_durability(item_id, 1.0)
	return {
		"success": true,
		"cost": cost,
		"message": "Починено: %s" % str(item.get("name", "-"))
	}

func discard_owned_item(item_id: String) -> Dictionary:
	var item_index := -1
	var item: Dictionary = {}
	for i in owned_items.size():
		var owned_item: Dictionary = owned_items[i]
		if str(owned_item.get("id", "")) == item_id:
			item_index = i
			item = owned_item
			break

	if item_index < 0:
		return {"success": false, "message": "Предмет не найден."}
	if not can_discard_item(item):
		return {"success": false, "message": "Выбросить можно только полностью сломанную снасть."}

	for slot in TACKLE_SLOTS:
		if not current_tackle.has(slot):
			continue
		var component = current_tackle.get(slot, {})
		if typeof(component) == TYPE_DICTIONARY and str(component.get("id", "")) == item_id:
			clear_current_tackle_slot(slot)

	owned_items.remove_at(item_index)
	return {
		"success": true,
		"message": "Выброшено: %s" % str(item.get("name", "-"))
	}

func _is_durable_tackle_category(category: String) -> bool:
	return ["rod", "line", "leader", "hook"].has(category)

func has_usable_basic_tackle() -> bool:
	for slot in REQUIRED_TACKLE_SLOTS:
		if _is_current_tackle_slot_usable(slot):
			continue
		if not _has_usable_owned_tackle_item(slot):
			return false

	return true

func can_claim_rescue_kit() -> Dictionary:
	if money >= RESCUE_KIT_MONEY_LIMIT:
		return {
			"allowed": false,
			"reason": "У вас достаточно денег для покупки снастей."
		}

	if has_usable_basic_tackle():
		return {
			"allowed": false,
			"reason": "У вас уже есть рабочий комплект."
		}

	var current_day: int = _get_current_game_day()
	if rescue_kit_last_claim_day == current_day:
		return {
			"allowed": false,
			"reason": "Базовый набор уже получен сегодня."
		}

	return {
		"allowed": true,
		"reason": "Вы можете получить базовый набор."
	}

func claim_rescue_kit() -> Dictionary:
	var check: Dictionary = can_claim_rescue_kit()
	if not bool(check.get("allowed", false)):
		check["success"] = false
		check["message"] = str(check.get("reason", "Базовый набор сейчас недоступен."))
		return check

	var hook_id: String = _get_rescue_hook_id()
	var hook_quantity: int = 5 if hook_id == RESCUE_KIT_PRIMARY_HOOK_ID else 3

	_grant_rescue_item("simple_pole_rod_4m", 1)
	_grant_rescue_item(RESCUE_KIT_LINE_ID, 1)
	_grant_rescue_item("light_float", 1)
	_grant_rescue_item(hook_id, hook_quantity)
	_grant_rescue_item("worm", 5)
	_equip_rescue_items_if_needed(hook_id)

	rescue_kit_claims_total += 1
	rescue_kit_last_claim_day = _get_current_game_day()
	_save_after_rescue_kit()

	return {
		"allowed": true,
		"success": true,
		"message": "Базовый набор выдан: удочка, леска, поплавок, крючки и наживка."
	}

func _is_current_tackle_slot_usable(slot: String) -> bool:
	if slot == "leader":
		var leader_component = current_tackle.get(slot, {})
		if typeof(leader_component) == TYPE_DICTIONARY and str(leader_component.get("id", "")) == "":
			return true
	if slot == "bait_2":
		if not can_use_second_bait():
			return true
		var second_bait_component = current_tackle.get(slot, {})
		if typeof(second_bait_component) == TYPE_DICTIONARY and str(second_bait_component.get("id", "")) == "":
			return true

	if not current_tackle.has(slot):
		return false

	var raw_component: Variant = current_tackle.get(slot, {})
	if typeof(raw_component) != TYPE_DICTIONARY:
		return false

	var component: Dictionary = raw_component
	var item_id: String = str(component.get("id", ""))
	if item_id == "":
		return false

	if slot == "bait":
		return get_current_bait_quantity("bait") > 0
	if slot == "bait_2":
		return get_current_bait_quantity("bait_2") > 0

	if _get_owned_item_quantity(item_id) <= 0:
		return false

	if ["rod", "line", "leader", "hook"].has(slot):
		return get_item_wear_percent(component) < REPAIR_BLOCK_WEAR_PERCENT

	return true

func _has_usable_owned_tackle_item(category: String) -> bool:
	for item in owned_items:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var owned_item: Dictionary = item
		if str(owned_item.get("category", "")) != category:
			continue
		if can_equip_item(owned_item):
			return true

	return false

func _get_rescue_hook_id() -> String:
	if not get_tackle_catalog_item(RESCUE_KIT_PRIMARY_HOOK_ID).is_empty():
		return RESCUE_KIT_PRIMARY_HOOK_ID
	return RESCUE_KIT_FALLBACK_HOOK_ID

func _grant_rescue_item(item_id: String, quantity: int) -> void:
	var item: Dictionary = _make_owned_catalog_item(item_id, quantity)
	if item.is_empty():
		return
	add_owned_item(item, quantity)

func _equip_rescue_items_if_needed(hook_id: String) -> void:
	var rescue_slots: Dictionary = {
		"rod": "simple_pole_rod_4m",
		"line": RESCUE_KIT_LINE_ID,
		"leader": "basic_mono_leader_1kg",
		"float": "light_float",
		"hook": hook_id,
		"bait": "worm"
	}

	for slot in REQUIRED_TACKLE_SLOTS:
		if _is_current_tackle_slot_usable(slot):
			continue
		equip_item(str(rescue_slots.get(slot, "")))

func _get_current_game_day() -> int:
	var time_manager: Node = get_node_or_null("/root/TimeManager")
	if time_manager != null:
		var day_value: Variant = time_manager.get("day_index")
		if day_value != null:
			return int(day_value)
	return 1

func _save_after_rescue_kit() -> void:
	var save_manager: Node = get_node_or_null("/root/SaveManager")
	if save_manager != null and save_manager.has_method("save_game"):
		save_manager.call("save_game")

func equip_item(item_id: String) -> bool:
	var item := get_owned_item(item_id)

	if item.is_empty() or not can_equip_item(item):
		return false

	var category := str(item["category"])
	if not TACKLE_SLOTS.has(category):
		return false

	return set_current_tackle_slot(category, item)

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
		owned_item["image_path"] = str(normalized_item.get("image_path", owned_item.get("image_path", "")))
		owned_item["description"] = str(normalized_item.get("description", owned_item.get("description", "")))

		if ["rod", "line", "leader", "hook"].has(item_category):
			var refreshed_stats: Dictionary = normalized_item.get("stats", {}).duplicate(true)
			var owned_stats: Dictionary = owned_item.get("stats", {})
			refreshed_stats["durability"] = max(
				float(refreshed_stats.get("durability", 1.0)),
				float(owned_stats.get("durability", 0.0))
			)
			owned_item["stats"] = refreshed_stats
		else:
			owned_item["stats"] = normalized_item.get("stats", {}).duplicate(true)

		_refresh_current_tackle_from_owned_item(owned_item)

		return

	normalized_item["quantity"] = quantity_to_add
	owned_items.append(normalized_item)

func _refresh_current_tackle_from_owned_item(owned_item: Dictionary) -> void:
	var category := str(owned_item.get("category", ""))
	var owned_id := str(owned_item.get("id", ""))

	for slot in TACKLE_SLOTS:
		if _get_tackle_slot_item_category(slot) != category:
			continue
		if not current_tackle.has(slot):
			continue
		if str(current_tackle[slot].get("id", "")) != owned_id:
			continue

		var stats: Dictionary = _normalize_equipment_stats(owned_item.get("stats", {}).duplicate(true), category, owned_id)
		for key in stats.keys():
			current_tackle[slot][key] = stats[key]

		current_tackle[slot]["image_path"] = str(owned_item.get("image_path", current_tackle[slot].get("image_path", "")))
		current_tackle[slot]["quantity"] = int(owned_item.get("quantity", 0))

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
		var stats: Dictionary = _normalize_equipment_stats(item.get("stats", {}).duplicate(true), category, item_id)
		stats["durability"] = clamp(durability, 0.0, 1.0)
		item["stats"] = stats
		_refresh_current_tackle_from_owned_item(item)
		return

func get_tackle_condition(slot: String) -> float:
	if not current_tackle.has(slot):
		return 0.0

	return clamp(float(current_tackle[slot].get("durability", 1.0)), 0.0, 1.0)

func get_tackle_block_reason() -> String:
	var issues := get_tackle_setup_issues()
	if issues.is_empty():
		return ""

	if issues.size() == 1:
		return str(issues[0])

	return "Проблемы сборки:\n- %s" % "\n- ".join(issues)

func get_tackle_setup_issues() -> Array:
	var issues: Array = []

	for slot in REQUIRED_TACKLE_SLOTS:
		var issue := _get_tackle_slot_issue(slot)
		if issue != "":
			issues.append(issue)

	for slot in ["leader", "bait_2"]:
		var optional_issue := _get_tackle_slot_issue(slot)
		if optional_issue != "":
			issues.append(optional_issue)

	return issues

func get_tackle_setup_status_text() -> String:
	var issues := get_tackle_setup_issues()
	if issues.is_empty():
		return "Сборка готова к ловле."

	return "Не хватает/не работает:\n- %s" % "\n- ".join(issues)

func _get_tackle_slot_issue(slot: String) -> String:
	var title := _get_tackle_slot_title(slot)
	var slot_is_optional := ["leader", "bait_2"].has(slot)

	if slot == "bait_2" and not can_use_second_bait():
		return ""
	if slot_is_optional:
		var optional_component = current_tackle.get(slot, {})
		if typeof(optional_component) != TYPE_DICTIONARY or str(optional_component.get("id", "")) == "":
			return ""

	if not current_tackle.has(slot):
		return "%s не выбрана." % title

	var raw_component: Variant = current_tackle.get(slot, {})
	if typeof(raw_component) != TYPE_DICTIONARY:
		return "%s не выбрана." % title

	var component: Dictionary = raw_component
	var item_id := str(component.get("id", ""))
	var item_name := str(component.get("name", title))
	if item_id == "":
		return "%s не выбрана." % title

	if slot == "bait":
		if get_current_bait_quantity("bait") <= 0:
			return "Наживка закончилась: %s." % item_name
		return ""
	if slot == "bait_2":
		if get_current_bait_quantity("bait_2") <= 0:
			return "Наживка 2 закончилась: %s." % item_name
		return ""

	if _get_owned_item_quantity(item_id) <= 0:
		return "%s отсутствует в инвентаре: %s." % [title, item_name]

	if ["rod", "line", "leader", "hook"].has(slot):
		var wear_percent := get_item_wear_percent(component)
		if wear_percent >= BROKEN_WEAR_PERCENT:
			return "%s сломана: %s." % [title, item_name]
		if wear_percent >= REPAIR_BLOCK_WEAR_PERCENT:
			return "%s требует ремонта: %s." % [title, item_name]

	return ""

func _get_tackle_slot_title(slot: String) -> String:
	if slot == "leader":
		return "Поводок"
	if slot == "bait_2":
		return "Наживка 2"
	match slot:
		"rod":
			return "Удочка"
		"line":
			return "Леска"
		"float":
			return "Поплавок"
		"hook":
			return "Крючок"
		"bait":
			return "Наживка"
		_:
			return "Слот"

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

func get_current_bait_quantity(slot_id: String = "bait") -> int:
	var bait_id := str(current_tackle.get(slot_id, {}).get("id", ""))

	for item in owned_items:
		if str(item.get("id", "")) == bait_id:
			return int(item.get("quantity", 0))

	return 0

func has_current_bait() -> bool:
	if get_current_bait_quantity("bait") <= 0:
		return false
	if _has_active_second_bait() and get_current_bait_quantity("bait_2") <= 0:
		return false
	return true

func _has_active_second_bait() -> bool:
	if not can_use_second_bait():
		return false
	var second_bait = current_tackle.get("bait_2", {})
	return typeof(second_bait) == TYPE_DICTIONARY and str(second_bait.get("id", "")) != ""

func consume_current_bait(amount: int = 1) -> bool:
	return consume_current_tackle_baits(amount)

func consume_current_tackle_baits(amount: int = 1) -> bool:
	amount = max(amount, 1)
	var bait_id := str(current_tackle.get("bait", {}).get("id", ""))
	var second_bait_id := str(current_tackle.get("bait_2", {}).get("id", "")) if _has_active_second_bait() else ""

	if bait_id == "":
		return false
	if _get_owned_item_quantity(bait_id) < amount:
		return false
	if second_bait_id != "":
		var needed_second_amount := amount
		if second_bait_id == bait_id:
			needed_second_amount += amount
		if _get_owned_item_quantity(second_bait_id) < needed_second_amount:
			return false

	_change_owned_item_quantity(bait_id, -amount)
	if second_bait_id != "":
		_change_owned_item_quantity(second_bait_id, -amount)

	return true

func consume_primary_bait(amount: int = 1) -> bool:
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
	var leader: Dictionary = _normalize_equipment_stats(current_tackle.get("leader", {}).duplicate(true), "leader")
	var float_part: Dictionary = current_tackle.get("float", {})
	var hook: Dictionary = _normalize_equipment_stats(current_tackle.get("hook", {}).duplicate(true), "hook")
	var bait: Dictionary = _normalize_equipment_stats(current_tackle.get("bait", {}).duplicate(true), "bait", str(current_tackle.get("bait", {}).get("id", "")))
	var second_bait: Dictionary = _normalize_equipment_stats(current_tackle.get("bait_2", {}).duplicate(true), "bait", str(current_tackle.get("bait_2", {}).get("id", ""))) if _has_active_second_bait() else {}
	var skill_effects := get_skill_effects()
	var rod_durability: float = clamp(float(rod.get("durability", 1.0)), 0.0, 1.0)
	var line_durability: float = clamp(float(line.get("durability", 1.0)), 0.0, 1.0)
	var leader_durability: float = clamp(float(leader.get("durability", 1.0)), 0.0, 1.0)
	var hook_durability: float = clamp(float(hook.get("durability", 1.0)), 0.0, 1.0)
	var rod_condition: float = lerp(0.45, 1.0, rod_durability)
	var line_condition: float = lerp(0.45, 1.0, line_durability)
	var leader_condition: float = lerp(0.45, 1.0, leader_durability)
	var hook_condition: float = lerp(0.35, 1.0, hook_durability)
	var raw_rod_control: float = float(rod.get("control_bonus", rod.get("tension_bonus", 0.0)))
	var rod_handling_bonus: float = float(rod.get("handling_bonus", 0.0))
	var rod_reach_bonus: float = float(rod.get("reach_bonus", 0.0)) * rod_condition
	var rod_tension_bonus: float = (raw_rod_control + rod_handling_bonus) * rod_condition
	var raw_rod_stiffness: float = float(rod.get("stiffness", rod.get("strength", 1.0)))
	var rod_strength: float = raw_rod_stiffness * lerp(0.55, 1.0, rod_durability)
	var raw_line_strength: float = float(line.get("max_load", line.get("max_load_kg", line.get("strength", 1.0))))
	var line_strength_bonus: float = max(float(skill_effects.get("line_strength_bonus", 0.0)), -0.95)
	var line_strength: float = raw_line_strength * line_condition * (1.0 + line_strength_bonus)
	var line_visibility: float = float(line.get("visibility", line.get("visibility_penalty", 0.0)))
	var has_leader := str(current_tackle.get("leader", {}).get("id", "")) != ""
	var leader_strength: float = float(leader.get("strength", line_strength)) * leader_condition
	var leader_visibility: float = float(leader.get("visibility", 0.0)) if has_leader else 0.0
	var leader_bite_protection: float = float(leader.get("bite_protection", 0.0)) * leader_condition if has_leader else 0.0
	if has_leader:
		line_strength = min(line_strength, max(leader_strength * 1.08, 0.05))
		line_visibility = clamp(line_visibility + leader_visibility * 0.55 - leader_bite_protection * 0.25, 0.0, 0.65)
	var float_sensitivity: float = float(float_part.get("sensitivity", float_part.get("bite_detection_bonus", 0.0)))
	var float_stability: float = float(float_part.get("stability", 0.0))
	var float_bite_visibility: float = float(float_part.get("bite_visibility", 0.0))
	var hook_chance: float = float(hook.get("hook_chance", hook.get("hook_success_bonus", 0.0))) * hook_condition
	var hook_strength: float = float(hook.get("hook_strength", 1.0)) * hook_condition
	var raw_escape_modifier: float = float(hook.get("fish_escape_modifier", 1.0))
	var line_wear_reduction: float = clamp(float(skill_effects.get("line_wear_reduction", 0.0)), 0.0, 0.85)
	var line_wear_rate: float = max(float(line.get("wear_rate", 0.022)) * (1.0 - line_wear_reduction), 0.001)
	var bite_detection_bonus: float = float_sensitivity + float_bite_visibility * 0.50 + float(skill_effects.get("bite_detection_bonus", 0.0))
	var bait_id := str(bait.get("id", bait.get("bait_id", "")))
	var secondary_bait_id := ""
	var bait_types: Array = [str(bait.get("bait_type", "worm"))]
	var secondary_bait_type := ""
	var bait_tags: Array = _to_string_array(bait.get("bait_tags", []))
	var target_fish_ids: Array = _to_string_array(bait.get("target_fish_ids", []))
	var secondary_fish_ids: Array = _to_string_array(bait.get("secondary_fish_ids", []))
	var fish_attraction: float = clamp(float(bait.get("fish_attraction", 0.0)), 0.0, 0.08)
	var fish_attraction_by_id: Dictionary = bait.get("fish_attraction_by_id", {}).duplicate(true) if typeof(bait.get("fish_attraction_by_id", {})) == TYPE_DICTIONARY else {}
	var allowed_rarities: Array = bait.get("allowed_rarities", []).duplicate(true) if typeof(bait.get("allowed_rarities", [])) == TYPE_ARRAY else []
	if not second_bait.is_empty():
		secondary_bait_id = str(second_bait.get("id", second_bait.get("bait_id", "")))
		secondary_bait_type = str(second_bait.get("bait_type", ""))
		if secondary_bait_type != "" and not bait_types.has(secondary_bait_type):
			bait_types.append(secondary_bait_type)
		bait_tags = _merge_unique_string_arrays(bait_tags, _to_string_array(second_bait.get("bait_tags", [])))
		target_fish_ids = _merge_unique_string_arrays(target_fish_ids, _to_string_array(second_bait.get("target_fish_ids", [])))
		secondary_fish_ids = _merge_unique_string_arrays(secondary_fish_ids, _to_string_array(second_bait.get("secondary_fish_ids", [])))
		for fish_id in target_fish_ids:
			secondary_fish_ids.erase(str(fish_id))
		var second_base_attraction: float = clamp(float(second_bait.get("fish_attraction", 0.0)), 0.0, 0.08)
		fish_attraction = clamp(max(fish_attraction, second_base_attraction) + min(fish_attraction, second_base_attraction) * 0.35 + 0.01, 0.0, 0.12)
		var second_attraction_by_id = second_bait.get("fish_attraction_by_id", {})
		if typeof(second_attraction_by_id) == TYPE_DICTIONARY:
			for fish_id in second_attraction_by_id.keys():
				var merged_fish_id := str(fish_id)
				var current_attraction := float(fish_attraction_by_id.get(merged_fish_id, 0.0))
				var second_attraction := float(second_attraction_by_id[fish_id])
				if current_attraction > 0.0 and second_attraction > 0.0:
					fish_attraction_by_id[merged_fish_id] = clamp(max(current_attraction, second_attraction) + min(current_attraction, second_attraction) * 0.35 + 0.03, 0.0, 0.42)
				else:
					fish_attraction_by_id[merged_fish_id] = max(current_attraction, second_attraction)
		var second_allowed = second_bait.get("allowed_rarities", [])
		if typeof(second_allowed) == TYPE_ARRAY:
			for rarity in second_allowed:
				if not allowed_rarities.has(rarity):
					allowed_rarities.append(rarity)

	return {
		"control_bonus": rod_tension_bonus,
		"tension_bonus": rod_tension_bonus,
		"base_control_bonus": raw_rod_control * rod_condition,
		"handling_bonus": rod_handling_bonus * rod_condition,
		"reach_bonus": rod_reach_bonus,
		"length_m": float(rod.get("length_m", 4.0)),
		"rod_length_m": float(rod.get("length_m", 4.0)),
		"rod_class": str(rod.get("rod_class", "medium")),
		"durability": rod_durability,
		"rod_durability": rod_durability,
		"line_durability": line_durability,
		"leader_durability": leader_durability if has_leader else 1.0,
		"hook_durability": hook_durability,
		"max_fish_weight": float(rod.get("max_fish_weight", 1.0)) * lerp(0.60, 1.0, rod_durability),
		"rod_strength": rod_strength,
		"stiffness": rod_strength,
		"durability_loss": float(rod.get("durability_loss", 0.012)),
		"line_strength": line_strength,
		"max_load_kg": line_strength,
		"max_load": line_strength,
		"raw_line_strength": raw_line_strength,
		"break_resistance": float(line.get("break_resistance", 1.0)) * lerp(0.35, 1.0, line_durability) * (1.0 + leader_bite_protection),
		"break_chance": float(line.get("break_chance", 0.15)) / max(lerp(0.45, 1.0, line_durability) * (1.0 + leader_bite_protection), 0.1),
		"line_wear_rate": line_wear_rate,
		"wear_rate": line_wear_rate,
		"visibility": line_visibility,
		"visibility_penalty": line_visibility,
		"leader_strength": leader_strength if has_leader else 0.0,
		"leader_visibility": leader_visibility,
		"leader_bite_protection": leader_bite_protection,
		"sensitivity": float_sensitivity,
		"bite_visibility": float_bite_visibility,
		"bite_detection_bonus": bite_detection_bonus,
		"green_zone_bonus": float(skill_effects.get("green_zone_bonus", 0.0)),
		"stability": float_stability,
		"hook_size": int(hook.get("hook_size", 12)),
		"hook_chance": hook_chance,
		"hook_success_bonus": hook_chance,
		"hook_strength": hook_strength,
		"hook_wear_rate": float(hook.get("wear_rate", 0.026)),
		"target_fish_size": str(hook.get("target_fish_size", "small")),
		"fish_escape_modifier": raw_escape_modifier * lerp(1.45, 1.0, hook_durability),
		"bait_id": bait_id,
		"bait_type": str(bait.get("bait_type", "worm")),
		"secondary_bait_id": secondary_bait_id,
		"secondary_bait_type": secondary_bait_type,
		"bait_types": bait_types,
		"bait_tags": bait_tags,
		"target_fish_ids": target_fish_ids,
		"secondary_fish_ids": secondary_fish_ids,
		"fishing_depth": fishing_depth,
		"fish_attraction": fish_attraction,
		"fish_attraction_by_id": fish_attraction_by_id,
		"allowed_rarities": allowed_rarities
	}

func get_bait_target_fish_names(bait_id: String, limit: int = 4) -> String:
	var names := _get_bait_fish_names(bait_id, "target_fish_ids", limit)
	if names.is_empty():
		return ""
	return "Лучше для: %s" % ", ".join(names)

func get_bait_secondary_fish_names(bait_id: String, limit: int = 4) -> String:
	var names := _get_bait_fish_names(bait_id, "secondary_fish_ids", limit)
	if names.is_empty():
		return ""
	return "Также берёт: %s" % ", ".join(names)

func get_fish_bait_names(fish_id: String, limit: int = 8) -> String:
	var names := _get_fish_bait_names(fish_id, limit)
	if names.is_empty():
		return ""
	return ", ".join(names)

func _get_fish_bait_names(fish_id: String, limit: int) -> Array:
	var matches: Array = []
	var capped_limit: int = max(limit, 1)

	for item in get_tackle_catalog_items("bait"):
		var stats: Dictionary = item.get("stats", {}) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}
		var target_ids: Array = stats.get("target_fish_ids", []) if typeof(stats.get("target_fish_ids", [])) == TYPE_ARRAY else []
		var secondary_ids: Array = stats.get("secondary_fish_ids", []) if typeof(stats.get("secondary_fish_ids", [])) == TYPE_ARRAY else []
		var attraction_by_id: Dictionary = stats.get("fish_attraction_by_id", {}) if typeof(stats.get("fish_attraction_by_id", {})) == TYPE_DICTIONARY else {}
		var attraction: float = float(attraction_by_id.get(fish_id, 0.0))
		var score := 0.0

		if target_ids.has(fish_id):
			score = 3.0 + attraction
		elif attraction > 0.0:
			score = 2.6 + attraction
		elif secondary_ids.has(fish_id):
			score = 1.8 + attraction

		if score <= 0.0:
			continue

		matches.append({
			"name": str(item.get("name", item.get("id", ""))),
			"score": score,
			"price": float(item.get("price", 0.0))
		})

	matches.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var score_a := float(a.get("score", 0.0))
		var score_b := float(b.get("score", 0.0))
		if is_equal_approx(score_a, score_b):
			return float(a.get("price", 0.0)) < float(b.get("price", 0.0))
		return score_a > score_b
	)

	var names: Array = []
	for item in matches:
		names.append(str(item.get("name", "")))
		if names.size() >= capped_limit:
			break

	if matches.size() > names.size():
		names.append("...")

	return names

func _get_bait_fish_names(bait_id: String, field: String, limit: int) -> Array:
	var item := get_tackle_catalog_item(bait_id)
	var stats: Dictionary = item.get("stats", {})
	var fish_ids: Array = stats.get(field, []) if typeof(stats.get(field, [])) == TYPE_ARRAY else []
	var names: Array = []
	var capped_limit: int = max(limit, 1)

	for fish_id in fish_ids:
		var fish := FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue
		names.append(str(fish.get("name", fish_id)))
		if names.size() >= capped_limit:
			break

	if fish_ids.size() > names.size():
		names.append("...")

	return names

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
