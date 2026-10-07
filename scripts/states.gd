# Copyright © 2026, jurgfish. All rights reserved.

# holds all game states (core state machine)

extends Node

##################################################################################################

enum REQUEST { WORLD }
enum WORLD { PAUSE, UNPAUSE, RELOAD, QUIT }

enum DEBUG { DISABLED = 1, ENABLED = 2, USER = 4, SERVICE = 8 }

var DEBUG_MODE: int = (
	DEBUG.ENABLED ^ DEBUG.USER
)

##################################################################################################

const GAME_NAME: String = "astral shepherd"
const GAME_AUTHOR: String = "jurgfish"
const GAME_VERSION: String = "0.0.2"
const VERSION_DATE: Dictionary = { "year": 2026, "month": 10, "day": 6 }

##################################################################################################

# DEFAULT SETTINGS
const INIT_INVERT_CAM_V: bool = false
const INIT_INVERT_CAM_H: bool = false
#const INIT_SENSITIVITY: float = 1.0 # slider range: 0.0 to 2.0 (increments 0.01)
#const INIT_VOLUME: float = 1.0 # 0.0 to 1.0
#const INIT_FRAME_RATE: int = 60 # 30 to 200, inf (increments 5)
#const INIT_VSYNC: bool = true
#const INIT_FULLSCREEN: int = 0

# USER SETTINGS
var user: Dictionary = {
	"invert_cam_v": INIT_INVERT_CAM_V,
	"invert_cam_h": INIT_INVERT_CAM_H,
	#"sensitivity": INIT_SENSITIVITY,
	#"volume": INIT_VOLUME,
	#"frame_rate": INIT_FRAME_RATE,
	#"vsync": INIT_VSYNC,
	#"fullscreen": INIT_FULLSCREEN
}

##################################################################################################
