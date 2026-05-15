# Handles fishing presence visuals: water, rod, line, and float.
extends RefCounted

var main
enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

func setup(main_ref) -> void:
	main = main_ref

func open() -> void:
	pass

func close() -> void:
	pass

func refresh(delta: float = 0.0) -> void:
	_update_fishing_presence(delta)

func is_open() -> bool:
	return main != null

func _configure_fishing_presence_style() -> void:
	main.fishing_presence_layer.z_index = 4

	for rod_line in [
		main.rod_shadow,
		main.rod_handle_shadow,
		main.rod_handle,
		main.rod_handle_wrap_a,
		main.rod_handle_wrap_b,
		main.rod_blank,
		main.rod_near_section,
		main.rod_mid_section,
		main.rod_tip_section,
		main.rod_highlight,
		main.rod_ferrule_near,
		main.rod_ferrule_mid,
		main.rod_ferrule_tip,
		main.rod_reel_stem,
		main.rod_reel_spool,
		main.rod_reel_handle
	]:
		rod_line.joint_mode = Line2D.LINE_JOINT_ROUND
		rod_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		rod_line.end_cap_mode = Line2D.LINE_CAP_ROUND

	main.rod_shadow.width = 11.0
	main.rod_shadow.default_color = Color(0.0, 0.0, 0.0, 0.24)
	main.rod_shadow.antialiased = true

	main.rod_handle_shadow.width = 16.0
	main.rod_handle_shadow.default_color = Color(0.0, 0.0, 0.0, 0.20)
	main.rod_handle_shadow.antialiased = true

	main.rod_handle.width = 14.0
	main.rod_handle.default_color = Color(0.12, 0.078, 0.047, 0.98)
	main.rod_handle.antialiased = true

	main.rod_handle_wrap_a.width = 2.0
	main.rod_handle_wrap_a.default_color = Color(0.86, 0.64, 0.34, 0.58)
	main.rod_handle_wrap_a.antialiased = true

	main.rod_handle_wrap_b.width = 2.0
	main.rod_handle_wrap_b.default_color = Color(0.86, 0.64, 0.34, 0.48)
	main.rod_handle_wrap_b.antialiased = true

	main.rod_blank.width = 6.0
	main.rod_blank.default_color = Color(0.13, 0.105, 0.065, 0.98)
	main.rod_blank.antialiased = true

	main.rod_near_section.width = 8.0
	main.rod_near_section.default_color = Color(0.29, 0.185, 0.090, 0.98)
	main.rod_near_section.antialiased = true

	main.rod_mid_section.width = 4.8
	main.rod_mid_section.default_color = Color(0.25, 0.165, 0.082, 0.96)
	main.rod_mid_section.antialiased = true

	main.rod_tip_section.width = 2.2
	main.rod_tip_section.default_color = Color(0.19, 0.130, 0.075, 0.92)
	main.rod_tip_section.antialiased = true

	main.rod_highlight.width = 1.4
	main.rod_highlight.default_color = Color(0.92, 0.78, 0.48, 0.42)
	main.rod_highlight.antialiased = true

	main.rod_ferrule_near.width = 2.2
	main.rod_ferrule_near.default_color = Color(0.92, 0.78, 0.50, 0.52)
	main.rod_ferrule_near.antialiased = true

	main.rod_ferrule_mid.width = 1.8
	main.rod_ferrule_mid.default_color = Color(0.92, 0.78, 0.50, 0.46)
	main.rod_ferrule_mid.antialiased = true

	main.rod_ferrule_tip.width = 1.3
	main.rod_ferrule_tip.default_color = Color(0.92, 0.78, 0.50, 0.40)
	main.rod_ferrule_tip.antialiased = true

	main.rod_reel_stem.width = 3.2
	main.rod_reel_stem.default_color = Color(0.17, 0.18, 0.15, 0.82)
	main.rod_reel_stem.antialiased = true

	main.rod_reel_spool.width = 3.0
	main.rod_reel_spool.default_color = Color(0.52, 0.58, 0.50, 0.72)
	main.rod_reel_spool.antialiased = true

	main.rod_reel_handle.width = 2.2
	main.rod_reel_handle.default_color = Color(0.52, 0.58, 0.50, 0.70)
	main.rod_reel_handle.antialiased = true

	main.fishing_line_glow.width = 1.8
	main.fishing_line_glow.default_color = Color(0.72, 1.0, 0.88, 0.08)
	main.fishing_line_glow.antialiased = true

	main.fishing_line.width = 0.8
	main.fishing_line.default_color = Color(0.86, 0.96, 0.92, 0.36)
	main.fishing_line.antialiased = true


func _get_line_normal(from: Vector2, to: Vector2, prefer_down: bool = false) -> Vector2:
	var direction = (to - from).normalized()

	if direction == Vector2.ZERO:
		direction = Vector2.LEFT

	var normal = Vector2(-direction.y, direction.x)

	if prefer_down and normal.y < 0.0:
		normal = -normal

	return normal


func _make_ellipse_points(center: Vector2, radius: Vector2, steps: int = 16) -> PackedVector2Array:
	var points = PackedVector2Array()
	var safe_steps: int = max(steps, 8)

	for index in range(safe_steps + 1):
		var angle = TAU * float(index) / float(safe_steps)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))

	return points


func _set_short_cross_line(line: Line2D, center: Vector2, direction_to_tip: Vector2, length: float) -> void:
	var normal = _get_line_normal(center, direction_to_tip)
	line.points = PackedVector2Array([
		center - normal * length,
		center + normal * length
	])


func _cubic_bezier_point(start: Vector2, control_a: Vector2, control_b: Vector2, end: Vector2, t: float) -> Vector2:
	var safe_t: float = clamp(t, 0.0, 1.0)
	var inv_t: float = 1.0 - safe_t
	return (
		start * inv_t * inv_t * inv_t
		+ control_a * 3.0 * inv_t * inv_t * safe_t
		+ control_b * 3.0 * inv_t * safe_t * safe_t
		+ end * safe_t * safe_t * safe_t
	)


func _sample_cubic_curve(
	start: Vector2,
	control_a: Vector2,
	control_b: Vector2,
	end: Vector2,
	from_t: float = 0.0,
	to_t: float = 1.0,
	steps: int = 12
) -> PackedVector2Array:
	var points = PackedVector2Array()
	var safe_steps: int = max(steps, 1)

	for index in range(safe_steps + 1):
		var local_t: float = float(index) / float(safe_steps)
		var curve_t: float = lerp(from_t, to_t, local_t)
		points.append(_cubic_bezier_point(start, control_a, control_b, end, curve_t))

	return points


func _get_presence_state() -> String:
	if main._presence_bite_timer > 0.0:
		return "bite"

	match main._fishing_ui_state:
		FishingUiState.WAITING:
			return "waiting"
		FishingUiState.FIGHTING:
			return "reeling"
		FishingUiState.CAUGHT:
			return "caught"
		_:
			return "idle"


func _get_presence_reeling_intensity() -> float:
	var tension: float = clamp(float(main._last_reeling_state.get("tension", 0.0)), 0.0, 1.0)
	var fish_force: float = clamp(float(main._last_reeling_state.get("fish_force", 0.0)) * 0.7, 0.0, 1.0)
	var struggle_power: float = clamp(float(main._last_reeling_state.get("struggle_power", 0.0)) * 0.6, 0.0, 1.0)
	var risk: float = max(
		clamp(float(main._last_reeling_state.get("break_risk", 0.0)), 0.0, 1.0),
		clamp(float(main._last_reeling_state.get("escape_risk", 0.0)), 0.0, 1.0)
	)
	return clamp(tension * 0.42 + fish_force * 0.28 + struggle_power * 0.22 + risk * 0.18, 0.0, 1.0)


func _offset_points(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var shifted = PackedVector2Array()

	for point in points:
		shifted.append(point + offset)

	return shifted


func _set_float_presence(center: Vector2, state: String, intensity: float) -> void:
	var ripple_scale = 1.0
	var glow_scale = 1.0
	var reflection_scale = 1.0
	var marker_height = 52.0
	var marker_width = 11.0
	var marker_sink = 0.0
	var marker_tilt = sin(main._presence_time * 0.9) * 1.2
	var ripple_alpha = 0.86
	var glow_alpha = 1.0
	var reflection_alpha = 0.74

	match state:
		"bite":
			var bite_pulse: float = abs(sin(main._presence_time * 18.0))
			ripple_scale = 1.20 + bite_pulse * 0.14
			glow_scale = 1.20
			reflection_scale = 1.12 + bite_pulse * 0.10
			marker_height = 39.0
			marker_width = 12.0
			marker_sink = 10.0 + bite_pulse * 8.0
			marker_tilt = sin(main._presence_time * 22.0) * 6.5
			ripple_alpha = 1.0
			glow_alpha = 1.18
			reflection_alpha = 1.0
		"reeling":
			ripple_scale = 1.07 + intensity * 0.22 + sin(main._presence_time * 3.5) * 0.03
			glow_scale = 1.10 + intensity * 0.18
			reflection_scale = 1.04 + intensity * 0.12
			marker_height = 50.0 - intensity * 7.0
			marker_width = 11.5
			marker_sink = intensity * 5.0 + sin(main._presence_time * 5.0) * 2.0
			marker_tilt = sin(main._presence_time * 6.4) * (2.0 + intensity * 4.0)
			ripple_alpha = 0.92 + intensity * 0.18
			glow_alpha = 1.05 + intensity * 0.18
			reflection_alpha = 0.82 + intensity * 0.14
		"caught":
			ripple_scale = 1.08
			glow_scale = 1.16
			reflection_scale = 1.08
			marker_sink = -3.0 + sin(main._presence_time * 2.0) * 1.2
			marker_tilt = sin(main._presence_time * 1.4) * 1.4
		_:
			ripple_scale = 1.0 + sin(main._presence_time * 1.25) * 0.025
			glow_scale = 1.0 + sin(main._presence_time * 1.1) * 0.035
			reflection_scale = 1.0 + sin(main._presence_time * 1.0) * 0.018

	var ripple_size = Vector2(96.0, 38.0) * ripple_scale
	main.float_ripple.size = ripple_size
	main.float_ripple.position = center + Vector2(-ripple_size.x * 0.5, 15.0 - (ripple_size.y - 38.0) * 0.5)
	main.float_ripple.modulate = Color(1.0, 1.0, 1.0, ripple_alpha)

	var reflection_size = Vector2(74.0, 26.0) * reflection_scale
	main.float_reflection.size = reflection_size
	main.float_reflection.position = center + Vector2(-reflection_size.x * 0.5, 17.0 - (reflection_size.y - 26.0) * 0.5)
	main.float_reflection.modulate = Color(1.0, 1.0, 1.0, reflection_alpha)

	var glow_size = Vector2(64.0, 64.0) * glow_scale
	main.float_glow.size = glow_size
	main.float_glow.position = center - glow_size * 0.5 + Vector2(0.0, 9.0)
	main.float_glow.modulate = Color(1.0, 1.0, 1.0, glow_alpha)

	main.float_marker.size = Vector2(marker_width, marker_height)
	main.float_marker.pivot_offset = main.float_marker.size * Vector2(0.5, 0.72)
	main.float_marker.position = center + Vector2(-marker_width * 0.5, -marker_height * 0.62 + marker_sink)
	main.float_marker.rotation = deg_to_rad(marker_tilt)
	main.float_marker.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _update_fishing_presence(delta: float) -> void:
	if not main._presence_has_layout:
		return

	main._presence_time += delta
	main._presence_bite_timer = max(main._presence_bite_timer - delta, 0.0)
	main._presence_caught_timer = max(main._presence_caught_timer - delta, 0.0)

	var state = _get_presence_state()
	var intensity = _get_presence_reeling_intensity()

	if state == "bite":
		intensity = max(intensity, 0.9)
	elif state == "caught":
		intensity = max(intensity, 0.35 + main._presence_caught_timer * 0.15)
	elif state == "idle":
		intensity *= 0.2
	elif state == "waiting":
		intensity *= 0.35

	var screen_size = main.get_viewport_rect().size
	var scene_breath = Vector2(sin(main._presence_time * 0.34) * 1.0, sin(main._presence_time * 0.27) * 0.6)
	var mist_alpha: float = 0.92 + sin(main._presence_time * 0.28) * 0.05
	var light_alpha: float = 0.96 + sin(main._presence_time * 0.22) * 0.04
	main.foreground_mist_layer.modulate = Color(1.0, 1.0, 1.0, mist_alpha)
	main.reflection_layer.modulate = Color(1.0, 1.0, 1.0, light_alpha)
	main.sun_glow_layer.modulate = Color(1.0, 1.0, 1.0, light_alpha)

	var idle_wave = Vector2(sin(main._presence_time * 1.1) * 2.2, sin(main._presence_time * 1.55) * 2.0)
	var float_offset = idle_wave

	match state:
		"bite":
			float_offset += Vector2(sin(main._presence_time * 22.0) * 7.0, 14.0 + abs(sin(main._presence_time * 18.0)) * 9.0)
		"reeling":
			float_offset += Vector2(sin(main._presence_time * 7.7) * (2.0 + intensity * 3.5), sin(main._presence_time * 6.3) * (2.0 + intensity * 3.0))
		"caught":
			float_offset += Vector2(sin(main._presence_time * 1.8) * 1.4, -4.0 + sin(main._presence_time * 2.1) * 1.0)

	var target_float_center = main._float_base_center + float_offset + scene_breath * 0.35
	var float_follow = 7.0

	if state == "bite":
		float_follow = 13.0
	elif state == "reeling":
		float_follow = 9.0

	main._float_visual_center = main._float_visual_center.lerp(target_float_center, clamp(delta * float_follow, 0.0, 1.0))
	_set_float_presence(main._float_visual_center, state, intensity)

	var rod_butt = Vector2(screen_size.x - 62.0, screen_size.y - 44.0) + scene_breath
	var rod_tip_rest = main._float_base_center + Vector2(118.0, -104.0)
	var tip_pull_direction = (main._float_visual_center - rod_tip_rest).normalized()

	if tip_pull_direction == Vector2.ZERO:
		tip_pull_direction = Vector2(-0.68, 0.74)

	var rod_tip_target = rod_tip_rest

	match state:
		"bite":
			var bite_pull: float = 12.0 + abs(sin(main._presence_time * 12.0)) * 7.0
			var bite_shake: Vector2 = _get_line_normal(rod_tip_rest, main._float_visual_center) * sin(main._presence_time * 18.0) * 1.8
			rod_tip_target += tip_pull_direction * bite_pull + bite_shake
		"reeling":
			var fight_pull: float = 8.0 + intensity * 26.0
			var fight_pulse: Vector2 = tip_pull_direction * sin(main._presence_time * 4.2) * (0.7 + intensity * 1.5)
			rod_tip_target += tip_pull_direction * fight_pull + fight_pulse
		"caught":
			rod_tip_target += tip_pull_direction * 4.0 + Vector2(-3.0, -3.0 + sin(main._presence_time * 1.8) * 1.1)
		_:
			rod_tip_target += Vector2(sin(main._presence_time * 0.55) * 0.8, 3.0 + sin(main._presence_time * 0.72) * 0.7)

	var rod_tip_follow = 4.4

	if state == "bite":
		rod_tip_follow = 7.5
	elif state == "reeling":
		rod_tip_follow = 5.2

	main._rod_tip_visual = main._rod_tip_visual.lerp(rod_tip_target, clamp(delta * rod_tip_follow, 0.0, 1.0))

	var line_end = main._float_visual_center + Vector2(0.0, -24.0)
	var line_pull_direction = (line_end - main._rod_tip_visual).normalized()

	if line_pull_direction == Vector2.ZERO:
		line_pull_direction = tip_pull_direction

	var rod_bend_direction = _get_line_normal(rod_butt, main._rod_tip_visual, true)

	if rod_bend_direction.dot(line_pull_direction) < 0.0:
		rod_bend_direction = -rod_bend_direction

	if state == "idle" or state == "waiting":
		rod_bend_direction = rod_bend_direction.lerp(Vector2.DOWN, 0.34).normalized()

	var bend_direction_follow = 3.8

	if state == "bite":
		bend_direction_follow = 6.0
	elif state == "reeling":
		bend_direction_follow = 4.6

	main._rod_bend_direction_visual = main._rod_bend_direction_visual.lerp(rod_bend_direction, clamp(delta * bend_direction_follow, 0.0, 1.0))

	if main._rod_bend_direction_visual == Vector2.ZERO:
		main._rod_bend_direction_visual = rod_bend_direction
	else:
		main._rod_bend_direction_visual = main._rod_bend_direction_visual.normalized()

	var tension: float = clamp(float(main._last_reeling_state.get("tension", 0.0)), 0.0, 1.0)
	var target_bend_amount = 3.2

	match state:
		"bite":
			target_bend_amount = 8.0 + abs(sin(main._presence_time * 8.0)) * 2.4
		"reeling":
			var load: float = clamp(tension * 0.62 + intensity * 0.34, 0.0, 1.0)
			target_bend_amount = lerp(4.0, 20.0, load)
		"caught":
			target_bend_amount = 3.6
		_:
			target_bend_amount = 2.8

	target_bend_amount = clamp(target_bend_amount, 1.5, 22.0)

	var bend_amount_follow = 2.8

	if state == "bite":
		bend_amount_follow = 5.0
	elif state == "reeling":
		bend_amount_follow = 3.6

	main._rod_bend_amount_visual = lerp(main._rod_bend_amount_visual, target_bend_amount, clamp(delta * bend_amount_follow, 0.0, 1.0))

	var rod_highlight_direction = -main._rod_bend_direction_visual
	var bend_amount = main._rod_bend_amount_visual
	var rod_control_near = rod_butt.lerp(main._rod_tip_visual, 0.38) + main._rod_bend_direction_visual * (bend_amount * 0.08)
	var rod_control_tip = rod_butt.lerp(main._rod_tip_visual, 0.82) + main._rod_bend_direction_visual * (bend_amount * 0.58)
	var rod_points = _sample_cubic_curve(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.0, 1.0, 14)
	main.rod_shadow.points = _offset_points(rod_points, main._rod_bend_direction_visual * 4.5 + Vector2(2.0, 2.0))
	main.rod_blank.points = rod_points
	main.rod_near_section.points = _sample_cubic_curve(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.0, 0.52, 6)
	main.rod_mid_section.points = _sample_cubic_curve(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.48, 0.80, 5)
	main.rod_tip_section.points = _sample_cubic_curve(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.76, 1.0, 5)
	main.rod_highlight.points = _offset_points(rod_points, rod_highlight_direction * 2.0 + Vector2(-0.5, -0.5))
	main.rod_blank.width = 5.8 + intensity * 0.45
	main.rod_near_section.width = 8.3 + intensity * 0.35
	main.rod_mid_section.width = 4.8 + intensity * 0.20
	main.rod_tip_section.width = 2.1 + intensity * 0.10

	var rod_ring_near = _cubic_bezier_point(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.32)
	var rod_ring_mid = _cubic_bezier_point(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.60)
	var rod_ring_tip = _cubic_bezier_point(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.84)
	_set_short_cross_line(main.rod_ferrule_near, rod_ring_near, main._rod_tip_visual, 7.0)
	_set_short_cross_line(main.rod_ferrule_mid, rod_ring_mid, main._rod_tip_visual, 4.9)
	_set_short_cross_line(main.rod_ferrule_tip, rod_ring_tip, main._rod_tip_visual, 3.2)

	var handle_end = rod_butt + Vector2(82.0, 34.0)
	var handle_points = PackedVector2Array([handle_end, rod_butt])
	main.rod_handle_shadow.points = _offset_points(handle_points, Vector2(3.0, 4.0))
	main.rod_handle.points = handle_points
	_set_short_cross_line(main.rod_handle_wrap_a, handle_end.lerp(rod_butt, 0.34), rod_butt, 7.0)
	_set_short_cross_line(main.rod_handle_wrap_b, handle_end.lerp(rod_butt, 0.66), rod_butt, 6.0)

	var reel_mount = _cubic_bezier_point(rod_butt, rod_control_near, rod_control_tip, main._rod_tip_visual, 0.16)
	var reel_center = reel_mount + main._rod_bend_direction_visual * (18.0 + intensity * 2.0)
	main.rod_reel_stem.points = PackedVector2Array([reel_mount, reel_center])
	main.rod_reel_spool.points = _make_ellipse_points(reel_center, Vector2(13.0, 8.0), 18)
	main.rod_reel_handle.points = PackedVector2Array([
		reel_center + Vector2(9.0, -3.0),
		reel_center + Vector2(23.0, -1.0),
		reel_center + Vector2(27.0, 5.0)
	])

	var sag = 20.0

	if state == "reeling":
		sag = lerp(8.0, 1.2, intensity)
	elif state == "bite":
		sag = 2.5
	elif state == "caught":
		sag = 22.0

	var line_start = main._rod_tip_visual
	var line_mid_a = line_start.lerp(line_end, 0.34) + Vector2(
		sin(main._presence_time * 2.6) * (1.4 + intensity * 1.2),
		sag * 0.58 + sin(main._presence_time * 3.0) * (1.1 + intensity)
	)
	var line_mid_b = line_start.lerp(line_end, 0.68) + Vector2(
		sin(main._presence_time * 3.1 + 0.8) * (1.0 + intensity),
		sag + sin(main._presence_time * 3.6) * (0.9 + intensity)
	)
	var line_points = PackedVector2Array([line_start, line_mid_a, line_mid_b, line_end])
	main.fishing_line.points = line_points
	main.fishing_line_glow.points = line_points

	var line_alpha = 0.24
	var glow_alpha = 0.035
	var line_width = 0.72

	if state == "waiting":
		line_alpha = 0.32
		glow_alpha = 0.05
		line_width = 0.78
	elif state == "bite":
		line_alpha = 0.56
		glow_alpha = 0.18
		line_width = 0.95
	elif state == "reeling":
		line_alpha = 0.42 + intensity * 0.22
		glow_alpha = 0.08 + intensity * 0.16
		line_width = 0.78 + intensity * 0.16
	elif state == "caught":
		line_alpha = 0.30
		glow_alpha = 0.05
		line_width = 0.72

	main.fishing_line.width = line_width
	main.fishing_line_glow.width = line_width + 0.8
	main.fishing_line.default_color = Color(0.86, 0.96, 0.92, line_alpha)
	main.fishing_line_glow.default_color = Color(0.72, 1.0, 0.88, glow_alpha)
