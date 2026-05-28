extends RefCounted


static func set_price(label: Label, value: float) -> void:
	if label == null:
		return
	label.text = UIFormatters.format_money(value)
	_apply_price_style(label)


static func set_price_with_multiplier(label: Label, price: float, multiplier: float) -> void:
	if label == null:
		return
	label.text = "%s  %s" % [
		UIFormatters.format_money(price),
		UIFormatters.format_market_multiplier(multiplier)
	]
	_apply_price_style(label)


static func set_total_price(label: Label, value: float) -> void:
	if label == null:
		return
	label.text = "Итого: %s" % UIFormatters.format_money(value)
	_apply_price_style(label)


static func _apply_price_style(label: Label) -> void:
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48, 1.0))
