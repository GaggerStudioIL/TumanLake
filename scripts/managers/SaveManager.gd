extends Node

const SAVE_PATH := "user://save_game.json"

func save_game() -> void:
	var save_data := {
		"money": PlayerData.money,
		"level": PlayerData.level,
		"current_xp": PlayerData.current_xp,
		"xp": PlayerData.current_xp,
		"xp_to_next_level": PlayerData.xp_to_next_level,
		"current_spot": PlayerData.current_spot,
		"unlocked_spots": PlayerData.unlocked_spots,
		"upgrades": PlayerData.upgrades,
		"current_tackle": PlayerData.current_tackle,
		"inventory": InventoryManager.inventory,
		"max_items": InventoryManager.max_items
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

	PlayerData.money = int(save_data.get("money", 0))
	PlayerData.set_progression(
		int(save_data.get("level", 1)),
		int(save_data.get("current_xp", save_data.get("xp", 0)))
	)
	PlayerData.current_spot = str(save_data.get("current_spot", "north_pier"))
	PlayerData.unlocked_spots = save_data.get("unlocked_spots", ["north_pier"])
	PlayerData.upgrades = save_data.get("upgrades", [])
	PlayerData.set_current_tackle(save_data.get("current_tackle", {}))

	InventoryManager.inventory = save_data.get("inventory", [])
	InventoryManager.max_items = int(save_data.get("max_items", 20))

	print("Game loaded")

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save deleted")
