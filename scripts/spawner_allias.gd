# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

const ALLIAS = preload("uid://cbmg7ps1h673y")

##################################################################################################

func _spawn_allias(symbol_id: States.SYMBOL) -> void:
	var allias := ALLIAS.instantiate()
	add_child(allias)
	var pos_x: float = randf_range(-States.SPAWN_BOUND, States.SPAWN_BOUND)
	var pos_z: float = randf_range(-States.SPAWN_BOUND, States.SPAWN_BOUND)
	allias.set_location(Vector3(pos_x, 0.0, pos_z))
	allias.set_symbol(symbol_id)

##################################################################################################

func set_target(body: Node3D) -> void:
	for child in get_children():
		child.set_target(body)

func set_visors(flag: bool) -> void:
	for child in get_children():
		child.set_visor(flag)

func spawn(count: int) -> void:
	for idx in count:
		_spawn_allias(States.SYMBOL.STAR)

##################################################################################################
