# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

const ALKA_SPAWN_BOUND: float = 38.0
const SYMBOL_SPAWN_BOUND: float = 8.0
const ALLIAS_SPAWN_BOUND: float = 5.0
const ALKA_SYMBOL_SPAWN_LOC: Vector3 = Vector3(0.0, 5.0, 25.0)

var _spawn_count: int = States.ALLIAS_SYMBOLS.size()

@export var _alka: CharacterBody3D
@export var _spawner_symbol: Node3D
@export var _spawner_allias: Node3D
@export var _exits: Node3D

##################################################################################################

# GENERAL

func open_exits(flag: bool) -> void:
	for exit in _exits.get_children():
		exit.open_door(flag)

func get_spawn_count() -> int:
	return _spawn_count

##################################################################################################

# SYMBOLS

func spawn_symbol(symbol: States.SYMBOL) -> void:
	_spawner_symbol.spawn_symbol(symbol, SYMBOL_SPAWN_BOUND)

##################################################################################################

# ALLIAS

func capture_symbol(symbol: States.SYMBOL) -> int:
	return _spawner_allias.capture_symbol(symbol)

func open_allias_visors(flag: bool) -> void:
	_spawner_allias.open_visors(flag)

func set_chasing(symbol: States.SYMBOL, flag: bool, body: Node3D) -> void:
	_spawner_allias.set_chasing(symbol, flag, body)

func reset_random_navigation() -> void:
	_spawner_allias.set_random_symbols_target_navigation()

func get_allias_capture_count() -> int:
	return _spawner_allias.get_capture_count()

##################################################################################################

func initialize() -> void:
	if States.DEBUG_MODE & States.DEBUG.CUSTOM_SPAWN_COUNT:
		_spawn_count = States.DEBUG_SPAWN_COUNT

	_spawner_allias.spawn(_spawn_count, ALLIAS_SPAWN_BOUND)
	_spawner_allias.set_target_look(_alka)
	_alka.set_location(Vector3(0.0, 0.0, ALKA_SPAWN_BOUND))

	var alka_symbol: Node3D = _spawner_symbol.spawn_symbol(States.SYMBOL.STAR, SYMBOL_SPAWN_BOUND)
	alka_symbol.set_location(ALKA_SYMBOL_SPAWN_LOC, true)

func begin_routine() -> void:
	_spawner_allias.open_visors(true)
	_spawner_symbol.spawn(_spawn_count, SYMBOL_SPAWN_BOUND)
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

func end_routine() -> void:
	_spawner_allias.despawn_all()

##################################################################################################
