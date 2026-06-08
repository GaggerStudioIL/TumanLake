extends Control

const DEFAULT_CATEGORY_ORDER := ["line", "leader", "float", "hook", "bait", "tackle"]
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
	"tackle": "res://assets/ui/icons/quick_tackle/fishing_tackle.png"
}
const QUICK_SLOT_COUNT := 3

var main
var _buttons: Dictionary = {}
var _button_icons: Dictionary = {}
var _popup_panel: Panel
var _popup_scroll: ScrollContainer
var _popup_row: VBoxContainer
var _popup_category := ""
var _popup_mode := "quick"
var _popup_target_slot := -1
var _popup_item_count := 0
var _button_edge := 44.0
var _ui_scale := 1.0
var _texture_cache: Dictionary = {}
var _current_category_order: Array = []


func setup(main_ref) -> void:
	main = main_ref
	mouse_filter = Control.MOUSE_FILTER_PASS
	z_index = 266
	_ensure_nodes()
	refresh()


func layout(rect: Rect2, ui_scale: float) -> void:
	_ui_scale = clamp(ui_scale, 0.82, 1.24)
	_ensure_nodes()
	_ensure_popup_overlay_parent()
	position = rect.position
	size = rect.size
	custom_minimum_size = rect.size
	visible = true
	z_index = 266

	_button_edge = clamp(rect.size.y - 8.0 * _ui_scale, 88.0, 98.0)
	var category_order: Array = _get_category_order()
	var category_count: int = maxi(category_order.size(), 1)
	var gap: float = 8.0 * _ui_scale
	if category_count > 1:
		gap = max((rect.size.x - _button_edge * float(category_count)) / float(category_count - 1), 8.0 * _ui_scale)
	var total_width: float = _button_edge * float(category_count) + gap * float(maxi(category_count - 1, 0))
	var start_x: float = max((rect.size.x - total_width) * 0.5, 0.0)
	var y: float = max((rect.size.y - _button_edge) * 0.5, 0.0)

	for key in _buttons.keys():
		var stale_button := _buttons.get(key) as Button
		if stale_button != null:
			stale_button.visible = category_order.has(str(key))

	for i in category_order.size():
		var category := str(category_order[i])
		var button := _buttons.get(category) as Button
		if button == null:
			continue
		button.position = Vector2(start_x + float(i) * (_button_edge + gap), y)
		button.size = Vector2(_button_edge, _button_edge)
		button.custom_minimum_size = button.size
		button.pivot_offset = button.size * 0.5
		_apply_slot_button_style(button, _is_slot_equipped(category), false)
		var icon := _button_icons.get(category) as TextureRect
		if icon != null:
			icon.position = Vector2.ZERO
			icon.size = button.size

	_layout_popup()
	refresh()


func refresh() -> void:
	_ensure_nodes()
	var category_order: Array = _get_category_order()
	for key in _buttons.keys():
		var stale_button := _buttons.get(key) as Button
		if stale_button != null:
			stale_button.visible = category_order.has(str(key))

	for category in category_order:
		var key := str(category)
		var equipped := _is_slot_equipped(key)
		var button := _buttons.get(key) as Button
		if button != null:
			button.disabled = false
			button.tooltip_text = _get_button_tooltip(key)
			button.modulate = Color.WHITE
			_apply_slot_button_style(button, equipped, false)
		var icon := _button_icons.get(key) as TextureRect
		if icon != null:
			icon.modulate = Color(1.0, 1.0, 1.0, 1.0) if equipped or key == "tackle" else Color(0.78, 0.84, 0.82, 0.78)

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


func _input(event: InputEvent) -> void:
	if _popup_panel == null or not _popup_panel.visible:
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
		hide_popup()


func _ensure_nodes() -> void:
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


func _get_category_order() -> Array:
	var order: Array = []
	if PlayerData != null and PlayerData.has_method("get_tackle_schema_slots"):
		var slot_schemas: Array = PlayerData.get_tackle_schema_slots()
		for slot_schema in slot_schemas:
			if typeof(slot_schema) != TYPE_DICTIONARY:
				continue
			var slot_id := str((slot_schema as Dictionary).get("id", ""))
			if slot_id == "" or slot_id == "rod" or slot_id == "bait_2":
				continue
			if PlayerData.has_method("is_tackle_slot_locked") and bool(PlayerData.call("is_tackle_slot_locked", slot_id)):
				continue
			if not order.has(slot_id):
				order.append(slot_id)

	if order.is_empty():
		order = DEFAULT_CATEGORY_ORDER.duplicate()
	elif not order.has("tackle"):
		order.append("tackle")

	_current_category_order = order.duplicate()
	return order


func _get_allowed_item_categories(category: String) -> Array:
	if category == "tackle":
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
	if button == null:
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
	if category == "tackle":
		hide_popup()
		if main != null and main.has_method("open_full_tackle_from_quick_panel"):
			main.open_full_tackle_from_quick_panel()
		return

	if not _can_change_tackle():
		_show_toast("Снасть можно менять только перед забросом.", false)
		return

	if _popup_category == category and _popup_panel != null and _popup_panel.visible and _popup_mode == "quick":
		hide_popup()
		return

	_popup_category = category
	_popup_mode = "quick"
	_popup_target_slot = -1
	_rebuild_popup(category)
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
	_show_toast("Снято со снасти." if was_equipped else "Убрано из последних.", true)

	_popup_category = category
	_popup_mode = "quick"
	_popup_target_slot = -1
	_rebuild_popup(category)
	_popup_panel.visible = true
	_layout_popup()


func _open_owned_picker(category: String, slot_index: int) -> void:
	if not _can_change_tackle():
		return
	if not _can_change_tackle():
		_show_toast("РЎРЅР°СЃС‚СЊ РјРѕР¶РЅРѕ РјРµРЅСЏС‚СЊ С‚РѕР»СЊРєРѕ РїРµСЂРµРґ Р·Р°Р±СЂРѕСЃРѕРј.", false)
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
	if category == "tackle":
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
	if category == "tackle":
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
	if get_global_rect().has_point(point):
		return true
	if _popup_panel != null and _popup_panel.visible and _popup_panel.get_global_rect().has_point(point):
		return true
	return false


func _apply_slot_button_style(button: Button, _equipped: bool, _pressed: bool) -> void:
	var transparent_style := _make_round_style(Color.TRANSPARENT, Color.TRANSPARENT, _button_edge * 0.5, 0, Color.TRANSPARENT)
	button.add_theme_stylebox_override("normal", transparent_style)
	button.add_theme_stylebox_override("hover", transparent_style)
	button.add_theme_stylebox_override("pressed", transparent_style)
	button.add_theme_stylebox_override("disabled", transparent_style)
	button.add_theme_color_override("icon_normal_color", Color(0.94, 1.0, 0.96, 0.94))
	button.add_theme_color_override("icon_hover_color", Color(1.0, 1.0, 0.92, 1.0))
	button.add_theme_color_override("icon_pressed_color", Color(0.86, 1.0, 0.74, 1.0))
	button.add_theme_constant_override("icon_max_width", int(_button_edge))


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
