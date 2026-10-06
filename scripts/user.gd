# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

signal request(id, status, data)

const MOUSE_MULT: float = 0.0005
var _invert_look: Vector2 = Vector2.ONE
var _in_look: Vector2 = Vector2.ZERO
var _look_sy: float = 1.8
var _in_move: Vector2 = Vector2.ZERO
var _accepting_input: bool = true

@export var _alka: CharacterBody3D

##################################################################################################

func set_invert_cam_v(flag: bool, set_state: bool = true) -> void:
	var prev_state: bool = States.user.invert_cam_v
	if set_state:
		States.user.invert_cam_v = flag
		if States.DEBUG_MODE & States.DEBUG.USER:
			print("INVERT CAM V SET: %s" % flag)

	_invert_look.y = -1.0 if flag else 1.0
	_in_look.y *= -1.0 if prev_state != flag else 1.0

func set_invert_cam_h(flag: bool, set_state: bool = true) -> void:
	var prev_state: bool = States.user.invert_cam_h
	if set_state:
		States.user.invert_cam_h = flag
		if States.DEBUG_MODE & States.DEBUG.USER:
			print("INVERT CAM H SET: %s" % flag)

	_invert_look.x = -1.0 if flag else 1.0
	_in_look.x *= -1.0 if prev_state != flag else 1.0

##################################################################################################

func pause(flag: bool) -> void:
	_accepting_input = !flag
	if flag:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

##################################################################################################

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	connect("request", Callable(Service, "_on_service_request"))

	set_invert_cam_v(States.user.invert_cam_v, false)
	set_invert_cam_h(States.user.invert_cam_h, false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.QUIT)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.PAUSE, !get_tree().paused)
		get_viewport().set_input_as_handled()

	if _accepting_input:
		if event is InputEventMouseMotion:
			_in_look.x -= event.screen_relative.x * MOUSE_MULT
			_in_look.y -= event.screen_relative.y * MOUSE_MULT

func _process(delta: float) -> void:
	if _accepting_input:
		_in_look -= Input.get_vector("LOOK_L", "LOOK_R", "LOOK_U", "LOOK_D") * delta
		_in_move = Input.get_vector("MOVE_L", "MOVE_R", "MOVE_F", "MOVE_B")
		_alka.set_inputs(_in_look * _look_sy * _invert_look, _in_move)

##################################################################################################
