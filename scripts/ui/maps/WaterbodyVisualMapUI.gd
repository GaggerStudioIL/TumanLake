extends Control

signal spot_selected(waterbody_id: String, spot_id: String)
signal global_requested
signal shop_requested
signal harbor_requested
signal fisher_home_requested
signal close_requested

const MapSpotMarkerScript := preload("res://scripts/ui/maps/MapSpotMarker.gd")
const SpotInfoPanelScript := preload("res://scripts/ui/maps/SpotInfoPanel.gd")
const FALLBACK_MAP_TEXTURE: Texture2D = preload("res://assets/environment/lake/lake_bg_base.png.png")
const MAP_DRAG_THRESHOLD := 14.0
const MARKER_PRESS_SUPPRESS_MS := 180
const BAKED_ACTION_BUTTON_RECTS := {
	"waterbodies": Rect2(0.0146, 0.0222, 0.1302, 0.0630),
	"home": Rect2(0.1604, 0.0222, 0.1292, 0.0630),
	"shop": Rect2(0.6563, 0.0222, 0.1104, 0.0630),
	"harbor": Rect2(0.7729, 0.0222, 0.1052, 0.0630),
	"close": Rect2(0.8854, 0.0222, 0.1000, 0.0630)
}

var main
var waterbody_data: Dictionary = {}
var marker_nodes: Array = []

var clip_area: Control
var movable_map: Control
var map_texture: TextureRect
var fallback_tint: ColorRect
var marker_layer: Control
var title_label: Label
var placeholder_label: Label
var waterbodies_button: Button
var home_button: Button
var shop_button: Button
var harbor_button: Button
var close_button: Button
var spot_info_panel
var _map_draw_size := Vector2.ZERO
var _map_position := Vector2.ZERO
var _map_position_initialized := false
var _drag_active := false
var _dragging_map := false
var _drag_start_position := Vector2.ZERO
var _drag_start_map_position := Vector2.ZERO
var _suppress_marker_press_until_msec := 0
var _selected_spot_id := ""
var _active_waterbody_id := ""
var _active_map_asset := ""

func setup(owner) -> void:
	main = owner
	_ensure_nodes()
	visible = false

func show_waterbody(waterbody: Dictionary) -> void:
	_ensure_nodes()
	waterbody_data = waterbody.duplicate(true)
	var waterbody_id := str(waterbody_data.get("id", ""))
	var map_asset := str(waterbody_data.get("map_asset", ""))
	if waterbody_id != _active_waterbody_id or map_asset != _active_map_asset:
		_map_position_initialized = false
		_selected_spot_id = ""
		_active_waterbody_id = waterbody_id
		_active_map_asset = map_asset
	if _selected_spot_id == "":
		_selected_spot_id = _get_initial_selected_spot_id(waterbody_id)
	visible = true
	title_label.text = ""
	_apply_map_texture()
	_rebuild_markers()
	layout_map()

func layout_map() -> void:
	if clip_area == null:
		return

	var view_size: Vector2 = size
	clip_area.position = Vector2.ZERO
	clip_area.size = view_size
	clip_area.clip_contents = true

	var texture_size := _get_map_texture_size(view_size)
	var map_scale := _get_map_scale(view_size, texture_size)
	_map_draw_size = texture_size * map_scale

	movable_map.size = _map_draw_size
	map_texture.position = Vector2.ZERO
	map_texture.size = _map_draw_size
	fallback_tint.position = Vector2.ZERO
	fallback_tint.size = _map_draw_size
	marker_layer.position = Vector2.ZERO
	marker_layer.size = _map_draw_size

	if not _map_position_initialized:
		_map_position = _get_initial_map_position(view_size)
		_map_position_initialized = true
	else:
		_map_position = _clamp_map_position(_map_position, view_size)
	movable_map.position = _map_position

	placeholder_label.position = Vector2(view_size.x * 0.5 - 210.0, view_size.y * 0.5 - 34.0)
	placeholder_label.size = Vector2(420.0, 68.0)
	var map_rect: Rect2 = Rect2(_map_position, _map_draw_size)

	var top_margin: float = maxf(12.0, view_size.y * 0.024)
	var top_button_y: float = top_margin + 2.0
	var top_button_height: float = clampf(view_size.y * 0.070, 34.0, 40.0)
	var top_button_gap: float = clampf(view_size.x * 0.008, 7.0, 10.0)
	var edge_margin: float = maxf(18.0, view_size.x * 0.018)
	var back_button_width: float = clampf(view_size.x * 0.142, 126.0, 150.0)
	var menu_button_width: float = clampf(view_size.x * 0.112, 96.0, 124.0)
	var home_button_width: float = clampf(view_size.x * 0.126, 112.0, 142.0)
	var close_button_width: float = clampf(view_size.x * 0.098, 86.0, 104.0)

	title_label.position = Vector2.ZERO
	title_label.size = Vector2.ZERO
	if _uses_baked_map_controls():
		_layout_baked_action_button(waterbodies_button, "waterbodies", "К водоёмам", map_rect)
		_layout_baked_action_button(home_button, "home", "Дом рыбака", map_rect)
		_layout_baked_action_button(shop_button, "shop", "Магазин", map_rect)
		_layout_baked_action_button(harbor_button, "harbor", "Гавань", map_rect)
		_layout_baked_action_button(close_button, "close", "Закрыть", map_rect)
	else:
		_prepare_visible_action_button(waterbodies_button, "К водоёмам")
		_prepare_visible_action_button(home_button, "Дом рыбака")
		_prepare_visible_action_button(shop_button, "Магазин")
		_prepare_visible_action_button(harbor_button, "Гавань")
		_prepare_visible_action_button(close_button, "Закрыть")
		waterbodies_button.position = Vector2(edge_margin, top_button_y)
		waterbodies_button.size = Vector2(back_button_width, top_button_height)
		home_button.position = Vector2(waterbodies_button.position.x + back_button_width + top_button_gap, top_button_y)
		home_button.size = Vector2(home_button_width, top_button_height)
		close_button.position = Vector2(view_size.x - edge_margin - close_button_width, top_button_y)
		close_button.size = Vector2(close_button_width, top_button_height)
		harbor_button.position = Vector2(close_button.position.x - top_button_gap - menu_button_width, top_button_y)
		harbor_button.size = Vector2(menu_button_width, top_button_height)
		shop_button.position = Vector2(harbor_button.position.x - top_button_gap - menu_button_width, top_button_y)
		shop_button.size = Vector2(menu_button_width, top_button_height)

	var marker_size: float = clampf(view_size.y * 0.145, 72.0, 84.0)
	var info_size: float = clampf(view_size.y * 0.060, 30.0, 40.0)
	if _uses_baked_map_controls():
		marker_size = clampf(map_rect.size.y * 0.088, 42.0, 92.0)
		info_size = clampf(map_rect.size.y * 0.040, 22.0, 42.0)
	for marker in marker_nodes:
		if marker != null and marker.has_method("layout_marker"):
			marker.call("layout_marker", Rect2(Vector2.ZERO, _map_draw_size), marker_size, info_size)

	if spot_info_panel != null and spot_info_panel.visible and spot_info_panel.has_method("layout_panel"):
		spot_info_panel.call("layout_panel", view_size)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		layout_map()

func _ensure_nodes() -> void:
	if map_texture != null:
		return

	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)

	clip_area = Control.new()
	clip_area.name = "MapViewport"
	clip_area.clip_contents = true
	clip_area.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(clip_area)
	clip_area.gui_input.connect(_on_clip_area_gui_input)

	movable_map = Control.new()
	movable_map.name = "MovableMap"
	movable_map.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_area.add_child(movable_map)

	map_texture = TextureRect.new()
	map_texture.name = "WaterbodyMapTexture"
	map_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_texture.stretch_mode = TextureRect.STRETCH_SCALE
	map_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	movable_map.add_child(map_texture)

	fallback_tint = ColorRect.new()
	fallback_tint.name = "WaterbodyMapFallbackTint"
	fallback_tint.color = Color(0.02, 0.05, 0.05, 0.18)
	fallback_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	movable_map.add_child(fallback_tint)

	marker_layer = Control.new()
	marker_layer.name = "WaterbodyMapMarkerLayer"
	marker_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	movable_map.add_child(marker_layer)

	title_label = Label.new()
	title_label.name = "WaterbodyMapTitle"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.98, 0.94, 0.72, 1.0))
	title_label.add_theme_stylebox_override("normal", _make_panel_style(Color(0.03, 0.05, 0.035, 0.84), Color(0.82, 0.62, 0.28, 0.72), 8, 2))
	title_label.visible = false
	add_child(title_label)

	placeholder_label = Label.new()
	placeholder_label.name = "WaterbodyMapPlaceholder"
	placeholder_label.text = "Карта водоёма в разработке"
	placeholder_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placeholder_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	placeholder_label.add_theme_font_size_override("font_size", 22)
	placeholder_label.add_theme_color_override("font_color", Color(0.98, 0.94, 0.72, 1.0))
	placeholder_label.add_theme_stylebox_override("normal", _make_panel_style(Color(0.03, 0.05, 0.035, 0.86), Color(0.82, 0.62, 0.28, 0.72), 8, 2))
	placeholder_label.visible = false
	add_child(placeholder_label)

	waterbodies_button = Button.new()
	waterbodies_button.name = "BackToWaterbodiesButton"
	# TODO: Rename to "Карта мира" / "Мир" when the global map becomes a broader hub.
	waterbodies_button.text = "К водоёмам"
	waterbodies_button.focus_mode = Control.FOCUS_NONE
	waterbodies_button.pressed.connect(func(): global_requested.emit())
	add_child(waterbodies_button)

	shop_button = Button.new()
	shop_button.name = "WaterbodyMapShopButton"
	shop_button.text = "Магазин"
	shop_button.focus_mode = Control.FOCUS_NONE
	shop_button.pressed.connect(func(): shop_requested.emit())
	add_child(shop_button)

	home_button = Button.new()
	home_button.name = "WaterbodyMapFisherHomeButton"
	home_button.text = "Дом рыбака"
	home_button.focus_mode = Control.FOCUS_NONE
	home_button.pressed.connect(func(): fisher_home_requested.emit())
	add_child(home_button)

	harbor_button = Button.new()
	harbor_button.name = "WaterbodyMapHarborButton"
	harbor_button.text = "Гавань"
	harbor_button.focus_mode = Control.FOCUS_NONE
	harbor_button.pressed.connect(func(): harbor_requested.emit())
	add_child(harbor_button)

	close_button = Button.new()
	close_button.name = "CloseWaterbodyMapButton"
	close_button.text = "Закрыть"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(func(): close_requested.emit())
	add_child(close_button)

	spot_info_panel = SpotInfoPanelScript.new()
	spot_info_panel.name = "SpotInfoPanel"
	add_child(spot_info_panel)
	spot_info_panel.call("setup_panel")
	spot_info_panel.connect("select_requested", Callable(self, "_on_info_select_requested"))

	_apply_small_button_style(waterbodies_button)
	_apply_small_button_style(home_button)
	_apply_small_button_style(shop_button)
	_apply_small_button_style(harbor_button)
	_apply_small_button_style(close_button)

func _apply_map_texture() -> void:
	var path := str(waterbody_data.get("map_asset", ""))
	var texture: Texture2D = null
	if path != "" and (ResourceLoader.exists(path) or FileAccess.file_exists(path)):
		texture = load(path) as Texture2D
	if texture == null:
		texture = FALLBACK_MAP_TEXTURE
	map_texture.texture = texture
	fallback_tint.visible = path == "" or texture == FALLBACK_MAP_TEXTURE
	placeholder_label.visible = path == "" or texture == FALLBACK_MAP_TEXTURE

func _rebuild_markers() -> void:
	for marker in marker_nodes:
		if marker != null:
			marker.queue_free()
	marker_nodes.clear()

	var waterbody_id := str(waterbody_data.get("id", ""))
	var spots: Array = SpotDatabase.get_spots_for_waterbody(waterbody_id)
	var display_index := 1
	for spot in spots:
		if not (spot is Dictionary):
			continue
		var marker_spot: Dictionary = (spot as Dictionary).duplicate(true)
		if not marker_spot.has("map_order"):
			marker_spot["map_order"] = display_index
		var spot_id := str(marker_spot.get("id", ""))
		var marker: Control = MapSpotMarkerScript.new()
		marker_layer.add_child(marker)
		var unlocked: bool = _can_use_spot(spot_id) and PlayerData.can_use_waterbody(waterbody_id)
		var current: bool = waterbody_id == PlayerData.current_waterbody and spot_id == PlayerData.current_spot
		if marker.has_method("set_baked_map_controls"):
			marker.call("set_baked_map_controls", _uses_baked_map_controls())
		marker.call("setup_marker", waterbody_id, marker_spot, unlocked, current)
		if marker.has_method("set_selected"):
			marker.call("set_selected", spot_id == _selected_spot_id)
		marker.connect("spot_pressed", Callable(self, "_on_marker_spot_pressed"))
		marker.connect("info_pressed", Callable(self, "_on_marker_info_pressed"))
		marker_nodes.append(marker)
		display_index += 1

func _can_use_spot(spot_id: String) -> bool:
	if PlayerData.has_method("can_use_spot"):
		return bool(PlayerData.call("can_use_spot", spot_id))
	var spot: Dictionary = SpotDatabase.get_spot(spot_id)
	if spot.is_empty():
		return false
	return PlayerData.level >= int(spot.get("required_level", spot.get("unlock_level", 1))) and bool(spot.get("is_unlocked", true))

func _get_lock_reason(waterbody_id: String, spot: Dictionary) -> String:
	if not PlayerData.can_use_waterbody(waterbody_id):
		var waterbody_level := int(waterbody_data.get("required_level", 1))
		return "Водоём откроется на LVL %d." % waterbody_level
	var required_level := int(spot.get("required_level", spot.get("unlock_level", 1)))
	if PlayerData.level < required_level:
		return "Точка откроется на LVL %d." % required_level
	return "Эта точка пока закрыта."

func _find_spot(spot_id: String) -> Dictionary:
	var spots: Array = SpotDatabase.get_spots_for_waterbody(str(waterbody_data.get("id", "")))
	for spot in spots:
		if spot is Dictionary and str((spot as Dictionary).get("id", "")) == spot_id:
			return (spot as Dictionary).duplicate(true)
	return {}

func _get_drawn_map_rect(view_size: Vector2) -> Rect2:
	if _map_draw_size.x > 0.0 and _map_draw_size.y > 0.0:
		return Rect2(_map_position, _map_draw_size)

	var texture_size := Vector2.ZERO
	if map_texture != null and map_texture.texture != null:
		texture_size = Vector2(map_texture.texture.get_width(), map_texture.texture.get_height())
	else:
		var data_size = waterbody_data.get("map_size", view_size)
		if data_size is Vector2:
			texture_size = data_size as Vector2

	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Rect2(Vector2.ZERO, view_size)

	var scale_factor: float = minf(view_size.x / texture_size.x, view_size.y / texture_size.y)
	if map_texture != null and map_texture.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED:
		scale_factor = maxf(view_size.x / texture_size.x, view_size.y / texture_size.y)
	var drawn_size: Vector2 = texture_size * scale_factor
	var offset: Vector2 = (view_size - drawn_size) * 0.5
	return Rect2(offset, drawn_size)

func _get_initial_selected_spot_id(waterbody_id: String) -> String:
	if main != null and str(main._selected_waterbody_id) == waterbody_id and str(main._selected_waterbody_spot_id) != "":
		return str(main._selected_waterbody_spot_id)
	if waterbody_id == PlayerData.current_waterbody and PlayerData.current_spot != "":
		return str(PlayerData.current_spot)
	var spots: Array = SpotDatabase.get_spots_for_waterbody(waterbody_id)
	if not spots.is_empty() and spots[0] is Dictionary:
		return str((spots[0] as Dictionary).get("id", ""))
	return ""

func _get_map_texture_size(view_size: Vector2) -> Vector2:
	if map_texture != null and map_texture.texture != null:
		return Vector2(map_texture.texture.get_width(), map_texture.texture.get_height())

	var data_size = waterbody_data.get("map_size", view_size)
	if data_size is Vector2:
		return data_size as Vector2
	return view_size

func _get_map_scale(view_size: Vector2, texture_size: Vector2) -> float:
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return 1.0
	var cover_scale: float = maxf(view_size.x / texture_size.x, view_size.y / texture_size.y)
	if waterbody_data.has("map_zoom_scale"):
		var requested_scale: float = clampf(float(waterbody_data.get("map_zoom_scale", 1.0)), 0.1, 4.0)
		var min_view_multiplier: float = maxf(float(waterbody_data.get("map_min_view_multiplier", 1.0)), 1.0)
		return maxf(requested_scale, cover_scale * min_view_multiplier)
	return maxf(1.0, cover_scale)

func _get_initial_map_position(view_size: Vector2) -> Vector2:
	var focus_point := _get_spot_map_point(_selected_spot_id)
	var target_position := view_size * 0.5 - focus_point
	return _clamp_map_position(target_position, view_size)

func _get_spot_map_point(spot_id: String) -> Vector2:
	var spot := _find_spot(spot_id)
	if spot.is_empty():
		return _map_draw_size * 0.5
	var raw_position = spot.get("map_position", Vector2(0.5, 0.5))
	if raw_position is Vector2:
		var normalized_position: Vector2 = raw_position
		return Vector2(
			clampf(normalized_position.x, 0.0, 1.0),
			clampf(normalized_position.y, 0.0, 1.0)
		) * _map_draw_size
	return _map_draw_size * 0.5

func _clamp_map_position(candidate: Vector2, view_size: Vector2) -> Vector2:
	var clamped_position := candidate
	if _map_draw_size.x <= view_size.x:
		clamped_position.x = (view_size.x - _map_draw_size.x) * 0.5
	else:
		clamped_position.x = clampf(candidate.x, view_size.x - _map_draw_size.x, 0.0)

	if _map_draw_size.y <= view_size.y:
		clamped_position.y = (view_size.y - _map_draw_size.y) * 0.5
	else:
		clamped_position.y = clampf(candidate.y, view_size.y - _map_draw_size.y, 0.0)

	return clamped_position

func _on_clip_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_event.pressed:
			_begin_map_drag(mouse_event.position)
		else:
			_end_map_drag(mouse_event.position)
	elif event is InputEventMouseMotion:
		var motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		if _drag_active and (motion_event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			_update_map_drag(motion_event.position)
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			_begin_map_drag(touch_event.position)
		else:
			_end_map_drag(touch_event.position)
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		if _drag_active:
			_update_map_drag(drag_event.position)

func _begin_map_drag(pointer_position: Vector2) -> void:
	_drag_active = true
	_dragging_map = false
	_drag_start_position = pointer_position
	_drag_start_map_position = _map_position

func _update_map_drag(pointer_position: Vector2) -> void:
	if not _drag_active:
		return
	var drag_delta := pointer_position - _drag_start_position
	if not _dragging_map and drag_delta.length() < MAP_DRAG_THRESHOLD:
		return

	_dragging_map = true
	_map_position = _clamp_map_position(_drag_start_map_position + drag_delta, size)
	if movable_map != null:
		movable_map.position = _map_position
	get_viewport().set_input_as_handled()

func _end_map_drag(_pointer_position: Vector2) -> void:
	if _dragging_map:
		_suppress_marker_press_until_msec = Time.get_ticks_msec() + MARKER_PRESS_SUPPRESS_MS
		get_viewport().set_input_as_handled()
	_drag_active = false
	_dragging_map = false

func _marker_press_blocked() -> bool:
	return _dragging_map or Time.get_ticks_msec() <= _suppress_marker_press_until_msec

func _update_marker_selection() -> void:
	for marker in marker_nodes:
		if marker != null and marker.has_method("set_selected"):
			var marker_spot_id := str(marker.get("spot_id"))
			marker.call("set_selected", marker_spot_id == _selected_spot_id)

func _on_marker_spot_pressed(waterbody_id: String, spot_id: String) -> void:
	if _marker_press_blocked():
		return
	var spot := _find_spot(spot_id)
	if spot.is_empty():
		return
	_selected_spot_id = spot_id
	_update_marker_selection()
	var unlocked := _can_use_spot(spot_id) and PlayerData.can_use_waterbody(waterbody_id)
	var reason := "" if unlocked else _get_lock_reason(waterbody_id, spot)
	if reason != "" and main != null:
		main._show_toast(reason, false)
	spot_info_panel.call("show_spot", waterbody_data, spot, unlocked, reason)
	spot_info_panel.call("layout_panel", size)

func _on_marker_info_pressed(waterbody_id: String, spot_id: String) -> void:
	var spot := _find_spot(spot_id)
	if spot.is_empty():
		return
	var unlocked := _can_use_spot(spot_id) and PlayerData.can_use_waterbody(waterbody_id)
	var reason := "" if unlocked else _get_lock_reason(waterbody_id, spot)
	spot_info_panel.call("show_spot", waterbody_data, spot, unlocked, reason, true)
	spot_info_panel.call("layout_panel", size)

func _on_info_select_requested(waterbody_id: String, spot_id: String) -> void:
	spot_selected.emit(waterbody_id, spot_id)

func _apply_small_button_style(button: Button) -> void:
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color(0.92, 1.0, 0.90, 1.0))
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.025, 0.050, 0.045, 0.88), Color(0.70, 0.95, 0.72, 0.48), 10, 2))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.060, 0.160, 0.100, 0.96), Color(0.86, 1.0, 0.76, 0.78), 10, 2))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.035, 0.105, 0.065, 0.98), Color(0.62, 0.92, 0.62, 0.82), 10, 2))

func _uses_baked_map_controls() -> bool:
	return bool(waterbody_data.get("map_controls_baked", false))

func _layout_baked_action_button(button: Button, rect_key: String, tooltip: String, map_rect: Rect2) -> void:
	if button == null:
		return
	var normalized_rect: Rect2 = BAKED_ACTION_BUTTON_RECTS.get(rect_key, Rect2())
	var button_position := map_rect.position + Vector2(
		normalized_rect.position.x * map_rect.size.x,
		normalized_rect.position.y * map_rect.size.y
	)
	var button_size := Vector2(
		normalized_rect.size.x * map_rect.size.x,
		normalized_rect.size.y * map_rect.size.y
	)
	button.position = button_position
	button.size = button_size
	button.custom_minimum_size = button_size
	button.visible = true
	button.disabled = false
	button.text = ""
	button.tooltip_text = tooltip
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_hitbox_button_style(button)

func _prepare_visible_action_button(button: Button, text: String) -> void:
	if button == null:
		return
	button.visible = true
	button.disabled = false
	button.text = text
	button.tooltip_text = ""
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_small_button_style(button)

func _apply_hitbox_button_style(button: Button) -> void:
	var style := _make_hitbox_style()
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_stylebox_override("disabled", style)
	button.add_theme_stylebox_override("focus", style)
	button.add_theme_color_override("font_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_disabled_color", Color.TRANSPARENT)
	button.add_theme_font_size_override("font_size", 1)

func _make_hitbox_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = Color.TRANSPARENT
	style.shadow_color = Color.TRANSPARENT
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	return style

func _make_panel_style(fill: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.30)
	style.shadow_size = 7
	return style
