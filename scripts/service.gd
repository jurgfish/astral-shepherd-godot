# Copyright © 2026, jurgfish. All rights reserved.

# core signal bus

extends Node

signal status_update(status)

var _status: int = States.STATUS.STARTUP
var _world: Node3D = null
var _game_hud: Control = null
var _alka: Node3D = null
var _city: Node3D = null

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
			if States.DEBUG_MODE & States.DEBUG.ENABLED:
				print("PAUSE: %s" % data[1])
			_world.pause(data[1])
	else:
		push_warning("SERVICE REQUEST INVALID: WORLD %s, %s" % [id, data])

##################################################################################################

func set_status(status: int) -> void:
	if _status == status:
		return
	if _status == States.STATUS.SHUTDOWN:
		return

	_status = status

	if _status == States.STATUS.READY:
		if States.DEBUG_MODE & States.DEBUG.ENABLED:
			print("\nHELLO WORLD")
	if _status == States.STATUS.SHUTDOWN:
		if States.DEBUG_MODE & States.DEBUG.ENABLED:
			print("GOODBYE WORLD\n")

	emit_signal("status_update", status)

func wait_for_status(req_status: int) -> void:
	while(_status < req_status):
		await status_update

func initialize() -> void:
	_debug_initialize()
	_world = get_tree().get_root().get_node("world")
	_game_hud = get_tree().get_root().get_node("world/game_hud")
	_alka = get_tree().get_root().get_node("world/user/alka")
	_city = get_tree().get_root().get_node("world/city")

##################################################################################################

func _on_delivery_request(status: int, ...data: Array) -> void:
	if (_status < States.STATUS.READY) or (_status == States.STATUS.SHUTDOWN):
		return
	if States.DEBUG_MODE & States.DEBUG.SERVICE:
		print("DELIVERY REQUEST: %s, %s" % [status, data])

	if status == States.DELIVERY.CAPTURING:
		if data[0] is Player:
			_city.set_chasing(data[1], true, _alka)

	elif status == States.DELIVERY.CAPTURED:
		if data[0] is Player:
			var count: int = _alka.capture_symbol(data[1])
			_game_hud.set_count(count)
		elif data[0] is Played:
			_city.capture_symbol(data[1])

	elif status == States.DELIVERY.CANCEL:
		_city.set_chasing(data[1], false, null)

	elif status == States.DELIVERY.RELEASE:
		var release_data: Array = _alka.release_symbol()
		var count: int = release_data[0]
		var erased_symbol: States.SYMBOL = release_data[1]
		_game_hud.set_count(count)
		if erased_symbol != States.SYMBOL.NULL:
			_city.spawn_symbol(erased_symbol)
			_city.set_chasing(erased_symbol, false, null)

	else:
		push_warning("DELIVERY REQUEST INVALID: %s, %s_%s" % [status, data[0], data[1]])

func _on_service_request(id: String, status: int, ...data: Array) -> void:
	if (_status < States.STATUS.READY) or (_status == States.STATUS.SHUTDOWN):
		return
	if States.DEBUG_MODE & States.DEBUG.SERVICE:
		print("SERVICE REQUEST: %s, %s, %s" % [id, status, data])

	if status == States.REQUEST.WORLD:
		_request_world(id, data)
	else:
		push_warning("SERVICE REQUEST INVALID: %s, %s, %s" % [id, status, data])

##################################################################################################
