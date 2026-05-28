extends PanelContainer

const DEFAULT_BG := Color(0.020, 0.046, 0.050, 0.72)
const DEFAULT_BORDER := Color(0.58, 0.86, 0.80, 0.24)


func _ready() -> void:
	apply_default_style()


func apply_default_style() -> void:
	apply_style(self, "default")


func apply_active_style() -> void:
	apply_style(self, "active")


func apply_warning_style() -> void:
	apply_style(self, "warning")


func apply_gold_style() -> void:
	apply_style(self, "gold")


func apply_locked_style() -> void:
	apply_style(self, "locked")


static func apply_style(panel: Control, variant: String = "default", radius: int = 8, padding: int = 10) -> void:
	if panel == null:
		return
	var bg := DEFAULT_BG
	var border := DEFAULT_BORDER
	var shadow := Color(0.0, 0.0, 0.0, 0.18)
	var shadow_size := 4
	match variant:
		"active", "highlight":
			bg = Color(0.030, 0.076, 0.070, 0.82)
			border = Color(0.50, 0.98, 0.86, 0.48)
			shadow = Color(0.26, 0.90, 0.70, 0.10)
			shadow_size = 7
		"warning":
			bg = Color(0.090, 0.062, 0.026, 0.82)
			border = Color(1.00, 0.70, 0.28, 0.42)
			shadow = Color(0.80, 0.44, 0.12, 0.12)
			shadow_size = 6
		"gold":
			bg = Color(0.100, 0.073, 0.028, 0.84)
			border = Color(1.00, 0.78, 0.34, 0.48)
			shadow = Color(0.95, 0.62, 0.18, 0.14)
			shadow_size = 7
		"locked":
			bg = Color(0.026, 0.032, 0.034, 0.70)
			border = Color(0.48, 0.56, 0.54, 0.20)
			shadow = Color(0.0, 0.0, 0.0, 0.14)
			shadow_size = 3
		"danger":
			bg = Color(0.100, 0.038, 0.036, 0.82)
			border = Color(1.00, 0.46, 0.38, 0.42)
			shadow = Color(0.70, 0.16, 0.12, 0.12)
			shadow_size = 6
	panel.add_theme_stylebox_override("panel", make_style(bg, border, radius, padding, shadow_size, shadow))


static func make_style(bg: Color, border: Color, radius: int = 8, padding: int = 10, shadow_size: int = 4, shadow: Color = Color(0.0, 0.0, 0.0, 0.18)) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_size = shadow_size
	style.shadow_color = shadow
	style.content_margin_left = float(padding)
	style.content_margin_top = float(padding)
	style.content_margin_right = float(padding)
	style.content_margin_bottom = float(padding)
	return style
