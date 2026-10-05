# Copyright © 2026, jurgfish. All rights reserved.

extends CharacterBody3D

# look
const MIN_PITCH: float = -PI
const MAX_PITCH: float = PI
const MOUSE_MULT: float = 0.0005
var _in_look: Vector2 = Vector2.ZERO
var _look_sy: float = 1.8

const HEAD_HEIGHT: float = 1.8
const BOB_FRQ: float = 2.0
const BOB_AMP: float = 0.05
var _bob_builder: float = 0.0

# move
const MAX_SPEED: float = 5.0
const LERP_V: float = 8.0
var _in_dir: Vector2 = Vector2.ZERO
var _dir: Vector3 = Vector3.ZERO
var _speed: float = 0.0

@export var _head: Marker3D

##################################################################################################

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_in_look.x -= event.screen_relative.x * _look_sy * MOUSE_MULT
		_in_look.y -= event.screen_relative.y * _look_sy * MOUSE_MULT

func _process(delta: float) -> void:
	_in_look -= Input.get_vector("LOOK_L", "LOOK_R", "LOOK_U", "LOOK_D") * _look_sy * delta

	_head.rotation.x = clampf(_in_look.y, MIN_PITCH, MAX_PITCH) # pitch
	_head.rotation.y = _in_look.x # yaw

	_bob_builder += delta * velocity.length()
	_head.transform.origin.y = sin(_bob_builder * BOB_FRQ) * BOB_AMP + HEAD_HEIGHT

func _physics_process(delta: float) -> void:
	_in_dir = Input.get_vector("MOVE_L", "MOVE_R", "MOVE_F", "MOVE_B")
	_dir = (transform.basis * Vector3(_in_dir.x, 0.0, _in_dir.y)).normalized()
	_dir = _dir.rotated(Vector3(0, 1, 0), _in_look.x)

	_speed = MAX_SPEED * _in_dir.length()
	velocity = lerp(velocity, _dir * _speed, LERP_V * delta)
	move_and_slide()

##################################################################################################
