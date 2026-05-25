extends Node2D

@export var star_count: int = 58
@export var star_color: Color = Color(0.86, 0.94, 1.0, 1.0)
@export var max_alpha: float = 0.48
@export var horizon_y_ratio: float = 0.58
@export var sky_padding_ratio: float = 0.08
@export var twinkle_strength: float = 0.12

var _stars: Array[Dictionary] = []
var _viewport_size: Vector2 = Vector2.ZERO
var _alpha: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	_generate_stars()

func _process(delta: float) -> void:
	_time += delta
	if visible and _alpha > 0.001:
		queue_redraw()

func set_viewport_size(size: Vector2) -> void:
	if _viewport_size.is_equal_approx(size):
		return

	_viewport_size = size
	_generate_stars()
	queue_redraw()

func set_star_alpha(value: float) -> void:
	_alpha = clampf(value, 0.0, 1.0)
	visible = _alpha > 0.001
	queue_redraw()

func set_horizon_y_ratio(value: float) -> void:
	horizon_y_ratio = clampf(value, 0.30, 0.82)
	_generate_stars()
	queue_redraw()

func _generate_stars() -> void:
	_stars.clear()
	if _viewport_size.x <= 0.0 or _viewport_size.y <= 0.0:
		return

	var rng := RandomNumberGenerator.new()
	rng.seed = 823741
	var padding_x: float = _viewport_size.x * sky_padding_ratio
	var top_y: float = _viewport_size.y * 0.07
	var bottom_y: float = _viewport_size.y * maxf(horizon_y_ratio - 0.11, 0.18)

	for _index in range(maxi(star_count, 0)):
		_stars.append({
			"position": Vector2(
				rng.randf_range(padding_x, _viewport_size.x - padding_x),
				rng.randf_range(top_y, bottom_y)
			),
			"radius": rng.randf_range(0.55, 1.25),
			"alpha": rng.randf_range(0.42, 1.0),
			"phase": rng.randf_range(0.0, TAU)
		})

func _draw() -> void:
	if _alpha <= 0.001:
		return

	for star in _stars:
		var position: Vector2 = star.get("position", Vector2.ZERO)
		var radius: float = float(star.get("radius", 1.0))
		var star_alpha: float = float(star.get("alpha", 1.0))
		var phase: float = float(star.get("phase", 0.0))
		var twinkle: float = 1.0 + sin(_time * 0.55 + phase) * twinkle_strength
		var color: Color = star_color
		color.a = clampf(_alpha * max_alpha * star_alpha * twinkle, 0.0, max_alpha)
		draw_circle(position, radius, color)
