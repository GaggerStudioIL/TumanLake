extends RefCounted

const ROW_ID := 0
const ROW_NAME := 1
const ROW_SERIES := 2
const ROW_SIZE := 3
const ROW_LEVEL := 4
const ROW_PRICE := 5
const ROW_GEAR_RATIO := 6
const ROW_MAX_DRAG := 7
const ROW_LINE_CAPACITY := 8
const ROW_WEIGHT := 9
const ROW_DURABILITY := 10
const ROW_WEAR_RESISTANCE := 11
const ROW_METHODS := 12
const ROW_BONUS_TYPE := 13
const ROW_BONUS_VALUE := 14
const ROW_ICON_PATH := 15

const RAW_REELS := [
	["fishpoint_start_2000", "FishPoint Start 2000", "FishPoint Start", 2000, 8, 260, "5.2:1", 3.2, "0.20 мм / 120 м", 235, 90, 0.90, ["spinning"], "starter_control", 3, "res://assets/items/reels/fishpoint_start.png"],
	["fishpoint_start_3000", "FishPoint Start 3000", "FishPoint Start", 3000, 10, 360, "5.2:1", 4.5, "0.25 мм / 150 м", 285, 100, 0.88, ["spinning", "picker"], "starter_power", 4, "res://assets/items/reels/fishpoint_start.png"],
	["nordlake_basic_2000", "NordLake Basic 2000", "NordLake Basic", 2000, 9, 340, "5.1:1", 3.8, "0.20 мм / 130 м", 245, 105, 0.88, ["spinning"], "line_safety", 4, "res://assets/items/reels/nordlake_basic.png"],
	["nordlake_basic_3000", "NordLake Basic 3000", "NordLake Basic", 3000, 12, 480, "5.1:1", 5.2, "0.25 мм / 160 м", 300, 118, 0.86, ["spinning", "picker"], "line_safety", 5, "res://assets/items/reels/nordlake_basic.png"],
	["aerospin_swift_1000", "AeroSpin Swift 1000", "AeroSpin Swift", 1000, 8, 380, "5.6:1", 2.8, "0.16 мм / 100 м", 190, 100, 0.92, ["spinning"], "sensitivity", 5, "res://assets/items/reels/aerospin_swift.png"],
	["aerospin_swift_2000", "AeroSpin Swift 2000", "AeroSpin Swift", 2000, 10, 520, "5.6:1", 3.8, "0.20 мм / 120 м", 220, 112, 0.90, ["spinning"], "sensitivity", 6, "res://assets/items/reels/aerospin_swift.png"],
	["aerospin_swift_3000", "AeroSpin Swift 3000", "AeroSpin Swift", 3000, 14, 760, "5.5:1", 5.0, "0.25 мм / 150 м", 265, 130, 0.88, ["spinning"], "cast_distance", 6, "res://assets/items/reels/aerospin_swift.png"],
	["riverfox_blade_1000", "RiverFox Blade 1000", "RiverFox Blade", 1000, 11, 540, "6.0:1", 3.0, "0.16 мм / 110 м", 195, 115, 0.90, ["spinning"], "retrieve_speed", 6, "res://assets/items/reels/riverfox_blade.png"],
	["riverfox_blade_2000", "RiverFox Blade 2000", "RiverFox Blade", 2000, 13, 720, "6.0:1", 4.2, "0.20 мм / 130 м", 230, 130, 0.88, ["spinning"], "retrieve_speed", 7, "res://assets/items/reels/riverfox_blade.png"],
	["riverfox_blade_3000", "RiverFox Blade 3000", "RiverFox Blade", 3000, 17, 1050, "5.8:1", 6.0, "0.25 мм / 160 м", 285, 150, 0.86, ["spinning"], "active_lure_control", 8, "res://assets/items/reels/riverfox_blade.png"],
	["silvercast_prospin_1000", "SilverCast ProSpin 1000", "SilverCast ProSpin", 1000, 15, 780, "5.4:1", 3.4, "0.16 мм / 120 м", 185, 140, 0.87, ["spinning"], "drag_smoothness", 8, "res://assets/items/reels/silvercast_prospin.png"],
	["silvercast_prospin_2000", "SilverCast ProSpin 2000", "SilverCast ProSpin", 2000, 18, 1050, "5.4:1", 4.8, "0.20 мм / 140 м", 220, 160, 0.84, ["spinning"], "break_risk_reduction", 9, "res://assets/items/reels/silvercast_prospin.png"],
	["silvercast_prospin_3000", "SilverCast ProSpin 3000", "SilverCast ProSpin", 3000, 22, 1480, "5.3:1", 6.8, "0.25 мм / 180 м", 275, 185, 0.82, ["spinning"], "fish_control", 10, "res://assets/items/reels/silvercast_prospin.png"],
	["lakemaster_balance_1000", "LakeMaster Balance 1000", "LakeMaster Balance", 1000, 10, 460, "5.2:1", 3.0, "0.16 мм / 110 м", 205, 110, 0.90, ["spinning"], "balanced_tackle", 4, "res://assets/items/reels/lakemaster_balance.png"],
	["lakemaster_balance_2000", "LakeMaster Balance 2000", "LakeMaster Balance", 2000, 12, 620, "5.2:1", 4.2, "0.20 мм / 130 м", 240, 125, 0.88, ["spinning"], "balanced_tackle", 5, "res://assets/items/reels/lakemaster_balance.png"],
	["lakemaster_balance_3000", "LakeMaster Balance 3000", "LakeMaster Balance", 3000, 15, 850, "5.2:1", 5.8, "0.25 мм / 160 м", 295, 145, 0.86, ["spinning", "picker"], "balanced_tackle", 6, "res://assets/items/reels/lakemaster_balance.png"],
	["lakemaster_balance_4000", "LakeMaster Balance 4000", "LakeMaster Balance", 4000, 18, 1150, "5.1:1", 7.5, "0.30 мм / 180 м", 355, 165, 0.84, ["spinning", "picker", "feeder_light"], "balanced_tackle", 7, "res://assets/items/reels/lakemaster_balance.png"],
	["lakemaster_balance_5000", "LakeMaster Balance 5000", "LakeMaster Balance", 5000, 22, 1550, "5.0:1", 9.5, "0.35 мм / 220 м", 430, 190, 0.82, ["feeder", "donka"], "balanced_tackle", 8, "res://assets/items/reels/lakemaster_balance.png"],
	["lakemaster_balance_6000", "LakeMaster Balance 6000", "LakeMaster Balance", 6000, 26, 2100, "4.9:1", 11.5, "0.40 мм / 260 м", 515, 215, 0.80, ["feeder", "donka"], "balanced_tackle", 9, "res://assets/items/reels/lakemaster_balance.png"],
	["fjordline_universal_1000", "FjordLine Universal 1000", "FjordLine Universal", 1000, 12, 560, "5.2:1", 3.2, "0.16 мм / 120 м", 210, 125, 0.89, ["spinning"], "durability", 5, "res://assets/items/reels/fjordline_universal.png"],
	["fjordline_universal_2000", "FjordLine Universal 2000", "FjordLine Universal", 2000, 14, 760, "5.2:1", 4.6, "0.20 мм / 140 м", 250, 145, 0.87, ["spinning"], "durability", 6, "res://assets/items/reels/fjordline_universal.png"],
	["fjordline_universal_3000", "FjordLine Universal 3000", "FjordLine Universal", 3000, 17, 1050, "5.1:1", 6.3, "0.25 мм / 170 м", 310, 165, 0.85, ["spinning", "picker"], "durability", 7, "res://assets/items/reels/fjordline_universal.png"],
	["fjordline_universal_4000", "FjordLine Universal 4000", "FjordLine Universal", 4000, 20, 1450, "5.0:1", 8.3, "0.30 мм / 190 м", 375, 190, 0.83, ["spinning", "picker", "feeder_light"], "durability", 8, "res://assets/items/reels/fjordline_universal.png"],
	["fjordline_universal_5000", "FjordLine Universal 5000", "FjordLine Universal", 5000, 24, 1950, "4.9:1", 10.8, "0.35 мм / 230 м", 455, 220, 0.80, ["feeder", "donka"], "durability", 9, "res://assets/items/reels/fjordline_universal.png"],
	["fjordline_universal_6000", "FjordLine Universal 6000", "FjordLine Universal", 6000, 28, 2600, "4.8:1", 13.0, "0.40 мм / 280 м", 545, 250, 0.78, ["feeder", "donka"], "durability", 10, "res://assets/items/reels/fjordline_universal.png"],
	["blackriver_control_1000", "BlackRiver Control 1000", "BlackRiver Control", 1000, 14, 650, "5.1:1", 3.6, "0.16 мм / 120 м", 215, 135, 0.88, ["spinning"], "drag_smoothness", 6, "res://assets/items/reels/blackriver_control.png"],
	["blackriver_control_2000", "BlackRiver Control 2000", "BlackRiver Control", 2000, 16, 880, "5.1:1", 5.0, "0.20 мм / 140 м", 255, 155, 0.86, ["spinning"], "drag_smoothness", 7, "res://assets/items/reels/blackriver_control.png"],
	["blackriver_control_3000", "BlackRiver Control 3000", "BlackRiver Control", 3000, 19, 1200, "5.0:1", 6.8, "0.25 мм / 170 м", 315, 180, 0.84, ["spinning", "picker"], "break_risk_reduction", 8, "res://assets/items/reels/blackriver_control.png"],
	["blackriver_control_4000", "BlackRiver Control 4000", "BlackRiver Control", 4000, 22, 1650, "4.9:1", 9.0, "0.30 мм / 200 м", 385, 205, 0.82, ["picker", "feeder"], "break_risk_reduction", 9, "res://assets/items/reels/blackriver_control.png"],
	["blackriver_control_5000", "BlackRiver Control 5000", "BlackRiver Control", 5000, 25, 2200, "4.8:1", 11.5, "0.35 мм / 240 м", 465, 235, 0.79, ["feeder", "donka"], "fish_control", 10, "res://assets/items/reels/blackriver_control.png"],
	["blackriver_control_6000", "BlackRiver Control 6000", "BlackRiver Control", 6000, 28, 2900, "4.7:1", 14.0, "0.40 мм / 290 м", 555, 265, 0.76, ["feeder", "donka"], "fish_control", 11, "res://assets/items/reels/blackriver_control.png"],
	["goldenfish_allround_1000", "GoldenFish Allround 1000", "GoldenFish Allround", 1000, 16, 760, "5.3:1", 3.8, "0.16 мм / 130 м", 205, 145, 0.87, ["spinning"], "premium_balance", 6, "res://assets/items/reels/goldenfish_allround.png"],
	["goldenfish_allround_2000", "GoldenFish Allround 2000", "GoldenFish Allround", 2000, 18, 1020, "5.3:1", 5.2, "0.20 мм / 150 м", 245, 165, 0.85, ["spinning"], "premium_balance", 7, "res://assets/items/reels/goldenfish_allround.png"],
	["goldenfish_allround_3000", "GoldenFish Allround 3000", "GoldenFish Allround", 3000, 21, 1400, "5.2:1", 7.0, "0.25 мм / 180 м", 300, 190, 0.83, ["spinning", "picker"], "premium_balance", 8, "res://assets/items/reels/goldenfish_allround.png"],
	["goldenfish_allround_4000", "GoldenFish Allround 4000", "GoldenFish Allround", 4000, 24, 1900, "5.1:1", 9.3, "0.30 мм / 210 м", 370, 220, 0.80, ["picker", "feeder"], "premium_balance", 9, "res://assets/items/reels/goldenfish_allround.png"],
	["goldenfish_allround_5000", "GoldenFish Allround 5000", "GoldenFish Allround", 5000, 27, 2600, "5.0:1", 12.0, "0.35 мм / 250 м", 450, 250, 0.77, ["feeder", "donka"], "premium_balance", 10, "res://assets/items/reels/goldenfish_allround.png"],
	["goldenfish_allround_6000", "GoldenFish Allround 6000", "GoldenFish Allround", 6000, 29, 3400, "4.9:1", 14.5, "0.40 мм / 300 м", 540, 280, 0.74, ["feeder", "donka"], "premium_balance", 11, "res://assets/items/reels/goldenfish_allround.png"],
	["clearwater_flex_1000", "ClearWater Flex 1000", "ClearWater Flex", 1000, 11, 500, "5.4:1", 3.0, "0.16 мм / 120 м", 195, 115, 0.90, ["spinning"], "light_tackle", 5, "res://assets/items/reels/clearwater_flex.png"],
	["clearwater_flex_2000", "ClearWater Flex 2000", "ClearWater Flex", 2000, 13, 680, "5.4:1", 4.2, "0.20 мм / 140 м", 230, 132, 0.88, ["spinning"], "light_tackle", 6, "res://assets/items/reels/clearwater_flex.png"],
	["clearwater_flex_3000", "ClearWater Flex 3000", "ClearWater Flex", 3000, 16, 920, "5.3:1", 5.8, "0.25 мм / 165 м", 285, 152, 0.86, ["spinning", "picker"], "light_tackle", 7, "res://assets/items/reels/clearwater_flex.png"],
	["clearwater_flex_4000", "ClearWater Flex 4000", "ClearWater Flex", 4000, 19, 1250, "5.2:1", 7.5, "0.30 мм / 190 м", 350, 175, 0.84, ["picker", "feeder_light"], "light_feeder", 7, "res://assets/items/reels/clearwater_flex.png"],
	["clearwater_flex_5000", "ClearWater Flex 5000", "ClearWater Flex", 5000, 23, 1650, "5.1:1", 9.5, "0.35 мм / 225 м", 425, 200, 0.82, ["feeder"], "light_feeder", 8, "res://assets/items/reels/clearwater_flex.png"],
	["clearwater_flex_6000", "ClearWater Flex 6000", "ClearWater Flex", 6000, 27, 2200, "5.0:1", 11.5, "0.40 мм / 265 м", 505, 225, 0.80, ["feeder", "donka_light"], "light_feeder", 9, "res://assets/items/reels/clearwater_flex.png"],
	["reedline_picker_1000", "ReedLine Picker 1000", "ReedLine Picker", 1000, 12, 520, "5.2:1", 3.2, "0.16 мм / 120 м", 205, 120, 0.89, ["spinning", "picker"], "picker_control", 5, "res://assets/items/reels/reedline_picker.png"],
	["reedline_picker_2000", "ReedLine Picker 2000", "ReedLine Picker", 2000, 14, 720, "5.2:1", 4.4, "0.20 мм / 145 м", 245, 140, 0.87, ["spinning", "picker"], "picker_control", 6, "res://assets/items/reels/reedline_picker.png"],
	["reedline_picker_3000", "ReedLine Picker 3000", "ReedLine Picker", 3000, 17, 980, "5.1:1", 6.0, "0.25 мм / 170 м", 300, 162, 0.85, ["picker", "spinning"], "picker_control", 7, "res://assets/items/reels/reedline_picker.png"],
	["reedline_picker_4000", "ReedLine Picker 4000", "ReedLine Picker", 4000, 20, 1350, "5.0:1", 7.8, "0.30 мм / 200 м", 365, 188, 0.83, ["picker", "feeder_light"], "feeder_control", 8, "res://assets/items/reels/reedline_picker.png"],
	["reedline_picker_5000", "ReedLine Picker 5000", "ReedLine Picker", 5000, 24, 1780, "4.9:1", 10.0, "0.35 мм / 235 м", 440, 215, 0.80, ["feeder"], "feeder_control", 9, "res://assets/items/reels/reedline_picker.png"],
	["reedline_picker_6000", "ReedLine Picker 6000", "ReedLine Picker", 6000, 28, 2350, "4.8:1", 12.0, "0.40 мм / 275 м", 525, 240, 0.78, ["feeder", "donka_light"], "feeder_control", 10, "res://assets/items/reels/reedline_picker.png"],
	["stormway_match_1000", "StormWay Match 1000", "StormWay Match", 1000, 13, 580, "5.5:1", 3.0, "0.16 мм / 130 м", 200, 122, 0.89, ["spinning"], "cast_distance", 5, "res://assets/items/reels/stormway_match.png"],
	["stormway_match_2000", "StormWay Match 2000", "StormWay Match", 2000, 15, 790, "5.5:1", 4.3, "0.20 мм / 150 м", 235, 142, 0.87, ["spinning"], "cast_distance", 6, "res://assets/items/reels/stormway_match.png"],
	["stormway_match_3000", "StormWay Match 3000", "StormWay Match", 3000, 18, 1080, "5.4:1", 6.0, "0.25 мм / 180 м", 290, 165, 0.85, ["spinning", "picker"], "cast_distance", 7, "res://assets/items/reels/stormway_match.png"],
	["stormway_match_4000", "StormWay Match 4000", "StormWay Match", 4000, 21, 1500, "5.3:1", 7.8, "0.30 мм / 210 м", 355, 190, 0.83, ["picker", "feeder_light"], "cast_distance", 8, "res://assets/items/reels/stormway_match.png"],
	["stormway_match_5000", "StormWay Match 5000", "StormWay Match", 5000, 25, 2000, "5.2:1", 10.0, "0.35 мм / 250 м", 430, 218, 0.80, ["feeder"], "long_cast", 9, "res://assets/items/reels/stormway_match.png"],
	["stormway_match_6000", "StormWay Match 6000", "StormWay Match", 6000, 29, 2650, "5.1:1", 12.2, "0.40 мм / 300 м", 515, 245, 0.78, ["feeder", "donka_light"], "long_cast", 10, "res://assets/items/reels/stormway_match.png"],
	["bluepeak_river_1000", "BluePeak River 1000", "BluePeak River", 1000, 14, 620, "5.3:1", 3.4, "0.16 мм / 125 м", 210, 130, 0.88, ["spinning"], "river_control", 6, "res://assets/items/reels/bluepeak_river.png"],
	["bluepeak_river_2000", "BluePeak River 2000", "BluePeak River", 2000, 16, 850, "5.3:1", 4.8, "0.20 мм / 145 м", 250, 150, 0.86, ["spinning"], "river_control", 7, "res://assets/items/reels/bluepeak_river.png"],
	["bluepeak_river_3000", "BluePeak River 3000", "BluePeak River", 3000, 19, 1150, "5.2:1", 6.5, "0.25 мм / 175 м", 305, 175, 0.84, ["spinning", "picker"], "river_control", 8, "res://assets/items/reels/bluepeak_river.png"],
	["bluepeak_river_4000", "BluePeak River 4000", "BluePeak River", 4000, 22, 1580, "5.1:1", 8.6, "0.30 мм / 205 м", 375, 202, 0.82, ["picker", "feeder"], "river_control", 9, "res://assets/items/reels/bluepeak_river.png"],
	["bluepeak_river_5000", "BluePeak River 5000", "BluePeak River", 5000, 26, 2150, "5.0:1", 11.0, "0.35 мм / 245 м", 455, 232, 0.79, ["feeder", "donka_light"], "river_control", 10, "res://assets/items/reels/bluepeak_river.png"],
	["bluepeak_river_6000", "BluePeak River 6000", "BluePeak River", 6000, 29, 2850, "4.9:1", 13.5, "0.40 мм / 290 м", 545, 260, 0.76, ["feeder", "donka"], "river_control", 11, "res://assets/items/reels/bluepeak_river.png"],
	["wildcarp_lite_1000", "WildCarp Lite 1000", "WildCarp Lite", 1000, 16, 700, "5.1:1", 3.6, "0.16 мм / 130 м", 215, 140, 0.87, ["spinning"], "carp_lite", 6, "res://assets/items/reels/wildcarp_lite.png"],
	["wildcarp_lite_2000", "WildCarp Lite 2000", "WildCarp Lite", 2000, 18, 950, "5.1:1", 5.0, "0.20 мм / 150 м", 255, 162, 0.85, ["spinning", "picker"], "carp_lite", 7, "res://assets/items/reels/wildcarp_lite.png"],
	["wildcarp_lite_3000", "WildCarp Lite 3000", "WildCarp Lite", 3000, 21, 1300, "5.0:1", 6.8, "0.25 мм / 180 м", 315, 188, 0.83, ["picker", "feeder_light"], "carp_lite", 8, "res://assets/items/reels/wildcarp_lite.png"],
	["wildcarp_lite_4000", "WildCarp Lite 4000", "WildCarp Lite", 4000, 24, 1750, "4.9:1", 9.0, "0.30 мм / 220 м", 390, 218, 0.80, ["feeder"], "carp_lite", 9, "res://assets/items/reels/wildcarp_lite.png"],
	["wildcarp_lite_5000", "WildCarp Lite 5000", "WildCarp Lite", 5000, 27, 2350, "4.8:1", 11.8, "0.35 мм / 265 м", 475, 250, 0.77, ["feeder", "donka"], "carp_lite", 10, "res://assets/items/reels/wildcarp_lite.png"],
	["wildcarp_lite_6000", "WildCarp Lite 6000", "WildCarp Lite", 6000, 29, 3100, "4.7:1", 14.0, "0.40 мм / 320 м", 565, 280, 0.74, ["feeder", "donka"], "carp_lite", 11, "res://assets/items/reels/wildcarp_lite.png"],
	["irondrag_titan_8000", "IronDrag Titan 8000", "IronDrag Titan", 8000, 29, 5200, "4.6:1", 22.0, "0.55 мм / 350 м", 780, 340, 0.68, ["donka_heavy", "carp", "som", "sea_future"], "heavy_power", 15, "res://assets/items/reels/irondrag_titan.png"],
	["oceanbull_force_8000", "OceanBull Force 8000", "OceanBull Force", 8000, 30, 7200, "4.5:1", 26.0, "0.60 мм / 380 м", 840, 380, 0.62, ["donka_heavy", "carp", "som", "sea_future"], "trophy_power", 18, "res://assets/items/reels/oceanbull_force.png"]
]


static func get_reel_catalog() -> Dictionary:
	var catalog := {}
	for row in RAW_REELS:
		var item := _build_reel_item(row)
		catalog[str(item.get("id", ""))] = item
	return catalog


static func get_reel_required_levels() -> Dictionary:
	var levels := {}
	for row in RAW_REELS:
		levels[str(row[ROW_ID])] = int(row[ROW_LEVEL])
	return levels


static func _build_reel_item(row: Array) -> Dictionary:
	var item_id := str(row[ROW_ID])
	var item_name := str(row[ROW_NAME])
	var series := str(row[ROW_SERIES])
	var reel_size := int(row[ROW_SIZE])
	var required_level := int(row[ROW_LEVEL])
	var price := float(row[ROW_PRICE])
	var gear_ratio := str(row[ROW_GEAR_RATIO])
	var max_drag_kg := float(row[ROW_MAX_DRAG])
	var line_capacity := str(row[ROW_LINE_CAPACITY])
	var weight_g := float(row[ROW_WEIGHT])
	var durability_points := float(row[ROW_DURABILITY])
	var wear_resistance := float(row[ROW_WEAR_RESISTANCE])
	var compatible_methods := _to_string_array(row[ROW_METHODS])
	var bonus_type := str(row[ROW_BONUS_TYPE])
	var bonus_value := float(row[ROW_BONUS_VALUE])
	var icon_path := str(row[ROW_ICON_PATH])
	var bonus_text := _get_bonus_text(bonus_type, bonus_value)

	var stats := {
		"reel_size": reel_size,
		"size": reel_size,
		"reel_type": "spinning_reel",
		"gear_ratio": gear_ratio,
		"max_drag": max_drag_kg,
		"max_drag_kg": max_drag_kg,
		"line_capacity": line_capacity,
		"spool_capacity": _extract_capacity_m(line_capacity),
		"weight": weight_g,
		"weight_g": weight_g,
		"durability": 1.0,
		"durability_points": durability_points,
		"wear_resistance": wear_resistance,
		"wear_rate": _get_wear_rate(wear_resistance),
		"retrieve_speed": _get_retrieve_speed(gear_ratio),
		"compatible_methods": compatible_methods,
		"bonus_type": bonus_type,
		"bonus_value": bonus_value,
		"bonus_text": bonus_text,
		"icon_path": icon_path,
		"image_path": icon_path
	}

	return {
		"id": item_id,
		"name": item_name,
		"display_name_ru": item_name,
		"series": series,
		"item_type": "reel",
		"type": "reel",
		"category": "reel",
		"reel_type": "spinning_reel",
		"size": reel_size,
		"gear_ratio": gear_ratio,
		"max_drag_kg": max_drag_kg,
		"line_capacity": line_capacity,
		"weight_g": weight_g,
		"required_level": required_level,
		"level_required": required_level,
		"rarity": _get_rarity_for_level(required_level),
		"price": price,
		"durability": durability_points,
		"durability_points": durability_points,
		"wear_resistance": wear_resistance,
		"compatible_methods": compatible_methods,
		"bonus_type": bonus_type,
		"bonus_value": bonus_value,
		"bonus_text": bonus_text,
		"icon_path": icon_path,
		"image_path": icon_path,
		"description": _build_description(series, reel_size, max_drag_kg, compatible_methods, bonus_text),
		"description_ru": _build_description(series, reel_size, max_drag_kg, compatible_methods, bonus_text),
		"stats": stats
	}


static func _to_string_array(value) -> Array:
	var result: Array = []
	if value is Array:
		for entry in value:
			result.append(str(entry))
	elif value is PackedStringArray:
		for entry in value:
			result.append(str(entry))
	elif str(value) != "":
		for entry in str(value).split(",", false):
			result.append(entry.strip_edges())
	return result


static func _extract_capacity_m(line_capacity: String) -> float:
	var parts := line_capacity.split("/")
	if parts.size() < 2:
		return 120.0
	return float(parts[1].replace("м", "").strip_edges())


static func _get_retrieve_speed(gear_ratio: String) -> float:
	var parts := gear_ratio.split(":")
	var ratio_value := float(parts[0]) if parts.size() > 0 else 5.2
	return clampf(ratio_value / 5.2, 0.45, 1.45)


static func _get_wear_rate(wear_resistance: float) -> float:
	return clampf(0.011 - wear_resistance * 0.006, 0.0035, 0.012)


static func _get_rarity_for_level(required_level: int) -> String:
	if required_level >= 29:
		return "trophy"
	if required_level >= 25:
		return "epic"
	if required_level >= 18:
		return "rare"
	if required_level >= 12:
		return "uncommon"
	return "common"


static func _build_description(series: String, reel_size: int, max_drag_kg: float, compatible_methods: Array, bonus_text: String) -> String:
	return "%s %d: фрикцион %.1f кг, совместимость: %s. %s." % [
		series,
		reel_size,
		max_drag_kg,
		_get_methods_text(compatible_methods),
		bonus_text
	]


static func _get_methods_text(methods: Array) -> String:
	var labels := PackedStringArray()
	for method in methods:
		match str(method):
			"spinning":
				labels.append("спиннинг")
			"picker":
				labels.append("пикер")
			"feeder_light":
				labels.append("легкий фидер")
			"feeder":
				labels.append("фидер")
			"donka":
				labels.append("донка")
			"donka_light":
				labels.append("легкая донка")
			"donka_heavy":
				labels.append("тяжелая донка")
			"carp":
				labels.append("карп")
			"som":
				labels.append("сом")
			"sea_future":
				labels.append("море")
			_:
				labels.append(str(method))
	return ", ".join(labels)


static func _get_bonus_text(bonus_type: String, bonus_value: float) -> String:
	var label := ""
	match bonus_type:
		"starter_control":
			label = "стартовый контроль"
		"starter_power":
			label = "стартовая тяга"
		"line_safety":
			label = "защита лески"
		"sensitivity":
			label = "чувствительность"
		"cast_distance":
			label = "дальность заброса"
		"retrieve_speed":
			label = "скорость проводки"
		"active_lure_control":
			label = "контроль активных приманок"
		"drag_smoothness":
			label = "плавность фрикциона"
		"break_risk_reduction":
			label = "снижение риска обрыва"
		"fish_control":
			label = "контроль рыбы"
		"balanced_tackle":
			label = "баланс снасти"
		"durability":
			label = "прочность"
		"premium_balance":
			label = "премиальный баланс"
		"light_tackle":
			label = "легкая снасть"
		"light_feeder":
			label = "легкий фидер"
		"picker_control":
			label = "контроль пикера"
		"feeder_control":
			label = "контроль фидера"
		"long_cast":
			label = "дальний заброс"
		"river_control":
			label = "контроль на течении"
		"carp_lite":
			label = "легкий карп"
		"heavy_power":
			label = "силовая тяга"
		"trophy_power":
			label = "трофейная мощь"
		_:
			label = bonus_type.replace("_", " ")
	return "%s +%d%%" % [label, roundi(bonus_value)]
