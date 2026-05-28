extends Control

var _values: Array = []


func set_history(history: Array) -> void:
	_values.clear()
	for entry in history:
		if typeof(entry) == TYPE_DICTIONARY:
			_values.append(float((entry as Dictionary).get("demand", 1.0)))
		elif typeof(entry) == TYPE_FLOAT or typeof(entry) == TYPE_INT:
			_values.append(float(entry))
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color(0.012, 0.025, 0.028, 0.78), true)
	draw_rect(rect.grow(-0.5), Color(0.55, 0.88, 0.86, 0.26), false, 1.0)

	var plot := rect.grow(-14.0)
	plot.position.y += 4.0
	plot.size.y -= 8.0
	if plot.size.x <= 4.0 or plot.size.y <= 4.0:
		return

	for i in range(3):
		var y := plot.position.y + plot.size.y * (float(i + 1) / 4.0)
		draw_line(Vector2(plot.position.x, y), Vector2(plot.end.x, y), Color(0.55, 0.88, 0.86, 0.09), 1.0)

	if _values.size() < 2:
		return

	var min_value := float(_values[0])
	var max_value := float(_values[0])
	for value in _values:
		min_value = minf(min_value, float(value))
		max_value = maxf(max_value, float(value))
	if is_equal_approx(min_value, max_value):
		min_value -= 0.1
		max_value += 0.1

	var points := PackedVector2Array()
	var denom := float(maxi(_values.size() - 1, 1))
	for i in range(_values.size()):
		var value := float(_values[i])
		var x := plot.position.x + plot.size.x * (float(i) / denom)
		var normalized := clampf((value - min_value) / (max_value - min_value), 0.0, 1.0)
		var y := plot.end.y - plot.size.y * normalized
		points.append(Vector2(x, y))

	draw_polyline(points, Color(0.48, 0.96, 0.88, 0.95), 2.0, true)
	for point in points:
		draw_circle(point, 3.2, Color(0.76, 1.0, 0.94, 1.0))
		draw_circle(point, 5.4, Color(0.48, 0.96, 0.88, 0.16))
