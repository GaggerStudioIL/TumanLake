extends Node


func can_equip_item(slot_type: String, item: Dictionary) -> bool:
	return get_equip_block_reason(slot_type, item).is_empty()


func get_equip_block_reason(slot_type: String, item: Dictionary) -> String:
	if PlayerData.has_method("get_equip_block_reason"):
		return str(PlayerData.call("get_equip_block_reason", item, slot_type))
	return "Предмет нельзя экипировать."


func validate_current_tackle() -> Dictionary:
	var issues := PlayerData.get_tackle_setup_issues() if PlayerData.has_method("get_tackle_setup_issues") else []
	var usable := issues.is_empty()
	return {
		"usable": usable,
		"has_required_bait": has_required_bait(),
		"issues": issues,
		"reason": "" if usable else PlayerData.get_tackle_block_reason()
	}


func has_required_bait() -> bool:
	if PlayerData.has_method("get_tackle_schema_slots"):
		for slot_schema in PlayerData.get_tackle_schema_slots():
			if str(slot_schema.get("id", "")) == "bait" and bool(slot_schema.get("required", false)):
				return bool(PlayerData.call("has_current_bait")) if PlayerData.has_method("has_current_bait") else false
		return true
	if PlayerData.has_method("has_current_bait"):
		return bool(PlayerData.call("has_current_bait"))
	return false


func is_tackle_usable() -> bool:
	if PlayerData.has_method("get_tackle_setup_issues"):
		return PlayerData.get_tackle_setup_issues().is_empty()
	return has_required_bait()
