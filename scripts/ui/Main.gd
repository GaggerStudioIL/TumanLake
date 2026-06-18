extends Control

const ShopUIScript := preload("res://scripts/ui/ShopUI.gd")
const KeepnetUIScript := preload("res://scripts/ui/KeepnetUI.gd")
const InventoryUIScript := preload("res://scripts/ui/InventoryUI.gd")
const TackleUIScript := preload("res://scripts/ui/TackleUI.gd")
const WaterbodyUIScript := preload("res://scripts/ui/WaterbodyUI.gd")
const CatchPopupUIScript := preload("res://scripts/ui/CatchPopupUI.gd")
const FishingHUDUIScript := preload("res://scripts/ui/FishingHUDUI.gd")
const FishingPresenceUIScript := preload("res://scripts/ui/FishingPresenceUI.gd")
const FloatBitePreviewScene := preload("res://scenes/ui/FloatBitePreview.tscn")
const ProfileUIScript := preload("res://scripts/ui/ProfileUI.gd")
const EncyclopediaUIScript := preload("res://scripts/ui/EncyclopediaUI.gd")
const SystemMenuUIScript := preload("res://scripts/ui/SystemMenuUI.gd")
const FailurePopupUIScript := preload("res://scripts/ui/FailurePopupUI.gd")
const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const MobileScrollHelperScript := preload("res://scripts/ui/MobileScrollHelper.gd")
const KeepnetHudButtonScript := preload("res://scripts/ui/components/KeepnetHudButton.gd")
const PlayerXpHudScript := preload("res://scripts/ui/components/PlayerXpHud.gd")
const TumanFmHudScript := preload("res://scripts/ui/components/TumanFmHud.gd")
const FloatDepthRadialControlScript := preload("res://scripts/ui/components/FloatDepthRadialControl.gd")
const QuickTacklePanelScript := preload("res://scripts/ui/components/QuickTacklePanel.gd")
const MainHUDControllerScript := preload("res://scripts/ui/controllers/MainHUDController.gd")
const PopupManagerScript := preload("res://scripts/ui/controllers/PopupManager.gd")
const CatchPopupControllerScript := preload("res://scripts/ui/controllers/CatchPopupController.gd")
const CatchResultHandlerScript := preload("res://scripts/gameplay/handlers/CatchResultHandler.gd")
const WeatherEffectsControllerScript := preload("res://scripts/environment/WeatherEffectsController.gd")
const AmbientVoicesControllerScript := preload("res://scripts/environment/AmbientVoicesController.gd")
const WeatherUIHelperScript := preload("res://scripts/ui/helpers/WeatherUIHelper.gd")
const NAVIGATION_CONTROLLER_PATH := "res://scripts/ui/controllers/NavigationController.gd"
const SIDE_MENU_CONTROLLER_PATH := "res://scripts/ui/controllers/SideMenuController.gd"
const FishHarborScene := preload("res://scenes/economy/FishHarbor.tscn")
const TUMAN_LAKE_THEME := preload("res://themes/TumanLakeUI.tres")
const DEPTH_HOOK_ICON := preload("res://assets/ui/icons/icon_depth_hook.png")
const WIND_HUD_ICON_PATH := "res://assets/ui/icons/wind.png"
const CONDITION_HEALTH_ICON := preload("res://assets/ui/icons/hud/condition_health.png")
const CONDITION_TEMPERATURE_ICON := preload("res://assets/ui/icons/hud/condition_temperature.png")
const CONDITION_HUNGER_ICON := preload("res://assets/ui/icons/hud/condition_hunger.png")

const STYLE_HUD_PANEL := "HUDPanel"
const STYLE_INFO_CARD := "InfoCard"
const STYLE_PRIMARY_BUTTON := "PrimaryButton"
const STYLE_SECONDARY_BUTTON := "SecondaryButton"
const STYLE_BOTTOM_NAV_BUTTON := "BottomNavButton"
const STYLE_BOTTOM_NAV_ACTIVE := "BottomNavActive"
const BASE_SCREEN_SIZE := Vector2(960.0, 540.0)
const HUD_HEIGHT := 44.0
const LEFT_NAV_WIDTH := 58.0
const LEFT_NAV_HEIGHT := 222.0
const ACTION_BAR_HEIGHT := 46.0
const HUD_GLASS_RADIUS := 14
const HUD_GLASS_BORDER_WIDTH := 1
const MENU_BACKDROP_Z := 300
const MENU_PANEL_Z := 301
const PILOT_WATER_SPOT_ID := "old_oak_pier"
const PILOT_WATER_MASK_ID := "old_oak_pier_lake"
const SPOT_BACKGROUND_LAYER_Z := -110
const SPOT_WATER_LAYER_Z := -13
const SPOT_FOREGROUND_LAYER_Z := -10
const MODAL_TAP_GUARD_MSEC := 320
const LEVEL_UP_MODAL_NAME := "level_up_reward"
const WATER_SURFACE_Y := 402.0
const FLOAT_DEFAULT_POS := Vector2(500.0, 402.0)
const ROD_ANCHOR_POS := Vector2(610.0, 562.0)
const ROD_TARGET_POS := Vector2(480.0, 210.0)
const CAST_CONTROL_CENTER_BASE := Vector2(720.0, 280.0)
const CAST_CHARGE_TIME := 1.5
const CURRENT_TACKLE_LONG_PRESS_MSEC := 560
const MIN_CAST_POWER := 0.05
const MAX_CAST_POWER := 1.0
const MIN_SHORE_DEPTH := 0.16
const DEPTH_TOLERANCE := 0.05
const ALPHA_TESTER_BONUS_MONEY := 5000.0
const ALPHA_TESTER_BONUS_MESSAGE := "Привет альфа тестер, для удобного теста мы даем тебе 5000 монет."
const FIRST_RUN_HINT_TEXTS := {
	"choose_spot": "Выберите точку ловли на карте",
	"cast": "Нажмите Заброс",
	"wait_bite": "Дождитесь поклёвки",
	"hook": "Подсеките рыбу",
	"sell_fish": "Рыба в садке. Её можно продать"
}

@onready var background: ColorRect = $Background
@onready var scene_gradient: ColorRect = $SceneGradient
@onready var noise_layer: ColorRect = $NoiseLayer
@onready var sun_glow_layer: ColorRect = $SunGlowLayer
@onready var far_forest_layer: ColorRect = $FarForestLayer
@onready var mid_forest_layer: ColorRect = $MidForestLayer
@onready var lake_layer: ColorRect = $LakeLayer
@onready var reflection_layer: ColorRect = $ReflectionLayer
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
# TODO: `bottom_nav_*` is legacy naming. The nodes now render the left vertical menu;
# rename scene nodes and references in one dedicated UI pass to keep this change small.
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
var category_food_button: Button
var category_clothing_button: Button
@onready var inventory_details_card: ColorRect = $InventoryPanel/InventoryDetailsCard
@onready var inventory_tackle_card: ColorRect = $InventoryPanel/InventoryTackleCard
@onready var inventory_item_list: ItemList = $InventoryPanel/InventoryItemList
@onready var inventory_details_label: Label = $InventoryPanel/InventoryDetailsLabel
@onready var inventory_tackle_label: Label = $InventoryPanel/InventoryTackleLabel
@onready var inventory_equip_button: Button = $InventoryPanel/InventoryEquipButton
@onready var inventory_close_button: Button = $InventoryPanel/InventoryCloseButton
var inventory_repair_button: Button
var inventory_discard_button: Button
var inventory_prev_page_button: Button
var inventory_next_page_button: Button
var inventory_page_label: Label
var inventory_tiles_scroll: ScrollContainer
var inventory_tiles_container: Control
var inventory_empty_label: Label
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
var shop_clothing_category_button: Button
var shop_tackle_category_button: Button
var shop_line_category_button: Button
var shop_leader_category_button: Button
var shop_hook_category_button: Button
var shop_float_category_button: Button
var shop_items_scroll: ScrollContainer
var shop_items_container: Control
var shop_notice_label: Label
var shop_close_button: Button
var shop_prev_page_button: Button
var shop_next_page_button: Button
var shop_page_label: Label
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
var tackle_left_panel: Panel
var tackle_center_panel: Panel
var tackle_right_panel: Panel
var tackle_action_bar_panel: Panel
var tackle_rod_stats_panel: Panel
var tackle_rod_description_panel: Panel
var tackle_final_stats_panel: Panel
var tackle_status_panel: Panel
var tackle_title_divider_left: ColorRect
var tackle_title_divider_right: ColorRect
var tackle_title_label: Label
var tackle_current_label: Label
var tackle_rod_name_label: Label
var tackle_rod_meta_label: Label
var tackle_picker_title_label: Label
var tackle_visual_title_label: Label
var tackle_visual_rod_line: Line2D
var tackle_visual_main_line: Line2D
var tackle_visual_leader_line: Line2D
var tackle_visual_float_marker: ColorRect
var tackle_visual_hook_marker: Label
var tackle_visual_bait_marker: Label
var tackle_visual_bait_2_marker: Label
var tackle_visual_line_label: Label
var tackle_visual_float_label: Label
var tackle_visual_leader_label: Label
var tackle_visual_hook_label: Label
var tackle_visual_bait_label: Label
var tackle_visual_bait_2_label: Label
var tackle_slot_scroll: ScrollContainer
var tackle_slot_list: VBoxContainer
var tackle_slot_buttons: Dictionary = {}
var tackle_item_list: ItemList
var tackle_details_label: Label
var tackle_compare_label: Label
var tackle_depth_label: Label
var tackle_depth_minus_button: Button
var tackle_depth_plus_button: Button
var tackle_hint_label: Label
var tackle_rod_button: Button
var tackle_line_button: Button
var tackle_leader_button: Button
var tackle_float_button: Button
var tackle_hook_button: Button
var tackle_bait_button: Button
var tackle_bait_2_button: Button
var tackle_info_button: Button
var tackle_clear_button: Button
var tackle_auto_button: Button
var tackle_equip_button: Button
var tackle_repair_button: Button
var tackle_discard_button: Button
var tackle_close_button: Button
var tackle_prev_page_button: Button
var tackle_next_page_button: Button
var tackle_page_label: Label
var discard_confirm_dialog: ConfirmationDialog
var _pending_discard_item_id := ""
var _pending_discard_source := ""
var waterbody_backdrop: ColorRect
var waterbody_panel: Panel
var waterbody_title_label: Label
var waterbody_item_list: ItemList
var waterbody_preview_frame: Panel
var waterbody_preview: TextureRect
var waterbody_details_label: Label
var waterbody_spot_list: ItemList
var waterbody_spot_details_label: Label
var waterbody_select_button: Button
var waterbody_close_button: Button
var waterbody_spot_prev_page_button: Button
var waterbody_spot_next_page_button: Button
var waterbody_spot_page_label: Label
var waterbody_spot_buttons: Array = []
var level_up_backdrop: ColorRect
var level_up_panel: Panel
var level_up_title_label: Label
var level_up_level_label: Label
var level_up_unlocks_label: Label
var level_up_rewards_label: Label
var level_up_warning_label: Label
var level_up_confirm_button: Button
var toast_label: Label
var main_hud_controller
var popup_manager
var navigation_controller
var side_menu_controller
var catch_popup_controller
var catch_result_handler
var weather_effects_controller: Node
var ambient_voices_controller: Node
var shop_ui
var keepnet_ui
var inventory_ui
var tackle_ui
var waterbody_ui
var catch_popup_ui
var fishing_hud_ui
var fishing_presence_ui
var float_bite_preview: Control
var profile_ui
var encyclopedia_ui
var system_menu_ui
var failure_popup_ui
var mobile_scroll_helper
var fish_harbor_ui: Control
var ui_theme
var ui_canvas_layer: CanvasLayer
var modal_canvas_layer: CanvasLayer
var modal_content_root: Control
var modal_input_shield: ColorRect
var is_modal_open := false
var _current_modal_name := ""
var cast_button_visual: TextureRect
var cast_power_indicator_track: Panel
var cast_power_indicator_fill: ColorRect
var stop_fishing_button: Button
var depth_hud_minus_button: Button
var depth_hud_plus_button: Button
var depth_hud_label: Label
var depth_radial_control: FloatDepthRadialControl
var keepnet_hud_button: Button
var player_xp_hud: Control
var quick_tackle_panel: Control
var tuman_fm_hud: Control
var rod_sprite: Sprite2D
var rod_shadow_sprite: Sprite2D
var top_hud_container: HBoxContainer
var top_hud_spacer: Control
var top_hud_money_group: HBoxContainer
var top_hud_time_group: HBoxContainer
var top_hud_temperature_group: HBoxContainer
var top_hud_wind_group: HBoxContainer
var quick_actions_container: VBoxContainer
var bottom_nav_container: VBoxContainer
var encyclopedia_button: Button
var harbor_button: Button
var current_tackle_button: Button
var current_tackle_popup: Panel
var current_tackle_popup_box: VBoxContainer
var environment_layer: Node2D
var environment_sprites: Dictionary = {}
var day_night_controller: Node2D
var water_animation_layer: Control
var spot_visual_root: Control
var spot_background_layer: Control
var spot_water_layer: Control
var spot_foreground_layer: Control
var spot_cutout_rect: TextureRect
var time_hud_panel: Panel
var weather_hud_row: HBoxContainer
var weather_hud_panel: Panel
var money_hud_icon: TextureRect
var time_hud_icon: TextureRect
var weather_hud_icon: TextureRect
var wind_hud_icon: TextureRect
var wind_label: Label
var condition_hud_card: Panel
var condition_hud_group: VBoxContainer
var condition_health_row: HBoxContainer
var condition_temperature_row: HBoxContainer
var condition_hunger_row: HBoxContainer
var condition_health_icon: TextureRect
var condition_temperature_icon: TextureRect
var condition_hunger_icon: TextureRect
var condition_health_label: Label
var condition_temperature_label: Label
var condition_hunger_label: Label
var lake_bg_base_rect: TextureRect
var lake_bg_foreground_rect: TextureRect
var water_overlay_rect: TextureRect
var time_color_overlay: ColorRect
var time_celestial_overlay: ColorRect
var time_stars_overlay: ColorRect
var time_vignette_overlay: ColorRect
var _wind_hud_texture: Texture2D

enum FishingUiState {
	IDLE,
	WAITING,
	FIGHTING,
	CAUGHT,
	FAILED
}

var _fishing_ui_state: int = FishingUiState.IDLE
var is_cast_animating := false
var _pending_cast_spot_id := ""
var _pending_cast_valid := true
var _pending_cast_depth_context: Dictionary = {}
var _active_nav_tab: String = "fish"
var _inventory_category: String = "all"
var _inventory_page: int = 0
var _visible_inventory_items: Array = []
var _selected_inventory_item_id: String = ""
var _tackle_category: String = "rod"
var _tackle_page: int = 0
var _visible_tackle_items: Array = []
var _selected_tackle_item_id: String = ""
var _visible_waterbodies: Array = []
var _selected_waterbody_id: String = ""
var _waterbody_spot_page: int = 0
var _visible_waterbody_spots: Array = []
var _selected_waterbody_spot_id: String = ""
var _map_return_screen_id := ""
var _map_return_waterbody_id := ""
var _map_return_spot_id := ""
var _pending_reward_catch: Dictionary = {}
var _level_up_reward_queue: Array = []
var _current_level_up_reward: Dictionary = {}
var _level_up_popup_tween: Tween
var _catch_popup_tween: Tween
var _catch_fish_tween: Tween
var _fish_reward_atlas: Texture2D
var _small_fish_atlas: Texture2D
var _catch_fish_base_position := Vector2.ZERO
var _catch_shadow_base_position := Vector2.ZERO
var _catch_reward_buttons_ready := false
var _catch_reward_unlock_after_msec := 0
var _shop_category: String = "bait"
var _shop_page: int = 0
var _shop_card_nodes: Dictionary = {}
var _shop_feedback_tween: Tween
var _presence_time := 0.0
var _presence_bite_timer := 0.0
var _presence_caught_timer := 0.0
var _presence_has_layout := false
var _cast_button_hovered := false
var _cast_button_pressed := false
var _cast_charge_active := false
var _cast_charge_hold_time := 0.0
var _cast_charge_power := MIN_CAST_POWER
var _cast_release_action_guard_msec := 0
var _fish_button_action_guard_msec := 0
var _fish_button_pointer_action_active := false
var _current_tackle_press_started_msec := 0
var _current_tackle_long_press_triggered := false
var _modal_tap_guard_until_msec := 0
var _use_cast_png_button := false
var _use_pull_png_button := false
var _float_base_center := Vector2.ZERO
var _float_visual_center := Vector2.ZERO
var _rod_tip_visual := Vector2.ZERO
var _rod_bend_direction_visual := Vector2.DOWN
var _rod_bend_amount_visual := 3.0
var _water_surface_y := 0.0
var _water_zone_top := 0.0
var _water_zone_bottom := 0.0
var _last_water_animation_log_key := ""
var _rod_anchor_pos := Vector2.ZERO
var _rod_target_pos := Vector2.ZERO
var _depth_hud_refresh_queued := false
var _depth_hud_visibility_check_accumulator := 0.0
var _last_detailed_failure_msec := -100000
var _first_run_hints_active := false
var _first_run_hints_shown: Dictionary = {}
var reeling_panel_frame: Panel
var tension_slack_zone: ColorRect
var tension_warning_zone: ColorRect
var tension_critical_zone: ColorRect
var tension_marker_glow: ColorRect
var _last_reeling_visual_key := ""

var _last_reeling_state := {
	"fish_name": "-",
	"fish_weight": 0.0,
	"fight_mode": "pole",
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
	"reel_handle_speed": 0.0,
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
	if BuildConfig.ENABLE_VERBOSE_LOGS:
		print("%s: Main scene loaded" % BuildConfig.PUBLIC_GAME_NAME)
	_play_main_ambient()

	theme = TUMAN_LAKE_THEME
	SaveManager.load_game()
	_setup_ui_controllers()
	_ensure_ui_canvas_layer()
	_ensure_float_bite_preview()
	_ensure_tuman_fm_hud()
	_ensure_system_menu_ui()
	_ensure_fish_harbor_ui()
	failure_popup_ui.setup(self)
	profile_ui.setup(self)
	encyclopedia_ui.setup(self)
	_ensure_gameplay_layer_names()

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
	_grant_alpha_tester_bonus_if_needed()
	_ensure_mobile_scroll_helper()
	_first_run_hints_active = _should_show_first_run_hints()
	if _first_run_hints_active:
		call_deferred("_show_first_run_hint", "choose_spot")

func _process(delta: float) -> void:
	_update_fishing_presence(delta)
	_update_cast_charge(delta)
	_update_catch_reward_input_lock()
	_update_modal_tap_guard()
	_update_time_hud()
	_refresh_condition_hud()
	_update_depth_hud_visibility_watchdog(delta)
	_update_current_tackle_hold()
	_refresh_float_bite_preview_visibility()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED:
		call_deferred("_refresh_after_application_resumed")

func _refresh_after_application_resumed() -> void:
	if InventoryManager.has_method("ensure_inventory_freshness_metadata"):
		InventoryManager.ensure_inventory_freshness_metadata()
	_update_keepnet_hud_button(false)
	if keepnet_ui != null and keepnet_ui.has_method("is_open") and bool(keepnet_ui.call("is_open")):
		_update_basket_ui()
	if fish_harbor_ui != null and fish_harbor_ui.visible and fish_harbor_ui.has_method("refresh"):
		fish_harbor_ui.refresh()
	if inventory_panel != null and inventory_panel.visible:
		_update_inventory_ui()
	if quick_tackle_panel != null:
		if quick_tackle_panel.has_method("refresh"):
			quick_tackle_panel.call("refresh")
	_refresh_current_tackle_hud()

func _input(event: InputEvent) -> void:
	if is_modal_open or _is_modal_tap_guard_active():
		return

	if _is_depth_radial_pointer_event(event):
		return

	if _cast_charge_active and _is_cast_charge_release_event(event):
		_cast_button_pressed = false
		_update_cast_button_visual()
		_on_reel_button_up()
		get_viewport().set_input_as_handled()
		return

	if not _is_fish_button_pointer_event(event):
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event.pressed:
		_cast_button_pressed = true
		_update_cast_button_visual()
		_on_reel_button_down()
		if not _cast_charge_active and not fish_button.disabled:
			_fish_button_pointer_action_active = true
			_trigger_fish_button_action(true)
	else:
		_cast_button_pressed = false
		_update_cast_button_visual()
		_on_reel_button_up()
		call_deferred("_clear_fish_button_pointer_action_active")

	get_viewport().set_input_as_handled()

func _is_cast_charge_release_event(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		return mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed
	if event is InputEventScreenTouch:
		return not (event as InputEventScreenTouch).pressed
	return false

func _unhandled_input(event: InputEvent) -> void:
	if system_menu_ui != null and system_menu_ui.is_menu_open() and event.is_action_pressed("ui_cancel"):
		system_menu_ui.close_menu()
		get_viewport().set_input_as_handled()
		return

	if not is_modal_open:
		return
	if event.is_action_pressed("ui_cancel"):
		if _block_pending_catch_reward_close_attempt():
			get_viewport().set_input_as_handled()
			return
		if _block_level_up_reward_close_attempt():
			get_viewport().set_input_as_handled()
			return
		close_current_modal()
		get_viewport().set_input_as_handled()

func _setup_ui_controllers() -> void:
	ui_theme = UIThemeScript.new()
	main_hud_controller = MainHUDControllerScript.new()
	popup_manager = PopupManagerScript.new()
	catch_popup_controller = CatchPopupControllerScript.new()
	catch_result_handler = CatchResultHandlerScript.new()
	weather_effects_controller = WeatherEffectsControllerScript.new()
	weather_effects_controller.name = "WeatherEffectsController"
	add_child(weather_effects_controller)
	ambient_voices_controller = AmbientVoicesControllerScript.new()
	ambient_voices_controller.name = "AmbientVoicesController"
	add_child(ambient_voices_controller)
	navigation_controller = load(NAVIGATION_CONTROLLER_PATH).new()
	side_menu_controller = load(SIDE_MENU_CONTROLLER_PATH).new()
	shop_ui = ShopUIScript.new()
	keepnet_ui = KeepnetUIScript.new()
	inventory_ui = InventoryUIScript.new()
	tackle_ui = TackleUIScript.new()
	waterbody_ui = WaterbodyUIScript.new()
	catch_popup_ui = CatchPopupUIScript.new()
	fishing_hud_ui = FishingHUDUIScript.new()
	fishing_presence_ui = FishingPresenceUIScript.new()
	quick_tackle_panel = QuickTacklePanelScript.new()
	quick_tackle_panel.name = "QuickTacklePanel"
	profile_ui = ProfileUIScript.new()
	encyclopedia_ui = EncyclopediaUIScript.new()
	system_menu_ui = SystemMenuUIScript.new()
	failure_popup_ui = FailurePopupUIScript.new()

	encyclopedia_button = Button.new()
	encyclopedia_button.name = "EncyclopediaButton"
	encyclopedia_button.text = "Атлас рыб"
	encyclopedia_button.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(encyclopedia_button)

	harbor_button = Button.new()
	harbor_button.name = "HarborButton"
	harbor_button.text = "Гавань"
	harbor_button.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(harbor_button)

	_ensure_current_tackle_hud_nodes()

	main_hud_controller.setup(self, self)
	popup_manager.setup(self)
	navigation_controller.setup(self)
	side_menu_controller.setup(self, navigation_controller, false)
	shop_ui.setup(self)
	keepnet_ui.setup(self)
	inventory_ui.setup(self)
	tackle_ui.setup(self)
	waterbody_ui.setup(self)
	catch_popup_controller.setup(self, catch_popup_ui)
	weather_effects_controller.setup(self)
	ambient_voices_controller.setup(self)
	fishing_hud_ui.setup(self)
	fishing_presence_ui.setup(self)
	if quick_tackle_panel.has_method("setup"):
		quick_tackle_panel.call("setup", self)
	fishing_presence_ui.cast_visual_finished.connect(_on_cast_visual_finished)

	shop_ui.buy_requested.connect(_on_shop_buy_pressed)
	keepnet_ui.sell_fish_requested.connect(_on_keepnet_sell_fish_pressed)
	catch_popup_controller.keep_requested.connect(_on_catch_keep_button_pressed)
	catch_popup_controller.release_requested.connect(_on_catch_release_button_pressed)

func _ensure_spot_visual_layers() -> void:
	_disable_failed_live_water_layers()

func _disable_failed_live_water_layers() -> void:
	if day_night_controller != null:
		if day_night_controller.get_parent() != self:
			_reparent_node(day_night_controller, self)
		day_night_controller.visible = true

	for layer in [
		water_animation_layer,
		spot_cutout_rect,
		spot_water_layer,
		spot_foreground_layer,
		spot_background_layer,
		spot_visual_root
	]:
		if layer == null:
			continue
		layer.visible = false
		if layer is Control:
			(layer as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		if layer.has_method("set_process"):
			layer.set_process(false)

	var legacy_layer := get_node_or_null("WaterLiveLayer") as Control
	if legacy_layer != null:
		if legacy_layer.has_method("set_water_profile"):
			legacy_layer.call("set_water_profile", "disabled")
		legacy_layer.visible = false
		legacy_layer.set_process(false)

func _ensure_spot_visual_layer(layer: Control, layer_name: String, z: int) -> Control:
	if layer == null:
		layer = Control.new()
		layer.name = layer_name
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		spot_visual_root.add_child(layer)

	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.offset_left = 0.0
	layer.offset_top = 0.0
	layer.offset_right = 0.0
	layer.offset_bottom = 0.0
	layer.z_as_relative = false
	layer.z_index = z
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return layer

func _layout_spot_visual_layers(_screen_size: Vector2) -> void:
	_disable_failed_live_water_layers()

func _attach_environment_background_to_spot_layer() -> void:
	if day_night_controller == null or spot_background_layer == null:
		return
	if day_night_controller.get_parent() == spot_background_layer:
		return

	_reparent_node(day_night_controller, spot_background_layer)

func _get_current_spot_visual_layer_config() -> Dictionary:
	var spot := SpotDatabase.get_spot(PlayerData.current_spot)
	var raw_layers = spot.get("visual_layers", {})
	if raw_layers is Dictionary:
		return (raw_layers as Dictionary).duplicate(true)
	return {}

func _apply_current_spot_visual_layers() -> void:
	_disable_failed_live_water_layers()

func _uses_current_spot_cutout_pipeline() -> bool:
	if not _is_water_animation_pilot_spot():
		return false

	var visual_layers := _get_current_spot_visual_layer_config()
	var cutout_path := _get_spot_visual_layer_asset_path(visual_layers, [
		"background_without_water",
		"foreground_overlay",
		"foreground_asset",
		"foreground"
	])
	return cutout_path != "" and ResourceLoader.exists(cutout_path)

func _ensure_spot_cutout_rect() -> void:
	if spot_foreground_layer == null:
		return
	if spot_cutout_rect == null:
		spot_cutout_rect = TextureRect.new()
		spot_cutout_rect.name = "SpotCutoutLayer"
		spot_cutout_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		spot_cutout_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		spot_cutout_rect.stretch_mode = TextureRect.STRETCH_SCALE
		spot_cutout_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		spot_cutout_rect.z_as_relative = true
		spot_cutout_rect.z_index = 0
		spot_foreground_layer.add_child(spot_cutout_rect)

	spot_cutout_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	spot_cutout_rect.offset_left = 0.0
	spot_cutout_rect.offset_top = 0.0
	spot_cutout_rect.offset_right = 0.0
	spot_cutout_rect.offset_bottom = 0.0
	spot_cutout_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _load_spot_visual_texture(path: String) -> Texture2D:
	if path == "" or path == "procedural" or not ResourceLoader.exists(path):
		return null

	var resource := load(path)
	if resource is Texture2D:
		return resource as Texture2D
	return null

func _ensure_water_animation_layer() -> void:
	_disable_failed_live_water_layers()

func _disable_legacy_water_live_layer() -> void:
	var legacy_layer := get_node_or_null("WaterLiveLayer") as Control
	if legacy_layer == null:
		return

	if legacy_layer.has_method("set_water_profile"):
		legacy_layer.call("set_water_profile", "disabled")
	legacy_layer.visible = false
	legacy_layer.set_process(false)

func _update_water_animation_layer_z() -> void:
	if water_animation_layer == null:
		return

	water_animation_layer.z_as_relative = true
	water_animation_layer.z_index = 0

func _apply_water_debug_visuals() -> void:
	if water_animation_layer == null:
		return

	if water_animation_layer.has_method("set_debug_visuals"):
		water_animation_layer.call("set_debug_visuals", BuildConfig.ENABLE_WATER_DEBUG_VISUALS)

func _apply_water_surface_visibility() -> void:
	if water_animation_layer == null:
		return

	if water_animation_layer.has_method("set_surface_visible"):
		water_animation_layer.call("set_surface_visible", _should_show_current_water_surface())

func _apply_water_alpha_mask_texture() -> void:
	if water_animation_layer == null:
		return

	var texture: Texture2D = null
	var mask_path := _get_current_water_alpha_mask_asset_path()
	if mask_path != "":
		texture = _load_spot_visual_texture(mask_path)
	if water_animation_layer.has_method("set_alpha_mask_texture"):
		water_animation_layer.call("set_alpha_mask_texture", texture)

func _should_show_current_water_surface() -> bool:
	if not _is_water_animation_pilot_spot():
		return false

	var visual_layers := _get_current_spot_visual_layer_config()
	if not bool(visual_layers.get("enable_live_water_surface", false)):
		return false

	return _uses_current_spot_cutout_pipeline() and _get_current_water_alpha_mask_asset_path() != ""

func _get_current_water_alpha_mask_asset_path() -> String:
	if not _is_water_animation_pilot_spot():
		return ""

	var visual_layers := _get_current_spot_visual_layer_config()
	var mask_path := _get_spot_visual_layer_asset_path(visual_layers, [
		"water_mask_asset",
		"background_without_water",
		"foreground_overlay",
		"foreground_asset",
		"foreground"
	])
	if mask_path != "" and ResourceLoader.exists(mask_path):
		return mask_path
	return ""

func _get_spot_visual_layer_asset_path(visual_layers: Dictionary, keys: Array) -> String:
	for key in keys:
		var path := str(visual_layers.get(str(key), "")).strip_edges()
		if path != "":
			return path
	return ""

func _get_current_water_profile_id() -> String:
	if not _is_water_animation_pilot_spot():
		return "disabled"

	var spot := SpotDatabase.get_spot(PlayerData.current_spot)
	var visual_layers := _get_current_spot_visual_layer_config()
	var layer_profile := str(visual_layers.get("water_profile", "")).strip_edges()
	if layer_profile != "":
		return layer_profile
	return str(spot.get("water_profile", "calm_pier"))

func _get_current_water_mask_id() -> String:
	var spot := SpotDatabase.get_spot(PlayerData.current_spot)
	var visual_layers := _get_current_spot_visual_layer_config()
	var layer_mask := str(visual_layers.get("water_mask", "")).strip_edges()
	if layer_mask != "":
		return layer_mask
	if _is_water_animation_pilot_spot():
		return PILOT_WATER_MASK_ID
	return str(spot.get("water_mask", "default_lake"))

func _is_water_animation_pilot_spot() -> bool:
	if str(PlayerData.current_spot) != PILOT_WATER_SPOT_ID:
		return false

	var spot := SpotDatabase.get_spot(PlayerData.current_spot)
	return bool(spot.get("water_visual_pilot", false))

func _set_water_animation_enabled(value: bool) -> void:
	if water_animation_layer == null:
		return

	if water_animation_layer.has_method("set_enabled"):
		water_animation_layer.call("set_enabled", value)
	else:
		water_animation_layer.visible = value
		water_animation_layer.set_process(value)

func _apply_current_water_profile() -> void:
	_disable_failed_live_water_layers()

func _layout_water_animation_layer(_screen_size: Vector2) -> void:
	_disable_failed_live_water_layers()

func _get_safe_water_animation_rect(screen_size: Vector2) -> Rect2:
	if screen_size.x <= 1.0 or screen_size.y <= 1.0:
		return Rect2(Vector2.ZERO, Vector2.ZERO)

	if _is_water_animation_pilot_spot():
		if _get_current_water_alpha_mask_asset_path() != "":
			return Rect2(Vector2.ZERO, screen_size)
		return _get_old_oak_pier_water_rect(screen_size)

	var water_top := _water_zone_top
	var water_bottom := _water_zone_bottom
	if water_top <= 0.0 or water_bottom <= water_top:
		water_top = screen_size.y * 0.52
		water_bottom = screen_size.y * 0.88

	var horizontal_padding := clampf(screen_size.x * 0.025, 12.0, 36.0)
	var rect_top := clampf(water_top - screen_size.y * 0.08, screen_size.y * 0.42, screen_size.y * 0.66)
	var rect_bottom := minf(water_bottom + screen_size.y * 0.16, screen_size.y * 0.93)
	var min_height := maxf(130.0, screen_size.y * 0.24)
	if rect_bottom <= rect_top + min_height:
		rect_bottom = minf(rect_top + min_height, screen_size.y * 0.93)

	return Rect2(
		Vector2(horizontal_padding, rect_top),
		Vector2(maxf(screen_size.x - horizontal_padding * 2.0, 1.0), maxf(rect_bottom - rect_top, 1.0))
	)

func _get_old_oak_pier_water_rect(screen_size: Vector2) -> Rect2:
	return Rect2(
		Vector2(0.0, screen_size.y * 0.34),
		Vector2(screen_size.x, screen_size.y * 0.60)
	)

func _get_water_animation_area(rect: Rect2) -> Dictionary:
	var mask_id := _get_current_water_mask_id()
	var polygons := [_get_full_water_layer_polygon(rect.size)] if _get_current_water_alpha_mask_asset_path() != "" else _get_water_mask_polygons(mask_id, rect.size)
	return {
		"mask_id": mask_id,
		"rect": rect,
		"polygon": polygons[0] if not polygons.is_empty() else PackedVector2Array(),
		"polygons": polygons
	}

func _get_full_water_layer_polygon(rect_size: Vector2) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2.ZERO,
		Vector2(rect_size.x, 0.0),
		rect_size,
		Vector2(0.0, rect_size.y)
	])

func _get_water_mask_polygons(mask_id: String, rect_size: Vector2) -> Array[PackedVector2Array]:
	if rect_size.x <= 1.0 or rect_size.y <= 1.0:
		return []

	match mask_id:
		PILOT_WATER_MASK_ID:
			return _get_old_oak_pier_water_polygons(rect_size)
		_:
			return [_get_water_mask_polygon(mask_id, rect_size)]

func _get_water_mask_polygon(mask_id: String, rect_size: Vector2) -> PackedVector2Array:
	if rect_size.x <= 1.0 or rect_size.y <= 1.0:
		return PackedVector2Array()

	match mask_id:
		"default_lake":
			return PackedVector2Array([
				Vector2(0.0, rect_size.y * 0.22),
				Vector2(rect_size.x * 0.18, rect_size.y * 0.15),
				Vector2(rect_size.x * 0.48, rect_size.y * 0.10),
				Vector2(rect_size.x * 0.80, rect_size.y * 0.14),
				Vector2(rect_size.x, rect_size.y * 0.24),
				Vector2(rect_size.x, rect_size.y),
				Vector2(0.0, rect_size.y)
			])
		_:
			return PackedVector2Array([
				Vector2(0.0, rect_size.y * 0.22),
				Vector2(rect_size.x * 0.18, rect_size.y * 0.15),
				Vector2(rect_size.x * 0.48, rect_size.y * 0.10),
				Vector2(rect_size.x * 0.80, rect_size.y * 0.14),
				Vector2(rect_size.x, rect_size.y * 0.24),
				Vector2(rect_size.x, rect_size.y),
				Vector2(0.0, rect_size.y)
			])

func _get_old_oak_pier_water_polygons(rect_size: Vector2) -> Array[PackedVector2Array]:
	return [
		_make_scaled_polygon(rect_size, [
			Vector2(0.47, 0.05),
			Vector2(0.66, 0.05),
			Vector2(0.82, 0.10),
			Vector2(0.95, 0.24),
			Vector2(0.995, 0.54),
			Vector2(0.94, 0.88),
			Vector2(0.72, 0.99),
			Vector2(0.50, 0.95),
			Vector2(0.40, 0.72),
			Vector2(0.40, 0.45),
			Vector2(0.45, 0.22)
		]),
		_make_scaled_polygon(rect_size, [
			Vector2(0.00, 0.48),
			Vector2(0.15, 0.42),
			Vector2(0.29, 0.42),
			Vector2(0.38, 0.55),
			Vector2(0.47, 0.94),
			Vector2(0.22, 0.98),
			Vector2(0.03, 0.86),
			Vector2(0.00, 0.66)
		]),
		_make_scaled_polygon(rect_size, [
			Vector2(0.23, 0.20),
			Vector2(0.33, 0.12),
			Vector2(0.43, 0.13),
			Vector2(0.42, 0.25),
			Vector2(0.32, 0.30),
			Vector2(0.22, 0.28)
		])
	]

func _make_scaled_polygon(rect_size: Vector2, normalized_points: Array) -> PackedVector2Array:
	var points := PackedVector2Array()
	for point in normalized_points:
		var normalized: Vector2 = point
		points.append(Vector2(normalized.x * rect_size.x, normalized.y * rect_size.y))
	return points

func _log_water_animation_state() -> void:
	if not BuildConfig.ENABLE_VERBOSE_LOGS or water_animation_layer == null:
		return

	var profile_id := ""
	if water_animation_layer.has_method("get_water_profile"):
		profile_id = str(water_animation_layer.call("get_water_profile"))
	else:
		profile_id = _get_current_water_profile_id()
	var rect := Rect2(water_animation_layer.position, water_animation_layer.size)
	var key: String = "%s|%s|%s|%s|%s|%s" % [
		profile_id,
		rect,
		water_animation_layer.visible,
		water_animation_layer.z_index,
		water_animation_layer.mouse_filter,
		water_animation_layer.is_processing()
	]
	if key == _last_water_animation_log_key:
		return

	_last_water_animation_log_key = key
	print("WaterAnimationLayer state profile_id=%s rect=%s size=%s visible=%s z=%s mouse_ignore=%s processing=%s debug=%s" % [
		profile_id,
		rect,
		water_animation_layer.size,
		water_animation_layer.visible,
		water_animation_layer.z_index,
		water_animation_layer.mouse_filter == Control.MOUSE_FILTER_IGNORE,
		water_animation_layer.is_processing(),
		BuildConfig.ENABLE_WATER_DEBUG_VISUALS
	])

func _apply_water_animation_weather() -> void:
	_disable_failed_live_water_layers()

func _get_current_weather_type() -> String:
	var weather_state := WeatherUIHelperScript.get_current_weather_state(_get_time_manager())
	return str(weather_state.get("weather_type", "clear"))

func _get_current_water_wind_speed() -> float:
	var wind_state := _get_effective_wind_state_for_spot(str(PlayerData.current_spot))
	return maxf(float(wind_state.get("speed_mps", 0.0)), 0.0)

func _ensure_ui_canvas_layer() -> void:
	if ui_canvas_layer == null:
		ui_canvas_layer = CanvasLayer.new()
		ui_canvas_layer.name = "ui_layer"
		ui_canvas_layer.layer = 20
		add_child(ui_canvas_layer)

	var ui_roots: Array = [
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
		harbor_button,
		map_button,
		profile_button,
		encyclopedia_button,
		current_tackle_button,
		current_tackle_popup,
		feed_button,
		bait_button,
		quick_tackle_panel,
		timer_label,
		tackle_label,
		result_label,
		reeling_panel,
		debug_panel,
		basket_backdrop,
		basket_panel,
		inventory_backdrop,
		inventory_panel,
		catch_popup_backdrop,
		catch_popup_panel,
		shop_backdrop,
		shop_panel,
		tackle_backdrop,
		tackle_panel,
		waterbody_backdrop,
		waterbody_panel,
		toast_label
	]

	for node in ui_roots:
		if node == null or node.get_parent() == ui_canvas_layer:
			continue
		var parent: Node = node.get_parent()
		if parent != null:
			parent.remove_child(node)
		ui_canvas_layer.add_child(node)

	_ensure_modal_layer()
	_move_modal_roots_to_layer()
	_refresh_modal_input_blocker()
	_ensure_tuman_fm_hud()
	_ensure_current_tackle_hud_nodes()


func _ensure_tuman_fm_hud() -> void:
	if tuman_fm_hud == null:
		tuman_fm_hud = TumanFmHudScript.new()
		tuman_fm_hud.name = "TumanFmHud"
	if ui_canvas_layer != null and tuman_fm_hud.get_parent() != ui_canvas_layer:
		_reparent_node(tuman_fm_hud, ui_canvas_layer)
	if tuman_fm_hud.has_method("setup"):
		tuman_fm_hud.call("setup", self)
	tuman_fm_hud.visible = false

func _ensure_current_tackle_hud_nodes() -> void:
	var parent: Node = ui_canvas_layer if ui_canvas_layer != null else self

	if current_tackle_button == null:
		current_tackle_button = Button.new()
		current_tackle_button.name = "CurrentTackleHudButton"
		current_tackle_button.focus_mode = Control.FOCUS_NONE
		current_tackle_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		current_tackle_button.visible = false
		current_tackle_button.disabled = true
		current_tackle_button.clip_text = true
		current_tackle_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		add_child(current_tackle_button)
	if current_tackle_button.get_parent() != parent:
		_reparent_node(current_tackle_button, parent)

	if current_tackle_popup == null:
		current_tackle_popup = Panel.new()
		current_tackle_popup.name = "CurrentTacklePopup"
		current_tackle_popup.visible = false
		current_tackle_popup.mouse_filter = Control.MOUSE_FILTER_STOP
		parent.add_child(current_tackle_popup)
	elif current_tackle_popup.get_parent() != parent:
		_reparent_node(current_tackle_popup, parent)

	if current_tackle_popup_box == null:
		current_tackle_popup_box = VBoxContainer.new()
		current_tackle_popup_box.name = "CurrentTacklePopupBox"
		current_tackle_popup_box.mouse_filter = Control.MOUSE_FILTER_PASS
		current_tackle_popup_box.add_theme_constant_override("separation", 6)
		current_tackle_popup.add_child(current_tackle_popup_box)
	elif current_tackle_popup_box.get_parent() != current_tackle_popup:
		_reparent_node(current_tackle_popup_box, current_tackle_popup)

func _ensure_fish_harbor_ui() -> void:
	_ensure_modal_layer()
	if fish_harbor_ui == null:
		fish_harbor_ui = FishHarborScene.instantiate() as Control
		fish_harbor_ui.name = "FishHarbor"
		fish_harbor_ui.visible = false
		modal_content_root.add_child(fish_harbor_ui)
		if fish_harbor_ui.has_method("setup"):
			fish_harbor_ui.call("setup", self)
	elif fish_harbor_ui.get_parent() != modal_content_root:
		_reparent_node(fish_harbor_ui, modal_content_root)

func _ensure_system_menu_ui() -> void:
	if system_menu_ui == null:
		system_menu_ui = SystemMenuUIScript.new()
	if system_menu_ui.has_method("setup"):
		system_menu_ui.setup(self)

func _ensure_mobile_scroll_helper() -> void:
	if mobile_scroll_helper == null:
		mobile_scroll_helper = MobileScrollHelperScript.new()
		mobile_scroll_helper.name = "MobileScrollHelper"
		add_child(mobile_scroll_helper)
	if mobile_scroll_helper.has_method("setup"):
		mobile_scroll_helper.setup(self)


func refresh_mobile_scroll_helper() -> void:
	if mobile_scroll_helper == null:
		_ensure_mobile_scroll_helper()
	if mobile_scroll_helper != null and mobile_scroll_helper.has_method("refresh"):
		mobile_scroll_helper.call_deferred("refresh")

func _ensure_modal_input_shield() -> void:
	_ensure_modal_layer()

func _ensure_modal_layer() -> void:
	if modal_canvas_layer == null:
		modal_canvas_layer = CanvasLayer.new()
		modal_canvas_layer.name = "ModalLayer"
		modal_canvas_layer.layer = 40
		add_child(modal_canvas_layer)

	if modal_input_shield != null:
		_layout_modal_layer()
		return

	modal_input_shield = ColorRect.new()
	modal_input_shield.name = "ModalInputBlocker"
	modal_input_shield.visible = false
	modal_input_shield.mouse_filter = Control.MOUSE_FILTER_STOP
	modal_input_shield.color = Color(0.0, 0.0, 0.0, 0.0)
	modal_input_shield.z_index = 0
	modal_canvas_layer.add_child(modal_input_shield)

	modal_content_root = Control.new()
	modal_content_root.name = "ModalContentRoot"
	modal_content_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal_content_root.z_index = 1
	modal_canvas_layer.add_child(modal_content_root)

	_layout_modal_layer()

func get_modal_content_root() -> Control:
	_ensure_modal_layer()
	return modal_content_root

func _get_full_ui_viewport_size() -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size
	var root_size: Vector2 = get_tree().root.get_visible_rect().size
	var project_size := Vector2(
		float(ProjectSettings.get_setting("display/window/size/viewport_width", viewport_size.x)),
		float(ProjectSettings.get_setting("display/window/size/viewport_height", viewport_size.y))
	)
	return Vector2(
		max(max(viewport_size.x, root_size.x), project_size.x),
		max(max(viewport_size.y, root_size.y), project_size.y)
	)

func _layout_modal_layer() -> void:
	var screen_size := _get_full_ui_viewport_size()
	if modal_input_shield != null:
		modal_input_shield.set_anchors_preset(Control.PRESET_FULL_RECT)
		modal_input_shield.position = Vector2.ZERO
		modal_input_shield.size = screen_size
		modal_input_shield.scale = Vector2.ONE
		modal_input_shield.offset_left = 0.0
		modal_input_shield.offset_top = 0.0
		modal_input_shield.offset_right = 0.0
		modal_input_shield.offset_bottom = 0.0
	if modal_content_root != null:
		modal_content_root.set_anchors_preset(Control.PRESET_FULL_RECT)
		modal_content_root.position = Vector2.ZERO
		modal_content_root.size = screen_size
		modal_content_root.custom_minimum_size = screen_size
		modal_content_root.scale = Vector2.ONE
		modal_content_root.offset_left = 0.0
		modal_content_root.offset_top = 0.0
		modal_content_root.offset_right = 0.0
		modal_content_root.offset_bottom = 0.0

func _move_modal_roots_to_layer() -> void:
	var root := get_modal_content_root()
	for node in [
		basket_backdrop,
		basket_panel,
		inventory_backdrop,
		inventory_panel,
		catch_popup_backdrop,
		catch_popup_panel,
		shop_backdrop,
		shop_panel,
		tackle_backdrop,
		tackle_panel,
		waterbody_backdrop,
		waterbody_panel,
		level_up_backdrop,
		level_up_panel,
		fish_harbor_ui
	]:
		_reparent_node(node, root)
		if node is Control:
			(node as Control).mouse_filter = Control.MOUSE_FILTER_STOP

func open_modal(modal_name: String) -> void:
	_close_quick_tackle_radial(false)
	_ensure_modal_layer()
	_move_modal_roots_to_layer()
	if system_menu_ui != null:
		system_menu_ui.close_menu()
	_hide_modal_roots_except(modal_name)
	_current_modal_name = modal_name
	is_modal_open = true
	if modal_input_shield != null:
		modal_input_shield.visible = true
		modal_input_shield.mouse_filter = Control.MOUSE_FILTER_STOP
	_request_depth_hud_refresh()

func close_modal(modal_name: String = "") -> void:
	if modal_name == "" or _current_modal_name == modal_name:
		_current_modal_name = ""
	_refresh_modal_input_blocker()
	_request_depth_hud_refresh()

func _close_quick_tackle_radial(animated: bool = true) -> void:
	if quick_tackle_panel == null:
		return
	if quick_tackle_panel.has_method("close_radial_menu"):
		quick_tackle_panel.call("close_radial_menu", animated)
	elif quick_tackle_panel.has_method("hide_radial_menu"):
		quick_tackle_panel.call("hide_radial_menu", animated)
	elif quick_tackle_panel.has_method("hide_popup"):
		quick_tackle_panel.call("hide_popup")

func close_current_modal() -> void:
	match _current_modal_name:
		"shop":
			shop_ui.close()
		"inventory":
			inventory_ui.close()
		"keepnet":
			keepnet_ui.close()
		"tackle":
			tackle_ui.close()
		"map":
			waterbody_ui.close()
		"profile":
			if profile_ui != null:
				profile_ui.close()
		"fish_harbor":
			if fish_harbor_ui != null and fish_harbor_ui.has_method("close"):
				fish_harbor_ui.call("close")
		"settings":
			if system_menu_ui != null:
				system_menu_ui.close_settings()
		"weather_forecast":
			if system_menu_ui != null and system_menu_ui.has_method("close_forecast"):
				system_menu_ui.close_forecast()
		"bug_report":
			if system_menu_ui != null and system_menu_ui.has_method("close_bug_report"):
				system_menu_ui.close_bug_report()
		"encyclopedia":
			if encyclopedia_ui != null:
				encyclopedia_ui.close()
		"catch_reward":
			if _block_pending_catch_reward_close_attempt():
				return
			_hide_catch_reward_popup()
		"level_up_reward":
			if _block_level_up_reward_close_attempt():
				return
			_hide_level_up_reward_popup()
		_:
			_hide_modal_roots_except("")
			if profile_ui != null:
				profile_ui.close()
			if encyclopedia_ui != null:
				encyclopedia_ui.close()
			if fish_harbor_ui != null:
				fish_harbor_ui.visible = false
			if system_menu_ui != null:
				system_menu_ui.close_settings()
				if system_menu_ui.has_method("close_forecast"):
					system_menu_ui.close_forecast()
				if system_menu_ui.has_method("close_bug_report"):
					system_menu_ui.close_bug_report()
			_refresh_modal_input_blocker()

func _hide_modal_roots_except(modal_name: String) -> void:
	if modal_name == "":
		_current_modal_name = ""
	if modal_name != "keepnet":
		if basket_panel != null:
			basket_panel.visible = false
		if basket_backdrop != null:
			basket_backdrop.visible = false
	if modal_name != "inventory":
		if inventory_panel != null:
			inventory_panel.visible = false
		if inventory_backdrop != null:
			inventory_backdrop.visible = false
	if modal_name != "shop":
		if shop_panel != null:
			shop_panel.visible = false
		if shop_backdrop != null:
			shop_backdrop.visible = false
	if modal_name != "tackle":
		if tackle_panel != null:
			tackle_panel.visible = false
		if tackle_backdrop != null:
			tackle_backdrop.visible = false
	if modal_name != "map":
		if waterbody_panel != null:
			waterbody_panel.visible = false
		if waterbody_backdrop != null:
			waterbody_backdrop.visible = false
	if modal_name != "fish_harbor" and fish_harbor_ui != null:
		fish_harbor_ui.visible = false
	if modal_name != "catch_reward":
		if catch_popup_panel != null:
			catch_popup_panel.visible = false
		if catch_popup_backdrop != null:
			catch_popup_backdrop.visible = false
	if modal_name != LEVEL_UP_MODAL_NAME:
		if level_up_panel != null:
			level_up_panel.visible = false
		if level_up_backdrop != null:
			level_up_backdrop.visible = false
	if modal_name != "profile" and profile_ui != null:
		profile_ui.close(false)
	if modal_name != "encyclopedia" and encyclopedia_ui != null:
		encyclopedia_ui.close(false)
	if modal_name != "settings" and system_menu_ui != null:
		system_menu_ui.close_settings(false)
	if modal_name != "weather_forecast" and system_menu_ui != null and system_menu_ui.has_method("close_forecast"):
		system_menu_ui.close_forecast(false)
	if modal_name != "bug_report" and system_menu_ui != null and system_menu_ui.has_method("close_bug_report"):
		system_menu_ui.close_bug_report(false)

func _refresh_modal_input_blocker() -> void:
	_ensure_modal_layer()
	var has_open_modal := _is_any_modal_visible()
	is_modal_open = has_open_modal
	if modal_input_shield != null:
		modal_input_shield.visible = has_open_modal or _is_modal_tap_guard_active()
		modal_input_shield.mouse_filter = Control.MOUSE_FILTER_STOP
	_request_depth_hud_refresh()

func _is_any_modal_visible() -> bool:
	for control in [
		basket_panel,
		inventory_panel,
		shop_panel,
		tackle_panel,
		waterbody_panel,
		catch_popup_panel,
		level_up_panel
	]:
		if _is_visible_ui_control(control):
			return true
	if profile_ui != null and profile_ui.is_any_modal_open():
		return true
	if encyclopedia_ui != null and encyclopedia_ui.is_any_modal_open():
		return true
	if fish_harbor_ui != null and fish_harbor_ui.visible:
		return true
	if system_menu_ui != null and system_menu_ui.is_settings_open():
		return true
	if system_menu_ui != null and system_menu_ui.has_method("is_forecast_open") and system_menu_ui.is_forecast_open():
		return true
	if system_menu_ui != null and system_menu_ui.has_method("is_bug_report_open") and system_menu_ui.is_bug_report_open():
		return true
	return false

func _ensure_gameplay_layer_names() -> void:
	fishing_presence_layer.name = "gameplay_rod"
	float_marker.name = "gameplay_float"
	float_ripple.name = "gameplay_ripple"

func _ensure_mobile_ui_containers() -> void:
	if top_hud_container == null:
		top_hud_container = HBoxContainer.new()
		top_hud_container.name = "TopHudHBox"
		top_hud_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top_hud_container.add_theme_constant_override("separation", 8)
		ui_canvas_layer.add_child(top_hud_container)

	if top_hud_spacer == null:
		top_hud_spacer = Control.new()
		top_hud_spacer.name = "TopHudSpacer"
		top_hud_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top_hud_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top_hud_container.add_child(top_hud_spacer)
	_ensure_top_hud_groups()

	if quick_actions_container == null:
		quick_actions_container = VBoxContainer.new()
		quick_actions_container.name = "QuickActionsVBox"
		quick_actions_container.mouse_filter = Control.MOUSE_FILTER_PASS
		quick_actions_container.add_theme_constant_override("separation", 8)
		action_panel.add_child(quick_actions_container)

	if bottom_nav_container == null:
		bottom_nav_container = VBoxContainer.new()
		bottom_nav_container.name = "LeftNavVBox"
		bottom_nav_container.mouse_filter = Control.MOUSE_FILTER_PASS
		bottom_nav_container.add_theme_constant_override("separation", 7)
		bottom_nav_panel.add_child(bottom_nav_container)

	for node in [top_hud_panel, time_hud_panel, weather_hud_panel]:
		_reparent_node(node, ui_canvas_layer)
		node.visible = false
		node.custom_minimum_size = Vector2.ZERO
		node.size = Vector2.ZERO
	_reparent_node(top_hud_spacer, top_hud_container)
	_reparent_node(spot_option_button, top_hud_container)
	top_hud_container.move_child(top_hud_money_group, 0)
	top_hud_container.move_child(top_hud_time_group, 1)
	top_hud_container.move_child(top_hud_temperature_group, 2)
	top_hud_container.move_child(top_hud_wind_group, 3)
	top_hud_container.move_child(top_hud_spacer, 4)
	top_hud_container.move_child(spot_option_button, 5)

	if money_hud_icon != null:
		_reparent_node(money_hud_icon, top_hud_money_group)
	_reparent_node(money_label, top_hud_money_group)
	if time_hud_icon != null:
		_reparent_node(time_hud_icon, top_hud_time_group)
	_reparent_node(clock_label, top_hud_time_group)
	if weather_hud_icon != null:
		_reparent_node(weather_hud_icon, top_hud_temperature_group)
	_reparent_node(weather_label, top_hud_temperature_group)
	if wind_hud_icon != null:
		_reparent_node(wind_hud_icon, top_hud_wind_group)
	if wind_label != null:
		_reparent_node(wind_label, top_hud_wind_group)
	_order_weather_hud_row_children()

	for node in [feed_button, bait_button, tackle_button]:
		_reparent_node(node, quick_actions_container)
		node.visible = false
		node.disabled = true
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quick_actions_container.move_child(feed_button, 0)
	quick_actions_container.move_child(bait_button, 1)
	quick_actions_container.move_child(tackle_button, 2)
	quick_actions_container.visible = false
	quick_actions_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action_panel.visible = false
	action_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if nav_fish_button.get_parent() == bottom_nav_container:
		_reparent_node(nav_fish_button, ui_canvas_layer)
	nav_fish_button.visible = false
	nav_fish_button.disabled = true
	nav_fish_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if basket_button != null:
		_reparent_node(basket_button, ui_canvas_layer)
		basket_button.visible = false
		basket_button.disabled = true
		basket_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for node in [inventory_button, map_button]:
		_reparent_node(node, bottom_nav_container)
	bottom_nav_container.move_child(inventory_button, 0)
	bottom_nav_container.move_child(map_button, 1)
	bottom_nav_panel.visible = true
	bottom_nav_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	bottom_nav_container.visible = true
	bottom_nav_container.mouse_filter = Control.MOUSE_FILTER_PASS

	for node in [shop_button, harbor_button]:
		if node != null:
			_reparent_node(node, ui_canvas_layer)
			node.visible = false
			node.disabled = true
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for node in [encyclopedia_button, profile_button, current_tackle_button]:
		if node != null:
			_reparent_node(node, ui_canvas_layer)
			node.visible = false
			node.disabled = true
	if current_tackle_popup != null:
		_reparent_node(current_tackle_popup, ui_canvas_layer)
		current_tackle_popup.visible = false

func _ensure_top_hud_groups() -> void:
	top_hud_money_group = _ensure_top_hud_group(top_hud_money_group, "MoneyGroup")
	top_hud_time_group = _ensure_top_hud_group(top_hud_time_group, "TimeGroup")
	top_hud_temperature_group = _ensure_top_hud_group(top_hud_temperature_group, "TemperatureGroup")
	top_hud_wind_group = _ensure_top_hud_group(top_hud_wind_group, "WindGroup")


func _ensure_top_hud_group(group: HBoxContainer, node_name: String) -> HBoxContainer:
	if group == null:
		group = HBoxContainer.new()
		group.name = node_name
		group.mouse_filter = Control.MOUSE_FILTER_IGNORE
		group.alignment = BoxContainer.ALIGNMENT_BEGIN
		top_hud_container.add_child(group)
	elif group.get_parent() != top_hud_container:
		_reparent_node(group, top_hud_container)
	group.add_theme_constant_override("separation", 6)
	group.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	group.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return group

func _ensure_cast_button_visual() -> void:
	if cast_button_visual != null:
		return

	cast_button_visual = TextureRect.new()
	cast_button_visual.name = "CastButtonVisual"
	cast_button_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cast_button_visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cast_button_visual.stretch_mode = TextureRect.STRETCH_SCALE
	cast_button_visual.visible = false
	cast_button_visual.z_index = 102
	cast_button_visual.set_anchors_preset(Control.PRESET_TOP_LEFT)
	ui_canvas_layer.add_child(cast_button_visual)

	fish_button.mouse_entered.connect(func() -> void:
		_cast_button_hovered = true
		_update_cast_button_visual()
	)
	fish_button.mouse_exited.connect(func() -> void:
		_cast_button_hovered = false
		_cast_button_pressed = false
		_fish_button_pointer_action_active = false
		_update_cast_button_visual()
	)
	fish_button.button_down.connect(func() -> void:
		_cast_button_pressed = true
		_update_cast_button_visual()
	)
	fish_button.button_up.connect(func() -> void:
		_cast_button_pressed = false
		_update_cast_button_visual()
	)


func _ensure_cast_power_indicator() -> void:
	if cast_power_indicator_track != null and cast_power_indicator_fill != null:
		return

	cast_power_indicator_track = Panel.new()
	cast_power_indicator_track.name = "CastPowerIndicator"
	cast_power_indicator_track.visible = false
	cast_power_indicator_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cast_power_indicator_track.z_index = 266
	cast_power_indicator_track.set_anchors_preset(Control.PRESET_TOP_LEFT)
	cast_power_indicator_track.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color(0.020, 0.058, 0.062, 0.82), Color(0.80, 1.0, 0.90, 0.34), 5, 2, Color(0.0, 0.0, 0.0, 0.22))
	)
	ui_canvas_layer.add_child(cast_power_indicator_track)

	cast_power_indicator_fill = ColorRect.new()
	cast_power_indicator_fill.name = "CastPowerFill"
	cast_power_indicator_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cast_power_indicator_fill.color = Color(0.72, 1.0, 0.80, 0.92)
	cast_power_indicator_track.add_child(cast_power_indicator_fill)


func _ensure_stop_fishing_button() -> void:
	if stop_fishing_button != null:
		return

	stop_fishing_button = Button.new()
	stop_fishing_button.name = "StopFishingButton"
	stop_fishing_button.text = "X"
	stop_fishing_button.tooltip_text = "Вытащить удочку"
	stop_fishing_button.mouse_filter = Control.MOUSE_FILTER_STOP
	stop_fishing_button.focus_mode = Control.FOCUS_NONE
	stop_fishing_button.visible = false
	stop_fishing_button.z_index = 262
	stop_fishing_button.add_theme_constant_override("h_separation", 0)
	stop_fishing_button.pressed.connect(_on_stop_fishing_button_pressed)
	ui_canvas_layer.add_child(stop_fishing_button)


func _ensure_float_bite_preview() -> void:
	if float_bite_preview != null and is_instance_valid(float_bite_preview):
		return
	if ui_canvas_layer == null:
		_ensure_ui_canvas_layer()

	float_bite_preview = FloatBitePreviewScene.instantiate() as Control
	float_bite_preview.name = "FloatBitePreview"
	float_bite_preview.visible = false
	float_bite_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	float_bite_preview.z_index = 103
	ui_canvas_layer.add_child(float_bite_preview)
	_layout_float_bite_preview(get_viewport_rect().size, min(get_viewport_rect().size.x / BASE_SCREEN_SIZE.x, get_viewport_rect().size.y / BASE_SCREEN_SIZE.y))


func _layout_float_bite_preview(screen_size: Vector2, ui_scale: float) -> void:
	if float_bite_preview == null or not is_instance_valid(float_bite_preview):
		return

	var diameter: float = clamp(176.0 * ui_scale, 148.0, 188.0)
	var preview_size := Vector2(diameter, diameter)
	var margin: float = clamp(18.0 * ui_scale, 12.0, 24.0)
	var top_guard: float = HUD_HEIGHT * ui_scale + margin
	var action_button_guard: float = clamp(132.0 * ui_scale, 104.0, 152.0)
	var desired_x: float = screen_size.x * 0.33 - preview_size.x * 0.5
	var desired_y: float = max(top_guard, screen_size.y * 0.58)
	var preview_pos := Vector2(desired_x, desired_y)
	preview_pos.x = clamp(preview_pos.x, margin, max(margin, screen_size.x - preview_size.x - margin))
	preview_pos.x = min(preview_pos.x, max(margin, screen_size.x - preview_size.x - action_button_guard))
	preview_pos.y = clamp(preview_pos.y, top_guard, max(top_guard, screen_size.y - preview_size.y - margin))

	_anchor_control(float_bite_preview, 0.0, 0.0, 0.0, 0.0, preview_pos.x, preview_pos.y, preview_pos.x + preview_size.x, preview_pos.y + preview_size.y)
	float_bite_preview.custom_minimum_size = preview_size
	float_bite_preview.size = preview_size
	float_bite_preview.z_index = 103
	float_bite_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _show_float_bite_preview_idle() -> void:
	if _is_reel_tackle_mode() or _is_menu_overlay_open():
		_hide_float_bite_preview()
		return
	_ensure_float_bite_preview()
	if float_bite_preview == null:
		return
	_layout_float_bite_preview(get_viewport_rect().size, min(get_viewport_rect().size.x / BASE_SCREEN_SIZE.x, get_viewport_rect().size.y / BASE_SCREEN_SIZE.y))
	float_bite_preview.visible = true
	float_bite_preview.modulate = Color.WHITE
	float_bite_preview.move_to_front()
	if float_bite_preview.has_method("show_preview"):
		float_bite_preview.call("show_preview")
	if float_bite_preview.has_method("set_idle"):
		float_bite_preview.call("set_idle")


func _hide_float_bite_preview() -> void:
	if float_bite_preview == null or not is_instance_valid(float_bite_preview):
		return
	if float_bite_preview.has_method("hide_preview"):
		float_bite_preview.call("hide_preview")
	else:
		float_bite_preview.visible = false


func _refresh_float_bite_preview_visibility() -> void:
	_ensure_float_bite_preview()
	if float_bite_preview == null or not is_instance_valid(float_bite_preview):
		return

	var should_show := (
		_fishing_ui_state == FishingUiState.WAITING
		and not bool(FishingManager.get("is_reeling"))
		and not _is_reel_tackle_mode()
		and not _is_menu_overlay_open()
	)
	if should_show:
		if not float_bite_preview.visible:
			_show_float_bite_preview_idle()
	else:
		_hide_float_bite_preview()


func _ensure_depth_hud_controls() -> void:
	if depth_hud_minus_button == null:
		depth_hud_minus_button = Button.new()
		depth_hud_minus_button.name = "DepthHudMinusButton"
		depth_hud_minus_button.text = "-"
		depth_hud_minus_button.tooltip_text = "Уменьшить глубину"
		depth_hud_minus_button.mouse_filter = Control.MOUSE_FILTER_STOP
		depth_hud_minus_button.focus_mode = Control.FOCUS_NONE
		depth_hud_minus_button.visible = false
		depth_hud_minus_button.z_index = 261
		depth_hud_minus_button.add_theme_constant_override("h_separation", 0)
		depth_hud_minus_button.pressed.connect(_on_tackle_depth_button_pressed.bind(-0.1))
		ui_canvas_layer.add_child(depth_hud_minus_button)

	if depth_hud_plus_button == null:
		depth_hud_plus_button = Button.new()
		depth_hud_plus_button.name = "DepthHudPlusButton"
		depth_hud_plus_button.text = "+"
		depth_hud_plus_button.tooltip_text = "Увеличить глубину"
		depth_hud_plus_button.mouse_filter = Control.MOUSE_FILTER_STOP
		depth_hud_plus_button.focus_mode = Control.FOCUS_NONE
		depth_hud_plus_button.visible = false
		depth_hud_plus_button.z_index = 261
		depth_hud_plus_button.add_theme_constant_override("h_separation", 0)
		depth_hud_plus_button.pressed.connect(_on_tackle_depth_button_pressed.bind(0.1))
		ui_canvas_layer.add_child(depth_hud_plus_button)

	if depth_hud_label == null:
		depth_hud_label = Label.new()
		depth_hud_label.name = "DepthHudLabel"
		depth_hud_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		depth_hud_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		depth_hud_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		depth_hud_label.visible = false
		depth_hud_label.z_index = 261
		depth_hud_label.add_theme_color_override("font_color", Color(0.96, 1.0, 0.90, 1.0))
		depth_hud_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.70))
		depth_hud_label.add_theme_constant_override("shadow_offset_x", 1)
		depth_hud_label.add_theme_constant_override("shadow_offset_y", 1)
		ui_canvas_layer.add_child(depth_hud_label)

	if depth_radial_control == null:
		depth_radial_control = FloatDepthRadialControlScript.new()
		depth_radial_control.name = "FloatDepthRadialControl"
		depth_radial_control.visible = false
		depth_radial_control.z_index = 3
		depth_radial_control.mouse_filter = Control.MOUSE_FILTER_PASS
		depth_radial_control.depth_changed.connect(_on_depth_radial_control_changed)
		depth_radial_control.depth_change_committed.connect(_on_depth_radial_control_committed)
		depth_radial_control.set_hook_texture(DEPTH_HOOK_ICON)
		if fish_button != null:
			fish_button.add_child(depth_radial_control)
		else:
			ui_canvas_layer.add_child(depth_radial_control)


func _ensure_keepnet_hud_button() -> void:
	if keepnet_hud_button != null:
		return

	keepnet_hud_button = KeepnetHudButtonScript.new()
	keepnet_hud_button.name = "KeepnetHudButton"
	keepnet_hud_button.tooltip_text = "Садок"
	keepnet_hud_button.mouse_filter = Control.MOUSE_FILTER_STOP
	keepnet_hud_button.focus_mode = Control.FOCUS_NONE
	keepnet_hud_button.visible = true
	keepnet_hud_button.z_index = 260
	if ui_theme != null and keepnet_hud_button.has_method("set_icon_texture"):
		keepnet_hud_button.call("set_icon_texture", ui_theme.get_side_menu_icon("keepnet"))
	keepnet_hud_button.pressed.connect(_on_basket_button_pressed)
	ui_canvas_layer.add_child(keepnet_hud_button)


func _ensure_player_xp_hud() -> void:
	if player_xp_hud != null:
		return

	player_xp_hud = PlayerXpHudScript.new()
	player_xp_hud.name = "PlayerXpHud"
	player_xp_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player_xp_hud.visible = true
	player_xp_hud.z_index = 270
	ui_canvas_layer.add_child(player_xp_hud)


func _layout_player_xp_hud(screen_size: Vector2, ui_scale: float) -> void:
	if player_xp_hud == null:
		return
	var hud_width := clampf(screen_size.x * 0.42, 360.0 * ui_scale, 520.0 * ui_scale)
	var hud_height := clampf(36.0 * ui_scale, 32.0, 42.0)
	var hud_x := (screen_size.x - hud_width) * 0.5
	var hud_y := screen_size.y - hud_height - clampf(9.0 * ui_scale, 7.0, 12.0)
	_anchor_control(player_xp_hud, 0.0, 0.0, 0.0, 0.0, hud_x, hud_y, hud_x + hud_width, hud_y + hud_height)
	player_xp_hud.custom_minimum_size = Vector2(hud_width, hud_height)
	player_xp_hud.size = Vector2(hud_width, hud_height)
	player_xp_hud.visible = true
	player_xp_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player_xp_hud.z_index = 270
	_update_player_xp_hud(false)


func _make_reeling_color_rect(node_name: String, parent: Node, z: int) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = node_name
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.z_index = z
	parent.add_child(rect)
	return rect

func _ensure_reeling_visual_nodes() -> void:
	if reeling_panel == null or tension_track == null:
		return

	reeling_panel.color = Color.TRANSPARENT
	reeling_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tension_track.clip_contents = false
	tension_track.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if reeling_panel_frame == null:
		reeling_panel_frame = Panel.new()
		reeling_panel_frame.name = "ReelingPanelFrame"
		reeling_panel_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		reeling_panel_frame.z_index = 0
		reeling_panel.add_child(reeling_panel_frame)
		reeling_panel.move_child(reeling_panel_frame, 0)

	if tension_slack_zone == null:
		tension_slack_zone = _make_reeling_color_rect("SlackZone", tension_track, 0)
	if tension_warning_zone == null:
		tension_warning_zone = _make_reeling_color_rect("WarningZone", tension_track, 0)
	if tension_critical_zone == null:
		tension_critical_zone = _make_reeling_color_rect("CriticalZone", tension_track, 0)
	if tension_marker_glow == null:
		tension_marker_glow = _make_reeling_color_rect("TensionMarkerGlow", tension_track, 3)

	if safe_zone != null:
		safe_zone.z_index = 0
		safe_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tension_fill != null:
		tension_fill.z_index = 2
		tension_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tension_marker != null:
		tension_marker.z_index = 4
		tension_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if progress_track != null:
		progress_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if progress_fill != null:
		progress_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _layout_reeling_panel_frame() -> void:
	_ensure_reeling_visual_nodes()
	if reeling_panel_frame == null:
		return

	reeling_panel_frame.position = Vector2.ZERO
	reeling_panel_frame.size = reeling_panel.size

func _set_reeling_panel_visual_state(state_key: String, accent: Color) -> void:
	_ensure_reeling_visual_nodes()
	if reeling_panel_frame == null:
		return
	if _last_reeling_visual_key == state_key:
		return

	_last_reeling_visual_key = state_key
	var critical := state_key == "critical"
	var bg := Color(0.018, 0.032, 0.036, 0.70)
	var border := Color(accent.r, accent.g, accent.b, 0.56 if critical else 0.34)
	var shadow := Color(accent.r, accent.g, accent.b, 0.18 if critical else 0.08)
	var style := _make_panel_style(bg, border, 18, 7 if critical else 4, shadow)
	style.set_border_width_all(1)
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	reeling_panel_frame.add_theme_stylebox_override("panel", style)

func _reparent_node(node: Node, new_parent: Node) -> void:
	if node == null or new_parent == null or node.get_parent() == new_parent:
		return

	var old_parent: Node = node.get_parent()
	if old_parent != null:
		old_parent.remove_child(node)
	new_parent.add_child(node)

func _ensure_level_up_reward_popup() -> void:
	if modal_content_root == null:
		_ensure_modal_layer()
	var root := modal_content_root
	if root == null:
		return

	if level_up_backdrop == null:
		level_up_backdrop = ColorRect.new()
		level_up_backdrop.name = "LevelUpBackdrop"
		level_up_backdrop.visible = false
		level_up_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
		level_up_backdrop.color = Color(0.0, 0.0, 0.0, 0.76)
		root.add_child(level_up_backdrop)

	if level_up_panel == null:
		level_up_panel = Panel.new()
		level_up_panel.name = "LevelUpPanel"
		level_up_panel.visible = false
		level_up_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		root.add_child(level_up_panel)

	if level_up_title_label == null:
		level_up_title_label = _create_level_up_label("LevelUpTitle", 24, Color(0.96, 1.0, 0.92, 1.0), true)
		level_up_title_label.text = "Новый уровень!"
		level_up_panel.add_child(level_up_title_label)

	if level_up_level_label == null:
		level_up_level_label = _create_level_up_label("LevelUpNumber", 42, Color(0.72, 1.0, 0.80, 1.0), true)
		level_up_panel.add_child(level_up_level_label)

	if level_up_unlocks_label == null:
		level_up_unlocks_label = _create_level_up_label("LevelUpUnlocks", 14, Color(0.82, 0.94, 0.86, 0.96), false)
		level_up_unlocks_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		level_up_panel.add_child(level_up_unlocks_label)

	if level_up_rewards_label == null:
		level_up_rewards_label = _create_level_up_label("LevelUpRewards", 15, Color(0.96, 0.96, 0.84, 0.98), false)
		level_up_rewards_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		level_up_panel.add_child(level_up_rewards_label)

	if level_up_warning_label == null:
		level_up_warning_label = _create_level_up_label("LevelUpWarning", 12, Color(1.0, 0.76, 0.52, 0.92), true)
		level_up_warning_label.visible = false
		level_up_panel.add_child(level_up_warning_label)

	if level_up_confirm_button == null:
		level_up_confirm_button = Button.new()
		level_up_confirm_button.name = "LevelUpConfirmButton"
		level_up_confirm_button.text = "Забрать"
		level_up_confirm_button.mouse_filter = Control.MOUSE_FILTER_STOP
		level_up_panel.add_child(level_up_confirm_button)
		var callback := Callable(self, "_on_level_up_confirm_pressed")
		if not level_up_confirm_button.pressed.is_connected(callback):
			level_up_confirm_button.pressed.connect(callback)

func _create_level_up_label(label_name: String, font_size: int, color: Color, centered: bool) -> Label:
	var label := Label.new()
	label.name = label_name
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.58))
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label

func _layout_level_up_reward_popup(screen_size: Vector2) -> void:
	_ensure_level_up_reward_popup()
	if level_up_panel == null or level_up_backdrop == null:
		return

	level_up_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	level_up_backdrop.offset_left = 0.0
	level_up_backdrop.offset_top = 0.0
	level_up_backdrop.offset_right = 0.0
	level_up_backdrop.offset_bottom = 0.0
	level_up_backdrop.z_index = 220
	if ui_theme != null:
		ui_theme.apply_modal_backdrop_style(level_up_backdrop)

	var popup_width: float = min(screen_size.x - 40.0, 520.0)
	var popup_height: float = min(screen_size.y - 42.0, 368.0)
	popup_width = max(popup_width, 320.0)
	popup_height = max(popup_height, 304.0)
	level_up_panel.position = Vector2((screen_size.x - popup_width) * 0.5, (screen_size.y - popup_height) * 0.5)
	level_up_panel.size = Vector2(popup_width, popup_height)
	level_up_panel.pivot_offset = level_up_panel.size * 0.5
	level_up_panel.z_index = 221
	level_up_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	level_up_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color(0.018, 0.050, 0.046, 0.96), Color(0.78, 1.0, 0.82, 0.42), 12, 8, Color(0.0, 0.0, 0.0, 0.34))
	)

	var padding := 22.0
	var inner_width := popup_width - padding * 2.0
	level_up_title_label.position = Vector2(padding, 18.0)
	level_up_title_label.size = Vector2(inner_width, 30.0)
	level_up_title_label.add_theme_font_size_override("font_size", 24)

	level_up_level_label.position = Vector2(padding, 50.0)
	level_up_level_label.size = Vector2(inner_width, 54.0)
	level_up_level_label.add_theme_font_size_override("font_size", 42)

	level_up_unlocks_label.position = Vector2(padding, 112.0)
	level_up_unlocks_label.size = Vector2(inner_width, 70.0)
	level_up_unlocks_label.add_theme_font_size_override("font_size", 14)

	level_up_rewards_label.position = Vector2(padding, 188.0)
	level_up_rewards_label.size = Vector2(inner_width, max(popup_height - 286.0, 44.0))
	level_up_rewards_label.add_theme_font_size_override("font_size", 15)

	level_up_warning_label.position = Vector2(padding, popup_height - 88.0)
	level_up_warning_label.size = Vector2(inner_width, 24.0)
	level_up_warning_label.add_theme_font_size_override("font_size", 12)

	var button_size := Vector2(150.0, 42.0)
	level_up_confirm_button.position = Vector2((popup_width - button_size.x) * 0.5, popup_height - 58.0)
	level_up_confirm_button.size = button_size
	level_up_confirm_button.custom_minimum_size = button_size
	level_up_confirm_button.add_theme_font_size_override("font_size", 14)
	_apply_button_style(level_up_confirm_button, STYLE_PRIMARY_BUTTON)

func _ensure_shop_ui_nodes() -> void:
	shop_ui._ensure_shop_ui_nodes()

func _ensure_keepnet_ui_nodes() -> void:
	keepnet_ui._ensure_keepnet_ui_nodes()

func _ensure_tackle_ui_nodes() -> void:
	tackle_ui._ensure_tackle_ui_nodes()

func _ensure_waterbody_ui_nodes() -> void:
	waterbody_ui._ensure_waterbody_ui_nodes()

func _make_panel_style(
	bg_color: Color,
	border_color: Color,
	radius: int = 12,
	shadow_size: int = 8,
	shadow_color: Color = Color(0.0, 0.0, 0.0, 0.28)
) -> StyleBoxFlat:
	return ui_theme.make_style(bg_color, border_color, radius, shadow_size, shadow_color)


func _make_hud_glass_style(active: bool = false, radius: int = HUD_GLASS_RADIUS) -> StyleBoxFlat:
	var bg := Color(0.018, 0.034, 0.036, 0.68)
	var border := Color(0.70, 0.86, 0.80, 0.24)
	var shadow := Color(0.0, 0.0, 0.0, 0.24)
	var shadow_size := 4
	if active:
		bg = Color(0.034, 0.082, 0.062, 0.78)
		border = Color(0.66, 1.0, 0.72, 0.46)
		shadow = Color(0.20, 0.72, 0.38, 0.15)
		shadow_size = 7
	var style := _make_panel_style(bg, border, radius, shadow_size, shadow)
	style.set_border_width_all(HUD_GLASS_BORDER_WIDTH)
	style.content_margin_left = 10.0
	style.content_margin_top = 7.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 7.0
	return style


func _is_primary_action_signal_active() -> bool:
	return (
		(_fishing_ui_state == FishingUiState.WAITING and _presence_bite_timer > 0.0)
		or _fishing_ui_state == FishingUiState.FIGHTING
		or _fishing_ui_state == FishingUiState.CAUGHT
		or _fishing_ui_state == FishingUiState.FAILED
	)


func _apply_hud_text_shadow(label: Label, outline_size: int = 1) -> void:
	if label == null:
		return
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.80))
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.50))
	label.add_theme_constant_override("outline_size", outline_size)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 1)


func _get_panel_style(style_name: String) -> StyleBoxFlat:
	match style_name:
		STYLE_INFO_CARD:
			return ui_theme.get_card_style()
		_:
			return ui_theme.get_panel_style()

func _apply_panel_style(panel: Panel, style_name: String = STYLE_HUD_PANEL) -> void:
	if style_name == STYLE_INFO_CARD:
		ui_theme.apply_card_style(panel)
	else:
		ui_theme.apply_panel_style(panel)

func _get_button_style(style_name: String, state: String = "normal") -> StyleBoxFlat:
	match style_name:
		STYLE_PRIMARY_BUTTON:
			return ui_theme.get_button_style("primary", state)
		STYLE_BOTTOM_NAV_ACTIVE:
			return ui_theme.get_button_style("nav_active", state)
		STYLE_BOTTOM_NAV_BUTTON:
			return ui_theme.get_button_style("nav", state)
		_:
			return ui_theme.get_button_style("secondary", state)

func _apply_button_style(button: Button, style_name: String = STYLE_SECONDARY_BUTTON) -> void:
	match style_name:
		STYLE_PRIMARY_BUTTON:
			ui_theme.apply_primary_button_style(button)
		STYLE_BOTTOM_NAV_ACTIVE:
			ui_theme.apply_nav_button_style(button, true)
		STYLE_BOTTOM_NAV_BUTTON:
			ui_theme.apply_nav_button_style(button, false)
		_:
			ui_theme.apply_secondary_button_style(button)

func _apply_top_icon_button_style(button: Button) -> void:
	if button == null or ui_theme == null:
		return
	var normal: StyleBoxFlat = ui_theme.make_style(Color(0.026, 0.044, 0.044, 0.78), Color(0.74, 0.96, 0.86, 0.32), 15, 5, Color(0.0, 0.0, 0.0, 0.22))
	var hover: StyleBoxFlat = ui_theme.make_style(Color(0.046, 0.082, 0.076, 0.88), Color(0.84, 1.0, 0.88, 0.54), 15, 7, Color(0.18, 0.66, 0.48, 0.13))
	var pressed: StyleBoxFlat = ui_theme.make_style(Color(0.038, 0.112, 0.092, 0.94), Color(0.82, 1.0, 0.86, 0.62), 15, 3, Color(0.0, 0.0, 0.0, 0.16))
	var disabled: StyleBoxFlat = ui_theme.make_style(Color(0.030, 0.040, 0.042, 0.44), Color(0.58, 0.64, 0.62, 0.12), 15, 1, Color.TRANSPARENT)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", Color(0.88, 1.0, 0.94, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.80, 1.0, 0.92, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.62, 0.70, 0.68, 0.54))

func _apply_action_button_style(button: Button, active: bool = false) -> void:
	var normal_bg := Color(0.018, 0.034, 0.036, 0.68)
	var hover_bg := Color(0.030, 0.062, 0.058, 0.76)
	var pressed_bg := Color(0.036, 0.088, 0.070, 0.84)
	var border := Color(0.70, 0.86, 0.80, 0.24)
	var shadow := Color(0.0, 0.0, 0.0, 0.22)

	if active:
		normal_bg = Color(0.052, 0.130, 0.078, 0.84)
		hover_bg = Color(0.070, 0.166, 0.096, 0.92)
		pressed_bg = Color(0.084, 0.206, 0.112, 0.98)
		border = Color(0.66, 1.0, 0.72, 0.48)
		shadow = Color(0.20, 0.72, 0.34, 0.14)

	button.add_theme_stylebox_override("normal", _make_panel_style(normal_bg, border, HUD_GLASS_RADIUS, 4, shadow))
	button.add_theme_stylebox_override("hover", _make_panel_style(hover_bg, Color(border.r, border.g, border.b, min(border.a + 0.12, 1.0)), HUD_GLASS_RADIUS, 5, shadow))
	button.add_theme_stylebox_override("pressed", _make_panel_style(pressed_bg, Color(border.r, border.g, border.b, min(border.a + 0.16, 1.0)), HUD_GLASS_RADIUS, 2, Color(0.0, 0.0, 0.0, 0.12)))
	button.add_theme_stylebox_override("disabled", _make_panel_style(Color(0.024, 0.032, 0.034, 0.46), Color(0.58, 0.64, 0.62, 0.14), HUD_GLASS_RADIUS, 1, Color.TRANSPARENT))
	button.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.86, 1.0, 0.84, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.62, 0.68, 0.66, 0.62))
	button.add_theme_constant_override("h_separation", 4)

func _make_primary_action_circle_style(
	bg_color: Color,
	border_color: Color,
	radius: int,
	shadow_size: int,
	shadow_color: Color
) -> StyleBoxFlat:
	var style := _make_panel_style(bg_color, border_color, radius, shadow_size, shadow_color)
	style.set_border_width_all(HUD_GLASS_BORDER_WIDTH)
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	return style

func _apply_primary_fishing_action_style(button: Button, target_size: Vector2) -> void:
	var radius := roundi(max(target_size.x, target_size.y) * 0.5)
	var normal_bg := Color(0.014, 0.034, 0.032, 0.70)
	var hover_bg := Color(0.028, 0.064, 0.052, 0.82)
	var pressed_bg := Color(0.036, 0.096, 0.064, 0.90)
	var border := Color(0.68, 0.86, 0.78, 0.30)
	var shadow := Color(0.0, 0.0, 0.0, 0.24)

	if _is_primary_action_signal_active():
		normal_bg = Color(0.048, 0.128, 0.078, 0.86)
		hover_bg = Color(0.070, 0.166, 0.096, 0.94)
		pressed_bg = Color(0.086, 0.214, 0.118, 1.0)
		border = Color(0.68, 1.0, 0.72, 0.58)
		shadow = Color(0.20, 0.72, 0.34, 0.18)

	button.custom_minimum_size = target_size
	button.size = target_size
	button.add_theme_stylebox_override("normal", _make_primary_action_circle_style(normal_bg, border, radius, 4, shadow))
	button.add_theme_stylebox_override("hover", _make_primary_action_circle_style(hover_bg, Color(border.r, border.g, border.b, min(border.a + 0.10, 1.0)), radius, 6, shadow))
	button.add_theme_stylebox_override("pressed", _make_primary_action_circle_style(pressed_bg, Color(border.r, border.g, border.b, min(border.a + 0.16, 1.0)), radius, 2, Color(0.0, 0.0, 0.0, 0.16)))
	button.add_theme_stylebox_override("disabled", _make_primary_action_circle_style(Color(1.0, 1.0, 1.0, 0.020), Color(1.0, 1.0, 1.0, 0.34), radius, 1, Color.TRANSPARENT))
	button.add_theme_stylebox_override("focus", _make_primary_action_circle_style(Color(1.0, 1.0, 1.0, 0.075), Color(1.0, 1.0, 1.0, 0.92), radius, 6, shadow))
	button.add_theme_color_override("font_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_disabled_color", Color.TRANSPARENT)
	button.add_theme_color_override("icon_normal_color", Color(1.0, 1.0, 1.0, 0.95))
	button.add_theme_color_override("icon_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_color_override("icon_pressed_color", Color(1.0, 1.0, 1.0, 0.88))
	button.add_theme_color_override("icon_disabled_color", Color(1.0, 1.0, 1.0, 0.44))
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_constant_override("h_separation", 0)

func _apply_stop_fishing_button_symbol_style(button: Button, edge: float) -> void:
	button.text = "X"
	button.icon = null
	button.expand_icon = false
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.clip_text = false
	button.add_theme_font_size_override("font_size", roundi(edge * 0.54))
	button.add_theme_color_override("font_color", Color(0.98, 1.0, 0.96, 0.96))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.86, 1.0, 0.90, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(1.0, 1.0, 1.0, 0.38))
	button.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.42))
	button.add_theme_constant_override("outline_size", 1)
	button.add_theme_constant_override("h_separation", 0)

func _apply_weather_hud_panel_style(panel: Panel) -> void:
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

func _apply_weather_hud_text_style(ui_scale: float = 1.0) -> void:
	if clock_label != null:
		clock_label.add_theme_font_size_override("font_size", int(clampf(15.0 * ui_scale, 13.0, 17.0)))
		clock_label.add_theme_color_override("font_color", Color(0.94, 0.98, 0.92, 1.0))
		_apply_hud_text_shadow(clock_label, 1)
	if weather_label != null:
		weather_label.add_theme_font_size_override("font_size", int(clampf(15.0 * ui_scale, 13.0, 17.0)))
		weather_label.add_theme_color_override("font_color", Color(0.94, 0.98, 0.92, 1.0))
		_apply_hud_text_shadow(weather_label, 1)
	if wind_label != null:
		wind_label.add_theme_font_size_override("font_size", int(clampf(14.0 * ui_scale, 12.0, 16.0)))
		wind_label.add_theme_color_override("font_color", Color(0.88, 0.96, 1.0, 1.0))
		_apply_hud_text_shadow(wind_label, 1)

func _apply_label_style(label: Label, primary: bool = false) -> void:
	ui_theme.apply_label_style(label, "title" if primary else "body")

func _make_scene_shader_material(shader_code: String) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = shader_code

	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _create_time_of_day_overlay(node_name: String, z: int, material: ShaderMaterial) -> ColorRect:
	var overlay := ColorRect.new()
	overlay.name = node_name
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_as_relative = false
	overlay.z_index = z
	overlay.color = Color.WHITE
	overlay.material = material
	add_child(overlay)
	return overlay

func _ensure_time_of_day_layers() -> void:
	if day_night_controller != null:
		_hide_time_of_day_layers()
		return

	if time_color_overlay == null:
		time_color_overlay = _create_time_of_day_overlay("TimeColorOverlay", -99, _make_time_color_material())
	if time_stars_overlay == null:
		time_stars_overlay = _create_time_of_day_overlay("TimeStarsOverlay", -98, _make_time_stars_material())
	if time_celestial_overlay == null:
		time_celestial_overlay = _create_time_of_day_overlay("TimeCelestialOverlay", -97, _make_time_celestial_material())
	if time_vignette_overlay == null:
		time_vignette_overlay = _create_time_of_day_overlay("TimeVignetteOverlay", -96, _make_time_vignette_material())

func _layout_time_of_day_layers(_screen_size: Vector2) -> void:
	if day_night_controller != null:
		_hide_time_of_day_layers()
		return

	for overlay in [
		time_color_overlay,
		time_stars_overlay,
		time_celestial_overlay,
		time_vignette_overlay
	]:
		if overlay == null:
			continue
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.offset_left = 0.0
		overlay.offset_top = 0.0
		overlay.offset_right = 0.0
		overlay.offset_bottom = 0.0
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.visible = true

func _hide_time_of_day_layers() -> void:
	for overlay in [
		time_color_overlay,
		time_stars_overlay,
		time_celestial_overlay,
		time_vignette_overlay
	]:
		if overlay != null:
			overlay.visible = false

func _disable_legacy_environment_visuals() -> void:
	for layer in [
		scene_gradient,
		noise_layer,
		sun_glow_layer,
		far_forest_layer,
		mid_forest_layer,
		lake_layer,
		reflection_layer,
		vignette_layer,
		water_panel,
		lake_bg_base_rect,
		lake_bg_foreground_rect,
		water_overlay_rect
	]:
		if layer == null:
			continue
		layer.visible = false
		if layer is Control:
			(layer as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE

func _make_time_color_material() -> ShaderMaterial:
	return _make_scene_shader_material("""
		shader_type canvas_item;

		uniform vec4 sky_tint : source_color = vec4(0.03, 0.06, 0.12, 0.18);
		uniform vec4 water_tint : source_color = vec4(0.02, 0.05, 0.08, 0.20);
		uniform vec4 horizon_tint : source_color = vec4(1.0, 0.56, 0.22, 0.0);
		uniform float horizon_y = 0.47;

		void fragment() {
			float water_mask = smoothstep(horizon_y - 0.04, horizon_y + 0.18, UV.y);
			vec4 tint = mix(sky_tint, water_tint, water_mask);
			float horizon_band = (1.0 - smoothstep(0.0, 0.13, abs(UV.y - horizon_y))) * horizon_tint.a;
			vec3 color = mix(tint.rgb, horizon_tint.rgb, clamp(horizon_band, 0.0, 1.0));
			float alpha = clamp(max(tint.a, horizon_band * 0.82), 0.0, 0.88);
			COLOR = vec4(color, alpha);
		}
	""")

func _make_time_celestial_material() -> ShaderMaterial:
	return _make_scene_shader_material("""
		shader_type canvas_item;

		uniform vec2 body_pos = vec2(0.22, 0.34);
		uniform vec4 body_color : source_color = vec4(1.0, 0.78, 0.42, 1.0);
		uniform vec4 glow_color : source_color = vec4(1.0, 0.54, 0.22, 1.0);
		uniform vec4 reflection_color : source_color = vec4(1.0, 0.68, 0.32, 1.0);
		uniform float body_radius = 0.018;
		uniform float body_alpha = 0.34;
		uniform float glow_radius = 0.22;
		uniform float glow_alpha = 0.16;
		uniform float reflection_alpha = 0.12;
		uniform float horizon_y = 0.47;

		void fragment() {
			float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
			vec2 to_body = UV - body_pos;
			to_body.x *= aspect;
			float dist_to_body = length(to_body);
			float glow = (1.0 - smoothstep(body_radius, glow_radius, dist_to_body)) * glow_alpha;
			float body = (1.0 - smoothstep(body_radius * 0.72, body_radius, dist_to_body)) * body_alpha;

			float water = smoothstep(horizon_y, horizon_y + 0.10, UV.y);
			float bottom_fade = 1.0 - smoothstep(0.82, 1.0, UV.y);
			float lane = (1.0 - smoothstep(0.0, 0.18, abs(UV.x - body_pos.x))) * water * bottom_fade;
			float ripple = 0.62 + sin(UV.y * 132.0 + UV.x * 24.0 + TIME * 0.45) * 0.16;
			float reflection = lane * ripple * reflection_alpha;

			vec3 color = glow_color.rgb;
			color = mix(color, body_color.rgb, clamp(body * 2.2, 0.0, 1.0));
			color = mix(color, reflection_color.rgb, clamp(reflection * 2.4, 0.0, 1.0));
			float alpha = clamp(max(glow, body) + reflection, 0.0, 0.92);
			COLOR = vec4(color, alpha);
		}
	""")

func _make_time_stars_material() -> ShaderMaterial:
	return _make_scene_shader_material("""
		shader_type canvas_item;

		uniform float star_alpha = 0.0;
		uniform float horizon_y = 0.47;
		uniform vec4 star_color : source_color = vec4(0.84, 0.95, 1.0, 1.0);

		float rand(vec2 value) {
			return fract(sin(dot(value, vec2(12.9898, 78.233))) * 43758.5453);
		}

		void fragment() {
			vec2 cell = floor(UV * vec2(92.0, 46.0));
			vec2 local = fract(UV * vec2(92.0, 46.0));
			float seed = rand(cell);
			vec2 star_pos = vec2(rand(cell + 4.7), rand(cell + 9.3));
			float point = 1.0 - smoothstep(0.0, 0.055, distance(local, star_pos));
			float star_mask = step(0.985, seed);
			float sky_mask = 1.0 - smoothstep(horizon_y - 0.12, horizon_y + 0.02, UV.y);
			float twinkle = 0.72 + sin(TIME * 0.8 + seed * 18.0) * 0.20;
			float alpha = point * star_mask * sky_mask * twinkle * star_alpha;
			COLOR = vec4(star_color.rgb, alpha);
		}
	""")

func _make_time_vignette_material() -> ShaderMaterial:
	return _make_scene_shader_material("""
		shader_type canvas_item;

		uniform vec4 vignette_color : source_color = vec4(0.0, 0.025, 0.045, 1.0);
		uniform float vignette_alpha = 0.22;

		void fragment() {
			float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
			vec2 centered = UV * 2.0 - 1.0;
			centered.x *= aspect;
			float edge = smoothstep(0.58, 1.22, length(centered));
			float top = (1.0 - smoothstep(0.00, 0.34, UV.y)) * 0.32;
			float bottom = smoothstep(0.58, 1.0, UV.y) * 0.38;
			float alpha = clamp((edge + top + bottom) * vignette_alpha, 0.0, 0.78);
			COLOR = vec4(vignette_color.rgb, alpha);
		}
	""")

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
		uniform vec4 glow_tint : source_color = vec4(0.84, 1.0, 0.72, 1.0);
		uniform float glow_power = 1.0;
		void fragment() {
			vec2 uv = UV - vec2(0.5);
			float pulse = 0.90 + sin(TIME * 1.35) * 0.08;
			float glow = 1.0 - smoothstep(0.0, 0.48, length(uv));
			float core = 1.0 - smoothstep(0.0, 0.18, length(uv));
			COLOR = vec4(glow_tint.rgb, (glow * 0.34 + core * 0.14) * pulse * glow_power);
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
			vec2 uv = (UV - vec2(0.5)) * vec2(1.0, 2.60);
			float d = length(uv);
			float ring = 1.0 - smoothstep(0.015, 0.035, abs(d - 0.32));
			float ring2 = 1.0 - smoothstep(0.018, 0.040, abs(d - 0.49));
			float pulse = 0.72 + sin(TIME * 1.25) * 0.18;
			COLOR = vec4(0.80, 1.0, 0.92, (ring * 0.26 + ring2 * 0.12) * pulse);
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
			uv.x *= 1.0;
			float pulse = 0.64 + sin(TIME * 0.95) * 0.08;
			float glow = 1.0 - smoothstep(0.10, 0.58, length(uv));
			COLOR = vec4(1.0, 1.0, 1.0, glow * 0.075 * pulse);
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

func _setup_cinematic_environment_materials() -> void:
	scene_gradient.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV;
			float horizon = 0.455;
			float sky = 1.0 - smoothstep(0.05, horizon + 0.12, uv.y);
			float water = smoothstep(horizon - 0.03, 0.98, uv.y);
			vec3 zenith = vec3(0.045, 0.150, 0.205);
			vec3 warm_horizon = vec3(0.510, 0.500, 0.335);
			vec3 deep_water = vec3(0.025, 0.105, 0.135);
			vec3 near_water = vec3(0.070, 0.245, 0.255);
			float sun_warmth = 1.0 - smoothstep(0.0, 0.58, distance(uv, vec2(0.155, 0.245)));
			vec3 sky_color = mix(warm_horizon, zenith, smoothstep(0.02, horizon, uv.y));
			sky_color += vec3(0.38, 0.23, 0.10) * sun_warmth * 0.34;
			vec3 water_color = mix(near_water, deep_water, smoothstep(horizon, 1.0, uv.y));
			float reflection = (1.0 - smoothstep(0.0, 0.22, abs(uv.x - 0.19))) * smoothstep(horizon, 0.66, uv.y) * (1.0 - smoothstep(0.78, 1.0, uv.y));
			water_color += vec3(0.52, 0.42, 0.22) * reflection * 0.34;
			vec3 color = mix(sky_color, water_color, water);
			COLOR = vec4(color, 1.0);
		}
	""")

	sun_glow_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV;
			float sun = 1.0 - smoothstep(0.0, 0.22, distance(uv, vec2(0.145, 0.28)));
			float bloom = 1.0 - smoothstep(0.0, 0.58, distance(uv, vec2(0.16, 0.30)));
			float water_path = (1.0 - smoothstep(0.0, 0.14, abs(uv.x - 0.18))) * smoothstep(0.47, 0.60, uv.y) * (1.0 - smoothstep(0.78, 1.0, uv.y));
			vec3 color = vec3(1.0, 0.78, 0.43);
			COLOR = vec4(color, sun * 0.34 + bloom * 0.13 + water_path * 0.12);
		}
	""")

	far_forest_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		float ridge(float x, float scale, float shift) {
			return sin(x * scale + shift) * 0.025 + sin(x * scale * 0.43 + shift * 1.7) * 0.038;
		}
		void fragment() {
			vec2 uv = UV;
			float ridge_a = 0.320 + ridge(uv.x, 12.0, 0.2);
			float ridge_b = 0.380 + ridge(uv.x, 20.0, 2.1);
			float mountains = smoothstep(ridge_a - 0.012, ridge_a + 0.014, uv.y) * (1.0 - smoothstep(0.48, 0.62, uv.y));
			float rear = smoothstep(ridge_b - 0.014, ridge_b + 0.014, uv.y) * (1.0 - smoothstep(0.51, 0.68, uv.y));
			vec3 color = mix(vec3(0.090, 0.155, 0.150), vec3(0.035, 0.085, 0.078), uv.y);
			COLOR = vec4(color, max(mountains * 0.58, rear * 0.46));
		}
	""")

	mid_forest_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		float random(vec2 value) {
			return fract(sin(dot(value, vec2(12.9898, 78.233))) * 43758.5453);
		}
		float forest_ridge(float x) {
			return sin(x * 38.0) * 0.014 + sin(x * 67.0 + 0.7) * 0.010;
		}
		void fragment() {
			vec2 uv = UV;
			float shoreline = 0.448 + forest_ridge(uv.x);
			float cell = floor(uv.x * 155.0);
			float seed = random(vec2(cell, 3.7));
			float tree_height = 0.035 + seed * 0.105;
			float local_x = abs(fract(uv.x * 155.0) - 0.5);
			float crown = smoothstep(0.36, 0.03, local_x) * smoothstep(shoreline - tree_height, shoreline - tree_height * 0.30, uv.y) * (1.0 - smoothstep(shoreline - 0.01, shoreline + 0.02, uv.y));
			float forest_body = smoothstep(shoreline - 0.018, shoreline + 0.012, uv.y) * (1.0 - smoothstep(0.56, 0.72, uv.y));
			float side_depth = smoothstep(0.80, 1.0, uv.x) + (1.0 - smoothstep(0.0, 0.20, uv.x));
			vec3 color = mix(vec3(0.035, 0.105, 0.078), vec3(0.015, 0.055, 0.044), uv.y);
			color = mix(color, vec3(0.020, 0.075, 0.044), side_depth * 0.46);
			COLOR = vec4(color, max(forest_body * 0.72, crown * 0.88));
		}
	""")

	lake_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV;
			float water_mask = smoothstep(0.455, 0.505, uv.y);
			float depth = smoothstep(0.48, 1.0, uv.y);
			float wave_a = sin(uv.x * 54.0 + uv.y * 18.0 + TIME * 0.58) * 0.5 + 0.5;
			float wave_b = sin(uv.x * 126.0 - uv.y * 12.0 - TIME * 0.36) * 0.5 + 0.5;
			float horizon_fog = 1.0 - smoothstep(0.47, 0.60, uv.y);
			float sun_path = (1.0 - smoothstep(0.0, 0.20, abs(uv.x - 0.18))) * smoothstep(0.47, 0.64, uv.y) * (1.0 - smoothstep(0.80, 0.98, uv.y));
			float side_shadow = smoothstep(0.72, 1.0, uv.x) * 0.38 + (1.0 - smoothstep(0.0, 0.18, uv.x)) * 0.24;
			vec3 shallow = vec3(0.090, 0.275, 0.255);
			vec3 deep = vec3(0.018, 0.078, 0.112);
			vec3 color = mix(shallow, deep, depth);
			color += vec3(0.085, 0.145, 0.120) * (wave_a * 0.050 + wave_b * 0.030) * depth;
			color += vec3(0.80, 0.62, 0.34) * sun_path * (0.10 + wave_a * 0.09);
			color = mix(color, vec3(0.54, 0.70, 0.64), horizon_fog * 0.17);
			color *= 1.0 - side_shadow;
			COLOR = vec4(color, water_mask * 0.96);
		}
	""")

	reflection_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV;
			float water_mask = smoothstep(0.475, 0.56, uv.y) * (1.0 - smoothstep(0.90, 1.0, uv.y));
			float ripple = sin(uv.y * 160.0 + sin(uv.x * 18.0) * 2.0 + TIME * 0.56) * 0.5 + 0.5;
			float fine = sin(uv.y * 310.0 + uv.x * 32.0 - TIME * 0.32) * 0.5 + 0.5;
			float sun_lane = (1.0 - smoothstep(0.0, 0.23, abs(uv.x - 0.18))) * smoothstep(0.47, 0.67, uv.y) * (1.0 - smoothstep(0.78, 1.0, uv.y));
			float forest_reflection = (smoothstep(0.48, 0.54, uv.y) * (1.0 - smoothstep(0.56, 0.72, uv.y))) * (0.30 + ripple * 0.18);
			vec3 warm = vec3(0.95, 0.78, 0.44);
			vec3 cool = vec3(0.22, 0.42, 0.36);
			float alpha = water_mask * (sun_lane * (0.10 + ripple * 0.08 + fine * 0.025) + forest_reflection * 0.16);
			vec3 color = mix(cool, warm, sun_lane);
			COLOR = vec4(color, alpha);
		}
	""")

	noise_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		float random(vec2 value) {
			return fract(sin(dot(value, vec2(12.9898, 78.233))) * 43758.5453);
		}
		void fragment() {
			vec2 uv = UV;
			float grain = random(floor(uv * 260.0));
			vec2 particle_cell = floor(vec2(uv.x * 34.0, uv.y * 18.0 + TIME * 0.10));
			float seed = random(particle_cell);
			vec2 center = (particle_cell + vec2(seed, random(particle_cell + 2.31))) / vec2(34.0, 18.0);
			center.y = fract(center.y - TIME * 0.018);
			float sparkle = 1.0 - smoothstep(0.001, 0.006, distance(uv, center));
			float focus = smoothstep(0.10, 0.54, uv.y) * (1.0 - smoothstep(0.92, 1.0, uv.y));
			vec3 color = mix(vec3(0.0, 0.018, 0.020), vec3(0.74, 0.88, 0.74), grain);
			COLOR = vec4(color, 0.014 + sparkle * focus * 0.13);
		}
	""")

	vignette_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV - vec2(0.48, 0.52);
			float edge = smoothstep(0.38, 0.76, length(uv));
			float bottom = smoothstep(0.72, 1.0, UV.y);
			float top = 1.0 - smoothstep(0.0, 0.18, UV.y);
			COLOR = vec4(0.0, 0.012, 0.015, edge * 0.35 + bottom * 0.18 + top * 0.08);
		}
	""")

func _apply_gameplay_screen_composition(screen_size: Vector2) -> void:
	_ensure_compact_hud_panels()
	_ensure_mobile_ui_containers()
	_ensure_cast_button_visual()
	_ensure_cast_power_indicator()
	_ensure_stop_fishing_button()
	_ensure_float_bite_preview()
	_ensure_depth_hud_controls()
	_ensure_keepnet_hud_button()
	_ensure_player_xp_hud()
	_ensure_hud_icons()
	_ensure_condition_hud()
	_ensure_current_tackle_hud_nodes()

	var sx: float = screen_size.x / BASE_SCREEN_SIZE.x
	var sy: float = screen_size.y / BASE_SCREEN_SIZE.y
	var ui_scale: float = min(sx, sy)
	var top_height: float = clampf(40.0 * ui_scale, 34.0, 42.0)
	var cast_button_edge: float = clampf(106.0 * ui_scale, 88.0, 116.0)
	var cast_button_size := Vector2(cast_button_edge, cast_button_edge)
	_water_surface_y = WATER_SURFACE_Y * sy
	_water_zone_top = _water_surface_y - 12.0 * sy
	_water_zone_bottom = _water_surface_y + 12.0 * sy
	_rod_anchor_pos = _get_adaptive_rod_anchor(screen_size, ui_scale)
	_rod_target_pos = _get_adaptive_rod_tip(screen_size, sy)

	water_panel.position = Vector2.ZERO
	water_panel.size = screen_size
	water_panel.z_index = 0
	water_panel.visible = false
	water_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	water_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color(0.020, 0.080, 0.090, 0.04), Color(0.78, 0.96, 0.88, 0.06), 0, 0, Color.TRANSPARENT)
	)

	left_hud_panel.visible = false
	right_hud_panel.visible = false
	timer_label.visible = false
	tackle_label.visible = false
	result_label.visible = false
	debug_panel.visible = BuildConfig.ENABLE_DEBUG_PANEL

	var hud_rect := _scale_rect(Rect2(18.0, 14.0, 560.0, HUD_HEIGHT), screen_size)
	hud_rect.size.x = clampf(560.0 * ui_scale, 470.0, max(470.0, screen_size.x - hud_rect.position.x - 250.0 * ui_scale))
	hud_rect.size.y = top_height
	_anchor_control(top_hud_panel, 0.0, 0.0, 0.0, 0.0, hud_rect.position.x, hud_rect.position.y, hud_rect.end.x, hud_rect.end.y)
	top_hud_panel.visible = false
	top_hud_panel.custom_minimum_size = hud_rect.size
	top_hud_panel.size = hud_rect.size
	top_hud_panel.z_index = 99
	top_hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_hud_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_anchor_control(top_hud_container, 0.0, 0.0, 0.0, 0.0, hud_rect.position.x, hud_rect.position.y, hud_rect.end.x, hud_rect.end.y)
	top_hud_container.z_index = 100
	top_hud_container.add_theme_constant_override("separation", int(clampf(18.0 * ui_scale, 14.0, 22.0)))
	top_hud_spacer.custom_minimum_size = Vector2(1.0, 1.0)

	time_hud_panel.visible = false
	time_hud_panel.custom_minimum_size = Vector2.ZERO
	time_hud_panel.size = Vector2.ZERO
	time_hud_panel.z_index = 100
	if weather_hud_row != null:
		weather_hud_row.visible = false

	weather_hud_panel.visible = false
	weather_hud_panel.custom_minimum_size = Vector2.ZERO

	title_label.visible = false
	level_label.visible = false
	xp_progress_bar.visible = false
	var hud_icon_edge := clampf(26.0 * ui_scale, 23.0, 29.0)
	var hud_icon_size := Vector2(hud_icon_edge, hud_icon_edge)
	var group_height := maxf(top_height, hud_icon_edge)
	for group in [top_hud_money_group, top_hud_time_group, top_hud_temperature_group, top_hud_wind_group]:
		if group == null:
			continue
		group.visible = true
		group.custom_minimum_size = Vector2(0.0, group_height)
		group.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		group.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		group.alignment = BoxContainer.ALIGNMENT_BEGIN
		group.add_theme_constant_override("separation", int(clampf(5.0 * ui_scale, 4.0, 7.0)))

	money_label.visible = true
	money_label.z_index = 102
	money_label.custom_minimum_size = Vector2(clampf(68.0 * ui_scale, 58.0, 86.0), group_height)
	money_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	money_label.size_flags_vertical = Control.SIZE_FILL
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	money_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	money_label.add_theme_font_size_override("font_size", int(clampf(16.0 * ui_scale, 14.0, 18.0)))
	money_label.add_theme_color_override("font_color", Color(0.94, 0.98, 0.92, 1.0))
	_apply_hud_text_shadow(money_label, 1)
	money_label.clip_text = true

	clock_label.visible = true
	clock_label.z_index = 102
	clock_label.custom_minimum_size = Vector2(clampf(58.0 * ui_scale, 52.0, 70.0), group_height)
	clock_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	clock_label.size_flags_vertical = Control.SIZE_FILL
	clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	clock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	clock_label.clip_text = true

	weather_label.visible = true
	weather_label.z_index = 102
	weather_label.custom_minimum_size = Vector2(clampf(56.0 * ui_scale, 48.0, 70.0), group_height)
	weather_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	weather_label.size_flags_vertical = Control.SIZE_FILL
	weather_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	weather_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	weather_label.clip_text = true
	if wind_label != null:
		wind_label.visible = true
		wind_label.z_index = 102
		wind_label.custom_minimum_size = Vector2(clampf(92.0 * ui_scale, 82.0, 118.0), group_height)
		wind_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		wind_label.size_flags_vertical = Control.SIZE_FILL
		wind_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		wind_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		wind_label.clip_text = true
	_apply_weather_hud_text_style(ui_scale)

	if money_hud_icon != null:
		money_hud_icon.visible = true
		money_hud_icon.custom_minimum_size = hud_icon_size
		money_hud_icon.size = hud_icon_size
		money_hud_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		money_hud_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		money_hud_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		money_hud_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		money_hud_icon.modulate = Color(1.0, 1.0, 1.0, 0.96)
	if time_hud_icon != null:
		time_hud_icon.visible = true
		time_hud_icon.custom_minimum_size = hud_icon_size
		time_hud_icon.size = hud_icon_size
		time_hud_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		time_hud_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		time_hud_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		time_hud_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		time_hud_icon.modulate = Color(1.0, 1.0, 1.0, 0.92)
	if weather_hud_icon != null:
		weather_hud_icon.custom_minimum_size = hud_icon_size
		weather_hud_icon.size = hud_icon_size
		weather_hud_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		weather_hud_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		weather_hud_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		weather_hud_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		weather_hud_icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if wind_hud_icon != null:
		wind_hud_icon.custom_minimum_size = hud_icon_size
		wind_hud_icon.size = hud_icon_size
		wind_hud_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		wind_hud_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		wind_hud_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		wind_hud_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		wind_hud_icon.modulate = Color(1.0, 1.0, 1.0, 0.94)
	_order_weather_hud_row_children()
	_layout_condition_hud(screen_size, ui_scale)
	_refresh_condition_hud()

	spot_option_button.visible = false
	spot_option_button.disabled = true
	spot_option_button.custom_minimum_size = Vector2.ZERO
	spot_option_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	spot_option_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	action_panel.visible = false
	var action_panel_rect := _scale_rect(Rect2(150.0, 424.0, 660.0, 104.0), screen_size)
	_anchor_control(action_panel, 0.0, 0.0, 0.0, 0.0, action_panel_rect.position.x, action_panel_rect.position.y, action_panel_rect.end.x, action_panel_rect.end.y)
	action_panel.z_index = 100
	action_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color.TRANSPARENT, Color.TRANSPARENT, 0, 0, Color.TRANSPARENT)
	)

	quick_actions_container.visible = false
	if quick_tackle_panel != null:
		_reparent_node(quick_tackle_panel, ui_canvas_layer)

	var cast_center := _scale_point(CAST_CONTROL_CENTER_BASE + Vector2(18.0, 22.0), screen_size)
	var cast_margin: float = 8.0 * ui_scale
	var cast_min_x: float = cast_button_size.x * 0.5 + cast_margin
	var cast_max_x: float = max(cast_min_x, screen_size.x - cast_button_size.x * 0.5 - cast_margin)
	var cast_min_y: float = cast_button_size.y * 0.5 + cast_margin
	var cast_max_y: float = max(cast_min_y, screen_size.y - cast_button_size.y * 0.5 - cast_margin)
	cast_center.x = clamp(cast_center.x, cast_min_x, cast_max_x)
	cast_center.y = clamp(cast_center.y, cast_min_y, cast_max_y)
	var cast_rect := Rect2(cast_center - cast_button_size * 0.5, cast_button_size)
	_layout_player_xp_hud(screen_size, ui_scale)
	var glow_rect := cast_rect.grow(8.0 * ui_scale)
	_anchor_control(action_glow, 0.0, 0.0, 0.0, 0.0, glow_rect.position.x, glow_rect.position.y, glow_rect.end.x, glow_rect.end.y)
	action_glow.z_index = 99
	action_glow.visible = _is_primary_action_signal_active()
	action_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for quick_button in [feed_button, bait_button, tackle_button]:
		_reparent_node(quick_button, ui_canvas_layer)
		quick_button.visible = false
		quick_button.disabled = true
		quick_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_anchor_control(fish_button, 0.0, 0.0, 0.0, 0.0, cast_rect.position.x, cast_rect.position.y, cast_rect.end.x, cast_rect.end.y)
	fish_button.z_index = 104
	fish_button.custom_minimum_size = cast_button_size
	fish_button.add_theme_font_size_override("font_size", 12)
	fish_button.clip_text = true
	_apply_primary_fishing_action_style(fish_button, cast_button_size)
	fish_button.custom_minimum_size = cast_button_size
	fish_button.size = cast_button_size
	fish_button.add_theme_font_size_override("font_size", 12)
	if cast_button_visual != null:
		_anchor_control(cast_button_visual, 0.0, 0.0, 0.0, 0.0, cast_rect.position.x, cast_rect.position.y, cast_rect.end.x, cast_rect.end.y)
		cast_button_visual.z_index = 103
		cast_button_visual.size = cast_button_size
	_layout_cast_power_indicator()
	if stop_fishing_button != null:
		var stop_edge: float = clamp(cast_button_size.x * 0.33, 32.0, 46.0)
		var stop_size := Vector2(stop_edge, stop_edge)
		var stop_gap: float = max(8.0, 10.0 * ui_scale)
		var stop_center := Vector2(cast_center.x, cast_rect.position.y - stop_gap - stop_edge * 0.5)
		stop_center.y = clamp(stop_center.y, stop_size.y * 0.5 + cast_margin, screen_size.y - stop_size.y * 0.5 - cast_margin)
		var stop_rect := Rect2(stop_center - stop_size * 0.5, stop_size)
		_anchor_control(stop_fishing_button, 0.0, 0.0, 0.0, 0.0, stop_rect.position.x, stop_rect.position.y, stop_rect.end.x, stop_rect.end.y)
		stop_fishing_button.z_index = 262
		stop_fishing_button.custom_minimum_size = stop_size
		stop_fishing_button.size = stop_size
		_apply_primary_fishing_action_style(stop_fishing_button, stop_size)
		_apply_stop_fishing_button_symbol_style(stop_fishing_button, stop_edge)
	_layout_float_bite_preview(screen_size, ui_scale)

	if keepnet_hud_button != null:
		var keepnet_edge: float = clamp(cast_button_size.x * 0.68, 72.0, 92.0)
		var keepnet_size := Vector2(keepnet_edge, keepnet_edge)
		var quick_panel_button_edge: float = clamp(action_panel_rect.size.y - 8.0 * ui_scale, 88.0, 98.0)
		var quick_panel_button_y: float = action_panel_rect.position.y + max((action_panel_rect.size.y - quick_panel_button_edge) * 0.5, 0.0)
		var keepnet_gap: float = max(10.0, 12.0 * ui_scale)
		var desired_keepnet_x: float = action_panel_rect.position.x - keepnet_gap - keepnet_size.x * 0.5
		var desired_keepnet_y: float = quick_panel_button_y + quick_panel_button_edge * 0.5
		var keepnet_center := Vector2(desired_keepnet_x, desired_keepnet_y)
		var keepnet_min_x: float = keepnet_size.x * 0.5 + cast_margin
		var keepnet_max_x: float = max(keepnet_min_x, screen_size.x - keepnet_size.x * 0.5 - cast_margin)
		var keepnet_min_y: float = keepnet_size.y * 0.5 + cast_margin
		var keepnet_max_y: float = max(keepnet_min_y, screen_size.y - keepnet_size.y * 0.5 - cast_margin)
		keepnet_center.x = clamp(keepnet_center.x, keepnet_min_x, keepnet_max_x)
		keepnet_center.y = clamp(keepnet_center.y, keepnet_min_y, keepnet_max_y)
		var keepnet_rect := Rect2(keepnet_center - keepnet_size * 0.5, keepnet_size)
		_anchor_control(keepnet_hud_button, 0.0, 0.0, 0.0, 0.0, keepnet_rect.position.x, keepnet_rect.position.y, keepnet_rect.end.x, keepnet_rect.end.y)
		keepnet_hud_button.z_index = 260
		keepnet_hud_button.custom_minimum_size = keepnet_size
		keepnet_hud_button.size = keepnet_size
		_update_keepnet_hud_button(false)

	_set_action_button_icon(feed_button, "hud_feed", 19.0)
	_set_action_button_icon(bait_button, "hud_bait", 19.0)
	var primary_icon_size: float = clampf(cast_button_size.x * 0.72, 58.0, 82.0)
	_set_primary_fishing_button_icon(fish_button, _get_primary_fishing_action_icon(), primary_icon_size)
	_set_action_button_icon(tackle_button, "hud_tackle", 19.0)
	_refresh_fish_button_presentation()
	if quick_tackle_panel != null and quick_tackle_panel.has_method("layout"):
		quick_tackle_panel.call("layout", cast_rect, ui_scale)

	bottom_nav_panel.visible = true
	var nav_rect := _scale_rect(Rect2(38.0, 150.0, LEFT_NAV_WIDTH, LEFT_NAV_HEIGHT), screen_size)
	_anchor_control(bottom_nav_panel, 0.0, 0.0, 0.0, 0.0, nav_rect.position.x, nav_rect.position.y, nav_rect.end.x, nav_rect.end.y)
	bottom_nav_panel.z_index = 100
	bottom_nav_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	bottom_nav_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

	_anchor_control(bottom_nav_container, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0)
	bottom_nav_container.visible = true
	bottom_nav_container.mouse_filter = Control.MOUSE_FILTER_PASS
	bottom_nav_container.add_theme_constant_override("separation", int(9.0 * ui_scale))

	nav_fish_button.visible = false
	var side_menu_button_size := _scale_size(Vector2(LEFT_NAV_WIDTH, 48.0), screen_size)
	_layout_side_menu_button(inventory_button, "Инвентарь", "inventory", side_menu_button_size, false)
	_layout_side_menu_button(map_button, "Карта", "map", side_menu_button_size, false)
	for node in [shop_button, harbor_button]:
		node.visible = false
		node.disabled = true
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE

	basket_button.visible = false
	basket_button.disabled = true
	basket_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	inventory_button.disabled = false
	inventory_button.mouse_filter = Control.MOUSE_FILTER_STOP
	map_button.disabled = false
	map_button.mouse_filter = Control.MOUSE_FILTER_STOP
	encyclopedia_button.visible = true
	profile_button.visible = false
	encyclopedia_button.disabled = false
	profile_button.disabled = true
	_layout_main_hud_v2_right_stack(screen_size, ui_scale, cast_button_size)

	var water_anchor := _scale_point(FLOAT_DEFAULT_POS, screen_size)
	_float_base_center = water_anchor
	if not _presence_has_layout or _fishing_ui_state == FishingUiState.IDLE:
		_float_visual_center = water_anchor
		_rod_tip_visual = _rod_target_pos
		_rod_bend_direction_visual = Vector2.DOWN
		_rod_bend_amount_visual = 3.0
		_presence_has_layout = true
	_layout_float_visuals(water_anchor, clamp(screen_size.y / 540.0, 0.86, 1.22))

	var reel_width: float = clamp(screen_size.x * 0.42, 340.0 * sx, 420.0 * sx)
	var reel_height: float = clamp(74.0 * sy, 64.0, 78.0)
	var reel_y: float = max(16.0 * sy + top_height + 10.0 * sy, action_panel_rect.position.y - reel_height - 14.0 * sy)
	var reel_x: float = clamp((screen_size.x - reel_width) * 0.5 - 40.0 * sx, 16.0 * sx, screen_size.x - reel_width - 148.0 * sx)
	_anchor_control(reeling_panel, 0.0, 0.0, 0.0, 0.0, reel_x, reel_y, reel_x + reel_width, reel_y + reel_height)
	reeling_panel.color = Color.TRANSPARENT
	reeling_panel.z_index = 103
	_layout_reeling_panel_frame()
	_set_reeling_panel_visual_state("green", Color(0.36, 0.86, 0.46, 1.0))

	var reel_padding := 14.0
	var reel_inner_width: float = reel_width - reel_padding * 2.0
	fight_title_label.position = Vector2(reel_padding, 7.0)
	fight_title_label.size = Vector2(142.0, 18.0)
	fight_title_label.add_theme_font_size_override("font_size", 11)
	fight_status_label.position = Vector2(reel_padding + 150.0, 7.0)
	fight_status_label.size = Vector2(max(reel_inner_width - 150.0, 80.0), 18.0)
	fight_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fight_status_label.add_theme_font_size_override("font_size", 11)
	tension_label.position = Vector2(reel_padding, 25.0)
	tension_label.size = Vector2(reel_inner_width * 0.5, 14.0)
	tension_label.add_theme_font_size_override("font_size", 11)
	progress_label.position = Vector2(reel_padding + reel_inner_width * 0.5, 25.0)
	progress_label.size = Vector2(reel_inner_width * 0.5, 14.0)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	progress_label.add_theme_font_size_override("font_size", 11)
	tension_track.position = Vector2(reel_padding, 43.0)
	tension_track.size = Vector2(reel_inner_width, 16.0)
	progress_track.position = Vector2(reel_padding, 65.0)
	progress_track.size = Vector2(reel_inner_width, 4.0)
	tension_track.color = Color(0.94, 1.0, 0.96, 0.16)
	ui_theme.apply_meter_track_style(progress_track, progress_fill, Color(0.58, 0.82, 0.28, 1.0))
	fight_hint_label.visible = false

func _get_adaptive_rod_anchor(screen_size: Vector2, _ui_scale: float) -> Vector2:
	var sx: float = screen_size.x / BASE_SCREEN_SIZE.x
	var sy: float = screen_size.y / BASE_SCREEN_SIZE.y
	return Vector2(ROD_ANCHOR_POS.x * sx, ROD_ANCHOR_POS.y * sy)

func _get_adaptive_rod_tip(screen_size: Vector2, sy: float) -> Vector2:
	var sx: float = screen_size.x / BASE_SCREEN_SIZE.x
	return Vector2(ROD_TARGET_POS.x * sx, ROD_TARGET_POS.y * sy)

func _ensure_compact_hud_panels() -> void:
	if time_hud_panel == null:
		time_hud_panel = Panel.new()
		time_hud_panel.name = "TimeHudPanel"
		time_hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		(ui_canvas_layer if ui_canvas_layer != null else self).add_child(time_hud_panel)

	if weather_hud_row == null:
		weather_hud_row = HBoxContainer.new()
		weather_hud_row.name = "WeatherHudRow"
		weather_hud_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		weather_hud_row.alignment = BoxContainer.ALIGNMENT_BEGIN
		time_hud_panel.add_child(weather_hud_row)
	elif weather_hud_row.get_parent() != time_hud_panel:
		_reparent_node(weather_hud_row, time_hud_panel)

	if weather_hud_panel == null:
		weather_hud_panel = Panel.new()
		weather_hud_panel.name = "WeatherHudPanel"
		weather_hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		(ui_canvas_layer if ui_canvas_layer != null else self).add_child(weather_hud_panel)

	if wind_label == null:
		wind_label = Label.new()
		wind_label.name = "WindLabel"
		wind_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wind_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		wind_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		wind_label.clip_text = true
		var wind_parent: Control = top_hud_wind_group if top_hud_wind_group != null else (weather_hud_row if weather_hud_row != null else time_hud_panel)
		wind_parent.add_child(wind_label)
	elif top_hud_wind_group != null and wind_label.get_parent() != top_hud_wind_group:
		_reparent_node(wind_label, top_hud_wind_group)

func _ensure_hud_icons() -> void:
	var money_icon_parent: Control = top_hud_money_group if top_hud_money_group != null else top_hud_panel
	var time_icon_parent: Control = top_hud_time_group if top_hud_time_group != null else (weather_hud_row if weather_hud_row != null else time_hud_panel)
	var weather_icon_parent: Control = top_hud_temperature_group if top_hud_temperature_group != null else time_icon_parent
	var wind_icon_parent: Control = top_hud_wind_group if top_hud_wind_group != null else time_icon_parent
	money_hud_icon = _ensure_hud_icon(money_hud_icon, "MoneyHudIcon", money_icon_parent, "money")
	time_hud_icon = _ensure_hud_icon(time_hud_icon, "TimeHudIcon", time_icon_parent, "time")
	weather_hud_icon = _ensure_hud_icon(weather_hud_icon, "WeatherHudIcon", weather_icon_parent, "weather")
	wind_hud_icon = _ensure_hud_texture_icon(wind_hud_icon, "WindHudIcon", wind_icon_parent, _get_wind_hud_texture())
	if money_hud_icon != null:
		money_hud_icon.visible = false
	if time_hud_icon != null:
		time_hud_icon.visible = false
	_order_weather_hud_row_children()


func _ensure_condition_hud() -> void:
	var parent: Node = ui_canvas_layer if ui_canvas_layer != null else self
	if condition_hud_card == null:
		condition_hud_card = Panel.new()
		condition_hud_card.name = "ConditionHudCard"
		condition_hud_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		condition_hud_card.z_index = 104
		parent.add_child(condition_hud_card)
	elif condition_hud_card.get_parent() != parent:
		_reparent_node(condition_hud_card, parent)
	condition_hud_card.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

	if condition_hud_group == null:
		condition_hud_group = VBoxContainer.new()
		condition_hud_group.name = "ConditionHud"
		condition_hud_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
		condition_hud_group.alignment = BoxContainer.ALIGNMENT_BEGIN
		condition_hud_group.z_index = 105
		condition_hud_group.add_theme_constant_override("separation", 4)
		condition_hud_card.add_child(condition_hud_group)
	elif condition_hud_group.get_parent() != condition_hud_card:
		_reparent_node(condition_hud_group, condition_hud_card)

	condition_health_row = _ensure_condition_hud_row(condition_health_row, "ConditionHealthRow")
	condition_temperature_row = _ensure_condition_hud_row(condition_temperature_row, "ConditionTemperatureRow")
	condition_hunger_row = _ensure_condition_hud_row(condition_hunger_row, "ConditionHungerRow")

	condition_health_icon = _ensure_condition_hud_icon(condition_health_icon, "ConditionHealthIcon", condition_health_row, CONDITION_HEALTH_ICON)
	condition_temperature_icon = _ensure_condition_hud_icon(condition_temperature_icon, "ConditionTemperatureIcon", condition_temperature_row, CONDITION_TEMPERATURE_ICON)
	condition_hunger_icon = _ensure_condition_hud_icon(condition_hunger_icon, "ConditionHungerIcon", condition_hunger_row, CONDITION_HUNGER_ICON)

	condition_health_label = _ensure_condition_hud_label(condition_health_label, "ConditionHealthLabel", condition_health_row)
	condition_temperature_label = _ensure_condition_hud_label(condition_temperature_label, "ConditionTemperatureLabel", condition_temperature_row)
	condition_hunger_label = _ensure_condition_hud_label(condition_hunger_label, "ConditionHungerLabel", condition_hunger_row)


func _ensure_condition_hud_row(row: HBoxContainer, node_name: String) -> HBoxContainer:
	if row == null:
		row = HBoxContainer.new()
		row.name = node_name
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.alignment = BoxContainer.ALIGNMENT_BEGIN
		row.add_theme_constant_override("separation", 7)
		condition_hud_group.add_child(row)
	elif row.get_parent() != condition_hud_group:
		_reparent_node(row, condition_hud_group)
	row.visible = true
	row.z_index = 106
	row.size_flags_horizontal = Control.SIZE_FILL
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return row


func _ensure_condition_hud_icon(icon: TextureRect, node_name: String, row: Control, texture: Texture2D) -> TextureRect:
	if icon == null:
		icon = TextureRect.new()
		icon.name = node_name
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)
	elif icon.get_parent() != row:
		_reparent_node(icon, row)
	icon.texture = texture
	icon.visible = texture != null
	icon.z_index = 107
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.modulate = Color(1.0, 1.0, 1.0, 0.94)
	return icon


func _ensure_condition_hud_label(label: Label, node_name: String, row: Control) -> Label:
	if label == null:
		label = Label.new()
		label.name = node_name
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.clip_text = true
		row.add_child(label)
	elif label.get_parent() != row:
		_reparent_node(label, row)
	label.visible = true
	label.z_index = 106
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_FILL
	_apply_hud_text_shadow(label, 1)
	return label


func _layout_condition_hud(screen_size: Vector2, ui_scale: float) -> void:
	if condition_hud_group == null or condition_hud_card == null:
		return
	var sx: float = screen_size.x / BASE_SCREEN_SIZE.x
	var sy: float = screen_size.y / BASE_SCREEN_SIZE.y
	var card_width := clampf(154.0 * ui_scale, 138.0, 176.0)
	var padding_x := clampf(6.0 * ui_scale, 4.0, 8.0)
	var padding_y := clampf(6.0 * ui_scale, 4.0, 8.0)
	var group_width := card_width - padding_x * 2.0
	var label_height := clampf(24.0 * ui_scale, 22.0, 28.0)
	var item_gap := clampf(4.0 * ui_scale, 3.0, 6.0)
	var group_height := label_height * 3.0 + item_gap * 2.0
	var card_height := group_height + padding_y * 2.0
	var margin_x := clampf(10.0 * sx, 6.0, 14.0)
	var margin_y := clampf(26.0 * sy, 18.0, 34.0)
	var card_pos := Vector2(
		screen_size.x - margin_x - card_width,
		screen_size.y - margin_y - card_height
	)
	_anchor_control(condition_hud_card, 0.0, 0.0, 0.0, 0.0, card_pos.x, card_pos.y, card_pos.x + card_width, card_pos.y + card_height)
	condition_hud_card.visible = true
	condition_hud_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	condition_hud_card.z_index = 104
	condition_hud_card.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_anchor_control(condition_hud_group, 0.0, 0.0, 0.0, 0.0, padding_x, padding_y, padding_x + group_width, padding_y + group_height)
	condition_hud_group.visible = true
	condition_hud_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	condition_hud_group.add_theme_constant_override("separation", int(item_gap))

	var font_size := int(clampf(13.0 * ui_scale, 12.0, 15.0))
	var icon_edge := clampf(21.0 * ui_scale, 19.0, 25.0)
	var icon_gap := int(clampf(7.0 * ui_scale, 6.0, 9.0))
	for row in [condition_health_row, condition_temperature_row, condition_hunger_row]:
		if row == null:
			continue
		row.custom_minimum_size = Vector2(group_width, label_height)
		row.size_flags_horizontal = Control.SIZE_FILL
		row.size_flags_vertical = Control.SIZE_FILL
		row.add_theme_constant_override("separation", icon_gap)
	for icon in [condition_health_icon, condition_temperature_icon, condition_hunger_icon]:
		if icon == null:
			continue
		icon.custom_minimum_size = Vector2(icon_edge, icon_edge)
		icon.size = Vector2(icon_edge, icon_edge)
	for label in [condition_health_label, condition_temperature_label, condition_hunger_label]:
		if label == null:
			continue
		label.custom_minimum_size = Vector2(maxf(group_width - icon_edge - float(icon_gap), 70.0), label_height)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_FILL
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.add_theme_font_size_override("font_size", font_size)
		_apply_hud_text_shadow(label, 1)


func _refresh_condition_hud() -> void:
	if condition_hud_group == null:
		return
	var condition_manager := get_node_or_null("/root/PlayerConditionManager")
	var state := {
		"health": float(PlayerData.health),
		"body_temperature": float(PlayerData.body_temperature),
		"hunger": float(PlayerData.hunger),
		"temperature_status": "normal",
		"hunger_status": "normal",
		"health_status": "normal",
		"wellbeing_status": "normal",
		"wellbeing_label": "Нормально"
	}
	if condition_manager != null and condition_manager.has_method("get_condition_state"):
		var raw_state = condition_manager.call("get_condition_state")
		if raw_state is Dictionary:
			state = (raw_state as Dictionary).duplicate(true)

	var body_temperature := clampf(float(state.get("body_temperature", 36.6)), 30.0, 42.0)
	var hunger := clampf(float(state.get("hunger", 100.0)), 0.0, 100.0)
	var wellbeing_status := str(state.get("wellbeing_status", state.get("health_status", "normal")))
	var wellbeing_label := str(state.get("wellbeing_label", _get_condition_wellbeing_label(wellbeing_status)))

	for icon in [condition_health_icon, condition_temperature_icon, condition_hunger_icon]:
		if icon != null:
			icon.modulate = Color(1.0, 1.0, 1.0, 0.96)

	if condition_health_label != null:
		condition_health_label.text = wellbeing_label
		condition_health_label.add_theme_color_override("font_color", _get_condition_wellbeing_color(wellbeing_status))
	if condition_temperature_label != null:
		condition_temperature_label.text = "%.1f°C" % body_temperature
		condition_temperature_label.add_theme_color_override("font_color", _get_condition_temperature_color(str(state.get("temperature_status", "normal"))))
	if condition_hunger_label != null:
		condition_hunger_label.text = "%d%%" % roundi(hunger)
		condition_hunger_label.add_theme_color_override("font_color", _get_condition_hunger_color(hunger))


func _get_condition_wellbeing_label(status: String) -> String:
	match status:
		"excellent":
			return "Отлично"
		"normal":
			return "Нормально"
		"tired":
			return "Устал"
		"poor":
			return "Плохо"
		_:
			return "Вымотан"


func _get_condition_wellbeing_color(status: String) -> Color:
	match status:
		"excellent":
			return Color(0.78, 1.0, 0.78, 1.0)
		"normal":
			return Color(0.94, 1.0, 0.92, 1.0)
		"tired":
			return Color(1.0, 0.86, 0.38, 1.0)
		"poor":
			return Color(1.0, 0.64, 0.34, 1.0)
		_:
			return Color(1.0, 0.48, 0.30, 1.0)


func _get_condition_temperature_color(status: String) -> Color:
	match status:
		"freezing", "overheating":
			return Color(1.0, 0.28, 0.18, 1.0)
		"cold", "hot":
			return Color(1.0, 0.74, 0.32, 1.0)
		_:
			return Color(0.94, 1.0, 0.98, 1.0)


func _get_condition_hunger_color(value: float) -> Color:
	if value < 10.0:
		return Color(1.0, 0.24, 0.16, 1.0)
	if value < 30.0:
		return Color(1.0, 0.72, 0.30, 1.0)
	return Color(0.95, 1.0, 0.90, 1.0)


func _order_weather_hud_row_children() -> void:
	if top_hud_container != null and top_hud_money_group != null:
		top_hud_container.move_child(top_hud_money_group, 0)
		top_hud_container.move_child(top_hud_time_group, min(1, top_hud_container.get_child_count() - 1))
		top_hud_container.move_child(top_hud_temperature_group, min(2, top_hud_container.get_child_count() - 1))
		top_hud_container.move_child(top_hud_wind_group, min(3, top_hud_container.get_child_count() - 1))
		top_hud_container.move_child(top_hud_spacer, min(4, top_hud_container.get_child_count() - 1))
	if money_hud_icon != null and money_hud_icon.get_parent() == top_hud_money_group:
		top_hud_money_group.move_child(money_hud_icon, 0)
	if money_label != null and money_label.get_parent() == top_hud_money_group:
		top_hud_money_group.move_child(money_label, min(1, top_hud_money_group.get_child_count() - 1))
	if time_hud_icon != null and time_hud_icon.get_parent() == top_hud_time_group:
		top_hud_time_group.move_child(time_hud_icon, 0)
	if clock_label != null and clock_label.get_parent() == top_hud_time_group:
		top_hud_time_group.move_child(clock_label, min(1, top_hud_time_group.get_child_count() - 1))
	if weather_hud_icon != null and weather_hud_icon.get_parent() == top_hud_temperature_group:
		top_hud_temperature_group.move_child(weather_hud_icon, 0)
	if weather_label != null and weather_label.get_parent() == top_hud_temperature_group:
		top_hud_temperature_group.move_child(weather_label, min(1, top_hud_temperature_group.get_child_count() - 1))
	if wind_hud_icon != null and wind_hud_icon.get_parent() == top_hud_wind_group:
		top_hud_wind_group.move_child(wind_hud_icon, 0)
	if wind_label != null and wind_label.get_parent() == top_hud_wind_group:
		top_hud_wind_group.move_child(wind_label, min(1, top_hud_wind_group.get_child_count() - 1))


func _ensure_hud_icon(icon: TextureRect, node_name: String, parent: Control, icon_name: String) -> TextureRect:
	if icon == null:
		icon = TextureRect.new()
		icon.name = node_name
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(icon)
	elif icon.get_parent() != parent:
		_reparent_node(icon, parent)

	icon.texture = ui_theme.get_icon(icon_name)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.z_index = 103
	icon.visible = icon.texture != null
	return icon


func _ensure_hud_texture_icon(icon: TextureRect, node_name: String, parent: Control, texture: Texture2D) -> TextureRect:
	if icon == null:
		icon = TextureRect.new()
		icon.name = node_name
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(icon)
	elif icon.get_parent() != parent:
		_reparent_node(icon, parent)

	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.z_index = 103
	icon.visible = texture != null
	return icon


func _get_wind_hud_texture() -> Texture2D:
	if _wind_hud_texture != null:
		return _wind_hud_texture
	if ResourceLoader.exists(WIND_HUD_ICON_PATH):
		var loaded_texture := ResourceLoader.load(WIND_HUD_ICON_PATH)
		if loaded_texture is Texture2D:
			_wind_hud_texture = loaded_texture
			return _wind_hud_texture
	var image := Image.new()
	if image.load(WIND_HUD_ICON_PATH) == OK:
		_wind_hud_texture = ImageTexture.create_from_image(image)
	return _wind_hud_texture

func _layout_hud_icon(icon: TextureRect, base_pos: Vector2, base_size: Vector2, screen_size: Vector2) -> void:
	if icon == null:
		return

	icon.position = _scale_point(base_pos, screen_size)
	icon.size = _scale_size(base_size, screen_size)

func _scale_point(base_point: Vector2, screen_size: Vector2) -> Vector2:
	return Vector2(
		base_point.x * screen_size.x / BASE_SCREEN_SIZE.x,
		base_point.y * screen_size.y / BASE_SCREEN_SIZE.y
	)

func _scale_size(base_size: Vector2, screen_size: Vector2) -> Vector2:
	return Vector2(
		base_size.x * screen_size.x / BASE_SCREEN_SIZE.x,
		base_size.y * screen_size.y / BASE_SCREEN_SIZE.y
	)

func _scale_rect(base_rect: Rect2, screen_size: Vector2) -> Rect2:
	return Rect2(
		_scale_point(base_rect.position, screen_size),
		_scale_size(base_rect.size, screen_size)
	)

func _anchor_control(
	control: Control,
	anchor_left: float,
	anchor_top: float,
	anchor_right: float,
	anchor_bottom: float,
	offset_left: float,
	offset_top: float,
	offset_right: float,
	offset_bottom: float
) -> void:
	control.anchor_left = anchor_left
	control.anchor_top = anchor_top
	control.anchor_right = anchor_right
	control.anchor_bottom = anchor_bottom
	control.offset_left = offset_left
	control.offset_top = offset_top
	control.offset_right = offset_right
	control.offset_bottom = offset_bottom

func _layout_action_button(button: Button, label: String, pos: Vector2, button_size: Vector2, enabled: bool) -> void:
	button.text = label
	if button.get_parent() is Container:
		button.custom_minimum_size = Vector2(max(button_size.x, 36.0), max(button_size.y, 36.0))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	else:
		_anchor_control(button, 0.0, 0.0, 0.0, 0.0, pos.x, pos.y, pos.x + button_size.x, pos.y + button_size.y)
		button.custom_minimum_size = Vector2(max(button_size.x, 36.0), max(button_size.y, 36.0))
	button.z_index = 102
	button.disabled = not enabled
	button.clip_text = true
	button.add_theme_font_size_override("font_size", 11)
	_apply_action_button_style(button, enabled)
	button.custom_minimum_size = button_size
	if not (button.get_parent() is Container):
		button.size = button_size
	button.add_theme_font_size_override("font_size", 11)

func _layout_nav_button(button: Button, label: String, pos: Vector2, button_size: Vector2, active: bool) -> void:
	button.text = label
	if button.get_parent() is Container:
		button.custom_minimum_size = button_size
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	else:
		_anchor_control(button, 0.0, 0.0, 0.0, 0.0, pos.x, pos.y, pos.x + button_size.x, pos.y + button_size.y)
		button.custom_minimum_size = button_size
	button.z_index = 102
	button.visible = true
	button.clip_text = false
	button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	button.add_theme_font_size_override("font_size", 9 if label.length() < 9 else 8)
	_apply_button_style(button, STYLE_BOTTOM_NAV_ACTIVE if active else STYLE_BOTTOM_NAV_BUTTON)
	button.modulate = Color(1.0, 1.0, 1.0, 1.0 if active else 0.86)
	button.add_theme_font_size_override("font_size", 9 if label.length() < 9 else 8)

func _layout_side_menu_button(button: Button, label: String, icon_name: String, button_size: Vector2, active: bool) -> void:
	button.text = ""
	button.icon = null
	button.expand_icon = false
	button.tooltip_text = label
	if button.get_parent() is Container:
		button.custom_minimum_size = button_size
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	else:
		_anchor_control(button, 0.0, 0.0, 0.0, 0.0, button.position.x, button.position.y, button.position.x + button_size.x, button.position.y + button_size.y)
		button.custom_minimum_size = button_size
	button.size = button_size
	button.z_index = 102
	button.visible = true
	button.clip_text = false
	button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	button.add_theme_constant_override("h_separation", 0)
	button.add_theme_constant_override("icon_max_width", 0)

	var icon_rect := _ensure_side_menu_icon(button)
	var scale_factor: float = clamp(button_size.y / 48.0, 0.78, 1.22)
	var icon_edge: float = clamp(min(button_size.x, button_size.y) * 0.86, 42.0 * scale_factor, 66.0 * scale_factor)
	var icon_size := Vector2(icon_edge, icon_edge)

	icon_rect.texture = ui_theme.get_side_menu_icon(icon_name)
	icon_rect.position = (button_size - icon_size) * 0.5
	icon_rect.size = icon_size
	icon_rect.visible = icon_rect.texture != null

	var text_label := button.get_node_or_null("SideMenuText") as Label
	if text_label != null:
		text_label.text = ""
		text_label.visible = false

	var arrow_label := button.get_node_or_null("SideMenuArrow") as Label
	if arrow_label != null:
		arrow_label.text = ""
		arrow_label.visible = false

	_refresh_side_menu_button_state(button, active)

func _layout_main_hud_v2_right_stack(screen_size: Vector2, ui_scale: float, cast_button_size: Vector2) -> void:
	var sx: float = screen_size.x / BASE_SCREEN_SIZE.x
	var sy: float = screen_size.y / BASE_SCREEN_SIZE.y
	var margin_x: float = clampf(24.0 * sx, 18.0, 30.0)
	var margin_y: float = clampf(18.0 * sy, 14.0, 24.0)
	var gap: float = clampf(8.0 * ui_scale, 7.0, 10.0)
	var menu_button_size := Vector2(
		clampf(62.0 * ui_scale, 56.0, 76.0),
		clampf(54.0 * ui_scale, 48.0, 66.0)
	)
	var compact_size := Vector2(menu_button_size.y, menu_button_size.y)

	if encyclopedia_button != null:
		var encyclopedia_pos := Vector2(screen_size.x - margin_x - menu_button_size.x - gap - compact_size.x, margin_y)
		_anchor_control(encyclopedia_button, 0.0, 0.0, 0.0, 0.0, encyclopedia_pos.x, encyclopedia_pos.y, encyclopedia_pos.x + compact_size.x, encyclopedia_pos.y + compact_size.y)
		encyclopedia_button.text = ""
		encyclopedia_button.tooltip_text = "Энциклопедия рыб"
		encyclopedia_button.visible = true
		encyclopedia_button.disabled = false
		encyclopedia_button.mouse_filter = Control.MOUSE_FILTER_STOP
		encyclopedia_button.custom_minimum_size = compact_size
		encyclopedia_button.size = compact_size
		encyclopedia_button.clip_contents = true
		encyclopedia_button.z_index = 260
		_apply_top_icon_button_style(encyclopedia_button)
		encyclopedia_button.icon = null
		encyclopedia_button.expand_icon = false
		encyclopedia_button.add_theme_constant_override("icon_max_width", 0)
		var encyclopedia_icon := _ensure_button_overlay_icon(encyclopedia_button, "EncyclopediaIcon")
		var encyclopedia_icon_size := Vector2(
			clampf(compact_size.x * 0.78, 40.0, 52.0),
			clampf(compact_size.y * 0.64, 30.0, 42.0)
		)
		encyclopedia_icon.texture = ui_theme.get_icon("encyclopedia") if ui_theme != null else null
		encyclopedia_icon.position = (compact_size - encyclopedia_icon_size) * 0.5
		encyclopedia_icon.size = encyclopedia_icon_size
		encyclopedia_icon.modulate = Color(0.90, 1.0, 0.94, 0.96)
		encyclopedia_icon.visible = encyclopedia_icon.texture != null
		encyclopedia_button.add_theme_constant_override("h_separation", 0)

	if current_tackle_button != null:
		current_tackle_button.text = ""
		current_tackle_button.tooltip_text = ""
		current_tackle_button.visible = false
		current_tackle_button.disabled = true
		current_tackle_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if current_tackle_popup != null:
		current_tackle_popup.visible = false


func _refresh_side_menu_button_state(button: Button, active: bool) -> void:
	if button == null or ui_theme == null:
		return

	ui_theme.apply_side_menu_button_style(button, active)
	button.modulate = Color(1.0, 1.0, 1.0, 1.0 if active else 0.92)
	var icon_color := Color(1.0, 1.0, 0.94, 1.0) if active else Color(0.94, 0.96, 0.86, 0.92)

	var icon_rect := button.get_node_or_null("SideMenuIcon") as TextureRect
	if icon_rect != null:
		icon_rect.modulate = icon_color if not button.disabled else Color(0.60, 0.64, 0.58, 0.48)

	var text_label := button.get_node_or_null("SideMenuText") as Label
	if text_label != null:
		text_label.visible = false

	var arrow_label := button.get_node_or_null("SideMenuArrow") as Label
	if arrow_label != null:
		arrow_label.visible = false

func _ensure_side_menu_icon(button: Button) -> TextureRect:
	var icon_rect := button.get_node_or_null("SideMenuIcon") as TextureRect
	if icon_rect == null:
		icon_rect = TextureRect.new()
		icon_rect.name = "SideMenuIcon"
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		button.add_child(icon_rect)
	return icon_rect

func _ensure_button_overlay_icon(button: Button, node_name: String) -> TextureRect:
	var icon_rect := button.get_node_or_null(node_name) as TextureRect
	if icon_rect == null:
		icon_rect = TextureRect.new()
		icon_rect.name = node_name
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.z_index = 1
		button.add_child(icon_rect)
	return icon_rect

func _set_button_icon(button: Button, icon_name: String, icon_size: float = 20.0) -> void:
	if ui_theme == null or icon_name.is_empty():
		button.icon = null
		return

	button.icon = ui_theme.get_icon(icon_name)
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	button.add_theme_constant_override("icon_max_width", int(icon_size))
	button.add_theme_constant_override("h_separation", 4)

func _set_action_button_icon(button: Button, icon_name: String, icon_size: float = 18.0) -> void:
	if ui_theme == null or icon_name.is_empty():
		button.icon = null
		return

	button.icon = ui_theme.get_icon(icon_name)
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.add_theme_constant_override("icon_max_width", int(icon_size))
	button.add_theme_constant_override("h_separation", 7)

func _set_primary_fishing_button_icon(button: Button, icon_name: String, icon_size: float = 26.0) -> void:
	if ui_theme == null or icon_name.is_empty():
		button.icon = null
		return

	button.icon = ui_theme.get_icon(icon_name)
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.add_theme_constant_override("icon_max_width", int(icon_size))
	button.add_theme_constant_override("h_separation", 0)

func _get_primary_fishing_action_icon() -> String:
	match _fishing_ui_state:
		FishingUiState.WAITING:
			return "hud_pull" if _is_reel_tackle_mode() else "hud_hook"
		FishingUiState.FIGHTING:
			return "hud_pull"
		FishingUiState.CAUGHT, FishingUiState.FAILED:
			return "hud_pull_out"
		_:
			return "hud_cast"

func _get_primary_fishing_action_label() -> String:
	match _fishing_ui_state:
		FishingUiState.WAITING:
			if bool(FishingManager.get("use_new_bite_system")) and _presence_bite_timer > 0.0 and not _is_reel_tackle_mode():
				return "Подсечь"
			return "Ждать"
		FishingUiState.FIGHTING:
			return "Борьба"
		FishingUiState.CAUGHT, FishingUiState.FAILED:
			return "Вытянуть"
		_:
			return "Заброс"

func _refresh_fish_button_presentation() -> void:
	if fish_button == null or ui_theme == null:
		return

	var target_size: Vector2 = fish_button.size
	if target_size == Vector2.ZERO:
		var viewport_size := get_viewport_rect().size
		var button_scale: float = min(viewport_size.x / BASE_SCREEN_SIZE.x, viewport_size.y / BASE_SCREEN_SIZE.y)
		var button_edge: float = clampf(106.0 * button_scale, 88.0, 116.0)
		target_size = Vector2(button_edge, button_edge)

	fish_button.visible = true
	fish_button.mouse_filter = Control.MOUSE_FILTER_STOP
	fish_button.z_index = 260
	fish_button.custom_minimum_size = target_size
	fish_button.size = target_size
	if cast_button_visual != null:
		cast_button_visual.z_index = fish_button.z_index - 1
		cast_button_visual.visible = false
	_cast_button_hovered = false
	_apply_primary_fishing_action_style(fish_button, target_size)
	if action_glow != null:
		action_glow.visible = _is_primary_action_signal_active()
	fish_button.add_theme_font_size_override("font_size", int(clampf(min(target_size.x, target_size.y) * 0.135, 14.0, 18.0)))
	fish_button.clip_text = true
	var action_label := _get_primary_fishing_action_label()
	fish_button.text = ""
	fish_button.tooltip_text = action_label
	var icon_size: float = clamp(min(target_size.x, target_size.y) * 0.72, 58.0, 86.0)
	_set_primary_fishing_button_icon(fish_button, _get_primary_fishing_action_icon(), icon_size)
	fish_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	fish_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	fish_button.add_theme_constant_override("h_separation", 0)
	fish_button.add_theme_color_override("font_color", Color(0.90, 1.0, 0.92, 1.0))
	fish_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	fish_button.add_theme_color_override("font_pressed_color", Color(0.78, 1.0, 0.82, 1.0))
	fish_button.add_theme_color_override("font_disabled_color", Color(0.62, 0.70, 0.68, 0.62))
	_apply_primary_action_press_scale()
	_refresh_stop_fishing_button_presentation()
	_refresh_depth_hud_controls()


func _refresh_stop_fishing_button_presentation() -> void:
	if stop_fishing_button == null:
		return

	var should_show := _can_cancel_current_fishing_wait() and not _is_menu_overlay_open()
	stop_fishing_button.visible = should_show
	stop_fishing_button.disabled = not should_show
	if should_show:
		stop_fishing_button.text = "X"


func _request_depth_hud_refresh() -> void:
	if _depth_hud_refresh_queued:
		return
	_depth_hud_refresh_queued = true
	call_deferred("_refresh_depth_hud_after_ui_state_change")


func _refresh_depth_hud_after_ui_state_change() -> void:
	_depth_hud_refresh_queued = false
	if not is_inside_tree():
		return
	if fish_button != null:
		_refresh_fish_button_presentation()
	else:
		_refresh_depth_hud_controls()


func _update_depth_hud_visibility_watchdog(delta: float) -> void:
	if depth_radial_control == null:
		return
	_depth_hud_visibility_check_accumulator += delta
	if _depth_hud_visibility_check_accumulator < 0.15:
		return
	_depth_hud_visibility_check_accumulator = 0.0
	var should_show := _should_show_depth_hud_controls()
	if _is_depth_hud_control_out_of_sync(should_show):
		_refresh_depth_hud_controls()


func _is_depth_hud_control_out_of_sync(should_show: bool) -> bool:
	if depth_radial_control == null:
		return false
	if depth_radial_control.visible != should_show:
		return true
	if not should_show:
		return false
	if fish_button == null or not fish_button.visible or not fish_button.is_visible_in_tree():
		return true
	if depth_radial_control.get_parent() != fish_button:
		return true
	if not depth_radial_control.is_visible_in_tree():
		return true
	if fish_button.icon != null:
		return true
	if not depth_radial_control.size.is_equal_approx(_get_depth_radial_control_size()):
		return true
	return false


func _get_depth_radial_control_size() -> Vector2:
	if fish_button == null:
		return Vector2.ZERO
	return Vector2(fish_button.size.x, fish_button.size.y * 1.36)


func _refresh_depth_hud_controls() -> void:
	_ensure_depth_hud_controls()
	for old_node in [depth_hud_minus_button, depth_hud_plus_button, depth_hud_label]:
		if old_node != null:
			old_node.visible = false
			if old_node is Button:
				(old_node as Button).disabled = true
	if depth_radial_control == null or fish_button == null:
		return

	var should_show: bool = _should_show_depth_hud_controls()
	depth_radial_control.visible = should_show
	depth_radial_control.mouse_filter = Control.MOUSE_FILTER_PASS if should_show else Control.MOUSE_FILTER_IGNORE
	if not should_show:
		if ui_theme != null:
			var restore_icon_size: float = clampf(min(fish_button.size.x, fish_button.size.y) * 0.72, 58.0, 82.0)
			_set_primary_fishing_button_icon(fish_button, _get_primary_fishing_action_icon(), restore_icon_size)
		return

	if depth_radial_control.get_parent() != fish_button:
		_reparent_node(depth_radial_control, fish_button)
	var depth_control_size := _get_depth_radial_control_size()
	_anchor_control(depth_radial_control, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, depth_control_size.x, depth_control_size.y)
	depth_radial_control.size = depth_control_size
	depth_radial_control.z_index = 3
	var depth_range := PlayerData.get_current_spot_depth_range()
	depth_radial_control.set_depth_range(float(depth_range.get("min", 0.2)), float(depth_range.get("max", 6.0)))
	depth_radial_control.set_depth_value(PlayerData.fishing_depth, false)
	depth_radial_control.set_hook_texture(DEPTH_HOOK_ICON)
	if depth_radial_control.has_method("set_draw_depth_text"):
		depth_radial_control.call("set_draw_depth_text", false)
	_layout_depth_hud_value_label()
	fish_button.icon = null
	return

	var viewport_size := get_viewport_rect().size
	var ui_scale: float = min(viewport_size.x / BASE_SCREEN_SIZE.x, viewport_size.y / BASE_SCREEN_SIZE.y)
	var fish_rect := Rect2(fish_button.position, fish_button.size)
	var margin := 8.0 * ui_scale
	var circle_edge: float = clamp(fish_button.size.x * 0.34, 38.0, 48.0)
	var circle_size := Vector2(circle_edge, circle_edge)
	var minus_center := fish_rect.position + Vector2(-28.0 * ui_scale, 28.0 * ui_scale)
	var plus_center := fish_rect.position + Vector2(18.0 * ui_scale, -14.0 * ui_scale)

	minus_center.x = clamp(minus_center.x, circle_edge * 0.5 + margin, viewport_size.x - circle_edge * 0.5 - margin)
	plus_center.x = clamp(plus_center.x, circle_edge * 0.5 + margin, viewport_size.x - circle_edge * 0.5 - margin)
	minus_center.y = clamp(minus_center.y, circle_edge * 0.5 + margin, viewport_size.y - circle_edge * 0.5 - margin)
	plus_center.y = clamp(plus_center.y, circle_edge * 0.5 + margin, viewport_size.y - circle_edge * 0.5 - margin)

	var minus_rect := Rect2(minus_center - circle_size * 0.5, circle_size)
	var plus_rect := Rect2(plus_center - circle_size * 0.5, circle_size)
	_anchor_control(depth_hud_minus_button, 0.0, 0.0, 0.0, 0.0, minus_rect.position.x, minus_rect.position.y, minus_rect.end.x, minus_rect.end.y)
	_anchor_control(depth_hud_plus_button, 0.0, 0.0, 0.0, 0.0, plus_rect.position.x, plus_rect.position.y, plus_rect.end.x, plus_rect.end.y)
	depth_hud_minus_button.size = circle_size
	depth_hud_plus_button.size = circle_size
	depth_hud_minus_button.add_theme_font_size_override("font_size", int(clamp(circle_edge * 0.52, 20.0, 26.0)))
	depth_hud_plus_button.add_theme_font_size_override("font_size", int(clamp(circle_edge * 0.52, 20.0, 26.0)))
	_apply_depth_hud_button_style(depth_hud_minus_button)
	_apply_depth_hud_button_style(depth_hud_plus_button)

	var label_size := Vector2(clamp(78.0 * ui_scale, 70.0, 92.0), clamp(28.0 * ui_scale, 24.0, 32.0))
	var label_pos := plus_rect.position + Vector2(circle_edge + 4.0 * ui_scale, circle_edge * 0.5 - label_size.y * 0.5)
	label_pos.x = clamp(label_pos.x, margin, viewport_size.x - label_size.x - margin)
	label_pos.y = clamp(label_pos.y, margin, viewport_size.y - label_size.y - margin)
	_anchor_control(depth_hud_label, 0.0, 0.0, 0.0, 0.0, label_pos.x, label_pos.y, label_pos.x + label_size.x, label_pos.y + label_size.y)
	depth_hud_label.text = "%.1f м" % PlayerData.fishing_depth
	depth_hud_label.add_theme_font_size_override("font_size", int(clampf(15.0 * ui_scale, 13.0, 17.0)))
	depth_hud_label.add_theme_color_override("font_color", Color(0.94, 0.98, 0.92, 0.98))
	_apply_hud_text_shadow(depth_hud_label, 1)
	depth_hud_label.add_theme_stylebox_override("normal", _make_hud_glass_style(false, HUD_GLASS_RADIUS))


func _layout_depth_hud_value_label() -> void:
	if depth_hud_label == null or fish_button == null:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var ui_scale: float = clampf(min(viewport_size.x / BASE_SCREEN_SIZE.x, viewport_size.y / BASE_SCREEN_SIZE.y), 0.82, 1.24)
	var fish_rect := Rect2(fish_button.position, fish_button.size)
	var margin: float = 8.0 * ui_scale
	var label_size := Vector2(clamp(78.0 * ui_scale, 70.0, 92.0), clamp(30.0 * ui_scale, 26.0, 34.0))
	var label_gap: float = clamp(9.0 * ui_scale, 7.0, 12.0)
	var label_pos := Vector2(
		fish_rect.position.x - label_size.x - label_gap,
		fish_rect.position.y + clamp(7.0 * ui_scale, 6.0, 10.0)
	)
	label_pos.x = clamp(label_pos.x, margin, viewport_size.x - label_size.x - margin)
	label_pos.y = clamp(label_pos.y, margin, viewport_size.y - label_size.y - margin)

	_anchor_control(depth_hud_label, 0.0, 0.0, 0.0, 0.0, label_pos.x, label_pos.y, label_pos.x + label_size.x, label_pos.y + label_size.y)
	depth_hud_label.visible = true
	depth_hud_label.z_index = 263
	depth_hud_label.text = "%.1f м" % PlayerData.fishing_depth
	depth_hud_label.add_theme_font_size_override("font_size", int(clampf(15.0 * ui_scale, 13.0, 17.0)))
	depth_hud_label.add_theme_color_override("font_color", Color(0.94, 0.98, 0.92, 0.98))
	_apply_hud_text_shadow(depth_hud_label, 1)
	depth_hud_label.add_theme_stylebox_override("normal", _make_hud_glass_style(false, HUD_GLASS_RADIUS))


func _update_depth_hud_value_label() -> void:
	if depth_hud_label == null:
		return
	depth_hud_label.text = "%.1f м" % PlayerData.fishing_depth


func _should_show_depth_hud_controls() -> bool:
	if is_cast_animating or _is_catch_reward_open() or _is_menu_overlay_open():
		return false
	if _fishing_ui_state != FishingUiState.IDLE:
		return false
	if not _is_current_tackle_depth_adjustable():
		return false
	return true


func _is_current_tackle_depth_adjustable() -> bool:
	var rod: Dictionary = PlayerData.current_tackle.get("rod", {})
	if rod.is_empty():
		return false
	var rod_id := str(rod.get("id", "")).to_lower()
	var rod_name := str(rod.get("name", "")).to_lower()
	var rod_description := str(rod.get("description", "")).to_lower()
	if rod_id.contains("pole") or rod_id.contains("match"):
		return true
	if rod_name.contains("мах") or rod_name.contains("match") or rod_description.contains("мах"):
		return true
	return str(PlayerData.current_tackle.get("float", {}).get("id", "")) != ""


func get_physical_depth_at_cast_power(cast_power: float, spot_max_depth: float) -> float:
	var safe_max_depth: float = max(spot_max_depth, MIN_SHORE_DEPTH)
	return lerp(MIN_SHORE_DEPTH, safe_max_depth, clamp(cast_power, 0.0, 1.0))


func is_float_depth_valid_for_cast(float_depth: float, water_depth_at_cast: float) -> bool:
	return float_depth <= water_depth_at_cast + DEPTH_TOLERANCE


func is_depth_in_effective_fish_range(depth: float, spot_data: Dictionary) -> bool:
	if spot_data.is_empty():
		return true
	# spot.min_depth / effective_min_depth = рабочая глубина рыбы, not physical shore depth.
	var effective_min_depth: float = float(spot_data.get("min_depth", 0.2))
	var effective_max_depth: float = float(spot_data.get("max_depth", 6.0))
	return depth >= min(effective_min_depth, effective_max_depth) and depth <= max(effective_min_depth, effective_max_depth)


func _build_cast_depth_context(cast_power: float, hold_time: float) -> Dictionary:
	var spot: Dictionary = SpotDatabase.get_spot(PlayerData.current_spot)
	var spot_max_depth: float = PlayerData.fishing_depth
	var spot_min_depth: float = PlayerData.fishing_depth
	var has_spot_min_depth := false
	if not spot.is_empty():
		spot_max_depth = float(spot.get("max_depth", spot.get("depth", PlayerData.fishing_depth)))
		spot_min_depth = float(spot.get("min_depth", spot.get("depth", spot_max_depth)))
		has_spot_min_depth = spot.has("min_depth")

	var cast_modifiers := _get_cast_float_wind_modifiers(spot)
	var raw_power: float = clamp(cast_power, 0.0, 1.0)
	var far_cast_factor: float = clamp((raw_power - 0.55) / 0.45, 0.0, 1.0)
	var safe_power: float = clamp(raw_power + float(cast_modifiers.get("cast_distance_bonus", 0.0)) * 0.55 + float(cast_modifiers.get("long_range_accuracy_bonus", 0.0)) * far_cast_factor * 0.12 - float(cast_modifiers.get("wind_cast_penalty", 0.0)) * 0.20, 0.0, 1.0)
	var water_depth_at_cast := get_physical_depth_at_cast_power(safe_power, spot_max_depth)
	var float_depth := float(PlayerData.fishing_depth)
	var valid := is_float_depth_valid_for_cast(float_depth, water_depth_at_cast)
	return {
		"hold_time": hold_time,
		"raw_cast_power": raw_power,
		"cast_power": safe_power,
		"shore_depth": MIN_SHORE_DEPTH,
		"spot_min_depth": spot_min_depth,
		"spot_max_depth": max(spot_max_depth, MIN_SHORE_DEPTH),
		"has_spot_min_depth": has_spot_min_depth,
		"water_depth_at_cast": water_depth_at_cast,
		"float_depth": float_depth,
		"valid": valid,
		"effective_depth_ok": is_depth_in_effective_fish_range(float_depth, spot),
		"cast_distance_bonus": float(cast_modifiers.get("cast_distance_bonus", 0.0)),
		"long_range_accuracy_bonus": float(cast_modifiers.get("long_range_accuracy_bonus", 0.0)),
		"wind_cast_penalty": float(cast_modifiers.get("wind_cast_penalty", 0.0)),
		"cast_accuracy": float(cast_modifiers.get("cast_accuracy", 1.0))
	}


func _get_cast_float_wind_modifiers(spot: Dictionary) -> Dictionary:
	var float_data: Dictionary = PlayerData.get_current_float_data() if PlayerData.has_method("get_current_float_data") else {}
	var tackle_stats: Dictionary = PlayerData.get_tackle_stats()
	var cast_distance_bonus: float = clamp(float(float_data.get("cast_distance_bonus", 0.0)), -0.20, 0.25)
	var long_range_accuracy_bonus: float = clamp(float(float_data.get("long_range_accuracy_bonus", 0.0)), 0.0, 0.20)
	var setup_comfort: float = clamp(float(float_data.get("setup_comfort", 0.0)), 0.0, 0.20)
	var wind_resistance: float = clamp(float(float_data.get("wind_resistance", 0.65)), 0.0, 1.0)
	var rig_cast_accuracy_multiplier: float = clamp(float(tackle_stats.get("rig_cast_accuracy_multiplier", 1.0)), 0.72, 1.02)
	var rig_cast_distance_bonus: float = clamp(float(tackle_stats.get("rig_cast_distance_bonus", 0.0)), -0.10, 0.0)
	cast_distance_bonus = clamp(cast_distance_bonus + rig_cast_distance_bonus, -0.30, 0.25)
	var wind_state: Dictionary = _get_effective_wind_state_for_spot(str(spot.get("id", PlayerData.current_spot)))
	var wind_speed: float = max(float(wind_state.get("speed_mps", 0.0)), 0.0)
	var wind_cast_penalty: float = max(wind_speed - 2.0, 0.0) / 8.0 * (1.0 - wind_resistance * 0.65)
	var cast_accuracy: float = clamp((1.0 - wind_cast_penalty * 0.20 + cast_distance_bonus * 0.10 + long_range_accuracy_bonus * 0.18 + setup_comfort * 0.08) * rig_cast_accuracy_multiplier, 0.58, 1.14)
	return {
		"cast_distance_bonus": cast_distance_bonus,
		"long_range_accuracy_bonus": long_range_accuracy_bonus,
		"wind_cast_penalty": clamp(wind_cast_penalty, 0.0, 0.60),
		"cast_accuracy": cast_accuracy,
		"rig_cast_accuracy_multiplier": rig_cast_accuracy_multiplier,
		"rig_cast_distance_bonus": rig_cast_distance_bonus
	}


func _get_effective_wind_state_for_spot(spot_id: String) -> Dictionary:
	var wind_manager := get_node_or_null("/root/WindManager")
	if wind_manager != null:
		if wind_manager.has_method("get_effective_wind_state"):
			var effective_state = wind_manager.call("get_effective_wind_state", spot_id)
			if effective_state is Dictionary:
				return (effective_state as Dictionary).duplicate(true)
		if wind_manager.has_method("get_wind_state"):
			var base_state = wind_manager.call("get_wind_state")
			if base_state is Dictionary:
				return (base_state as Dictionary).duplicate(true)
	return {"speed_mps": 0.0, "gust_active": false, "gust_strength": 0.0}


func _debug_log_cast_depth(context: Dictionary) -> void:
	if not BuildConfig.ENABLE_VERBOSE_LOGS:
		return

	var valid := bool(context.get("valid", false))
	print("[CastDepth] hold_time=%.2f, cast_power=%.2f, shore_depth=%.2f, spot_max_depth=%.1f, water_depth_at_cast=%.2f, float_depth=%.1f, valid=%s" % [
		float(context.get("hold_time", 0.0)),
		float(context.get("cast_power", 0.0)),
		float(context.get("shore_depth", MIN_SHORE_DEPTH)),
		float(context.get("spot_max_depth", MIN_SHORE_DEPTH)),
		float(context.get("water_depth_at_cast", MIN_SHORE_DEPTH)),
		float(context.get("float_depth", PlayerData.fishing_depth)),
		"true" if valid else "false"
	])
	if bool(context.get("has_spot_min_depth", false)):
		print("[CastDepth] spot_min_depth=%.1f is treated as effective fish depth, not physical shore depth" % float(context.get("spot_min_depth", 0.0)))
	if valid:
		print("[Cast] valid=true, starting fishing")
	else:
		print("[Cast] invalid: float laid down, bait not consumed")


func _apply_depth_hud_button_style(button: Button) -> void:
	var normal := _make_primary_action_circle_style(Color(0.018, 0.034, 0.036, 0.72), Color(0.70, 0.86, 0.80, 0.28), 24, 4, Color(0.0, 0.0, 0.0, 0.22))
	var hover := _make_primary_action_circle_style(Color(0.034, 0.078, 0.066, 0.84), Color(0.66, 1.0, 0.72, 0.46), 24, 6, Color(0.20, 0.72, 0.34, 0.14))
	var pressed := _make_primary_action_circle_style(Color(0.048, 0.120, 0.076, 0.92), Color(0.72, 1.0, 0.66, 0.58), 24, 2, Color(0.0, 0.0, 0.0, 0.16))
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", Color(0.96, 1.0, 0.92, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.90, 0.56, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.78, 0.32, 1.0))


func _can_cancel_current_fishing_wait() -> bool:
	if is_cast_animating or _is_catch_reward_open():
		return false
	var waiting_ui := _fishing_ui_state == FishingUiState.WAITING
	var fighting_ui := _fishing_ui_state == FishingUiState.FIGHTING
	var manager_waiting := bool(FishingManager.get("is_fishing")) and not bool(FishingManager.get("is_reeling"))
	if waiting_ui and manager_waiting:
		return true
	if fighting_ui and (bool(FishingManager.get("is_fishing")) or bool(FishingManager.get("is_reeling"))):
		return true
	if (waiting_ui or fighting_ui) and FishingManager.has_method("can_cancel_current_fishing"):
		return bool(FishingManager.can_cancel_current_fishing())
	if FishingManager.has_method("can_cancel_current_fishing_wait"):
		return bool(FishingManager.can_cancel_current_fishing_wait())
	return waiting_ui and manager_waiting

func _update_cast_button_visual() -> void:
	if cast_button_visual == null or ui_theme == null:
		return
	_apply_primary_action_press_scale()

	var active_hook_input: bool = _fishing_ui_state == FishingUiState.WAITING and bool(FishingManager.get("use_new_bite_system"))
	var use_cast_texture := _use_cast_png_button and (_fishing_ui_state == FishingUiState.IDLE or (_fishing_ui_state == FishingUiState.WAITING and not active_hook_input))
	var use_pull_texture := _use_pull_png_button and (
		_fishing_ui_state == FishingUiState.FIGHTING
		or _fishing_ui_state == FishingUiState.CAUGHT
		or _fishing_ui_state == FishingUiState.FAILED
	)
	var use_action_texture := use_cast_texture or use_pull_texture
	cast_button_visual.visible = use_action_texture
	if not use_action_texture:
		return

	var texture_state := "regular"
	if fish_button.disabled:
		texture_state = "disabled"
	elif _cast_button_pressed:
		texture_state = "pressed"
	elif _cast_button_hovered:
		texture_state = "hover"

	cast_button_visual.texture = ui_theme.get_pull_button_texture(texture_state) if use_pull_texture else ui_theme.get_cast_button_texture(texture_state)


func _apply_primary_action_press_scale() -> void:
	if fish_button == null:
		return

	var target_scale := 1.0
	if _cast_button_pressed and not fish_button.disabled:
		target_scale = 1.06
	elif _cast_button_hovered and not fish_button.disabled:
		target_scale = 1.035
	fish_button.pivot_offset = fish_button.size * 0.5
	fish_button.scale = Vector2.ONE * target_scale
	if cast_button_visual != null:
		cast_button_visual.pivot_offset = cast_button_visual.size * 0.5
		cast_button_visual.scale = Vector2.ONE * target_scale


func _layout_cast_power_indicator() -> void:
	if cast_power_indicator_track == null or fish_button == null:
		return

	var viewport_size := get_viewport_rect().size
	var ui_scale: float = min(viewport_size.x / BASE_SCREEN_SIZE.x, viewport_size.y / BASE_SCREEN_SIZE.y)
	var bar_size := Vector2(clamp(fish_button.size.x * 0.66, 68.0, 96.0), clamp(7.0 * ui_scale, 5.0, 8.0))
	var gap: float = clamp(8.0 * ui_scale, 6.0, 10.0)
	var bar_pos := fish_button.position + Vector2((fish_button.size.x - bar_size.x) * 0.5, -bar_size.y - gap)
	bar_pos.x = clamp(bar_pos.x, 8.0 * ui_scale, viewport_size.x - bar_size.x - 8.0 * ui_scale)
	bar_pos.y = clamp(bar_pos.y, 8.0 * ui_scale, viewport_size.y - bar_size.y - 8.0 * ui_scale)
	_anchor_control(cast_power_indicator_track, 0.0, 0.0, 0.0, 0.0, bar_pos.x, bar_pos.y, bar_pos.x + bar_size.x, bar_pos.y + bar_size.y)
	cast_power_indicator_track.size = bar_size
	cast_power_indicator_track.z_index = max(fish_button.z_index + 4, 266)


func _update_cast_power_indicator() -> void:
	if cast_power_indicator_track == null or cast_power_indicator_fill == null:
		return

	_layout_cast_power_indicator()
	var inner_margin := 1.5
	var progress: float = clamp(_cast_charge_power, 0.0, 1.0)
	var fill_width: float = max((cast_power_indicator_track.size.x - inner_margin * 2.0) * progress, 0.0)
	cast_power_indicator_fill.position = Vector2(inner_margin, inner_margin)
	cast_power_indicator_fill.size = Vector2(fill_width, max(cast_power_indicator_track.size.y - inner_margin * 2.0, 1.0))
	cast_power_indicator_fill.color = Color(0.72, 1.0, 0.80, lerp(0.68, 1.0, progress))


func _set_cast_power_indicator_visible(visible: bool) -> void:
	_ensure_cast_power_indicator()
	if cast_power_indicator_track != null:
		cast_power_indicator_track.visible = visible
	if visible:
		_update_cast_power_indicator()


func _can_begin_cast_charge() -> bool:
	if fish_button == null or fish_button.disabled:
		return false
	if _should_ignore_base_ui_press() or is_cast_animating:
		return false
	if _fishing_ui_state != FishingUiState.IDLE:
		return false
	return true


func _start_cast_charge() -> void:
	if not _can_begin_cast_charge():
		return
	_close_quick_tackle_radial()
	_cast_charge_active = true
	_cast_charge_hold_time = 0.0
	_cast_charge_power = MIN_CAST_POWER
	_set_cast_power_indicator_visible(true)


func _cancel_cast_charge() -> void:
	_cast_charge_active = false
	_cast_charge_hold_time = 0.0
	_cast_charge_power = MIN_CAST_POWER
	_set_cast_power_indicator_visible(false)


func _update_cast_charge(delta: float) -> void:
	if not _cast_charge_active:
		return
	if not _can_begin_cast_charge():
		_cancel_cast_charge()
		return
	_cast_charge_hold_time += delta
	_cast_charge_power = clamp(_cast_charge_hold_time / CAST_CHARGE_TIME, MIN_CAST_POWER, MAX_CAST_POWER)
	_update_cast_power_indicator()


func _release_cast_charge() -> void:
	if not _cast_charge_active:
		return
	var hold_time := _cast_charge_hold_time
	var cast_power: float = clamp(hold_time / CAST_CHARGE_TIME, MIN_CAST_POWER, MAX_CAST_POWER)
	_cancel_cast_charge()
	_cast_release_action_guard_msec = Time.get_ticks_msec() + 220
	_on_fish_button_pressed(cast_power, hold_time)


func _is_fish_button_pointer_event(event: InputEvent) -> bool:
	if is_modal_open:
		return false
	if fish_button == null or not fish_button.visible or not fish_button.is_visible_in_tree():
		return false
	if not (event is InputEventMouseButton):
		return false

	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return false
	if _is_catch_reward_open():
		return false
	if basket_panel.visible or inventory_panel.visible or shop_panel.visible or tackle_panel.visible or waterbody_panel.visible:
		return false

	return fish_button.get_global_rect().has_point(mouse_event.position)


func _is_depth_radial_pointer_event(event: InputEvent) -> bool:
	if depth_radial_control == null or not depth_radial_control.visible or not depth_radial_control.is_visible_in_tree():
		return false
	if not _should_show_depth_hud_controls():
		return false
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return false
		if depth_radial_control.is_adjusting_depth():
			return true
		return mouse_event.pressed and depth_radial_control.is_depth_gesture_global_point(mouse_event.position)
	return false

func _arm_modal_tap_guard() -> void:
	_ensure_modal_input_shield()
	_modal_tap_guard_until_msec = Time.get_ticks_msec() + MODAL_TAP_GUARD_MSEC
	if modal_input_shield != null:
		modal_input_shield.visible = true
	get_viewport().set_input_as_handled()

func _is_modal_tap_guard_active() -> bool:
	return Time.get_ticks_msec() < _modal_tap_guard_until_msec

func _update_modal_tap_guard() -> void:
	if modal_input_shield == null or not modal_input_shield.visible:
		return
	if not _is_modal_tap_guard_active():
		_refresh_modal_input_blocker()

func _is_visible_ui_control(control: CanvasItem) -> bool:
	return control != null and control.visible

func _is_menu_overlay_open() -> bool:
	if _is_catch_reward_open():
		return true
	if _is_level_up_reward_popup_open():
		return true
	if _is_visible_ui_control(basket_panel) or _is_visible_ui_control(inventory_panel):
		return true
	if _is_visible_ui_control(shop_panel) or _is_visible_ui_control(tackle_panel):
		return true
	if _is_visible_ui_control(waterbody_panel):
		return true
	if _is_visible_ui_control(fish_harbor_ui):
		return true
	if profile_ui != null and profile_ui.is_any_modal_open():
		return true
	if system_menu_ui != null and (system_menu_ui.is_menu_open() or system_menu_ui.is_settings_open()):
		return true
	if system_menu_ui != null and system_menu_ui.has_method("is_forecast_open") and system_menu_ui.is_forecast_open():
		return true
	return encyclopedia_ui != null and encyclopedia_ui.is_any_modal_open()

func _should_ignore_base_ui_press() -> bool:
	return is_modal_open or _is_modal_tap_guard_active() or _is_catch_reward_open() or _has_pending_catch_reward() or (system_menu_ui != null and system_menu_ui.is_menu_open())

func _has_pending_catch_reward() -> bool:
	return _fishing_ui_state == FishingUiState.CAUGHT and not _pending_reward_catch.is_empty()

func _trigger_fish_button_action(from_pointer_event: bool = false) -> void:
	if _should_ignore_base_ui_press():
		return

	if _cast_charge_active:
		return

	if _fish_button_pointer_action_active and not from_pointer_event:
		return

	var now := Time.get_ticks_msec()
	if now < _cast_release_action_guard_msec:
		return
	if now - _fish_button_action_guard_msec < 120:
		return

	_fish_button_action_guard_msec = now
	_on_fish_button_pressed()

func _clear_fish_button_pointer_action_active() -> void:
	_fish_button_pointer_action_active = false

func _layout_float_visuals(center: Vector2, scene_scale: float) -> void:
	var surface_y: float = clamp(center.y, _water_zone_top, _water_zone_bottom)
	var ripple_size := Vector2(32.0, 11.5) * scene_scale
	float_ripple.position = Vector2(center.x - ripple_size.x * 0.5, surface_y - ripple_size.y * 0.5)
	float_ripple.size = ripple_size
	float_ripple.z_index = 24
	float_ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var reflection_size := Vector2(23.0, 7.5) * scene_scale
	float_reflection.position = Vector2(center.x - reflection_size.x * 0.5, surface_y - reflection_size.y * 0.5 + 1.0 * scene_scale)
	float_reflection.size = reflection_size
	float_reflection.z_index = 23
	float_reflection.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var glow_size := Vector2(26.0, 26.0) * scene_scale
	float_glow.position = Vector2(center.x - glow_size.x * 0.5, surface_y - glow_size.y * 0.5 - 1.0 * scene_scale)
	float_glow.size = glow_size
	float_glow.z_index = 23
	float_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	float_marker.position = Vector2(center.x - 2.4 * scene_scale, surface_y - 12.4 * scene_scale)
	float_marker.size = Vector2(4.8, 22.0) * scene_scale
	float_marker.color = Color(0.92, 1.0, 0.82, 1.0)
	float_marker.z_index = 25
	float_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _configure_fishing_presence_style() -> void:
	fishing_presence_ui._configure_fishing_presence_style()

func _get_line_normal(from: Vector2, to: Vector2, prefer_down: bool = false) -> Vector2:
	return fishing_presence_ui._get_line_normal(from, to, prefer_down)

func _set_short_cross_line(line: Line2D, center: Vector2, direction_to_tip: Vector2, length: float) -> void:
	fishing_presence_ui._set_short_cross_line(line, center, direction_to_tip, length)

func _cubic_bezier_point(start: Vector2, control_a: Vector2, control_b: Vector2, end: Vector2, t: float) -> Vector2:
	return fishing_presence_ui._cubic_bezier_point(start, control_a, control_b, end, t)

func _sample_cubic_curve(
	start: Vector2,
	control_a: Vector2,
	control_b: Vector2,
	end: Vector2,
	from_t: float = 0.0,
	to_t: float = 1.0,
	steps: int = 12
) -> PackedVector2Array:
	return fishing_presence_ui._sample_cubic_curve(start, control_a, control_b, end, from_t, to_t, steps)

func _get_presence_state() -> String:
	return fishing_presence_ui._get_presence_state()

func _get_presence_reeling_intensity() -> float:
	return fishing_presence_ui._get_presence_reeling_intensity()

func _offset_points(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	return fishing_presence_ui._offset_points(points, offset)

func _set_float_presence(center: Vector2, state: String, intensity: float) -> void:
	fishing_presence_ui._set_float_presence(center, state, intensity)

func _update_fishing_presence(delta: float) -> void:
	fishing_presence_ui._update_fishing_presence(delta)
	_layout_water_animation_layer(get_viewport_rect().size)

func _setup_layout() -> void:
	_ensure_modal_layer()
	_ensure_level_up_reward_popup()
	_move_modal_roots_to_layer()
	_layout_modal_layer()
	var screen_size := get_viewport_rect().size
	_ensure_spot_visual_layers()
	_layout_spot_visual_layers(screen_size)
	var margin := 10.0
	var top_height := 58.0
	var bottom_nav_height := 50.0
	var action_height := 86.0
	var content_top := margin + top_height + 8.0
	var bottom_nav_y := screen_size.y - margin - bottom_nav_height
	var content_bottom := bottom_nav_y - 8.0
	var content_height = max(content_bottom - content_top, 220.0)
	var left_width = clamp(screen_size.x * 0.19, 168.0, 220.0)
	var right_width = clamp(screen_size.x * 0.24, 210.0, 268.0)
	var action_width: float = min(max(screen_size.x * 0.64, 560.0), screen_size.x - margin * 2.0)
	var action_x := (screen_size.x - action_width) * 0.5
	var action_y := bottom_nav_y - action_height - 8.0
	var center_width = max(screen_size.x - left_width - right_width - margin * 4.0, 280.0)
	var center_x = margin + left_width + margin
	var right_x = screen_size.x - margin - right_width

	for node in [
		scene_gradient,
		noise_layer,
		sun_glow_layer,
		far_forest_layer,
		mid_forest_layer,
		lake_layer,
		reflection_layer,
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
		encyclopedia_button,
		feed_button,
		bait_button,
		quick_tackle_panel,
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
		catch_popup_panel,
		level_up_backdrop,
		level_up_panel
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
		inventory_repair_button,
		inventory_discard_button,
		inventory_close_button,
		shop_title_label,
		shop_money_label,
		shop_bait_category_button,
		shop_consumable_category_button,
		shop_clothing_category_button,
		shop_tackle_category_button,
		shop_line_category_button,
		shop_leader_category_button,
		shop_hook_category_button,
		shop_float_category_button,
		shop_items_scroll,
		shop_items_container,
		shop_notice_label,
		shop_close_button,
		tackle_title_label,
		tackle_current_label,
		tackle_rod_button,
		tackle_rod_name_label,
		tackle_rod_meta_label,
		tackle_line_button,
		tackle_leader_button,
		tackle_float_button,
		tackle_hook_button,
		tackle_bait_button,
		tackle_bait_2_button,
		tackle_info_button,
		tackle_item_list,
		tackle_details_label,
		tackle_compare_label,
		tackle_depth_label,
		tackle_depth_minus_button,
		tackle_depth_plus_button,
		tackle_status_panel,
		tackle_hint_label,
		tackle_equip_button,
		tackle_repair_button,
		tackle_discard_button,
		tackle_close_button,
		waterbody_title_label,
		waterbody_item_list,
		waterbody_preview_frame,
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
		catch_release_button,
		level_up_title_label,
		level_up_level_label,
		level_up_unlocks_label,
		level_up_rewards_label,
		level_up_warning_label,
		level_up_confirm_button
	]:
		node.set_anchors_preset(Control.PRESET_TOP_LEFT)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.z_index = -120
	background.color = Color("#12363b")

	for layer in [
		scene_gradient,
		sun_glow_layer,
		far_forest_layer,
		mid_forest_layer,
		lake_layer,
		reflection_layer,
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
	noise_layer.z_index = -11
	vignette_layer.z_index = 3
	_setup_atmosphere_materials()
	fishing_presence_ui._layout_environment_scene(screen_size)
	if day_night_controller != null:
		_disable_legacy_environment_visuals()
	_ensure_time_of_day_layers()
	_layout_time_of_day_layers(screen_size)
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
	ui_theme.apply_hud_badge_style(top_hud_panel)
	ui_theme.apply_hud_badge_style(left_hud_panel)
	ui_theme.apply_hud_badge_style(right_hud_panel)

	inventory_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	inventory_backdrop.offset_left = 0.0
	inventory_backdrop.offset_top = 0.0
	inventory_backdrop.offset_right = 0.0
	inventory_backdrop.offset_bottom = 0.0
	inventory_backdrop.z_index = MENU_BACKDROP_Z
	ui_theme.apply_modal_backdrop_style(inventory_backdrop)
	inventory_backdrop.color = Color(0.0, 0.0, 0.0, 0.84)

	basket_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	basket_backdrop.offset_left = 0.0
	basket_backdrop.offset_top = 0.0
	basket_backdrop.offset_right = 0.0
	basket_backdrop.offset_bottom = 0.0
	basket_backdrop.z_index = MENU_BACKDROP_Z
	basket_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_theme.apply_modal_backdrop_style(basket_backdrop)
	basket_backdrop.color = Color(0.0, 0.0, 0.0, 0.84)

	shop_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	shop_backdrop.offset_left = 0.0
	shop_backdrop.offset_top = 0.0
	shop_backdrop.offset_right = 0.0
	shop_backdrop.offset_bottom = 0.0
	shop_backdrop.z_index = MENU_BACKDROP_Z
	ui_theme.apply_modal_backdrop_style(shop_backdrop)
	shop_backdrop.color = Color(0.0, 0.0, 0.0, 0.84)

	tackle_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	tackle_backdrop.position = Vector2.ZERO
	tackle_backdrop.size = _get_full_ui_viewport_size()
	tackle_backdrop.scale = Vector2.ONE
	tackle_backdrop.offset_left = 0.0
	tackle_backdrop.offset_top = 0.0
	tackle_backdrop.offset_right = 0.0
	tackle_backdrop.offset_bottom = 0.0
	tackle_backdrop.z_index = MENU_BACKDROP_Z
	ui_theme.apply_modal_backdrop_style(tackle_backdrop)
	tackle_backdrop.color = Color(0.0, 0.0, 0.0, 0.84)

	waterbody_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	waterbody_backdrop.offset_left = 0.0
	waterbody_backdrop.offset_top = 0.0
	waterbody_backdrop.offset_right = 0.0
	waterbody_backdrop.offset_bottom = 0.0
	waterbody_backdrop.z_index = MENU_BACKDROP_Z
	ui_theme.apply_modal_backdrop_style(waterbody_backdrop)
	waterbody_backdrop.color = Color(0.0, 0.0, 0.0, 0.84)

	shop_panel.z_index = MENU_PANEL_Z
	shop_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_panel_style(shop_panel, STYLE_HUD_PANEL)

	tackle_panel.z_index = MENU_PANEL_Z
	tackle_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_panel_style(tackle_panel, STYLE_HUD_PANEL)

	waterbody_panel.z_index = MENU_PANEL_Z
	waterbody_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_panel_style(waterbody_panel, STYLE_HUD_PANEL)

	catch_popup_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	catch_popup_backdrop.offset_left = 0.0
	catch_popup_backdrop.offset_top = 0.0
	catch_popup_backdrop.offset_right = 0.0
	catch_popup_backdrop.offset_bottom = 0.0
	catch_popup_backdrop.z_index = 200
	ui_theme.apply_modal_backdrop_style(catch_popup_backdrop)

	catch_popup_panel.z_index = 201
	catch_popup_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_theme.apply_popup_window_style(catch_popup_panel)
	_layout_level_up_reward_popup(screen_size)

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

	var top_cluster_width: float = min(max(screen_size.x * 0.43, 390.0), 430.0)
	var location_card_width: float = min(max(screen_size.x * 0.27, 232.0), 300.0)
	var side_card_width: float = min(max(screen_size.x * 0.22, 178.0), 230.0)
	var status_card_height: float = min(max(content_height * 0.27, 94.0), 116.0)
	var result_card_width: float = min(max(screen_size.x * 0.25, 224.0), 280.0)
	var result_card_height: float = min(max(content_height * 0.31, 108.0), 146.0)
	var nav_panel_width: float = min(max(screen_size.x * 0.48, 420.0), 560.0)

	top_hud_panel.position = Vector2(margin, margin)
	top_hud_panel.size = Vector2(top_cluster_width, top_height)
	top_hud_panel.z_index = 5

	left_hud_panel.position = Vector2(margin, content_top + 10.0)
	left_hud_panel.size = Vector2(side_card_width, status_card_height)
	left_hud_panel.z_index = 5

	right_hud_panel.position = Vector2(screen_size.x - margin - result_card_width, content_top + 10.0)
	right_hud_panel.size = Vector2(result_card_width, result_card_height)
	right_hud_panel.z_index = 5

	bottom_nav_panel.position = Vector2((screen_size.x - nav_panel_width) * 0.5, bottom_nav_y)
	bottom_nav_panel.size = Vector2(nav_panel_width, bottom_nav_height)
	bottom_nav_panel.z_index = 5

	action_panel.position = Vector2(action_x, action_y)
	action_panel.size = Vector2(action_width, action_height)
	action_panel.z_index = 6

	action_glow.position = Vector2(action_x + action_width * 0.5 - 140.0, action_y - 8.0)
	action_glow.size = Vector2(280.0, 96.0)
	action_glow.z_index = 6
	action_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	title_label.text = BuildConfig.PUBLIC_GAME_NAME
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

	basket_button.visible = false
	basket_button.disabled = true
	basket_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	inventory_button.text = "Инвентарь"
	inventory_button.position = Vector2(margin, 332)
	inventory_button.size = Vector2(left_width, 48)
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

	title_label.text = BuildConfig.PUBLIC_GAME_NAME
	title_label.position = top_hud_panel.position + Vector2(14.0, 8.0)
	title_label.size = Vector2(126.0, 20.0)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.clip_text = true

	level_label.position = top_hud_panel.position + Vector2(14.0, 30.0)
	level_label.size = Vector2(128.0, 18.0)
	level_label.add_theme_font_size_override("font_size", 12)
	level_label.clip_text = true

	xp_progress_bar.position = top_hud_panel.position + Vector2(148.0, 36.0)
	xp_progress_bar.size = Vector2(96.0, 7.0)
	xp_progress_bar.show_percentage = false
	ui_theme.apply_progress_bar_style(xp_progress_bar)

	money_label.position = top_hud_panel.position + Vector2(150.0, 9.0)
	money_label.size = Vector2(88.0, 20.0)
	money_label.add_theme_font_size_override("font_size", 14)
	money_label.clip_text = true

	clock_label.text = _get_clock_text()
	clock_label.position = top_hud_panel.position + Vector2(252.0, 9.0)
	clock_label.size = Vector2(58.0, 20.0)
	clock_label.add_theme_font_size_override("font_size", 13)
	clock_label.clip_text = true

	weather_label.text = _get_time_of_day_title()
	weather_label.position = top_hud_panel.position + Vector2(318.0, 9.0)
	weather_label.size = Vector2(max(top_hud_panel.size.x - 330.0, 64.0), 20.0)
	weather_label.add_theme_font_size_override("font_size", 13)
	weather_label.clip_text = true

	spot_option_button.position = Vector2(screen_size.x - margin - location_card_width + 12.0, margin + 7.0)
	spot_option_button.size = Vector2(location_card_width - 24.0, 44.0)
	spot_option_button.visible = false
	spot_option_button.disabled = true
	spot_option_button.custom_minimum_size = Vector2.ZERO
	spot_option_button.add_theme_font_size_override("font_size", 13)
	_apply_button_style(spot_option_button, STYLE_SECONDARY_BUTTON)

	var action_button_gap: float = 8.0
	var main_action_size := Vector2(224.0, 64.0)
	var side_action_count: float = 3.0
	var side_action_width: float = clamp((action_width - main_action_size.x - action_button_gap * side_action_count) / side_action_count, 72.0, 86.0)
	var side_action_size := Vector2(side_action_width, 56.0)
	var action_total_width: float = side_action_size.x * side_action_count + main_action_size.x + action_button_gap * side_action_count
	var action_start_x: float = action_x + max((action_width - action_total_width) * 0.5, 12.0)
	var side_action_y: float = action_y + (action_height - side_action_size.y) * 0.5
	var main_action_y: float = action_y + (action_height - main_action_size.y) * 0.5

	feed_button.text = "Прикорм"
	feed_button.position = Vector2(action_start_x, side_action_y)
	feed_button.size = side_action_size
	feed_button.z_index = 8
	feed_button.add_theme_font_size_override("font_size", 12)
	feed_button.disabled = true
	_apply_button_style(feed_button, STYLE_SECONDARY_BUTTON)

	bait_button.text = "Наживка"
	bait_button.position = Vector2(action_start_x + side_action_size.x + action_button_gap, side_action_y)
	bait_button.size = side_action_size
	bait_button.z_index = 8
	bait_button.add_theme_font_size_override("font_size", 12)
	_apply_button_style(bait_button, STYLE_SECONDARY_BUTTON)

	fish_button.position = Vector2(action_start_x + (side_action_size.x + action_button_gap) * 2.0, main_action_y)
	fish_button.size = main_action_size
	fish_button.z_index = 8
	fish_button.add_theme_font_size_override("font_size", 22)
	_apply_button_style(fish_button, STYLE_PRIMARY_BUTTON)

	tackle_button.text = "Снасти"
	tackle_button.position = Vector2(fish_button.position.x + main_action_size.x + action_button_gap, side_action_y)
	tackle_button.size = side_action_size
	tackle_button.z_index = 8
	tackle_button.add_theme_font_size_override("font_size", 12)
	_apply_button_style(tackle_button, STYLE_SECONDARY_BUTTON)

	var nav_buttons: Array = [
		inventory_button,
		map_button
	]
	var nav_texts: Array = ["Инвентарь", "Карта"]
	var nav_gap := 6.0
	var nav_x := bottom_nav_panel.position.x + 10.0
	var nav_y := bottom_nav_y + 3.0
	var nav_width: float = (bottom_nav_panel.size.x - 24.0 - nav_gap * float(nav_buttons.size() - 1)) / float(nav_buttons.size())

	for i in nav_buttons.size():
		var nav_button: Button = nav_buttons[i]
		nav_button.text = nav_texts[i]
		nav_button.position = Vector2(nav_x + float(i) * (nav_width + nav_gap), nav_y)
		nav_button.size = Vector2(nav_width, 44.0)
		nav_button.add_theme_font_size_override("font_size", 11)
		_apply_button_style(nav_button, STYLE_BOTTOM_NAV_ACTIVE if i == 0 else STYLE_BOTTOM_NAV_BUTTON)
		nav_button.disabled = false
		nav_button.mouse_filter = Control.MOUSE_FILTER_STOP

	nav_fish_button.visible = false
	nav_fish_button.disabled = true
	nav_fish_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for node in [shop_button, harbor_button]:
		node.visible = false
		node.disabled = true
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	encyclopedia_button.visible = true
	profile_button.visible = false
	encyclopedia_button.disabled = false
	profile_button.disabled = true

	timer_label.position = left_hud_panel.position + Vector2(12.0, 10.0)
	timer_label.size = Vector2(left_hud_panel.size.x - 24.0, 22.0)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	timer_label.add_theme_font_size_override("font_size", 14)
	timer_label.clip_text = true

	tackle_label.position = left_hud_panel.position + Vector2(12.0, 36.0)
	tackle_label.size = Vector2(left_hud_panel.size.x - 24.0, left_hud_panel.size.y - 46.0)
	tackle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tackle_label.add_theme_font_size_override("font_size", 12)
	tackle_label.clip_text = true

	result_label.position = right_hud_panel.position + Vector2(12.0, 12.0)
	result_label.size = Vector2(right_hud_panel.size.x - 24.0, right_hud_panel.size.y - 24.0)
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
	ui_theme.apply_meter_track_style(tension_track, tension_fill)

	progress_track.position = Vector2(panel_padding, 55.0)
	progress_track.size = Vector2(panel_width, 4.0)
	ui_theme.apply_meter_track_style(progress_track, progress_fill, Color(0.58, 0.82, 0.28, 1.0))

	debug_panel.position = Vector2(screen_size.x - margin - 360.0, content_top + 246.0)
	debug_panel.size = Vector2(350.0, 148.0)
	debug_panel.z_index = 8
	debug_panel.visible = BuildConfig.ENABLE_DEBUG_PANEL
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

	_apply_gameplay_screen_composition(screen_size)
	_layout_water_animation_layer(screen_size)
	if system_menu_ui != null and system_menu_ui.has_method("layout"):
		system_menu_ui.layout(screen_size)
	if tuman_fm_hud != null:
		tuman_fm_hud.visible = false

	for primary_label in [title_label, money_label, level_label, fight_title_label, tension_label, progress_label, basket_title_label, shop_title_label, tackle_title_label]:
		_apply_label_style(primary_label, true)

	for secondary_label in [clock_label, weather_label, timer_label, tackle_label, result_label, fight_status_label, debug_label, basket_stats_label, basket_contents_label, basket_notice_label, shop_money_label, shop_notice_label, tackle_current_label, tackle_details_label, tackle_compare_label]:
		_apply_label_style(secondary_label)
	_apply_weather_hud_text_style(clampf(min(screen_size.x / BASE_SCREEN_SIZE.x, screen_size.y / BASE_SCREEN_SIZE.y), 0.88, 1.18))
	_update_time_hud()

	var basket_width: float = screen_size.x
	var basket_height: float = screen_size.y
	var basket_x := 0.0
	var basket_y := 0.0
	var basket_padding := 28.0
	var basket_inner_width: float = basket_width - basket_padding * 2.0
	var basket_scroll_y := 104.0
	var basket_footer_y: float = basket_height - basket_padding - 52.0
	var basket_scroll_height: float = max(basket_footer_y - basket_scroll_y - 18.0, 160.0)
	var basket_notice_width: float = basket_inner_width - 340.0

	basket_panel.position = Vector2(basket_x, basket_y)
	basket_panel.size = Vector2(basket_width, basket_height)
	basket_panel.z_index = MENU_PANEL_Z
	ui_theme.apply_panel_style(basket_panel)
	basket_panel.color = Color(0.028, 0.038, 0.040, 0.90)
	basket_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	basket_frame_panel.position = Vector2.ZERO
	basket_frame_panel.size = Vector2(basket_width, basket_height)
	basket_frame_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_panel_style(basket_frame_panel, STYLE_HUD_PANEL)

	basket_title_label.position = Vector2(basket_padding, 20.0)
	basket_title_label.size = Vector2(basket_inner_width, 38.0)
	basket_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	basket_title_label.add_theme_font_size_override("font_size", 24)
	basket_title_label.z_index = 2

	basket_stats_label.position = Vector2(basket_padding, 62.0)
	basket_stats_label.size = Vector2(basket_inner_width, 34.0)
	basket_stats_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	basket_stats_label.add_theme_font_size_override("font_size", 14)
	basket_stats_label.add_theme_color_override("font_color", Color(0.88, 1.0, 0.88, 0.98))

	basket_scroll.position = Vector2(basket_padding, basket_scroll_y)
	basket_scroll.size = Vector2(basket_inner_width, basket_scroll_height)
	basket_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	basket_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	basket_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	basket_cards_grid.position = Vector2.ZERO
	basket_cards_grid.size = basket_scroll.size
	basket_cards_grid.custom_minimum_size = Vector2(basket_inner_width, 0.0)
	basket_cards_grid.mouse_filter = Control.MOUSE_FILTER_PASS
	basket_cards_grid.columns = 2
	basket_cards_grid.add_theme_constant_override("h_separation", 10)
	basket_cards_grid.add_theme_constant_override("v_separation", 10)

	basket_contents_label.position = Vector2(basket_padding, basket_scroll_y)
	basket_contents_label.size = Vector2(basket_inner_width, basket_scroll_height)
	basket_contents_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	basket_contents_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	basket_contents_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	basket_contents_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	basket_contents_label.add_theme_font_size_override("font_size", 16)
	basket_contents_label.z_index = 2

	basket_notice_label.position = Vector2(basket_padding, basket_footer_y)
	basket_notice_label.size = Vector2(max(basket_notice_width, 160.0), 44.0)
	basket_notice_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	basket_notice_label.add_theme_font_size_override("font_size", 12)
	basket_notice_label.clip_text = true

	basket_sell_all_button.position = Vector2(basket_width - basket_padding - 314.0, basket_footer_y)
	basket_sell_all_button.size = Vector2(150.0, 52.0)
	basket_sell_all_button.z_index = MENU_PANEL_Z + 3
	basket_sell_all_button.mouse_filter = Control.MOUSE_FILTER_STOP
	basket_sell_all_button.add_theme_font_size_override("font_size", 15)
	_apply_button_style(basket_sell_all_button, STYLE_PRIMARY_BUTTON)

	basket_close_button.position = Vector2(basket_width - basket_padding - 140.0, basket_footer_y + 4.0)
	basket_close_button.size = Vector2(140.0, 46.0)
	basket_close_button.z_index = MENU_PANEL_Z + 3
	basket_close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	basket_close_button.add_theme_font_size_override("font_size", 14)
	ui_theme.apply_close_button_style(basket_close_button)

	var inventory_width: float = screen_size.x
	var inventory_height: float = screen_size.y
	var inventory_x := 0.0
	var inventory_y := 0.0
	var inventory_padding := 28.0
	var category_gap := 8.0
	var category_columns := 8
	var category_button_width: float = (inventory_width - inventory_padding * 2.0 - category_gap * float(category_columns - 1)) / float(category_columns)
	var grid_width: float = inventory_width - inventory_padding * 2.0
	var inventory_body_y := 116.0
	var close_button_size := Vector2(146.0, 48.0)
	var inventory_action_y: float = inventory_height - inventory_padding - close_button_size.y
	var tackle_height := 100.0
	var tackle_y: float = inventory_action_y - tackle_height - 16.0
	var inventory_body_height: float = max(inventory_action_y - inventory_body_y - 16.0, 180.0)

	inventory_panel.position = Vector2(inventory_x, inventory_y)
	inventory_panel.size = Vector2(inventory_width, inventory_height)
	inventory_panel.z_index = MENU_PANEL_Z
	inventory_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_theme.apply_panel_style(inventory_panel)
	inventory_panel.color = Color(0.028, 0.038, 0.040, 0.90)

	inventory_title_label.position = Vector2(inventory_padding, 20.0)
	inventory_title_label.size = Vector2(inventory_width - inventory_padding * 2.0, 34.0)
	inventory_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inventory_title_label.add_theme_font_size_override("font_size", 24)

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
			62.0 + category_row * 46.0
		)
		category_button.size = Vector2(category_button_width, 44.0)
		category_button.add_theme_font_size_override("font_size", 11)

	var inventory_pager_height := 42.0
	var inventory_pager_gap := 8.0
	var inventory_list_height: float = max(inventory_body_height - inventory_pager_height - inventory_pager_gap, 120.0)

	inventory_details_card.position = Vector2(inventory_padding, inventory_body_y)
	inventory_details_card.size = Vector2(grid_width, inventory_body_height)
	inventory_details_card.visible = false
	ui_theme.apply_card_style(inventory_details_card)

	inventory_tackle_card.position = Vector2(inventory_padding, tackle_y)
	inventory_tackle_card.size = Vector2(inventory_width - inventory_padding * 2.0, tackle_height)
	inventory_tackle_card.visible = false
	ui_theme.apply_card_style(inventory_tackle_card)

	inventory_item_list.position = Vector2(inventory_padding, inventory_body_y)
	inventory_item_list.size = Vector2(grid_width, inventory_list_height)
	inventory_item_list.visible = false
	var inventory_tile_width: float = clamp(grid_width / 6.0 - 12.0, 126.0, 190.0)
	var inventory_grid_columns: int = maxi(int(floor(grid_width / max(inventory_tile_width + 12.0, 1.0))), 2)
	inventory_item_list.max_columns = inventory_grid_columns
	inventory_item_list.icon_mode = ItemList.ICON_MODE_TOP
	inventory_item_list.fixed_icon_size = Vector2i(74, 74)
	inventory_item_list.fixed_column_width = int(inventory_tile_width)
	inventory_item_list.same_column_width = true
	inventory_item_list.max_text_lines = 2
	inventory_item_list.add_theme_constant_override("h_separation", 12)
	inventory_item_list.add_theme_constant_override("v_separation", 12)
	ui_theme.apply_item_list_style(inventory_item_list)
	inventory_item_list.add_theme_font_size_override("font_size", 11)

	if inventory_prev_page_button != null and inventory_next_page_button != null and inventory_page_label != null:
		var pager_y: float = inventory_body_y + inventory_list_height + inventory_pager_gap
		inventory_prev_page_button.position = Vector2(inventory_padding, pager_y)
		inventory_prev_page_button.size = Vector2(58.0, inventory_pager_height)
		inventory_prev_page_button.z_index = MENU_PANEL_Z + 4
		inventory_prev_page_button.add_theme_font_size_override("font_size", 14)
		_apply_button_style(inventory_prev_page_button, STYLE_SECONDARY_BUTTON)

		inventory_next_page_button.position = Vector2(inventory_padding + grid_width - 58.0, pager_y)
		inventory_next_page_button.size = Vector2(58.0, inventory_pager_height)
		inventory_next_page_button.z_index = MENU_PANEL_Z + 4
		inventory_next_page_button.add_theme_font_size_override("font_size", 14)
		_apply_button_style(inventory_next_page_button, STYLE_SECONDARY_BUTTON)

		inventory_page_label.position = Vector2(inventory_padding + 66.0, pager_y + 6.0)
		inventory_page_label.size = Vector2(max(grid_width - 132.0, 48.0), inventory_pager_height - 12.0)
		inventory_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inventory_page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		inventory_page_label.add_theme_font_size_override("font_size", 12)
		inventory_page_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.92))

	inventory_details_label.position = Vector2(inventory_padding + 12.0, inventory_body_y + 12.0)
	inventory_details_label.size = Vector2(grid_width - 24.0, max(inventory_body_height - 76.0, 48.0))
	inventory_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_details_label.add_theme_font_size_override("font_size", 12)
	inventory_details_label.clip_text = false
	inventory_details_label.visible = false

	inventory_tackle_label.position = Vector2(inventory_padding + 14.0, tackle_y + 10.0)
	inventory_tackle_label.size = Vector2(inventory_width - inventory_padding * 2.0 - 28.0, tackle_height - 20.0)
	inventory_tackle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_tackle_label.add_theme_font_size_override("font_size", 12)
	inventory_tackle_label.clip_text = true
	inventory_tackle_label.visible = false

	var inventory_action_button_width: float = 150.0
	var inventory_action_y_pos: float = inventory_body_y + inventory_body_height - 54.0
	var inventory_secondary_x: float = inventory_padding + 12.0
	var inventory_primary_x: float = inventory_width - inventory_padding - inventory_action_button_width - 12.0
	inventory_equip_button.position = Vector2(inventory_primary_x, inventory_action_y_pos)
	inventory_equip_button.size = Vector2(inventory_action_button_width, 50.0)
	inventory_equip_button.visible = false
	_apply_button_style(inventory_equip_button, STYLE_PRIMARY_BUTTON)
	if inventory_repair_button != null:
		inventory_repair_button.position = Vector2(inventory_secondary_x, inventory_action_y_pos)
		inventory_repair_button.size = Vector2(inventory_action_button_width, 50.0)
		inventory_repair_button.visible = false
		_apply_button_style(inventory_repair_button, STYLE_SECONDARY_BUTTON)
	if inventory_discard_button != null:
		inventory_discard_button.position = Vector2(inventory_secondary_x, inventory_action_y_pos)
		inventory_discard_button.size = Vector2(inventory_action_button_width, 50.0)
		inventory_discard_button.visible = false
		_apply_button_style(inventory_discard_button, STYLE_SECONDARY_BUTTON)

	inventory_close_button.position = Vector2(inventory_width - inventory_padding - close_button_size.x, inventory_action_y)
	inventory_close_button.size = close_button_size
	ui_theme.apply_close_button_style(inventory_close_button)

	var tackle_screen_size := _get_full_ui_viewport_size()
	var tackle_margin_x: float = clamp(tackle_screen_size.x * 0.02, 14.0, 24.0)
	var tackle_margin_y: float = clamp(tackle_screen_size.y * 0.03, 14.0, 24.0)
	var tackle_available_width: float = max(tackle_screen_size.x - tackle_margin_x * 2.0, 1.0)
	var tackle_available_height: float = max(tackle_screen_size.y - tackle_margin_y * 2.0, 1.0)
	var tackle_width: float = min(tackle_available_width, 930.0)
	if tackle_available_width >= 900.0:
		tackle_width = max(tackle_width, 900.0)
	var tackle_panel_height: float = min(tackle_available_height, 510.0)
	if tackle_available_height >= 480.0:
		tackle_panel_height = max(tackle_panel_height, 480.0)
	var tackle_x: float = (tackle_screen_size.x - tackle_width) * 0.5
	var tackle_y_pos: float = (tackle_screen_size.y - tackle_panel_height) * 0.5
	var tackle_padding := 12.0
	var tackle_gap := 10.0
	var tackle_inner_width: float = tackle_width - tackle_padding * 2.0
	var tackle_header_height := 48.0
	var tackle_action_height := 68.0
	var tackle_content_y: float = tackle_header_height + 6.0
	var tackle_action_y: float = tackle_panel_height - tackle_padding - tackle_action_height
	var tackle_content_height: float = max(tackle_action_y - tackle_content_y - 8.0, 320.0)
	var tackle_right_content_height: float = max(tackle_panel_height - tackle_padding - tackle_content_y, 360.0)
	var tackle_left_width: float = clamp(tackle_inner_width * 0.31, 268.0, 292.0)
	var tackle_right_width: float = tackle_inner_width - tackle_left_width - tackle_gap
	var tackle_center_width: float = max(tackle_right_width - 28.0, 320.0)
	var tackle_left_x := tackle_padding
	var tackle_right_x: float = tackle_left_x + tackle_left_width + tackle_gap
	var tackle_center_x: float = tackle_right_x + 14.0

	tackle_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	tackle_backdrop.position = Vector2.ZERO
	tackle_backdrop.size = tackle_screen_size
	tackle_backdrop.scale = Vector2.ONE
	tackle_backdrop.offset_left = 0.0
	tackle_backdrop.offset_top = 0.0
	tackle_backdrop.offset_right = 0.0
	tackle_backdrop.offset_bottom = 0.0

	tackle_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	tackle_panel.position = Vector2(tackle_x, tackle_y_pos)
	tackle_panel.size = Vector2(tackle_width, tackle_panel_height)
	tackle_panel.custom_minimum_size = Vector2(tackle_width, tackle_panel_height)
	tackle_panel.scale = Vector2.ONE
	tackle_panel.pivot_offset = Vector2.ZERO
	ui_theme.apply_tackle_panel_style(tackle_panel, true)

	tackle_title_label.position = Vector2(tackle_padding, 8.0)
	tackle_title_label.size = Vector2(tackle_inner_width, 32.0)
	tackle_title_label.add_theme_font_size_override("font_size", 24)
	tackle_title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.68, 1.0))
	tackle_title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.38))
	tackle_title_label.add_theme_constant_override("shadow_offset_y", 1)

	tackle_title_divider_left.position = Vector2(tackle_width * 0.5 - 210.0, 42.0)
	tackle_title_divider_left.size = Vector2(420.0, 2.0)
	tackle_title_divider_left.color = Color(0.82, 0.58, 0.24, 0.72)
	tackle_title_divider_right.visible = false
	tackle_title_divider_right.position = Vector2.ZERO
	tackle_title_divider_right.size = Vector2.ZERO
	tackle_title_divider_right.color = Color(0.82, 0.58, 0.24, 0.72)

	tackle_left_panel.position = Vector2(tackle_left_x, tackle_content_y)
	tackle_left_panel.size = Vector2(tackle_left_width, tackle_content_height)
	ui_theme.apply_tackle_panel_style(tackle_left_panel)

	tackle_center_panel.position = Vector2(tackle_center_x, tackle_content_y + 8.0)
	tackle_center_panel.size = Vector2(tackle_center_width, tackle_content_height - 16.0)
	tackle_center_panel.z_index = MENU_PANEL_Z + 4
	ui_theme.apply_tackle_panel_style(tackle_center_panel)

	tackle_right_panel.position = Vector2(tackle_right_x, tackle_content_y)
	tackle_right_panel.size = Vector2(tackle_right_width, tackle_content_height)
	ui_theme.apply_tackle_panel_style(tackle_right_panel)

	tackle_action_bar_panel.position = Vector2(tackle_left_x, tackle_action_y)
	tackle_action_bar_panel.size = Vector2(tackle_inner_width, tackle_action_height)
	ui_theme.apply_tackle_panel_style(tackle_action_bar_panel)

	var tackle_category_buttons: Array = [tackle_line_button, tackle_leader_button, tackle_hook_button, tackle_float_button, tackle_bait_button, tackle_bait_2_button]
	var slot_gap := 7.0
	var tackle_slot_height: float = clamp((tackle_content_height - 16.0 - slot_gap * 5.0) / 6.0, 52.0, 58.0)
	for i in tackle_category_buttons.size():
		var tackle_category_button: Button = tackle_category_buttons[i]
		tackle_category_button.position = Vector2(tackle_left_x + 9.0, tackle_content_y + 8.0 + float(i) * (tackle_slot_height + slot_gap))
		tackle_category_button.size = Vector2(tackle_left_width - 18.0, tackle_slot_height)
		tackle_category_button.add_theme_font_size_override("font_size", 12)
		tackle_category_button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	if tackle_slot_scroll != null:
		tackle_slot_scroll.position = Vector2(tackle_right_x + 12.0, tackle_content_y + 8.0)
		tackle_slot_scroll.size = Vector2(tackle_right_width - 24.0, tackle_content_height - 16.0)
		tackle_slot_scroll.z_index = MENU_PANEL_Z + 2
		tackle_slot_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
		if tackle_slot_list != null:
			tackle_slot_list.position = Vector2.ZERO
			tackle_slot_list.size = Vector2(max(tackle_slot_scroll.size.x - 16.0, 1.0), tackle_slot_list.size.y)
			tackle_slot_list.custom_minimum_size = Vector2(max(tackle_slot_scroll.size.x - 16.0, 1.0), 0.0)

	tackle_visual_title_label.position = Vector2(tackle_center_x + 14.0, tackle_content_y + 8.0)
	tackle_visual_title_label.size = Vector2(tackle_center_width - 28.0, 28.0)
	tackle_visual_title_label.add_theme_font_size_override("font_size", 16)
	tackle_visual_title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.62, 1.0))

	var visual_top: float = tackle_content_y + 38.0
	var visual_bottom: float = tackle_content_y + tackle_right_content_height - 18.0
	var line_x: float = tackle_center_x + tackle_center_width * 0.55
	var rod_tip := Vector2(line_x + 10.0, visual_top)
	var rod_base := Vector2(tackle_center_x + tackle_center_width * 0.88, visual_bottom - 4.0)
	var line_bottom := Vector2(line_x, visual_bottom - 20.0)
	tackle_visual_rod_line.points = PackedVector2Array([rod_tip, rod_base])
	tackle_visual_main_line.points = PackedVector2Array([rod_tip + Vector2(0.0, 5.0), line_bottom])
	tackle_visual_leader_line.points = PackedVector2Array([line_bottom - Vector2(0.0, 54.0), line_bottom])
	tackle_visual_rod_line.width = 7.0
	tackle_visual_main_line.width = 2.8
	tackle_visual_leader_line.width = 2.8
	tackle_visual_rod_line.z_index = MENU_PANEL_Z + 2
	tackle_visual_main_line.z_index = MENU_PANEL_Z + 2
	tackle_visual_leader_line.z_index = MENU_PANEL_Z + 2

	tackle_visual_float_marker.position = Vector2(line_x - 9.0, visual_top + tackle_content_height * 0.31)
	tackle_visual_float_marker.size = Vector2(18.0, 44.0)
	tackle_visual_float_marker.color = Color(0.92, 0.32, 0.22, 0.96)
	tackle_visual_float_marker.z_index = MENU_PANEL_Z + 3

	tackle_visual_hook_marker.position = Vector2(line_x - 20.0, line_bottom.y - 16.0)
	tackle_visual_hook_marker.size = Vector2(38.0, 36.0)
	tackle_visual_hook_marker.add_theme_font_size_override("font_size", 29)
	tackle_visual_hook_marker.add_theme_color_override("font_color", Color(0.78, 0.88, 0.90, 1.0))
	tackle_visual_hook_marker.z_index = MENU_PANEL_Z + 3

	tackle_visual_bait_marker.position = Vector2(line_x + 15.0, line_bottom.y - 5.0)
	tackle_visual_bait_marker.size = Vector2(34.0, 30.0)
	tackle_visual_bait_marker.add_theme_font_size_override("font_size", 26)
	tackle_visual_bait_marker.add_theme_color_override("font_color", Color(0.86, 0.42, 0.26, 1.0))
	tackle_visual_bait_marker.z_index = MENU_PANEL_Z + 3

	tackle_visual_bait_2_marker.position = Vector2(line_x + 44.0, line_bottom.y - 5.0)
	tackle_visual_bait_2_marker.size = Vector2(34.0, 30.0)
	tackle_visual_bait_2_marker.add_theme_font_size_override("font_size", 20)
	tackle_visual_bait_2_marker.add_theme_color_override("font_color", Color(0.90, 0.70, 0.32, 1.0))
	tackle_visual_bait_2_marker.z_index = MENU_PANEL_Z + 3

	var label_width: float = max(tackle_center_width * 0.37, 112.0)
	tackle_visual_line_label.position = Vector2(tackle_center_x + 16.0, visual_top + 24.0)
	tackle_visual_float_label.position = Vector2(tackle_center_x + 16.0, visual_top + tackle_content_height * 0.31 + 2.0)
	tackle_visual_leader_label.position = Vector2(tackle_center_x + 16.0, line_bottom.y - 76.0)
	tackle_visual_hook_label.position = Vector2(tackle_center_x + 16.0, line_bottom.y - 34.0)
	tackle_visual_bait_label.position = Vector2(tackle_center_x + 16.0, line_bottom.y + 4.0)
	tackle_visual_bait_2_label.position = Vector2(tackle_center_x + tackle_center_width - label_width - 12.0, line_bottom.y + 4.0)
	for visual_label in [tackle_visual_line_label, tackle_visual_float_label, tackle_visual_leader_label, tackle_visual_hook_label, tackle_visual_bait_label, tackle_visual_bait_2_label]:
		visual_label.size = Vector2(label_width, 38.0)
		visual_label.add_theme_font_size_override("font_size", 12)

	tackle_picker_title_label.position = Vector2(tackle_center_x + 14.0, tackle_content_y + 8.0)
	tackle_picker_title_label.size = Vector2(tackle_center_width - 28.0, 28.0)
	tackle_picker_title_label.z_index = MENU_PANEL_Z + 5
	tackle_picker_title_label.add_theme_font_size_override("font_size", 15)
	tackle_picker_title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.62, 1.0))

	var tackle_pager_height := 36.0
	var tackle_pager_gap := 7.0
	var tackle_list_x: float = tackle_center_x + 14.0
	var tackle_list_y: float = tackle_content_y + 43.0
	var tackle_list_width: float = tackle_center_width - 28.0
	var tackle_list_height: float = max(tackle_content_height - 44.0 - tackle_pager_height - tackle_pager_gap - 12.0, 124.0)
	tackle_item_list.position = Vector2(tackle_list_x, tackle_list_y)
	tackle_item_list.size = Vector2(tackle_list_width, tackle_list_height)
	tackle_item_list.z_index = MENU_PANEL_Z + 5
	if _tackle_category == "rod":
		tackle_item_list.max_columns = 2
		tackle_item_list.icon_mode = ItemList.ICON_MODE_TOP
		tackle_item_list.fixed_icon_size = Vector2i(172, 56)
		tackle_item_list.fixed_column_width = int(max((tackle_list_width - 14.0) * 0.5, 176.0))
	else:
		tackle_item_list.max_columns = 1
		tackle_item_list.icon_mode = ItemList.ICON_MODE_LEFT
		tackle_item_list.fixed_icon_size = Vector2i(30, 30)
		tackle_item_list.fixed_column_width = 0
	ui_theme.apply_item_list_style(tackle_item_list)
	tackle_item_list.add_theme_font_size_override("font_size", 13)
	tackle_item_list.add_theme_color_override("font_color", Color(0.84, 0.94, 0.90, 0.96))
	tackle_item_list.add_theme_color_override("font_selected_color", Color(0.98, 1.0, 0.94, 1.0))
	tackle_item_list.add_theme_constant_override("h_separation", 10)
	tackle_item_list.add_theme_constant_override("v_separation", 12)

	if tackle_prev_page_button != null and tackle_next_page_button != null and tackle_page_label != null:
		var tackle_pager_y: float = tackle_list_y + tackle_list_height + tackle_pager_gap
		tackle_prev_page_button.position = Vector2(tackle_list_x, tackle_pager_y)
		tackle_prev_page_button.size = Vector2(48.0, tackle_pager_height)
		tackle_prev_page_button.z_index = MENU_PANEL_Z + 4
		tackle_prev_page_button.add_theme_font_size_override("font_size", 13)
		_apply_button_style(tackle_prev_page_button, STYLE_SECONDARY_BUTTON)

		tackle_next_page_button.position = Vector2(tackle_list_x + tackle_list_width - 48.0, tackle_pager_y)
		tackle_next_page_button.size = Vector2(48.0, tackle_pager_height)
		tackle_next_page_button.z_index = MENU_PANEL_Z + 4
		tackle_next_page_button.add_theme_font_size_override("font_size", 13)
		_apply_button_style(tackle_next_page_button, STYLE_SECONDARY_BUTTON)

		tackle_page_label.position = Vector2(tackle_list_x + 54.0, tackle_pager_y + 5.0)
		tackle_page_label.size = Vector2(max(tackle_list_width - 108.0, 48.0), tackle_pager_height - 10.0)
		tackle_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tackle_page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		tackle_page_label.add_theme_font_size_override("font_size", 11)
		tackle_page_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.90, 0.92))

	var tackle_final_panel_height: float = 84.0
	var final_panel_y: float = tackle_content_y + tackle_content_height - tackle_final_panel_height - 8.0
	var rod_showcase_y: float = tackle_content_y + 8.0
	var rod_showcase_height: float = max(tackle_content_height - 16.0, 220.0)

	tackle_rod_button.position = Vector2(tackle_left_x + 12.0, rod_showcase_y)
	tackle_rod_button.size = Vector2(tackle_left_width - 24.0, rod_showcase_height)
	tackle_rod_button.add_theme_font_size_override("font_size", 13)
	tackle_rod_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	tackle_rod_button.add_theme_constant_override("icon_max_width", int(min(tackle_left_width - 76.0, 210.0)))

	if tackle_rod_name_label != null:
		tackle_rod_name_label.position = Vector2(tackle_left_x + 26.0, rod_showcase_y + 14.0)
		tackle_rod_name_label.size = Vector2(tackle_left_width - 70.0, 58.0)
		tackle_rod_name_label.z_index = MENU_PANEL_Z + 5
		tackle_rod_name_label.add_theme_font_size_override("font_size", 18)
		tackle_rod_name_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.48, 1.0))
		tackle_rod_name_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
		tackle_rod_name_label.add_theme_constant_override("shadow_offset_x", 1)
		tackle_rod_name_label.add_theme_constant_override("shadow_offset_y", 1)

	if tackle_rod_meta_label != null:
		tackle_rod_meta_label.position = Vector2(tackle_left_x + 26.0, rod_showcase_y + 78.0)
		tackle_rod_meta_label.size = Vector2(tackle_left_width - 52.0, 86.0)
		tackle_rod_meta_label.z_index = MENU_PANEL_Z + 5
		tackle_rod_meta_label.add_theme_font_size_override("font_size", 12)
		tackle_rod_meta_label.add_theme_color_override("font_color", Color(0.77, 0.92, 0.86, 0.96))
		tackle_rod_meta_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.62))
		tackle_rod_meta_label.add_theme_constant_override("shadow_offset_x", 1)
		tackle_rod_meta_label.add_theme_constant_override("shadow_offset_y", 1)
		tackle_rod_meta_label.clip_text = true

	if tackle_info_button != null:
		tackle_info_button.position = Vector2(tackle_left_x + tackle_left_width - 52.0, rod_showcase_y + 10.0)
		tackle_info_button.size = Vector2(34.0, 34.0)
		tackle_info_button.z_index = MENU_PANEL_Z + 6

	tackle_rod_stats_panel.position = Vector2(tackle_left_x + 12.0, rod_showcase_y)
	tackle_rod_stats_panel.size = Vector2(tackle_left_width - 24.0, 82.0)
	ui_theme.apply_tackle_panel_style(tackle_rod_stats_panel)

	tackle_current_label.position = Vector2(tackle_left_x + 19.0, tackle_rod_stats_panel.position.y + 8.0)
	tackle_current_label.size = Vector2(tackle_left_width - 38.0, tackle_rod_stats_panel.size.y - 16.0)
	tackle_current_label.add_theme_font_size_override("font_size", 10)
	tackle_current_label.add_theme_color_override("font_color", Color(0.88, 0.96, 0.92, 0.96))
	tackle_current_label.clip_text = true

	var details_panel_y: float = tackle_rod_stats_panel.position.y + tackle_rod_stats_panel.size.y + 8.0
	tackle_rod_description_panel.position = Vector2(tackle_left_x + 12.0, details_panel_y)
	tackle_rod_description_panel.size = Vector2(tackle_left_width - 24.0, max(final_panel_y - details_panel_y - 8.0, 84.0))
	ui_theme.apply_tackle_panel_style(tackle_rod_description_panel)

	tackle_details_label.position = Vector2(tackle_left_x + 19.0, details_panel_y + 8.0)
	tackle_details_label.size = Vector2(tackle_left_width - 38.0, tackle_rod_description_panel.size.y - 16.0)
	tackle_details_label.add_theme_font_size_override("font_size", 11)
	tackle_details_label.add_theme_color_override("font_color", Color(0.78, 0.88, 0.86, 0.96))
	tackle_details_label.clip_text = true

	tackle_final_stats_panel.position = Vector2(tackle_left_x + 9.0, final_panel_y)
	tackle_final_stats_panel.size = Vector2(tackle_left_width - 18.0, tackle_final_panel_height)
	ui_theme.apply_tackle_panel_style(tackle_final_stats_panel)

	tackle_compare_label.position = Vector2(tackle_left_x + 19.0, final_panel_y + 8.0)
	tackle_compare_label.size = Vector2(tackle_left_width - 38.0, max(tackle_final_stats_panel.size.y - 16.0, 58.0))
	tackle_compare_label.add_theme_font_size_override("font_size", 9)
	tackle_compare_label.add_theme_color_override("font_color", Color(0.78, 0.90, 0.86, 0.94))
	tackle_compare_label.clip_text = true

	if tackle_status_panel != null:
		tackle_status_panel.position = Vector2(tackle_left_x + 16.0, tackle_action_y + 44.0)
		tackle_status_panel.size = Vector2(tackle_inner_width - 32.0, 22.0)
		tackle_status_panel.z_index = MENU_PANEL_Z + 3

	tackle_hint_label.position = Vector2(tackle_left_x + 28.0, tackle_action_y + 46.0)
	tackle_hint_label.size = Vector2(tackle_inner_width - 56.0, 18.0)
	tackle_hint_label.z_index = MENU_PANEL_Z + 4
	tackle_hint_label.add_theme_font_size_override("font_size", 12)
	tackle_hint_label.add_theme_color_override("font_color", Color(0.82, 0.72, 0.48, 0.92))
	tackle_hint_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.52))
	tackle_hint_label.add_theme_constant_override("shadow_offset_y", 1)
	tackle_hint_label.clip_text = true

	tackle_depth_label.position = Vector2(tackle_padding + 16.0, tackle_action_y + 10.0)
	tackle_depth_label.size = Vector2(174.0, 24.0)
	tackle_depth_label.add_theme_font_size_override("font_size", 13)
	tackle_depth_label.add_theme_color_override("font_color", Color(0.92, 0.96, 0.90, 0.96))

	tackle_depth_minus_button.position = Vector2(tackle_depth_label.position.x + tackle_depth_label.size.x + 8.0, tackle_action_y + 10.0)
	tackle_depth_minus_button.size = Vector2(48.0, 48.0)
	tackle_depth_minus_button.add_theme_font_size_override("font_size", 20)
	_apply_button_style(tackle_depth_minus_button, STYLE_SECONDARY_BUTTON)

	tackle_depth_plus_button.position = Vector2(tackle_depth_minus_button.position.x + 54.0, tackle_action_y + 10.0)
	tackle_depth_plus_button.size = Vector2(48.0, 48.0)
	tackle_depth_plus_button.add_theme_font_size_override("font_size", 20)
	_apply_button_style(tackle_depth_plus_button, STYLE_SECONDARY_BUTTON)

	var equip_width: float = 150.0
	var clear_width: float = 126.0
	var auto_width: float = 150.0
	var action_gap := 10.0
	var tackle_secondary_width: float = 110.0
	var tackle_action_button_y: float = tackle_action_y + 7.0
	if tackle_clear_button != null:
		tackle_clear_button.position = Vector2(tackle_left_x + 16.0, tackle_action_button_y)
		tackle_clear_button.size = Vector2(clear_width, 38.0)
		_apply_button_style(tackle_clear_button, STYLE_SECONDARY_BUTTON)
	if tackle_auto_button != null:
		tackle_auto_button.position = Vector2(tackle_left_x + 16.0 + clear_width + action_gap, tackle_action_button_y)
		tackle_auto_button.size = Vector2(auto_width, 38.0)
		_apply_button_style(tackle_auto_button, STYLE_SECONDARY_BUTTON)
	tackle_equip_button.position = Vector2(tackle_left_x + tackle_inner_width - equip_width - 16.0, tackle_action_button_y)
	tackle_equip_button.size = Vector2(equip_width, 38.0)
	ui_theme.apply_tackle_primary_action_style(tackle_equip_button)
	if tackle_repair_button != null:
		tackle_repair_button.position = Vector2(tackle_equip_button.position.x - tackle_secondary_width - action_gap, tackle_action_button_y)
		tackle_repair_button.size = Vector2(tackle_secondary_width, 38.0)
		_apply_button_style(tackle_repair_button, STYLE_SECONDARY_BUTTON)
	if tackle_discard_button != null:
		tackle_discard_button.position = Vector2(tackle_equip_button.position.x - tackle_secondary_width - action_gap, tackle_action_button_y)
		tackle_discard_button.size = Vector2(tackle_secondary_width, 38.0)
		_apply_button_style(tackle_discard_button, STYLE_SECONDARY_BUTTON)

	var close_width: float = 108.0
	tackle_close_button.position = Vector2(tackle_width - tackle_padding - close_width, 8.0)
	tackle_close_button.size = Vector2(close_width, 34.0)
	tackle_close_button.add_theme_font_size_override("font_size", 13)
	ui_theme.apply_close_button_style(tackle_close_button)

	var waterbody_width: float = screen_size.x
	var waterbody_height: float = screen_size.y
	var waterbody_x := 0.0
	var waterbody_y := 0.0
	var waterbody_padding := 28.0
	var waterbody_inner_width: float = waterbody_width - waterbody_padding * 2.0
	var waterbody_body_y := 78.0
	var waterbody_footer_y := waterbody_height - waterbody_padding - 50.0
	var waterbody_list_width: float = min(max(waterbody_width * 0.24, 200.0), 236.0)
	var waterbody_details_x: float = waterbody_padding + waterbody_list_width + 20.0
	var waterbody_details_width: float = waterbody_width - waterbody_details_x - waterbody_padding
	var waterbody_spot_grid_y := waterbody_body_y + 138.0
	var waterbody_spot_grid_height: float = waterbody_footer_y - waterbody_spot_grid_y - 8.0

	waterbody_panel.position = Vector2(waterbody_x, waterbody_y)
	waterbody_panel.size = Vector2(waterbody_width, waterbody_height)

	waterbody_title_label.position = Vector2(waterbody_padding, 20.0)
	waterbody_title_label.size = Vector2(waterbody_inner_width, 38.0)
	waterbody_title_label.add_theme_font_size_override("font_size", 24)
	waterbody_title_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))

	waterbody_item_list.position = Vector2(waterbody_padding, waterbody_body_y)
	waterbody_item_list.size = Vector2(waterbody_list_width, 126.0)
	ui_theme.apply_item_list_style(waterbody_item_list)
	waterbody_item_list.add_theme_font_size_override("font_size", 14)
	waterbody_item_list.add_theme_constant_override("v_separation", 12)
	waterbody_item_list.add_theme_constant_override("h_separation", 8)
	waterbody_item_list.add_theme_color_override("font_color", Color(0.84, 0.94, 0.86, 0.96))
	waterbody_item_list.add_theme_color_override("font_selected_color", Color(0.98, 1.0, 0.94, 1.0))

	waterbody_preview_frame.position = Vector2(waterbody_details_x, waterbody_body_y)
	waterbody_preview_frame.size = Vector2(waterbody_details_width, 72.0)
	ui_theme.apply_card_style(waterbody_preview_frame)

	waterbody_preview.position = Vector2(4.0, 4.0)
	waterbody_preview.size = Vector2(max(waterbody_details_width - 8.0, 1.0), 64.0)
	waterbody_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	waterbody_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	waterbody_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	waterbody_preview.modulate = Color(0.90, 1.0, 0.92, 0.96)

	waterbody_details_label.position = Vector2(waterbody_details_x, waterbody_body_y + 84.0)
	waterbody_details_label.size = Vector2(waterbody_details_width, 44.0)
	waterbody_details_label.add_theme_font_size_override("font_size", 13)
	waterbody_details_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.94))
	waterbody_details_label.clip_text = true

	var waterbody_spot_pager_height := 48.0
	var waterbody_spot_pager_gap := 8.0
	var waterbody_spot_list_height: float = max(waterbody_spot_grid_height - waterbody_spot_pager_height - waterbody_spot_pager_gap, 120.0)

	waterbody_spot_list.position = Vector2(waterbody_details_x, waterbody_spot_grid_y)
	waterbody_spot_list.size = Vector2(waterbody_details_width, waterbody_spot_list_height)
	waterbody_spot_list.visible = false
	waterbody_spot_list.max_columns = 2
	waterbody_spot_list.same_column_width = true
	waterbody_spot_list.fixed_column_width = int((waterbody_details_width - 12.0) * 0.5)
	ui_theme.apply_item_list_style(waterbody_spot_list)
	waterbody_spot_list.add_theme_font_size_override("font_size", 12)
	waterbody_spot_list.add_theme_constant_override("h_separation", 8)
	waterbody_spot_list.add_theme_constant_override("v_separation", 4)
	waterbody_spot_list.add_theme_color_override("font_color", Color(0.84, 0.94, 0.86, 0.96))
	waterbody_spot_list.add_theme_color_override("font_selected_color", Color(0.98, 1.0, 0.94, 1.0))

	var waterbody_spot_button_gap := 8.0
	var waterbody_spot_button_height: float = min(54.0, max((waterbody_spot_list_height - waterbody_spot_button_gap * 3.0) / 4.0, 46.0))
	for i in waterbody_spot_buttons.size():
		var spot_button := waterbody_spot_buttons[i] as Button
		if spot_button == null:
			continue
		spot_button.position = Vector2(waterbody_details_x, waterbody_spot_grid_y + float(i) * (waterbody_spot_button_height + waterbody_spot_button_gap))
		spot_button.size = Vector2(waterbody_details_width, waterbody_spot_button_height)
		spot_button.custom_minimum_size = spot_button.size
		spot_button.z_index = MENU_PANEL_Z + 2
		spot_button.add_theme_font_size_override("font_size", 15)

	if waterbody_spot_prev_page_button != null and waterbody_spot_next_page_button != null and waterbody_spot_page_label != null:
		var waterbody_spot_pager_y: float = waterbody_spot_grid_y + waterbody_spot_list_height + waterbody_spot_pager_gap
		waterbody_spot_prev_page_button.position = Vector2(waterbody_details_x, waterbody_spot_pager_y)
		waterbody_spot_prev_page_button.size = Vector2(66.0, waterbody_spot_pager_height)
		waterbody_spot_prev_page_button.custom_minimum_size = waterbody_spot_prev_page_button.size
		waterbody_spot_prev_page_button.z_index = MENU_PANEL_Z + 4
		waterbody_spot_prev_page_button.add_theme_font_size_override("font_size", 18)
		_apply_button_style(waterbody_spot_prev_page_button, STYLE_SECONDARY_BUTTON)

		waterbody_spot_next_page_button.position = Vector2(waterbody_details_x + waterbody_details_width - 66.0, waterbody_spot_pager_y)
		waterbody_spot_next_page_button.size = Vector2(66.0, waterbody_spot_pager_height)
		waterbody_spot_next_page_button.custom_minimum_size = waterbody_spot_next_page_button.size
		waterbody_spot_next_page_button.z_index = MENU_PANEL_Z + 4
		waterbody_spot_next_page_button.add_theme_font_size_override("font_size", 18)
		_apply_button_style(waterbody_spot_next_page_button, STYLE_SECONDARY_BUTTON)

		waterbody_spot_page_label.position = Vector2(waterbody_details_x + 76.0, waterbody_spot_pager_y + 6.0)
		waterbody_spot_page_label.size = Vector2(max(waterbody_details_width - 152.0, 48.0), waterbody_spot_pager_height - 12.0)
		waterbody_spot_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		waterbody_spot_page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		waterbody_spot_page_label.add_theme_font_size_override("font_size", 14)
		waterbody_spot_page_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.92))

	waterbody_spot_details_label.position = Vector2(waterbody_padding, waterbody_body_y + 142.0)
	waterbody_spot_details_label.size = Vector2(waterbody_list_width, waterbody_footer_y - waterbody_body_y - 152.0)
	waterbody_spot_details_label.add_theme_font_size_override("font_size", 12)
	waterbody_spot_details_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.94))
	waterbody_spot_details_label.clip_text = true

	waterbody_select_button.position = Vector2(waterbody_width - waterbody_padding - 320.0, waterbody_footer_y)
	waterbody_select_button.size = Vector2(156.0, 50.0)
	waterbody_select_button.add_theme_font_size_override("font_size", 14)
	_apply_button_style(waterbody_select_button, STYLE_PRIMARY_BUTTON)

	waterbody_close_button.position = Vector2(waterbody_width - waterbody_padding - 140.0, waterbody_footer_y + 3.0)
	waterbody_close_button.size = Vector2(140.0, 46.0)
	waterbody_close_button.add_theme_font_size_override("font_size", 14)
	ui_theme.apply_close_button_style(waterbody_close_button)

	var shop_width: float = screen_size.x
	var shop_height: float = screen_size.y
	var shop_x := 0.0
	var shop_y := 0.0
	var shop_padding := 32.0
	var shop_inner_width: float = shop_width - shop_padding * 2.0
	var shop_category_y := 64.0
	var shop_category_gap := 9.0
	var shop_category_columns := 8
	var shop_category_width: float = (shop_inner_width - shop_category_gap * float(shop_category_columns - 1)) / float(shop_category_columns)
	var shop_category_height := 42.0
	var shop_items_y := 124.0
	var shop_footer_height := 92.0

	shop_panel.position = Vector2(shop_x, shop_y)
	shop_panel.size = Vector2(shop_width, shop_height)

	shop_title_label.position = Vector2(shop_padding, 20.0)
	shop_title_label.size = Vector2(shop_inner_width, 38.0)
	shop_title_label.add_theme_font_size_override("font_size", 24)
	shop_title_label.add_theme_color_override("font_color", Color(0.94, 1.0, 0.90, 1.0))

	shop_money_label.position = Vector2(shop_width - shop_padding - 190.0, 26.0)
	shop_money_label.size = Vector2(190.0, 24.0)
	shop_money_label.add_theme_font_size_override("font_size", 14)
	shop_money_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.92))

	shop_bait_category_button.position = Vector2(shop_padding, shop_category_y)
	shop_bait_category_button.size = Vector2(shop_category_width, shop_category_height)
	shop_bait_category_button.add_theme_font_size_override("font_size", 12)

	shop_consumable_category_button.position = Vector2(shop_padding + (shop_category_width + shop_category_gap), shop_category_y)
	shop_consumable_category_button.size = Vector2(shop_category_width, shop_category_height)
	shop_consumable_category_button.add_theme_font_size_override("font_size", 12)

	if shop_clothing_category_button != null:
		shop_clothing_category_button.position = Vector2(shop_padding + (shop_category_width + shop_category_gap) * 2.0, shop_category_y)
		shop_clothing_category_button.size = Vector2(shop_category_width, shop_category_height)
		shop_clothing_category_button.add_theme_font_size_override("font_size", 12)

	shop_tackle_category_button.position = Vector2(shop_padding + (shop_category_width + shop_category_gap) * 3.0, shop_category_y)
	shop_tackle_category_button.size = Vector2(shop_category_width, shop_category_height)
	shop_tackle_category_button.add_theme_font_size_override("font_size", 12)

	shop_line_category_button.position = Vector2(shop_padding + (shop_category_width + shop_category_gap) * 4.0, shop_category_y)
	shop_line_category_button.size = Vector2(shop_category_width, shop_category_height)
	shop_line_category_button.add_theme_font_size_override("font_size", 12)

	shop_leader_category_button.position = Vector2(shop_padding + (shop_category_width + shop_category_gap) * 5.0, shop_category_y)
	shop_leader_category_button.size = Vector2(shop_category_width, shop_category_height)
	shop_leader_category_button.add_theme_font_size_override("font_size", 12)

	shop_hook_category_button.position = Vector2(shop_padding + (shop_category_width + shop_category_gap) * 6.0, shop_category_y)
	shop_hook_category_button.size = Vector2(shop_category_width, shop_category_height)
	shop_hook_category_button.add_theme_font_size_override("font_size", 12)

	shop_float_category_button.position = Vector2(shop_padding + (shop_category_width + shop_category_gap) * 7.0, shop_category_y)
	shop_float_category_button.size = Vector2(shop_category_width, shop_category_height)
	shop_float_category_button.add_theme_font_size_override("font_size", 12)

	shop_items_scroll.position = Vector2(shop_padding, shop_items_y)
	shop_items_scroll.size = Vector2(shop_inner_width, shop_height - shop_items_y - shop_footer_height)
	shop_items_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	shop_items_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	shop_items_container.position = Vector2.ZERO
	shop_items_container.size = shop_items_scroll.size
	shop_items_container.custom_minimum_size = shop_items_scroll.size

	shop_notice_label.position = Vector2(shop_padding, shop_height - shop_padding - 44.0)
	shop_notice_label.size = Vector2(shop_inner_width - 190.0, 44.0)
	shop_notice_label.add_theme_font_size_override("font_size", 14)
	shop_notice_label.clip_text = true

	if shop_prev_page_button != null and shop_next_page_button != null and shop_page_label != null:
		var shop_pager_y: float = shop_height - shop_padding - 44.0
		var shop_pager_center_x: float = shop_width * 0.5
		shop_prev_page_button.position = Vector2(shop_pager_center_x - 122.0, shop_pager_y)
		shop_prev_page_button.size = Vector2(58.0, 40.0)
		shop_prev_page_button.z_index = MENU_PANEL_Z + 4
		shop_prev_page_button.add_theme_font_size_override("font_size", 14)
		_apply_button_style(shop_prev_page_button, STYLE_SECONDARY_BUTTON)

		shop_page_label.position = Vector2(shop_pager_center_x - 58.0, shop_pager_y + 7.0)
		shop_page_label.size = Vector2(116.0, 26.0)
		shop_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		shop_page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		shop_page_label.add_theme_font_size_override("font_size", 12)
		shop_page_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.92))

		shop_next_page_button.position = Vector2(shop_pager_center_x + 64.0, shop_pager_y)
		shop_next_page_button.size = Vector2(58.0, 40.0)
		shop_next_page_button.z_index = MENU_PANEL_Z + 4
		shop_next_page_button.add_theme_font_size_override("font_size", 14)
		_apply_button_style(shop_next_page_button, STYLE_SECONDARY_BUTTON)

	shop_close_button.position = Vector2(shop_width - shop_padding - 140.0, shop_height - shop_padding - 46.0)
	shop_close_button.size = Vector2(140.0, 46.0)
	shop_close_button.add_theme_font_size_override("font_size", 14)
	ui_theme.apply_close_button_style(shop_close_button)

	_update_shop_ui()

	if toast_label != null:
		popup_manager.layout(screen_size, margin)

	var reward_width: float = min(screen_size.x - margin * 4.0, 700.0)
	var reward_height: float = min(screen_size.y - margin * 3.0, 486.0)
	var reward_x: float = (screen_size.x - reward_width) * 0.5
	var reward_y: float = (screen_size.y - reward_height) * 0.5
	var reward_padding := 18.0
	var reward_inner_width: float = reward_width - reward_padding * 2.0
	var reward_button_gap := 12.0
	var reward_button_width: float = min(max(reward_inner_width * 0.18, 116.0), 128.0)
	var reward_button_height := 38.0
	var reward_buttons_width: float = reward_button_width * 2.0 + reward_button_gap
	var reward_button_x: float = (reward_width - reward_buttons_width) * 0.5
	var reward_button_y: float = reward_height - 18.0 - reward_button_height

	catch_popup_panel.position = Vector2(reward_x, reward_y)
	catch_popup_panel.size = Vector2(reward_width, reward_height)
	catch_popup_panel.pivot_offset = catch_popup_panel.size * 0.5

	catch_popup_particles.position = Vector2.ZERO
	catch_popup_particles.size = Vector2(reward_width, reward_height)
	catch_popup_particles.z_index = 0
	catch_popup_particles.mouse_filter = Control.MOUSE_FILTER_IGNORE

	catch_popup_glow.position = Vector2((reward_width - 540.0) * 0.5, 100.0)
	catch_popup_glow.size = Vector2(540.0, 218.0)
	catch_popup_glow.z_index = 0
	catch_popup_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	catch_popup_title_label.position = Vector2(reward_padding, 18.0)
	catch_popup_title_label.size = Vector2(reward_inner_width, 24.0)
	catch_popup_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_popup_title_label.add_theme_font_size_override("font_size", 13)
	catch_popup_title_label.add_theme_color_override("font_color", Color(0.78, 0.94, 0.86, 0.92))

	catch_popup_badge_label.position = Vector2((reward_width - 142.0) * 0.5, 86.0)
	catch_popup_badge_label.size = Vector2(142.0, 22.0)
	catch_popup_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_popup_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	catch_popup_badge_label.add_theme_font_size_override("font_size", 11)

	catch_popup_name_label.position = Vector2(reward_padding, 50.0)
	catch_popup_name_label.size = Vector2(reward_inner_width, 34.0)
	catch_popup_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_popup_name_label.add_theme_font_size_override("font_size", 24)
	catch_popup_name_label.add_theme_color_override("font_color", Color(0.98, 1.0, 0.94, 1.0))
	catch_popup_name_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.34))
	catch_popup_name_label.add_theme_constant_override("shadow_offset_x", 0)
	catch_popup_name_label.add_theme_constant_override("shadow_offset_y", 2)

	catch_trophy_banner_label.position = Vector2((reward_width - 430.0) * 0.5, 88.0)
	catch_trophy_banner_label.size = Vector2(430.0, 24.0)
	catch_trophy_banner_label.z_index = 5
	catch_trophy_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_trophy_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	catch_trophy_banner_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	catch_trophy_banner_label.add_theme_font_size_override("font_size", 11)
	catch_trophy_banner_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.56, 1.0))
	catch_trophy_banner_label.add_theme_stylebox_override(
		"normal",
		_make_panel_style(Color(0.12, 0.095, 0.045, 0.62), Color(1.0, 0.78, 0.38, 0.28), 12, 6, Color(0.86, 0.54, 0.16, 0.10))
	)

	var fish_visual_width: float = min(reward_inner_width, 560.0)
	var fish_visual_height: float = min(170.0, reward_height * 0.36)
	catch_fish_shadow.position = Vector2((reward_width - fish_visual_width) * 0.5 + 8.0, 134.0)
	catch_fish_shadow.size = Vector2(fish_visual_width, fish_visual_height)
	catch_fish_shadow.z_index = 1
	catch_fish_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_catch_shadow_base_position = catch_fish_shadow.position

	catch_fish_visual.position = Vector2((reward_width - fish_visual_width) * 0.5, 126.0)
	catch_fish_visual.size = Vector2(fish_visual_width, fish_visual_height)
	catch_fish_visual.z_index = 2
	catch_fish_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_catch_fish_base_position = catch_fish_visual.position

	catch_popup_stats_label.position = Vector2(reward_padding, reward_height - 184.0)
	catch_popup_stats_label.size = Vector2(reward_inner_width, 56.0)
	catch_popup_stats_label.z_index = 5
	catch_popup_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_popup_stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	catch_popup_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	catch_popup_stats_label.add_theme_font_size_override("font_size", 12)
	catch_popup_stats_label.add_theme_color_override("font_color", Color(0.88, 0.98, 0.91, 0.96))

	catch_keep_button.position = Vector2(reward_button_x, reward_button_y)
	catch_keep_button.size = Vector2(reward_button_width, reward_button_height)
	catch_keep_button.add_theme_font_size_override("font_size", 12)
	_apply_button_style(catch_keep_button, STYLE_PRIMARY_BUTTON)
	catch_keep_button.custom_minimum_size = Vector2(reward_button_width, reward_button_height)
	catch_keep_button.size = Vector2(reward_button_width, reward_button_height)
	catch_keep_button.add_theme_font_size_override("font_size", 12)

	catch_release_button.position = Vector2(reward_button_x + reward_button_width + reward_button_gap, reward_button_y)
	catch_release_button.size = Vector2(reward_button_width, reward_button_height)
	catch_release_button.add_theme_font_size_override("font_size", 12)
	_apply_button_style(catch_release_button, STYLE_SECONDARY_BUTTON)
	catch_release_button.custom_minimum_size = Vector2(reward_button_width, reward_button_height)
	catch_release_button.size = Vector2(reward_button_width, reward_button_height)
	catch_release_button.add_theme_font_size_override("font_size", 12)

	_update_reeling_ui(_last_reeling_state)
	_update_basket_ui()
	if inventory_panel.visible:
		_update_inventory_ui()
	_update_inventory_ui()
	_update_fishing_presence(0.0)
	_refresh_modal_input_blocker()

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
	_apply_current_water_profile()

func _connect_signals() -> void:
	spot_option_button.item_selected.connect(_on_spot_selected)
	fish_button.pressed.connect(_trigger_fish_button_action)
	fish_button.button_down.connect(_on_reel_button_down)
	fish_button.button_up.connect(_on_reel_button_up)
	nav_fish_button.pressed.connect(_on_nav_fish_button_pressed)
	basket_button.pressed.connect(_on_basket_button_pressed)
	basket_sell_all_button.pressed.connect(_on_sell_all_button_pressed)
	basket_close_button.pressed.connect(_on_basket_close_button_pressed)
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	tackle_button.pressed.connect(_on_tackle_button_pressed)
	shop_button.pressed.connect(_on_shop_button_pressed)
	harbor_button.pressed.connect(_on_harbor_button_pressed)
	encyclopedia_button.pressed.connect(_on_encyclopedia_button_pressed)
	if current_tackle_button != null:
		current_tackle_button.pressed.connect(_on_current_tackle_button_pressed)
		current_tackle_button.button_down.connect(_on_current_tackle_button_down)
		current_tackle_button.button_up.connect(_on_current_tackle_button_up)
	map_button.pressed.connect(_on_map_button_pressed)
	profile_button.pressed.connect(_on_profile_button_pressed)
	bait_button.pressed.connect(_on_bait_button_pressed)
	inventory_close_button.pressed.connect(_on_inventory_close_button_pressed)
	inventory_equip_button.pressed.connect(_on_inventory_equip_button_pressed)
	if inventory_repair_button != null:
		inventory_repair_button.pressed.connect(_on_inventory_repair_button_pressed)
	if inventory_discard_button != null:
		inventory_discard_button.pressed.connect(_on_inventory_discard_button_pressed)
	inventory_item_list.item_selected.connect(_on_inventory_item_selected)
	shop_close_button.pressed.connect(_on_shop_close_button_pressed)
	shop_bait_category_button.pressed.connect(_set_shop_category.bind("bait"))
	shop_consumable_category_button.pressed.connect(_set_shop_category.bind("food"))
	if shop_clothing_category_button != null:
		shop_clothing_category_button.pressed.connect(_set_shop_category.bind("clothing"))
	shop_tackle_category_button.pressed.connect(_set_shop_category.bind("rod"))
	shop_line_category_button.pressed.connect(_set_shop_category.bind("line"))
	shop_leader_category_button.pressed.connect(_set_shop_category.bind("leader"))
	shop_hook_category_button.pressed.connect(_set_shop_category.bind("hook"))
	shop_float_category_button.pressed.connect(_set_shop_category.bind("float"))
	tackle_rod_button.pressed.connect(_set_tackle_category.bind("rod"))
	tackle_line_button.pressed.connect(_set_tackle_category.bind("line"))
	tackle_leader_button.pressed.connect(_set_tackle_category.bind("leader"))
	tackle_float_button.pressed.connect(_set_tackle_category.bind("float"))
	tackle_hook_button.pressed.connect(_set_tackle_category.bind("hook"))
	tackle_bait_button.pressed.connect(_set_tackle_category.bind("bait"))
	tackle_bait_2_button.pressed.connect(_set_tackle_category.bind("bait_2"))
	tackle_item_list.item_selected.connect(_on_tackle_item_selected)
	tackle_item_list.item_activated.connect(_on_tackle_item_activated)
	tackle_depth_minus_button.pressed.connect(_on_tackle_depth_button_pressed.bind(-0.1))
	tackle_depth_plus_button.pressed.connect(_on_tackle_depth_button_pressed.bind(0.1))
	tackle_equip_button.pressed.connect(_on_tackle_equip_button_pressed)
	if tackle_repair_button != null:
		tackle_repair_button.pressed.connect(_on_tackle_repair_button_pressed)
	if tackle_discard_button != null:
		tackle_discard_button.pressed.connect(_on_tackle_discard_button_pressed)
	tackle_close_button.pressed.connect(_on_tackle_close_button_pressed)
	waterbody_item_list.item_selected.connect(_on_waterbody_item_selected)
	waterbody_spot_list.item_selected.connect(_on_waterbody_spot_item_selected)
	waterbody_select_button.pressed.connect(_on_waterbody_select_button_pressed)
	waterbody_close_button.pressed.connect(_on_waterbody_close_button_pressed)
	category_all_button.pressed.connect(_set_inventory_category.bind("all"))
	category_rods_button.pressed.connect(_set_inventory_category.bind("rod"))
	category_lines_button.pressed.connect(_set_inventory_category.bind("line"))
	category_floats_button.pressed.connect(_set_inventory_category.bind("float"))
	category_hooks_button.pressed.connect(_set_inventory_category.bind("hook"))
	category_baits_button.pressed.connect(_set_inventory_category.bind("bait"))
	if category_food_button != null:
		category_food_button.pressed.connect(_set_inventory_category.bind("food"))
	if category_clothing_button != null:
		category_clothing_button.pressed.connect(_set_inventory_category.bind("clothing"))
	category_fish_button.pressed.connect(_set_inventory_category.bind("fish"))
	category_misc_button.pressed.connect(_set_inventory_category.bind("misc"))

	FishingManager.fishing_started.connect(_on_fishing_started)
	FishingManager.fishing_tick.connect(_on_fishing_tick)
	FishingManager.reeling_started.connect(_on_reeling_started)
	FishingManager.reeling_updated.connect(_on_reeling_updated)
	FishingManager.fish_caught.connect(_on_fish_caught)
	FishingManager.fishing_failed_detailed.connect(_on_fishing_failed_detailed)
	FishingManager.fishing_failed.connect(_on_fishing_failed)
	FishingManager.waiting_for_bite_started.connect(_on_waiting_for_bite_started)
	FishingManager.lure_retrieve_started.connect(_on_lure_retrieve_started)
	FishingManager.lure_retrieve_updated.connect(_on_lure_retrieve_updated)
	FishingManager.lure_retrieve_finished.connect(_on_lure_retrieve_finished)
	FishingManager.float_nudge.connect(_on_float_nudge)
	FishingManager.bite_preview_event.connect(_on_bite_preview_event)
	FishingManager.bite_started.connect(_on_bite_started)
	FishingManager.bite_window_updated.connect(_on_bite_window_updated)
	FishingManager.hook_success.connect(_on_hook_success)
	FishingManager.hook_failed.connect(_on_hook_failed)
	var condition_manager := get_node_or_null("/root/PlayerConditionManager")
	if condition_manager != null:
		var condition_changed_callback := Callable(self, "_on_player_condition_changed")
		var condition_warning_callback := Callable(self, "_on_player_condition_warning")
		if condition_manager.has_signal("condition_changed") and not condition_manager.condition_changed.is_connected(condition_changed_callback):
			condition_manager.condition_changed.connect(condition_changed_callback)
		if condition_manager.has_signal("condition_warning") and not condition_manager.condition_warning.is_connected(condition_warning_callback):
			condition_manager.condition_warning.connect(condition_warning_callback)

func _update_ui() -> void:
	fishing_hud_ui._update_ui()
	_update_player_xp_hud()
	if quick_tackle_panel != null:
		if quick_tackle_panel.has_method("refresh"):
			quick_tackle_panel.call("refresh")
	_refresh_current_tackle_hud()
	_refresh_condition_hud()
	_refresh_stop_fishing_button_presentation()
	_refresh_float_bite_preview_visibility()


func _on_player_condition_changed(_state: Dictionary) -> void:
	_refresh_condition_hud()


func _on_player_condition_warning(message: String, _warning_id: String) -> void:
	_show_toast(message, false)


func _grant_alpha_tester_bonus_if_needed() -> void:
	if not BuildConfig.ENABLE_ALPHA_TESTER_BONUS:
		return

	if PlayerData.alpha_tester_bonus_claimed:
		return

	PlayerData.money += ALPHA_TESTER_BONUS_MONEY
	PlayerData.alpha_tester_bonus_claimed = true
	_update_ui()
	_show_toast(ALPHA_TESTER_BONUS_MESSAGE, true)
	SaveManager.save_game()


func _update_player_xp_hud(animate := true) -> void:
	if player_xp_hud == null:
		return
	if player_xp_hud.has_method("set_progress"):
		player_xp_hud.call("set_progress", PlayerData.level, PlayerData.current_xp, PlayerData.xp_to_next_level, animate)

func _on_global_time_changed(_time_state: Dictionary) -> void:
	_update_time_hud()
	_apply_time_atmosphere()

func _on_global_period_changed(_time_of_day: String) -> void:
	_apply_time_atmosphere()

func _update_time_hud() -> void:
	if main_hud_controller != null:
		main_hud_controller.update_time()
		main_hud_controller.update_weather()
		_apply_water_animation_weather()
		return

	if clock_label == null or weather_label == null:
		return

	clock_label.text = _get_clock_text()
	weather_label.text = _get_time_of_day_title()
	_apply_water_animation_weather()

func _apply_time_atmosphere() -> void:
	if day_night_controller != null:
		_disable_legacy_environment_visuals()
		_apply_time_of_day_overlays()
		return

	var settings := _get_atmosphere_settings()

	if settings.is_empty():
		return

	background.color = settings.get("background", background.color)
	scene_gradient.modulate = settings.get("scene", Color.WHITE)
	sun_glow_layer.modulate = settings.get("sun", Color.WHITE)
	lake_layer.modulate = settings.get("water", Color.WHITE)
	reflection_layer.modulate = settings.get("water", Color.WHITE)
	far_forest_layer.modulate = settings.get("scene", Color.WHITE)
	mid_forest_layer.modulate = settings.get("scene", Color.WHITE)
	vignette_layer.modulate = settings.get("vignette", Color.WHITE)
	_apply_time_of_day_overlays()

func _apply_time_of_day_overlays() -> void:
	if day_night_controller != null:
		_hide_time_of_day_layers()
		if day_night_controller.has_method("update_day_night_visuals"):
			day_night_controller.call("update_day_night_visuals")
		return

	_ensure_time_of_day_layers()
	var visuals := _get_time_visual_settings()

	if lake_bg_base_rect != null:
		lake_bg_base_rect.modulate = visuals.get("base_modulate", Color.WHITE)

	var color_material := time_color_overlay.material as ShaderMaterial
	if color_material != null:
		color_material.set_shader_parameter("sky_tint", visuals.get("sky_tint", Color.TRANSPARENT))
		color_material.set_shader_parameter("water_tint", visuals.get("water_tint", Color.TRANSPARENT))
		color_material.set_shader_parameter("horizon_tint", visuals.get("horizon_tint", Color.TRANSPARENT))
		color_material.set_shader_parameter("horizon_y", visuals.get("horizon_y", 0.47))

	var celestial_material := time_celestial_overlay.material as ShaderMaterial
	if celestial_material != null:
		celestial_material.set_shader_parameter("body_pos", visuals.get("body_pos", Vector2(0.22, 0.34)))
		celestial_material.set_shader_parameter("body_color", visuals.get("body_color", Color(1.0, 0.80, 0.45, 1.0)))
		celestial_material.set_shader_parameter("glow_color", visuals.get("glow_color", Color(1.0, 0.55, 0.24, 1.0)))
		celestial_material.set_shader_parameter("reflection_color", visuals.get("reflection_color", Color(1.0, 0.68, 0.34, 1.0)))
		celestial_material.set_shader_parameter("body_radius", visuals.get("body_radius", 0.018))
		celestial_material.set_shader_parameter("body_alpha", visuals.get("body_alpha", 0.0))
		celestial_material.set_shader_parameter("glow_radius", visuals.get("glow_radius", 0.22))
		celestial_material.set_shader_parameter("glow_alpha", visuals.get("glow_alpha", 0.0))
		celestial_material.set_shader_parameter("reflection_alpha", visuals.get("reflection_alpha", 0.0))
		celestial_material.set_shader_parameter("horizon_y", visuals.get("horizon_y", 0.47))

	var stars_material := time_stars_overlay.material as ShaderMaterial
	if stars_material != null:
		stars_material.set_shader_parameter("star_alpha", visuals.get("star_alpha", 0.0))
		stars_material.set_shader_parameter("horizon_y", visuals.get("horizon_y", 0.47))
		stars_material.set_shader_parameter("star_color", visuals.get("star_color", Color(0.84, 0.95, 1.0, 1.0)))

	var vignette_material := time_vignette_overlay.material as ShaderMaterial
	if vignette_material != null:
		vignette_material.set_shader_parameter("vignette_color", visuals.get("vignette_color", Color(0.0, 0.025, 0.045, 1.0)))
		vignette_material.set_shader_parameter("vignette_alpha", visuals.get("vignette_alpha", 0.22))

func _get_time_visual_settings() -> Dictionary:
	var minutes := _get_current_game_minutes()
	var horizon_y := 0.47
	var base_modulate := _sample_time_color(minutes, [
		[0.0, Color(0.34, 0.43, 0.60, 1.0)],
		[300.0, Color(0.45, 0.52, 0.66, 1.0)],
		[420.0, Color(1.05, 0.88, 0.70, 1.0)],
		[660.0, Color(1.02, 1.02, 0.96, 1.0)],
		[1020.0, Color(1.04, 1.00, 0.92, 1.0)],
		[1170.0, Color(1.08, 0.78, 0.58, 1.0)],
		[1320.0, Color(0.40, 0.48, 0.66, 1.0)],
		[1440.0, Color(0.34, 0.43, 0.60, 1.0)]
	])
	var sky_tint := _sample_time_color(minutes, [
		[0.0, Color(0.00, 0.02, 0.08, 0.54)],
		[300.0, Color(0.06, 0.08, 0.16, 0.34)],
		[390.0, Color(1.00, 0.46, 0.18, 0.28)],
		[690.0, Color(0.20, 0.42, 0.64, 0.06)],
		[1080.0, Color(1.00, 0.58, 0.24, 0.15)],
		[1200.0, Color(1.00, 0.34, 0.12, 0.34)],
		[1320.0, Color(0.02, 0.05, 0.14, 0.58)],
		[1440.0, Color(0.00, 0.02, 0.08, 0.54)]
	])
	var water_tint := _sample_time_color(minutes, [
		[0.0, Color(0.00, 0.03, 0.08, 0.50)],
		[300.0, Color(0.04, 0.08, 0.14, 0.30)],
		[390.0, Color(0.88, 0.42, 0.18, 0.24)],
		[690.0, Color(0.04, 0.22, 0.26, 0.08)],
		[1080.0, Color(0.78, 0.38, 0.18, 0.17)],
		[1200.0, Color(0.86, 0.30, 0.10, 0.31)],
		[1320.0, Color(0.00, 0.04, 0.10, 0.56)],
		[1440.0, Color(0.00, 0.03, 0.08, 0.50)]
	])
	var horizon_tint := _sample_time_color(minutes, [
		[0.0, Color(0.24, 0.42, 0.84, 0.05)],
		[300.0, Color(0.72, 0.48, 0.22, 0.12)],
		[390.0, Color(1.00, 0.64, 0.25, 0.42)],
		[660.0, Color(1.00, 0.86, 0.50, 0.04)],
		[1080.0, Color(1.00, 0.70, 0.30, 0.18)],
		[1200.0, Color(1.00, 0.44, 0.16, 0.46)],
		[1320.0, Color(0.34, 0.46, 0.88, 0.09)],
		[1440.0, Color(0.24, 0.42, 0.84, 0.05)]
	])
	var vignette_alpha := _sample_time_value(minutes, [
		[0.0, 0.50],
		[300.0, 0.34],
		[420.0, 0.22],
		[720.0, 0.15],
		[1080.0, 0.20],
		[1200.0, 0.31],
		[1320.0, 0.54],
		[1440.0, 0.50]
	])
	var star_alpha := _sample_time_value(minutes, [
		[0.0, 0.34],
		[300.0, 0.16],
		[390.0, 0.0],
		[1140.0, 0.0],
		[1260.0, 0.18],
		[1320.0, 0.36],
		[1440.0, 0.34]
	])
	var celestial := _get_celestial_visuals(minutes)

	return {
		"base_modulate": base_modulate,
		"sky_tint": sky_tint,
		"water_tint": water_tint,
		"horizon_tint": horizon_tint,
		"horizon_y": horizon_y,
		"star_alpha": star_alpha,
		"star_color": Color(0.86, 0.96, 1.0, 1.0),
		"vignette_color": Color(0.0, 0.020, 0.045, 1.0),
		"vignette_alpha": vignette_alpha,
		"body_pos": celestial.get("body_pos", Vector2(0.22, 0.34)),
		"body_color": celestial.get("body_color", Color(1.0, 0.80, 0.45, 1.0)),
		"glow_color": celestial.get("glow_color", Color(1.0, 0.55, 0.24, 1.0)),
		"reflection_color": celestial.get("reflection_color", Color(1.0, 0.68, 0.34, 1.0)),
		"body_radius": celestial.get("body_radius", 0.018),
		"body_alpha": celestial.get("body_alpha", 0.0),
		"glow_radius": celestial.get("glow_radius", 0.22),
		"glow_alpha": celestial.get("glow_alpha", 0.0),
		"reflection_alpha": celestial.get("reflection_alpha", 0.0)
	}

func _get_celestial_visuals(minutes: float) -> Dictionary:
	var sun_start := 300.0
	var sun_end := 1320.0
	var is_daylight := minutes >= sun_start and minutes <= sun_end

	if is_daylight:
		var sun_t := clampf((minutes - sun_start) / max(sun_end - sun_start, 1.0), 0.0, 1.0)
		var sun_arc := sin(sun_t * PI)
		var edge_fade: float = clampf(min((minutes - sun_start) / 120.0, (sun_end - minutes) / 120.0), 0.0, 1.0)
		var sunrise_sunset_boost := 1.0 - clampf(abs(sun_t - 0.5) / 0.5, 0.0, 1.0)
		var warm_edge := 1.0 - sunrise_sunset_boost
		var body_alpha: float = (0.12 + warm_edge * 0.24) * edge_fade
		var glow_alpha: float = (0.06 + warm_edge * 0.20) * edge_fade
		var reflection_alpha: float = (0.06 + warm_edge * 0.17) * edge_fade
		return {
			"body_pos": Vector2(lerpf(0.16, 0.86, sun_t), lerpf(0.36, 0.12, sun_arc)),
			"body_color": Color(1.0, lerpf(0.58, 0.92, sun_arc), lerpf(0.28, 0.70, sun_arc), 1.0),
			"glow_color": Color(1.0, 0.48 + sun_arc * 0.28, 0.16 + sun_arc * 0.22, 1.0),
			"reflection_color": Color(1.0, 0.62, 0.28, 1.0),
			"body_radius": lerpf(0.020, 0.014, sun_arc),
			"body_alpha": body_alpha,
			"glow_radius": lerpf(0.24, 0.16, sun_arc),
			"glow_alpha": glow_alpha,
			"reflection_alpha": reflection_alpha
		}

	var night_length := 1440.0 - sun_end + sun_start
	var moon_minutes := minutes - sun_end if minutes >= sun_end else minutes + 1440.0 - sun_end
	var moon_t := clampf(moon_minutes / max(night_length, 1.0), 0.0, 1.0)
	var moon_arc := sin(moon_t * PI)
	var night_edge_fade: float = clampf(min(moon_minutes / 90.0, (night_length - moon_minutes) / 90.0), 0.0, 1.0)
	return {
		"body_pos": Vector2(lerpf(0.18, 0.82, moon_t), lerpf(0.34, 0.18, moon_arc)),
		"body_color": Color(0.70, 0.84, 1.0, 1.0),
		"glow_color": Color(0.22, 0.42, 0.82, 1.0),
		"reflection_color": Color(0.42, 0.64, 1.0, 1.0),
		"body_radius": 0.012,
		"body_alpha": 0.46 * night_edge_fade,
		"glow_radius": 0.15,
		"glow_alpha": 0.10 * night_edge_fade,
		"reflection_alpha": 0.055 * night_edge_fade
	}

func _get_current_game_minutes() -> float:
	var time_manager := _get_time_manager()

	if time_manager != null:
		var raw_minutes: Variant = time_manager.get("current_game_minutes")
		if raw_minutes != null:
			return fposmod(float(raw_minutes), 1440.0)

	return 525.0

func _sample_time_color(minutes: float, anchors: Array) -> Color:
	if anchors.is_empty():
		return Color.WHITE

	var wrapped_minutes := fposmod(minutes, 1440.0)
	var previous: Array = anchors[0]

	for index in range(1, anchors.size()):
		var current: Array = anchors[index]
		var current_minute := float(current[0])
		if wrapped_minutes <= current_minute:
			var previous_minute := float(previous[0])
			var span: float = max(current_minute - previous_minute, 0.001)
			var t: float = clampf((wrapped_minutes - previous_minute) / span, 0.0, 1.0)
			t = t * t * (3.0 - 2.0 * t)
			var previous_color: Color = previous[1]
			var current_color: Color = current[1]
			return previous_color.lerp(current_color, t)
		previous = current

	var last_color: Color = anchors[anchors.size() - 1][1]
	return last_color

func _sample_time_value(minutes: float, anchors: Array) -> float:
	if anchors.is_empty():
		return 0.0

	var wrapped_minutes := fposmod(minutes, 1440.0)
	var previous: Array = anchors[0]

	for index in range(1, anchors.size()):
		var current: Array = anchors[index]
		var current_minute := float(current[0])
		if wrapped_minutes <= current_minute:
			var previous_minute := float(previous[0])
			var span: float = max(current_minute - previous_minute, 0.001)
			var t: float = clampf((wrapped_minutes - previous_minute) / span, 0.0, 1.0)
			t = t * t * (3.0 - 2.0 * t)
			return lerpf(float(previous[1]), float(current[1]), t)
		previous = current

	return float(anchors[anchors.size() - 1][1])

func _get_time_manager() -> Node:
	return get_node_or_null("/root/TimeManager")

func _get_waterbody_database() -> Node:
	return get_node_or_null("/root/WaterbodyDatabase")

func _get_clock_text() -> String:
	var time_manager := _get_time_manager()

	if time_manager != null and time_manager.has_method("get_clock_text"):
		return str(time_manager.call("get_clock_text"))

	return "08:45"

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
	keepnet_ui._update_basket_ui()
	_update_keepnet_hud_button()


func _update_keepnet_hud_button(animate := true) -> void:
	if keepnet_hud_button == null:
		return

	var locked := _fishing_ui_state == FishingUiState.WAITING or _fishing_ui_state == FishingUiState.FIGHTING or is_cast_animating
	keepnet_hud_button.visible = true
	keepnet_hud_button.disabled = locked
	keepnet_hud_button.mouse_filter = Control.MOUSE_FILTER_STOP
	keepnet_hud_button.tooltip_text = "Садок: %d/%d" % [InventoryManager.inventory.size(), InventoryManager.max_items]
	if keepnet_hud_button.has_method("set_counts"):
		keepnet_hud_button.call("set_counts", InventoryManager.inventory.size(), InventoryManager.max_items, animate)

func _get_keepnet_summary() -> Dictionary:
	return keepnet_ui._get_keepnet_summary()

func _rebuild_keepnet_cards() -> void:
	keepnet_ui._rebuild_keepnet_cards()

func _create_keepnet_card(fish: Dictionary, fish_index: int, card_size: Vector2) -> Panel:
	return keepnet_ui._create_keepnet_card(fish, fish_index, card_size)

func _get_keepnet_tier_color(tier: String) -> Color:
	return keepnet_ui._get_keepnet_tier_color(tier)

func _get_keepnet_tier_label(tier: String) -> String:
	return keepnet_ui._get_keepnet_tier_label(tier)

func _show_basket_notice(message: String, success: bool = true) -> void:
	keepnet_ui._show_basket_notice(message, success)

func _is_catch_reward_open() -> bool:
	return catch_popup_controller != null and catch_popup_controller.is_open()

func _bring_catch_reward_to_front() -> void:
	if catch_popup_controller != null:
		catch_popup_controller.bring_to_front()

func _close_secondary_popups_for_reward() -> void:
	if catch_popup_controller != null:
		catch_popup_controller.close_secondary_popups()

func _show_catch_reward_popup(catch_data: Dictionary) -> void:
	if catch_popup_controller != null:
		catch_popup_controller.show_catch_result(catch_data)
	else:
		_pending_reward_catch = {}

func _lock_catch_reward_buttons() -> void:
	if catch_popup_controller != null:
		catch_popup_controller.lock_buttons()

func _update_catch_reward_input_lock() -> void:
	if catch_popup_controller != null:
		catch_popup_controller.update_input_lock()

func _unlock_catch_reward_buttons() -> void:
	if catch_popup_controller != null:
		catch_popup_controller.unlock_buttons()

func _start_catch_fish_idle_motion(feedback: Dictionary) -> void:
	if catch_popup_controller != null:
		catch_popup_controller.start_fish_idle_motion(feedback)

func _update_catch_reward_popup(catch_data: Dictionary) -> void:
	if catch_popup_controller != null:
		catch_popup_controller.update_popup(catch_data)

func _set_reward_fish_texture(fish_id: String) -> void:
	if catch_popup_controller != null:
		catch_popup_controller.set_fish_texture(fish_id)

func _get_reward_fish_texture(fish_id: String) -> Texture2D:
	if catch_popup_controller != null:
		return catch_popup_controller.get_fish_texture(fish_id)
	return null

func _play_catch_reward_sound(tier: String) -> void:
	if catch_popup_controller != null:
		catch_popup_controller.play_reward_sound(tier)

func _play_main_ambient() -> void:
	_call_audio_manager("play_water_ambient_loop")

func _play_game_sfx(sfx_name: String) -> void:
	_call_audio_manager("play_sfx", [sfx_name])

func _play_line_break_sfx_if_needed(failure_data: Dictionary) -> void:
	var reason := str(failure_data.get("reason", ""))
	var fail_kind := str(failure_data.get("fail_kind", ""))
	var failure_text := "%s %s %s" % [
		str(failure_data.get("title", "")),
		str(failure_data.get("message", "")),
		str(failure_data.get("raw_message", ""))
	]
	if reason == "LINE_BROKE" or fail_kind == "line_break" or _message_mentions_line_break(failure_text):
		_call_audio_manager("play_line_break")

func _message_mentions_line_break(message: String) -> bool:
	var normalized_message := message.to_lower()
	return (
		normalized_message.find("line_broke") != -1
		or normalized_message.find("line_break") != -1
		or normalized_message.find("леска") != -1
		or normalized_message.find("порвалась") != -1
		or normalized_message.find("обрыв") != -1
	)

func _call_audio_manager(method_name: String, args: Array = []) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager == null or not audio_manager.has_method(method_name):
		return

	audio_manager.callv(method_name, args)

func _play_audio_hook(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return

	player.stop()
	player.play()

func _hide_catch_reward_popup(animated: bool = true) -> void:
	if catch_popup_controller != null:
		catch_popup_controller.hide(animated)

func _set_catch_popup_hidden() -> void:
	if catch_popup_controller != null:
		catch_popup_controller.set_hidden()

func _get_reward_tier(catch_data: Dictionary) -> String:
	if catch_popup_controller != null:
		return catch_popup_controller.get_reward_tier(catch_data)
	return "common"

func _get_reward_colors(tier: String) -> Dictionary:
	if catch_popup_controller != null:
		return catch_popup_controller.get_reward_colors(tier)
	return {}

func _get_reward_feedback_tuning(tier: String) -> Dictionary:
	if catch_popup_controller != null:
		return catch_popup_controller.get_reward_feedback_tuning(tier)
	return {}

func _get_catch_length_cm(catch_data: Dictionary) -> float:
	if catch_popup_controller != null:
		return catch_popup_controller.get_catch_length_cm(catch_data)
	return 0.0

func _refresh_bottom_nav_styles() -> void:
	fishing_hud_ui._refresh_bottom_nav_styles()

func _get_main_hud_text() -> String:
	return fishing_hud_ui._get_main_hud_text()

func _update_shop_ui() -> void:
	shop_ui._update_shop_ui()

func _rebuild_shop_cards() -> void:
	shop_ui._rebuild_shop_cards()

func _create_shop_card(item: Dictionary, card_size: Vector2) -> Panel:
	return shop_ui._create_shop_card(item, card_size)

func _get_shop_items_for_category(category: String) -> Array:
	return shop_ui._get_shop_items_for_category(category)

func _get_shop_item(item_id: String) -> Dictionary:
	return shop_ui._get_shop_item(item_id)

func _get_owned_shop_item_quantity(item_id: String) -> int:
	return shop_ui._get_owned_shop_item_quantity(item_id)

func _get_shop_key_stat_text(item: Dictionary) -> String:
	return shop_ui._get_shop_key_stat_text(item)

func _get_shop_inventory_item(shop_item: Dictionary) -> Dictionary:
	return shop_ui._get_shop_inventory_item(shop_item)

func _set_shop_category(category: String) -> void:
	shop_ui._set_shop_category(category)

func _show_shop_notice(message: String, success: bool) -> void:
	shop_ui._show_shop_notice(message, success)

func _show_toast(message: String, success: bool = true) -> void:
	if popup_manager != null:
		popup_manager.show_toast(message, success)

func _queue_level_up_rewards(rewards: Array) -> void:
	for reward in rewards:
		if typeof(reward) != TYPE_DICTIONARY:
			continue
		var reward_data: Dictionary = reward
		if not bool(reward_data.get("success", false)):
			continue
		_level_up_reward_queue.append(reward_data.duplicate(true))

	if not _level_up_reward_queue.is_empty():
		_try_show_queued_level_up_reward()

func _try_show_queued_level_up_reward() -> void:
	if _level_up_reward_queue.is_empty():
		return
	if not _current_level_up_reward.is_empty():
		return
	if _is_catch_reward_open() or _has_pending_catch_reward():
		return
	if is_modal_open and _current_modal_name != LEVEL_UP_MODAL_NAME:
		return

	_show_next_level_up_reward()

func _show_next_level_up_reward() -> void:
	if _level_up_reward_queue.is_empty():
		_current_level_up_reward = {}
		return

	_ensure_level_up_reward_popup()
	_current_level_up_reward = (_level_up_reward_queue.pop_front() as Dictionary).duplicate(true)
	_update_level_up_reward_popup(_current_level_up_reward)

	if _current_modal_name != LEVEL_UP_MODAL_NAME:
		open_modal(LEVEL_UP_MODAL_NAME)
	_bring_level_up_reward_popup_to_front()
	level_up_backdrop.visible = true
	level_up_panel.visible = true
	level_up_backdrop.modulate = Color(1.0, 1.0, 1.0, 1.0)
	level_up_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
	level_up_panel.scale = Vector2.ONE
	_refresh_modal_input_blocker()

func _update_level_up_reward_popup(reward: Dictionary) -> void:
	if level_up_panel == null:
		return

	var reward_level := int(reward.get("level", PlayerData.level))
	level_up_level_label.text = "LVL %d" % reward_level
	level_up_unlocks_label.text = _format_level_up_unlocks_text(reward)
	level_up_rewards_label.text = _format_level_up_rewards_text(reward)

	var skipped_items: Array = reward.get("skipped_items", [])
	level_up_warning_label.visible = not skipped_items.is_empty()
	level_up_warning_label.text = "Часть наград пропущена, подробности в warning log." if not skipped_items.is_empty() else ""
	level_up_confirm_button.text = "Забрать"

func _format_level_up_unlocks_text(reward: Dictionary) -> String:
	var unlocks: Array = reward.get("unlocks", [])
	var lines: Array = ["Открылось:"]
	if unlocks.is_empty():
		lines.append("- Награда за новый уровень")
	else:
		for unlock in unlocks:
			var text := str(unlock).strip_edges()
			if text != "":
				lines.append("- %s" % text)
	return "\n".join(lines)

func _format_level_up_rewards_text(reward: Dictionary) -> String:
	var lines: Array = ["Получено:"]
	var silver := int(reward.get("silver", 0))
	if silver > 0:
		lines.append("- %d серебра" % silver)

	var items: Array = reward.get("items", [])
	for item in items:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var item_data: Dictionary = item
		var item_name := str(item_data.get("name", item_data.get("id", "-")))
		var quantity: int = maxi(int(item_data.get("quantity", 1)), 1)
		lines.append("- %s x%d" % [item_name, quantity])

	if lines.size() == 1:
		lines.append("- Награда уже учтена")
	return "\n".join(lines)

func _bring_level_up_reward_popup_to_front() -> void:
	var parent: Node = level_up_panel.get_parent() if level_up_panel != null else null
	if parent == null:
		return
	if level_up_backdrop != null and level_up_backdrop.get_parent() == parent:
		parent.move_child(level_up_backdrop, parent.get_child_count() - 1)
	if level_up_panel != null and level_up_panel.get_parent() == parent:
		parent.move_child(level_up_panel, parent.get_child_count() - 1)

func _is_level_up_reward_popup_open() -> bool:
	return level_up_panel != null and level_up_panel.visible

func _hide_level_up_reward_popup(animated: bool = true) -> void:
	if level_up_panel == null or level_up_backdrop == null:
		close_modal(LEVEL_UP_MODAL_NAME)
		return

	if is_instance_valid(_level_up_popup_tween):
		_level_up_popup_tween.kill()

	if not animated:
		_set_level_up_reward_popup_hidden()
		return

	_level_up_popup_tween = create_tween()
	_level_up_popup_tween.tween_property(level_up_panel, "modulate:a", 0.0, 0.10)
	_level_up_popup_tween.parallel().tween_property(level_up_backdrop, "modulate:a", 0.0, 0.10)
	_level_up_popup_tween.tween_callback(Callable(self, "_set_level_up_reward_popup_hidden"))

func _set_level_up_reward_popup_hidden() -> void:
	if level_up_backdrop != null:
		level_up_backdrop.visible = false
		level_up_backdrop.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if level_up_panel != null:
		level_up_panel.visible = false
		level_up_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
		level_up_panel.scale = Vector2.ONE
	close_modal(LEVEL_UP_MODAL_NAME)

func _on_level_up_confirm_pressed() -> void:
	if _current_level_up_reward.is_empty():
		_hide_level_up_reward_popup(false)
		return

	var completed_level := int(_current_level_up_reward.get("level", PlayerData.level))
	result_label.text = "Награда за LVL %d получена." % completed_level
	_current_level_up_reward = {}
	SaveManager.save_game()
	_update_ui()

	if not _level_up_reward_queue.is_empty():
		_show_next_level_up_reward()
		return

	_hide_level_up_reward_popup()

func _block_level_up_reward_close_attempt() -> bool:
	if _current_modal_name != LEVEL_UP_MODAL_NAME:
		return false
	if _current_level_up_reward.is_empty():
		return false

	_bring_level_up_reward_popup_to_front()
	_show_toast("Сначала заберите награду", false)
	return true

func _should_show_first_run_hints() -> bool:
	return BuildConfig.IS_BETA_BUILD and PlayerData.total_fish_caught <= 0

func _show_first_run_hint(stage: String) -> void:
	if not _first_run_hints_active:
		return
	if _first_run_hints_shown.has(stage):
		return
	if not FIRST_RUN_HINT_TEXTS.has(stage):
		return

	_first_run_hints_shown[stage] = true
	result_label.text = str(FIRST_RUN_HINT_TEXTS[stage])

func _block_pending_catch_reward_close_attempt() -> bool:
	if _current_modal_name != "catch_reward":
		return false
	if _pending_reward_catch.is_empty():
		return false

	_bring_catch_reward_to_front()
	result_label.text = "Сначала заберите улов"
	_show_toast("Сначала заберите улов", false)
	return true

func _play_shop_card_feedback(item_id: String, success: bool) -> void:
	shop_ui._play_shop_card_feedback(item_id, success)

func _on_shop_card_hovered(item_id: String, hovered: bool) -> void:
	shop_ui._on_shop_card_hovered(item_id, hovered)

func _update_inventory_ui() -> void:
	inventory_ui._update_inventory_ui()

func _get_visible_inventory_items() -> Array:
	return inventory_ui._get_visible_inventory_items()

func _get_selected_inventory_item() -> Dictionary:
	return inventory_ui._get_selected_inventory_item()

func _get_inventory_item_display_text(item: Dictionary) -> String:
	return inventory_ui._get_inventory_item_display_text(item)

func _get_inventory_item_details_text(item: Dictionary) -> String:
	return inventory_ui._get_inventory_item_details_text(item)

func _get_inventory_stats_text(stats: Dictionary) -> String:
	return inventory_ui._get_inventory_stats_text(stats)

func _get_current_tackle_inventory_text() -> String:
	return inventory_ui._get_current_tackle_inventory_text()

func _get_tackle_build_summary_text() -> String:
	return inventory_ui._get_tackle_build_summary_text()

func _get_inventory_category_title(category: String) -> String:
	return inventory_ui._get_inventory_category_title(category)

func _update_tackle_ui() -> void:
	tackle_ui._update_tackle_ui()

func _set_tackle_category(category: String) -> void:
	tackle_ui._set_tackle_category(category)

func _on_tackle_item_selected(index: int) -> void:
	tackle_ui._on_tackle_item_selected(index)

func _on_tackle_item_activated(index: int) -> void:
	tackle_ui._on_tackle_item_activated(index)

func _on_tackle_equip_button_pressed() -> void:
	var selected_item := _get_selected_tackle_item()
	if selected_item.is_empty() and tackle_ui != null and tackle_ui.has_method("is_item_picker_open") and not bool(tackle_ui.is_item_picker_open()):
		var validation_service: Node = get_node_or_null("/root/TackleValidationService")
		var validation: Dictionary = {}
		if validation_service != null and validation_service.has_method("validate_current_tackle"):
			var validation_result = validation_service.call("validate_current_tackle")
			if typeof(validation_result) == TYPE_DICTIONARY:
				validation = validation_result
		var issues: Array = PlayerData.get_tackle_setup_issues()
		var tackle_ready: bool = bool(validation.get("usable", issues.is_empty())) and issues.is_empty()
		if not tackle_ready:
			var block_text := PlayerData.get_tackle_block_reason()
			result_label.text = block_text if block_text != "" else "Снасть не готова."
			_show_toast(result_label.text, false)
			_update_tackle_ui()
			return
		if _fishing_ui_state != FishingUiState.IDLE:
			result_label.text = "Снасть можно менять только перед забросом."
			_show_toast(result_label.text, false)
			_update_tackle_ui()
			return
		result_label.text = "Снасть экипирована и готова к ловле."
		_show_toast(result_label.text, true)
		SaveManager.save_game()
		_update_ui()
		return

	var validation_service := get_node_or_null("/root/TackleValidationService")
	var block_reason := str(validation_service.call("get_equip_block_reason", _tackle_category, selected_item)) if validation_service != null and validation_service.has_method("get_equip_block_reason") else PlayerData.get_equip_block_reason(selected_item, _tackle_category)

	if selected_item.is_empty() or block_reason != "":
		result_label.text = block_reason if block_reason != "" else "Эту снасть нельзя экипировать."
		_show_toast(result_label.text, false)
		_update_tackle_ui()
		return

	if _fishing_ui_state != FishingUiState.IDLE:
		result_label.text = "Снасть можно менять только перед забросом."
		_update_tackle_ui()
		return

	var equipped := false
	if PlayerData.has_method("set_current_tackle_slot"):
		equipped = PlayerData.set_current_tackle_slot(_tackle_category, selected_item)
	else:
		equipped = PlayerData.equip_item(str(selected_item.get("id", "")))

	if equipped:
		var equip_message := "Экипировано: %s" % str(selected_item.get("name", "-"))
		result_label.text = equip_message
		_show_toast(equip_message, true)
		SaveManager.save_game()
		tackle_ui.close_item_picker(false)
	else:
		result_label.text = "Не удалось экипировать снасть."

	_update_ui()

func _on_tackle_repair_button_pressed() -> void:
	var selected_item := _get_selected_tackle_item()
	if selected_item.is_empty():
		return
	var repair_service := get_node_or_null("/root/RepairService")
	if repair_service != null and repair_service.has_method("repair_item"):
		_apply_repair_result(repair_service.call("repair_item", str(selected_item.get("id", ""))))
	else:
		_apply_repair_result(PlayerData.repair_owned_item(str(selected_item.get("id", ""))))

func _on_tackle_discard_button_pressed() -> void:
	var selected_item := _get_selected_tackle_item()
	if selected_item.is_empty():
		return
	_request_discard_owned_item(str(selected_item.get("id", "")), "tackle")

func _on_tackle_depth_button_pressed(delta: float) -> void:
	if _fishing_ui_state != FishingUiState.IDLE:
		result_label.text = "Глубину можно менять только перед забросом."
		_show_toast("Глубину можно менять перед забросом", false)
		_update_tackle_ui()
		return

	PlayerData.adjust_fishing_depth(delta)
	var depth_message := "Глубина: %.1f м" % PlayerData.fishing_depth
	result_label.text = "Выставлена глубина снасти: %.1f м" % PlayerData.fishing_depth
	_update_depth_hud_value_label()
	_show_toast(depth_message, true)
	SaveManager.save_game()
	_update_ui()

func _on_depth_radial_control_changed(value: float) -> void:
	if _fishing_ui_state != FishingUiState.IDLE:
		return
	PlayerData.set_fishing_depth(value)
	if depth_radial_control != null:
		depth_radial_control.set_depth_value(PlayerData.fishing_depth, false)
	_update_depth_hud_value_label()


func _on_depth_radial_control_committed(value: float) -> void:
	if _fishing_ui_state != FishingUiState.IDLE:
		return
	PlayerData.set_fishing_depth(value)
	if depth_radial_control != null:
		depth_radial_control.set_depth_value(PlayerData.fishing_depth, false)
	_update_depth_hud_value_label()
	var depth_message := "Глубина: %.1f м" % PlayerData.fishing_depth
	result_label.text = "Выставлена глубина снасти: %.1f м" % PlayerData.fishing_depth
	_show_toast(depth_message, true)
	SaveManager.save_game()
	_update_ui()


func _on_tackle_close_button_pressed() -> void:
	_arm_modal_tap_guard()
	call_deferred("_close_tackle_ui_after_guard")

func _close_tackle_ui_after_guard() -> void:
	tackle_ui.close()

func _update_waterbody_ui() -> void:
	waterbody_ui._update_waterbody_ui()

func _get_selected_waterbody() -> Dictionary:
	return waterbody_ui._get_selected_waterbody()

func _update_waterbody_spot_picker(waterbody: Dictionary) -> void:
	waterbody_ui._update_waterbody_spot_picker(waterbody)

func _get_selected_waterbody_spot() -> Dictionary:
	return waterbody_ui._get_selected_waterbody_spot()

func _get_waterbody_spot_details_text(spot: Dictionary) -> String:
	return waterbody_ui._get_waterbody_spot_details_text(spot)

func _get_waterbody_details_text(waterbody: Dictionary) -> String:
	return waterbody_ui._get_waterbody_details_text(waterbody)

func _get_waterbody_preview_color(waterbody_id: String) -> Color:
	return waterbody_ui._get_waterbody_preview_color(waterbody_id)

func _on_waterbody_item_selected(index: int) -> void:
	waterbody_ui._on_waterbody_item_selected(index)

func _on_waterbody_spot_item_selected(index: int) -> void:
	waterbody_ui._on_waterbody_spot_item_selected(index)

func _on_waterbody_select_button_pressed() -> void:
	var selected_waterbody := _get_selected_waterbody()

	if selected_waterbody.is_empty():
		return

	var waterbody_id := str(selected_waterbody.get("id", ""))
	var selected_spot := _get_selected_waterbody_spot()
	var selected_spot_id := str(selected_spot.get("id", ""))
	var is_current_spot := waterbody_id == PlayerData.current_waterbody and selected_spot_id == PlayerData.current_spot

	if is_current_spot:
		if _fishing_ui_state == FishingUiState.FAILED:
			_return_to_idle_after_result()
		_show_toast("Вы уже на этой точке", true)
		_on_waterbody_close_button_pressed()
		return

	if _fishing_ui_state == FishingUiState.FAILED:
		_return_to_idle_after_result()
	elif _fishing_ui_state != FishingUiState.IDLE:
		_show_toast("Сначала закончите текущую ловлю", false)
		_update_waterbody_ui()
		return

	if not PlayerData.set_current_waterbody(waterbody_id):
		var required_level := int(selected_waterbody.get("required_level", 1))
		_show_toast("Нужен LVL %d" % required_level, false)
		_update_waterbody_ui()
		return

	if selected_spot_id == "":
		selected_spot_id = _get_primary_waterbody_spot(waterbody_id)

	if selected_spot_id != "" and not PlayerData.set_current_spot(selected_spot_id):
		_show_toast("Точка недоступна", false)
		_update_waterbody_ui()
		return

	_selected_waterbody_id = PlayerData.current_waterbody
	_selected_waterbody_spot_id = PlayerData.current_spot
	_setup_spots()
	result_label.text = "Выбрано: %s / %s" % [
		str(selected_waterbody.get("name", "-")),
		str(SpotDatabase.get_spot(PlayerData.current_spot).get("name", "-"))
	]
	_show_toast(result_label.text, true)
	SaveManager.save_game()
	_update_ui()
	_on_waterbody_close_button_pressed()
	call_deferred("_show_first_run_hint", "cast")

func _on_waterbody_close_button_pressed() -> void:
	_arm_modal_tap_guard()
	call_deferred("_close_waterbody_ui_after_guard")

func _close_waterbody_ui_after_guard() -> void:
	waterbody_ui.close()

func _get_selected_tackle_item() -> Dictionary:
	return tackle_ui._get_selected_tackle_item()

func _get_tackle_item_display_text(item: Dictionary) -> String:
	return tackle_ui._get_tackle_item_display_text(item)

func _get_tackle_item_details_text(item: Dictionary) -> String:
	return tackle_ui._get_tackle_item_details_text(item)

func _get_tackle_stats_text(item: Dictionary) -> String:
	return tackle_ui._get_tackle_stats_text(item)

func _get_tackle_compare_text(item: Dictionary) -> String:
	return tackle_ui._get_tackle_compare_text(item)

func _get_tackle_setup_hints_text(max_lines: int = 4) -> String:
	return tackle_ui._get_tackle_setup_hints_text(max_lines)

func _get_tackle_setup_hints() -> Array:
	return tackle_ui._get_tackle_setup_hints()

func _get_no_bite_candidate_reason(spot_id: String) -> String:
	return tackle_ui._get_no_bite_candidate_reason(spot_id)

func _get_tackle_stat_keys(category: String) -> Array:
	return tackle_ui._get_tackle_stat_keys(category)

func _get_tackle_stat_title(key: String) -> String:
	return tackle_ui._get_tackle_stat_title(key)

func _format_tackle_stat_value(key: String, value) -> String:
	return tackle_ui._format_tackle_stat_value(key, value)

func _format_tackle_wear_message(wear: Dictionary) -> String:
	return tackle_ui._format_tackle_wear_message(wear)

func _get_rarity_title(rarity: String) -> String:
	return tackle_ui._get_rarity_title(rarity)

func _get_rarity_color(rarity: String) -> Color:
	return tackle_ui._get_rarity_color(rarity)

func _is_tackle_item_equipped(item: Dictionary) -> bool:
	return tackle_ui._is_tackle_item_equipped(item)

func _reset_reeling_ui() -> void:
	fishing_hud_ui._reset_reeling_ui()

func _update_reeling_ui(state: Dictionary) -> void:
	fishing_hud_ui._update_reeling_ui(state)

func _on_resized() -> void:
	_setup_layout()

func _on_spot_selected(index: int) -> void:
	if _is_catch_reward_open():
		return

	PlayerData.set_current_spot(str(spot_option_button.get_item_metadata(index)))
	_apply_current_water_profile()
	var spot := SpotDatabase.get_spot(PlayerData.current_spot)
	result_label.text = "Выбрано: %s\nГлубина воды: до %.1f м | снасть %.1f м" % [
		spot["name"],
		float(spot.get("max_depth", spot.get("depth", 0.0))),
		PlayerData.fishing_depth
	]

	SaveManager.save_game()
	_update_ui()
	_show_first_run_hint("cast")

func _get_player_condition_cast_block_reason() -> String:
	var condition_manager := get_node_or_null("/root/PlayerConditionManager")
	if condition_manager == null:
		return ""
	if condition_manager.has_method("can_start_fishing") and bool(condition_manager.call("can_start_fishing")):
		return ""
	if condition_manager.has_method("get_fishing_block_message"):
		return str(condition_manager.call("get_fishing_block_message"))
	return "Вы слишком плохо себя чувствуете. Нужно уйти с водоёма и восстановиться."

func _show_condition_cast_block_popup(message: String) -> void:
	if failure_popup_ui == null or not failure_popup_ui.has_method("show"):
		return
	var lines := message.split("\n", false)
	var primary_message := message
	var hint := "Перекусить, выпить, открыть инвентарь, зайти в дом рыбака или отдохнуть."
	if not lines.is_empty():
		primary_message = str(lines[0])
	if lines.size() > 1:
		var hint_lines: Array = []
		for index in range(1, lines.size()):
			hint_lines.append(str(lines[index]))
		hint = "\n".join(hint_lines)
	failure_popup_ui.show({
		"title": "Плохое самочувствие",
		"message": primary_message,
		"raw_message": primary_message,
		"hint": hint,
		"severity": "high"
	})

func _on_fish_button_pressed(cast_power: float = MIN_CAST_POWER, cast_hold_time: float = 0.0) -> void:
	if _is_catch_reward_open():
		return

	if is_cast_animating:
		return
	_close_quick_tackle_radial()

	if _fishing_ui_state == FishingUiState.CAUGHT:
		if _has_pending_catch_reward():
			return
		_return_to_idle_after_result()
		return

	if _fishing_ui_state == FishingUiState.FAILED:
		if failure_popup_ui != null and failure_popup_ui.has_method("requires_acknowledgement") and failure_popup_ui.requires_acknowledgement():
			if failure_popup_ui.has_method("bring_to_front"):
				failure_popup_ui.bring_to_front()
			return
		_return_to_idle_after_result()
		return

	if _fishing_ui_state == FishingUiState.WAITING and _is_reel_tackle_mode():
		return

	if _fishing_ui_state == FishingUiState.WAITING and bool(FishingManager.get("use_new_bite_system")):
		FishingManager.try_hook()
		return

	if _fishing_ui_state != FishingUiState.IDLE:
		return

	var selected_index := spot_option_button.selected
	PlayerData.set_current_spot(str(spot_option_button.get_item_metadata(selected_index)))

	var condition_block_reason := _get_player_condition_cast_block_reason()
	if condition_block_reason != "":
		result_label.text = condition_block_reason
		_show_condition_cast_block_popup(condition_block_reason)
		_show_toast(condition_block_reason, false)
		timer_label.text = "Готов к забросу"
		_update_ui()
		return

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

	if not PlayerData.has_current_bait():
		result_label.text = "Нет наживки."
		_show_toast("Нет наживки", false)
		timer_label.text = "Готов к забросу"
		_update_ui()
		return

	var cast_depth_context := _build_cast_depth_context(cast_power, cast_hold_time)
	_debug_log_cast_depth(cast_depth_context)

	_hide_modal_roots_except("")
	_refresh_modal_input_blocker()
	SaveManager.save_game()

	_pending_cast_spot_id = PlayerData.current_spot
	_pending_cast_valid = bool(cast_depth_context.get("valid", true))
	_pending_cast_depth_context = cast_depth_context
	is_cast_animating = true
	timer_label.text = "Заброс..."
	result_label.text = "Снасть летит к воде..."
	_call_audio_manager("play_cast")
	if fishing_presence_ui != null:
		fishing_presence_ui.start_cast_visual(float(cast_depth_context.get("cast_power", cast_power)))
	_update_ui()
	_show_first_run_hint("wait_bite")


func _on_stop_fishing_button_pressed() -> void:
	_cancel_current_fishing_wait()


func _cancel_current_fishing_wait() -> void:
	if _should_ignore_base_ui_press() or not _can_cancel_current_fishing_wait():
		return

	var cancelled := false
	if FishingManager.has_method("cancel_current_fishing"):
		cancelled = bool(FishingManager.cancel_current_fishing())
	elif FishingManager.has_method("cancel_current_fishing_wait"):
		cancelled = bool(FishingManager.cancel_current_fishing_wait())
	if not cancelled:
		return

	_pending_reward_catch = {}
	_pending_cast_spot_id = ""
	_pending_cast_valid = true
	_pending_cast_depth_context = {}
	is_cast_animating = false
	_presence_bite_timer = 0.0
	_presence_caught_timer = 0.0
	_fishing_ui_state = FishingUiState.IDLE
	if fishing_presence_ui != null:
		if fishing_presence_ui.has_method("set_rod_uncasted"):
			fishing_presence_ui.set_rod_uncasted()
		else:
			fishing_presence_ui.stop_cast_visual()
	FishingManager.set_reel_input(false)
	timer_label.text = "Готов к забросу"
	result_label.text = "Ловля прекращена. Удочка вытянута."
	fight_status_label.text = ""
	_hide_float_bite_preview()
	_reset_reeling_ui()
	_update_ui()


func _on_reel_button_down() -> void:
	if _can_begin_cast_charge():
		_start_cast_charge()
		return
	if _fishing_ui_state == FishingUiState.WAITING and _is_reel_tackle_mode():
		FishingManager.set_reel_input(true)
		return
	if _fishing_ui_state == FishingUiState.FIGHTING and FishingManager.is_reeling:
		FishingManager.set_reel_input(true)

func _on_reel_button_up() -> void:
	if _cast_charge_active:
		_release_cast_charge()
		return
	FishingManager.set_reel_input(false)

func _on_sell_all_button_pressed() -> void:
	if _is_catch_reward_open():
		return

	var sales_service := get_node_or_null("/root/SalesService")
	var earned := int(sales_service.call("sell_all_fish_best_offer")) if sales_service != null and sales_service.has_method("sell_all_fish_best_offer") else InventoryManager.sell_all()
	var sale_summary: Dictionary = sales_service.call("get_last_sale_summary") if sales_service != null and sales_service.has_method("get_last_sale_summary") else InventoryManager.get_last_sale_summary()
	var contract_reward: int = int(sale_summary.get("contract_reward_total", 0))
	var sale_total: int = int(sale_summary.get("sale_total", max(earned - contract_reward, 0)))

	if earned > 0:
		result_label.text = "Рыба продана. Получено: %s" % UIFormatters.format_money(float(earned))
		if contract_reward > 0:
			result_label.text += " Контракты: +%s" % UIFormatters.format_money(float(contract_reward))
	else:
		result_label.text = "Садок пуст. Продавать пока нечего."

	SaveManager.save_game()
	_update_ui()

	if earned > 0:
		var notice := "Рыба продана: +%s" % UIFormatters.format_money(float(sale_total))
		if contract_reward > 0:
			notice += " Контракты: +%s" % UIFormatters.format_money(float(contract_reward))
		_show_basket_notice(notice, true)
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
	var sales_service := get_node_or_null("/root/SalesService")
	var price := int(sales_service.call("sell_fish_at", fish_index)) if sales_service != null and sales_service.has_method("sell_fish_at") else InventoryManager.sell_fish_at(fish_index)
	var sale_summary: Dictionary = sales_service.call("get_last_sale_summary") if sales_service != null and sales_service.has_method("get_last_sale_summary") else InventoryManager.get_last_sale_summary()
	var supplier_name := str(sale_summary.get("supplier_name", "Местный рынок"))
	var contract_reward := int(sale_summary.get("contract_reward_total", 0))
	var sale_total := int(sale_summary.get("sale_total", max(price - contract_reward, 0)))
	result_label.text = "Рыба продана: %s +%s" % [
		str(fish.get("name", "-")),
		UIFormatters.format_money(float(sale_total))
	]
	if contract_reward > 0:
		result_label.text += " Контракт: +%s" % UIFormatters.format_money(float(contract_reward))
	_show_basket_notice("Продано: +%s | %s" % [UIFormatters.format_money(float(sale_total)), supplier_name], true)
	SaveManager.save_game()
	_update_ui()

func _on_nav_fish_button_pressed() -> void:
	if _open_screen_via_navigation("fish"):
		return
	_open_fishing_screen()


func _open_screen_via_navigation(screen_id: String) -> bool:
	if navigation_controller == null or not navigation_controller.has_method("open_screen"):
		return false
	navigation_controller.open_screen(screen_id)
	return true

func _set_map_return_target_for_screen(screen_id: String, waterbody_id: String, spot_id: String = "") -> void:
	var id := screen_id.strip_edges().to_lower()
	if id != "shop" and id != "harbor":
		_clear_map_return_target()
		return

	_map_return_screen_id = id
	_map_return_waterbody_id = waterbody_id if waterbody_id != "" else PlayerData.current_waterbody
	_map_return_spot_id = spot_id if spot_id != "" else PlayerData.current_spot

func _clear_map_return_target() -> void:
	_map_return_screen_id = ""
	_map_return_waterbody_id = ""
	_map_return_spot_id = ""

func _restore_map_after_screen_close(screen_id: String) -> bool:
	if _map_return_screen_id != screen_id:
		return false

	var waterbody_id := _map_return_waterbody_id
	var spot_id := _map_return_spot_id
	_clear_map_return_target()

	if waterbody_ui == null or not waterbody_ui.has_method("open_waterbody_map"):
		return false

	return bool(waterbody_ui.call("open_waterbody_map", waterbody_id, spot_id, true))


func _open_fishing_screen() -> void:
	if _should_ignore_base_ui_press():
		return
	if _is_catch_reward_open():
		return

	_active_nav_tab = "fish"
	_hide_modal_roots_except("")
	_refresh_modal_input_blocker()
	_refresh_bottom_nav_styles()


func close_game_panels_before_opening_new_one(_screen_id: String = "") -> void:
	if _map_return_screen_id != "" and _screen_id != _map_return_screen_id:
		_clear_map_return_target()
	_close_quick_tackle_radial(false)
	if system_menu_ui != null:
		system_menu_ui.close_menu()
	if _is_catch_reward_open():
		return
	_hide_modal_roots_except("")
	_refresh_modal_input_blocker()
	_request_depth_hud_refresh()


func _close_profile_and_encyclopedia(reset_nav: bool = false) -> void:
	if system_menu_ui != null:
		system_menu_ui.close_menu()
	if profile_ui != null:
		profile_ui.close(reset_nav)
	if encyclopedia_ui != null:
		encyclopedia_ui.close(reset_nav)
	if fish_harbor_ui != null:
		fish_harbor_ui.visible = false


func _prepare_for_menu_open(menu_name: String) -> void:
	_hide_current_tackle_popup()
	_close_quick_tackle_radial(false)
	if popup_manager != null and popup_manager.has_method("prepare_for_menu_open"):
		popup_manager.prepare_for_menu_open(menu_name)
		return

	_close_profile_and_encyclopedia(false)


func _on_basket_button_pressed() -> void:
	if _open_screen_via_navigation("keepnet"):
		return
	_open_keepnet()


func _open_keepnet() -> void:
	if _should_ignore_base_ui_press():
		return

	_prepare_for_menu_open("basket")
	keepnet_ui.open()

func _on_basket_close_button_pressed() -> void:
	_arm_modal_tap_guard()
	call_deferred("_close_keepnet_ui_after_guard")

func _close_keepnet_ui_after_guard() -> void:
	keepnet_ui.close()

func _on_inventory_button_pressed() -> void:
	if _open_screen_via_navigation("inventory"):
		return
	_open_inventory()


func _open_inventory() -> void:
	if _should_ignore_base_ui_press():
		return

	_prepare_for_menu_open("inventory")
	_inventory_category = "all"
	_selected_inventory_item_id = ""
	inventory_ui.open()

func can_quick_change_tackle() -> bool:
	return not _should_ignore_base_ui_press() and _fishing_ui_state == FishingUiState.IDLE and not is_cast_animating and not _cast_charge_active

func refresh_after_quick_tackle_change() -> void:
	_update_ui()
	if tackle_panel != null and tackle_panel.visible:
		_update_tackle_ui()
	if inventory_panel != null and inventory_panel.visible:
		_update_inventory_ui()

func _refresh_current_tackle_hud() -> void:
	if current_tackle_button == null:
		return

	current_tackle_button.text = ""
	current_tackle_button.tooltip_text = ""
	current_tackle_button.visible = false
	current_tackle_button.disabled = true
	current_tackle_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hide_current_tackle_popup()

func _get_current_tackle_button_text() -> String:
	var tackle_type := "Снасть"
	if PlayerData != null and PlayerData.has_method("get_current_tackle_type_title"):
		tackle_type = str(PlayerData.get_current_tackle_type_title())
	var rod_name := _get_current_tackle_slot_name("rod")
	if rod_name == "":
		return "%s\nНе выбрана" % tackle_type
	return "%s\n%s" % [tackle_type, _trim_ui_text(rod_name, 20)]

func _get_current_tackle_slot_name(slot_id: String) -> String:
	if PlayerData == null:
		return ""
	var component: Dictionary = {}
	if PlayerData.has_method("get_current_tackle_slot"):
		var value = PlayerData.get_current_tackle_slot(slot_id)
		if value is Dictionary:
			component = value
	elif PlayerData.current_tackle is Dictionary:
		var raw = PlayerData.current_tackle.get(slot_id, {})
		if raw is Dictionary:
			component = raw
	return str(component.get("display_name_ru", component.get("name", ""))).strip_edges()

func _trim_ui_text(text: String, max_chars: int) -> String:
	if text.length() <= max_chars:
		return text
	return text.substr(0, max(max_chars - 1, 1)) + "…"

func _update_current_tackle_hold() -> void:
	if current_tackle_button == null:
		return
	if _current_tackle_press_started_msec <= 0 or _current_tackle_long_press_triggered:
		return
	if Time.get_ticks_msec() - _current_tackle_press_started_msec < CURRENT_TACKLE_LONG_PRESS_MSEC:
		return
	_current_tackle_long_press_triggered = true
	_hide_current_tackle_popup()
	open_full_tackle_from_quick_panel()

func _on_current_tackle_button_down() -> void:
	_current_tackle_press_started_msec = Time.get_ticks_msec()
	_current_tackle_long_press_triggered = false

func _on_current_tackle_button_up() -> void:
	_current_tackle_press_started_msec = 0

func _on_current_tackle_button_pressed() -> void:
	if _current_tackle_long_press_triggered:
		_current_tackle_long_press_triggered = false
		return
	if _should_ignore_base_ui_press():
		return
	if current_tackle_popup != null and current_tackle_popup.visible:
		_hide_current_tackle_popup()
	else:
		_show_current_tackle_popup()

func _show_current_tackle_popup() -> void:
	if current_tackle_button == null:
		return
	_ensure_current_tackle_hud_nodes()
	if current_tackle_popup == null or current_tackle_popup_box == null:
		return

	for child in current_tackle_popup_box.get_children():
		current_tackle_popup_box.remove_child(child)
		child.queue_free()

	var title_label := Label.new()
	title_label.text = "Текущая снасть"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 13)
	title_label.add_theme_color_override("font_color", Color(0.92, 1.0, 0.94, 1.0))
	current_tackle_popup_box.add_child(title_label)

	# TODO: Add saved rig presets when the beta scope includes multiple ready tackle builds.
	var edit_button := _create_current_tackle_popup_button("Редактировать", true)
	edit_button.tooltip_text = "Открыть сборку снасти"
	edit_button.pressed.connect(_on_current_tackle_edit_pressed)
	current_tackle_popup_box.add_child(edit_button)

	var close_button := _create_current_tackle_popup_button("Закрыть", false)
	close_button.tooltip_text = _get_current_tackle_popup_tooltip()
	close_button.pressed.connect(_hide_current_tackle_popup)
	current_tackle_popup_box.add_child(close_button)

	var popup_size := _get_current_tackle_popup_size()
	var popup_pos := current_tackle_button.global_position + Vector2(current_tackle_button.size.x - popup_size.x, current_tackle_button.size.y + 8.0)
	var viewport_size := get_viewport_rect().size
	popup_pos.x = clamp(popup_pos.x, 10.0, max(10.0, viewport_size.x - popup_size.x - 10.0))
	popup_pos.y = clamp(popup_pos.y, 10.0, max(10.0, viewport_size.y - popup_size.y - 10.0))

	current_tackle_popup.position = popup_pos
	current_tackle_popup.size = popup_size
	current_tackle_popup.custom_minimum_size = popup_size
	current_tackle_popup.z_index = 330
	if ui_theme != null:
		ui_theme.apply_popup_window_style(current_tackle_popup)

	current_tackle_popup_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	current_tackle_popup_box.offset_left = 10.0
	current_tackle_popup_box.offset_top = 10.0
	current_tackle_popup_box.offset_right = -10.0
	current_tackle_popup_box.offset_bottom = -10.0
	current_tackle_popup.visible = true

func _hide_current_tackle_popup() -> void:
	if current_tackle_popup != null:
		current_tackle_popup.hide()

func _get_current_tackle_popup_size() -> Vector2:
	var scale_value := clampf(min(get_viewport_rect().size.x / BASE_SCREEN_SIZE.x, get_viewport_rect().size.y / BASE_SCREEN_SIZE.y), 0.86, 1.18)
	return Vector2(clamp(214.0 * scale_value, 190.0, 250.0), clamp(150.0 * scale_value, 136.0, 176.0))

func _get_current_tackle_popup_tooltip() -> String:
	if PlayerData != null and PlayerData.has_method("get_tackle_text"):
		return str(PlayerData.get_tackle_text())
	return _get_current_tackle_button_text()

func _create_current_tackle_popup_button(text: String, primary := false) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.clip_text = true
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.custom_minimum_size = Vector2(0.0, 46.0)
	button.add_theme_font_size_override("font_size", 13)
	_apply_button_style(button, STYLE_PRIMARY_BUTTON if primary else STYLE_SECONDARY_BUTTON)
	return button

func _on_current_tackle_current_pressed() -> void:
	_hide_current_tackle_popup()
	_show_toast("Текущая снасть выбрана", true)

func _on_current_tackle_edit_pressed() -> void:
	_hide_current_tackle_popup()
	open_full_tackle_from_quick_panel()

func open_full_tackle_from_quick_panel() -> void:
	if _should_ignore_base_ui_press():
		return
	_prepare_for_menu_open("tackle")
	tackle_ui.open()

func open_tackle_category_from_quick_panel(category_id: String) -> void:
	if _should_ignore_base_ui_press():
		return
	_prepare_for_menu_open("tackle")
	tackle_ui.open()
	_set_tackle_category(category_id)

func open_shop_category(category_id: String) -> void:
	if _should_ignore_base_ui_press():
		return
	_prepare_for_menu_open("shop")
	_shop_category = category_id
	_shop_page = 0
	shop_ui.open()
	_set_shop_category(category_id)

func _on_tackle_button_pressed() -> void:
	if _should_ignore_base_ui_press():
		return

	_prepare_for_menu_open("tackle")
	tackle_ui.open()

func _on_shop_button_pressed() -> void:
	if _open_screen_via_navigation("shop"):
		return
	_open_shop()


func _open_shop() -> void:
	if _should_ignore_base_ui_press():
		return

	_prepare_for_menu_open("shop")
	shop_ui.open()

func _on_harbor_button_pressed() -> void:
	if _open_screen_via_navigation("harbor"):
		return
	_open_harbor()


func _open_harbor() -> void:
	if _should_ignore_base_ui_press():
		return

	_prepare_for_menu_open("harbor")
	_ensure_fish_harbor_ui()
	if fish_harbor_ui != null and fish_harbor_ui.has_method("open"):
		fish_harbor_ui.call("open")

func _on_encyclopedia_button_pressed() -> void:
	if _open_screen_via_navigation("encyclopedia"):
		return
	_open_encyclopedia()


func _open_encyclopedia() -> void:
	if _should_ignore_base_ui_press():
		return

	_close_quick_tackle_radial(false)
	_hide_current_tackle_popup()
	if profile_ui != null:
		profile_ui.close(false)
	if fish_harbor_ui != null:
		fish_harbor_ui.visible = false
	encyclopedia_ui.open()

func _on_map_button_pressed() -> void:
	if _open_screen_via_navigation("map"):
		return
	_open_map()


func _open_map() -> void:
	if _should_ignore_base_ui_press():
		return

	_prepare_for_menu_open("waterbody")
	waterbody_ui.open()

func _on_profile_button_pressed() -> void:
	if _open_screen_via_navigation("profile"):
		return
	_open_profile()


func _open_profile() -> void:
	if _should_ignore_base_ui_press():
		return

	_close_quick_tackle_radial(false)
	_hide_current_tackle_popup()
	if encyclopedia_ui != null:
		encyclopedia_ui.close(false)
	if fish_harbor_ui != null:
		fish_harbor_ui.visible = false
	profile_ui.open()


func _open_settings() -> void:
	if _should_ignore_base_ui_press():
		return
	_close_quick_tackle_radial(false)
	if system_menu_ui != null and system_menu_ui.has_method("open_settings"):
		system_menu_ui.open_settings()
	elif system_menu_ui != null and system_menu_ui.has_method("_on_settings_pressed"):
		system_menu_ui._on_settings_pressed()

func _on_bait_button_pressed() -> void:
	if _should_ignore_base_ui_press():
		return

	if _is_catch_reward_open():
		return

	_prepare_for_menu_open("inventory")
	_active_nav_tab = "inventory"
	_inventory_category = "bait"
	_selected_inventory_item_id = ""
	inventory_ui.open()

func _on_shop_close_button_pressed() -> void:
	_arm_modal_tap_guard()
	call_deferred("_close_shop_ui_after_guard")

func _close_shop_ui_after_guard() -> void:
	shop_ui.close()

func _on_shop_buy_pressed(item_id: String) -> void:
	var shop_item := _get_shop_item(item_id)

	if shop_item.is_empty():
		return

	var price := float(shop_item.get("price", 0.0))
	var quantity := int(shop_item.get("quantity", 1))

	if PlayerData.money < price:
		_show_shop_notice("Недостаточно монет", false)
		_play_audio_hook(shop_error_audio)
		_play_shop_card_feedback(item_id, false)
		return

	PlayerData.money -= price
	PlayerData.add_owned_item(_get_shop_inventory_item(shop_item), quantity)

	var purchased_category := str(shop_item.get("category", ""))
	if ["rod", "line", "leader", "float", "hook", "bait"].has(purchased_category):
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
	_arm_modal_tap_guard()
	call_deferred("_close_inventory_ui_after_guard")

func _close_inventory_ui_after_guard() -> void:
	inventory_ui.close()

# Gameplay flow completion intentionally stays in Main for now.
func _on_catch_keep_button_pressed() -> void:
	if not _catch_reward_buttons_ready:
		return

	var catch_data := _pending_reward_catch.duplicate(true)
	_pending_reward_catch = {}
	_hide_catch_reward_popup()

	var result: Dictionary = {}
	if catch_result_handler != null:
		result = catch_result_handler.handle_keep(catch_data)
	else:
		if not catch_data.is_empty():
			PlayerData.register_catch_stats(catch_data)
		result = {
			"success": not catch_data.is_empty(),
			"message": "Рыба в садке: %s\nНажми “Вытянуть”, чтобы закончить цикл." % str(catch_data.get("name", "-")),
			"catch_data": catch_data
		}
	result_label.text = str(result.get("message", "Рыба в садке."))

	SaveManager.save_game()
	_return_to_idle_after_result()
	_show_first_run_hint("sell_fish")
	_try_show_queued_level_up_reward()

# Gameplay flow completion intentionally stays in Main for now.
func _on_catch_release_button_pressed() -> void:
	if not _catch_reward_buttons_ready:
		return

	var catch_data := _pending_reward_catch.duplicate(true)
	_pending_reward_catch = {}
	_hide_catch_reward_popup()

	var result: Dictionary = {}
	if catch_result_handler != null:
		result = catch_result_handler.handle_release(catch_data)
	else:
		var removed := not catch_data.is_empty() and InventoryManager.remove_fish(catch_data)
		var fallback_message := "Рыба отпущена.\nНажми “Вытянуть”, чтобы закончить цикл."
		if removed:
			fallback_message = "Рыба отпущена: %s\nXP за поимку сохранён. Нажми “Вытянуть”." % str(catch_data.get("name", "-"))
		result = {
			"success": removed,
			"message": fallback_message,
			"catch_data": catch_data
		}
	result_label.text = str(result.get("message", "Рыба отпущена."))

	SaveManager.save_game()
	_return_to_idle_after_result()
	_try_show_queued_level_up_reward()

func _set_inventory_category(category: String) -> void:
	inventory_ui._set_inventory_category(category)

func _on_inventory_item_selected(index: int) -> void:
	inventory_ui._on_inventory_item_selected(index)

func _on_inventory_equip_button_pressed() -> void:
	var selected_item := _get_selected_inventory_item()
	var selected_category := str(selected_item.get("category", ""))
	if ["food", "drink", "clothing", "shelter"].has(selected_category):
		var result: Dictionary = PlayerData.use_survival_item(str(selected_item.get("id", ""))) if PlayerData.has_method("use_survival_item") else {"success": false, "message": "Действие недоступно."}
		var success := bool(result.get("success", false))
		var message := str(result.get("message", "Действие недоступно."))
		result_label.text = message
		_show_toast(message, success)
		if success:
			SaveManager.save_game()
		_update_ui()
		return
	var validation_service := get_node_or_null("/root/TackleValidationService")
	var block_reason := str(validation_service.call("get_equip_block_reason", "", selected_item)) if validation_service != null and validation_service.has_method("get_equip_block_reason") else PlayerData.get_equip_block_reason(selected_item)

	if selected_item.is_empty() or block_reason != "":
		result_label.text = block_reason if block_reason != "" else "Этот предмет нельзя экипировать."
		_show_toast(result_label.text, false)
		_update_inventory_ui()
		return

	if PlayerData.equip_item(str(selected_item.get("id", ""))):
		result_label.text = "Экипировано: %s" % str(selected_item.get("name", "-"))
		SaveManager.save_game()
	else:
		result_label.text = "Не удалось экипировать предмет."

	_update_ui()

func _on_inventory_repair_button_pressed() -> void:
	var selected_item := _get_selected_inventory_item()
	if selected_item.is_empty():
		return
	var repair_service := get_node_or_null("/root/RepairService")
	if repair_service != null and repair_service.has_method("repair_item"):
		_apply_repair_result(repair_service.call("repair_item", str(selected_item.get("id", ""))))
	else:
		_apply_repair_result(PlayerData.repair_owned_item(str(selected_item.get("id", ""))))

func _on_inventory_discard_button_pressed() -> void:
	var selected_item := _get_selected_inventory_item()
	if selected_item.is_empty():
		return
	_request_discard_owned_item(str(selected_item.get("id", "")), "inventory")

func _apply_repair_result(result: Dictionary) -> void:
	var success := bool(result.get("success", false))
	var message := str(result.get("message", "Ремонт недоступен."))
	result_label.text = message
	_show_toast(message, success)
	if success:
		SaveManager.save_game()
	_update_ui()

func _request_discard_owned_item(item_id: String, source: String) -> void:
	var item := PlayerData.get_owned_item(item_id)
	if item.is_empty():
		_show_toast("Предмет не найден.", false)
		return
	var repair_service := get_node_or_null("/root/RepairService")
	var can_discard := bool(repair_service.call("can_discard_item", item)) if repair_service != null and repair_service.has_method("can_discard_item") else PlayerData.can_discard_item(item)
	if not can_discard:
		_show_toast("Выбросить можно только полностью сломанную снасть.", false)
		return

	_pending_discard_item_id = item_id
	_pending_discard_source = source
	_ensure_discard_confirm_dialog()
	discard_confirm_dialog.title = "Выбросить снасть"
	discard_confirm_dialog.dialog_text = "Выбросить сломанную снасть?\nЭто действие нельзя отменить."
	if discard_confirm_dialog.get_ok_button() != null:
		discard_confirm_dialog.get_ok_button().text = "Выбросить"
	if discard_confirm_dialog.get_cancel_button() != null:
		discard_confirm_dialog.get_cancel_button().text = "Отмена"
	discard_confirm_dialog.popup_centered(Vector2i(360, 160))

func _ensure_discard_confirm_dialog() -> void:
	if discard_confirm_dialog != null and is_instance_valid(discard_confirm_dialog):
		return
	discard_confirm_dialog = ConfirmationDialog.new()
	discard_confirm_dialog.name = "DiscardBrokenTackleDialog"
	discard_confirm_dialog.exclusive = true
	discard_confirm_dialog.confirmed.connect(_on_discard_confirmed)
	add_child(discard_confirm_dialog)

func _on_discard_confirmed() -> void:
	if _pending_discard_item_id == "":
		return
	var repair_service := get_node_or_null("/root/RepairService")
	var result: Dictionary = {}
	if repair_service != null and repair_service.has_method("discard_item"):
		var result_value = repair_service.call("discard_item", _pending_discard_item_id)
		if result_value is Dictionary:
			result = result_value
	else:
		result = PlayerData.discard_owned_item(_pending_discard_item_id)
	var success := bool(result.get("success", false))
	var message := str(result.get("message", "Не удалось выбросить предмет."))
	_pending_discard_item_id = ""
	_pending_discard_source = ""
	result_label.text = message
	_show_toast(message, success)
	if success:
		SaveManager.save_game()
	_update_ui()

func _return_to_idle_after_result() -> void:
	_pending_reward_catch = {}
	_pending_cast_spot_id = ""
	_pending_cast_valid = true
	_pending_cast_depth_context = {}
	is_cast_animating = false
	_hide_catch_reward_popup(false)
	_hide_float_bite_preview()
	if fishing_presence_ui != null:
		if fishing_presence_ui.has_method("set_rod_uncasted"):
			fishing_presence_ui.set_rod_uncasted()
		else:
			fishing_presence_ui.stop_cast_visual()
	if failure_popup_ui != null:
		failure_popup_ui.close()
	if FishingManager.has_method("reset_after_result"):
		FishingManager.reset_after_result()
	_presence_bite_timer = 0.0
	_presence_caught_timer = 0.0
	_fishing_ui_state = FishingUiState.IDLE
	timer_label.text = "Готов к забросу"
	result_label.text = "Удочка вытянута. Можно забрасывать снова."
	_reset_reeling_ui()
	_update_ui()

func _is_reel_tackle_mode() -> bool:
	if not BuildConfig.ENABLE_SPINNING_FEATURES:
		return false
	if PlayerData == null:
		return false
	if PlayerData.has_method("get_current_tackle_type") and str(PlayerData.call("get_current_tackle_type")) != "spinning":
		return false
	if PlayerData.has_method("get_current_fight_mode"):
		return str(PlayerData.call("get_current_fight_mode")) == "reel"
	if PlayerData.has_method("get_current_rod_requires_reel"):
		return bool(PlayerData.call("get_current_rod_requires_reel"))
	return false

func _on_cast_visual_finished() -> void:
	if not is_cast_animating:
		return

	var reel_tackle_mode := _is_reel_tackle_mode()
	var spot_id := _pending_cast_spot_id
	var cast_valid := _pending_cast_valid
	var cast_depth_context := _pending_cast_depth_context.duplicate(true)
	_pending_cast_spot_id = ""
	_pending_cast_valid = true
	_pending_cast_depth_context = {}
	is_cast_animating = false

	if spot_id == "":
		_update_ui()
		return

	if not cast_valid:
		_fishing_ui_state = FishingUiState.IDLE
		if not reel_tackle_mode and fishing_presence_ui != null and fishing_presence_ui.has_method("play_float_lay_down_animation"):
			fishing_presence_ui.play_float_lay_down_animation()
		var shallow_message := "Слишком мелко. Забросьте дальше или уменьшите глубину."
		result_label.text = shallow_message
		timer_label.text = "Готов к забросу"
		_show_toast(shallow_message, false)
		if not cast_depth_context.is_empty():
			fight_status_label.text = "Глубина воды: %.1f м | Снасть: %.1f м" % [
				float(cast_depth_context.get("water_depth_at_cast", MIN_SHORE_DEPTH)),
				float(cast_depth_context.get("float_depth", PlayerData.fishing_depth))
			]
		_update_ui()
		return

	_fishing_ui_state = FishingUiState.WAITING
	if not reel_tackle_mode and fishing_presence_ui != null and fishing_presence_ui.has_method("set_float_in_water"):
		fishing_presence_ui.set_float_in_water(true)
	result_label.text = "Туман сгущается. Ждем клев..."
	FishingManager.start_fishing(spot_id)
	_update_ui()

func _on_fishing_started(seconds: int) -> void:
	_presence_bite_timer = 0.0
	_presence_caught_timer = 0.0
	_fishing_ui_state = FishingUiState.WAITING
	var reel_tackle_mode := _is_reel_tackle_mode()
	if not reel_tackle_mode and fishing_presence_ui != null and fishing_presence_ui.has_method("set_float_in_water"):
		fishing_presence_ui.set_float_in_water(true)
	_reset_reeling_ui()
	if bool(FishingManager.get("use_new_bite_system")):
		timer_label.text = "Следи за поплавком"
		fight_status_label.text = "Ждём поклёвку. Нажимай только когда поплавок резко уйдёт."
		if reel_tackle_mode:
			timer_label.text = "Проводка"
			fight_status_label.text = "Зажми кнопку, чтобы мотать катушкой."
	else:
		timer_label.text = "Клев через: %d сек." % seconds
		fight_status_label.text = "Ожидание поклевки..."
	_update_ui()

func _on_fishing_tick(seconds_left: int) -> void:
	timer_label.text = "Клев через: %d сек." % seconds_left

func _on_waiting_for_bite_started() -> void:
	_presence_bite_timer = 0.0
	_presence_caught_timer = 0.0
	_fishing_ui_state = FishingUiState.WAITING
	var reel_tackle_mode := _is_reel_tackle_mode()
	if not reel_tackle_mode and fishing_presence_ui != null and fishing_presence_ui.has_method("set_float_in_water"):
		fishing_presence_ui.set_float_in_water(true)
	if reel_tackle_mode:
		_hide_float_bite_preview()
	else:
		_show_float_bite_preview_idle()
	_reset_reeling_ui()
	timer_label.text = "Следи за поплавком"
	result_label.text = "Поплавок в воде. Жди настоящую поклёвку и нажми “Подсечь”."
	fight_status_label.text = "Ожидание поклёвки..."
	if reel_tackle_mode:
		timer_label.text = "Проводка"
		result_label.text = "Приманка в воде. Зажми кнопку и веди её катушкой."
		fight_status_label.text = "Мотай катушкой: поклёвка будет на проводке."
	_update_ui()

func _on_float_nudge(nudge_data: Dictionary) -> void:
	if _is_reel_tackle_mode():
		return
	if fishing_presence_ui != null and fishing_presence_ui.has_method("play_float_nudge"):
		fishing_presence_ui.play_float_nudge(nudge_data)
	if float_bite_preview != null and float_bite_preview.visible and float_bite_preview.has_method("play_wind_nudge"):
		float_bite_preview.call("play_wind_nudge", nudge_data)

	if str(nudge_data.get("kind", "small")) == "suspicious":
		fight_status_label.text = "Поплавок подозрительно качнулся..."

func _on_bite_preview_event(event_data: Dictionary) -> void:
	if _is_reel_tackle_mode() or _is_menu_overlay_open():
		_hide_float_bite_preview()
		return

	_ensure_float_bite_preview()
	if float_bite_preview == null:
		return
	if not float_bite_preview.visible and float_bite_preview.has_method("show_preview"):
		float_bite_preview.call("show_preview")

	var phase := str(event_data.get("phase", ""))
	var style := str(event_data.get("visual_style", ""))
	match phase:
		"interest":
			if float_bite_preview.has_method("play_interest"):
				float_bite_preview.call("play_interest", event_data)
		"nibble":
			if style == "cautious_nibble" and float_bite_preview.has_method("play_cautious_nibble"):
				float_bite_preview.call("play_cautious_nibble", event_data)
			elif style == "small_fish_taps" and float_bite_preview.has_method("play_small_fish_taps"):
				float_bite_preview.call("play_small_fish_taps", event_data)
			elif float_bite_preview.has_method("play_nibble"):
				float_bite_preview.call("play_nibble", event_data)
		"lost_interest":
			if float_bite_preview.has_method("play_lost_interest"):
				float_bite_preview.call("play_lost_interest", event_data)
		"bait_stolen":
			if float_bite_preview.has_method("play_bait_stolen"):
				float_bite_preview.call("play_bait_stolen", event_data)
		"take", "strong_bite":
			_play_float_bite_preview_take(style, event_data)


func _play_float_bite_preview_take(style: String, data: Dictionary) -> void:
	if float_bite_preview == null or not is_instance_valid(float_bite_preview):
		return
	match style:
		"aggressive_take":
			if float_bite_preview.has_method("play_aggressive_take"):
				float_bite_preview.call("play_aggressive_take", data)
		"heavy_take":
			if float_bite_preview.has_method("play_heavy_take"):
				float_bite_preview.call("play_heavy_take", data)
		"erratic_take":
			if float_bite_preview.has_method("play_erratic_take"):
				float_bite_preview.call("play_erratic_take", data)
		_:
			if float_bite_preview.has_method("play_submerge"):
				float_bite_preview.call("play_submerge", data)

func _on_lure_retrieve_started(state: Dictionary) -> void:
	_hide_float_bite_preview()
	_fishing_ui_state = FishingUiState.WAITING
	_presence_bite_timer = 0.0
	_presence_caught_timer = 0.0
	_apply_lure_retrieve_state(state)
	timer_label.text = "Проводка"
	result_label.text = "Приманка упала в воду. Зажми кнопку и мотай катушкой."
	fight_status_label.text = "Веди приманку к берегу, поклёвка будет на движении."
	_update_ui()

func _on_lure_retrieve_updated(state: Dictionary) -> void:
	if _fishing_ui_state != FishingUiState.WAITING:
		return
	_apply_lure_retrieve_state(state)
	var progress: float = clamp(float(state.get("retrieve_progress", 0.0)), 0.0, 1.0)
	var input_active: bool = bool(state.get("input_active", false))
	timer_label.text = "Проводка %.0f%%" % (progress * 100.0)
	fight_status_label.text = "Катушка мотает. Приманка идёт к берегу." if input_active else "Зажми кнопку, чтобы продолжить проводку."
	_update_ui()

func _on_lure_retrieve_finished(state: Dictionary) -> void:
	_hide_float_bite_preview()
	_apply_lure_retrieve_state(state)
	_fishing_ui_state = FishingUiState.IDLE
	_presence_bite_timer = 0.0
	_presence_caught_timer = 0.0
	if fishing_presence_ui != null and fishing_presence_ui.has_method("set_rod_uncasted"):
		fishing_presence_ui.set_rod_uncasted()
	timer_label.text = "Готов к забросу"
	result_label.text = "Проводка закончилась без поклёвки. Забрось снова."
	fight_status_label.text = "Спиннинг готов к следующему забросу."
	_reset_reeling_ui()
	_update_ui()

func _apply_lure_retrieve_state(state: Dictionary) -> void:
	_last_reeling_state = state.duplicate(true)
	_last_reeling_state["fight_mode"] = "reel"
	_last_reeling_state["phase"] = "retrieve"
	if not _last_reeling_state.has("progress"):
		_last_reeling_state["progress"] = float(state.get("retrieve_progress", 0.0))

func _on_bite_started(bite_data: Dictionary) -> void:
	_fishing_ui_state = FishingUiState.WAITING
	_presence_bite_timer = max(float(bite_data.get("bite_window_seconds", 1.4)), 0.8)
	if float_bite_preview != null and is_instance_valid(float_bite_preview) and float_bite_preview.has_method("play_hook_ready"):
		float_bite_preview.call("play_hook_ready", bite_data)
	else:
		_play_float_bite_preview_take(str(bite_data.get("visual_style", "submerge")), bite_data)
	timer_label.text = "Клюёт! Подсекай!"
	result_label.text = "Поклёвка: %s\nЖми “Подсечь” в момент рывка." % str(bite_data.get("fish_name", "рыба"))
	fight_status_label.text = "Окно подсечки открыто"
	if fishing_presence_ui != null and fishing_presence_ui.has_method("play_bite_signal"):
		fishing_presence_ui.play_bite_signal(bite_data)
	_update_ui()
	_show_first_run_hint("hook")

func _on_bite_window_updated(bite_data: Dictionary) -> void:
	if _fishing_ui_state != FishingUiState.WAITING:
		return

	var remaining := float(bite_data.get("remaining", 0.0))
	timer_label.text = "Подсечь: %.1f" % remaining

func _on_hook_success(catch_data: Dictionary) -> void:
	_hide_float_bite_preview()
	timer_label.text = "Подсечка!"
	result_label.text = "Подсечка! На крючке: %s" % str(catch_data.get("name", "-"))
	if fishing_presence_ui != null and fishing_presence_ui.has_method("play_hook_result"):
		fishing_presence_ui.play_hook_result(true)

func _on_hook_failed(reason: String, data: Dictionary) -> void:
	_fishing_ui_state = FishingUiState.WAITING
	_presence_bite_timer = 0.0
	var message := str(data.get("message", "Рыба сорвалась!"))
	match reason:
		"too_early":
			message = "Рыба испугалась!"
		"early_hook":
			message = "Рано!"
		"late_hook":
			message = "Поздно!"
		"missed_bite":
			message = "Рыба сорвалась!"

	timer_label.text = message
	result_label.text = "%s\nСнасть всё ещё в воде. Жди следующую поклёвку." % message
	fight_status_label.text = "Ожидание продолжается"
	if fishing_presence_ui != null and fishing_presence_ui.has_method("play_hook_result"):
		fishing_presence_ui.play_hook_result(false, reason)
	_show_float_bite_preview_idle()
	_update_ui()

func _on_reeling_started(catch_data: Dictionary, state: Dictionary) -> void:
	_hide_float_bite_preview()
	if not bool(FishingManager.get("use_new_bite_system")):
		_call_audio_manager("play_bite")
	_presence_bite_timer = 0.95
	_presence_caught_timer = 0.0
	_fishing_ui_state = FishingUiState.FIGHTING
	if fishing_presence_ui != null and fishing_presence_ui.has_method("set_rod_visual_state"):
		fishing_presence_ui.set_rod_visual_state("reeling")
	timer_label.text = "Удар по приманке!" if str(state.get("fight_mode", "pole")) == "reel" else "Поклевка!"
	result_label.text = "На крючке: %s\nВес: %s\nРедкость: %s\nПоведение: %s" % [
		catch_data["name"],
		UIFormatters.format_weight_kg(float(catch_data["weight"])),
		catch_data["rarity"],
		catch_data.get("behavior", "-")
	]
	if str(state.get("fight_mode", "pole")) == "reel":
		fight_hint_label.text = "Удерживай кнопку для подмотки. Отпускай, когда фрикцион и натяжение перегружены."
	else:
		fight_hint_label.text = "Удерживай кнопку, чтобы тянуть. Отпускай, когда натяжение уходит выше зеленой зоны."
	_update_reeling_ui(state)
	_update_ui()
	SaveManager.save_game()

func _on_reeling_updated(state: Dictionary) -> void:
	_update_reeling_ui(state)

func _on_fish_caught(catch_data: Dictionary) -> void:
	_call_audio_manager("play_catch_success")
	_hide_float_bite_preview()
	_presence_bite_timer = 0.0
	_presence_caught_timer = 1.1
	_fishing_ui_state = FishingUiState.CAUGHT
	_pending_reward_catch = catch_data.duplicate(true)
	var wait_for_final_visual := false
	if fishing_presence_ui != null and fishing_presence_ui.has_method("play_final_catch_animation"):
		fishing_presence_ui.play_final_catch_animation()
		wait_for_final_visual = fishing_presence_ui.has_signal("final_catch_visual_finished")
	elif fishing_presence_ui != null and fishing_presence_ui.has_method("reset_after_landing"):
		fishing_presence_ui.reset_after_landing()
	timer_label.text = "Рыба поймана"

	var xp_result: Dictionary = catch_data.get("xp_result", {})
	var xp_text: String = "\nXP: +%d" % int(xp_result.get("gained_xp", 0))
	var wear_text := _format_tackle_wear_message(catch_data.get("tackle_wear", {}))

	if bool(xp_result.get("leveled_up", false)):
		xp_text += "\nНовый уровень! LVL %d" % int(xp_result.get("level", PlayerData.level))
		if PlayerData.has_method("claim_level_rewards_for_xp_result"):
			_queue_level_up_rewards(PlayerData.claim_level_rewards_for_xp_result(xp_result))
	if wear_text != "":
		xp_text += "\n%s" % wear_text

	result_label.text = "Поймано: %s\nВес: %s\nЦена: %s%s\nНажми “Вытянуть удочку”." % [
		catch_data["name"],
		UIFormatters.format_weight_kg(float(catch_data["weight"])),
		UIFormatters.format_money(float(catch_data["price"])),
		xp_text
	]
	_reset_reeling_ui()
	SaveManager.save_game()
	_update_ui()
	if wait_for_final_visual:
		await fishing_presence_ui.final_catch_visual_finished
		if _fishing_ui_state != FishingUiState.CAUGHT:
			return
	if catch_popup_controller != null:
		catch_popup_controller.show_catch_result(catch_data)

func _on_fishing_failed_detailed(failure_data: Dictionary) -> void:
	_play_line_break_sfx_if_needed(failure_data)
	_hide_float_bite_preview()
	_last_detailed_failure_msec = Time.get_ticks_msec()
	_pending_reward_catch = {}
	_hide_catch_reward_popup(false)
	_presence_bite_timer = 0.0
	_presence_caught_timer = 0.0
	_fishing_ui_state = FishingUiState.FAILED
	if fishing_presence_ui != null and fishing_presence_ui.has_method("reset_after_landing"):
		fishing_presence_ui.reset_after_landing()
	timer_label.text = "Неудача"

	var title := str(failure_data.get("title", "Неудачная попытка"))
	var message := str(failure_data.get("message", "Рыба ушла."))
	var hint := str(failure_data.get("hint", ""))
	result_label.text = "%s\n%s" % [title, message]
	if hint != "":
		result_label.text += "\n%s" % hint
	result_label.text += "\nНажми “Вытянуть удочку”."

	_reset_reeling_ui()
	SaveManager.save_game()
	_update_ui()
	if failure_popup_ui != null:
		failure_popup_ui.show(failure_data)

func _on_fishing_failed(message: String) -> void:
	if Time.get_ticks_msec() - _last_detailed_failure_msec < 250:
		return

	if _message_mentions_line_break(message):
		_call_audio_manager("play_line_break")

	_hide_float_bite_preview()
	_pending_reward_catch = {}
	_hide_catch_reward_popup(false)
	_presence_bite_timer = 0.0
	_presence_caught_timer = 0.0
	_fishing_ui_state = FishingUiState.FAILED
	if fishing_presence_ui != null and fishing_presence_ui.has_method("reset_after_landing"):
		fishing_presence_ui.reset_after_landing()
	timer_label.text = "Неудача"
	result_label.text = "%s\nНажми “Вытянуть удочку”." % message
	_reset_reeling_ui()
	SaveManager.save_game()
	_update_ui()
