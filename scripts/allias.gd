# Copyright © 2026, jurgfish. All rights reserved.

class_name Played
extends CharacterBody3D

const HEAD_ROT_LIMIT: float = 2.2
const HELMET_ROT_LIMIT: float = 1.6
const LERP_H: float = 10.0
const LERP_R: float = 2.0
const SPEED: float = 0.2

var _symbol_id: States.SYMBOL = States.SYMBOL.NULL
var _target_look: Node3D = null
var _next_pos: Vector3 = Vector3.ZERO
var _offset_pos: Vector3 = Vector3.ZERO
var _dir: Vector3 = Vector3.ZERO
var _target_nav: Node3D = null
var _updated_rot: float = 0.0
var _curr_rot: float = 0.0

@export var _nav_arm: Marker3D
@export var _nav: NavigationAgent3D
@export var _target_tracker: Marker3D
@export var _symbol_tri: MeshInstance3D
@export var _head: Marker3D
@export var _helmet: MeshInstance3D
@export var _helmet_visor: MeshInstance3D
@export var _suit: MeshInstance3D

##################################################################################################

func set_visor(flag: bool) -> void:
	_helmet_visor.visible = flag

func set_symbol(flag: States.SYMBOL) -> void:
	_symbol_tri.visible = flag == States.SYMBOL.TRI
	_symbol_id = flag

func set_location(pos: Vector3) -> void:
	global_transform.origin = pos

func align_rotation_to_target() -> void:
	_target_tracker.look_at(_target_look.get_target(), Vector3.UP, true)
	rotation.y = _target_tracker.rotation.y
	_updated_rot = rotation.y
	_curr_rot = _updated_rot

func set_target_look(body: Node3D) -> void:
	_target_look = body

func get_target() -> Vector3:
	return _head.get_global_transform_interpolated().origin

func set_target_navigation(body: Node3D) -> void:
	_target_nav = body

##################################################################################################

func _physics_process(delta: float) -> void:
	if _target_look != null:
		_target_tracker.look_at(_target_look.get_target(), Vector3.UP, true)
		if abs(_target_tracker.rotation.y - _suit.rotation.y) < HEAD_ROT_LIMIT:
			_head.rotation = lerp(_head.rotation, _target_tracker.rotation, LERP_H * delta)
			_helmet.rotation.y = clamp(_head.rotation.y, -HELMET_ROT_LIMIT, HELMET_ROT_LIMIT)

	if _target_nav != null:
		_nav.target_position = _target_nav.get_global_transform_interpolated().origin
		_next_pos = _nav.get_next_path_position()
		_offset_pos = _nav_arm.position
		_dir = global_position.direction_to(_next_pos - _offset_pos)
		velocity = SPEED * _dir

		_updated_rot = Vector3.MODEL_FRONT.signed_angle_to(_dir, Vector3.UP)
		if not is_equal_approx(_curr_rot, _updated_rot):
			_curr_rot = lerp_angle(_curr_rot, _updated_rot, LERP_R * delta)
		rotation.y = _curr_rot

		move_and_slide()

##################################################################################################

func _on_area_detect_body_entered(_body: Node3D) -> void:
	pass # Replace with function body.

func _on_area_detect_body_exited(_body: Node3D) -> void:
	pass # Replace with function body.

##################################################################################################
