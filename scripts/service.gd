# Copyright © 2026, jurgfish. All rights reserved.

# core signal bus

extends Node

var _world: Node3D = null

##################################################################################################

func _debug_initialize() -> void:
	if OS.is_debug_build():
		if States.DEBUG_MODE & States.DEBUG.DISABLED:
			States.DEBUG_MODE = States.DEBUG.DISABLED

		print("--------------------------------------------------------------------------------")
		print_rich("[b]%s[/b] by [b]%s <3[/b] v%s d%s" % [
				States.GAME_NAME, States.GAME_AUTHOR, States.GAME_VERSION, States.DEBUG_MODE])
		print("--------------------------------------------------------------------------------")

	else:
		States.DEBUG_MODE = States.DEBUG.DISABLED

##################################################################################################

func _request_world(id: String, data: Array) -> void:
	if data[0] == States.WORLD.QUIT:
		_world.quit()
	elif len(data) > 1:
		if data[0] == States.WORLD.PAUSE:
			_world.pause(data[1])
	else:
		push_warning("SERVICE REQUEST INVALID: WORLD %s, %s" % [id, data])

##################################################################################################

func initialize() -> void:
	_debug_initialize()
	_world = get_tree().get_root().get_node("world")

##################################################################################################

func _on_service_request(id: String, status: int, ...data: Array) -> void:
	if States.DEBUG_MODE & States.DEBUG.SERVICE:
		print("SERVICE REQUEST: %s, %s, %s" % [id, status, data])

	if status == States.REQUEST.WORLD:
		_request_world(id, data)
	else:
		push_warning("SERVICE REQUEST INVALID: %s, %s, %s" % [id, status, data])

##################################################################################################
