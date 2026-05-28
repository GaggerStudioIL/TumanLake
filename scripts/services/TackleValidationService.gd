extends Node


func can_equip_item(slot_type: String, item: Dictionary) -> bool:
	return get_equip_block_reason(slot_type, item).is_empty()


func get_equip_block_reason(slot_type: String, item: Dictionary) -> String:
	if PlayerData.has_method("get_equip_block_reason"):
		return str(PlayerData.call("get_equip_block_reason", item, slot_type))
	return "Предмет нельзя экипировать."


func validate_current_tackle() -> Dictionary:
	var usable := is_tackle_usable()
	return {
		"usable": usable,
		"has_required_bait": has_required_bait(),
		"reason": "" if usable else "Снасть не готова."
	}


func has_required_bait() -> bool:
	if PlayerData.has_method("has_current_bait"):
		return bool(PlayerData.call("has_current_bait"))
	return false


func is_tackle_usable() -> bool:
	if PlayerData.has_method("has_usable_basic_tackle") and not bool(PlayerData.call("has_usable_basic_tackle")):
		return false
	return has_required_bait()
