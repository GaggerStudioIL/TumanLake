extends Control

const SHOW_DEBUG_PANEL := false
const STYLE_HUD_PANEL := "HUDPanel"
const STYLE_INFO_CARD := "InfoCard"
const STYLE_PRIMARY_BUTTON := "PrimaryButton"
const STYLE_SECONDARY_BUTTON := "SecondaryButton"
const STYLE_BOTTOM_NAV_BUTTON := "BottomNavButton"
const STYLE_BOTTOM_NAV_ACTIVE := "BottomNavActive"
const FISH_REWARD_ATLAS_PATH := "res://assets/fish/fish_reward_atlas.png"
const SMALL_FISH_ATLAS_PATH := "res://assets/fish/small_fish_atlas.png"
const FISH_REWARD_ATLAS_REGIONS := {
	"roach": Rect2(45, 68, 438, 204),
	"perch": Rect2(503, 61, 420, 211),
	"crucian": Rect2(966, 63, 418, 209),
	"rudd": Rect2(30, 322, 426, 197),
	"tench": Rect2(494, 317, 406, 200),
	"pike": Rect2(957, 347, 464, 165),
	"bream": Rect2(30, 544, 414, 225),
	"white_bream": Rect2(30, 544, 414, 225),
	"skimmer_bream": Rect2(30, 544, 414, 225),
	"catfish": Rect2(482, 575, 469, 176),
	"small_catfish": Rect2(482, 575, 469, 176),
	"eel": Rect2(957, 613, 458, 100),
	"loach": Rect2(957, 613, 458, 100),
	"zander": Rect2(29, 810, 445, 206),
	"young_pike": Rect2(957, 347, 464, 165),
	"ide": Rect2(30, 322, 426, 197),
	"young_chub": Rect2(30, 322, 426, 197),
	"young_grass_carp": Rect2(966, 63, 418, 209),
	"young_mirror_carp": Rect2(506, 821, 415, 205),
	"mist_carp": Rect2(506, 821, 415, 205),
	"moon_catfish": Rect2(957, 848, 460, 169)
}
const SMALL_FISH_ATLAS_REGIONS := {
	"bleak": Rect2(0, 0, 512, 256),
	"topmouth_gudgeon": Rect2(0, 0, 512, 256),
	"gudgeon": Rect2(0, 0, 512, 256),
	"rotan": Rect2(512, 0, 512, 256),
	"goby": Rect2(512, 0, 512, 256),
	"frog": Rect2(512, 0, 512, 256),
	"crayfish": Rect2(512, 0, 512, 256),
	"water_turtle": Rect2(512, 0, 512, 256),
	"silver_crucian": Rect2(1024, 0, 512, 256),
	"golden_crucian": Rect2(0, 256, 512, 256),
	"ruffe": Rect2(512, 256, 512, 256)
}
const SHOP_CATEGORY_BAIT := "bait"
const SHOP_CATEGORY_CONSUMABLE := "consumable"
const SHOP_CATEGORY_TACKLE := "tackle"
const SHOP_ITEMS := [
	{
		"id": "worm",
		"shop_category": SHOP_CATEGORY_BAIT,
		"icon": "W",
		"name": "Червь",
		"category": "bait",
		"quantity": 10,
		"price": 12,
		"description": "Универсальная наживка. Хорошо работает по плотве, окуню и карасю.",
		"stats": {
			"bait_type": "worm",
			"fish_attraction": 0.14,
			"fish_attraction_by_id": {
				"roach": 0.28,
				"rotan": 0.20,
				"ruffe": 0.18,
				"perch": 0.22,
				"crucian": 0.24,
				"silver_crucian": 0.22,
				"golden_crucian": 0.18
			},
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	{
		"id": "bread",
		"shop_category": SHOP_CATEGORY_BAIT,
		"icon": "B",
		"name": "Хлеб",
		"category": "bait",
		"quantity": 12,
		"price": 10,
		"description": "Дешевая наживка для спокойной белой рыбы.",
		"stats": {
			"bait_type": "bread",
			"fish_attraction": 0.08,
			"fish_attraction_by_id": {
				"bleak": 0.28,
				"roach": 0.22,
				"rudd": 0.20,
				"silver_crucian": 0.16,
				"golden_crucian": 0.12,
				"bream": 0.12
			},
			"allowed_rarities": ["common", "uncommon"]
		}
	},
	{
		"id": "dough",
		"shop_category": SHOP_CATEGORY_BAIT,
		"icon": "D",
		"name": "Тесто",
		"category": "bait",
		"quantity": 10,
		"price": 14,
		"description": "Мягкая наживка для карася, плотвы и красноперки.",
		"stats": {
			"bait_type": "dough",
			"fish_attraction": 0.11,
			"fish_attraction_by_id": {
				"crucian": 0.26,
				"silver_crucian": 0.24,
				"golden_crucian": 0.26,
				"roach": 0.16,
				"rudd": 0.18
			},
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	{
		"id": "maggot",
		"shop_category": SHOP_CATEGORY_BAIT,
		"icon": "M",
		"name": "Опарыш",
		"category": "bait",
		"quantity": 8,
		"price": 18,
		"description": "Активная наживка. Лучше провоцирует окуня и мелкую рыбу.",
		"stats": {
			"bait_type": "maggot",
			"fish_attraction": 0.15,
			"fish_attraction_by_id": {
				"bleak": 0.24,
				"rotan": 0.20,
				"ruffe": 0.22,
				"perch": 0.26,
				"roach": 0.18,
				"rudd": 0.16
			},
			"allowed_rarities": ["common", "uncommon", "rare", "very_rare"]
		}
	},
	{
		"id": "groundbait_light",
		"shop_category": SHOP_CATEGORY_CONSUMABLE,
		"icon": "G",
		"name": "Прикормка",
		"category": "misc",
		"quantity": 3,
		"price": 45,
		"description": "Базовая прикормка. Пока расходник для будущей механики.",
		"stats": {
			"effect": "groundbait",
			"bite_bonus": 0.12
		}
	},
	{
		"id": "mono_1_2kg",
		"shop_category": SHOP_CATEGORY_TACKLE,
		"icon": "L",
		"name": "Леска моно 1.2 кг",
		"category": "line",
		"quantity": 1,
		"price": 55,
		"description": "Запасная тонкая монофильная леска для маховой удочки.",
		"stats": {
			"strength": 1.2,
			"break_resistance": 0.92,
			"visibility_penalty": 0.08
		}
	}
]

@onready var background: ColorRect = $Background
@onready var scene_gradient: ColorRect = $SceneGradient
@onready var mist_layer: ColorRect = $MistLayer
@onready var noise_layer: ColorRect = $NoiseLayer
@onready var sun_glow_layer: ColorRect = $SunGlowLayer
@onready var far_forest_layer: ColorRect = $FarForestLayer
@onready var mid_forest_layer: ColorRect = $MidForestLayer
@onready var lake_layer: ColorRect = $LakeLayer
@onready var reflection_layer: ColorRect = $ReflectionLayer
@onready var foreground_mist_layer: ColorRect = $ForegroundMistLayer
@onready var vignette_layer: ColorRect = $VignetteLayer
@onready var water_panel: Panel = $WaterPanel
@onready var fishing_presence_layer: Node2D = $FishingPresenceLayer
@onready var rod_shadow: Line2D = $FishingPresenceLayer/RodShadow
@onready var rod_handle_shadow: Line2D = $FishingPresenceLayer/RodHandleShadow
@onready var rod_handle: Line2D = $FishingPresenceLayer/RodHandle
@onready var rod_handle_wrap_a: Line2D = $FishingPresenceLayer/RodHandleWrapA
@onready var rod_handle_wrap_b: Line2D = $FishingPresenceLayer/RodHandleWrapB
@onready var rod_blank: Line2D = $FishingPresenceLayer/RodBlank
@onready var rod_near_section: Line2D = $FishingPresenceLayer/RodNearSection
@onready var rod_mid_section: Line2D = $FishingPresenceLayer/RodMidSection
@onready var rod_tip_section: Line2D = $FishingPresenceLayer/RodTipSection
@onready var rod_highlight: Line2D = $FishingPresenceLayer/RodHighlight
@onready var rod_ferrule_near: Line2D = $FishingPresenceLayer/RodFerruleNear
@onready var rod_ferrule_mid: Line2D = $FishingPresenceLayer/RodFerruleMid
@onready var rod_ferrule_tip: Line2D = $FishingPresenceLayer/RodFerruleTip
@onready var rod_reel_stem: Line2D = $FishingPresenceLayer/RodReelStem
@onready var rod_reel_spool: Line2D = $FishingPresenceLayer/RodReelSpool
@onready var rod_reel_handle: Line2D = $FishingPresenceLayer/RodReelHandle
@onready var fishing_line_glow: Line2D = $FishingPresenceLayer/FishingLineGlow
@onready var fishing_line: Line2D = $FishingPresenceLayer/FishingLine
@onready var float_marker: ColorRect = $FloatMarker
@onready var float_glow: ColorRect = $FloatGlow
@onready var float_ripple: ColorRect = $FloatRipple
@onready var float_reflection: ColorRect = $FloatReflection
@onready var top_hud_panel: Panel = $TopHudPanel
@onready var left_hud_panel: Panel = $LeftHudPanel
@onready var right_hud_panel: Panel = $RightHudPanel
@onready var bottom_nav_panel: Panel = $BottomNavPanel
@onready var action_panel: Panel = $ActionPanel
@onready var action_glow: ColorRect = $ActionGlow
@onready var title_label: Label = $TitleLabel
@onready var money_label: Label = $MoneyLabel
@onready var level_label: Label = $LevelLabel
@onready var xp_progress_bar: ProgressBar = $XPProgressBar
@onready var clock_label: Label = $ClockLabel
@onready var weather_label: Label = $WeatherLabel
@onready var spot_option_button: OptionButton = $SpotOptionButton
@onready var nav_fish_button: Button = $NavFishButton
@onready var fish_button: Button = $FishButton
@onready var basket_button: Button = $BasketButton
@onready var inventory_button: Button = $InventoryButton
@onready var tackle_button: Button = $TackleButton
@onready var shop_button: Button = $ShopButton
@onready var map_button: Button = $MapButton
@onready var profile_button: Button = $ProfileButton
@onready var feed_button: Button = $FeedButton
@onready var auto_button: Button = $AutoButton
@onready var bait_button: Button = $BaitButton
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
@onready var debug_panel: Panel = $DebugPanel
@onready var debug_label: Label = $DebugPanel/DebugLabel
@onready var fight_status_label: Label = $ReelingPanel/FightStatusLabel
@onready var fight_hint_label: Label = $ReelingPanel/FightHintLabel
@onready var basket_panel: ColorRect = $BasketPanel
@onready var basket_title_label: Label = $BasketPanel/BasketTitleLabel
@onready var basket_contents_label: Label = $BasketPanel/BasketContentsLabel
@onready var basket_sell_all_button: Button = $BasketPanel/BasketSellAllButton
@onready var basket_close_button: Button = $BasketPanel/BasketCloseButton
@onready var inventory_backdrop: ColorRect = $InventoryBackdrop
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
@onready var inventory_details_card: ColorRect = $InventoryPanel/InventoryDetailsCard
@onready var inventory_tackle_card: ColorRect = $InventoryPanel/InventoryTackleCard
@onready var inventory_item_list: ItemList = $InventoryPanel/InventoryItemList
@onready var inventory_details_label: Label = $InventoryPanel/InventoryDetailsLabel
@onready var inventory_tackle_label: Label = $InventoryPanel/InventoryTackleLabel
@onready var inventory_equip_button: Button = $InventoryPanel/InventoryEquipButton
@onready var inventory_close_button: Button = $InventoryPanel/InventoryCloseButton
@onready var catch_popup_backdrop: ColorRect = $CatchPopupBackdrop
@onready var catch_popup_panel: Panel = $CatchPopupPanel
@onready var catch_popup_particles: ColorRect = $CatchPopupPanel/CatchPopupParticles
@onready var catch_popup_glow: ColorRect = $CatchPopupPanel/CatchPopupGlow
@onready var catch_popup_title_label: Label = $CatchPopupPanel/CatchPopupTitleLabel
@onready var catch_popup_badge_label: Label = $CatchPopupPanel/CatchPopupBadgeLabel
@onready var catch_popup_name_label: Label = $CatchPopupPanel/CatchPopupNameLabel
@onready var catch_trophy_banner_label: Label = $CatchPopupPanel/CatchTrophyBannerLabel
@onready var catch_fish_shadow: TextureRect = $CatchPopupPanel/CatchFishShadow
@onready var catch_fish_visual: TextureRect = $CatchPopupPanel/CatchFishVisual
@onready var catch_popup_stats_label: Label = $CatchPopupPanel/CatchPopupStatsLabel
@onready var catch_keep_button: Button = $CatchPopupPanel/CatchKeepButton
@onready var catch_release_button: Button = $CatchPopupPanel/CatchReleaseButton
@onready var catch_popup_open_audio: AudioStreamPlayer = $CatchPopupOpenAudio
@onready var catch_reward_audio: AudioStreamPlayer = $CatchRewardAudio
@onready var catch_rare_audio: AudioStreamPlayer = $CatchRareAudio
@onready var catch_trophy_audio: AudioStreamPlayer = $CatchTrophyAudio

var shop_backdrop: ColorRect
var shop_panel: Panel
var shop_title_label: Label
var shop_money_label: Label
var shop_bait_category_button: Button
var shop_consumable_category_button: Button
var shop_tackle_category_button: Button
var shop_items_container: Control
var shop_notice_label: Label
var shop_close_button: Button
var shop_buy_audio: AudioStreamPlayer
var shop_error_audio: AudioStreamPlayer
var basket_backdrop: ColorRect
var basket_frame_panel: Panel
var basket_stats_label: Label
var basket_scroll: ScrollContainer
var basket_cards_grid: GridContainer
var basket_notice_label: Label
var tackle_backdrop: ColorRect
var tackle_panel: Panel
var tackle_title_label: Label
var tackle_current_label: Label
var tackle_item_list: ItemList
var tackle_details_label: Label
var tackle_compare_label: Label
var tackle_depth_label: Label
var tackle_depth_minus_button: Button
var tackle_depth_plus_button: Button
var tackle_hint_label: Label
var tackle_rod_button: Button
var tackle_line_button: Button
var tackle_float_button: Button
var tackle_hook_button: Button
var tackle_bait_button: Button
var tackle_equip_button: Button
var tackle_close_button: Button
var waterbody_backdrop: ColorRect
var waterbody_panel: Panel
var waterbody_title_label: Label
var waterbody_item_list: ItemList
var waterbody_preview: ColorRect
var waterbody_details_label: Label
var waterbody_spot_list: ItemList
var waterbody_spot_details_label: Label
var waterbody_select_button: Button
var waterbody_close_button: Button
var toast_label: Label
var _toast_tween: Tween

enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

var _fishing_ui_state: int = FishingUiState.IDLE
var _active_nav_tab: String = "fish"
var _inventory_category: String = "all"
var _visible_inventory_items: Array = []
var _selected_inventory_item_id: String = ""
var _tackle_category: String = "rod"
var _visible_tackle_items: Array = []
var _selected_tackle_item_id: String = ""
var _visible_waterbodies: Array = []
var _selected_waterbody_id: String = ""
var _visible_waterbody_spots: Array = []
var _selected_waterbody_spot_id: String = ""
var _pending_reward_catch: Dictionary = {}
var _catch_popup_tween: Tween
var _catch_fish_tween: Tween
var _fish_reward_atlas: Texture2D
var _small_fish_atlas: Texture2D
var _catch_fish_base_position := Vector2.ZERO
var _catch_shadow_base_position := Vector2.ZERO
var _catch_reward_buttons_ready := false
var _catch_reward_unlock_after_msec := 0
var _shop_category: String = SHOP_CATEGORY_BAIT
var _shop_card_nodes: Dictionary = {}
var _shop_feedback_tween: Tween
var _presence_time := 0.0
var _presence_bite_timer := 0.0
var _presence_caught_timer := 0.0
var _presence_has_layout := false
var _float_base_center := Vector2.ZERO
var _float_visual_center := Vector2.ZERO
var _rod_tip_visual := Vector2.ZERO
var _rod_bend_direction_visual := Vector2.DOWN
var _rod_bend_amount_visual := 3.0

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
	_ensure_shop_ui_nodes()
	_ensure_keepnet_ui_nodes()
	_ensure_tackle_ui_nodes()
	_ensure_waterbody_ui_nodes()

	resized.connect(_on_resized)
	var time_manager := _get_time_manager()
	if time_manager != null:
		time_manager.connect("time_changed", Callable(self, "_on_global_time_changed"))
		time_manager.connect("period_changed", Callable(self, "_on_global_period_changed"))
	_setup_layout()
	_setup_spots()
	_connect_signals()
	_reset_reeling_ui()
	_update_ui()

func _process(delta: float) -> void:
	_update_fishing_presence(delta)
	_update_catch_reward_input_lock()
	_update_time_hud()

func _ensure_shop_ui_nodes() -> void:
	if shop_panel != null:
		return

	shop_backdrop = ColorRect.new()
	shop_backdrop.name = "ShopBackdrop"
	shop_backdrop.visible = false
	shop_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	shop_backdrop.color = Color(0.0, 0.0, 0.0, 0.52)
	add_child(shop_backdrop)

	shop_panel = Panel.new()
	shop_panel.name = "ShopPanel"
	shop_panel.visible = false
	shop_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shop_panel)

	shop_title_label = Label.new()
	shop_title_label.name = "ShopTitleLabel"
	shop_title_label.text = "Магазин"
	shop_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_panel.add_child(shop_title_label)

	shop_money_label = Label.new()
	shop_money_label.name = "ShopMoneyLabel"
	shop_money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	shop_panel.add_child(shop_money_label)

	shop_bait_category_button = Button.new()
	shop_bait_category_button.name = "ShopBaitCategoryButton"
	shop_bait_category_button.text = "Наживки"
	shop_panel.add_child(shop_bait_category_button)

	shop_consumable_category_button = Button.new()
	shop_consumable_category_button.name = "ShopConsumableCategoryButton"
	shop_consumable_category_button.text = "Расходники"
	shop_panel.add_child(shop_consumable_category_button)

	shop_tackle_category_button = Button.new()
	shop_tackle_category_button.name = "ShopTackleCategoryButton"
	shop_tackle_category_button.text = "Снасти"
	shop_panel.add_child(shop_tackle_category_button)

	shop_items_container = Control.new()
	shop_items_container.name = "ShopItemsContainer"
	shop_panel.add_child(shop_items_container)

	shop_notice_label = Label.new()
	shop_notice_label.name = "ShopNoticeLabel"
	shop_notice_label.text = ""
	shop_notice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shop_panel.add_child(shop_notice_label)

	shop_close_button = Button.new()
	shop_close_button.name = "ShopCloseButton"
	shop_close_button.text = "Закрыть"
	shop_panel.add_child(shop_close_button)

	shop_buy_audio = AudioStreamPlayer.new()
	shop_buy_audio.name = "ShopBuyAudio"
	add_child(shop_buy_audio)

	shop_error_audio = AudioStreamPlayer.new()
	shop_error_audio.name = "ShopErrorAudio"
	add_child(shop_error_audio)

func _ensure_keepnet_ui_nodes() -> void:
	if basket_backdrop != null:
		return

	basket_backdrop = ColorRect.new()
	basket_backdrop.name = "BasketBackdrop"
	basket_backdrop.visible = false
	basket_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	basket_backdrop.color = Color(0.0, 0.0, 0.0, 0.54)
	add_child(basket_backdrop)
	move_child(basket_backdrop, basket_panel.get_index())

	basket_frame_panel = Panel.new()
	basket_frame_panel.name = "BasketFramePanel"
	basket_frame_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	basket_frame_panel.z_index = 0
	basket_panel.add_child(basket_frame_panel)

	basket_stats_label = Label.new()
	basket_stats_label.name = "BasketStatsLabel"
	basket_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	basket_stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	basket_stats_label.z_index = 2
	basket_panel.add_child(basket_stats_label)

	basket_scroll = ScrollContainer.new()
	basket_scroll.name = "BasketScroll"
	basket_scroll.z_index = 2
	basket_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	basket_panel.add_child(basket_scroll)

	basket_cards_grid = GridContainer.new()
	basket_cards_grid.name = "BasketCardsGrid"
	basket_cards_grid.columns = 2
	basket_scroll.add_child(basket_cards_grid)

	basket_notice_label = Label.new()
	basket_notice_label.name = "BasketNoticeLabel"
	basket_notice_label.text = ""
	basket_notice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	basket_notice_label.z_index = 2
	basket_panel.add_child(basket_notice_label)

func _ensure_tackle_ui_nodes() -> void:
	if tackle_panel != null:
		return

	tackle_backdrop = ColorRect.new()
	tackle_backdrop.name = "TackleBackdrop"
	tackle_backdrop.visible = false
	tackle_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	tackle_backdrop.color = Color(0.0, 0.0, 0.0, 0.54)
	add_child(tackle_backdrop)

	tackle_panel = Panel.new()
	tackle_panel.name = "TacklePanel"
	tackle_panel.visible = false
	tackle_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(tackle_panel)

	tackle_title_label = Label.new()
	tackle_title_label.name = "TackleTitleLabel"
	tackle_title_label.text = "Снасти"
	tackle_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tackle_panel.add_child(tackle_title_label)

	tackle_current_label = Label.new()
	tackle_current_label.name = "TackleCurrentLabel"
	tackle_current_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tackle_panel.add_child(tackle_current_label)

	tackle_rod_button = Button.new()
	tackle_rod_button.name = "TackleRodButton"
	tackle_rod_button.text = "Удочки"
	tackle_panel.add_child(tackle_rod_button)

	tackle_line_button = Button.new()
	tackle_line_button.name = "TackleLineButton"
	tackle_line_button.text = "Лески"
	tackle_panel.add_child(tackle_line_button)

	tackle_float_button = Button.new()
	tackle_float_button.name = "TackleFloatButton"
	tackle_float_button.text = "Поплавки"
	tackle_panel.add_child(tackle_float_button)

	tackle_hook_button = Button.new()
	tackle_hook_button.name = "TackleHookButton"
	tackle_hook_button.text = "Крючки"
	tackle_panel.add_child(tackle_hook_button)

	tackle_bait_button = Button.new()
	tackle_bait_button.name = "TackleBaitButton"
	tackle_bait_button.text = "Наживки"
	tackle_panel.add_child(tackle_bait_button)

	tackle_item_list = ItemList.new()
	tackle_item_list.name = "TackleItemList"
	tackle_item_list.select_mode = ItemList.SELECT_SINGLE
	tackle_item_list.allow_reselect = true
	tackle_panel.add_child(tackle_item_list)

	tackle_details_label = Label.new()
	tackle_details_label.name = "TackleDetailsLabel"
	tackle_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tackle_panel.add_child(tackle_details_label)

	tackle_compare_label = Label.new()
	tackle_compare_label.name = "TackleCompareLabel"
	tackle_compare_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tackle_panel.add_child(tackle_compare_label)

	tackle_depth_label = Label.new()
	tackle_depth_label.name = "TackleDepthLabel"
	tackle_depth_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tackle_panel.add_child(tackle_depth_label)

	tackle_depth_minus_button = Button.new()
	tackle_depth_minus_button.name = "TackleDepthMinusButton"
	tackle_depth_minus_button.text = "-"
	tackle_panel.add_child(tackle_depth_minus_button)

	tackle_depth_plus_button = Button.new()
	tackle_depth_plus_button.name = "TackleDepthPlusButton"
	tackle_depth_plus_button.text = "+"
	tackle_panel.add_child(tackle_depth_plus_button)

	tackle_hint_label = Label.new()
	tackle_hint_label.name = "TackleHintLabel"
	tackle_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tackle_panel.add_child(tackle_hint_label)

	tackle_equip_button = Button.new()
	tackle_equip_button.name = "TackleEquipButton"
	tackle_equip_button.text = "Экипировать"
	tackle_panel.add_child(tackle_equip_button)

	tackle_close_button = Button.new()
	tackle_close_button.name = "TackleCloseButton"
	tackle_close_button.text = "Закрыть"
	tackle_panel.add_child(tackle_close_button)

	toast_label = Label.new()
	toast_label.name = "ToastLabel"
	toast_label.visible = false
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(toast_label)

func _ensure_waterbody_ui_nodes() -> void:
	if waterbody_panel != null:
		return

	waterbody_backdrop = ColorRect.new()
	waterbody_backdrop.name = "WaterbodyBackdrop"
	waterbody_backdrop.visible = false
	waterbody_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	waterbody_backdrop.color = Color(0.0, 0.0, 0.0, 0.54)
	add_child(waterbody_backdrop)

	waterbody_panel = Panel.new()
	waterbody_panel.name = "WaterbodyPanel"
	waterbody_panel.visible = false
	waterbody_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(waterbody_panel)

	waterbody_title_label = Label.new()
	waterbody_title_label.name = "WaterbodyTitleLabel"
	waterbody_title_label.text = "Водоёмы"
	waterbody_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	waterbody_panel.add_child(waterbody_title_label)

	waterbody_item_list = ItemList.new()
	waterbody_item_list.name = "WaterbodyItemList"
	waterbody_item_list.select_mode = ItemList.SELECT_SINGLE
	waterbody_item_list.allow_reselect = true
	waterbody_panel.add_child(waterbody_item_list)

	waterbody_preview = ColorRect.new()
	waterbody_preview.name = "WaterbodyPreview"
	waterbody_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	waterbody_panel.add_child(waterbody_preview)

	waterbody_details_label = Label.new()
	waterbody_details_label.name = "WaterbodyDetailsLabel"
	waterbody_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	waterbody_panel.add_child(waterbody_details_label)

	waterbody_spot_list = ItemList.new()
	waterbody_spot_list.name = "WaterbodySpotList"
	waterbody_spot_list.select_mode = ItemList.SELECT_SINGLE
	waterbody_spot_list.allow_reselect = true
	waterbody_panel.add_child(waterbody_spot_list)

	waterbody_spot_details_label = Label.new()
	waterbody_spot_details_label.name = "WaterbodySpotDetailsLabel"
	waterbody_spot_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	waterbody_panel.add_child(waterbody_spot_details_label)

	waterbody_select_button = Button.new()
	waterbody_select_button.name = "WaterbodySelectButton"
	waterbody_select_button.text = "Перейти"
	waterbody_panel.add_child(waterbody_select_button)

	waterbody_close_button = Button.new()
	waterbody_close_button.name = "WaterbodyCloseButton"
	waterbody_close_button.text = "Закрыть"
	waterbody_panel.add_child(waterbody_close_button)

func _make_panel_style(
	bg_color: Color,
	border_color: Color,
	radius: int = 12,
	shadow_size: int = 8,
	shadow_color: Color = Color(0.0, 0.0, 0.0, 0.28)
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = shadow_color
	style.shadow_size = shadow_size
	style.content_margin_left = 8.0
	style.content_margin_top = 6.0
	style.content_margin_right = 8.0
	style.content_margin_bottom = 6.0
	return style

func _get_panel_style(style_name: String) -> StyleBoxFlat:
	match style_name:
		STYLE_INFO_CARD:
			return _make_panel_style(
				Color(0.075, 0.145, 0.155, 0.58),
				Color(0.82, 0.98, 0.90, 0.30),
				14,
				8,
				Color(0.0, 0.0, 0.0, 0.18)
			)
		_:
			return _make_panel_style(
				Color(0.060, 0.105, 0.115, 0.58),
				Color(0.82, 0.98, 0.90, 0.34),
				16,
				10,
				Color(0.0, 0.0, 0.0, 0.20)
			)

func _apply_panel_style(panel: Panel, style_name: String = STYLE_HUD_PANEL) -> void:
	panel.add_theme_stylebox_override("panel", _get_panel_style(style_name))

func _get_button_style(style_name: String, state: String = "normal") -> StyleBoxFlat:
	var radius := 12
	var shadow_size := 3
	var shadow_color := Color(0.0, 0.0, 0.0, 0.14)
	var border_color := Color(0.80, 0.96, 0.86, 0.24)
	var bg_color := Color(0.08, 0.15, 0.15, 0.66)

	match style_name:
		STYLE_PRIMARY_BUTTON:
			radius = 18
			shadow_size = 14
			shadow_color = Color(0.16, 0.78, 0.42, 0.32)
			border_color = Color(0.70, 1.00, 0.73, 0.46)
			bg_color = Color(0.12, 0.44, 0.26, 0.96)

			if state == "hover":
				bg_color = Color(0.15, 0.52, 0.31, 1.0)
				border_color = Color(0.78, 1.0, 0.78, 0.60)
			elif state == "pressed":
				bg_color = Color(0.08, 0.34, 0.21, 1.0)
				shadow_size = 7
			elif state == "disabled":
				bg_color = Color(0.08, 0.17, 0.13, 0.58)
				border_color = Color(0.62, 0.70, 0.66, 0.16)
				shadow_color = Color(0.0, 0.0, 0.0, 0.12)
		STYLE_BOTTOM_NAV_ACTIVE:
			radius = 13
			shadow_size = 6
			shadow_color = Color(0.10, 0.56, 0.32, 0.22)
			border_color = Color(0.68, 0.96, 0.76, 0.42)
			bg_color = Color(0.12, 0.31, 0.22, 0.92)
		STYLE_BOTTOM_NAV_BUTTON:
			radius = 13
			shadow_size = 2
			border_color = Color(0.84, 0.98, 0.90, 0.22)
			bg_color = Color(0.070, 0.115, 0.120, 0.58)

			if state == "hover":
				bg_color = Color(0.095, 0.155, 0.150, 0.76)
			elif state == "pressed":
				bg_color = Color(0.095, 0.24, 0.17, 0.88)
			elif state == "disabled":
				bg_color = Color(0.060, 0.080, 0.082, 0.46)
				border_color = Color(0.80, 0.86, 0.82, 0.12)
		_:
			radius = 12
			shadow_size = 2
			border_color = Color(0.82, 0.96, 0.88, 0.20)
			bg_color = Color(0.070, 0.125, 0.125, 0.58)

			if state == "hover":
				bg_color = Color(0.095, 0.160, 0.150, 0.76)
			elif state == "pressed":
				bg_color = Color(0.095, 0.240, 0.160, 0.88)
			elif state == "disabled":
				bg_color = Color(0.060, 0.075, 0.076, 0.44)
				border_color = Color(0.65, 0.70, 0.68, 0.14)

	return _make_panel_style(bg_color, border_color, radius, shadow_size, shadow_color)

func _apply_button_style(button: Button, style_name: String = STYLE_SECONDARY_BUTTON) -> void:
	button.add_theme_stylebox_override("normal", _get_button_style(style_name, "normal"))
	button.add_theme_stylebox_override("hover", _get_button_style(style_name, "hover"))
	button.add_theme_stylebox_override("pressed", _get_button_style(style_name, "pressed"))
	button.add_theme_stylebox_override("disabled", _get_button_style(style_name, "disabled"))
	button.add_theme_color_override("font_color", Color(0.90, 0.97, 0.92, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.98, 1.0, 0.96, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.84, 0.96, 0.86, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.66, 0.74, 0.70, 0.82))

func _apply_label_style(label: Label, primary: bool = false) -> void:
	if primary:
		label.add_theme_color_override("font_color", Color(0.96, 1.0, 0.96, 1.0))
		label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.28))
		label.add_theme_constant_override("shadow_offset_x", 0)
		label.add_theme_constant_override("shadow_offset_y", 1)
	else:
		label.add_theme_color_override("font_color", Color(0.82, 0.93, 0.88, 0.96))

func _make_scene_shader_material(shader_code: String) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = shader_code

	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _setup_atmosphere_materials() -> void:
	scene_gradient.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV;
			vec3 morning = vec3(0.300, 0.405, 0.335);
			vec3 horizon = vec3(0.170, 0.355, 0.325);
			vec3 water = vec3(0.070, 0.255, 0.275);
			vec3 deep = vec3(0.035, 0.105, 0.155);
			float vertical = smoothstep(0.0, 1.0, uv.y);
			vec3 color = mix(morning, deep, vertical);
			color = mix(color, horizon, (1.0 - smoothstep(0.22, 0.52, abs(uv.y - 0.40))) * 0.34);
			color = mix(color, water, smoothstep(0.46, 0.86, uv.y) * 0.46);
			float center_light = 1.0 - smoothstep(0.0, 0.74, distance(uv, vec2(0.54, 0.36)));
			color += vec3(0.105, 0.130, 0.070) * center_light;
			COLOR = vec4(color, 1.0);
		}
	""")

	mist_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV;
			float drift = TIME * 0.025;
			float haze = sin((uv.x * 8.0) + (uv.y * 3.0) + drift * 10.0) * 0.5 + 0.5;
			float band = smoothstep(0.10, 0.42, uv.y) * (1.0 - smoothstep(0.62, 0.94, uv.y));
			float alpha = (0.090 + haze * 0.070) * band;
			COLOR = vec4(0.64, 0.82, 0.78, alpha);
		}
	""")

	noise_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		float random(vec2 value) {
			return fract(sin(dot(value, vec2(12.9898, 78.233))) * 43758.5453);
		}
		void fragment() {
			float grain = random(floor(UV * 240.0));
			vec3 grain_color = mix(vec3(0.0, 0.02, 0.025), vec3(0.68, 0.86, 0.78), grain);
			COLOR = vec4(grain_color, 0.018);
		}
	""")

	sun_glow_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV;
			float sun = 1.0 - smoothstep(0.0, 0.46, distance(uv, vec2(0.58, 0.18)));
			float upper_warmth = 1.0 - smoothstep(0.0, 0.55, uv.y);
			float reflection = 1.0 - smoothstep(0.0, 0.20, abs(uv.x - 0.55));
			reflection *= smoothstep(0.36, 0.58, uv.y) * (1.0 - smoothstep(0.58, 0.96, uv.y));
			vec3 color = vec3(1.0, 0.78, 0.46);
			COLOR = vec4(color, sun * 0.26 + upper_warmth * 0.035 + reflection * 0.075);
		}
	""")

	far_forest_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		float ridge(vec2 uv, float scale) {
			return sin(uv.x * scale) * 0.018 + sin(uv.x * scale * 0.47 + 1.7) * 0.026;
		}
		void fragment() {
			vec2 uv = UV;
			float tree_line = 0.365 + ridge(uv, 22.0);
			float body = smoothstep(tree_line - 0.010, tree_line + 0.010, uv.y);
			float fade_bottom = 1.0 - smoothstep(0.49, 0.70, uv.y);
			vec3 color = mix(vec3(0.040, 0.115, 0.095), vec3(0.065, 0.155, 0.125), uv.y);
			COLOR = vec4(color, body * fade_bottom * 0.78);
		}
	""")

	mid_forest_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		float ridge(vec2 uv, float scale) {
			return sin(uv.x * scale + 0.8) * 0.026 + sin(uv.x * scale * 0.61) * 0.018;
		}
		void fragment() {
			vec2 uv = UV;
			float tree_line = 0.430 + ridge(uv, 34.0);
			float body = smoothstep(tree_line - 0.012, tree_line + 0.012, uv.y);
			float fade_bottom = 1.0 - smoothstep(0.57, 0.72, uv.y);
			vec3 color = vec3(0.025, 0.095, 0.078);
			COLOR = vec4(color, body * fade_bottom * 0.74);
		}
	""")

	lake_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV;
			float water_mask = smoothstep(0.44, 0.50, uv.y);
			float wave = sin((uv.x * 38.0) + TIME * 0.75) * 0.5 + 0.5;
			float wave2 = sin((uv.x * 77.0) - TIME * 0.45 + uv.y * 9.0) * 0.5 + 0.5;
			float long_highlight = 1.0 - smoothstep(0.0, 0.28, abs(uv.x - 0.55));
			long_highlight *= smoothstep(0.46, 0.58, uv.y) * (1.0 - smoothstep(0.72, 0.96, uv.y));
			float shimmer = (wave * 0.038 + wave2 * 0.024) * smoothstep(0.48, 0.95, uv.y);
			vec3 shallow = vec3(0.105, 0.305, 0.285);
			vec3 deep = vec3(0.025, 0.095, 0.135);
			vec3 color = mix(shallow, deep, smoothstep(0.48, 1.0, uv.y));
			color += vec3(0.13, 0.22, 0.19) * shimmer;
			color += vec3(0.42, 0.50, 0.32) * long_highlight * 0.095;
			COLOR = vec4(color, water_mask * 0.92);
		}
	""")

	reflection_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV;
			float mask = smoothstep(0.50, 0.60, uv.y) * (1.0 - smoothstep(0.86, 1.0, uv.y));
			float center = 1.0 - smoothstep(0.0, 0.24, abs(uv.x - 0.54));
			float lines = sin(uv.y * 115.0 + sin(uv.x * 20.0) + TIME * 0.65) * 0.5 + 0.5;
			float fine_lines = sin(uv.y * 210.0 + uv.x * 9.0 - TIME * 0.42) * 0.5 + 0.5;
			float alpha = center * mask * (lines * 0.09 + fine_lines * 0.035);
			COLOR = vec4(0.86, 0.98, 0.76, alpha);
		}
	""")

	foreground_mist_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV;
			float drift = TIME * 0.018;
			float fog = sin((uv.x + drift) * 11.0 + uv.y * 4.0) * 0.5 + 0.5;
			float lower_band = smoothstep(0.52, 0.70, uv.y) * (1.0 - smoothstep(0.95, 1.0, uv.y));
			float horizon_band = smoothstep(0.34, 0.43, uv.y) * (1.0 - smoothstep(0.47, 0.60, uv.y));
			COLOR = vec4(0.72, 0.88, 0.82, (fog * 0.075 + 0.045) * (lower_band + horizon_band * 0.8));
		}
	""")

	vignette_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV - vec2(0.5, 0.48);
			float edge = smoothstep(0.36, 0.78, length(uv));
			COLOR = vec4(0.0, 0.018, 0.022, edge * 0.28);
		}
	""")

	float_glow.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV - vec2(0.5);
			float pulse = 0.86 + sin(TIME * 1.35) * 0.10;
			float glow = 1.0 - smoothstep(0.0, 0.50, length(uv));
			COLOR = vec4(0.82, 1.0, 0.70, glow * 0.32 * pulse);
		}
	""")

	float_marker.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV;
			float edge = smoothstep(0.50, 0.28, abs(uv.x - 0.5));
			float top = 1.0 - smoothstep(0.30, 0.38, uv.y);
			float mid = smoothstep(0.24, 0.42, uv.y) * (1.0 - smoothstep(0.66, 0.78, uv.y));
			float bottom = smoothstep(0.64, 0.84, uv.y);
			float rim = smoothstep(0.18, 0.48, abs(uv.x - 0.5));
			vec3 red = vec3(0.92, 0.18, 0.12);
			vec3 cream = vec3(0.95, 1.0, 0.76);
			vec3 dark_tip = vec3(0.14, 0.28, 0.20);
			vec3 color = mix(cream, red, top);
			color = mix(color, cream + vec3(0.03, 0.02, 0.00), mid * 0.38);
			color = mix(color, dark_tip, bottom * 0.62);
			color += vec3(0.16, 0.22, 0.08) * rim;
			COLOR = vec4(color, edge);
		}
	""")

	float_ripple.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = (UV - vec2(0.5)) * vec2(1.0, 2.35);
			float d = length(uv);
			float ring = 1.0 - smoothstep(0.020, 0.045, abs(d - 0.33));
			float ring2 = 1.0 - smoothstep(0.020, 0.045, abs(d - 0.48));
			float pulse = 0.72 + sin(TIME * 1.25) * 0.18;
			COLOR = vec4(0.72, 0.96, 0.88, (ring * 0.16 + ring2 * 0.08) * pulse);
		}
	""")

	float_reflection.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = (UV - vec2(0.5)) * vec2(1.0, 2.55);
			float ellipse = 1.0 - smoothstep(0.18, 0.50, length(uv));
			float shimmer = 0.70 + sin(TIME * 1.05 + UV.x * 10.0) * 0.12;
			float fade = smoothstep(0.12, 0.42, UV.y) * (1.0 - smoothstep(0.76, 1.0, UV.y));
			COLOR = vec4(0.92, 1.0, 0.80, ellipse * fade * shimmer * 0.22);
		}
	""")

	action_glow.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV - vec2(0.5);
			uv.x *= 1.75;
			float pulse = 0.72 + sin(TIME * 1.15) * 0.12;
			float glow = 1.0 - smoothstep(0.08, 0.64, length(uv));
			COLOR = vec4(0.32, 0.92, 0.46, glow * 0.24 * pulse);
		}
	""")

	catch_popup_backdrop.material = _make_scene_shader_material("""
		shader_type canvas_item;
		uniform float focus_strength = 0.58;
		uniform float edge_strength = 0.18;
		uniform vec4 focus_color : source_color = vec4(0.015, 0.045, 0.044, 1.0);
		void fragment() {
			vec2 uv = UV - vec2(0.5);
			float edge = smoothstep(0.22, 0.72, length(uv));
			float center_haze = 1.0 - smoothstep(0.0, 0.54, length(uv * vec2(1.0, 1.28)));
			vec3 color = mix(vec3(0.0, 0.010, 0.014), focus_color.rgb, center_haze);
			COLOR = vec4(color, focus_strength + edge * edge_strength);
		}
	""")

	catch_popup_glow.material = _make_scene_shader_material("""
		shader_type canvas_item;
		uniform vec4 glow_color : source_color = vec4(0.35, 0.90, 0.50, 1.0);
		uniform float glow_power = 0.42;
		uniform float pulse_speed = 1.05;
		void fragment() {
			vec2 uv = UV - vec2(0.5);
			uv.x *= 1.35;
			float pulse = 0.84 + sin(TIME * pulse_speed) * 0.10;
			float glow = 1.0 - smoothstep(0.06, 0.58, length(uv));
			COLOR = vec4(glow_color.rgb, glow * glow_power * pulse);
		}
	""")

	catch_popup_particles.material = _make_scene_shader_material("""
		shader_type canvas_item;
		uniform vec4 particle_color : source_color = vec4(0.74, 1.0, 0.74, 1.0);
		uniform float sparkle_power = 0.20;
		uniform float drift_speed = 0.08;
		uniform float particle_scale = 1.0;
		float random(vec2 value) {
			return fract(sin(dot(value, vec2(12.9898, 78.233))) * 43758.5453);
		}
		void fragment() {
			vec2 uv = UV;
			uv.y += TIME * drift_speed * 0.035;
			uv.x += sin(TIME * 0.16 + uv.y * 5.0) * 0.010;
			vec2 cell = floor(uv * vec2(36.0, 20.0) * particle_scale);
			float seed = random(cell);
			vec2 center = (cell + vec2(seed, random(cell + 4.17))) / (vec2(36.0, 20.0) * particle_scale);
			float d = distance(uv, center);
			float sparkle = 1.0 - smoothstep(0.002, 0.010 / max(particle_scale, 0.1), d);
			float twinkle = 0.42 + sin(TIME * (0.75 + seed * 1.7) + seed * 6.28) * 0.28;
			float focus = 1.0 - smoothstep(0.18, 0.68, distance(uv, vec2(0.5, 0.47)));
			COLOR = vec4(particle_color.rgb, sparkle * twinkle * focus * sparkle_power);
		}
	""")

	catch_fish_visual.material = _make_scene_shader_material("""
		shader_type canvas_item;
		uniform vec4 rim_color : source_color = vec4(0.84, 1.0, 0.76, 1.0);
		uniform vec4 shimmer_color : source_color = vec4(1.0, 0.95, 0.62, 1.0);
		uniform float shimmer_strength = 0.16;
		uniform float shimmer_speed = 0.18;
		void fragment() {
			vec4 tex = texture(TEXTURE, UV);
			float sweep = 1.0 - smoothstep(0.0, 0.18, abs((UV.x + UV.y * 0.16) - (fract(TIME * shimmer_speed) * 1.34 - 0.18)));
			float rim = smoothstep(0.06, 0.70, tex.a) * (1.0 - smoothstep(0.70, 1.0, tex.a));
			vec3 color = tex.rgb + shimmer_color.rgb * sweep * tex.a * shimmer_strength;
			color = mix(color, rim_color.rgb, rim * 0.18);
			COLOR = vec4(color, tex.a);
		}
	""")

	catch_fish_shadow.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec4 tex = texture(TEXTURE, UV);
			COLOR = vec4(0.0, 0.0, 0.0, tex.a * 0.30);
		}
	""")

func _configure_fishing_presence_style() -> void:
	fishing_presence_layer.z_index = 4

	for rod_line in [
		rod_shadow,
		rod_handle_shadow,
		rod_handle,
		rod_handle_wrap_a,
		rod_handle_wrap_b,
		rod_blank,
		rod_near_section,
		rod_mid_section,
		rod_tip_section,
		rod_highlight,
		rod_ferrule_near,
		rod_ferrule_mid,
		rod_ferrule_tip,
		rod_reel_stem,
		rod_reel_spool,
		rod_reel_handle
	]:
		rod_line.joint_mode = Line2D.LINE_JOINT_ROUND
		rod_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		rod_line.end_cap_mode = Line2D.LINE_CAP_ROUND

	rod_shadow.width = 11.0
	rod_shadow.default_color = Color(0.0, 0.0, 0.0, 0.24)
	rod_shadow.antialiased = true

	rod_handle_shadow.width = 16.0
	rod_handle_shadow.default_color = Color(0.0, 0.0, 0.0, 0.20)
	rod_handle_shadow.antialiased = true

	rod_handle.width = 14.0
	rod_handle.default_color = Color(0.12, 0.078, 0.047, 0.98)
	rod_handle.antialiased = true

	rod_handle_wrap_a.width = 2.0
	rod_handle_wrap_a.default_color = Color(0.86, 0.64, 0.34, 0.58)
	rod_handle_wrap_a.antialiased = true

	rod_handle_wrap_b.width = 2.0
	rod_handle_wrap_b.default_color = Color(0.86, 0.64, 0.34, 0.48)
	rod_handle_wrap_b.antialiased = true

	rod_blank.width = 6.0
	rod_blank.default_color = Color(0.13, 0.105, 0.065, 0.98)
	rod_blank.antialiased = true

	rod_near_section.width = 8.0
	rod_near_section.default_color = Color(0.29, 0.185, 0.090, 0.98)
	rod_near_section.antialiased = true

	rod_mid_section.width = 4.8
	rod_mid_section.default_color = Color(0.25, 0.165, 0.082, 0.96)
	rod_mid_section.antialiased = true

	rod_tip_section.width = 2.2
	rod_tip_section.default_color = Color(0.19, 0.130, 0.075, 0.92)
	rod_tip_section.antialiased = true

	rod_highlight.width = 1.4
	rod_highlight.default_color = Color(0.92, 0.78, 0.48, 0.42)
	rod_highlight.antialiased = true

	rod_ferrule_near.width = 2.2
	rod_ferrule_near.default_color = Color(0.92, 0.78, 0.50, 0.52)
	rod_ferrule_near.antialiased = true

	rod_ferrule_mid.width = 1.8
	rod_ferrule_mid.default_color = Color(0.92, 0.78, 0.50, 0.46)
	rod_ferrule_mid.antialiased = true

	rod_ferrule_tip.width = 1.3
	rod_ferrule_tip.default_color = Color(0.92, 0.78, 0.50, 0.40)
	rod_ferrule_tip.antialiased = true

	rod_reel_stem.width = 3.2
	rod_reel_stem.default_color = Color(0.17, 0.18, 0.15, 0.82)
	rod_reel_stem.antialiased = true

	rod_reel_spool.width = 3.0
	rod_reel_spool.default_color = Color(0.52, 0.58, 0.50, 0.72)
	rod_reel_spool.antialiased = true

	rod_reel_handle.width = 2.2
	rod_reel_handle.default_color = Color(0.52, 0.58, 0.50, 0.70)
	rod_reel_handle.antialiased = true

	fishing_line_glow.width = 1.8
	fishing_line_glow.default_color = Color(0.72, 1.0, 0.88, 0.08)
	fishing_line_glow.antialiased = true

	fishing_line.width = 0.8
	fishing_line.default_color = Color(0.86, 0.96, 0.92, 0.36)
	fishing_line.antialiased = true

func _get_line_normal(from: Vector2, to: Vector2, prefer_down: bool = false) -> Vector2:
	var direction := (to - from).normalized()

	if direction == Vector2.ZERO:
		direction = Vector2.LEFT

	var normal := Vector2(-direction.y, direction.x)

	if prefer_down and normal.y < 0.0:
		normal = -normal

	return normal

func _make_ellipse_points(center: Vector2, radius: Vector2, steps: int = 16) -> PackedVector2Array:
	var points := PackedVector2Array()
	var safe_steps: int = max(steps, 8)

	for index in range(safe_steps + 1):
		var angle := TAU * float(index) / float(safe_steps)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))

	return points

func _set_short_cross_line(line: Line2D, center: Vector2, direction_to_tip: Vector2, length: float) -> void:
	var normal := _get_line_normal(center, direction_to_tip)
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
	var points := PackedVector2Array()
	var safe_steps: int = max(steps, 1)

	for index in range(safe_steps + 1):
		var local_t: float = float(index) / float(safe_steps)
		var curve_t: float = lerp(from_t, to_t, local_t)
		points.append(_cubic_bezier_point(start, control_a, control_b, end, curve_t))

	return points

func _get_presence_state() -> String:
	if _presence_bite_timer > 0.0:
		return "bite"

	match _fishing_ui_state:
		FishingUiState.WAITING:
			return "waiting"
		FishingUiState.FIGHTING:
			return "reeling"
		FishingUiState.CAUGHT:
			return "caught"
		_:
			return "idle"

func _get_presence_reeling_intensity() -> float:
	var tension: float = clamp(float(_last_reeling_state.get("tension", 0.0)), 0.0, 1.0)
	var fish_force: float = clamp(float(_last_reeling_state.get("fish_force", 0.0)) * 0.7, 0.0, 1.0)
	var struggle_power: float = clamp(float(_last_reeling_state.get("struggle_power", 0.0)) * 0.6, 0.0, 1.0)
	var risk: float = max(
		clamp(float(_last_reeling_state.get("break_risk", 0.0)), 0.0, 1.0),
		clamp(float(_last_reeling_state.get("escape_risk", 0.0)), 0.0, 1.0)
	)
	return clamp(tension * 0.42 + fish_force * 0.28 + struggle_power * 0.22 + risk * 0.18, 0.0, 1.0)

func _offset_points(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var shifted := PackedVector2Array()

	for point in points:
		shifted.append(point + offset)

	return shifted

func _set_float_presence(center: Vector2, state: String, intensity: float) -> void:
	var ripple_scale := 1.0
	var glow_scale := 1.0
	var reflection_scale := 1.0
	var marker_height := 52.0
	var marker_width := 11.0
	var marker_sink := 0.0
	var marker_tilt := sin(_presence_time * 0.9) * 1.2
	var ripple_alpha := 0.86
	var glow_alpha := 1.0
	var reflection_alpha := 0.74

	match state:
		"bite":
			var bite_pulse: float = abs(sin(_presence_time * 18.0))
			ripple_scale = 1.20 + bite_pulse * 0.14
			glow_scale = 1.20
			reflection_scale = 1.12 + bite_pulse * 0.10
			marker_height = 39.0
			marker_width = 12.0
			marker_sink = 10.0 + bite_pulse * 8.0
			marker_tilt = sin(_presence_time * 22.0) * 6.5
			ripple_alpha = 1.0
			glow_alpha = 1.18
			reflection_alpha = 1.0
		"reeling":
			ripple_scale = 1.07 + intensity * 0.22 + sin(_presence_time * 3.5) * 0.03
			glow_scale = 1.10 + intensity * 0.18
			reflection_scale = 1.04 + intensity * 0.12
			marker_height = 50.0 - intensity * 7.0
			marker_width = 11.5
			marker_sink = intensity * 5.0 + sin(_presence_time * 5.0) * 2.0
			marker_tilt = sin(_presence_time * 6.4) * (2.0 + intensity * 4.0)
			ripple_alpha = 0.92 + intensity * 0.18
			glow_alpha = 1.05 + intensity * 0.18
			reflection_alpha = 0.82 + intensity * 0.14
		"caught":
			ripple_scale = 1.08
			glow_scale = 1.16
			reflection_scale = 1.08
			marker_sink = -3.0 + sin(_presence_time * 2.0) * 1.2
			marker_tilt = sin(_presence_time * 1.4) * 1.4
		_:
			ripple_scale = 1.0 + sin(_presence_time * 1.25) * 0.025
			glow_scale = 1.0 + sin(_presence_time * 1.1) * 0.035
			reflection_scale = 1.0 + sin(_presence_time * 1.0) * 0.018

	var ripple_size := Vector2(96.0, 38.0) * ripple_scale
	float_ripple.size = ripple_size
	float_ripple.position = center + Vector2(-ripple_size.x * 0.5, 15.0 - (ripple_size.y - 38.0) * 0.5)
	float_ripple.modulate = Color(1.0, 1.0, 1.0, ripple_alpha)

	var reflection_size := Vector2(74.0, 26.0) * reflection_scale
	float_reflection.size = reflection_size
	float_reflection.position = center + Vector2(-reflection_size.x * 0.5, 17.0 - (reflection_size.y - 26.0) * 0.5)
	float_reflection.modulate = Color(1.0, 1.0, 1.0, reflection_alpha)

	var glow_size := Vector2(64.0, 64.0) * glow_scale
	float_glow.size = glow_size
	float_glow.position = center - glow_size * 0.5 + Vector2(0.0, 9.0)
	float_glow.modulate = Color(1.0, 1.0, 1.0, glow_alpha)

	float_marker.size = Vector2(marker_width, marker_height)
	float_marker.pivot_offset = float_marker.size * Vector2(0.5, 0.72)
	float_marker.position = center + Vector2(-marker_width * 0.5, -marker_height * 0.62 + marker_sink)
	float_marker.rotation = deg_to_rad(marker_tilt)
	float_marker.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _update_fishing_presence(delta: float) -> void:
	if not _presence_has_layout:
		return

	_presence_time += delta
	_presence_bite_timer = max(_presence_bite_timer - delta, 0.0)
	_presence_caught_timer = max(_presence_caught_timer - delta, 0.0)

	var state := _get_presence_state()
	var intensity := _get_presence_reeling_intensity()

	if state == "bite":
		intensity = max(intensity, 0.9)
	elif state == "caught":
		intensity = max(intensity, 0.35 + _presence_caught_timer * 0.15)
	elif state == "idle":
		intensity *= 0.2
	elif state == "waiting":
		intensity *= 0.35

	var screen_size := get_viewport_rect().size
	var scene_breath := Vector2(sin(_presence_time * 0.34) * 1.0, sin(_presence_time * 0.27) * 0.6)
	var mist_alpha: float = 0.92 + sin(_presence_time * 0.28) * 0.05
	var light_alpha: float = 0.96 + sin(_presence_time * 0.22) * 0.04
	foreground_mist_layer.modulate = Color(1.0, 1.0, 1.0, mist_alpha)
	reflection_layer.modulate = Color(1.0, 1.0, 1.0, light_alpha)
	sun_glow_layer.modulate = Color(1.0, 1.0, 1.0, light_alpha)

	var idle_wave := Vector2(sin(_presence_time * 1.1) * 2.2, sin(_presence_time * 1.55) * 2.0)
	var float_offset := idle_wave

	match state:
		"bite":
			float_offset += Vector2(sin(_presence_time * 22.0) * 7.0, 14.0 + abs(sin(_presence_time * 18.0)) * 9.0)
		"reeling":
			float_offset += Vector2(sin(_presence_time * 7.7) * (2.0 + intensity * 3.5), sin(_presence_time * 6.3) * (2.0 + intensity * 3.0))
		"caught":
			float_offset += Vector2(sin(_presence_time * 1.8) * 1.4, -4.0 + sin(_presence_time * 2.1) * 1.0)

	var target_float_center := _float_base_center + float_offset + scene_breath * 0.35
	var float_follow := 7.0

	if state == "bite":
		float_follow = 13.0
	elif state == "reeling":
		float_follow = 9.0

	_float_visual_center = _float_visual_center.lerp(target_float_center, clamp(delta * float_follow, 0.0, 1.0))
	_set_float_presence(_float_visual_center, state, intensity)

	var rod_butt := Vector2(screen_size.x - 62.0, screen_size.y - 44.0) + scene_breath
	var rod_tip_rest := _float_base_center + Vector2(118.0, -104.0)
	var tip_pull_direction := (_float_visual_center - rod_tip_rest).normalized()

	if tip_pull_direction == Vector2.ZERO:
		tip_pull_direction = Vector2(-0.68, 0.74)

	var rod_tip_target := rod_tip_rest

	match state:
		"bite":
			var bite_pull: float = 12.0 + abs(sin(_presence_time * 12.0)) * 7.0
			var bite_shake: Vector2 = _get_line_normal(rod_tip_rest, _float_visual_center) * sin(_presence_time * 18.0) * 1.8
			rod_tip_target += tip_pull_direction * bite_pull + bite_shake
		"reeling":
			var fight_pull: float = 8.0 + intensity * 26.0
			var fight_pulse: Vector2 = tip_pull_direction * sin(_presence_time * 4.2) * (0.7 + intensity * 1.5)
			rod_tip_target += tip_pull_direction * fight_pull + fight_pulse
		"caught":
			rod_tip_target += tip_pull_direction * 4.0 + Vector2(-3.0, -3.0 + sin(_presence_time * 1.8) * 1.1)
		_:
			rod_tip_target += Vector2(sin(_presence_time * 0.55) * 0.8, 3.0 + sin(_presence_time * 0.72) * 0.7)

	var rod_tip_follow := 4.4

	if state == "bite":
		rod_tip_follow = 7.5
	elif state == "reeling":
		rod_tip_follow = 5.2

	_rod_tip_visual = _rod_tip_visual.lerp(rod_tip_target, clamp(delta * rod_tip_follow, 0.0, 1.0))

	var line_end := _float_visual_center + Vector2(0.0, -24.0)
	var line_pull_direction := (line_end - _rod_tip_visual).normalized()

	if line_pull_direction == Vector2.ZERO:
		line_pull_direction = tip_pull_direction

	var rod_bend_direction := _get_line_normal(rod_butt, _rod_tip_visual, true)

	if rod_bend_direction.dot(line_pull_direction) < 0.0:
		rod_bend_direction = -rod_bend_direction

	if state == "idle" or state == "waiting":
		rod_bend_direction = rod_bend_direction.lerp(Vector2.DOWN, 0.34).normalized()

	var bend_direction_follow := 3.8

	if state == "bite":
		bend_direction_follow = 6.0
	elif state == "reeling":
		bend_direction_follow = 4.6

	_rod_bend_direction_visual = _rod_bend_direction_visual.lerp(rod_bend_direction, clamp(delta * bend_direction_follow, 0.0, 1.0))

	if _rod_bend_direction_visual == Vector2.ZERO:
		_rod_bend_direction_visual = rod_bend_direction
	else:
		_rod_bend_direction_visual = _rod_bend_direction_visual.normalized()

	var tension: float = clamp(float(_last_reeling_state.get("tension", 0.0)), 0.0, 1.0)
	var target_bend_amount := 3.2

	match state:
		"bite":
			target_bend_amount = 8.0 + abs(sin(_presence_time * 8.0)) * 2.4
		"reeling":
			var load: float = clamp(tension * 0.62 + intensity * 0.34, 0.0, 1.0)
			target_bend_amount = lerp(4.0, 20.0, load)
		"caught":
			target_bend_amount = 3.6
		_:
			target_bend_amount = 2.8

	target_bend_amount = clamp(target_bend_amount, 1.5, 22.0)

	var bend_amount_follow := 2.8

	if state == "bite":
		bend_amount_follow = 5.0
	elif state == "reeling":
		bend_amount_follow = 3.6

	_rod_bend_amount_visual = lerp(_rod_bend_amount_visual, target_bend_amount, clamp(delta * bend_amount_follow, 0.0, 1.0))

	var rod_highlight_direction := -_rod_bend_direction_visual
	var bend_amount := _rod_bend_amount_visual
	var rod_control_near := rod_butt.lerp(_rod_tip_visual, 0.38) + _rod_bend_direction_visual * (bend_amount * 0.08)
	var rod_control_tip := rod_butt.lerp(_rod_tip_visual, 0.82) + _rod_bend_direction_visual * (bend_amount * 0.58)
	var rod_points := _sample_cubic_curve(rod_butt, rod_control_near, rod_control_tip, _rod_tip_visual, 0.0, 1.0, 14)
	rod_shadow.points = _offset_points(rod_points, _rod_bend_direction_visual * 4.5 + Vector2(2.0, 2.0))
	rod_blank.points = rod_points
	rod_near_section.points = _sample_cubic_curve(rod_butt, rod_control_near, rod_control_tip, _rod_tip_visual, 0.0, 0.52, 6)
	rod_mid_section.points = _sample_cubic_curve(rod_butt, rod_control_near, rod_control_tip, _rod_tip_visual, 0.48, 0.80, 5)
	rod_tip_section.points = _sample_cubic_curve(rod_butt, rod_control_near, rod_control_tip, _rod_tip_visual, 0.76, 1.0, 5)
	rod_highlight.points = _offset_points(rod_points, rod_highlight_direction * 2.0 + Vector2(-0.5, -0.5))
	rod_blank.width = 5.8 + intensity * 0.45
	rod_near_section.width = 8.3 + intensity * 0.35
	rod_mid_section.width = 4.8 + intensity * 0.20
	rod_tip_section.width = 2.1 + intensity * 0.10

	var rod_ring_near := _cubic_bezier_point(rod_butt, rod_control_near, rod_control_tip, _rod_tip_visual, 0.32)
	var rod_ring_mid := _cubic_bezier_point(rod_butt, rod_control_near, rod_control_tip, _rod_tip_visual, 0.60)
	var rod_ring_tip := _cubic_bezier_point(rod_butt, rod_control_near, rod_control_tip, _rod_tip_visual, 0.84)
	_set_short_cross_line(rod_ferrule_near, rod_ring_near, _rod_tip_visual, 7.0)
	_set_short_cross_line(rod_ferrule_mid, rod_ring_mid, _rod_tip_visual, 4.9)
	_set_short_cross_line(rod_ferrule_tip, rod_ring_tip, _rod_tip_visual, 3.2)

	var handle_end := rod_butt + Vector2(82.0, 34.0)
	var handle_points := PackedVector2Array([handle_end, rod_butt])
	rod_handle_shadow.points = _offset_points(handle_points, Vector2(3.0, 4.0))
	rod_handle.points = handle_points
	_set_short_cross_line(rod_handle_wrap_a, handle_end.lerp(rod_butt, 0.34), rod_butt, 7.0)
	_set_short_cross_line(rod_handle_wrap_b, handle_end.lerp(rod_butt, 0.66), rod_butt, 6.0)

	var reel_mount := _cubic_bezier_point(rod_butt, rod_control_near, rod_control_tip, _rod_tip_visual, 0.16)
	var reel_center := reel_mount + _rod_bend_direction_visual * (18.0 + intensity * 2.0)
	rod_reel_stem.points = PackedVector2Array([reel_mount, reel_center])
	rod_reel_spool.points = _make_ellipse_points(reel_center, Vector2(13.0, 8.0), 18)
	rod_reel_handle.points = PackedVector2Array([
		reel_center + Vector2(9.0, -3.0),
		reel_center + Vector2(23.0, -1.0),
		reel_center + Vector2(27.0, 5.0)
	])

	var sag := 20.0

	if state == "reeling":
		sag = lerp(8.0, 1.2, intensity)
	elif state == "bite":
		sag = 2.5
	elif state == "caught":
		sag = 22.0

	var line_start := _rod_tip_visual
	var line_mid_a := line_start.lerp(line_end, 0.34) + Vector2(
		sin(_presence_time * 2.6) * (1.4 + intensity * 1.2),
		sag * 0.58 + sin(_presence_time * 3.0) * (1.1 + intensity)
	)
	var line_mid_b := line_start.lerp(line_end, 0.68) + Vector2(
		sin(_presence_time * 3.1 + 0.8) * (1.0 + intensity),
		sag + sin(_presence_time * 3.6) * (0.9 + intensity)
	)
	var line_points := PackedVector2Array([line_start, line_mid_a, line_mid_b, line_end])
	fishing_line.points = line_points
	fishing_line_glow.points = line_points

	var line_alpha := 0.24
	var glow_alpha := 0.035
	var line_width := 0.72

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

	fishing_line.width = line_width
	fishing_line_glow.width = line_width + 0.8
	fishing_line.default_color = Color(0.86, 0.96, 0.92, line_alpha)
	fishing_line_glow.default_color = Color(0.72, 1.0, 0.88, glow_alpha)

func _setup_layout() -> void:
	var screen_size := get_viewport_rect().size
	var margin := 10.0
	var top_height := 54.0
	var bottom_nav_height := 52.0
	var action_height := 82.0
	var content_top := margin + top_height + 8.0
	var bottom_nav_y := screen_size.y - margin - bottom_nav_height
	var content_bottom := bottom_nav_y - 8.0
	var content_height = max(content_bottom - content_top, 220.0)
	var left_width = clamp(screen_size.x * 0.20, 168.0, 220.0)
	var right_width = clamp(screen_size.x * 0.24, 210.0, 268.0)
	var action_width: float = min(max(screen_size.x * 0.56, 440.0), screen_size.x - margin * 2.0)
	var action_x := (screen_size.x - action_width) * 0.5
	var action_y := bottom_nav_y - action_height - 8.0
	var center_width = max(screen_size.x - left_width - right_width - margin * 4.0, 280.0)
	var center_x = margin + left_width + margin
	var right_x = screen_size.x - margin - right_width

	for node in [
		scene_gradient,
		mist_layer,
		noise_layer,
		sun_glow_layer,
		far_forest_layer,
		mid_forest_layer,
		lake_layer,
		reflection_layer,
		foreground_mist_layer,
		vignette_layer,
		water_panel,
		float_marker,
		float_glow,
		float_ripple,
		float_reflection,
		top_hud_panel,
		left_hud_panel,
		right_hud_panel,
		bottom_nav_panel,
		action_panel,
		action_glow,
		title_label,
		money_label,
		level_label,
		xp_progress_bar,
		clock_label,
		weather_label,
		spot_option_button,
		nav_fish_button,
		fish_button,
		basket_button,
		inventory_button,
		tackle_button,
		shop_button,
		map_button,
		profile_button,
		feed_button,
		auto_button,
		bait_button,
		timer_label,
		tackle_label,
		result_label,
		reeling_panel,
		debug_panel,
		basket_backdrop,
		basket_panel,
		inventory_backdrop,
		inventory_panel,
		tackle_backdrop,
		tackle_panel,
		waterbody_backdrop,
		waterbody_panel,
		shop_backdrop,
		shop_panel,
		catch_popup_backdrop,
		catch_popup_panel
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
		basket_frame_panel,
		basket_title_label,
		basket_stats_label,
		basket_scroll,
		basket_cards_grid,
		basket_contents_label,
		basket_notice_label,
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
		inventory_details_card,
		inventory_tackle_card,
		inventory_item_list,
		inventory_details_label,
		inventory_tackle_label,
		inventory_equip_button,
		inventory_close_button,
		shop_title_label,
		shop_money_label,
		shop_bait_category_button,
		shop_consumable_category_button,
		shop_tackle_category_button,
		shop_items_container,
		shop_notice_label,
		shop_close_button,
		tackle_title_label,
		tackle_current_label,
		tackle_rod_button,
		tackle_line_button,
		tackle_float_button,
		tackle_hook_button,
		tackle_bait_button,
		tackle_item_list,
		tackle_details_label,
		tackle_compare_label,
		tackle_depth_label,
		tackle_depth_minus_button,
		tackle_depth_plus_button,
		tackle_hint_label,
		tackle_equip_button,
		tackle_close_button,
		waterbody_title_label,
		waterbody_item_list,
		waterbody_preview,
		waterbody_details_label,
		waterbody_spot_list,
		waterbody_spot_details_label,
		waterbody_select_button,
		waterbody_close_button,
		catch_popup_particles,
		catch_popup_glow,
		catch_popup_title_label,
		catch_popup_badge_label,
		catch_popup_name_label,
		catch_trophy_banner_label,
		catch_fish_shadow,
		catch_fish_visual,
		catch_popup_stats_label,
		catch_keep_button,
		catch_release_button
	]:
		node.set_anchors_preset(Control.PRESET_TOP_LEFT)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.z_index = -20
	background.color = Color("#12363b")

	for layer in [
		scene_gradient,
		sun_glow_layer,
		far_forest_layer,
		mid_forest_layer,
		lake_layer,
		reflection_layer,
		mist_layer,
		foreground_mist_layer,
		noise_layer,
		vignette_layer
	]:
		layer.set_anchors_preset(Control.PRESET_FULL_RECT)
		layer.offset_left = 0.0
		layer.offset_top = 0.0
		layer.offset_right = 0.0
		layer.offset_bottom = 0.0
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	scene_gradient.z_index = -19
	sun_glow_layer.z_index = -18
	far_forest_layer.z_index = -17
	mid_forest_layer.z_index = -16
	lake_layer.z_index = -15
	reflection_layer.z_index = -14
	mist_layer.z_index = -13
	foreground_mist_layer.z_index = -12
	noise_layer.z_index = -11
	vignette_layer.z_index = 3
	_setup_atmosphere_materials()
	_apply_time_atmosphere()

	water_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			Color(0.035, 0.110, 0.125, 0.10),
			Color(0.78, 0.96, 0.88, 0.18),
			18,
			4,
			Color(0.0, 0.0, 0.0, 0.10)
		)
	)
	_apply_panel_style(top_hud_panel, STYLE_HUD_PANEL)
	_apply_panel_style(left_hud_panel, STYLE_HUD_PANEL)
	_apply_panel_style(right_hud_panel, STYLE_HUD_PANEL)
	_apply_panel_style(bottom_nav_panel, STYLE_HUD_PANEL)
	_apply_panel_style(action_panel, STYLE_INFO_CARD)
	_apply_panel_style(debug_panel, STYLE_INFO_CARD)

	inventory_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	inventory_backdrop.offset_left = 0.0
	inventory_backdrop.offset_top = 0.0
	inventory_backdrop.offset_right = 0.0
	inventory_backdrop.offset_bottom = 0.0
	inventory_backdrop.z_index = 24
	inventory_backdrop.color = Color(0.0, 0.0, 0.0, 0.56)
	inventory_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP

	basket_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	basket_backdrop.offset_left = 0.0
	basket_backdrop.offset_top = 0.0
	basket_backdrop.offset_right = 0.0
	basket_backdrop.offset_bottom = 0.0
	basket_backdrop.z_index = 19
	basket_backdrop.color = Color(0.0, 0.0, 0.0, 0.54)
	basket_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP

	shop_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	shop_backdrop.offset_left = 0.0
	shop_backdrop.offset_top = 0.0
	shop_backdrop.offset_right = 0.0
	shop_backdrop.offset_bottom = 0.0
	shop_backdrop.z_index = 26
	shop_backdrop.color = Color(0.0, 0.0, 0.0, 0.52)
	shop_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP

	tackle_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	tackle_backdrop.offset_left = 0.0
	tackle_backdrop.offset_top = 0.0
	tackle_backdrop.offset_right = 0.0
	tackle_backdrop.offset_bottom = 0.0
	tackle_backdrop.z_index = 28
	tackle_backdrop.color = Color(0.0, 0.0, 0.0, 0.54)
	tackle_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP

	waterbody_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	waterbody_backdrop.offset_left = 0.0
	waterbody_backdrop.offset_top = 0.0
	waterbody_backdrop.offset_right = 0.0
	waterbody_backdrop.offset_bottom = 0.0
	waterbody_backdrop.z_index = 30
	waterbody_backdrop.color = Color(0.0, 0.0, 0.0, 0.54)
	waterbody_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP

	shop_panel.z_index = 27
	shop_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	shop_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			Color(0.055, 0.105, 0.105, 0.92),
			Color(0.82, 1.0, 0.86, 0.34),
			20,
			16,
			Color(0.0, 0.0, 0.0, 0.30)
		)
	)

	tackle_panel.z_index = 29
	tackle_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	tackle_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			Color(0.055, 0.105, 0.105, 0.94),
			Color(0.82, 1.0, 0.86, 0.34),
			20,
			16,
			Color(0.0, 0.0, 0.0, 0.30)
		)
	)

	waterbody_panel.z_index = 31
	waterbody_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	waterbody_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			Color(0.055, 0.105, 0.105, 0.94),
			Color(0.82, 1.0, 0.86, 0.34),
			20,
			16,
			Color(0.0, 0.0, 0.0, 0.30)
		)
	)

	catch_popup_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	catch_popup_backdrop.offset_left = 0.0
	catch_popup_backdrop.offset_top = 0.0
	catch_popup_backdrop.offset_right = 0.0
	catch_popup_backdrop.offset_bottom = 0.0
	catch_popup_backdrop.z_index = 40
	catch_popup_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP

	catch_popup_panel.z_index = 41
	catch_popup_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	catch_popup_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			Color(0.060, 0.115, 0.120, 0.88),
			Color(0.88, 1.0, 0.86, 0.34),
			22,
			18,
			Color(0.0, 0.0, 0.0, 0.36)
		)
	)

	water_panel.position = Vector2(margin, content_top)
	water_panel.size = Vector2(screen_size.x - margin * 2.0, content_height)
	water_panel.z_index = 0
	water_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_configure_fishing_presence_style()

	var float_center := Vector2(screen_size.x * 0.5, content_top + content_height * 0.55)
	_float_base_center = float_center

	if not _presence_has_layout:
		_float_visual_center = float_center
		_rod_tip_visual = float_center + Vector2(108.0, -92.0)
		_rod_bend_direction_visual = Vector2.DOWN
		_rod_bend_amount_visual = 3.0
		_presence_has_layout = true

	float_ripple.position = float_center + Vector2(-48.0, 15.0)
	float_ripple.size = Vector2(96.0, 38.0)
	float_ripple.z_index = 3
	float_ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE

	float_reflection.position = float_center + Vector2(-37.0, 17.0)
	float_reflection.size = Vector2(74.0, 26.0)
	float_reflection.z_index = 2
	float_reflection.mouse_filter = Control.MOUSE_FILTER_IGNORE

	float_glow.position = float_center + Vector2(-32.0, -23.0)
	float_glow.size = Vector2(64.0, 64.0)
	float_glow.z_index = 3
	float_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	float_marker.position = float_center + Vector2(-5.5, -32.0)
	float_marker.size = Vector2(11.0, 52.0)
	float_marker.color = Color(0.92, 1.0, 0.82, 1.0)
	float_marker.z_index = 4
	float_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE

	top_hud_panel.position = Vector2(margin, margin)
	top_hud_panel.size = Vector2(screen_size.x - margin * 2.0, top_height)
	top_hud_panel.z_index = 5

	left_hud_panel.position = Vector2(margin, content_top)
	left_hud_panel.size = Vector2(left_width, min(178.0, content_height))
	left_hud_panel.z_index = 5

	right_hud_panel.position = Vector2(screen_size.x - margin - right_width, content_top)
	right_hud_panel.size = Vector2(right_width, min(236.0, content_height))
	right_hud_panel.z_index = 5

	bottom_nav_panel.position = Vector2(margin, bottom_nav_y)
	bottom_nav_panel.size = Vector2(screen_size.x - margin * 2.0, bottom_nav_height)
	bottom_nav_panel.z_index = 5

	action_panel.position = Vector2(action_x, action_y)
	action_panel.size = Vector2(action_width, action_height)
	action_panel.z_index = 6

	action_glow.position = Vector2(action_x + action_width * 0.5 - 140.0, action_y - 8.0)
	action_glow.size = Vector2(280.0, 96.0)
	action_glow.z_index = 6
	action_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

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

	title_label.text = "Tuman Lake"
	title_label.position = Vector2(margin + 14.0, margin + 10.0)
	title_label.size = Vector2(112.0, 24.0)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.add_theme_font_size_override("font_size", 18)

	money_label.position = Vector2(margin + 138.0, margin + 10.0)
	money_label.size = Vector2(112.0, 22.0)
	money_label.add_theme_font_size_override("font_size", 14)

	level_label.position = Vector2(margin + 262.0, margin + 8.0)
	level_label.size = Vector2(112.0, 22.0)
	level_label.add_theme_font_size_override("font_size", 13)

	xp_progress_bar.position = Vector2(margin + 262.0, margin + 32.0)
	xp_progress_bar.size = Vector2(130.0, 8.0)
	xp_progress_bar.show_percentage = false

	clock_label.text = _get_clock_text()
	clock_label.position = Vector2(screen_size.x - margin - 362.0, margin + 10.0)
	clock_label.size = Vector2(62.0, 22.0)
	clock_label.add_theme_font_size_override("font_size", 13)

	weather_label.text = _get_time_of_day_title()
	weather_label.position = Vector2(screen_size.x - margin - 294.0, margin + 10.0)
	weather_label.size = Vector2(74.0, 22.0)
	weather_label.add_theme_font_size_override("font_size", 13)

	spot_option_button.position = Vector2(screen_size.x - margin - 206.0, margin + 8.0)
	spot_option_button.size = Vector2(190.0, 32.0)
	_apply_button_style(spot_option_button, STYLE_SECONDARY_BUTTON)

	var compact_button_size := Vector2(68.0, 30.0)
	feed_button.position = Vector2(action_x + 14.0, action_y + 26.0)
	feed_button.size = compact_button_size
	feed_button.z_index = 8
	feed_button.add_theme_font_size_override("font_size", 11)
	feed_button.disabled = true
	_apply_button_style(feed_button, STYLE_SECONDARY_BUTTON)

	bait_button.position = Vector2(action_x + 90.0, action_y + 26.0)
	bait_button.size = compact_button_size
	bait_button.z_index = 8
	bait_button.add_theme_font_size_override("font_size", 11)
	_apply_button_style(bait_button, STYLE_SECONDARY_BUTTON)

	auto_button.position = Vector2(action_x + action_width - 82.0, action_y + 26.0)
	auto_button.size = compact_button_size
	auto_button.z_index = 8
	auto_button.add_theme_font_size_override("font_size", 11)
	auto_button.disabled = true
	_apply_button_style(auto_button, STYLE_SECONDARY_BUTTON)

	fish_button.position = Vector2(action_x + action_width * 0.5 - 110.0, action_y + 9.0)
	fish_button.size = Vector2(220.0, 62.0)
	fish_button.z_index = 8
	fish_button.add_theme_font_size_override("font_size", 22)
	_apply_button_style(fish_button, STYLE_PRIMARY_BUTTON)

	var nav_buttons: Array = [
		nav_fish_button,
		inventory_button,
		tackle_button,
		shop_button,
		basket_button,
		map_button,
		profile_button
	]
	var nav_texts: Array = [
		"○ Ловить",
		"□ Инв.",
		"◇ Снасти",
		"$ Магазин",
		"△ Продать",
		"⌖ Карта",
		"◎ Профиль"
	]
	var nav_gap := 6.0
	var nav_x := margin + 12.0
	var nav_y := bottom_nav_y + 9.0
	var nav_width: float = (bottom_nav_panel.size.x - 24.0 - nav_gap * float(nav_buttons.size() - 1)) / float(nav_buttons.size())

	for i in nav_buttons.size():
		var nav_button: Button = nav_buttons[i]
		nav_button.text = nav_texts[i]
		nav_button.position = Vector2(nav_x + float(i) * (nav_width + nav_gap), nav_y)
		nav_button.size = Vector2(nav_width, 34.0)
		nav_button.add_theme_font_size_override("font_size", 11)
		_apply_button_style(nav_button, STYLE_BOTTOM_NAV_ACTIVE if i == 0 else STYLE_BOTTOM_NAV_BUTTON)

	map_button.disabled = false
	profile_button.disabled = true

	timer_label.position = Vector2(margin + 12.0, content_top + 12.0)
	timer_label.size = Vector2(left_width - 24.0, 24.0)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	timer_label.add_theme_font_size_override("font_size", 14)
	timer_label.clip_text = true

	tackle_label.position = Vector2(margin + 12.0, content_top + 42.0)
	tackle_label.size = Vector2(left_width - 24.0, left_hud_panel.size.y - 54.0)
	tackle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tackle_label.add_theme_font_size_override("font_size", 12)
	tackle_label.clip_text = true

	result_label.position = Vector2(screen_size.x - margin - right_width + 12.0, content_top + 12.0)
	result_label.size = Vector2(right_width - 24.0, right_hud_panel.size.y - 24.0)
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.add_theme_font_size_override("font_size", 12)
	result_label.clip_text = true

	var reel_width: float = min(max(screen_size.x * 0.50, 430.0), 540.0)
	var reel_height: float = 60.0
	var reel_x: float = (screen_size.x - reel_width) * 0.5
	var reel_y: float = max(content_top + 10.0, action_y - reel_height - 6.0)

	reeling_panel.position = Vector2(reel_x, reel_y)
	reeling_panel.size = Vector2(reel_width, reel_height)
	reeling_panel.color = Color(0.065, 0.125, 0.130, 0.76)
	reeling_panel.z_index = 7
	reeling_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for reeling_control in [
		fight_title_label,
		tension_label,
		tension_track,
		tension_fill,
		safe_zone,
		tension_marker,
		progress_label,
		progress_track,
		progress_fill,
		fight_status_label,
		fight_hint_label
	]:
		reeling_control.mouse_filter = Control.MOUSE_FILTER_IGNORE

	panel_padding = 12.0
	panel_width = reel_width - panel_padding * 2.0

	fight_title_label.text = "Вываживание"
	fight_title_label.position = Vector2(panel_padding, 5.0)
	fight_title_label.size = Vector2(124.0, 16.0)
	fight_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	fight_title_label.add_theme_font_size_override("font_size", 10)

	fight_status_label.position = Vector2(panel_padding + 126.0, 5.0)
	fight_status_label.size = Vector2(max(panel_width - 126.0, 80.0), 16.0)
	fight_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fight_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fight_status_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	fight_status_label.add_theme_font_size_override("font_size", 10)
	fight_status_label.clip_text = true

	tension_label.position = Vector2(panel_padding, 23.0)
	tension_label.size = Vector2(panel_width * 0.5, 14.0)
	tension_label.add_theme_font_size_override("font_size", 10)

	progress_label.position = Vector2(panel_padding + panel_width * 0.5, 23.0)
	progress_label.size = Vector2(panel_width * 0.5, 14.0)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	progress_label.add_theme_font_size_override("font_size", 10)

	tension_track.position = Vector2(panel_padding, 40.0)
	tension_track.size = Vector2(panel_width, 11.0)
	tension_track.color = Color(0.135, 0.190, 0.190, 0.95)

	progress_track.position = Vector2(panel_padding, 55.0)
	progress_track.size = Vector2(panel_width, 4.0)
	progress_track.color = Color(0.135, 0.190, 0.190, 0.95)

	debug_panel.position = Vector2(screen_size.x - margin - 360.0, content_top + 246.0)
	debug_panel.size = Vector2(350.0, 148.0)
	debug_panel.z_index = 8
	debug_panel.visible = SHOW_DEBUG_PANEL
	debug_label.position = Vector2(10.0, 8.0)
	debug_label.size = Vector2(debug_panel.size.x - 20.0, debug_panel.size.y - 16.0)
	debug_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	debug_label.add_theme_font_size_override("font_size", 12)
	debug_label.clip_text = true

	fight_hint_label.position = Vector2(panel_padding, 5.0)
	fight_hint_label.size = Vector2(panel_width, 16.0)
	fight_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fight_hint_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	fight_hint_label.add_theme_font_size_override("font_size", 10)
	fight_hint_label.visible = false

	for primary_label in [title_label, money_label, level_label, fight_title_label, tension_label, progress_label, basket_title_label, shop_title_label, tackle_title_label]:
		_apply_label_style(primary_label, true)

	for secondary_label in [clock_label, weather_label, timer_label, tackle_label, result_label, fight_status_label, debug_label, basket_stats_label, basket_contents_label, basket_notice_label, shop_money_label, shop_notice_label, tackle_current_label, tackle_details_label, tackle_compare_label]:
		_apply_label_style(secondary_label)

	var basket_width: float = min(screen_size.x - margin * 4.0, 820.0)
	var basket_height: float = min(screen_size.y - margin * 3.0, 468.0)
	var basket_x: float = (screen_size.x - basket_width) * 0.5
	var basket_y: float = (screen_size.y - basket_height) * 0.5
	var basket_padding := 20.0
	var basket_inner_width: float = basket_width - basket_padding * 2.0
	var basket_footer_height := 58.0
	var basket_scroll_y := 108.0
	var basket_notice_width: float = basket_inner_width - 336.0

	basket_panel.position = Vector2(basket_x, basket_y)
	basket_panel.size = Vector2(basket_width, basket_height)
	basket_panel.z_index = 20
	basket_panel.color = Color(0.030, 0.060, 0.060, 0.58)
	basket_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	basket_frame_panel.position = Vector2.ZERO
	basket_frame_panel.size = Vector2(basket_width, basket_height)
	basket_frame_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	basket_frame_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			Color(0.055, 0.105, 0.105, 0.88),
			Color(0.82, 1.0, 0.86, 0.34),
			20,
			16,
			Color(0.0, 0.0, 0.0, 0.32)
		)
	)

	basket_title_label.position = Vector2(basket_padding, 16)
	basket_title_label.size = Vector2(basket_inner_width, 36)
	basket_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	basket_title_label.add_theme_font_size_override("font_size", 25)
	basket_title_label.z_index = 2

	basket_stats_label.position = Vector2(basket_padding, 56.0)
	basket_stats_label.size = Vector2(basket_inner_width, 34.0)
	basket_stats_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	basket_stats_label.add_theme_font_size_override("font_size", 14)
	basket_stats_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.92))

	basket_scroll.position = Vector2(basket_padding, basket_scroll_y)
	basket_scroll.size = Vector2(basket_inner_width, basket_height - basket_scroll_y - basket_footer_height)
	basket_scroll.mouse_filter = Control.MOUSE_FILTER_PASS

	basket_cards_grid.position = Vector2.ZERO
	basket_cards_grid.size = basket_scroll.size
	basket_cards_grid.columns = 2
	basket_cards_grid.add_theme_constant_override("h_separation", 10)
	basket_cards_grid.add_theme_constant_override("v_separation", 10)

	basket_contents_label.position = Vector2(basket_padding, basket_scroll_y)
	basket_contents_label.size = Vector2(basket_inner_width, basket_height - basket_scroll_y - basket_footer_height)
	basket_contents_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	basket_contents_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	basket_contents_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	basket_contents_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	basket_contents_label.add_theme_font_size_override("font_size", 20)
	basket_contents_label.z_index = 2

	basket_notice_label.position = Vector2(basket_padding, basket_height - 48.0)
	basket_notice_label.size = Vector2(max(basket_notice_width, 160.0), 36.0)
	basket_notice_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	basket_notice_label.add_theme_font_size_override("font_size", 14)
	basket_notice_label.clip_text = true

	basket_sell_all_button.position = Vector2(basket_width - basket_padding - 316.0, basket_height - 50.0)
	basket_sell_all_button.size = Vector2(150.0, 40.0)
	basket_sell_all_button.z_index = 20
	basket_sell_all_button.mouse_filter = Control.MOUSE_FILTER_STOP
	basket_sell_all_button.add_theme_font_size_override("font_size", 15)
	_apply_button_style(basket_sell_all_button, STYLE_PRIMARY_BUTTON)

	basket_close_button.position = Vector2(basket_width - basket_padding - 150.0, basket_height - 50.0)
	basket_close_button.size = Vector2(150.0, 40.0)
	basket_close_button.z_index = 20
	basket_close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	basket_close_button.add_theme_font_size_override("font_size", 15)
	_apply_button_style(basket_close_button, STYLE_SECONDARY_BUTTON)

	var inventory_width: float = min(screen_size.x - margin * 2.0, 860.0)
	var inventory_height: float = min(screen_size.y - margin * 2.0, 500.0)
	var inventory_x: float = (screen_size.x - inventory_width) * 0.5
	var inventory_y: float = (screen_size.y - inventory_height) * 0.5
	var inventory_padding := 18.0
	var category_gap := 6.0
	var category_columns := 4
	var category_button_width: float = (inventory_width - inventory_padding * 2.0 - category_gap * float(category_columns - 1)) / float(category_columns)
	var list_width: float = inventory_width * 0.42
	var right_panel_x: float = inventory_padding + list_width + 18.0
	var right_panel_width: float = inventory_width - right_panel_x - inventory_padding
	var inventory_body_y := 140.0
	var close_button_size := Vector2(160.0, 46.0)
	var inventory_action_y: float = inventory_height - inventory_padding - close_button_size.y
	var tackle_height := 86.0
	var tackle_y: float = inventory_action_y - tackle_height - 12.0
	var inventory_body_height: float = max(tackle_y - inventory_body_y - 14.0, 110.0)

	inventory_panel.position = Vector2(inventory_x, inventory_y)
	inventory_panel.size = Vector2(inventory_width, inventory_height)
	inventory_panel.z_index = 25
	inventory_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	inventory_panel.color = Color("#091016", 0.98)

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
		"Рыба",
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

	inventory_details_card.position = Vector2(right_panel_x, inventory_body_y)
	inventory_details_card.size = Vector2(right_panel_width, inventory_body_height)
	inventory_details_card.color = Color("#121c22")

	inventory_tackle_card.position = Vector2(inventory_padding, tackle_y)
	inventory_tackle_card.size = Vector2(inventory_width - inventory_padding * 2.0, tackle_height)
	inventory_tackle_card.color = Color("#121c22")

	inventory_item_list.position = Vector2(inventory_padding, inventory_body_y)
	inventory_item_list.size = Vector2(list_width, inventory_body_height)

	inventory_details_label.position = Vector2(right_panel_x + 12.0, inventory_body_y + 12.0)
	inventory_details_label.size = Vector2(right_panel_width - 24.0, max(inventory_body_height - 76.0, 48.0))
	inventory_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_details_label.add_theme_font_size_override("font_size", 14)
	inventory_details_label.clip_text = true

	inventory_tackle_label.position = Vector2(inventory_padding + 14.0, tackle_y + 10.0)
	inventory_tackle_label.size = Vector2(inventory_width - inventory_padding * 2.0 - 28.0, tackle_height - 20.0)
	inventory_tackle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_tackle_label.add_theme_font_size_override("font_size", 13)
	inventory_tackle_label.clip_text = true

	inventory_equip_button.position = Vector2(right_panel_x + right_panel_width - 182.0, inventory_body_y + inventory_body_height - 56.0)
	inventory_equip_button.size = Vector2(170.0, 42.0)

	inventory_close_button.position = Vector2(inventory_width - inventory_padding - close_button_size.x, inventory_action_y)
	inventory_close_button.size = close_button_size

	var tackle_width: float = min(screen_size.x - margin * 3.0, 820.0)
	var tackle_panel_height: float = min(screen_size.y - margin * 3.0, 462.0)
	var tackle_x: float = (screen_size.x - tackle_width) * 0.5
	var tackle_y_pos: float = (screen_size.y - tackle_panel_height) * 0.5
	var tackle_padding := 20.0
	var tackle_inner_width: float = tackle_width - tackle_padding * 2.0
	var tackle_current_height := 74.0
	var tackle_category_y := 110.0
	var tackle_depth_y := 152.0
	var tackle_list_y := 202.0
	var tackle_footer_height := 58.0
	var tackle_list_width: float = tackle_width * 0.38
	var tackle_details_x: float = tackle_padding + tackle_list_width + 18.0
	var tackle_details_width: float = tackle_width - tackle_details_x - tackle_padding
	var tackle_body_height: float = tackle_panel_height - tackle_list_y - tackle_footer_height
	var tackle_category_width: float = (tackle_inner_width - 8.0 * 4.0) / 5.0

	tackle_panel.position = Vector2(tackle_x, tackle_y_pos)
	tackle_panel.size = Vector2(tackle_width, tackle_panel_height)

	tackle_title_label.position = Vector2(tackle_padding, 14.0)
	tackle_title_label.size = Vector2(tackle_inner_width, 30.0)
	tackle_title_label.add_theme_font_size_override("font_size", 25)
	tackle_title_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))

	tackle_current_label.position = Vector2(tackle_padding, 52.0)
	tackle_current_label.size = Vector2(tackle_inner_width, tackle_current_height - 8.0)
	tackle_current_label.add_theme_font_size_override("font_size", 12)
	tackle_current_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.92))
	tackle_current_label.clip_text = true

	var tackle_category_buttons: Array = [tackle_rod_button, tackle_line_button, tackle_float_button, tackle_hook_button, tackle_bait_button]
	for i in tackle_category_buttons.size():
		var tackle_category_button: Button = tackle_category_buttons[i]
		tackle_category_button.position = Vector2(tackle_padding + float(i) * (tackle_category_width + 8.0), tackle_category_y)
		tackle_category_button.size = Vector2(tackle_category_width, 34.0)
		tackle_category_button.add_theme_font_size_override("font_size", 12)

	tackle_depth_label.position = Vector2(tackle_padding, tackle_depth_y)
	tackle_depth_label.size = Vector2(178.0, 36.0)
	tackle_depth_label.add_theme_font_size_override("font_size", 14)
	tackle_depth_label.add_theme_color_override("font_color", Color(0.86, 0.98, 0.86, 0.96))

	tackle_depth_minus_button.position = Vector2(tackle_padding + 188.0, tackle_depth_y + 1.0)
	tackle_depth_minus_button.size = Vector2(38.0, 34.0)
	tackle_depth_minus_button.add_theme_font_size_override("font_size", 18)
	_apply_button_style(tackle_depth_minus_button, STYLE_SECONDARY_BUTTON)

	tackle_depth_plus_button.position = Vector2(tackle_padding + 232.0, tackle_depth_y + 1.0)
	tackle_depth_plus_button.size = Vector2(38.0, 34.0)
	tackle_depth_plus_button.add_theme_font_size_override("font_size", 18)
	_apply_button_style(tackle_depth_plus_button, STYLE_SECONDARY_BUTTON)

	tackle_hint_label.position = Vector2(tackle_padding + 288.0, tackle_depth_y - 2.0)
	tackle_hint_label.size = Vector2(tackle_inner_width - 288.0, 42.0)
	tackle_hint_label.add_theme_font_size_override("font_size", 12)
	tackle_hint_label.add_theme_color_override("font_color", Color(0.78, 0.92, 0.82, 0.92))
	tackle_hint_label.clip_text = true

	tackle_item_list.position = Vector2(tackle_padding, tackle_list_y)
	tackle_item_list.size = Vector2(tackle_list_width, tackle_body_height)
	tackle_item_list.add_theme_font_size_override("font_size", 13)
	tackle_item_list.add_theme_color_override("font_color", Color(0.84, 0.94, 0.86, 0.96))
	tackle_item_list.add_theme_color_override("font_selected_color", Color(0.98, 1.0, 0.94, 1.0))

	tackle_details_label.position = Vector2(tackle_details_x, tackle_list_y)
	tackle_details_label.size = Vector2(tackle_details_width, max(tackle_body_height * 0.54, 120.0))
	tackle_details_label.add_theme_font_size_override("font_size", 13)
	tackle_details_label.clip_text = true

	tackle_compare_label.position = Vector2(tackle_details_x, tackle_list_y + tackle_details_label.size.y + 12.0)
	tackle_compare_label.size = Vector2(tackle_details_width, max(tackle_body_height - tackle_details_label.size.y - 12.0, 86.0))
	tackle_compare_label.add_theme_font_size_override("font_size", 12)
	tackle_compare_label.add_theme_color_override("font_color", Color(0.78, 0.90, 0.82, 0.94))
	tackle_compare_label.clip_text = true

	tackle_equip_button.position = Vector2(tackle_width - tackle_padding - 324.0, tackle_panel_height - 50.0)
	tackle_equip_button.size = Vector2(150.0, 40.0)
	tackle_equip_button.add_theme_font_size_override("font_size", 15)
	_apply_button_style(tackle_equip_button, STYLE_PRIMARY_BUTTON)

	tackle_close_button.position = Vector2(tackle_width - tackle_padding - 150.0, tackle_panel_height - 50.0)
	tackle_close_button.size = Vector2(150.0, 40.0)
	tackle_close_button.add_theme_font_size_override("font_size", 15)
	_apply_button_style(tackle_close_button, STYLE_SECONDARY_BUTTON)

	var waterbody_width: float = min(screen_size.x - margin * 4.0, 760.0)
	var waterbody_height: float = min(screen_size.y - margin * 3.0, 430.0)
	var waterbody_x: float = (screen_size.x - waterbody_width) * 0.5
	var waterbody_y: float = (screen_size.y - waterbody_height) * 0.5
	var waterbody_padding := 20.0
	var waterbody_inner_width: float = waterbody_width - waterbody_padding * 2.0
	var waterbody_body_y := 68.0
	var waterbody_footer_y := waterbody_height - 54.0
	var waterbody_list_width: float = waterbody_width * 0.35
	var waterbody_details_x: float = waterbody_padding + waterbody_list_width + 18.0
	var waterbody_details_width: float = waterbody_width - waterbody_details_x - waterbody_padding
	var waterbody_spot_list_width: float = waterbody_details_width * 0.46

	waterbody_panel.position = Vector2(waterbody_x, waterbody_y)
	waterbody_panel.size = Vector2(waterbody_width, waterbody_height)

	waterbody_title_label.position = Vector2(waterbody_padding, 14.0)
	waterbody_title_label.size = Vector2(waterbody_inner_width, 32.0)
	waterbody_title_label.add_theme_font_size_override("font_size", 25)
	waterbody_title_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))

	waterbody_item_list.position = Vector2(waterbody_padding, waterbody_body_y)
	waterbody_item_list.size = Vector2(waterbody_list_width, waterbody_footer_y - waterbody_body_y - 12.0)
	waterbody_item_list.add_theme_font_size_override("font_size", 14)
	waterbody_item_list.add_theme_color_override("font_color", Color(0.84, 0.94, 0.86, 0.96))
	waterbody_item_list.add_theme_color_override("font_selected_color", Color(0.98, 1.0, 0.94, 1.0))

	waterbody_preview.position = Vector2(waterbody_details_x, waterbody_body_y)
	waterbody_preview.size = Vector2(waterbody_details_width, 74.0)
	waterbody_preview.color = Color(0.12, 0.28, 0.25, 0.82)

	waterbody_details_label.position = Vector2(waterbody_details_x, waterbody_body_y + 84.0)
	waterbody_details_label.size = Vector2(waterbody_details_width, 72.0)
	waterbody_details_label.add_theme_font_size_override("font_size", 13)
	waterbody_details_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.94))
	waterbody_details_label.clip_text = true

	waterbody_spot_list.position = Vector2(waterbody_details_x, waterbody_body_y + 168.0)
	waterbody_spot_list.size = Vector2(waterbody_spot_list_width, waterbody_footer_y - waterbody_body_y - 180.0)
	waterbody_spot_list.add_theme_font_size_override("font_size", 13)
	waterbody_spot_list.add_theme_color_override("font_color", Color(0.84, 0.94, 0.86, 0.96))
	waterbody_spot_list.add_theme_color_override("font_selected_color", Color(0.98, 1.0, 0.94, 1.0))

	waterbody_spot_details_label.position = Vector2(waterbody_details_x + waterbody_spot_list_width + 14.0, waterbody_body_y + 168.0)
	waterbody_spot_details_label.size = Vector2(waterbody_details_width - waterbody_spot_list_width - 14.0, waterbody_footer_y - waterbody_body_y - 180.0)
	waterbody_spot_details_label.add_theme_font_size_override("font_size", 12)
	waterbody_spot_details_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.94))
	waterbody_spot_details_label.clip_text = true

	waterbody_select_button.position = Vector2(waterbody_width - waterbody_padding - 324.0, waterbody_footer_y)
	waterbody_select_button.size = Vector2(150.0, 40.0)
	waterbody_select_button.add_theme_font_size_override("font_size", 15)
	_apply_button_style(waterbody_select_button, STYLE_PRIMARY_BUTTON)

	waterbody_close_button.position = Vector2(waterbody_width - waterbody_padding - 150.0, waterbody_footer_y)
	waterbody_close_button.size = Vector2(150.0, 40.0)
	waterbody_close_button.add_theme_font_size_override("font_size", 15)
	_apply_button_style(waterbody_close_button, STYLE_SECONDARY_BUTTON)

	var shop_width: float = min(screen_size.x - margin * 4.0, 780.0)
	var shop_height: float = min(screen_size.y - margin * 3.0, 462.0)
	var shop_x: float = (screen_size.x - shop_width) * 0.5
	var shop_y: float = (screen_size.y - shop_height) * 0.5
	var shop_padding := 20.0
	var shop_inner_width: float = shop_width - shop_padding * 2.0
	var shop_category_y := 56.0
	var shop_category_width := 142.0
	var shop_items_y := 104.0
	var shop_footer_height := 58.0

	shop_panel.position = Vector2(shop_x, shop_y)
	shop_panel.size = Vector2(shop_width, shop_height)

	shop_title_label.position = Vector2(shop_padding, 14.0)
	shop_title_label.size = Vector2(shop_inner_width, 30.0)
	shop_title_label.add_theme_font_size_override("font_size", 25)
	shop_title_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))

	shop_money_label.position = Vector2(shop_width - shop_padding - 160.0, 20.0)
	shop_money_label.size = Vector2(160.0, 22.0)
	shop_money_label.add_theme_font_size_override("font_size", 14)
	shop_money_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.92))

	shop_bait_category_button.position = Vector2(shop_padding, shop_category_y)
	shop_bait_category_button.size = Vector2(shop_category_width, 34.0)
	shop_bait_category_button.add_theme_font_size_override("font_size", 13)

	shop_consumable_category_button.position = Vector2(shop_padding + shop_category_width + 8.0, shop_category_y)
	shop_consumable_category_button.size = Vector2(shop_category_width, 34.0)
	shop_consumable_category_button.add_theme_font_size_override("font_size", 13)

	shop_tackle_category_button.position = Vector2(shop_padding + (shop_category_width + 8.0) * 2.0, shop_category_y)
	shop_tackle_category_button.size = Vector2(shop_category_width, 34.0)
	shop_tackle_category_button.add_theme_font_size_override("font_size", 13)

	shop_items_container.position = Vector2(shop_padding, shop_items_y)
	shop_items_container.size = Vector2(shop_inner_width, shop_height - shop_items_y - shop_footer_height)

	shop_notice_label.position = Vector2(shop_padding, shop_height - 46.0)
	shop_notice_label.size = Vector2(shop_inner_width - 166.0, 34.0)
	shop_notice_label.add_theme_font_size_override("font_size", 14)
	shop_notice_label.clip_text = true

	shop_close_button.position = Vector2(shop_width - shop_padding - 150.0, shop_height - 50.0)
	shop_close_button.size = Vector2(150.0, 40.0)
	shop_close_button.add_theme_font_size_override("font_size", 15)
	_apply_button_style(shop_close_button, STYLE_SECONDARY_BUTTON)

	_update_shop_ui()

	if toast_label != null:
		toast_label.position = Vector2((screen_size.x - 360.0) * 0.5, screen_size.y - 116.0)
		toast_label.size = Vector2(360.0, 40.0)
		toast_label.z_index = 45
		toast_label.add_theme_font_size_override("font_size", 15)
		toast_label.add_theme_color_override("font_color", Color(0.90, 1.0, 0.90, 1.0))
		toast_label.add_theme_stylebox_override(
			"normal",
			_make_panel_style(Color(0.055, 0.135, 0.105, 0.92), Color(0.68, 1.0, 0.76, 0.36), 18, 10, Color(0.0, 0.0, 0.0, 0.24))
		)

	var reward_width: float = min(screen_size.x - margin * 6.0, 720.0)
	var reward_height: float = min(screen_size.y - margin * 4.0, 486.0)
	var reward_x: float = (screen_size.x - reward_width) * 0.5
	var reward_y: float = (screen_size.y - reward_height) * 0.5
	var reward_padding := 24.0
	var reward_inner_width: float = reward_width - reward_padding * 2.0
	var reward_button_gap := 14.0
	var reward_button_width: float = min(max(reward_inner_width * 0.21, 126.0), 154.0)
	var reward_button_height := 38.0
	var reward_buttons_width: float = reward_button_width * 2.0 + reward_button_gap
	var reward_button_x: float = reward_width - reward_padding - reward_buttons_width
	var reward_button_y: float = reward_height - 18.0 - reward_button_height

	catch_popup_panel.position = Vector2(reward_x, reward_y)
	catch_popup_panel.size = Vector2(reward_width, reward_height)
	catch_popup_panel.pivot_offset = catch_popup_panel.size * 0.5

	catch_popup_particles.position = Vector2.ZERO
	catch_popup_particles.size = Vector2(reward_width, reward_height)
	catch_popup_particles.z_index = 0
	catch_popup_particles.mouse_filter = Control.MOUSE_FILTER_IGNORE

	catch_popup_glow.position = Vector2((reward_width - 520.0) * 0.5, 92.0)
	catch_popup_glow.size = Vector2(520.0, 264.0)
	catch_popup_glow.z_index = 0
	catch_popup_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	catch_popup_title_label.position = Vector2(reward_padding, 18.0)
	catch_popup_title_label.size = Vector2(reward_inner_width, 24.0)
	catch_popup_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_popup_title_label.add_theme_font_size_override("font_size", 16)
	catch_popup_title_label.add_theme_color_override("font_color", Color(0.78, 0.94, 0.86, 0.92))

	catch_popup_badge_label.position = Vector2((reward_width - 164.0) * 0.5, 48.0)
	catch_popup_badge_label.size = Vector2(164.0, 28.0)
	catch_popup_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_popup_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	catch_popup_badge_label.add_theme_font_size_override("font_size", 13)

	catch_popup_name_label.position = Vector2(reward_padding, 76.0)
	catch_popup_name_label.size = Vector2(reward_inner_width, 38.0)
	catch_popup_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_popup_name_label.add_theme_font_size_override("font_size", 28)
	catch_popup_name_label.add_theme_color_override("font_color", Color(0.98, 1.0, 0.94, 1.0))
	catch_popup_name_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.34))
	catch_popup_name_label.add_theme_constant_override("shadow_offset_x", 0)
	catch_popup_name_label.add_theme_constant_override("shadow_offset_y", 2)

	catch_trophy_banner_label.position = Vector2((reward_width - 220.0) * 0.5, 112.0)
	catch_trophy_banner_label.size = Vector2(220.0, 34.0)
	catch_trophy_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_trophy_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	catch_trophy_banner_label.add_theme_font_size_override("font_size", 18)
	catch_trophy_banner_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.56, 1.0))
	catch_trophy_banner_label.add_theme_stylebox_override(
		"normal",
		_make_panel_style(Color(0.34, 0.235, 0.08, 0.84), Color(1.0, 0.78, 0.38, 0.50), 15, 8, Color(0.86, 0.54, 0.16, 0.20))
	)

	var fish_visual_width: float = min(reward_inner_width, 560.0)
	var fish_visual_height := 224.0
	catch_fish_shadow.position = Vector2((reward_width - fish_visual_width) * 0.5 + 10.0, 132.0)
	catch_fish_shadow.size = Vector2(fish_visual_width, fish_visual_height)
	catch_fish_shadow.z_index = 1
	catch_fish_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_catch_shadow_base_position = catch_fish_shadow.position

	catch_fish_visual.position = Vector2((reward_width - fish_visual_width) * 0.5, 122.0)
	catch_fish_visual.size = Vector2(fish_visual_width, fish_visual_height)
	catch_fish_visual.z_index = 2
	catch_fish_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_catch_fish_base_position = catch_fish_visual.position

	catch_popup_stats_label.position = Vector2(reward_padding, 348.0)
	catch_popup_stats_label.size = Vector2(reward_inner_width, 58.0)
	catch_popup_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_popup_stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	catch_popup_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	catch_popup_stats_label.add_theme_font_size_override("font_size", 16)
	catch_popup_stats_label.add_theme_color_override("font_color", Color(0.88, 0.98, 0.91, 0.96))

	catch_keep_button.position = Vector2(reward_button_x, reward_button_y)
	catch_keep_button.size = Vector2(reward_button_width, reward_button_height)
	catch_keep_button.add_theme_font_size_override("font_size", 15)
	_apply_button_style(catch_keep_button, STYLE_PRIMARY_BUTTON)

	catch_release_button.position = Vector2(reward_button_x + reward_button_width + reward_button_gap, reward_button_y)
	catch_release_button.size = Vector2(reward_button_width, reward_button_height)
	catch_release_button.add_theme_font_size_override("font_size", 15)
	_apply_button_style(catch_release_button, STYLE_SECONDARY_BUTTON)

	_update_reeling_ui(_last_reeling_state)
	_update_basket_ui()
	if inventory_panel.visible:
		_update_inventory_ui()
	_update_inventory_ui()
	_update_fishing_presence(0.0)

func _setup_spots() -> void:
	spot_option_button.clear()

	var selected_index := 0
	var spots := SpotDatabase.get_spots_for_waterbody(PlayerData.current_waterbody)

	if spots.is_empty():
		PlayerData.current_waterbody = "agamin_lake"
		spots = SpotDatabase.get_spots_for_waterbody(PlayerData.current_waterbody)

	for spot in spots:
		spot_option_button.add_item(spot["name"])
		var index := spot_option_button.item_count - 1
		spot_option_button.set_item_metadata(index, spot["id"])

		if spot["id"] == PlayerData.current_spot:
			selected_index = index

	spot_option_button.select(selected_index)
	PlayerData.set_current_spot(str(spot_option_button.get_item_metadata(selected_index)))

func _connect_signals() -> void:
	spot_option_button.item_selected.connect(_on_spot_selected)
	fish_button.pressed.connect(_on_fish_button_pressed)
	fish_button.button_down.connect(_on_reel_button_down)
	fish_button.button_up.connect(_on_reel_button_up)
	nav_fish_button.pressed.connect(_on_nav_fish_button_pressed)
	basket_button.pressed.connect(_on_basket_button_pressed)
	basket_sell_all_button.pressed.connect(_on_sell_all_button_pressed)
	basket_close_button.pressed.connect(_on_basket_close_button_pressed)
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	tackle_button.pressed.connect(_on_tackle_button_pressed)
	shop_button.pressed.connect(_on_shop_button_pressed)
	map_button.pressed.connect(_on_map_button_pressed)
	bait_button.pressed.connect(_on_bait_button_pressed)
	inventory_close_button.pressed.connect(_on_inventory_close_button_pressed)
	inventory_equip_button.pressed.connect(_on_inventory_equip_button_pressed)
	inventory_item_list.item_selected.connect(_on_inventory_item_selected)
	shop_close_button.pressed.connect(_on_shop_close_button_pressed)
	shop_bait_category_button.pressed.connect(_set_shop_category.bind(SHOP_CATEGORY_BAIT))
	shop_consumable_category_button.pressed.connect(_set_shop_category.bind(SHOP_CATEGORY_CONSUMABLE))
	shop_tackle_category_button.pressed.connect(_set_shop_category.bind(SHOP_CATEGORY_TACKLE))
	tackle_rod_button.pressed.connect(_set_tackle_category.bind("rod"))
	tackle_line_button.pressed.connect(_set_tackle_category.bind("line"))
	tackle_float_button.pressed.connect(_set_tackle_category.bind("float"))
	tackle_hook_button.pressed.connect(_set_tackle_category.bind("hook"))
	tackle_bait_button.pressed.connect(_set_tackle_category.bind("bait"))
	tackle_item_list.item_selected.connect(_on_tackle_item_selected)
	tackle_item_list.item_activated.connect(_on_tackle_item_activated)
	tackle_depth_minus_button.pressed.connect(_on_tackle_depth_button_pressed.bind(-0.1))
	tackle_depth_plus_button.pressed.connect(_on_tackle_depth_button_pressed.bind(0.1))
	tackle_equip_button.pressed.connect(_on_tackle_equip_button_pressed)
	tackle_close_button.pressed.connect(_on_tackle_close_button_pressed)
	waterbody_item_list.item_selected.connect(_on_waterbody_item_selected)
	waterbody_spot_list.item_selected.connect(_on_waterbody_spot_item_selected)
	waterbody_select_button.pressed.connect(_on_waterbody_select_button_pressed)
	waterbody_close_button.pressed.connect(_on_waterbody_close_button_pressed)
	catch_keep_button.pressed.connect(_on_catch_keep_button_pressed)
	catch_release_button.pressed.connect(_on_catch_release_button_pressed)
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
	_update_time_hud()
	money_label.text = "%d мон." % PlayerData.money
	tackle_label.text = _get_main_hud_text()
	level_label.text = "LVL %d  XP %d/%d" % [
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
	tackle_button.disabled = inventory_button.disabled
	shop_button.disabled = inventory_button.disabled
	map_button.disabled = inventory_button.disabled
	bait_button.disabled = inventory_button.disabled
	reeling_panel.visible = _fishing_ui_state == FishingUiState.FIGHTING
	debug_panel.visible = SHOW_DEBUG_PANEL

	if _is_catch_reward_open():
		_close_secondary_popups_for_reward()
		_bring_catch_reward_to_front()

	if inventory_button.disabled:
		basket_panel.visible = false
		basket_backdrop.visible = false
		inventory_panel.visible = false
		inventory_backdrop.visible = false
		tackle_panel.visible = false
		tackle_backdrop.visible = false
		waterbody_panel.visible = false
		waterbody_backdrop.visible = false
		shop_panel.visible = false
		shop_backdrop.visible = false
		_active_nav_tab = "fish"

	match _fishing_ui_state:
		FishingUiState.WAITING:
			fish_button.text = "Ожидание"
		FishingUiState.FIGHTING:
			fish_button.text = "Тянуть"
		FishingUiState.CAUGHT, FishingUiState.FAILED:
			fish_button.text = "Вытянуть"
		_:
			fish_button.text = "Забросить"

	_update_basket_ui()
	_refresh_bottom_nav_styles()
	if inventory_panel.visible:
		_update_inventory_ui()
	if shop_panel.visible:
		_update_shop_ui()
	if tackle_panel.visible:
		_update_tackle_ui()
	if waterbody_panel.visible:
		_update_waterbody_ui()

func _on_global_time_changed(_time_state: Dictionary) -> void:
	_update_time_hud()

func _on_global_period_changed(_time_of_day: String) -> void:
	_apply_time_atmosphere()

func _update_time_hud() -> void:
	if clock_label == null or weather_label == null:
		return

	clock_label.text = _get_clock_text()
	weather_label.text = _get_time_of_day_title()

func _apply_time_atmosphere() -> void:
	var settings := _get_atmosphere_settings()

	if settings.is_empty():
		return

	background.color = settings.get("background", background.color)
	scene_gradient.modulate = settings.get("scene", Color.WHITE)
	sun_glow_layer.modulate = settings.get("sun", Color.WHITE)
	lake_layer.modulate = settings.get("water", Color.WHITE)
	reflection_layer.modulate = settings.get("water", Color.WHITE)
	mist_layer.modulate = settings.get("mist", Color.WHITE)
	foreground_mist_layer.modulate = settings.get("mist", Color.WHITE)
	far_forest_layer.modulate = settings.get("scene", Color.WHITE)
	mid_forest_layer.modulate = settings.get("scene", Color.WHITE)
	vignette_layer.modulate = settings.get("vignette", Color.WHITE)

func _get_time_manager() -> Node:
	return get_node_or_null("/root/TimeManager")

func _get_waterbody_database() -> Node:
	return get_node_or_null("/root/WaterbodyDatabase")

func _get_clock_text() -> String:
	var time_manager := _get_time_manager()

	if time_manager != null and time_manager.has_method("get_clock_text"):
		return str(time_manager.call("get_clock_text"))

	return "07:40"

func _get_time_of_day_title() -> String:
	var time_manager := _get_time_manager()

	if time_manager != null and time_manager.has_method("get_time_of_day_title"):
		return str(time_manager.call("get_time_of_day_title"))

	return "Утро"

func _get_atmosphere_settings() -> Dictionary:
	var time_manager := _get_time_manager()

	if time_manager != null and time_manager.has_method("get_atmosphere_settings"):
		var raw_settings = time_manager.call("get_atmosphere_settings")
		if typeof(raw_settings) == TYPE_DICTIONARY:
			return raw_settings

	return {
		"background": Color("#153d3f"),
		"scene": Color(1.10, 1.03, 0.90, 1.0),
		"sun": Color(1.16, 0.92, 0.58, 0.88),
		"water": Color(0.90, 1.02, 0.96, 1.0),
		"mist": Color(1.03, 0.98, 0.86, 0.82),
		"vignette": Color(0.95, 0.92, 0.80, 0.78)
	}

func _get_waterbody(waterbody_id: String) -> Dictionary:
	var waterbody_db := _get_waterbody_database()

	if waterbody_db != null and waterbody_db.has_method("get_waterbody"):
		var raw_waterbody = waterbody_db.call("get_waterbody", waterbody_id)
		if typeof(raw_waterbody) == TYPE_DICTIONARY:
			return raw_waterbody

	if waterbody_id == "agamin_lake":
		return {"id": "agamin_lake", "name": "Озеро Агамим", "required_level": 1}

	return {}

func _get_all_waterbodies() -> Array:
	var waterbody_db := _get_waterbody_database()

	if waterbody_db != null and waterbody_db.has_method("get_all_waterbodies"):
		var raw_waterbodies = waterbody_db.call("get_all_waterbodies")
		if typeof(raw_waterbodies) == TYPE_ARRAY:
			return raw_waterbodies

	return [{"id": "agamin_lake", "name": "Озеро Агамим", "required_level": 1}]

func _get_waterbody_fish_names(waterbody_id: String, limit: int) -> String:
	var waterbody_db := _get_waterbody_database()

	if waterbody_db != null and waterbody_db.has_method("get_fish_names"):
		return str(waterbody_db.call("get_fish_names", waterbody_id, limit))

	return "Уклейка, плотва, карась"

func _get_primary_waterbody_spot(waterbody_id: String) -> String:
	var waterbody_db := _get_waterbody_database()

	if waterbody_db != null and waterbody_db.has_method("get_primary_spot"):
		return str(waterbody_db.call("get_primary_spot", waterbody_id))

	return "old_oak_pier"

func _update_basket_ui() -> void:
	var fish_count: int = InventoryManager.inventory.size()
	basket_button.text = "△ %d" % fish_count
	var summary := _get_keepnet_summary()
	basket_stats_label.text = "%d рыб  |  %.2f кг  |  %d мон." % [
		fish_count,
		float(summary.get("weight", 0.0)),
		int(summary.get("price", 0))
	]
	basket_contents_label.text = "Садок пуст.\nПоймай первую рыбу."
	basket_contents_label.visible = fish_count == 0
	basket_scroll.visible = fish_count > 0
	basket_sell_all_button.disabled = fish_count == 0 or _fishing_ui_state == FishingUiState.WAITING or _fishing_ui_state == FishingUiState.FIGHTING

	if basket_panel.visible:
		_rebuild_keepnet_cards()

func _get_keepnet_summary() -> Dictionary:
	var total_weight := 0.0
	var total_price := 0

	for fish in InventoryManager.inventory:
		if typeof(fish) != TYPE_DICTIONARY:
			continue

		total_weight += float(fish.get("weight", 0.0))
		total_price += int(fish.get("price", 0))

	return {
		"weight": total_weight,
		"price": total_price
	}

func _rebuild_keepnet_cards() -> void:
	for child in basket_cards_grid.get_children():
		child.queue_free()

	var fish_count: int = InventoryManager.inventory.size()
	if fish_count == 0:
		return

	var columns := 2
	var gap := 10.0
	var card_width: float = (basket_scroll.size.x - gap * float(columns - 1)) / float(columns)
	var card_height := 104.0
	basket_cards_grid.columns = columns

	for i in fish_count:
		var fish: Dictionary = InventoryManager.inventory[i]
		var card := _create_keepnet_card(fish, i, Vector2(card_width, card_height))
		basket_cards_grid.add_child(card)

func _create_keepnet_card(fish: Dictionary, fish_index: int, card_size: Vector2) -> Panel:
	var tier := _get_reward_tier(fish)
	var accent := _get_keepnet_tier_color(tier)
	var card := Panel.new()
	card.custom_minimum_size = card_size
	card.size = card_size
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.clip_contents = true
	card.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			Color(0.070, 0.135, 0.125, 0.76),
			Color(accent.r, accent.g, accent.b, 0.34),
			14,
			8,
			Color(0.0, 0.0, 0.0, 0.18)
		)
	)

	var fish_slot := Panel.new()
	fish_slot.position = Vector2(10.0, 18.0)
	fish_slot.size = Vector2(132.0, 60.0)
	fish_slot.clip_contents = true
	fish_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fish_slot.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color(0.035, 0.080, 0.076, 0.34), Color(accent.r, accent.g, accent.b, 0.12), 10, 2, Color(0.0, 0.0, 0.0, 0.08))
	)
	card.add_child(fish_slot)

	var fish_texture := _get_reward_fish_texture(str(fish.get("id", "")))
	if fish_texture != null:
		var fish_sprite := Sprite2D.new()
		fish_sprite.texture = fish_texture
		fish_sprite.centered = true
		fish_sprite.position = fish_slot.size * 0.5
		var texture_size := fish_texture.get_size()
		var fit_scale: float = min(
			(fish_slot.size.x - 12.0) / max(texture_size.x, 1.0),
			(fish_slot.size.y - 10.0) / max(texture_size.y, 1.0)
		)
		fish_sprite.scale = Vector2.ONE * fit_scale
		fish_slot.add_child(fish_sprite)
	else:
		var fallback_label := Label.new()
		fallback_label.text = "><>"
		fallback_label.position = Vector2.ZERO
		fallback_label.size = fish_slot.size
		fallback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		fallback_label.add_theme_font_size_override("font_size", 24)
		fallback_label.add_theme_color_override("font_color", Color(accent.r, accent.g, accent.b, 0.84))
		fish_slot.add_child(fallback_label)

	var name_label := Label.new()
	name_label.text = str(fish.get("name", "-"))
	name_label.position = Vector2(154.0, 10.0)
	name_label.size = Vector2(card_size.x - 164.0, 22.0)
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.91, 1.0))
	card.add_child(name_label)

	var badge_label := Label.new()
	badge_label.text = _get_keepnet_tier_label(tier)
	badge_label.position = Vector2(154.0, 34.0)
	badge_label.size = Vector2(112.0, 22.0)
	badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge_label.add_theme_font_size_override("font_size", 12)
	badge_label.add_theme_color_override("font_color", Color(accent.r, accent.g, accent.b, 1.0))
	badge_label.add_theme_stylebox_override(
		"normal",
		_make_panel_style(Color(accent.r * 0.16, accent.g * 0.20, accent.b * 0.18, 0.62), Color(accent.r, accent.g, accent.b, 0.36), 11, 4, Color(0.0, 0.0, 0.0, 0.10))
	)
	card.add_child(badge_label)

	var weight := float(fish.get("weight", 0.0))
	var length_cm := _get_catch_length_cm(fish)
	var price := int(fish.get("price", 0))
	var stats_label := Label.new()
	stats_label.text = "%.2f кг  |  %.1f см\n%d мон." % [weight, length_cm, price]
	stats_label.position = Vector2(154.0, 61.0)
	stats_label.size = Vector2(card_size.x - 262.0, 36.0)
	stats_label.add_theme_font_size_override("font_size", 13)
	stats_label.add_theme_color_override("font_color", Color(0.76, 0.88, 0.80, 0.92))
	card.add_child(stats_label)

	var sell_button := Button.new()
	sell_button.text = "Продать"
	sell_button.position = Vector2(card_size.x - 94.0, card_size.y - 38.0)
	sell_button.size = Vector2(82.0, 30.0)
	sell_button.z_index = 5
	sell_button.mouse_filter = Control.MOUSE_FILTER_STOP
	sell_button.add_theme_font_size_override("font_size", 12)
	_apply_button_style(sell_button, STYLE_SECONDARY_BUTTON)
	sell_button.pressed.connect(_on_keepnet_sell_fish_pressed.bind(fish_index))
	card.add_child(sell_button)

	return card

func _get_keepnet_tier_color(tier: String) -> Color:
	match tier:
		"trophy":
			return Color(1.0, 0.80, 0.38, 1.0)
		"rare":
			return Color(0.54, 0.86, 1.0, 1.0)
		"uncommon":
			return Color(0.58, 1.0, 0.64, 1.0)
		_:
			return Color(0.72, 0.86, 0.76, 1.0)

func _get_keepnet_tier_label(tier: String) -> String:
	match tier:
		"trophy":
			return "Трофей"
		"rare":
			return "Редкая"
		"uncommon":
			return "Необычная"
		_:
			return "Обычная"

func _show_basket_notice(message: String, success: bool = true) -> void:
	if basket_notice_label == null:
		return

	basket_notice_label.text = message
	basket_notice_label.modulate = Color(0.78, 1.0, 0.78, 1.0) if success else Color(1.0, 0.64, 0.54, 1.0)

func _is_catch_reward_open() -> bool:
	return catch_popup_panel != null and catch_popup_panel.visible

func _bring_catch_reward_to_front() -> void:
	if catch_popup_backdrop != null and catch_popup_backdrop.get_parent() == self:
		move_child(catch_popup_backdrop, get_child_count() - 1)
	if catch_popup_panel != null and catch_popup_panel.get_parent() == self:
		move_child(catch_popup_panel, get_child_count() - 1)

func _close_secondary_popups_for_reward() -> void:
	if basket_panel != null:
		basket_panel.visible = false
	if basket_backdrop != null:
		basket_backdrop.visible = false
	if inventory_panel != null:
		inventory_panel.visible = false
	if inventory_backdrop != null:
		inventory_backdrop.visible = false
	if shop_panel != null:
		shop_panel.visible = false
	if shop_backdrop != null:
		shop_backdrop.visible = false
	if tackle_panel != null:
		tackle_panel.visible = false
	if tackle_backdrop != null:
		tackle_backdrop.visible = false
	if waterbody_panel != null:
		waterbody_panel.visible = false
	if waterbody_backdrop != null:
		waterbody_backdrop.visible = false
	_active_nav_tab = "fish"

func _show_catch_reward_popup(catch_data: Dictionary) -> void:
	_pending_reward_catch = catch_data.duplicate(true)
	_close_secondary_popups_for_reward()
	_bring_catch_reward_to_front()
	_update_catch_reward_popup(catch_data)
	var tier := _get_reward_tier(catch_data)
	var feedback := _get_reward_feedback_tuning(tier)
	var fish_start_scale := float(feedback["fish_start_scale"])
	var fish_reveal_scale := float(feedback["fish_reveal_scale"])
	var fish_delay := float(feedback["fish_delay"])
	var fish_reveal_duration := float(feedback["fish_reveal_duration"])
	var panel_duration := float(feedback["panel_duration"])

	if is_instance_valid(_catch_popup_tween):
		_catch_popup_tween.kill()
	if is_instance_valid(_catch_fish_tween):
		_catch_fish_tween.kill()

	catch_popup_backdrop.visible = true
	catch_popup_panel.visible = true
	catch_popup_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	catch_popup_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	catch_popup_backdrop.z_index = 40
	catch_popup_panel.z_index = 41
	catch_popup_backdrop.modulate = Color(1.0, 1.0, 1.0, 0.0)
	catch_popup_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	catch_popup_panel.scale = Vector2(0.92, 0.92)
	catch_fish_visual.position = _catch_fish_base_position
	catch_fish_shadow.position = _catch_shadow_base_position
	catch_fish_visual.pivot_offset = catch_fish_visual.size * 0.5
	catch_fish_shadow.pivot_offset = catch_fish_shadow.size * 0.5
	catch_fish_visual.scale = Vector2(fish_start_scale, fish_start_scale)
	catch_fish_shadow.scale = Vector2(fish_start_scale * 1.02, fish_start_scale * 1.02)
	catch_fish_visual.rotation = -0.018
	catch_fish_shadow.rotation = -0.018
	catch_fish_visual.modulate = Color(1.0, 1.0, 1.0, 0.0)
	catch_fish_shadow.modulate = Color(0.0, 0.0, 0.0, 0.0)
	catch_popup_particles.modulate = Color(1.0, 1.0, 1.0, 0.0)
	catch_popup_glow.modulate = Color(1.0, 1.0, 1.0, 0.0)
	catch_popup_title_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	catch_popup_badge_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	catch_popup_name_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	catch_trophy_banner_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	catch_popup_stats_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	catch_keep_button.modulate = Color(1.0, 1.0, 1.0, 0.0)
	catch_release_button.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_lock_catch_reward_buttons()
	_catch_reward_unlock_after_msec = Time.get_ticks_msec() + 1200

	_play_catch_reward_sound(tier)

	_catch_popup_tween = create_tween()
	_catch_popup_tween.tween_property(catch_popup_backdrop, "modulate:a", 1.0, 0.20)
	_catch_popup_tween.parallel().tween_property(catch_popup_panel, "modulate:a", 1.0, panel_duration)
	_catch_popup_tween.parallel().tween_property(catch_popup_panel, "scale", Vector2.ONE, panel_duration + 0.06).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_catch_popup_tween.parallel().tween_property(catch_popup_glow, "modulate:a", 1.0, 0.28).set_delay(0.06)
	_catch_popup_tween.parallel().tween_property(catch_popup_particles, "modulate:a", 1.0, 0.36).set_delay(0.10)
	_catch_popup_tween.parallel().tween_property(catch_popup_title_label, "modulate:a", 1.0, 0.16).set_delay(0.08)
	_catch_popup_tween.parallel().tween_property(catch_popup_badge_label, "modulate:a", 1.0, 0.18).set_delay(0.13)
	_catch_popup_tween.parallel().tween_property(catch_popup_name_label, "modulate:a", 1.0, 0.22).set_delay(0.17)
	if catch_trophy_banner_label.visible:
		_catch_popup_tween.parallel().tween_property(catch_trophy_banner_label, "modulate:a", 1.0, 0.24).set_delay(0.22)
	_catch_popup_tween.parallel().tween_property(catch_fish_visual, "modulate:a", 1.0, 0.18).set_delay(fish_delay)
	_catch_popup_tween.parallel().tween_property(catch_fish_shadow, "modulate:a", float(feedback["shadow_alpha"]), 0.20).set_delay(fish_delay)
	_catch_popup_tween.parallel().tween_property(catch_fish_visual, "scale", Vector2(fish_reveal_scale, fish_reveal_scale), fish_reveal_duration).set_delay(fish_delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_catch_popup_tween.parallel().tween_property(catch_fish_shadow, "scale", Vector2(fish_reveal_scale, fish_reveal_scale), fish_reveal_duration).set_delay(fish_delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_catch_popup_tween.parallel().tween_property(catch_fish_visual, "rotation", 0.0, fish_reveal_duration).set_delay(fish_delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_catch_popup_tween.parallel().tween_property(catch_fish_shadow, "rotation", 0.0, fish_reveal_duration).set_delay(fish_delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_catch_popup_tween.parallel().tween_property(catch_popup_stats_label, "modulate:a", 1.0, 0.22).set_delay(fish_delay + 0.18)
	_catch_popup_tween.parallel().tween_property(catch_keep_button, "modulate:a", 1.0, 0.20).set_delay(fish_delay + 0.27)
	_catch_popup_tween.parallel().tween_property(catch_release_button, "modulate:a", 1.0, 0.20).set_delay(fish_delay + 0.30)
	_catch_popup_tween.tween_callback(Callable(self, "_start_catch_fish_idle_motion").bind(feedback))

func _lock_catch_reward_buttons() -> void:
	_catch_reward_buttons_ready = false
	catch_keep_button.disabled = true
	catch_release_button.disabled = true
	catch_keep_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	catch_release_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _update_catch_reward_input_lock() -> void:
	if not _is_catch_reward_open() or _catch_reward_buttons_ready:
		return
	if Time.get_ticks_msec() < _catch_reward_unlock_after_msec:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return

	_unlock_catch_reward_buttons()

func _unlock_catch_reward_buttons() -> void:
	if not _is_catch_reward_open():
		return

	_catch_reward_buttons_ready = true
	catch_keep_button.disabled = false
	catch_release_button.disabled = false
	catch_keep_button.mouse_filter = Control.MOUSE_FILTER_STOP
	catch_release_button.mouse_filter = Control.MOUSE_FILTER_STOP

func _start_catch_fish_idle_motion(feedback: Dictionary) -> void:
	var fish_base_y := _catch_fish_base_position.y
	var shadow_base_y := _catch_shadow_base_position.y
	var float_y := float(feedback["float_y"])
	var float_duration := float(feedback["float_duration"])
	var breath_scale := float(feedback["breath_scale"])

	if is_instance_valid(_catch_fish_tween):
		_catch_fish_tween.kill()

	_catch_fish_tween = create_tween().set_loops()
	_catch_fish_tween.tween_property(catch_fish_visual, "position:y", fish_base_y - float_y, float_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_catch_fish_tween.parallel().tween_property(catch_fish_shadow, "position:y", shadow_base_y + float_y * 0.45, float_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_catch_fish_tween.parallel().tween_property(catch_fish_visual, "scale", Vector2(1.0 + breath_scale, 1.0 + breath_scale), float_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_catch_fish_tween.parallel().tween_property(catch_fish_shadow, "scale", Vector2(1.0 + breath_scale * 0.55, 1.0 + breath_scale * 0.55), float_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_catch_fish_tween.tween_property(catch_fish_visual, "position:y", fish_base_y + float_y, float_duration * 1.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_catch_fish_tween.parallel().tween_property(catch_fish_shadow, "position:y", shadow_base_y - float_y * 0.25, float_duration * 1.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_catch_fish_tween.parallel().tween_property(catch_fish_visual, "scale", Vector2(1.0 - breath_scale * 0.35, 1.0 - breath_scale * 0.35), float_duration * 1.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_catch_fish_tween.parallel().tween_property(catch_fish_shadow, "scale", Vector2(1.0 - breath_scale * 0.20, 1.0 - breath_scale * 0.20), float_duration * 1.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _update_catch_reward_popup(catch_data: Dictionary) -> void:
	var tier := _get_reward_tier(catch_data)
	var colors := _get_reward_colors(tier)
	var feedback := _get_reward_feedback_tuning(tier)
	var xp_result: Dictionary = catch_data.get("xp_result", {})
	var gained_xp := int(xp_result.get("gained_xp", 0))
	var weight := float(catch_data.get("weight", 0.0))
	var length_cm := _get_catch_length_cm(catch_data)
	var price := int(catch_data.get("price", 0))
	_set_reward_fish_texture(str(catch_data.get("id", "")))

	catch_popup_title_label.text = "Поймана рыба"
	catch_popup_badge_label.text = str(colors["label"])
	catch_popup_name_label.text = str(catch_data.get("name", "-"))
	catch_trophy_banner_label.visible = tier == "trophy"
	catch_trophy_banner_label.text = "ТРОФЕЙНЫЙ УЛОВ"
	catch_popup_stats_label.text = "Вес: %.2f кг   Длина: %.1f см\nXP: +%d   Стоимость: %d мон." % [
		weight,
		length_cm,
		gained_xp,
		price
	]

	catch_popup_badge_label.add_theme_color_override("font_color", colors["text"])
	catch_popup_badge_label.add_theme_stylebox_override(
		"normal",
		_make_panel_style(colors["badge_bg"], colors["border"], 14, 6, colors["shadow"])
	)
	catch_popup_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(colors["panel_bg"], colors["border"], 22, 18, Color(0.0, 0.0, 0.0, 0.36))
	)

	var backdrop_material := catch_popup_backdrop.material as ShaderMaterial
	if backdrop_material:
		backdrop_material.set_shader_parameter("focus_strength", float(feedback["focus_strength"]))
		backdrop_material.set_shader_parameter("edge_strength", float(feedback["edge_strength"]))
		backdrop_material.set_shader_parameter("focus_color", colors["focus_color"])

	var glow_material := catch_popup_glow.material as ShaderMaterial
	if glow_material:
		glow_material.set_shader_parameter("glow_color", colors["glow"])
		glow_material.set_shader_parameter("glow_power", float(feedback["glow_power"]))
		glow_material.set_shader_parameter("pulse_speed", float(feedback["pulse_speed"]))

	var particle_material := catch_popup_particles.material as ShaderMaterial
	if particle_material:
		particle_material.set_shader_parameter("particle_color", colors["particle"])
		particle_material.set_shader_parameter("sparkle_power", float(colors["sparkle_power"]))
		particle_material.set_shader_parameter("drift_speed", float(feedback["particle_drift"]))
		particle_material.set_shader_parameter("particle_scale", float(feedback["particle_scale"]))

	var fish_material := catch_fish_visual.material as ShaderMaterial
	if fish_material:
		fish_material.set_shader_parameter("rim_color", colors["fish_rim"])
		fish_material.set_shader_parameter("shimmer_color", colors["fish_shimmer"])
		fish_material.set_shader_parameter("shimmer_strength", float(colors["shimmer_strength"]))
		fish_material.set_shader_parameter("shimmer_speed", float(feedback["shimmer_speed"]))

func _set_reward_fish_texture(fish_id: String) -> void:
	var texture := _get_reward_fish_texture(fish_id)
	catch_fish_visual.texture = texture
	catch_fish_shadow.texture = texture

func _get_reward_fish_texture(fish_id: String) -> Texture2D:
	if SMALL_FISH_ATLAS_REGIONS.has(fish_id):
		if _small_fish_atlas == null:
			_small_fish_atlas = load(SMALL_FISH_ATLAS_PATH) as Texture2D

			if _small_fish_atlas == null:
				var small_image := Image.load_from_file(SMALL_FISH_ATLAS_PATH)
				if small_image:
					_small_fish_atlas = ImageTexture.create_from_image(small_image)

		if _small_fish_atlas != null:
			var small_atlas_texture := AtlasTexture.new()
			small_atlas_texture.atlas = _small_fish_atlas
			small_atlas_texture.region = SMALL_FISH_ATLAS_REGIONS[fish_id]
			return small_atlas_texture

	if _fish_reward_atlas == null:
		_fish_reward_atlas = load(FISH_REWARD_ATLAS_PATH) as Texture2D

		if _fish_reward_atlas == null:
			var image := Image.load_from_file(FISH_REWARD_ATLAS_PATH)
			if image:
				_fish_reward_atlas = ImageTexture.create_from_image(image)

	if _fish_reward_atlas == null:
		return null

	var atlas_region: Rect2 = FISH_REWARD_ATLAS_REGIONS.get(fish_id, FISH_REWARD_ATLAS_REGIONS["roach"])
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = _fish_reward_atlas
	atlas_texture.region = atlas_region

	return atlas_texture

func _play_catch_reward_sound(tier: String) -> void:
	_play_audio_hook(catch_popup_open_audio)

	match tier:
		"trophy":
			_play_audio_hook(catch_trophy_audio)
		"rare":
			_play_audio_hook(catch_rare_audio)
		_:
			_play_audio_hook(catch_reward_audio)

func _play_audio_hook(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return

	player.stop()
	player.play()

func _hide_catch_reward_popup(animated: bool = true) -> void:
	_catch_reward_unlock_after_msec = 0
	_lock_catch_reward_buttons()

	if is_instance_valid(_catch_popup_tween):
		_catch_popup_tween.kill()
	if is_instance_valid(_catch_fish_tween):
		_catch_fish_tween.kill()

	if not animated:
		_set_catch_popup_hidden()
		return

	_catch_popup_tween = create_tween()
	_catch_popup_tween.tween_property(catch_popup_panel, "modulate:a", 0.0, 0.12)
	_catch_popup_tween.parallel().tween_property(catch_popup_backdrop, "modulate:a", 0.0, 0.12)
	_catch_popup_tween.tween_callback(Callable(self, "_set_catch_popup_hidden"))

func _set_catch_popup_hidden() -> void:
	catch_popup_backdrop.visible = false
	catch_popup_panel.visible = false
	catch_popup_panel.scale = Vector2.ONE
	catch_fish_visual.position = _catch_fish_base_position
	catch_fish_shadow.position = _catch_shadow_base_position
	catch_fish_visual.scale = Vector2.ONE
	catch_fish_shadow.scale = Vector2.ONE
	catch_fish_visual.rotation = 0.0
	catch_fish_shadow.rotation = 0.0
	catch_fish_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
	catch_fish_shadow.modulate = Color(0.0, 0.0, 0.0, 0.26)
	catch_popup_particles.modulate = Color(1.0, 1.0, 1.0, 1.0)
	catch_popup_glow.modulate = Color(1.0, 1.0, 1.0, 1.0)
	catch_popup_title_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	catch_popup_badge_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	catch_popup_name_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	catch_trophy_banner_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	catch_popup_stats_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	catch_keep_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	catch_release_button.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _get_reward_tier(catch_data: Dictionary) -> String:
	var rarity := str(catch_data.get("rarity", "common"))
	var fish := FishDatabase.get_fish(str(catch_data.get("id", "")))
	var weight_ratio := 0.0

	if not fish.is_empty():
		var min_weight := float(fish.get("min_weight", 0.0))
		var max_weight := float(fish.get("max_weight", min_weight + 1.0))
		weight_ratio = clamp((float(catch_data.get("weight", 0.0)) - min_weight) / max(max_weight - min_weight, 0.01), 0.0, 1.0)

	if rarity == "legendary" or weight_ratio >= 0.88:
		return "trophy"
	if rarity == "rare" or rarity == "very_rare" or weight_ratio >= 0.70:
		return "rare"
	if rarity == "uncommon" or weight_ratio >= 0.48:
		return "uncommon"

	return "common"

func _get_reward_colors(tier: String) -> Dictionary:
	match tier:
		"trophy":
			return {
				"label": "Трофейная",
				"text": Color(1.0, 0.90, 0.56, 1.0),
				"badge_bg": Color(0.34, 0.235, 0.08, 0.90),
				"panel_bg": Color(0.095, 0.095, 0.082, 0.91),
				"border": Color(1.0, 0.78, 0.38, 0.56),
				"shadow": Color(0.86, 0.54, 0.16, 0.22),
				"glow": Color(1.0, 0.72, 0.32, 1.0),
				"focus_color": Color(0.080, 0.060, 0.030, 1.0),
				"particle": Color(1.0, 0.88, 0.52, 1.0),
				"sparkle_power": 0.36,
				"fish_rim": Color(1.0, 0.88, 0.46, 1.0),
				"fish_shimmer": Color(1.0, 0.96, 0.66, 1.0),
				"shimmer_strength": 0.24
			}
		"rare":
			return {
				"label": "Редкая",
				"text": Color(0.74, 0.94, 1.0, 1.0),
				"badge_bg": Color(0.075, 0.220, 0.285, 0.90),
				"panel_bg": Color(0.055, 0.115, 0.135, 0.90),
				"border": Color(0.58, 0.90, 1.0, 0.46),
				"shadow": Color(0.18, 0.58, 0.78, 0.18),
				"glow": Color(0.34, 0.84, 1.0, 1.0),
				"focus_color": Color(0.020, 0.060, 0.080, 1.0),
				"particle": Color(0.58, 0.92, 1.0, 1.0),
				"sparkle_power": 0.28,
				"fish_rim": Color(0.62, 0.92, 1.0, 1.0),
				"fish_shimmer": Color(0.90, 0.98, 1.0, 1.0),
				"shimmer_strength": 0.20
			}
		"uncommon":
			return {
				"label": "Необычная",
				"text": Color(0.78, 1.0, 0.74, 1.0),
				"badge_bg": Color(0.075, 0.255, 0.150, 0.90),
				"panel_bg": Color(0.050, 0.125, 0.105, 0.90),
				"border": Color(0.58, 1.0, 0.64, 0.42),
				"shadow": Color(0.18, 0.72, 0.32, 0.16),
				"glow": Color(0.38, 0.98, 0.56, 1.0),
				"focus_color": Color(0.020, 0.070, 0.050, 1.0),
				"particle": Color(0.62, 1.0, 0.68, 1.0),
				"sparkle_power": 0.23,
				"fish_rim": Color(0.70, 1.0, 0.68, 1.0),
				"fish_shimmer": Color(0.90, 1.0, 0.76, 1.0),
				"shimmer_strength": 0.17
			}
		_:
			return {
				"label": "Обычная",
				"text": Color(0.84, 1.0, 0.82, 1.0),
				"badge_bg": Color(0.105, 0.245, 0.145, 0.88),
				"panel_bg": Color(0.060, 0.115, 0.120, 0.88),
				"border": Color(0.80, 1.0, 0.82, 0.34),
				"shadow": Color(0.22, 0.78, 0.34, 0.14),
				"glow": Color(0.38, 0.92, 0.50, 1.0),
				"focus_color": Color(0.015, 0.045, 0.044, 1.0),
				"particle": Color(0.74, 1.0, 0.74, 1.0),
				"sparkle_power": 0.15,
				"fish_rim": Color(0.80, 1.0, 0.76, 1.0),
				"fish_shimmer": Color(0.96, 0.86, 0.44, 1.0),
				"shimmer_strength": 0.12
			}

func _get_reward_feedback_tuning(tier: String) -> Dictionary:
	match tier:
		"trophy":
			return {
				"panel_duration": 0.36,
				"fish_delay": 0.20,
				"fish_reveal_duration": 0.52,
				"fish_start_scale": 0.58,
				"fish_reveal_scale": 1.04,
				"shadow_alpha": 0.34,
				"float_y": 6.5,
				"float_duration": 1.65,
				"breath_scale": 0.020,
				"focus_strength": 0.66,
				"edge_strength": 0.26,
				"glow_power": 0.60,
				"pulse_speed": 0.82,
				"particle_drift": 0.13,
				"particle_scale": 1.25,
				"shimmer_speed": 0.24
			}
		"rare":
			return {
				"panel_duration": 0.32,
				"fish_delay": 0.17,
				"fish_reveal_duration": 0.46,
				"fish_start_scale": 0.64,
				"fish_reveal_scale": 1.025,
				"shadow_alpha": 0.30,
				"float_y": 5.5,
				"float_duration": 1.80,
				"breath_scale": 0.017,
				"focus_strength": 0.62,
				"edge_strength": 0.22,
				"glow_power": 0.52,
				"pulse_speed": 0.92,
				"particle_drift": 0.11,
				"particle_scale": 1.12,
				"shimmer_speed": 0.21
			}
		"uncommon":
			return {
				"panel_duration": 0.30,
				"fish_delay": 0.15,
				"fish_reveal_duration": 0.40,
				"fish_start_scale": 0.70,
				"fish_reveal_scale": 1.015,
				"shadow_alpha": 0.27,
				"float_y": 4.5,
				"float_duration": 1.95,
				"breath_scale": 0.014,
				"focus_strength": 0.59,
				"edge_strength": 0.20,
				"glow_power": 0.46,
				"pulse_speed": 1.02,
				"particle_drift": 0.09,
				"particle_scale": 1.00,
				"shimmer_speed": 0.18
			}
		_:
			return {
				"panel_duration": 0.28,
				"fish_delay": 0.13,
				"fish_reveal_duration": 0.36,
				"fish_start_scale": 0.74,
				"fish_reveal_scale": 1.0,
				"shadow_alpha": 0.24,
				"float_y": 3.8,
				"float_duration": 2.10,
				"breath_scale": 0.011,
				"focus_strength": 0.56,
				"edge_strength": 0.18,
				"glow_power": 0.40,
				"pulse_speed": 1.12,
				"particle_drift": 0.07,
				"particle_scale": 0.90,
				"shimmer_speed": 0.15
			}

func _get_catch_length_cm(catch_data: Dictionary) -> float:
	if catch_data.has("length_cm"):
		return float(catch_data.get("length_cm", 0.0))

	var weight := float(catch_data.get("weight", 0.0))
	return max(12.0 + pow(max(weight, 0.05), 0.42) * 23.0, 8.0)

func _refresh_bottom_nav_styles() -> void:
	var active_tab := _active_nav_tab

	if basket_panel.visible:
		active_tab = "sell"
	elif tackle_panel != null and tackle_panel.visible:
		active_tab = "tackle"
	elif inventory_panel.visible:
		active_tab = _active_nav_tab
	elif shop_panel != null and shop_panel.visible:
		active_tab = "shop"
	elif waterbody_panel != null and waterbody_panel.visible:
		active_tab = "map"

	var nav_data: Array = [
		[nav_fish_button, "fish"],
		[inventory_button, "inventory"],
		[tackle_button, "tackle"],
		[shop_button, "shop"],
		[basket_button, "sell"],
		[map_button, "map"],
		[profile_button, "profile"]
	]

	for item in nav_data:
		var nav_button: Button = item[0]
		var tab_name: String = item[1]
		_apply_button_style(nav_button, STYLE_BOTTOM_NAV_ACTIVE if tab_name == active_tab else STYLE_BOTTOM_NAV_BUTTON)

func _get_main_hud_text() -> String:
	var spot := SpotDatabase.get_spot(PlayerData.current_spot)
	var waterbody := _get_waterbody(PlayerData.current_waterbody)
	var tackle_stats := PlayerData.get_tackle_stats()
	var depth := float(spot.get("depth", 0.0))
	var bottom_type := "ил"

	if depth <= 1.6:
		bottom_type = "трава"
	elif depth >= 5.0:
		bottom_type = "яма"

	var activity := "ровная"
	if float(spot.get("bite_chance_modifier", 1.0)) > 1.05:
		activity = "активная"
	elif float(spot.get("bite_chance_modifier", 1.0)) < 0.95:
		activity = "тихая"

	return "Статус: %s\nВодоём: %s\nАктивность: %s\nТочка: %.1f м | снасть: %.1f м\nДно: %s\nСнасть: уд. %.1f кг | леска %.1f кг\nПрочность: уд. %d%% | леска %d%%\nБонус клёва: +%d%%" % [
		timer_label.text,
		str(waterbody.get("name", "-")),
		activity,
		depth,
		float(tackle_stats.get("fishing_depth", PlayerData.fishing_depth)),
		bottom_type,
		float(tackle_stats.get("max_fish_weight", 0.0)),
		float(tackle_stats.get("line_strength", 0.0)),
		roundi(PlayerData.get_tackle_condition("rod") * 100.0),
		roundi(PlayerData.get_tackle_condition("line") * 100.0),
		roundi((float(tackle_stats.get("bite_detection_bonus", 0.0)) + float(tackle_stats.get("fish_attraction", 0.0))) * 100.0)
	]

func _update_shop_ui() -> void:
	if shop_panel == null:
		return

	shop_money_label.text = "%d мон." % PlayerData.money
	_apply_button_style(shop_bait_category_button, STYLE_BOTTOM_NAV_ACTIVE if _shop_category == SHOP_CATEGORY_BAIT else STYLE_SECONDARY_BUTTON)
	_apply_button_style(shop_consumable_category_button, STYLE_BOTTOM_NAV_ACTIVE if _shop_category == SHOP_CATEGORY_CONSUMABLE else STYLE_SECONDARY_BUTTON)
	_apply_button_style(shop_tackle_category_button, STYLE_BOTTOM_NAV_ACTIVE if _shop_category == SHOP_CATEGORY_TACKLE else STYLE_SECONDARY_BUTTON)
	_rebuild_shop_cards()

func _rebuild_shop_cards() -> void:
	for child in shop_items_container.get_children():
		child.queue_free()

	_shop_card_nodes.clear()
	var items := _get_shop_items_for_category(_shop_category)
	var columns := 2
	var gap := 10.0

	var card_width: float = (shop_items_container.size.x - gap * float(columns - 1)) / float(columns)
	var rows: int = max(ceil(float(items.size()) / float(columns)), 1)
	var card_min_height := 88.0
	var card_max_height := 96.0

	if _shop_category == SHOP_CATEGORY_TACKLE:
		gap = 8.0
		card_width = (shop_items_container.size.x - gap * float(columns - 1)) / float(columns)
		card_min_height = 64.0
		card_max_height = 74.0

	var card_height: float = min(max((shop_items_container.size.y - gap * float(rows - 1)) / float(rows), card_min_height), card_max_height)

	for i in items.size():
		var item: Dictionary = items[i]
		var column: int = i % columns
		var row: int = int(i / columns)
		var card := _create_shop_card(item, Vector2(card_width, card_height))
		card.position = Vector2(float(column) * (card_width + gap), float(row) * (card_height + gap))
		shop_items_container.add_child(card)
		_shop_card_nodes[str(item.get("id", ""))] = card

func _create_shop_card(item: Dictionary, card_size: Vector2) -> Panel:
	var card := Panel.new()
	card.size = card_size
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.mouse_entered.connect(_on_shop_card_hovered.bind(str(item.get("id", "")), true))
	card.mouse_exited.connect(_on_shop_card_hovered.bind(str(item.get("id", "")), false))
	card.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			Color(0.065, 0.130, 0.120, 0.78),
			Color(0.80, 1.0, 0.86, 0.24),
			14,
			7,
			Color(0.0, 0.0, 0.0, 0.18)
		)
	)

	var item_id := str(item.get("id", ""))
	var rarity := str(item.get("rarity", "common"))
	var rarity_color := _get_rarity_color(rarity)
	var compact := card_size.y <= 78.0
	var content_x := 52.0 if compact else 56.0
	var button_width := 74.0 if compact else 78.0
	var button_height := 28.0 if compact else 30.0
	var button_x := card_size.x - button_width - 10.0
	var icon_size := 32.0 if compact else 36.0
	var icon_y := (card_size.y - icon_size) * 0.5
	var name_font_size := 13 if compact else 14
	var stat_font_size := 10 if compact else 11
	var meta_font_size := 10 if compact else 11
	var price_font_size := 12 if compact else 13
	var badge_font_size := 9 if compact else 10

	var icon_label := Label.new()
	icon_label.text = str(item.get("icon", "?"))
	icon_label.position = Vector2(10.0, icon_y)
	icon_label.size = Vector2(icon_size, icon_size)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 17 if compact else 18)
	icon_label.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.98))
	icon_label.add_theme_stylebox_override(
		"normal",
		_make_panel_style(Color(0.10, 0.22, 0.17, 0.72), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.32), 12, 4, Color(0.0, 0.0, 0.0, 0.10))
	)
	card.add_child(icon_label)

	var badge_label := Label.new()
	badge_label.text = _get_rarity_title(rarity)
	badge_label.position = Vector2(button_x, 7.0)
	badge_label.size = Vector2(button_width, 18.0 if compact else 20.0)
	badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge_label.clip_text = true
	badge_label.add_theme_font_size_override("font_size", badge_font_size)
	badge_label.add_theme_color_override("font_color", Color(rarity_color.r, rarity_color.g, rarity_color.b, 1.0))
	badge_label.add_theme_stylebox_override(
		"normal",
		_make_panel_style(Color(rarity_color.r * 0.12, rarity_color.g * 0.16, rarity_color.b * 0.14, 0.64), Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.34), 10, 2, Color(0.0, 0.0, 0.0, 0.08))
	)
	card.add_child(badge_label)

	var name_label := Label.new()
	name_label.text = str(item.get("name", "-"))
	name_label.position = Vector2(content_x, 7.0)
	name_label.size = Vector2(max(button_x - content_x - 10.0, 96.0), 19.0)
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", name_font_size)
	name_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.91, 1.0))
	card.add_child(name_label)

	var quantity := int(item.get("quantity", 1))
	var owned := _get_owned_shop_item_quantity(item_id)
	var stat_label := Label.new()
	stat_label.text = _get_shop_key_stat_text(item)
	stat_label.position = Vector2(content_x, 27.0)
	stat_label.size = Vector2(max(button_x - content_x - 10.0, 96.0), 16.0)
	stat_label.clip_text = true
	stat_label.add_theme_font_size_override("font_size", stat_font_size)
	stat_label.add_theme_color_override("font_color", Color(0.74, 0.88, 0.78, 0.92))
	card.add_child(stat_label)

	var owned_label := Label.new()
	owned_label.text = "Есть: %d  +%d" % [owned, quantity]
	owned_label.position = Vector2(content_x, card_size.y - 23.0)
	owned_label.size = Vector2(88.0, 17.0)
	owned_label.clip_text = true
	owned_label.add_theme_font_size_override("font_size", meta_font_size)
	owned_label.add_theme_color_override("font_color", Color(0.64, 0.78, 0.70, 0.84))
	card.add_child(owned_label)

	var price_label := Label.new()
	price_label.text = "%d мон." % int(item.get("price", 0))
	price_label.position = Vector2(content_x + 92.0, card_size.y - 24.0)
	price_label.size = Vector2(max(button_x - content_x - 102.0, 54.0), 18.0)
	price_label.clip_text = true
	price_label.add_theme_font_size_override("font_size", price_font_size)
	price_label.add_theme_color_override("font_color", Color(0.92, 0.96, 0.74, 0.95))
	card.add_child(price_label)

	var buy_button := Button.new()
	buy_button.text = "Купить"
	buy_button.position = Vector2(button_x, card_size.y - button_height - 7.0)
	buy_button.size = Vector2(button_width, button_height)
	buy_button.add_theme_font_size_override("font_size", 11 if compact else 12)
	_apply_button_style(buy_button, STYLE_PRIMARY_BUTTON)
	buy_button.pressed.connect(_on_shop_buy_pressed.bind(item_id))
	card.add_child(buy_button)

	return card

func _get_shop_items_for_category(category: String) -> Array:
	var items: Array = []

	if category == SHOP_CATEGORY_TACKLE:
		return PlayerData.get_tackle_shop_items()

	for item in SHOP_ITEMS:
		if str(item.get("shop_category", "")) == category:
			items.append(item)

	return items

func _get_shop_item(item_id: String) -> Dictionary:
	for item in PlayerData.get_tackle_shop_items():
		if str(item.get("id", "")) == item_id:
			return item

	for item in SHOP_ITEMS:
		if str(item.get("id", "")) == item_id:
			return item

	return {}

func _get_owned_shop_item_quantity(item_id: String) -> int:
	var owned_item := PlayerData.get_owned_item(item_id)

	if owned_item.is_empty():
		return 0

	return int(owned_item.get("quantity", 0))

func _get_shop_key_stat_text(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {})
	var category := str(item.get("category", item.get("type", "misc")))

	match category:
		"rod":
			return "Рыба %.1f кг  |  контроль +%d%%" % [
				float(stats.get("max_fish_weight", 0.0)),
				roundi(float(stats.get("tension_bonus", stats.get("control_bonus", 0.0))) * 100.0)
			]
		"line":
			return "Нагрузка %.1f кг  |  обрыв %d%%" % [
				float(stats.get("max_load_kg", stats.get("strength", 0.0))),
				roundi(float(stats.get("break_resistance", 1.0)) * 100.0)
			]
		"float":
			return "Клёв +%d%%  |  стабильн. +%d%%" % [
				roundi((float(stats.get("sensitivity", stats.get("bite_detection_bonus", 0.0))) + float(stats.get("bite_visibility", 0.0)) * 0.5) * 100.0),
				roundi(float(stats.get("stability", 0.0)) * 100.0)
			]
		"hook":
			return "№%d  |  %s  |  подсечка +%d%%" % [
				int(stats.get("hook_size", 0)),
				_format_tackle_stat_value("target_fish_size", stats.get("target_fish_size", "small")),
				roundi(float(stats.get("hook_chance", stats.get("hook_success_bonus", 0.0))) * 100.0)
			]
		"bait":
			return "Клёв +%d%%  |  пачка x%d" % [
				roundi(float(stats.get("fish_attraction", 0.0)) * 100.0),
				int(item.get("quantity", 1))
			]
		_:
			if stats.has("bite_bonus"):
				return "Бонус клёва +%d%%" % roundi(float(stats.get("bite_bonus", 0.0)) * 100.0)
			return "Расходник"

func _get_shop_inventory_item(shop_item: Dictionary) -> Dictionary:
	var stats: Dictionary = shop_item.get("stats", {}).duplicate(true)
	return {
		"id": str(shop_item.get("id", "")),
		"name": str(shop_item.get("name", "-")),
		"type": str(shop_item.get("type", shop_item.get("category", "misc"))),
		"category": str(shop_item.get("category", "misc")),
		"rarity": str(shop_item.get("rarity", "common")),
		"price": int(shop_item.get("price", 0)),
		"quantity": int(shop_item.get("quantity", 1)),
		"description": str(shop_item.get("description", "")),
		"stats": stats
	}

func _set_shop_category(category: String) -> void:
	_shop_category = category
	_show_shop_notice("", true)
	_update_shop_ui()

func _show_shop_notice(message: String, success: bool) -> void:
	if shop_notice_label == null:
		return

	shop_notice_label.text = message
	shop_notice_label.modulate = Color(0.78, 1.0, 0.78, 1.0) if success else Color(1.0, 0.64, 0.54, 1.0)

	if message == "":
		return

	if is_instance_valid(_shop_feedback_tween):
		_shop_feedback_tween.kill()

	_shop_feedback_tween = create_tween()
	_shop_feedback_tween.tween_property(shop_notice_label, "modulate:a", 1.0, 0.05)
	_shop_feedback_tween.tween_property(shop_notice_label, "modulate:a", 0.82, 1.25)

func _show_toast(message: String, success: bool = true) -> void:
	if toast_label == null or message == "":
		return

	if is_instance_valid(_toast_tween):
		_toast_tween.kill()

	toast_label.text = message
	toast_label.visible = true
	toast_label.modulate = Color(0.78, 1.0, 0.78, 0.0) if success else Color(1.0, 0.68, 0.58, 0.0)

	_toast_tween = create_tween()
	_toast_tween.tween_property(toast_label, "modulate:a", 1.0, 0.12)
	_toast_tween.tween_interval(1.2)
	_toast_tween.tween_property(toast_label, "modulate:a", 0.0, 0.28)
	_toast_tween.tween_callback(func() -> void:
		if toast_label != null:
			toast_label.visible = false
	)

func _play_shop_card_feedback(item_id: String, success: bool) -> void:
	if not _shop_card_nodes.has(item_id):
		return

	var card := _shop_card_nodes[item_id] as Control
	if card == null:
		return

	var flash := Color(1.0, 1.0, 1.0, 1.0)

	if success:
		flash = Color(1.18, 1.35, 1.18, 1.0)
	else:
		flash = Color(1.35, 0.82, 0.72, 1.0)

	var tween := create_tween()
	tween.tween_property(card, "modulate", flash, 0.08)
	tween.tween_property(card, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.18)

func _on_shop_card_hovered(item_id: String, hovered: bool) -> void:
	if not _shop_card_nodes.has(item_id):
		return

	var card := _shop_card_nodes[item_id] as Control
	if card == null:
		return

	var target := Color(1.08, 1.12, 1.06, 1.0) if hovered else Color(1.0, 1.0, 1.0, 1.0)
	var tween := create_tween()
	tween.tween_property(card, "modulate", target, 0.10)

func _update_inventory_ui() -> void:
	_visible_inventory_items = _get_visible_inventory_items()
	inventory_title_label.text = "Инвентарь"
	inventory_tackle_label.text = _get_current_tackle_inventory_text()
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
	var details_bottom_padding := 24.0

	if can_equip:
		details_bottom_padding = 76.0

	inventory_details_label.size = Vector2(
		inventory_details_label.size.x,
		max(inventory_details_card.size.y - details_bottom_padding, 48.0)
	)
	inventory_equip_button.disabled = not can_equip or _fishing_ui_state != FishingUiState.IDLE
	inventory_equip_button.visible = can_equip

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

func _get_current_tackle_inventory_text() -> String:
	return "Текущая маховая снасть\nУдилище: %s\nЛеска: %s | Поплавок: %s\nКрючок: %s | Наживка: %s x%d\nПрочность: уд. %d%% | леска %d%% | крючок %d%%" % [
		PlayerData.current_tackle.get("rod", {}).get("name", "-"),
		PlayerData.current_tackle.get("line", {}).get("name", "-"),
		PlayerData.current_tackle.get("float", {}).get("name", "-"),
		PlayerData.current_tackle.get("hook", {}).get("name", "-"),
		PlayerData.current_tackle.get("bait", {}).get("name", "-"),
		PlayerData.get_current_bait_quantity(),
		roundi(PlayerData.get_tackle_condition("rod") * 100.0),
		roundi(PlayerData.get_tackle_condition("line") * 100.0),
		roundi(PlayerData.get_tackle_condition("hook") * 100.0)
	]

func _get_tackle_build_summary_text() -> String:
	return "Текущая сборка: %s | %s | %s\n%s | %s x%d | глубина %.1f м\nПрочность: уд. %d%% | леска %d%% | крючок %d%%" % [
		PlayerData.current_tackle.get("rod", {}).get("name", "-"),
		PlayerData.current_tackle.get("line", {}).get("name", "-"),
		PlayerData.current_tackle.get("float", {}).get("name", "-"),
		PlayerData.current_tackle.get("hook", {}).get("name", "-"),
		PlayerData.current_tackle.get("bait", {}).get("name", "-"),
		PlayerData.get_current_bait_quantity(),
		PlayerData.fishing_depth,
		roundi(PlayerData.get_tackle_condition("rod") * 100.0),
		roundi(PlayerData.get_tackle_condition("line") * 100.0),
		roundi(PlayerData.get_tackle_condition("hook") * 100.0)
	]

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
			return "Рыба"
		_:
			return "Разное"

func _update_tackle_ui() -> void:
	if tackle_panel == null:
		return

	_visible_tackle_items = PlayerData.get_owned_items_for_category(_tackle_category)
	tackle_title_label.text = "Сборка снасти"
	tackle_current_label.text = _get_tackle_build_summary_text()
	tackle_depth_label.text = "Глубина: %.1f м" % PlayerData.fishing_depth
	tackle_hint_label.text = _get_tackle_setup_hints_text(2)
	tackle_item_list.clear()

	var selected_index := -1
	for i in _visible_tackle_items.size():
		var item: Dictionary = _visible_tackle_items[i]
		tackle_item_list.add_item(_get_tackle_item_display_text(item))
		var list_index := tackle_item_list.item_count - 1

		if _is_tackle_item_equipped(item):
			tackle_item_list.set_item_custom_bg_color(list_index, Color(0.12, 0.34, 0.22, 0.66))
			tackle_item_list.set_item_custom_fg_color(list_index, Color(0.80, 1.0, 0.82, 1.0))

		if str(item.get("id", "")) == _selected_tackle_item_id:
			selected_index = i

	if selected_index < 0 and not _visible_tackle_items.is_empty():
		selected_index = 0
		_selected_tackle_item_id = str(_visible_tackle_items[0].get("id", ""))

	if selected_index >= 0:
		tackle_item_list.select(selected_index)
	else:
		_selected_tackle_item_id = ""

	var selected_item := _get_selected_tackle_item()
	var hints_text := _get_tackle_setup_hints_text(4)
	if selected_item.is_empty():
		tackle_details_label.text = "В этой категории пока нет предметов."
		tackle_compare_label.text = "Купи снасть в магазине или выбери другую категорию.\n\nПодсказки:\n%s" % hints_text
	else:
		tackle_details_label.text = _get_tackle_item_details_text(selected_item)
		tackle_compare_label.text = "%s\n\nПодсказки:\n%s" % [_get_tackle_compare_text(selected_item), hints_text]

	var can_equip := not selected_item.is_empty() and PlayerData.can_equip_item(selected_item)
	tackle_equip_button.visible = can_equip
	tackle_equip_button.disabled = not can_equip or _is_tackle_item_equipped(selected_item) or _fishing_ui_state != FishingUiState.IDLE

	if _fishing_ui_state != FishingUiState.IDLE and can_equip:
		tackle_equip_button.text = "Только вне ловли"
	elif _is_tackle_item_equipped(selected_item):
		tackle_equip_button.text = "Экипировано"
	else:
		tackle_equip_button.text = "Экипировать"

	var category_buttons: Array = [
		[tackle_rod_button, "rod"],
		[tackle_line_button, "line"],
		[tackle_float_button, "float"],
		[tackle_hook_button, "hook"],
		[tackle_bait_button, "bait"]
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
		_apply_button_style(button, STYLE_BOTTOM_NAV_ACTIVE if category == _tackle_category else STYLE_SECONDARY_BUTTON)

func _set_tackle_category(category: String) -> void:
	_tackle_category = category
	_selected_tackle_item_id = ""
	_update_tackle_ui()

func _on_tackle_item_selected(index: int) -> void:
	if index < 0 or index >= _visible_tackle_items.size():
		_selected_tackle_item_id = ""
	else:
		_selected_tackle_item_id = str(_visible_tackle_items[index].get("id", ""))

	_update_tackle_ui()

func _on_tackle_item_activated(index: int) -> void:
	if index < 0 or index >= _visible_tackle_items.size():
		return

	_selected_tackle_item_id = str(_visible_tackle_items[index].get("id", ""))

	if _fishing_ui_state == FishingUiState.IDLE and not _is_tackle_item_equipped(_visible_tackle_items[index]):
		_on_tackle_equip_button_pressed()
	else:
		_update_tackle_ui()

func _on_tackle_equip_button_pressed() -> void:
	var selected_item := _get_selected_tackle_item()

	if selected_item.is_empty() or not PlayerData.can_equip_item(selected_item):
		result_label.text = "Эту снасть нельзя экипировать."
		_update_tackle_ui()
		return

	if _fishing_ui_state != FishingUiState.IDLE:
		result_label.text = "Снасть можно менять только перед забросом."
		_update_tackle_ui()
		return

	if PlayerData.equip_item(str(selected_item.get("id", ""))):
		var equip_message := "Экипировано: %s" % str(selected_item.get("name", "-"))
		result_label.text = equip_message
		_show_toast(equip_message, true)
		SaveManager.save_game()
	else:
		result_label.text = "Не удалось экипировать снасть."

	_update_ui()

func _on_tackle_depth_button_pressed(delta: float) -> void:
	if _fishing_ui_state != FishingUiState.IDLE:
		result_label.text = "Глубину можно менять только перед забросом."
		_show_toast("Глубину можно менять перед забросом", false)
		_update_tackle_ui()
		return

	PlayerData.adjust_fishing_depth(delta)
	var depth_message := "Глубина: %.1f м" % PlayerData.fishing_depth
	result_label.text = "Выставлена глубина снасти: %.1f м" % PlayerData.fishing_depth
	_show_toast(depth_message, true)
	SaveManager.save_game()
	_update_ui()

func _on_tackle_close_button_pressed() -> void:
	tackle_panel.visible = false
	tackle_backdrop.visible = false
	_active_nav_tab = "fish"
	_refresh_bottom_nav_styles()

func _update_waterbody_ui() -> void:
	if waterbody_panel == null:
		return

	PlayerData.refresh_waterbody_unlocks()
	_visible_waterbodies = _get_all_waterbodies()
	waterbody_item_list.clear()

	var selected_index := -1
	for i in _visible_waterbodies.size():
		var waterbody: Dictionary = _visible_waterbodies[i]
		var waterbody_id := str(waterbody.get("id", ""))
		var required_level := int(waterbody.get("required_level", 1))
		var unlocked := PlayerData.can_use_waterbody(waterbody_id)
		var label := "%s" % str(waterbody.get("name", "-"))
		if not unlocked:
			label = "%s  |  LVL %d" % [label, required_level]
		elif waterbody_id == PlayerData.current_waterbody:
			label = "%s  |  текущий" % label

		waterbody_item_list.add_item(label)
		var list_index := waterbody_item_list.item_count - 1
		if unlocked:
			waterbody_item_list.set_item_custom_fg_color(list_index, Color(0.84, 0.98, 0.86, 1.0))
		else:
			waterbody_item_list.set_item_custom_fg_color(list_index, Color(0.52, 0.62, 0.58, 0.88))
		if waterbody_id == PlayerData.current_waterbody:
			waterbody_item_list.set_item_custom_bg_color(list_index, Color(0.12, 0.34, 0.22, 0.66))

		if waterbody_id == _selected_waterbody_id:
			selected_index = i

	if selected_index < 0 and not _visible_waterbodies.is_empty():
		selected_index = 0
		_selected_waterbody_id = str(_visible_waterbodies[0].get("id", ""))

	if selected_index >= 0:
		waterbody_item_list.select(selected_index)

	var selected_waterbody := _get_selected_waterbody()
	_update_waterbody_spot_picker(selected_waterbody)
	var can_select := not selected_waterbody.is_empty() and PlayerData.can_use_waterbody(str(selected_waterbody.get("id", "")))
	var selected_spot := _get_selected_waterbody_spot()
	var is_current := str(selected_waterbody.get("id", "")) == PlayerData.current_waterbody and str(selected_spot.get("id", "")) == PlayerData.current_spot
	waterbody_details_label.text = _get_waterbody_details_text(selected_waterbody)
	waterbody_preview.color = _get_waterbody_preview_color(str(selected_waterbody.get("id", "")))
	waterbody_select_button.disabled = not can_select or selected_spot.is_empty() or is_current or _fishing_ui_state != FishingUiState.IDLE
	waterbody_select_button.text = "Текущая точка" if is_current else "Ловить здесь"

func _get_selected_waterbody() -> Dictionary:
	for waterbody in _visible_waterbodies:
		if str(waterbody.get("id", "")) == _selected_waterbody_id:
			return waterbody

	return {}

func _update_waterbody_spot_picker(waterbody: Dictionary) -> void:
	if waterbody_spot_list == null:
		return

	waterbody_spot_list.clear()
	_visible_waterbody_spots = []

	if waterbody.is_empty():
		waterbody_spot_details_label.text = "Точка ловли не выбрана."
		_selected_waterbody_spot_id = ""
		return

	var waterbody_id := str(waterbody.get("id", ""))
	_visible_waterbody_spots = SpotDatabase.get_spots_for_waterbody(waterbody_id)
	var selected_index := -1

	for i in _visible_waterbody_spots.size():
		var spot: Dictionary = _visible_waterbody_spots[i]
		var spot_id := str(spot.get("id", ""))
		var label := "%s  %.1f-%.1f м" % [
			str(spot.get("name", "-")),
			float(spot.get("min_depth", 0.2)),
			float(spot.get("max_depth", 6.0))
		]
		if waterbody_id == PlayerData.current_waterbody and spot_id == PlayerData.current_spot:
			label = "%s  |  текущая" % label

		waterbody_spot_list.add_item(label)
		var list_index := waterbody_spot_list.item_count - 1
		if waterbody_id == PlayerData.current_waterbody and spot_id == PlayerData.current_spot:
			waterbody_spot_list.set_item_custom_bg_color(list_index, Color(0.12, 0.34, 0.22, 0.66))
			waterbody_spot_list.set_item_custom_fg_color(list_index, Color(0.80, 1.0, 0.82, 1.0))

		if spot_id == _selected_waterbody_spot_id:
			selected_index = i

	if selected_index < 0 and not _visible_waterbody_spots.is_empty():
		selected_index = 0
		if waterbody_id == PlayerData.current_waterbody:
			for i in _visible_waterbody_spots.size():
				if str(_visible_waterbody_spots[i].get("id", "")) == PlayerData.current_spot:
					selected_index = i
					break
		_selected_waterbody_spot_id = str(_visible_waterbody_spots[selected_index].get("id", ""))

	if selected_index >= 0:
		waterbody_spot_list.select(selected_index)

	waterbody_spot_details_label.text = _get_waterbody_spot_details_text(_get_selected_waterbody_spot())

func _get_selected_waterbody_spot() -> Dictionary:
	for spot in _visible_waterbody_spots:
		if str(spot.get("id", "")) == _selected_waterbody_spot_id:
			return spot

	return {}

func _get_waterbody_spot_details_text(spot: Dictionary) -> String:
	if spot.is_empty():
		return "Точка ловли не выбрана."

	var fish_names: Array = []
	var fish_pool: Array = spot.get("fish_pool", spot.get("available_fish", []))
	for fish_id in fish_pool:
		var fish := FishDatabase.get_fish(str(fish_id))
		if fish.is_empty():
			continue

		fish_names.append(str(fish.get("name", fish_id)))
		if fish_names.size() >= 7:
			break

	return "%s\n%s\nГлубина: %.1f-%.1f м  |  лучше %.1f м\nРыба: %s\n\n%s" % [
		str(spot.get("name", "-")),
		str(spot.get("spot_type", spot.get("type", "-"))),
		float(spot.get("min_depth", 0.2)),
		float(spot.get("max_depth", 6.0)),
		float(spot.get("preferred_depth", spot.get("depth", 1.0))),
		", ".join(fish_names),
		str(spot.get("description", ""))
	]

func _get_waterbody_details_text(waterbody: Dictionary) -> String:
	if waterbody.is_empty():
		return "Водоём не выбран."

	var waterbody_id := str(waterbody.get("id", ""))
	var required_level := int(waterbody.get("required_level", 1))
	var unlocked := PlayerData.can_use_waterbody(waterbody_id)
	var status := "Доступен" if unlocked else "Требуется LVL %d" % required_level
	var spots := SpotDatabase.get_spots_for_waterbody(waterbody_id)
	var spot_names: Array = []
	for spot in spots:
		spot_names.append(str(spot.get("name", "-")))

	return "%s\n%s\n\n%s\n\nОсновная рыба: %s\nТочки: %s\nФон: %s" % [
		str(waterbody.get("name", "-")),
		status,
		str(waterbody.get("description", "")),
		_get_waterbody_fish_names(waterbody_id, 7),
		", ".join(spot_names),
		str(waterbody.get("background", "-"))
	]

func _get_waterbody_preview_color(waterbody_id: String) -> Color:
	match waterbody_id:
		"forest_lake":
			return Color(0.08, 0.22, 0.15, 0.88)
		"river_backwater":
			return Color(0.08, 0.16, 0.23, 0.88)
		_:
			return Color(0.12, 0.30, 0.27, 0.88)

func _on_waterbody_item_selected(index: int) -> void:
	if index < 0 or index >= _visible_waterbodies.size():
		_selected_waterbody_id = ""
	else:
		_selected_waterbody_id = str(_visible_waterbodies[index].get("id", ""))
		_selected_waterbody_spot_id = ""

	_update_waterbody_ui()

func _on_waterbody_spot_item_selected(index: int) -> void:
	if index < 0 or index >= _visible_waterbody_spots.size():
		_selected_waterbody_spot_id = ""
	else:
		_selected_waterbody_spot_id = str(_visible_waterbody_spots[index].get("id", ""))

	_update_waterbody_ui()

func _on_waterbody_select_button_pressed() -> void:
	var selected_waterbody := _get_selected_waterbody()

	if selected_waterbody.is_empty():
		return

	var waterbody_id := str(selected_waterbody.get("id", ""))
	if not PlayerData.set_current_waterbody(waterbody_id):
		var required_level := int(selected_waterbody.get("required_level", 1))
		_show_toast("Нужен LVL %d" % required_level, false)
		_update_waterbody_ui()
		return

	var selected_spot := _get_selected_waterbody_spot()
	if selected_spot.is_empty():
		PlayerData.current_spot = _get_primary_waterbody_spot(waterbody_id)
	else:
		PlayerData.set_current_spot(str(selected_spot.get("id", "")))
	_setup_spots()
	result_label.text = "Выбрано: %s / %s" % [
		str(selected_waterbody.get("name", "-")),
		str(SpotDatabase.get_spot(PlayerData.current_spot).get("name", "-"))
	]
	_show_toast(result_label.text, true)
	SaveManager.save_game()
	_update_ui()
	_on_waterbody_close_button_pressed()

func _on_waterbody_close_button_pressed() -> void:
	waterbody_panel.visible = false
	waterbody_backdrop.visible = false
	_active_nav_tab = "fish"
	_refresh_bottom_nav_styles()

func _get_selected_tackle_item() -> Dictionary:
	for item in _visible_tackle_items:
		if str(item.get("id", "")) == _selected_tackle_item_id:
			return item

	return {}

func _get_tackle_item_display_text(item: Dictionary) -> String:
	var name := str(item.get("name", "-"))
	var quantity := int(item.get("quantity", 1))
	var equipped_marker := "  ✓ Equipped" if _is_tackle_item_equipped(item) else ""

	if str(item.get("category", "")) == "bait":
		return "%s x%d%s" % [name, quantity, equipped_marker]

	return "%s%s" % [name, equipped_marker]

func _get_tackle_item_details_text(item: Dictionary) -> String:
	var category := str(item.get("category", "misc"))
	var details := "%s\nТип: %s\nРедкость: %s\nЦена: %d мон.\nКоличество: %d" % [
		str(item.get("name", "-")),
		_get_inventory_category_title(category),
		_get_rarity_title(str(item.get("rarity", "common"))),
		int(item.get("price", 0)),
		int(item.get("quantity", 1))
	]
	var description := str(item.get("description", ""))

	if description != "":
		details += "\n%s" % description

	var stats_text := _get_tackle_stats_text(item)
	if stats_text != "":
		details += "\n\n%s" % stats_text

	return details

func _get_tackle_stats_text(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {})
	var category := str(item.get("category", item.get("type", "misc")))
	var lines: Array = []

	for key in _get_tackle_stat_keys(category):
		if not stats.has(key):
			continue

		lines.append("%s: %s" % [_get_tackle_stat_title(key), _format_tackle_stat_value(key, stats[key])])

	return "\n".join(lines)

func _get_tackle_compare_text(item: Dictionary) -> String:
	var category := str(item.get("category", "misc"))
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
		var diff_text := ""

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
	var spot := SpotDatabase.get_spot(PlayerData.current_spot)
	var spot_fish: Array = spot.get("available_fish", [])
	var depth := PlayerData.fishing_depth
	var tackle_stats := PlayerData.get_tackle_stats()
	var hook_size: int = int(tackle_stats.get("hook_size", 12))
	var line_strength: float = float(tackle_stats.get("line_strength", 1.0))
	var bait_type := str(tackle_stats.get("bait_type", "worm"))
	var depth_candidates: Array = []
	var bait_match_names: Array = []
	var too_big_hook_count := 0
	var too_small_hook_count := 0
	var fitting_hook_count := 0
	var line_warning := false
	var large_fish_nearby := false

	if depth <= 1.1:
		hints.append("На этой глубине чаще клюёт мелкая рыба.")
	elif depth >= 3.2:
		hints.append("Глубина подходит для крупной донной рыбы.")
	else:
		hints.append("Средняя глубина: универсальная настройка.")

	for fish_id in spot_fish:
		var fish := FishDatabase.get_fish(str(fish_id))
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
	var spot := SpotDatabase.get_spot(spot_id)

	if spot.is_empty():
		return "Точка ловли не найдена."

	var depth := PlayerData.fishing_depth
	var spot_fish: Array = spot.get("available_fish", [])
	var min_available_depth := 999.0
	var max_available_depth := -1.0
	var depth_fish: Array = []
	var hook_fish: Array = []
	var bait_fish: Array = []
	var tackle_stats := PlayerData.get_tackle_stats()
	var hook_size: int = int(tackle_stats.get("hook_size", 12))
	var bait_type := str(tackle_stats.get("bait_type", "worm"))

	for fish_id in spot_fish:
		var fish := FishDatabase.get_fish(str(fish_id))
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
	var category := str(item.get("category", ""))

	if not PlayerData.current_tackle.has(category):
		return false

	return str(PlayerData.current_tackle[category].get("id", "")) == str(item.get("id", ""))

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
		"fish_strength": 0.0,
		"fish_aggression": 0.0,
		"load_kg": 0.0,
		"line_load_ratio": 0.0,
		"rod_load_ratio": 0.0,
		"rod_durability": 1.0,
		"line_durability": 1.0,
		"hook_durability": 1.0,
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
	var load_kg: float = max(float(state.get("load_kg", 0.0)), 0.0)
	var line_load_ratio: float = max(float(state.get("line_load_ratio", 0.0)), 0.0)
	var rod_load_ratio: float = max(float(state.get("rod_load_ratio", 0.0)), 0.0)
	var rod_durability: float = clamp(float(state.get("rod_durability", 1.0)), 0.0, 1.0)
	var line_durability: float = clamp(float(state.get("line_durability", 1.0)), 0.0, 1.0)
	var hook_durability: float = clamp(float(state.get("hook_durability", 1.0)), 0.0, 1.0)
	var fish_strength: float = max(float(state.get("fish_strength", 0.0)), 0.0)
	var fish_aggression: float = max(float(state.get("fish_aggression", 0.0)), 0.0)
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

	tension_label.text = "Натяжение: %d%%" % roundi(tension * 100.0)
	progress_label.text = "Прогресс: %d%%" % roundi(catch_progress * 100.0)
	debug_label.text = "fish: %s %.2fkg | behavior: %s\nfight: %.2f | strength: %.2f | aggr: %.2f\nload: %.2fkg | line %.0f%% | rod %.0f%%\ntension: %d%% | green: %d-%d%%\nbreak risk: %d%% | escape risk: %d%%\ndurability: rod %d%% | line %d%% | hook %d%%\ncatch progress: %d%% | event: %s" % [
		fish_name,
		fish_weight,
		behavior,
		fight_power,
		fish_strength,
		fish_aggression,
		load_kg,
		line_load_ratio * 100.0,
		rod_load_ratio * 100.0,
		roundi(tension * 100.0),
		roundi(green_min * 100.0),
		roundi(green_max * 100.0),
		roundi(critical_break_risk * 100.0),
		roundi(escape_risk * 100.0),
		roundi(rod_durability * 100.0),
		roundi(line_durability * 100.0),
		roundi(hook_durability * 100.0),
		roundi(catch_progress * 100.0),
		struggle_event
	]

	if FishingManager.is_reeling:
		fight_hint_label.text = feedback_message

	var overload_warning: float = max(max(line_load_ratio - 1.0, rod_load_ratio - 1.0), critical_break_risk)
	match status:
		"high":
			if overload_warning > 0.22 or high_danger > 0.55:
				tension_fill.color = Color("#e65f45", 0.82)
				fight_status_label.text = "ОБРЫВ %d%%" % roundi(max(high_danger, critical_break_risk) * 100.0)
			else:
				tension_fill.color = Color("#e0b84b", 0.78)
				fight_status_label.text = "Перегруз %d%%" % roundi(max(line_load_ratio - 1.0, 0.0) * 100.0)
		"low":
			tension_fill.color = Color("#e0b84b", 0.78)
			fight_status_label.text = "Сход %d%%" % roundi(low_danger * 100.0)
		_:
			tension_fill.color = Color("#36c96e", 0.76)
			if FishingManager.is_reeling:
				fight_status_label.text = "Контроль"

func _on_resized() -> void:
	_setup_layout()

func _on_spot_selected(index: int) -> void:
	if _is_catch_reward_open():
		return

	PlayerData.set_current_spot(str(spot_option_button.get_item_metadata(index)))
	var spot := SpotDatabase.get_spot(PlayerData.current_spot)
	result_label.text = "Выбрано: %s\nГлубина: %.1f-%.1f м | снасть %.1f м" % [
		spot["name"],
		float(spot.get("min_depth", spot.get("depth", 0.0))),
		float(spot.get("max_depth", spot.get("depth", 0.0))),
		PlayerData.fishing_depth
	]

	SaveManager.save_game()
	_update_ui()

func _on_fish_button_pressed() -> void:
	if _is_catch_reward_open():
		return

	if _fishing_ui_state == FishingUiState.CAUGHT or _fishing_ui_state == FishingUiState.FAILED:
		_return_to_idle_after_result()
		return

	if _fishing_ui_state != FishingUiState.IDLE:
		return

	var selected_index := spot_option_button.selected
	PlayerData.set_current_spot(str(spot_option_button.get_item_metadata(selected_index)))

	var tackle_block_reason := PlayerData.get_tackle_block_reason()
	if tackle_block_reason != "":
		result_label.text = tackle_block_reason
		_show_toast(tackle_block_reason, false)
		timer_label.text = "Готов к забросу"
		_update_ui()
		return

	if FishingManager.get_bite_candidates(PlayerData.current_spot).is_empty():
		result_label.text = _get_no_bite_candidate_reason(PlayerData.current_spot)
		_show_toast("Поклёвка может быть редкой", false)

	if not PlayerData.consume_current_bait(1):
		result_label.text = "Нет наживки."
		timer_label.text = "Готов к забросу"
		_update_ui()
		return

	basket_panel.visible = false
	basket_backdrop.visible = false
	inventory_panel.visible = false
	inventory_backdrop.visible = false
	tackle_panel.visible = false
	tackle_backdrop.visible = false
	waterbody_panel.visible = false
	waterbody_backdrop.visible = false
	shop_panel.visible = false
	shop_backdrop.visible = false
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
	if _is_catch_reward_open():
		return

	var earned := InventoryManager.sell_all()

	if earned > 0:
		result_label.text = "Рыба продана. Получено: %d мон." % earned
	else:
		result_label.text = "Садок пуст. Продавать пока нечего."

	SaveManager.save_game()
	_update_ui()

	if earned > 0:
		_show_basket_notice("Рыба продана: +%d мон." % earned, true)
	else:
		_show_basket_notice("Садок пуст.", false)

func _on_keepnet_sell_fish_pressed(fish_index: int) -> void:
	if _is_catch_reward_open():
		return

	if fish_index < 0 or fish_index >= InventoryManager.inventory.size():
		_show_basket_notice("Рыба уже продана.", false)
		_update_basket_ui()
		return

	var fish: Dictionary = InventoryManager.inventory[fish_index]
	var price := int(fish.get("price", 0))
	InventoryManager.inventory.remove_at(fish_index)
	PlayerData.money += price
	result_label.text = "Рыба продана: %s +%d мон." % [
		str(fish.get("name", "-")),
		price
	]
	_show_basket_notice("Продано: +%d мон." % price, true)
	SaveManager.save_game()
	_update_ui()

func _on_nav_fish_button_pressed() -> void:
	if _is_catch_reward_open():
		return

	_active_nav_tab = "fish"
	basket_panel.visible = false
	basket_backdrop.visible = false
	inventory_panel.visible = false
	inventory_backdrop.visible = false
	tackle_panel.visible = false
	tackle_backdrop.visible = false
	waterbody_panel.visible = false
	waterbody_backdrop.visible = false
	shop_panel.visible = false
	shop_backdrop.visible = false
	_refresh_bottom_nav_styles()

func _on_basket_button_pressed() -> void:
	if _is_catch_reward_open():
		return

	_active_nav_tab = "sell"
	inventory_panel.visible = false
	inventory_backdrop.visible = false
	tackle_panel.visible = false
	tackle_backdrop.visible = false
	waterbody_panel.visible = false
	waterbody_backdrop.visible = false
	shop_panel.visible = false
	shop_backdrop.visible = false
	waterbody_panel.visible = false
	waterbody_backdrop.visible = false
	basket_backdrop.visible = true
	basket_panel.visible = true
	_show_basket_notice("")
	_update_basket_ui()
	_refresh_bottom_nav_styles()

func _on_basket_close_button_pressed() -> void:
	basket_panel.visible = false
	basket_backdrop.visible = false
	_active_nav_tab = "fish"
	_refresh_bottom_nav_styles()

func _on_inventory_button_pressed() -> void:
	if _is_catch_reward_open():
		return

	_active_nav_tab = "inventory"
	basket_panel.visible = false
	basket_backdrop.visible = false
	tackle_panel.visible = false
	tackle_backdrop.visible = false
	shop_panel.visible = false
	shop_backdrop.visible = false
	waterbody_panel.visible = false
	waterbody_backdrop.visible = false
	inventory_backdrop.visible = true
	inventory_panel.visible = true
	_update_inventory_ui()
	_refresh_bottom_nav_styles()

func _on_tackle_button_pressed() -> void:
	if _is_catch_reward_open():
		return

	_active_nav_tab = "tackle"
	basket_panel.visible = false
	basket_backdrop.visible = false
	shop_panel.visible = false
	shop_backdrop.visible = false
	inventory_panel.visible = false
	inventory_backdrop.visible = false
	waterbody_panel.visible = false
	waterbody_backdrop.visible = false
	tackle_backdrop.visible = true
	tackle_panel.visible = true
	_update_tackle_ui()
	_refresh_bottom_nav_styles()

func _on_shop_button_pressed() -> void:
	if _is_catch_reward_open():
		return

	if shop_button.disabled:
		return

	_active_nav_tab = "shop"
	basket_panel.visible = false
	basket_backdrop.visible = false
	inventory_panel.visible = false
	inventory_backdrop.visible = false
	tackle_panel.visible = false
	tackle_backdrop.visible = false
	waterbody_panel.visible = false
	waterbody_backdrop.visible = false
	shop_backdrop.visible = true
	shop_panel.visible = true
	_update_shop_ui()
	_refresh_bottom_nav_styles()

func _on_map_button_pressed() -> void:
	if _is_catch_reward_open():
		return

	if map_button.disabled:
		return

	_active_nav_tab = "map"
	basket_panel.visible = false
	basket_backdrop.visible = false
	inventory_panel.visible = false
	inventory_backdrop.visible = false
	tackle_panel.visible = false
	tackle_backdrop.visible = false
	shop_panel.visible = false
	shop_backdrop.visible = false
	waterbody_backdrop.visible = true
	waterbody_panel.visible = true
	_selected_waterbody_id = PlayerData.current_waterbody
	_update_waterbody_ui()
	_refresh_bottom_nav_styles()

func _on_bait_button_pressed() -> void:
	if _is_catch_reward_open():
		return

	_active_nav_tab = "inventory"
	_inventory_category = "bait"
	_selected_inventory_item_id = ""
	_on_inventory_button_pressed()

func _on_shop_close_button_pressed() -> void:
	shop_panel.visible = false
	shop_backdrop.visible = false
	_active_nav_tab = "fish"
	_refresh_bottom_nav_styles()

func _on_shop_buy_pressed(item_id: String) -> void:
	var shop_item := _get_shop_item(item_id)

	if shop_item.is_empty():
		return

	var price := int(shop_item.get("price", 0))
	var quantity := int(shop_item.get("quantity", 1))

	if PlayerData.money < price:
		_show_shop_notice("Недостаточно монет", false)
		_play_audio_hook(shop_error_audio)
		_play_shop_card_feedback(item_id, false)
		return

	PlayerData.money -= price
	PlayerData.add_owned_item(_get_shop_inventory_item(shop_item), quantity)

	var purchased_category := str(shop_item.get("category", ""))
	if ["rod", "line", "float", "hook", "bait"].has(purchased_category):
		_tackle_category = purchased_category
		_selected_tackle_item_id = item_id

	SaveManager.save_game()
	_update_ui()
	_update_shop_ui()
	var buy_message := "Куплено: %s" % str(shop_item.get("name", "-"))
	if quantity > 1:
		buy_message += " x%d" % quantity
	_show_shop_notice(buy_message, true)
	_show_toast(buy_message, true)
	_play_audio_hook(shop_buy_audio)
	_play_shop_card_feedback(item_id, true)

func _on_inventory_close_button_pressed() -> void:
	inventory_panel.visible = false
	inventory_backdrop.visible = false
	_active_nav_tab = "fish"
	_refresh_bottom_nav_styles()

func _on_catch_keep_button_pressed() -> void:
	if not _catch_reward_buttons_ready:
		return

	var catch_data := _pending_reward_catch.duplicate(true)
	_pending_reward_catch = {}
	_hide_catch_reward_popup()

	if not catch_data.is_empty():
		result_label.text = "Рыба в садке: %s\nНажми “Вытянуть”, чтобы закончить цикл." % str(catch_data.get("name", "-"))

	SaveManager.save_game()
	_update_ui()

func _on_catch_release_button_pressed() -> void:
	if not _catch_reward_buttons_ready:
		return

	var catch_data := _pending_reward_catch.duplicate(true)
	_pending_reward_catch = {}
	_hide_catch_reward_popup()

	if not catch_data.is_empty() and InventoryManager.remove_fish(catch_data):
		result_label.text = "Рыба отпущена: %s\nXP за поимку сохранён. Нажми “Вытянуть”." % str(catch_data.get("name", "-"))
	else:
		result_label.text = "Рыба отпущена.\nНажми “Вытянуть”, чтобы закончить цикл."

	SaveManager.save_game()
	_update_ui()

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
	_pending_reward_catch = {}
	_hide_catch_reward_popup(false)
	_presence_bite_timer = 0.0
	_presence_caught_timer = 0.0
	_fishing_ui_state = FishingUiState.IDLE
	timer_label.text = "Готов к забросу"
	result_label.text = "Удочка вытянута. Можно забрасывать снова."
	_reset_reeling_ui()
	_update_ui()

func _on_fishing_started(seconds: int) -> void:
	_presence_bite_timer = 0.0
	_presence_caught_timer = 0.0
	_fishing_ui_state = FishingUiState.WAITING
	_reset_reeling_ui()
	timer_label.text = "Клев через: %d сек." % seconds
	fight_status_label.text = "Ожидание поклевки..."
	_update_ui()

func _on_fishing_tick(seconds_left: int) -> void:
	timer_label.text = "Клев через: %d сек." % seconds_left

func _on_reeling_started(catch_data: Dictionary, state: Dictionary) -> void:
	_presence_bite_timer = 0.95
	_presence_caught_timer = 0.0
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
	_presence_bite_timer = 0.0
	_presence_caught_timer = 1.1
	_fishing_ui_state = FishingUiState.CAUGHT
	timer_label.text = "Рыба поймана"

	var xp_result: Dictionary = catch_data.get("xp_result", {})
	var xp_text: String = "\nXP: +%d" % int(xp_result.get("gained_xp", 0))
	var wear_text := _format_tackle_wear_message(catch_data.get("tackle_wear", {}))

	if bool(xp_result.get("leveled_up", false)):
		xp_text += "\nНовый уровень! LVL %d" % int(xp_result.get("level", PlayerData.level))
	if wear_text != "":
		xp_text += "\n%s" % wear_text

	result_label.text = "Поймано: %s\nВес: %.2f кг\nЦена: %d мон.%s\nНажми “Вытянуть удочку”." % [
		catch_data["name"],
		catch_data["weight"],
		catch_data["price"],
		xp_text
	]
	_reset_reeling_ui()
	SaveManager.save_game()
	_update_ui()
	_show_catch_reward_popup(catch_data)

func _on_fishing_failed(message: String) -> void:
	_pending_reward_catch = {}
	_hide_catch_reward_popup(false)
	_presence_bite_timer = 0.0
	_presence_caught_timer = 0.0
	_fishing_ui_state = FishingUiState.FAILED
	timer_label.text = "Неудача"
	result_label.text = "%s\nНажми “Вытянуть удочку”." % message
	_reset_reeling_ui()
	SaveManager.save_game()
	_update_ui()
