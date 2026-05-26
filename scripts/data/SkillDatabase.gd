extends Node

const BRANCH_ORDER := [
	"water_sense",
	"reeling",
	"tackle",
	"economy"
]

const BRANCH_NAMES := {
	"water_sense": "Чувство воды",
	"reeling": "Вываживание",
	"tackle": "Снасти",
	"economy": "Торговля и опыт"
}

const BRANCH_SKILLS := {
	"water_sense": [
		"float_sense_1",
		"float_sense_2",
		"depth_reader",
		"quiet_water"
	],
	"reeling": [
		"soft_hand_1",
		"soft_hand_2",
		"jerk_control",
		"steady_pressure"
	],
	"tackle": [
		"basic_knot_1",
		"basic_knot_2",
		"careful_hookset",
		"bait_sandwich",
		"line_reserve"
	],
	"economy": [
		"good_deal_1",
		"good_deal_2",
		"experienced_eye",
		"trophy_habit"
	]
}

const SKILLS := {
	"float_sense_1": {
		"id": "float_sense_1",
		"name": "Чуткий поплавок I",
		"branch": "water_sense",
		"description": "+5% к скорости обнаружения поклёвки.",
		"cost": 1,
		"requires": [],
		"effects": {
			"bite_detection_bonus": 0.05
		}
	},
	"float_sense_2": {
		"id": "float_sense_2",
		"name": "Чуткий поплавок II",
		"branch": "water_sense",
		"description": "+10% к скорости обнаружения поклёвки.",
		"cost": 1,
		"requires": ["float_sense_1"],
		"effects": {
			"bite_detection_bonus": 0.10
		}
	},
	"depth_reader": {
		"id": "depth_reader",
		"name": "Чтение глубины",
		"branch": "water_sense",
		"description": "+5% к шансу клёва, если глубина близка к нужной.",
		"cost": 1,
		"requires": ["float_sense_1"],
		"effects": {
			"depth_match_bonus": 0.05
		}
	},
	"quiet_water": {
		"id": "quiet_water",
		"name": "Тихая вода",
		"branch": "water_sense",
		"description": "-5% к шансу пустой поклёвки.",
		"cost": 1,
		"requires": ["depth_reader"],
		"effects": {
			"no_bite_reduction": 0.05
		}
	},
	"soft_hand_1": {
		"id": "soft_hand_1",
		"name": "Мягкая рука I",
		"branch": "reeling",
		"description": "Зелёная зона натяжения шире на 4%.",
		"cost": 1,
		"requires": [],
		"effects": {
			"green_zone_bonus": 0.04
		}
	},
	"soft_hand_2": {
		"id": "soft_hand_2",
		"name": "Мягкая рука II",
		"branch": "reeling",
		"description": "Зелёная зона натяжения шире на 8%.",
		"cost": 1,
		"requires": ["soft_hand_1"],
		"effects": {
			"green_zone_bonus": 0.08
		}
	},
	"jerk_control": {
		"id": "jerk_control",
		"name": "Контроль рывка",
		"branch": "reeling",
		"description": "Рывки рыбы слабее на 5%.",
		"cost": 1,
		"requires": ["soft_hand_1"],
		"effects": {
			"fish_jerk_reduction": 0.05
		}
	},
	"steady_pressure": {
		"id": "steady_pressure",
		"name": "Ровное давление",
		"branch": "reeling",
		"description": "-8% к риску схода при слабом натяжении.",
		"cost": 1,
		"requires": ["jerk_control"],
		"effects": {
			"escape_risk_reduction": 0.08
		}
	},
	"basic_knot_1": {
		"id": "basic_knot_1",
		"name": "Узел новичка I",
		"branch": "tackle",
		"description": "-5% к износу лески.",
		"cost": 1,
		"requires": [],
		"effects": {
			"line_wear_reduction": 0.05
		}
	},
	"basic_knot_2": {
		"id": "basic_knot_2",
		"name": "Узел новичка II",
		"branch": "tackle",
		"description": "-10% к износу лески.",
		"cost": 1,
		"requires": ["basic_knot_1"],
		"effects": {
			"line_wear_reduction": 0.10
		}
	},
	"careful_hookset": {
		"id": "careful_hookset",
		"name": "Аккуратная подсечка",
		"branch": "tackle",
		"description": "-5% к шансу схода с крючка.",
		"cost": 1,
		"requires": ["basic_knot_1"],
		"effects": {
			"hook_escape_reduction": 0.05
		}
	},
	"line_reserve": {
		"id": "line_reserve",
		"name": "Запас прочности",
		"branch": "tackle",
		"description": "+5% к эффективной прочности лески.",
		"cost": 1,
		"requires": ["careful_hookset"],
		"effects": {
			"line_strength_bonus": 0.05
		}
	},
	"bait_sandwich": {
		"id": "bait_sandwich",
		"name": "Бутерброд",
		"branch": "tackle",
		"description": "Позволяет использовать вторую наживку на крючке.",
		"cost": 1,
		"requires": ["careful_hookset"],
		"effects": {
			"second_bait_slot": 1.0
		}
	},
	"good_deal_1": {
		"id": "good_deal_1",
		"name": "Хороший торг I",
		"branch": "economy",
		"description": "+5% к цене продажи рыбы.",
		"cost": 1,
		"requires": [],
		"effects": {
			"sell_price_bonus": 0.05
		}
	},
	"good_deal_2": {
		"id": "good_deal_2",
		"name": "Хороший торг II",
		"branch": "economy",
		"description": "+10% к цене продажи рыбы.",
		"cost": 1,
		"requires": ["good_deal_1"],
		"effects": {
			"sell_price_bonus": 0.10
		}
	},
	"experienced_eye": {
		"id": "experienced_eye",
		"name": "Опытный взгляд",
		"branch": "economy",
		"description": "+5% к XP за рыбу.",
		"cost": 1,
		"requires": [],
		"effects": {
			"xp_bonus": 0.05
		}
	},
	"trophy_habit": {
		"id": "trophy_habit",
		"name": "Трофейная привычка",
		"branch": "economy",
		"description": "+10% XP за трофейные и раритетные экземпляры.",
		"cost": 1,
		"requires": ["experienced_eye"],
		"effects": {
			"trophy_xp_bonus": 0.10
		}
	}
}

func get_skill(skill_id: String) -> Dictionary:
	if not SKILLS.has(skill_id):
		return {}

	return SKILLS[skill_id].duplicate(true)

func has_skill(skill_id: String) -> bool:
	return SKILLS.has(skill_id)

func get_branch_ids() -> Array:
	return BRANCH_ORDER.duplicate()

func get_branch_title(branch_id: String) -> String:
	return str(BRANCH_NAMES.get(branch_id, branch_id))

func get_branch_skill_ids(branch_id: String) -> Array:
	return BRANCH_SKILLS.get(branch_id, []).duplicate()

func get_branch_skills(branch_id: String) -> Array:
	var result: Array = []
	for skill_id in get_branch_skill_ids(branch_id):
		var skill := get_skill(str(skill_id))
		if not skill.is_empty():
			result.append(skill)

	return result

func get_all_skills() -> Dictionary:
	return SKILLS.duplicate(true)
