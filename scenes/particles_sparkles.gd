# Copyright © 2026, jurgfish. All rights reserved.

extends GPUParticles3D

##################################################################################################

func emit_particles() -> void:
	emitting = true
	await finished
	queue_free()

##################################################################################################
