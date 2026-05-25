extends Control

var effect_name := ""
var effect_time := 0.0
var particles: Array = []

func configure(next_effect_name: String) -> void:
	effect_name = next_effect_name
	effect_time = 0.0
	particles.clear()
	var count := 42
	if effect_name == "rain" or effect_name == "city":
		count = 70
	elif effect_name == "road":
		count = 34
	elif effect_name == "none":
		count = 0

	for index in range(count):
		particles.append({
			"x": randf(),
			"y": randf(),
			"speed": randf_range(0.35, 1.0),
			"size": randf_range(0.45, 1.35),
			"phase": randf_range(0.0, TAU)
		})
	queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func _process(delta: float) -> void:
	effect_time += delta
	queue_redraw()

func _draw() -> void:
	var rect_size := size
	if rect_size.x <= 1.0 or rect_size.y <= 1.0:
		return

	match effect_name:
		"rain":
			_draw_rain(rect_size, Color(0.72, 0.82, 0.92, 0.30))
		"city":
			_draw_rain(rect_size, Color(0.62, 0.72, 0.88, 0.23))
			_draw_neon_haze(rect_size)
			_draw_crowd_shadows(rect_size)
		"balcony":
			_draw_particles(rect_size, Color(1.0, 0.75, 0.40, 0.28), 20.0, 0.28)
			_draw_film_grain(rect_size)
		"lake_memory":
			_draw_particles(rect_size, Color(1.0, 0.77, 0.36, 0.30), 24.0, 0.20)
			_draw_birds(rect_size)
		"road":
			_draw_road_dust(rect_size)
			_draw_light_rays(rect_size, Color(1.0, 0.78, 0.42, 0.10))
		"lake":
			_draw_particles(rect_size, Color(1.0, 0.82, 0.45, 0.27), 26.0, 0.18)
			_draw_water_ripples(rect_size)
			_draw_birds(rect_size)
		"final":
			_draw_particles(rect_size, Color(1.0, 0.82, 0.54, 0.24), 28.0, 0.18)
			_draw_light_rays(rect_size, Color(1.0, 0.76, 0.38, 0.08))

func _draw_rain(rect_size: Vector2, rain_color: Color) -> void:
	for particle in particles:
		var px := fposmod(float(particle["x"]) * rect_size.x + effect_time * 46.0 * float(particle["speed"]), rect_size.x)
		var py := fposmod(float(particle["y"]) * rect_size.y + effect_time * 520.0 * float(particle["speed"]), rect_size.y)
		var length := 22.0 * float(particle["size"])
		draw_line(Vector2(px, py), Vector2(px - length * 0.25, py + length), rain_color, maxf(1.0, float(particle["size"])))

func _draw_fog(rect_size: Vector2, fog_color: Color, speed: float) -> void:
	for index in range(5):
		var y := rect_size.y * (0.15 + float(index) * 0.17)
		var x := sin(effect_time * speed * 0.18 + float(index)) * rect_size.x * 0.08
		var fog_rect := Rect2(Vector2(x - rect_size.x * 0.18, y), Vector2(rect_size.x * 1.36, 72.0 + float(index) * 18.0))
		draw_rect(fog_rect, fog_color)

func _draw_neon_haze(rect_size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, rect_size), Color(0.08, 0.14, 0.22, 0.10))
	var pulse := 0.5 + sin(effect_time * 1.4) * 0.5
	draw_circle(Vector2(rect_size.x * 0.82, rect_size.y * 0.32), rect_size.x * 0.30, Color(1.0, 0.42, 0.14, 0.06 + pulse * 0.035))
	draw_circle(Vector2(rect_size.x * 0.20, rect_size.y * 0.34), rect_size.x * 0.22, Color(0.25, 0.54, 1.0, 0.045))

func _draw_crowd_shadows(rect_size: Vector2) -> void:
	for index in range(12):
		var x := fposmod(float(index) * rect_size.x * 0.11 + effect_time * (18.0 + float(index) * 2.0), rect_size.x + 120.0) - 60.0
		var height := 56.0 + float(index % 4) * 15.0
		draw_rect(Rect2(Vector2(x, rect_size.y - 150.0 - height * 0.2), Vector2(22.0, height)), Color(0.02, 0.025, 0.03, 0.18))

func _draw_particles(rect_size: Vector2, particle_color: Color, drift: float, alpha_scale: float) -> void:
	for particle in particles:
		var phase := float(particle["phase"])
		var px := fposmod(float(particle["x"]) * rect_size.x + sin(effect_time * 0.35 + phase) * drift, rect_size.x)
		var py := fposmod(float(particle["y"]) * rect_size.y - effect_time * 18.0 * float(particle["speed"]), rect_size.y)
		var radius := 1.4 + float(particle["size"]) * 1.7
		var color := particle_color
		color.a *= alpha_scale + sin(effect_time + phase) * 0.08
		draw_circle(Vector2(px, py), radius, color)

func _draw_film_grain(rect_size: Vector2) -> void:
	for index in range(42):
		var x := fposmod(float(index * 97) + effect_time * 9.0, rect_size.x)
		var y := fposmod(float(index * 53) + effect_time * 13.0, rect_size.y)
		draw_rect(Rect2(Vector2(x, y), Vector2(1.0, 1.0)), Color(1.0, 0.86, 0.62, 0.035))

func _draw_birds(rect_size: Vector2) -> void:
	for index in range(4):
		var base := Vector2(rect_size.x * (0.18 + float(index) * 0.14), rect_size.y * (0.15 + float(index % 2) * 0.04))
		var offset := Vector2(effect_time * (10.0 + float(index) * 3.0), sin(effect_time + float(index)) * 5.0)
		var pos := base + offset
		var wing := 7.0 + sin(effect_time * 2.0 + float(index)) * 2.0
		draw_line(pos, pos + Vector2(-wing, 4.0), Color(0.08, 0.07, 0.055, 0.45), 2.0)
		draw_line(pos, pos + Vector2(wing, 4.0), Color(0.08, 0.07, 0.055, 0.45), 2.0)

func _draw_road_dust(rect_size: Vector2) -> void:
	for particle in particles:
		var px := fposmod(float(particle["x"]) * rect_size.x - effect_time * 55.0 * float(particle["speed"]), rect_size.x)
		var py := rect_size.y * (0.58 + float(particle["y"]) * 0.30)
		draw_circle(Vector2(px, py), 7.0 * float(particle["size"]), Color(0.95, 0.70, 0.42, 0.08))

func _draw_light_rays(rect_size: Vector2, ray_color: Color) -> void:
	var origin := Vector2(rect_size.x * 0.05, rect_size.y * 0.12)
	for index in range(5):
		var spread := float(index) * 0.13 + sin(effect_time * 0.12 + float(index)) * 0.02
		var points := PackedVector2Array([
			origin,
			Vector2(rect_size.x * (0.26 + spread), rect_size.y),
			Vector2(rect_size.x * (0.18 + spread), rect_size.y)
		])
		draw_colored_polygon(points, ray_color)

func _draw_water_ripples(rect_size: Vector2) -> void:
	for index in range(4):
		var t := fposmod(effect_time * 0.23 + float(index) * 0.22, 1.0)
		var center := Vector2(rect_size.x * (0.33 + float(index) * 0.08), rect_size.y * (0.55 + float(index % 2) * 0.06))
		var rx := 30.0 + t * 92.0
		var ry := 6.0 + t * 18.0
		draw_arc(center, rx, 0.0, TAU, 44, Color(1.0, 0.82, 0.44, 0.13 * (1.0 - t)), 1.5)
		draw_arc(center, ry, 0.0, TAU, 44, Color(1.0, 0.82, 0.44, 0.05 * (1.0 - t)), 1.0)
