extends Node

const STARTER_INCOME_PER_HOUR := Vector2i(50, 120)
const MID_INCOME_PER_HOUR := Vector2i(200, 400)
const TOP_INCOME_PER_HOUR := Vector2i(700, 2000)

func get_income_band_for_player_level(level: int) -> Dictionary:
	if level >= 18:
		return {
			"name": "top",
			"min": TOP_INCOME_PER_HOUR.x,
			"max": TOP_INCOME_PER_HOUR.y
		}
	if level >= 8:
		return {
			"name": "mid",
			"min": MID_INCOME_PER_HOUR.x,
			"max": MID_INCOME_PER_HOUR.y
		}
	return {
		"name": "starter",
		"min": STARTER_INCOME_PER_HOUR.x,
		"max": STARTER_INCOME_PER_HOUR.y
	}


func get_price_breakdown_text(catch_data: Dictionary) -> String:
	var breakdown: Dictionary = FishPriceCalculator.calculate_breakdown(catch_data, "", true)
	return "спрос x%.2f, поставщик x%.2f, качество x%.0f" % [
		float(breakdown.get("marketDemandMultiplier", 1.0)),
		float(breakdown.get("supplierBonusMultiplier", 1.0)),
		float(breakdown.get("quality_multiplier", 1.0))
	]
