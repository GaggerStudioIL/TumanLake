# Handles tackle assembly: tabs, item choice, comparison, and hints.
extends RefCounted

var main
var theme
enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

func setup(main_ref) -> void:
	main = main_ref
	theme = main.ui_theme
	_ensure_tackle_ui_nodes()

func open() -> void:
	if main._is_catch_reward_open():
		return

	main._active_nav_tab = "tackle"
	main.basket_panel.visible = false
	main.basket_backdrop.visible = false
	main.shop_panel.visible = false
	main.shop_backdrop.visible = false
	main.inventory_panel.visible = false
	main.inventory_backdrop.visible = false
	main.waterbody_panel.visible = false
	main.waterbody_backdrop.visible = false
	main.tackle_backdrop.visible = true
	main.tackle_panel.visible = true
	refresh()
	main._refresh_bottom_nav_styles()

func close() -> void:
	if main == null or main.tackle_panel == null:
		return

	main.tackle_panel.visible = false
	main.tackle_backdrop.visible = false
	main._active_nav_tab = "fish"
	main._refresh_bottom_nav_styles()

func refresh() -> void:
	_update_tackle_ui()

func is_open() -> bool:
	return main != null and main.tackle_panel != null and main.tackle_panel.visible

func _ensure_tackle_ui_nodes() -> void:
	if main.tackle_panel != null:
		return

	main.tackle_backdrop = ColorRect.new()
	main.tackle_backdrop.name = "TackleBackdrop"
	main.tackle_backdrop.visible = false
	main.tackle_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	main.tackle_backdrop.color = Color(0.0, 0.0, 0.0, 0.54)
	main.add_child(main.tackle_backdrop)

	main.tackle_panel = Panel.new()
	main.tackle_panel.name = "TacklePanel"
	main.tackle_panel.visible = false
	main.tackle_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	main.add_child(main.tackle_panel)

	main.tackle_title_label = Label.new()
	main.tackle_title_label.name = "TackleTitleLabel"
	main.tackle_title_label.text = "Снасти"
	main.tackle_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.tackle_panel.add_child(main.tackle_title_label)

	main.tackle_current_label = Label.new()
	main.tackle_current_label.name = "TackleCurrentLabel"
	main.tackle_current_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.tackle_panel.add_child(main.tackle_current_label)

	main.tackle_rod_button = Button.new()
	main.tackle_rod_button.name = "TackleRodButton"
	main.tackle_rod_button.text = "Удочки"
	main.tackle_panel.add_child(main.tackle_rod_button)

	main.tackle_line_button = Button.new()
	main.tackle_line_button.name = "TackleLineButton"
	main.tackle_line_button.text = "Лески"
	main.tackle_panel.add_child(main.tackle_line_button)

	main.tackle_float_button = Button.new()
	main.tackle_float_button.name = "TackleFloatButton"
	main.tackle_float_button.text = "Поплавки"
	main.tackle_panel.add_child(main.tackle_float_button)

	main.tackle_hook_button = Button.new()
	main.tackle_hook_button.name = "TackleHookButton"
	main.tackle_hook_button.text = "Крючки"
	main.tackle_panel.add_child(main.tackle_hook_button)

	main.tackle_bait_button = Button.new()
	main.tackle_bait_button.name = "TackleBaitButton"
	main.tackle_bait_button.text = "Наживки"
	main.tackle_panel.add_child(main.tackle_bait_button)

	main.tackle_item_list = ItemList.new()
	main.tackle_item_list.name = "TackleItemList"
	main.tackle_item_list.select_mode = ItemList.SELECT_SINGLE
	main.tackle_item_list.allow_reselect = true
	main.tackle_panel.add_child(main.tackle_item_list)

	main.tackle_details_label = Label.new()
	main.tackle_details_label.name = "TackleDetailsLabel"
	main.tackle_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.tackle_panel.add_child(main.tackle_details_label)

	main.tackle_compare_label = Label.new()
	main.tackle_compare_label.name = "TackleCompareLabel"
	main.tackle_compare_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.tackle_panel.add_child(main.tackle_compare_label)

	main.tackle_depth_label = Label.new()
	main.tackle_depth_label.name = "TackleDepthLabel"
	main.tackle_depth_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.tackle_panel.add_child(main.tackle_depth_label)

	main.tackle_depth_minus_button = Button.new()
	main.tackle_depth_minus_button.name = "TackleDepthMinusButton"
	main.tackle_depth_minus_button.text = "-"
	main.tackle_panel.add_child(main.tackle_depth_minus_button)

	main.tackle_depth_plus_button = Button.new()
	main.tackle_depth_plus_button.name = "TackleDepthPlusButton"
	main.tackle_depth_plus_button.text = "+"
	main.tackle_panel.add_child(main.tackle_depth_plus_button)

	main.tackle_hint_label = Label.new()
	main.tackle_hint_label.name = "TackleHintLabel"
	main.tackle_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.tackle_panel.add_child(main.tackle_hint_label)

	main.tackle_equip_button = Button.new()
	main.tackle_equip_button.name = "TackleEquipButton"
	main.tackle_equip_button.text = "Экипировать"
	main.tackle_panel.add_child(main.tackle_equip_button)

	main.tackle_close_button = Button.new()
	main.tackle_close_button.name = "TackleCloseButton"
	main.tackle_close_button.text = "Закрыть"
	main.tackle_panel.add_child(main.tackle_close_button)

	main.toast_label = Label.new()
	main.toast_label.name = "ToastLabel"
	main.toast_label.visible = false
	main.toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.add_child(main.toast_label)


func _update_tackle_ui() -> void:
	if main.tackle_panel == null:
		return

	main._visible_tackle_items = PlayerData.get_owned_items_for_category(main._tackle_category)
	main.tackle_title_label.text = "Сборка снасти"
	main.tackle_current_label.text = main._get_tackle_build_summary_text()
	main.tackle_depth_label.text = "Глубина: %.1f м" % PlayerData.fishing_depth
	main.tackle_hint_label.text = _get_tackle_setup_hints_text(2)
	main.tackle_item_list.clear()

	var selected_index = -1
	for i in main._visible_tackle_items.size():
		var item: Dictionary = main._visible_tackle_items[i]
		main.tackle_item_list.add_item(_get_tackle_item_display_text(item))
		var list_index = main.tackle_item_list.item_count - 1

		if _is_tackle_item_equipped(item):
			main.tackle_item_list.set_item_custom_bg_color(list_index, Color(0.12, 0.34, 0.22, 0.66))
			main.tackle_item_list.set_item_custom_fg_color(list_index, Color(0.80, 1.0, 0.82, 1.0))

		if str(item.get("id", "")) == main._selected_tackle_item_id:
			selected_index = i

	if selected_index < 0 and not main._visible_tackle_items.is_empty():
		selected_index = 0
		main._selected_tackle_item_id = str(main._visible_tackle_items[0].get("id", ""))

	if selected_index >= 0:
		main.tackle_item_list.select(selected_index)
	else:
		main._selected_tackle_item_id = ""

	var selected_item = _get_selected_tackle_item()
	var hints_text = _get_tackle_setup_hints_text(4)
	if selected_item.is_empty():
		main.tackle_details_label.text = "В этой категории пока нет предметов."
		main.tackle_compare_label.text = "Купи снасть в магазине или выбери другую категорию.\n\nПодсказки:\n%s" % hints_text
	else:
		main.tackle_details_label.text = _get_tackle_item_details_text(selected_item)
		main.tackle_compare_label.text = "%s\n\nПодсказки:\n%s" % [_get_tackle_compare_text(selected_item), hints_text]

	var can_equip = not selected_item.is_empty() and PlayerData.can_equip_item(selected_item)
	main.tackle_equip_button.visible = can_equip
	main.tackle_equip_button.disabled = not can_equip or _is_tackle_item_equipped(selected_item) or main._fishing_ui_state != FishingUiState.IDLE

	if main._fishing_ui_state != FishingUiState.IDLE and can_equip:
		main.tackle_equip_button.text = "Только вне ловли"
	elif _is_tackle_item_equipped(selected_item):
		main.tackle_equip_button.text = "Экипировано"
	else:
		main.tackle_equip_button.text = "Экипировать"

	var category_buttons: Array = [
		[main.tackle_rod_button, "rod"],
		[main.tackle_line_button, "line"],
		[main.tackle_float_button, "float"],
		[main.tackle_hook_button, "hook"],
		[main.tackle_bait_button, "bait"]
	]

	for item in category_buttons:
		var button: Button = item[0]
		var category: String = item[1]
		match category:
			"rod":
				button.text = "Удочка"
			"line":
				button.text = "Леска"
			"float":
				button.text = "Поплавок"
			"hook":
				button.text = "Крючок"
			"bait":
				button.text = "Наживка"
		theme.apply_tab_button_style(button, category == main._tackle_category)


func _set_tackle_category(category: String) -> void:
	main._tackle_category = category
	main._selected_tackle_item_id = ""
	_update_tackle_ui()


func _on_tackle_item_selected(index: int) -> void:
	if index < 0 or index >= main._visible_tackle_items.size():
		main._selected_tackle_item_id = ""
	else:
		main._selected_tackle_item_id = str(main._visible_tackle_items[index].get("id", ""))

	_update_tackle_ui()


func _on_tackle_item_activated(index: int) -> void:
	if index < 0 or index >= main._visible_tackle_items.size():
		return

	main._selected_tackle_item_id = str(main._visible_tackle_items[index].get("id", ""))

	if main._fishing_ui_state == FishingUiState.IDLE and not _is_tackle_item_equipped(main._visible_tackle_items[index]):
		main._on_tackle_equip_button_pressed()
	else:
		_update_tackle_ui()


func _get_selected_tackle_item() -> Dictionary:
	for item in main._visible_tackle_items:
		if str(item.get("id", "")) == main._selected_tackle_item_id:
			return item

	return {}


func _get_tackle_item_display_text(item: Dictionary) -> String:
	var name = str(item.get("name", "-"))
	var quantity = int(item.get("quantity", 1))
	var equipped_marker = "  ✓ Equipped" if _is_tackle_item_equipped(item) else ""

	if str(item.get("category", "")) == "bait":
		return "%s x%d%s" % [name, quantity, equipped_marker]

	return "%s%s" % [name, equipped_marker]


func _get_tackle_item_details_text(item: Dictionary) -> String:
	var category = str(item.get("category", "misc"))
	var details = "%s\nТип: %s\nРедкость: %s\nЦена: %d мон.\nКоличество: %d" % [
		str(item.get("name", "-")),
		main._get_inventory_category_title(category),
		_get_rarity_title(str(item.get("rarity", "common"))),
		int(item.get("price", 0)),
		int(item.get("quantity", 1))
	]
	var description = str(item.get("description", ""))

	if description != "":
		details += "\n%s" % description

	var stats_text = _get_tackle_stats_text(item)
	if stats_text != "":
		details += "\n\n%s" % stats_text

	return details


func _get_tackle_stats_text(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {})
	var category = str(item.get("category", item.get("type", "misc")))
	var lines: Array = []

	for key in _get_tackle_stat_keys(category):
		if not stats.has(key):
			continue

		lines.append("%s: %s" % [_get_tackle_stat_title(key), _format_tackle_stat_value(key, stats[key])])

	return "\n".join(lines)


func _get_tackle_compare_text(item: Dictionary) -> String:
	var category = str(item.get("category", "misc"))
	var current: Dictionary = PlayerData.current_tackle.get(category, {})
	var stats: Dictionary = item.get("stats", {})

	if current.is_empty():
		return "Сравнение недоступно."

	if str(current.get("id", "")) == str(item.get("id", "")):
		return "Сейчас экипировано.\nЭта снасть уже стоит в текущей маховой сборке."

	var lines: Array = ["Сравнение с текущей снастью:"]

	for key in _get_tackle_stat_keys(category):
		if not stats.has(key) and not current.has(key):
			continue

		var current_value = current.get(key, 0)
		var selected_value = stats.get(key, current_value)
		var diff_text = ""

		if typeof(current_value) in [TYPE_FLOAT, TYPE_INT] and typeof(selected_value) in [TYPE_FLOAT, TYPE_INT]:
			var diff: float = float(selected_value) - float(current_value)
			if abs(diff) >= 0.005:
				diff_text = " (+%.2f)" % diff if diff > 0.0 else " (%.2f)" % diff

		lines.append("%s: %s → %s%s" % [
			_get_tackle_stat_title(key),
			_format_tackle_stat_value(key, current_value),
			_format_tackle_stat_value(key, selected_value),
			diff_text
		])

	return "\n".join(lines)


func _get_tackle_setup_hints_text(max_lines: int = 4) -> String:
	var hints: Array = _get_tackle_setup_hints()
	var visible_hints: Array = []
	var line_count: int = min(max_lines, hints.size())

	for i in line_count:
		visible_hints.append(hints[i])

	return "\n".join(visible_hints)


func _get_tackle_setup_hints() -> Array:
	var hints: Array = []
	var spot = SpotDatabase.get_spot(PlayerData.current_spot)
	var spot_fish: Array = spot.get("available_fish", [])
	var depth = PlayerData.fishing_depth
	var tackle_stats = PlayerData.get_tackle_stats()
	var hook_size: int = int(tackle_stats.get("hook_size", 12))
	var line_strength: float = float(tackle_stats.get("line_strength", 1.0))
	var bait_type = str(tackle_stats.get("bait_type", "worm"))
	var depth_candidates: Array = []
	var bait_match_names: Array = []
	var too_big_hook_count = 0
	var too_small_hook_count = 0
	var fitting_hook_count = 0
	var line_warning = false
	var large_fish_nearby = false

	if depth <= 1.1:
		hints.append("На этой глубине чаще клюёт мелкая рыба.")
	elif depth >= 3.2:
		hints.append("Глубина подходит для крупной донной рыбы.")
	else:
		hints.append("Средняя глубина: универсальная настройка.")

	for fish_id in spot_fish:
		var fish = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue

		var min_depth: float = float(fish.get("min_depth", 0.2))
		var max_depth: float = float(fish.get("max_depth", 6.0))
		if depth < min_depth or depth > max_depth:
			continue

		depth_candidates.append(fish)
		var min_hook_size: int = int(fish.get("min_hook_size", 2))
		var max_hook_size: int = int(fish.get("max_hook_size", 18))

		if hook_size < min_hook_size:
			too_big_hook_count += 1
		elif hook_size > max_hook_size:
			too_small_hook_count += 1
		else:
			fitting_hook_count += 1

		var average_weight: float = (float(fish.get("min_weight", 0.0)) + float(fish.get("max_weight", 0.0))) * 0.5
		if average_weight >= 1.2:
			large_fish_nearby = true
		if line_strength < average_weight * 0.85:
			line_warning = true

		var preferred_baits = fish.get("preferred_baits", [])
		if typeof(preferred_baits) == TYPE_ARRAY and preferred_baits.has(bait_type) and bait_match_names.size() < 4:
			bait_match_names.append(str(fish.get("name", "-")))

	if depth_candidates.is_empty():
		hints.append(_get_no_bite_candidate_reason(PlayerData.current_spot))
	elif too_big_hook_count > fitting_hook_count and depth <= 1.6:
		hints.append("Крючок слишком большой для мелкой рыбы.")
	elif too_small_hook_count > 0 and large_fish_nearby:
		hints.append("Крючок маловат для крупной рыбы: выше риск схода.")

	if line_warning:
		hints.append("Леска слабовата для крупной рыбы.")

	if bait_match_names.is_empty():
		hints.append("Наживка не лучшая для рыбы на этой глубине.")
	else:
		hints.append("Наживка подходит для: %s." % ", ".join(bait_match_names))

	return hints


func _get_no_bite_candidate_reason(spot_id: String) -> String:
	var spot = SpotDatabase.get_spot(spot_id)

	if spot.is_empty():
		return "Точка ловли не найдена."

	var depth = PlayerData.fishing_depth
	var spot_fish: Array = spot.get("available_fish", [])
	var min_available_depth = 999.0
	var max_available_depth = -1.0
	var depth_fish: Array = []
	var hook_fish: Array = []
	var bait_fish: Array = []
	var tackle_stats = PlayerData.get_tackle_stats()
	var hook_size: int = int(tackle_stats.get("hook_size", 12))
	var bait_type = str(tackle_stats.get("bait_type", "worm"))

	for fish_id in spot_fish:
		var fish = FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue

		var min_depth: float = float(fish.get("min_depth", 0.2))
		var max_depth: float = float(fish.get("max_depth", 6.0))
		min_available_depth = min(min_available_depth, min_depth)
		max_available_depth = max(max_available_depth, max_depth)

		if depth < min_depth or depth > max_depth:
			continue

		depth_fish.append(fish)

		var min_hook_size: int = int(fish.get("min_hook_size", 2))
		var max_hook_size: int = int(fish.get("max_hook_size", 18))
		if hook_size >= min_hook_size and hook_size <= max_hook_size:
			hook_fish.append(fish)

		var preferred_baits = fish.get("preferred_baits", [])
		if typeof(preferred_baits) == TYPE_ARRAY and preferred_baits.has(bait_type):
			bait_fish.append(fish)

	if min_available_depth < 999.0:
		if depth < min_available_depth:
			return "%s: на %.1f м рыба держится глубже. Попробуй от %.1f м или другую точку." % [
				str(spot.get("name", "Точка")),
				depth,
				min_available_depth
			]
		if depth > max_available_depth:
			return "%s: глубина %.1f м слишком большая для этой рыбы. Попробуй до %.1f м." % [
				str(spot.get("name", "Точка")),
				depth,
				max_available_depth
			]

	if depth_fish.is_empty():
		return "На этой глубине в выбранной точке нет подходящей рыбы."

	if hook_fish.is_empty():
		return "Глубина подходит, но крючок не подходит рыбе в этой точке."

	if bait_fish.is_empty():
		return "Глубина и крючок подходят, но наживка слабая для этой рыбы."

	return "На этой глубине и снасти нет подходящей рыбы. Измени глубину, крючок или наживку."


func _get_tackle_stat_keys(category: String) -> Array:
	match category:
		"rod":
			return ["max_fish_weight", "control_bonus", "stiffness", "durability", "durability_loss"]
		"line":
			return ["max_load", "break_resistance", "break_chance", "visibility", "durability", "wear_rate"]
		"float":
			return ["sensitivity", "stability", "bite_visibility"]
		"hook":
			return ["hook_size", "hook_strength", "hook_chance", "target_fish_size", "fish_escape_modifier", "durability", "wear_rate"]
		"bait":
			return ["bait_type", "fish_attraction"]
		_:
			return []


func _get_tackle_stat_title(key: String) -> String:
	match key:
		"max_fish_weight":
			return "Макс. рыба"
		"strength":
			return "Жёсткость"
		"stiffness":
			return "Жёсткость"
		"tension_bonus":
			return "Контроль"
		"control_bonus":
			return "Контроль"
		"durability":
			return "Прочность"
		"durability_loss":
			return "Износ удочки"
		"max_load_kg":
			return "Нагрузка"
		"max_load":
			return "Нагрузка"
		"break_resistance":
			return "Защита обрыва"
		"break_chance":
			return "Риск обрыва"
		"wear_rate":
			return "Износ"
		"visibility":
			return "Заметность"
		"sensitivity":
			return "Чувствительность"
		"stability":
			return "Стабильность"
		"bite_visibility":
			return "Видимость клёва"
		"hook_size":
			return "Размер"
		"hook_strength":
			return "Прочность крючка"
		"hook_chance":
			return "Подсечка"
		"target_fish_size":
			return "Размер рыбы"
		"fish_escape_modifier":
			return "Сход рыбы"
		"bait_type":
			return "Тип наживки"
		"fish_attraction":
			return "Привлечение"
		_:
			return key


func _format_tackle_stat_value(key: String, value) -> String:
	match key:
		"max_fish_weight", "max_load_kg", "max_load":
			return "%.1f кг" % float(value)
		"tension_bonus", "control_bonus", "break_resistance", "break_chance", "visibility", "sensitivity", "stability", "bite_visibility", "hook_chance", "fish_escape_modifier", "fish_attraction", "strength", "stiffness", "durability", "durability_loss", "wear_rate", "hook_strength":
			return "%d%%" % roundi(float(value) * 100.0)
		"target_fish_size":
			match str(value):
				"small":
					return "мелкая"
				"medium":
					return "средняя"
				"large":
					return "крупная"
				_:
					return str(value)
		"bait_type":
			match str(value):
				"worm":
					return "червь"
				"bread":
					return "хлеб"
				"dough":
					return "тесто"
				"maggot":
					return "опарыш"
				_:
					return str(value)
		_:
			return str(value)


func _format_tackle_wear_message(wear: Dictionary) -> String:
	if wear.is_empty():
		return ""

	var lines: Array = []
	var rod_loss: int = max(roundi((float(wear.get("rod_old", 1.0)) - float(wear.get("rod_new", wear.get("rod_old", 1.0)))) * 100.0), 0)
	var line_loss: int = max(roundi((float(wear.get("line_old", 1.0)) - float(wear.get("line_new", wear.get("line_old", 1.0)))) * 100.0), 0)
	var hook_loss: int = max(roundi((float(wear.get("hook_old", 1.0)) - float(wear.get("hook_new", wear.get("hook_old", 1.0)))) * 100.0), 0)
	var wear_parts: Array = []

	if rod_loss > 0:
		wear_parts.append("уд. -%d%%" % rod_loss)
	if line_loss > 0:
		wear_parts.append("леска -%d%%" % line_loss)
	if hook_loss > 0:
		wear_parts.append("крючок -%d%%" % hook_loss)

	if not wear_parts.is_empty():
		lines.append("Износ: %s" % ", ".join(wear_parts))
	if bool(wear.get("line_broken", false)):
		lines.append("Леска порвана.")
	if bool(wear.get("rod_broken", false)):
		lines.append("Удочка повреждена.")
	if bool(wear.get("hook_lost", false)):
		lines.append("Крючок потерян.")

	return "\n".join(lines)


func _get_rarity_title(rarity: String) -> String:
	match rarity:
		"uncommon":
			return "Необычная"
		"rare":
			return "Редкая"
		"trophy":
			return "Трофейная"
		_:
			return "Обычная"


func _get_rarity_color(rarity: String) -> Color:
	match rarity:
		"trophy":
			return Color(1.0, 0.80, 0.38, 1.0)
		"rare":
			return Color(0.54, 0.86, 1.0, 1.0)
		"uncommon":
			return Color(0.58, 1.0, 0.64, 1.0)
		_:
			return Color(0.72, 0.86, 0.76, 1.0)


func _is_tackle_item_equipped(item: Dictionary) -> bool:
	var category = str(item.get("category", ""))

	if not PlayerData.current_tackle.has(category):
		return false

	return str(PlayerData.current_tackle[category].get("id", "")) == str(item.get("id", ""))
