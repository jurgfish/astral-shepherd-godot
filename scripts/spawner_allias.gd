# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

const ALLIAS = preload("uid://cbmg7ps1h673y")

var _allias_list: Array = []

@export var _spawner_symbol: Node3D

##################################################################################################

func _spawn_allias(symbol_id: States.SYMBOL) -> void:
	var allias := ALLIAS.instantiate()
	add_child(allias)
	var pos_x: float = randf_range(-States.SPAWN_BOUND, States.SPAWN_BOUND)
	var pos_z: float = randf_range(-States.SPAWN_BOUND, States.SPAWN_BOUND)
	allias.set_location(Vector3(pos_x, 0.0, pos_z))
	allias.set_symbol(symbol_id)

func _retrieve_symbol_list() -> Array:
	var symbol_list: Array = _spawner_symbol.get_symbol_list()
	if _allias_list.size() != symbol_list.size():
		push_error("ALLIAS SPAWNER: mismatched symbol/allias counts")
	return symbol_list

##################################################################################################

func set_target_look(body: Node3D) -> void:
	for child in _allias_list:
		child.set_target_look(body)

func set_random_symbols_target_look() -> void:
	var symbol_list: Array = _retrieve_symbol_list()
	symbol_list.shuffle()

	for idx in _allias_list.size():
		_allias_list[idx].set_target_look(symbol_list[idx])

func set_visors(flag: bool) -> void:
	for child in _allias_list:
		child.set_visor(flag)

func align_rotation_to_target() -> void:
	for child in _allias_list:
		child.align_rotation_to_target()

func set_target_navigation(body: Node3D) -> void:
	for child in _allias_list:
		child.set_target_navigation(body)

func set_random_symbols_target_navigation() -> void:
	var symbol_list: Array = _retrieve_symbol_list()
	symbol_list.shuffle()

	for idx in _allias_list.size():
		_allias_list[idx].set_target_navigation(symbol_list[idx])

func spawn(count: int) -> void:
	for idx in count:
		_spawn_allias(States.SYMBOL.TRI)
	_allias_list = get_children()

##################################################################################################
