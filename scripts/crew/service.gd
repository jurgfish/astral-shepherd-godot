# Copyright © 2026, jurgfish. All rights reserved.

# core signal bus

extends Node

signal status_update(status)

var _status: States.STATUS = States.STATUS.STARTUP
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

func set_status(status: States.STATUS) -> void:
	if _status == status:
		return
	if _status == States.STATUS.SHUTDOWN:
		return

	_status = status

	if _status == States.STATUS.READY:
		if States.DEBUG_MODE & States.DEBUG.ENABLED:
			print("\nHELLO WORLD")
	elif _status == States.STATUS.SHUTDOWN:
		if States.DEBUG_MODE & States.DEBUG.ENABLED:
			print("GOODBYE WORLD\n")

	emit_signal("status_update", status)

func get_status() -> States.STATUS:
	return _status

func wait_for_status(req_status: int) -> void:
	while(_status < req_status):
		await status_update

##################################################################################################

# MAIN DELIVERY REQUEST PROCESSING

func _process_capture_counts() -> void:
	var total_count: int = _city.get_spawn_count() + 1 # account for alka's star
	var alka_captures: int = _alka.get_capture_count()
	var allias_captures: int = _city.get_allias_capture_count()
	var remaining_symbols: int = total_count - (alka_captures + allias_captures)

	_city.open_exits(remaining_symbols == 0)
	if allias_captures == (total_count - 1): # impossible to undo this state
		_city.open_allias_visors(true)

	if States.DEBUG_MODE & States.DEBUG.ENABLED:
		print("SYMBOL STATUS: total: %s - (alka: %s + allias: %s) = %s remain" % [
			total_count, alka_captures, allias_captures, remaining_symbols
		])

func _symbol_capturing(host: Node3D, symbol_id: States.SYMBOL) -> void:
	if host is Player:
		if symbol_id == States.ALKA_SYMBOL:
			_game_hud.fade_in(true)
		else:
			_city.set_chasing(symbol_id, true, _alka)

func _symbol_captured(host: Node3D, symbol_id: States.SYMBOL) -> void:
	if host is Player:
		var alka_captures: int = _alka.capture_symbol(symbol_id)
		_game_hud.set_count(alka_captures)
		if symbol_id == States.ALKA_SYMBOL:
			set_status(States.STATUS.RUNNING)
		else:
			_city.set_chasing(symbol_id, true, _alka) # possible to capture if not capturing

	elif host is Played:
		_city.capture_symbol(symbol_id)

	_process_capture_counts()

func _symbol_released() -> void:
	var release_data: Array = _alka.release_symbol()
	var alka_captures: int = release_data[0]
	var erased_symbol: States.SYMBOL = release_data[1]
	if erased_symbol != States.SYMBOL.NULL:
		_game_hud.set_count(alka_captures)
		_city.spawn_symbol(erased_symbol)
		_city.set_chasing(erased_symbol, false, null)
	if alka_captures == 0 and _status >= States.STATUS.RUNNING:
		_city.reset_random_navigation()

	_process_capture_counts()

func _clockout() -> void:
	set_status(States.STATUS.COOLDOWN)
	_city.end_routine()
	_game_hud.quit()

	var spawn_count: int = _city.get_spawn_count()
	var alka_captures: int = _alka.get_capture_count()
	var allias_captures: int = _city.get_allias_capture_count()

	if spawn_count != allias_captures:
		_load_hud.play_lose(alka_captures, allias_captures)
	else:
		_load_hud.play_win()

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

func _reload_game() -> void:
	if States.DEBUG_MODE & States.DEBUG.ENABLED:
		print("RELOAD\n")

	States.session_counter += 1
	_status = States.STATUS.STARTUP
	_game_hud.quit()
	_pause_hud.quit()
	_load_hud.quit()
	get_tree().reload_current_scene()

func _quit_game() -> void:
	set_status(States.STATUS.SHUTDOWN)
	get_tree().paused = true
	_game_hud.quit()
	_pause_hud.quit()
	_load_hud.quit()
	get_tree().quit()

func _request_world(id: String, data: Array) -> void:
	if data[0] == States.WORLD.QUIT:
		_quit_game()
	elif data[0] == States.WORLD.RELOAD:
		_reload_game()
	elif len(data) > 1:
		if data[0] == States.WORLD.PAUSE:
			_pause_game(data[1])
	else:
		push_warning("SERVICE REQUEST INVALID: WORLD %s, %s" % [id, data])

func _request_city(id: String, data: Array) -> void:
	if len(data) > 1:
		if data[0] == States.CITY.MUSIC:
			_city.play_music(data[1])
	else:
		push_warning("SERVICE REQUEST INVALID: CITY %s, %s" % [id, data])

##################################################################################################

# INCOMING SIGNAL REQUESTS

func _on_delivery_request(status: int, ...data: Array) -> void:
	if (_status < States.STATUS.READY) or (_status >= States.STATUS.COOLDOWN):
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
	elif status == States.DELIVERY.CLOCKOUT:
		_clockout()
	else:
		push_warning("DELIVERY REQUEST INVALID: %s, %s" % [status, data])

func _on_service_request(id: String, status: int, ...data: Array) -> void:
	if _status >= States.STATUS.SHUTDOWN:
		return
	if States.DEBUG_MODE & States.DEBUG.SERVICE:
		print("SERVICE REQUEST: %s, %s, %s" % [id, status, data])

	if status == States.REQUEST.WORLD:
		_request_world(id, data)
	elif status == States.REQUEST.CITY:
		_request_city(id, data)
	else:
		push_warning("SERVICE REQUEST INVALID: %s, %s, %s" % [id, status, data])

##################################################################################################
