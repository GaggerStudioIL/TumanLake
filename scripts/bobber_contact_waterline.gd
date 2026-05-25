extends Node2D

@export var shadow_color: Color = Color(0.03, 0.08, 0.075, 0.24)
@export var front_crest_color: Color = Color(0.82, 0.93, 0.92, 0.34)
@export var back_crest_color: Color = Color(0.72, 0.86, 0.86, 0.18)
@export var radius_x: float = 16.0
@export var radius_y: float = 3.4
@export var pulse_speed: float = 1.25
@export var pulse_amount: float = 0.7

var time: float = 0.0

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	var pulse: float = sin(time * pulse_speed) * pulse_amount
	var rx: float = radius_x + pulse
	var ry: float = radius_y
	draw_colored_polygon(_ellipse_points(Vector2(0.0, 1.0), rx * 0.92, ry * 0.95, 32), shadow_color)
	draw_polyline(_ellipse_arc_points(Vector2.ZERO, rx, ry, PI * 1.02, PI * 1.98, 24), back_crest_color, 0.9, true)
	draw_polyline(_ellipse_arc_points(Vector2.ZERO, rx, ry, 0.02, PI * 0.98, 24), front_crest_color, 1.35, true)
	draw_line(Vector2(-5.2, 0.4), Vector2(5.2, 0.4), front_crest_color, 1.25, true)

func _ellipse_points(center: Vector2, rx: float, ry: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(max(segments, 12)):
		var angle := TAU * float(i) / float(max(segments, 12))
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	return points

func _ellipse_arc_points(center: Vector2, rx: float, ry: float, start_angle: float, end_angle: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	var safe_segments: int = max(segments, 4)
	for i in range(safe_segments + 1):
		var t := float(i) / float(safe_segments)
		var angle := lerpf(start_angle, end_angle, t)
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	return points
