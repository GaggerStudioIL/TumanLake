extends Node

const SAVE_PATH := "user://save_game.json"

func save_game() -> void:
	var save_data := {
		"money": PlayerData.money,
		"level": PlayerData.level,
		"current_xp": PlayerData.current_xp,
		"xp": PlayerData.current_xp,
		"xp_to_next_level": PlayerData.xp_to_next_level,
		"skill_points": PlayerData.skill_points,
		"learned_skills": PlayerData.learned_skills,
		"player_name": PlayerData.player_name,
		"total_fish_caught": PlayerData.total_fish_caught,
		"total_trophies_caught": PlayerData.total_trophies_caught,
		"total_rarity_caught": PlayerData.total_rarity_caught,
		"biggest_fish": PlayerData.biggest_fish,
		"biggest_fish_by_species": PlayerData.biggest_fish_by_species,
		"trophy_catches": PlayerData.trophy_catches,
		"personal_records": PlayerData.personal_records,
		"rescue_kit_claims_total": PlayerData.rescue_kit_claims_total,
		"rescue_kit_last_claim_day": PlayerData.rescue_kit_last_claim_day,
		"current_waterbody": PlayerData.current_waterbody,
		"unlocked_waterbodies": PlayerData.unlocked_waterbodies,
		"current_spot": PlayerData.current_spot,
		"unlocked_spots": PlayerData.unlocked_spots,
		"upgrades": PlayerData.upgrades,
		"fishing_depth": PlayerData.fishing_depth,
		"owned_items": PlayerData.owned_items,
		"current_tackle": PlayerData.current_tackle,
		"inventory": InventoryManager.inventory,
		"max_items": InventoryManager.max_items,
		"current_game_minutes": _get_time_value("current_game_minutes", 460.0),
		"day_index": int(_get_time_value("day_index", 1.0))
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Save failed")
		return

	file.store_string(JSON.stringify(save_data))
	file.close()

	print("Game saved")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file yet")
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("Load failed")
		return

	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(text)

	if error != OK:
		print("Save file is broken")
		return

	var save_data = json.data

	if typeof(save_data) != TYPE_DICTIONARY:
		print("Save data is not valid")
		return

	PlayerData.money = float(save_data.get("money", 0.0))
	PlayerData.set_progression(
		int(save_data.get("level", 1)),
		int(save_data.get("current_xp", save_data.get("xp", 0)))
	)
	PlayerData.set_skill_state(
		int(save_data.get("skill_points", 0)),
		save_data.get("learned_skills", {})
	)
	PlayerData.set_catch_stats_from_save(save_data)
	PlayerData.rescue_kit_claims_total = max(int(save_data.get("rescue_kit_claims_total", 0)), 0)
	PlayerData.rescue_kit_last_claim_day = int(save_data.get("rescue_kit_last_claim_day", -1))
	PlayerData.set_unlocked_waterbodies(save_data.get("unlocked_waterbodies", ["agamin_lake"]))
	PlayerData.current_waterbody = str(save_data.get("current_waterbody", "agamin_lake"))
	if not PlayerData.can_use_waterbody(PlayerData.current_waterbody):
		PlayerData.current_waterbody = "agamin_lake"
	PlayerData.current_spot = str(save_data.get("current_spot", "old_oak_pier"))
	if SpotDatabase.get_spot(PlayerData.current_spot).is_empty():
		PlayerData.current_spot = "old_oak_pier"
	PlayerData.unlocked_spots = save_data.get("unlocked_spots", ["old_oak_pier"])
	PlayerData.upgrades = save_data.get("upgrades", [])
	PlayerData.set_fishing_depth(float(save_data.get("fishing_depth", PlayerData.fishing_depth)))
	PlayerData.set_owned_items(save_data.get("owned_items", []))
	PlayerData.set_current_tackle(save_data.get("current_tackle", {}))

	InventoryManager.inventory = save_data.get("inventory", [])
	InventoryManager.max_items = int(save_data.get("max_items", 20))
	var time_manager := _get_time_manager()
	if time_manager != null and time_manager.has_method("set_time"):
		time_manager.call(
			"set_time",
			float(save_data.get("current_game_minutes", _get_time_value("current_game_minutes", 460.0))),
			int(save_data.get("day_index", int(_get_time_value("day_index", 1.0))))
		)

	print("Game loaded")

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save deleted")

func _get_time_manager() -> Node:
	return get_node_or_null("/root/TimeManager")

func _get_time_value(property_name: String, fallback: float) -> float:
	var time_manager := _get_time_manager()

	if time_manager == null:
		return fallback

	return float(time_manager.get(property_name))
