extends Node3D

@export_group("Motion")
@export var default_reel_speed := 8.0
@export var max_reel_speed := 12.0
@export var rotor_axis := Vector3(0.0, 0.0, 1.0)
@export var handle_axis := Vector3(1.0, 0.0, 0.0)
@export var knob_axis := Vector3(1.0, 0.0, 0.0)
@export var rotor_speed_multiplier := 0.0
@export var handle_speed_multiplier := 1.0
@export var knob_speed_multiplier := 1.35
@export var rotation_direction := 1.0
@export var animate_knob := false
@export var animate_spool := false
@export var manual_update_only := true
@export var auto_start := false

@export_group("Model")
@export var model_rotation_degrees := Vector3(0.0, 180.0, 0.0)

@export_group("Handle")
@export var handle_rotation_offset_degrees := Vector3.ZERO
@export var handle_pivot_offset := Vector3.ZERO
@export var handle_visibility_scale := 1.14
@export var knob_visibility_scale := 1.08

@export_group("Camera")
@export var camera_offset := Vector3(0.04, 0.02, 2.4)
@export var camera_rotation_degrees := Vector3.ZERO
@export var camera_orthographic_size := 0.28
@export var camera_near := 0.02
@export var camera_far := 8.0
@export_group("")

const BODY_NODE_NAME := "Body_low"
const ROTOR_NODE_NAME := "Rotor_low"
const HANDLE_NODE_NAME := "Handle_low"
const HANDLE_SMALL_NODE_NAME := "Handle_small_low"
const KNOB_NODE_NAME := "Knob_low"
const SPOOL_NODE_NAME := "Spool_low"
const MODEL_ROOT_NODE_NAME := "Kat001Model"
const CAMERA_NODE_NAME := "Camera3D"

var _model_root: Node3D
var _body_node: Node3D
var _rotor_node: Node3D
var _handle_node: Node3D
var _handle_small_node: Node3D
var _handle_pivot: Node3D
var _knob_node: Node3D
var _spool_node: Node3D
var _camera_node: Camera3D
var _reel_speed := 0.0
var _is_reeling := false
var _missing_warnings: Dictionary = {}


func _ready() -> void:
	_cache_reel_nodes()
	_apply_model_orientation()
	_setup_handle_pivot()
	_apply_static_visual_config()
	_apply_camera_config()
	set_process(false)
	if auto_start:
		start_reel()


func _process(delta: float) -> void:
	_advance_reel(delta)


func set_reel_speed(value: float) -> void:
	_reel_speed = clampf(absf(value), 0.0, maxf(max_reel_speed, 0.0))
	_is_reeling = absf(_reel_speed) > 0.001
	set_process(_is_reeling and not manual_update_only)


func start_reel() -> void:
	_is_reeling = true
	if absf(_reel_speed) <= 0.001:
		_reel_speed = clampf(default_reel_speed, 0.0, maxf(max_reel_speed, 0.0))
	set_process(not manual_update_only)


func stop_reel() -> void:
	_is_reeling = false
	_reel_speed = 0.0
	set_process(false)


func advance_reel(delta: float) -> void:
	_advance_reel(delta)


func set_visible_reel(value: bool) -> void:
	visible = value
	if not value:
		stop_reel()


func _advance_reel(delta: float) -> void:
	if not _is_reeling:
		return
	if absf(_reel_speed) <= 0.001:
		return

	var angular_delta := _reel_speed * delta * rotation_direction
	_rotate_part(_rotor_node, rotor_axis, angular_delta * rotor_speed_multiplier)
	_rotate_part(_handle_pivot if _handle_pivot != null else _handle_node, handle_axis, angular_delta * handle_speed_multiplier)
	if animate_knob:
		_rotate_part(_knob_node, knob_axis, angular_delta * knob_speed_multiplier)
	if animate_spool:
		_rotate_part(_spool_node, rotor_axis, angular_delta * rotor_speed_multiplier * 0.35)


func _cache_reel_nodes() -> void:
	_model_root = get_node_or_null(MODEL_ROOT_NODE_NAME) as Node3D
	_body_node = _find_part(BODY_NODE_NAME)
	_rotor_node = _find_part(ROTOR_NODE_NAME)
	_handle_node = _find_part(HANDLE_NODE_NAME)
	_handle_small_node = _find_part(HANDLE_SMALL_NODE_NAME)
	_knob_node = _find_part(KNOB_NODE_NAME)
	_spool_node = _find_part(SPOOL_NODE_NAME)
	_camera_node = _find_part(CAMERA_NODE_NAME) as Camera3D


func _find_part(part_name: String) -> Node3D:
	var found := _find_node3d_recursive(self, part_name)
	if found == null:
		_warn_missing_part(part_name)
	return found


func _find_node3d_recursive(root: Node, target_name: String) -> Node3D:
	if root.name == target_name and root is Node3D:
		return root as Node3D

	for child in root.get_children():
		var found := _find_node3d_recursive(child, target_name)
		if found != null:
			return found

	return null


func _setup_handle_pivot() -> void:
	if _handle_node == null:
		return
	if _handle_pivot != null and is_instance_valid(_handle_pivot):
		return

	var parent := _handle_node.get_parent()
	if parent == null:
		return

	var handle_global_transform := _handle_node.global_transform
	_handle_pivot = Node3D.new()
	_handle_pivot.name = "HandlePivot"
	parent.add_child(_handle_pivot)
	_handle_pivot.global_transform = Transform3D(Basis.IDENTITY, handle_global_transform.origin + handle_pivot_offset)
	_handle_node.reparent(_handle_pivot, true)
	_handle_node.rotation_degrees += handle_rotation_offset_degrees


func _apply_model_orientation() -> void:
	if _model_root == null:
		return
	_model_root.rotation_degrees = model_rotation_degrees


func _apply_static_visual_config() -> void:
	_set_tree_visible(self)
	_boost_node_scale(_handle_node, handle_visibility_scale)
	_boost_node_scale(_handle_small_node, handle_visibility_scale)
	_boost_node_scale(_knob_node, knob_visibility_scale)
	_set_visual_layers(self, 1)
	_disable_light_shadows(self)


func _apply_camera_config() -> void:
	if _camera_node == null:
		return
	_camera_node.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera_node.position = camera_offset
	_camera_node.rotation_degrees = camera_rotation_degrees
	_camera_node.size = maxf(camera_orthographic_size, 0.05)
	_camera_node.near = maxf(camera_near, 0.001)
	_camera_node.far = maxf(camera_far, _camera_node.near + 0.1)
	_camera_node.cull_mask = 1
	_camera_node.current = true


func _boost_node_scale(node: Node3D, factor: float) -> void:
	if node == null:
		return
	node.visible = true
	var safe_factor := maxf(factor, 0.01)
	node.scale = Vector3(
		maxf(node.scale.x, 0.001) * safe_factor,
		maxf(node.scale.y, 0.001) * safe_factor,
		maxf(node.scale.z, 0.001) * safe_factor
	)


func _set_tree_visible(root: Node) -> void:
	if root is Node3D:
		(root as Node3D).visible = true
	for child in root.get_children():
		_set_tree_visible(child)


func _set_visual_layers(root: Node, layers: int) -> void:
	if root is VisualInstance3D:
		(root as VisualInstance3D).layers = layers
	for child in root.get_children():
		_set_visual_layers(child, layers)


func _disable_light_shadows(root: Node) -> void:
	if root is Light3D:
		(root as Light3D).shadow_enabled = false
	for child in root.get_children():
		_disable_light_shadows(child)


func _rotate_part(part: Node3D, axis: Vector3, angle: float) -> void:
	if part == null:
		return
	if axis.length_squared() <= 0.0001:
		return
	part.rotate_object_local(axis.normalized(), angle)


func _warn_missing_part(part_name: String) -> void:
	if _missing_warnings.has(part_name):
		return
	_missing_warnings[part_name] = true
	push_warning("ReelKat001: GLB part '%s' was not found." % part_name)
