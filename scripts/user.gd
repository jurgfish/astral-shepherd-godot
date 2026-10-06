# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

signal request(id, status, data)

##################################################################################################

func pause(flag: bool) -> void:
	if flag:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

##################################################################################################

func _input(event) -> void:
	if event.is_action_pressed("pause"):
		emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.PAUSE, !get_tree().paused)
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.QUIT)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#Engine.max_fps = 30

	connect("request", Callable(Service, "_on_service_request"))

##################################################################################################
