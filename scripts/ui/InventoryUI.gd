# Handles the inventory window: categories, item list, and item details.
extends RefCounted

var main
var theme
const INVENTORY_ITEMS_PER_PAGE := 24
const INVENTORY_DETAILS_COMPACT_HEIGHT := 360.0
const INVENTORY_DETAILS_TINY_HEIGHT := 300.0
var _texture_cache: Dictionary = {}
var _placeholder_texture_cache: Dictionary = {}
var _details_close_button: Button
var _details_panel: Panel
var _details_title_label: Label
var _details_icon_slot: Panel
var _details_icon: TextureRect
var _details_category_label: Label
var _details_status_label: Label
var _details_meta_panel: Panel
var _details_body_panel: Panel
var _details_action_panel: Panel
var _details_margin: MarginContainer
var _details_root: VBoxContainer
var _details_header_row: HBoxContainer
var _details_empty_label: RichTextLabel
var _details_meta_margin: MarginContainer
var _details_preview_row: HBoxContainer
var _details_meta_column: VBoxContainer
var _details_body_margin: MarginContainer
var _details_description_panel: Panel
var _details_description_margin: MarginContainer
var _details_description_scroll: ScrollContainer
var _details_description_label: RichTextLabel
var _details_action_margin: MarginContainer
var _details_body_scroll: ScrollContainer
var _details_body_label: RichTextLabel
var _details_action_row: HBoxContainer

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
	_ensure_inventory_action_nodes()
	_ensure_inventory_pager_nodes()
	_ensure_inventory_tile_nodes()
	_ensure_inventory_detail_popup_nodes()

func open() -> void:
	if main._is_catch_reward_open():
		return

	main.open_modal("inventory")
	main._active_nav_tab = "inventory"
	main.inventory_backdrop.visible = true
	main.inventory_panel.visible = true
	refresh()
	if main.has_method("refresh_mobile_scroll_helper"):
		main.refresh_mobile_scroll_helper()
	main._refresh_bottom_nav_styles()

func close() -> void:
	if main == null or main.inventory_panel == null:
		return

	main.inventory_panel.visible = false
	main.inventory_backdrop.visible = false
	main.close_modal("inventory")
	main._active_nav_tab = "fish"
	main._refresh_bottom_nav_styles()

func refresh() -> void:
	_update_inventory_ui()

func is_open() -> bool:
	return main != null and main.inventory_panel != null and main.inventory_panel.visible

func _ensure_inventory_action_nodes() -> void:
	if main == null or main.inventory_panel == null:
		return

	if main.inventory_repair_button == null:
		main.inventory_repair_button = Button.new()
		main.inventory_repair_button.name = "InventoryRepairButton"
		main.inventory_repair_button.text = "Починить"
		main.inventory_repair_button.focus_mode = Control.FOCUS_NONE
		main.inventory_repair_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.inventory_repair_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.inventory_panel.add_child(main.inventory_repair_button)

	if main.inventory_discard_button == null:
		main.inventory_discard_button = Button.new()
		main.inventory_discard_button.name = "InventoryDiscardButton"
		main.inventory_discard_button.text = "Выбросить"
		main.inventory_discard_button.focus_mode = Control.FOCUS_NONE
		main.inventory_discard_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.inventory_discard_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.inventory_panel.add_child(main.inventory_discard_button)


func _ensure_inventory_tile_nodes() -> void:
	if main == null or main.inventory_panel == null:
		return

	if main.inventory_tiles_scroll == null or not is_instance_valid(main.inventory_tiles_scroll):
		main.inventory_tiles_scroll = ScrollContainer.new()
		main.inventory_tiles_scroll.name = "InventoryTilesScroll"
		main.inventory_tiles_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		main.inventory_tiles_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		main.inventory_tiles_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
		main.inventory_tiles_scroll.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.inventory_panel.add_child(main.inventory_tiles_scroll)
		if not main.inventory_tiles_scroll.gui_input.is_connected(_on_inventory_tiles_scroll_gui_input):
			main.inventory_tiles_scroll.gui_input.connect(_on_inventory_tiles_scroll_gui_input)

	if main.inventory_tiles_container == null or not is_instance_valid(main.inventory_tiles_container):
		main.inventory_tiles_container = Control.new()
		main.inventory_tiles_container.name = "InventoryTilesContainer"
		main.inventory_tiles_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main.inventory_tiles_scroll.add_child(main.inventory_tiles_container)

	if main.inventory_empty_label == null or not is_instance_valid(main.inventory_empty_label):
		main.inventory_empty_label = Label.new()
		main.inventory_empty_label.name = "InventoryEmptyLabel"
		main.inventory_empty_label.text = "В этой категории пока пусто."
		main.inventory_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		main.inventory_empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		main.inventory_empty_label.add_theme_color_override("font_color", Color(0.80, 0.92, 0.84, 0.78))
		main.inventory_empty_label.add_theme_font_size_override("font_size", 18)
		main.inventory_empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main.inventory_panel.add_child(main.inventory_empty_label)


func _ensure_inventory_detail_popup_nodes() -> void:
	if main == null or main.inventory_panel == null:
		return

	if _details_panel == null or not is_instance_valid(_details_panel):
		_details_panel = Panel.new()
		_details_panel.name = "InventoryItemDetailsPanel"
		_details_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		_details_panel.clip_contents = true
		_details_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
		_details_panel.z_index = main.inventory_panel.z_index + 30
		_details_panel.visible = false
		main.inventory_panel.add_child(_details_panel)
		_apply_inventory_details_panel_style()

	if _details_title_label == null or not is_instance_valid(_details_title_label):
		_details_title_label = Label.new()
		_details_title_label.name = "DetailsTitle"
		_details_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_details_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_details_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_details_title_label.clip_text = true
		_details_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_title_label.add_theme_font_size_override("font_size", 20)
		_details_title_label.add_theme_color_override("font_color", Color(0.98, 1.0, 0.93, 1.0))
		_details_panel.add_child(_details_title_label)

	if _details_close_button == null or not is_instance_valid(_details_close_button):
		_details_close_button = Button.new()
		_details_close_button.name = "InventoryDetailsCloseButton"
		_details_close_button.text = "Закрыть"
		_details_close_button.focus_mode = Control.FOCUS_NONE
		_details_close_button.mouse_filter = Control.MOUSE_FILTER_STOP
		_details_close_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		_details_close_button.z_index = main.inventory_panel.z_index + 24
		main.inventory_panel.add_child(_details_close_button)
		_details_close_button.pressed.connect(_on_inventory_detail_close_pressed)

	_move_control_to_parent(_details_close_button, _details_panel)
	_details_close_button.text = "Закрыть"
	_details_close_button.z_index = main.inventory_panel.z_index + 32

	if _details_meta_panel == null or not is_instance_valid(_details_meta_panel):
		_details_meta_panel = Panel.new()
		_details_meta_panel.name = "DetailsMetaPanel"
		_details_meta_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_panel.add_child(_details_meta_panel)
	_apply_inventory_details_section_style(
		_details_meta_panel,
		Color(0.018, 0.048, 0.044, 0.97),
		Color(0.52, 0.88, 0.76, 0.42)
	)

	if _details_icon_slot == null or not is_instance_valid(_details_icon_slot):
		_details_icon_slot = Panel.new()
		_details_icon_slot.name = "DetailsIconSlot"
		_details_icon_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_meta_panel.add_child(_details_icon_slot)
	_move_control_to_parent(_details_icon_slot, _details_meta_panel)

	if _details_icon == null or not is_instance_valid(_details_icon):
		_details_icon = TextureRect.new()
		_details_icon.name = "DetailsIcon"
		_details_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_details_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_details_icon_slot.add_child(_details_icon)

	if _details_category_label == null or not is_instance_valid(_details_category_label):
		_details_category_label = Label.new()
		_details_category_label.name = "DetailsCategory"
		_details_category_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_details_category_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_details_category_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_details_category_label.clip_text = true
		_details_category_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_category_label.add_theme_font_size_override("font_size", 13)
		_details_category_label.add_theme_color_override("font_color", Color(0.72, 0.86, 0.80, 0.94))
		_details_meta_panel.add_child(_details_category_label)
	_move_control_to_parent(_details_category_label, _details_meta_panel)

	if _details_status_label == null or not is_instance_valid(_details_status_label):
		_details_status_label = Label.new()
		_details_status_label.name = "DetailsStatus"
		_details_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_details_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_details_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_details_status_label.clip_text = true
		_details_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_status_label.add_theme_font_size_override("font_size", 13)
		_details_meta_panel.add_child(_details_status_label)
	_move_control_to_parent(_details_status_label, _details_meta_panel)

	if _details_body_panel == null or not is_instance_valid(_details_body_panel):
		_details_body_panel = Panel.new()
		_details_body_panel.name = "DetailsBodyPanel"
		_details_body_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		_details_panel.add_child(_details_body_panel)
	_apply_inventory_details_section_style(
		_details_body_panel,
		Color(0.006, 0.018, 0.018, 0.98),
		Color(0.42, 0.74, 0.70, 0.34)
	)

	if _details_body_scroll == null or not is_instance_valid(_details_body_scroll):
		_details_body_scroll = ScrollContainer.new()
		_details_body_scroll.name = "DetailsBodyScroll"
		_details_body_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		_details_body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		_details_body_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
		_details_body_panel.add_child(_details_body_scroll)
	_move_control_to_parent(_details_body_scroll, _details_body_panel)

	if _details_body_label == null or not is_instance_valid(_details_body_label):
		_details_body_label = RichTextLabel.new()
		_details_body_label.name = "DetailsBody"
		_details_body_label.bbcode_enabled = true
		_details_body_label.fit_content = true
		_details_body_label.scroll_active = false
		_details_body_label.selection_enabled = false
		_details_body_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_body_label.add_theme_font_size_override("normal_font_size", 13)
		_details_body_label.add_theme_font_size_override("bold_font_size", 14)
		_details_body_label.add_theme_color_override("default_color", Color(0.88, 0.94, 0.90, 0.98))
		_details_body_scroll.add_child(_details_body_label)

	if _details_action_panel == null or not is_instance_valid(_details_action_panel):
		_details_action_panel = Panel.new()
		_details_action_panel.name = "DetailsActionPanel"
		_details_action_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		_details_panel.add_child(_details_action_panel)
	_apply_inventory_details_section_style(
		_details_action_panel,
		Color(0.014, 0.038, 0.034, 0.98),
		Color(0.50, 0.84, 0.72, 0.36)
	)

	if _details_action_row == null or not is_instance_valid(_details_action_row):
		_details_action_row = HBoxContainer.new()
		_details_action_row.name = "DetailsActionRow"
		_details_action_row.mouse_filter = Control.MOUSE_FILTER_STOP
		_details_action_row.add_theme_constant_override("separation", 10)
		_details_action_panel.add_child(_details_action_row)
	_move_control_to_parent(_details_action_row, _details_action_panel)

	_move_control_to_parent(main.inventory_equip_button, _details_action_row)
	if main.inventory_repair_button != null:
		_move_control_to_parent(main.inventory_repair_button, _details_action_row)
	if main.inventory_discard_button != null:
		_move_control_to_parent(main.inventory_discard_button, _details_action_row)

	_ensure_inventory_details_container_nodes()


func _ensure_inventory_details_container_nodes() -> void:
	if _details_panel == null or not is_instance_valid(_details_panel):
		return

	if _details_margin == null or not is_instance_valid(_details_margin):
		_details_margin = MarginContainer.new()
		_details_margin.name = "DetailsMargin"
		_details_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		_details_panel.add_child(_details_margin)
	_details_margin.add_theme_constant_override("margin_left", 18)
	_details_margin.add_theme_constant_override("margin_top", 16)
	_details_margin.add_theme_constant_override("margin_right", 18)
	_details_margin.add_theme_constant_override("margin_bottom", 16)
	_details_margin.offset_left = 0.0
	_details_margin.offset_top = 0.0
	_details_margin.offset_right = 0.0
	_details_margin.offset_bottom = 0.0

	if _details_root == null or not is_instance_valid(_details_root):
		_details_root = VBoxContainer.new()
		_details_root.name = "DetailsRoot"
		_details_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_details_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_details_root.add_theme_constant_override("separation", 10)
		_details_margin.add_child(_details_root)

	if _details_header_row == null or not is_instance_valid(_details_header_row):
		_details_header_row = HBoxContainer.new()
		_details_header_row.name = "DetailsHeaderRow"
		_details_header_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_header_row.custom_minimum_size = Vector2(0.0, 40.0)
		_details_header_row.add_theme_constant_override("separation", 10)
		_details_root.add_child(_details_header_row)
	_move_control_to_parent(_details_title_label, _details_header_row)
	_move_control_to_parent(_details_close_button, _details_header_row)
	_details_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_title_label.custom_minimum_size = Vector2(0.0, 40.0)
	_details_close_button.text = "X"
	_details_close_button.custom_minimum_size = Vector2(42.0, 34.0)
	_details_close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	theme.apply_close_button_style(_details_close_button)

	if _details_empty_label == null or not is_instance_valid(_details_empty_label):
		_details_empty_label = RichTextLabel.new()
		_details_empty_label.name = "DetailsEmptyState"
		_details_empty_label.bbcode_enabled = true
		_details_empty_label.fit_content = false
		_details_empty_label.scroll_active = false
		_details_empty_label.selection_enabled = false
		_details_empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_empty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_details_empty_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_details_empty_label.add_theme_font_size_override("normal_font_size", 15)
		_details_empty_label.add_theme_color_override("default_color", Color(0.82, 0.93, 0.86, 0.92))
		_details_root.add_child(_details_empty_label)

	_move_control_to_parent(_details_meta_panel, _details_root)
	_details_meta_panel.custom_minimum_size = Vector2(0.0, 116.0)
	_details_meta_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_meta_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	if _details_meta_margin == null or not is_instance_valid(_details_meta_margin):
		_details_meta_margin = MarginContainer.new()
		_details_meta_margin.name = "DetailsMetaMargin"
		_details_meta_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_meta_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		_details_meta_panel.add_child(_details_meta_margin)
	_details_meta_margin.add_theme_constant_override("margin_left", 12)
	_details_meta_margin.add_theme_constant_override("margin_top", 12)
	_details_meta_margin.add_theme_constant_override("margin_right", 12)
	_details_meta_margin.add_theme_constant_override("margin_bottom", 12)

	if _details_preview_row == null or not is_instance_valid(_details_preview_row):
		_details_preview_row = HBoxContainer.new()
		_details_preview_row.name = "DetailsPreviewRow"
		_details_preview_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_preview_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_details_preview_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_details_preview_row.add_theme_constant_override("separation", 12)
		_details_meta_margin.add_child(_details_preview_row)
	_move_control_to_parent(_details_icon_slot, _details_preview_row)
	_details_icon_slot.custom_minimum_size = Vector2(92.0, 92.0)
	_details_icon_slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_details_icon_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_details_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	_details_icon.offset_left = 8.0
	_details_icon.offset_top = 8.0
	_details_icon.offset_right = -8.0
	_details_icon.offset_bottom = -8.0

	if _details_meta_column == null or not is_instance_valid(_details_meta_column):
		_details_meta_column = VBoxContainer.new()
		_details_meta_column.name = "DetailsMetaColumn"
		_details_meta_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_meta_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_details_meta_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_details_meta_column.add_theme_constant_override("separation", 8)
		_details_preview_row.add_child(_details_meta_column)
	_move_control_to_parent(_details_category_label, _details_meta_column)
	_move_control_to_parent(_details_status_label, _details_meta_column)
	_details_category_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_move_control_to_parent(_details_body_panel, _details_root)
	_details_body_panel.custom_minimum_size = Vector2(0.0, 128.0)
	_details_body_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_body_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if _details_body_margin == null or not is_instance_valid(_details_body_margin):
		_details_body_margin = MarginContainer.new()
		_details_body_margin.name = "DetailsBodyMargin"
		_details_body_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_body_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		_details_body_panel.add_child(_details_body_margin)
	_details_body_margin.add_theme_constant_override("margin_left", 12)
	_details_body_margin.add_theme_constant_override("margin_top", 10)
	_details_body_margin.add_theme_constant_override("margin_right", 12)
	_details_body_margin.add_theme_constant_override("margin_bottom", 10)
	_move_control_to_parent(_details_body_scroll, _details_body_margin)
	_details_body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_details_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	if _details_description_panel == null or not is_instance_valid(_details_description_panel):
		_details_description_panel = Panel.new()
		_details_description_panel.name = "DetailsDescriptionPanel"
		_details_description_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		_details_root.add_child(_details_description_panel)
	_apply_inventory_details_section_style(
		_details_description_panel,
		Color(0.010, 0.030, 0.028, 0.98),
		Color(0.42, 0.74, 0.70, 0.34)
	)
	_details_description_panel.custom_minimum_size = Vector2(0.0, 112.0)
	_details_description_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_description_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	if _details_description_margin == null or not is_instance_valid(_details_description_margin):
		_details_description_margin = MarginContainer.new()
		_details_description_margin.name = "DetailsDescriptionMargin"
		_details_description_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_description_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		_details_description_panel.add_child(_details_description_margin)
	_details_description_margin.add_theme_constant_override("margin_left", 12)
	_details_description_margin.add_theme_constant_override("margin_top", 10)
	_details_description_margin.add_theme_constant_override("margin_right", 12)
	_details_description_margin.add_theme_constant_override("margin_bottom", 10)
	if _details_description_scroll == null or not is_instance_valid(_details_description_scroll):
		_details_description_scroll = ScrollContainer.new()
		_details_description_scroll.name = "DetailsDescriptionScroll"
		_details_description_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		_details_description_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		_details_description_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
		_details_description_margin.add_child(_details_description_scroll)
	if _details_description_label == null or not is_instance_valid(_details_description_label):
		_details_description_label = RichTextLabel.new()
		_details_description_label.name = "DetailsDescription"
		_details_description_label.bbcode_enabled = false
		_details_description_label.fit_content = true
		_details_description_label.scroll_active = false
		_details_description_label.selection_enabled = false
		_details_description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_description_label.add_theme_font_size_override("normal_font_size", 13)
		_details_description_label.add_theme_color_override("default_color", Color(0.82, 0.90, 0.84, 0.94))
		_details_description_scroll.add_child(_details_description_label)
	_details_description_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_description_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_details_description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	_move_control_to_parent(_details_action_panel, _details_root)
	_details_action_panel.custom_minimum_size = Vector2(0.0, 76.0)
	_details_action_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_action_panel.size_flags_vertical = Control.SIZE_SHRINK_END
	if _details_action_margin == null or not is_instance_valid(_details_action_margin):
		_details_action_margin = MarginContainer.new()
		_details_action_margin.name = "DetailsActionMargin"
		_details_action_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_details_action_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		_details_action_panel.add_child(_details_action_margin)
	_details_action_margin.add_theme_constant_override("margin_left", 12)
	_details_action_margin.add_theme_constant_override("margin_top", 10)
	_details_action_margin.add_theme_constant_override("margin_right", 12)
	_details_action_margin.add_theme_constant_override("margin_bottom", 10)
	_move_control_to_parent(_details_action_row, _details_action_margin)
	_details_action_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_action_row.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var ordered_nodes: Array = [
		_details_header_row,
		_details_empty_label,
		_details_meta_panel,
		_details_body_panel,
		_details_description_panel,
		_details_action_panel
	]
	for i in ordered_nodes.size():
		var node = ordered_nodes[i]
		if node != null and is_instance_valid(node) and node.get_parent() == _details_root:
			_details_root.move_child(node, i)


func _apply_inventory_details_panel_style() -> void:
	if _details_panel == null or not is_instance_valid(_details_panel):
		return
	var style: StyleBoxFlat = theme.make_style(
		Color(0.002, 0.012, 0.014, 0.995),
		Color(0.70, 1.0, 0.88, 0.82),
		14,
		18,
		Color(0.0, 0.0, 0.0, 0.66)
	)
	style.set_border_width_all(2)
	style.content_margin_left = 14.0
	style.content_margin_top = 14.0
	style.content_margin_right = 14.0
	style.content_margin_bottom = 14.0
	_details_panel.add_theme_stylebox_override("panel", style)


func _apply_inventory_details_section_style(panel: Panel, bg_color: Color, border_color: Color) -> void:
	if panel == null or not is_instance_valid(panel):
		return
	var style: StyleBoxFlat = theme.make_style(
		bg_color,
		border_color,
		10,
		4,
		Color(0.0, 0.0, 0.0, 0.26)
	)
	style.set_border_width_all(1)
	style.content_margin_left = 12.0
	style.content_margin_top = 10.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 10.0
	panel.add_theme_stylebox_override("panel", style)


func _set_detail_margin(margin: MarginContainer, left: int, top: int, right: int, bottom: int) -> void:
	if margin == null or not is_instance_valid(margin):
		return
	margin.add_theme_constant_override("margin_left", left)
	margin.add_theme_constant_override("margin_top", top)
	margin.add_theme_constant_override("margin_right", right)
	margin.add_theme_constant_override("margin_bottom", bottom)


func _move_control_to_parent(control: Control, parent: Control) -> void:
	if control == null or parent == null or not is_instance_valid(control) or not is_instance_valid(parent):
		return
	if control.get_parent() == parent:
		return
	if control.get_parent() != null:
		control.get_parent().remove_child(control)
	parent.add_child(control)


func _update_inventory_ui() -> void:
	_ensure_inventory_tile_nodes()
	_layout_inventory_tile_nodes()
	main._visible_inventory_items = _get_visible_inventory_items()
	main.inventory_title_label.text = "Инвентарь"
	main.inventory_item_list.clear()
	main.inventory_item_list.visible = false
	main.inventory_tackle_card.visible = false
	main.inventory_tackle_label.visible = false
	_hide_inventory_pager()
	_rebuild_inventory_tiles()

	var selected_item = _get_selected_inventory_item()
	_update_inventory_details_popup(selected_item)
	_refresh_inventory_category_buttons()


func _get_inventory_content_layout(panel_size: Vector2) -> Dictionary:
	var is_compact := panel_size.y <= 620.0
	var inventory_padding := 20.0 if is_compact else 28.0
	var inventory_body_y := 104.0 if is_compact else 116.0
	var close_button_height := 48.0
	var inventory_action_y: float = panel_size.y - inventory_padding - close_button_height
	var gap := 14.0 if is_compact else 18.0
	var content_width: float = maxf(panel_size.x - inventory_padding * 2.0, 360.0)
	var body_height: float = maxf(inventory_action_y - inventory_body_y - 16.0, 1.0)
	var min_grid_width := 260.0
	var available_details_width: float = maxf(content_width - min_grid_width - gap, 240.0)
	var min_details_width: float = minf(300.0, available_details_width)
	var max_details_width: float = maxf(min_details_width, minf(520.0, content_width * 0.42))
	var details_width: float = clampf(content_width * 0.35, min_details_width, max_details_width)
	if content_width - details_width - gap < min_grid_width:
		details_width = maxf(content_width - min_grid_width - gap, 260.0)
	var grid_width: float = maxf(content_width - details_width - gap, min_grid_width)
	return {
		"grid_pos": Vector2(inventory_padding, inventory_body_y),
		"grid_size": Vector2(grid_width, body_height),
		"details_pos": Vector2(inventory_padding + grid_width + gap, inventory_body_y),
		"details_size": Vector2(details_width, body_height)
	}


func _layout_inventory_tile_nodes() -> void:
	var layout: Dictionary = _get_inventory_content_layout(main.inventory_panel.size)
	var grid_pos: Vector2 = layout.get("grid_pos", Vector2.ZERO)
	var grid_size: Vector2 = layout.get("grid_size", Vector2(240.0, 180.0))

	main.inventory_tiles_scroll.position = grid_pos
	main.inventory_tiles_scroll.size = grid_size
	main.inventory_tiles_scroll.z_index = main.inventory_panel.z_index + 3
	main.inventory_tiles_scroll.visible = true

	main.inventory_tiles_container.position = Vector2.ZERO
	main.inventory_tiles_container.size = main.inventory_tiles_scroll.size
	main.inventory_tiles_container.custom_minimum_size = main.inventory_tiles_scroll.size

	main.inventory_empty_label.position = main.inventory_tiles_scroll.position
	main.inventory_empty_label.size = main.inventory_tiles_scroll.size
	main.inventory_empty_label.z_index = main.inventory_panel.z_index + 4


func _hide_inventory_pager() -> void:
	if main.inventory_prev_page_button != null:
		main.inventory_prev_page_button.visible = false
	if main.inventory_next_page_button != null:
		main.inventory_next_page_button.visible = false
	if main.inventory_page_label != null:
		main.inventory_page_label.visible = false


func _rebuild_inventory_tiles() -> void:
	for child in main.inventory_tiles_container.get_children():
		main.inventory_tiles_container.remove_child(child)
		child.queue_free()

	var items: Array = main._visible_inventory_items
	main.inventory_empty_label.visible = items.is_empty()
	if items.is_empty():
		main.inventory_tiles_container.custom_minimum_size = main.inventory_tiles_scroll.size
		return

	var gap := 14.0
	var viewport_width: float = max(main.inventory_tiles_scroll.size.x, 240.0)
	var min_card_width := 172.0
	var max_columns := 8
	var columns: int = clampi(int(floor((viewport_width + gap) / (min_card_width + gap))), 2, max_columns)
	var card_width: float = floor((viewport_width - gap * float(columns - 1)) / float(columns))
	var card_height := 176.0

	for i in items.size():
		var item: Dictionary = items[i]
		var column := i % columns
		var row := int(i / columns)
		var pos := Vector2(float(column) * (card_width + gap), float(row) * (card_height + gap))
		var card := _create_inventory_tile_card(item, Vector2(card_width, card_height))
		card.position = pos
		main.inventory_tiles_container.add_child(card)

	var rows := ceili(float(items.size()) / float(columns))
	var content_height: float = max(float(rows) * card_height + float(maxi(rows - 1, 0)) * gap, main.inventory_tiles_scroll.size.y)
	main.inventory_tiles_container.size = Vector2(viewport_width, content_height)
	main.inventory_tiles_container.custom_minimum_size = main.inventory_tiles_container.size


func _create_inventory_tile_card(item: Dictionary, card_size: Vector2) -> Button:
	var item_id := str(item.get("id", ""))
	var selected: bool = item_id == str(main._selected_inventory_item_id)
	var card := Button.new()
	card.name = "InventoryTile_%s" % item_id
	card.text = ""
	card.focus_mode = Control.FOCUS_NONE
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.size = card_size
	card.custom_minimum_size = card_size
	card.z_index = main.inventory_panel.z_index + 4
	card.pressed.connect(_on_inventory_tile_pressed.bind(item_id))
	_apply_inventory_tile_button_style(card, item, selected)

	var image_slot := Panel.new()
	image_slot.name = "ImageSlot"
	image_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image_slot.position = Vector2((card_size.x - 92.0) * 0.5, 14.0)
	image_slot.size = Vector2(92.0, 92.0)
	image_slot.add_theme_stylebox_override("panel", theme.get_inventory_slot_style(selected, _get_item_rarity(item)))
	card.add_child(image_slot)

	var image := TextureRect.new()
	image.name = "Icon"
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.texture = _get_item_texture(item)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.position = Vector2(8.0, 8.0)
	image.size = Vector2(76.0, 76.0)
	image_slot.add_child(image)

	var title := Label.new()
	title.name = "Title"
	title.text = _shorten_tile_text(_get_item_display_name(item), 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.clip_text = true
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.position = Vector2(12.0, 112.0)
	title.size = Vector2(card_size.x - 24.0, 36.0)
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", Color(0.88, 0.97, 0.88, 0.98) if not _is_inventory_tile_dimmed(item) else Color(0.64, 0.70, 0.68, 0.88))
	card.add_child(title)

	var subtitle := Label.new()
	subtitle.name = "Subtitle"
	subtitle.text = _get_inventory_item_tile_subtitle(item)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle.clip_text = true
	subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	subtitle.position = Vector2(12.0, 146.0)
	subtitle.size = Vector2(card_size.x - 24.0, 22.0)
	subtitle.add_theme_font_size_override("font_size", 11)
	subtitle.add_theme_color_override("font_color", Color(0.74, 0.92, 0.78, 0.96) if not _is_inventory_tile_dimmed(item) else Color(0.55, 0.61, 0.59, 0.88))
	card.add_child(subtitle)

	if _is_inventory_item_equipped(item):
		var badge := Label.new()
		badge.name = "EquippedBadge"
		badge.text = "Надето"
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.position = Vector2(card_size.x - 76.0, 10.0)
		badge.size = Vector2(62.0, 22.0)
		badge.add_theme_font_size_override("font_size", 9)
		badge.add_theme_color_override("font_color", Color(0.89, 1.0, 0.78, 1.0))
		card.add_child(badge)

	return card


func _apply_inventory_tile_button_style(card: Button, item: Dictionary, selected: bool) -> void:
	var normal := _get_inventory_tile_style(item, selected, "normal")
	var hover := _get_inventory_tile_style(item, selected, "hover")
	var pressed := _get_inventory_tile_style(item, selected, "pressed")
	card.add_theme_stylebox_override("normal", normal)
	card.add_theme_stylebox_override("hover", hover)
	card.add_theme_stylebox_override("pressed", pressed)
	card.add_theme_stylebox_override("focus", pressed)
	card.add_theme_color_override("font_color", Color.TRANSPARENT)
	card.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	card.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)


func _get_inventory_tile_style(item: Dictionary, selected: bool, state: String) -> StyleBoxFlat:
	var style := theme.get_shop_row_style(_get_item_rarity(item)) as StyleBoxFlat
	if selected:
		style.bg_color = Color(0.075, 0.145, 0.090, 0.80)
		style.border_color = Color(0.70, 1.0, 0.66, 0.56)
		style.shadow_color = Color(0.20, 0.72, 0.24, 0.18)
		style.shadow_size = 8
	elif _is_inventory_item_equipped(item):
		style.bg_color = Color(0.055, 0.105, 0.072, 0.78)
		style.border_color = Color(0.58, 0.92, 0.56, 0.40)
	elif _is_inventory_tile_dimmed(item):
		style.bg_color = Color(0.035, 0.040, 0.040, 0.68)
		style.border_color = Color(0.58, 0.62, 0.60, 0.16)

	if state == "hover":
		style.bg_color = Color(style.bg_color.r + 0.025, style.bg_color.g + 0.035, style.bg_color.b + 0.025, style.bg_color.a)
		style.border_color = Color(0.82, 0.98, 0.84, max(style.border_color.a, 0.40))
	elif state == "pressed":
		style.bg_color = Color(max(style.bg_color.r - 0.015, 0.0), max(style.bg_color.g - 0.010, 0.0), max(style.bg_color.b - 0.015, 0.0), style.bg_color.a)
	return style


func _is_inventory_tile_dimmed(item: Dictionary) -> bool:
	var category := str(item.get("category", ""))
	if ["rod", "line", "leader", "hook"].has(category):
		return PlayerData.get_item_condition_title(item) != "Исправна"
	return false


func _get_item_rarity(item: Dictionary) -> String:
	var rarity := str(item.get("rarity", "common")).to_lower()
	var stats = item.get("stats", {})
	if rarity == "common" and typeof(stats) == TYPE_DICTIONARY:
		rarity = str((stats as Dictionary).get("rarity", "common")).to_lower()
	if not ["common", "uncommon", "rare", "very_rare", "epic", "legendary"].has(rarity):
		return "common"
	return rarity


func _update_inventory_details_popup(selected_item: Dictionary) -> void:
	_ensure_inventory_detail_popup_nodes()

	var has_selection := not selected_item.is_empty()
	main.inventory_details_card.visible = false
	main.inventory_details_label.visible = false
	main.inventory_equip_button.visible = false
	if main.inventory_repair_button != null:
		main.inventory_repair_button.visible = false
	if main.inventory_discard_button != null:
		main.inventory_discard_button.visible = false
	if _details_panel != null:
		_details_panel.visible = true
	if _details_close_button != null:
		_details_close_button.visible = has_selection

	if not has_selection:
		_position_inventory_details_popup(false)
		_show_inventory_details_empty_state()
		_layout_inventory_detail_actions([])
		return

	var is_equippable := _is_equippable_inventory_item(selected_item)
	var block_reason := _get_equip_block_reason(selected_item) if is_equippable else ""
	var can_equip := is_equippable and block_reason == ""
	var is_equipped := is_equippable and _is_inventory_item_equipped(selected_item)
	var can_repair := _can_repair_item(selected_item)
	var can_discard := _can_discard_item(selected_item)

	var action_buttons: Array = []
	if can_repair and main.inventory_repair_button != null:
		action_buttons.append(main.inventory_repair_button)
	if can_discard and main.inventory_discard_button != null:
		action_buttons.append(main.inventory_discard_button)
	if is_equippable:
		action_buttons.append(main.inventory_equip_button)

	_position_inventory_details_popup(action_buttons.size() > 0)
	main.inventory_details_label.text = ""
	_update_inventory_details_content(selected_item)

	main.inventory_equip_button.disabled = not can_equip or is_equipped or main._fishing_ui_state != FishingUiState.IDLE
	if main.inventory_repair_button != null:
		main.inventory_repair_button.disabled = not can_repair
		main.inventory_repair_button.text = "Починить"
	if main.inventory_discard_button != null:
		main.inventory_discard_button.disabled = not can_discard
		main.inventory_discard_button.text = "Выбросить"

	if is_equipped:
		main.inventory_equip_button.text = "Надето"
	elif main._fishing_ui_state != FishingUiState.IDLE and can_equip:
		main.inventory_equip_button.text = "Только вне ловли"
	elif block_reason != "":
		main.inventory_equip_button.text = "Недоступно"
	else:
		main.inventory_equip_button.text = "Экипировать"

	_layout_inventory_detail_actions(action_buttons)


func _show_inventory_details_empty_state() -> void:
	if _details_panel == null or not is_instance_valid(_details_panel):
		return

	_details_title_label.text = "Подробности"
	_details_empty_label.visible = true
	_details_empty_label.text = "[center][font_size=22][b]Выберите предмет[/b][/font_size]\n\n[color=#b8d7c5]Здесь появится информация о выбранном предмете.[/color][/center]"
	_details_meta_panel.visible = false
	_details_body_panel.visible = false
	_details_description_panel.visible = false
	_details_action_panel.visible = false
	_details_body_label.text = ""
	if _details_description_label != null:
		_details_description_label.text = ""


func _update_inventory_details_content(item: Dictionary) -> void:
	if _details_panel == null or not is_instance_valid(_details_panel):
		return

	var category := str(item.get("category", "misc"))
	var status_text := _get_inventory_item_status_summary(item)
	_details_empty_label.visible = false
	_details_meta_panel.visible = true
	_details_body_panel.visible = true
	_details_description_panel.visible = true
	_details_title_label.text = _get_item_display_name(item)
	_details_icon.texture = _get_item_texture(item)
	_details_icon_slot.add_theme_stylebox_override("panel", theme.get_inventory_slot_style(false, _get_item_rarity(item)))
	_details_category_label.text = "Категория: %s" % _get_inventory_category_title(category)
	_details_status_label.text = status_text
	if status_text.find("Слом") >= 0 or status_text.find("законч") >= 0:
		_details_status_label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.34, 1.0))
	else:
		_details_status_label.add_theme_color_override("font_color", Color(0.68, 0.96, 0.72, 1.0))
	_details_body_label.text = _get_inventory_item_details_body_text(item)
	var description := _get_item_description(item).strip_edges()
	if description == "":
		description = "Описание пока не добавлено."
	_details_description_label.text = description


func _get_inventory_item_status_summary(item: Dictionary) -> String:
	var category := str(item.get("category", "misc"))
	var quantity := int(item.get("quantity", 1))
	if category == "bait":
		if quantity <= 0:
			return "Состояние: закончилась"
		return "Количество: %d" % quantity
	if category == "fish":
		var stats: Dictionary = item.get("stats", {}) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}
		return "Свежесть: %s" % str(stats.get("freshness_title", "-"))
	if ["rod", "line", "leader", "hook"].has(category):
		return "%s · износ %d%%" % [_get_item_condition_title(item), _get_item_wear_percent(item)]
	if quantity > 1:
		return "Количество: %d" % quantity
	return "Готово к использованию"


func _get_inventory_item_details_body_text(item: Dictionary) -> String:
	var category := str(item.get("category", "misc"))
	var quantity := int(item.get("quantity", 1))
	var stats: Dictionary = item.get("stats", {}) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}
	var sections: Array = []
	var lines: Array = []

	if category == "fish":
		lines.append("Вес: %s" % UIFormatters.format_weight_kg(float(stats.get("weight", 0.0))))
		lines.append("Цена продажи: %s" % UIFormatters.format_money(float(stats.get("sell_price", stats.get("price", 0)))))
		lines.append("Базовая цена: %s" % UIFormatters.format_money(float(stats.get("price", 0))))
		lines.append("Редкость: %s" % str(stats.get("rarity", "-")))
		if stats.has("fish_status_title"):
			lines.append("Статус: %s" % str(stats.get("fish_status_title", "-")))
		_append_detail_section(sections, "Основное", lines)
		return "\n\n".join(sections)

	lines.append("Количество: %d" % quantity)
	if _is_inventory_item_equipped(item):
		lines.append("Статус: надето в текущей сборке")
	_append_detail_section(sections, "Основное", lines)

	var condition_text := _get_item_condition_details_text(item, "")
	if condition_text != "":
		_append_detail_section(sections, "Состояние", condition_text.split("\n", false))

	var stats_text := ""
	if category == "float":
		stats_text = _get_float_inventory_stats_text(stats)
	elif category == "leader":
		stats_text = _get_leader_inventory_stats_text(item)
	else:
		stats_text = _get_inventory_stats_text(stats)
	if stats_text != "":
		_append_detail_section(sections, "Характеристики", stats_text.split("\n", false))

	return "\n\n".join(sections)


func _append_detail_section(sections: Array, title: String, lines) -> void:
	var clean_lines: Array = []
	for line in lines:
		var text := str(line).strip_edges()
		if text != "":
			clean_lines.append(text)
	if clean_lines.is_empty():
		return
	var escaped_lines: Array = []
	for line in clean_lines:
		escaped_lines.append(_escape_details_bbcode(str(line)))
	sections.append("[color=#baf28a][b]%s[/b][/color]\n%s" % [
		_escape_details_bbcode(title),
		"\n".join(escaped_lines)
	])


func _escape_details_bbcode(value: String) -> String:
	return value.replace("[", "[lb]").replace("]", "[rb]")


func _position_inventory_details_popup(has_actions: bool) -> void:
	var layout: Dictionary = _get_inventory_content_layout(main.inventory_panel.size)
	var panel_pos: Vector2 = layout.get("details_pos", Vector2.ZERO)
	var panel_size: Vector2 = layout.get("details_size", Vector2(320.0, 260.0))
	var compact := panel_size.y <= INVENTORY_DETAILS_COMPACT_HEIGHT
	var tiny := panel_size.y <= INVENTORY_DETAILS_TINY_HEIGHT
	var outer_padding := 10 if compact else 14
	var section_padding := 8 if compact else 10
	var root_separation := 6 if compact else 10
	var header_height := 34.0 if compact else 40.0
	var meta_height := 72.0 if compact else 116.0
	var description_height := 48.0 if tiny else (56.0 if compact else 112.0)
	var action_height := 48.0 if tiny else (52.0 if compact else 76.0)
	var visible_gap_count := 4 if has_actions else 3
	var fixed_height := float(outer_padding * 2) + header_height + meta_height + description_height
	if has_actions:
		fixed_height += action_height
	fixed_height += float(visible_gap_count * root_separation)
	var body_height := 128.0
	if compact:
		body_height = clampf(panel_size.y - fixed_height, 56.0, 98.0)
	var icon_size := 58.0 if tiny else (64.0 if compact else 92.0)
	var icon_inset := 5.0 if compact else 8.0
	var title_font_size := 17 if compact else 20
	var meta_font_size := 11 if compact else 13
	var body_font_size := 12 if compact else 13
	var body_bold_font_size := 13 if compact else 14

	_details_panel.position = panel_pos
	_details_panel.size = panel_size
	_details_panel.z_index = main.inventory_panel.z_index + 30
	_details_panel.visible = true
	_details_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_details_panel.clip_contents = true
	_apply_inventory_details_panel_style()

	var content_width: float = maxf(panel_size.x - float(outer_padding * 2), 120.0)
	var label_width: float = maxf(content_width - 16.0, 100.0)
	if _details_margin != null:
		_details_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		_set_detail_margin(_details_margin, outer_padding, outer_padding, outer_padding, outer_padding)
		_details_margin.offset_left = 0.0
		_details_margin.offset_top = 0.0
		_details_margin.offset_right = 0.0
		_details_margin.offset_bottom = 0.0
	if _details_root != null:
		_details_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_details_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_details_root.add_theme_constant_override("separation", root_separation)
	if _details_header_row != null:
		_details_header_row.custom_minimum_size = Vector2(0.0, header_height)
		_details_header_row.add_theme_constant_override("separation", root_separation)
	_details_title_label.z_index = main.inventory_panel.z_index + 31
	_details_title_label.custom_minimum_size = Vector2(maxf(label_width - 52.0, 80.0), header_height)
	_details_title_label.add_theme_font_size_override("font_size", title_font_size)

	if _details_close_button != null:
		_details_close_button.z_index = main.inventory_panel.z_index + 32
		_details_close_button.custom_minimum_size = Vector2(36.0 if compact else 42.0, 30.0 if compact else 34.0)
		theme.apply_close_button_style(_details_close_button)

	_details_meta_panel.z_index = main.inventory_panel.z_index + 31
	_details_meta_panel.custom_minimum_size = Vector2(0.0, meta_height)
	_details_meta_panel.clip_contents = true
	_set_detail_margin(_details_meta_margin, section_padding, section_padding, section_padding, section_padding)
	if _details_preview_row != null:
		_details_preview_row.add_theme_constant_override("separation", 8 if compact else 12)
	if _details_meta_column != null:
		_details_meta_column.add_theme_constant_override("separation", 4 if compact else 8)
	_details_icon_slot.z_index = main.inventory_panel.z_index + 32
	_details_icon_slot.custom_minimum_size = Vector2(icon_size, icon_size)
	_details_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	_details_icon.offset_left = icon_inset
	_details_icon.offset_top = icon_inset
	_details_icon.offset_right = -icon_inset
	_details_icon.offset_bottom = -icon_inset
	_details_category_label.custom_minimum_size = Vector2(label_width, 24.0 if compact else 32.0)
	_details_category_label.add_theme_font_size_override("font_size", meta_font_size)
	_details_status_label.custom_minimum_size = Vector2(label_width, 28.0 if compact else 42.0)
	_details_status_label.add_theme_font_size_override("font_size", meta_font_size)

	_details_body_panel.z_index = main.inventory_panel.z_index + 31
	_details_body_panel.custom_minimum_size = Vector2(0.0, body_height)
	_details_body_panel.clip_contents = true
	_set_detail_margin(_details_body_margin, section_padding, section_padding, section_padding, section_padding)
	if _details_body_scroll != null:
		_details_body_scroll.clip_contents = true
	_details_body_label.custom_minimum_size = Vector2(label_width, 1.0)
	_details_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_body_label.add_theme_font_size_override("normal_font_size", body_font_size)
	_details_body_label.add_theme_font_size_override("bold_font_size", body_bold_font_size)

	if _details_description_panel != null:
		_details_description_panel.z_index = main.inventory_panel.z_index + 31
		_details_description_panel.custom_minimum_size = Vector2(0.0, description_height)
		_details_description_panel.clip_contents = true
		_set_detail_margin(_details_description_margin, section_padding, section_padding, section_padding, section_padding)
	if _details_description_scroll != null:
		_details_description_scroll.clip_contents = true
	if _details_description_label != null:
		_details_description_label.custom_minimum_size = Vector2(label_width, 1.0)
		_details_description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_details_description_label.add_theme_font_size_override("normal_font_size", body_font_size)

	_details_action_panel.z_index = main.inventory_panel.z_index + 31
	_details_action_panel.visible = has_actions
	_details_action_panel.custom_minimum_size = Vector2(0.0, action_height)
	_details_action_panel.clip_contents = true
	_set_detail_margin(_details_action_margin, section_padding, section_padding, section_padding, section_padding)
	_details_action_row.z_index = main.inventory_panel.z_index + 32
	_details_action_row.add_theme_constant_override("separation", 6 if compact else 10)


func _layout_inventory_detail_actions(action_buttons: Array) -> void:
	if _details_action_row == null or not is_instance_valid(_details_action_row):
		return

	var compact := _details_panel != null and is_instance_valid(_details_panel) and _details_panel.size.y <= INVENTORY_DETAILS_COMPACT_HEIGHT
	var button_height := 40.0 if compact else 56.0
	var button_width := 64.0 if compact else 92.0
	var button_font_size := 13 if compact else 16

	_details_action_row.visible = not action_buttons.is_empty()
	for button in [main.inventory_repair_button, main.inventory_discard_button, main.inventory_equip_button]:
		if button != null:
			_move_control_to_parent(button, _details_action_row)
			button.visible = false
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.custom_minimum_size = Vector2(button_width, button_height)
			button.add_theme_font_size_override("font_size", button_font_size)

	if action_buttons.is_empty():
		return

	for button in action_buttons:
		button.visible = true
		button.z_index = main.inventory_panel.z_index + 33
		if button == main.inventory_equip_button:
			theme.apply_primary_button_style(button)
		else:
			theme.apply_secondary_button_style(button)


func _ensure_inventory_pager_nodes() -> void:
	if main == null or main.inventory_panel == null:
		return

	if main.inventory_prev_page_button == null:
		main.inventory_prev_page_button = Button.new()
		main.inventory_prev_page_button.name = "InventoryPrevPageButton"
		main.inventory_prev_page_button.text = "<"
		main.inventory_prev_page_button.focus_mode = Control.FOCUS_NONE
		main.inventory_prev_page_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.inventory_prev_page_button.z_index = 2
		main.inventory_prev_page_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.inventory_panel.add_child(main.inventory_prev_page_button)
		main.inventory_prev_page_button.pressed.connect(_on_inventory_prev_page_pressed)

	if main.inventory_next_page_button == null:
		main.inventory_next_page_button = Button.new()
		main.inventory_next_page_button.name = "InventoryNextPageButton"
		main.inventory_next_page_button.text = ">"
		main.inventory_next_page_button.focus_mode = Control.FOCUS_NONE
		main.inventory_next_page_button.mouse_filter = Control.MOUSE_FILTER_STOP
		main.inventory_next_page_button.z_index = 2
		main.inventory_next_page_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.inventory_panel.add_child(main.inventory_next_page_button)
		main.inventory_next_page_button.pressed.connect(_on_inventory_next_page_pressed)

	if main.inventory_page_label == null:
		main.inventory_page_label = Label.new()
		main.inventory_page_label.name = "InventoryPageLabel"
		main.inventory_page_label.text = ""
		main.inventory_page_label.z_index = 2
		main.inventory_page_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main.inventory_page_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
		main.inventory_panel.add_child(main.inventory_page_label)


func _update_inventory_pager(page_count: int, total_count: int) -> void:
	_ensure_inventory_pager_nodes()
	if main.inventory_prev_page_button == null or main.inventory_next_page_button == null or main.inventory_page_label == null:
		return

	var has_pages := total_count > INVENTORY_ITEMS_PER_PAGE
	main.inventory_prev_page_button.visible = has_pages
	main.inventory_next_page_button.visible = has_pages
	main.inventory_page_label.visible = has_pages
	main.inventory_prev_page_button.disabled = main._inventory_page <= 0
	main.inventory_next_page_button.disabled = main._inventory_page >= page_count - 1
	main.inventory_page_label.text = "%d / %d" % [main._inventory_page + 1, page_count]


func _refresh_inventory_category_buttons() -> void:
	if main.category_lines_button != null:
		main.category_lines_button.text = "Лески/пов."

	var category_buttons: Array = [
		[main.category_all_button, "all"],
		[main.category_rods_button, "rod"],
		[main.category_lines_button, "line"],
		[main.category_floats_button, "float"],
		[main.category_hooks_button, "hook"],
		[main.category_baits_button, "bait"],
		[main.category_fish_button, "fish"],
		[main.category_misc_button, "misc"]
	]

	for item in category_buttons:
		var button: Button = item[0]
		var category: String = item[1]
		theme.apply_tab_button_style(button, category == main._inventory_category)


func _get_visible_inventory_items() -> Array:
	var items: Array = []

	if main._inventory_category == "all":
		items.append_array(PlayerData.owned_items)
	elif main._inventory_category == "line":
		items.append_array(PlayerData.get_owned_items_for_category("line"))
		items.append_array(PlayerData.get_owned_items_for_category("leader"))
	elif main._inventory_category != "fish":
		items.append_array(PlayerData.get_owned_items_for_category(main._inventory_category))

	var filtered_items: Array = []
	for item in items:
		if typeof(item) == TYPE_DICTIONARY and _should_show_inventory_item(item):
			filtered_items.append(item)
	items = filtered_items

	if _should_show_keepnet_fish_in_inventory() and (main._inventory_category == "all" or main._inventory_category == "fish"):
		for i in InventoryManager.inventory.size():
			var fish: Dictionary = InventoryManager.inventory[i]
			var base_price := int(fish.get("price", 0))
			items.append({
				"id": "basket_fish_%d" % i,
				"name": str(fish.get("name", "-")),
				"category": "fish",
				"quantity": 1,
				"description": "Рыба в садке.",
				"stats": {
					"weight": float(fish.get("weight", 0.0)),
					"price": base_price,
					"sell_price": InventoryManager.get_fish_sell_price(fish),
					"freshness_price": InventoryManager.get_fish_freshness_price(fish),
					"freshness_title": FishFreshnessManager.get_freshness_title(fish),
					"freshness_ratio": FishFreshnessManager.get_freshness_ratio(fish),
					"rarity": str(fish.get("rarity", "-"))
				}
			})

	return items

func _should_show_keepnet_fish_in_inventory() -> bool:
	return false

func _should_show_inventory_item(item: Dictionary) -> bool:
	var category := str(item.get("category", "misc"))
	if ["bait", "consumable", "groundbait"].has(category) and int(item.get("quantity", 0)) <= 0:
		return false
	return true

func _is_equippable_inventory_item(item: Dictionary) -> bool:
	var category := str(item.get("category", ""))
	return PlayerData.TACKLE_SLOT_ITEM_CATEGORIES.values().has(category)


func _get_selected_inventory_item() -> Dictionary:
	for item in main._visible_inventory_items:
		if str(item.get("id", "")) == main._selected_inventory_item_id:
			return item

	return {}

func _get_item_display_name(item: Dictionary) -> String:
	return str(item.get("display_name_ru", item.get("name", "-")))

func _get_item_description(item: Dictionary) -> String:
	return str(item.get("description_ru", item.get("description", "")))


func _get_inventory_item_display_text(item: Dictionary) -> String:
	var category = str(item.get("category", "misc"))
	var name = _get_item_display_name(item)
	var quantity = int(item.get("quantity", 1))
	var equipped_marker := "  [Надето]" if _is_inventory_item_equipped(item) else ""

	if category == "fish":
		var stats: Dictionary = item.get("stats", {})
		return "%s | %s | %s | %s" % [
			name,
			UIFormatters.format_weight_kg(float(stats.get("weight", 0.0))),
			UIFormatters.format_money(float(stats.get("sell_price", stats.get("price", 0)))),
			str(stats.get("freshness_title", "-"))
		]

	if ["rod", "line", "leader", "hook"].has(category):
		var status := PlayerData.get_item_condition_title(item)
		if status != "Исправна":
			return "%s [%s]%s" % [name, status, equipped_marker]

	if quantity > 1:
		return "%s x%d%s" % [name, quantity, equipped_marker]

	return "%s%s" % [name, equipped_marker]


func _get_inventory_item_tile_text(item: Dictionary) -> String:
	var name := _shorten_tile_text(_get_item_display_name(item), 28)
	var subtitle := _get_inventory_item_tile_subtitle(item)
	if subtitle == "":
		return name
	return "%s\n%s" % [name, subtitle]


func _get_inventory_item_tile_subtitle(item: Dictionary) -> String:
	var category := str(item.get("category", "misc"))
	var quantity := int(item.get("quantity", 1))
	var stats: Dictionary = item.get("stats", {}) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}

	if _is_inventory_item_equipped(item):
		return "Надето"

	if category == "fish":
		return UIFormatters.format_weight_kg(float(stats.get("weight", 0.0)))

	if ["rod", "line", "leader", "hook"].has(category):
		var status := PlayerData.get_item_condition_title(item)
		if status != "Исправна":
			return status

	if category == "leader":
		var length_cm := int(stats.get("length_cm", 0))
		var test_kg := float(stats.get("max_load_kg", stats.get("max_load", stats.get("strength", 0.0))))
		if length_cm > 0 and test_kg > 0.0:
			return "%d см / %s" % [length_cm, _format_kg_short(test_kg)]

	if category == "line":
		var line_test := float(stats.get("max_load_kg", stats.get("max_load", stats.get("strength", 0.0))))
		if line_test > 0.0:
			return _format_kg_short(line_test)

	if category == "float":
		var sensitivity := float(stats.get("sensitivity", 0.0))
		if sensitivity > 0.0:
			return "Чувст. %d%%" % roundi(sensitivity * 100.0)

	if category == "bait" or quantity > 1:
		return "x%d" % quantity

	return _get_inventory_category_title(category)


func _shorten_tile_text(value: String, max_chars: int) -> String:
	if value.length() <= max_chars:
		return value
	return "%s..." % value.substr(0, maxi(max_chars - 3, 1))


func _format_kg_short(value: float) -> String:
	if absf(value - roundf(value)) < 0.05:
		return "%d кг" % roundi(value)
	return "%.1f кг" % value


func _get_inventory_item_details_text(item: Dictionary) -> String:
	var panel_body := _get_inventory_item_details_body_text(item)
	if panel_body == "":
		return _get_item_display_name(item)
	return "%s\n\n%s" % [_get_item_display_name(item), panel_body]

	var category = str(item.get("category", "misc"))
	var name = _get_item_display_name(item)
	var quantity = int(item.get("quantity", 1))
	var description = _get_item_description(item)
	var stats: Dictionary = item.get("stats", {})

	if category == "fish":
		return "%s\nКатегория: Рыба / Садок\nВес: %s\nСвежесть: %s\nЦена продажи: %s\nБазовая цена: %s\nРедкость: %s" % [
			name,
			UIFormatters.format_weight_kg(float(stats.get("weight", 0.0))),
			str(stats.get("freshness_title", "-")),
			UIFormatters.format_money(float(stats.get("sell_price", stats.get("price", 0)))),
			UIFormatters.format_money(float(stats.get("price", 0))),
			str(stats.get("rarity", "-"))
		]

	var equipped_line := "Статус: надето в текущей сборке\n" if _is_inventory_item_equipped(item) else ""
	var details = "%s\n%sКатегория: %s\nКоличество: %d" % [
		name,
		equipped_line,
		_get_inventory_category_title(category),
		quantity
	]

	var condition_text := _get_item_condition_details_text(item, "")
	if condition_text != "":
		details += "\n\n%s" % condition_text

	if description != "":
		details += "\n%s" % description

	var stats_text := ""
	if category == "float":
		stats_text = _get_float_inventory_stats_text(stats)
	elif category == "leader":
		stats_text = _get_leader_inventory_stats_text(item)
	else:
		stats_text = _get_inventory_stats_text(stats)
	if stats_text != "":
		details += "\n\n%s" % stats_text

	return details


func _get_item_texture(item: Dictionary) -> Texture2D:
	var path := str(item.get("image_path", ""))
	if path == "":
		return _get_placeholder_texture(str(item.get("category", "misc")))
	if _texture_cache.has(path):
		var cached_texture = _texture_cache[path]
		if cached_texture is Texture2D:
			return cached_texture
		return _get_placeholder_texture(str(item.get("category", "misc")))

	var texture := _load_texture_resource(path)
	_texture_cache[path] = texture
	if texture != null:
		return texture
	return _get_placeholder_texture(str(item.get("category", "misc")))


func _get_placeholder_texture(category: String) -> Texture2D:
	if _placeholder_texture_cache.has(category):
		return _placeholder_texture_cache[category]

	var color := Color(0.12, 0.19, 0.17, 0.96)
	match category:
		"rod":
			color = Color(0.20, 0.16, 0.10, 0.96)
		"line", "leader":
			color = Color(0.10, 0.18, 0.22, 0.96)
		"float":
			color = Color(0.18, 0.12, 0.10, 0.96)
		"hook":
			color = Color(0.18, 0.18, 0.18, 0.96)
		"bait":
			color = Color(0.18, 0.21, 0.10, 0.96)
		"fish":
			color = Color(0.08, 0.17, 0.22, 0.96)

	var image := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture := ImageTexture.create_from_image(image)
	_placeholder_texture_cache[category] = texture
	return texture


func _load_texture_resource(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var resource: Resource = load(path)
		if resource is Texture2D:
			return resource

	if FileAccess.file_exists(path):
		var image := Image.load_from_file(path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)

	return null


func _get_inventory_stats_text(stats: Dictionary) -> String:
	var lines: Array = []
	var stat_keys: Array = [
		"length_m",
		"rod_class",
		"max_fish_weight",
		"max_load_kg",
		"max_load",
		"strength",
		"diameter_mm",
		"diameter",
		"material",
		"break_resistance",
		"break_chance",
		"visibility",
		"control_bonus",
		"handling_bonus",
		"reach_bonus",
		"stiffness",
		"durability",
		"durability_loss",
		"wear_rate",
		"hook_size",
		"hook_strength",
		"hook_chance",
		"target_fish_size",
		"fish_escape_modifier",
		"bait_type",
		"fish_attraction"
	]
	var has_load := false
	var has_diameter := false
	for key in stat_keys:
		if not stats.has(key):
			continue
		if ["max_load_kg", "max_load", "strength"].has(key):
			if has_load:
				continue
			has_load = true
		if ["diameter_mm", "diameter"].has(key):
			if has_diameter:
				continue
			has_diameter = true
		var value = stats[key]
		if typeof(value) == TYPE_DICTIONARY or typeof(value) == TYPE_ARRAY:
			continue
		var line := _format_inventory_stat_line(str(key), value)
		if line != "":
			lines.append(line)

	return "\n".join(lines)


func _format_inventory_stat_line(key: String, value) -> String:
	if key == "fish_escape_modifier":
		var escape_delta := roundi((1.0 - float(value)) * 100.0)
		if escape_delta > 0:
			return "Снижение схода: %d%%" % escape_delta
		if escape_delta < 0:
			return "Риск схода: +%d%%" % absi(escape_delta)
		return "Сход рыбы: без изменений"
	return "%s: %s" % [_get_inventory_stat_title(key), _format_inventory_stat_value(key, value)]


func _get_inventory_stat_title(key: String) -> String:
	match key:
		"length_m":
			return "Длина"
		"rod_class":
			return "Класс"
		"max_fish_weight":
			return "Макс. рыба"
		"max_load_kg", "max_load", "strength":
			return "Тест"
		"diameter_mm", "diameter":
			return "Диаметр"
		"material":
			return "Материал"
		"break_resistance":
			return "Защита от обрыва"
		"break_chance":
			return "Риск обрыва"
		"visibility":
			return "Заметность"
		"control_bonus":
			return "Контроль"
		"handling_bonus":
			return "Управляемость"
		"reach_bonus":
			return "Дальность"
		"stiffness":
			return "Жёсткость"
		"durability":
			return "Прочность"
		"durability_loss":
			return "Износ удочки"
		"wear_rate":
			return "Скорость износа"
		"hook_size":
			return "Размер"
		"hook_strength":
			return "Прочность крючка"
		"hook_chance":
			return "Подсечка"
		"target_fish_size":
			return "Размер рыбы"
		"bait_type":
			return "Тип наживки"
		"fish_attraction":
			return "Привлечение"
		_:
			return ""


func _format_inventory_stat_value(key: String, value) -> String:
	match key:
		"hook_size":
			return "№%s" % PlayerData.format_hook_size(int(value))
		"length_m":
			return "%.1f м" % float(value)
		"max_fish_weight", "max_load_kg", "max_load", "strength":
			return "%.1f кг" % float(value)
		"diameter_mm", "diameter":
			return "%.2f мм" % float(value)
		"durability", "durability_loss", "wear_rate", "break_resistance", "break_chance", "visibility", "control_bonus", "handling_bonus", "reach_bonus", "stiffness", "hook_strength", "hook_chance", "fish_attraction":
			return "%d%%" % roundi(float(value) * 100.0)
		"rod_class":
			match str(value):
				"ultra_light":
					return "ультралайт"
				"light":
					return "лёгкая"
				"medium":
					return "средняя"
				"universal":
					return "универсальная"
				"heavy":
					return "тяжёлая"
				"extra_heavy":
					return "очень тяжёлая"
				_:
					return str(value)
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
		"material":
			return _format_leader_material(str(value))
		_:
			return str(value)


func _get_float_inventory_stats_text(stats: Dictionary) -> String:
	var lines: Array = [
		"Чувствительность: %d%%" % roundi(float(stats.get("sensitivity", 0.0)) * 100.0),
		"Устойчивость: %d%%" % roundi(float(stats.get("stability", 0.0)) * 100.0),
		"Ветер: %d%%" % roundi(float(stats.get("wind_resistance", 0.0)) * 100.0),
		"Дальность: %s" % _format_signed_percent(float(stats.get("cast_distance_bonus", 0.0))),
		"Камыши/трава: %d%%" % roundi(float(stats.get("vegetation_control", 0.0)) * 100.0),
		"Тяжёлая наживка: %d%%" % roundi(float(stats.get("heavy_bait_support", 0.0)) * 100.0),
		"Рабочая глубина: %.1f-%.1f м" % [float(stats.get("depth_min", 0.2)), float(stats.get("depth_max", 2.5))]
	]
	if float(stats.get("night_bonus", 0.0)) > 0.0:
		lines.append("Ночной бонус: +%d%%" % roundi(float(stats.get("night_bonus", 0.0)) * 100.0))
	if float(stats.get("hook_timing_bonus", 0.0)) > 0.0:
		lines.append("Окно подсечки: +%d%%" % roundi(float(stats.get("hook_timing_bonus", 0.0)) * 100.0))
	if float(stats.get("long_range_accuracy_bonus", 0.0)) > 0.0:
		lines.append("Дальняя точность: +%d%%" % roundi(float(stats.get("long_range_accuracy_bonus", 0.0)) * 100.0))
	if float(stats.get("setup_comfort", 0.0)) > 0.0:
		lines.append("Удобство настройки: +%d%%" % roundi(float(stats.get("setup_comfort", 0.0)) * 100.0))
	return "\n".join(lines)

func _get_leader_inventory_stats_text(item: Dictionary) -> String:
	var stats: Dictionary = item.get("stats", {}) if typeof(item.get("stats", {})) == TYPE_DICTIONARY else {}
	var lines: Array = [
		"Материал: %s" % _format_leader_material(str(stats.get("material", stats.get("leader_type", "")))),
		"Длина: %d см" % int(stats.get("length_cm", 0)),
		"Тест: %.1f кг" % float(stats.get("max_load_kg", stats.get("max_load", stats.get("strength", 0.0)))),
		"Цена: %s" % UIFormatters.format_money(float(item.get("price", 0.0))),
		"Контроль: %s" % _format_signed_percent(float(stats.get("control_bonus", 0.0))),
		"Осторожная рыба: %s" % _format_signed_percent(float(stats.get("cautious_bite_bonus", 0.0))),
		"Штраф мелочи: %s" % _format_signed_percent(-float(stats.get("small_fish_penalty", 0.0))),
		"Защита от обрыва: %d%%" % roundi(float(stats.get("break_resistance", 1.0)) * 100.0),
		"Защита от среза: %d%%" % roundi(float(stats.get("bite_protection", 0.0)) * 100.0)
	]
	return "\n".join(lines)

func _format_leader_material(value: String) -> String:
	match value.to_lower():
		"nylon", "mono", "monofilament":
			return "нейлон"
		"fluoro", "fluorocarbon":
			return "флюорокарбон"
		"braid", "braided":
			return "плетёный"
		"reinforced":
			return "усиленный"
		"steel":
			return "стальной"
		_:
			return value


func _format_signed_percent(value: float) -> String:
	var percent := roundi(value * 100.0)
	if percent > 0:
		return "+%d%%" % percent
	return "%d%%" % percent


func _repair_service() -> Node:
	if main != null:
		return main.get_node_or_null("/root/RepairService")
	return null


func _validation_service() -> Node:
	if main != null:
		return main.get_node_or_null("/root/TackleValidationService")
	return null


func _get_equip_block_reason(item: Dictionary, slot_type: String = "") -> String:
	var validation_service := _validation_service()
	if validation_service != null and validation_service.has_method("get_equip_block_reason"):
		return str(validation_service.call("get_equip_block_reason", slot_type, item))
	return PlayerData.get_equip_block_reason(item, slot_type)


func _can_repair_item(item: Dictionary) -> bool:
	var repair_service := _repair_service()
	if repair_service != null and repair_service.has_method("can_repair_item"):
		return bool(repair_service.call("can_repair_item", item))
	return PlayerData.is_item_repairable(item)


func _can_discard_item(item: Dictionary) -> bool:
	var repair_service := _repair_service()
	if repair_service != null and repair_service.has_method("can_discard_item"):
		return bool(repair_service.call("can_discard_item", item))
	return PlayerData.can_discard_item(item)


func _get_item_wear_percent(item: Dictionary) -> int:
	var repair_service := _repair_service()
	if repair_service != null and repair_service.has_method("get_wear_percent"):
		return int(repair_service.call("get_wear_percent", item))
	return PlayerData.get_item_wear_percent(item)


func _get_item_repair_cost(item: Dictionary) -> int:
	var repair_service := _repair_service()
	if repair_service != null and repair_service.has_method("get_repair_cost"):
		return int(repair_service.call("get_repair_cost", item))
	return PlayerData.get_item_repair_cost(item)


func _get_item_condition_title(item: Dictionary) -> String:
	var repair_service := _repair_service()
	if repair_service != null and repair_service.has_method("get_item_condition_title"):
		return str(repair_service.call("get_item_condition_title", item))
	return PlayerData.get_item_condition_title(item)


func _get_item_condition_details_text(item: Dictionary, slot_type: String = "") -> String:
	var category := str(item.get("category", ""))
	if not ["rod", "line", "leader", "hook", "bait"].has(category):
		return ""

	if category == "bait":
		if int(item.get("quantity", 0)) <= 0:
			return "Состояние: закончилась\nПричина: Наживка закончилась."
		return ""

	var wear_percent := _get_item_wear_percent(item)
	var repair_cost := _get_item_repair_cost(item)
	var block_reason := _get_equip_block_reason(item, slot_type)
	var lines: Array = [
		"Состояние: %s" % _get_item_condition_title(item),
		"Износ: %d%%" % wear_percent
	]
	if repair_cost > 0:
		lines.append("Ремонт: %s" % UIFormatters.format_money(float(repair_cost)))
	if block_reason != "":
		lines.append("Причина: %s" % block_reason)
	return "\n".join(lines)


func _get_current_tackle_inventory_text() -> String:
	var bait_2_text := "закрыта"
	if PlayerData.can_use_second_bait():
		bait_2_text = _format_current_bait_slot("bait_2")

	return "ТЕКУЩАЯ СНАСТЬ\nУдочка: %s\nЛеска: %s | Поводок: %s | Поплавок: %s\nКрючок: %s | Наживка 1: %s | Наживка 2: %s\nГлубина %.1f м | Состояние: уд.%d%% / леска %d%% / пов.%d%% / крючок %d%%\n%s" % [
		PlayerData.current_tackle.get("rod", {}).get("name", "-"),
		PlayerData.current_tackle.get("line", {}).get("name", "-"),
		PlayerData.current_tackle.get("leader", {}).get("name", "-"),
		PlayerData.current_tackle.get("float", {}).get("name", "-"),
		PlayerData.current_tackle.get("hook", {}).get("name", "-"),
		_format_current_bait_slot("bait"),
		bait_2_text,
		PlayerData.fishing_depth,
		roundi(PlayerData.get_tackle_condition("rod") * 100.0),
		roundi(PlayerData.get_tackle_condition("line") * 100.0),
		roundi(PlayerData.get_tackle_condition("leader") * 100.0),
		roundi(PlayerData.get_tackle_condition("hook") * 100.0),
		_get_tackle_setup_status_inline()
	]

func _format_current_bait_slot(slot_id: String) -> String:
	var current: Dictionary = PlayerData.current_tackle.get(slot_id, {})
	if str(current.get("id", "")) == "":
		return "не установлена"
	var name := str(current.get("name", "-"))
	var quantity := PlayerData.get_current_bait_quantity(slot_id)
	if quantity <= 0:
		return "%s x0 — закончилась" % name
	return "%s x%d" % [name, quantity]

func _get_current_tackle_inventory_text_legacy() -> String:
	return "СЕЙЧАС НАДЕТО В СБОРКЕ\nУдочка: %s\nЛеска: %s  |  Поплавок: %s\nКрючок: %s  |  Наживка: %s x%d\nГлубина %.1f м  |  Состояние: уд.%d%% / леска %d%% / крючок %d%%\n%s" % [
		PlayerData.current_tackle.get("rod", {}).get("name", "-"),
		PlayerData.current_tackle.get("line", {}).get("name", "-"),
		PlayerData.current_tackle.get("float", {}).get("name", "-"),
		PlayerData.current_tackle.get("hook", {}).get("name", "-"),
		PlayerData.current_tackle.get("bait", {}).get("name", "-"),
		PlayerData.get_current_bait_quantity(),
		PlayerData.fishing_depth,
		roundi(PlayerData.get_tackle_condition("rod") * 100.0),
		roundi(PlayerData.get_tackle_condition("line") * 100.0),
		roundi(PlayerData.get_tackle_condition("hook") * 100.0),
		_get_tackle_setup_status_inline()
	]


func _get_tackle_build_summary_text() -> String:
	return _get_current_tackle_inventory_text()

func _get_tackle_build_summary_text_legacy() -> String:
	return "СЕЙЧАС НАДЕТО В СБОРКЕ\nУдочка: %s\nЛеска: %s  |  Поплавок: %s\nКрючок: %s  |  Наживка: %s x%d\nГлубина %.1f м  |  Состояние: уд.%d%% / леска %d%% / крючок %d%%\n%s" % [
		PlayerData.current_tackle.get("rod", {}).get("name", "-"),
		PlayerData.current_tackle.get("line", {}).get("name", "-"),
		PlayerData.current_tackle.get("float", {}).get("name", "-"),
		PlayerData.current_tackle.get("hook", {}).get("name", "-"),
		PlayerData.current_tackle.get("bait", {}).get("name", "-"),
		PlayerData.get_current_bait_quantity(),
		PlayerData.fishing_depth,
		roundi(PlayerData.get_tackle_condition("rod") * 100.0),
		roundi(PlayerData.get_tackle_condition("line") * 100.0),
		roundi(PlayerData.get_tackle_condition("hook") * 100.0),
		_get_tackle_setup_status_inline()
	]


func _get_tackle_setup_status_inline() -> String:
	var issues: Array = PlayerData.get_tackle_setup_issues()
	if issues.is_empty():
		return "Статус: сборка готова."

	return "Проблемы: %s" % "; ".join(issues)


func _is_inventory_item_equipped(item: Dictionary) -> bool:
	var category := str(item.get("category", ""))
	if not PlayerData.current_tackle.has(category):
		return false

	return str(PlayerData.current_tackle[category].get("id", "")) == str(item.get("id", ""))


func _get_inventory_category_title(category: String) -> String:
	match category:
		"all":
			return "Все"
		"rod":
			return "Удилища"
		"line":
			return "Лески и поводки"
		"leader":
			return "Поводки"
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


func _set_inventory_category(category: String) -> void:
	main._inventory_category = category
	main._inventory_page = 0
	main._selected_inventory_item_id = ""
	_update_inventory_ui()


func _on_inventory_item_selected(index: int) -> void:
	var item_index: int = main._inventory_page * INVENTORY_ITEMS_PER_PAGE + index
	if item_index < 0 or item_index >= main._visible_inventory_items.size():
		main._selected_inventory_item_id = ""
	else:
		main._selected_inventory_item_id = str(main._visible_inventory_items[item_index].get("id", ""))

	_update_inventory_ui()


func _on_inventory_tile_pressed(item_id: String) -> void:
	main._selected_inventory_item_id = item_id
	_update_inventory_ui()


func _on_inventory_tiles_scroll_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	if str(main._selected_inventory_item_id) == "":
		return
	var local_pos: Vector2 = main.inventory_tiles_container.get_local_mouse_position()
	for child in main.inventory_tiles_container.get_children():
		if child is Control and Rect2(child.position, child.size).has_point(local_pos):
			return
	main._selected_inventory_item_id = ""
	_update_inventory_ui()


func _on_inventory_detail_close_pressed() -> void:
	main._selected_inventory_item_id = ""
	_update_inventory_ui()


func _on_inventory_prev_page_pressed() -> void:
	if main._inventory_page <= 0:
		return

	main._inventory_page -= 1
	main._selected_inventory_item_id = ""
	_update_inventory_ui()


func _on_inventory_next_page_pressed() -> void:
	var total_count: int = _get_visible_inventory_items().size()
	var page_count: int = max(ceili(float(total_count) / float(INVENTORY_ITEMS_PER_PAGE)), 1)
	if main._inventory_page >= page_count - 1:
		return

	main._inventory_page += 1
	main._selected_inventory_item_id = ""
	_update_inventory_ui()
