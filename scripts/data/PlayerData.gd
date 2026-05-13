extends Node

var money: int = 0
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 175
var current_spot: String = "north_pier"
var unlocked_spots: Array = ["north_pier"]
var upgrades: Array = []

func get_xp_to_next_level(for_level: int) -> int:
	return 100 + 50 * for_level + 25 * for_level * for_level

func add_xp(amount: int) -> Dictionary:
	var gained_xp: int = max(amount, 0)
	var levels_gained: int = 0

	current_xp += gained_xp

	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		level += 1
		levels_gained += 1
		xp_to_next_level = get_xp_to_next_level(level)

	return {
		"gained_xp": gained_xp,
		"levels_gained": levels_gained,
		"leveled_up": levels_gained > 0,
		"level": level,
		"current_xp": current_xp,
		"xp_to_next_level": xp_to_next_level
	}

func set_progression(saved_level: int, saved_xp: int) -> void:
	level = max(saved_level, 1)
	xp_to_next_level = get_xp_to_next_level(level)
	current_xp = max(saved_xp, 0)

	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		level += 1
		xp_to_next_level = get_xp_to_next_level(level)
