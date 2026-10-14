# Copyright © 2026, jurgfish. All rights reserved.

# core signal bus

extends Node

signal status_update(status)

var _status: int = States.STATUS.STARTUP
var _world: Node3D = null
var _load_hud: Control = null
var _game_hud: Control = null
var _pause_hud: Control = null
var _user: Node3D = null
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

# autoload singleton data isn't reset on scene reload (node refrences also lost)
func initialize() -> void:
	get_tree().set_auto_accept_quit(false)
	get_tree().paused = false # for game reload
	_debug_initialize()

	_world = get_tree().get_root().get_node("world")
	_load_hud = get_tree().get_root().get_node("world/load_hud")
	_game_hud = get_tree().get_root().get_node("world/game_hud")
	_pause_hud = get_tree().get_root().get_node("world/pause_hud")
	_user = get_tree().get_root().get_node("world/user")
	_alka = get_tree().get_root().get_node("world/user/alka")
	_city = get_tree().get_root().get_node("world/city")

##################################################################################################

# SCHEDULING

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

##################################################################################################

# MAIN DELIVERY REQUEST PROCESSING

func _symbol_capturing(host: Node3D, symbol_id: States.SYMBOL) -> void:
	if host is Player:
		if symbol_id == States.ALKA_SYMBOL:
			_game_hud.fade_in(true)
		else:
			_city.set_chasing(symbol_id, true, _alka)

func _symbol_captured(host: Node3D, symbol_id: States.SYMBOL) -> void:
	if host is Player:
		var count: int = _alka.capture_symbol(symbol_id)
		_game_hud.set_count(count)

		if symbol_id == States.ALKA_SYMBOL:
			set_status(States.STATUS.RUNNING)

	elif host is Played:
		_city.capture_symbol(symbol_id)

func _symbol_released() -> void:
	var release_data: Array = _alka.release_symbol()
	var count: int = release_data[0]
	var erased_symbol: States.SYMBOL = release_data[1]
	_game_hud.set_count(count)
	if erased_symbol != States.SYMBOL.NULL:
		_city.spawn_symbol(erased_symbol)
		_city.set_chasing(erased_symbol, false, null)

##################################################################################################

# MAIN WORLD LOGIC REQUEST PROCESSING

func _pause_game(flag: bool) -> void:
	if States.DEBUG_MODE & States.DEBUG.ENABLED:
		print("PAUSE: %s" % flag)

	get_tree().paused = flag
	_pause_hud.pause(flag)
	_load_hud.pause(flag)
	_user.pause(flag)
	if _status >= States.STATUS.RUNNING:
		_game_hud.fade_in(!flag)

func _quit_game() -> void:
	set_status(States.STATUS.SHUTDOWN)
	get_tree().paused = true
	_game_hud.fade_in(false)
	_pause_hud.quit()
	_load_hud.quit()
	get_tree().quit()

func _request_world(id: String, data: Array) -> void:
	if data[0] == States.WORLD.QUIT:
		_quit_game()
	elif len(data) > 1:
		if data[0] == States.WORLD.PAUSE:
			_pause_game(data[1])
	else:
		push_warning("SERVICE REQUEST INVALID: WORLD %s, %s" % [id, data])

##################################################################################################

# INCOMING SIGNAL REQUESTS

func _on_delivery_request(status: int, ...data: Array) -> void:
	if (_status < States.STATUS.READY) or (_status >= States.STATUS.SHUTDOWN):
		return
	if States.DEBUG_MODE & States.DEBUG.SERVICE:
		print("DELIVERY REQUEST: %s, %s" % [status, data])

	if status == States.DELIVERY.CAPTURING:
		_symbol_capturing(data[0], data[1])
	elif status == States.DELIVERY.CAPTURED:
		_symbol_captured(data[0], data[1])
	elif status == States.DELIVERY.CANCEL:
		_city.set_chasing(data[1], false, null)
	elif status == States.DELIVERY.RELEASE:
		_symbol_released()
	else:
		push_warning("DELIVERY REQUEST INVALID: %s, %s_%s" % [status, data[0], data[1]])

func _on_service_request(id: String, status: int, ...data: Array) -> void:
	if _status >= States.STATUS.SHUTDOWN:
		return
	if States.DEBUG_MODE & States.DEBUG.SERVICE:
		print("SERVICE REQUEST: %s, %s, %s" % [id, status, data])

	if status == States.REQUEST.WORLD:
		_request_world(id, data)
	else:
		push_warning("SERVICE REQUEST INVALID: %s, %s, %s" % [id, status, data])

##################################################################################################
