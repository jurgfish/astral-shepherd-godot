# Copyright © 2026, jurgfish. All rights reserved.

class_name Player
extends CharacterBody3D

signal delivery(status, data)

# look
const MIN_PITCH: float = -1.2
const MAX_PITCH: float = 1.2
var _look_dir: Vector2 = Vector2.ZERO

# head bob
const HEAD_HEIGHT: float = 1.8
const BOB_FRQ: float = 12.0
const BOB_AMP_MAX: float = 0.012
var _bob_builder: float = 0.0
var _bob_amp: float = 0.0
var _bob_weight: float = 0.0

# move
const MAX_SPEED: float = 2.0
const LERP_V: float = 18.0
var _move_dir: Vector3 = Vector3.ZERO
var _speed: float = 0.0
var _captured_symbols: Array = []

var _capturing_count: int = 0
var _captured_count: int = 0

@export var _head: Marker3D
@export var _body: Marker3D
@export var _headlamps: Marker3D
@export var _anim_effects: AnimationPlayer

##################################################################################################

func _flicker_headlamps(flag: bool, captured: bool = false) -> void:
	if flag:
		if not captured:
			_anim_effects.play("flicker_headlamps_capturing")
		else:
			_anim_effects.play("flicker_headlamps_captured")
	else:
		_anim_effects.play("RESET_HEADLAMPS")

func _count_allias_capturing(increment: bool) -> void:
	if increment:
		_capturing_count += 1
		_flicker_headlamps(true)
	else:
		_capturing_count -= 1
		if _capturing_count <= 0:
			_capturing_count = 0
			_flicker_headlamps(false)

func _count_allias_captured(increment: bool) -> void:
	if increment:
		_captured_count += 1
		_flicker_headlamps(true, true)
	else:
		_captured_count -= 1
		if _captured_count <= 0:
			_captured_count = 0
			if _capturing_count > 0:
				_flicker_headlamps(true, false)
			else:
				_flicker_headlamps(false)

##################################################################################################

func update_look(in_look: Vector2) -> void:
	_look_dir += in_look
	_look_dir.y = clampf(_look_dir.y, MIN_PITCH, MAX_PITCH)

func update_move(in_move: Vector2) -> void:
	_speed = MAX_SPEED * in_move.length()
	_move_dir = (transform.basis * Vector3(in_move.x, 0.0, in_move.y)).normalized()
	_move_dir = _move_dir.rotated(Vector3(0, 1, 0), _look_dir.x)

func get_target() -> Vector3:
	return _headlamps.get_global_transform_interpolated().origin

func set_location(pos: Vector3) -> void:
	global_transform.origin = pos

##################################################################################################

func get_symbol_count() -> int:
	return _captured_symbols.size()

func capture_symbol(symbol: States.SYMBOL) -> int:
	_captured_symbols.push_back(symbol)

	if States.DEBUG_MODE & States.DEBUG.DELIVERY:
		prints("ALKA SYMBOLS (CAPTURE):", _captured_symbols)

	return get_symbol_count()

func release_symbol(symbol: States.SYMBOL = States.SYMBOL.NULL) -> Array:
	var erased: States.SYMBOL = States.SYMBOL.NULL

	if not _captured_symbols.is_empty():
		if symbol == States.SYMBOL.NULL:
			erased = _captured_symbols.pop_front()
		else:
			_captured_symbols.erase(symbol)
			erased = symbol

	if States.DEBUG_MODE & States.DEBUG.DELIVERY:
		prints("ALKA SYMBOLS (RELEASE):", _captured_symbols)

	return [get_symbol_count(), erased]

##################################################################################################

func _ready() -> void:
	connect("delivery", Callable(Service, "_on_delivery_request"))

func _process(delta: float) -> void:
	_head.rotation.x = _look_dir.y # pitch
	_head.rotation.y = _look_dir.x # yaw

	_bob_weight = velocity.length() / MAX_SPEED
	_bob_builder += _bob_weight * delta
	_bob_amp = BOB_AMP_MAX * _bob_weight
	_head.transform.origin.y = sin(_bob_builder * BOB_FRQ) * _bob_amp + HEAD_HEIGHT

func _physics_process(delta: float) -> void:
	_body.rotation.y = _look_dir.x
	velocity = lerp(velocity, _move_dir * _speed, LERP_V * delta)
	_headlamps.rotation.x = _look_dir.y
	move_and_slide()

##################################################################################################

func _on_area_capturing_body_entered(body: Node3D) -> void:
	if body is Played:
		if not body.is_dormant():
			_count_allias_capturing(true)

func _on_area_capturing_body_exited(body: Node3D) -> void:
	if body is Played:
		_count_allias_capturing(false)

func _on_area_captured_body_entered(body: Node3D) -> void:
	if body is Played:
		if not body.is_dormant():
			_count_allias_captured(true)
			emit_signal("delivery", States.DELIVERY.RELEASE, body)

func _on_area_captured_body_exited(body: Node3D) -> void:
	if body is Played:
		_count_allias_captured(false)

##################################################################################################
