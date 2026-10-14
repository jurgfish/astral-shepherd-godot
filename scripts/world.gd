# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

@export var _load_hud: Control
@export var _pause_hud: Control
@export var _game_hud: Control
@export var _user: Node3D
@export var _city: Node3D

##################################################################################################

func _initialize() -> void:
	get_tree().set_auto_accept_quit(false)
	get_tree().paused = false # for game reload

	Service.initialize()
	_city.initialize()

	if not States.DEBUG_MODE & States.DEBUG.SKIP_LOAD_SPLASH:
		_load_hud.play_load()
	else:
		Service.set_status(States.STATUS.INTRO)

func _start() -> void:
	# TODO: handle skip intro logic here
	_city.begin_routine()
	_game_hud.fade_in(true)

	Service.set_status(States.STATUS.RUNNING)

##################################################################################################

func pause(flag: bool) -> void:
	_pause_hud.pause(flag)
	_load_hud.pause(flag)
	_user.pause(flag)
	_game_hud.fade_in(!flag)
	get_tree().paused = flag

func quit() -> void:
	Service.set_status(States.STATUS.SHUTDOWN)
	get_tree().paused = true
	_game_hud.fade_in(false)
	_pause_hud.quit()
	_load_hud.quit()
	get_tree().quit()

##################################################################################################

# GAME STARUP SEQUENCE

func _ready() -> void:
	_initialize()

	await Service.wait_for_status(States.STATUS.INTRO)
	_start()

##################################################################################################
