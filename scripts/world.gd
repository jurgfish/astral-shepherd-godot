# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

@export var _pause_hud: Control
@export var _user: Node3D

##################################################################################################

func _initialize() -> void:
	get_tree().set_auto_accept_quit(false)
	get_tree().paused = false # for game reload

	Service.initialize()

func _start() -> void:
	if States.DEBUG_MODE & States.DEBUG.ENABLED:
		print("\nHELLO WORLD")

##################################################################################################

func pause(flag: bool) -> void:
	if States.DEBUG_MODE & States.DEBUG.ENABLED:
		print("PAUSED: %s" % flag)

	_pause_hud.pause(flag)
	_user.pause(flag)
	get_tree().paused = flag

func quit() -> void:
	get_tree().quit()

##################################################################################################

func _ready() -> void:
	_initialize()

##################################################################################################
