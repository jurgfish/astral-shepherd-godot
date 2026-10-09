# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

const IDLE_SPEED: float = 0.8
const COLLECT_SPEED: float = 8.8
const APPROACH_SPEED: Vector3 = Vector3(0.0, 0.0, -1.0)

var _symbol_id: States.SYMBOL = States.SYMBOL.NULL
var _target: Node3D = null
var _player_detected: bool = false
var _player_collecting: bool = false

@export var _symbol_gimbal: Marker3D
@export var _symbol_star: MeshInstance3D
@export var _symbol_tri: MeshInstance3D

##################################################################################################

func set_symbol(flag: States.SYMBOL) -> void:
	_symbol_star.visible = flag == States.SYMBOL.STAR
	_symbol_tri.visible = flag == States.SYMBOL.TRI
	_symbol_id = flag

func get_symbol() -> States.SYMBOL:
	return _symbol_id

func set_location(pos: Vector3) -> void:
	global_transform.origin = pos

##################################################################################################

func _physics_process(delta: float) -> void:
	if _target != null:
		look_at(_target.get_head(), Vector3.UP)
		if _player_collecting:
			_symbol_gimbal.rotate_object_local(Vector3.FORWARD, COLLECT_SPEED * delta)
			translate_object_local(APPROACH_SPEED * delta)
	else:
		rotate_x(IDLE_SPEED * delta)
		rotate_y(IDLE_SPEED * delta)
		rotate_z(IDLE_SPEED * delta)

##################################################################################################

func _on_area_detect_body_entered(body: Node3D) -> void:
	if body is Player:
		_player_detected = true
		_target = body

func _on_area_detect_body_exited(body: Node3D) -> void:
	if body is Player:
		_player_detected = false
		_target = null

func _on_area_collect_body_entered(body: Node3D) -> void:
	if body is Player:
		_player_collecting = true

func _on_area_collect_body_exited(body: Node3D) -> void:
	if body is Player:
		_player_collecting = false
		_symbol_gimbal.rotation = Vector3.ZERO

func _on_area_capture_body_entered(body: Node3D) -> void:
	if body is Player:
		queue_free()

##################################################################################################
