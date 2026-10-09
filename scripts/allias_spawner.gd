# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

const ALLIAS = preload("uid://cbmg7ps1h673y")

##################################################################################################

func set_target(body: Node3D) -> void:
	for child in get_children():
		child.set_target(body)

func spawn() -> void:
	var allias := ALLIAS.instantiate()
	add_child(allias)
	allias.set_symbol(States.SYMBOL.TRI)
	allias.set_location(Vector3(0.0, 0.0, -3.0))

##################################################################################################
