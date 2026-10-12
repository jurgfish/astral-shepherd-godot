# Copyright © 2026, jurgfish. All rights reserved.

# holds all game states (core state machine)

extends Node

##################################################################################################

enum STATUS { STARTUP, READY, INTRO, RUNNING, SHUTDOWN }
enum REQUEST { WORLD }
enum WORLD { PAUSE, UNPAUSE, RELOAD, QUIT }
enum SYMBOL {
	NULL, STAR, MOON, TRI, CIRCLE, FLOWER, PROP, PLUS, ASTRAL, DIAMOND, APOSTROPHE, THEREFORE,
	HEXAGON
}
enum DELIVERY { CAPTURING, CAPTURED, CANCEL }

enum DEBUG {
	DISABLED = 1, ENABLED = 2, USER = 4, SERVICE = 8, SKIP_LOAD_SPLASH = 16,
	LIGHTS_ON = 32, DELIVERY = 64
}

var DEBUG_MODE: int = (
	DEBUG.ENABLED #^ DEBUG.SERVICE
	^ DEBUG.SKIP_LOAD_SPLASH #^ DEBUG.LIGHTS_ON
)

##################################################################################################

const GAME_NAME: String = "astral shepherd"
const GAME_AUTHOR: String = "jurgfish"
const GAME_VERSION: String = "0.0.4"
const VERSION_DATE: Dictionary = { "year": 2026, "month": 10, "day": 11 }

##################################################################################################

# GAME SETTINGS
const ALLIAS_SYMBOLS: Array = [
	SYMBOL.MOON, SYMBOL.TRI, SYMBOL.CIRCLE, SYMBOL.FLOWER, SYMBOL.PROP, SYMBOL.PLUS,
	SYMBOL.ASTRAL, SYMBOL.DIAMOND, SYMBOL.APOSTROPHE, SYMBOL.THEREFORE, SYMBOL.HEXAGON
]

# DEFAULT SETTINGS
const INIT_SENSITIVITY: float = 1.0 # slider range: 0.0 to 2.0 (increments 0.01)
const INIT_INVERT_CAM_V: bool = false
const INIT_INVERT_CAM_H: bool = false
const INIT_VOLUME: float = 1.0 # 0.0 to 1.0
const INIT_FRAME_RATE: int = 60 # 30 to 200, inf (increments 5)
const INIT_FULLSCREEN: int = 0
const INIT_VSYNC: bool = true

# USER SETTINGS
var user: Dictionary = {
	"sensitivity": INIT_SENSITIVITY,
	"invert_cam_v": INIT_INVERT_CAM_V,
	"invert_cam_h": INIT_INVERT_CAM_H,
	"volume": INIT_VOLUME,
	"frame_rate": INIT_FRAME_RATE,
	"fullscreen": INIT_FULLSCREEN,
	"vsync": INIT_VSYNC
}

##################################################################################################
