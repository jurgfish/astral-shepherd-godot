# Copyright © 2026, jurgfish. All rights reserved.

extends Node3D

const ALLIAS = preload("uid://cbmg7ps1h673y")

var _allias_list: Array = []

@export var _spawner_symbol: Node3D

##################################################################################################

func _spawn_allias(symbol_id: States.SYMBOL, spawn_bound: float) -> void:
	var allias := ALLIAS.instantiate()
	add_child(allias)
	var pos_x: float = randf_range(-spawn_bound, spawn_bound)
	var pos_z: float = randf_range(-spawn_bound, spawn_bound)
	allias.set_location(Vector3(pos_x, 0.0, pos_z))
	allias.set_symbol(symbol_id)

func _retrieve_symbol_list() -> Array:
	var symbol_list: Array = _spawner_symbol.get_symbol_list()
	return symbol_list

##################################################################################################

func set_target_look(body: Node3D) -> void:
	for allias in _allias_list:
		allias.set_target_look(body)

func set_random_symbols_target_look() -> void:
	var symbol_list: Array = _retrieve_symbol_list()
	symbol_list.shuffle()

	for idx in _allias_list.size():
		_allias_list[idx].set_target_look(symbol_list[idx])

func open_visors(flag: bool) -> void:
	for allias in _allias_list:
		allias.open_visor(flag)

func align_rotation_to_target() -> void:
	for allias in _allias_list:
		allias.align_rotation_to_target()

func set_target_navigation(body: Node3D) -> void:
	for allias in _allias_list:
		allias.set_target_navigation(body)

func set_random_symbols_target_navigation() -> void:
	var symbol_list: Array = _retrieve_symbol_list()
	if symbol_list.is_empty():
		return
	symbol_list.shuffle()

	# allias list will always be >= remaining symbols
	# remaining symbols should be >= allias idle
	# captured symbols = (alka captured = allias chasing) + allias captured
	# remaining symbols = (uncaptured = allias idle)
	for allias in _allias_list:
		if not (allias.is_chasing() or allias.is_dormant()):
			var target = symbol_list.pop_back()
			if target != null:
				allias.set_target_navigation(target)
			else:
				push_warning("SPAWNER ALLIAS: unexpected symbol mismatch")

##################################################################################################

func set_chasing(symbol: States.SYMBOL, flag: bool, body: Node3D) -> void:
	for allias in _allias_list:
		if allias.get_symbol() == symbol:
			allias.set_chasing(flag, body)
			return

func capture_symbol(symbol: States.SYMBOL) -> void:
	for allias in _allias_list:
		if allias.get_symbol() == symbol:
			allias.capture_symbol(symbol)
			return

# param: count [int] max State.ALLIAS_SYMBOLS size
# note: spawned allias symbols should match spawned symbols
func spawn(count: int, spawn_bound: float) -> void:
	count = min(count, States.ALLIAS_SYMBOLS.size())
	for idx in count:
		_spawn_allias(States.ALLIAS_SYMBOLS[idx], spawn_bound)
	_allias_list = get_children()

##################################################################################################
