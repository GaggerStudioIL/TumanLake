extends Node

const VERY_FRESH_HOURS := 6.0
const FRESH_HOURS := 12.0
const NORMAL_HOURS := 24.0
const STALE_HOURS := 36.0
const ALMOST_SPOILED_HOURS := 48.0

const VERY_FRESH_PRICE_MULTIPLIER := 1.00
const FRESH_PRICE_MULTIPLIER := 0.95
const NORMAL_PRICE_MULTIPLIER := 0.85
const STALE_PRICE_MULTIPLIER := 0.70
const ALMOST_SPOILED_PRICE_MULTIPLIER := 0.50
const SPOILED_PRICE_MULTIPLIER := 0.20


func stamp_catch(catch_data: Dictionary) -> Dictionary:
	var result := catch_data.duplicate(true)
	_write_current_time_metadata(result)
	return result


func ensure_catch_freshness_metadata(catch_data: Dictionary) -> Dictionary:
	var result := catch_data.duplicate(true)
	if result.has("caught_at_real_unix_time"):
		_write_missing_game_time_metadata(result)
		return result

	_write_current_time_metadata(result)
	result["freshness_migrated"] = true
	return result


func get_fish_age_seconds(catch_data: Dictionary) -> float:
	return get_fish_age_game_hours(catch_data) * 60.0 * 60.0


func get_fish_age_game_hours(catch_data: Dictionary) -> float:
	return get_fish_age_game_minutes(catch_data) / 60.0


func get_fish_age_game_minutes(catch_data: Dictionary) -> float:
	var ensured := ensure_catch_freshness_metadata(catch_data)
	var caught_at_total_game_minutes := float(ensured.get("caught_at_total_game_minutes", -1.0))
	var time_manager := _get_time_manager()
	if time_manager != null and caught_at_total_game_minutes >= 0.0:
		var current_total_game_minutes := float(time_manager.get("total_game_minutes"))
		return maxf(current_total_game_minutes - caught_at_total_game_minutes, 0.0)

	var caught_at_real_time := float(ensured.get("caught_at_real_unix_time", 0.0))
	var now := _get_real_unix_time()
	if caught_at_real_time <= 0.0 or now <= 0.0:
		return 0.0

	return maxf(now - caught_at_real_time, 0.0) / 60.0


func get_freshness_ratio(catch_data: Dictionary) -> float:
	var age_hours := get_fish_age_game_hours(catch_data)
	return clampf(1.0 - age_hours / ALMOST_SPOILED_HOURS, 0.0, 1.0)


func get_freshness_key(catch_data: Dictionary) -> String:
	var age_hours := get_fish_age_game_hours(catch_data)
	if age_hours <= VERY_FRESH_HOURS:
		return "very_fresh"
	if age_hours <= FRESH_HOURS:
		return "fresh"
	if age_hours <= NORMAL_HOURS:
		return "normal"
	if age_hours <= STALE_HOURS:
		return "stale"
	if age_hours <= ALMOST_SPOILED_HOURS:
		return "almost_spoiled"
	return "spoiled"


func get_freshness_title(catch_data: Dictionary) -> String:
	match get_freshness_key(catch_data):
		"very_fresh":
			return "Очень свежая"
		"fresh":
			return "Свежая"
		"normal":
			return "Нормальная"
		"stale":
			return "Несвежая"
		"almost_spoiled":
			return "Почти испорченная"
		_:
			return "Испорченная"


func get_price_multiplier(catch_data: Dictionary, buyer_id: String = "") -> float:
	var base_multiplier := _get_base_price_multiplier_for_key(get_freshness_key(catch_data))
	var freshness_floor := _get_buyer_freshness_floor(buyer_id)
	if freshness_floor > 0.0:
		return maxf(base_multiplier, freshness_floor)
	return base_multiplier


func get_adjusted_price(catch_data: Dictionary) -> int:
	var base_price := int(catch_data.get("price", 0))
	return max(roundi(float(max(base_price, 0)) * get_price_multiplier(catch_data)), 0)


func _get_base_price_multiplier_for_key(freshness_key: String) -> float:
	match freshness_key:
		"very_fresh":
			return VERY_FRESH_PRICE_MULTIPLIER
		"fresh":
			return FRESH_PRICE_MULTIPLIER
		"normal":
			return NORMAL_PRICE_MULTIPLIER
		"stale":
			return STALE_PRICE_MULTIPLIER
		"almost_spoiled":
			return ALMOST_SPOILED_PRICE_MULTIPLIER
		_:
			return SPOILED_PRICE_MULTIPLIER


func _get_buyer_freshness_floor(buyer_id: String) -> float:
	if buyer_id.is_empty():
		return 0.0
	var supplier_manager := get_node_or_null("/root/SupplierManager")
	if supplier_manager == null or not supplier_manager.has_method("get_supplier"):
		return 0.0
	var value = supplier_manager.call("get_supplier", buyer_id)
	if not (value is Dictionary):
		return 0.0
	var supplier: Dictionary = value
	return float(supplier.get("freshness_price_floor", 0.0))


func _write_current_time_metadata(catch_data: Dictionary) -> void:
	var time_manager := _get_time_manager()
	catch_data["caught_at_real_unix_time"] = _get_real_unix_time()

	if time_manager != null:
		catch_data["caught_at_total_game_minutes"] = float(time_manager.get("total_game_minutes"))
		catch_data["caught_at_day_index"] = int(time_manager.get("day_index"))
		catch_data["caught_at_clock"] = _get_current_clock_text(time_manager)
		catch_data["caught_at_time_of_day"] = str(time_manager.get("time_of_day"))
		return

	catch_data["caught_at_total_game_minutes"] = 0.0
	catch_data["caught_at_day_index"] = 1
	catch_data["caught_at_clock"] = "00:00"
	catch_data["caught_at_time_of_day"] = "unknown"


func _write_missing_game_time_metadata(catch_data: Dictionary) -> void:
	var time_manager := _get_time_manager()
	if time_manager != null:
		if not catch_data.has("caught_at_total_game_minutes"):
			catch_data["caught_at_total_game_minutes"] = float(time_manager.get("total_game_minutes"))
		if not catch_data.has("caught_at_day_index"):
			catch_data["caught_at_day_index"] = int(time_manager.get("day_index"))
		if not catch_data.has("caught_at_clock"):
			catch_data["caught_at_clock"] = _get_current_clock_text(time_manager)
		if not catch_data.has("caught_at_time_of_day"):
			catch_data["caught_at_time_of_day"] = str(time_manager.get("time_of_day"))
		return

	if not catch_data.has("caught_at_total_game_minutes"):
		catch_data["caught_at_total_game_minutes"] = 0.0
	if not catch_data.has("caught_at_day_index"):
		catch_data["caught_at_day_index"] = 1
	if not catch_data.has("caught_at_clock"):
		catch_data["caught_at_clock"] = "00:00"
	if not catch_data.has("caught_at_time_of_day"):
		catch_data["caught_at_time_of_day"] = "unknown"


func _get_real_unix_time() -> float:
	var time_manager := _get_time_manager()
	if time_manager != null and time_manager.has_method("get_real_unix_time"):
		return float(time_manager.call("get_real_unix_time"))
	return 0.0


func _get_time_manager() -> Node:
	return get_node_or_null("/root/TimeManager")


func _get_current_clock_text(time_manager: Node) -> String:
	if time_manager != null and time_manager.has_method("get_clock_text"):
		return str(time_manager.call("get_clock_text"))
	if time_manager != null:
		return _format_clock_from_minutes(float(time_manager.get("current_game_minutes")))
	return "00:00"


func _format_clock_from_minutes(minutes_in_day: float) -> String:
	var safe_minutes := int(floor(fposmod(minutes_in_day, 1440.0)))
	return "%02d:%02d" % [int(safe_minutes / 60), safe_minutes % 60]
