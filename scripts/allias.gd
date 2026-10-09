# Copyright © 2026, jurgfish. All rights reserved.

class_name Played
extends CharacterBody3D

var _symbol_id: States.SYMBOL = States.SYMBOL.NULL
var _target: Node3D = null

@export var _symbol_tri: MeshInstance3D
@export var _head: Marker3D
@export var _helmet: MeshInstance3D
#@export var _helmet_visor: MeshInstance3D

##################################################################################################

func set_symbol(flag: States.SYMBOL) -> void:
	_symbol_tri.visible = flag == States.SYMBOL.TRI
	_symbol_id = flag

func set_location(pos: Vector3) -> void:
	global_transform.origin = pos

func set_target(body: Node3D) -> void:
	_target = body

func get_target() -> Vector3:
	return _head.get_global_transform_interpolated().origin

##################################################################################################

func _physics_process(_delta: float) -> void:
	if _target != null:
		_head.look_at(_target.get_target(), Vector3.UP, true)
		_helmet.rotation.y = _head.rotation.y

##################################################################################################

func _on_area_detect_body_entered(_body: Node3D) -> void:
	pass # Replace with function body.

func _on_area_detect_body_exited(_body: Node3D) -> void:
	pass # Replace with function body.

##################################################################################################
