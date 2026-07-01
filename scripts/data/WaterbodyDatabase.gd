extends Node

const STATUS_OPEN := "open"
const STATUS_BETA_OR_SOON := "beta_or_soon"
const STATUS_LOCKED := "locked"

const DEFAULT_WATERBODY_ID := "agamin_lake"
const WORLD_MAP_ASSET := "res://assets/ui/maps/world_map_tumannye_vody.png"

const REGION_AGAMIN := "Агамимский край"
const REGION_WILLOWS := "Ивовые низины"
const REGION_SILVER := "Серебряные предгорья"
const REGION_NORTH := "Северный ледовый пояс"
const REGION_SALT := "Солёное побережье"
const REGION_ARCHIPELAGO := "Полуденный архипелаг"

const AGAMIN_FISH_POOL := [
	"bleak",
	"roach",
	"rudd",
	"rotan",
	"ruffe",
	"silver_crucian",
	"golden_crucian",
	"perch",
	"white_bream",
	"skimmer_bream",
	"tench",
	"bream",
	"topmouth_gudgeon",
	"gudgeon",
	"young_chub",
	"young_pike",
	"ide",
	"young_grass_carp",
	"young_mirror_carp",
	"small_catfish",
	"frog",
	"loach",
	"goby",
	"crayfish",
	"water_turtle"
]

const OLD_WATERBODY_ID_MIGRATIONS := {
	"forest_lake": DEFAULT_WATERBODY_ID,
	"lesnoe_ozero": DEFAULT_WATERBODY_ID,
	"old_forest_lake": DEFAULT_WATERBODY_ID,
	"river_backwater": DEFAULT_WATERBODY_ID,
	"rechnaya_zavod": DEFAULT_WATERBODY_ID,
	"old_river_backwater": DEFAULT_WATERBODY_ID
}

var WATERBODIES := {
	"agamin_lake": {
		"id": "agamin_lake",
		"world_order": 1,
		"name": "Озеро Агамим",
		"region": REGION_AGAMIN,
		"status": STATUS_OPEN,
		"required_level": 1,
		"background": "calm_morning_lake",
		"map_asset": "res://assets/ui/maps/agamin_lake_map.png",
		"map_size": Vector2(2736.0, 1536.0),
		"map_zoom_scale": 0.50,
		"map_min_view_multiplier": 1.18,
		"map_controls_baked": false,
		"world_map_position": Vector2(0.462, 0.371),
		"global_map_position": Vector2(0.462, 0.371),
		"fish_pool": AGAMIN_FISH_POOL,
		"weather_modifier": 1.00,
		"depth_modifier": 1.00,
		"rare_chance_modifier": 0.88,
		"wind_profile": {
			"profile": "calm_lake",
			"base_wind_min": 0.2,
			"base_wind_max": 2.2,
			"strong_wind_weather": ["rain", "storm", "thunderstorm"],
			"gusts_allowed": true,
			"gust_chance_clear": 0.03,
			"gust_chance_rain": 0.22,
			"gust_chance_storm": 0.45,
			"description": "Агамим — спокойное озеро. Обычно ветер слабый, но во время дождя и грозы бывают резкие порывы."
		},
		"description": "Стартовое спокойное озеро средней зоны. Камыши, ряска, старые мостики и тихая вода."
	},
	"ivnitsa_river": {
		"id": "ivnitsa_river",
		"world_order": 2,
		"name": "Река Ивница",
		"region": REGION_AGAMIN,
		"status": STATUS_BETA_OR_SOON,
		"required_level": 2,
		"background": "ivnitsa_river",
		"map_asset": "",
		"map_size": Vector2(1536.0, 864.0),
		"world_map_position": Vector2(0.344, 0.439),
		"global_map_position": Vector2(0.344, 0.439),
		"fish_pool": [],
		"weather_modifier": 1.00,
		"depth_modifier": 1.00,
		"rare_chance_modifier": 1.00,
		"description": "Медленная река средней зоны. Здесь появляется течение и другая логика ловли."
	},
	"birch_pond": _future_waterbody("birch_pond", 3, "Пруд Берёзовый", REGION_AGAMIN, Vector2(0.564, 0.355), 2, "Небольшой тихий пруд у берёзовой рощи. Будущая учебная локация для спокойной ловли."),
	"foxtrail_lake": _future_waterbody("foxtrail_lake", 4, "Озеро Лисий След", REGION_AGAMIN, Vector2(0.564, 0.424), 3, "Лесное озеро с травяными берегами и осторожной рыбой. Водоём в разработке."),
	"white_oxbow": _future_waterbody("white_oxbow", 5, "Старица Белая", REGION_AGAMIN, Vector2(0.372, 0.510), 4, "Старая светлая старица с мягким течением. Будущий водоём средней зоны."),
	"whispering_willows_marsh": _future_waterbody("whispering_willows_marsh", 6, "Болото Шепчущих Ив", REGION_WILLOWS, Vector2(0.069, 0.511), 5, "Заросшее болото в ивовых низинах. Будущий водоём для тихой и осторожной рыбалки."),
	"waterlily_lake": _future_waterbody("waterlily_lake", 7, "Озеро Кувшинное", REGION_WILLOWS, Vector2(0.197, 0.501), 6, "Тёплое озеро с кувшинками, окнами чистой воды и тенистыми заводями."),
	"mossy_channel": _future_waterbody("mossy_channel", 8, "Протока Мшистая", REGION_WILLOWS, Vector2(0.239, 0.560), 7, "Узкая мшистая протока между низинными озёрами. Водоём в разработке."),
	"old_mill_dam": _future_waterbody("old_mill_dam", 9, "Старая Мельничная Запруда", REGION_WILLOWS, Vector2(0.086, 0.604), 8, "Старая запруда у разрушенной мельницы. Здесь позже появятся коряги и перепады глубины."),
	"black_backwater": _future_waterbody("black_backwater", 10, "Чёрная Заводь", REGION_WILLOWS, Vector2(0.268, 0.644), 9, "Тёмная заводь с илистым дном и редкими глубокими окнами. Будущий водоём."),
	"silverstream_river": _future_waterbody("silverstream_river", 11, "Река Серебрянка", REGION_SILVER, Vector2(0.065, 0.167), 10, "Горная река у серебряных склонов. В разработке для будущей ловли на течении."),
	"pine_basin_lake": _future_waterbody("pine_basin_lake", 12, "Озеро Сосновый Котёл", REGION_SILVER, Vector2(0.052, 0.267), 11, "Холодное озеро в сосновой чаше предгорий. Будущий водоём."),
	"white_stone_creek": _future_waterbody("white_stone_creek", 13, "Ручей Белый Камень", REGION_SILVER, Vector2(0.239, 0.189), 12, "Каменистый ручей с прозрачной водой. Водоём в разработке."),
	"mirror_cliff_lake": _future_waterbody("mirror_cliff_lake", 14, "Озеро Зеркальный Обрыв", REGION_SILVER, Vector2(0.173, 0.250), 13, "Глубокое предгорное озеро под светлым обрывом. Будущая локация."),
	"upper_rapid": _future_waterbody("upper_rapid", 15, "Верхний Порог", REGION_SILVER, Vector2(0.227, 0.266), 14, "Быстрый верхний порог с холодной водой. Будущий водоём для сильной снасти."),
	"frozen_still_lake": _future_waterbody("frozen_still_lake", 16, "Озеро Стылое", REGION_NORTH, Vector2(0.367, 0.118), 18, "Северное ледовое озеро для будущей подлёдной рыбалки."),
	"northern_polynya": _future_waterbody("northern_polynya", 17, "Северная Полынья", REGION_NORTH, Vector2(0.438, 0.154), 19, "Открытая вода среди льда. Водоём северного региона в разработке."),
	"silent_fjord": _future_waterbody("silent_fjord", 18, "Фьорд Молчаливый", REGION_NORTH, Vector2(0.520, 0.146), 20, "Холодный фьорд среди скал и льда. Будущая северная локация."),
	"nerpa_tundra_lake": _future_waterbody("nerpa_tundra_lake", 19, "Тундровое Озеро Нерпа", REGION_NORTH, Vector2(0.640, 0.129), 21, "Тундровое озеро с ледяным ветром и редкой рыбой. В разработке."),
	"harsa_ice_channel": _future_waterbody("harsa_ice_channel", 20, "Ледяная Протока Харса", REGION_NORTH, Vector2(0.679, 0.182), 22, "Узкая ледяная протока северного пояса. Будущий водоём."),
	"grey_gull_bay": _future_waterbody("grey_gull_bay", 21, "Бухта Седых Чаек", REGION_SALT, Vector2(0.814, 0.224), 23, "Солёная бухта у холодного побережья. В разработке для морской ловли."),
	"saltwind_cape": _future_waterbody("saltwind_cape", 22, "Мыс Солёный Ветер", REGION_SALT, Vector2(0.769, 0.308), 24, "Открытый мыс с резким ветром и волной. Будущий водоём."),
	"old_run_harbor": _future_waterbody("old_run_harbor", 23, "Старая Гавань Рун", REGION_SALT, Vector2(0.769, 0.387), 25, "Старая гавань с каменными причалами и солёной водой. В разработке."),
	"stone_cove": _future_waterbody("stone_cove", 24, "Каменный Залив", REGION_SALT, Vector2(0.712, 0.437), 26, "Каменистый залив солёного побережья. Будущая морская локация."),
	"black_net_strait": _future_waterbody("black_net_strait", 25, "Пролив Чёрных Сетей", REGION_SALT, Vector2(0.941, 0.460), 27, "Опасный пролив с сильной водой и старыми сетями. Водоём в разработке."),
	"warm_palm_lagoon": _future_waterbody("warm_palm_lagoon", 26, "Лагуна Тёплых Пальм", REGION_ARCHIPELAGO, Vector2(0.567, 0.664), 28, "Тёплая лагуна архипелага с прозрачной водой. Будущий тропический водоём."),
	"lumi_atoll": _future_waterbody("lumi_atoll", 27, "Атолл Луми", REGION_ARCHIPELAGO, Vector2(0.767, 0.549), 29, "Кольцевой атолл с мелководьем и рифами. В разработке."),
	"singing_wave_reef": _future_waterbody("singing_wave_reef", 28, "Риф Поющих Волн", REGION_ARCHIPELAGO, Vector2(0.815, 0.570), 30, "Риф с чистой водой и яркой морской рыбой. Будущая локация."),
	"ra_manu_island": _future_waterbody("ra_manu_island", 29, "Остров Ра-Ману", REGION_ARCHIPELAGO, Vector2(0.848, 0.634), 31, "Островная точка архипелага для будущей морской экспедиции."),
	"blue_edge_bank": _future_waterbody("blue_edge_bank", 30, "Банка Синего Края", REGION_ARCHIPELAGO, Vector2(0.930, 0.630), 32, "Дальняя банка у синей кромки моря. Водоём в разработке.")
}

func _future_waterbody(id: String, world_order: int, name: String, region: String, world_map_position: Vector2, required_level: int, description: String) -> Dictionary:
	return {
		"id": id,
		"world_order": world_order,
		"name": name,
		"region": region,
		"status": STATUS_LOCKED,
		"required_level": required_level,
		"background": "",
		"map_asset": "",
		"map_size": Vector2(1536.0, 864.0),
		"world_map_position": world_map_position,
		"global_map_position": world_map_position,
		"fish_pool": [],
		"weather_modifier": 1.0,
		"depth_modifier": 1.0,
		"rare_chance_modifier": 1.0,
		"description": description
	}

func normalize_waterbody_id(waterbody_id: String) -> String:
	var id := str(waterbody_id).strip_edges()
	if WATERBODIES.has(id):
		return id
	if OLD_WATERBODY_ID_MIGRATIONS.has(id):
		return str(OLD_WATERBODY_ID_MIGRATIONS[id])
	return DEFAULT_WATERBODY_ID

func get_migration_target(waterbody_id: String) -> String:
	var id := str(waterbody_id).strip_edges()
	return str(OLD_WATERBODY_ID_MIGRATIONS.get(id, id))

func get_waterbody(waterbody_id: String) -> Dictionary:
	var normalized_id := normalize_waterbody_id(waterbody_id)
	if not WATERBODIES.has(normalized_id):
		return {}

	return WATERBODIES[normalized_id].duplicate(true)

func get_all_waterbodies() -> Array:
	var waterbodies: Array = []

	for waterbody_id in WATERBODIES.keys():
		waterbodies.append(get_waterbody(waterbody_id))

	waterbodies.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("world_order", 999)) < int(b.get("world_order", 999))
	)

	return waterbodies

func is_unlocked(waterbody_id: String, player_level: int) -> bool:
	var normalized_id := normalize_waterbody_id(waterbody_id)
	var waterbody := get_waterbody(normalized_id)

	if waterbody.is_empty():
		return false
	if str(waterbody.get("status", STATUS_LOCKED)) != STATUS_OPEN:
		return false

	return player_level >= int(waterbody.get("required_level", 1))

func get_available_waterbody_ids(player_level: int) -> Array:
	var ids: Array = []

	for waterbody in get_all_waterbodies():
		var waterbody_id := str(waterbody.get("id", ""))
		if is_unlocked(waterbody_id, player_level):
			ids.append(waterbody_id)

	return ids

func get_fish_pool(waterbody_id: String) -> Array:
	var waterbody := get_waterbody(waterbody_id)
	var fish_pool = waterbody.get("fish_pool", [])

	if typeof(fish_pool) == TYPE_ARRAY:
		return fish_pool.duplicate()

	return []

func get_primary_spot(waterbody_id: String) -> String:
	var normalized_id := normalize_waterbody_id(waterbody_id)
	var spots := SpotDatabase.get_spots_for_waterbody(normalized_id)

	if spots.is_empty():
		return "old_oak_pier" if normalized_id == DEFAULT_WATERBODY_ID else ""

	return str(spots[0].get("id", "old_oak_pier"))

func get_fish_names(waterbody_id: String, limit: int = 5) -> String:
	var names: Array = []

	for fish_id in get_fish_pool(waterbody_id):
		var fish := FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue

		names.append(str(fish.get("name", fish_id)))
		if names.size() >= limit:
			break

	return ", ".join(names)
