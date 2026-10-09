# Copyright © 2026, jurgfish. All rights reserved.

class_name Played
extends CharacterBody3D

const HEAD_ROT_LIMIT: float = 2.2
const HELMET_ROT_LIMIT: float = 1.6
const LERP_H: float = 10.0

var _symbol_id: States.SYMBOL = States.SYMBOL.NULL
var _target: Node3D = null

@export var _target_tracker: Marker3D
@export var _symbol_tri: MeshInstance3D
@export var _head: Marker3D
@export var _helmet: MeshInstance3D
@export var _helmet_visor: MeshInstance3D

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

func _ready() -> void:
	_helmet_visor.visible = false

func _physics_process(delta: float) -> void:
	if _target != null:
		_target_tracker.look_at(_target.get_target(), Vector3.UP, true)
		if abs(_target_tracker.rotation.y - rotation.y) < HEAD_ROT_LIMIT:
			_head.rotation = lerp(_head.rotation, _target_tracker.rotation, LERP_H * delta)
			_helmet.rotation.y = clamp(_head.rotation.y, -HELMET_ROT_LIMIT, HELMET_ROT_LIMIT)

##################################################################################################

func _on_area_detect_body_entered(_body: Node3D) -> void:
	pass # Replace with function body.

func _on_area_detect_body_exited(_body: Node3D) -> void:
	pass # Replace with function body.

##################################################################################################
