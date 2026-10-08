# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

signal request(id, status, data)

const BASE_SETTING: float = 1.0 # slider range: 0.0 to 2.0 (increments 0.01)
const MOUSE_MULT: float = 0.0005
const MIN_SY: float = 0.1 # sensitivity
const BASE_SY: float = 1.8
const MAX_SY: float = 5.0
var _invert_look: Vector2 = Vector2.ONE
var _in_look: Vector2 = Vector2.ZERO
var _look_sy: float = 1.8
var _accepting_input: bool = true

@export var _alka: CharacterBody3D
@export var _pause_hud: Control

##################################################################################################

func _convert_lerp(low: float, base: float, high: float, req: float) -> float:
	if req < BASE_SETTING:
		return lerp(low, base, req)
	elif req > BASE_SETTING:
		return lerp(base, high, req - BASE_SETTING)
	else:
		return base

##################################################################################################

func set_sensitivity(req_lerp: float, states_flag: bool = true) -> void:
	if states_flag:
		States.user.sensitivity = req_lerp
		if States.DEBUG_MODE & States.DEBUG.USER:
			print("SENSITIVITY SET: %s" % req_lerp)
	_look_sy = _convert_lerp(MIN_SY, BASE_SY, MAX_SY, req_lerp)

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

func set_volume(value: float, states_flag: bool = true) -> void:
	if states_flag:
		States.user.volume = value
		if States.DEBUG_MODE & States.DEBUG.USER:
			print("VOLUME SET: %s" % value)
	# TODO: volume controls

func set_frame_rate(rate: int, states_flag: bool = true) -> void:
	if states_flag:
		States.user.frame_rate = rate
		if States.DEBUG_MODE & States.DEBUG.USER:
			print("FRAME RATE SET: %s" % rate)
	Engine.max_fps = rate

func _calculate_fullscreen() -> int:
	return wrapi(States.user.fullscreen + 1, 0, 2)

func set_fullscreen(status: int, states_flag: bool = true) -> void:
	if states_flag:
		States.user.fullscreen = status
		if States.DEBUG_MODE & States.DEBUG.USER:
			print("FULLSCREEN SET: %s" % status)

	if status == 0: # fullscreen on (exclusive)
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	elif status == 1: # fullscreen off
		get_window().mode = Window.MODE_WINDOWED
	elif status == 2: # off: maximized
		get_window().mode = Window.MODE_MAXIMIZED
	elif status == 3: # on: non-exclusive
		get_window().mode = Window.MODE_FULLSCREEN

func set_vsync(enabled: bool, states_flag: bool = true) -> void:
	if states_flag:
		States.user.vsync = enabled
		if States.DEBUG_MODE & States.DEBUG.USER:
			print("VSYNC SET: %s" % enabled)
	# TODO: replace with VSYNC_ADAPTIVE when POP_OS updates
	var vsync_mode := DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(vsync_mode)

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

	set_sensitivity(States.user.sensitivity, false)
	set_invert_cam_v(States.user.invert_cam_v, false)
	set_invert_cam_h(States.user.invert_cam_h, false)
	set_volume(States.user.volume, false)
	set_frame_rate(States.user.frame_rate, false)
	set_fullscreen(States.user.fullscreen, false)
	set_vsync(States.user.fullscreen, false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.QUIT)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PAUSE"):
		emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.PAUSE, !get_tree().paused)
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("FULLSCREEN_TOGGLE"):
		var fullscreen_status = _calculate_fullscreen()
		set_fullscreen(fullscreen_status)
		_pause_hud.set_fullscreen(fullscreen_status)

	elif _accepting_input:
		if event is InputEventMouseMotion:
			_in_look.x = -event.screen_relative.x * MOUSE_MULT
			_in_look.y = -event.screen_relative.y * MOUSE_MULT
			_alka.update_look(_in_look * _look_sy * _invert_look)

func _process(delta: float) -> void:
	if _accepting_input:
		_in_look = Input.get_vector("LOOK_L", "LOOK_R", "LOOK_U", "LOOK_D") * delta
		_alka.update_look(_in_look * _look_sy * _invert_look)
		_alka.update_move(Input.get_vector("MOVE_L", "MOVE_R", "MOVE_F", "MOVE_B"))

##################################################################################################
