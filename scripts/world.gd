# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

@export var _load_hud: Control
@export var _pause_hud: Control
@export var _user: Node3D
@export var _alka: CharacterBody3D

@export var _symbol_spawner: Node3D
@export var _allias_spawner: Node3D

##################################################################################################

func _initialize() -> void:
	get_tree().set_auto_accept_quit(false)
	get_tree().paused = false # for game reload

	Service.initialize()
	if not States.DEBUG_MODE & States.DEBUG.SKIP_LOAD_SPLASH:
		await _load_hud.play_load()

func _start() -> void:
	if States.DEBUG_MODE & States.DEBUG.ENABLED:
		print("\nHELLO WORLD")

	_symbol_spawner.spawn()
	_allias_spawner.spawn()

	_allias_spawner.set_target(_alka)

##################################################################################################

func pause(flag: bool) -> void:
	if States.DEBUG_MODE & States.DEBUG.ENABLED:
		print("PAUSED: %s" % flag)

	_pause_hud.pause(flag)
	_load_hud.pause(flag)
	_user.pause(flag)
	get_tree().paused = flag

func quit() -> void:
	if States.DEBUG_MODE & States.DEBUG.ENABLED:
		print("GOODBYE WORLD\n")

	_pause_hud.quit()
	_load_hud.quit()
	get_tree().quit()

##################################################################################################

# GAME STARUP SEQUENCE

func _ready() -> void:
	await _initialize()
	_start()

##################################################################################################
