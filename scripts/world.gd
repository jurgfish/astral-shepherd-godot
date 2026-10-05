# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

##################################################################################################

func _initialize_game() -> void:
	get_tree().set_auto_accept_quit(false)
	get_tree().paused = false # for game reload

	Service.debug_initialize()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#Engine.max_fps = 30

func _start_game() -> void:
	pass

func quit_game() -> void:
	get_tree().quit()

##################################################################################################

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()

func _ready() -> void:
	_initialize_game()

##################################################################################################
