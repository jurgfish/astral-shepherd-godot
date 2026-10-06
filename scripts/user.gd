# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

signal request(id, status, data)

##################################################################################################

func set_invert_cam_v(flag: bool, set_state: bool = true) -> void:
	if set_state:
		States.user.invert_cam_v = flag
		if States.DEBUG_MODE & States.DEBUG.USER:
			print("INVERT CAM V SET: %s" % flag)

	# TODO: move user input to user.gd

func set_invert_cam_h(flag: bool, set_state: bool = true) -> void:
	if set_state:
		States.user.invert_cam_h = flag
		if States.DEBUG_MODE & States.DEBUG.USER:
			print("INVERT CAM H SET: %s" % flag)

	# TODO: move user input to user.gd

##################################################################################################

func pause(flag: bool) -> void:
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

func _input(event) -> void:
	if event.is_action_pressed("pause"):
		emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.PAUSE, !get_tree().paused)
		get_viewport().set_input_as_handled()

##################################################################################################
