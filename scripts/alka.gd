# Copyright © 2026, jurgfish. All rights reserved.

extends CharacterBody3D

var _in_dir: Vector2 = Vector2.ZERO
var _dir: Vector3 = Vector3.ZERO
var _speed: float = 10.0 # TODO: smooth

const MIN_PITCH: float = -PI
const MAX_PITCH: float = PI
const MOUSE_MULT: float = 0.0005
var _in_look: Vector2 = Vector2.ZERO
var _look_sy: float = 1.8

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

func _physics_process(_delta: float) -> void:
	_in_dir = Input.get_vector("MOVE_L", "MOVE_R", "MOVE_F", "MOVE_B")
	_dir = (transform.basis * Vector3(_in_dir.x, 0.0, _in_dir.y)).normalized()
	_dir = _dir.rotated(Vector3(0, 1, 0), _in_look.x)

	velocity = _dir * _speed
	move_and_slide()

##################################################################################################
