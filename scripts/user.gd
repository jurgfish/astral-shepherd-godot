# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

signal pause_requested(flag: bool)
signal quit_requested()

##################################################################################################

func _pause_game(flag: bool) -> void:
	pause_requested.emit(flag)
	if flag:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _quit_game() -> void:
	quit_requested.emit()

##################################################################################################

func _input(event) -> void:
	if event.is_action_pressed("pause"):
		_pause_game(!get_tree().paused)
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_quit_game()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#Engine.max_fps = 30

##################################################################################################
