extends RefCounted

const TumanPanelScript := preload("res://scripts/ui/components/TumanPanel.gd")


static func apply_button_style(button: BaseButton, variant: String = "default") -> void:
	if button == null:
		return
	var normal_bg := Color(0.045, 0.095, 0.092, 0.92)
	var normal_border := Color(0.50, 0.86, 0.82, 0.34)
	var hover_bg := Color(0.055, 0.128, 0.112, 0.96)
	var pressed_bg := Color(0.036, 0.150, 0.122, 0.98)
	var text_color := Color(0.94, 1.0, 0.92, 1.0)
	var radius := 8
	var padding := 7
	match variant:
		"primary", "active_tab":
			normal_bg = Color(0.060, 0.180, 0.135, 0.96)
			normal_border = Color(0.46, 1.00, 0.78, 0.56)
			hover_bg = Color(0.078, 0.230, 0.166, 1.0)
			pressed_bg = Color(0.046, 0.152, 0.110, 1.0)
		"danger":
			normal_bg = Color(0.160, 0.060, 0.052, 0.94)
			normal_border = Color(1.00, 0.46, 0.38, 0.42)
			hover_bg = Color(0.210, 0.078, 0.064, 0.98)
			pressed_bg = Color(0.135, 0.045, 0.040, 1.0)
		"tab":
			normal_bg = Color(0.030, 0.064, 0.064, 0.74)
			normal_border = Color(0.46, 0.74, 0.70, 0.24)
			hover_bg = Color(0.046, 0.100, 0.094, 0.88)
			pressed_bg = Color(0.038, 0.122, 0.106, 0.96)
		"icon_button":
			radius = 7
			padding = 4
			normal_bg = Color(0.034, 0.068, 0.066, 0.78)
			normal_border = Color(0.52, 0.84, 0.80, 0.26)
		"disabled":
			normal_bg = Color(0.026, 0.032, 0.034, 0.62)
			normal_border = Color(0.48, 0.56, 0.54, 0.16)
			hover_bg = normal_bg
			pressed_bg = normal_bg
			text_color = Color(0.52, 0.60, 0.58, 0.86)
	button.add_theme_stylebox_override("normal", TumanPanelScript.make_style(normal_bg, normal_border, radius, padding, 3, Color(0.0, 0.0, 0.0, 0.16)))
	button.add_theme_stylebox_override("hover", TumanPanelScript.make_style(hover_bg, Color(normal_border.r, normal_border.g, normal_border.b, minf(normal_border.a + 0.18, 0.76)), radius, padding, 5, Color(normal_border.r, normal_border.g, normal_border.b, 0.08)))
	button.add_theme_stylebox_override("pressed", TumanPanelScript.make_style(pressed_bg, Color(normal_border.r, normal_border.g, normal_border.b, minf(normal_border.a + 0.24, 0.86)), radius, padding, 1, Color.TRANSPARENT))
	button.add_theme_stylebox_override("disabled", TumanPanelScript.make_style(Color(0.022, 0.028, 0.030, 0.62), Color(0.45, 0.52, 0.50, 0.14), radius, padding, 1, Color.TRANSPARENT))
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", Color(0.98, 1.0, 0.94, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.88, 1.0, 0.90, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.50, 0.58, 0.56, 0.78))
	button.add_theme_font_size_override("font_size", 13)


static func set_button_enabled(button: BaseButton, enabled: bool, reason: String = "") -> void:
	if button == null:
		return
	button.disabled = not enabled
	button.tooltip_text = "" if enabled else reason
	if not enabled:
		apply_button_style(button, "disabled")
