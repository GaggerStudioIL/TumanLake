extends Node2D

@export var ripple_color_1: Color = Color(0.88, 0.94, 0.96, 0.16)
@export var ripple_color_2: Color = Color(0.88, 0.94, 0.96, 0.08)
@export var radius_x_1: float = 14.0
@export var radius_y_1: float = 3.0
@export var radius_x_2: float = 24.0
@export var radius_y_2: float = 5.0
@export var pulse_speed: float = 1.65
@export var pulse_amount: float = 1.25

var time := 0.0

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	var pulse := sin(time * pulse_speed) * pulse_amount
	draw_ellipse_outline(Vector2.ZERO, radius_x_1 + pulse, radius_y_1, ripple_color_1, 0.85)
	draw_ellipse_outline(Vector2.ZERO, radius_x_2 + pulse * 0.7, radius_y_2, ripple_color_2, 0.75)

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
