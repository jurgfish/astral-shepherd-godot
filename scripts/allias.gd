# Copyright © 2026, jurgfish. All rights reserved.

class_name Played
extends CharacterBody3D

const HEAD_ROT_LIMIT: float = 2.2
const HELMET_ROT_LIMIT: float = 1.6
const LERP_H: float = 10.0
const LERP_R: float = 2.0
const WALK_S: float = 0.2
const RUN_S: float = 1.5

var _symbol_id: States.SYMBOL = States.SYMBOL.NULL
var _target_look: Node3D = null
var _next_pos: Vector3 = Vector3.ZERO
var _offset_pos: Vector3 = Vector3.ZERO
var _dir: Vector3 = Vector3.ZERO
var _speed: float = 0.0
var _target_nav: Node3D = null
var _updated_rot: float = 0.0
var _curr_rot: float = 0.0
var _symbol_captured: bool = false
var _chasing: bool = false

@export var _nav_arm: Marker3D
@export var _nav: NavigationAgent3D
@export var _target_tracker: Marker3D
@export var _symbol_moon: MeshInstance3D
@export var _symbol_tri: MeshInstance3D
@export var _symbol_circle: MeshInstance3D
@export var _symbol_flower: MeshInstance3D
@export var _symbol_prop: MeshInstance3D
@export var _symbol_plus: MeshInstance3D
@export var _symbol_astral: MeshInstance3D
@export var _symbol_diamond: MeshInstance3D
@export var _symbol_apostrophe: MeshInstance3D
@export var _symbol_therefore: MeshInstance3D
@export var _symbol_hexagon: MeshInstance3D
@export var _head: Marker3D
@export var _helmet: MeshInstance3D
@export var _suit: MeshInstance3D
@export var _anim_effects: AnimationPlayer

##################################################################################################

func open_visor(flag: bool) -> void:
	if flag:
		_anim_effects.play("open_visor")
	else:
		_anim_effects.play_backwards("open_visor")

func set_location(pos: Vector3) -> void:
	global_transform.origin = pos

func align_rotation_to_target() -> void:
	_target_tracker.look_at(_target_look.get_target(), Vector3.UP, true)
	rotation.y = _target_tracker.rotation.y
	_updated_rot = rotation.y
	_curr_rot = _updated_rot

func set_target_look(body: Node3D) -> void:
	_target_look = body
	if _target_look == null:
		_target_tracker.rotation.y = 0.0

func get_target() -> Vector3:
	return _head.get_global_transform_interpolated().origin

func set_target_navigation(body: Node3D) -> void:
	if _symbol_captured:
		body = null
	_target_nav = body

func set_chasing(flag: bool, body: Node3D) -> void:
	if _symbol_captured:
		flag = false
		body = null
	_target_nav = body
	_chasing = flag

func is_chasing() -> bool:
	return _chasing

func is_dormant() -> bool:
	return _symbol_captured

##################################################################################################

func set_symbol(flag: States.SYMBOL) -> void:
	if flag == States.SYMBOL.STAR:
		push_error("ALLIAS: set symbol (star) invalid")
		return
	_symbol_moon.visible = flag == States.SYMBOL.MOON
	_symbol_tri.visible = flag == States.SYMBOL.TRI
	_symbol_circle.visible = flag == States.SYMBOL.CIRCLE
	_symbol_flower.visible = flag == States.SYMBOL.FLOWER
	_symbol_prop.visible = flag == States.SYMBOL.PROP
	_symbol_plus.visible = flag == States.SYMBOL.PLUS
	_symbol_astral.visible = flag == States.SYMBOL.ASTRAL
	_symbol_diamond.visible = flag == States.SYMBOL.DIAMOND
	_symbol_apostrophe.visible = flag == States.SYMBOL.APOSTROPHE
	_symbol_therefore.visible = flag == States.SYMBOL.THEREFORE
	_symbol_hexagon.visible = flag == States.SYMBOL.HEXAGON
	_symbol_id = flag

func get_symbol() -> States.SYMBOL:
	return _symbol_id

func capture_symbol(symbol: States.SYMBOL) -> void:
	if symbol != _symbol_id:
		push_error("ALLIAS INVALID SYMBOL CAPTURE")
		return

	_symbol_captured = true
	set_target_navigation(null)
	set_target_look(null)
	open_visor(false)

	if States.DEBUG_MODE & States.DEBUG.DELIVERY:
		prints("ALLIAS SYMBOL CAPTURED:", _symbol_id)

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
		_dir.y = 0.0
		_speed = RUN_S if _chasing else WALK_S

		_updated_rot = Vector3.MODEL_FRONT.signed_angle_to(_dir, Vector3.UP)
		if not is_equal_approx(_curr_rot, _updated_rot):
			_curr_rot = lerp_angle(_curr_rot, _updated_rot, LERP_R * delta)

		velocity = _speed * _dir
		rotation.y = _curr_rot

		move_and_slide()

##################################################################################################

func _on_area_detect_body_entered(_body: Node3D) -> void:
	pass # Replace with function body.

func _on_area_detect_body_exited(_body: Node3D) -> void:
	pass # Replace with function body.

##################################################################################################
