extends RefCounted

const ICON_BASE_PATH := "res://assets/ui/shop/spinning/lures/"

const IDX_ID := 0
const IDX_NAME := 1
const IDX_BRAND := 2
const IDX_SERIES := 3
const IDX_DISPLAY_TYPE := 4
const IDX_LURE_TYPE := 5
const IDX_WEIGHT_G := 6
const IDX_SIZE_MM := 7
const IDX_COLOR_NAME := 8
const IDX_COLOR_STYLE := 9
const IDX_REQUIRED_LEVEL := 10
const IDX_RARITY := 11
const IDX_PRICE := 12
const IDX_DURABILITY_POINTS := 13
const IDX_WEAR_PER_CAST := 14
const IDX_BONUS_TYPE := 15
const IDX_BONUS_VALUE := 16
const IDX_BONUS_TEXT := 17
const IDX_TARGET_FISH := 18
const IDX_DEPTH_TYPE := 19
const IDX_ICON_FILE := 20

const RAW_LURES := [
	["riverline_spin_2_silver_flash", "RiverLine Spin 2 Silver Flash", "RiverLine", "RiverLine Spin", "Вращающаяся блесна", "spinner", 2.0, 25, "серебро, блеск", "Silver Flash", 2, "common", 25, 85, 1.00, "target_fish", 0.03, "+3% шанс поклёвки окуня", "окунь, мелкий хищник", "малая глубина", "RiverLine_Spin_2-Silver Flash.png"],
	["riverline_spin_3_pearl_dot", "RiverLine Spin 3 Pearl Dot", "RiverLine", "RiverLine Spin", "Вращающаяся блесна", "spinner", 3.0, 28, "белый/серебро, точки", "Pearl Dot", 2, "common", 30, 85, 1.00, "water_condition", 0.03, "+3% в чистой воде", "окунь, форель", "малая глубина", "RiverLine_Spin_3-Pearl Dot.png"],
	["riverline_spin_4_gold_bee", "RiverLine Spin 4 Gold Bee", "RiverLine", "RiverLine Spin", "Вращающаяся блесна", "spinner", 4.0, 32, "золото, полосы", "Gold Bee", 3, "common", 38, 90, 1.00, "weather", 0.04, "+4% в пасмурную погоду", "окунь, голавль", "малая глубина", "RiverLine_Spin_4-Gold Bee.png"],
	["riverline_spin_5_copper_sun", "RiverLine Spin 5 Copper Sun", "RiverLine", "RiverLine Spin", "Вращающаяся блесна", "spinner", 5.0, 35, "медь, солнце", "Copper Sun", 4, "common", 48, 95, 1.00, "time", 0.04, "+4% на рассвете и закате", "окунь, щука-травянка", "малая глубина", "RiverLine_Spin_5-Copper Sun.png"],
	["riverline_spin_6_red_tail", "RiverLine Spin 6 Red Tail", "RiverLine", "RiverLine Spin", "Вращающаяся блесна", "spinner", 6.0, 38, "серебро, красный хвост", "Red Tail", 5, "common", 58, 100, 1.00, "target_fish", 0.05, "+5% по активной щуке", "окунь, щука", "средняя глубина", "RiverLine_Spin_6-Red_Tail.png"],
	["riverline_spin_8_acid_dot", "RiverLine Spin 8 Acid Dot", "RiverLine", "RiverLine Spin", "Вращающаяся блесна", "spinner", 8.0, 42, "кислотный, точка", "Acid Dot", 7, "uncommon", 78, 105, 0.95, "water_condition", 0.06, "+6% в мутной воде", "окунь, щука", "средняя глубина", "RiverLine_Spin_8-Acid_Dot.png"],
	["riverline_spin_10_black_fury", "RiverLine Spin 10 Black Fury", "RiverLine", "RiverLine Spin", "Вращающаяся блесна", "spinner", 10.0, 46, "чёрный, яркое пятно", "Black Fury", 9, "uncommon", 98, 115, 0.90, "weather", 0.07, "+7% в ветреную погоду", "крупный окунь, щука", "средняя глубина", "RiverLine_Spin_10-Black_Fury.png"],
	["riverline_spin_12_blue_spark", "RiverLine Spin 12 Blue Spark", "RiverLine", "RiverLine Spin", "Вращающаяся блесна", "spinner", 12.0, 50, "синий, искра", "Blue Spark", 11, "uncommon", 120, 120, 0.90, "target_fish", 0.08, "+8% по хищнику на бровке", "щука, судак", "средняя глубина", "RiverLine_Spin_12-Blue_Spark.png"],

	["lakepro_spoon_7_silver_scale", "LakePro Spoon 7 Silver Scale", "LakePro", "LakePro Spoon", "Колеблющаяся блесна", "spoon", 7.0, 45, "серебро, чешуя", "Silver Scale", 4, "common", 65, 110, 0.90, "target_fish", 0.05, "+5% по окуню и щуке", "окунь, щука", "малая глубина", "LakePro_Spoon_7-Silver_Scale.png"],
	["lakepro_spoon_9_gold_flame", "LakePro Spoon 9 Gold Flame", "LakePro", "LakePro Spoon", "Колеблющаяся блесна", "spoon", 9.0, 50, "золото, пламя", "Gold Flame", 5, "common", 82, 115, 0.90, "weather", 0.06, "+6% в пасмурный день", "окунь, щука", "средняя глубина", "LakePro_Spoon_9-Gold_Flame.png"],
	["lakepro_spoon_11_copper_lake", "LakePro Spoon 11 Copper Lake", "LakePro", "LakePro Spoon", "Колеблющаяся блесна", "spoon", 11.0, 55, "медь, озеро", "Copper Lake", 7, "uncommon", 105, 125, 0.85, "water_condition", 0.07, "+7% в тёмной воде", "щука, голавль", "средняя глубина", "LakePro_Spoon_11-Copper_Lake.png"],
	["lakepro_spoon_14_green_flash", "LakePro Spoon 14 Green Flash", "LakePro", "LakePro Spoon", "Колеблющаяся блесна", "spoon", 14.0, 60, "зелёный, вспышка", "Green Flash", 9, "uncommon", 135, 135, 0.85, "target_fish", 0.08, "+8% по щуке у травы", "щука, крупный окунь", "средняя глубина", "LakePro_Spoon_14-Green_Flash.png"],
	["lakepro_spoon_18_blue_mirror", "LakePro Spoon 18 Blue Mirror", "LakePro", "LakePro Spoon", "Колеблющаяся блесна", "spoon", 18.0, 70, "синий, зеркало", "Blue Mirror", 12, "uncommon", 180, 150, 0.80, "water_condition", 0.09, "+9% в прозрачной воде", "судак, щука", "средняя глубина", "LakePro_Spoon_18-Blue_Mirror.png"],
	["lakepro_spoon_22_red_belly", "LakePro Spoon 22 Red Belly", "LakePro", "LakePro Spoon", "Колеблющаяся блесна", "spoon", 22.0, 78, "красное брюхо", "Red Belly", 14, "rare", 240, 165, 0.75, "target_fish", 0.10, "+10% по крупной щуке", "крупная щука, судак", "средняя глубина", "LakePro_Spoon_22-Red_Belly.png"],
	["lakepro_spoon_28_trophy_gold", "LakePro Spoon 28 Trophy Gold", "LakePro", "LakePro Spoon", "Колеблющаяся блесна", "spoon", 28.0, 88, "трофейное золото", "Trophy Gold", 16, "rare", 310, 185, 0.70, "target_fish", 0.12, "+12% по трофейной щуке", "трофейная щука", "большая глубина", "LakePro_Spoon_28-Trophy_Gold.png"],

	["predatorx_minnow_50_natural_fry", "PredatorX Minnow 50 Natural Fry", "PredatorX", "PredatorX Minnow", "Воблер", "wobbler", 5.0, 50, "натуральный малёк", "Natural Fry", 5, "common", 90, 120, 0.90, "target_fish", 0.05, "+5% по окуню", "окунь, мелкий хищник", "малая глубина", "PredatorX_Minnow_50-Natural_Fry.png"],
	["predatorx_minnow_55_pearl_shad", "PredatorX Minnow 55 Pearl Shad", "PredatorX", "PredatorX Minnow", "Воблер", "wobbler", 6.0, 55, "перламутровая уклейка", "Pearl Shad", 6, "common", 105, 125, 0.85, "water_condition", 0.06, "+6% в прозрачной воде", "окунь, голавль", "малая глубина", "PredatorX_Minnow_55-Pearl_Shad.png"],
	["predatorx_minnow_65_perch_skin", "PredatorX Minnow 65 Perch Skin", "PredatorX", "PredatorX Minnow", "Воблер", "wobbler", 8.0, 65, "окунёвая расцветка", "Perch Skin", 8, "uncommon", 140, 135, 0.80, "target_fish", 0.08, "+8% по щуке на окуня", "щука, крупный окунь", "средняя глубина", "PredatorX_Minnow_65-Perch_Skin.png"],
	["predatorx_minnow_70_red_head", "PredatorX Minnow 70 Red Head", "PredatorX", "PredatorX Minnow", "Воблер", "wobbler", 9.0, 70, "красная голова", "Red Head", 10, "uncommon", 170, 145, 0.80, "target_fish", 0.09, "+9% по щуке", "щука", "средняя глубина", "PredatorX_Minnow_70-Red_Head.png"],
	["predatorx_minnow_80_fire_tiger", "PredatorX Minnow 80 Fire Tiger", "PredatorX", "PredatorX Minnow", "Воблер", "wobbler", 12.0, 80, "огненный тигр", "Fire Tiger", 12, "uncommon", 220, 155, 0.75, "water_condition", 0.10, "+10% в мутной воде", "щука, судак", "средняя глубина", "PredatorX_Minnow_80-Fire_Tiger.png"],
	["predatorx_minnow_90_blue_back", "PredatorX Minnow 90 Blue Back", "PredatorX", "PredatorX Minnow", "Воблер", "wobbler", 15.0, 90, "синяя спина", "Blue Back", 14, "rare", 280, 170, 0.72, "weather", 0.10, "+10% в ясную погоду", "судак, щука", "средняя глубина", "PredatorX_Minnow_90-Blue_Back.png"],
	["predatorx_minnow_100_ghost_silver", "PredatorX Minnow 100 Ghost Silver", "PredatorX", "PredatorX Minnow", "Воблер", "wobbler", 18.0, 100, "призрачное серебро", "Ghost Silver", 16, "rare", 350, 185, 0.70, "target_fish", 0.12, "+12% по осторожному судаку", "судак, крупная щука", "большая глубина", "PredatorX_Minnow_100-Ghost_Silver.png"],
	["predatorx_minnow_110_pike_killer", "PredatorX Minnow 110 Pike Killer", "PredatorX", "PredatorX Minnow", "Воблер", "wobbler", 22.0, 110, "щучий убийца", "Pike Killer", 18, "rare", 450, 205, 0.68, "target_fish", 0.14, "+14% по крупной щуке", "крупная щука", "большая глубина", "PredatorX_Minnow_110-Pike_Killer.png"],
	["predatorx_minnow_125_deep_wound", "PredatorX Minnow 125 Deep Wound", "PredatorX", "PredatorX Minnow", "Воблер", "wobbler", 28.0, 125, "раненая рыба", "Deep Wound", 20, "rare", 600, 230, 0.65, "target_fish", 0.15, "+15% по глубинному хищнику", "крупная щука, судак", "большая глубина", "PredatorX_Minnow_125-Deep_Wound.png"],

	["softtail_flex_40_pearl", "SoftTail Flex 40 Pearl", "SoftTail", "SoftTail Flex", "Мягкая приманка", "soft_lure", 2.0, 40, "перламутр", "Pearl", 2, "common", 28, 70, 1.20, "target_fish", 0.03, "+3% по окуню", "окунь", "малая глубина", "SoftTail_Flex_40-Pearl.png"],
	["softtail_flex_45_clear_fry", "SoftTail Flex 45 Clear Fry", "SoftTail", "SoftTail Flex", "Мягкая приманка", "soft_lure", 3.0, 45, "прозрачный малёк", "Clear Fry", 3, "common", 35, 72, 1.15, "water_condition", 0.04, "+4% в чистой воде", "окунь, голавль", "малая глубина", "SoftTail_Flex_45-Clear_Fry.png"],
	["softtail_flex_50_motoroil", "SoftTail Flex 50 MotorOil", "SoftTail", "SoftTail Flex", "Мягкая приманка", "soft_lure", 4.0, 50, "моторное масло", "MotorOil", 4, "common", 45, 78, 1.10, "water_condition", 0.05, "+5% в тёмной воде", "окунь, судак", "средняя глубина", "SoftTail_Flex_50-MotorOil.png"],
	["softtail_flex_60_lime_chart", "SoftTail Flex 60 Lime Chart", "SoftTail", "SoftTail Flex", "Мягкая приманка", "soft_lure", 6.0, 60, "лайм, шартрез", "Lime Chart", 6, "uncommon", 70, 86, 1.05, "water_condition", 0.06, "+6% в мутной воде", "окунь, щука", "средняя глубина", "SoftTail_Flex_60-Lime_Chart.png"],
	["softtail_flex_70_blood_shad", "SoftTail Flex 70 Blood Shad", "SoftTail", "SoftTail Flex", "Мягкая приманка", "soft_lure", 8.0, 70, "кровавый шэд", "Blood Shad", 9, "uncommon", 105, 96, 1.00, "target_fish", 0.08, "+8% по судаку", "судак, щука", "средняя глубина", "SoftTail_Flex_70-Blood_Shad.png"],
	["softtail_flex_80_deep_purple", "SoftTail Flex 80 Deep Purple", "SoftTail", "SoftTail Flex", "Мягкая приманка", "soft_lure", 11.0, 80, "глубокий фиолетовый", "Deep Purple", 12, "uncommon", 150, 110, 0.95, "time", 0.09, "+9% вечером", "судак, ночной хищник", "большая глубина", "SoftTail_Flex_80-Deep_Purple.png"],
	["softtail_flex_95_black_minnow", "SoftTail Flex 95 Black Minnow", "SoftTail", "SoftTail Flex", "Мягкая приманка", "soft_lure", 16.0, 95, "чёрный малёк", "Black Minnow", 15, "rare", 230, 130, 0.85, "target_fish", 0.11, "+11% по глубинному судаку", "судак, крупная щука", "большая глубина", "SoftTail_Flex_95-Black_Minnow.png"],
	["softtail_flex_110_trophy_tail", "SoftTail Flex 110 Trophy Tail", "SoftTail", "SoftTail Flex", "Мягкая приманка", "soft_lure", 24.0, 110, "трофейный хвост", "Trophy Tail", 18, "rare", 330, 150, 0.80, "target_fish", 0.13, "+13% по трофейному хищнику", "крупная щука, судак", "большая глубина", "SoftTail_Flex_110-Trophy_Tail.png"],

	["deephunter_jig_6_pearl_fry", "DeepHunter Jig 6 Pearl Fry", "DeepHunter", "DeepHunter Jig", "Джиг", "jig", 6.0, 45, "перламутровый малёк", "Pearl Fry", 5, "common", 80, 100, 0.95, "target_fish", 0.06, "+6% по окуню на свале", "окунь, судак", "средняя глубина", "DeepHunter_Jig_6-Pearl_Fry.png"],
	["deephunter_jig_8_green_oil", "DeepHunter Jig 8 Green Oil", "DeepHunter", "DeepHunter Jig", "Джиг", "jig", 8.0, 50, "зелёное масло", "Green Oil", 6, "common", 95, 105, 0.90, "water_condition", 0.07, "+7% в тёмной воде", "окунь, судак", "средняя глубина", "DeepHunter_Jig_8-Green-Oil.png"],
	["deephunter_jig_10_orange_bite", "DeepHunter Jig 10 Orange Bite", "DeepHunter", "DeepHunter Jig", "Джиг", "jig", 10.0, 55, "оранжевая атака", "Orange Bite", 8, "uncommon", 120, 115, 0.85, "target_fish", 0.08, "+8% по судаку", "судак, щука", "средняя глубина", "DeepHunter_Jig_10-Orange_Bite.png"],
	["deephunter_jig_14_violet_deep", "DeepHunter Jig 14 Violet Deep", "DeepHunter", "DeepHunter Jig", "Джиг", "jig", 14.0, 65, "фиолетовая глубина", "Violet Deep", 11, "uncommon", 165, 130, 0.80, "time", 0.09, "+9% вечером и ночью", "судак, ночной хищник", "большая глубина", "DeepHunter_Jig_14-Violet_Deep.png"],
	["deephunter_jig_18_black_gold", "DeepHunter Jig 18 Black Gold", "DeepHunter", "DeepHunter Jig", "Джиг", "jig", 18.0, 75, "чёрное золото", "Black Gold", 14, "rare", 230, 150, 0.75, "weather", 0.10, "+10% в пасмурную погоду", "судак, щука", "большая глубина", "DeepHunter_Jig_18_Black_Gold.png"],
	["deephunter_jig_22_blue_ice", "DeepHunter Jig 22 Blue Ice", "DeepHunter", "DeepHunter Jig", "Джиг", "jig", 22.0, 85, "синий лёд", "Blue Ice", 16, "rare", 310, 170, 0.70, "target_fish", 0.12, "+12% по крупному судаку", "крупный судак, щука", "большая глубина", "DeepHunter_Jig_22-Blue_Ice.png"],
	["deephunter_jig_28_trophy_mud", "DeepHunter Jig 28 Trophy Mud", "DeepHunter", "DeepHunter Jig", "Джиг", "jig", 28.0, 95, "трофейная муть", "Trophy Mud", 19, "rare", 420, 190, 0.68, "water_condition", 0.13, "+13% у дна в мутной воде", "трофейный судак, сом", "большая глубина", "DeepHunter_Jig_28-Trophy_Mud.png"],
	["deephunter_jig_36_bottom_beast", "DeepHunter Jig 36 Bottom Beast", "DeepHunter", "DeepHunter Jig", "Джиг", "jig", 36.0, 110, "донный зверь", "Bottom Beast", 22, "epic", 520, 220, 0.62, "target_fish", 0.15, "+15% по глубинному хищнику", "крупный судак, сом", "большая глубина", "DeepHunter_Jig_36-Bottom_Beast.png"],

	["surfacestrike_pop_45_frog", "SurfaceStrike Pop 45 Frog", "SurfaceStrike", "SurfaceStrike Pop", "Поппер", "topwater", 4.0, 45, "лягушка", "Frog", 6, "common", 95, 95, 0.90, "target_fish", 0.06, "+6% по щуке у кувшинок", "щука, окунь", "поверхность", "SurfaceStrike_Pop_45-Frog.png"],
	["surfacestrike_pop_55_white_bug", "SurfaceStrike Pop 55 White Bug", "SurfaceStrike", "SurfaceStrike Pop", "Поппер", "topwater", 6.0, 55, "белый жук", "White Bug", 8, "uncommon", 130, 105, 0.85, "weather", 0.07, "+7% в тихую погоду", "окунь, голавль", "поверхность", "SurfaceStrike_Pop_55-White_Bug.png"],
	["surfacestrike_pop_60_red_head", "SurfaceStrike Pop 60 Red Head", "SurfaceStrike", "SurfaceStrike Pop", "Поппер", "topwater", 8.0, 60, "красная голова", "Red Head", 10, "uncommon", 165, 115, 0.82, "target_fish", 0.09, "+9% по щуке на мелководье", "щука", "поверхность", "SurfaceStrike_Pop_60-Red_Head.png"],
	["surfacestrike_pop_70_night_bug", "SurfaceStrike Pop 70 Night Bug", "SurfaceStrike", "SurfaceStrike Pop", "Поппер", "topwater", 11.0, 70, "ночной жук", "Night Bug", 14, "rare", 250, 135, 0.76, "time", 0.11, "+11% ночью", "ночной хищник, щука", "поверхность", "SurfaceStrike_Pop_70-Night_Bug.png"],
	["surfacestrike_pop_80_acid_splash", "SurfaceStrike Pop 80 Acid Splash", "SurfaceStrike", "SurfaceStrike Pop", "Поппер", "topwater", 15.0, 80, "кислотный всплеск", "Acid Splash", 16, "rare", 340, 155, 0.72, "water_condition", 0.12, "+12% в мутной воде", "щука, крупный окунь", "поверхность", "SurfaceStrike_Pop_80-Acid_Splash.png"],
	["surfacestrike_pop_90_trophy_frog", "SurfaceStrike Pop 90 Trophy Frog", "SurfaceStrike", "SurfaceStrike Pop", "Поппер", "topwater", 20.0, 90, "трофейная лягушка", "Trophy Frog", 19, "rare", 480, 180, 0.68, "target_fish", 0.14, "+14% по крупной щуке с поверхности", "трофейная щука", "поверхность", "SurfaceStrike_Pop_90-Trophy_Frog.png"],

	["predatorx_blade_10_white_flash", "PredatorX Blade 10 White Flash", "PredatorX", "PredatorX Blade", "Спиннербейт", "spinner_bait", 10.0, 55, "белая вспышка", "White Flash", 10, "uncommon", 170, 130, 0.80, "water_condition", 0.08, "+8% в чистой воде у травы", "щука, окунь", "малая глубина", "PredatorX_Blade_10-White_Flash.png"],
	["predatorx_blade_12_fire_skirt", "PredatorX Blade 12 Fire Skirt", "PredatorX", "PredatorX Blade", "Спиннербейт", "spinner_bait", 12.0, 60, "огненная юбка", "Fire Skirt", 12, "uncommon", 210, 140, 0.78, "target_fish", 0.10, "+10% по щуке в окнах травы", "щука", "малая глубина", "PredatorX_Blade_12-Fire_Skirt.png"],
	["predatorx_blade_16_green_mud", "PredatorX Blade 16 Green Mud", "PredatorX", "PredatorX Blade", "Спиннербейт", "spinner_bait", 16.0, 70, "зелёная муть", "Green Mud", 14, "rare", 280, 155, 0.75, "water_condition", 0.11, "+11% в мутной воде", "щука, крупный окунь", "средняя глубина", "PredatorX_Blade_16-Green_Mud.png"],
	["predatorx_blade_20_gold_leaf", "PredatorX Blade 20 Gold Leaf", "PredatorX", "PredatorX Blade", "Спиннербейт", "spinner_bait", 20.0, 80, "золотой лист", "Gold Leaf", 17, "rare", 390, 175, 0.70, "weather", 0.12, "+12% в пасмурную погоду", "крупная щука", "средняя глубина", "PredatorX_Blade_20-Gold_Leaf.png"],
	["predatorx_blade_26_trophy_black", "PredatorX Blade 26 Trophy Black", "PredatorX", "PredatorX Blade", "Спиннербейт", "spinner_bait", 26.0, 95, "трофейный чёрный", "Trophy Black", 19, "rare", 520, 200, 0.66, "target_fish", 0.14, "+14% по трофейной щуке у коряг", "трофейная щука", "средняя глубина", "PredatorX_Blade_26-Trophy_Black.png"],

	["nightglow_spin_6_moon_dot", "NightGlow Spin 6 Moon Dot", "NightGlow", "NightGlow", "Вращающаяся блесна", "spinner", 6.0, 38, "лунная точка", "Moon Dot", 14, "rare", 420, 145, 0.72, "time", 0.12, "+12% ночью", "ночной хищник, окунь", "средняя глубина", "NightGlow_Spin_6-Moon_Dot.png"],
	["nightglow_spoon_14_blue_moon", "NightGlow Spoon 14 Blue Moon", "NightGlow", "NightGlow", "Колеблющаяся блесна", "spoon", 14.0, 64, "синяя луна", "Blue Moon", 15, "rare", 500, 165, 0.70, "time", 0.13, "+13% ночью на глубине", "ночная щука, судак", "большая глубина", "NightGlow_Spoon_14-Blue_Moon.png"],
	["nightglow_minnow_80_ghost_night", "NightGlow Minnow 80 Ghost Night", "NightGlow", "NightGlow", "Воблер", "wobbler", 12.0, 80, "ночной призрак", "Ghost Night", 16, "rare", 560, 175, 0.68, "time", 0.14, "+14% ночью по судаку", "ночной судак, щука", "средняя глубина", "NightGlow_Minnow_80-Ghost_Night.png"],
	["nightglow_jig_18_purple_lamp", "NightGlow Jig 18 Purple Lamp", "NightGlow", "NightGlow", "Джиг", "jig", 18.0, 78, "фиолетовая лампа", "Purple Lamp", 17, "rare", 650, 185, 0.66, "time", 0.15, "+15% ночью у дна", "ночной судак, сом", "большая глубина", "NightGlow_Jig_18-Purple_Lamp.png"],

	["trophymax_spoon_32_king_pike", "TrophyMax Spoon 32 King Pike", "TrophyMax", "TrophyMax", "Колеблющаяся блесна", "spoon", 32.0, 95, "королевская щука", "King Pike", 20, "epic", 900, 230, 0.62, "target_fish", 0.15, "+15% по трофейной щуке", "трофейная щука", "большая глубина", "TrophyMax_Spoon_32-King_Pike.png"],
	["trophymax_blade_38_black_crown", "TrophyMax Blade 38 Black Crown", "TrophyMax", "TrophyMax", "Спиннербейт", "spinner_bait", 38.0, 110, "чёрная корона", "Black Crown", 22, "epic", 1050, 245, 0.60, "target_fish", 0.16, "+16% по крупной щуке в траве", "трофейная щука", "средняя глубина", "TrophyMax_Blade_38-Black_Crown.png"],
	["trophymax_jig_42_deep_monster", "TrophyMax Jig 42 Deep Monster", "TrophyMax", "TrophyMax", "Джиг", "jig", 42.0, 120, "глубинный монстр", "Deep Monster", 24, "epic", 1200, 255, 0.58, "target_fish", 0.17, "+17% по самому глубокому хищнику", "трофейный судак, сом", "большая глубина", "TrophyMax_Jig_42-Deep_Monster.png"],
	["trophymax_minnow_130_big_hunter", "TrophyMax Minnow 130 Big Hunter", "TrophyMax", "TrophyMax", "Воблер", "wobbler", 34.0, 130, "большой охотник", "Big Hunter", 26, "epic", 1350, 270, 0.56, "target_fish", 0.17, "+17% по большой щуке", "самый крупный хищник", "большая глубина", "TrophyMax_Minnow_130-Big_Hunter.png"],
	["trophymax_minnow_150_final_bite", "TrophyMax Minnow 150 Final Bite", "TrophyMax", "TrophyMax", "Воблер", "wobbler", 48.0, 150, "раненая рыба, премиум", "Final Bite", 28, "epic", 1500, 280, 0.54, "target_fish", 0.18, "+18% по самому крупному хищнику", "самый крупный хищник", "большая глубина", "TrophyMax_Minnow_150-Final_Bite.png"]
]

const PACK_DEFINITIONS := [
	{
		"id": "spinning_starter_lure_pack",
		"name": "Стартовый набор спиннингиста",
		"rarity": "common",
		"required_level": 8,
		"price": 95,
		"item_ids": ["riverline_spin_2_silver_flash", "riverline_spin_4_gold_bee", "softtail_flex_40_pearl", "softtail_flex_50_motoroil"]
	},
	{
		"id": "first_predator_lure_pack",
		"name": "Первый хищник",
		"rarity": "common",
		"required_level": 8,
		"price": 240,
		"item_ids": ["riverline_spin_6_red_tail", "lakepro_spoon_9_gold_flame", "predatorx_minnow_50_natural_fry", "deephunter_jig_6_pearl_fry"]
	},
	{
		"id": "grass_pike_lure_pack",
		"name": "Щука у травы",
		"rarity": "uncommon",
		"required_level": 10,
		"price": 590,
		"item_ids": ["predatorx_minnow_70_red_head", "surfacestrike_pop_60_red_head", "predatorx_blade_10_white_flash", "riverline_spin_10_black_fury"]
	},
	{
		"id": "night_hunt_lure_pack",
		"name": "Ночная охота",
		"rarity": "rare",
		"required_level": 14,
		"price": 990,
		"item_ids": ["nightglow_spin_6_moon_dot", "nightglow_spoon_14_blue_moon", "nightglow_minnow_80_ghost_night", "nightglow_jig_18_purple_lamp"]
	},
	{
		"id": "trophy_pike_lure_pack",
		"name": "Трофейная щука",
		"rarity": "epic",
		"required_level": 20,
		"price": 2200,
		"item_ids": ["trophymax_spoon_32_king_pike", "trophymax_minnow_130_big_hunter", "predatorx_blade_26_trophy_black", "surfacestrike_pop_90_trophy_frog"]
	}
]

static func get_lure_catalog() -> Dictionary:
	var catalog: Dictionary = {}
	for row in RAW_LURES:
		var item := _build_lure_item(row)
		catalog[str(item.get("id", ""))] = item
	return catalog


static func get_lure_packs() -> Array:
	var catalog := get_lure_catalog()
	var packs: Array = []
	for pack_def in PACK_DEFINITIONS:
		var item_ids: Array = (pack_def.get("item_ids", []) as Array).duplicate()
		var item_names := PackedStringArray()
		var icon_path := ""
		for item_id_value in item_ids:
			var item_id := str(item_id_value)
			var lure: Dictionary = catalog.get(item_id, {})
			if lure.is_empty():
				continue
			item_names.append(str(lure.get("name", item_id)))
			if icon_path == "":
				icon_path = str(lure.get("icon_path", lure.get("image_path", "")))

		var required_level := int(pack_def.get("required_level", 1))
		var stats := {
			"required_level": required_level,
			"level_required": required_level,
			"pack_item_ids": item_ids,
			"pack_item_names": item_names
		}
		packs.append({
			"id": str(pack_def.get("id", "")),
			"name": str(pack_def.get("name", "")),
			"display_name_ru": str(pack_def.get("name", "")),
			"type": "lure_pack",
			"category": "lure_pack",
			"shop_category": "lure",
			"rarity": str(pack_def.get("rarity", "common")),
			"price": float(pack_def.get("price", 0.0)),
			"quantity": 1,
			"required_level": required_level,
			"level_required": required_level,
			"pack_item_ids": item_ids,
			"image_path": icon_path,
			"icon_path": icon_path,
			"icon": "P",
			"description": "Набор готовых спиннинговых приманок: %s." % ", ".join(item_names),
			"description_ru": "Набор готовых спиннинговых приманок: %s." % ", ".join(item_names),
			"stats": stats
		})
	return packs


static func _build_lure_item(row: Array) -> Dictionary:
	var item_id := str(row[IDX_ID])
	var lure_type := str(row[IDX_LURE_TYPE])
	var weight_g := float(row[IDX_WEIGHT_G])
	var size_mm := int(row[IDX_SIZE_MM])
	var required_level := int(row[IDX_REQUIRED_LEVEL])
	var durability_points := float(row[IDX_DURABILITY_POINTS])
	var wear_per_cast := float(row[IDX_WEAR_PER_CAST])
	var bonus_type := str(row[IDX_BONUS_TYPE])
	var bonus_value := float(row[IDX_BONUS_VALUE])
	var target_fish_text := str(row[IDX_TARGET_FISH])
	var target_ids := _get_target_fish_ids(target_fish_text, lure_type, required_level)
	var secondary_ids := _get_secondary_fish_ids(target_ids, lure_type)
	var icon_path := ICON_BASE_PATH + str(row[IDX_ICON_FILE])
	var stats := _build_lure_stats(row, target_ids, secondary_ids)
	var description := "%s %s г, %d мм. Цвет: %s. Горизонт: %s. %s" % [
		str(row[IDX_DISPLAY_TYPE]),
		_format_decimal(weight_g),
		size_mm,
		str(row[IDX_COLOR_NAME]),
		str(row[IDX_DEPTH_TYPE]),
		str(row[IDX_BONUS_TEXT])
	]

	return {
		"id": item_id,
		"name": str(row[IDX_NAME]),
		"display_name_ru": str(row[IDX_NAME]),
		"brand": str(row[IDX_BRAND]),
		"series": str(row[IDX_SERIES]),
		"type": "lure",
		"category": "lure",
		"display_type": str(row[IDX_DISPLAY_TYPE]),
		"lure_type": lure_type,
		"weight_g": weight_g,
		"size_mm": size_mm,
		"color_name": str(row[IDX_COLOR_NAME]),
		"color_style": str(row[IDX_COLOR_STYLE]),
		"required_level": required_level,
		"level_required": required_level,
		"rarity": str(row[IDX_RARITY]),
		"price": float(row[IDX_PRICE]),
		"durability": 1.0,
		"durability_points": durability_points,
		"wear_per_cast": wear_per_cast,
		"bonus_type": bonus_type,
		"bonus_value": bonus_value,
		"bonus_text": str(row[IDX_BONUS_TEXT]),
		"target_fish": target_fish_text,
		"depth_type": str(row[IDX_DEPTH_TYPE]),
		"water_condition_bonus": _conditional_bonus(bonus_type, "water_condition", bonus_value),
		"weather_bonus": _conditional_bonus(bonus_type, "weather", bonus_value),
		"time_bonus": _conditional_bonus(bonus_type, "time", bonus_value),
		"icon_path": icon_path,
		"image_path": icon_path,
		"description": description,
		"description_ru": description,
		"stats": stats
	}


static func _build_lure_stats(row: Array, target_ids: Array, secondary_ids: Array) -> Dictionary:
	var lure_type := str(row[IDX_LURE_TYPE])
	var weight_g := float(row[IDX_WEIGHT_G])
	var size_mm := int(row[IDX_SIZE_MM])
	var required_level := int(row[IDX_REQUIRED_LEVEL])
	var durability_points := float(row[IDX_DURABILITY_POINTS])
	var wear_per_cast := float(row[IDX_WEAR_PER_CAST])
	var bonus_type := str(row[IDX_BONUS_TYPE])
	var bonus_value := float(row[IDX_BONUS_VALUE])
	var rarity := str(row[IDX_RARITY])
	var fish_attraction_by_id := _build_fish_attraction_by_id(target_ids, secondary_ids, bonus_value)
	var wear_rate := clampf(wear_per_cast / maxf(durability_points, 1.0), 0.001, 0.040)

	return {
		"id": str(row[IDX_ID]),
		"bait_id": str(row[IDX_ID]),
		"bait_type": "lure",
		"lure_type": lure_type,
		"display_lure_type": str(row[IDX_DISPLAY_TYPE]),
		"weight": weight_g,
		"weight_g": weight_g,
		"size_mm": size_mm,
		"color_name": str(row[IDX_COLOR_NAME]),
		"color_style": str(row[IDX_COLOR_STYLE]),
		"required_level": required_level,
		"level_required": required_level,
		"rarity": rarity,
		"durability": 1.0,
		"durability_points": durability_points,
		"wear_per_cast": wear_per_cast,
		"wear_rate": wear_rate,
		"bonus_type": bonus_type,
		"bonus_value": bonus_value,
		"bonus_text": str(row[IDX_BONUS_TEXT]),
		"target_fish": str(row[IDX_TARGET_FISH]),
		"target_fish_ids": target_ids,
		"secondary_fish_ids": secondary_ids,
		"fish_attraction": clampf(0.035 + bonus_value * 0.28, 0.03, 0.08),
		"fish_attraction_by_id": fish_attraction_by_id,
		"allowed_rarities": _get_allowed_rarities(required_level, rarity),
		"bait_tags": _get_lure_tags(lure_type, str(row[IDX_COLOR_STYLE]), bonus_type, rarity, str(row[IDX_DEPTH_TYPE])),
		"depth_type": str(row[IDX_DEPTH_TYPE]),
		"water_condition_bonus": _conditional_bonus(bonus_type, "water_condition", bonus_value),
		"weather_bonus": _conditional_bonus(bonus_type, "weather", bonus_value),
		"time_bonus": _conditional_bonus(bonus_type, "time", bonus_value),
		"hook_size": _get_hook_size_for_lure(weight_g, size_mm),
		"hook_chance": clampf(0.08 + bonus_value * 0.45 + float(size_mm) * 0.00035, 0.08, 0.22),
		"hook_strength": clampf(0.82 + weight_g * 0.028 + bonus_value * 0.8, 0.85, 2.20),
		"fish_escape_modifier": clampf(1.04 - bonus_value * 0.65 - weight_g * 0.004, 0.72, 1.04),
		"target_fish_size": _get_target_size(weight_g, required_level)
	}


static func _conditional_bonus(bonus_type: String, expected_type: String, bonus_value: float) -> float:
	return bonus_value if bonus_type == expected_type else 0.0


static func _get_target_fish_ids(target_text: String, lure_type: String, required_level: int) -> Array:
	var ids: Array = []
	var text := target_text.to_lower()
	if text.find("окун") != -1:
		_add_unique(ids, "perch")
	if text.find("голав") != -1 or text.find("форел") != -1:
		_add_unique(ids, "young_chub")
	if text.find("щук") != -1:
		_add_unique(ids, "young_pike")
		_add_unique(ids, "pike")
	if text.find("суда") != -1:
		_add_unique(ids, "zander")
	if text.find("сом") != -1:
		_add_unique(ids, "small_catfish")
		_add_unique(ids, "catfish")
	if text.find("ноч") != -1:
		_add_unique(ids, "zander")
		_add_unique(ids, "moon_catfish")
		_add_unique(ids, "catfish")
	if text.find("круп") != -1 or text.find("троф") != -1 or required_level >= 18:
		_add_unique(ids, "pike")
		_add_unique(ids, "zander")
	if text.find("хищ") != -1:
		_add_unique(ids, "perch")
		_add_unique(ids, "young_pike")
		_add_unique(ids, "pike")
		_add_unique(ids, "zander")

	if ids.is_empty():
		match lure_type:
			"jig":
				ids = ["perch", "zander", "pike"]
			"topwater":
				ids = ["perch", "young_pike", "pike"]
			_:
				ids = ["perch", "young_pike", "pike", "zander"]
	return ids


static func _get_secondary_fish_ids(target_ids: Array, lure_type: String) -> Array:
	var secondary := ["perch", "young_pike", "pike", "zander", "young_chub", "ide", "small_catfish"]
	if lure_type == "topwater":
		secondary = ["perch", "young_pike", "pike", "young_chub", "ide"]
	elif lure_type == "jig":
		secondary = ["perch", "zander", "pike", "small_catfish", "catfish"]
	for fish_id in target_ids:
		secondary.erase(str(fish_id))
	return secondary


static func _build_fish_attraction_by_id(target_ids: Array, secondary_ids: Array, bonus_value: float) -> Dictionary:
	var attraction: Dictionary = {}
	for i in range(target_ids.size()):
		var fish_id := str(target_ids[i])
		attraction[fish_id] = clampf(0.20 + bonus_value + maxf(0.04 - float(i) * 0.01, 0.0), 0.12, 0.42)
	for i in range(secondary_ids.size()):
		var fish_id := str(secondary_ids[i])
		attraction[fish_id] = clampf(0.11 + bonus_value * 0.45 - float(i) * 0.005, 0.06, 0.22)
	return attraction


static func _get_lure_tags(lure_type: String, color_style: String, bonus_type: String, rarity: String, depth_type: String) -> Array:
	var tags: Array = ["lure", "predator", "moving"]
	match lure_type:
		"spinner", "spoon", "spinner_bait":
			tags.append("metal")
		"wobbler":
			tags.append("hard_bait")
		"soft_lure", "jig":
			tags.append("soft")
		"topwater":
			tags.append("surface")
	if lure_type == "jig" or depth_type == "большая глубина":
		tags.append("deep")
	if depth_type == "поверхность":
		tags.append("surface")
	if bonus_type == "time" or color_style.to_lower().find("night") != -1:
		tags.append("night")
	if rarity == "rare" or rarity == "epic":
		tags.append("premium")
	if color_style.to_lower().find("trophy") != -1 or rarity == "epic":
		tags.append("trophy")
	return tags


static func _get_allowed_rarities(required_level: int, rarity: String) -> Array:
	var allowed := ["common", "uncommon", "rare"]
	if required_level >= 12 or rarity == "rare" or rarity == "epic":
		allowed.append("very_rare")
	if required_level >= 20 or rarity == "epic":
		allowed.append("legendary")
	return allowed


static func _get_hook_size_for_lure(weight_g: float, size_mm: int) -> int:
	if weight_g >= 34.0 or size_mm >= 125:
		return 2
	if weight_g >= 24.0 or size_mm >= 100:
		return 4
	if weight_g >= 14.0 or size_mm >= 80:
		return 6
	if weight_g >= 8.0 or size_mm >= 60:
		return 8
	if weight_g >= 4.0:
		return 10
	return 12


static func _get_target_size(weight_g: float, required_level: int) -> String:
	if required_level >= 20 or weight_g >= 32.0:
		return "trophy"
	if required_level >= 14 or weight_g >= 18.0:
		return "large"
	if required_level >= 8 or weight_g >= 8.0:
		return "medium"
	return "small"


static func _format_decimal(value: float) -> String:
	if is_equal_approx(value, float(roundi(value))):
		return str(roundi(value))
	return "%.1f" % value


static func _add_unique(values: Array, value: String) -> void:
	if not values.has(value):
		values.append(value)
