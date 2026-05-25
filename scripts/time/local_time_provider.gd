extends "res://scripts/time/time_provider.gd"
class_name LocalTimeProvider

func get_utc_unix_time() -> float:
	return Time.get_unix_time_from_system()
