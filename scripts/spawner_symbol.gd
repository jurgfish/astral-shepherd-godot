# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

const SYMBOL = preload("uid://b8qqhyewwc2jk")

##################################################################################################

func _spawn_symbol(symbol_id: States.SYMBOL) -> void:
	var symbol := SYMBOL.instantiate()
	add_child(symbol)
	symbol.set_symbol(symbol_id)
	var pos_x: float = randf_range(-States.SPAWN_BOUND, States.SPAWN_BOUND)
	var pos_z: float = randf_range(-States.SPAWN_BOUND, States.SPAWN_BOUND)
	symbol.set_location(Vector3(pos_x, 0.0, pos_z))

func spawn(count: int) -> void:
	for idx in count:
		_spawn_symbol(States.SYMBOL.STAR)

##################################################################################################
