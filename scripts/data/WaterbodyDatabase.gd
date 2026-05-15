extends Node

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

const WATERBODIES := {
	"agamin_lake": {
		"id": "agamin_lake",
		"name": "Озеро Агамим",
		"required_level": 1,
		"background": "calm_morning_lake",
		"fish_pool": AGAMIN_FISH_POOL,
		"weather_modifier": 1.00,
		"depth_modifier": 1.00,
		"rare_chance_modifier": 0.88,
		"description": "Стартовый спокойный водоём для маховой ловли. На разных мостиках заметно меняются глубина, активность и состав рыбы."
	},
	"forest_lake": {
		"id": "forest_lake",
		"name": "Лесное Озеро",
		"required_level": 3,
		"background": "forest_lake",
		"fish_pool": ["roach", "rotan", "ruffe", "perch", "silver_crucian", "golden_crucian", "tench", "pike"],
		"weather_modifier": 0.96,
		"depth_modifier": 1.08,
		"rare_chance_modifier": 1.18,
		"description": "Тихое лесное озеро с активным окунем и первой щукой. Требует более уверенной снасти."
	},
	"river_backwater": {
		"id": "river_backwater",
		"name": "Речная Заводь",
		"required_level": 5,
		"background": "deep_backwater",
		"fish_pool": ["rotan", "ruffe", "perch", "pike", "bream", "zander", "eel", "catfish", "mist_carp", "moon_catfish"],
		"weather_modifier": 0.90,
		"depth_modifier": 1.18,
		"rare_chance_modifier": 1.55,
		"description": "Глубокая заводь с сильной рыбой и редкими видами. Ошибки со снастью здесь стоят дорого."
	}
}

func get_waterbody(waterbody_id: String) -> Dictionary:
	if not WATERBODIES.has(waterbody_id):
		return {}

	return WATERBODIES[waterbody_id].duplicate(true)

func get_all_waterbodies() -> Array:
	var waterbodies: Array = []

	for waterbody_id in WATERBODIES.keys():
		waterbodies.append(get_waterbody(waterbody_id))

	waterbodies.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("required_level", 1)) < int(b.get("required_level", 1))
	)

	return waterbodies

func is_unlocked(waterbody_id: String, player_level: int) -> bool:
	var waterbody := get_waterbody(waterbody_id)

	if waterbody.is_empty():
		return false

	return player_level >= int(waterbody.get("required_level", 1))

func get_available_waterbody_ids(player_level: int) -> Array:
	var ids: Array = []

	for waterbody in get_all_waterbodies():
		if player_level >= int(waterbody.get("required_level", 1)):
			ids.append(str(waterbody.get("id", "")))

	return ids

func get_fish_pool(waterbody_id: String) -> Array:
	var waterbody := get_waterbody(waterbody_id)
	var fish_pool = waterbody.get("fish_pool", [])

	if typeof(fish_pool) == TYPE_ARRAY:
		return fish_pool.duplicate()

	return []

func get_primary_spot(waterbody_id: String) -> String:
	var spots := SpotDatabase.get_spots_for_waterbody(waterbody_id)

	if spots.is_empty():
		return "old_oak_pier"

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
