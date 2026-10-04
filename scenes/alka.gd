# Copyright © 2026, jurgfish. All rights reserved.

extends CharacterBody3D

var _in_dir: Vector2 = Vector2.ZERO
var _dir: Vector3 = Vector3.ZERO
var _speed: float = 10.0 # TODO: smooth

const MIN_LOOK_Y: float = -PI
const MAX_LOOK_Y: float = PI
const MOUSE_MULT: float = 0.1
var _in_look: Vector2 = Vector2.ZERO
var _look: Vector2 = Vector2.ZERO
var _look_sy: float = 0.005

@export var _head: Marker3D

##################################################################################################

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_in_look.x += -event.screen_relative.x * _look_sy * MOUSE_MULT
		_in_look.y += -event.screen_relative.y * _look_sy * MOUSE_MULT

func _process(_delta: float) -> void:
	_in_look -= Input.get_vector("look_left", "look_right", "look_up", "look_down") * _look_sy

	_look.x = clampf(_look.x + _in_look.y, MIN_LOOK_Y, MAX_LOOK_Y)
	_look.y = _in_look.x

	_head.rotation.x = _look.x
	rotation.y = _look.y

	_look = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	_in_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	_dir = (transform.basis * Vector3(_in_dir.x, 0.0, _in_dir.y)).normalized()

	velocity.x = _dir.x * _speed
	velocity.z = _dir.z * _speed
	velocity.y = 0.0

	move_and_slide()

##################################################################################################
