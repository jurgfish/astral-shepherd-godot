# Copyright © 2026, jurgfish. All rights reserved.

extends Control

signal request(id, status, data)

@export var _resume_button: Button

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

##################################################################################################

func _on_resume_pressed() -> void:
	emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.PAUSE, false)

func _on_abandon_ship_pressed() -> void:
	emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.QUIT)

##################################################################################################
