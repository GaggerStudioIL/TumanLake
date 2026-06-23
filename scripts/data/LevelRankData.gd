extends RefCounted

const RANKS := [
	{
		"id": "rank_01",
		"max_level": 15,
		"icon": preload("res://assets/ui/ux/fishing_spot/level_ranks/level_rank_01.png")
	},
	{
		"id": "rank_02",
		"max_level": 29,
		"icon": preload("res://assets/ui/ux/fishing_spot/level_ranks/level_rank_02.png")
	},
	{
		"id": "rank_03",
		"max_level": 38,
		"icon": preload("res://assets/ui/ux/fishing_spot/level_ranks/level_rank_03.png")
	},
	{
		"id": "rank_04",
		"max_level": 47,
		"icon": preload("res://assets/ui/ux/fishing_spot/level_ranks/level_rank_04.png")
	},
	{
		"id": "rank_05",
		"max_level": 55,
		"icon": preload("res://assets/ui/ux/fishing_spot/level_ranks/level_rank_05.png")
	},
	{
		"id": "rank_06",
		"max_level": 65,
		"icon": preload("res://assets/ui/ux/fishing_spot/level_ranks/level_rank_06.png")
	},
	{
		"id": "master",
		"max_level": 100,
		"icon": preload("res://assets/ui/ux/fishing_spot/level_ranks/level_rank_master.png")
	}
]


static func get_rank_index(for_level: int) -> int:
	var normalized_level: int = max(for_level, 1)
	for index in range(RANKS.size()):
		if normalized_level <= int(RANKS[index].get("max_level", 100)):
			return index
	return RANKS.size() - 1


static func get_rank_id_for_level(for_level: int) -> String:
	return str(RANKS[get_rank_index(for_level)].get("id", "rank_01"))


static func get_icon_for_level(for_level: int) -> Texture2D:
	return RANKS[get_rank_index(for_level)].get("icon") as Texture2D
