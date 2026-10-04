# Copyright © 2026, jurgfish. All rights reserved.

extends CharacterBody3D

var _in_dir: Vector2 = Vector2.ZERO
var _dir: Vector3 = Vector3.ZERO
var _speed: float = 10.0 # TODO: smooth

const MIN_LOOK_Y: float = -PI
const MAX_LOOK_Y: float = PI
var _in_look: Vector2 = Vector2.ZERO
var _look: Vector2 = Vector2.ZERO
var _look_sy: float = 0.005

@export var _head: Marker3D

##################################################################################################

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_in_look.x += -event.screen_relative.x * _look_sy
		_in_look.y += -event.screen_relative.y * _look_sy

func _process(_delta: float) -> void:
	_look.x = clampf(_look.x + _in_look.y, MIN_LOOK_Y, MAX_LOOK_Y)
	_look.y = _in_look.x

	_head.rotation.x = _look.x
	rotation.y = _look.y

	_look = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	_in_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_dir = (transform.basis * Vector3(_in_dir.x, 0.0, _in_dir.y)).normalized()

	velocity.x = _dir.x * _speed
	velocity.z = _dir.z * _speed
	velocity.y = 0.0

	move_and_slide()

##################################################################################################
