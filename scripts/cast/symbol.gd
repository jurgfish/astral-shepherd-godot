# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

signal delivery(status, data)

const PARTICLES_SPARKLES = preload("uid://bhmsmjcv4dtup")
const IDLE_R: float = 1.8
const CAPTURE_R: float = 8.8
const APPROACH_S: Vector3 = Vector3(0.0, 0.0, 1.1)
const FLOAT_S: float = 0.8
const SKY_HEIGHT: float = 5.0
const SKY_MAX: float = 8.0

var _symbol_id: States.SYMBOL = States.SYMBOL.NULL
var _target: Node3D = null
var _player_detected: bool = false
var _player_capturing: bool = false
var _player_capturable: bool = false
var _on_screen: bool = false
var _sky_home: Vector3 = Vector3.ZERO
var _idle_speed: float = 0.0
var _captured: bool = false

@export var _symbol_gimbal: Marker3D
@export var _awareness: Marker3D

##################################################################################################

func _instance_sparkles() -> void:
	var sparkles := PARTICLES_SPARKLES.instantiate()
	get_parent().get_parent().add_child(sparkles)
	sparkles.global_transform = get_global_transform_interpolated()
	sparkles.emit_particles()

func _set_capturing(flag: bool, body: Node3D) -> void:
	_player_capturing = flag
	if _player_capturing:
		emit_signal("delivery", States.DELIVERY.CAPTURING, body, _symbol_id)
	else:
		_symbol_gimbal.rotation = Vector3.ZERO
		emit_signal("delivery", States.DELIVERY.CANCEL, body, _symbol_id)

func _set_captured(body: Node3D) -> void:
	_captured = true
	_instance_sparkles()
	emit_signal("delivery", States.DELIVERY.CAPTURED, body, _symbol_id)
	queue_free()

##################################################################################################

func set_symbol(flag: States.SYMBOL) -> void:
	for symbol in _symbol_gimbal.get_children():
		symbol.visible = States.SYMBOL_DICT[symbol.name] == flag
	_symbol_id = flag

func get_symbol() -> States.SYMBOL:
	return _symbol_id

func set_location(pos: Vector3, override_y: bool = false) -> void:
	if not override_y:
		_sky_home = Vector3(pos.x, SKY_HEIGHT + (SKY_MAX * randf()), pos.z)
	else:
		_sky_home = pos
	global_transform.origin = _sky_home

func get_target() -> Vector3:
	return get_global_transform_interpolated().origin

##################################################################################################

func _physics_process(delta: float) -> void:
	if _target != null:
		look_at(_target.get_target(), Vector3.UP, true)
		if _player_capturing and _on_screen:
			_symbol_gimbal.rotate_object_local(Vector3.FORWARD, CAPTURE_R * delta)
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
	_idle_speed = randf_range(-IDLE_R, IDLE_R)

	connect("delivery", Callable(Service, "_on_delivery_request"))

##################################################################################################

func _on_screen_notifier_screen_entered() -> void:
	if _captured:
		return
	_on_screen = true
	if _player_capturable and _target is Player:
		_set_capturing(true, _target)

func _on_screen_notifier_screen_exited() -> void:
	if _captured:
		return
	_on_screen = false
	if _player_capturing and _target is Player:
		_set_capturing(false, _target)

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
		_player_capturable = true
		if _on_screen:
			_set_capturing(true, body)

func _on_area_capturing_body_exited(body: Node3D) -> void:
	if _captured:
		return
	if body is Player:
		_player_capturable = false
		_set_capturing(false, body)

func _on_area_captured_body_entered(body: Node3D) -> void:
	if _captured:
		return
	if body is Player or (body is Played and body.get_symbol() == _symbol_id):
		_set_captured(body)

##################################################################################################
