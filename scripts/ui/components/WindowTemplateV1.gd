extends RefCounted

const BASE_SIZE := Vector2(960.0, 540.0)
const MIN_GRID_COLUMNS := 4
const MAX_GRID_COLUMNS := 6


static func viewport_scale(viewport_size: Vector2) -> float:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return 1.0
	return clampf(minf(viewport_size.x / BASE_SIZE.x, viewport_size.y / BASE_SIZE.y), 0.72, 1.28)


static func get_window_rect(viewport_size: Vector2) -> Rect2:
	var scale: float = viewport_scale(viewport_size)
	var outer_margin: float = clampf(10.0 * scale, 6.0, 18.0)
	var available: Vector2 = Vector2(
		maxf(viewport_size.x - outer_margin * 2.0, 1.0),
		maxf(viewport_size.y - outer_margin * 2.0, 1.0)
	)
	var max_size: Vector2 = Vector2(940.0 * scale, 520.0 * scale)
	var min_size: Vector2 = Vector2(minf(640.0 * scale, available.x), minf(360.0 * scale, available.y))
	var window_size: Vector2 = Vector2(
		clampf(minf(available.x, max_size.x), min_size.x, available.x),
		clampf(minf(available.y, max_size.y), min_size.y, available.y)
	)
	return Rect2((viewport_size - window_size) * 0.5, window_size)


static func get_metrics(window_size: Vector2) -> Dictionary:
	var scale: float = clampf(minf(window_size.x / 940.0, window_size.y / 520.0), 0.72, 1.18)
	var padding: float = clampf(14.0 * scale, 9.0, 18.0)
	var gap: float = clampf(10.0 * scale, 7.0, 14.0)
	var header_height: float = clampf(38.0 * scale, 30.0, 44.0)
	var tab_height: float = clampf(42.0 * scale, 34.0, 46.0)
	var toolbar_height: float = clampf(36.0 * scale, 30.0, 40.0)
	var footer_height: float = clampf(34.0 * scale, 30.0, 40.0)
	return {
		"scale": scale,
		"padding": padding,
		"gap": gap,
		"header_height": header_height,
		"tab_height": tab_height,
		"toolbar_height": toolbar_height,
		"footer_height": footer_height,
		"tab_button_width": clampf(104.0 * scale, 82.0, 118.0),
		"tab_button_height": clampf(36.0 * scale, 30.0, 40.0),
		"chip_width": clampf(78.0 * scale, 66.0, 92.0),
		"chip_height": clampf(30.0 * scale, 26.0, 34.0),
		"close_size": clampf(34.0 * scale, 30.0, 40.0)
	}


static func get_inventory_content_layout(window_size: Vector2) -> Dictionary:
	var metrics: Dictionary = get_metrics(window_size)
	var padding: float = metrics.get("padding", 14.0)
	var gap: float = metrics.get("gap", 10.0)
	var header_height: float = metrics.get("header_height", 38.0)
	var tab_height: float = metrics.get("tab_height", 42.0)
	var toolbar_height: float = metrics.get("toolbar_height", 36.0)
	var footer_height: float = metrics.get("footer_height", 34.0)
	var content_y: float = padding + header_height + gap + tab_height + gap + toolbar_height + gap
	var footer_y: float = window_size.y - padding - footer_height
	var content_height: float = maxf(footer_y - content_y - gap, 120.0)
	var inner_width: float = maxf(window_size.x - padding * 2.0, 1.0)
	var details_width: float = clampf(inner_width * 0.32, 238.0 * float(metrics.get("scale", 1.0)), 306.0 * float(metrics.get("scale", 1.0)))
	if inner_width < 650.0:
		details_width = clampf(inner_width * 0.34, 190.0, 250.0)
	var grid_width: float = maxf(inner_width - details_width - gap, 260.0)
	return {
		"padding": padding,
		"gap": gap,
		"header_pos": Vector2(padding, padding),
		"header_size": Vector2(inner_width, header_height),
		"tab_pos": Vector2(padding, padding + header_height + gap),
		"tab_size": Vector2(inner_width, tab_height),
		"toolbar_pos": Vector2(padding, padding + header_height + gap + tab_height + gap),
		"toolbar_size": Vector2(inner_width, toolbar_height),
		"content_pos": Vector2(padding, content_y),
		"content_size": Vector2(inner_width, content_height),
		"grid_pos": Vector2(padding, content_y),
		"grid_size": Vector2(grid_width, content_height),
		"details_pos": Vector2(padding + grid_width + gap, content_y),
		"details_size": Vector2(details_width, content_height),
		"footer_pos": Vector2(padding, footer_y),
		"footer_size": Vector2(inner_width, footer_height)
	}


static func get_grid_columns(grid_width: float) -> int:
	var target_width: float = 154.0
	var gap: float = 10.0
	var columns: int = int(floor((grid_width + gap) / (target_width + gap)))
	return clampi(columns, MIN_GRID_COLUMNS, MAX_GRID_COLUMNS)


static func get_grid_card_size(grid_width: float, columns: int, gap: float) -> Vector2:
	var safe_columns: int = clampi(columns, MIN_GRID_COLUMNS, MAX_GRID_COLUMNS)
	var card_width: float = floor((grid_width - gap * float(safe_columns - 1)) / float(safe_columns))
	var card_height: float = clampf(card_width * 1.08, 126.0, 166.0)
	return Vector2(maxf(card_width, 96.0), card_height)


static func apply_full_rect(control: Control, viewport_size: Vector2) -> void:
	if control == null:
		return
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.position = Vector2.ZERO
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0
	control.scale = Vector2.ONE
