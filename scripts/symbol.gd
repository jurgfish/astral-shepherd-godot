# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

const IDLE_S: float = 1.8
const COLLECT_S: float = 8.8
const APPROACH_S: Vector3 = Vector3(0.0, 0.0, 1.0)
const FLOAT_S: float = 0.8
const SKY_HEIGHT: float = 5.0
const SKY_MAX: float = 8.0

var _symbol_id: States.SYMBOL = States.SYMBOL.NULL
var _target: Node3D = null
var _player_detected: bool = false
var _player_collecting: bool = false
var _on_screen: bool = false
var _sky_home: Vector3 = Vector3.ZERO
var _idle_speed: float = 0.0

@export var _symbol_gimbal: Marker3D
@export var _symbol_star: MeshInstance3D
@export var _symbol_tri: MeshInstance3D
@export var _awareness: Marker3D

##################################################################################################

func set_symbol(flag: States.SYMBOL) -> void:
	_symbol_star.visible = flag == States.SYMBOL.STAR
	_symbol_tri.visible = flag == States.SYMBOL.TRI
	_symbol_id = flag

func get_symbol() -> States.SYMBOL:
	return _symbol_id

func set_location(pos: Vector3) -> void:
	_sky_home = Vector3(pos.x, SKY_HEIGHT + (SKY_MAX * randf()), pos.z)
	global_transform.origin = _sky_home

func get_target() -> Vector3:
	return get_global_transform_interpolated().origin

##################################################################################################

func _physics_process(delta: float) -> void:
	if _target != null:
		look_at(_target.get_target(), Vector3.UP, true)
		if _player_collecting and _on_screen:
			_symbol_gimbal.rotate_object_local(Vector3.FORWARD, COLLECT_S * delta)
			translate_object_local(APPROACH_S * delta)
	else:
		rotate_x(_idle_speed * delta)
		rotate_y(_idle_speed * delta)
		rotate_z(_idle_speed * delta)
		global_transform.origin = global_transform.origin.move_toward(_sky_home, FLOAT_S * delta)

	_awareness.global_transform.origin = global_transform.origin

func _ready() -> void:
	rotation.x = randf_range(-PI, PI)
	rotation.y = randf_range(-PI, PI)
	rotation.z = randf_range(-PI, PI)
	_idle_speed = randf_range(-IDLE_S, IDLE_S)

##################################################################################################

func _on_screen_notifier_screen_entered() -> void:
	_on_screen = true

func _on_screen_notifier_screen_exited() -> void:
	_on_screen = false

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
