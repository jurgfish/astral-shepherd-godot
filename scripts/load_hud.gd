# Copyright © 2021-2026, jurgfish. All rights reserved.

##################################################################################################

extends Control

const BANNED_KEYS: Array = [
	Key.KEY_NONE, Key.KEY_SPECIAL, Key.KEY_PRINT, Key.KEY_SYSREQ, Key.KEY_META, Key.KEY_ALT
]

var _epigraph_shown: bool = false
var _tip_shown: bool = false
var _quit_queued: bool = false

@export var _display: Control
@export var _anim: AnimationPlayer

##################################################################################################

func _set_epigraph_shown() -> void:
	_epigraph_shown = true
	set_process_input(true)

func _set_tip_shown() -> void:
	_tip_shown = true

func _hide_epigraph() -> void:
	if (not _epigraph_shown) or _quit_queued:
		return
	_epigraph_shown = false
	set_process_input(false)

	if _anim.is_playing() and _tip_shown:
		await _anim.animation_finished
	if _tip_shown:
		_anim.play("epigraph_tip_hide")
	else:
		_anim.play("epigraph_hide")

	await _anim.animation_finished

##################################################################################################

func play_load() -> void:
	_anim.play("logo_reveal")
	await _anim.animation_finished
	if _quit_queued:
		return
	_anim.play("epigraph_reveal")
	await _anim.animation_finished

func pause(flag: bool) -> void:
	if _epigraph_shown:
		set_process_input(!flag)
	_display.visible = !flag

func quit() -> void:
	_quit_queued = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_anim.stop(true)
	_anim.play("quit")

##################################################################################################

func _ready() -> void:
	set_process_input(false)
	if States.DEBUG_MODE & States.DEBUG.SKIP_LOAD_SPLASH:
		visible = false

func _input(event: InputEvent) -> void:
	if _epigraph_shown and not (event.is_released() or
			event.is_action_pressed("FULLSCREEN_TOGGLE") or
			event.is_action_pressed("PAUSE") or
			event is InputEventMouseMotion or event is InputEventPanGesture or
			event is InputEventJoypadMotion or (event is InputEventKey and (
			(event.physical_keycode >= Key.KEY_F1 or event.keycode >= Key.KEY_F1 or
			event.physical_keycode in BANNED_KEYS or event.keycode in BANNED_KEYS)))):
		_hide_epigraph()

##################################################################################################
