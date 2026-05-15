extends Control

const ShopUIScript := preload("res://scripts/ui/ShopUI.gd")
const KeepnetUIScript := preload("res://scripts/ui/KeepnetUI.gd")
const InventoryUIScript := preload("res://scripts/ui/InventoryUI.gd")
const TackleUIScript := preload("res://scripts/ui/TackleUI.gd")
const WaterbodyUIScript := preload("res://scripts/ui/WaterbodyUI.gd")
const CatchPopupUIScript := preload("res://scripts/ui/CatchPopupUI.gd")
const FishingHUDUIScript := preload("res://scripts/ui/FishingHUDUI.gd")
const FishingPresenceUIScript := preload("res://scripts/ui/FishingPresenceUI.gd")

const SHOW_DEBUG_PANEL := false
const STYLE_HUD_PANEL := "HUDPanel"
const STYLE_INFO_CARD := "InfoCard"
const STYLE_PRIMARY_BUTTON := "PrimaryButton"
const STYLE_SECONDARY_BUTTON := "SecondaryButton"
const STYLE_BOTTOM_NAV_BUTTON := "BottomNavButton"
const STYLE_BOTTOM_NAV_ACTIVE := "BottomNavActive"

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
var shop_ui
var keepnet_ui
var inventory_ui
var tackle_ui
var waterbody_ui
var catch_popup_ui
var fishing_hud_ui
var fishing_presence_ui

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
var _shop_category: String = "bait"
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
	_setup_ui_controllers()

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

func _setup_ui_controllers() -> void:
	shop_ui = ShopUIScript.new()
	keepnet_ui = KeepnetUIScript.new()
	inventory_ui = InventoryUIScript.new()
	tackle_ui = TackleUIScript.new()
	waterbody_ui = WaterbodyUIScript.new()
	catch_popup_ui = CatchPopupUIScript.new()
	fishing_hud_ui = FishingHUDUIScript.new()
	fishing_presence_ui = FishingPresenceUIScript.new()

	shop_ui.setup(self)
	keepnet_ui.setup(self)
	inventory_ui.setup(self)
	tackle_ui.setup(self)
	waterbody_ui.setup(self)
	catch_popup_ui.setup(self)
	fishing_hud_ui.setup(self)
	fishing_presence_ui.setup(self)

	shop_ui.buy_requested.connect(_on_shop_buy_pressed)
	keepnet_ui.sell_fish_requested.connect(_on_keepnet_sell_fish_pressed)
	catch_popup_ui.catch_keep_requested.connect(_on_catch_keep_button_pressed)
	catch_popup_ui.catch_release_requested.connect(_on_catch_release_button_pressed)

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
	shop_bait_category_button.pressed.connect(_set_shop_category.bind("bait"))
	shop_consumable_category_button.pressed.connect(_set_shop_category.bind("consumable"))
	shop_tackle_category_button.pressed.connect(_set_shop_category.bind("tackle"))
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
	FishingManager.fishing_failed.connect(_on_fishing_failed)

func _update_ui() -> void:
	fishing_hud_ui._update_ui()

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
	keepnet_ui.open()

func _on_basket_close_button_pressed() -> void:
	keepnet_ui.close()

func _on_inventory_button_pressed() -> void:
	inventory_ui.open()

func _on_tackle_button_pressed() -> void:
	tackle_ui.open()

func _on_shop_button_pressed() -> void:
	shop_ui.open()

func _on_map_button_pressed() -> void:
	waterbody_ui.open()

func _on_bait_button_pressed() -> void:
	if _is_catch_reward_open():
		return

	_active_nav_tab = "inventory"
	_inventory_category = "bait"
	_selected_inventory_item_id = ""
	_on_inventory_button_pressed()

func _on_shop_close_button_pressed() -> void:
	shop_ui.close()

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
	inventory_ui.close()

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
