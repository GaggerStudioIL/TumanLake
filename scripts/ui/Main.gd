extends Control

const ShopUIScript := preload("res://scripts/ui/ShopUI.gd")
const KeepnetUIScript := preload("res://scripts/ui/KeepnetUI.gd")
const InventoryUIScript := preload("res://scripts/ui/InventoryUI.gd")
const TackleUIScript := preload("res://scripts/ui/TackleUI.gd")
const WaterbodyUIScript := preload("res://scripts/ui/WaterbodyUI.gd")
const CatchPopupUIScript := preload("res://scripts/ui/CatchPopupUI.gd")
const FishingHUDUIScript := preload("res://scripts/ui/FishingHUDUI.gd")
const FishingPresenceUIScript := preload("res://scripts/ui/FishingPresenceUI.gd")
const ProfileUIScript := preload("res://scripts/ui/ProfileUI.gd")
const FailurePopupUIScript := preload("res://scripts/ui/FailurePopupUI.gd")
const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const TUMAN_LAKE_THEME := preload("res://themes/TumanLakeUI.tres")

const SHOW_DEBUG_PANEL := false
const STYLE_HUD_PANEL := "HUDPanel"
const STYLE_INFO_CARD := "InfoCard"
const STYLE_PRIMARY_BUTTON := "PrimaryButton"
const STYLE_SECONDARY_BUTTON := "SecondaryButton"
const STYLE_BOTTOM_NAV_BUTTON := "BottomNavButton"
const STYLE_BOTTOM_NAV_ACTIVE := "BottomNavActive"
const BASE_SCREEN_SIZE := Vector2(960.0, 540.0)
const HUD_HEIGHT := 44.0
const LEFT_NAV_WIDTH := 140.0
const LEFT_NAV_HEIGHT := 282.0
const ACTION_BAR_HEIGHT := 46.0
const MENU_BACKDROP_Z := 300
const MENU_PANEL_Z := 301
const MODAL_TAP_GUARD_MSEC := 320
const WATER_SURFACE_Y := 402.0
const FLOAT_DEFAULT_POS := Vector2(500.0, 402.0)
const ROD_ANCHOR_POS := Vector2(1108.0, 646.0)
const ROD_TARGET_POS := Vector2(590.0, 382.0)

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
var inventory_prev_page_button: Button
var inventory_next_page_button: Button
var inventory_page_label: Label
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
var tackle_title_divider_left: ColorRect
var tackle_title_divider_right: ColorRect
var tackle_title_label: Label
var tackle_current_label: Label
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
var tackle_equip_button: Button
var tackle_close_button: Button
var tackle_prev_page_button: Button
var tackle_next_page_button: Button
var tackle_page_label: Label
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
var toast_label: Label
var _toast_tween: Tween
var shop_ui
var keepnet_ui
var inventory_ui
var tackle_ui
var waterbody_ui
var catch_popup_ui
var fishing_hud_ui
var fishing_presence_ui
var profile_ui
var failure_popup_ui
var ui_theme
var ui_canvas_layer: CanvasLayer
var modal_canvas_layer: CanvasLayer
var modal_content_root: Control
var modal_input_shield: ColorRect
var is_modal_open := false
var _current_modal_name := ""
var cast_button_visual: TextureRect
var rod_sprite: Sprite2D
var rod_shadow_sprite: Sprite2D
var top_hud_container: HBoxContainer
var top_hud_spacer: Control
var quick_actions_container: VBoxContainer
var bottom_nav_container: VBoxContainer
var environment_layer: Node2D
var environment_sprites: Dictionary = {}
var day_night_controller: Node2D
var time_hud_panel: Panel
var weather_hud_panel: Panel
var money_hud_icon: TextureRect
var time_hud_icon: TextureRect
var weather_hud_icon: TextureRect
var lake_bg_base_rect: TextureRect
var lake_bg_foreground_rect: TextureRect
var lake_bg_mist_rect: TextureRect
var water_overlay_rect: TextureRect
var time_color_overlay: ColorRect
var time_celestial_overlay: ColorRect
var time_stars_overlay: ColorRect
var time_vignette_overlay: ColorRect

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
var _pending_reward_catch: Dictionary = {}
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
var _fish_button_action_guard_msec := 0
var _fish_button_pointer_action_active := false
var _modal_tap_guard_until_msec := 0
var _use_cast_png_button := true
var _use_pull_png_button := true
var _float_base_center := Vector2.ZERO
var _float_visual_center := Vector2.ZERO
var _rod_tip_visual := Vector2.ZERO
var _rod_bend_direction_visual := Vector2.DOWN
var _rod_bend_amount_visual := 3.0
var _water_surface_y := 0.0
var _water_zone_top := 0.0
var _water_zone_bottom := 0.0
var _rod_anchor_pos := Vector2.ZERO
var _rod_target_pos := Vector2.ZERO
var _last_detailed_failure_msec := -100000

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
	_play_main_ambient()

	theme = TUMAN_LAKE_THEME
	SaveManager.load_game()
	_setup_ui_controllers()
	_ensure_ui_canvas_layer()
	failure_popup_ui.setup(self)
	profile_ui.setup(self)
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

func _process(delta: float) -> void:
	_update_fishing_presence(delta)
	_update_catch_reward_input_lock()
	_update_modal_tap_guard()
	_update_time_hud()

func _input(event: InputEvent) -> void:
	if is_modal_open or _is_modal_tap_guard_active():
		return

	if not _is_fish_button_pointer_event(event):
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event.pressed:
		_cast_button_pressed = true
		_update_cast_button_visual()
		_on_reel_button_down()
		if not fish_button.disabled:
			_fish_button_pointer_action_active = true
			_trigger_fish_button_action(true)
	else:
		_cast_button_pressed = false
		_update_cast_button_visual()
		_on_reel_button_up()
		call_deferred("_clear_fish_button_pointer_action_active")

	get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if not is_modal_open:
		return
	if event.is_action_pressed("ui_cancel"):
		close_current_modal()
		get_viewport().set_input_as_handled()

func _setup_ui_controllers() -> void:
	ui_theme = UIThemeScript.new()
	shop_ui = ShopUIScript.new()
	keepnet_ui = KeepnetUIScript.new()
	inventory_ui = InventoryUIScript.new()
	tackle_ui = TackleUIScript.new()
	waterbody_ui = WaterbodyUIScript.new()
	catch_popup_ui = CatchPopupUIScript.new()
	fishing_hud_ui = FishingHUDUIScript.new()
	fishing_presence_ui = FishingPresenceUIScript.new()
	profile_ui = ProfileUIScript.new()
	failure_popup_ui = FailurePopupUIScript.new()

	shop_ui.setup(self)
	keepnet_ui.setup(self)
	inventory_ui.setup(self)
	tackle_ui.setup(self)
	waterbody_ui.setup(self)
	catch_popup_ui.setup(self)
	fishing_hud_ui.setup(self)
	fishing_presence_ui.setup(self)
	fishing_presence_ui.cast_visual_finished.connect(_on_cast_visual_finished)

	shop_ui.buy_requested.connect(_on_shop_buy_pressed)
	keepnet_ui.sell_fish_requested.connect(_on_keepnet_sell_fish_pressed)
	catch_popup_ui.catch_keep_requested.connect(_on_catch_keep_button_pressed)
	catch_popup_ui.catch_release_requested.connect(_on_catch_release_button_pressed)

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

func _layout_modal_layer() -> void:
	if modal_input_shield != null:
		modal_input_shield.set_anchors_preset(Control.PRESET_FULL_RECT)
		modal_input_shield.offset_left = 0.0
		modal_input_shield.offset_top = 0.0
		modal_input_shield.offset_right = 0.0
		modal_input_shield.offset_bottom = 0.0
	if modal_content_root != null:
		modal_content_root.set_anchors_preset(Control.PRESET_FULL_RECT)
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
		waterbody_panel
	]:
		_reparent_node(node, root)
		if node is Control:
			(node as Control).mouse_filter = Control.MOUSE_FILTER_STOP

func open_modal(modal_name: String) -> void:
	_ensure_modal_layer()
	_move_modal_roots_to_layer()
	_hide_modal_roots_except(modal_name)
	_current_modal_name = modal_name
	is_modal_open = true
	if modal_input_shield != null:
		modal_input_shield.visible = true
		modal_input_shield.mouse_filter = Control.MOUSE_FILTER_STOP

func close_modal(modal_name: String = "") -> void:
	if modal_name == "" or _current_modal_name == modal_name:
		_current_modal_name = ""
	_refresh_modal_input_blocker()

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
		"catch_reward":
			_hide_catch_reward_popup()
		_:
			_hide_modal_roots_except("")
			if profile_ui != null:
				profile_ui.close()
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
	if modal_name != "catch_reward":
		if catch_popup_panel != null:
			catch_popup_panel.visible = false
		if catch_popup_backdrop != null:
			catch_popup_backdrop.visible = false
	if modal_name != "profile" and profile_ui != null:
		profile_ui.close(false)

func _refresh_modal_input_blocker() -> void:
	_ensure_modal_layer()
	var has_open_modal := _is_any_modal_visible()
	is_modal_open = has_open_modal
	if modal_input_shield != null:
		modal_input_shield.visible = has_open_modal or _is_modal_tap_guard_active()
		modal_input_shield.mouse_filter = Control.MOUSE_FILTER_STOP

func _is_any_modal_visible() -> bool:
	for control in [
		basket_panel,
		inventory_panel,
		shop_panel,
		tackle_panel,
		waterbody_panel,
		catch_popup_panel
	]:
		if _is_visible_ui_control(control):
			return true
	if profile_ui != null and profile_ui.is_any_modal_open():
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
		_reparent_node(node, top_hud_container)
	_reparent_node(top_hud_spacer, top_hud_container)
	_reparent_node(spot_option_button, top_hud_container)
	top_hud_container.move_child(top_hud_panel, 0)
	top_hud_container.move_child(time_hud_panel, 1)
	top_hud_container.move_child(weather_hud_panel, 2)
	top_hud_container.move_child(top_hud_spacer, 3)
	top_hud_container.move_child(spot_option_button, 4)

	_reparent_node(money_label, top_hud_panel)
	_reparent_node(clock_label, time_hud_panel)
	_reparent_node(weather_label, weather_hud_panel)

	for node in [feed_button, bait_button, tackle_button, auto_button]:
		_reparent_node(node, quick_actions_container)
	quick_actions_container.move_child(feed_button, 0)
	quick_actions_container.move_child(bait_button, 1)
	quick_actions_container.move_child(tackle_button, 2)
	quick_actions_container.move_child(auto_button, 3)

	if nav_fish_button.get_parent() == bottom_nav_container:
		_reparent_node(nav_fish_button, ui_canvas_layer)
	nav_fish_button.visible = false

	for node in [basket_button, inventory_button, shop_button, map_button, profile_button]:
		_reparent_node(node, bottom_nav_container)
	bottom_nav_container.move_child(basket_button, 0)
	bottom_nav_container.move_child(inventory_button, 1)
	bottom_nav_container.move_child(shop_button, 2)
	bottom_nav_container.move_child(map_button, 3)
	bottom_nav_container.move_child(profile_button, 4)

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

func _reparent_node(node: Node, new_parent: Node) -> void:
	if node == null or new_parent == null or node.get_parent() == new_parent:
		return

	var old_parent: Node = node.get_parent()
	if old_parent != null:
		old_parent.remove_child(node)
	new_parent.add_child(node)

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

func _apply_action_button_style(button: Button, active: bool = false) -> void:
	var normal_bg := Color(0.054, 0.088, 0.086, 0.94)
	var hover_bg := Color(0.078, 0.130, 0.116, 0.98)
	var pressed_bg := Color(0.082, 0.176, 0.118, 1.0)
	var border := Color(0.80, 0.96, 0.86, 0.40)
	var shadow := Color(0.0, 0.0, 0.0, 0.18)

	if active:
		normal_bg = Color(0.142, 0.332, 0.176, 1.0)
		hover_bg = Color(0.180, 0.420, 0.210, 1.0)
		pressed_bg = Color(0.100, 0.270, 0.140, 1.0)
		border = Color(0.70, 1.0, 0.72, 0.54)
		shadow = Color(0.18, 0.66, 0.24, 0.20)

	button.add_theme_stylebox_override("normal", _make_panel_style(normal_bg, border, 8, 4, shadow))
	button.add_theme_stylebox_override("hover", _make_panel_style(hover_bg, Color(border.r, border.g, border.b, min(border.a + 0.12, 1.0)), 8, 5, shadow))
	button.add_theme_stylebox_override("pressed", _make_panel_style(pressed_bg, Color(border.r, border.g, border.b, min(border.a + 0.16, 1.0)), 8, 2, Color(0.0, 0.0, 0.0, 0.12)))
	button.add_theme_stylebox_override("disabled", _make_panel_style(Color(0.040, 0.050, 0.052, 0.48), Color(0.58, 0.64, 0.62, 0.14), 8, 1, Color.TRANSPARENT))
	button.add_theme_color_override("font_color", Color(0.94, 1.0, 0.92, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.86, 1.0, 0.84, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.62, 0.68, 0.66, 0.62))

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
			float pulse = 0.90 + sin(TIME * 1.35) * 0.08;
			float glow = 1.0 - smoothstep(0.0, 0.48, length(uv));
			float core = 1.0 - smoothstep(0.0, 0.18, length(uv));
			COLOR = vec4(0.84, 1.0, 0.72, (glow * 0.34 + core * 0.14) * pulse);
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
			uv.x *= 1.75;
			float pulse = 0.64 + sin(TIME * 0.95) * 0.08;
			float glow = 1.0 - smoothstep(0.10, 0.58, length(uv));
			COLOR = vec4(0.30, 0.78, 0.40, glow * 0.14 * pulse);
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

	mist_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		void fragment() {
			vec2 uv = UV;
			float drift = TIME * 0.018;
			float noise = sin((uv.x + drift) * 13.0 + uv.y * 6.0) * 0.5 + 0.5;
			float horizon = smoothstep(0.36, 0.43, uv.y) * (1.0 - smoothstep(0.51, 0.62, uv.y));
			float near_water = smoothstep(0.50, 0.70, uv.y) * (1.0 - smoothstep(0.84, 1.0, uv.y));
			COLOR = vec4(0.72, 0.86, 0.80, (0.060 + noise * 0.095) * (horizon + near_water * 0.42));
		}
	""")

	foreground_mist_layer.material = _make_scene_shader_material("""
		shader_type canvas_item;
		float random(vec2 value) {
			return fract(sin(dot(value, vec2(39.346, 11.135))) * 32758.5453);
		}
		void fragment() {
			vec2 uv = UV;
			float lower = smoothstep(0.74, 0.99, uv.y);
			float right_bank = smoothstep(0.72, 0.92, uv.x) * smoothstep(0.64, 0.92, uv.y);
			float left_bank = (1.0 - smoothstep(0.00, 0.18, uv.x)) * smoothstep(0.70, 0.98, uv.y);
			float cell = floor(uv.x * 120.0);
			float seed = random(vec2(cell, 8.2));
			float blade_x = abs(fract(uv.x * 120.0 + seed * 0.2) - 0.5);
			float blade_height = 0.10 + seed * 0.23;
			float blade_mask = (right_bank + left_bank * 0.72) * smoothstep(1.0 - blade_height, 1.0 - blade_height * 0.18, uv.y) * (1.0 - smoothstep(0.006, 0.040, blade_x));
			float ground = lower * (right_bank * 0.72 + left_bank * 0.42);
			float fog = smoothstep(0.58, 0.78, uv.y) * (1.0 - smoothstep(0.90, 1.0, uv.y)) * (0.42 + sin(uv.x * 11.0 + TIME * 0.25) * 0.12);
			vec3 grass = mix(vec3(0.050, 0.105, 0.050), vec3(0.145, 0.220, 0.085), seed);
			vec3 ground_color = vec3(0.060, 0.050, 0.036);
			vec3 fog_color = vec3(0.64, 0.78, 0.72);
			vec3 color = mix(ground_color, grass, blade_mask);
			color = mix(color, fog_color, fog * 0.45);
			float alpha = clamp(ground * 0.72 + blade_mask * 0.92 + fog * 0.18, 0.0, 0.96);
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
	_ensure_hud_icons()

	var sx: float = screen_size.x / BASE_SCREEN_SIZE.x
	var sy: float = screen_size.y / BASE_SCREEN_SIZE.y
	var ui_scale: float = min(sx, sy)
	var chip_gap: float = 10.0 * ui_scale
	var top_height: float = HUD_HEIGHT * sy
	var cast_button_size := _scale_size(ui_theme.get_cast_button_size(), screen_size)
	var quick_button_width: float = 86.0 * sx
	var quick_button_height: float = 36.0 * sy
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
	debug_panel.visible = SHOW_DEBUG_PANEL

	var hud_rect := _scale_rect(Rect2(20.0, 16.0, 910.0, HUD_HEIGHT), screen_size)
	_anchor_control(top_hud_container, 0.0, 0.0, 0.0, 0.0, hud_rect.position.x, hud_rect.position.y, hud_rect.end.x, hud_rect.end.y)
	top_hud_container.z_index = 100
	top_hud_container.add_theme_constant_override("separation", int(9.0 * ui_scale))
	top_hud_spacer.custom_minimum_size = _scale_size(Vector2(250.0, 1.0), screen_size)

	top_hud_panel.visible = true
	top_hud_panel.custom_minimum_size = _scale_size(Vector2(120.0, HUD_HEIGHT), screen_size)
	top_hud_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	top_hud_panel.size_flags_vertical = Control.SIZE_FILL
	top_hud_panel.z_index = 100
	ui_theme.apply_hud_badge_style(top_hud_panel)

	time_hud_panel.custom_minimum_size = _scale_size(Vector2(110.0, HUD_HEIGHT), screen_size)
	time_hud_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	time_hud_panel.size_flags_vertical = Control.SIZE_FILL
	time_hud_panel.z_index = 100
	time_hud_panel.visible = true
	ui_theme.apply_hud_badge_style(time_hud_panel)

	weather_hud_panel.custom_minimum_size = _scale_size(Vector2(120.0, HUD_HEIGHT), screen_size)
	weather_hud_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	weather_hud_panel.size_flags_vertical = Control.SIZE_FILL
	weather_hud_panel.z_index = 100
	weather_hud_panel.visible = true
	ui_theme.apply_hud_badge_style(weather_hud_panel)

	title_label.visible = false
	level_label.visible = false
	xp_progress_bar.visible = false

	money_label.visible = true
	money_label.z_index = 102
	_anchor_control(money_label, 0.0, 0.0, 1.0, 1.0, 36.0 * sx, 4.0 * sy, -8.0 * sx, -4.0 * sy)
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	money_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	money_label.add_theme_font_size_override("font_size", 14)
	money_label.clip_text = true

	clock_label.visible = true
	clock_label.z_index = 102
	_anchor_control(clock_label, 0.0, 0.0, 1.0, 1.0, 36.0 * sx, 4.0 * sy, -8.0 * sx, -4.0 * sy)
	clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	clock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	clock_label.add_theme_font_size_override("font_size", 14)
	clock_label.clip_text = true

	weather_label.visible = true
	weather_label.z_index = 102
	_anchor_control(weather_label, 0.0, 0.0, 1.0, 1.0, 36.0 * sx, 4.0 * sy, -8.0 * sx, -4.0 * sy)
	weather_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	weather_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	weather_label.add_theme_font_size_override("font_size", 13)
	weather_label.clip_text = true

	_layout_hud_icon(money_hud_icon, Vector2(11.0, 12.0), Vector2(19.0, 19.0), screen_size)
	_layout_hud_icon(time_hud_icon, Vector2(11.0, 12.0), Vector2(19.0, 19.0), screen_size)
	_layout_hud_icon(weather_hud_icon, Vector2(11.0, 12.0), Vector2(19.0, 19.0), screen_size)

	spot_option_button.visible = true
	spot_option_button.custom_minimum_size = _scale_size(Vector2(280.0, HUD_HEIGHT), screen_size)
	spot_option_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	spot_option_button.size_flags_vertical = Control.SIZE_FILL
	spot_option_button.z_index = 101
	spot_option_button.add_theme_font_size_override("font_size", 13)
	_set_button_icon(spot_option_button, "location", 20.0)
	_apply_button_style(spot_option_button, STYLE_SECONDARY_BUTTON)
	spot_option_button.add_theme_font_size_override("font_size", 13)

	action_panel.visible = true
	var action_panel_rect := _scale_rect(Rect2(174.0, 472.0, 612.0, ACTION_BAR_HEIGHT), screen_size)
	_anchor_control(action_panel, 0.0, 0.0, 0.0, 0.0, action_panel_rect.position.x, action_panel_rect.position.y, action_panel_rect.end.x, action_panel_rect.end.y)
	action_panel.z_index = 100
	action_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color(0.026, 0.052, 0.055, 0.46), Color(0.74, 0.96, 0.86, 0.22), 9, 2, Color(0.0, 0.0, 0.0, 0.10))
	)

	quick_actions_container.visible = false

	var cast_center := _scale_point(Vector2(480.0, 495.0), screen_size)
	var cast_rect := Rect2(cast_center - cast_button_size * 0.5, cast_button_size)
	var glow_rect := cast_rect.grow(3.0 * ui_scale)
	_anchor_control(action_glow, 0.0, 0.0, 0.0, 0.0, glow_rect.position.x, glow_rect.position.y, glow_rect.end.x, glow_rect.end.y)
	action_glow.z_index = 99
	action_glow.visible = true
	action_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for quick_button in [feed_button, bait_button, tackle_button, auto_button]:
		_reparent_node(quick_button, ui_canvas_layer)

	var quick_size := Vector2(quick_button_width, quick_button_height)

	_layout_action_button(feed_button, "Прикормка", _scale_point(Vector2(190.0, 477.0), screen_size), quick_size, false)
	_layout_action_button(bait_button, "Наживка", _scale_point(Vector2(284.0, 477.0), screen_size), quick_size, true)
	_layout_action_button(tackle_button, "Снасти", _scale_point(Vector2(596.0, 477.0), screen_size), quick_size, true)
	_layout_action_button(auto_button, "Авто", _scale_point(Vector2(690.0, 477.0), screen_size), quick_size, false)

	_anchor_control(fish_button, 0.0, 0.0, 0.0, 0.0, cast_rect.position.x, cast_rect.position.y, cast_rect.end.x, cast_rect.end.y)
	fish_button.z_index = 104
	fish_button.custom_minimum_size = cast_button_size
	fish_button.add_theme_font_size_override("font_size", 16)
	fish_button.clip_text = true
	_apply_button_style(fish_button, STYLE_PRIMARY_BUTTON)
	fish_button.custom_minimum_size = cast_button_size
	fish_button.size = cast_button_size
	fish_button.add_theme_font_size_override("font_size", 16)
	if cast_button_visual != null:
		_anchor_control(cast_button_visual, 0.0, 0.0, 0.0, 0.0, cast_rect.position.x, cast_rect.position.y, cast_rect.end.x, cast_rect.end.y)
		cast_button_visual.z_index = 103
		cast_button_visual.size = cast_button_size

	_set_button_icon(feed_button, "bait", 12.0)
	_set_button_icon(bait_button, "bait", 12.0)
	_set_button_icon(fish_button, "hook", 16.0)
	_set_button_icon(tackle_button, "rod", 12.0)
	_set_button_icon(auto_button, "auto", 12.0)
	_refresh_fish_button_presentation()

	bottom_nav_panel.visible = true
	var nav_rect := _scale_rect(Rect2(38.0, 150.0, LEFT_NAV_WIDTH, LEFT_NAV_HEIGHT), screen_size)
	_anchor_control(bottom_nav_panel, 0.0, 0.0, 0.0, 0.0, nav_rect.position.x, nav_rect.position.y, nav_rect.end.x, nav_rect.end.y)
	bottom_nav_panel.z_index = 100
	bottom_nav_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	bottom_nav_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

	_anchor_control(bottom_nav_container, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0)
	bottom_nav_container.mouse_filter = Control.MOUSE_FILTER_PASS
	bottom_nav_container.add_theme_constant_override("separation", int(9.0 * ui_scale))

	var nav_buttons: Array = [nav_fish_button, basket_button, inventory_button, shop_button, map_button, profile_button]
	var nav_labels: Array = ["Ловля", "Садок", "Инвентарь", "Магазин", "Карта", "Профиль"]
	var nav_button_size := _scale_size(Vector2(LEFT_NAV_WIDTH - 18.0, 42.0), screen_size)
	for i in nav_buttons.size():
		_layout_nav_button(nav_buttons[i], nav_labels[i], Vector2.ZERO, nav_button_size, i == 0)
	var nav_icons: Array = ["fish", "keepnet", "inventory", "shop", "map", "profile"]
	for i in nav_buttons.size():
		_set_button_icon(nav_buttons[i], nav_icons[i], 12.0)

	nav_fish_button.visible = false
	var side_menu_buttons: Array = [basket_button, inventory_button, shop_button, map_button, profile_button]
	var side_menu_labels: Array = ["Садок", "Инвентарь", "Магазин", "Карта", "Профиль"]
	var side_menu_icons: Array = ["keepnet", "inventory", "shop", "map", "profile"]
	var side_menu_button_size := _scale_size(Vector2(LEFT_NAV_WIDTH, 48.0), screen_size)
	for i in side_menu_buttons.size():
		_layout_side_menu_button(side_menu_buttons[i], side_menu_labels[i], side_menu_icons[i], side_menu_button_size, false)

	basket_button.visible = true

	map_button.disabled = false
	profile_button.disabled = false

	var water_anchor := _scale_point(FLOAT_DEFAULT_POS, screen_size)
	_float_base_center = water_anchor
	if not _presence_has_layout or _fishing_ui_state == FishingUiState.IDLE:
		_float_visual_center = water_anchor
		_rod_tip_visual = _rod_target_pos
		_rod_bend_direction_visual = Vector2.DOWN
		_rod_bend_amount_visual = 3.0
		_presence_has_layout = true
	_layout_float_visuals(water_anchor, clamp(screen_size.y / 540.0, 0.86, 1.22))

	var reel_width: float = 520.0 * sx
	var reel_height: float = 64.0 * sy
	var reel_y: float = max(16.0 * sy + top_height + 10.0 * sy, action_panel_rect.position.y - reel_height - 10.0 * sy)
	var reel_x: float = (screen_size.x - reel_width) * 0.5
	_anchor_control(reeling_panel, 0.0, 0.0, 0.0, 0.0, reel_x, reel_y, reel_x + reel_width, reel_y + reel_height)
	reeling_panel.color = Color(0.020, 0.040, 0.042, 0.78)
	reeling_panel.z_index = 103

	var reel_padding := 14.0
	var reel_inner_width: float = reel_width - reel_padding * 2.0
	fight_title_label.position = Vector2(reel_padding, 6.0)
	fight_title_label.size = Vector2(142.0, 18.0)
	fight_title_label.add_theme_font_size_override("font_size", 11)
	fight_status_label.position = Vector2(reel_padding + 150.0, 6.0)
	fight_status_label.size = Vector2(max(reel_inner_width - 150.0, 80.0), 18.0)
	fight_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fight_status_label.add_theme_font_size_override("font_size", 11)
	tension_label.position = Vector2(reel_padding, 26.0)
	tension_label.size = Vector2(reel_inner_width * 0.5, 14.0)
	tension_label.add_theme_font_size_override("font_size", 10)
	progress_label.position = Vector2(reel_padding + reel_inner_width * 0.5, 26.0)
	progress_label.size = Vector2(reel_inner_width * 0.5, 14.0)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	progress_label.add_theme_font_size_override("font_size", 10)
	tension_track.position = Vector2(reel_padding, 43.0)
	tension_track.size = Vector2(reel_inner_width, 11.0)
	progress_track.position = Vector2(reel_padding, 58.0)
	progress_track.size = Vector2(reel_inner_width, 4.0)
	ui_theme.apply_meter_track_style(tension_track, tension_fill)
	ui_theme.apply_meter_track_style(progress_track, progress_fill, Color(0.58, 0.82, 0.28, 1.0))
	fight_hint_label.visible = false

func _get_adaptive_rod_anchor(screen_size: Vector2, ui_scale: float) -> Vector2:
	return Vector2(
		screen_size.x + 58.0 * ui_scale,
		screen_size.y + 18.0 * ui_scale
	)

func _get_adaptive_rod_tip(screen_size: Vector2, sy: float) -> Vector2:
	return Vector2(
		screen_size.x * 0.640,
		min(screen_size.y * 0.705, _water_zone_bottom + 26.0 * sy)
	)

func _ensure_compact_hud_panels() -> void:
	if time_hud_panel == null:
		time_hud_panel = Panel.new()
		time_hud_panel.name = "TimeHudPanel"
		time_hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		(ui_canvas_layer if ui_canvas_layer != null else self).add_child(time_hud_panel)

	if weather_hud_panel == null:
		weather_hud_panel = Panel.new()
		weather_hud_panel.name = "WeatherHudPanel"
		weather_hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		(ui_canvas_layer if ui_canvas_layer != null else self).add_child(weather_hud_panel)

func _ensure_hud_icons() -> void:
	money_hud_icon = _ensure_hud_icon(money_hud_icon, "MoneyHudIcon", top_hud_panel, "money")
	time_hud_icon = _ensure_hud_icon(time_hud_icon, "TimeHudIcon", time_hud_panel, "time")
	weather_hud_icon = _ensure_hud_icon(weather_hud_icon, "WeatherHudIcon", weather_hud_panel, "weather")

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
	button.add_theme_font_size_override("font_size", 10)
	_apply_action_button_style(button, false)
	button.custom_minimum_size = button_size
	if not (button.get_parent() is Container):
		button.size = button_size
	button.add_theme_font_size_override("font_size", 10)

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
	var text_label := _ensure_side_menu_label(button)
	var arrow_label := _ensure_side_menu_arrow(button)
	var scale_factor: float = clamp(button_size.y / 48.0, 0.78, 1.22)
	var icon_size := Vector2(31.0, 31.0) * scale_factor
	var left_pad := 9.0 * scale_factor
	var arrow_width := 12.0 * scale_factor
	var text_x := 45.0 * scale_factor
	var font_size := int(round(13.0 * scale_factor))

	icon_rect.texture = ui_theme.get_side_menu_icon(icon_name)
	icon_rect.position = Vector2(left_pad, (button_size.y - icon_size.y) * 0.5)
	icon_rect.size = icon_size
	icon_rect.visible = icon_rect.texture != null

	text_label.text = label
	text_label.position = Vector2(text_x, 0.0)
	text_label.size = Vector2(max(button_size.x - text_x - arrow_width - 8.0 * scale_factor, 56.0), button_size.y)
	text_label.add_theme_font_size_override("font_size", font_size)

	arrow_label.text = ">"
	arrow_label.position = Vector2(button_size.x - arrow_width - 9.0 * scale_factor, 0.0)
	arrow_label.size = Vector2(arrow_width, button_size.y)
	arrow_label.add_theme_font_size_override("font_size", font_size + 1)

	_refresh_side_menu_button_state(button, active)

func _refresh_side_menu_button_state(button: Button, active: bool) -> void:
	if button == null or ui_theme == null:
		return

	ui_theme.apply_side_menu_button_style(button, active)
	button.modulate = Color(1.0, 1.0, 1.0, 1.0 if active else 0.92)
	var text_color := Color(0.94, 0.98, 0.91, 1.0) if active else Color(0.86, 0.91, 0.84, 0.96)
	var arrow_color := Color(0.76, 1.0, 0.58, 0.96) if active else Color(0.84, 0.90, 0.78, 0.86)
	var icon_color := Color(1.0, 1.0, 0.94, 1.0) if active else Color(0.94, 0.96, 0.86, 0.92)

	var icon_rect := button.get_node_or_null("SideMenuIcon") as TextureRect
	if icon_rect != null:
		icon_rect.modulate = icon_color if not button.disabled else Color(0.60, 0.64, 0.58, 0.48)

	var text_label := button.get_node_or_null("SideMenuText") as Label
	if text_label != null:
		text_label.add_theme_color_override("font_color", text_color if not button.disabled else Color(0.60, 0.64, 0.58, 0.52))

	var arrow_label := button.get_node_or_null("SideMenuArrow") as Label
	if arrow_label != null:
		arrow_label.add_theme_color_override("font_color", arrow_color if not button.disabled else Color(0.60, 0.64, 0.58, 0.42))

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

func _ensure_side_menu_label(button: Button) -> Label:
	var text_label := button.get_node_or_null("SideMenuText") as Label
	if text_label == null:
		text_label = Label.new()
		text_label.name = "SideMenuText"
		text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		text_label.clip_text = true
		text_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		button.add_child(text_label)
	return text_label

func _ensure_side_menu_arrow(button: Button) -> Label:
	var arrow_label := button.get_node_or_null("SideMenuArrow") as Label
	if arrow_label == null:
		arrow_label = Label.new()
		arrow_label.name = "SideMenuArrow"
		arrow_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		arrow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		arrow_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		button.add_child(arrow_label)
	return arrow_label

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

func _refresh_fish_button_presentation() -> void:
	if fish_button == null or ui_theme == null:
		return

	var target_size: Vector2 = fish_button.size
	if target_size == Vector2.ZERO:
		target_size = _scale_size(ui_theme.get_cast_button_size(), get_viewport_rect().size)

	var active_hook_input: bool = _fishing_ui_state == FishingUiState.WAITING and bool(FishingManager.get("use_new_bite_system"))
	var use_cast_texture := _use_cast_png_button and (_fishing_ui_state == FishingUiState.IDLE or (_fishing_ui_state == FishingUiState.WAITING and not active_hook_input))
	var use_pull_texture := _use_pull_png_button and (
		_fishing_ui_state == FishingUiState.FIGHTING
		or _fishing_ui_state == FishingUiState.CAUGHT
		or _fishing_ui_state == FishingUiState.FAILED
	)

	fish_button.visible = true
	fish_button.mouse_filter = Control.MOUSE_FILTER_STOP
	fish_button.z_index = 260
	fish_button.custom_minimum_size = target_size
	fish_button.size = target_size
	if cast_button_visual != null:
		cast_button_visual.z_index = fish_button.z_index - 1

	if use_cast_texture or use_pull_texture:
		if use_pull_texture:
			ui_theme.apply_pull_button_hitbox_style(fish_button, target_size)
		else:
			ui_theme.apply_cast_button_hitbox_style(fish_button, target_size)
		_update_cast_button_visual()
		return

	if cast_button_visual != null:
		cast_button_visual.visible = false
	_cast_button_hovered = false
	_cast_button_pressed = false
	_apply_button_style(fish_button, STYLE_PRIMARY_BUTTON)
	_set_button_icon(fish_button, "hook", 16.0)

func _update_cast_button_visual() -> void:
	if cast_button_visual == null or ui_theme == null:
		return

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
	if _is_visible_ui_control(basket_panel) or _is_visible_ui_control(inventory_panel):
		return true
	if _is_visible_ui_control(shop_panel) or _is_visible_ui_control(tackle_panel):
		return true
	if _is_visible_ui_control(waterbody_panel):
		return true
	return profile_ui != null and profile_ui.is_any_modal_open()

func _should_ignore_base_ui_press() -> bool:
	return is_modal_open or _is_modal_tap_guard_active() or _is_catch_reward_open()

func _trigger_fish_button_action(from_pointer_event: bool = false) -> void:
	if _should_ignore_base_ui_press():
		return

	if _fish_button_pointer_action_active and not from_pointer_event:
		return

	var now := Time.get_ticks_msec()
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

func _make_ellipse_points(center: Vector2, radius: Vector2, steps: int = 16) -> PackedVector2Array:
	return fishing_presence_ui._make_ellipse_points(center, radius, steps)

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

func _setup_layout() -> void:
	_ensure_modal_layer()
	_move_modal_roots_to_layer()
	_layout_modal_layer()
	var screen_size := get_viewport_rect().size
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
		tackle_line_button,
		tackle_leader_button,
		tackle_float_button,
		tackle_hook_button,
		tackle_bait_button,
		tackle_bait_2_button,
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
		catch_release_button
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
	fishing_presence_ui._layout_environment_scene(screen_size)
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
	spot_option_button.add_theme_font_size_override("font_size", 13)
	_apply_button_style(spot_option_button, STYLE_SECONDARY_BUTTON)

	var action_button_gap: float = 8.0
	var main_action_size := Vector2(224.0, 64.0)
	var side_action_width: float = clamp((action_width - main_action_size.x - action_button_gap * 4.0) / 4.0, 72.0, 86.0)
	var side_action_size := Vector2(side_action_width, 56.0)
	var action_total_width: float = side_action_size.x * 4.0 + main_action_size.x + action_button_gap * 4.0
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

	auto_button.text = "Авто"
	auto_button.position = Vector2(tackle_button.position.x + side_action_size.x + action_button_gap, side_action_y)
	auto_button.size = side_action_size
	auto_button.z_index = 8
	auto_button.add_theme_font_size_override("font_size", 12)
	auto_button.disabled = true
	_apply_button_style(auto_button, STYLE_SECONDARY_BUTTON)

	var nav_buttons: Array = [
		nav_fish_button,
		inventory_button,
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
	nav_texts = ["Ловля", "Инвентарь", "Магазин", "Садок", "Карта", "Профиль"]
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

	map_button.disabled = false
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

	_apply_gameplay_screen_composition(screen_size)

	for primary_label in [title_label, money_label, level_label, fight_title_label, tension_label, progress_label, basket_title_label, shop_title_label, tackle_title_label]:
		_apply_label_style(primary_label, true)

	for secondary_label in [clock_label, weather_label, timer_label, tackle_label, result_label, fight_status_label, debug_label, basket_stats_label, basket_contents_label, basket_notice_label, shop_money_label, shop_notice_label, tackle_current_label, tackle_details_label, tackle_compare_label]:
		_apply_label_style(secondary_label)

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
	basket_stats_label.add_theme_font_size_override("font_size", 12)
	basket_stats_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.92))

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
	var list_width: float = inventory_width * 0.34
	var right_panel_x: float = inventory_padding + list_width + 22.0
	var right_panel_width: float = inventory_width - right_panel_x - inventory_padding
	var inventory_body_y := 116.0
	var close_button_size := Vector2(146.0, 48.0)
	var inventory_action_y: float = inventory_height - inventory_padding - close_button_size.y
	var tackle_height := 100.0
	var tackle_y: float = inventory_action_y - tackle_height - 16.0
	var inventory_body_height: float = max(tackle_y - inventory_body_y - 18.0, 140.0)

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

	inventory_details_card.position = Vector2(right_panel_x, inventory_body_y)
	inventory_details_card.size = Vector2(right_panel_width, inventory_body_height)
	ui_theme.apply_card_style(inventory_details_card)

	inventory_tackle_card.position = Vector2(inventory_padding, tackle_y)
	inventory_tackle_card.size = Vector2(inventory_width - inventory_padding * 2.0, tackle_height)
	ui_theme.apply_card_style(inventory_tackle_card)

	inventory_item_list.position = Vector2(inventory_padding, inventory_body_y)
	inventory_item_list.size = Vector2(list_width, inventory_list_height)
	inventory_item_list.max_columns = 1
	ui_theme.apply_item_list_style(inventory_item_list)

	if inventory_prev_page_button != null and inventory_next_page_button != null and inventory_page_label != null:
		var pager_y: float = inventory_body_y + inventory_list_height + inventory_pager_gap
		inventory_prev_page_button.position = Vector2(inventory_padding, pager_y)
		inventory_prev_page_button.size = Vector2(58.0, inventory_pager_height)
		inventory_prev_page_button.z_index = MENU_PANEL_Z + 4
		inventory_prev_page_button.add_theme_font_size_override("font_size", 14)
		_apply_button_style(inventory_prev_page_button, STYLE_SECONDARY_BUTTON)

		inventory_next_page_button.position = Vector2(inventory_padding + list_width - 58.0, pager_y)
		inventory_next_page_button.size = Vector2(58.0, inventory_pager_height)
		inventory_next_page_button.z_index = MENU_PANEL_Z + 4
		inventory_next_page_button.add_theme_font_size_override("font_size", 14)
		_apply_button_style(inventory_next_page_button, STYLE_SECONDARY_BUTTON)

		inventory_page_label.position = Vector2(inventory_padding + 66.0, pager_y + 6.0)
		inventory_page_label.size = Vector2(max(list_width - 132.0, 48.0), inventory_pager_height - 12.0)
		inventory_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inventory_page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		inventory_page_label.add_theme_font_size_override("font_size", 12)
		inventory_page_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.84, 0.92))

	inventory_details_label.position = Vector2(right_panel_x + 12.0, inventory_body_y + 12.0)
	inventory_details_label.size = Vector2(right_panel_width - 24.0, max(inventory_body_height - 76.0, 48.0))
	inventory_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_details_label.add_theme_font_size_override("font_size", 12)
	inventory_details_label.clip_text = true

	inventory_tackle_label.position = Vector2(inventory_padding + 14.0, tackle_y + 10.0)
	inventory_tackle_label.size = Vector2(inventory_width - inventory_padding * 2.0 - 28.0, tackle_height - 20.0)
	inventory_tackle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_tackle_label.add_theme_font_size_override("font_size", 12)
	inventory_tackle_label.clip_text = true

	inventory_equip_button.position = Vector2(right_panel_x + right_panel_width - 154.0, inventory_body_y + inventory_body_height - 54.0)
	inventory_equip_button.size = Vector2(142.0, 50.0)
	_apply_button_style(inventory_equip_button, STYLE_PRIMARY_BUTTON)

	inventory_close_button.position = Vector2(inventory_width - inventory_padding - close_button_size.x, inventory_action_y)
	inventory_close_button.size = close_button_size
	ui_theme.apply_close_button_style(inventory_close_button)

	var tackle_width: float = min(screen_size.x * 0.94, screen_size.x - 16.0)
	var tackle_panel_height: float = min(screen_size.y * 0.92, screen_size.y - 10.0)
	var tackle_x: float = (screen_size.x - tackle_width) * 0.5
	var tackle_y_pos: float = (screen_size.y - tackle_panel_height) * 0.5
	var tackle_padding := 16.0
	var tackle_gap := 10.0
	var tackle_inner_width: float = tackle_width - tackle_padding * 2.0
	var tackle_header_height := 58.0
	var tackle_action_height := 60.0
	var tackle_content_y: float = tackle_header_height + 8.0
	var tackle_action_y: float = tackle_panel_height - tackle_padding - tackle_action_height
	var tackle_content_height: float = max(tackle_action_y - tackle_content_y - 12.0, 260.0)
	var tackle_left_width: float = floor(tackle_inner_width * 0.27)
	var tackle_center_width: float = floor(tackle_inner_width * 0.35)
	var tackle_right_width: float = tackle_inner_width - tackle_left_width - tackle_center_width - tackle_gap * 2.0
	var tackle_left_x := tackle_padding
	var tackle_center_x: float = tackle_left_x + tackle_left_width + tackle_gap
	var tackle_right_x: float = tackle_center_x + tackle_center_width + tackle_gap

	tackle_panel.position = Vector2(tackle_x, tackle_y_pos)
	tackle_panel.size = Vector2(tackle_width, tackle_panel_height)
	ui_theme.apply_tackle_panel_style(tackle_panel, true)

	tackle_title_label.position = Vector2(tackle_padding, 12.0)
	tackle_title_label.size = Vector2(tackle_inner_width, 34.0)
	tackle_title_label.add_theme_font_size_override("font_size", 24)
	tackle_title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.68, 1.0))
	tackle_title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.38))
	tackle_title_label.add_theme_constant_override("shadow_offset_y", 1)

	tackle_title_divider_left.position = Vector2(tackle_width * 0.5 - 126.0, 47.0)
	tackle_title_divider_left.size = Vector2(110.0, 2.0)
	tackle_title_divider_left.color = Color(0.82, 0.58, 0.24, 0.72)
	tackle_title_divider_right.position = Vector2(tackle_width * 0.5 + 16.0, 47.0)
	tackle_title_divider_right.size = Vector2(110.0, 2.0)
	tackle_title_divider_right.color = Color(0.82, 0.58, 0.24, 0.72)

	tackle_left_panel.position = Vector2(tackle_left_x, tackle_content_y)
	tackle_left_panel.size = Vector2(tackle_left_width, tackle_content_height)
	ui_theme.apply_tackle_panel_style(tackle_left_panel)

	tackle_center_panel.position = Vector2(tackle_center_x, tackle_content_y)
	tackle_center_panel.size = Vector2(tackle_center_width, tackle_content_height)
	ui_theme.apply_tackle_panel_style(tackle_center_panel)

	tackle_right_panel.position = Vector2(tackle_right_x, tackle_content_y)
	tackle_right_panel.size = Vector2(tackle_right_width, tackle_content_height)
	ui_theme.apply_tackle_panel_style(tackle_right_panel)

	tackle_action_bar_panel.position = Vector2(tackle_padding, tackle_action_y)
	tackle_action_bar_panel.size = Vector2(tackle_inner_width, tackle_action_height)
	ui_theme.apply_tackle_panel_style(tackle_action_bar_panel)

	var tackle_category_buttons: Array = [tackle_line_button, tackle_leader_button, tackle_hook_button, tackle_float_button, tackle_bait_button, tackle_bait_2_button]
	var slot_gap := 7.0
	var tackle_slot_height: float = max((tackle_content_height - 24.0 - slot_gap * 5.0) / 6.0, 42.0)
	for i in tackle_category_buttons.size():
		var tackle_category_button: Button = tackle_category_buttons[i]
		tackle_category_button.position = Vector2(tackle_left_x + 12.0, tackle_content_y + 12.0 + float(i) * (tackle_slot_height + slot_gap))
		tackle_category_button.size = Vector2(tackle_left_width - 24.0, tackle_slot_height)
		tackle_category_button.add_theme_font_size_override("font_size", 10)
		tackle_category_button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	tackle_visual_title_label.position = Vector2(tackle_center_x + 14.0, tackle_content_y + 10.0)
	tackle_visual_title_label.size = Vector2(tackle_center_width - 28.0, 24.0)
	tackle_visual_title_label.add_theme_font_size_override("font_size", 14)
	tackle_visual_title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.62, 1.0))

	var visual_top: float = tackle_content_y + 42.0
	var visual_bottom: float = tackle_content_y + tackle_content_height - 28.0
	var line_x: float = tackle_center_x + tackle_center_width * 0.52
	var rod_tip := Vector2(line_x + 8.0, visual_top)
	var rod_base := Vector2(tackle_center_x + tackle_center_width * 0.82, visual_bottom - 8.0)
	var line_bottom := Vector2(line_x, visual_bottom - 20.0)
	tackle_visual_rod_line.points = PackedVector2Array([rod_tip, rod_base])
	tackle_visual_main_line.points = PackedVector2Array([rod_tip + Vector2(0.0, 5.0), line_bottom])
	tackle_visual_leader_line.points = PackedVector2Array([line_bottom - Vector2(0.0, 42.0), line_bottom])
	tackle_visual_rod_line.z_index = MENU_PANEL_Z + 2
	tackle_visual_main_line.z_index = MENU_PANEL_Z + 2
	tackle_visual_leader_line.z_index = MENU_PANEL_Z + 2

	tackle_visual_float_marker.position = Vector2(line_x - 5.0, visual_top + tackle_content_height * 0.28)
	tackle_visual_float_marker.size = Vector2(10.0, 28.0)
	tackle_visual_float_marker.color = Color(0.92, 0.32, 0.22, 0.96)
	tackle_visual_float_marker.z_index = MENU_PANEL_Z + 3

	tackle_visual_hook_marker.position = Vector2(line_x - 16.0, line_bottom.y - 12.0)
	tackle_visual_hook_marker.size = Vector2(30.0, 28.0)
	tackle_visual_hook_marker.add_theme_font_size_override("font_size", 22)
	tackle_visual_hook_marker.add_theme_color_override("font_color", Color(0.78, 0.88, 0.90, 1.0))
	tackle_visual_hook_marker.z_index = MENU_PANEL_Z + 3

	tackle_visual_bait_marker.position = Vector2(line_x + 12.0, line_bottom.y - 4.0)
	tackle_visual_bait_marker.size = Vector2(26.0, 24.0)
	tackle_visual_bait_marker.add_theme_font_size_override("font_size", 20)
	tackle_visual_bait_marker.add_theme_color_override("font_color", Color(0.86, 0.42, 0.26, 1.0))
	tackle_visual_bait_marker.z_index = MENU_PANEL_Z + 3

	tackle_visual_bait_2_marker.position = Vector2(line_x + 34.0, line_bottom.y - 4.0)
	tackle_visual_bait_2_marker.size = Vector2(26.0, 24.0)
	tackle_visual_bait_2_marker.add_theme_font_size_override("font_size", 16)
	tackle_visual_bait_2_marker.add_theme_color_override("font_color", Color(0.90, 0.70, 0.32, 1.0))
	tackle_visual_bait_2_marker.z_index = MENU_PANEL_Z + 3

	var label_width: float = max(tackle_center_width * 0.34, 82.0)
	tackle_visual_line_label.position = Vector2(tackle_center_x + 14.0, visual_top + 22.0)
	tackle_visual_float_label.position = Vector2(tackle_center_x + 14.0, visual_top + tackle_content_height * 0.28 - 4.0)
	tackle_visual_leader_label.position = Vector2(tackle_center_x + 14.0, line_bottom.y - 62.0)
	tackle_visual_hook_label.position = Vector2(tackle_center_x + 14.0, line_bottom.y - 22.0)
	tackle_visual_bait_label.position = Vector2(tackle_center_x + 14.0, line_bottom.y + 16.0)
	tackle_visual_bait_2_label.position = Vector2(tackle_center_x + tackle_center_width - label_width - 12.0, line_bottom.y + 16.0)
	for visual_label in [tackle_visual_line_label, tackle_visual_float_label, tackle_visual_leader_label, tackle_visual_hook_label, tackle_visual_bait_label, tackle_visual_bait_2_label]:
		visual_label.size = Vector2(label_width, 34.0)
		visual_label.add_theme_font_size_override("font_size", 10)

	tackle_picker_title_label.position = Vector2(tackle_center_x + 14.0, tackle_content_y + 10.0)
	tackle_picker_title_label.size = Vector2(tackle_center_width - 28.0, 26.0)
	tackle_picker_title_label.add_theme_font_size_override("font_size", 13)
	tackle_picker_title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.62, 1.0))

	var tackle_pager_height := 34.0
	var tackle_pager_gap := 7.0
	var tackle_list_x: float = tackle_center_x + 14.0
	var tackle_list_y: float = tackle_content_y + 44.0
	var tackle_list_width: float = tackle_center_width - 28.0
	var tackle_list_height: float = max(tackle_content_height - 44.0 - tackle_pager_height - tackle_pager_gap - 12.0, 124.0)
	tackle_item_list.position = Vector2(tackle_list_x, tackle_list_y)
	tackle_item_list.size = Vector2(tackle_list_width, tackle_list_height)
	tackle_item_list.max_columns = 1
	ui_theme.apply_item_list_style(tackle_item_list)
	tackle_item_list.add_theme_font_size_override("font_size", 11)
	tackle_item_list.add_theme_color_override("font_color", Color(0.84, 0.94, 0.90, 0.96))
	tackle_item_list.add_theme_color_override("font_selected_color", Color(0.98, 1.0, 0.94, 1.0))

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

	tackle_rod_button.position = Vector2(tackle_right_x + 12.0, tackle_content_y + 12.0)
	tackle_rod_button.size = Vector2(tackle_right_width - 24.0, 54.0)
	tackle_rod_button.add_theme_font_size_override("font_size", 11)
	tackle_rod_button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	tackle_current_label.position = Vector2(tackle_right_x + 14.0, tackle_content_y + 78.0)
	tackle_current_label.size = Vector2(tackle_right_width - 28.0, 82.0)
	tackle_current_label.add_theme_font_size_override("font_size", 10)
	tackle_current_label.add_theme_color_override("font_color", Color(0.88, 0.96, 0.92, 0.96))
	tackle_current_label.clip_text = true

	tackle_details_label.position = Vector2(tackle_right_x + 14.0, tackle_content_y + 168.0)
	tackle_details_label.size = Vector2(tackle_right_width - 28.0, max(tackle_content_height * 0.24, 72.0))
	tackle_details_label.add_theme_font_size_override("font_size", 10)
	tackle_details_label.add_theme_color_override("font_color", Color(0.78, 0.88, 0.86, 0.96))
	tackle_details_label.clip_text = true

	tackle_compare_label.position = Vector2(tackle_right_x + 14.0, tackle_details_label.position.y + tackle_details_label.size.y + 8.0)
	tackle_compare_label.size = Vector2(tackle_right_width - 28.0, max(tackle_action_y - tackle_compare_label.position.y - 20.0, 82.0))
	tackle_compare_label.add_theme_font_size_override("font_size", 10)
	tackle_compare_label.add_theme_color_override("font_color", Color(0.78, 0.90, 0.86, 0.94))
	tackle_compare_label.clip_text = true

	tackle_hint_label.position = Vector2(tackle_right_x + 14.0, tackle_content_y + tackle_content_height - 34.0)
	tackle_hint_label.size = Vector2(tackle_right_width - 28.0, 28.0)
	tackle_hint_label.add_theme_font_size_override("font_size", 10)
	tackle_hint_label.add_theme_color_override("font_color", Color(0.82, 0.72, 0.48, 0.92))
	tackle_hint_label.clip_text = true

	tackle_depth_label.position = Vector2(tackle_padding + 18.0, tackle_action_y + 12.0)
	tackle_depth_label.size = Vector2(162.0, 36.0)
	tackle_depth_label.add_theme_font_size_override("font_size", 13)
	tackle_depth_label.add_theme_color_override("font_color", Color(0.92, 0.96, 0.90, 0.96))

	tackle_depth_minus_button.position = Vector2(tackle_depth_label.position.x + tackle_depth_label.size.x + 10.0, tackle_action_y + 10.0)
	tackle_depth_minus_button.size = Vector2(42.0, 40.0)
	tackle_depth_minus_button.add_theme_font_size_override("font_size", 18)
	_apply_button_style(tackle_depth_minus_button, STYLE_SECONDARY_BUTTON)

	tackle_depth_plus_button.position = Vector2(tackle_depth_minus_button.position.x + 50.0, tackle_action_y + 10.0)
	tackle_depth_plus_button.size = Vector2(42.0, 40.0)
	tackle_depth_plus_button.add_theme_font_size_override("font_size", 18)
	_apply_button_style(tackle_depth_plus_button, STYLE_SECONDARY_BUTTON)

	var equip_width: float = min(270.0, tackle_inner_width * 0.32)
	tackle_equip_button.position = Vector2(tackle_padding + tackle_inner_width * 0.5 - equip_width * 0.5, tackle_action_y + 8.0)
	tackle_equip_button.size = Vector2(equip_width, 44.0)
	ui_theme.apply_tackle_primary_action_style(tackle_equip_button)

	var close_width: float = min(180.0, tackle_inner_width * 0.22)
	tackle_close_button.position = Vector2(tackle_padding + tackle_inner_width - close_width - 18.0, tackle_action_y + 9.0)
	tackle_close_button.size = Vector2(close_width, 42.0)
	tackle_close_button.add_theme_font_size_override("font_size", 14)
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
	var shop_category_columns := 7
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

	shop_tackle_category_button.position = Vector2(shop_padding + (shop_category_width + shop_category_gap) * 2.0, shop_category_y)
	shop_tackle_category_button.size = Vector2(shop_category_width, shop_category_height)
	shop_tackle_category_button.add_theme_font_size_override("font_size", 12)

	shop_line_category_button.position = Vector2(shop_padding + (shop_category_width + shop_category_gap) * 3.0, shop_category_y)
	shop_line_category_button.size = Vector2(shop_category_width, shop_category_height)
	shop_line_category_button.add_theme_font_size_override("font_size", 12)

	shop_leader_category_button.position = Vector2(shop_padding + (shop_category_width + shop_category_gap) * 4.0, shop_category_y)
	shop_leader_category_button.size = Vector2(shop_category_width, shop_category_height)
	shop_leader_category_button.add_theme_font_size_override("font_size", 12)

	shop_hook_category_button.position = Vector2(shop_padding + (shop_category_width + shop_category_gap) * 5.0, shop_category_y)
	shop_hook_category_button.size = Vector2(shop_category_width, shop_category_height)
	shop_hook_category_button.add_theme_font_size_override("font_size", 12)

	shop_float_category_button.position = Vector2(shop_padding + (shop_category_width + shop_category_gap) * 6.0, shop_category_y)
	shop_float_category_button.size = Vector2(shop_category_width, shop_category_height)
	shop_float_category_button.add_theme_font_size_override("font_size", 12)

	shop_items_scroll.position = Vector2(shop_padding, shop_items_y)
	shop_items_scroll.size = Vector2(shop_inner_width, shop_height - shop_items_y - shop_footer_height)
	shop_items_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
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
		toast_label.position = Vector2((screen_size.x - 360.0) * 0.5, screen_size.y - 116.0)
		toast_label.size = Vector2(360.0, 40.0)
		toast_label.z_index = 220
		toast_label.add_theme_font_size_override("font_size", 15)
		toast_label.add_theme_color_override("font_color", Color(0.90, 1.0, 0.90, 1.0))
		toast_label.add_theme_stylebox_override(
			"normal",
			_make_panel_style(Color(0.055, 0.135, 0.105, 0.92), Color(0.68, 1.0, 0.76, 0.36), 18, 10, Color(0.0, 0.0, 0.0, 0.24))
		)

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

	catch_popup_glow.position = Vector2((reward_width - 470.0) * 0.5, 112.0)
	catch_popup_glow.size = Vector2(470.0, 176.0)
	catch_popup_glow.z_index = 0
	catch_popup_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	catch_popup_title_label.position = Vector2(reward_padding, 18.0)
	catch_popup_title_label.size = Vector2(reward_inner_width, 24.0)
	catch_popup_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_popup_title_label.add_theme_font_size_override("font_size", 13)
	catch_popup_title_label.add_theme_color_override("font_color", Color(0.78, 0.94, 0.86, 0.92))

	catch_popup_badge_label.position = Vector2((reward_width - 142.0) * 0.5, 42.0)
	catch_popup_badge_label.size = Vector2(142.0, 22.0)
	catch_popup_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_popup_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	catch_popup_badge_label.add_theme_font_size_override("font_size", 11)

	catch_popup_name_label.position = Vector2(reward_padding, 64.0)
	catch_popup_name_label.size = Vector2(reward_inner_width, 34.0)
	catch_popup_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_popup_name_label.add_theme_font_size_override("font_size", 24)
	catch_popup_name_label.add_theme_color_override("font_color", Color(0.98, 1.0, 0.94, 1.0))
	catch_popup_name_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.34))
	catch_popup_name_label.add_theme_constant_override("shadow_offset_x", 0)
	catch_popup_name_label.add_theme_constant_override("shadow_offset_y", 2)

	catch_trophy_banner_label.position = Vector2((reward_width - 430.0) * 0.5, 98.0)
	catch_trophy_banner_label.size = Vector2(430.0, 40.0)
	catch_trophy_banner_label.z_index = 5
	catch_trophy_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_trophy_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	catch_trophy_banner_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	catch_trophy_banner_label.add_theme_font_size_override("font_size", 12)
	catch_trophy_banner_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.56, 1.0))
	catch_trophy_banner_label.add_theme_stylebox_override(
		"normal",
		_make_panel_style(Color(0.34, 0.235, 0.08, 0.84), Color(1.0, 0.78, 0.38, 0.50), 15, 8, Color(0.86, 0.54, 0.16, 0.20))
	)

	var fish_visual_width: float = min(reward_inner_width, 450.0)
	var fish_visual_height: float = min(148.0, reward_height * 0.34)
	catch_fish_shadow.position = Vector2((reward_width - fish_visual_width) * 0.5 + 8.0, 144.0)
	catch_fish_shadow.size = Vector2(fish_visual_width, fish_visual_height)
	catch_fish_shadow.z_index = 1
	catch_fish_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_catch_shadow_base_position = catch_fish_shadow.position

	catch_fish_visual.position = Vector2((reward_width - fish_visual_width) * 0.5, 136.0)
	catch_fish_visual.size = Vector2(fish_visual_width, fish_visual_height)
	catch_fish_visual.z_index = 2
	catch_fish_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_catch_fish_base_position = catch_fish_visual.position

	catch_popup_stats_label.position = Vector2(reward_padding, reward_height - 158.0)
	catch_popup_stats_label.size = Vector2(reward_inner_width, 82.0)
	catch_popup_stats_label.z_index = 5
	catch_popup_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catch_popup_stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	catch_popup_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	catch_popup_stats_label.add_theme_font_size_override("font_size", 11)
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
	map_button.pressed.connect(_on_map_button_pressed)
	profile_button.pressed.connect(_on_profile_button_pressed)
	bait_button.pressed.connect(_on_bait_button_pressed)
	inventory_close_button.pressed.connect(_on_inventory_close_button_pressed)
	inventory_equip_button.pressed.connect(_on_inventory_equip_button_pressed)
	inventory_item_list.item_selected.connect(_on_inventory_item_selected)
	shop_close_button.pressed.connect(_on_shop_close_button_pressed)
	shop_bait_category_button.pressed.connect(_set_shop_category.bind("bait"))
	shop_consumable_category_button.pressed.connect(_set_shop_category.bind("consumable"))
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
	tackle_close_button.pressed.connect(_on_tackle_close_button_pressed)
	waterbody_item_list.item_selected.connect(_on_waterbody_item_selected)
	waterbody_spot_list.item_selected.connect(_on_waterbody_spot_item_selected)
	waterbody_select_button.pressed.connect(_on_waterbody_select_button_pressed)
	waterbody_close_button.pressed.connect(_on_waterbody_close_button_pressed)
	catch_keep_button.pressed.connect(catch_popup_ui.request_keep)
	catch_release_button.pressed.connect(catch_popup_ui.request_release)
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
	FishingManager.fishing_failed_detailed.connect(_on_fishing_failed_detailed)
	FishingManager.fishing_failed.connect(_on_fishing_failed)
	FishingManager.waiting_for_bite_started.connect(_on_waiting_for_bite_started)
	FishingManager.float_nudge.connect(_on_float_nudge)
	FishingManager.bite_started.connect(_on_bite_started)
	FishingManager.bite_window_updated.connect(_on_bite_window_updated)
	FishingManager.hook_success.connect(_on_hook_success)
	FishingManager.hook_failed.connect(_on_hook_failed)

func _update_ui() -> void:
	fishing_hud_ui._update_ui()

func _on_global_time_changed(_time_state: Dictionary) -> void:
	_update_time_hud()
	_apply_time_atmosphere()

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
	keepnet_ui._update_basket_ui()

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
	return catch_popup_ui._is_catch_reward_open()

func _bring_catch_reward_to_front() -> void:
	catch_popup_ui._bring_catch_reward_to_front()

func _close_secondary_popups_for_reward() -> void:
	catch_popup_ui._close_secondary_popups_for_reward()

func _show_catch_reward_popup(catch_data: Dictionary) -> void:
	catch_popup_ui._show_catch_reward_popup(catch_data)

func _lock_catch_reward_buttons() -> void:
	catch_popup_ui._lock_catch_reward_buttons()

func _update_catch_reward_input_lock() -> void:
	catch_popup_ui._update_catch_reward_input_lock()

func _unlock_catch_reward_buttons() -> void:
	catch_popup_ui._unlock_catch_reward_buttons()

func _start_catch_fish_idle_motion(feedback: Dictionary) -> void:
	catch_popup_ui._start_catch_fish_idle_motion(feedback)

func _update_catch_reward_popup(catch_data: Dictionary) -> void:
	catch_popup_ui._update_catch_reward_popup(catch_data)

func _set_reward_fish_texture(fish_id: String) -> void:
	catch_popup_ui._set_reward_fish_texture(fish_id)

func _get_reward_fish_texture(fish_id: String) -> Texture2D:
	return catch_popup_ui._get_reward_fish_texture(fish_id)

func _play_catch_reward_sound(tier: String) -> void:
	catch_popup_ui._play_catch_reward_sound(tier)

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
	catch_popup_ui._hide_catch_reward_popup(animated)

func _set_catch_popup_hidden() -> void:
	catch_popup_ui._set_catch_popup_hidden()

func _get_reward_tier(catch_data: Dictionary) -> String:
	return catch_popup_ui._get_reward_tier(catch_data)

func _get_reward_colors(tier: String) -> Dictionary:
	return catch_popup_ui._get_reward_colors(tier)

func _get_reward_feedback_tuning(tier: String) -> Dictionary:
	return catch_popup_ui._get_reward_feedback_tuning(tier)

func _get_catch_length_cm(catch_data: Dictionary) -> float:
	return catch_popup_ui._get_catch_length_cm(catch_data)

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

	if selected_item.is_empty() or not PlayerData.can_equip_item(selected_item):
		result_label.text = "Эту снасть нельзя экипировать."
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

	if is_cast_animating:
		return

	if _fishing_ui_state == FishingUiState.CAUGHT or _fishing_ui_state == FishingUiState.FAILED:
		_return_to_idle_after_result()
		return

	if _fishing_ui_state == FishingUiState.WAITING and bool(FishingManager.get("use_new_bite_system")):
		FishingManager.try_hook()
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

	if not PlayerData.has_current_bait():
		result_label.text = "Нет наживки."
		_show_toast("Нет наживки", false)
		timer_label.text = "Готов к забросу"
		_update_ui()
		return

	_hide_modal_roots_except("")
	_refresh_modal_input_blocker()
	SaveManager.save_game()

	_pending_cast_spot_id = PlayerData.current_spot
	is_cast_animating = true
	timer_label.text = "Заброс..."
	result_label.text = "Снасть летит к воде..."
	_call_audio_manager("play_cast")
	if fishing_presence_ui != null:
		fishing_presence_ui.start_cast_visual()
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
	var price := InventoryManager.sell_fish_at(fish_index)
	result_label.text = "Рыба продана: %s +%d мон." % [
		str(fish.get("name", "-")),
		price
	]
	_show_basket_notice("Продано: +%d мон." % price, true)
	SaveManager.save_game()
	_update_ui()

func _on_nav_fish_button_pressed() -> void:
	if _should_ignore_base_ui_press():
		return
	if _is_catch_reward_open():
		return

	_active_nav_tab = "fish"
	_hide_modal_roots_except("")
	_refresh_modal_input_blocker()
	_refresh_bottom_nav_styles()

func _on_basket_button_pressed() -> void:
	if _should_ignore_base_ui_press():
		return

	if profile_ui != null:
		profile_ui.close(false)
	keepnet_ui.open()

func _on_basket_close_button_pressed() -> void:
	_arm_modal_tap_guard()
	call_deferred("_close_keepnet_ui_after_guard")

func _close_keepnet_ui_after_guard() -> void:
	keepnet_ui.close()

func _on_inventory_button_pressed() -> void:
	if _should_ignore_base_ui_press():
		return

	if profile_ui != null:
		profile_ui.close(false)
	_inventory_category = "all"
	_selected_inventory_item_id = ""
	inventory_ui.open()

func _on_tackle_button_pressed() -> void:
	if _should_ignore_base_ui_press():
		return

	if profile_ui != null:
		profile_ui.close(false)
	tackle_ui.open()

func _on_shop_button_pressed() -> void:
	if _should_ignore_base_ui_press():
		return

	if profile_ui != null:
		profile_ui.close(false)
	shop_ui.open()

func _on_map_button_pressed() -> void:
	if _should_ignore_base_ui_press():
		return

	if profile_ui != null:
		profile_ui.close(false)
	waterbody_ui.open()

func _on_profile_button_pressed() -> void:
	if _should_ignore_base_ui_press():
		return

	profile_ui.open()
	return
	if _is_catch_reward_open():
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
	_active_nav_tab = "profile"
	_refresh_bottom_nav_styles()
	_show_toast("Профиль пока недоступен.", false)

func _on_bait_button_pressed() -> void:
	if _should_ignore_base_ui_press():
		return

	if _is_catch_reward_open():
		return

	if profile_ui != null:
		profile_ui.close(false)
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

func _on_catch_keep_button_pressed() -> void:
	if not _catch_reward_buttons_ready:
		return

	var catch_data := _pending_reward_catch.duplicate(true)
	_pending_reward_catch = {}
	_hide_catch_reward_popup()

	if not catch_data.is_empty():
		PlayerData.register_catch_stats(catch_data)
		result_label.text = "Рыба в садке: %s\nНажми “Вытянуть”, чтобы закончить цикл." % str(catch_data.get("name", "-"))

	SaveManager.save_game()
	_return_to_idle_after_result()

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
	_return_to_idle_after_result()

func _set_inventory_category(category: String) -> void:
	inventory_ui._set_inventory_category(category)

func _on_inventory_item_selected(index: int) -> void:
	inventory_ui._on_inventory_item_selected(index)

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
	_pending_cast_spot_id = ""
	is_cast_animating = false
	_hide_catch_reward_popup(false)
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

func _on_cast_visual_finished() -> void:
	if not is_cast_animating:
		return

	var spot_id := _pending_cast_spot_id
	_pending_cast_spot_id = ""
	is_cast_animating = false

	if spot_id == "":
		_update_ui()
		return

	_fishing_ui_state = FishingUiState.WAITING
	if fishing_presence_ui != null and fishing_presence_ui.has_method("set_float_in_water"):
		fishing_presence_ui.set_float_in_water(true)
	result_label.text = "Туман сгущается. Ждем клев..."
	FishingManager.start_fishing(spot_id)
	_update_ui()

func _on_fishing_started(seconds: int) -> void:
	_presence_bite_timer = 0.0
	_presence_caught_timer = 0.0
	_fishing_ui_state = FishingUiState.WAITING
	if fishing_presence_ui != null and fishing_presence_ui.has_method("set_float_in_water"):
		fishing_presence_ui.set_float_in_water(true)
	_reset_reeling_ui()
	if bool(FishingManager.get("use_new_bite_system")):
		timer_label.text = "Следи за поплавком"
		fight_status_label.text = "Ждём поклёвку. Нажимай только когда поплавок резко уйдёт."
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
	if fishing_presence_ui != null and fishing_presence_ui.has_method("set_float_in_water"):
		fishing_presence_ui.set_float_in_water(true)
	_reset_reeling_ui()
	timer_label.text = "Следи за поплавком"
	result_label.text = "Поплавок в воде. Жди настоящую поклёвку и нажми “Подсечь”."
	fight_status_label.text = "Ожидание поклёвки..."
	_update_ui()

func _on_float_nudge(nudge_data: Dictionary) -> void:
	if fishing_presence_ui != null and fishing_presence_ui.has_method("play_float_nudge"):
		fishing_presence_ui.play_float_nudge(nudge_data)

	if str(nudge_data.get("kind", "small")) == "suspicious":
		fight_status_label.text = "Поплавок подозрительно качнулся..."

func _on_bite_started(bite_data: Dictionary) -> void:
	_fishing_ui_state = FishingUiState.WAITING
	_presence_bite_timer = max(float(bite_data.get("bite_window_seconds", 1.4)), 0.8)
	timer_label.text = "Клюёт! Подсекай!"
	result_label.text = "Поклёвка: %s\nЖми “Подсечь” в момент рывка." % str(bite_data.get("fish_name", "рыба"))
	fight_status_label.text = "Окно подсечки открыто"
	if fishing_presence_ui != null and fishing_presence_ui.has_method("play_bite_signal"):
		fishing_presence_ui.play_bite_signal(bite_data)
	_update_ui()

func _on_bite_window_updated(bite_data: Dictionary) -> void:
	if _fishing_ui_state != FishingUiState.WAITING:
		return

	var remaining := float(bite_data.get("remaining", 0.0))
	timer_label.text = "Подсечь: %.1f" % remaining

func _on_hook_success(catch_data: Dictionary) -> void:
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
	_update_ui()

func _on_reeling_started(catch_data: Dictionary, state: Dictionary) -> void:
	if not bool(FishingManager.get("use_new_bite_system")):
		_call_audio_manager("play_bite")
	_presence_bite_timer = 0.95
	_presence_caught_timer = 0.0
	_fishing_ui_state = FishingUiState.FIGHTING
	if fishing_presence_ui != null and fishing_presence_ui.has_method("set_rod_visual_state"):
		fishing_presence_ui.set_rod_visual_state("reeling")
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
	SaveManager.save_game()

func _on_reeling_updated(state: Dictionary) -> void:
	_update_reeling_ui(state)

func _on_fish_caught(catch_data: Dictionary) -> void:
	_call_audio_manager("play_catch_success")
	_presence_bite_timer = 0.0
	_presence_caught_timer = 1.1
	_fishing_ui_state = FishingUiState.CAUGHT
	if fishing_presence_ui != null and fishing_presence_ui.has_method("reset_after_landing"):
		fishing_presence_ui.reset_after_landing()
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

func _on_fishing_failed_detailed(failure_data: Dictionary) -> void:
	_play_line_break_sfx_if_needed(failure_data)
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
