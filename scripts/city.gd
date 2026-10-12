# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

const ALKA_SPAWN_BOUND: float = 28.0
const SYMBOL_SPAWN_BOUND: float = 8.0
const ALLIAS_SPAWN_BOUND: float = 5.0

@export var _alka: CharacterBody3D
@export var _spawner_symbol: Node3D
@export var _spawner_allias: Node3D

##################################################################################################

func initialize() -> void:
	_spawner_symbol.spawn(States.ALLIAS_SYMBOLS.size(), SYMBOL_SPAWN_BOUND)
	_spawner_allias.spawn(States.ALLIAS_SYMBOLS.size(), ALLIAS_SPAWN_BOUND)
	_spawner_allias.set_target_look(_alka)
	_spawner_allias.set_visors(false)
	_alka.set_location(Vector3(0.0, 0.0, ALKA_SPAWN_BOUND))

func begin_routine() -> void:
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
