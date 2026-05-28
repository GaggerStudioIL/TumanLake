# Coordinates the catch reward popup without owning fishing or economy logic.
extends RefCounted

# CatchPopupController only owns popup UI state and user intent signals.
signal keep_requested
signal release_requested
signal catch_keep_requested
signal catch_release_requested

var main
var popup_ui


func setup(main_ref, popup_ui_ref) -> void:
	main = main_ref
	popup_ui = popup_ui_ref
	if popup_ui == null:
		return

	if popup_ui.has_method("setup"):
		popup_ui.setup(main)
	_connect_action_buttons()
	if popup_ui.has_signal("catch_keep_requested"):
		var keep_callback := Callable(self, "_on_popup_keep_requested")
		if not popup_ui.catch_keep_requested.is_connected(keep_callback):
			popup_ui.catch_keep_requested.connect(keep_callback)
	if popup_ui.has_signal("catch_release_requested"):
		var release_callback := Callable(self, "_on_popup_release_requested")
		if not popup_ui.catch_release_requested.is_connected(release_callback):
			popup_ui.catch_release_requested.connect(release_callback)


func show_catch_result(catch_data: Dictionary) -> void:
	if popup_ui == null:
		return
	var display_data := _normalize_catch_data(catch_data)
	if popup_ui.has_method("open"):
		popup_ui.open(display_data)


func hide(animated: bool = true) -> void:
	if popup_ui == null:
		return
	if popup_ui.has_method("_hide_catch_reward_popup"):
		popup_ui._hide_catch_reward_popup(animated)
	elif popup_ui.has_method("close"):
		popup_ui.close()


func refresh() -> void:
	if popup_ui != null and popup_ui.has_method("refresh"):
		popup_ui.refresh()


func is_open() -> bool:
	return popup_ui != null and popup_ui.has_method("is_open") and popup_ui.is_open()


func update_input_lock() -> void:
	if popup_ui != null and popup_ui.has_method("_update_catch_reward_input_lock"):
		popup_ui._update_catch_reward_input_lock()


func request_keep() -> void:
	keep_requested.emit()
	catch_keep_requested.emit()


func request_release() -> void:
	release_requested.emit()
	catch_release_requested.emit()


func bring_to_front() -> void:
	if popup_ui != null and popup_ui.has_method("_bring_catch_reward_to_front"):
		popup_ui._bring_catch_reward_to_front()


func close_secondary_popups() -> void:
	if popup_ui != null and popup_ui.has_method("_close_secondary_popups_for_reward"):
		popup_ui._close_secondary_popups_for_reward()


func lock_buttons() -> void:
	if popup_ui != null and popup_ui.has_method("_lock_catch_reward_buttons"):
		popup_ui._lock_catch_reward_buttons()


func unlock_buttons() -> void:
	if popup_ui != null and popup_ui.has_method("_unlock_catch_reward_buttons"):
		popup_ui._unlock_catch_reward_buttons()


func start_fish_idle_motion(feedback: Dictionary) -> void:
	if popup_ui != null and popup_ui.has_method("_start_catch_fish_idle_motion"):
		popup_ui._start_catch_fish_idle_motion(feedback)


func update_popup(catch_data: Dictionary) -> void:
	if popup_ui != null and popup_ui.has_method("_update_catch_reward_popup"):
		popup_ui._update_catch_reward_popup(_normalize_catch_data(catch_data))


func set_fish_texture(fish_id: String) -> void:
	if popup_ui != null and popup_ui.has_method("_set_reward_fish_texture"):
		popup_ui._set_reward_fish_texture(fish_id)


func get_fish_texture(fish_id: String) -> Texture2D:
	if popup_ui != null and popup_ui.has_method("_get_reward_fish_texture"):
		return popup_ui._get_reward_fish_texture(fish_id)
	return null


func play_reward_sound(tier: String) -> void:
	if popup_ui != null and popup_ui.has_method("_play_catch_reward_sound"):
		popup_ui._play_catch_reward_sound(tier)


func set_hidden() -> void:
	if popup_ui != null and popup_ui.has_method("_set_catch_popup_hidden"):
		popup_ui._set_catch_popup_hidden()


func get_reward_tier(catch_data: Dictionary) -> String:
	if popup_ui != null and popup_ui.has_method("_get_reward_tier"):
		return str(popup_ui._get_reward_tier(catch_data))
	return "common"


func get_reward_colors(tier: String) -> Dictionary:
	if popup_ui != null and popup_ui.has_method("_get_reward_colors"):
		return popup_ui._get_reward_colors(tier)
	return {}


func get_reward_feedback_tuning(tier: String) -> Dictionary:
	if popup_ui != null and popup_ui.has_method("_get_reward_feedback_tuning"):
		return popup_ui._get_reward_feedback_tuning(tier)
	return {}


func get_catch_length_cm(catch_data: Dictionary) -> float:
	if popup_ui != null and popup_ui.has_method("_get_catch_length_cm"):
		return float(popup_ui._get_catch_length_cm(catch_data))
	return 0.0


func _normalize_catch_data(catch_data: Dictionary) -> Dictionary:
	var result := catch_data.duplicate(true)
	if not result.has("fish_id") and result.has("id"):
		result["fish_id"] = str(result.get("id", ""))
	if not result.has("fish_name") and result.has("name"):
		result["fish_name"] = str(result.get("name", ""))
	return result


func _connect_action_buttons() -> void:
	if main == null:
		return
	if main.catch_keep_button != null:
		var keep_button_callback := Callable(self, "request_keep")
		if not main.catch_keep_button.pressed.is_connected(keep_button_callback):
			main.catch_keep_button.pressed.connect(keep_button_callback)
	if main.catch_release_button != null:
		var release_button_callback := Callable(self, "request_release")
		if not main.catch_release_button.pressed.is_connected(release_button_callback):
			main.catch_release_button.pressed.connect(release_button_callback)


func _on_popup_keep_requested() -> void:
	request_keep()


func _on_popup_release_requested() -> void:
	request_release()
