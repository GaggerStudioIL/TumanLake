extends Node

const SAVE_PATH := "user://save_game.json"

func save_game() -> void:
	var time_save_data := _get_time_save_data()
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
		"economy": _get_economy_save_data(),
		"game_time": time_save_data,
		"total_game_minutes": float(time_save_data.get("total_game_minutes", 525.0)),
		"current_game_minutes": float(time_save_data.get("current_game_minutes", 525.0)),
		"day_index": int(time_save_data.get("day_index", 1)),
		"last_real_utc_unix_time": float(time_save_data.get("last_real_utc_unix_time", 0.0))
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
		var time_manager := _get_time_manager()
		if time_manager != null and time_manager.has_method("initialize_new_game_time"):
			time_manager.call("initialize_new_game_time", false)
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
	_load_economy_save_data(save_data.get("economy", {}))
	var time_manager := _get_time_manager()
	var should_save_after_time_load := false
	if time_manager != null and time_manager.has_method("load_time_from_save"):
		time_manager.call("load_time_from_save", save_data)
		should_save_after_time_load = true
	elif time_manager != null and time_manager.has_method("set_time"):
		time_manager.call(
			"set_time",
			float(save_data.get("current_game_minutes", _get_time_value("current_game_minutes", 525.0))),
			int(save_data.get("day_index", int(_get_time_value("day_index", 1.0))))
		)
		should_save_after_time_load = true

	var migrated_freshness := false
	if InventoryManager.has_method("ensure_inventory_freshness_metadata"):
		migrated_freshness = InventoryManager.ensure_inventory_freshness_metadata()

	print("Game loaded")
	if should_save_after_time_load or migrated_freshness:
		save_game()

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save deleted")
	var time_manager := _get_time_manager()
	if time_manager != null and time_manager.has_method("initialize_new_game_time"):
		time_manager.call("initialize_new_game_time", false)

func _get_time_manager() -> Node:
	return get_node_or_null("/root/TimeManager")

func _get_time_save_data() -> Dictionary:
	var time_manager := _get_time_manager()

	if time_manager != null and time_manager.has_method("get_time_save_data"):
		var time_data = time_manager.call("get_time_save_data")
		if time_data is Dictionary:
			return time_data as Dictionary

	return {
		"initialized": false,
		"total_game_minutes": 525.0,
		"current_game_minutes": _get_time_value("current_game_minutes", 525.0),
		"day_index": int(_get_time_value("day_index", 1.0)),
		"last_real_utc_unix_time": 0.0
	}

func _get_economy_save_data() -> Dictionary:
	var result: Dictionary = {}
	var reputation_system: Node = get_node_or_null("/root/ReputationSystem")
	if reputation_system != null and reputation_system.has_method("get_save_data"):
		var reputation_data = reputation_system.call("get_save_data")
		if reputation_data is Dictionary:
			result["reputation"] = reputation_data

	var contract_manager: Node = get_node_or_null("/root/ContractManager")
	if contract_manager != null and contract_manager.has_method("get_save_data"):
		var contract_data = contract_manager.call("get_save_data")
		if contract_data is Dictionary:
			result["contracts"] = contract_data

	var market_manager: Node = get_node_or_null("/root/DynamicMarketManager")
	if market_manager != null and market_manager.has_method("get_save_data"):
		var market_data = market_manager.call("get_save_data")
		if market_data is Dictionary:
			result["market"] = market_data

	return result


func _load_economy_save_data(value) -> void:
	if typeof(value) != TYPE_DICTIONARY:
		return

	var economy_data: Dictionary = value
	var reputation_system: Node = get_node_or_null("/root/ReputationSystem")
	if reputation_system != null and reputation_system.has_method("load_save_data"):
		reputation_system.call("load_save_data", economy_data.get("reputation", {}))

	var contract_manager: Node = get_node_or_null("/root/ContractManager")
	if contract_manager != null and contract_manager.has_method("load_save_data"):
		contract_manager.call("load_save_data", economy_data.get("contracts", {}))

	var market_manager: Node = get_node_or_null("/root/DynamicMarketManager")
	if market_manager != null and market_manager.has_method("load_save_data"):
		market_manager.call("load_save_data", economy_data.get("market", {}))


func _get_time_value(property_name: String, fallback: float) -> float:
	var time_manager := _get_time_manager()

	if time_manager == null:
		return fallback

	return float(time_manager.get(property_name))
