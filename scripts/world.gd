# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

@export var _load_hud: Control
@export var _pause_hud: Control
@export var _user: Node3D
@export var _alka: CharacterBody3D

@export var _spawner_symbol: Node3D
@export var _spawner_allias: Node3D

##################################################################################################

func _initialize() -> void:
	get_tree().set_auto_accept_quit(false)
	get_tree().paused = false # for game reload

	Service.initialize()
	_alka.set_init_distance(States.SPAWN_BOUND)

	if not States.DEBUG_MODE & States.DEBUG.SKIP_LOAD_SPLASH:
		await _load_hud.play_load()

func _start() -> void:
	if States.DEBUG_MODE & States.DEBUG.ENABLED:
		print("\nHELLO WORLD")

	_spawner_symbol.spawn(States.ALLIAS_COUNT)
	_spawner_allias.spawn(States.ALLIAS_COUNT)

	_spawner_allias.set_target_look(_alka)
	_spawner_allias.set_visors(false)
	_spawner_allias.align_rotation_to_target()

	#await get_tree().create_timer(10.0).timeout
	#_spawner_allias.set_target_navigation(_alka)

	#await get_tree().create_timer(5.0).timeout
	#_spawner_allias.set_target_navigation(null)
	#await get_tree().create_timer(5.0).timeout
	#_spawner_allias.set_target_look(null)

	while true:
		_spawner_allias.set_random_symbols_target_navigation()
		await get_tree().create_timer(20.0).timeout

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
