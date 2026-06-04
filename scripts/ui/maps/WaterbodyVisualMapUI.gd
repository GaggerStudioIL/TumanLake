extends Control

signal spot_selected(waterbody_id: String, spot_id: String)
signal global_requested
signal close_requested

const MapSpotMarkerScript := preload("res://scripts/ui/maps/MapSpotMarker.gd")
const SpotInfoPanelScript := preload("res://scripts/ui/maps/SpotInfoPanel.gd")
const FALLBACK_MAP_TEXTURE: Texture2D = preload("res://assets/environment/lake/lake_bg_base.png.png")

var main
var waterbody_data: Dictionary = {}
var marker_nodes: Array = []

var map_texture: TextureRect
var fallback_tint: ColorRect
var marker_layer: Control
var title_label: Label
var placeholder_label: Label
var waterbodies_button: Button
var close_button: Button
var spot_info_panel

func setup(owner) -> void:
	main = owner
	_ensure_nodes()
	visible = false

func show_waterbody(waterbody: Dictionary) -> void:
	_ensure_nodes()
	waterbody_data = waterbody.duplicate(true)
	visible = true
	title_label.text = ""
	_apply_map_texture()
	_rebuild_markers()
	layout_map()

func layout_map() -> void:
	if map_texture == null:
		return

	var view_size: Vector2 = size
	map_texture.position = Vector2.ZERO
	map_texture.size = view_size
	fallback_tint.position = Vector2.ZERO
	fallback_tint.size = view_size
	marker_layer.position = Vector2.ZERO
	marker_layer.size = view_size
	placeholder_label.position = Vector2(view_size.x * 0.5 - 210.0, view_size.y * 0.5 - 34.0)
	placeholder_label.size = Vector2(420.0, 68.0)

	var top_margin: float = maxf(12.0, view_size.y * 0.024)
	title_label.position = Vector2.ZERO
	title_label.size = Vector2.ZERO
	waterbodies_button.position = Vector2(18.0, top_margin + 2.0)
	waterbodies_button.size = Vector2(136.0, 38.0)
	close_button.position = Vector2(view_size.x - 112.0, top_margin + 2.0)
	close_button.size = Vector2(94.0, 38.0)

	var marker_size: float = clampf(view_size.y * 0.078, 38.0, 50.0)
	var info_size: float = clampf(view_size.y * 0.044, 22.0, 28.0)
	var map_rect: Rect2 = _get_drawn_map_rect(view_size)
	for marker in marker_nodes:
		if marker != null and marker.has_method("layout_marker"):
			marker.call("layout_marker", map_rect, marker_size, info_size)

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

	map_texture = TextureRect.new()
	map_texture.name = "WaterbodyMapTexture"
	map_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	map_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(map_texture)

	fallback_tint = ColorRect.new()
	fallback_tint.name = "WaterbodyMapFallbackTint"
	fallback_tint.color = Color(0.02, 0.05, 0.05, 0.18)
	fallback_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fallback_tint)

	marker_layer = Control.new()
	marker_layer.name = "WaterbodyMapMarkerLayer"
	marker_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(marker_layer)

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
	waterbodies_button.text = "Водоёмы"
	waterbodies_button.text = "К водоёмам"
	waterbodies_button.focus_mode = Control.FOCUS_NONE
	waterbodies_button.pressed.connect(func(): global_requested.emit())
	add_child(waterbodies_button)

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
	for spot in spots:
		if not (spot is Dictionary):
			continue
		var spot_id := str((spot as Dictionary).get("id", ""))
		var marker: Control = MapSpotMarkerScript.new()
		marker_layer.add_child(marker)
		var unlocked: bool = _can_use_spot(spot_id) and PlayerData.can_use_waterbody(waterbody_id)
		var current: bool = waterbody_id == PlayerData.current_waterbody and spot_id == PlayerData.current_spot
		marker.call("setup_marker", waterbody_id, spot, unlocked, current)
		marker.connect("spot_pressed", Callable(self, "_on_marker_spot_pressed"))
		marker.connect("info_pressed", Callable(self, "_on_marker_info_pressed"))
		marker_nodes.append(marker)

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
		return "Водоём откроется на %d уровне." % waterbody_level
	var required_level := int(spot.get("required_level", spot.get("unlock_level", 1)))
	if PlayerData.level < required_level:
		return "Точка откроется на %d уровне." % required_level
	return "Эта точка пока закрыта."

func _find_spot(spot_id: String) -> Dictionary:
	var spots: Array = SpotDatabase.get_spots_for_waterbody(str(waterbody_data.get("id", "")))
	for spot in spots:
		if spot is Dictionary and str((spot as Dictionary).get("id", "")) == spot_id:
			return (spot as Dictionary).duplicate(true)
	return {}

func _get_drawn_map_rect(view_size: Vector2) -> Rect2:
	var texture_size := Vector2.ZERO
	if map_texture != null and map_texture.texture != null:
		texture_size = Vector2(map_texture.texture.get_width(), map_texture.texture.get_height())
	else:
		var data_size = waterbody_data.get("map_size", view_size)
		if data_size is Vector2:
			texture_size = data_size as Vector2

	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Rect2(Vector2.ZERO, view_size)

	var scale_factor: float = maxf(view_size.x / texture_size.x, view_size.y / texture_size.y)
	var drawn_size: Vector2 = texture_size * scale_factor
	var offset: Vector2 = (view_size - drawn_size) * 0.5
	return Rect2(offset, drawn_size)

func _on_marker_spot_pressed(waterbody_id: String, spot_id: String) -> void:
	spot_selected.emit(waterbody_id, spot_id)

func _on_marker_info_pressed(waterbody_id: String, spot_id: String) -> void:
	var spot := _find_spot(spot_id)
	if spot.is_empty():
		return
	var unlocked := _can_use_spot(spot_id) and PlayerData.can_use_waterbody(waterbody_id)
	var reason := "" if unlocked else _get_lock_reason(waterbody_id, spot)
	spot_info_panel.call("show_spot", waterbody_data, spot, unlocked, reason)
	spot_info_panel.call("layout_panel", size)

func _on_info_select_requested(waterbody_id: String, spot_id: String) -> void:
	spot_selected.emit(waterbody_id, spot_id)

func _apply_small_button_style(button: Button) -> void:
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color(0.92, 1.0, 0.90, 1.0))
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.025, 0.050, 0.045, 0.88), Color(0.70, 0.95, 0.72, 0.48), 10, 2))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.060, 0.160, 0.100, 0.96), Color(0.86, 1.0, 0.76, 0.78), 10, 2))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.035, 0.105, 0.065, 0.98), Color(0.62, 0.92, 0.62, 0.82), 10, 2))

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
