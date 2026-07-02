extends RefCounted

const ROW_ID := 0
const ROW_NAME := 1
const ROW_SERIES := 2
const ROW_LEVEL := 3
const ROW_PRICE := 4
const ROW_LENGTH_CM := 5
const ROW_TEST_MIN_G := 6
const ROW_TEST_MAX_G := 7
const ROW_ROD_CLASS := 8
const ROW_ACTION := 9
const ROW_POWER_CLASS := 10
const ROW_WEIGHT_G := 11
const ROW_MAX_FISH_WEIGHT_KG := 12
const ROW_SENSITIVITY := 13
const ROW_CAST_DISTANCE := 14
const ROW_DURABILITY_POINTS := 15
const ROW_WEAR_PER_CAST := 16
const ROW_BONUS_TYPE := 17
const ROW_BONUS_VALUE := 18
const ROW_ICON_PATH := 19

const RAW_SPINNING_RODS := [
	["fishpoint_start_spin_210_ul", "FishPoint Start Spin 210 UL", "FishPoint Start Spin", 8, 320, 210, 1, 5, "ultra_light", "medium_fast", "light", 125, 2.0, 45, 45, 100, 1.00, "starter_control", 3, "res://assets/items/rods/spinning/fishpoint_start_spin.png"],
	["fishpoint_start_spin_220_l", "FishPoint Start Spin 220 L", "FishPoint Start Spin", 9, 430, 220, 3, 10, "light", "medium_fast", "light", 138, 3.0, 42, 50, 110, 0.98, "starter_control", 4, "res://assets/items/rods/spinning/fishpoint_start_spin.png"],
	["fishpoint_start_spin_240_ml", "FishPoint Start Spin 240 ML", "FishPoint Start Spin", 11, 620, 240, 5, 15, "medium_light", "medium_fast", "medium_light", 158, 4.2, 40, 55, 125, 0.96, "starter_power", 5, "res://assets/items/rods/spinning/fishpoint_start_spin.png"],
	["nordlake_basic_spin_210_ul", "NordLake Basic Spin 210 UL", "NordLake Basic Spin", 9, 450, 210, 1, 5, "ultra_light", "medium_fast", "light", 118, 2.2, 52, 48, 120, 0.94, "line_safety", 4, "res://assets/items/rods/spinning/nordlake_basic_spin.png"],
	["nordlake_basic_spin_230_l", "NordLake Basic Spin 230 L", "NordLake Basic Spin", 11, 610, 230, 3, 10, "light", "medium_fast", "light", 135, 3.5, 50, 54, 138, 0.92, "line_safety", 5, "res://assets/items/rods/spinning/nordlake_basic_spin.png"],
	["nordlake_basic_spin_250_ml", "NordLake Basic Spin 250 ML", "NordLake Basic Spin", 13, 820, 250, 5, 15, "medium_light", "medium_fast", "medium_light", 158, 4.8, 48, 60, 155, 0.90, "line_safety", 6, "res://assets/items/rods/spinning/nordlake_basic_spin.png"],
	["aerospin_swift_180_ul", "AeroSpin Swift 180 UL", "AeroSpin Swift", 8, 600, 180, 1, 5, "ultra_light", "fast", "light", 95, 1.8, 70, 48, 120, 0.90, "sensitivity", 7, "res://assets/items/rods/spinning/aerospin_swift.png"],
	["aerospin_swift_210_l", "AeroSpin Swift 210 L", "AeroSpin Swift", 10, 820, 210, 3, 10, "light", "fast", "light", 115, 2.8, 68, 55, 138, 0.88, "sensitivity", 8, "res://assets/items/rods/spinning/aerospin_swift.png"],
	["aerospin_swift_230_ml", "AeroSpin Swift 230 ML", "AeroSpin Swift", 14, 1150, 230, 5, 15, "medium_light", "fast", "medium_light", 135, 4.0, 65, 62, 160, 0.86, "cast_distance", 8, "res://assets/items/rods/spinning/aerospin_swift.png"],
	["riverfox_twitch_210_l", "RiverFox Twitch 210 L", "RiverFox Twitch", 11, 850, 210, 3, 10, "light", "extra_fast", "light", 128, 3.2, 62, 56, 150, 0.90, "twitch_control", 6, "res://assets/items/rods/spinning/riverfox_twitch.png"],
	["riverfox_twitch_220_ml", "RiverFox Twitch 220 ML", "RiverFox Twitch", 14, 1150, 220, 5, 15, "medium_light", "extra_fast", "medium_light", 145, 4.5, 65, 60, 170, 0.88, "twitch_control", 7, "res://assets/items/rods/spinning/riverfox_twitch.png"],
	["riverfox_twitch_240_m", "RiverFox Twitch 240 M", "RiverFox Twitch", 18, 1600, 240, 10, 25, "medium", "extra_fast", "medium", 178, 6.5, 63, 65, 195, 0.85, "active_lure_control", 8, "res://assets/items/rods/spinning/riverfox_twitch.png"],
	["silvercast_jigpro_220_ml", "SilverCast JigPro 220 ML", "SilverCast JigPro", 14, 1250, 220, 5, 15, "medium_light", "fast", "medium_light", 140, 4.8, 72, 60, 170, 0.86, "jig_sensitivity", 8, "res://assets/items/rods/spinning/silvercast_jigpro.png"],
	["silvercast_jigpro_240_m", "SilverCast JigPro 240 M", "SilverCast JigPro", 18, 1750, 240, 10, 25, "medium", "fast", "medium", 175, 7.0, 75, 66, 200, 0.82, "jig_sensitivity", 9, "res://assets/items/rods/spinning/silvercast_jigpro.png"],
	["silvercast_jigpro_260_h", "SilverCast JigPro 260 H", "SilverCast JigPro", 23, 2400, 260, 20, 45, "heavy", "fast", "heavy", 225, 10.5, 70, 72, 235, 0.78, "jig_power", 10, "res://assets/items/rods/spinning/silvercast_jigpro.png"],
	["lakemaster_balance_spin_210_l", "LakeMaster Balance Spin 210 L", "LakeMaster Balance Spin", 10, 800, 210, 3, 10, "light", "medium_fast", "light", 130, 3.2, 55, 56, 140, 0.90, "balanced_tackle", 5, "res://assets/items/rods/spinning/lakemaster_balance_spin.png"],
	["lakemaster_balance_spin_240_ml", "LakeMaster Balance Spin 240 ML", "LakeMaster Balance Spin", 13, 1050, 240, 5, 15, "medium_light", "medium_fast", "medium_light", 155, 4.8, 57, 62, 160, 0.88, "balanced_tackle", 6, "res://assets/items/rods/spinning/lakemaster_balance_spin.png"],
	["lakemaster_balance_spin_270_m", "LakeMaster Balance Spin 270 M", "LakeMaster Balance Spin", 17, 1500, 270, 10, 25, "medium", "medium_fast", "medium", 190, 7.5, 55, 70, 190, 0.84, "balanced_tackle", 7, "res://assets/items/rods/spinning/lakemaster_balance_spin.png"],
	["lakemaster_balance_spin_300_h", "LakeMaster Balance Spin 300 H", "LakeMaster Balance Spin", 22, 2500, 300, 20, 45, "heavy", "medium_fast", "heavy", 245, 11.0, 52, 78, 230, 0.80, "balanced_power", 8, "res://assets/items/rods/spinning/lakemaster_balance_spin.png"],
	["fjordline_universal_spin_220_l", "FjordLine Universal Spin 220 L", "FjordLine Universal Spin", 12, 1100, 220, 3, 10, "light", "medium_fast", "light", 138, 3.6, 54, 58, 155, 0.88, "durability", 6, "res://assets/items/rods/spinning/fjordline_universal_spin.png"],
	["fjordline_universal_spin_250_ml", "FjordLine Universal Spin 250 ML", "FjordLine Universal Spin", 15, 1450, 250, 5, 15, "medium_light", "medium_fast", "medium_light", 165, 5.2, 56, 64, 180, 0.85, "durability", 7, "res://assets/items/rods/spinning/fjordline_universal_spin.png"],
	["fjordline_universal_spin_270_m", "FjordLine Universal Spin 270 M", "FjordLine Universal Spin", 19, 2050, 270, 10, 25, "medium", "medium_fast", "medium", 200, 8.0, 54, 72, 215, 0.81, "durability", 8, "res://assets/items/rods/spinning/fjordline_universal_spin.png"],
	["fjordline_universal_spin_300_h", "FjordLine Universal Spin 300 H", "FjordLine Universal Spin", 24, 3200, 300, 20, 45, "heavy", "medium_fast", "heavy", 260, 12.5, 50, 80, 260, 0.76, "durability", 10, "res://assets/items/rods/spinning/fjordline_universal_spin.png"],
	["blackriver_control_spin_210_ul", "BlackRiver Control Spin 210 UL", "BlackRiver Control Spin", 14, 1500, 210, 1, 5, "ultra_light", "fast", "light", 105, 2.4, 76, 52, 150, 0.86, "fish_control", 7, "res://assets/items/rods/spinning/blackriver_control_spin.png"],
	["blackriver_control_spin_230_l", "BlackRiver Control Spin 230 L", "BlackRiver Control Spin", 16, 1900, 230, 3, 10, "light", "fast", "light", 128, 3.8, 74, 58, 175, 0.84, "fish_control", 8, "res://assets/items/rods/spinning/blackriver_control_spin.png"],
	["blackriver_control_spin_250_ml", "BlackRiver Control Spin 250 ML", "BlackRiver Control Spin", 20, 2500, 250, 5, 15, "medium_light", "fast", "medium_light", 158, 5.5, 72, 66, 205, 0.80, "break_risk_reduction", 9, "res://assets/items/rods/spinning/blackriver_control_spin.png"],
	["blackriver_control_spin_270_m", "BlackRiver Control Spin 270 M", "BlackRiver Control Spin", 24, 3600, 270, 10, 25, "medium", "fast", "medium", 195, 8.2, 70, 74, 240, 0.76, "break_risk_reduction", 10, "res://assets/items/rods/spinning/blackriver_control_spin.png"],
	["goldenfish_allround_spin_220_l", "GoldenFish Allround Spin 220 L", "GoldenFish Allround Spin", 16, 1800, 220, 3, 10, "light", "medium_fast", "light", 125, 3.8, 65, 60, 175, 0.84, "premium_balance", 7, "res://assets/items/rods/spinning/goldenfish_allround_spin.png"],
	["goldenfish_allround_spin_250_ml", "GoldenFish Allround Spin 250 ML", "GoldenFish Allround Spin", 19, 2400, 250, 5, 15, "medium_light", "medium_fast", "medium_light", 152, 5.5, 67, 68, 205, 0.81, "premium_balance", 8, "res://assets/items/rods/spinning/goldenfish_allround_spin.png"],
	["goldenfish_allround_spin_270_m", "GoldenFish Allround Spin 270 M", "GoldenFish Allround Spin", 23, 3300, 270, 10, 25, "medium", "medium_fast", "medium", 185, 8.0, 65, 76, 245, 0.77, "premium_balance", 10, "res://assets/items/rods/spinning/goldenfish_allround_spin.png"],
	["goldenfish_allround_spin_300_h", "GoldenFish Allround Spin 300 H", "GoldenFish Allround Spin", 27, 4800, 300, 20, 45, "heavy", "medium_fast", "heavy", 235, 12.0, 60, 84, 290, 0.72, "premium_power", 12, "res://assets/items/rods/spinning/goldenfish_allround_spin.png"],
	["bluepeak_river_spin_240_ml", "BluePeak River Spin 240 ML", "BluePeak River Spin", 17, 1700, 240, 5, 15, "medium_light", "fast", "medium_light", 160, 5.2, 62, 66, 190, 0.83, "river_control", 7, "res://assets/items/rods/spinning/bluepeak_river_spin.png"],
	["bluepeak_river_spin_270_m", "BluePeak River Spin 270 M", "BluePeak River Spin", 21, 2600, 270, 10, 25, "medium", "fast", "medium", 198, 8.0, 64, 74, 230, 0.79, "river_control", 9, "res://assets/items/rods/spinning/bluepeak_river_spin.png"],
	["bluepeak_river_spin_300_h", "BluePeak River Spin 300 H", "BluePeak River Spin", 26, 4200, 300, 20, 45, "heavy", "fast", "heavy", 255, 12.5, 60, 82, 280, 0.73, "river_power", 11, "res://assets/items/rods/spinning/bluepeak_river_spin.png"],
	["irondrag_pike_hunter_260_m", "IronDrag Pike Hunter 260 M", "IronDrag Pike Hunter", 22, 2800, 260, 10, 25, "medium", "fast", "medium", 205, 8.5, 58, 72, 240, 0.78, "pike_power", 9, "res://assets/items/rods/spinning/irondrag_pike_hunter.png"],
	["irondrag_pike_hunter_280_h", "IronDrag Pike Hunter 280 H", "IronDrag Pike Hunter", 26, 4400, 280, 20, 45, "heavy", "fast", "heavy", 265, 13.5, 55, 80, 295, 0.72, "pike_power", 12, "res://assets/items/rods/spinning/irondrag_pike_hunter.png"],
	["irondrag_pike_hunter_300_xh", "IronDrag Pike Hunter 300 XH", "IronDrag Pike Hunter", 29, 6800, 300, 40, 80, "extra_heavy", "fast", "extra_heavy", 340, 20.0, 48, 88, 350, 0.66, "trophy_power", 15, "res://assets/items/rods/spinning/irondrag_pike_hunter.png"],
	["oceanbull_monster_spin_270_h", "OceanBull Monster Spin 270 H", "OceanBull Monster Spin", 28, 5200, 270, 20, 45, "heavy", "medium_fast", "heavy", 285, 15.0, 52, 82, 320, 0.70, "monster_control", 13, "res://assets/items/rods/spinning/oceanbull_monster_spin.png"],
	["oceanbull_monster_spin_300_xh", "OceanBull Monster Spin 300 XH", "OceanBull Monster Spin", 30, 7800, 300, 40, 80, "extra_heavy", "medium_fast", "extra_heavy", 365, 24.0, 45, 90, 390, 0.60, "monster_power", 18, "res://assets/items/rods/spinning/oceanbull_monster_spin.png"]
]

static func get_rod_catalog() -> Dictionary:
	var catalog := {}
	for row in RAW_SPINNING_RODS:
		var item := _build_rod_item(row)
		catalog[str(item.get("id", ""))] = item
	return catalog


static func get_rod(item_id: String) -> Dictionary:
	var catalog := get_rod_catalog()
	if not catalog.has(item_id):
		return {}
	return (catalog[item_id] as Dictionary).duplicate(true)


static func _build_rod_item(row: Array) -> Dictionary:
	var item_id := str(row[ROW_ID])
	var name := str(row[ROW_NAME])
	var series := str(row[ROW_SERIES])
	var level := int(row[ROW_LEVEL])
	var length_cm := int(row[ROW_LENGTH_CM])
	var test_min := float(row[ROW_TEST_MIN_G])
	var test_max := float(row[ROW_TEST_MAX_G])
	var rod_class := str(row[ROW_ROD_CLASS])
	var action := str(row[ROW_ACTION])
	var power_class := str(row[ROW_POWER_CLASS])
	var weight_g := float(row[ROW_WEIGHT_G])
	var max_fish_weight := float(row[ROW_MAX_FISH_WEIGHT_KG])
	var sensitivity := float(row[ROW_SENSITIVITY])
	var cast_distance := float(row[ROW_CAST_DISTANCE])
	var durability_points := float(row[ROW_DURABILITY_POINTS])
	var wear_per_cast := float(row[ROW_WEAR_PER_CAST])
	var bonus_type := str(row[ROW_BONUS_TYPE])
	var bonus_value := float(row[ROW_BONUS_VALUE])
	var icon_path := str(row[ROW_ICON_PATH])
	var reel_range := _get_reel_range_for_class(rod_class)
	var methods := _get_methods(series, bonus_type)
	var filter_tags := _get_filter_tags(series, rod_class, bonus_type)
	var length_m := float(length_cm) / 100.0
	var power_value := _get_power_value(power_class, max_fish_weight, test_max)
	var stiffness := _get_stiffness_value(action, power_class, test_max)
	var control_bonus := _get_control_bonus(sensitivity, bonus_type, bonus_value)
	var reach_bonus := _get_reach_bonus(cast_distance, bonus_type, bonus_value)
	var handling_bonus := _get_handling_bonus(weight_g, length_cm, action)
	var wear_rate := clampf(wear_per_cast / maxf(durability_points, 1.0), 0.003, 0.014)
	var rarity := _get_rarity_for_level(level)
	var bonus_text := _get_bonus_text(bonus_type, bonus_value)

	return {
		"id": item_id,
		"name": name,
		"display_name_ru": name,
		"series": series,
		"item_type": "rod",
		"type": "rod",
		"category": "rod",
		"rod_type": "spinning",
		"tackle_type": "spinning",
		"requires_reel": true,
		"rarity": rarity,
		"price": float(row[ROW_PRICE]),
		"required_level": level,
		"level_required": level,
		"compatible_methods": methods.duplicate(),
		"bonus_type": bonus_type,
		"bonus_value": bonus_value,
		"bonus_text": bonus_text,
		"icon_path": icon_path,
		"image_path": icon_path,
		"description": _get_description(name, series, length_cm, test_min, test_max, rod_class, bonus_text),
		"description_ru": _get_description(name, series, length_cm, test_min, test_max, rod_class, bonus_text),
		"stats": {
			"rod_type": "spinning",
			"tackle_type": "spinning",
			"requires_reel": true,
			"series": series,
			"length": length_m,
			"length_m": length_m,
			"length_cm": length_cm,
			"test_min": test_min,
			"test_max": test_max,
			"test_min_g": test_min,
			"test_max_g": test_max,
			"rod_class": rod_class,
			"action": action,
			"power": power_value,
			"power_class": power_class,
			"weight": weight_g,
			"weight_g": weight_g,
			"max_fish_weight": max_fish_weight,
			"sensitivity": sensitivity,
			"sensitivity_rating": sensitivity,
			"cast_distance": cast_distance,
			"cast_distance_rating": cast_distance,
			"durability": 1.0,
			"durability_points": durability_points,
			"wear_per_cast": wear_per_cast,
			"durability_loss": wear_rate,
			"strength": power_value,
			"stiffness": stiffness,
			"flexibility": _get_flexibility(action, power_class),
			"control_bonus": control_bonus,
			"tension_bonus": control_bonus,
			"handling_bonus": handling_bonus,
			"reach_bonus": reach_bonus,
			"cast_distance_bonus": reach_bonus,
			"compatible_reel_min_size": int(reel_range.get("min", 1000)),
			"compatible_reel_max_size": int(reel_range.get("max", 4000)),
			"compatible_methods": methods.duplicate(),
			"bonus_type": bonus_type,
			"bonus_value": bonus_value,
			"bonus_text": bonus_text,
			"filter_tags": filter_tags.duplicate(),
			"lure_light_cast_distance_penalty": -0.20,
			"lure_light_bite_chance_multiplier": 0.90,
			"lure_heavy_rod_wear_multiplier": 1.50,
			"lure_heavy_lure_wear_multiplier": 1.50
		}
	}


static func _get_reel_range_for_class(rod_class: String) -> Dictionary:
	match rod_class:
		"ultra_light", "light":
			return {"min": 1000, "max": 2000}
		"medium_light":
			return {"min": 2000, "max": 3000}
		"medium":
			return {"min": 2500, "max": 4000}
		"heavy":
			return {"min": 3000, "max": 5000}
		"extra_heavy":
			return {"min": 4000, "max": 6000}
		_:
			return {"min": 1000, "max": 4000}


static func _get_methods(series: String, bonus_type: String) -> Array:
	var methods := ["spinning"]
	var text := ("%s %s" % [series, bonus_type]).to_lower()
	if text.find("jig") != -1:
		methods.append("jig")
	if text.find("twitch") != -1:
		methods.append("twitching")
	if text.find("universal") != -1 or text.find("allround") != -1 or text.find("balance") != -1:
		methods.append("universal")
	if text.find("pike") != -1 or text.find("trophy") != -1 or text.find("monster") != -1:
		methods.append("trophy")
	if text.find("start") != -1 or text.find("basic") != -1:
		methods.append("starter")
	return methods


static func _get_filter_tags(series: String, rod_class: String, bonus_type: String) -> Array:
	var tags := [rod_class]
	var text := ("%s %s" % [series, bonus_type]).to_lower()
	if text.find("start") != -1 or text.find("basic") != -1:
		tags.append("starter")
	if text.find("universal") != -1 or text.find("allround") != -1 or text.find("balance") != -1:
		tags.append("universal")
	if text.find("jig") != -1:
		tags.append("jig")
	if text.find("twitch") != -1:
		tags.append("twitching")
	if text.find("pike") != -1 or text.find("trophy") != -1 or text.find("monster") != -1:
		tags.append("trophy")
	return tags


static func _get_rarity_for_level(level: int) -> String:
	if level >= 28:
		return "trophy"
	if level >= 24:
		return "epic"
	if level >= 18:
		return "rare"
	if level >= 12:
		return "uncommon"
	return "common"


static func _get_power_value(power_class: String, max_fish_weight: float, test_max: float) -> float:
	var base := 0.72
	match power_class:
		"light":
			base = 0.82
		"medium_light":
			base = 1.02
		"medium":
			base = 1.20
		"heavy":
			base = 1.48
		"extra_heavy":
			base = 1.88
	return clampf(base + max_fish_weight * 0.022 + test_max * 0.004, 0.45, 2.75)


static func _get_stiffness_value(action: String, power_class: String, test_max: float) -> float:
	var value := 0.86 + test_max * 0.006
	match action:
		"extra_fast":
			value += 0.20
		"fast":
			value += 0.12
		"medium_fast":
			value += 0.04
	match power_class:
		"heavy":
			value += 0.10
		"extra_heavy":
			value += 0.18
	return clampf(value, 0.70, 2.10)


static func _get_flexibility(action: String, power_class: String) -> float:
	var value := 0.60
	match action:
		"extra_fast":
			value = 0.36
		"fast":
			value = 0.44
		"medium_fast":
			value = 0.54
	if power_class == "heavy":
		value -= 0.05
	elif power_class == "extra_heavy":
		value -= 0.10
	return clampf(value, 0.20, 0.78)


static func _get_control_bonus(sensitivity: float, bonus_type: String, bonus_value: float) -> float:
	var value := (sensitivity - 40.0) / 100.0 * 0.34
	if ["starter_control", "twitch_control", "active_lure_control", "jig_sensitivity", "fish_control", "river_control", "monster_control"].has(bonus_type):
		value += bonus_value / 100.0 * 0.35
	return clampf(value, 0.02, 0.24)


static func _get_reach_bonus(cast_distance: float, bonus_type: String, bonus_value: float) -> float:
	var value := (cast_distance - 45.0) / 100.0 * 0.34
	if bonus_type == "cast_distance":
		value += bonus_value / 100.0 * 0.35
	return clampf(value, -0.02, 0.18)


static func _get_handling_bonus(weight_g: float, length_cm: int, action: String) -> float:
	var value := 0.045 - maxf(weight_g - 120.0, 0.0) / 1000.0 - maxf(float(length_cm) - 230.0, 0.0) / 1800.0
	if action == "extra_fast":
		value += 0.01
	return clampf(value, -0.06, 0.07)


static func _get_bonus_text(bonus_type: String, bonus_value: float) -> String:
	var value := roundi(bonus_value)
	match bonus_type:
		"starter_control":
			return "контроль новичка +%d%%" % value
		"starter_power":
			return "стартовая мощность +%d%%" % value
		"line_safety":
			return "безопасность лески +%d%%" % value
		"sensitivity":
			return "чувствительность +%d%%" % value
		"cast_distance":
			return "дальность +%d%%" % value
		"twitch_control":
			return "твичинг +%d%%" % value
		"active_lure_control":
			return "активная приманка +%d%%" % value
		"jig_sensitivity":
			return "джиг-чувствительность +%d%%" % value
		"jig_power":
			return "джиг-мощность +%d%%" % value
		"balanced_tackle":
			return "баланс снасти +%d%%" % value
		"balanced_power":
			return "сбалансированная мощь +%d%%" % value
		"durability":
			return "прочность +%d%%" % value
		"fish_control":
			return "контроль рыбы +%d%%" % value
		"break_risk_reduction":
			return "меньше риск обрыва +%d%%" % value
		"premium_balance":
			return "премиум-баланс +%d%%" % value
		"premium_power":
			return "премиум-мощь +%d%%" % value
		"river_control":
			return "контроль на течении +%d%%" % value
		"river_power":
			return "речная мощь +%d%%" % value
		"pike_power":
			return "щучья мощь +%d%%" % value
		"trophy_power":
			return "трофейная мощь +%d%%" % value
		"monster_control":
			return "монстр-контроль +%d%%" % value
		"monster_power":
			return "монстр-мощь +%d%%" % value
		_:
			return "%s +%d%%" % [bonus_type.replace("_", " "), value]


static func _get_description(name: String, series: String, length_cm: int, test_min: float, test_max: float, rod_class: String, bonus_text: String) -> String:
	return "%s. Спиннинговое удилище серии %s: %d см, тест %.0f-%.0f г, класс %s. Бонус: %s." % [
		name,
		series,
		length_cm,
		test_min,
		test_max,
		rod_class.replace("_", " "),
		bonus_text
	]
