# Copyright © 2026, jurgfish. All rights reserved.

extends Control

signal request(id, status, data)

var _curr_page: String = ""

@export var _invert_cam_v: Button
@export var _invert_cam_h: Button
@export var _game_info: Label

@export var _resume_button: Button
@export var _sensitivity_slider: HSlider
@export var _volume_slider: HSlider
@export var _legal_button: Button
@export var _info_button: Button
@export var _settings: MarginContainer

@export var _user: Node3D
@onready var _legal_scroll: VScrollBar = $settings/legal/legal_text.get_v_scroll_bar()

##################################################################################################

func _format_bool(flag: bool) -> String:
	return "on" if flag else "off"

func _set_invert_cam_v(flag: bool) -> void:
	_invert_cam_v.text = _format_bool(flag)

func _set_invert_cam_h(flag: bool) -> void:
	_invert_cam_h.text = _format_bool(flag)

func _update_info() -> void:
	var year: String = str(States.VERSION_DATE.year).substr(2)
	var date: String = "%s.%s.%s" % [States.VERSION_DATE.month, States.VERSION_DATE.day, year]

	var history: String = "version %s: %s\n" % [States.GAME_VERSION, date]
	_game_info.text = history + _game_info.text

##################################################################################################

func _switch_page(page_id: String) -> void:
	_curr_page = ""
	set_physics_process(false)

	for page in _settings.get_children():
		page.visible = (page.name == page_id)
		if page.name == page_id:
			_curr_page = page_id

	if _curr_page == "main":
		_resume_button.grab_focus()
	elif _curr_page == "controls":
		_sensitivity_slider.grab_focus()
	elif _curr_page == "options":
		_volume_slider.grab_focus()
	elif _curr_page == "info":
		_legal_button.grab_focus()
	elif _curr_page == "legal":
		_info_button.grab_focus()
		_legal_scroll.value = 0.0

	if _curr_page.is_empty():
		push_warning("PAUSE_HUD PAGE INVALID: %s" % page_id)

##################################################################################################

func pause(flag) -> void:
	if flag:
		_switch_page("main")
		visible = true
		_resume_button.grab_focus()
	else:
		visible = false

##################################################################################################

func _ready() -> void:
	pause(false)
	connect("request", Callable(Service, "_on_service_request"))

	_set_invert_cam_v(States.user.invert_cam_v)
	_set_invert_cam_h(States.user.invert_cam_h)
	_update_info()

##################################################################################################

func _on_resume_pressed() -> void:
	emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.PAUSE, false)

func _on_controls_pressed() -> void:
	_switch_page("controls")

func _on_options_pressed():
	_switch_page("options")

func _on_abandon_pressed() -> void:
	emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.QUIT)

func _on_main_pressed() -> void:
	_switch_page("main")

func _on_info_pressed() -> void:
	_switch_page("info")

func _on_legal_pressed() -> void:
	_switch_page("legal")

##################################################################################################

func _on_invert_cam_v_pressed() -> void:
	_set_invert_cam_v(!States.user.invert_cam_v)
	_user.set_invert_cam_v(!States.user.invert_cam_v)
	_invert_cam_v.grab_focus()

func _on_invert_cam_h_pressed() -> void:
	_set_invert_cam_h(!States.user.invert_cam_h)
	_user.set_invert_cam_h(!States.user.invert_cam_h)
	_invert_cam_h.grab_focus()

##################################################################################################
