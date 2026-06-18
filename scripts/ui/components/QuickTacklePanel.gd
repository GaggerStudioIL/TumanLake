extends Control

const DEFAULT_CATEGORY_ORDER := ["line", "leader", "hook", "float", "bait", "full_tackle"]
const CATEGORY_TITLES := {
	"line": "Леска",
	"leader": "Поводок",
	"float": "Поплавок",
	"hook": "Крючок",
	"bait": "Наживка",
	"reel": "Катушка",
	"lure": "Приманка",
	"feeder_rig": "Оснастка",
	"hook_or_lure": "Крючок/приманка",
	"sinker_or_rig": "Груз/оснастка",
	"tackle": "Снасти"
}
const CATEGORY_ICONS := {
	"line": "res://assets/ui/icons/quick_tackle/lines_button.png",
	"leader": "res://assets/ui/icons/quick_tackle/leashes_button.png",
	"float": "res://assets/ui/icons/quick_tackle/floats_button.png",
	"hook": "res://assets/ui/icons/quick_tackle/hooks_button.png",
	"bait": "res://assets/ui/icons/quick_tackle/baits_button.png",
	"reel": "res://assets/ui/icons/quick_tackle/fishing_tackle.png",
	"lure": "res://assets/ui/icons/quick_tackle/baits_button.png",
	"feeder_rig": "res://assets/ui/icons/quick_tackle/fishing_tackle.png",
	"hook_or_lure": "res://assets/ui/icons/quick_tackle/hooks_button.png",
	"sinker_or_rig": "res://assets/ui/icons/quick_tackle/fishing_tackle.png",
	"tackle": "res://assets/ui/icons/quick_tackle/fishing_tackle.png",
	"full_tackle": "res://assets/ui/icons/quick_tackle/fishing_tackle.png"
}
const QUICK_SLOT_COUNT := 3
const RADIAL_SLOT_OFFSETS := {
	"line": Vector2(-0.92, -0.88),
	"leader": Vector2(0.06, -1.16),
	"hook": Vector2(-0.96, 0.44),
	"float": Vector2(0.92, -0.64),
	"bait": Vector2(0.88, 0.62),
	"full_tackle": Vector2(-0.10, 1.14)
}
const RADIAL_STATE_CLOSED := "closed"
const RADIAL_STATE_OPENING := "opening"
const RADIAL_STATE_OPEN := "open"
const RADIAL_STATE_CLOSING := "closing"
const RADIAL_STATE_DISABLED := "disabled"
const RADIAL_ANIMATION_SECONDS := 0.18

var main
var is_tackle_radial_open := false
var _buttons: Dictionary = {}
var _button_icons: Dictionary = {}
var _toggle_button: Button
var _toggle_icon: TextureRect
var _popup_panel: Panel
var _popup_scroll: ScrollContainer
var _popup_row: VBoxContainer
var _popup_category := ""
var _popup_mode := "quick"
var _popup_target_slot := -1
var _popup_item_count := 0
var _button_edge := 44.0
var _toggle_edge := 42.0
var _ui_scale := 1.0
var _texture_cache: Dictionary = {}
var _current_category_order: Array = []
var _radial_state := RADIAL_STATE_CLOSED
var _radial_tween: Tween
var _collapsed_button_position := Vector2.ZERO
var _slot_target_positions: Dictionary = {}
var _has_layout := false


func setup(main_ref) -> void:
	main = main_ref
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 266
	set_process_input(true)
	_ensure_nodes()
	refresh()


func layout(rect: Rect2, ui_scale: float) -> void:
	_ui_scale = clamp(ui_scale, 0.82, 1.24)
	_ensure_nodes()
	_ensure_popup_overlay_parent()
	var category_order: Array = _get_category_order()
	var should_show := _should_show_radial_hud()
	visible = should_show
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 266
	if not should_show:
		_set_disabled_state()
		return
	if _radial_state == RADIAL_STATE_DISABLED:
		_radial_state = RADIAL_STATE_CLOSED
		is_tackle_radial_open = false

	_button_edge = clamp(rect.size.x * 0.39, 46.0 * _ui_scale, 56.0 * _ui_scale)
	_toggle_edge = clamp(rect.size.x * 0.34, 42.0 * _ui_scale, 50.0 * _ui_scale)
	var viewport_size := get_viewport_rect().size
	var center := rect.position + rect.size * 0.5
	var radius: float = clamp(rect.size.x * 0.78, _button_edge * 1.50, _button_edge * 1.92)
	var margin: float = max(8.0 * _ui_scale, 6.0)
	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)
	var slot_centers: Dictionary = {}
	var toggle_center := center + Vector2(rect.size.x * 0.72, -rect.size.y * 0.08)
	toggle_center.x = clamp(toggle_center.x, margin + _toggle_edge * 0.5, viewport_size.x - margin - _toggle_edge * 0.5)
	toggle_center.y = clamp(toggle_center.y, margin + _toggle_edge * 0.5, viewport_size.y - margin - _toggle_edge * 0.5)
	min_pos.x = min(min_pos.x, toggle_center.x - _toggle_edge * 0.5)
	min_pos.y = min(min_pos.y, toggle_center.y - _toggle_edge * 0.5)
	max_pos.x = max(max_pos.x, toggle_center.x + _toggle_edge * 0.5)
	max_pos.y = max(max_pos.y, toggle_center.y + _toggle_edge * 0.5)
	min_pos.x = min(min_pos.x, center.x - _button_edge * 0.5)
	min_pos.y = min(min_pos.y, center.y - _button_edge * 0.5)
	max_pos.x = max(max_pos.x, center.x + _button_edge * 0.5)
	max_pos.y = max(max_pos.y, center.y + _button_edge * 0.5)

	for category_value in category_order:
		var category := str(category_value)
		var offset_value = RADIAL_SLOT_OFFSETS.get(category, Vector2.ZERO)
		var offset: Vector2 = offset_value if offset_value is Vector2 else Vector2.ZERO
		if offset == Vector2.ZERO:
			continue
		var slot_center := center + offset.normalized() * radius
		slot_center.x = clamp(slot_center.x, margin + _button_edge * 0.5, viewport_size.x - margin - _button_edge * 0.5)
		slot_center.y = clamp(slot_center.y, margin + _button_edge * 0.5, viewport_size.y - margin - _button_edge * 0.5)
		slot_centers[category] = slot_center
		min_pos.x = min(min_pos.x, slot_center.x - _button_edge * 0.5)
		min_pos.y = min(min_pos.y, slot_center.y - _button_edge * 0.5)
		max_pos.x = max(max_pos.x, slot_center.x + _button_edge * 0.5)
		max_pos.y = max(max_pos.y, slot_center.y + _button_edge * 0.5)

	if slot_centers.is_empty():
		visible = false
		hide_popup()
		return

	position = min_pos
	size = max_pos - min_pos
	custom_minimum_size = size
	_has_layout = true
	_collapsed_button_position = center - position - Vector2(_button_edge, _button_edge) * 0.5
	_slot_target_positions.clear()
	_layout_toggle_button(toggle_center - position)

	for key in _buttons.keys():
		var stale_button := _buttons.get(key) as Button
		if stale_button != null:
			stale_button.visible = _is_radial_visible() and category_order.has(str(key))

	for category_value in category_order:
		var category := str(category_value)
		var button := _buttons.get(category) as Button
		if button == null:
			continue
		var slot_center: Vector2 = slot_centers.get(category, center)
		var target_position := slot_center - position - Vector2(_button_edge, _button_edge) * 0.5
		_slot_target_positions[category] = target_position
		if _radial_state == RADIAL_STATE_OPEN:
			button.position = target_position
			button.scale = Vector2.ONE
			button.modulate = Color(1.0, 1.0, 1.0, 1.0)
		elif _radial_state == RADIAL_STATE_CLOSED:
			button.position = _collapsed_button_position
			button.scale = Vector2.ONE * 0.2
			button.modulate = Color(1.0, 1.0, 1.0, 0.0)
		button.size = Vector2(_button_edge, _button_edge)
		button.custom_minimum_size = button.size
		button.pivot_offset = button.size * 0.5
		button.mouse_filter = Control.MOUSE_FILTER_STOP if _is_radial_visible() else Control.MOUSE_FILTER_IGNORE
		_apply_slot_button_style(button, _get_slot_visual_state(category))
		var icon := _button_icons.get(category) as TextureRect
		if icon != null:
			var inset: float = _button_edge * 0.18
			icon.position = Vector2(inset, inset)
			icon.size = button.size - Vector2(inset * 2.0, inset * 2.0)

	_layout_popup()
	refresh()


func refresh() -> void:
	_ensure_nodes()
	if not _has_layout:
		visible = false
		return
	var should_show := _should_show_radial_hud()
	visible = should_show
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not should_show:
		_set_disabled_state()
		return
	if _radial_state == RADIAL_STATE_DISABLED:
		_radial_state = RADIAL_STATE_CLOSED
		is_tackle_radial_open = false

	var category_order: Array = _get_category_order()
	var can_change := _can_change_tackle()
	_refresh_toggle_button(can_change)
	for key in _buttons.keys():
		var stale_button := _buttons.get(key) as Button
		if stale_button != null:
			stale_button.visible = _is_radial_visible() and category_order.has(str(key))
			stale_button.mouse_filter = Control.MOUSE_FILTER_STOP if stale_button.visible else Control.MOUSE_FILTER_IGNORE

	for category in category_order:
		var key := str(category)
		var equipped := _is_slot_equipped(key)
		var button := _buttons.get(key) as Button
		if button != null:
			button.disabled = not can_change
			button.tooltip_text = _get_button_tooltip(key)
			button.modulate = Color.WHITE if can_change else Color(0.76, 0.82, 0.80, 0.62)
			_apply_slot_button_style(button, _get_slot_visual_state(key))
		var icon := _button_icons.get(key) as TextureRect
		if icon != null:
			icon.texture = _get_current_slot_texture(key)
			icon.modulate = Color(1.0, 1.0, 1.0, 0.98) if equipped else Color(1.0, 0.78, 0.72, 0.94)

	if _popup_panel != null and _popup_panel.visible and _popup_category != "" and not category_order.has(_popup_category):
		hide_popup()
	if _popup_panel != null and _popup_panel.visible and _popup_category != "":
		_rebuild_popup(_popup_category)
		_layout_popup()


func hide_popup() -> void:
	_popup_category = ""
	_popup_mode = "quick"
	_popup_target_slot = -1
	_popup_item_count = 0
	if _popup_panel != null:
		_popup_panel.visible = false


func toggle_radial_menu() -> void:
	if is_tackle_radial_open or _radial_state == RADIAL_STATE_OPENING:
		close_radial_menu()
	else:
		open_radial_menu()


func open_radial_menu() -> void:
	if not _should_show_radial_hud() or not _can_change_tackle():
		close_radial_menu(false)
		return
	if not _has_layout:
		return
	if _radial_state == RADIAL_STATE_OPEN or _radial_state == RADIAL_STATE_OPENING:
		return
	is_tackle_radial_open = true
	_radial_state = RADIAL_STATE_OPENING
	_animate_radial_buttons(true)


func close_radial_menu(animated: bool = true) -> void:
	hide_popup()
	if _radial_state == RADIAL_STATE_CLOSED or _radial_state == RADIAL_STATE_DISABLED:
		is_tackle_radial_open = false
		_hide_radial_buttons()
		return
	is_tackle_radial_open = false
	if not animated:
		_radial_state = RADIAL_STATE_CLOSED
		_hide_radial_buttons()
		return
	_radial_state = RADIAL_STATE_CLOSING
	_animate_radial_buttons(false)


func hide_radial_menu(animated: bool = true) -> void:
	close_radial_menu(animated)


func get_radial_state() -> String:
	return _radial_state


func _input(event: InputEvent) -> void:
	if not _is_radial_visible() and (_popup_panel == null or not _popup_panel.visible):
		return
	if not (event is InputEventMouseButton or event is InputEventScreenTouch):
		return

	var pressed := false
	var point := Vector2.ZERO
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		pressed = mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT
		point = mouse_event.position
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		pressed = touch_event.pressed
		point = touch_event.position

	if pressed and not _is_point_inside_quick_ui(point):
		close_radial_menu()


func _ensure_nodes() -> void:
	if _toggle_button == null:
		_toggle_button = Button.new()
		_toggle_button.name = "QuickTackleToggleButton"
		_toggle_button.text = ""
		_toggle_button.tooltip_text = ""
		_toggle_button.mouse_filter = Control.MOUSE_FILTER_STOP
		_toggle_button.focus_mode = Control.FOCUS_NONE
		_toggle_button.visible = false
		_toggle_button.add_theme_constant_override("h_separation", 0)
		_toggle_button.pressed.connect(_on_toggle_pressed)
		add_child(_toggle_button)

		_toggle_icon = TextureRect.new()
		_toggle_icon.name = "Icon"
		_toggle_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_toggle_icon.texture = _get_category_texture("full_tackle")
		_toggle_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_toggle_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_toggle_button.add_child(_toggle_icon)

	var category_order: Array = _get_category_order()
	for category in category_order:
		var key := str(category)
		if not _buttons.has(key):
			var button := Button.new()
			button.name = "QuickTackle%sButton" % key.capitalize()
			button.text = ""
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			button.focus_mode = Control.FOCUS_NONE
			button.add_theme_constant_override("h_separation", 0)
			button.button_down.connect(_on_main_button_down.bind(key))
			button.button_up.connect(_on_main_button_up.bind(key))
			button.pressed.connect(_on_category_pressed.bind(key))
			add_child(button)
			_buttons[key] = button

			var icon := TextureRect.new()
			icon.name = "Icon"
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.texture = _get_category_texture(key)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			button.add_child(icon)
			_button_icons[key] = icon
		else:
			var icon := _button_icons.get(key) as TextureRect
			if icon != null:
				icon.texture = _get_category_texture(key)

	if _popup_panel == null:
		_popup_panel = Panel.new()
		_popup_panel.name = "QuickTacklePopup"
		_popup_panel.visible = false
		_popup_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		_popup_panel.z_index = 280
		add_child(_popup_panel)

	if _popup_scroll == null:
		_popup_scroll = ScrollContainer.new()
		_popup_scroll.name = "QuickTacklePopupScroll"
		_popup_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
		_popup_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		_popup_panel.add_child(_popup_scroll)

	if _popup_row == null:
		_popup_row = VBoxContainer.new()
		_popup_row.name = "QuickTacklePopupRow"
		_popup_row.mouse_filter = Control.MOUSE_FILTER_PASS
		_popup_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_popup_row.add_theme_constant_override("separation", 6)
		_popup_scroll.add_child(_popup_row)


func _layout_toggle_button(local_center: Vector2) -> void:
	if _toggle_button == null:
		return
	var toggle_size := Vector2(_toggle_edge, _toggle_edge)
	_toggle_button.position = local_center - toggle_size * 0.5
	_toggle_button.size = toggle_size
	_toggle_button.custom_minimum_size = toggle_size
	_toggle_button.pivot_offset = toggle_size * 0.5
	_toggle_button.z_index = 2
	_apply_toggle_button_style()
	if _toggle_icon != null:
		var inset: float = _toggle_edge * 0.20
		_toggle_icon.position = Vector2(inset, inset)
		_toggle_icon.size = toggle_size - Vector2(inset * 2.0, inset * 2.0)
		_toggle_icon.texture = _get_category_texture("full_tackle")
	_refresh_toggle_button(_can_change_tackle())


func _refresh_toggle_button(can_change: bool) -> void:
	if _toggle_button == null:
		return
	_toggle_button.visible = _should_show_radial_hud()
	_toggle_button.disabled = not can_change
	_toggle_button.mouse_filter = Control.MOUSE_FILTER_STOP if _toggle_button.visible and can_change else Control.MOUSE_FILTER_IGNORE
	_toggle_button.modulate = Color.WHITE if can_change else Color(0.76, 0.82, 0.80, 0.62)
	if _toggle_icon != null:
		_toggle_icon.modulate = Color(1.0, 1.0, 1.0, 0.98 if can_change else 0.56)


func _on_toggle_pressed() -> void:
	toggle_radial_menu()


func _is_radial_visible() -> bool:
	return _radial_state == RADIAL_STATE_OPEN or _radial_state == RADIAL_STATE_OPENING or _radial_state == RADIAL_STATE_CLOSING


func _hide_radial_buttons() -> void:
	for button_value in _buttons.values():
		var button := button_value as Button
		if button == null:
			continue
		button.visible = false
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.scale = Vector2.ONE * 0.2
		button.modulate = Color(1.0, 1.0, 1.0, 0.0)
		button.position = _collapsed_button_position


func _set_disabled_state() -> void:
	if is_instance_valid(_radial_tween):
		_radial_tween.kill()
	hide_popup()
	is_tackle_radial_open = false
	_radial_state = RADIAL_STATE_DISABLED
	_hide_radial_buttons()
	if _toggle_button != null:
		_toggle_button.visible = false
		_toggle_button.disabled = true
		_toggle_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _animate_radial_buttons(opening: bool) -> void:
	if is_instance_valid(_radial_tween):
		_radial_tween.kill()
	var category_order: Array = _get_category_order()
	var can_change := _can_change_tackle()
	var start_alpha := 0.0 if opening else 1.0
	var end_alpha := 1.0 if opening else 0.0
	var start_scale := Vector2.ONE * (0.2 if opening else 1.0)
	var end_scale := Vector2.ONE * (1.0 if opening else 0.2)
	_radial_tween = create_tween()
	_radial_tween.set_parallel(true)
	for category_value in category_order:
		var category := str(category_value)
		var button := _buttons.get(category) as Button
		if button == null:
			continue
		var target_position: Vector2 = _slot_target_positions.get(category, _collapsed_button_position)
		button.visible = true
		button.disabled = not can_change
		button.mouse_filter = Control.MOUSE_FILTER_STOP if can_change else Control.MOUSE_FILTER_IGNORE
		button.pivot_offset = button.size * 0.5
		if opening:
			button.position = _collapsed_button_position
			button.scale = start_scale
			button.modulate = Color(1.0, 1.0, 1.0, start_alpha)
		_radial_tween.tween_property(button, "position", target_position if opening else _collapsed_button_position, RADIAL_ANIMATION_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT if opening else Tween.EASE_IN)
		_radial_tween.tween_property(button, "scale", end_scale, RADIAL_ANIMATION_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT if opening else Tween.EASE_IN)
		_radial_tween.tween_property(button, "modulate:a", end_alpha, RADIAL_ANIMATION_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT if opening else Tween.EASE_IN)
	_radial_tween.finished.connect(func() -> void:
		if opening:
			_radial_state = RADIAL_STATE_OPEN
			is_tackle_radial_open = true
			refresh()
		else:
			_radial_state = RADIAL_STATE_CLOSED
			is_tackle_radial_open = false
			_hide_radial_buttons()
	)


func _get_category_order() -> Array:
	var order: Array = []
	var supported_slots: Dictionary = {}
	if PlayerData != null and PlayerData.has_method("get_tackle_schema_slots"):
		var slot_schemas: Array = PlayerData.get_tackle_schema_slots()
		for slot_schema in slot_schemas:
			if typeof(slot_schema) != TYPE_DICTIONARY:
				continue
			var slot_id := str((slot_schema as Dictionary).get("id", ""))
			if slot_id != "":
				supported_slots[slot_id] = true

	for slot_id_value in DEFAULT_CATEGORY_ORDER:
		var slot_id := str(slot_id_value)
		if slot_id == "full_tackle":
			order.append(slot_id)
			continue
		if not supported_slots.is_empty() and not supported_slots.has(slot_id):
			continue
		if PlayerData != null and PlayerData.has_method("is_tackle_slot_locked") and bool(PlayerData.call("is_tackle_slot_locked", slot_id)):
			continue
		order.append(slot_id)

	if order.is_empty():
		order = DEFAULT_CATEGORY_ORDER.duplicate()

	_current_category_order = order.duplicate()
	return order


func _get_allowed_item_categories(category: String) -> Array:
	if category == "tackle" or category == "full_tackle":
		return []
	if PlayerData != null and PlayerData.has_method("get_tackle_slot_item_categories"):
		var configured = PlayerData.call("get_tackle_slot_item_categories", category)
		if typeof(configured) == TYPE_ARRAY:
			var result: Array = []
			for item_category in configured:
				var item_category_key := str(item_category)
				if item_category_key != "" and not result.has(item_category_key):
					result.append(item_category_key)
			if not result.is_empty():
				return result
	return [category]


func _get_category_title(category: String) -> String:
	if PlayerData != null and PlayerData.has_method("get_tackle_slot_title"):
		var title := str(PlayerData.call("get_tackle_slot_title", category))
		if title != "":
			return title
	return str(CATEGORY_TITLES.get(category, category))


func _ensure_popup_overlay_parent() -> void:
	if _popup_panel == null:
		return
	var target_parent: Node = get_parent()
	if main != null:
		var main_canvas = main.get("ui_canvas_layer")
		if main_canvas is Node:
			target_parent = main_canvas
	if target_parent == null or _popup_panel.get_parent() == target_parent:
		return
	var was_visible := _popup_panel.visible
	var current_parent := _popup_panel.get_parent()
	if current_parent != null:
		current_parent.remove_child(_popup_panel)
	target_parent.add_child(_popup_panel)
	_popup_panel.visible = was_visible


func _on_main_button_down(category: String) -> void:
	var button := _buttons.get(category) as Button
	if button == null or button.disabled:
		return
	button.pivot_offset = button.size * 0.5
	button.scale = Vector2.ONE * 1.08


func _on_main_button_up(category: String) -> void:
	var button := _buttons.get(category) as Button
	if button == null:
		return
	button.scale = Vector2.ONE


func _on_category_pressed(category: String) -> void:
	_on_main_button_up(category)
	if not _can_change_tackle():
		_show_toast("Снасть можно менять только перед забросом.", false)
		return
	if category == "full_tackle":
		hide_popup()
		close_radial_menu(false)
		if main != null and main.has_method("open_full_tackle_from_quick_panel"):
			main.open_full_tackle_from_quick_panel()
		return

	if _popup_category == category and _popup_panel != null and _popup_panel.visible and _popup_mode == "picker":
		hide_popup()
		return

	_popup_category = category
	_popup_mode = "picker"
	_popup_target_slot = -1
	_rebuild_popup(category)
	if _popup_item_count > 0:
		_popup_panel.visible = true
		_layout_popup()


func _on_remove_pressed(category: String, item_id: String, slot_index: int = -1) -> void:
	if item_id == "":
		return
	if not _can_change_tackle():
		_show_toast("Снасть можно менять только перед забросом.", false)
		return

	if slot_index >= 0 and PlayerData.has_method("clear_recent_tackle_item_slot"):
		PlayerData.clear_recent_tackle_item_slot(category, slot_index)
	elif PlayerData.has_method("forget_recent_tackle_item"):
		PlayerData.forget_recent_tackle_item(category, item_id)
	var was_equipped: bool = _is_item_equipped_in_slot(category, item_id)
	if was_equipped:
		PlayerData.clear_current_tackle_slot(category)
	_save_game()
	_refresh_main_ui()
	refresh()
	_show_toast("Снято со снасти." if was_equipped else "Убрано из последних.", true)

	_popup_category = category
	_popup_mode = "quick"
	_popup_target_slot = -1
	_rebuild_popup(category)
	_popup_panel.visible = true
	_layout_popup()


func _open_owned_picker(category: String, slot_index: int) -> void:
	if not _can_change_tackle():
		_show_toast("Снасть можно менять только перед забросом.", false)
		return

	_popup_category = category
	_popup_mode = "picker"
	_popup_target_slot = slot_index
	_rebuild_popup(category)
	if _popup_item_count > 0:
		_popup_panel.visible = true
		_layout_popup()


func _equip_quick_item(category: String, item_id: String, slot_index: int = -1) -> void:
	if not _can_change_tackle():
		_show_toast("Снасть можно менять только перед забросом.", false)
		return

	var item := PlayerData.get_owned_item(item_id)
	if item.is_empty():
		_show_toast("Предмет не найден в инвентаре.", false)
		hide_popup()
		refresh()
		return

	var validation_service := get_node_or_null("/root/TackleValidationService")
	var block_reason := ""
	if validation_service != null and validation_service.has_method("get_equip_block_reason"):
		block_reason = str(validation_service.call("get_equip_block_reason", category, item))
	else:
		block_reason = PlayerData.get_equip_block_reason(item, category)

	if block_reason != "":
		_show_toast(block_reason, false)
		return

	var keep_popup_open := slot_index >= 0
	if PlayerData.set_current_tackle_slot(category, item):
		if slot_index >= 0 and PlayerData.has_method("set_recent_tackle_item_slot"):
			PlayerData.set_recent_tackle_item_slot(category, slot_index, item_id)
		if keep_popup_open:
			_popup_category = category
			_popup_mode = "quick"
			_popup_target_slot = -1
		else:
			hide_popup()
		_save_game()
		_refresh_main_ui()
		refresh()
		if keep_popup_open:
			_rebuild_popup(category)
			_popup_panel.visible = true
			_layout_popup()
		_show_toast("Экипировано: %s" % _get_item_display_name(item), true)
	else:
		_show_toast("Не удалось экипировать предмет.", false)


func _rebuild_popup(category: String) -> void:
	if _popup_row == null:
		return

	for child in _popup_row.get_children():
		_popup_row.remove_child(child)
		child.queue_free()
	_popup_item_count = 0

	if _popup_mode == "picker":
		var picker_items := _get_owned_picker_items(category)
		if picker_items.is_empty():
			hide_popup()
			_open_full_category_or_shop(category)
			return
		for item in picker_items:
			if typeof(item) != TYPE_DICTIONARY:
				continue
			_popup_row.add_child(_create_popup_item_button(category, item, false, _popup_target_slot))
			_popup_item_count += 1
		return

	var slots := _get_quick_slot_items(category)
	for i in slots.size():
		var slot_item = slots[i]
		if typeof(slot_item) == TYPE_DICTIONARY and not (slot_item as Dictionary).is_empty():
			_popup_row.add_child(_create_popup_item_button(category, slot_item, true, i))
		else:
			_popup_row.add_child(_create_empty_slot_button(category, i))
		_popup_item_count += 1


func _create_popup_item_button(category: String, item: Dictionary, show_remove: bool = true, slot_index: int = -1) -> Button:
	var button := Button.new()
	button.name = "QuickTackleItemButton"
	button.text = ""
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var card_edge: float = clamp(62.0 * _ui_scale, 56.0, 72.0)
	button.custom_minimum_size = Vector2(card_edge, card_edge)
	button.size = button.custom_minimum_size
	button.tooltip_text = ""
	button.pressed.connect(_equip_quick_item.bind(category, str(item.get("id", "")), slot_index))
	_apply_popup_card_style(button)

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture = _get_item_texture(item, category)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = Vector2(card_edge * 0.14, card_edge * 0.10)
	icon.size = Vector2(card_edge * 0.72, card_edge * 0.62)
	button.add_child(icon)

	var label := Label.new()
	label.name = "ShortLabel"
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = _get_short_item_label(category, item)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(card_edge * 0.08, card_edge * 0.70)
	label.size = Vector2(card_edge * 0.84, card_edge * 0.22)
	label.clip_text = true
	label.add_theme_font_size_override("font_size", int(clamp(9.0 * _ui_scale, 8.0, 11.0)))
	label.add_theme_color_override("font_color", Color(0.90, 0.98, 0.94, 0.92))
	button.add_child(label)

	if show_remove:
		var remove_button := Button.new()
		remove_button.name = "RemoveFromTackleButton"
		remove_button.text = "x"
		remove_button.tooltip_text = ""
		remove_button.focus_mode = Control.FOCUS_NONE
		remove_button.mouse_filter = Control.MOUSE_FILTER_STOP
		var remove_edge: float = clamp(18.0 * _ui_scale, 16.0, 22.0)
		remove_button.position = Vector2(card_edge - remove_edge * 0.78, -remove_edge * 0.18)
		remove_button.size = Vector2(remove_edge, remove_edge)
		remove_button.custom_minimum_size = remove_button.size
		remove_button.visible = true
		remove_button.disabled = false
		remove_button.pressed.connect(_on_remove_pressed.bind(category, str(item.get("id", "")), slot_index))
		_apply_remove_button_style(remove_button)
		button.add_child(remove_button)

	return button


func _create_empty_slot_button(category: String, slot_index: int) -> Button:
	var button := Button.new()
	button.name = "QuickTackleEmptySlotButton"
	button.text = "+"
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var card_edge: float = clamp(62.0 * _ui_scale, 56.0, 72.0)
	button.custom_minimum_size = Vector2(card_edge, card_edge)
	button.size = button.custom_minimum_size
	button.tooltip_text = ""
	button.pressed.connect(_open_owned_picker.bind(category, slot_index))
	button.add_theme_font_size_override("font_size", int(clamp(30.0 * _ui_scale, 24.0, 36.0)))
	button.add_theme_color_override("font_color", Color(0.84, 1.0, 0.88, 0.92))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.90, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.72, 1.0, 0.62, 1.0))
	_apply_popup_empty_slot_style(button)
	return button


func _layout_popup() -> void:
	if _popup_panel == null or not _popup_panel.visible or _popup_category == "":
		return
	_ensure_popup_overlay_parent()

	var item_count: int = max(_popup_item_count, 1)
	var card_edge: float = clamp(62.0 * _ui_scale, 56.0, 72.0)
	var gap: float = 7.0 * _ui_scale
	var visible_count := item_count
	if _popup_mode == "picker" and visible_count > 5:
		visible_count = 5
	var content_height: float = card_edge * float(item_count) + gap * float(item_count - 1)
	var visible_height: float = card_edge * float(visible_count) + gap * float(visible_count - 1)
	var popup_size: Vector2 = Vector2(card_edge + 14.0 * _ui_scale, visible_height + 14.0 * _ui_scale)
	_popup_panel.size = popup_size
	_popup_panel.custom_minimum_size = popup_size
	_popup_panel.add_theme_stylebox_override("panel", _make_round_style(Color(0.018, 0.034, 0.036, 0.90), Color(0.72, 1.0, 0.86, 0.30), 16.0 * _ui_scale, 1, Color(0.0, 0.0, 0.0, 0.35)))
	if _popup_scroll != null:
		_popup_scroll.position = Vector2(7.0, 7.0) * _ui_scale
		_popup_scroll.size = popup_size - Vector2(14.0, 14.0) * _ui_scale
		_popup_scroll.custom_minimum_size = _popup_scroll.size
	_popup_row.position = Vector2.ZERO
	_popup_row.size = Vector2(popup_size.x - 14.0 * _ui_scale, max(content_height, popup_size.y - 14.0 * _ui_scale))
	_popup_row.custom_minimum_size = Vector2(_popup_row.size.x, content_height)
	_popup_row.add_theme_constant_override("separation", int(round(gap)))

	var source_button := _buttons.get(_popup_category) as Button
	if source_button == null:
		return
	var source_rect := source_button.get_global_rect()
	var viewport_size := get_viewport_rect().size
	var popup_global_x := source_rect.position.x + source_rect.size.x * 0.5 - popup_size.x * 0.5
	var popup_global_y := source_rect.position.y - popup_size.y - 10.0 * _ui_scale
	popup_global_x = clamp(popup_global_x, 8.0, viewport_size.x - popup_size.x - 8.0)
	popup_global_y = clamp(popup_global_y, 8.0, viewport_size.y - popup_size.y - 8.0)
	_popup_panel.position = Vector2(popup_global_x, popup_global_y)


func _is_slot_equipped(category: String) -> bool:
	if category == "full_tackle":
		return true
	var component = PlayerData.current_tackle.get(category, {})
	return typeof(component) == TYPE_DICTIONARY and str(component.get("id", "")) != ""


func _is_item_equipped_in_slot(category: String, item_id: String) -> bool:
	if item_id == "" or not PlayerData.current_tackle.has(category):
		return false
	var component = PlayerData.current_tackle.get(category, {})
	return typeof(component) == TYPE_DICTIONARY and str(component.get("id", "")) == item_id


func _get_quick_slot_items(category: String) -> Array:
	var slots: Array = []
	var recent_ids: Array = []
	if PlayerData.has_method("get_recent_tackle_item_ids"):
		recent_ids = PlayerData.get_recent_tackle_item_ids(category)

	for i in QUICK_SLOT_COUNT:
		var item_id := ""
		if i < recent_ids.size():
			item_id = str(recent_ids[i])
		if item_id == "":
			slots.append({})
			continue
		var item := PlayerData.get_owned_item(item_id)
		if _is_owned_quick_item_available(item, category):
			slots.append(item)
		else:
			slots.append({})

	var has_any_recent_slot := false
	for slot in slots:
		if typeof(slot) == TYPE_DICTIONARY and not (slot as Dictionary).is_empty():
			has_any_recent_slot = true
			break
	if not has_any_recent_slot:
		var current = PlayerData.current_tackle.get(category, {})
		if typeof(current) == TYPE_DICTIONARY:
			var current_id := str(current.get("id", ""))
			if current_id != "":
				var current_item := PlayerData.get_owned_item(current_id)
				if _is_owned_quick_item_available(current_item, category):
					slots[0] = current_item

	return slots


func _get_owned_picker_items(category: String) -> Array:
	var result: Array = []
	var seen_ids: Dictionary = {}
	for item_category in _get_allowed_item_categories(category):
		for item in PlayerData.get_owned_items_for_category(str(item_category)):
			if typeof(item) != TYPE_DICTIONARY:
				continue
			var owned_item: Dictionary = item
			var item_id := str(owned_item.get("id", ""))
			if item_id == "" or seen_ids.has(item_id):
				continue
			if _is_owned_quick_item_available(owned_item, category):
				seen_ids[item_id] = true
				result.append(owned_item)
	return result


func _is_owned_quick_item_available(item: Dictionary, category: String) -> bool:
	if item.is_empty():
		return false
	var item_category := str(item.get("category", item.get("type", "")))
	if not _get_allowed_item_categories(category).has(item_category):
		return false
	if int(item.get("quantity", 0)) <= 0:
		return false
	return true


func _has_owned_quick_items(category: String) -> bool:
	for item_category in _get_allowed_item_categories(category):
		for item in PlayerData.get_owned_items_for_category(str(item_category)):
			if typeof(item) != TYPE_DICTIONARY:
				continue
			var item_id := str(item.get("id", ""))
			if item_id == "":
				continue
			if int(item.get("quantity", 0)) <= 0:
				continue
			return true
	return false


func _open_full_category_or_shop(category: String) -> void:
	if _has_owned_quick_items(category):
		if main != null and main.has_method("open_tackle_category_from_quick_panel"):
			main.open_tackle_category_from_quick_panel(category)
			return
	if main != null and main.has_method("open_shop_category"):
		var shop_category := category
		var allowed_categories := _get_allowed_item_categories(category)
		if not allowed_categories.is_empty():
			shop_category = str(allowed_categories[0])
		main.open_shop_category(shop_category)


func _can_change_tackle() -> bool:
	if main != null and main.has_method("can_quick_change_tackle"):
		return bool(main.can_quick_change_tackle())
	return true


func _refresh_main_ui() -> void:
	if main != null and main.has_method("refresh_after_quick_tackle_change"):
		main.refresh_after_quick_tackle_change()
	elif main != null and main.has_method("_update_ui"):
		main._update_ui()
	else:
		refresh()


func _show_toast(message: String, success: bool) -> void:
	if main != null and main.has_method("_show_toast"):
		main._show_toast(message, success)


func _save_game() -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null and save_manager.has_method("save_game"):
		save_manager.call("save_game")


func _get_button_tooltip(category: String) -> String:
	if category == "tackle" or category == "full_tackle":
		return "Полная сборка снасти"
	var equipped: Variant = PlayerData.current_tackle.get(category, {})
	var title := _get_category_title(category)
	if typeof(equipped) == TYPE_DICTIONARY and str(equipped.get("id", "")) != "":
		return "%s: %s" % [title, _get_item_display_name(equipped)]
	return "%s: не установлено" % title


func _get_item_display_name(item: Dictionary) -> String:
	return str(item.get("display_name_ru", item.get("name", "-")))


func _get_short_item_label(category: String, item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {}) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}
	var item_category := str(item.get("category", item.get("type", "")))
	if category != item_category and ["hook_or_lure", "sinker_or_rig"].has(category):
		return _get_short_item_label(item_category, item)
	match category:
		"line", "leader":
			var strength := float(stats.get("max_load_kg", stats.get("max_load", stats.get("strength", 0.0))))
			if strength > 0.0:
				return "%.1fкг" % strength
		"reel":
			var reel_size := int(stats.get("reel_size", item.get("reel_size", 0)))
			if reel_size > 0:
				return "%d" % reel_size
		"lure":
			var lure_weight := float(stats.get("weight", item.get("weight", 0.0)))
			if lure_weight > 0.0:
				return "%.0fг" % lure_weight
		"hook":
			if stats.has("hook_size_label"):
				return "№%s" % str(stats.get("hook_size_label", ""))
			if stats.has("hook_size"):
				return "№%s" % PlayerData.format_hook_size(int(stats.get("hook_size", 0)))
		"bait":
			return "x%d" % int(item.get("quantity", 0))
		"float":
			var min_depth := float(stats.get("depth_min", 0.0))
			var max_depth := float(stats.get("depth_max", 0.0))
			if max_depth > min_depth and max_depth > 0.0:
				return "%.1fм" % max_depth
	return _shorten(_get_item_display_name(item), 6)


func _shorten(value: String, max_chars: int) -> String:
	if value.length() <= max_chars:
		return value
	return value.substr(0, max_chars - 1) + "…"


func _get_category_texture(category: String) -> Texture2D:
	return _load_texture(str(CATEGORY_ICONS.get(category, "")))


func _get_item_texture(item: Dictionary, category: String) -> Texture2D:
	var texture := _load_texture(str(item.get("image_path", "")))
	if texture != null:
		return texture
	return _get_category_texture(category)


func _load_texture(path: String) -> Texture2D:
	if path == "":
		return null
	if _texture_cache.has(path):
		return _texture_cache[path]
	var resource: Resource = load(path)
	var texture := resource as Texture2D
	_texture_cache[path] = texture
	return texture


func _is_point_inside_quick_ui(point: Vector2) -> bool:
	if _toggle_button != null and _toggle_button.visible and _toggle_button.get_global_rect().has_point(point):
		return true
	for button_value in _buttons.values():
		var button := button_value as Button
		if button != null and button.visible and button.get_global_rect().has_point(point):
			return true
	if _popup_panel != null and _popup_panel.visible and _popup_panel.get_global_rect().has_point(point):
		return true
	return false


func _should_show_radial_hud() -> bool:
	if main != null:
		var modal_value = main.get("is_modal_open")
		if modal_value is bool and bool(modal_value):
			return false
		if main.has_method("_is_menu_overlay_open") and bool(main.call("_is_menu_overlay_open")):
			return false
	return true


func _get_slot_visual_state(category: String) -> String:
	if not _can_change_tackle():
		return "disabled"
	if category == "full_tackle":
		return "normal"
	if _is_slot_problem(category):
		return "warning"
	return "normal"


func _is_slot_problem(category: String) -> bool:
	if category == "full_tackle":
		return false
	if PlayerData == null:
		return true
	var component_value = PlayerData.current_tackle.get(category, {})
	if typeof(component_value) != TYPE_DICTIONARY:
		return true
	var component: Dictionary = component_value
	var item_id := str(component.get("id", ""))
	if item_id == "":
		return true
	var owned_item: Dictionary = {}
	if PlayerData.has_method("get_owned_item"):
		owned_item = PlayerData.get_owned_item(item_id)
	if owned_item.is_empty():
		return true
	if int(owned_item.get("quantity", 0)) <= 0:
		return true
	if category == "bait" and PlayerData.has_method("get_current_bait_quantity"):
		if int(PlayerData.call("get_current_bait_quantity", category)) <= 0:
			return true
	if PlayerData.has_method("get_equip_block_reason") and str(PlayerData.call("get_equip_block_reason", owned_item, category)) != "":
		return true
	return false


func _get_current_slot_texture(category: String) -> Texture2D:
	if category == "full_tackle":
		return _get_category_texture(category)
	if PlayerData != null:
		var component_value = PlayerData.current_tackle.get(category, {})
		if typeof(component_value) == TYPE_DICTIONARY:
			var component: Dictionary = component_value
			var item_id := str(component.get("id", ""))
			if item_id != "":
				var owned_item: Dictionary = {}
				if PlayerData.has_method("get_owned_item"):
					owned_item = PlayerData.get_owned_item(item_id)
				if not owned_item.is_empty():
					var owned_texture := _get_item_texture(owned_item, category)
					if owned_texture != null:
						return owned_texture
				var component_texture := _get_item_texture(component, category)
				if component_texture != null:
					return component_texture
	return _get_category_texture(category)


func _apply_slot_button_style(button: Button, state: String = "normal") -> void:
	var radius: float = _button_edge * 0.5
	var fill := Color(0.026, 0.045, 0.044, 0.84)
	var border := Color(0.62, 0.96, 0.78, 0.58)
	var hover_fill := Color(0.044, 0.076, 0.068, 0.92)
	var hover_border := Color(0.80, 1.0, 0.88, 0.82)
	var pressed_fill := Color(0.056, 0.112, 0.078, 0.98)
	var pressed_border := Color(0.92, 1.0, 0.74, 0.96)
	var disabled_fill := Color(0.034, 0.044, 0.044, 0.42)
	var disabled_border := Color(0.52, 0.66, 0.60, 0.22)
	var shadow := Color(0.0, 0.0, 0.0, 0.28)
	var border_width := 2

	match state:
		"warning":
			fill = Color(0.13, 0.045, 0.038, 0.88)
			border = Color(1.0, 0.35, 0.26, 0.90)
			hover_fill = Color(0.19, 0.060, 0.046, 0.96)
			hover_border = Color(1.0, 0.62, 0.48, 1.0)
			pressed_fill = Color(0.28, 0.074, 0.052, 1.0)
			pressed_border = Color(1.0, 0.82, 0.58, 1.0)
			border_width = 3
		"disabled":
			fill = disabled_fill
			border = disabled_border
			hover_fill = disabled_fill
			hover_border = disabled_border
			pressed_fill = disabled_fill
			pressed_border = disabled_border
			shadow = Color.TRANSPARENT

	button.add_theme_stylebox_override("normal", _make_round_style(fill, border, radius, border_width, shadow))
	button.add_theme_stylebox_override("hover", _make_round_style(hover_fill, hover_border, radius, border_width, shadow))
	button.add_theme_stylebox_override("pressed", _make_round_style(pressed_fill, pressed_border, radius, border_width, Color.TRANSPARENT))
	button.add_theme_stylebox_override("disabled", _make_round_style(disabled_fill, disabled_border, radius, border_width, Color.TRANSPARENT))
	button.add_theme_color_override("icon_normal_color", Color(0.94, 1.0, 0.96, 0.94))
	button.add_theme_color_override("icon_hover_color", Color(1.0, 1.0, 0.92, 1.0))
	button.add_theme_color_override("icon_pressed_color", Color(0.86, 1.0, 0.74, 1.0))
	button.add_theme_color_override("icon_disabled_color", Color(0.62, 0.70, 0.68, 0.56))
	button.add_theme_constant_override("icon_max_width", int(_button_edge * 0.68))


func _apply_toggle_button_style() -> void:
	if _toggle_button == null:
		return
	var radius: float = _toggle_edge * 0.5
	var fill := Color(0.026, 0.045, 0.044, 0.88)
	var border := Color(0.70, 1.0, 0.82, 0.62)
	var hover_fill := Color(0.046, 0.080, 0.070, 0.94)
	var hover_border := Color(0.86, 1.0, 0.90, 0.86)
	var pressed_fill := Color(0.060, 0.118, 0.084, 1.0)
	var pressed_border := Color(0.96, 1.0, 0.76, 0.96)
	var disabled_fill := Color(0.034, 0.044, 0.044, 0.42)
	var disabled_border := Color(0.52, 0.66, 0.60, 0.22)
	_toggle_button.add_theme_stylebox_override("normal", _make_round_style(fill, border, radius, 2, Color(0.0, 0.0, 0.0, 0.28)))
	_toggle_button.add_theme_stylebox_override("hover", _make_round_style(hover_fill, hover_border, radius, 2, Color(0.0, 0.0, 0.0, 0.24)))
	_toggle_button.add_theme_stylebox_override("pressed", _make_round_style(pressed_fill, pressed_border, radius, 2, Color.TRANSPARENT))
	_toggle_button.add_theme_stylebox_override("disabled", _make_round_style(disabled_fill, disabled_border, radius, 2, Color.TRANSPARENT))
	_toggle_button.add_theme_color_override("font_color", Color.TRANSPARENT)
	_toggle_button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	_toggle_button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
	_toggle_button.add_theme_color_override("font_disabled_color", Color.TRANSPARENT)
	_toggle_button.add_theme_constant_override("h_separation", 0)
	_toggle_button.add_theme_constant_override("icon_max_width", 0)


func _apply_remove_button_style(button: Button) -> void:
	var radius: float = max(button.size.x, 12.0) * 0.5
	button.add_theme_font_size_override("font_size", int(clamp(10.0 * _ui_scale, 9.0, 12.0)))
	button.add_theme_stylebox_override("normal", _make_round_style(Color(0.12, 0.032, 0.032, 0.92), Color(1.0, 0.76, 0.68, 0.64), radius, 1, Color(0.0, 0.0, 0.0, 0.25)))
	button.add_theme_stylebox_override("hover", _make_round_style(Color(0.22, 0.055, 0.052, 0.96), Color(1.0, 0.90, 0.82, 0.82), radius, 1, Color(0.0, 0.0, 0.0, 0.20)))
	button.add_theme_stylebox_override("pressed", _make_round_style(Color(0.34, 0.075, 0.060, 1.0), Color(1.0, 0.96, 0.88, 0.92), radius, 1, Color.TRANSPARENT))
	button.add_theme_color_override("font_color", Color(1.0, 0.93, 0.88, 0.96))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.96, 1.0))


func _apply_popup_card_style(button: Button) -> void:
	var radius: float = 8.0 * _ui_scale
	button.add_theme_stylebox_override("normal", _make_round_style(Color(0.040, 0.066, 0.064, 0.92), Color(0.66, 0.92, 0.78, 0.28), radius, 1, Color(0.0, 0.0, 0.0, 0.20)))
	button.add_theme_stylebox_override("hover", _make_round_style(Color(0.060, 0.094, 0.082, 0.96), Color(0.78, 1.0, 0.88, 0.48), radius, 1, Color(0.0, 0.0, 0.0, 0.18)))
	button.add_theme_stylebox_override("pressed", _make_round_style(Color(0.076, 0.128, 0.094, 1.0), Color(0.92, 1.0, 0.76, 0.72), radius, 1, Color.TRANSPARENT))


func _apply_popup_empty_slot_style(button: Button) -> void:
	var radius: float = 8.0 * _ui_scale
	button.add_theme_stylebox_override("normal", _make_round_style(Color(0.028, 0.042, 0.042, 0.76), Color(0.58, 0.88, 0.76, 0.28), radius, 1, Color(0.0, 0.0, 0.0, 0.14)))
	button.add_theme_stylebox_override("hover", _make_round_style(Color(0.046, 0.076, 0.066, 0.90), Color(0.78, 1.0, 0.88, 0.58), radius, 1, Color(0.0, 0.0, 0.0, 0.14)))
	button.add_theme_stylebox_override("pressed", _make_round_style(Color(0.070, 0.116, 0.086, 0.96), Color(0.92, 1.0, 0.76, 0.74), radius, 1, Color.TRANSPARENT))


func _make_round_style(fill: Color, border: Color, radius: float, border_width: int = 1, shadow: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	var rounded_radius := int(round(radius))
	style.corner_radius_top_left = rounded_radius
	style.corner_radius_top_right = rounded_radius
	style.corner_radius_bottom_left = rounded_radius
	style.corner_radius_bottom_right = rounded_radius
	style.shadow_color = shadow
	style.shadow_size = 6 if shadow.a > 0.0 else 0
	style.content_margin_left = 0.0
	style.content_margin_right = 0.0
	style.content_margin_top = 0.0
	style.content_margin_bottom = 0.0
	return style
