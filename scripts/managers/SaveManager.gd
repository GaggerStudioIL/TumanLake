extends Node

const SAVE_PATH := "user://save_game.json"
const SAVE_VERSION := 1

var intro_enabled: bool = true
var _intro_setting_loaded_from_disk: bool = false

func save_game() -> void:
	if InventoryManager.has_method("purge_zero_value_fish"):
		InventoryManager.purge_zero_value_fish()

	var time_save_data := _get_time_save_data()
	var save_data := {
		"save_version": SAVE_VERSION,
		"money": PlayerData.money,
		"alpha_tester_bonus_claimed": PlayerData.alpha_tester_bonus_claimed,
		"level": PlayerData.level,
		"current_xp": PlayerData.current_xp,
		"xp": PlayerData.current_xp,
		"xp_to_next_level": PlayerData.xp_to_next_level,
		"health": PlayerData.health,
		"body_temperature": PlayerData.body_temperature,
		"hunger": PlayerData.hunger,
		"condition": PlayerData.get_condition_save_data() if PlayerData.has_method("get_condition_save_data") else {},
		"claimed_level_rewards": PlayerData.get_claimed_level_rewards_save_data() if PlayerData.has_method("get_claimed_level_rewards_save_data") else {},
		"skill_points": PlayerData.skill_points,
		"total_skill_points_earned": PlayerData.total_skill_points_earned,
		"learned_skills": PlayerData.get_skill_ranks_save_data() if PlayerData.has_method("get_skill_ranks_save_data") else PlayerData.learned_skills,
		"skill_tree_points": PlayerData.get_skill_tree_points_save_data() if PlayerData.has_method("get_skill_tree_points_save_data") else {},
		"player_name": PlayerData.player_name,
		"total_fish_caught": PlayerData.total_fish_caught,
		"total_fish_weight": PlayerData.total_fish_weight,
		"daily_catch_day": PlayerData.daily_catch_day,
		"daily_fish_weight": PlayerData.daily_fish_weight,
		"best_daily_fish_weight": PlayerData.best_daily_fish_weight,
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
		"recent_tackle_items": PlayerData.get_recent_tackle_items_save_data(),
		"equipped_clothing": PlayerData.get_equipped_clothing_save_data() if PlayerData.has_method("get_equipped_clothing_save_data") else {},
		"starter_survival_kit_granted": PlayerData.starter_survival_kit_granted,
		"inventory": InventoryManager.inventory,
		"max_items": InventoryManager.max_items,
		"economy": _get_economy_save_data(),
		"audio": _get_audio_save_data(),
		"radio": _get_radio_save_data(),
		"gameplay": _get_gameplay_save_data(),
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

	if BuildConfig.ENABLE_VERBOSE_LOGS:
		print("Game saved")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		if BuildConfig.ENABLE_VERBOSE_LOGS:
			print("No save file yet")
		var time_manager := _get_time_manager()
		if time_manager != null and time_manager.has_method("initialize_new_game_time"):
			time_manager.call("initialize_new_game_time", false)
		if PlayerData.has_method("initialize_new_player_survival_state"):
			PlayerData.call("initialize_new_player_survival_state")
		save_game()
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

	var migrated_save := not (save_data as Dictionary).has("save_version")
	save_data = _migrate_save_data(save_data as Dictionary)

	PlayerData.money = float(save_data.get("money", 0.0))
	PlayerData.alpha_tester_bonus_claimed = bool(save_data.get("alpha_tester_bonus_claimed", false))
	PlayerData.set_progression(
		int(save_data.get("level", 1)),
		int(save_data.get("current_xp", save_data.get("xp", 0)))
	)
	var missing_condition_state := not (save_data as Dictionary).has("condition") and not (save_data as Dictionary).has("health")
	var repaired_condition_state := false
	if PlayerData.has_method("set_condition_from_save"):
		repaired_condition_state = bool(PlayerData.set_condition_from_save(save_data.get("condition", save_data)))
	var missing_level_rewards := not (save_data as Dictionary).has("claimed_level_rewards")
	if PlayerData.has_method("set_claimed_level_rewards"):
		PlayerData.set_claimed_level_rewards(save_data.get("claimed_level_rewards", {}), missing_level_rewards)
	PlayerData.set_skill_state(
		int(save_data.get("skill_points", 0)),
		save_data.get("learned_skills", {}),
		int(save_data.get("total_skill_points_earned", -1)),
		save_data.get("skill_tree_points", {})
	)
	PlayerData.set_catch_stats_from_save(save_data)
	PlayerData.rescue_kit_claims_total = max(int(save_data.get("rescue_kit_claims_total", 0)), 0)
	PlayerData.rescue_kit_last_claim_day = int(save_data.get("rescue_kit_last_claim_day", -1))
	PlayerData.set_unlocked_waterbodies(save_data.get("unlocked_waterbodies", ["agamin_lake"]))
	var repaired_location := _sanitize_loaded_location(save_data)
	PlayerData.unlocked_spots = save_data.get("unlocked_spots", ["old_oak_pier"])
	PlayerData.upgrades = save_data.get("upgrades", [])
	PlayerData.set_fishing_depth(float(save_data.get("fishing_depth", PlayerData.fishing_depth)))
	PlayerData.set_owned_items(save_data.get("owned_items", []))
	var missing_survival_state := not (save_data as Dictionary).has("starter_survival_kit_granted") or not (save_data as Dictionary).has("equipped_clothing")
	var migrated_survival_state := false
	if PlayerData.has_method("migrate_survival_state"):
		migrated_survival_state = bool(PlayerData.call(
			"migrate_survival_state",
			save_data.get("equipped_clothing", {}),
			save_data.get("starter_survival_kit_granted", false),
			(save_data as Dictionary).has("starter_survival_kit_granted")
		))
	PlayerData.set_current_tackle(save_data.get("current_tackle", {}))
	PlayerData.set_recent_tackle_items(save_data.get("recent_tackle_items", {}))

	InventoryManager.inventory = save_data.get("inventory", [])
	InventoryManager.max_items = maxi(int(save_data.get("max_items", 30)), 30)
	_load_economy_save_data(save_data.get("economy", {}))
	_load_audio_save_data(save_data.get("audio", {}))
	_load_radio_save_data(save_data.get("radio", {}))
	_load_gameplay_save_data(save_data.get("gameplay", {}))
	var time_manager := _get_time_manager()
	var should_save_after_time_load := false
	var missing_recent_tackle_items := not (save_data as Dictionary).has("recent_tackle_items")
	var missing_ranked_skill_state := not (save_data as Dictionary).has("total_skill_points_earned") or not (save_data as Dictionary).has("skill_tree_points")
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
	var removed_zero_value_fish := false
	if InventoryManager.has_method("purge_zero_value_fish"):
		removed_zero_value_fish = InventoryManager.purge_zero_value_fish() > 0

	if BuildConfig.ENABLE_VERBOSE_LOGS:
		print("Game loaded")
	if should_save_after_time_load or migrated_freshness or migrated_save or removed_zero_value_fish or missing_recent_tackle_items or missing_ranked_skill_state or missing_level_rewards or missing_condition_state or repaired_condition_state or repaired_location or missing_survival_state or migrated_survival_state:
		save_game()

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		if BuildConfig.ENABLE_VERBOSE_LOGS:
			print("Save deleted")
	var time_manager := _get_time_manager()
	if time_manager != null and time_manager.has_method("initialize_new_game_time"):
		time_manager.call("initialize_new_game_time", false)

func _get_time_manager() -> Node:
	return get_node_or_null("/root/TimeManager")

func _get_audio_manager() -> Node:
	return get_node_or_null("/root/AudioManager")

func _get_radio_manager() -> Node:
	return get_node_or_null("/root/RadioManager")

func _get_fishing_manager() -> Node:
	return get_node_or_null("/root/FishingManager")

func is_intro_enabled() -> bool:
	if not _intro_setting_loaded_from_disk:
		intro_enabled = _read_intro_enabled_from_save(intro_enabled)
		_intro_setting_loaded_from_disk = true
	return intro_enabled

func set_intro_enabled(enabled: bool) -> void:
	intro_enabled = enabled
	_intro_setting_loaded_from_disk = true

func _read_intro_enabled_from_save(fallback: bool = true) -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return fallback

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return fallback

	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(text) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return fallback

	var save_data: Dictionary = json.data as Dictionary
	var gameplay = save_data.get("gameplay", {})
	if gameplay is Dictionary:
		return bool((gameplay as Dictionary).get("intro_enabled", fallback))
	return fallback

func _get_audio_save_data() -> Dictionary:
	var audio_manager := _get_audio_manager()
	if audio_manager != null and audio_manager.has_method("get_volume_settings"):
		var value = audio_manager.call("get_volume_settings")
		if value is Dictionary:
			return value as Dictionary
	return {}

func _load_audio_save_data(data) -> void:
	if not (data is Dictionary):
		return
	var audio_manager := _get_audio_manager()
	if audio_manager != null and audio_manager.has_method("set_volume_settings"):
		audio_manager.call("set_volume_settings", data)

func _get_radio_save_data() -> Dictionary:
	var radio_manager: Node = _get_radio_manager()
	if radio_manager != null and radio_manager.has_method("get_radio_settings"):
		var value = radio_manager.call("get_radio_settings")
		if value is Dictionary:
			return value as Dictionary
	return {}

func _load_radio_save_data(data) -> void:
	if not (data is Dictionary):
		return
	var radio_manager: Node = _get_radio_manager()
	if radio_manager != null and radio_manager.has_method("set_radio_settings"):
		radio_manager.call("set_radio_settings", data)

func _get_gameplay_save_data() -> Dictionary:
	var result := {
		"intro_enabled": intro_enabled
	}
	var fishing_manager: Node = _get_fishing_manager()
	if fishing_manager != null and fishing_manager.has_method("get_gameplay_settings"):
		var value = fishing_manager.call("get_gameplay_settings")
		if value is Dictionary:
			for key in (value as Dictionary).keys():
				result[key] = (value as Dictionary)[key]
	if not result.has("vibration_enabled"):
		result["vibration_enabled"] = true
	return result

func _load_gameplay_save_data(data) -> void:
	if not (data is Dictionary):
		return
	intro_enabled = bool((data as Dictionary).get("intro_enabled", true))
	_intro_setting_loaded_from_disk = true
	var fishing_manager: Node = _get_fishing_manager()
	if fishing_manager != null and fishing_manager.has_method("set_gameplay_settings"):
		fishing_manager.call("set_gameplay_settings", data)

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

func _normalize_saved_waterbody_id(waterbody_id: String) -> String:
	var waterbody_db := get_node_or_null("/root/WaterbodyDatabase")
	if waterbody_db != null and waterbody_db.has_method("normalize_waterbody_id"):
		return str(waterbody_db.call("normalize_waterbody_id", waterbody_id))
	if waterbody_id == "":
		return "agamin_lake"
	return waterbody_id


func _sanitize_loaded_location(save_data: Dictionary) -> bool:
	var repaired := false
	var saved_waterbody := str(save_data.get("current_waterbody", "agamin_lake")).strip_edges()
	var waterbody_id := _normalize_saved_waterbody_id(saved_waterbody)
	if waterbody_id != saved_waterbody:
		repaired = true
	if not PlayerData.can_use_waterbody(waterbody_id):
		waterbody_id = "agamin_lake"
		repaired = true

	PlayerData.current_waterbody = waterbody_id

	var saved_spot_id := str(save_data.get("current_spot", "old_oak_pier")).strip_edges()
	var spot_id := saved_spot_id
	var current_spot: Dictionary = SpotDatabase.get_spot(spot_id) if spot_id != "" else {}
	var spot_invalid := spot_id == ""
	spot_invalid = spot_invalid or current_spot.is_empty()
	spot_invalid = spot_invalid or bool(current_spot.get("legacy", false))
	spot_invalid = spot_invalid or str(current_spot.get("waterbody_id", "agamin_lake")) != PlayerData.current_waterbody

	if spot_invalid:
		spot_id = WaterbodyDatabase.get_primary_spot(PlayerData.current_waterbody)
		if spot_id == "":
			spot_id = "old_oak_pier"

	if spot_id != saved_spot_id:
		repaired = true

	PlayerData.current_spot = spot_id
	return repaired


func _migrate_save_data(save_data: Dictionary) -> Dictionary:
	var result := save_data.duplicate(true)
	var version := int(result.get("save_version", 0))
	if version <= 0:
		result["save_version"] = SAVE_VERSION
		if not result.has("economy") or typeof(result.get("economy")) != TYPE_DICTIONARY:
			result["economy"] = {}
		if not result.has("inventory") or typeof(result.get("inventory")) != TYPE_ARRAY:
			result["inventory"] = []
		if not result.has("max_items"):
			result["max_items"] = 30
		result["max_items"] = maxi(int(result.get("max_items", 30)), 30)
	return result
