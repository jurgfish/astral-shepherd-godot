# Copyright © 2021-2026, jurgfish. All rights reserved.

##################################################################################################

extends Control

var _epigraph_shown: bool = false
var _tip_shown: bool = false
var _quit_queued: bool = false

@export var _anim: AnimationPlayer

##################################################################################################

func _set_epigraph_shown() -> void:
	_epigraph_shown = true
	set_process_unhandled_input(true)

func _set_tip_shown() -> void:
	_tip_shown = true

##################################################################################################

func reveal_logo() -> void:
	_anim.play("logo_reveal")
	await _anim.animation_finished

	reveal_poem()

func reveal_poem() -> void:
	if _quit_queued:
		return
	_anim.play("epigraph_reveal")

##################################################################################################
