extends Node

const MAX_BETA_LEVEL := 30

const AGAMIM_SPOT_UNLOCK_LEVELS := {
	"old_oak_pier": 1,
	"quiet_water_pier": 2,
	"reeds_pier": 3,
	"green_duckweed": 4,
	"morning_pier": 5,
	"old_boat_pier": 6,
	"frog_backwater": 7,
	"mist_pier": 8,
	"deep_pier": 9,
	"cold_water": 10,
	"dark_hole": 11
}

const FEATURE_UNLOCK_LEVELS := {
	"level_rewards": 2,
	"skill_tree": 2,
	"contracts_easy": 3,
	"contracts_medium": 7,
	"spinning": 8,
	"contracts_hard": 12,
	"advanced_spinning": 14
}

const CONTRACT_UNLOCK_LEVELS := {
	"easy": 3,
	"medium": 7,
	"hard": 12
}

const ITEM_REQUIRED_LEVELS := {
	"simple_pole_rod_4m": 1,
	"green_line_xs_light": 1,
	"riverstart_basic_hook_18": 1,
	"riverstart_basic_hook_16": 1,
	"small_hook_12": 5,
	"float_feather_basic": 4,
	"nylon_leader_15cm_1kg": 6,
	"bread": 7,
	"river_spin_210": 8,
	"river_reel_1000": 8,
	"silver_spinner_5g": 8,
	"motil": 9,
	"lakeline_nylon_basic_2kg": 10,
	"shore_pole_rod_5m": 11,
	"lake_spin_240": 12,
	"fluoro_leader_40cm_5kg": 12,
	"braided_leader_30cm_8kg": 13,
	"carp_cast_360": 14,
	"reinforced_leader_40cm_12kg": 14,
	"steel_leader_40cm_20kg": 15
}

const REEL_REQUIRED_LEVELS := {
	"fishpoint_start_2000": 8,
	"fishpoint_start_3000": 10,
	"nordlake_basic_2000": 9,
	"nordlake_basic_3000": 12,
	"aerospin_swift_1000": 8,
	"aerospin_swift_2000": 10,
	"aerospin_swift_3000": 14,
	"riverfox_blade_1000": 11,
	"riverfox_blade_2000": 13,
	"riverfox_blade_3000": 17,
	"silvercast_prospin_1000": 15,
	"silvercast_prospin_2000": 18,
	"silvercast_prospin_3000": 22,
	"lakemaster_balance_1000": 10,
	"lakemaster_balance_2000": 12,
	"lakemaster_balance_3000": 15,
	"lakemaster_balance_4000": 18,
	"lakemaster_balance_5000": 22,
	"lakemaster_balance_6000": 26,
	"fjordline_universal_1000": 12,
	"fjordline_universal_2000": 14,
	"fjordline_universal_3000": 17,
	"fjordline_universal_4000": 20,
	"fjordline_universal_5000": 24,
	"fjordline_universal_6000": 28,
	"blackriver_control_1000": 14,
	"blackriver_control_2000": 16,
	"blackriver_control_3000": 19,
	"blackriver_control_4000": 22,
	"blackriver_control_5000": 25,
	"blackriver_control_6000": 28,
	"goldenfish_allround_1000": 16,
	"goldenfish_allround_2000": 18,
	"goldenfish_allround_3000": 21,
	"goldenfish_allround_4000": 24,
	"goldenfish_allround_5000": 27,
	"goldenfish_allround_6000": 29,
	"clearwater_flex_1000": 11,
	"clearwater_flex_2000": 13,
	"clearwater_flex_3000": 16,
	"clearwater_flex_4000": 19,
	"clearwater_flex_5000": 23,
	"clearwater_flex_6000": 27,
	"reedline_picker_1000": 12,
	"reedline_picker_2000": 14,
	"reedline_picker_3000": 17,
	"reedline_picker_4000": 20,
	"reedline_picker_5000": 24,
	"reedline_picker_6000": 28,
	"stormway_match_1000": 13,
	"stormway_match_2000": 15,
	"stormway_match_3000": 18,
	"stormway_match_4000": 21,
	"stormway_match_5000": 25,
	"stormway_match_6000": 29,
	"bluepeak_river_1000": 14,
	"bluepeak_river_2000": 16,
	"bluepeak_river_3000": 19,
	"bluepeak_river_4000": 22,
	"bluepeak_river_5000": 26,
	"bluepeak_river_6000": 29,
	"wildcarp_lite_1000": 16,
	"wildcarp_lite_2000": 18,
	"wildcarp_lite_3000": 21,
	"wildcarp_lite_4000": 24,
	"wildcarp_lite_5000": 27,
	"wildcarp_lite_6000": 29,
	"irondrag_titan_8000": 29,
	"oceanbull_force_8000": 30
}

const LEVEL_REWARDS := {
	2: {
		"silver": 25,
		"items": [{"id": "worm", "quantity": 10}],
		"skill_points": 1,
		"unlocks": ["Получено первое очко навыка", "Открылось дерево навыков", "Мостик \"Тихая Вода\""],
		"unlock_message": "Открылось дерево навыков",
		"redirect_to": "skill_tree",
		"cta": "Открыть навыки"
	},
	3: {
		"silver": 35,
		"items": [{"id": "dough", "quantity": 8}],
		"unlocks": ["Открылись лёгкие контракты", "Мостик \"Камышовый\""],
		"unlock_message": "Открылись лёгкие контракты"
	},
	4: {
		"silver": 45,
		"items": [{"id": "float_feather_basic", "quantity": 1}],
		"unlocks": ["Зелёная Ряска", "Лёгкие удочки"]
	},
	5: {
		"silver": 55,
		"items": [{"id": "small_hook_12", "quantity": 5}],
		"unlocks": ["Мостик \"Утренний\"", "Крючки №12 и №10"]
	},
	6: {
		"silver": 70,
		"items": [{"id": "nylon_leader_15cm_1kg", "quantity": 3}],
		"unlocks": ["Мостик \"Старая Лодка\"", "Первые medium-удочки"]
	},
	7: {
		"silver": 90,
		"items": [{"id": "bread", "quantity": 10}],
		"unlocks": ["Лягушачья Заводь", "Средние контракты: 1 слот", "Крючки №8"]
	},
	8: {
		"silver": 120,
		"items": [
			{"id": "river_spin_210", "quantity": 1, "grant_if_missing": true},
			{"id": "river_reel_1000", "quantity": 1, "grant_if_missing": true},
			{"id": "silver_spinner_5g", "quantity": 1, "grant_if_missing": true}
		],
		"unlocks": ["Открылся спиннинг", "Мостик \"Туман\"", "Средние контракты: 2 слота"],
		"unlock_message": "Открылся спиннинг",
		"redirect_to": "spinning_tutorial",
		"cta": "Обучение спиннингу"
	},
	9: {
		"silver": 135,
		"items": [{"id": "motil", "quantity": 8}],
		"unlocks": ["Мостик \"Глубокий\"", "Усиленные medium-удочки"]
	},
	10: {
		"silver": 150,
		"items": [{"id": "lakeline_nylon_basic_2kg", "quantity": 1}],
		"unlocks": ["Холодная Вода", "Средние контракты: 3 слота", "Крючки №6"]
	},
	11: {
		"silver": 170,
		"items": [{"id": "shore_pole_rod_5m", "quantity": 1, "grant_if_missing": true}],
		"unlocks": ["Тёмная Яма", "Все точки Озера Агамим", "Тяжёлые удочки"]
	},
	12: {
		"silver": 190,
		"items": [{"id": "fluoro_leader_40cm_5kg", "quantity": 2}],
		"unlocks": ["Сложные контракты: 1 слот", "Продвинутые блёсны"]
	},
	13: {
		"silver": 220,
		"items": [{"id": "braided_leader_30cm_8kg", "quantity": 2}],
		"unlocks": ["Крючки №4"]
	},
	14: {
		"silver": 260,
		"items": [{"id": "reinforced_leader_40cm_12kg", "quantity": 1}],
		"unlocks": ["Продвинутый спиннинг", "Сложные контракты: 2 слота", "Тяжёлые блёсны"]
	},
	15: {
		"silver": 320,
		"items": [{"id": "steel_leader_40cm_20kg", "quantity": 1}],
		"unlocks": ["Полный набор beta-контрактов", "Крючки №2", "Топовые beta-снасти"]
	}
}


func get_max_beta_level() -> int:
	return MAX_BETA_LEVEL


func get_spot_unlock_level(spot_id: String) -> int:
	return clampi(int(AGAMIM_SPOT_UNLOCK_LEVELS.get(spot_id, 1)), 1, MAX_BETA_LEVEL)


func has_spot_progression(spot_id: String) -> bool:
	return AGAMIM_SPOT_UNLOCK_LEVELS.has(spot_id)


func is_spot_unlocked_for_level(spot_id: String, player_level: int) -> bool:
	return int(player_level) >= get_spot_unlock_level(spot_id)


func get_feature_unlock_level(feature_id: String) -> int:
	return clampi(int(FEATURE_UNLOCK_LEVELS.get(feature_id, 1)), 1, MAX_BETA_LEVEL)


func is_feature_unlocked(feature_id: String, player_level: int) -> bool:
	return int(player_level) >= get_feature_unlock_level(feature_id)


func get_level_reward(reward_level: int) -> Dictionary:
	if not LEVEL_REWARDS.has(reward_level):
		return {}
	return (LEVEL_REWARDS[reward_level] as Dictionary).duplicate(true)


func get_contract_slots_for_level(player_level: int) -> Dictionary:
	var level: int = maxi(int(player_level), 1)
	if level < 3:
		return {"easy": 0, "medium": 0, "hard": 0}
	if level == 3:
		return {"easy": 1, "medium": 0, "hard": 0}
	if level == 4:
		return {"easy": 2, "medium": 0, "hard": 0}
	if level <= 6:
		return {"easy": 3, "medium": 0, "hard": 0}
	if level == 7:
		return {"easy": 3, "medium": 1, "hard": 0}
	if level <= 9:
		return {"easy": 3, "medium": 2, "hard": 0}
	if level <= 11:
		return {"easy": 3, "medium": 3, "hard": 0}
	if level <= 13:
		return {"easy": 3, "medium": 3, "hard": 1}
	if level == 14:
		return {"easy": 3, "medium": 3, "hard": 2}
	return {"easy": 3, "medium": 3, "hard": 3}


func get_item_required_level(item_id: String, item_data: Dictionary = {}) -> int:
	var required_level := 1
	if item_data.has("level_required"):
		required_level = max(required_level, int(item_data.get("level_required", 1)))
	if item_data.has("required_level"):
		required_level = max(required_level, int(item_data.get("required_level", 1)))
	if ITEM_REQUIRED_LEVELS.has(item_id):
		required_level = max(required_level, int(ITEM_REQUIRED_LEVELS[item_id]))
	if REEL_REQUIRED_LEVELS.has(item_id):
		required_level = max(required_level, int(REEL_REQUIRED_LEVELS[item_id]))

	var category := str(item_data.get("category", item_data.get("type", ""))).strip_edges().to_lower()
	var stats := _get_item_stats(item_data)
	match category:
		"rod":
			required_level = max(required_level, _get_rod_required_level(item_data, stats))
		"reel":
			required_level = max(required_level, _get_reel_required_level(stats))
		"lure", "spoon", "wobbler", "spinner_bait":
			required_level = max(required_level, _get_lure_required_level(item_id, stats))
		"hook":
			required_level = max(required_level, _get_hook_required_level(stats))
		"float":
			required_level = max(required_level, _get_float_required_level(item_id, stats, item_data))
		"line", "leader":
			required_level = max(required_level, _get_load_based_required_level(stats))
		"bait":
			required_level = max(required_level, _get_bait_required_level(item_id))
		_:
			required_level = max(required_level, int(item_data.get("required_level", 1)))

	return maxi(required_level, 1)


func get_survival_multiplier_for_level(player_level: int) -> Dictionary:
	var level: int = maxi(int(player_level), 1)
	if level <= 3:
		return {
			"hunger_loss_multiplier": 0.35,
			"temperature_impact_multiplier": 0.45,
			"condition_penalty_multiplier": 0.50
		}
	if level <= 6:
		return {
			"hunger_loss_multiplier": 0.55,
			"temperature_impact_multiplier": 0.65,
			"condition_penalty_multiplier": 0.70
		}
	if level <= 9:
		return {
			"hunger_loss_multiplier": 0.75,
			"temperature_impact_multiplier": 0.85,
			"condition_penalty_multiplier": 0.85
		}
	return {
		"hunger_loss_multiplier": 1.0,
		"temperature_impact_multiplier": 1.0,
		"condition_penalty_multiplier": 1.0
	}


func get_locked_spot_text(spot_id: String) -> String:
	return "Откроется на LVL %d" % get_spot_unlock_level(spot_id)


func get_contract_lock_text(difficulty: String = "easy") -> String:
	match difficulty:
		"medium":
			return "Средние контракты откроются на LVL %d" % int(CONTRACT_UNLOCK_LEVELS["medium"])
		"hard":
			return "Сложные контракты откроются на LVL %d" % int(CONTRACT_UNLOCK_LEVELS["hard"])
		_:
			return "Контракты откроются на LVL %d" % int(CONTRACT_UNLOCK_LEVELS["easy"])


func get_item_lock_text(item_id: String, item_data: Dictionary = {}) -> String:
	if _is_spinning_item(item_data):
		return "Спиннинг откроется на LVL %d" % get_feature_unlock_level("spinning")
	return "Доступно с LVL %d" % get_item_required_level(item_id, item_data)


func _get_item_stats(item_data: Dictionary) -> Dictionary:
	var raw_stats = item_data.get("stats", {})
	if raw_stats is Dictionary:
		return (raw_stats as Dictionary)
	return {}


func _is_spinning_item(item_data: Dictionary) -> bool:
	var category := str(item_data.get("category", item_data.get("type", ""))).strip_edges().to_lower()
	if ["reel", "lure", "spoon", "wobbler", "spinner_bait"].has(category):
		return true
	var stats := _get_item_stats(item_data)
	var rod_type := str(stats.get("rod_type", item_data.get("rod_type", item_data.get("tackle_type", "")))).strip_edges().to_lower()
	var tackle_type := str(stats.get("tackle_type", item_data.get("tackle_type", rod_type))).strip_edges().to_lower()
	if rod_type == "spinning" or tackle_type == "spinning":
		return true
	return bool(stats.get("requires_reel", item_data.get("requires_reel", false)))


func _get_rod_required_level(item_data: Dictionary, stats: Dictionary) -> int:
	if _is_spinning_item(item_data):
		var rod_class := str(stats.get("rod_class", "light")).strip_edges().to_lower()
		if rod_class == "medium":
			return 12
		if rod_class == "heavy" or rod_class == "extra_heavy":
			return 14
		return 8

	var rod_class := str(stats.get("rod_class", "light")).strip_edges().to_lower()
	var max_fish_weight := float(stats.get("max_fish_weight", 1.0))
	match rod_class:
		"ultra_light":
			return 1
		"light":
			return 4 if max_fish_weight > 2.0 else 1
		"medium":
			return 9 if max_fish_weight >= 4.5 else 6
		"universal":
			return 14 if max_fish_weight >= 7.0 else 9
		"heavy":
			return 15 if max_fish_weight >= 8.0 else 11
		"extra_heavy":
			return 15
	return 1


func _get_reel_required_level(stats: Dictionary) -> int:
	var reel_size := int(stats.get("reel_size", stats.get("size", 1000)))
	if reel_size >= 8000:
		return 29
	if reel_size >= 6000:
		return 26
	if reel_size >= 5000:
		return 22
	if reel_size >= 4000:
		return 18
	if reel_size >= 3000:
		return 14
	if reel_size >= 2000:
		return 10
	return 8


func _get_lure_required_level(item_id: String, stats: Dictionary) -> int:
	if item_id == "small_spinner_3g" or item_id == "silver_spinner_5g":
		return 8
	var lure_type := str(stats.get("lure_type", "")).strip_edges().to_lower()
	var lure_weight := float(stats.get("weight", stats.get("weight_g", 5.0)))
	if lure_type == "wobbler" or lure_type == "spinner_bait":
		return 14 if lure_weight < 16.0 else 15
	if lure_weight >= 14.0:
		return 14
	if lure_weight >= 10.0:
		return 12
	if lure_weight >= 7.0:
		return 10
	return 8


func _get_hook_required_level(stats: Dictionary) -> int:
	var hook_size := int(stats.get("hook_size", 18))
	if hook_size >= 16:
		return 1
	if hook_size == 14:
		return 3
	if hook_size == 12 or hook_size == 10:
		return 5
	if hook_size == 8:
		return 7
	if hook_size == 6:
		return 10
	if hook_size == 4:
		return 13
	if hook_size == 2:
		return 15
	if hook_size <= 1:
		return 15
	return 1


func _get_float_required_level(item_id: String, stats: Dictionary, item_data: Dictionary) -> int:
	var rarity := str(item_data.get("rarity", "common")).strip_edges().to_lower()
	var price := float(item_data.get("price", 0.0))
	var float_type := str(stats.get("float_type", stats.get("base_type", ""))).strip_edges().to_lower()
	if item_id == "float_drop_basic":
		return 1
	if item_id == "float_feather_basic":
		return 4
	if float_type == "waggler" or float_type == "sliding":
		return 5
	if float_type == "glow_feather" or float_type == "barrel" or rarity == "uncommon":
		return 3
	if rarity == "rare" or price >= 30.0:
		return 5
	return 1


func _get_load_based_required_level(stats: Dictionary) -> int:
	var max_load := float(stats.get("max_load_kg", stats.get("max_load", stats.get("strength", 1.0))))
	if max_load >= 18.0:
		return 15
	if max_load >= 12.0:
		return 12
	if max_load >= 8.0:
		return 9
	if max_load >= 5.0:
		return 6
	if max_load >= 3.0:
		return 4
	if max_load >= 2.0:
		return 3
	return 1


func _get_bait_required_level(item_id: String) -> int:
	if item_id.find("vipolzok") >= 0:
		return 12
	if item_id.find("astrah") >= 0 or item_id.find("volhov") >= 0 or item_id.find("leningrad") >= 0:
		return 9
	if item_id.find("testo") >= 0 or item_id == "dough":
		return 3
	if item_id == "motil":
		return 6
	return 1
