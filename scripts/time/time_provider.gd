extends RefCounted
class_name TimeProvider

func get_utc_unix_time() -> float:
	push_error("TimeProvider.get_utc_unix_time() must be implemented by a concrete provider.")
	return 0.0
