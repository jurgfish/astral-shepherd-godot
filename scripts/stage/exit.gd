# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

signal delivery(status, data)

var _req_open: bool = false
var _door_open: bool = false

@export var _light: OmniLight3D
@export var _anim: AnimationPlayer

##################################################################################################

func open_door(flag: bool) -> void:
	_req_open = flag
	if _anim.is_playing():
		await _anim.animation_finished
	if not _door_open and _req_open:
		_light.visible = true
		_anim.play("open_door")
		await _anim.animation_finished
		_door_open = true
	elif _door_open and not _req_open:
		_anim.play_backwards("toggle")
		await _anim.animation_finished
		_door_open = false
		_light.visible = false

##################################################################################################

func _ready() -> void:
	_light.visible = false
	connect("delivery", Callable(Service, "_on_delivery_request"))

##################################################################################################

func _on_area_detect_body_entered(body: Node3D) -> void:
	if body is Player:
		emit_signal("delivery", States.DELIVERY.CLOCKOUT)

##################################################################################################
