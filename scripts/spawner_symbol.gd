# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

const SYMBOL = preload("uid://b8qqhyewwc2jk")

##################################################################################################

func spawn_symbol(symbol_id: States.SYMBOL, spawn_bound: float) -> void:
	if symbol_id == States.SYMBOL.NULL:
		return

	var symbol := SYMBOL.instantiate()
	add_child(symbol)
	symbol.set_symbol(symbol_id)
	var pos_x: float = randf_range(-spawn_bound, spawn_bound)
	var pos_z: float = randf_range(-spawn_bound, spawn_bound)
	symbol.set_location(Vector3(pos_x, 0.0, pos_z))

# param: count [int] max State.ALLIAS_SYMBOLS size
# note: spawned allias symbols should match spawned symbols
func spawn(count: int, spawn_bound: float) -> void:
	count = min(count, States.ALLIAS_SYMBOLS.size())
	for idx in count:
		spawn_symbol(States.ALLIAS_SYMBOLS[idx], spawn_bound)

func get_symbol_list() -> Array:
	return get_children()

##################################################################################################
