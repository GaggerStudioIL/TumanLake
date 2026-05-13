extends Control

@onready var background: ColorRect = $Background
@onready var title_label: Label = $TitleLabel
@onready var money_label: Label = $MoneyLabel
@onready var level_label: Label = $LevelLabel
@onready var xp_progress_bar: ProgressBar = $XPProgressBar
@onready var spot_option_button: OptionButton = $SpotOptionButton
@onready var fish_button: Button = $FishButton
@onready var basket_button: Button = $BasketButton
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

enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

var _fishing_ui_state: int = FishingUiState.IDLE

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
		timer_label,
		tackle_label,
		result_label,
		reeling_panel,
		basket_panel
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
		basket_close_button
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
	basket_button.size = Vector2(left_width, 48)
	basket_button.add_theme_font_size_override("font_size", 20)

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

	_update_reeling_ui(_last_reeling_state)
	_update_basket_ui()

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
	basket_panel.visible = true
	_update_basket_ui()

func _on_basket_close_button_pressed() -> void:
	basket_panel.visible = false

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
