# Copyright © 2026, jurgfish. All rights reserved.

extends Control

var _count: int = 0

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
	_count_label.text = str(_count)

func fade_in(flag: bool) -> void:
	if flag:
		if not visible:
			_anim.play("fade_in")
	else:
		_anim.stop()
		visible = false

##################################################################################################
