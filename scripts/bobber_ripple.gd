extends Node2D

@export var ripple_color_1: Color = Color(0.90, 0.96, 0.98, 0.30)
@export var ripple_color_2: Color = Color(0.90, 0.96, 0.98, 0.17)
@export var contact_shadow_color: Color = Color(0.02, 0.07, 0.075, 0.18)
@export var radius_x_1: float = 19.5
@export var radius_y_1: float = 3.8
@export var radius_x_2: float = 31.0
@export var radius_y_2: float = 6.2
@export var pulse_speed: float = 1.65
@export var pulse_amount: float = 1.25

var time: float = 0.0

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	var pulse: float = sin(time * pulse_speed) * pulse_amount
	draw_colored_polygon(_ellipse_points(Vector2(0.0, 1.0), radius_x_1 + pulse * 0.6, radius_y_1 + 1.2, 40), contact_shadow_color)
	draw_ellipse_outline(Vector2.ZERO, radius_x_1 + pulse, radius_y_1, ripple_color_1, 1.24)
	draw_ellipse_outline(Vector2.ZERO, radius_x_2 + pulse * 0.7, radius_y_2, ripple_color_2, 1.02)

func _ellipse_points(center: Vector2, rx: float, ry: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	var safe_segments: int = max(segments, 12)
	for i in range(safe_segments):
		var t := TAU * float(i) / float(safe_segments)
		points.append(Vector2(
			center.x + cos(t) * rx,
			center.y + sin(t) * ry
		))
	return points

func draw_ellipse_outline(
	center: Vector2,
	rx: float,
	ry: float,
	color: Color,
	width: float = 1.0,
	segments: int = 48
) -> void:
	var points := PackedVector2Array()

	for i in range(segments + 1):
		var t := TAU * float(i) / float(segments)
		points.append(Vector2(
			center.x + cos(t) * rx,
			center.y + sin(t) * ry
		))

	draw_polyline(points, color, width, true)
