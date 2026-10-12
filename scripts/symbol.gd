# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

signal delivery(status, data)

const IDLE_S: float = 1.8
const CAPTURE_S: float = 8.8
const APPROACH_S: Vector3 = Vector3(0.0, 0.0, 1.0)
const FLOAT_S: float = 0.8
const SKY_HEIGHT: float = 5.0
const SKY_MAX: float = 8.0

var _symbol_id: States.SYMBOL = States.SYMBOL.NULL
var _target: Node3D = null
var _player_detected: bool = false
var _player_capturing: bool = false
var _on_screen: bool = false
var _sky_home: Vector3 = Vector3.ZERO
var _idle_speed: float = 0.0
var _captured: bool = false

@export var _symbol_gimbal: Marker3D
@export var _symbol_star: MeshInstance3D
@export var _symbol_moon: MeshInstance3D
@export var _symbol_tri: MeshInstance3D
@export var _symbol_circle: MeshInstance3D
@export var _symbol_flower: MeshInstance3D
@export var _symbol_prop: MeshInstance3D
@export var _symbol_plus: MeshInstance3D
@export var _symbol_astral: MeshInstance3D
@export var _symbol_diamond: MeshInstance3D
@export var _symbol_apostrophe: MeshInstance3D
@export var _symbol_therefore: MeshInstance3D
@export var _symbol_hexagon: MeshInstance3D
@export var _awareness: Marker3D

##################################################################################################

func set_symbol(flag: States.SYMBOL) -> void:
	_symbol_star.visible = flag == States.SYMBOL.STAR
	_symbol_moon.visible = flag == States.SYMBOL.MOON
	_symbol_tri.visible = flag == States.SYMBOL.TRI
	_symbol_circle.visible = flag == States.SYMBOL.CIRCLE
	_symbol_flower.visible = flag == States.SYMBOL.FLOWER
	_symbol_prop.visible = flag == States.SYMBOL.PROP
	_symbol_plus.visible = flag == States.SYMBOL.PLUS
	_symbol_astral.visible = flag == States.SYMBOL.ASTRAL
	_symbol_diamond.visible = flag == States.SYMBOL.DIAMOND
	_symbol_apostrophe.visible = flag == States.SYMBOL.APOSTROPHE
	_symbol_therefore.visible = flag == States.SYMBOL.THEREFORE
	_symbol_hexagon.visible = flag == States.SYMBOL.HEXAGON
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
		if _player_capturing and _on_screen:
			_symbol_gimbal.rotate_object_local(Vector3.FORWARD, CAPTURE_S * delta)
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

	connect("delivery", Callable(Service, "_on_delivery_request"))

##################################################################################################

func _on_screen_notifier_screen_entered() -> void:
	_on_screen = true

func _on_screen_notifier_screen_exited() -> void:
	_on_screen = false

func _on_area_detect_body_entered(body: Node3D) -> void:
	if _captured:
		return
	if body is Player:
		_player_detected = true
		_target = body

func _on_area_detect_body_exited(body: Node3D) -> void:
	if _captured:
		return
	if body is Player:
		_player_detected = false
		_target = null

func _on_area_capturing_body_entered(body: Node3D) -> void:
	if _captured:
		return
	if body is Player:
		_player_capturing = true
		emit_signal("delivery", States.DELIVERY.CAPTURING, _target, _symbol_id)

func _on_area_capturing_body_exited(body: Node3D) -> void:
	if _captured:
		return
	if body is Player:
		_player_capturing = false
		_symbol_gimbal.rotation = Vector3.ZERO
		emit_signal("delivery", States.DELIVERY.CANCEL, _target, _symbol_id)

func _on_area_captured_body_entered(body: Node3D) -> void:
	if body is Player:
		_captured = true
		emit_signal("delivery", States.DELIVERY.CAPTURED, _target, _symbol_id)
		queue_free()

##################################################################################################
