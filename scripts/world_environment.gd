# Copyright © 2026, jurgfish. All rights reserved.

extends WorldEnvironment

##################################################################################################

func _ready() -> void:
	if States.DEBUG_MODE & States.DEBUG.LIGHTS_ON:
		environment.background_color = Color.DIM_GRAY

##################################################################################################
