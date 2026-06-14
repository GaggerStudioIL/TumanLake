extends Node2D

@export var star_count: int = 58
@export var star_color: Color = Color(0.86, 0.94, 1.0, 1.0)
@export var max_alpha: float = 0.48
@export var horizon_y_ratio: float = 0.58
@export var sky_padding_ratio: float = 0.08
@export var twinkle_strength: float = 0.12
@export var sky_fill_ratio: float = 0.62
@export var horizon_clearance_ratio: float = 0.16

var _stars: Array[Dictionary] = []
var _viewport_size: Vector2 = Vector2.ZERO
var _alpha: float = 0.0
var _time: float = 0.0
var _sky_rect: Rect2 = Rect2()
var _has_sky_rect := false
var _horizon_y: float = 0.0
var _has_horizon_y := false

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

func set_sky_bounds(sky_rect: Rect2, horizon_y: float) -> void:
	_has_sky_rect = sky_rect.size.x > 1.0 and sky_rect.size.y > 1.0
	_sky_rect = sky_rect
	_has_horizon_y = horizon_y > 1.0
	_horizon_y = horizon_y
	_generate_stars()
	queue_redraw()

func _generate_stars() -> void:
	_stars.clear()
	if _viewport_size.x <= 0.0 or _viewport_size.y <= 0.0:
		return

	var rng := RandomNumberGenerator.new()
	rng.seed = 823741
	var sky_rect := _get_effective_sky_rect()
	var padding_x: float = maxf(_viewport_size.x * 0.025, sky_rect.size.x * 0.035)
	var left_x: float = clampf(sky_rect.position.x + padding_x, 0.0, _viewport_size.x)
	var right_x: float = clampf(sky_rect.end.x - padding_x, left_x + 1.0, _viewport_size.x)
	var horizon_y: float = _horizon_y if _has_horizon_y else _viewport_size.y * horizon_y_ratio
	var top_y: float = maxf(sky_rect.position.y + _viewport_size.y * 0.025, _viewport_size.y * 0.04)
	var sky_bottom_y: float = sky_rect.position.y + sky_rect.size.y * clampf(sky_fill_ratio, 0.40, 0.78)
	var horizon_bottom_y: float = horizon_y - _viewport_size.y * clampf(horizon_clearance_ratio, 0.08, 0.26)
	var bottom_y: float = minf(sky_bottom_y, horizon_bottom_y)
	var min_band_height: float = maxf(_viewport_size.y * 0.08, 28.0)
	if bottom_y < top_y + min_band_height:
		bottom_y = minf(
			sky_rect.position.y + sky_rect.size.y * 0.74,
			horizon_y - _viewport_size.y * 0.08
		)
	if bottom_y <= top_y:
		return

	for _index in range(maxi(star_count, 0)):
		_stars.append({
			"position": Vector2(
				rng.randf_range(left_x, right_x),
				rng.randf_range(top_y, bottom_y)
			),
			"radius": rng.randf_range(0.55, 1.25),
			"alpha": rng.randf_range(0.42, 1.0),
			"phase": rng.randf_range(0.0, TAU)
		})

func _get_effective_sky_rect() -> Rect2:
	if _has_sky_rect:
		return Rect2(
			Vector2(
				clampf(_sky_rect.position.x, 0.0, _viewport_size.x),
				clampf(_sky_rect.position.y, 0.0, _viewport_size.y)
			),
			Vector2(
				clampf(_sky_rect.size.x, 1.0, _viewport_size.x),
				clampf(_sky_rect.size.y, 1.0, _viewport_size.y)
			)
		)

	var padding_x: float = _viewport_size.x * sky_padding_ratio
	var top_y: float = _viewport_size.y * 0.07
	var bottom_y: float = _viewport_size.y * maxf(horizon_y_ratio - 0.11, 0.18)
	return Rect2(
		Vector2(padding_x, top_y),
		Vector2(maxf(_viewport_size.x - padding_x * 2.0, 1.0), maxf(bottom_y - top_y, 1.0))
	)

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
