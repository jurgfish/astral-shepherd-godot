# Copyright © 2026, jurgfish. All rights reserved.

extends Area3D

@export var symbol_star: MeshInstance3D
@export var symbol_tri: MeshInstance3D

##################################################################################################

func set_symbol(flag: States.SYMBOL) -> void:
	symbol_star.visible = flag == States.SYMBOL.STAR
	symbol_tri.visible = flag == States.SYMBOL.TRI

func set_location(pos: Vector3) -> void:
	global_transform.origin = pos

##################################################################################################
