extends Node


func format_money(value: float) -> String:
	return "%s мон." % _format_number(value)


func format_weight_kg(value: float) -> String:
	return "%.2f кг" % maxf(value, 0.0)


func format_length_cm(value: float) -> String:
	return "%.1f см" % maxf(value, 0.0)


func format_fish_status(status: String) -> String:
	match status:
		"keeper":
			return "зачёт"
		"trophy":
			return "трофей"
		"rare_record":
			return "редкий экземпляр"
		_:
			return "незачёт"


func format_rarity(rarity: String) -> String:
	match rarity:
		"rare":
			return "Редкий вид"
		"legendary_species":
			return "Легендарный вид"
		_:
			return "Обычный вид"


func format_market_multiplier(value: float) -> String:
	return "x%.2f" % maxf(value, 0.0)


func format_reputation(value: int) -> String:
	return "%d реп." % max(value, 0)


func _format_number(value: float) -> String:
	var rounded := int(round(value))
	var text := str(rounded)
	var result := ""
	var count := 0
	for i in range(text.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = " " + result
		result = text.substr(i, 1) + result
		count += 1
	return result
