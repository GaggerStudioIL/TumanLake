extends RefCounted

const TumanPanelScript := preload("res://scripts/ui/components/TumanPanel.gd")


static func create_badge(text: String, type: String = "normal") -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.custom_minimum_size = Vector2(0.0, 24.0)
	apply_badge_style(label, type)
	return label


static func apply_badge_style(label: Label, type: String = "normal") -> void:
	if label == null:
		return
	var bg := Color(0.052, 0.090, 0.084, 0.78)
	var border := Color(0.60, 0.84, 0.76, 0.32)
	var font := Color(0.82, 0.94, 0.86, 1.0)
	match type:
		"success", "keeper":
			bg = Color(0.050, 0.155, 0.095, 0.82)
			border = Color(0.48, 1.00, 0.66, 0.46)
			font = Color(0.72, 1.00, 0.76, 1.0)
		"trophy":
			bg = Color(0.180, 0.120, 0.038, 0.86)
			border = Color(1.00, 0.78, 0.34, 0.56)
			font = Color(1.00, 0.88, 0.50, 1.0)
		"rare", "rarity":
			bg = Color(0.145, 0.065, 0.220, 0.86)
			border = Color(0.86, 0.58, 1.00, 0.54)
			font = Color(0.92, 0.78, 1.00, 1.0)
		"locked":
			bg = Color(0.030, 0.036, 0.038, 0.74)
			border = Color(0.48, 0.56, 0.54, 0.24)
			font = Color(0.58, 0.66, 0.64, 0.88)
		"best":
			bg = Color(0.035, 0.150, 0.145, 0.84)
			border = Color(0.42, 1.00, 0.90, 0.52)
			font = Color(0.62, 1.00, 0.92, 1.0)
		"warning":
			bg = Color(0.165, 0.102, 0.030, 0.84)
			border = Color(1.00, 0.66, 0.22, 0.48)
			font = Color(1.00, 0.84, 0.48, 1.0)
		"danger", "broken":
			bg = Color(0.160, 0.046, 0.044, 0.84)
			border = Color(1.00, 0.46, 0.38, 0.46)
			font = Color(1.00, 0.68, 0.62, 1.0)
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", font)
	label.add_theme_stylebox_override("normal", TumanPanelScript.make_style(bg, border, 12, 7, 4, Color(0.0, 0.0, 0.0, 0.16)))


static func type_for_fish_status(status: String) -> String:
	match status:
		"keeper":
			return "success"
		"trophy":
			return "trophy"
		"rare_record":
			return "rare"
		_:
			return "normal"
