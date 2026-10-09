# Copyright © 2026, jurgfish. All rights reserved.

class_name Player
extends CharacterBody3D

# look
const MIN_PITCH: float = -1.2
const MAX_PITCH: float = 1.2
var _look_dir: Vector2 = Vector2.ZERO

# head bob
const HEAD_HEIGHT: float = 1.8
const BOB_FRQ: float = 12.0
const BOB_AMP_MAX: float = 0.012
var _bob_builder: float = 0.0
var _bob_amp: float = 0.0
var _bob_weight: float = 0.0

# move
const MAX_SPEED: float = 2.0
const LERP_V: float = 18.0
var _move_dir: Vector3 = Vector3.ZERO
var _speed: float = 0.0

@export var _head: Marker3D
@export var _body: Marker3D
@export var _headlamps: Marker3D

##################################################################################################

func update_look(in_look: Vector2) -> void:
	_look_dir += in_look
	_look_dir.y = clampf(_look_dir.y, MIN_PITCH, MAX_PITCH)

func update_move(in_move: Vector2) -> void:
	_speed = MAX_SPEED * in_move.length()
	_move_dir = (transform.basis * Vector3(in_move.x, 0.0, in_move.y)).normalized()
	_move_dir = _move_dir.rotated(Vector3(0, 1, 0), _look_dir.x)

func get_head() -> Vector3:
	return _head.global_transform.origin

##################################################################################################

func _process(delta: float) -> void:
	_head.rotation.x = _look_dir.y # pitch
	_head.rotation.y = _look_dir.x # yaw

	_bob_weight = velocity.length() / MAX_SPEED
	_bob_builder += _bob_weight * delta
	_bob_amp = BOB_AMP_MAX * _bob_weight
	_head.transform.origin.y = sin(_bob_builder * BOB_FRQ) * _bob_amp + HEAD_HEIGHT

func _physics_process(delta: float) -> void:
	_body.rotation.y = _look_dir.x
	velocity = lerp(velocity, _move_dir * _speed, LERP_V * delta)
	_headlamps.rotation.x = _look_dir.y
	move_and_slide()

##################################################################################################
