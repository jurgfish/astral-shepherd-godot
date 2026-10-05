# Copyright © 2021-2026, jurgfish. All rights reserved.

# holds all game states (core state machine)

extends Node

##################################################################################################

enum STATUS { STARTUP, READY, INTRO, RUNNING, SHUTDOWN, QUIT }
enum DEBUG { DISABLED = 1, ENABLED = 2, USER = 4 }

var DEBUG_MODE: int = (
	DEBUG.ENABLED #^ DEBUG.USER
)

##################################################################################################

const GAME_NAME: String = "astral shepherd"
const GAME_AUTHOR: String = "jurgfish"
const GAME_VERSION: String = "0.0.1"
const VERSION_DATE: Dictionary = { "year": 2026, "month": 10, "day": 5 }

##################################################################################################
