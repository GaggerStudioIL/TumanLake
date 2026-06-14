extends Node

const PHYSICAL_SHORE_MIN_DEPTH := 0.16
const BASIC_FLOAT_ID := "float_drop_basic"
const BASIC_LEADER_ID := "nylon_leader_20cm_1kg"
const BASIC_REEL_ID := "river_reel_1000"
const BASIC_LURE_ID := "silver_spinner_5g"
const BETA_HIDDEN_TACKLE_CATEGORIES := {
	"reel": true,
	"lure": true,
	"spoon": true,
	"wobbler": true,
	"spinner_bait": true
}
const BETA_HIDDEN_LURE_TYPES := {
	"spinner": true,
	"spoon": true,
	"wobbler": true,
	"spinner_bait": true
}
const LEGACY_TACKLE_ITEM_ALIASES := {
	"light_float": "float_feather_basic",
	"medium_float": "float_drop_basic",
	"night_float": "float_glow_feather",
	"basic_mono_leader_1kg": BASIC_LEADER_ID,
	"soft_fluoro_leader_2kg": "fluoro_leader_25cm_2kg",
	"strong_braid_leader_4kg": "braided_leader_25cm_5kg"
}
const WORM_BAIT_PRICE_OVERRIDES := {
	"worm": 1.2,
	"cherv_moskovskiy": 2.4,
	"cherv_surskiy": 2.8,
	"cherv_navozni": 1.6,
	"cherv_astrahanskiy": 4.8,
	"cherv_volhovskiy": 5.2,
	"cherv_leningradskiy": 5.6,
	"vipolzok": 5.8
}
const SURVIVAL_ITEM_CATEGORIES := {
	"food": true,
	"drink": true,
	"clothing": true,
	"shelter": true
}
const CLOTHING_SLOTS := {
	"torso": "Верх",
	"legs": "Низ",
	"shoes": "Обувь",
	"head": "Голова",
	"outerwear": "Куртка"
}
const STARTER_CLOTHING_ITEM_IDS := ["basic_tshirt", "basic_pants", "basic_sneakers"]
const STARTER_SUPPLY_ITEMS := [
	{"id": "food_bread", "quantity": 2},
	{"id": "sandwich", "quantity": 2},
	{"id": "canned_food", "quantity": 2},
	{"id": "water_bottle", "quantity": 2},
	{"id": "hot_tea", "quantity": 1}
]
const SURVIVAL_ITEM_CATALOG := {
	"food_bread": {
		"id": "food_bread",
		"name": "Хлеб",
		"display_name_ru": "Хлеб",
		"type": "food",
		"category": "food",
		"shop_category": "food",
		"rarity": "common",
		"price": 4,
		"image_path": "res://assets/ui/shop/survival/food/bread.png",
		"description": "Простая еда для быстрого перекуса.",
		"description_ru": "Простая еда для быстрого перекуса.",
		"stats": {"hunger_restore": 15.0}
	},
	"sandwich": {
		"id": "sandwich",
		"name": "Бутерброд",
		"display_name_ru": "Бутерброд",
		"type": "food",
		"category": "food",
		"shop_category": "food",
		"rarity": "common",
		"price": 9,
		"image_path": "res://assets/ui/shop/survival/food/sandwich.png",
		"description": "Сытный перекус перед рыбалкой.",
		"description_ru": "Сытный перекус перед рыбалкой.",
		"stats": {"hunger_restore": 25.0}
	},
	"canned_food": {
		"id": "canned_food",
		"name": "Консервы",
		"display_name_ru": "Консервы",
		"type": "food",
		"category": "food",
		"shop_category": "food",
		"rarity": "common",
		"price": 14,
		"image_path": "res://assets/ui/shop/survival/food/canned_food.png",
		"description": "Надёжная еда для долгой вылазки.",
		"description_ru": "Надёжная еда для долгой вылазки.",
		"stats": {"hunger_restore": 35.0}
	},
	"chocolate_bar": {
		"id": "chocolate_bar",
		"name": "Шоколадный батончик",
		"display_name_ru": "Шоколадный батончик",
		"type": "food",
		"category": "food",
		"shop_category": "food",
		"rarity": "common",
		"price": 8,
		"description": "Быстрый заряд сил и концентрации.",
		"description_ru": "Быстрый заряд сил и концентрации.",
		"stats": {"hunger_restore": 12.0, "condition_bonus": 0.06, "bonus_minutes": 90.0}
	},
	"camp_meal": {
		"id": "camp_meal",
		"name": "Походный обед",
		"display_name_ru": "Походный обед",
		"type": "food",
		"category": "food",
		"shop_category": "food",
		"rarity": "uncommon",
		"price": 28,
		"description": "Плотная еда, которая помогает прийти в себя.",
		"description_ru": "Плотная еда, которая помогает прийти в себя.",
		"stats": {"hunger_restore": 50.0, "health_restore": 5.0}
	},
	"water_bottle": {
		"id": "water_bottle",
		"name": "Бутылка воды",
		"display_name_ru": "Бутылка воды",
		"type": "drink",
		"category": "drink",
		"shop_category": "food",
		"rarity": "common",
		"price": 5,
		"image_path": "res://assets/ui/shop/survival/drinks/water_bottle.png",
		"description": "Помогает освежиться в жару.",
		"description_ru": "Помогает освежиться в жару.",
		"stats": {"temperature_delta_hot": -0.18}
	},
	"hot_tea": {
		"id": "hot_tea",
		"name": "Горячий чай",
		"display_name_ru": "Горячий чай",
		"type": "drink",
		"category": "drink",
		"shop_category": "food",
		"rarity": "common",
		"price": 7,
		"image_path": "res://assets/ui/shop/survival/drinks/hot_tea.png",
		"description": "Согревает в холодную погоду.",
		"description_ru": "Согревает в холодную погоду.",
		"stats": {"temperature_delta_cold": 0.25}
	},
	"coffee": {
		"id": "coffee",
		"name": "Кофе",
		"display_name_ru": "Кофе",
		"type": "drink",
		"category": "drink",
		"shop_category": "food",
		"rarity": "common",
		"price": 9,
		"image_path": "res://assets/ui/shop/survival/drinks/coffee.png",
		"description": "Слегка согревает и помогает сосредоточиться.",
		"description_ru": "Слегка согревает и помогает сосредоточиться.",
		"stats": {"temperature_delta_cold": 0.12, "condition_bonus": 0.05, "bonus_minutes": 90.0}
	},
	"cold_drink": {
		"id": "cold_drink",
		"name": "Холодный напиток",
		"display_name_ru": "Холодный напиток",
		"type": "drink",
		"category": "drink",
		"shop_category": "food",
		"rarity": "common",
		"price": 9,
		"description": "Быстро охлаждает в жаркий день.",
		"description_ru": "Быстро охлаждает в жаркий день.",
		"stats": {"temperature_delta_hot": -0.36}
	},
	"basic_tshirt": {
		"id": "basic_tshirt",
		"name": "Базовая футболка",
		"display_name_ru": "Базовая футболка",
		"type": "clothing",
		"category": "clothing",
		"shop_category": "clothing",
		"rarity": "common",
		"price": 5,
		"image_path": "res://assets/ui/shop/survival/clothing/basic_tshirt.png",
		"description": "Стартовая лёгкая одежда.",
		"description_ru": "Стартовая лёгкая одежда.",
		"stats": {"clothing_slot": "torso", "cold_protection": 0.08, "heat_protection": 0.08, "warmth": 0.05}
	},
	"basic_pants": {
		"id": "basic_pants",
		"name": "Базовые штаны",
		"display_name_ru": "Базовые штаны",
		"type": "clothing",
		"category": "clothing",
		"shop_category": "clothing",
		"rarity": "common",
		"price": 6,
		"image_path": "res://assets/ui/shop/survival/clothing/basic_pants.png",
		"description": "Обычные штаны для первой рыбалки.",
		"description_ru": "Обычные штаны для первой рыбалки.",
		"stats": {"clothing_slot": "legs", "cold_protection": 0.10, "wind_protection": 0.04, "warmth": 0.07}
	},
	"basic_sneakers": {
		"id": "basic_sneakers",
		"name": "Базовые кеды",
		"display_name_ru": "Базовые кеды",
		"type": "clothing",
		"category": "clothing",
		"shop_category": "clothing",
		"rarity": "common",
		"price": 6,
		"image_path": "res://assets/ui/shop/survival/clothing/basic_sneakers.png",
		"description": "Простая обувь без защиты от воды.",
		"description_ru": "Простая обувь без защиты от воды.",
		"stats": {"clothing_slot": "shoes", "cold_protection": 0.05, "wind_protection": 0.02, "warmth": 0.03}
	},
	"light_jacket": {
		"id": "light_jacket",
		"name": "Лёгкая куртка",
		"display_name_ru": "Лёгкая куртка",
		"type": "clothing",
		"category": "clothing",
		"shop_category": "clothing",
		"rarity": "common",
		"price": 36,
		"description": "Защищает от ветра и прохлады.",
		"description_ru": "Защищает от ветра и прохлады.",
		"stats": {"clothing_slot": "outerwear", "cold_protection": 0.30, "wind_protection": 0.34, "rain_protection": 0.08, "warmth": 0.24}
	},
	"warm_jacket": {
		"id": "warm_jacket",
		"name": "Тёплая куртка",
		"display_name_ru": "Тёплая куртка",
		"type": "clothing",
		"category": "clothing",
		"shop_category": "clothing",
		"rarity": "uncommon",
		"price": 78,
		"image_path": "res://assets/ui/shop/survival/clothing/warm_jacket.png",
		"description": "Хорошо держит тепло в холодные часы.",
		"description_ru": "Хорошо держит тепло в холодные часы.",
		"stats": {"clothing_slot": "outerwear", "cold_protection": 0.58, "wind_protection": 0.42, "rain_protection": 0.12, "warmth": 0.48, "heat_penalty": 0.12}
	},
	"raincoat": {
		"id": "raincoat",
		"name": "Дождевик",
		"display_name_ru": "Дождевик",
		"type": "clothing",
		"category": "clothing",
		"shop_category": "clothing",
		"rarity": "common",
		"price": 44,
		"description": "Защищает от дождя и сырости.",
		"description_ru": "Защищает от дождя и сырости.",
		"stats": {"clothing_slot": "outerwear", "cold_protection": 0.18, "wind_protection": 0.20, "rain_protection": 0.62, "warmth": 0.12}
	},
	"cap": {
		"id": "cap",
		"name": "Кепка",
		"display_name_ru": "Кепка",
		"type": "clothing",
		"category": "clothing",
		"shop_category": "clothing",
		"rarity": "common",
		"price": 14,
		"image_path": "res://assets/ui/shop/survival/clothing/cap.png",
		"description": "Немного помогает на солнце.",
		"description_ru": "Немного помогает на солнце.",
		"stats": {"clothing_slot": "head", "heat_protection": 0.18}
	},
	"warm_hat": {
		"id": "warm_hat",
		"name": "Тёплая шапка",
		"display_name_ru": "Тёплая шапка",
		"type": "clothing",
		"category": "clothing",
		"shop_category": "clothing",
		"rarity": "common",
		"price": 18,
		"description": "Сохраняет тепло ночью и утром.",
		"description_ru": "Сохраняет тепло ночью и утром.",
		"stats": {"clothing_slot": "head", "cold_protection": 0.24, "wind_protection": 0.10, "warmth": 0.20, "heat_penalty": 0.04}
	},
	"rubber_boots": {
		"id": "rubber_boots",
		"name": "Резиновые сапоги",
		"display_name_ru": "Резиновые сапоги",
		"type": "clothing",
		"category": "clothing",
		"shop_category": "clothing",
		"rarity": "common",
		"price": 32,
		"description": "Держат ноги сухими у берега.",
		"description_ru": "Держат ноги сухими у берега.",
		"stats": {"clothing_slot": "shoes", "cold_protection": 0.16, "rain_protection": 0.38, "warmth": 0.12}
	},
	"simple_tent": {
		"id": "simple_tent",
		"name": "Простая палатка",
		"display_name_ru": "Простая палатка",
		"type": "shelter",
		"category": "shelter",
		"shop_category": "clothing",
		"rarity": "common",
		"price": 90,
		"image_path": "res://assets/ui/shop/survival/shelters/simple_tent.png",
		"description": "Позволяет отдохнуть и стабилизировать состояние.",
		"description_ru": "Позволяет отдохнуть и стабилизировать состояние.",
		"stats": {"rest_minutes": 90.0, "health_restore": 16.0, "hunger_cost": 8.0, "normalize_temperature": true}
	},
	"warm_tent": {
		"id": "warm_tent",
		"name": "Тёплая палатка",
		"display_name_ru": "Тёплая палатка",
		"type": "shelter",
		"category": "shelter",
		"shop_category": "clothing",
		"rarity": "uncommon",
		"price": 150,
		"description": "Лучше восстанавливает тепло и самочувствие.",
		"description_ru": "Лучше восстанавливает тепло и самочувствие.",
		"stats": {"rest_minutes": 120.0, "health_restore": 24.0, "hunger_cost": 10.0, "normalize_temperature": true}
	},
	"rain_shelter": {
		"id": "rain_shelter",
		"name": "Навес от дождя",
		"display_name_ru": "Навес от дождя",
		"type": "shelter",
		"category": "shelter",
		"shop_category": "clothing",
		"rarity": "common",
		"price": 72,
		"description": "Укрывает от дождя и ветра.",
		"description_ru": "Укрывает от дождя и ветра.",
		"stats": {"rest_minutes": 60.0, "health_restore": 8.0, "hunger_cost": 5.0, "normalize_temperature": true}
	}
}
const LEVEL_UP_REWARDS := {
	2: {
		"silver": 25,
		"items": [{"id": "worm", "quantity": 10}],
		"unlocks": ["Награды за новые уровни"]
	},
	3: {
		"silver": 30,
		"items": [{"id": "maggot", "quantity": 10}],
		"unlocks": ["Опарыш для активной рыбы"]
	},
	4: {
		"silver": 40,
		"items": [{"id": "float_feather_basic", "quantity": 1}],
		"unlocks": ["Запасной чувствительный поплавок"]
	},
	5: {
		"silver": 50,
		"items": [{"id": "small_hook_12", "quantity": 5}],
		"unlocks": ["Набор крючков для частой ловли"]
	},
	6: {
		"silver": 60,
		"items": [{"id": "nylon_leader_15cm_1kg", "quantity": 3}],
		"unlocks": ["Короткие поводки для осторожной рыбы"]
	},
	7: {
		"silver": 75,
		"items": [{"id": "bread", "quantity": 10}],
		"unlocks": ["Хлебная наживка для мирной рыбы"]
	},
	8: {
		"silver": 90,
		"items": [{"id": "lakeline_nylon_basic_2kg", "quantity": 1}],
		"unlocks": ["Более крепкая базовая леска"]
	},
	9: {
		"silver": 100,
		"items": [
			{"id": "worm", "quantity": 10},
			{"id": "maggot", "quantity": 10},
			{"id": "motil", "quantity": 8}
		],
		"unlocks": ["Набор наживки для разных точек"]
	},
	10: {
		"silver": 150,
		"items": [{"id": "shore_pole_rod_5m", "quantity": 1}],
		"unlocks": ["Береговая удочка 5 м"]
	}
}

const TACKLE_CATALOG := {
	"simple_pole_rod_4m": {
		"id": "simple_pole_rod_4m",
		"name": "Простая маховая удочка 4 м",
		"type": "rod",
		"category": "rod",
		"rarity": "common",
		"price": 0,
		"image_path": "res://assets/ui/shop/rods/simple_pole_rod_4m.png",
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
		"image_path": "res://assets/ui/shop/rods/shore_pole_rod_5m.png",
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
		"image_path": "res://assets/ui/shop/rods/reinforced_pole_rod_6m.png",
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
		"image_path": "res://assets/ui/shop/rods/titan_hook_ultra_match.png",
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
	"river_spin_210": {
		"id": "river_spin_210",
		"name": "River Spin 210",
		"type": "rod",
		"category": "rod",
		"rod_type": "spinning",
		"tackle_type": "spinning",
		"rarity": "common",
		"price": 180,
		"description": "Лёгкий спиннинг для окуня, щуки-травянки и первых катушечных проводок.",
		"stats": {
			"rod_type": "spinning",
			"tackle_type": "spinning",
			"requires_reel": true,
			"length": 2.1,
			"length_m": 2.1,
			"rod_class": "light",
			"power": 0.88,
			"test_min": 3.0,
			"test_max": 12.0,
			"flexibility": 0.62,
			"compatible_reel_min_size": 1000,
			"compatible_reel_max_size": 2500,
			"max_fish_weight": 3.0,
			"strength": 0.95,
			"stiffness": 0.90,
			"tension_bonus": 0.10,
			"control_bonus": 0.10,
			"reach_bonus": 0.08,
			"handling_bonus": 0.05,
			"durability": 1.0,
			"durability_loss": 0.009
		}
	},
	"lake_spin_240": {
		"id": "lake_spin_240",
		"name": "Lake Spin 240",
		"type": "rod",
		"category": "rod",
		"rod_type": "spinning",
		"tackle_type": "spinning",
		"rarity": "uncommon",
		"price": 420,
		"description": "Универсальный спиннинг для озёрной щуки, судака и дальнего заброса.",
		"stats": {
			"rod_type": "spinning",
			"tackle_type": "spinning",
			"requires_reel": true,
			"length": 2.4,
			"length_m": 2.4,
			"rod_class": "medium",
			"power": 1.15,
			"test_min": 7.0,
			"test_max": 28.0,
			"flexibility": 0.54,
			"compatible_reel_min_size": 2000,
			"compatible_reel_max_size": 4000,
			"max_fish_weight": 6.0,
			"strength": 1.24,
			"stiffness": 1.16,
			"tension_bonus": 0.13,
			"control_bonus": 0.13,
			"reach_bonus": 0.12,
			"handling_bonus": 0.02,
			"durability": 1.0,
			"durability_loss": 0.007
		}
	},
	"carp_cast_360": {
		"id": "carp_cast_360",
		"name": "Carp Cast 360",
		"type": "rod",
		"category": "rod",
		"rod_type": "feeder",
		"tackle_type": "feeder",
		"rarity": "rare",
		"price": 760,
		"description": "Силовое донное удилище под большую шпулю, кормушку и тяжёлую рыбу.",
		"stats": {
			"rod_type": "feeder",
			"tackle_type": "feeder",
			"requires_reel": true,
			"length": 3.6,
			"length_m": 3.6,
			"rod_class": "heavy",
			"power": 1.45,
			"test_min": 40.0,
			"test_max": 120.0,
			"flexibility": 0.42,
			"compatible_reel_min_size": 4000,
			"compatible_reel_max_size": 6000,
			"max_fish_weight": 12.0,
			"strength": 1.72,
			"stiffness": 1.55,
			"tension_bonus": 0.10,
			"control_bonus": 0.10,
			"reach_bonus": 0.18,
			"handling_bonus": -0.01,
			"durability": 1.0,
			"durability_loss": 0.006
		}
	},
	"river_reel_1000": {
		"id": "river_reel_1000",
		"name": "River Reel 1000",
		"type": "reel",
		"category": "reel",
		"rarity": "common",
		"price": 95,
		"description": "Лёгкая безынерционная катушка для маленьких спиннингов.",
		"stats": {
			"reel_size": 1000,
			"reel_type": "spinning",
			"max_drag": 2.5,
			"retrieve_speed": 0.62,
			"spool_capacity": 85.0,
			"durability": 1.0,
			"weight": 190.0,
			"wear_rate": 0.010,
			"body_texture": "",
			"spool_texture": "",
			"handle_texture": ""
		}
	},
	"river_reel_2000": {
		"id": "river_reel_2000",
		"name": "River Reel 2000",
		"type": "reel",
		"category": "reel",
		"rarity": "common",
		"price": 155,
		"description": "Универсальная ранняя катушка для лёгкого берега.",
		"stats": {
			"reel_size": 2000,
			"reel_type": "spinning",
			"max_drag": 4.0,
			"retrieve_speed": 0.70,
			"spool_capacity": 120.0,
			"durability": 1.0,
			"weight": 225.0,
			"wear_rate": 0.009,
			"body_texture": "",
			"spool_texture": "",
			"handle_texture": ""
		}
	},
	"lake_reel_2500": {
		"id": "lake_reel_2500",
		"name": "Lake Reel 2500",
		"type": "reel",
		"category": "reel",
		"rarity": "uncommon",
		"price": 240,
		"description": "Средняя катушка для озёрного спиннинга и аккуратной щуки.",
		"stats": {
			"reel_size": 2500,
			"reel_type": "spinning",
			"max_drag": 5.5,
			"retrieve_speed": 0.78,
			"spool_capacity": 155.0,
			"durability": 1.0,
			"weight": 260.0,
			"wear_rate": 0.008,
			"body_texture": "",
			"spool_texture": "",
			"handle_texture": ""
		}
	},
	"lake_reel_3000": {
		"id": "lake_reel_3000",
		"name": "Lake Reel 3000",
		"type": "reel",
		"category": "reel",
		"rarity": "uncommon",
		"price": 330,
		"description": "Надёжная катушка с запасом фрикциона для средней хищной рыбы.",
		"stats": {
			"reel_size": 3000,
			"reel_type": "spinning",
			"max_drag": 7.0,
			"retrieve_speed": 0.84,
			"spool_capacity": 190.0,
			"durability": 1.0,
			"weight": 295.0,
			"wear_rate": 0.007,
			"body_texture": "",
			"spool_texture": "",
			"handle_texture": ""
		}
	},
	"feeder_reel_4000": {
		"id": "feeder_reel_4000",
		"name": "Feeder Reel 4000",
		"type": "reel",
		"category": "reel",
		"rarity": "rare",
		"price": 520,
		"description": "Большая шпуля для дальнего заброса и уверенного донного темпа.",
		"stats": {
			"reel_size": 4000,
			"reel_type": "feeder",
			"max_drag": 9.0,
			"retrieve_speed": 0.92,
			"spool_capacity": 240.0,
			"durability": 1.0,
			"weight": 360.0,
			"wear_rate": 0.006,
			"body_texture": "",
			"spool_texture": "",
			"handle_texture": ""
		}
	},
	"feeder_reel_5000": {
		"id": "feeder_reel_5000",
		"name": "Feeder Reel 5000",
		"type": "reel",
		"category": "reel",
		"rarity": "rare",
		"price": 690,
		"description": "Тяговая катушка под кормушку, течение и крупного леща.",
		"stats": {
			"reel_size": 5000,
			"reel_type": "feeder",
			"max_drag": 11.0,
			"retrieve_speed": 0.96,
			"spool_capacity": 285.0,
			"durability": 1.0,
			"weight": 410.0,
			"wear_rate": 0.006,
			"body_texture": "",
			"spool_texture": "",
			"handle_texture": ""
		}
	},
	"carp_reel_6000": {
		"id": "carp_reel_6000",
		"name": "Carp Reel 6000",
		"type": "reel",
		"category": "reel",
		"rarity": "epic",
		"price": 980,
		"description": "Силовая катушка для тяжёлых монтажей и долгого вываживания.",
		"stats": {
			"reel_size": 6000,
			"reel_type": "carp",
			"max_drag": 13.0,
			"retrieve_speed": 1.02,
			"spool_capacity": 340.0,
			"durability": 1.0,
			"weight": 480.0,
			"wear_rate": 0.005,
			"body_texture": "",
			"spool_texture": "",
			"handle_texture": ""
		}
	},
	"carp_reel_8000": {
		"id": "carp_reel_8000",
		"name": "Carp Reel 8000",
		"type": "reel",
		"category": "reel",
		"rarity": "epic",
		"price": 1320,
		"description": "Большая карповая шпуля для дальнего берега и мощных рывков.",
		"stats": {
			"reel_size": 8000,
			"reel_type": "carp",
			"max_drag": 16.0,
			"retrieve_speed": 1.08,
			"spool_capacity": 430.0,
			"durability": 1.0,
			"weight": 560.0,
			"wear_rate": 0.0045,
			"body_texture": "",
			"spool_texture": "",
			"handle_texture": ""
		}
	},
	"trophy_reel_10000": {
		"id": "trophy_reel_10000",
		"name": "Trophy Reel 10000",
		"type": "reel",
		"category": "reel",
		"rarity": "trophy",
		"price": 1850,
		"description": "Трофейная катушка с огромной шпулей и мощным фрикционом.",
		"stats": {
			"reel_size": 10000,
			"reel_type": "big_game",
			"max_drag": 20.0,
			"retrieve_speed": 1.12,
			"spool_capacity": 540.0,
			"durability": 1.0,
			"weight": 680.0,
			"wear_rate": 0.004,
			"body_texture": "",
			"spool_texture": "",
			"handle_texture": ""
		}
	},
	"silver_spinner_5g": {
		"id": "silver_spinner_5g",
		"name": "Серебристая вертушка 5 г",
		"type": "lure",
		"category": "lure",
		"rarity": "common",
		"price": 65,
		"description": "Небольшая блесна для окуня и щуки-травянки.",
		"stats": {
			"lure_type": "spinner",
			"bait_type": "lure",
			"bait_tags": ["metal", "moving", "predator", "small"],
			"target_fish_ids": ["perch", "young_pike", "pike"],
			"secondary_fish_ids": ["zander", "young_chub", "ide"],
			"fish_attraction": 0.055,
			"hook_size": 8,
			"hook_chance": 0.11,
			"hook_strength": 1.05,
			"fish_escape_modifier": 0.95,
			"weight": 5.0,
			"durability": 1.0,
			"wear_rate": 0.006
		}
	},
	"mono_1_2kg": {
		"id": "mono_1_2kg",
		"name": "Леска 1.2 кг",
		"type": "line",
		"category": "line",
		"rarity": "common",
		"price": 55,
		"image_path": "res://assets/ui/shop/lines/mono_1_2kg.png",
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
	"nylon_leader_10cm_0_5kg": {
		"id": "nylon_leader_10cm_0_5kg",
		"name": "Нейлоновый поводок 10 см / 0.5 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "common",
		"price": 12,
		"level_required": 1,
		"image_path": "res://assets/ui/shop/leaders/nylon_leader_10cm_0_5kg.png",
		"description": "Очень тонкий короткий поводок для уклейки, мелкой плотвы и быстрой поклёвки. Контроль выше, но осторожная рыба чаще замечает короткую подачу.",
		"stats": {
			"leader_type": "nylon",
			"material": "nylon",
			"length_cm": 10,
			"max_load_kg": 0.5,
			"max_load": 0.5,
			"strength": 0.5,
			"visibility": 0.025,
			"bite_protection": 0.00,
			"control_bonus": 0.05,
			"cautious_bite_bonus": -0.05,
			"small_fish_penalty": 0.00,
			"break_resistance": 0.82,
			"break_chance": 0.22,
			"durability": 1.0,
			"wear_rate": 0.023
		}
	},
	"nylon_leader_15cm_1kg": {
		"id": "nylon_leader_15cm_1kg",
		"name": "Нейлоновый поводок 15 см / 1 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "common",
		"price": 16,
		"level_required": 1,
		"image_path": "res://assets/ui/shop/leaders/nylon_leader_15cm_1kg.png",
		"description": "Короткий недорогой поводок для активной мелкой рыбы. Даёт хороший контроль при вываживании.",
		"stats": {
			"leader_type": "nylon",
			"material": "nylon",
			"length_cm": 15,
			"max_load_kg": 1.0,
			"max_load": 1.0,
			"strength": 1.0,
			"visibility": 0.035,
			"bite_protection": 0.00,
			"control_bonus": 0.05,
			"cautious_bite_bonus": -0.05,
			"small_fish_penalty": 0.01,
			"break_resistance": 0.88,
			"break_chance": 0.18,
			"durability": 1.0,
			"wear_rate": 0.022
		}
	},
	"nylon_leader_20cm_1kg": {
		"id": "nylon_leader_20cm_1kg",
		"name": "Нейлоновый поводок 20 см / 1 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "common",
		"price": 18,
		"image_path": "res://assets/ui/tackle/leaders/nylon_leader_20cm_1kg.png",
		"level_required": 1,
		"description": "Базовый стартовый поводок для плотвы, уклейки и мелкого карася. Дешёвый, универсальный, без ярких бонусов.",
		"stats": {
			"leader_type": "nylon",
			"material": "nylon",
			"length_cm": 20,
			"max_load_kg": 1.0,
			"max_load": 1.0,
			"strength": 1.0,
			"visibility": 0.040,
			"bite_protection": 0.00,
			"control_bonus": 0.00,
			"cautious_bite_bonus": 0.00,
			"small_fish_penalty": 0.00,
			"break_resistance": 0.92,
			"break_chance": 0.17,
			"durability": 1.0,
			"wear_rate": 0.020
		}
	},
	"nylon_leader_25cm_2kg": {
		"id": "nylon_leader_25cm_2kg",
		"name": "Нейлоновый поводок 25 см / 2 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "common",
		"price": 28,
		"image_path": "res://assets/ui/tackle/leaders/nylon_leader_25cm_2kg.png",
		"level_required": 1,
		"description": "Универсальный нейлоновый поводок для карася, подлещика и спокойной озёрной рыбы.",
		"stats": {
			"leader_type": "nylon",
			"material": "nylon",
			"length_cm": 25,
			"max_load_kg": 2.0,
			"max_load": 2.0,
			"strength": 2.0,
			"visibility": 0.055,
			"bite_protection": 0.00,
			"control_bonus": 0.00,
			"cautious_bite_bonus": 0.00,
			"small_fish_penalty": 0.02,
			"break_resistance": 0.98,
			"break_chance": 0.14,
			"durability": 1.0,
			"wear_rate": 0.019
		}
	},
	"nylon_leader_30cm_3kg": {
		"id": "nylon_leader_30cm_3kg",
		"name": "Нейлоновый поводок 30 см / 3 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "common",
		"price": 42,
		"image_path": "res://assets/ui/tackle/leaders/nylon_leader_30cm_3kg.png",
		"level_required": 1,
		"description": "Простой прочный поводок для уверенной ловли карася, подлещика и некрупного леща.",
		"stats": {
			"leader_type": "nylon",
			"material": "nylon",
			"length_cm": 30,
			"max_load_kg": 3.0,
			"max_load": 3.0,
			"strength": 3.0,
			"visibility": 0.070,
			"bite_protection": 0.00,
			"control_bonus": 0.00,
			"cautious_bite_bonus": 0.00,
			"small_fish_penalty": 0.03,
			"break_resistance": 1.02,
			"break_chance": 0.12,
			"durability": 1.0,
			"wear_rate": 0.018
		}
	},
	"fluoro_leader_25cm_2kg": {
		"id": "fluoro_leader_25cm_2kg",
		"name": "Флюорокарбоновый поводок 25 см / 2 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "uncommon",
		"price": 56,
		"image_path": "res://assets/ui/tackle/leaders/fluoro_leader_25cm_2kg.png",
		"level_required": 2,
		"description": "Малозаметный поводок для прозрачной воды и осторожной белой рыбы. Чуть менее гибкий, зато лучше провоцирует поклёвку.",
		"stats": {
			"leader_type": "fluorocarbon",
			"material": "fluorocarbon",
			"length_cm": 25,
			"max_load_kg": 2.0,
			"max_load": 2.0,
			"strength": 2.0,
			"visibility": 0.020,
			"bite_protection": 0.02,
			"control_bonus": -0.01,
			"cautious_bite_bonus": 0.05,
			"small_fish_penalty": 0.00,
			"break_resistance": 0.96,
			"break_chance": 0.13,
			"durability": 1.0,
			"wear_rate": 0.018
		}
	},
	"fluoro_leader_30cm_3kg": {
		"id": "fluoro_leader_30cm_3kg",
		"name": "Флюорокарбоновый поводок 30 см / 3 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "uncommon",
		"price": 74,
		"image_path": "res://assets/ui/tackle/leaders/fluoro_leader_30cm_3kg.png",
		"level_required": 3,
		"description": "Универсальный флюорокарбон для карася, подлещика и осторожного леща.",
		"stats": {
			"leader_type": "fluorocarbon",
			"material": "fluorocarbon",
			"length_cm": 30,
			"max_load_kg": 3.0,
			"max_load": 3.0,
			"strength": 3.0,
			"visibility": 0.026,
			"bite_protection": 0.03,
			"control_bonus": -0.01,
			"cautious_bite_bonus": 0.06,
			"small_fish_penalty": 0.01,
			"break_resistance": 0.99,
			"break_chance": 0.12,
			"durability": 1.0,
			"wear_rate": 0.017
		}
	},
	"fluoro_leader_40cm_5kg": {
		"id": "fluoro_leader_40cm_5kg",
		"name": "Флюорокарбоновый поводок 40 см / 5 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "rare",
		"price": 128,
		"image_path": "res://assets/ui/tackle/leaders/fluoro_leader_40cm_5kg.png",
		"level_required": 5,
		"description": "Длинный малозаметный поводок для осторожной крупной рыбы. Лучше даёт поклёвку, но немного снижает контроль.",
		"stats": {
			"leader_type": "fluorocarbon",
			"material": "fluorocarbon",
			"length_cm": 40,
			"max_load_kg": 5.0,
			"max_load": 5.0,
			"strength": 5.0,
			"visibility": 0.032,
			"bite_protection": 0.04,
			"control_bonus": -0.05,
			"cautious_bite_bonus": 0.12,
			"small_fish_penalty": 0.04,
			"break_resistance": 1.03,
			"break_chance": 0.10,
			"durability": 1.0,
			"wear_rate": 0.016
		}
	},
	"fluoro_leader_50cm_3kg": {
		"id": "fluoro_leader_50cm_3kg",
		"name": "Флюорокарбоновый поводок 50 см / 3 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "rare",
		"price": 104,
		"level_required": 4,
		"image_path": "res://assets/ui/shop/leaders/fluoro_leader_50cm_3kg.png",
		"description": "Длинный деликатный поводок для самой осторожной мирной рыбы. Хорошо маскирует снасть, но хуже контролируется на вываживании.",
		"stats": {
			"leader_type": "fluorocarbon",
			"material": "fluorocarbon",
			"length_cm": 50,
			"max_load_kg": 3.0,
			"max_load": 3.0,
			"strength": 3.0,
			"visibility": 0.024,
			"bite_protection": 0.03,
			"control_bonus": -0.05,
			"cautious_bite_bonus": 0.13,
			"small_fish_penalty": 0.02,
			"break_resistance": 0.98,
			"break_chance": 0.12,
			"durability": 1.0,
			"wear_rate": 0.017
		}
	},
	"braided_leader_25cm_5kg": {
		"id": "braided_leader_25cm_5kg",
		"name": "Плетёный поводок 25 см / 5 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "uncommon",
		"price": 92,
		"image_path": "res://assets/ui/tackle/leaders/braided_leader_25cm_5kg.png",
		"level_required": 3,
		"description": "Прочный поводок с хорошим контролем для крупного леща, карпа и амура. Более заметен в воде.",
		"stats": {
			"leader_type": "braided",
			"material": "braided",
			"length_cm": 25,
			"max_load_kg": 5.0,
			"max_load": 5.0,
			"strength": 5.0,
			"visibility": 0.105,
			"bite_protection": 0.06,
			"control_bonus": 0.04,
			"cautious_bite_bonus": -0.06,
			"small_fish_penalty": 0.06,
			"break_resistance": 1.15,
			"break_chance": 0.08,
			"durability": 1.0,
			"wear_rate": 0.015
		}
	},
	"braided_leader_30cm_8kg": {
		"id": "braided_leader_30cm_8kg",
		"name": "Плетёный поводок 30 см / 8 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "rare",
		"price": 148,
		"image_path": "res://assets/ui/tackle/leaders/braided_leader_30cm_8kg.png",
		"level_required": 6,
		"description": "Силовая плетёнка для крупной рыбы. Держит рывки и даёт контроль, но отпугивает осторожную мелочь.",
		"stats": {
			"leader_type": "braided",
			"material": "braided",
			"length_cm": 30,
			"max_load_kg": 8.0,
			"max_load": 8.0,
			"strength": 8.0,
			"visibility": 0.130,
			"bite_protection": 0.08,
			"control_bonus": 0.04,
			"cautious_bite_bonus": -0.07,
			"small_fish_penalty": 0.09,
			"break_resistance": 1.22,
			"break_chance": 0.07,
			"durability": 1.0,
			"wear_rate": 0.014
		}
	},
	"reinforced_leader_30cm_5kg": {
		"id": "reinforced_leader_30cm_5kg",
		"name": "Усиленный поводок 30 см / 5 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "uncommon",
		"price": 118,
		"image_path": "res://assets/ui/tackle/leaders/reinforced_leader_30cm_5kg.png",
		"level_required": 4,
		"description": "Усиленный поводок для крупного леща и карповой рыбы. Надёжнее тонкого нейлона, но грубее для осторожной мелочи.",
		"stats": {
			"leader_type": "reinforced",
			"material": "reinforced",
			"length_cm": 30,
			"max_load_kg": 5.0,
			"max_load": 5.0,
			"strength": 5.0,
			"visibility": 0.120,
			"bite_protection": 0.10,
			"control_bonus": 0.01,
			"cautious_bite_bonus": -0.09,
			"small_fish_penalty": 0.08,
			"break_resistance": 1.28,
			"break_chance": 0.06,
			"durability": 1.0,
			"wear_rate": 0.013
		}
	},
	"reinforced_leader_40cm_12kg": {
		"id": "reinforced_leader_40cm_12kg",
		"name": "Усиленный поводок 40 см / 12 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "rare",
		"price": 230,
		"image_path": "res://assets/ui/tackle/leaders/reinforced_leader_40cm_12kg.png",
		"level_required": 8,
		"description": "Мощный длинный поводок под крупного карпа, амура и тяжёлую рыбу. Сильно заметен для мелкой мирной рыбы.",
		"stats": {
			"leader_type": "reinforced",
			"material": "reinforced",
			"length_cm": 40,
			"max_load_kg": 12.0,
			"max_load": 12.0,
			"strength": 12.0,
			"visibility": 0.165,
			"bite_protection": 0.14,
			"control_bonus": -0.03,
			"cautious_bite_bonus": -0.02,
			"small_fish_penalty": 0.13,
			"break_resistance": 1.40,
			"break_chance": 0.05,
			"durability": 1.0,
			"wear_rate": 0.012
		}
	},
	"steel_leader_30cm_12kg": {
		"id": "steel_leader_30cm_12kg",
		"name": "Стальной поводок 30 см / 12 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "rare",
		"price": 260,
		"image_path": "res://assets/ui/tackle/leaders/steel_leader_30cm_12kg.png",
		"level_required": 9,
		"description": "Стальной поводок для хищника. Защищает от перекуса, но заметен и плохо подходит для осторожной мирной рыбы.",
		"stats": {
			"leader_type": "steel",
			"material": "steel",
			"length_cm": 30,
			"max_load_kg": 12.0,
			"max_load": 12.0,
			"strength": 12.0,
			"visibility": 0.240,
			"bite_protection": 0.26,
			"control_bonus": -0.01,
			"cautious_bite_bonus": -0.18,
			"small_fish_penalty": 0.17,
			"break_resistance": 1.48,
			"break_chance": 0.04,
			"durability": 1.0,
			"wear_rate": 0.010
		}
	},
	"steel_leader_40cm_20kg": {
		"id": "steel_leader_40cm_20kg",
		"name": "Стальной поводок 40 см / 20 кг",
		"type": "leader",
		"category": "leader",
		"rarity": "trophy",
		"price": 420,
		"image_path": "res://assets/ui/tackle/leaders/steel_leader_40cm_20kg.png",
		"level_required": 12,
		"description": "Тяжёлый стальной поводок для будущей ловли щуки, сома и спиннинга. Максимальная защита, минимальная деликатность.",
		"stats": {
			"leader_type": "steel",
			"material": "steel",
			"length_cm": 40,
			"max_load_kg": 20.0,
			"max_load": 20.0,
			"strength": 20.0,
			"visibility": 0.280,
			"bite_protection": 0.30,
			"control_bonus": -0.05,
			"cautious_bite_bonus": -0.16,
			"small_fish_penalty": 0.20,
			"break_resistance": 1.58,
			"break_chance": 0.035,
			"durability": 1.0,
			"wear_rate": 0.009
		}
	},
	"float_feather_basic": {
		"id": "float_feather_basic",
		"name": "Поплавок «Перо»",
		"type": "float",
		"category": "float",
		"float_type": "feather",
		"rarity": "common",
		"price": 65,
		"image_path": "res://assets/ui/tackle/floats/float_feather.png",
		"description": "Очень чувствительный поплавок для мелкой осторожной рыбы в тихой воде.",
		"stats": {
			"float_type": "feather",
			"buoyancy": 0.72,
			"sensitivity": 0.97,
			"stability": 0.52,
			"wind_resistance": 0.35,
			"drift_resistance": 0.32,
			"cast_distance_bonus": -0.04,
			"bite_visibility": 0.88,
			"false_bite_resistance": 0.35,
			"depth_min": 0.2,
			"depth_max": 1.4,
			"night_bonus": 0.0,
			"vegetation_control": 0.55,
			"heavy_bait_support": 0.30,
			"recommended_spots": ["old_oak_pier", "green_duckweed", "quiet_water_pier"]
		}
	},
	"float_drop_basic": {
		"id": "float_drop_basic",
		"name": "Поплавок «Капля»",
		"type": "float",
		"category": "float",
		"float_type": "drop",
		"rarity": "common",
		"price": 120,
		"image_path": "res://assets/ui/tackle/floats/float_drop.png",
		"description": "Универсальный поплавок для спокойной воды и камышей.",
		"stats": {
			"float_type": "drop",
			"buoyancy": 1.0,
			"sensitivity": 0.90,
			"stability": 0.85,
			"wind_resistance": 0.70,
			"drift_resistance": 0.70,
			"cast_distance_bonus": 0.0,
			"bite_visibility": 0.90,
			"false_bite_resistance": 0.75,
			"depth_min": 0.3,
			"depth_max": 2.2,
			"night_bonus": 0.0,
			"vegetation_control": 0.65,
			"heavy_bait_support": 0.65,
			"recommended_spots": ["reeds_pier", "quiet_water_pier"]
		}
	},
	"float_spindle_basic": {
		"id": "float_spindle_basic",
		"name": "Поплавок «Веретено»",
		"type": "float",
		"category": "float",
		"float_type": "spindle",
		"rarity": "uncommon",
		"price": 155,
		"image_path": "res://assets/ui/tackle/floats/float_spindle.png",
		"description": "Точный поплавок для осторожной плотвы, карася и подлещика.",
		"stats": {
			"float_type": "spindle",
			"buoyancy": 0.86,
			"sensitivity": 0.94,
			"stability": 0.70,
			"wind_resistance": 0.55,
			"drift_resistance": 0.55,
			"cast_distance_bonus": 0.0,
			"bite_visibility": 0.92,
			"false_bite_resistance": 0.58,
			"depth_min": 0.3,
			"depth_max": 2.0,
			"night_bonus": 0.0,
			"vegetation_control": 0.60,
			"heavy_bait_support": 0.45,
			"recommended_spots": ["quiet_water_pier", "reeds_pier", "morning_pier"]
		}
	},
	"float_barrel_basic": {
		"id": "float_barrel_basic",
		"name": "Поплавок «Бочонок»",
		"type": "float",
		"category": "float",
		"float_type": "barrel",
		"rarity": "uncommon",
		"price": 180,
		"image_path": "res://assets/ui/tackle/floats/float_barrel.png",
		"description": "Устойчивый поплавок для камышей, волны и тяжёлой наживки.",
		"stats": {
			"float_type": "barrel",
			"buoyancy": 1.35,
			"sensitivity": 0.62,
			"stability": 0.96,
			"wind_resistance": 0.90,
			"drift_resistance": 0.88,
			"cast_distance_bonus": -0.01,
			"bite_visibility": 0.70,
			"false_bite_resistance": 0.92,
			"depth_min": 0.5,
			"depth_max": 2.8,
			"night_bonus": 0.0,
			"vegetation_control": 0.88,
			"heavy_bait_support": 0.95,
			"recommended_spots": ["reeds_pier", "frog_backwater", "old_boat_pier"]
		}
	},
	"float_waggler_basic": {
		"id": "float_waggler_basic",
		"name": "Поплавок «Вагглер»",
		"type": "float",
		"category": "float",
		"float_type": "waggler",
		"rarity": "rare",
		"price": 260,
		"image_path": "res://assets/ui/tackle/floats/float_waggler.png",
		"description": "Дальний заброс для открытой воды, где важны дистанция и стабильность.",
		"stats": {
			"float_type": "waggler",
			"buoyancy": 1.10,
			"sensitivity": 0.72,
			"stability": 0.82,
			"wind_resistance": 0.78,
			"drift_resistance": 0.82,
			"cast_distance_bonus": 0.18,
			"bite_visibility": 0.76,
			"false_bite_resistance": 0.78,
			"depth_min": 0.8,
			"depth_max": 3.5,
			"night_bonus": 0.0,
			"vegetation_control": 0.42,
			"heavy_bait_support": 0.72,
			"recommended_spots": ["morning_pier", "deep_pier", "cold_water", "quiet_water_pier"]
		}
	},
	"float_sliding_basic": {
		"id": "float_sliding_basic",
		"name": "Поплавок «Скользящий»",
		"type": "float",
		"category": "float",
		"float_type": "sliding",
		"rarity": "rare",
		"price": 310,
		"image_path": "res://assets/ui/tackle/floats/float_sliding.png",
		"description": "Поплавок для глубины и ям, когда обычная оснастка уже некомфортна.",
		"stats": {
			"float_type": "sliding",
			"buoyancy": 1.20,
			"sensitivity": 0.76,
			"stability": 0.74,
			"wind_resistance": 0.64,
			"drift_resistance": 0.66,
			"cast_distance_bonus": 0.06,
			"bite_visibility": 0.78,
			"false_bite_resistance": 0.70,
			"depth_min": 1.5,
			"depth_max": 6.5,
			"night_bonus": 0.0,
			"vegetation_control": 0.55,
			"heavy_bait_support": 0.80,
			"recommended_spots": ["dark_hole", "deep_pier", "cold_water", "mist_pier"]
		}
	},
	"float_glow_feather": {
		"id": "float_glow_feather",
		"name": "Светящееся перо",
		"type": "float",
		"category": "float",
		"float_type": "glow_feather",
		"rarity": "rare",
		"price": 240,
		"image_path": "res://assets/ui/tackle/floats/float_glow_feather.png",
		"description": "Ночная версия пера: высокая видимость поклёвки в темноте при слабой защите от ветра.",
		"stats": {
			"float_type": "glow_feather",
			"buoyancy": 0.74,
			"sensitivity": 0.95,
			"stability": 0.50,
			"wind_resistance": 0.32,
			"drift_resistance": 0.30,
			"cast_distance_bonus": -0.04,
			"bite_visibility": 0.86,
			"false_bite_resistance": 0.36,
			"depth_min": 0.2,
			"depth_max": 1.5,
			"night_bonus": 0.35,
			"vegetation_control": 0.55,
			"heavy_bait_support": 0.28,
			"recommended_spots": ["old_oak_pier", "mist_pier", "frog_backwater"]
		}
	},
	"float_goose_feather": {
		"id": "float_goose_feather",
		"name": "Goose Feather Float",
		"display_name_ru": "Гусиное перо",
		"type": "float",
		"category": "float",
		"float_type": "feather",
		"base_type": "feather",
		"rarity": "uncommon",
		"price": 180,
		"image_path": "res://assets/ui/tackle/floats/float_goose_feather.png",
		"bonus_tags": ["Very Sensitive", "Careful Bites", "Calm Water"],
		"description": "Extremely sensitive feather float for careful bites in calm water.",
		"description_ru": "Очень чувствительное гусиное перо для осторожных поклёвок в спокойной воде.",
		"stats": {
			"float_type": "feather",
			"base_type": "feather",
			"buoyancy": 0.70,
			"sensitivity": 0.98,
			"stability": 0.52,
			"wind_resistance": 0.38,
			"drift_resistance": 0.36,
			"cast_distance_bonus": -0.03,
			"bite_visibility": 0.95,
			"false_bite_resistance": 0.45,
			"depth_min": 0.2,
			"depth_max": 1.5,
			"night_bonus": 0.0,
			"vegetation_control": 0.45,
			"heavy_bait_support": 0.25,
			"recommended_spots": ["quiet_water_pier", "old_oak_pier"],
			"bonus_tags": ["Very Sensitive", "Careful Bites", "Calm Water"]
		}
	},
	"float_lacquered_feather": {
		"id": "float_lacquered_feather",
		"name": "Lacquered Feather Float",
		"display_name_ru": "Лакированное перо",
		"type": "float",
		"category": "float",
		"float_type": "feather",
		"base_type": "feather",
		"rarity": "rare",
		"price": 320,
		"image_path": "res://assets/ui/tackle/floats/float_lacquered_feather.png",
		"bonus_tags": ["Sensitive", "Stable Feather", "Clean Bite Feedback"],
		"description": "A polished feather float with better stability and clean bite feedback.",
		"description_ru": "Лакированное перо с улучшенной стабильностью и чистым отображением поклёвки.",
		"stats": {
			"float_type": "feather",
			"base_type": "feather",
			"buoyancy": 0.76,
			"sensitivity": 0.94,
			"stability": 0.68,
			"wind_resistance": 0.48,
			"drift_resistance": 0.44,
			"cast_distance_bonus": 0.0,
			"bite_visibility": 0.96,
			"false_bite_resistance": 0.60,
			"depth_min": 0.2,
			"depth_max": 1.8,
			"night_bonus": 0.0,
			"vegetation_control": 0.48,
			"heavy_bait_support": 0.30,
			"recommended_spots": ["quiet_water_pier", "old_oak_pier", "morning_pier"],
			"bonus_tags": ["Sensitive", "Stable Feather", "Clean Bite Feedback"]
		}
	},
	"float_reed_drop": {
		"id": "float_reed_drop",
		"name": "Reed Drop Float",
		"display_name_ru": "Камышовая капля",
		"type": "float",
		"category": "float",
		"float_type": "drop",
		"base_type": "drop",
		"rarity": "uncommon",
		"price": 260,
		"image_path": "res://assets/ui/tackle/floats/float_reed_drop.png",
		"bonus_tags": ["Reeds", "Vegetation Control", "Stable"],
		"description": "A drop float tuned for reeds, grass and quiet backwaters.",
		"description_ru": "Капля для камышей, травы и тихих заводей. Лучше контролирует снасть в заросших местах.",
		"stats": {
			"float_type": "drop",
			"base_type": "drop",
			"buoyancy": 1.05,
			"sensitivity": 0.82,
			"stability": 0.82,
			"wind_resistance": 0.68,
			"drift_resistance": 0.78,
			"cast_distance_bonus": -0.02,
			"bite_visibility": 0.86,
			"false_bite_resistance": 0.78,
			"depth_min": 0.3,
			"depth_max": 2.4,
			"night_bonus": 0.0,
			"vegetation_control": 0.92,
			"heavy_bait_support": 0.62,
			"recommended_spots": ["reeds_pier", "frog_backwater"],
			"bonus_tags": ["Reeds", "Vegetation Control", "Stable"]
		}
	},
	"float_sport_drop": {
		"id": "float_sport_drop",
		"name": "Sport Drop Float",
		"display_name_ru": "Спортивная капля",
		"type": "float",
		"category": "float",
		"float_type": "drop",
		"base_type": "drop",
		"rarity": "rare",
		"price": 420,
		"image_path": "res://assets/ui/tackle/floats/float_sport_drop.png",
		"bonus_tags": ["Sport", "Fast Bite Reading", "Accurate Hook Timing"],
		"description": "A responsive sport float for fast bite reading and accurate hook timing.",
		"description_ru": "Спортивная капля для быстрой реакции на поклёвку и точной подсечки.",
		"stats": {
			"float_type": "drop",
			"base_type": "drop",
			"buoyancy": 0.95,
			"sensitivity": 0.92,
			"stability": 0.76,
			"wind_resistance": 0.62,
			"drift_resistance": 0.64,
			"cast_distance_bonus": 0.04,
			"bite_visibility": 0.96,
			"false_bite_resistance": 0.70,
			"depth_min": 0.3,
			"depth_max": 2.2,
			"night_bonus": 0.0,
			"vegetation_control": 0.58,
			"heavy_bait_support": 0.48,
			"hook_timing_bonus": 0.10,
			"recommended_spots": ["quiet_water_pier", "morning_pier"],
			"bonus_tags": ["Sport", "Fast Bite Reading", "Accurate Hook Timing"]
		}
	},
	"float_night_barrel": {
		"id": "float_night_barrel",
		"name": "Night Barrel Float",
		"display_name_ru": "Ночной бочонок",
		"type": "float",
		"category": "float",
		"float_type": "barrel",
		"base_type": "barrel",
		"rarity": "rare",
		"price": 520,
		"image_path": "res://assets/ui/tackle/floats/float_night_barrel.png",
		"bonus_tags": ["Night Fishing", "Heavy Bait", "Wind Stable"],
		"description": "A stable glowing barrel float for night fishing and heavy bait.",
		"description_ru": "Устойчивый светящийся бочонок для ночной ловли, ветра и тяжёлой наживки.",
		"stats": {
			"float_type": "barrel",
			"base_type": "barrel",
			"buoyancy": 1.35,
			"sensitivity": 0.58,
			"stability": 0.94,
			"wind_resistance": 0.88,
			"drift_resistance": 0.86,
			"cast_distance_bonus": -0.03,
			"bite_visibility": 0.78,
			"false_bite_resistance": 0.88,
			"depth_min": 0.5,
			"depth_max": 3.0,
			"night_bonus": 0.35,
			"vegetation_control": 0.72,
			"heavy_bait_support": 0.92,
			"recommended_spots": ["reeds_pier", "frog_backwater", "dark_hole"],
			"bonus_tags": ["Night Fishing", "Heavy Bait", "Wind Stable"]
		}
	},
	"float_reinforced_barrel": {
		"id": "float_reinforced_barrel",
		"name": "Reinforced Barrel Float",
		"display_name_ru": "Усиленный бочонок",
		"type": "float",
		"category": "float",
		"float_type": "barrel",
		"base_type": "barrel",
		"rarity": "epic",
		"price": 850,
		"image_path": "res://assets/ui/tackle/floats/float_reinforced_barrel.png",
		"bonus_tags": ["Reinforced", "Heavy Bait", "Wind Stable"],
		"description": "A reinforced barrel float built for wind, waves and heavy bait.",
		"description_ru": "Усиленный бочонок для ветра, волны и тяжёлой наживки. Плохо подходит для осторожной мелочи.",
		"stats": {
			"float_type": "barrel",
			"base_type": "barrel",
			"buoyancy": 1.55,
			"sensitivity": 0.48,
			"stability": 1.00,
			"wind_resistance": 0.95,
			"drift_resistance": 0.94,
			"cast_distance_bonus": -0.05,
			"bite_visibility": 0.76,
			"false_bite_resistance": 0.95,
			"depth_min": 0.6,
			"depth_max": 3.2,
			"night_bonus": 0.0,
			"vegetation_control": 0.78,
			"heavy_bait_support": 1.00,
			"recommended_spots": ["reeds_pier", "frog_backwater", "dark_hole"],
			"bonus_tags": ["Reinforced", "Heavy Bait", "Wind Stable"]
		}
	},
	"float_long_cast_waggler": {
		"id": "float_long_cast_waggler",
		"name": "Long Cast Waggler",
		"display_name_ru": "Дальнобойный вагглер",
		"type": "float",
		"category": "float",
		"float_type": "waggler",
		"base_type": "waggler",
		"rarity": "rare",
		"price": 640,
		"image_path": "res://assets/ui/tackle/floats/float_long_cast_waggler.png",
		"bonus_tags": ["Long Cast", "Open Water", "Distance"],
		"description": "A long-range waggler for open water and distant casts.",
		"description_ru": "Дальнобойный вагглер для открытой воды и дальнего заброса.",
		"stats": {
			"float_type": "waggler",
			"base_type": "waggler",
			"buoyancy": 1.15,
			"sensitivity": 0.68,
			"stability": 0.82,
			"wind_resistance": 0.82,
			"drift_resistance": 0.76,
			"cast_distance_bonus": 0.25,
			"bite_visibility": 0.82,
			"false_bite_resistance": 0.78,
			"depth_min": 0.8,
			"depth_max": 3.8,
			"night_bonus": 0.0,
			"vegetation_control": 0.42,
			"heavy_bait_support": 0.65,
			"long_range_accuracy_bonus": 0.12,
			"recommended_spots": ["morning_pier", "quiet_water_pier"],
			"bonus_tags": ["Long Cast", "Open Water", "Distance"]
		}
	},
	"float_self_cocking_waggler": {
		"id": "float_self_cocking_waggler",
		"name": "Self-Cocking Waggler",
		"display_name_ru": "Самоогружаемый вагглер",
		"type": "float",
		"category": "float",
		"float_type": "waggler",
		"base_type": "waggler",
		"rarity": "epic",
		"price": 980,
		"image_path": "res://assets/ui/tackle/floats/float_self_cocking_waggler.png",
		"bonus_tags": ["Easy Setup", "Stable", "Long Cast"],
		"description": "A self-cocking waggler that is easy to set up and stable at distance.",
		"description_ru": "Самоогружаемый вагглер: легко настраивается, стабилен и хорошо работает на дистанции.",
		"stats": {
			"float_type": "waggler",
			"base_type": "waggler",
			"buoyancy": 1.20,
			"sensitivity": 0.72,
			"stability": 0.94,
			"wind_resistance": 0.84,
			"drift_resistance": 0.82,
			"cast_distance_bonus": 0.18,
			"bite_visibility": 0.88,
			"false_bite_resistance": 0.90,
			"depth_min": 0.8,
			"depth_max": 4.0,
			"night_bonus": 0.0,
			"vegetation_control": 0.48,
			"heavy_bait_support": 0.74,
			"setup_comfort": 0.15,
			"recommended_spots": ["morning_pier", "quiet_water_pier", "cold_water"],
			"bonus_tags": ["Easy Setup", "Stable", "Long Cast"]
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_24.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_22.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_20.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_18.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_16.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_14.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_12.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_10.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_8.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_6.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_4.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_2.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_1.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_1_0.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_2_0.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_3_0.png",
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
		"image_path": "res://assets/ui/shop/hooks/riverstart_basic_hook_4_0.png",
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
		"image_path": "res://assets/ui/shop/hooks/small_hook_12.png",
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
		"image_path": "res://assets/ui/shop/hooks/medium_hook_8.png",
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
		"image_path": "res://assets/ui/shop/hooks/large_hook_4.png",
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
		"price": 2.8,
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
		"price": 1.6,
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
		"price": 4.8,
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
		"price": 5.2,
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
		"price": 5.6,
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
		"price": 5.8,
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
		"image_path": "res://assets/ui/shop/baits/small_live_bait.png",
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
		"image_path": "res://assets/ui/shop/baits/frog_bait.png",
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
		"image_path": "res://assets/ui/shop/baits/shrimp.png",
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
		"image_path": "res://assets/ui/shop/baits/snail.png",
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
		"image_path": "res://assets/ui/shop/baits/boilie_simple.png",
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
const DEFAULT_TACKLE_TYPE := "float"
const TACKLE_TYPE_ALIASES := {
	"": DEFAULT_TACKLE_TYPE,
	"float": DEFAULT_TACKLE_TYPE,
	"pole": DEFAULT_TACKLE_TYPE,
	"spinning": "spinning",
	"feeder": "feeder",
	"sea": "sea"
}
const TACKLE_TYPE_TITLES := {
	"float": "Поплавочная",
	"spinning": "Спиннинг",
	"feeder": "Фидер",
	"sea": "Морская"
}
const TACKLE_SLOT_SCHEMAS := {
	"float": [
		{"id": "rod", "title": "Удилище", "item_categories": ["rod"], "required": true},
		{"id": "line", "title": "Леска", "item_categories": ["line"], "required": true},
		{"id": "leader", "title": "Поводок", "item_categories": ["leader"], "required": true},
		{"id": "float", "title": "Поплавок", "item_categories": ["float"], "required": true},
		{"id": "hook", "title": "Крючок", "item_categories": ["hook"], "required": true},
		{"id": "bait", "title": "Наживка", "item_categories": ["bait"], "required": true},
		{"id": "bait_2", "title": "Наживка 2", "item_categories": ["bait"], "required": false, "skill": "second_bait", "locked_text": "Требуется навык «Бутерброд»"}
	],
	"spinning": [
		{"id": "rod", "title": "Удилище", "item_categories": ["rod"], "required": true},
		{"id": "reel", "title": "Катушка", "item_categories": ["reel"], "required": true},
		{"id": "line", "title": "Леска/шнур", "item_categories": ["line"], "required": true},
		{"id": "leader", "title": "Поводок", "item_categories": ["leader"], "required": false},
		{"id": "lure", "title": "Приманка", "item_categories": ["lure"], "required": true}
	],
	"feeder": [
		{"id": "rod", "title": "Удилище", "item_categories": ["rod"], "required": true},
		{"id": "reel", "title": "Катушка", "item_categories": ["reel"], "required": true},
		{"id": "line", "title": "Леска", "item_categories": ["line"], "required": true},
		{"id": "feeder_rig", "title": "Оснастка/кормушка", "item_categories": ["feeder_rig"], "required": true},
		{"id": "leader", "title": "Поводок", "item_categories": ["leader"], "required": true},
		{"id": "hook", "title": "Крючок", "item_categories": ["hook"], "required": true},
		{"id": "bait", "title": "Наживка", "item_categories": ["bait"], "required": true},
		{"id": "bait_2", "title": "Наживка 2", "item_categories": ["bait"], "required": false, "skill": "second_bait", "locked_text": "Требуется навык «Бутерброд»"}
	],
	"sea": [
		{"id": "rod", "title": "Удилище", "item_categories": ["rod"], "required": true},
		{"id": "reel", "title": "Катушка", "item_categories": ["reel"], "required": true},
		{"id": "line", "title": "Леска/шнур", "item_categories": ["line"], "required": true},
		{"id": "leader", "title": "Поводок", "item_categories": ["leader"], "required": true},
		{"id": "hook_or_lure", "title": "Крючок или приманка", "item_categories": ["hook", "lure"], "required": true},
		{"id": "sinker_or_rig", "title": "Груз/оснастка", "item_categories": ["sinker", "sea_rig"], "required": false},
		{"id": "bait", "title": "Наживка", "item_categories": ["bait"], "required": false}
	]
}
const TACKLE_SLOTS := ["rod", "line", "leader", "hook", "float", "bait", "bait_2", "reel", "lure", "feeder_rig", "hook_or_lure", "sinker_or_rig"]
const REQUIRED_TACKLE_SLOTS := ["rod", "line", "leader", "hook", "float", "bait"]
const QUICK_TACKLE_CATEGORIES := ["line", "leader", "float", "hook", "bait"]
const TACKLE_SLOT_ITEM_CATEGORIES := {
	"rod": "rod",
	"line": "line",
	"leader": "leader",
	"hook": "hook",
	"float": "float",
	"bait": "bait",
	"bait_2": "bait",
	"reel": "reel",
	"lure": "lure",
	"feeder_rig": "feeder_rig",
	"hook_or_lure": "hook",
	"sinker_or_rig": "sinker"
}
const RESCUE_KIT_MONEY_LIMIT := 10.0
const RESCUE_KIT_LINE_ID := "lakeline_nylon_basic_1_5kg"
const RESCUE_KIT_PRIMARY_HOOK_ID := "riverstart_basic_hook_16"
const RESCUE_KIT_FALLBACK_HOOK_ID := "small_hook_12"
const REPAIR_COST_MULTIPLIER := 0.35
const REPAIR_BLOCK_WEAR_PERCENT := 90
const BROKEN_WEAR_PERCENT := 100

var money: float = 0.0
var alpha_tester_bonus_claimed := false
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 175
var claimed_level_rewards: Dictionary = {}
var skill_points: int = 0
var total_skill_points_earned: int = 0
var learned_skills: Dictionary = {}
var player_name: String = "Рыбак"
var current_waterbody: String = "agamin_lake"
var unlocked_waterbodies: Array = ["agamin_lake"]
var current_spot: String = "old_oak_pier"
var unlocked_spots: Array = ["old_oak_pier"]
var upgrades: Array = []
var fishing_depth: float = 0.8
var owned_items: Array = get_default_owned_items()
var current_tackle: Dictionary = get_default_tackle()
var recent_tackle_items: Dictionary = get_default_recent_tackle_items()
var equipped_clothing: Dictionary = get_default_equipped_clothing()
var starter_survival_kit_granted := false
var health: float = 100.0
var body_temperature: float = 36.6
var hunger: float = 100.0
var total_fish_caught := 0
var total_fish_weight: float = 0.0
var daily_catch_day: int = 1
var daily_fish_weight: float = 0.0
var best_daily_fish_weight: float = 0.0
var total_trophies_caught := 0
var total_rarity_caught := 0
var biggest_fish := {}
var biggest_fish_by_species := {}
var trophy_catches := []
var personal_records := {}
var rescue_kit_claims_total := 0
var rescue_kit_last_claim_day := -1

func ensure_condition_defaults() -> bool:
	var previous_health := float(health)
	var previous_temperature := float(body_temperature)
	var previous_hunger := float(hunger)
	if previous_health <= 0.0:
		health = 40.0
	else:
		health = clampf(previous_health, 0.0, 100.0)
	body_temperature = clampf(previous_temperature, 30.0, 42.0)
	hunger = clampf(previous_hunger, 0.0, 100.0)
	return (
		abs(previous_health - float(health)) > 0.001
		or abs(previous_temperature - float(body_temperature)) > 0.001
		or abs(previous_hunger - float(hunger)) > 0.001
	)

func get_condition_save_data() -> Dictionary:
	ensure_condition_defaults()
	return {
		"health": health,
		"body_temperature": body_temperature,
		"hunger": hunger
	}

func get_default_equipped_clothing() -> Dictionary:
	return {
		"torso": "basic_tshirt",
		"legs": "basic_pants",
		"shoes": "basic_sneakers",
		"head": "",
		"outerwear": ""
	}

func get_survival_catalog_item(item_id: String) -> Dictionary:
	if not SURVIVAL_ITEM_CATALOG.has(item_id):
		return {}
	return _normalize_survival_catalog_item(SURVIVAL_ITEM_CATALOG[item_id])

func get_survival_catalog_items(category_filter: String = "all") -> Array:
	var items: Array = []
	for item_id in SURVIVAL_ITEM_CATALOG.keys():
		var item := get_survival_catalog_item(str(item_id))
		if item.is_empty():
			continue
		var category := str(item.get("category", "misc"))
		var shop_category := str(item.get("shop_category", category))
		if (
			category_filter == "all"
			or category == category_filter
			or shop_category == category_filter
			or (category_filter == "food" and ["food", "drink"].has(category))
			or (category_filter == "clothing" and ["clothing", "shelter"].has(category))
		):
			items.append(item)
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var order := {"food": 0, "drink": 1, "clothing": 2, "shelter": 3}
		var category_a := str(a.get("category", "misc"))
		var category_b := str(b.get("category", "misc"))
		var order_a := int(order.get(category_a, 9))
		var order_b := int(order.get(category_b, 9))
		if order_a == order_b:
			return float(a.get("price", 0.0)) < float(b.get("price", 0.0))
		return order_a < order_b
	)
	return items

func get_survival_shop_items(shop_category: String) -> Array:
	var items: Array = []
	for item in get_survival_catalog_items("all"):
		if str(item.get("shop_category", "")) != shop_category:
			continue
		if STARTER_CLOTHING_ITEM_IDS.has(str(item.get("id", ""))):
			continue
		var shop_item: Dictionary = item.duplicate(true)
		shop_item["quantity"] = 1
		shop_item["icon"] = _get_item_icon(str(shop_item.get("category", "misc")))
		items.append(shop_item)
	return items

func _normalize_survival_catalog_item(raw_item: Dictionary) -> Dictionary:
	var item := raw_item.duplicate(true)
	var category := str(item.get("category", item.get("type", "misc")))
	item["id"] = str(item.get("id", ""))
	item["name"] = str(item.get("name", item.get("display_name_ru", "-")))
	item["display_name_ru"] = str(item.get("display_name_ru", item.get("name", "-")))
	item["type"] = str(item.get("type", category))
	item["category"] = category
	item["shop_category"] = str(item.get("shop_category", category))
	item["rarity"] = str(item.get("rarity", "common"))
	item["price"] = float(item.get("price", 0.0))
	item["image_path"] = str(item.get("image_path", ""))
	item["description"] = str(item.get("description", ""))
	item["description_ru"] = str(item.get("description_ru", item.get("description", "")))
	var stats: Dictionary = item.get("stats", {}).duplicate(true) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}
	item["stats"] = stats
	return item

func _is_survival_item_category(category: String) -> bool:
	return SURVIVAL_ITEM_CATEGORIES.has(category)

func is_survival_inventory_item(item: Dictionary) -> bool:
	var category := str(item.get("category", item.get("type", "")))
	return _is_survival_item_category(category)

func _make_owned_survival_item(item_id: String, quantity: int = 1) -> Dictionary:
	var item := get_survival_catalog_item(item_id)
	if item.is_empty():
		return {}
	item["quantity"] = max(quantity, 1)
	return _normalize_owned_item(item)

func initialize_new_player_survival_state() -> void:
	equipped_clothing = get_default_equipped_clothing()
	_grant_starter_survival_items(true)
	starter_survival_kit_granted = true

func migrate_survival_state(saved_equipped_clothing, saved_starter_kit_granted, had_starter_flag: bool) -> bool:
	var changed := false
	set_equipped_clothing_from_save(saved_equipped_clothing)

	for item_id in STARTER_CLOTHING_ITEM_IDS:
		if _get_owned_item_quantity(str(item_id)) <= 0:
			var clothing_item := _make_owned_survival_item(str(item_id), 1)
			if not clothing_item.is_empty():
				add_owned_item(clothing_item, 1)
				changed = true
		var starter_item := get_survival_catalog_item(str(item_id))
		var slot := _get_clothing_slot(starter_item)
		if slot != "" and str(equipped_clothing.get(slot, "")) == "":
			equipped_clothing[slot] = str(item_id)
			changed = true

	if had_starter_flag:
		starter_survival_kit_granted = bool(saved_starter_kit_granted)
	else:
		if not _has_any_starter_supply_item():
			_grant_starter_survival_items(true)
		starter_survival_kit_granted = true
		changed = true

	return changed

func _grant_starter_survival_items(include_supplies: bool) -> void:
	for item_id in STARTER_CLOTHING_ITEM_IDS:
		if _get_owned_item_quantity(str(item_id)) <= 0:
			var clothing_item := _make_owned_survival_item(str(item_id), 1)
			if not clothing_item.is_empty():
				add_owned_item(clothing_item, 1)
	if include_supplies:
		for supply in STARTER_SUPPLY_ITEMS:
			var supply_id := str(supply.get("id", ""))
			var quantity: int = maxi(int(supply.get("quantity", 1)), 1)
			var supply_item := _make_owned_survival_item(supply_id, quantity)
			if not supply_item.is_empty():
				add_owned_item(supply_item, quantity)

func _has_any_starter_supply_item() -> bool:
	for supply in STARTER_SUPPLY_ITEMS:
		if _get_owned_item_quantity(str(supply.get("id", ""))) > 0:
			return true
	return false

func get_equipped_clothing_save_data() -> Dictionary:
	return equipped_clothing.duplicate(true)

func set_equipped_clothing_from_save(saved_data) -> void:
	var defaults := get_default_equipped_clothing()
	equipped_clothing = defaults.duplicate(true)
	if typeof(saved_data) != TYPE_DICTIONARY:
		return
	for slot in defaults.keys():
		var item_id := str((saved_data as Dictionary).get(slot, ""))
		if item_id == "":
			equipped_clothing[slot] = ""
			continue
		var item := get_owned_item(item_id)
		if item.is_empty():
			continue
		if str(item.get("category", "")) != "clothing":
			continue
		var item_slot := _get_clothing_slot(item)
		if item_slot == slot:
			equipped_clothing[slot] = item_id

func get_clothing_slot_title(slot: String) -> String:
	return str(CLOTHING_SLOTS.get(slot, slot))

func _get_clothing_slot(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {}) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}
	return str(stats.get("clothing_slot", item.get("clothing_slot", "")))

func is_clothing_item_equipped(item_id: String) -> bool:
	for slot in equipped_clothing.keys():
		if str(equipped_clothing.get(slot, "")) == item_id:
			return true
	return false

func equip_clothing_item(item_id: String) -> Dictionary:
	var item := get_owned_item(item_id)
	if item.is_empty() or str(item.get("category", "")) != "clothing":
		return {"success": false, "message": "Этот предмет нельзя надеть."}
	var slot := _get_clothing_slot(item)
	if slot == "":
		return {"success": false, "message": "У предмета не задан слот одежды."}
	equipped_clothing[slot] = item_id
	return {
		"success": true,
		"message": "Надето: %s" % str(item.get("display_name_ru", item.get("name", "-"))),
		"slot": slot
	}

func unequip_clothing_item(item_id: String) -> Dictionary:
	for slot in equipped_clothing.keys():
		if str(equipped_clothing.get(slot, "")) != item_id:
			continue
		equipped_clothing[slot] = ""
		return {"success": true, "message": "Снято: %s" % str(get_owned_item(item_id).get("display_name_ru", get_owned_item(item_id).get("name", "-"))), "slot": slot}
	return {"success": false, "message": "Этот предмет не надет."}

func get_clothing_protection() -> Dictionary:
	var totals := {
		"cold_protection": 0.0,
		"wind_protection": 0.0,
		"rain_protection": 0.0,
		"heat_protection": 0.0,
		"warmth": 0.0,
		"heat_penalty": 0.0
	}
	for slot in equipped_clothing.keys():
		var item_id := str(equipped_clothing.get(slot, ""))
		if item_id == "":
			continue
		var item := get_owned_item(item_id)
		if item.is_empty():
			continue
		var stats: Dictionary = item.get("stats", {}) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}
		for key in totals.keys():
			totals[key] = float(totals[key]) + float(stats.get(key, 0.0))
	for key in totals.keys():
		totals[key] = clampf(float(totals[key]), 0.0, 1.5)
	return totals

func use_survival_item(item_id: String) -> Dictionary:
	var item := get_owned_item(item_id)
	if item.is_empty():
		return {"success": false, "message": "Предмет не найден."}
	var category := str(item.get("category", ""))
	if category == "clothing":
		if is_clothing_item_equipped(item_id):
			return unequip_clothing_item(item_id)
		return equip_clothing_item(item_id)
	if category == "food" or category == "drink":
		if int(item.get("quantity", 0)) <= 0:
			return {"success": false, "message": "Предмет закончился."}
		var condition_manager := get_node_or_null("/root/PlayerConditionManager")
		var result := {"success": false, "message": "Сейчас нельзя использовать этот предмет."}
		if condition_manager != null and condition_manager.has_method("apply_consumable_item"):
			result = condition_manager.call("apply_consumable_item", item)
		if bool(result.get("success", false)):
			_change_owned_item_quantity(item_id, -1)
		return result
	if category == "shelter":
		var condition_manager := get_node_or_null("/root/PlayerConditionManager")
		if condition_manager != null and condition_manager.has_method("use_shelter_item"):
			return condition_manager.call("use_shelter_item", item)
		return {"success": false, "message": "Сейчас нельзя отдохнуть."}
	return {"success": false, "message": "Для этого предмета нет действия."}

func get_survival_item_effect_lines(item: Dictionary) -> Array:
	var lines: Array = []
	if item.is_empty():
		return lines
	var category := str(item.get("category", ""))
	var stats: Dictionary = item.get("stats", {}) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}
	if category == "food" or category == "drink":
		if stats.has("hunger_restore"):
			lines.append("Сытость +%d" % roundi(float(stats.get("hunger_restore", 0.0))))
		if stats.has("health_restore"):
			lines.append("Самочувствие +%d" % roundi(float(stats.get("health_restore", 0.0))))
		if stats.has("temperature_delta_cold"):
			lines.append("Согревает в холод")
		if stats.has("temperature_delta_hot"):
			lines.append("Охлаждает в жару")
		if stats.has("condition_bonus"):
			lines.append("Временная концентрация +%d%%" % roundi(float(stats.get("condition_bonus", 0.0)) * 100.0))
	elif category == "clothing":
		var slot := _get_clothing_slot(item)
		if slot != "":
			lines.append("Слот: %s" % get_clothing_slot_title(slot))
		if float(stats.get("cold_protection", 0.0)) > 0.0:
			lines.append("Защита от холода +%d%%" % roundi(float(stats.get("cold_protection", 0.0)) * 100.0))
		if float(stats.get("wind_protection", 0.0)) > 0.0:
			lines.append("Защита от ветра +%d%%" % roundi(float(stats.get("wind_protection", 0.0)) * 100.0))
		if float(stats.get("rain_protection", 0.0)) > 0.0:
			lines.append("Защита от дождя +%d%%" % roundi(float(stats.get("rain_protection", 0.0)) * 100.0))
		if float(stats.get("heat_protection", 0.0)) > 0.0:
			lines.append("Защита от жары +%d%%" % roundi(float(stats.get("heat_protection", 0.0)) * 100.0))
	elif category == "shelter":
		lines.append("Отдых: %d мин." % roundi(float(stats.get("rest_minutes", 60.0))))
		if float(stats.get("health_restore", 0.0)) > 0.0:
			lines.append("Самочувствие +%d" % roundi(float(stats.get("health_restore", 0.0))))
		if bool(stats.get("normalize_temperature", false)):
			lines.append("Температура к норме")
	return lines

func set_condition_from_save(data) -> bool:
	var source: Dictionary = {}
	if data is Dictionary:
		source = (data as Dictionary).duplicate(true)
	health = float(source.get("health", 100.0))
	body_temperature = float(source.get("body_temperature", 36.6))
	hunger = float(source.get("hunger", 100.0))
	return ensure_condition_defaults()

func restore_condition_beta_safe() -> void:
	body_temperature = 36.6
	health = maxf(float(health), 65.0)
	hunger = maxf(float(hunger), 45.0)
	ensure_condition_defaults()

func format_money_amount(value: float) -> String:
	var rounded_value: float = round(value * 100.0) / 100.0

	if abs(rounded_value - round(rounded_value)) < 0.005:
		return "%d" % int(round(rounded_value))
	if abs(rounded_value * 10.0 - round(rounded_value * 10.0)) < 0.005:
		return "%.1f" % rounded_value
	return "%.2f" % rounded_value

func format_money(value: float, suffix: String = "мон.") -> String:
	var formatters := get_node_or_null("/root/UIFormatters")
	if formatters != null and formatters.has_method("format_money") and suffix == "мон.":
		return str(formatters.call("format_money", value))
	return "%s %s" % [format_money_amount(value), suffix]

func format_hook_size(size: int) -> String:
	if size <= 0:
		return "%d/0" % (1 - size)
	return "%d" % size

func get_xp_to_next_level(for_level: int) -> int:
	return 100 + 50 * for_level + 25 * for_level * for_level

func get_skill_points_for_level(for_level: int) -> int:
	if for_level >= 100:
		return 11
	return clampi(int(floor(float(max(for_level, 1)) / 10.0)) + 1, 1, 11)

func calculate_total_skill_points_for_level(for_level: int) -> int:
	var total := 0
	for reached_level in range(2, max(for_level, 1) + 1):
		total += get_skill_points_for_level(reached_level)
	return total

func add_xp(amount: int) -> Dictionary:
	var gained_xp: int = max(amount, 0)
	var levels_gained: int = 0
	var skill_points_gained := 0
	var previous_level := level
	var gained_levels: Array = []

	current_xp += gained_xp

	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		level += 1
		gained_levels.append(level)
		levels_gained += 1
		var points_for_level := get_skill_points_for_level(level)
		skill_points += points_for_level
		total_skill_points_earned += points_for_level
		skill_points_gained += points_for_level
		xp_to_next_level = get_xp_to_next_level(level)

	if levels_gained > 0:
		refresh_waterbody_unlocks()

	return {
		"gained_xp": gained_xp,
		"levels_gained": levels_gained,
		"gained_levels": gained_levels,
		"skill_points_gained": skill_points_gained,
		"leveled_up": levels_gained > 0,
		"previous_level": previous_level,
		"level": level,
		"current_xp": current_xp,
		"xp_to_next_level": xp_to_next_level
	}

func get_level_up_reward_config(reward_level: int) -> Dictionary:
	if not LEVEL_UP_REWARDS.has(reward_level):
		return {}
	return (LEVEL_UP_REWARDS[reward_level] as Dictionary).duplicate(true)

func claim_level_rewards_for_xp_result(xp_result: Dictionary) -> Array:
	var claimed_rewards: Array = []
	if xp_result.is_empty() or not bool(xp_result.get("leveled_up", false)):
		return claimed_rewards

	for reward_level in _get_level_reward_numbers_from_xp_result(xp_result):
		var result := claim_level_reward(int(reward_level))
		if bool(result.get("success", false)):
			claimed_rewards.append(result)

	return claimed_rewards

func claim_level_reward(reward_level: int) -> Dictionary:
	var reward: Dictionary = get_level_up_reward_config(reward_level)
	if reward.is_empty():
		return {
			"success": false,
			"level": reward_level,
			"reason": "no_reward_config"
		}

	if _is_level_reward_claimed(reward_level):
		return {
			"success": false,
			"level": reward_level,
			"reason": "already_claimed"
		}

	_set_level_reward_claimed(reward_level)

	var silver_reward: int = maxi(int(reward.get("silver", 0)), 0)
	if silver_reward > 0:
		money += float(silver_reward)

	var granted_items: Array = []
	var skipped_items: Array = []
	for item_reward in reward.get("items", []):
		if typeof(item_reward) != TYPE_DICTIONARY:
			continue
		var item_id := str(item_reward.get("id", "")).strip_edges()
		var quantity: int = maxi(int(item_reward.get("quantity", 1)), 1)
		var granted_item := _grant_level_reward_item(reward_level, item_id, quantity)
		if granted_item.is_empty():
			skipped_items.append({
				"id": item_id,
				"quantity": quantity
			})
			continue
		granted_items.append(granted_item)

	return {
		"success": true,
		"level": reward_level,
		"silver": silver_reward,
		"items": granted_items,
		"skipped_items": skipped_items,
		"unlocks": _safe_saved_array(reward.get("unlocks", []))
	}

func set_claimed_level_rewards(saved_rewards, mark_current_levels_claimed: bool = false) -> void:
	claimed_level_rewards = {}

	if typeof(saved_rewards) == TYPE_DICTIONARY:
		for raw_key in (saved_rewards as Dictionary).keys():
			var reward_level := int(raw_key)
			if reward_level > 0 and bool((saved_rewards as Dictionary).get(raw_key, false)):
				claimed_level_rewards[reward_level] = true
	elif typeof(saved_rewards) == TYPE_ARRAY:
		for raw_level in saved_rewards:
			var reward_level := int(raw_level)
			if reward_level > 0:
				claimed_level_rewards[reward_level] = true

	if mark_current_levels_claimed:
		mark_level_rewards_claimed_through(level)

func mark_level_rewards_claimed_through(max_level: int) -> void:
	for reward_level in range(2, mini(maxi(max_level, 1), 10) + 1):
		_set_level_reward_claimed(reward_level)

func get_claimed_level_rewards_save_data() -> Dictionary:
	var result: Dictionary = {}
	for raw_level in claimed_level_rewards.keys():
		var reward_level := int(raw_level)
		if reward_level > 0 and bool(claimed_level_rewards.get(raw_level, false)):
			result[str(reward_level)] = true
	return result

func _grant_level_reward_item(reward_level: int, item_id: String, quantity: int) -> Dictionary:
	if item_id == "":
		push_warning("Level reward has empty item id at level %d" % reward_level)
		return {}

	var catalog_item := get_tackle_catalog_item(item_id)
	if catalog_item.is_empty():
		push_warning("Level reward item not found: %s at level %d" % [item_id, reward_level])
		return {}
	if _is_beta_hidden_tackle_item(catalog_item):
		push_warning("Level reward item is hidden in beta: %s at level %d" % [item_id, reward_level])
		return {}

	var owned_item := _make_owned_catalog_item(item_id, quantity)
	if owned_item.is_empty():
		push_warning("Level reward item cannot be created: %s at level %d" % [item_id, reward_level])
		return {}

	add_owned_item(owned_item, quantity)
	return {
		"id": item_id,
		"name": str(catalog_item.get("display_name_ru", catalog_item.get("name", item_id))),
		"quantity": quantity
	}

func _get_level_reward_numbers_from_xp_result(xp_result: Dictionary) -> Array:
	var result: Array = []
	var raw_levels = xp_result.get("gained_levels", [])
	if typeof(raw_levels) == TYPE_ARRAY:
		for raw_level in raw_levels:
			var reward_level := int(raw_level)
			if reward_level > 0 and not result.has(reward_level):
				result.append(reward_level)

	if not result.is_empty():
		return result

	var levels_gained: int = maxi(int(xp_result.get("levels_gained", 0)), 0)
	var final_level := int(xp_result.get("level", level))
	var first_level := int(xp_result.get("previous_level", final_level - levels_gained)) + 1
	for reward_level in range(first_level, final_level + 1):
		if reward_level > 0 and not result.has(reward_level):
			result.append(reward_level)

	return result

func _is_level_reward_claimed(reward_level: int) -> bool:
	return bool(claimed_level_rewards.get(reward_level, claimed_level_rewards.get(str(reward_level), false)))

func _set_level_reward_claimed(reward_level: int) -> void:
	if reward_level > 0:
		claimed_level_rewards[reward_level] = true

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
	_update_daily_catch_weight(weight)

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

	var previous_record: Dictionary = {}
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
		"daily_catch_day": daily_catch_day,
		"daily_fish_weight": daily_fish_weight,
		"best_daily_fish_weight": best_daily_fish_weight,
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
	daily_catch_day = maxi(int(save_data.get("daily_catch_day", _get_current_game_day())), 1)
	daily_fish_weight = maxf(float(save_data.get("daily_fish_weight", 0.0)), 0.0)
	best_daily_fish_weight = maxf(float(save_data.get("best_daily_fish_weight", daily_fish_weight)), 0.0)
	total_trophies_caught = max(int(save_data.get("total_trophies_caught", 0)), 0)
	total_rarity_caught = max(int(save_data.get("total_rarity_caught", 0)), 0)
	biggest_fish = _safe_saved_dictionary(save_data.get("biggest_fish", {}))
	biggest_fish_by_species = _safe_saved_dictionary(save_data.get("biggest_fish_by_species", {}))
	trophy_catches = _safe_saved_array(save_data.get("trophy_catches", []))
	personal_records = _safe_saved_dictionary(save_data.get("personal_records", {}))

func _update_daily_catch_weight(weight: float) -> void:
	var current_day: int = _get_current_game_day()
	if daily_catch_day != current_day:
		daily_catch_day = current_day
		daily_fish_weight = 0.0
	daily_fish_weight = snappedf(daily_fish_weight + maxf(weight, 0.0), 0.01)
	best_daily_fish_weight = maxf(best_daily_fish_weight, daily_fish_weight)

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
	return get_skill_rank(skill_id) > 0

func get_skill_rank(skill_id: String) -> int:
	return max(int(learned_skills.get(_normalize_skill_id(skill_id), 0)), 0)

func can_upgrade_skill(skill_id: String) -> Dictionary:
	var skill_database := _get_skill_database()
	if skill_database == null or not skill_database.has_method("can_upgrade_skill"):
		return {"success": false, "can_upgrade": false, "can_learn": false, "reason": "База навыков недоступна."}
	var result: Dictionary = skill_database.call("can_upgrade_skill", _normalize_skill_id(skill_id))
	result["can_learn"] = bool(result.get("can_upgrade", false))
	return result

func upgrade_skill(skill_id: String) -> Dictionary:
	var normalized_id := _normalize_skill_id(skill_id)
	var skill_database := _get_skill_database()
	if skill_database == null or not skill_database.has_method("can_upgrade_skill"):
		return {"success": false, "can_upgrade": false, "can_learn": false, "reason": "База навыков недоступна."}

	var check: Dictionary = skill_database.call("can_upgrade_skill", normalized_id)
	if not bool(check.get("can_upgrade", false)):
		check["success"] = false
		check["can_learn"] = false
		return check

	var cost := int(check.get("cost", 0))
	if skill_points < cost:
		return {"success": false, "can_upgrade": false, "can_learn": false, "reason": "Недостаточно очков навыков."}

	var current_rank := get_skill_rank(normalized_id)
	learned_skills[normalized_id] = current_rank + 1
	skill_points = max(skill_points - cost, 0)

	return {
		"success": true,
		"can_upgrade": true,
		"can_learn": true,
		"reason": "Навык улучшен.",
		"skill_id": normalized_id,
		"new_rank": current_rank + 1,
		"spent": cost
	}

func can_learn_skill(skill_id: String) -> Dictionary:
	var result := can_upgrade_skill(skill_id)
	result["can_learn"] = bool(result.get("can_upgrade", false))
	return result

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
	return upgrade_skill(skill_id)

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
	var result: Dictionary = {}
	var skill_database := _get_skill_database()
	if skill_database != null and skill_database.has_method("get_skill_effects_for_rank"):
		for skill_id in learned_skills.keys():
			var rank: int = max(int(learned_skills.get(skill_id, 0)), 0)
			if rank <= 0:
				continue
			var effects: Dictionary = skill_database.call("get_skill_effects_for_rank", str(skill_id), rank)
			for effect_id in effects.keys():
				result[effect_id] = float(result.get(effect_id, 0.0)) + float(effects[effect_id])
		return result

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

func set_skill_state(saved_skill_points: int, saved_learned_skills, saved_total_skill_points: int = -1, _saved_tree_points = {}) -> void:
	learned_skills = {}
	var skill_db := _get_skill_database()
	var saved_ranks := _normalize_saved_skill_ranks(saved_learned_skills)

	for skill_id in saved_ranks.keys():
		if str(skill_id).is_empty():
			continue
		if skill_db != null and skill_db.has_method("has_skill") and not bool(skill_db.call("has_skill", str(skill_id))):
			continue
		var max_rank := int(skill_db.call("get_max_rank", str(skill_id))) if skill_db != null and skill_db.has_method("get_max_rank") else 5
		var rank: int = clampi(int(saved_ranks[skill_id]), 0, max_rank)
		if rank > 0:
			learned_skills[str(skill_id)] = rank

	var spent := get_total_spent_skill_points()
	if saved_total_skill_points >= 0:
		total_skill_points_earned = max(saved_total_skill_points, spent + max(saved_skill_points, 0))
		skill_points = max(saved_skill_points, 0)
	else:
		total_skill_points_earned = max(calculate_total_skill_points_for_level(level), spent)
		skill_points = max(total_skill_points_earned - spent, 0)
	return

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

func get_skill_ranks_save_data() -> Dictionary:
	return learned_skills.duplicate(true)

func get_skill_tree_points_save_data() -> Dictionary:
	var result: Dictionary = {}
	var skill_database := _get_skill_database()
	if skill_database == null or not skill_database.has_method("get_tree_ids") or not skill_database.has_method("get_tree_progress"):
		return result
	for tree_id in skill_database.call("get_tree_ids"):
		result[str(tree_id)] = int(skill_database.call("get_tree_progress", str(tree_id)).get("spent_points", 0))
	return result

func get_total_spent_skill_points() -> int:
	var spent := 0
	var skill_database := _get_skill_database()
	if skill_database == null or not skill_database.has_method("get_spent_points_for_rank"):
		return 0
	for skill_id in learned_skills.keys():
		spent += int(skill_database.call("get_spent_points_for_rank", str(skill_id), int(learned_skills[skill_id])))
	return spent

func _normalize_saved_skill_ranks(saved_learned_skills) -> Dictionary:
	var result: Dictionary = {}
	if typeof(saved_learned_skills) == TYPE_DICTIONARY:
		for raw_id in (saved_learned_skills as Dictionary).keys():
			var raw_value = (saved_learned_skills as Dictionary)[raw_id]
			var rank := 0
			if raw_value is bool:
				rank = 1 if bool(raw_value) else 0
			elif raw_value is Dictionary:
				rank = int((raw_value as Dictionary).get("current_rank", (raw_value as Dictionary).get("rank", 0)))
			else:
				rank = int(raw_value)
			_merge_migrated_skill_rank(result, str(raw_id), rank)
	elif typeof(saved_learned_skills) == TYPE_ARRAY:
		for raw_id in saved_learned_skills:
			_merge_migrated_skill_rank(result, str(raw_id), 1)
	return result

func _merge_migrated_skill_rank(result: Dictionary, raw_skill_id: String, raw_rank: int) -> void:
	if raw_rank <= 0:
		return
	var mapped := _map_legacy_skill_id(raw_skill_id)
	for skill_id in mapped.keys():
		var rank := int(mapped[skill_id]) * raw_rank
		result[skill_id] = max(int(result.get(skill_id, 0)), rank)

func _map_legacy_skill_id(skill_id: String) -> Dictionary:
	match skill_id:
		"float_sense_1":
			return {"float_bobber_control": 1}
		"float_sense_2":
			return {"float_bobber_control": 2}
		"depth_reader":
			return {"float_soft_hookset": 1}
		"quiet_water":
			return {"float_confident_reeling": 1}
		"soft_hand_1":
			return {"float_confident_reeling": 1}
		"soft_hand_2":
			return {"float_confident_reeling": 2}
		"jerk_control":
			return {"float_bobber_control": 1}
		"steady_pressure":
			return {"float_confident_reeling": 1}
		"basic_knot_1":
			return {"float_thin_tackle": 1}
		"basic_knot_2":
			return {"float_thin_tackle": 2}
		"careful_hookset":
			return {"float_soft_hookset": 1}
		"bait_sandwich":
			return {"float_double_bait": 1}
		"line_reserve":
			return {"bottom_reliable_rig": 1}
		"experienced_eye":
			return {"float_fishing_xp": 1}
		"trophy_habit":
			return {"float_fishing_xp": 2}
		_:
			return {_normalize_skill_id(skill_id): 1}

func _normalize_skill_id(skill_id: String) -> String:
	if skill_id == "bait_sandwich":
		return "float_double_bait"
	return skill_id

func refresh_waterbody_unlocks() -> void:
	var waterbody_db := _get_waterbody_database()
	var normalized_unlocked: Array = []
	for waterbody_id in unlocked_waterbodies:
		var normalized_id := _normalize_waterbody_id(str(waterbody_id))
		if normalized_id != "" and _get_waterbody(normalized_id).is_empty() == false and not normalized_unlocked.has(normalized_id):
			normalized_unlocked.append(normalized_id)
	unlocked_waterbodies = normalized_unlocked

	for waterbody in _get_all_waterbodies():
		var waterbody_id := str(waterbody.get("id", ""))
		var can_unlock := false
		if waterbody_db != null and waterbody_db.has_method("is_unlocked"):
			can_unlock = bool(waterbody_db.call("is_unlocked", waterbody_id, level))
		else:
			can_unlock = waterbody_id == "agamin_lake"
		if can_unlock and not unlocked_waterbodies.has(waterbody_id):
			unlocked_waterbodies.append(waterbody_id)

	if not unlocked_waterbodies.has("agamin_lake"):
		unlocked_waterbodies.append("agamin_lake")

	current_waterbody = _normalize_waterbody_id(current_waterbody)
	if not unlocked_waterbodies.has(current_waterbody):
		current_waterbody = "agamin_lake"

func set_unlocked_waterbodies(saved_waterbodies: Array) -> void:
	unlocked_waterbodies = []

	for waterbody_id in saved_waterbodies:
		var id := _normalize_waterbody_id(str(waterbody_id))
		if id != "" and _get_waterbody(id).is_empty() == false and not unlocked_waterbodies.has(id):
			unlocked_waterbodies.append(id)

	refresh_waterbody_unlocks()

func can_use_waterbody(waterbody_id: String) -> bool:
	var waterbody_db := _get_waterbody_database()
	var normalized_id := _normalize_waterbody_id(waterbody_id)
	if waterbody_db == null:
		return normalized_id == "agamin_lake"

	return unlocked_waterbodies.has(normalized_id) and bool(waterbody_db.call("is_unlocked", normalized_id, level))

func can_use_spot(spot_id: String) -> bool:
	var spot := SpotDatabase.get_spot(spot_id)
	if spot.is_empty():
		return false

	var required_level := int(spot.get("required_level", spot.get("unlock_level", 1)))
	if level < required_level:
		return false

	if bool(spot.get("is_unlocked", true)):
		return true

	return unlocked_spots.has(spot_id)

func set_current_waterbody(waterbody_id: String) -> bool:
	var normalized_id := _normalize_waterbody_id(waterbody_id)
	if not can_use_waterbody(normalized_id):
		return false

	current_waterbody = normalized_id
	var spot := SpotDatabase.get_spot(current_spot)
	if spot.is_empty() or str(spot.get("waterbody_id", "")) != current_waterbody:
		current_spot = _get_primary_waterbody_spot(current_waterbody)

	clamp_fishing_depth_to_current_spot()
	return true

func set_current_spot(spot_id: String) -> bool:
	var spot := SpotDatabase.get_spot(spot_id)

	if spot.is_empty():
		return false
	if not can_use_spot(spot_id):
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

func _normalize_waterbody_id(waterbody_id: String) -> String:
	var waterbody_db := _get_waterbody_database()
	if waterbody_db != null and waterbody_db.has_method("normalize_waterbody_id"):
		return str(waterbody_db.call("normalize_waterbody_id", waterbody_id))
	if waterbody_id == "":
		return "agamin_lake"
	return waterbody_id

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
		return {"min": PHYSICAL_SHORE_MIN_DEPTH, "max": 6.0, "preferred": clamp(fishing_depth, PHYSICAL_SHORE_MIN_DEPTH, 6.0)}

	var max_depth: float = float(spot.get("max_depth", 6.0))
	return {
		# spot.min_depth is an effective fish-depth hint; the physical shore depth starts shallow on every spot.
		"min": PHYSICAL_SHORE_MIN_DEPTH,
		"max": max(max_depth, PHYSICAL_SHORE_MIN_DEPTH),
		"preferred": clamp(float(spot.get("preferred_depth", spot.get("depth", 1.2))), PHYSICAL_SHORE_MIN_DEPTH, max(max_depth, PHYSICAL_SHORE_MIN_DEPTH))
	}

func _get_raw_tackle_catalog_item(item_id: String) -> Dictionary:
	item_id = _resolve_tackle_item_id(item_id)
	if TACKLE_CATALOG.has(item_id):
		return TACKLE_CATALOG[item_id]
	if ADDITIONAL_BAIT_CATALOG.has(item_id):
		return ADDITIONAL_BAIT_CATALOG[item_id]
	return {}

func _resolve_tackle_item_id(item_id: String) -> String:
	if LEGACY_TACKLE_ITEM_ALIASES.has(item_id):
		return str(LEGACY_TACKLE_ITEM_ALIASES[item_id])
	return item_id

func _normalize_catalog_item(item: Dictionary) -> Dictionary:
	if item.is_empty():
		return {}

	var normalized := item.duplicate(true)
	var item_id := str(normalized.get("id", ""))
	var category := str(normalized.get("category", normalized.get("type", "misc")))
	if WORM_BAIT_PRICE_OVERRIDES.has(item_id):
		normalized["price"] = float(WORM_BAIT_PRICE_OVERRIDES[item_id])
	if category == "bait":
		var stats: Dictionary = normalized.get("stats", {}).duplicate(true) if typeof(normalized.get("stats", {})) == TYPE_DICTIONARY else {}
		normalized["stats"] = _normalize_equipment_stats(stats, "bait", item_id)
	elif category == "float":
		var stats: Dictionary = normalized.get("stats", {}).duplicate(true) if typeof(normalized.get("stats", {})) == TYPE_DICTIONARY else {}
		normalized["stats"] = _normalize_equipment_stats(stats, "float", item_id)
	elif _is_tackle_item_category_supported(category):
		var stats: Dictionary = normalized.get("stats", {}).duplicate(true) if typeof(normalized.get("stats", {})) == TYPE_DICTIONARY else {}
		normalized["stats"] = _normalize_equipment_stats(stats, category, item_id)

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
		var category_order := {"rod": 0, "reel": 1, "line": 2, "leader": 3, "hook": 4, "float": 5, "lure": 6, "bait": 7, "feeder_rig": 8}
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
		BASIC_FLOAT_ID: true,
		BASIC_REEL_ID: true,
		BASIC_LURE_ID: true,
		"light_float": true,
		"medium_float": true,
		"night_float": true,
		"small_hook_12": true
	}

	for item in get_tackle_catalog_items("all"):
		if _is_beta_hidden_tackle_item(item):
			continue

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
	component["display_name_ru"] = str(item.get("display_name_ru", item.get("name", "")))
	component["description_ru"] = str(item.get("description_ru", item.get("description", "")))
	component["bonus_tags"] = _to_string_array(item.get("bonus_tags", component.get("bonus_tags", [])))
	for key in ["tackle_type", "fishing_type", "assembly_type", "rod_type"]:
		if item.has(key):
			component[key] = str(item.get(key, ""))
	return component

func _make_owned_catalog_item(item_id: String, quantity: int = 1) -> Dictionary:
	var item := get_tackle_catalog_item(item_id)

	if item.is_empty():
		item = get_survival_catalog_item(item_id)
	if item.is_empty():
		return {}

	item["quantity"] = max(quantity, 1)
	return _normalize_owned_item(item)

func _get_item_icon(item_type: String) -> String:
	match item_type:
		"rod":
			return "R"
		"reel":
			return "C"
		"line":
			return "L"
		"leader":
			return "P"
		"float":
			return "F"
		"hook":
			return "H"
		"lure":
			return "U"
		"bait":
			return "B"
		"food":
			return "E"
		"drink":
			return "D"
		"clothing":
			return "O"
		"shelter":
			return "T"
		_:
			return "?"

func _normalize_equipment_stats(stats: Dictionary, category: String, item_id: String = "") -> Dictionary:
	var normalized := stats.duplicate(true)

	match category:
		"rod":
			var rod_type_key := str(normalized.get("rod_type", normalized.get("tackle_type", DEFAULT_TACKLE_TYPE))).strip_edges().to_lower()
			if rod_type_key == "" or rod_type_key == DEFAULT_TACKLE_TYPE:
				rod_type_key = "pole"
			var requires_reel_default := ["spinning", "feeder", "sea"].has(rod_type_key)
			var raw_requires_reel = normalized.get("requires_reel", requires_reel_default)
			if typeof(raw_requires_reel) == TYPE_STRING:
				normalized["requires_reel"] = ["1", "true", "yes", "да"].has(str(raw_requires_reel).strip_edges().to_lower())
			else:
				normalized["requires_reel"] = bool(raw_requires_reel)
			normalized["rod_type"] = rod_type_key
			if not normalized.has("tackle_type"):
				normalized["tackle_type"] = rod_type_key if bool(normalized["requires_reel"]) else DEFAULT_TACKLE_TYPE
			if not normalized.has("length_m"):
				normalized["length_m"] = float(normalized.get("length", 4.0))
			if not normalized.has("length"):
				normalized["length"] = float(normalized.get("length_m", 4.0))
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
			if not normalized.has("power"):
				normalized["power"] = float(normalized.get("strength", normalized.get("stiffness", 1.0)))
			if not normalized.has("test_min"):
				normalized["test_min"] = 0.0 if not bool(normalized["requires_reel"]) else 3.0
			if not normalized.has("test_max"):
				normalized["test_max"] = float(normalized.get("max_fish_weight", 1.0)) * 4.0 if bool(normalized["requires_reel"]) else float(normalized.get("max_fish_weight", 1.0))
			if not normalized.has("flexibility"):
				normalized["flexibility"] = clamp(1.25 - float(normalized.get("stiffness", 1.0)) * 0.45, 0.20, 0.95)
			if not normalized.has("compatible_reel_min_size"):
				normalized["compatible_reel_min_size"] = 1000 if bool(normalized["requires_reel"]) else 0
			if not normalized.has("compatible_reel_max_size"):
				normalized["compatible_reel_max_size"] = 4000 if bool(normalized["requires_reel"]) else 0
			var min_rod_length := 1.5 if bool(normalized["requires_reel"]) else 2.7
			normalized["length_m"] = clamp(float(normalized["length_m"]), min_rod_length, 7.2)
			normalized["length"] = float(normalized["length_m"])
			normalized["reach_bonus"] = clamp(float(normalized["reach_bonus"]), -0.06, 0.22)
			normalized["handling_bonus"] = clamp(float(normalized["handling_bonus"]), -0.08, 0.08)
			normalized["power"] = clamp(float(normalized["power"]), 0.25, 3.0)
			normalized["test_min"] = max(float(normalized["test_min"]), 0.0)
			normalized["test_max"] = max(float(normalized["test_max"]), float(normalized["test_min"]))
			normalized["flexibility"] = clamp(float(normalized["flexibility"]), 0.05, 1.0)
			normalized["compatible_reel_min_size"] = max(int(normalized["compatible_reel_min_size"]), 0)
			normalized["compatible_reel_max_size"] = max(int(normalized["compatible_reel_max_size"]), int(normalized["compatible_reel_min_size"]))
			normalized["compatible_reel_min"] = int(normalized["compatible_reel_min_size"])
			normalized["compatible_reel_max"] = int(normalized["compatible_reel_max_size"])
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
				normalized["leader_type"] = str(normalized.get("material", "nylon"))
			if not normalized.has("material"):
				normalized["material"] = str(normalized.get("leader_type", "nylon"))
			var leader_load: float = float(normalized.get("max_load_kg", normalized.get("max_load", normalized.get("strength", 1.0))))
			normalized["max_load_kg"] = leader_load
			normalized["max_load"] = leader_load
			normalized["strength"] = leader_load
			if not normalized.has("length_cm"):
				normalized["length_cm"] = 20
			if not normalized.has("visibility"):
				normalized["visibility"] = 0.05
			if not normalized.has("bite_protection"):
				normalized["bite_protection"] = 0.0
			if not normalized.has("control_bonus"):
				normalized["control_bonus"] = 0.0
			if not normalized.has("cautious_bite_bonus"):
				normalized["cautious_bite_bonus"] = 0.0
			if not normalized.has("small_fish_penalty"):
				normalized["small_fish_penalty"] = 0.0
			if not normalized.has("break_resistance"):
				normalized["break_resistance"] = 1.0
			if not normalized.has("break_chance"):
				normalized["break_chance"] = 0.14
			if not normalized.has("level_required"):
				normalized["level_required"] = 1
			if not normalized.has("durability"):
				normalized["durability"] = 1.0
			if not normalized.has("wear_rate"):
				normalized["wear_rate"] = 0.020
			normalized["leader_type"] = str(normalized["leader_type"])
			normalized["material"] = str(normalized["material"])
			normalized["length_cm"] = clampi(int(normalized["length_cm"]), 5, 80)
			normalized["max_load_kg"] = max(float(normalized["max_load_kg"]), 0.05)
			normalized["max_load"] = float(normalized["max_load_kg"])
			normalized["strength"] = float(normalized["max_load_kg"])
			normalized["visibility"] = clamp(float(normalized["visibility"]), 0.0, 0.45)
			normalized["bite_protection"] = clamp(float(normalized["bite_protection"]), 0.0, 0.30)
			normalized["control_bonus"] = clamp(float(normalized["control_bonus"]), -0.12, 0.12)
			normalized["cautious_bite_bonus"] = clamp(float(normalized["cautious_bite_bonus"]), -0.30, 0.20)
			normalized["small_fish_penalty"] = clamp(float(normalized["small_fish_penalty"]), 0.0, 0.30)
			normalized["break_resistance"] = clamp(float(normalized["break_resistance"]), 0.45, 1.80)
			normalized["break_chance"] = clamp(float(normalized["break_chance"]), 0.02, 0.32)
			normalized["level_required"] = max(int(normalized["level_required"]), 1)
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
		"float":
			if not normalized.has("float_type"):
				normalized["float_type"] = "drop"
			if not normalized.has("base_type"):
				normalized["base_type"] = str(normalized.get("float_type", "drop"))
			if not normalized.has("buoyancy"):
				normalized["buoyancy"] = 1.0
			if not normalized.has("sensitivity"):
				normalized["sensitivity"] = float(normalized.get("bite_detection_bonus", 0.85))
			if not normalized.has("stability"):
				normalized["stability"] = 0.75
			if not normalized.has("wind_resistance"):
				normalized["wind_resistance"] = 0.65
			if not normalized.has("drift_resistance"):
				normalized["drift_resistance"] = 0.65
			if not normalized.has("cast_distance_bonus"):
				normalized["cast_distance_bonus"] = 0.0
			if not normalized.has("bite_visibility"):
				normalized["bite_visibility"] = 0.85
			if not normalized.has("false_bite_resistance"):
				normalized["false_bite_resistance"] = 0.65
			if not normalized.has("depth_min"):
				normalized["depth_min"] = 0.2
			if not normalized.has("depth_max"):
				normalized["depth_max"] = 2.5
			if not normalized.has("night_bonus"):
				normalized["night_bonus"] = 0.0
			if not normalized.has("vegetation_control"):
				normalized["vegetation_control"] = 0.55
			if not normalized.has("heavy_bait_support"):
				normalized["heavy_bait_support"] = 0.55
			if not normalized.has("hook_timing_bonus"):
				normalized["hook_timing_bonus"] = 0.0
			if not normalized.has("long_range_accuracy_bonus"):
				normalized["long_range_accuracy_bonus"] = 0.0
			if not normalized.has("setup_comfort"):
				normalized["setup_comfort"] = 0.0
			if not normalized.has("recommended_spots") or typeof(normalized.get("recommended_spots", [])) != TYPE_ARRAY:
				normalized["recommended_spots"] = []
			if not normalized.has("bonus_tags") or typeof(normalized.get("bonus_tags", [])) != TYPE_ARRAY:
				normalized["bonus_tags"] = []

			normalized["base_type"] = str(normalized["base_type"])
			normalized["buoyancy"] = clamp(float(normalized["buoyancy"]), 0.1, 2.0)
			normalized["sensitivity"] = clamp(_normalize_float_rating(float(normalized["sensitivity"]), 0.85), 0.0, 1.0)
			normalized["stability"] = clamp(_normalize_float_rating(float(normalized["stability"]), 0.75), 0.0, 1.0)
			normalized["wind_resistance"] = clamp(_normalize_float_rating(float(normalized["wind_resistance"]), 0.65), 0.0, 1.0)
			normalized["drift_resistance"] = clamp(_normalize_float_rating(float(normalized["drift_resistance"]), 0.65), 0.0, 1.0)
			normalized["cast_distance_bonus"] = clamp(float(normalized["cast_distance_bonus"]), -0.20, 0.25)
			normalized["bite_visibility"] = clamp(_normalize_float_rating(float(normalized["bite_visibility"]), 0.85), 0.0, 1.0)
			normalized["false_bite_resistance"] = clamp(_normalize_float_rating(float(normalized["false_bite_resistance"]), 0.65), 0.0, 1.0)
			normalized["depth_min"] = max(float(normalized["depth_min"]), PHYSICAL_SHORE_MIN_DEPTH)
			normalized["depth_max"] = max(float(normalized["depth_max"]), float(normalized["depth_min"]) + 0.1)
			normalized["night_bonus"] = clamp(float(normalized["night_bonus"]), 0.0, 0.60)
			normalized["vegetation_control"] = clamp(_normalize_float_rating(float(normalized["vegetation_control"]), 0.55), 0.0, 1.0)
			normalized["heavy_bait_support"] = clamp(_normalize_float_rating(float(normalized["heavy_bait_support"]), 0.55), 0.0, 1.0)
			normalized["hook_timing_bonus"] = clamp(float(normalized["hook_timing_bonus"]), 0.0, 0.20)
			normalized["long_range_accuracy_bonus"] = clamp(float(normalized["long_range_accuracy_bonus"]), 0.0, 0.20)
			normalized["setup_comfort"] = clamp(float(normalized["setup_comfort"]), 0.0, 0.20)
			normalized["recommended_spots"] = _to_string_array(normalized["recommended_spots"])
			normalized["bonus_tags"] = _to_string_array(normalized["bonus_tags"])
		"reel":
			if not normalized.has("reel_size"):
				normalized["reel_size"] = 2000
			if not normalized.has("reel_type"):
				normalized["reel_type"] = "spinning"
			if not normalized.has("max_drag"):
				normalized["max_drag"] = 4.0
			if not normalized.has("retrieve_speed"):
				normalized["retrieve_speed"] = 0.70
			if not normalized.has("spool_capacity"):
				normalized["spool_capacity"] = 120.0
			if not normalized.has("durability"):
				normalized["durability"] = 1.0
			if not normalized.has("weight"):
				normalized["weight"] = 250.0
			if not normalized.has("wear_rate"):
				normalized["wear_rate"] = 0.008
			if not normalized.has("body_texture"):
				normalized["body_texture"] = ""
			if not normalized.has("spool_texture"):
				normalized["spool_texture"] = ""
			if not normalized.has("handle_texture"):
				normalized["handle_texture"] = ""
			normalized["reel_size"] = clampi(int(normalized["reel_size"]), 1000, 10000)
			normalized["reel_type"] = str(normalized["reel_type"])
			normalized["max_drag"] = clamp(float(normalized["max_drag"]), 0.5, 30.0)
			normalized["retrieve_speed"] = clamp(float(normalized["retrieve_speed"]), 0.20, 2.0)
			normalized["spool_capacity"] = clamp(float(normalized["spool_capacity"]), 25.0, 650.0)
			normalized["durability"] = clamp(float(normalized["durability"]), 0.0, 1.0)
			normalized["weight"] = clamp(float(normalized["weight"]), 80.0, 1200.0)
			normalized["wear_rate"] = clamp(float(normalized["wear_rate"]), 0.001, 0.040)
			normalized["body_texture"] = str(normalized["body_texture"])
			normalized["spool_texture"] = str(normalized["spool_texture"])
			normalized["handle_texture"] = str(normalized["handle_texture"])
		"lure":
			var lure_id := item_id
			if lure_id == "":
				lure_id = str(normalized.get("id", normalized.get("bait_id", "")))
			if not normalized.has("bait_type"):
				normalized["bait_type"] = "lure"
			if not normalized.has("lure_type"):
				normalized["lure_type"] = "spinner"
			if not normalized.has("hook_chance"):
				normalized["hook_chance"] = 0.10
			if not normalized.has("hook_strength"):
				normalized["hook_strength"] = 1.0
			if not normalized.has("fish_escape_modifier"):
				normalized["fish_escape_modifier"] = 1.0
			if not normalized.has("hook_size"):
				normalized["hook_size"] = 8
			if not normalized.has("weight"):
				normalized["weight"] = 5.0
			if not normalized.has("durability"):
				normalized["durability"] = 1.0
			if not normalized.has("wear_rate"):
				normalized["wear_rate"] = 0.006
			normalized = _apply_bait_target_profile(normalized, lure_id)
			normalized["lure_type"] = str(normalized["lure_type"])
			normalized["hook_chance"] = clamp(float(normalized["hook_chance"]), 0.0, 0.35)
			normalized["hook_strength"] = clamp(float(normalized["hook_strength"]), 0.25, 2.5)
			normalized["fish_escape_modifier"] = clamp(float(normalized["fish_escape_modifier"]), 0.45, 1.80)
			normalized["hook_size"] = clampi(int(normalized["hook_size"]), 2, 24)
			normalized["weight"] = clamp(float(normalized["weight"]), 0.5, 160.0)
			normalized["durability"] = clamp(float(normalized["durability"]), 0.0, 1.0)
			normalized["wear_rate"] = clamp(float(normalized["wear_rate"]), 0.001, 0.040)
		"bait":
			var bait_id := item_id
			if bait_id == "":
				bait_id = str(normalized.get("id", normalized.get("bait_id", "")))
			normalized = _apply_bait_target_profile(normalized, bait_id)

	return normalized

func _normalize_float_rating(value: float, fallback: float) -> float:
	if value <= 0.0:
		return fallback
	if value <= 0.35:
		return clamp(value / 0.25, 0.35, 1.0)
	return clamp(value, 0.0, 1.0)

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
	var original_item_id := str(item.get("id", ""))
	var item_id := _resolve_tackle_item_id(original_item_id)
	var requested_category := str(item.get("category", item.get("type", "")))
	var survival_catalog_item := get_survival_catalog_item(original_item_id)
	var prefer_survival_catalog := (
		not survival_catalog_item.is_empty()
		and (_is_survival_item_category(requested_category) or get_tackle_catalog_item(item_id).is_empty())
	)
	var catalog_item := survival_catalog_item if prefer_survival_catalog else get_tackle_catalog_item(item_id)
	if prefer_survival_catalog:
		item_id = original_item_id
	var item_type := str(item.get("type", item.get("category", catalog_item.get("type", catalog_item.get("category", "misc")))))
	var category := str(item.get("category", catalog_item.get("category", item_type)))
	if prefer_survival_catalog:
		item_type = str(catalog_item.get("type", item_type))
		category = str(catalog_item.get("category", category))
	var catalog_stats: Dictionary = {}
	var catalog_raw_stats = catalog_item.get("stats", {})
	if typeof(catalog_raw_stats) == TYPE_DICTIONARY:
		catalog_stats = catalog_raw_stats.duplicate(true)
	var raw_stats = item.get("stats", catalog_stats)
	var stats: Dictionary = catalog_stats.duplicate(true)
	if typeof(raw_stats) == TYPE_DICTIONARY:
		stats.merge(raw_stats, true)
	if not _is_survival_item_category(category):
		stats = _normalize_equipment_stats(stats, category, item_id)
	var use_catalog_identity := (
		not catalog_item.is_empty()
		and (original_item_id != item_id or prefer_survival_catalog or not item.has("name"))
	)

	return {
		"id": item_id,
		"name": str(catalog_item.get("name", "-") if use_catalog_identity else item.get("name", catalog_item.get("name", "-"))),
		"type": str(catalog_item.get("type", item_type) if use_catalog_identity else item_type),
		"category": str(catalog_item.get("category", category) if use_catalog_identity else category),
		"rarity": str(catalog_item.get("rarity", "common") if use_catalog_identity else item.get("rarity", catalog_item.get("rarity", "common"))),
		"price": float(catalog_item.get("price", 0.0) if use_catalog_identity else item.get("price", catalog_item.get("price", 0.0))),
		"quantity": max(int(item.get("quantity", 1)), 0),
		"image_path": str(catalog_item.get("image_path", "") if use_catalog_identity else item.get("image_path", catalog_item.get("image_path", ""))),
		"description": str(catalog_item.get("description", "") if use_catalog_identity else item.get("description", catalog_item.get("description", ""))),
		"display_name_ru": str(catalog_item.get("display_name_ru", catalog_item.get("name", "-")) if use_catalog_identity else item.get("display_name_ru", catalog_item.get("display_name_ru", item.get("name", catalog_item.get("name", "-"))))),
		"description_ru": str(catalog_item.get("description_ru", catalog_item.get("description", "")) if use_catalog_identity else item.get("description_ru", catalog_item.get("description_ru", item.get("description", catalog_item.get("description", ""))))),
		"bonus_tags": _to_string_array(catalog_item.get("bonus_tags", []) if use_catalog_identity else item.get("bonus_tags", catalog_item.get("bonus_tags", stats.get("bonus_tags", [])))),
		"stats": stats
	}

func get_default_tackle() -> Dictionary:
	return {
		"rod": _make_tackle_component("simple_pole_rod_4m"),
		"line": _make_tackle_component("mono_1_2kg"),
		"leader": _make_tackle_component(BASIC_LEADER_ID),
		"hook": _make_tackle_component("small_hook_12"),
		"float": _make_tackle_component(BASIC_FLOAT_ID),
		"bait": _make_tackle_component("worm"),
		"bait_2": {},
		"reel": {},
		"lure": {},
		"feeder_rig": {},
		"hook_or_lure": {},
		"sinker_or_rig": {}
	}

func get_default_recent_tackle_items() -> Dictionary:
	var defaults: Dictionary = {}
	for category in QUICK_TACKLE_CATEGORIES:
		defaults[category] = []
	return defaults

func set_recent_tackle_items(saved_recent) -> void:
	recent_tackle_items = get_default_recent_tackle_items()
	if typeof(saved_recent) != TYPE_DICTIONARY:
		return

	for category in QUICK_TACKLE_CATEGORIES:
		var saved_ids = saved_recent.get(category, [])
		if typeof(saved_ids) != TYPE_ARRAY:
			continue

		var normalized_ids: Array = []
		for raw_id in saved_ids:
			var item_id := str(raw_id)
			if item_id != "" and normalized_ids.has(item_id):
				continue
			normalized_ids.append(item_id)
			if normalized_ids.size() >= 3:
				break
		recent_tackle_items[category] = normalized_ids

func get_recent_tackle_items_save_data() -> Dictionary:
	var data := get_default_recent_tackle_items()
	for category in QUICK_TACKLE_CATEGORIES:
		data[category] = get_recent_tackle_item_ids(category)
	return data

func get_recent_tackle_item_ids(category: String) -> Array:
	if not QUICK_TACKLE_CATEGORIES.has(category):
		return []
	var ids = recent_tackle_items.get(category, [])
	if typeof(ids) != TYPE_ARRAY:
		return []
	return (ids as Array).duplicate()

func remember_recent_tackle_item(category: String, item_id: String) -> void:
	if not QUICK_TACKLE_CATEGORIES.has(category) or item_id == "":
		return

	var ids := _get_recent_tackle_slot_ids(category)
	var existing_index := ids.find(item_id)
	if existing_index >= 0:
		recent_tackle_items[category] = ids
		return

	var empty_index := ids.find("")
	if empty_index >= 0:
		ids[empty_index] = item_id
	else:
		ids.push_front(item_id)
		while ids.size() > 3:
			ids.pop_back()
	recent_tackle_items[category] = ids

func forget_recent_tackle_item(category: String, item_id: String) -> void:
	if not QUICK_TACKLE_CATEGORIES.has(category) or item_id == "":
		return
	if not recent_tackle_items.has(category) or typeof(recent_tackle_items.get(category)) != TYPE_ARRAY:
		return

	var ids: Array = recent_tackle_items[category]
	ids.erase(item_id)
	recent_tackle_items[category] = ids

func set_recent_tackle_item_slot(category: String, slot_index: int, item_id: String) -> void:
	if not QUICK_TACKLE_CATEGORIES.has(category) or slot_index < 0 or slot_index >= 3:
		return

	var ids := _get_recent_tackle_slot_ids(category)
	if item_id != "":
		for i in ids.size():
			if i != slot_index and str(ids[i]) == item_id:
				ids[i] = ""
	ids[slot_index] = item_id
	recent_tackle_items[category] = ids

func clear_recent_tackle_item_slot(category: String, slot_index: int) -> void:
	set_recent_tackle_item_slot(category, slot_index, "")

func _get_recent_tackle_slot_ids(category: String) -> Array:
	var ids: Array = []
	if recent_tackle_items.has(category) and typeof(recent_tackle_items.get(category)) == TYPE_ARRAY:
		for raw_id in recent_tackle_items[category]:
			ids.append(str(raw_id))
			if ids.size() >= 3:
				break
	while ids.size() < 3:
		ids.append("")
	return ids

func get_quick_tackle_items(category: String, limit: int = 3) -> Array:
	if not QUICK_TACKLE_CATEGORIES.has(category):
		return []

	var result: Array = []
	var used_ids: Dictionary = {}
	for item_id in get_recent_tackle_item_ids(category):
		var item := get_owned_item(str(item_id))
		if _is_quick_tackle_item_available(item, category):
			result.append(item)
			used_ids[str(item.get("id", ""))] = true
		if result.size() >= limit:
			return result

	for item in get_owned_items_for_category(category):
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var owned_item: Dictionary = item
		var owned_id := str(owned_item.get("id", ""))
		if used_ids.has(owned_id):
			continue
		if not _is_quick_tackle_item_available(owned_item, category):
			continue
		result.append(owned_item)
		used_ids[owned_id] = true
		if result.size() >= limit:
			break

	return result

func _is_quick_tackle_item_available(item: Dictionary, category: String) -> bool:
	if item.is_empty():
		return false
	if str(item.get("category", item.get("type", ""))) != category:
		return false
	if int(item.get("quantity", 0)) <= 0:
		return false
	if category == "bait" and int(item.get("quantity", 0)) <= 0:
		return false
	return true

func get_default_owned_items() -> Array:
	return [
		_make_owned_catalog_item("simple_pole_rod_4m", 1),
		_make_owned_catalog_item("mono_1_2kg", 1),
		_make_owned_catalog_item(BASIC_LEADER_ID, 1),
		_make_owned_catalog_item(BASIC_FLOAT_ID, 1),
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
		var merged_component: Dictionary = current_tackle.get(slot, {}).duplicate(true)
		merged_component.merge(saved_component, true)
		if str(merged_component.get("id", "")) == "":
			current_tackle[slot] = {}
			continue
		var resolved_component_id := _resolve_tackle_item_id(str(merged_component.get("id", "")))
		if resolved_component_id != str(merged_component.get("id", "")):
			var catalog_component := _make_tackle_component(resolved_component_id)
			if not catalog_component.is_empty():
				merged_component = catalog_component
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
		var slot_catalog_item := get_tackle_catalog_item(str(merged_component.get("id", "")))
		if not slot_catalog_item.is_empty():
			merged_component["name"] = str(slot_catalog_item.get("name", merged_component.get("name", "-")))
			merged_component["rarity"] = str(slot_catalog_item.get("rarity", merged_component.get("rarity", "common")))
			merged_component["price"] = float(slot_catalog_item.get("price", merged_component.get("price", 0.0)))
			merged_component["image_path"] = str(slot_catalog_item.get("image_path", merged_component.get("image_path", "")))
			merged_component["description"] = str(slot_catalog_item.get("description", merged_component.get("description", "")))
			merged_component["display_name_ru"] = str(slot_catalog_item.get("display_name_ru", merged_component.get("display_name_ru", slot_catalog_item.get("name", "-"))))
			merged_component["description_ru"] = str(slot_catalog_item.get("description_ru", merged_component.get("description_ru", slot_catalog_item.get("description", ""))))
			merged_component["bonus_tags"] = _to_string_array(slot_catalog_item.get("bonus_tags", merged_component.get("bonus_tags", [])))
			for key in ["tackle_type", "fishing_type", "assembly_type", "rod_type"]:
				if slot_catalog_item.has(key) and not merged_component.has(key):
					merged_component[key] = str(slot_catalog_item.get(key, ""))
		if _is_beta_hidden_tackle_item(merged_component):
			continue
		current_tackle[slot] = merged_component

	if current_tackle.get("float", {}).is_empty():
		current_tackle["float"] = _make_tackle_component(BASIC_FLOAT_ID)
	if current_tackle.get("leader", {}).is_empty():
		current_tackle["leader"] = _make_tackle_component(BASIC_LEADER_ID)
	_sync_tackle_slots_for_current_rod()

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
	else:
		_ensure_default_float_owned()
		_ensure_default_leader_owned()
		_ensure_starter_reel_tackle_owned()

func _ensure_default_float_owned() -> void:
	if _has_owned_category("float"):
		return
	var fallback_float := _make_owned_catalog_item(BASIC_FLOAT_ID, 1)
	if not fallback_float.is_empty():
		owned_items.append(fallback_float)

func _ensure_default_leader_owned() -> void:
	if _has_owned_category("leader"):
		return
	var fallback_leader := _make_owned_catalog_item(BASIC_LEADER_ID, 1)
	if not fallback_leader.is_empty():
		owned_items.append(fallback_leader)

func _ensure_starter_reel_tackle_owned() -> void:
	if not BuildConfig.ENABLE_SPINNING_FEATURES:
		return

	for item_id in ["river_spin_210", BASIC_REEL_ID, BASIC_LURE_ID]:
		if not get_owned_item(str(item_id)).is_empty():
			continue
		var starter_item := _make_owned_catalog_item(str(item_id), 1)
		if not starter_item.is_empty():
			owned_items.append(starter_item)

func _has_owned_category(category: String) -> bool:
	for item in owned_items:
		if typeof(item) == TYPE_DICTIONARY and str(item.get("category", item.get("type", ""))) == category and int(item.get("quantity", 0)) > 0:
			return true
	return false

func get_owned_items_for_category(category_filter: String) -> Array:
	if category_filter == "all":
		return get_visible_owned_items()

	var items: Array = []

	for item in owned_items:
		if _is_beta_hidden_tackle_item(item):
			continue
		var item_category := str(item.get("category", "misc"))
		if category_filter == "food" and ["food", "drink"].has(item_category):
			items.append(item)
		elif category_filter == "clothing" and ["clothing", "shelter"].has(item_category):
			items.append(item)
		elif item_category == category_filter:
			items.append(item)

	return items

func get_visible_owned_items() -> Array:
	var items: Array = []

	for item in owned_items:
		if _is_beta_hidden_tackle_item(item):
			continue
		items.append(item)

	return items

func _is_beta_hidden_tackle_item(item: Dictionary) -> bool:
	if BuildConfig.ENABLE_SPINNING_FEATURES or item.is_empty():
		return false

	var category := str(item.get("category", item.get("type", ""))).strip_edges().to_lower()
	if BETA_HIDDEN_TACKLE_CATEGORIES.has(category):
		return true

	var stats: Dictionary = item.get("stats", {}) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}
	var lure_type := str(stats.get("lure_type", item.get("lure_type", ""))).strip_edges().to_lower()
	if lure_type != "" and BETA_HIDDEN_LURE_TYPES.has(lure_type):
		return true

	if category == "rod":
		var rod_type := str(stats.get("rod_type", item.get("rod_type", item.get("tackle_type", "")))).strip_edges().to_lower()
		var tackle_type := str(stats.get("tackle_type", item.get("tackle_type", rod_type))).strip_edges().to_lower()
		if rod_type == "spinning" or tackle_type == "spinning":
			return true
		if bool(stats.get("requires_reel", item.get("requires_reel", false))):
			return true

	return false

func normalize_tackle_type(raw_type: String) -> String:
	var type_key := raw_type.strip_edges().to_lower()
	return str(TACKLE_TYPE_ALIASES.get(type_key, DEFAULT_TACKLE_TYPE))

func get_current_tackle_type() -> String:
	var rod := get_current_tackle_slot("rod")
	var tackle_type := normalize_tackle_type(_get_tackle_type_from_item(rod))
	if not BuildConfig.ENABLE_SPINNING_FEATURES and tackle_type == "spinning":
		return DEFAULT_TACKLE_TYPE
	return tackle_type

func get_current_tackle_type_title() -> String:
	return str(TACKLE_TYPE_TITLES.get(get_current_tackle_type(), TACKLE_TYPE_TITLES[DEFAULT_TACKLE_TYPE]))

func get_current_rod_data() -> Dictionary:
	var raw_component = current_tackle.get("rod", {})
	if typeof(raw_component) != TYPE_DICTIONARY:
		return {}
	var component: Dictionary = (raw_component as Dictionary).duplicate(true)
	if str(component.get("id", "")) == "":
		return {}
	return _normalize_equipment_stats(component, "rod", str(component.get("id", "")))

func get_current_rod_requires_reel() -> bool:
	if not BuildConfig.ENABLE_SPINNING_FEATURES:
		return false
	var rod := get_current_rod_data()
	return bool(rod.get("requires_reel", false)) if not rod.is_empty() else false

func get_current_fight_mode() -> String:
	if not BuildConfig.ENABLE_SPINNING_FEATURES:
		return "pole"
	return "reel" if get_current_rod_requires_reel() else "pole"

func get_current_reel_data() -> Dictionary:
	if not BuildConfig.ENABLE_SPINNING_FEATURES:
		return {}
	var raw_component = current_tackle.get("reel", {})
	if typeof(raw_component) != TYPE_DICTIONARY or str(raw_component.get("id", "")) == "":
		return {}
	var component: Dictionary = (raw_component as Dictionary).duplicate(true)
	var resolved_id := _resolve_tackle_item_id(str(component.get("id", "")))
	var catalog_item := get_tackle_catalog_item(resolved_id)
	var stats: Dictionary = {}
	if not catalog_item.is_empty() and typeof(catalog_item.get("stats", {})) == TYPE_DICTIONARY:
		stats = (catalog_item.get("stats", {}) as Dictionary).duplicate(true)
	stats.merge(component, true)
	stats = _normalize_equipment_stats(stats, "reel", resolved_id)
	stats["id"] = resolved_id
	stats["name"] = str(catalog_item.get("name", component.get("name", "-")))
	stats["type"] = "reel"
	stats["category"] = "reel"
	stats["rarity"] = str(catalog_item.get("rarity", component.get("rarity", "common")))
	stats["price"] = float(catalog_item.get("price", component.get("price", 0.0)))
	return stats

func is_reel_compatible_with_rod(reel: Dictionary, rod: Dictionary = {}) -> bool:
	return get_reel_compatibility_issue(reel, rod) == ""

func get_reel_compatibility_issue(reel: Dictionary, rod: Dictionary = {}) -> String:
	var rod_data := rod.duplicate(true) if not rod.is_empty() else get_current_rod_data()
	if rod_data.is_empty():
		return "Удилище не выбрано."
	rod_data = _normalize_equipment_stats(rod_data, "rod", str(rod_data.get("id", "")))
	if not bool(rod_data.get("requires_reel", false)):
		return "На маховую удочку катушка не ставится."
	if reel.is_empty() or str(reel.get("id", "")) == "":
		return "Катушка не выбрана."
	var reel_data := _normalize_equipment_stats(reel.duplicate(true), "reel", str(reel.get("id", "")))
	var reel_size := int(reel_data.get("reel_size", 0))
	var min_size := int(rod_data.get("compatible_reel_min_size", rod_data.get("compatible_reel_min", 0)))
	var max_size := int(rod_data.get("compatible_reel_max_size", rod_data.get("compatible_reel_max", 0)))
	if min_size > 0 and reel_size < min_size:
		return "Размер катушки меньше диапазона удилища (%d-%d)." % [min_size, max_size]
	if max_size > 0 and reel_size > max_size:
		return "Размер катушки больше диапазона удилища (%d-%d)." % [min_size, max_size]
	return ""

func _get_tackle_type_from_item(item: Dictionary) -> String:
	if item.is_empty():
		return DEFAULT_TACKLE_TYPE
	for key in ["tackle_type", "fishing_type", "assembly_type", "rod_type"]:
		var value := str(item.get(key, ""))
		if value != "":
			return value
	var stats = item.get("stats", {})
	if typeof(stats) == TYPE_DICTIONARY:
		var stat_values: Dictionary = stats
		for key in ["tackle_type", "fishing_type", "assembly_type", "rod_type"]:
			var value := str(stat_values.get(key, ""))
			if value != "":
				return value
	return DEFAULT_TACKLE_TYPE

func get_tackle_slot_schema(slot_id: String, tackle_type: String = "") -> Dictionary:
	for slot_schema in get_tackle_schema_slots(tackle_type):
		if str(slot_schema.get("id", "")) == slot_id:
			return (slot_schema as Dictionary).duplicate(true)
	return {}

func get_tackle_schema_slots(tackle_type: String = "") -> Array:
	var normalized_type := normalize_tackle_type(tackle_type if tackle_type != "" else get_current_tackle_type())
	var raw_slots: Array = TACKLE_SLOT_SCHEMAS.get(normalized_type, TACKLE_SLOT_SCHEMAS[DEFAULT_TACKLE_TYPE])
	var result: Array = []
	for slot_schema in raw_slots:
		if typeof(slot_schema) == TYPE_DICTIONARY:
			result.append((slot_schema as Dictionary).duplicate(true))
	return result

func get_tackle_schema_slot_ids(tackle_type: String = "") -> Array:
	var slot_ids: Array = []
	for slot_schema in get_tackle_schema_slots(tackle_type):
		slot_ids.append(str(slot_schema.get("id", "")))
	return slot_ids

func get_required_tackle_slots(tackle_type: String = "") -> Array:
	var required_slots: Array = []
	for slot_schema in get_tackle_schema_slots(tackle_type):
		if bool(slot_schema.get("required", false)) and not is_tackle_slot_locked(str(slot_schema.get("id", ""))):
			required_slots.append(str(slot_schema.get("id", "")))
	return required_slots

func get_tackle_slot_title(slot_id: String, tackle_type: String = "") -> String:
	var slot_schema := get_tackle_slot_schema(slot_id, tackle_type)
	if not slot_schema.is_empty():
		return str(slot_schema.get("title", _get_tackle_slot_title(slot_id)))
	return _get_tackle_slot_title(slot_id)

func _get_tackle_slot_item_category(slot_id: String) -> String:
	var categories := get_tackle_slot_item_categories(slot_id)
	if categories.is_empty():
		return str(TACKLE_SLOT_ITEM_CATEGORIES.get(slot_id, slot_id))
	return str(categories[0])

func get_tackle_slot_item_categories(slot_id: String, tackle_type: String = "") -> Array:
	var slot_schema := get_tackle_slot_schema(slot_id, tackle_type)
	if not slot_schema.is_empty():
		var configured_categories = slot_schema.get("item_categories", [])
		if typeof(configured_categories) == TYPE_ARRAY:
			var categories: Array = []
			for category in configured_categories:
				var category_key := str(category)
				if category_key != "":
					categories.append(category_key)
			if not categories.is_empty():
				return categories
	var fallback_category := str(TACKLE_SLOT_ITEM_CATEGORIES.get(slot_id, slot_id))
	return [fallback_category] if fallback_category != "" else []

func is_tackle_slot_supported(slot_id: String) -> bool:
	return TACKLE_SLOTS.has(slot_id) or not get_tackle_slot_schema(slot_id).is_empty()

func is_tackle_slot_required(slot_id: String, tackle_type: String = "") -> bool:
	var slot_schema := get_tackle_slot_schema(slot_id, tackle_type)
	return bool(slot_schema.get("required", false)) if not slot_schema.is_empty() else REQUIRED_TACKLE_SLOTS.has(slot_id)

func is_tackle_slot_locked(slot_id: String, tackle_type: String = "") -> bool:
	var slot_schema := get_tackle_slot_schema(slot_id, tackle_type)
	var skill_key := str(slot_schema.get("skill", ""))
	if skill_key == "second_bait":
		return not can_use_second_bait()
	return false

func get_tackle_slot_lock_reason(slot_id: String, tackle_type: String = "") -> String:
	if not is_tackle_slot_locked(slot_id, tackle_type):
		return ""
	var slot_schema := get_tackle_slot_schema(slot_id, tackle_type)
	return str(slot_schema.get("locked_text", "Слот заблокирован навыком."))

func _is_tackle_item_category_supported(category: String) -> bool:
	if TACKLE_SLOT_ITEM_CATEGORIES.values().has(category):
		return true
	for schema_type in TACKLE_SLOT_SCHEMAS.keys():
		for slot_schema in get_tackle_schema_slots(str(schema_type)):
			var categories: Array = get_tackle_slot_item_categories(str(slot_schema.get("id", "")), str(schema_type))
			if categories.has(category):
				return true
	return false

func can_use_second_bait() -> bool:
	return get_skill_effect_value("unlock_double_bait") > 0.0 or get_skill_effect_value("second_bait_slot") > 0.0 or has_skill("float_double_bait") or has_skill("bait_sandwich")

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
	if is_tackle_slot_locked(slot_id):
		return false
	if item.is_empty():
		return false

	var slot_category := _get_tackle_slot_item_category(slot_id)
	var item_category := str(item.get("category", item.get("type", "")))
	var allowed_categories := get_tackle_slot_item_categories(slot_id)
	if not allowed_categories.has(item_category):
		return false
	if get_equip_block_reason(item, slot_id) != "":
		return false
	slot_category = item_category

	var original_item_id := str(item.get("id", ""))
	var resolved_item_id := _resolve_tackle_item_id(original_item_id)
	var catalog_item := get_tackle_catalog_item(resolved_item_id)
	var use_catalog_identity := resolved_item_id != original_item_id and not catalog_item.is_empty()
	var source_stats: Dictionary = catalog_item.get("stats", {}).duplicate(true) if use_catalog_identity and typeof(catalog_item.get("stats", {})) == TYPE_DICTIONARY else item.get("stats", {}).duplicate(true)
	var component: Dictionary = _normalize_equipment_stats(source_stats, slot_category, resolved_item_id)
	component["id"] = resolved_item_id
	component["name"] = str(catalog_item.get("name", "-") if use_catalog_identity else item.get("name", "-"))
	component["type"] = str(catalog_item.get("type", slot_category) if use_catalog_identity else item.get("type", slot_category))
	component["category"] = str(catalog_item.get("category", item_category) if use_catalog_identity else item_category)
	component["slot"] = slot_id
	component["rarity"] = str(catalog_item.get("rarity", "common") if use_catalog_identity else item.get("rarity", "common"))
	component["price"] = float(catalog_item.get("price", 0.0) if use_catalog_identity else item.get("price", 0.0))
	component["image_path"] = str(catalog_item.get("image_path", "") if use_catalog_identity else item.get("image_path", ""))
	component["description"] = str(catalog_item.get("description", "") if use_catalog_identity else item.get("description", ""))
	component["display_name_ru"] = str(catalog_item.get("display_name_ru", catalog_item.get("name", "-")) if use_catalog_identity else item.get("display_name_ru", catalog_item.get("display_name_ru", item.get("name", "-"))))
	component["description_ru"] = str(catalog_item.get("description_ru", catalog_item.get("description", "")) if use_catalog_identity else item.get("description_ru", catalog_item.get("description_ru", item.get("description", ""))))
	component["bonus_tags"] = _to_string_array(catalog_item.get("bonus_tags", []) if use_catalog_identity else item.get("bonus_tags", catalog_item.get("bonus_tags", component.get("bonus_tags", []))))
	for key in ["tackle_type", "fishing_type", "assembly_type", "rod_type"]:
		if catalog_item.has(key) or item.has(key):
			component[key] = str(catalog_item.get(key, item.get(key, "")) if use_catalog_identity else item.get(key, catalog_item.get(key, "")))

	if slot_category == "bait":
		component["quantity"] = int(item.get("quantity", 0))

	current_tackle[slot_id] = component
	if slot_id == "rod":
		_sync_tackle_slots_for_current_rod()
	if QUICK_TACKLE_CATEGORIES.has(slot_id):
		remember_recent_tackle_item(slot_id, resolved_item_id)
	return true

func clear_current_tackle_slot(slot_id: String) -> void:
	if not is_tackle_slot_supported(slot_id):
		return
	current_tackle[slot_id] = {}

func _sync_tackle_slots_for_current_rod() -> void:
	var rod := get_current_rod_data()
	if rod.is_empty():
		return
	if not bool(rod.get("requires_reel", false)):
		for reel_only_slot in ["reel", "lure", "feeder_rig", "hook_or_lure", "sinker_or_rig"]:
			if current_tackle.has(reel_only_slot):
				current_tackle[reel_only_slot] = {}
		return

	var reel := get_current_reel_data()
	if not reel.is_empty() and get_reel_compatibility_issue(reel, rod) != "":
		current_tackle["reel"] = {}

func can_equip_item(item: Dictionary) -> bool:
	return get_equip_block_reason(item) == ""

func get_equip_block_reason(item: Dictionary, slot_type: String = "") -> String:
	if item.is_empty():
		return "Предмет не выбран."

	var category := str(item.get("category", ""))
	if slot_type != "":
		if is_tackle_slot_locked(slot_type):
			return get_tackle_slot_lock_reason(slot_type)
		var expected_categories := get_tackle_slot_item_categories(slot_type)
		if not expected_categories.has(category):
			return "Не подходит к этой снасти."

	if not _is_tackle_item_category_supported(category):
		return "Не подходит к этой снасти."

	if _is_durable_tackle_category(category):
		var wear_percent := get_item_wear_percent(item)
		if wear_percent >= BROKEN_WEAR_PERCENT:
			return "Предмет сломан."
		if wear_percent >= REPAIR_BLOCK_WEAR_PERCENT:
			return "%s требует ремонта." % _get_tackle_slot_title(category)

	if category == "reel":
		var reel_stats: Dictionary = item.get("stats", {}).duplicate(true) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else item.duplicate(true)
		reel_stats["id"] = str(item.get("id", reel_stats.get("id", "")))
		var reel_issue := get_reel_compatibility_issue(reel_stats)
		if reel_issue != "":
			return reel_issue

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
	return ["rod", "reel", "line", "leader", "hook"].has(category)

func has_usable_basic_tackle() -> bool:
	for slot in get_required_tackle_slots():
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
	_grant_rescue_item(BASIC_LEADER_ID, 1)
	_grant_rescue_item(BASIC_FLOAT_ID, 1)
	_grant_rescue_item(hook_id, hook_quantity)
	_grant_rescue_item("worm", 5)
	_equip_rescue_items_if_needed(hook_id)

	rescue_kit_claims_total += 1
	rescue_kit_last_claim_day = _get_current_game_day()
	_save_after_rescue_kit()

	return {
		"allowed": true,
		"success": true,
		"message": "Базовый набор выдан: удочка, леска, поводок, поплавок, крючки и наживка."
	}

func _is_current_tackle_slot_usable(slot: String) -> bool:
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

	if ["rod", "reel", "line", "leader", "hook"].has(slot):
		return get_item_wear_percent(component) < REPAIR_BLOCK_WEAR_PERCENT

	return true

func _has_usable_owned_tackle_item(category: String) -> bool:
	var allowed_categories := get_tackle_slot_item_categories(category)
	if allowed_categories.is_empty():
		allowed_categories = [category]
	for item in owned_items:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var owned_item: Dictionary = item
		if not allowed_categories.has(str(owned_item.get("category", ""))):
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
		"leader": BASIC_LEADER_ID,
		"float": BASIC_FLOAT_ID,
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
		owned_item["display_name_ru"] = str(normalized_item.get("display_name_ru", owned_item.get("display_name_ru", owned_item.get("name", "-"))))
		owned_item["description_ru"] = str(normalized_item.get("description_ru", owned_item.get("description_ru", owned_item.get("description", ""))))
		owned_item["bonus_tags"] = _to_string_array(normalized_item.get("bonus_tags", owned_item.get("bonus_tags", [])))

		if ["rod", "reel", "line", "leader", "hook"].has(item_category):
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
		current_tackle[slot]["display_name_ru"] = str(owned_item.get("display_name_ru", current_tackle[slot].get("display_name_ru", current_tackle[slot].get("name", "-"))))
		current_tackle[slot]["description_ru"] = str(owned_item.get("description_ru", current_tackle[slot].get("description_ru", current_tackle[slot].get("description", ""))))
		current_tackle[slot]["bonus_tags"] = _to_string_array(owned_item.get("bonus_tags", current_tackle[slot].get("bonus_tags", [])))
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

	for slot_schema in get_tackle_schema_slots():
		var slot := str(slot_schema.get("id", ""))
		if slot == "" or is_tackle_slot_locked(slot):
			continue
		var issue := _get_tackle_slot_issue(slot, slot_schema)
		if issue != "":
			issues.append(issue)

	var dangling_reel = current_tackle.get("reel", {})
	if not get_current_rod_requires_reel() and typeof(dangling_reel) == TYPE_DICTIONARY and str(dangling_reel.get("id", "")) != "":
		issues.append("На маховую удочку катушка не ставится.")

	return issues

func get_tackle_setup_status_text() -> String:
	var issues := get_tackle_setup_issues()
	if issues.is_empty():
		return "Снасть готова к ловле."
	return "Снасть не готова:\n- %s" % "\n- ".join(issues)

func _get_tackle_slot_issue(slot: String, slot_schema: Dictionary = {}) -> String:
	var title := str(slot_schema.get("title", _get_tackle_slot_title(slot)))
	var slot_is_optional := not bool(slot_schema.get("required", REQUIRED_TACKLE_SLOTS.has(slot)))

	if is_tackle_slot_locked(slot):
		return ""
	if slot_is_optional:
		var optional_component = current_tackle.get(slot, {})
		if typeof(optional_component) != TYPE_DICTIONARY or str(optional_component.get("id", "")) == "":
			return ""

	if not current_tackle.has(slot):
		if slot == "leader":
			return "Установите поводок."
		return "%s не выбрана." % title

	var raw_component: Variant = current_tackle.get(slot, {})
	if typeof(raw_component) != TYPE_DICTIONARY:
		if slot == "leader":
			return "Установите поводок."
		return "%s не выбрана." % title

	var component: Dictionary = raw_component
	var item_id := str(component.get("id", ""))
	var item_name := str(component.get("name", title))
	if item_id == "":
		if slot == "leader":
			return "Установите поводок."
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

	if _is_durable_tackle_category(str(component.get("category", slot))):
		var wear_percent := get_item_wear_percent(component)
		if wear_percent >= BROKEN_WEAR_PERCENT:
			return "%s сломана: %s." % [title, item_name]
		if wear_percent >= REPAIR_BLOCK_WEAR_PERCENT:
			return "%s требует ремонта: %s." % [title, item_name]

	if slot == "reel":
		var reel_issue := get_reel_compatibility_issue(component)
		if reel_issue != "":
			return reel_issue

	return ""

func _get_tackle_slot_title(slot: String) -> String:
	if slot == "leader":
		return "Поводок"
	if slot == "bait_2":
		return "Наживка 2"
	match slot:
		"rod":
			return "Удочка"
		"reel":
			return "Катушка"
		"line":
			return "Леска"
		"float":
			return "Поплавок"
		"hook":
			return "Крючок"
		"bait":
			return "Наживка"
		"lure":
			return "Приманка"
		"feeder_rig":
			return "Оснастка"
		"hook_or_lure":
			return "Крючок или приманка"
		"sinker_or_rig":
			return "Груз/оснастка"
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
		"reel_broken": bool(wear.get("reel_broken", false)),
		"line_broken": bool(wear.get("line_broken", false)),
		"leader_broken": bool(wear.get("leader_broken", false)),
		"leader_lost": bool(wear.get("leader_lost", false)),
		"float_lost": bool(wear.get("float_lost", false)),
		"hook_lost": bool(wear.get("hook_lost", false)),
		"rod_old": get_tackle_condition("rod"),
		"reel_old": get_tackle_condition("reel"),
		"line_old": get_tackle_condition("line"),
		"leader_old": get_tackle_condition("leader"),
		"hook_old": get_tackle_condition("hook")
	}

	for slot in ["rod", "reel", "line", "leader", "hook"]:
		if not current_tackle.has(slot):
			continue

		var item_id := str(current_tackle[slot].get("id", ""))
		if item_id == "":
			continue
		var old_condition: float = get_tackle_condition(slot)
		var new_condition: float = clamp(old_condition - max(float(wear.get(slot, 0.0)), 0.0), 0.0, 1.0)

		if slot == "rod" and bool(wear.get("rod_broken", false)):
			new_condition = min(new_condition, 0.04)
		elif slot == "reel" and bool(wear.get("reel_broken", false)):
			new_condition = min(new_condition, 0.04)
		elif slot == "line" and bool(wear.get("line_broken", false)):
			var remaining_lines := _change_owned_item_quantity(item_id, -1)
			new_condition = 1.0 if remaining_lines > 0 else 0.0
		elif slot == "leader" and (bool(wear.get("leader_broken", false)) or bool(wear.get("leader_lost", false))):
			var remaining_leaders := _change_owned_item_quantity(item_id, -1)
			new_condition = 1.0 if remaining_leaders > 0 else 0.0
		elif slot == "hook" and bool(wear.get("hook_lost", false)):
			var remaining_hooks := _change_owned_item_quantity(item_id, -1)
			new_condition = 1.0 if remaining_hooks > 0 else 0.0

		current_tackle[slot]["durability"] = new_condition
		_set_owned_item_durability(item_id, new_condition)
		result["%s_new" % slot] = new_condition

	if bool(wear.get("float_lost", false)):
		var float_id := str(current_tackle.get("float", {}).get("id", ""))
		if float_id != "":
			var remaining_floats := _change_owned_item_quantity(float_id, -1)
			result["float_new_quantity"] = remaining_floats

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
	if get_current_tackle_type() == "spinning":
		var lure_id := str(current_tackle.get("lure", {}).get("id", ""))
		return lure_id != "" and _get_owned_item_quantity(lure_id) > 0
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

func consume_current_terminal_tackle_for_bite(amount: int = 1) -> bool:
	if get_current_tackle_type() == "spinning":
		var lure_id := str(current_tackle.get("lure", {}).get("id", ""))
		return lure_id != "" and _get_owned_item_quantity(lure_id) > 0
	return consume_current_tackle_baits(amount)

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

func get_current_float_data() -> Dictionary:
	var raw_component = current_tackle.get("float", {})
	if typeof(raw_component) != TYPE_DICTIONARY or str(raw_component.get("id", "")) == "":
		return _make_tackle_component(BASIC_FLOAT_ID)

	var component: Dictionary = (raw_component as Dictionary).duplicate(true)
	var original_id := str(component.get("id", ""))
	var resolved_id := _resolve_tackle_item_id(original_id)
	var catalog_item := get_tackle_catalog_item(resolved_id)
	var normalized: Dictionary = {}

	if not catalog_item.is_empty():
		var catalog_stats: Dictionary = catalog_item.get("stats", {}).duplicate(true) if typeof(catalog_item.get("stats", {})) == TYPE_DICTIONARY else {}
		catalog_stats.merge(component, true)
		normalized = _normalize_equipment_stats(catalog_stats, "float", resolved_id)
		normalized["id"] = resolved_id
		normalized["name"] = str(catalog_item.get("name", component.get("name", "-")))
		normalized["type"] = "float"
		normalized["category"] = "float"
		normalized["rarity"] = str(catalog_item.get("rarity", component.get("rarity", "common")))
		normalized["price"] = float(catalog_item.get("price", component.get("price", 0.0)))
		normalized["image_path"] = str(catalog_item.get("image_path", component.get("image_path", "")))
		normalized["description"] = str(catalog_item.get("description", component.get("description", "")))
		normalized["display_name_ru"] = str(catalog_item.get("display_name_ru", component.get("display_name_ru", catalog_item.get("name", ""))))
		normalized["description_ru"] = str(catalog_item.get("description_ru", component.get("description_ru", catalog_item.get("description", ""))))
		normalized["bonus_tags"] = _to_string_array(catalog_item.get("bonus_tags", component.get("bonus_tags", normalized.get("bonus_tags", []))))
	else:
		normalized = _normalize_equipment_stats(component, "float", resolved_id)
		normalized["id"] = resolved_id if resolved_id != "" else BASIC_FLOAT_ID
		normalized["type"] = "float"
		normalized["category"] = "float"
		normalized["display_name_ru"] = str(component.get("display_name_ru", component.get("name", "")))
		normalized["description_ru"] = str(component.get("description_ru", component.get("description", "")))
		normalized["bonus_tags"] = _to_string_array(component.get("bonus_tags", normalized.get("bonus_tags", [])))

	if original_id != str(normalized.get("id", "")):
		current_tackle["float"] = normalized.duplicate(true)

	return normalized.duplicate(true)

func _get_current_float_depth_match(float_part: Dictionary) -> float:
	var depth: float = float(fishing_depth)
	var min_depth: float = float(float_part.get("depth_min", PHYSICAL_SHORE_MIN_DEPTH))
	var max_depth: float = float(float_part.get("depth_max", 2.5))

	if depth >= min_depth and depth <= max_depth:
		return 1.0

	var distance: float = min(abs(depth - min_depth), abs(depth - max_depth))
	return clamp(1.0 - distance * 0.28, 0.58, 1.0)

func _is_current_time_night() -> bool:
	var time_manager := get_node_or_null("/root/TimeManager")
	if time_manager != null and time_manager.has_method("get_time_state"):
		var state = time_manager.call("get_time_state")
		if state is Dictionary:
			return str((state as Dictionary).get("time_of_day", "")) == "night"
	if time_manager != null:
		return str(time_manager.get("time_of_day")) == "night"
	return false

func _get_bait_float_load(bait_part: Dictionary) -> float:
	if bait_part.is_empty():
		return 0.0

	var tags: Array = _to_string_array(bait_part.get("bait_tags", []))
	var bait_id: String = str(bait_part.get("id", bait_part.get("bait_id", "")))
	var bait_type: String = str(bait_part.get("bait_type", ""))
	var load := 0.0

	if tags.has("large") or tags.has("live_bait"):
		load += 0.34
	if tags.has("predator") or tags.has("crustacean") or tags.has("shellfish"):
		load += 0.16
	if tags.has("bottom") and (bait_type == "worm" or bait_type == "maggot"):
		load += 0.06
	if ["fish_piece", "small_live_bait", "frog_bait", "rakovaia_sheika", "krabovoe_myaso", "vipolzok", "medvedka"].has(bait_id):
		load += 0.18

	load += clamp(float(bait_part.get("fish_attraction", 0.0)) - 0.14, 0.0, 0.12) * 0.55
	return clamp(load, 0.0, 0.45)

func get_tackle_stats() -> Dictionary:
	var rod: Dictionary = _normalize_equipment_stats(current_tackle.get("rod", {}).duplicate(true), "rod")
	var line: Dictionary = _normalize_equipment_stats(current_tackle.get("line", {}).duplicate(true), "line")
	var leader: Dictionary = _normalize_equipment_stats(current_tackle.get("leader", {}).duplicate(true), "leader")
	var float_part: Dictionary = get_current_float_data()
	var hook: Dictionary = _normalize_equipment_stats(current_tackle.get("hook", {}).duplicate(true), "hook")
	var bait: Dictionary = _normalize_equipment_stats(current_tackle.get("bait", {}).duplicate(true), "bait", str(current_tackle.get("bait", {}).get("id", "")))
	var tackle_type_key := normalize_tackle_type(_get_tackle_type_from_item(rod))
	var rod_requires_reel := bool(rod.get("requires_reel", false))
	var fight_mode := "reel" if rod_requires_reel else "pole"
	if not BuildConfig.ENABLE_SPINNING_FEATURES:
		tackle_type_key = DEFAULT_TACKLE_TYPE
		rod_requires_reel = false
		fight_mode = "pole"
	var reel: Dictionary = get_current_reel_data() if rod_requires_reel else {}
	var lure: Dictionary = _normalize_equipment_stats(current_tackle.get("lure", {}).duplicate(true), "lure", str(current_tackle.get("lure", {}).get("id", "")))
	if tackle_type_key == "spinning":
		hook = lure.duplicate(true)
		bait = lure.duplicate(true)
	var second_bait: Dictionary = _normalize_equipment_stats(current_tackle.get("bait_2", {}).duplicate(true), "bait", str(current_tackle.get("bait_2", {}).get("id", ""))) if _has_active_second_bait() and tackle_type_key != "spinning" else {}
	var skill_effects := get_skill_effects()
	var hook_skill_bonus: float = max(float(skill_effects.get("hook_success_chance", 0.0)), 0.0)
	var float_stability_skill_bonus: float = max(float(skill_effects.get("float_reeling_stability", 0.0)), 0.0)
	var escape_skill_reduction: float = clamp(float(skill_effects.get("fish_escape_chance_reduction", 0.0)), 0.0, 0.85)
	var line_break_skill_reduction: float = clamp(float(skill_effects.get("line_break_chance_reduction", 0.0)) + float(skill_effects.get("thin_tackle_break_reduction", 0.0)), 0.0, 0.85)
	var double_bait_skill_bonus: float = clamp(float(skill_effects.get("double_bait_bite_bonus", 0.0)), 0.0, 0.20)
	var cautious_fish_bite_bonus: float = clamp(float(skill_effects.get("cautious_fish_bite_chance", 0.0)), 0.0, 0.20)
	var rod_durability: float = clamp(float(rod.get("durability", 1.0)), 0.0, 1.0)
	var reel_durability: float = clamp(float(reel.get("durability", 1.0)), 0.0, 1.0) if rod_requires_reel and not reel.is_empty() else 1.0
	var line_durability: float = clamp(float(line.get("durability", 1.0)), 0.0, 1.0)
	var leader_durability: float = clamp(float(leader.get("durability", 1.0)), 0.0, 1.0)
	var hook_durability: float = clamp(float(hook.get("durability", 1.0)), 0.0, 1.0)
	var rod_condition: float = lerp(0.45, 1.0, rod_durability)
	var reel_condition: float = lerp(0.45, 1.0, reel_durability)
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
	var line_strength_bonus: float = max(float(skill_effects.get("line_strength_bonus", 0.0)) + line_break_skill_reduction * 0.30, -0.95)
	var line_strength: float = raw_line_strength * line_condition * (1.0 + line_strength_bonus)
	var line_visibility: float = float(line.get("visibility", line.get("visibility_penalty", 0.0)))
	var has_leader := str(current_tackle.get("leader", {}).get("id", "")) != ""
	var leader_strength: float = float(leader.get("strength", line_strength)) * leader_condition
	var leader_visibility: float = float(leader.get("visibility", 0.0)) if has_leader else 0.0
	var leader_bite_protection: float = float(leader.get("bite_protection", 0.0)) * leader_condition if has_leader else 0.0
	var leader_control_bonus: float = float(leader.get("control_bonus", 0.0)) * leader_condition if has_leader else 0.0
	var leader_cautious_bite_bonus: float = float(leader.get("cautious_bite_bonus", 0.0)) if has_leader else 0.0
	var leader_small_fish_penalty: float = float(leader.get("small_fish_penalty", 0.0)) if has_leader else 0.0
	var leader_break_resistance: float = float(leader.get("break_resistance", 1.0)) * leader_condition if has_leader else 1.0
	var leader_break_chance: float = float(leader.get("break_chance", 0.14)) / max(leader_condition, 0.1) if has_leader else 0.0
	var leader_wear_rate: float = float(leader.get("wear_rate", 0.020)) if has_leader else 0.0
	var leader_length_cm: int = int(leader.get("length_cm", 0)) if has_leader else 0
	var leader_material: String = str(leader.get("material", leader.get("leader_type", ""))) if has_leader else ""
	var effective_break_resistance: float = float(line.get("break_resistance", 1.0)) * lerp(0.35, 1.0, line_durability)
	var effective_break_chance: float = float(line.get("break_chance", 0.15)) * (1.0 - line_break_skill_reduction) / max(lerp(0.45, 1.0, line_durability), 0.1)
	if has_leader:
		line_strength = min(line_strength, max(leader_strength * 1.08, 0.05))
		line_visibility = clamp(line_visibility + leader_visibility * 0.55 - leader_bite_protection * 0.25, 0.0, 0.65)
		effective_break_resistance = min(effective_break_resistance, leader_break_resistance) * (1.0 + leader_bite_protection * 0.45)
		effective_break_chance = max(effective_break_chance, leader_break_chance) / max(1.0 + leader_bite_protection * 0.65, 0.1)
	var float_night_bonus_rating: float = clamp(float(float_part.get("night_bonus", 0.0)), 0.0, 0.60) if _is_current_time_night() else 0.0
	var float_setup_comfort_rating: float = clamp(float(float_part.get("setup_comfort", 0.0)), 0.0, 0.20)
	var float_sensitivity_rating: float = clamp(float(float_part.get("sensitivity", 0.85)), 0.0, 1.0)
	var float_stability_rating: float = clamp(float(float_part.get("stability", 0.75)) + float_setup_comfort_rating * 0.08 + float_stability_skill_bonus, 0.0, 1.0)
	var float_bite_visibility_rating: float = clamp(float(float_part.get("bite_visibility", 0.85)) + float_night_bonus_rating * 0.30, 0.0, 1.0)
	var float_false_bite_resistance_rating: float = clamp(float(float_part.get("false_bite_resistance", 0.65)) + float_setup_comfort_rating * 0.10 + (0.05 if float_night_bonus_rating > 0.0 else 0.0), 0.0, 1.0)
	var float_hook_timing_bonus: float = clamp(float(float_part.get("hook_timing_bonus", 0.0)), 0.0, 0.20)
	var float_long_range_accuracy_bonus: float = clamp(float(float_part.get("long_range_accuracy_bonus", 0.0)), 0.0, 0.20)
	var float_heavy_bait_support_rating: float = clamp(float(float_part.get("heavy_bait_support", 0.55)), 0.0, 1.0)
	var float_depth_match: float = _get_current_float_depth_match(float_part)
	var float_sensitivity: float = clamp((float_sensitivity_rating - 0.45) * 0.30, 0.0, 0.18)
	var float_stability: float = clamp(float_stability_rating * 0.22, 0.0, 0.24)
	var float_bite_visibility: float = clamp((float_bite_visibility_rating - 0.45) * 0.22 + float_night_bonus_rating * 0.10, 0.0, 0.24)
	var hook_chance: float = float(hook.get("hook_chance", hook.get("hook_success_bonus", 0.0))) * hook_condition + hook_skill_bonus
	var hook_strength: float = float(hook.get("hook_strength", 1.0)) * hook_condition
	var raw_escape_modifier: float = float(hook.get("fish_escape_modifier", 1.0)) * (1.0 - escape_skill_reduction)
	var line_wear_reduction: float = clamp(float(skill_effects.get("line_wear_reduction", 0.0)), 0.0, 0.85)
	var line_wear_rate: float = max(float(line.get("wear_rate", 0.022)) * (1.0 - line_wear_reduction), 0.001)
	var leader_bite_setup_bonus: float = clamp(leader_cautious_bite_bonus * 0.45 - leader_small_fish_penalty * 0.25 - max(leader_visibility - 0.10, 0.0) * 0.18, -0.08, 0.07) if has_leader else 0.0
	var bite_detection_bonus: float = float_sensitivity + float_bite_visibility * 0.50 + float(skill_effects.get("bite_detection_bonus", 0.0)) + leader_bite_setup_bonus
	var bait_id := str(bait.get("id", bait.get("bait_id", "")))
	var secondary_bait_id := ""
	var bait_types: Array = [str(bait.get("bait_type", "worm"))]
	var secondary_bait_type := ""
	var bait_tags: Array = _to_string_array(bait.get("bait_tags", []))
	var target_fish_ids: Array = _to_string_array(bait.get("target_fish_ids", []))
	var secondary_fish_ids: Array = _to_string_array(bait.get("secondary_fish_ids", []))
	var fish_attraction: float = clamp(float(bait.get("fish_attraction", 0.0)) + cautious_fish_bite_bonus * 0.35, 0.0, 0.14)
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
		fish_attraction = clamp(max(fish_attraction, second_base_attraction) + min(fish_attraction, second_base_attraction) * 0.35 + 0.01 + double_bait_skill_bonus * 0.35, 0.0, 0.20)
		var second_attraction_by_id = second_bait.get("fish_attraction_by_id", {})
		if typeof(second_attraction_by_id) == TYPE_DICTIONARY:
			for fish_id in second_attraction_by_id.keys():
				var merged_fish_id := str(fish_id)
				var current_attraction := float(fish_attraction_by_id.get(merged_fish_id, 0.0))
				var second_attraction := float(second_attraction_by_id[fish_id])
				if current_attraction > 0.0 and second_attraction > 0.0:
					fish_attraction_by_id[merged_fish_id] = clamp(max(current_attraction, second_attraction) + min(current_attraction, second_attraction) * 0.35 + 0.03 + double_bait_skill_bonus, 0.0, 0.48)
				else:
					fish_attraction_by_id[merged_fish_id] = max(current_attraction, second_attraction)
		var second_allowed = second_bait.get("allowed_rarities", [])
		if typeof(second_allowed) == TYPE_ARRAY:
			for rarity in second_allowed:
				if not allowed_rarities.has(rarity):
					allowed_rarities.append(rarity)

	var heavy_bait_load: float = _get_bait_float_load(bait)
	if not second_bait.is_empty():
		heavy_bait_load = max(heavy_bait_load, _get_bait_float_load(second_bait) * 0.85)
	var heavy_bait_penalty: float = clamp(heavy_bait_load * (1.0 - float_heavy_bait_support_rating * 0.60), 0.0, 0.22)
	bite_detection_bonus = max(bite_detection_bonus - heavy_bait_penalty * 0.35, -0.15)

	return {
		"tackle_type": tackle_type_key,
		"tackle_type_title": get_current_tackle_type_title(),
		"fight_mode": fight_mode,
		"rod_type": str(rod.get("rod_type", "pole")),
		"requires_reel": rod_requires_reel,
		"reel_equipped": rod_requires_reel and not reel.is_empty(),
		"control_bonus": rod_tension_bonus + leader_control_bonus,
		"tension_bonus": rod_tension_bonus + leader_control_bonus,
		"base_control_bonus": raw_rod_control * rod_condition,
		"handling_bonus": rod_handling_bonus * rod_condition,
		"reach_bonus": rod_reach_bonus,
		"length_m": float(rod.get("length_m", 4.0)),
		"rod_length_m": float(rod.get("length_m", 4.0)),
		"rod_class": str(rod.get("rod_class", "medium")),
		"rod_power": float(rod.get("power", rod.get("strength", 1.0))),
		"rod_test_min": float(rod.get("test_min", 0.0)),
		"rod_test_max": float(rod.get("test_max", rod.get("max_fish_weight", 1.0))),
		"rod_flexibility": float(rod.get("flexibility", 0.5)),
		"compatible_reel_min_size": int(rod.get("compatible_reel_min_size", 0)),
		"compatible_reel_max_size": int(rod.get("compatible_reel_max_size", 0)),
		"durability": rod_durability,
		"rod_durability": rod_durability,
		"reel_durability": reel_durability,
		"reel_id": str(reel.get("id", "")),
		"reel_name": str(reel.get("name", "")),
		"reel_size": int(reel.get("reel_size", 0)),
		"reel_type": str(reel.get("reel_type", "")),
		"reel_max_drag": float(reel.get("max_drag", 0.0)) * reel_condition if rod_requires_reel and not reel.is_empty() else 0.0,
		"max_drag": float(reel.get("max_drag", 0.0)) * reel_condition if rod_requires_reel and not reel.is_empty() else 0.0,
		"drag_value": float(reel.get("max_drag", 0.0)) * reel_condition * 0.45 if rod_requires_reel and not reel.is_empty() else 0.0,
		"drag_percent": 0.45 if rod_requires_reel and not reel.is_empty() else 0.0,
		"retrieve_speed": float(reel.get("retrieve_speed", 0.0)) * reel_condition if rod_requires_reel and not reel.is_empty() else 0.0,
		"spool_capacity": float(reel.get("spool_capacity", 0.0)) if rod_requires_reel and not reel.is_empty() else 0.0,
		"line_out": 0.0,
		"reel_weight": float(reel.get("weight", 0.0)) if rod_requires_reel and not reel.is_empty() else 0.0,
		"reel_wear_rate": float(reel.get("wear_rate", 0.0)) if rod_requires_reel and not reel.is_empty() else 0.0,
		"reel_body_texture": str(reel.get("body_texture", "")),
		"reel_spool_texture": str(reel.get("spool_texture", "")),
		"reel_handle_texture": str(reel.get("handle_texture", "")),
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
		"break_resistance": effective_break_resistance,
		"break_chance": effective_break_chance,
		"line_wear_rate": line_wear_rate,
		"wear_rate": line_wear_rate,
		"visibility": line_visibility,
		"visibility_penalty": line_visibility,
		"leader_strength": leader_strength if has_leader else 0.0,
		"leader_test_kg": leader_strength if has_leader else 0.0,
		"leader_length_cm": leader_length_cm,
		"leader_material": leader_material,
		"leader_visibility": leader_visibility,
		"leader_bite_protection": leader_bite_protection,
		"leader_control_bonus": leader_control_bonus,
		"leader_cautious_bite_bonus": leader_cautious_bite_bonus,
		"leader_small_fish_penalty": leader_small_fish_penalty,
		"leader_break_resistance": leader_break_resistance,
		"leader_break_chance": leader_break_chance,
		"leader_wear_rate": leader_wear_rate,
		"leader_bite_setup_bonus": leader_bite_setup_bonus,
		"sensitivity": float_sensitivity,
		"bite_visibility": float_bite_visibility,
		"bite_detection_bonus": bite_detection_bonus,
		"green_zone_bonus": float(skill_effects.get("green_zone_bonus", 0.0)),
		"stability": float_stability,
		"float_id": str(float_part.get("id", BASIC_FLOAT_ID)),
		"float_type": str(float_part.get("float_type", "drop")),
		"float_name": str(float_part.get("name", "")),
		"float_buoyancy": float(float_part.get("buoyancy", 1.0)),
		"float_sensitivity_rating": float_sensitivity_rating,
		"float_stability_rating": float_stability_rating,
		"float_bite_visibility_rating": float_bite_visibility_rating,
		"wind_resistance": clamp(float(float_part.get("wind_resistance", 0.65)), 0.0, 1.0),
		"drift_resistance": clamp(float(float_part.get("drift_resistance", 0.65)), 0.0, 1.0),
		"cast_distance_bonus": clamp(float(float_part.get("cast_distance_bonus", 0.0)), -0.20, 0.25),
		"false_bite_resistance": float_false_bite_resistance_rating,
		"depth_min": float(float_part.get("depth_min", PHYSICAL_SHORE_MIN_DEPTH)),
		"depth_max": float(float_part.get("depth_max", 2.5)),
		"float_depth_match": float_depth_match,
		"night_bonus": float_night_bonus_rating,
		"vegetation_control": clamp(float(float_part.get("vegetation_control", 0.55)), 0.0, 1.0),
		"heavy_bait_support": float_heavy_bait_support_rating,
		"heavy_bait_load": heavy_bait_load,
		"heavy_bait_penalty": heavy_bait_penalty,
		"hook_timing_bonus": float_hook_timing_bonus,
		"long_range_accuracy_bonus": float_long_range_accuracy_bonus,
		"setup_comfort": float_setup_comfort_rating,
		"recommended_spots": _to_string_array(float_part.get("recommended_spots", [])),
		"hook_size": int(hook.get("hook_size", 12)),
		"hook_chance": hook_chance,
		"hook_success_bonus": hook_chance,
		"hook_strength": hook_strength,
		"hook_wear_rate": float(hook.get("wear_rate", 0.026)),
		"target_fish_size": str(hook.get("target_fish_size", "small")),
		"fish_escape_modifier": raw_escape_modifier * lerp(1.45, 1.0, hook_durability),
		"lure_id": str(lure.get("id", lure.get("bait_id", ""))),
		"lure_type": str(lure.get("lure_type", "")),
		"lure_weight": float(lure.get("weight", 0.0)),
		"lure_durability": clamp(float(lure.get("durability", 1.0)), 0.0, 1.0),
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
		"allowed_rarities": allowed_rarities,
		"double_bait_bite_bonus": double_bait_skill_bonus,
		"cautious_fish_bite_bonus": cautious_fish_bite_bonus,
		"hook_skill_bonus": hook_skill_bonus,
		"escape_skill_reduction": escape_skill_reduction,
		"line_break_skill_reduction": line_break_skill_reduction
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
	var stats := get_tackle_stats()
	if str(stats.get("fight_mode", "pole")) == "reel":
		return "Текущая снасть:\nУдилище: %s\nКатушка: %s (%d)\nЛеска: %s\nПриманка/крючок: %s\nФрикцион: %.1f кг | Шпуля: %.0f м\nПрочность: уд. %d%% | кат. %d%% | леска %d%%" % [
			current_tackle.get("rod", {}).get("name", "-"),
			current_tackle.get("reel", {}).get("name", "-"),
			int(stats.get("reel_size", 0)),
			current_tackle.get("line", {}).get("name", "-"),
			current_tackle.get("lure", {}).get("name", current_tackle.get("hook", {}).get("name", "-")),
			float(stats.get("max_drag", 0.0)),
			float(stats.get("spool_capacity", 0.0)),
			roundi(get_tackle_condition("rod") * 100.0),
			roundi(get_tackle_condition("reel") * 100.0),
			roundi(get_tackle_condition("line") * 100.0)
		]
	return "Текущая снасть:\nУдочка: %s\nЛеска: %s\nПоводок: %s\nПоплавок: %s\nКрючок: %s\nНаживка: %s x%d\nГлубина: %.1f м\nПрочность: уд. %d%% | леска %d%% | поводок %d%% | крючок %d%%" % [
		current_tackle.get("rod", {}).get("name", "-"),
		current_tackle.get("line", {}).get("name", "-"),
		current_tackle.get("leader", {}).get("name", "-"),
		current_tackle.get("float", {}).get("name", "-"),
		current_tackle.get("hook", {}).get("name", "-"),
		current_tackle.get("bait", {}).get("name", "-"),
		get_current_bait_quantity(),
		fishing_depth,
		roundi(get_tackle_condition("rod") * 100.0),
		roundi(get_tackle_condition("line") * 100.0),
		roundi(get_tackle_condition("leader") * 100.0),
		roundi(get_tackle_condition("hook") * 100.0)
	]
