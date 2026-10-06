# Copyright © 2026, jurgfish. All rights reserved.

extends Control

signal request(id, status, data)

@export var _resume_button: Button
@export var _invert_cam_v: Button
@export var _invert_cam_h: Button

@export var _user: Node3D

##################################################################################################

func _format_bool(flag: bool) -> String:
	return "on" if flag else "off"

func _set_invert_cam_v(flag: bool) -> void:
	_invert_cam_v.text = _format_bool(flag)

func _set_invert_cam_h(flag: bool) -> void:
	_invert_cam_h.text = _format_bool(flag)

##################################################################################################

func pause(flag) -> void:
	if flag:
		visible = true
		_resume_button.grab_focus()
	else:
		visible = false

##################################################################################################

func _ready() -> void:
	pause(false)
	connect("request", Callable(Service, "_on_service_request"))

	_set_invert_cam_v(States.user.invert_cam_v)
	_set_invert_cam_h(States.user.invert_cam_h)

##################################################################################################

func _on_resume_pressed() -> void:
	emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.PAUSE, false)

func _on_abandon_pressed() -> void:
	emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.QUIT)

##################################################################################################

func _on_invert_cam_v_pressed() -> void:
	_set_invert_cam_v(!States.user.invert_cam_v)
	_user.set_invert_cam_v(!States.user.invert_cam_v)
	_invert_cam_v.grab_focus()

func _on_invert_cam_h_pressed() -> void:
	_set_invert_cam_h(!States.user.invert_cam_h)
	_user.set_invert_cam_h(!States.user.invert_cam_h)
	_invert_cam_h.grab_focus()

##################################################################################################
