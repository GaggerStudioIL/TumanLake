extends Node

const DEFAULT_RANK_COSTS := [1, 2, 3, 4, 5]

const TREE_ORDER := [
	"float_fishing",
	"bottom_fishing",
	"spinning",
	"sea_fishing",
	"fishing_craft",
	"cooking",
	"survival"
]

const TREES := {
	"float_fishing": {
		"id": "float_fishing",
		"title": "Маховая ловля",
		"icon": "float",
		"description": "Искусство ловли на поплавочную маховую удочку.",
		"ui_order": 1
	},
	"bottom_fishing": {
		"id": "bottom_fishing",
		"title": "Донная ловля",
		"icon": "bottom",
		"description": "Точная и сильная ловля на донные снасти.",
		"ui_order": 2
	},
	"spinning": {
		"id": "spinning",
		"title": "Спиннинг",
		"icon": "spinning",
		"description": "Основа будущей ловли хищника на приманки.",
		"ui_order": 3
	},
	"sea_fishing": {
		"id": "sea_fishing",
		"title": "Морская ловля",
		"icon": "sea",
		"description": "Контроль глубины, дистанции и крупной морской рыбы.",
		"ui_order": 4
	},
	"fishing_craft": {
		"id": "fishing_craft",
		"title": "Рыболовное ремесло",
		"icon": "craft",
		"description": "Добыча наживки, создание снастей, прикормки и ремонт.",
		"ui_order": 5
	},
	"cooking": {
		"id": "cooking",
		"title": "Кулинария",
		"icon": "cooking",
		"description": "Еда, рыбные блюда, хранение и временные бонусы.",
		"ui_order": 6
	},
	"survival": {
		"id": "survival",
		"title": "Выживание",
		"icon": "survival",
		"description": "Холод, жара, энергия, ночная рыбалка и лагерь.",
		"ui_order": 7
	}
}

const SKILLS := {
	"float_soft_hookset": {
		"title": "Мягкая подсечка",
		"tree_id": "float_fishing",
		"icon": "hook",
		"description": "Повышает шанс успешной подсечки и снижает риск плохой засечки в начале вываживания.",
		"effect_type": "hook_success_chance",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"ui_order": 1
	},
	"float_bobber_control": {
		"title": "Работа с поплавком",
		"tree_id": "float_fishing",
		"icon": "float",
		"description": "Делает поведение поплавка и натяжение снасти стабильнее при поклёвке и начале вываживания.",
		"effect_type": "float_reeling_stability",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 2,
		"required_skills": {"float_soft_hookset": 1},
		"ui_order": 2
	},
	"float_confident_reeling": {
		"title": "Уверенное вываживание",
		"tree_id": "float_fishing",
		"icon": "reel",
		"description": "Снижает шанс схода рыбы, если натяжение выходит из безопасной зоны шкалы вываживания.",
		"effect_type": "fish_escape_chance_reduction",
		"effect_value_per_rank": [0.05, 0.10, 0.15, 0.20, 0.25],
		"required_player_level": 4,
		"required_skills": {"float_bobber_control": 1},
		"ui_order": 3
	},
	"float_thin_tackle": {
		"title": "Тонкая снасть",
		"tree_id": "float_fishing",
		"icon": "line",
		"description": "Снижает риск обрыва тонкой лески и тонкого поводка при ловле осторожной рыбы.",
		"effect_type": "thin_tackle_break_reduction",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 6,
		"required_skills": {"float_confident_reeling": 1},
		"ui_order": 4
	},
	"float_double_bait": {
		"title": "Ловля на бутерброд",
		"tree_id": "float_fishing",
		"icon": "bait",
		"description": "Открывает второй слот наживки для маховой снасти. Старшие ранги повышают шанс поклёвки, если обе наживки подходят рыбе.",
		"effect_type": "unlock_double_bait",
		"effect_value_per_rank": [1.0, 1.0, 1.0, 1.0, 1.0],
		"effects": {
			"unlock_double_bait": [1.0, 1.0, 1.0, 1.0, 1.0],
			"second_bait_slot": [1.0, 1.0, 1.0, 1.0, 1.0],
			"double_bait_bite_bonus": [0.0, 0.02, 0.04, 0.06, 0.08]
		},
		"required_player_level": 8,
		"required_skills": {"float_soft_hookset": 2},
		"ui_order": 5
	},
	"float_fishing_xp": {
		"title": "Опыт поплавочника",
		"tree_id": "float_fishing",
		"icon": "xp",
		"description": "Увеличивает опыт за рыбу, пойманную на маховую снасть.",
		"effect_type": "float_fishing_xp_bonus",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 10,
		"required_skills": {"float_confident_reeling": 2},
		"ui_order": 6
	},
	"float_master": {
		"title": "Мастер маховой ловли",
		"tree_id": "float_fishing",
		"icon": "master",
		"description": "Финальный навык ветки. Даёт общий бонус к маховой ловле.",
		"max_rank": 1,
		"rank_costs": [5],
		"effect_type": "float_master_bonus",
		"effect_value_per_rank": [1.0],
		"effects": {
			"float_master_bonus": [1.0],
			"float_fishing_xp_bonus": [0.10],
			"fish_escape_chance_reduction": [0.10],
			"cautious_fish_bite_chance": [0.05]
		},
		"required_player_level": 25,
		"required_points_in_tree": 55,
		"required_skills": {"float_confident_reeling": 4, "float_double_bait": 1, "float_fishing_xp": 3},
		"is_final_skill": true,
		"ui_order": 99
	},

	"bottom_clip_accuracy": {
		"title": "Точное клипсование",
		"tree_id": "bottom_fishing",
		"icon": "target",
		"description": "Уменьшает разброс точки заброса при донной ловле.",
		"effect_type": "bottom_cast_accuracy",
		"effect_value_per_rank": [0.05, 0.10, 0.15, 0.20, 0.25],
		"ui_order": 1
	},
	"bottom_cast_distance": {
		"title": "Дальний заброс",
		"tree_id": "bottom_fishing",
		"icon": "cast",
		"description": "Увеличивает максимальную дистанцию заброса донной снастью.",
		"effect_type": "bottom_cast_distance",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 4,
		"required_skills": {"bottom_clip_accuracy": 1},
		"ui_order": 2
	},
	"bottom_groundbait_efficiency": {
		"title": "Эффективность прикормки",
		"tree_id": "bottom_fishing",
		"icon": "groundbait",
		"description": "Прикормка работает дольше и немного сильнее привлекает рыбу при донной ловле.",
		"effect_type": "groundbait_duration_bonus",
		"effect_value_per_rank": [0.05, 0.10, 0.15, 0.20, 0.25],
		"required_player_level": 6,
		"required_skills": {"bottom_clip_accuracy": 2},
		"ui_order": 3
	},
	"bottom_big_fish_control": {
		"title": "Крупная рыба на донку",
		"tree_id": "bottom_fishing",
		"icon": "fish",
		"description": "Снижает силу рывков крупной рыбы при ловле на донную снасть.",
		"effect_type": "big_fish_control",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 8,
		"required_skills": {"bottom_cast_distance": 2},
		"ui_order": 4
	},
	"bottom_reliable_rig": {
		"title": "Надёжная оснастка",
		"tree_id": "bottom_fishing",
		"icon": "rig",
		"description": "Снижает риск обрыва поводка или основной лески при донной ловле.",
		"effect_type": "line_break_chance_reduction",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 10,
		"required_skills": {"bottom_big_fish_control": 1},
		"ui_order": 5
	},
	"bottom_master": {
		"title": "Легенда донки",
		"tree_id": "bottom_fishing",
		"icon": "master",
		"description": "Финальный навык ветки донной ловли.",
		"max_rank": 1,
		"rank_costs": [5],
		"effect_type": "bottom_master_bonus",
		"effect_value_per_rank": [1.0],
		"effects": {
			"bottom_master_bonus": [1.0],
			"groundbait_duration_bonus": [0.10],
			"big_fish_control": [0.10],
			"bottom_quality_fish_chance": [0.05]
		},
		"required_player_level": 30,
		"required_points_in_tree": 45,
		"required_skills": {"bottom_groundbait_efficiency": 4, "bottom_reliable_rig": 3},
		"is_final_skill": true,
		"ui_order": 99
	},

	"spinning_retrieve_speed": {
		"title": "Скорость проводки",
		"tree_id": "spinning",
		"icon": "speed",
		"description": "Позволяет лучше контролировать скорость проводки приманки, когда спиннинг будет реализован.",
		"effect_type": "retrieve_speed_control",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"ui_order": 1
	},
	"spinning_spoon_mastery": {
		"title": "Блёсны",
		"tree_id": "spinning",
		"icon": "spoon",
		"description": "Повышает эффективность ловли на блёсны.",
		"effect_type": "spoon_efficiency_bonus",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 8,
		"required_skills": {"spinning_retrieve_speed": 1},
		"ui_order": 2
	},
	"spinning_wobbler_mastery": {
		"title": "Воблеры",
		"tree_id": "spinning",
		"icon": "wobbler",
		"description": "Повышает эффективность ловли на воблеры.",
		"effect_type": "wobbler_efficiency_bonus",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 10,
		"required_skills": {"spinning_retrieve_speed": 1},
		"ui_order": 3
	},
	"spinning_jig_mastery": {
		"title": "Джиг",
		"tree_id": "spinning",
		"icon": "jig",
		"description": "Повышает эффективность джиговых приманок.",
		"effect_type": "jig_efficiency_bonus",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 12,
		"required_skills": {"spinning_retrieve_speed": 2},
		"ui_order": 4
	},
	"spinning_predator_control": {
		"title": "Контроль хищника",
		"tree_id": "spinning",
		"icon": "predator",
		"description": "Снижает силу рывков хищной рыбы при вываживании на спиннинг.",
		"effect_type": "predator_control",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 14,
		"required_skills": {"spinning_spoon_mastery": 1, "spinning_wobbler_mastery": 1},
		"ui_order": 5
	},
	"spinning_master": {
		"title": "Гроза хищников",
		"tree_id": "spinning",
		"icon": "master",
		"description": "Финальный навык ветки спиннинга.",
		"max_rank": 1,
		"rank_costs": [5],
		"effect_type": "spinning_master_bonus",
		"effect_value_per_rank": [1.0],
		"effects": {
			"spinning_master_bonus": [1.0],
			"predator_bite_chance": [0.05],
			"predator_escape_reduction": [0.10],
			"predator_break_reduction": [0.10]
		},
		"required_player_level": 35,
		"required_points_in_tree": 45,
		"required_skills": {"spinning_predator_control": 4, "spinning_jig_mastery": 3},
		"is_final_skill": true,
		"ui_order": 99
	},

	"sea_fish_control": {
		"title": "Контроль морской рыбы",
		"tree_id": "sea_fishing",
		"icon": "sea_fish",
		"description": "Снижает силу рывков морской рыбы.",
		"effect_type": "sea_fish_control",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"ui_order": 1
	},
	"sea_cast_distance": {
		"title": "Дальний морской заброс",
		"tree_id": "sea_fishing",
		"icon": "cast",
		"description": "Увеличивает доступную дистанцию заброса на морских снастях.",
		"effect_type": "sea_cast_distance",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 12,
		"required_skills": {"sea_fish_control": 1},
		"ui_order": 2
	},
	"sea_deep_water": {
		"title": "Глубокая вода",
		"tree_id": "sea_fishing",
		"icon": "depth",
		"description": "Повышает эффективность ловли на больших глубинах.",
		"effect_type": "deep_water_efficiency",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 14,
		"required_skills": {"sea_cast_distance": 1},
		"ui_order": 3
	},
	"sea_rare_fish": {
		"title": "Редкая морская рыба",
		"tree_id": "sea_fishing",
		"icon": "rare",
		"description": "Немного повышает шанс редкой морской рыбы, если снасть, наживка и место подходят.",
		"effect_type": "sea_rare_fish_chance",
		"effect_value_per_rank": [0.01, 0.02, 0.03, 0.04, 0.05],
		"required_player_level": 16,
		"required_skills": {"sea_deep_water": 2},
		"ui_order": 4
	},
	"sea_trophy_fight": {
		"title": "Борьба с трофеем",
		"tree_id": "sea_fishing",
		"icon": "trophy",
		"description": "Снижает риск схода и обрыва при ловле очень крупной морской рыбы.",
		"effect_type": "sea_trophy_break_escape_reduction",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 18,
		"required_skills": {"sea_rare_fish": 1},
		"ui_order": 5
	},
	"sea_master": {
		"title": "Капитан океана",
		"tree_id": "sea_fishing",
		"icon": "master",
		"description": "Финальный навык ветки морской ловли.",
		"max_rank": 1,
		"rank_costs": [5],
		"effect_type": "sea_master_bonus",
		"effect_value_per_rank": [1.0],
		"effects": {
			"sea_master_bonus": [1.0],
			"sea_rare_fish_chance": [0.05],
			"sea_fish_control": [0.10],
			"sea_trophy_break_escape_reduction": [0.10]
		},
		"required_player_level": 45,
		"required_points_in_tree": 45,
		"required_skills": {"sea_trophy_fight": 4, "sea_rare_fish": 3},
		"is_final_skill": true,
		"ui_order": 99
	},

	"craft_worm_gathering": {
		"title": "Добыча червей",
		"tree_id": "fishing_craft",
		"icon": "worm",
		"description": "Открывает добычу червей без покупки в магазине.",
		"effect_type": "bait_gathering_unlock",
		"effect_value_per_rank": [1, 2, 3, 4, 5],
		"ui_order": 1
	},
	"craft_insect_gathering": {
		"title": "Добыча насекомых",
		"tree_id": "fishing_craft",
		"icon": "insect",
		"description": "Открывает сбор насекомых как наживки: кузнечик, жук, личинка, стрекоза и слепень.",
		"effect_type": "insect_gathering_unlock",
		"effect_value_per_rank": [1, 2, 3, 4, 5],
		"required_player_level": 5,
		"required_skills": {"craft_worm_gathering": 1},
		"ui_order": 2
	},
	"craft_plant_bait": {
		"title": "Заготовка растительной наживки",
		"tree_id": "fishing_craft",
		"icon": "plant",
		"description": "Открывает создание хлеба, теста, перловки, кукурузы и гороха.",
		"effect_type": "plant_bait_crafting_unlock",
		"effect_value_per_rank": [1, 2, 3, 4, 5],
		"required_player_level": 6,
		"required_skills": {"craft_worm_gathering": 1},
		"ui_order": 3
	},
	"craft_leader_making": {
		"title": "Создание поводков",
		"tree_id": "fishing_craft",
		"icon": "leader",
		"description": "Открывает создание поводков из материалов: от простых нейлоновых до стальных.",
		"effect_type": "leader_crafting_unlock",
		"effect_value_per_rank": [1, 2, 3, 4, 5],
		"required_player_level": 8,
		"required_skills": {"craft_plant_bait": 1},
		"ui_order": 4
	},
	"craft_groundbait": {
		"title": "Прикормка",
		"tree_id": "fishing_craft",
		"icon": "groundbait",
		"description": "Открывает создание прикормки разных уровней качества.",
		"effect_type": "groundbait_crafting_unlock",
		"effect_value_per_rank": [1, 2, 3, 4, 5],
		"required_player_level": 10,
		"required_skills": {"craft_plant_bait": 2},
		"ui_order": 5
	},
	"craft_tackle_repair": {
		"title": "Ремонт снастей",
		"tree_id": "fishing_craft",
		"icon": "repair",
		"description": "Позволяет частично ремонтировать снасти самостоятельно, если есть нужные инструменты.",
		"effect_type": "tackle_repair_unlock",
		"effect_value_per_rank": [1, 2, 3, 4, 5],
		"required_player_level": 12,
		"required_skills": {"craft_leader_making": 2},
		"ui_order": 6
	},
	"craft_master": {
		"title": "Мастер рыболовного ремесла",
		"tree_id": "fishing_craft",
		"icon": "master",
		"description": "Финальный навык ремесла: больше материалов, меньше расход и редкие рецепты.",
		"max_rank": 1,
		"rank_costs": [5],
		"effect_type": "craft_master_bonus",
		"effect_value_per_rank": [1.0],
		"effects": {
			"craft_master_bonus": [1.0],
			"material_yield_bonus": [0.20],
			"craft_material_cost_reduction": [0.20],
			"rare_crafting_recipes_unlock": [1.0]
		},
		"required_player_level": 35,
		"required_points_in_tree": 55,
		"required_skills": {"craft_groundbait": 4, "craft_tackle_repair": 4},
		"is_final_skill": true,
		"ui_order": 99
	},

	"cooking_simple": {
		"title": "Простая готовка",
		"tree_id": "cooking",
		"icon": "pot",
		"description": "Открывает приготовление простой еды.",
		"effect_type": "simple_cooking_unlock",
		"effect_value_per_rank": [1, 2, 3, 4, 5],
		"ui_order": 1
	},
	"cooking_fish_dishes": {
		"title": "Рыбные блюда",
		"tree_id": "cooking",
		"icon": "fish",
		"description": "Позволяет готовить блюда из пойманной рыбы.",
		"effect_type": "fish_cooking_unlock",
		"effect_value_per_rank": [1, 2, 3, 4, 5],
		"required_player_level": 4,
		"required_skills": {"cooking_simple": 1},
		"ui_order": 2
	},
	"cooking_smoking": {
		"title": "Копчение",
		"tree_id": "cooking",
		"icon": "smoke",
		"description": "Позволяет коптить рыбу, чтобы она дольше хранилась.",
		"effect_type": "smoking_unlock",
		"effect_value_per_rank": [1, 2, 3, 4, 5],
		"required_player_level": 7,
		"required_skills": {"cooking_fish_dishes": 1},
		"ui_order": 3
	},
	"cooking_preservation": {
		"title": "Консервация",
		"tree_id": "cooking",
		"icon": "jar",
		"description": "Позволяет консервировать еду и рыбу для более долгого хранения.",
		"effect_type": "preservation_unlock",
		"effect_value_per_rank": [1, 2, 3, 4, 5],
		"required_player_level": 9,
		"required_skills": {"cooking_smoking": 1},
		"ui_order": 4
	},
	"cooking_buff_food": {
		"title": "Пища с бонусом",
		"tree_id": "cooking",
		"icon": "buff",
		"description": "Открывает блюда с временными бонусами к энергии, концентрации, холоду или подсечке.",
		"effect_type": "buff_food_unlock",
		"effect_value_per_rank": [1, 2, 3, 4, 5],
		"required_player_level": 12,
		"required_skills": {"cooking_preservation": 2},
		"ui_order": 5
	},
	"cooking_master": {
		"title": "Полевой повар",
		"tree_id": "cooking",
		"icon": "master",
		"description": "Финальный навык кулинарии: еда действует дольше и открывает редкие рецепты.",
		"max_rank": 1,
		"rank_costs": [5],
		"effect_type": "cooking_master_bonus",
		"effect_value_per_rank": [1.0],
		"effects": {
			"cooking_master_bonus": [1.0],
			"food_duration_bonus": [0.20],
			"food_satiety_bonus": [0.20],
			"rare_buff_recipes_unlock": [1.0]
		},
		"required_player_level": 32,
		"required_points_in_tree": 45,
		"required_skills": {"cooking_buff_food": 4, "cooking_smoking": 3},
		"is_final_skill": true,
		"ui_order": 99
	},

	"survival_cold_resistance": {
		"title": "Защита от холода",
		"tree_id": "survival",
		"icon": "cold",
		"description": "Игрок медленнее замерзает на зимних водоёмах.",
		"effect_type": "cold_resistance",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"ui_order": 1
	},
	"survival_heat_resistance": {
		"title": "Защита от жары",
		"tree_id": "survival",
		"icon": "heat",
		"description": "Игрок медленнее теряет энергию и воду на жарких водоёмах.",
		"effect_type": "heat_resistance",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 4,
		"required_skills": {"survival_cold_resistance": 1},
		"ui_order": 2
	},
	"survival_energy_saving": {
		"title": "Экономия энергии",
		"tree_id": "survival",
		"icon": "energy",
		"description": "Снижает расход энергии при ловле, передвижении и добыче наживки.",
		"effect_type": "energy_consumption_reduction",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 6,
		"required_skills": {"survival_cold_resistance": 1},
		"ui_order": 3
	},
	"survival_night_fishing": {
		"title": "Ночная рыбалка",
		"tree_id": "survival",
		"icon": "night",
		"description": "Снижает штрафы ночью: усталость, видимость поклёвки и ошибки при вываживании.",
		"effect_type": "night_fishing_penalty_reduction",
		"effect_value_per_rank": [0.03, 0.06, 0.09, 0.12, 0.15],
		"required_player_level": 8,
		"required_skills": {"survival_energy_saving": 1},
		"ui_order": 4
	},
	"survival_campfire": {
		"title": "Костёр и лагерь",
		"tree_id": "survival",
		"icon": "camp",
		"description": "Открывает временный лагерь или костёр на некоторых водоёмах.",
		"effect_type": "campfire_unlock",
		"effect_value_per_rank": [1, 2, 3, 4, 5],
		"required_player_level": 10,
		"required_skills": {"survival_night_fishing": 1},
		"ui_order": 5
	},
	"survival_master": {
		"title": "Опытный выживальщик",
		"tree_id": "survival",
		"icon": "master",
		"description": "Финальный навык выживания: меньше расход энергии, меньше влияние погоды и улучшенный лагерь.",
		"max_rank": 1,
		"rank_costs": [5],
		"effect_type": "survival_master_bonus",
		"effect_value_per_rank": [1.0],
		"effects": {
			"survival_master_bonus": [1.0],
			"energy_consumption_reduction": [0.15],
			"weather_resistance": [0.15],
			"advanced_camp_unlock": [1.0]
		},
		"required_player_level": 32,
		"required_points_in_tree": 45,
		"required_skills": {"survival_campfire": 3, "survival_energy_saving": 4},
		"is_final_skill": true,
		"ui_order": 99
	}
}

func get_tree_ids() -> Array:
	return TREE_ORDER.duplicate()

func get_branch_ids() -> Array:
	return get_tree_ids()

func get_skill_tree(tree_id: String) -> Dictionary:
	if not TREES.has(tree_id):
		return {}
	var tree: Dictionary = TREES[tree_id].duplicate(true)
	tree["progress"] = get_tree_progress(tree_id)
	return tree

func get_branch(branch_id: String) -> Dictionary:
	return get_skill_tree(branch_id)

func get_branch_title(branch_id: String) -> String:
	return str(TREES.get(branch_id, {}).get("title", branch_id))

func get_skill(skill_id: String) -> Dictionary:
	if not SKILLS.has(skill_id):
		return {}
	return _with_skill_defaults(skill_id, SKILLS[skill_id])

func get_skill_data(skill_id: String) -> Dictionary:
	return get_skill(skill_id)

func has_skill(skill_id: String) -> bool:
	return SKILLS.has(skill_id)

func get_tree_skill_ids(tree_id: String) -> Array:
	var result: Array = []
	for skill_id in SKILLS.keys():
		var skill: Dictionary = SKILLS[skill_id]
		if str(skill.get("tree_id", "")) == tree_id:
			result.append(str(skill_id))
	result.sort_custom(func(a, b): return int(SKILLS[a].get("ui_order", 0)) < int(SKILLS[b].get("ui_order", 0)))
	return result

func get_branch_skill_ids(branch_id: String) -> Array:
	return get_tree_skill_ids(branch_id)

func get_tree_skills(tree_id: String) -> Array:
	var result: Array = []
	for skill_id in get_tree_skill_ids(tree_id):
		result.append(get_skill(str(skill_id)))
	return result

func get_branch_skills(branch_id: String) -> Array:
	return get_tree_skills(branch_id)

func get_all_skills() -> Dictionary:
	var result: Dictionary = {}
	for skill_id in SKILLS.keys():
		result[skill_id] = get_skill(str(skill_id))
	return result

func get_skill_points() -> int:
	return int(PlayerData.skill_points) if _has_player_data() else 0

func get_skill_rank(skill_id: String) -> int:
	return PlayerData.get_skill_rank(skill_id) if _has_player_data() and PlayerData.has_method("get_skill_rank") else 0

func get_max_rank(skill_id: String) -> int:
	var skill := get_skill(skill_id)
	return int(skill.get("max_rank", 0))

func get_next_rank_cost(skill_id: String) -> int:
	var skill := get_skill(skill_id)
	var rank := get_skill_rank(skill_id)
	var costs: Array = skill.get("rank_costs", DEFAULT_RANK_COSTS)
	if rank >= int(skill.get("max_rank", costs.size())):
		return 0
	if rank < 0 or rank >= costs.size():
		return 0
	return int(costs[rank])

func is_skill_unlocked(skill_id: String) -> bool:
	return bool(can_upgrade_skill(skill_id).get("unlocked", false))

func can_upgrade_skill(skill_id: String) -> Dictionary:
	var skill := get_skill(skill_id)
	if skill.is_empty():
		return {"can_upgrade": false, "unlocked": false, "reason": "Навык не найден."}

	var rank := get_skill_rank(skill_id)
	var max_rank := int(skill.get("max_rank", 5))
	if rank >= max_rank:
		return {"can_upgrade": false, "unlocked": true, "reason": "Навык уже улучшен до максимума."}

	var required_level := int(skill.get("required_player_level", 1))
	if _has_player_data() and int(PlayerData.level) < required_level:
		return {"can_upgrade": false, "unlocked": false, "reason": "Требуется уровень %d." % required_level}

	var tree_id := str(skill.get("tree_id", ""))
	var required_points := int(skill.get("required_points_in_tree", 0))
	if required_points > 0 and int(get_tree_progress(tree_id).get("spent_points", 0)) < required_points:
		return {"can_upgrade": false, "unlocked": false, "reason": "Вложите %d очков в эту ветку." % required_points}

	var requirements = skill.get("required_skills", {})
	if requirements is Dictionary:
		for required_id in (requirements as Dictionary).keys():
			var required_rank := int((requirements as Dictionary)[required_id])
			if get_skill_rank(str(required_id)) < required_rank:
				var required_skill := get_skill(str(required_id))
				return {
					"can_upgrade": false,
					"unlocked": false,
					"reason": "Нужен навык «%s» %d/%d." % [str(required_skill.get("title", required_id)), required_rank, int(required_skill.get("max_rank", 5))]
				}
	elif requirements is Array:
		for required_id in requirements:
			if get_skill_rank(str(required_id)) <= 0:
				var required_skill := get_skill(str(required_id))
				return {"can_upgrade": false, "unlocked": false, "reason": "Нужен навык «%s»." % str(required_skill.get("title", required_id))}

	var cost := get_next_rank_cost(skill_id)
	if get_skill_points() < cost:
		return {"can_upgrade": false, "unlocked": true, "reason": "Недостаточно очков навыков.", "cost": cost}

	return {"can_upgrade": true, "unlocked": true, "reason": "", "cost": cost}

func upgrade_skill(skill_id: String) -> Dictionary:
	if not _has_player_data() or not PlayerData.has_method("upgrade_skill"):
		return {"success": false, "reason": "Данные игрока недоступны."}
	return PlayerData.upgrade_skill(skill_id)

func get_effect_value(effect_type: String) -> float:
	return PlayerData.get_skill_effect_value(effect_type) if _has_player_data() else 0.0

func get_tree_progress(tree_id: String) -> Dictionary:
	var ranks := 0
	var max_ranks := 0
	var spent := 0
	var max_points := 0

	for skill_id in get_tree_skill_ids(tree_id):
		var skill := get_skill(str(skill_id))
		var max_rank := int(skill.get("max_rank", 5))
		var rank := get_skill_rank(str(skill_id))
		ranks += rank
		max_ranks += max_rank
		spent += get_spent_points_for_rank(str(skill_id), rank)
		max_points += get_spent_points_for_rank(str(skill_id), max_rank)

	return {
		"tree_id": tree_id,
		"rank_points": ranks,
		"max_rank_points": max_ranks,
		"spent_points": spent,
		"max_points": max_points
	}

func get_spent_points_for_rank(skill_id: String, rank: int) -> int:
	var skill := get_skill(skill_id)
	var costs: Array = skill.get("rank_costs", DEFAULT_RANK_COSTS)
	var total := 0
	var capped_rank: int = clampi(rank, 0, min(int(skill.get("max_rank", costs.size())), costs.size()))
	for i in capped_rank:
		total += int(costs[i])
	return total

func get_skill_effects_for_rank(skill_id: String, rank: int) -> Dictionary:
	var skill: Dictionary = get_skill(skill_id)
	var result: Dictionary = {}
	if skill.is_empty() or rank <= 0:
		return result

	var effects = skill.get("effects", {})
	if effects is Dictionary:
		for effect_id in (effects as Dictionary).keys():
			result[str(effect_id)] = _get_ranked_effect_value((effects as Dictionary)[effect_id], rank)
		return result

	var effect_type := str(skill.get("effect_type", ""))
	if effect_type == "":
		return result
	result[effect_type] = _get_ranked_effect_value(skill.get("effect_value_per_rank", []), rank)
	return result

func _get_ranked_effect_value(value, rank: int) -> float:
	if value is Array:
		var values: Array = value
		if values.is_empty():
			return 0.0
		var index: int = clampi(rank - 1, 0, values.size() - 1)
		return float(values[index])
	return float(value) * float(rank)

func _with_skill_defaults(skill_id: String, raw_skill: Dictionary) -> Dictionary:
	var skill: Dictionary = raw_skill.duplicate(true)
	skill["id"] = skill_id
	skill["title"] = str(skill.get("title", skill_id))
	skill["name"] = str(skill.get("title", skill_id))
	skill["tree_id"] = str(skill.get("tree_id", skill.get("branch", "")))
	skill["branch"] = str(skill["tree_id"])
	skill["icon"] = str(skill.get("icon", "skill"))
	skill["description"] = str(skill.get("description", ""))
	skill["max_rank"] = int(skill.get("max_rank", 5))
	if not skill.has("rank_costs"):
		skill["rank_costs"] = DEFAULT_RANK_COSTS.slice(0, int(skill["max_rank"]))
	skill["required_player_level"] = int(skill.get("required_player_level", 1))
	if not skill.has("required_skills"):
		skill["required_skills"] = {}
	skill["required_points_in_tree"] = int(skill.get("required_points_in_tree", 0))
	skill["effect_type"] = str(skill.get("effect_type", ""))
	if not skill.has("effect_value_per_rank"):
		skill["effect_value_per_rank"] = []
	skill["is_final_skill"] = bool(skill.get("is_final_skill", false))
	skill["ui_order"] = int(skill.get("ui_order", 0))
	var current_rank := get_skill_rank(skill_id)
	var costs: Array = skill["rank_costs"]
	skill["current_rank"] = current_rank
	skill["is_unlocked"] = _is_skill_unlocked_from_data(skill_id, skill) if _has_player_data() else false
	skill["cost"] = int(costs[current_rank]) if current_rank >= 0 and current_rank < costs.size() and current_rank < int(skill["max_rank"]) else 0
	skill["requires"] = skill["required_skills"]
	return skill

func _is_skill_unlocked_from_data(_skill_id: String, skill: Dictionary) -> bool:
	if not _has_player_data():
		return false
	if int(PlayerData.level) < int(skill.get("required_player_level", 1)):
		return false
	var tree_id := str(skill.get("tree_id", ""))
	if int(skill.get("required_points_in_tree", 0)) > 0 and _get_tree_spent_points_raw(tree_id) < int(skill.get("required_points_in_tree", 0)):
		return false
	var requirements = skill.get("required_skills", {})
	if requirements is Dictionary:
		for required_id in (requirements as Dictionary).keys():
			if get_skill_rank(str(required_id)) < int((requirements as Dictionary)[required_id]):
				return false
	elif requirements is Array:
		for required_id in requirements:
			if get_skill_rank(str(required_id)) <= 0:
				return false
	return true

func _get_tree_spent_points_raw(tree_id: String) -> int:
	var spent := 0
	for raw_skill_id in SKILLS.keys():
		var raw_skill: Dictionary = SKILLS[raw_skill_id]
		if str(raw_skill.get("tree_id", "")) != tree_id:
			continue
		var rank := get_skill_rank(str(raw_skill_id))
		var max_rank := int(raw_skill.get("max_rank", 5))
		var costs: Array = raw_skill.get("rank_costs", DEFAULT_RANK_COSTS)
		var capped_rank: int = clampi(rank, 0, min(max_rank, costs.size()))
		for i in capped_rank:
			spent += int(costs[i])
	return spent

func _has_player_data() -> bool:
	return get_node_or_null("/root/PlayerData") != null
