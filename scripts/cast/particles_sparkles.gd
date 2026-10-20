# Copyright © 2026, jurgfish. All rights reserved.

extends GPUParticles3D

@export var _effect_player: AudioStreamPlayer3D

##################################################################################################

func emit_particles() -> void:
	_effect_player.play()
	emitting = true
	await finished
	queue_free()

##################################################################################################
