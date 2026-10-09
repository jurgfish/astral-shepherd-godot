# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

const SYMBOL = preload("uid://b8qqhyewwc2jk")

##################################################################################################

func spawn() -> void:
	var symbol := SYMBOL.instantiate()
	add_child(symbol)
	symbol.set_symbol(States.SYMBOL.STAR)
	symbol.set_location(Vector3(0.0, 3.0, 0.0))

##################################################################################################
