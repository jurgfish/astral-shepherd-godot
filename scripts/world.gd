# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

##################################################################################################

func _debug_initialize() -> void:
	if OS.is_debug_build():
		if States.DEBUG_MODE & States.DEBUG.DISABLED:
			States.DEBUG_MODE = States.DEBUG.DISABLED

		print("--------------------------------------------------------------------------------")
		print_rich("[b]%s[/b] by [b]%s <3[/b] v%s d%s" % [
				States.GAME_NAME, States.GAME_AUTHOR, States.GAME_VERSION, States.DEBUG_MODE])
		print("--------------------------------------------------------------------------------")

	else:
		States.DEBUG_MODE = States.DEBUG.DISABLED

##################################################################################################

func _initialize_game() -> void:
	get_tree().set_auto_accept_quit(false)
	get_tree().paused = false # for game reload

	_debug_initialize()

func _start_game() -> void:
	if States.DEBUG_MODE & States.DEBUG.ENABLED:
		print("\nHELLO WORLD")

##################################################################################################

func _on_pause_requested(flag: bool) -> void:
	if States.DEBUG_MODE & States.DEBUG.ENABLED:
		print("PAUSED: %s" % flag)

	get_tree().paused = flag

func _on_quit_requested() -> void:
	get_tree().quit()

##################################################################################################

func _ready() -> void:
	_initialize_game()

##################################################################################################
