# Copyright © 2026, jurgfish. All rights reserved.

extends Control

const COUNT_STR: String = "      %s"

var _count: int = 0
var _quit_queued: bool = false

@export var _count_label: Label
@export var _anim: AnimationPlayer

##################################################################################################

func set_count(in_count: int) -> void:
	if _anim.is_playing():
		await _anim.animation_finished
	if in_count > _count:
		_anim.play("increment")
	else:
		_anim.play("decrement")
	_count = in_count
	_count_label.text = COUNT_STR % _count

func fade_in(flag: bool) -> void:
	if _quit_queued:
		return
	if flag:
		if not visible:
			_anim.play("fade_in")
	else:
		_anim.stop()
		visible = false

func quit() -> void:
	_quit_queued = true
	visible = false

##################################################################################################
