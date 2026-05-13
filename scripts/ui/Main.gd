extends Control

@onready var background: ColorRect = $Background
@onready var title_label: Label = $TitleLabel
@onready var money_label: Label = $MoneyLabel
@onready var level_label: Label = $LevelLabel
@onready var xp_progress_bar: ProgressBar = $XPProgressBar
@onready var spot_option_button: OptionButton = $SpotOptionButton
@onready var fish_button: Button = $FishButton
@onready var basket_button: Button = $BasketButton
@onready var inventory_button: Button = $InventoryButton
@onready var timer_label: Label = $TimerLabel
@onready var tackle_label: Label = $TackleLabel
@onready var result_label: Label = $ResultLabel
@onready var reeling_panel: ColorRect = $ReelingPanel
@onready var fight_title_label: Label = $ReelingPanel/FightTitleLabel
@onready var tension_label: Label = $ReelingPanel/TensionLabel
@onready var tension_track: ColorRect = $ReelingPanel/TensionTrack
@onready var safe_zone: ColorRect = $ReelingPanel/TensionTrack/SafeZone
@onready var tension_fill: ColorRect = $ReelingPanel/TensionTrack/TensionFill
@onready var tension_marker: ColorRect = $ReelingPanel/TensionTrack/TensionMarker
@onready var progress_label: Label = $ReelingPanel/ProgressLabel
@onready var progress_track: ColorRect = $ReelingPanel/ProgressTrack
@onready var progress_fill: ColorRect = $ReelingPanel/ProgressTrack/ProgressFill
@onready var debug_label: Label = $ReelingPanel/DebugLabel
@onready var fight_status_label: Label = $ReelingPanel/FightStatusLabel
@onready var fight_hint_label: Label = $ReelingPanel/FightHintLabel
@onready var basket_panel: ColorRect = $BasketPanel
@onready var basket_title_label: Label = $BasketPanel/BasketTitleLabel
@onready var basket_contents_label: Label = $BasketPanel/BasketContentsLabel
@onready var basket_sell_all_button: Button = $BasketPanel/BasketSellAllButton
@onready var basket_close_button: Button = $BasketPanel/BasketCloseButton
@onready var inventory_panel: ColorRect = $InventoryPanel
@onready var inventory_title_label: Label = $InventoryPanel/InventoryTitleLabel
@onready var category_all_button: Button = $InventoryPanel/CategoryAllButton
@onready var category_rods_button: Button = $InventoryPanel/CategoryRodsButton
@onready var category_lines_button: Button = $InventoryPanel/CategoryLinesButton
@onready var category_floats_button: Button = $InventoryPanel/CategoryFloatsButton
@onready var category_hooks_button: Button = $InventoryPanel/CategoryHooksButton
@onready var category_baits_button: Button = $InventoryPanel/CategoryBaitsButton
@onready var category_fish_button: Button = $InventoryPanel/CategoryFishButton
@onready var category_misc_button: Button = $InventoryPanel/CategoryMiscButton
@onready var inventory_item_list: ItemList = $InventoryPanel/InventoryItemList
@onready var inventory_details_label: Label = $InventoryPanel/InventoryDetailsLabel
@onready var inventory_tackle_label: Label = $InventoryPanel/InventoryTackleLabel
@onready var inventory_equip_button: Button = $InventoryPanel/InventoryEquipButton
@onready var inventory_close_button: Button = $InventoryPanel/InventoryCloseButton

enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

var _fishing_ui_state: int = FishingUiState.IDLE
var _inventory_category: String = "all"
var _visible_inventory_items: Array = []
var _selected_inventory_item_id: String = ""

var _last_reeling_state := {
	"fish_name": "-",
	"fish_weight": 0.0,
	"tension": 0.46,
	"green_min": 0.38,
	"green_max": 0.68,
	"progress": 0.0,
	"catch_progress": 0.0,
	"control": 0.0,
	"difficulty": 1.0,
	"fish_force": 0.0,
	"struggle_power": 0.0,
	"struggle_event": "пауза",
	"feedback_message": "Держи зеленую зону.",
	"behavior": "-",
	"fight_power": 0.0,
	"line_strength": 0.0,
	"critical_break_risk": 0.0,
	"break_risk": 0.0,
	"escape_risk": 0.0,
	"input_active": false,
	"status": "green",
	"high_danger": 0.0,
	"low_danger": 0.0
}

func _ready() -> void:
	print("Tuman Lake: Main scene loaded")

	SaveManager.load_game()

	resized.connect(_on_resized)
	_setup_layout()
	_setup_spots()
	_connect_signals()
	_reset_reeling_ui()
	_update_ui()

func _setup_layout() -> void:
	var screen_size := get_viewport_rect().size
	var margin := 24.0
	var content_height = max(screen_size.y - margin * 2.0, 320.0)
	var left_width = clamp(screen_size.x * 0.30, 250.0, 320.0)
	var right_width = clamp(screen_size.x * 0.25, 220.0, 280.0)
	var center_width = max(screen_size.x - left_width - right_width - margin * 4.0, 280.0)
	var center_x = margin + left_width + margin
	var right_x = screen_size.x - margin - right_width

	for node in [
		title_label,
		money_label,
		level_label,
		xp_progress_bar,
		spot_option_button,
		fish_button,
		basket_button,
		inventory_button,
		timer_label,
		tackle_label,
		result_label,
		reeling_panel,
		basket_panel,
		inventory_panel
	]:
		node.set_anchors_preset(Control.PRESET_TOP_LEFT)

	for node in [
		fight_title_label,
		tension_label,
		tension_track,
		progress_label,
		progress_track,
		debug_label,
		fight_status_label,
		fight_hint_label,
		basket_title_label,
		basket_contents_label,
		basket_sell_all_button,
		basket_close_button,
		inventory_title_label,
		category_all_button,
		category_rods_button,
		category_lines_button,
		category_floats_button,
		category_hooks_button,
		category_baits_button,
		category_fish_button,
		category_misc_button,
		inventory_item_list,
		inventory_details_label,
		inventory_tackle_label,
		inventory_equip_button,
		inventory_close_button
	]:
		node.set_anchors_preset(Control.PRESET_TOP_LEFT)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color("#071018")

	title_label.text = "Tuman Lake"
	title_label.position = Vector2(margin, 18)
	title_label.size = Vector2(left_width, 48)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.add_theme_font_size_override("font_size", 34)

	money_label.position = Vector2(margin, 74)
	money_label.size = Vector2(left_width, 28)
	money_label.add_theme_font_size_override("font_size", 20)

	level_label.position = Vector2(margin, 104)
	level_label.size = Vector2(left_width, 42)
	level_label.add_theme_font_size_override("font_size", 18)

	xp_progress_bar.position = Vector2(margin, 148)
	xp_progress_bar.size = Vector2(left_width, 18)
	xp_progress_bar.show_percentage = false

	spot_option_button.position = Vector2(margin, 186)
	spot_option_button.size = Vector2(left_width, 46)

	fish_button.position = Vector2(margin, 252)
	fish_button.size = Vector2(left_width, 64)
	fish_button.add_theme_font_size_override("font_size", 24)

	basket_button.text = "Садок"
	basket_button.position = Vector2(margin, 332)
	basket_button.size = Vector2((left_width - 12.0) * 0.5, 48)
	basket_button.add_theme_font_size_override("font_size", 20)

	inventory_button.text = "Инвентарь"
	inventory_button.position = Vector2(margin + (left_width + 12.0) * 0.5, 332)
	inventory_button.size = Vector2((left_width - 12.0) * 0.5, 48)
	inventory_button.add_theme_font_size_override("font_size", 18)

	timer_label.position = Vector2(margin, 396)
	timer_label.size = Vector2(left_width, 34)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 22)

	tackle_label.position = Vector2(margin, 438)
	tackle_label.size = Vector2(left_width, max(content_height - 414.0, 60.0))
	tackle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tackle_label.add_theme_font_size_override("font_size", 15)

	result_label.position = Vector2(right_x, margin)
	result_label.size = Vector2(right_width, content_height)
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.add_theme_font_size_override("font_size", 18)

	reeling_panel.position = Vector2(center_x, margin)
	reeling_panel.size = Vector2(center_width, content_height)
	reeling_panel.color = Color("#0f171d")

	var panel_padding := 20.0
	var panel_width = center_width - panel_padding * 2.0

	fight_title_label.text = "Вываживание"
	fight_title_label.position = Vector2(panel_padding, 18)
	fight_title_label.size = Vector2(panel_width, 34)
	fight_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fight_title_label.add_theme_font_size_override("font_size", 26)

	tension_label.position = Vector2(panel_padding, 72)
	tension_label.size = Vector2(panel_width, 26)
	tension_label.add_theme_font_size_override("font_size", 18)

	tension_track.position = Vector2(panel_padding, 108)
	tension_track.size = Vector2(panel_width, 48)
	tension_track.color = Color("#23282b")
	tension_fill.z_index = 0
	safe_zone.z_index = 1
	tension_marker.z_index = 2

	progress_label.position = Vector2(panel_padding, 172)
	progress_label.size = Vector2(panel_width, 26)
	progress_label.add_theme_font_size_override("font_size", 18)

	progress_track.position = Vector2(panel_padding, 206)
	progress_track.size = Vector2(panel_width, 24)
	progress_track.color = Color("#23282b")

	debug_label.position = Vector2(panel_padding, 248)
	debug_label.size = Vector2(panel_width, 104)
	debug_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	debug_label.add_theme_font_size_override("font_size", 15)

	fight_status_label.position = Vector2(panel_padding, content_height - 134)
	fight_status_label.size = Vector2(panel_width, 64)
	fight_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fight_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fight_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fight_status_label.add_theme_font_size_override("font_size", 22)

	fight_hint_label.position = Vector2(panel_padding, content_height - 64)
	fight_hint_label.size = Vector2(panel_width, 48)
	fight_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fight_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fight_hint_label.add_theme_font_size_override("font_size", 16)

	var basket_width: float = min(screen_size.x - margin * 4.0, 640.0)
	var basket_height: float = min(content_height - 20.0, 390.0)
	var basket_x: float = (screen_size.x - basket_width) * 0.5
	var basket_y: float = (screen_size.y - basket_height) * 0.5
	var basket_padding := 20.0
	var basket_inner_width: float = basket_width - basket_padding * 2.0

	basket_panel.position = Vector2(basket_x, basket_y)
	basket_panel.size = Vector2(basket_width, basket_height)
	basket_panel.z_index = 20

	basket_title_label.position = Vector2(basket_padding, 16)
	basket_title_label.size = Vector2(basket_inner_width, 36)
	basket_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	basket_title_label.add_theme_font_size_override("font_size", 26)

	basket_contents_label.position = Vector2(basket_padding, 68)
	basket_contents_label.size = Vector2(basket_inner_width, basket_height - 146)
	basket_contents_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	basket_contents_label.add_theme_font_size_override("font_size", 17)

	basket_sell_all_button.position = Vector2(basket_padding, basket_height - 62)
	basket_sell_all_button.size = Vector2((basket_inner_width - 16.0) * 0.5, 46)

	basket_close_button.position = Vector2(basket_padding + (basket_inner_width + 16.0) * 0.5, basket_height - 62)
	basket_close_button.size = Vector2((basket_inner_width - 16.0) * 0.5, 46)

	var inventory_width: float = min(screen_size.x - margin * 2.0, 820.0)
	var inventory_height: float = min(content_height + 16.0, 470.0)
	var inventory_x: float = (screen_size.x - inventory_width) * 0.5
	var inventory_y: float = (screen_size.y - inventory_height) * 0.5
	var inventory_padding := 18.0
	var category_gap := 6.0
	var category_columns := 4
	var category_button_width: float = (inventory_width - inventory_padding * 2.0 - category_gap * float(category_columns - 1)) / float(category_columns)
	var list_width: float = inventory_width * 0.42
	var right_panel_x: float = inventory_padding + list_width + 18.0
	var right_panel_width: float = inventory_width - right_panel_x - inventory_padding
	var inventory_body_y := 142.0
	var inventory_action_y: float = inventory_height - 62.0
	var inventory_body_height: float = max(inventory_action_y - inventory_body_y - 16.0, 96.0)
	var details_height: float = min(132.0, max(inventory_body_height * 0.45, 70.0))

	inventory_panel.position = Vector2(inventory_x, inventory_y)
	inventory_panel.size = Vector2(inventory_width, inventory_height)
	inventory_panel.z_index = 25

	inventory_title_label.position = Vector2(inventory_padding, 12)
	inventory_title_label.size = Vector2(inventory_width - inventory_padding * 2.0, 32)
	inventory_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inventory_title_label.add_theme_font_size_override("font_size", 26)

	var category_buttons: Array = [
		category_all_button,
		category_rods_button,
		category_lines_button,
		category_floats_button,
		category_hooks_button,
		category_baits_button,
		category_fish_button,
		category_misc_button
	]
	var category_texts: Array = [
		"Все",
		"Удилища",
		"Лески",
		"Поплавки",
		"Крючки",
		"Наживки",
		"Рыба / Садок",
		"Разное"
	]

	for i in category_buttons.size():
		var category_button: Button = category_buttons[i]
		var category_column: int = i % category_columns
		var category_row: int = int(i / category_columns)
		category_button.text = category_texts[i]
		category_button.position = Vector2(
			inventory_padding + category_column * (category_button_width + category_gap),
			56 + category_row * 40
		)
		category_button.size = Vector2(category_button_width, 34)
		category_button.add_theme_font_size_override("font_size", 13)

	inventory_item_list.position = Vector2(inventory_padding, inventory_body_y)
	inventory_item_list.size = Vector2(list_width, inventory_body_height)

	inventory_details_label.position = Vector2(right_panel_x, inventory_body_y)
	inventory_details_label.size = Vector2(right_panel_width, details_height)
	inventory_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_details_label.add_theme_font_size_override("font_size", 16)

	var inventory_tackle_y: float = inventory_body_y + details_height + 14.0
	inventory_tackle_label.position = Vector2(right_panel_x, inventory_tackle_y)
	inventory_tackle_label.size = Vector2(right_panel_width, max(inventory_action_y - inventory_tackle_y - 12.0, 0.0))
	inventory_tackle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_tackle_label.add_theme_font_size_override("font_size", 15)

	inventory_equip_button.position = Vector2(right_panel_x, inventory_action_y)
	inventory_equip_button.size = Vector2((right_panel_width - 16.0) * 0.5, 46)

	inventory_close_button.position = Vector2(right_panel_x + (right_panel_width + 16.0) * 0.5, inventory_action_y)
	inventory_close_button.size = Vector2((right_panel_width - 16.0) * 0.5, 46)

	_update_reeling_ui(_last_reeling_state)
	_update_basket_ui()
	_update_inventory_ui()

func _setup_spots() -> void:
	spot_option_button.clear()

	var selected_index := 0

	for spot in SpotDatabase.get_all_spots():
		spot_option_button.add_item(spot["name"])
		var index := spot_option_button.item_count - 1
		spot_option_button.set_item_metadata(index, spot["id"])

		if spot["id"] == PlayerData.current_spot:
			selected_index = index

	spot_option_button.select(selected_index)
	PlayerData.current_spot = str(spot_option_button.get_item_metadata(selected_index))

func _connect_signals() -> void:
	spot_option_button.item_selected.connect(_on_spot_selected)
	fish_button.pressed.connect(_on_fish_button_pressed)
	fish_button.button_down.connect(_on_reel_button_down)
	fish_button.button_up.connect(_on_reel_button_up)
	basket_button.pressed.connect(_on_basket_button_pressed)
	basket_sell_all_button.pressed.connect(_on_sell_all_button_pressed)
	basket_close_button.pressed.connect(_on_basket_close_button_pressed)
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	inventory_close_button.pressed.connect(_on_inventory_close_button_pressed)
	inventory_equip_button.pressed.connect(_on_inventory_equip_button_pressed)
	inventory_item_list.item_selected.connect(_on_inventory_item_selected)
	category_all_button.pressed.connect(_set_inventory_category.bind("all"))
	category_rods_button.pressed.connect(_set_inventory_category.bind("rod"))
	category_lines_button.pressed.connect(_set_inventory_category.bind("line"))
	category_floats_button.pressed.connect(_set_inventory_category.bind("float"))
	category_hooks_button.pressed.connect(_set_inventory_category.bind("hook"))
	category_baits_button.pressed.connect(_set_inventory_category.bind("bait"))
	category_fish_button.pressed.connect(_set_inventory_category.bind("fish"))
	category_misc_button.pressed.connect(_set_inventory_category.bind("misc"))

	FishingManager.fishing_started.connect(_on_fishing_started)
	FishingManager.fishing_tick.connect(_on_fishing_tick)
	FishingManager.reeling_started.connect(_on_reeling_started)
	FishingManager.reeling_updated.connect(_on_reeling_updated)
	FishingManager.fish_caught.connect(_on_fish_caught)
	FishingManager.fishing_failed.connect(_on_fishing_failed)

func _update_ui() -> void:
	money_label.text = "Деньги: %d мон." % PlayerData.money
	tackle_label.text = PlayerData.get_tackle_text()
	level_label.text = "LVL %d\nXP: %d / %d" % [
		PlayerData.level,
		PlayerData.current_xp,
		PlayerData.xp_to_next_level
	]
	xp_progress_bar.max_value = max(PlayerData.xp_to_next_level, 1)
	xp_progress_bar.value = clamp(PlayerData.current_xp, 0, PlayerData.xp_to_next_level)

	var locked_for_result_or_fishing: bool = _fishing_ui_state != FishingUiState.IDLE
	fish_button.disabled = _fishing_ui_state == FishingUiState.WAITING
	spot_option_button.disabled = locked_for_result_or_fishing
	basket_button.disabled = _fishing_ui_state == FishingUiState.WAITING or _fishing_ui_state == FishingUiState.FIGHTING
	inventory_button.disabled = _fishing_ui_state == FishingUiState.WAITING or _fishing_ui_state == FishingUiState.FIGHTING

	if inventory_button.disabled:
		inventory_panel.visible = false

	match _fishing_ui_state:
		FishingUiState.WAITING:
			fish_button.text = "Ждём поклёвку..."
		FishingUiState.FIGHTING:
			fish_button.text = "Тянуть"
		FishingUiState.CAUGHT, FishingUiState.FAILED:
			fish_button.text = "Вытянуть удочку"
		_:
			fish_button.text = "Забросить"

	_update_basket_ui()

func _update_basket_ui() -> void:
	var fish_count: int = InventoryManager.inventory.size()
	basket_button.text = "Садок (%d)" % fish_count
	basket_contents_label.text = InventoryManager.get_inventory_text()
	basket_sell_all_button.disabled = fish_count == 0 or _fishing_ui_state == FishingUiState.WAITING or _fishing_ui_state == FishingUiState.FIGHTING

func _update_inventory_ui() -> void:
	_visible_inventory_items = _get_visible_inventory_items()
	inventory_title_label.text = "Инвентарь - %s" % _get_inventory_category_title(_inventory_category)
	inventory_tackle_label.text = PlayerData.get_tackle_text()
	inventory_item_list.clear()

	var selected_index := -1
	for i in _visible_inventory_items.size():
		var item: Dictionary = _visible_inventory_items[i]
		inventory_item_list.add_item(_get_inventory_item_display_text(item))

		if str(item.get("id", "")) == _selected_inventory_item_id:
			selected_index = i

	if selected_index >= 0:
		inventory_item_list.select(selected_index)
	else:
		_selected_inventory_item_id = ""

	var selected_item := _get_selected_inventory_item()
	if selected_item.is_empty():
		if _visible_inventory_items.is_empty():
			inventory_details_label.text = "В этой категории пока пусто."
		else:
			inventory_details_label.text = "Выбери предмет."
	else:
		inventory_details_label.text = _get_inventory_item_details_text(selected_item)

	var can_equip := not selected_item.is_empty() and PlayerData.can_equip_item(selected_item)
	inventory_equip_button.disabled = not can_equip or _fishing_ui_state != FishingUiState.IDLE
	inventory_equip_button.visible = true

func _get_visible_inventory_items() -> Array:
	var items: Array = []

	if _inventory_category == "all":
		items.append_array(PlayerData.owned_items)
	elif _inventory_category != "fish":
		items.append_array(PlayerData.get_owned_items_for_category(_inventory_category))

	if _inventory_category == "all" or _inventory_category == "fish":
		for i in InventoryManager.inventory.size():
			var fish: Dictionary = InventoryManager.inventory[i]
			items.append({
				"id": "basket_fish_%d" % i,
				"name": str(fish.get("name", "-")),
				"category": "fish",
				"quantity": 1,
				"description": "Рыба в садке.",
				"stats": {
					"weight": float(fish.get("weight", 0.0)),
					"price": int(fish.get("price", 0)),
					"rarity": str(fish.get("rarity", "-"))
				}
			})

	return items

func _get_selected_inventory_item() -> Dictionary:
	for item in _visible_inventory_items:
		if str(item.get("id", "")) == _selected_inventory_item_id:
			return item

	return {}

func _get_inventory_item_display_text(item: Dictionary) -> String:
	var category := str(item.get("category", "misc"))
	var name := str(item.get("name", "-"))
	var quantity := int(item.get("quantity", 1))

	if category == "fish":
		var stats: Dictionary = item.get("stats", {})
		return "%s %.2f кг" % [name, float(stats.get("weight", 0.0))]

	if quantity > 1:
		return "%s x%d" % [name, quantity]

	return name

func _get_inventory_item_details_text(item: Dictionary) -> String:
	var category := str(item.get("category", "misc"))
	var name := str(item.get("name", "-"))
	var quantity := int(item.get("quantity", 1))
	var description := str(item.get("description", ""))
	var stats: Dictionary = item.get("stats", {})

	if category == "fish":
		return "%s\nКатегория: Рыба / Садок\nВес: %.2f кг\nЦена: %d мон.\nРедкость: %s" % [
			name,
			float(stats.get("weight", 0.0)),
			int(stats.get("price", 0)),
			str(stats.get("rarity", "-"))
		]

	var details := "%s\nКатегория: %s\nКоличество: %d" % [
		name,
		_get_inventory_category_title(category),
		quantity
	]

	if description != "":
		details += "\n%s" % description

	var stats_text := _get_inventory_stats_text(stats)
	if stats_text != "":
		details += "\n\n%s" % stats_text

	return details

func _get_inventory_stats_text(stats: Dictionary) -> String:
	var stats_text := ""

	for key in stats.keys():
		var value = stats[key]

		if typeof(value) == TYPE_DICTIONARY or typeof(value) == TYPE_ARRAY:
			continue

		if stats_text != "":
			stats_text += "\n"

		stats_text += "%s: %s" % [str(key), str(value)]

	return stats_text

func _get_inventory_category_title(category: String) -> String:
	match category:
		"all":
			return "Все"
		"rod":
			return "Удилища"
		"line":
			return "Лески"
		"float":
			return "Поплавки"
		"hook":
			return "Крючки"
		"bait":
			return "Наживки"
		"fish":
			return "Рыба / Садок"
		_:
			return "Разное"

func _reset_reeling_ui() -> void:
	_last_reeling_state = {
		"fish_name": "-",
		"fish_weight": 0.0,
		"tension": 0.46,
		"green_min": 0.38,
		"green_max": 0.68,
		"progress": 0.0,
		"catch_progress": 0.0,
		"control": 0.0,
		"difficulty": 1.0,
		"fish_force": 0.0,
		"struggle_power": 0.0,
		"struggle_event": "пауза",
		"feedback_message": "Держи зеленую зону.",
		"behavior": "-",
		"fight_power": 0.0,
		"line_strength": 0.0,
		"critical_break_risk": 0.0,
		"break_risk": 0.0,
		"escape_risk": 0.0,
		"input_active": false,
		"status": "green",
		"high_danger": 0.0,
		"low_danger": 0.0
	}
	_update_reeling_ui(_last_reeling_state)
	fight_status_label.text = "Забрось снасть и дождись поклевки."
	fight_hint_label.text = "Во время вываживания удерживай кнопку, чтобы поднять натяжение. Отпускай, чтобы дать слабину."

func _update_reeling_ui(state: Dictionary) -> void:
	_last_reeling_state = state.duplicate(true)

	var tension: float = clamp(float(state.get("tension", 0.0)), 0.0, 1.0)
	var green_min: float = clamp(float(state.get("green_min", 0.38)), 0.0, 1.0)
	var green_max: float = clamp(float(state.get("green_max", 0.68)), green_min, 1.0)
	var progress: float = clamp(float(state.get("progress", 0.0)), 0.0, 1.0)
	var catch_progress: float = clamp(float(state.get("catch_progress", progress)), 0.0, 1.0)
	var critical_break_risk: float = clamp(float(state.get("break_risk", state.get("critical_break_risk", 0.0))), 0.0, 1.0)
	var escape_risk: float = clamp(float(state.get("escape_risk", 0.0)), 0.0, 1.0)
	var fight_power: float = max(float(state.get("fight_power", 0.0)), 0.0)
	var line_strength: float = max(float(state.get("line_strength", 0.0)), 0.0)
	var fish_weight: float = max(float(state.get("fish_weight", 0.0)), 0.0)
	var high_danger: float = clamp(float(state.get("high_danger", 0.0)), 0.0, 1.0)
	var low_danger: float = clamp(float(state.get("low_danger", 0.0)), 0.0, 1.0)
	var track_width = max(tension_track.size.x, 1.0)
	var track_height = max(tension_track.size.y, 1.0)
	var progress_width = max(progress_track.size.x, 1.0)
	var status := str(state.get("status", "green"))
	var behavior := str(state.get("behavior", "-"))
	var fish_name := str(state.get("fish_name", "-"))
	var struggle_event := str(state.get("struggle_event", "пауза"))
	var feedback_message := str(state.get("feedback_message", "Держи зеленую зону."))

	safe_zone.position = Vector2(track_width * green_min, 0.0)
	safe_zone.size = Vector2(max(track_width * (green_max - green_min), 4.0), track_height)
	safe_zone.color = Color("#2fc466")

	tension_fill.position = Vector2.ZERO
	tension_fill.size = Vector2(track_width * tension, track_height)

	tension_marker.position = Vector2(clamp(track_width * tension - 3.0, 0.0, max(track_width - 6.0, 0.0)), -5.0)
	tension_marker.size = Vector2(6.0, track_height + 10.0)

	progress_fill.position = Vector2.ZERO
	progress_fill.size = Vector2(progress_width * progress, progress_track.size.y)

	tension_label.text = "Натяжение: %d%% | зона: %d-%d%%" % [
		roundi(tension * 100.0),
		roundi(green_min * 100.0),
		roundi(green_max * 100.0)
	]
	progress_label.text = "Прогресс вываживания: %d%%" % roundi(catch_progress * 100.0)
	debug_label.text = "fish: %s %.2fkg | behavior: %s\nfight power: %.2f | line: %.1fkg\ntension: %d%% | green: %d-%d%%\nbreak risk: %d%% | escape risk: %d%%\ncatch progress: %d%% | event: %s" % [
		fish_name,
		fish_weight,
		behavior,
		fight_power,
		line_strength,
		roundi(tension * 100.0),
		roundi(green_min * 100.0),
		roundi(green_max * 100.0),
		roundi(critical_break_risk * 100.0),
		roundi(escape_risk * 100.0),
		roundi(catch_progress * 100.0),
		struggle_event
	]

	match status:
		"high":
			tension_fill.color = Color("#e65f45", 0.78)
			fight_status_label.text = "%s\nРиск обрыва: %d%%" % [
				feedback_message,
				roundi(high_danger * 100.0)
			]
		"low":
			tension_fill.color = Color("#45a0e6", 0.78)
			fight_status_label.text = "%s\nРиск схода: %d%%" % [
				feedback_message,
				roundi(low_danger * 100.0)
			]
		_:
			tension_fill.color = Color("#d7b84a", 0.72)
			if FishingManager.is_reeling:
				fight_status_label.text = "%s\nРыба под контролем." % feedback_message

func _on_resized() -> void:
	_setup_layout()

func _on_spot_selected(index: int) -> void:
	PlayerData.current_spot = spot_option_button.get_item_metadata(index)
	var spot := SpotDatabase.get_spot(PlayerData.current_spot)
	result_label.text = "Выбрано: %s\nГлубина: %.1f м" % [spot["name"], spot["depth"]]

	SaveManager.save_game()

func _on_fish_button_pressed() -> void:
	if _fishing_ui_state == FishingUiState.CAUGHT or _fishing_ui_state == FishingUiState.FAILED:
		_return_to_idle_after_result()
		return

	if _fishing_ui_state != FishingUiState.IDLE:
		return

	var selected_index := spot_option_button.selected
	PlayerData.current_spot = spot_option_button.get_item_metadata(selected_index)

	if not PlayerData.consume_current_bait(1):
		result_label.text = "Нет наживки."
		timer_label.text = "Готов к забросу"
		_update_ui()
		return

	basket_panel.visible = false
	inventory_panel.visible = false
	SaveManager.save_game()

	_fishing_ui_state = FishingUiState.WAITING
	result_label.text = "Туман сгущается. Ждем клев..."
	FishingManager.start_fishing(PlayerData.current_spot)
	_update_ui()

func _on_reel_button_down() -> void:
	if _fishing_ui_state == FishingUiState.FIGHTING and FishingManager.is_reeling:
		FishingManager.set_reel_input(true)

func _on_reel_button_up() -> void:
	FishingManager.set_reel_input(false)

func _on_sell_all_button_pressed() -> void:
	var earned := InventoryManager.sell_all()

	if earned > 0:
		result_label.text = "Рыба продана. Получено: %d мон." % earned
	else:
		result_label.text = "Садок пуст. Продавать пока нечего."

	SaveManager.save_game()
	_update_ui()

func _on_basket_button_pressed() -> void:
	inventory_panel.visible = false
	basket_panel.visible = true
	_update_basket_ui()

func _on_basket_close_button_pressed() -> void:
	basket_panel.visible = false

func _on_inventory_button_pressed() -> void:
	basket_panel.visible = false
	inventory_panel.visible = true
	_update_inventory_ui()

func _on_inventory_close_button_pressed() -> void:
	inventory_panel.visible = false

func _set_inventory_category(category: String) -> void:
	_inventory_category = category
	_selected_inventory_item_id = ""
	_update_inventory_ui()

func _on_inventory_item_selected(index: int) -> void:
	if index < 0 or index >= _visible_inventory_items.size():
		_selected_inventory_item_id = ""
	else:
		_selected_inventory_item_id = str(_visible_inventory_items[index].get("id", ""))

	_update_inventory_ui()

func _on_inventory_equip_button_pressed() -> void:
	var selected_item := _get_selected_inventory_item()

	if selected_item.is_empty() or not PlayerData.can_equip_item(selected_item):
		result_label.text = "Этот предмет нельзя экипировать."
		_update_inventory_ui()
		return

	if PlayerData.equip_item(str(selected_item.get("id", ""))):
		result_label.text = "Экипировано: %s" % str(selected_item.get("name", "-"))
		SaveManager.save_game()
	else:
		result_label.text = "Не удалось экипировать предмет."

	_update_ui()

func _return_to_idle_after_result() -> void:
	_fishing_ui_state = FishingUiState.IDLE
	timer_label.text = "Готов к забросу"
	result_label.text = "Удочка вытянута. Можно забрасывать снова."
	_reset_reeling_ui()
	_update_ui()

func _on_fishing_started(seconds: int) -> void:
	_fishing_ui_state = FishingUiState.WAITING
	_reset_reeling_ui()
	timer_label.text = "Клев через: %d сек." % seconds
	fight_status_label.text = "Ожидание поклевки..."
	_update_ui()

func _on_fishing_tick(seconds_left: int) -> void:
	timer_label.text = "Клев через: %d сек." % seconds_left

func _on_reeling_started(catch_data: Dictionary, state: Dictionary) -> void:
	_fishing_ui_state = FishingUiState.FIGHTING
	timer_label.text = "Поклевка!"
	result_label.text = "На крючке: %s\nВес: %.2f кг\nРедкость: %s\nПоведение: %s" % [
		catch_data["name"],
		catch_data["weight"],
		catch_data["rarity"],
		catch_data.get("behavior", "-")
	]
	fight_hint_label.text = "Удерживай кнопку, чтобы тянуть. Отпускай, когда натяжение уходит выше зеленой зоны."
	_update_reeling_ui(state)
	_update_ui()

func _on_reeling_updated(state: Dictionary) -> void:
	_update_reeling_ui(state)

func _on_fish_caught(catch_data: Dictionary) -> void:
	_fishing_ui_state = FishingUiState.CAUGHT
	timer_label.text = "Рыба поймана"

	var xp_result: Dictionary = catch_data.get("xp_result", {})
	var xp_text: String = "\nXP: +%d" % int(xp_result.get("gained_xp", 0))

	if bool(xp_result.get("leveled_up", false)):
		xp_text += "\nНовый уровень! LVL %d" % int(xp_result.get("level", PlayerData.level))

	result_label.text = "Поймано: %s\nВес: %.2f кг\nЦена: %d мон.%s\nНажми “Вытянуть удочку”." % [
		catch_data["name"],
		catch_data["weight"],
		catch_data["price"],
		xp_text
	]
	_reset_reeling_ui()
	SaveManager.save_game()
	_update_ui()

func _on_fishing_failed(message: String) -> void:
	_fishing_ui_state = FishingUiState.FAILED
	timer_label.text = "Неудача"
	result_label.text = "%s\nНажми “Вытянуть удочку”." % message
	_reset_reeling_ui()
	_update_ui()
