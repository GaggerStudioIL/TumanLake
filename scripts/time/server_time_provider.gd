extends "res://scripts/time/time_provider.gd"
class_name ServerTimeProvider

var server_offset_seconds: float = 0.0

func set_server_unix_time(server_unix_time: float) -> void:
	server_offset_seconds = server_unix_time - Time.get_unix_time_from_system()

func get_utc_unix_time() -> float:
	return Time.get_unix_time_from_system() + server_offset_seconds
