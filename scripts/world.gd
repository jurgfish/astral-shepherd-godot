# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

@export var _load_hud: Control
@export var _city: Node3D

##################################################################################################

func _initialize() -> void:
	Service.initialize()
	_city.initialize()

	if not States.DEBUG_MODE & States.DEBUG.SKIP_LOAD_SPLASH:
		_load_hud.play_load()
	else:
		Service.set_status(States.STATUS.READY)

func _start() -> void:
	if not States.DEBUG_MODE & States.DEBUG.SKIP_EPIGRAPH:
		_load_hud.play_epigraph()
		await Service.wait_for_status(States.STATUS.INTRO)
	else:
		Service.set_status(States.STATUS.INTRO)

	await Service.wait_for_status(States.STATUS.RUNNING)
	_city.begin_routine()

##################################################################################################

# GAME STARUP SEQUENCE

func _ready() -> void:
	_initialize()
	await Service.wait_for_status(States.STATUS.READY)
	_start()

##################################################################################################
