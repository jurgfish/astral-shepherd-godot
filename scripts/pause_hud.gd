# Copyright © 2026, jurgfish. All rights reserved.

extends Control

signal request(id, status, data)

const FULLSCREEN_STATES: Array = ["on", "off", "maximized", "borderless"]
const FPS_INF: int = 205
const FORMAT_MULT: float = 100.0

var _curr_page: String = ""
var _setup_only: bool = true

@export var _sensitivity_value: Label
@export var _invert_cam_v_button: Button
@export var _invert_cam_h_button: Button
@export var _volume_value: Label
@export var _frame_rate_slider: HSlider
@export var _frame_rate_value: Label
@export var _vsync_button: Button
@export var _fullscreen_button: Button
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

func _format_range(value: float) -> String:
	return "%s%%" % int(value)

func _format_bool(flag: bool) -> String:
	return "on" if flag else "off"

func _format_fps(value: int) -> String:
	return "∞" if value == 0 else ("%s" % value)

func _calculate_fullscreen() -> int:
	return wrapi(States.user.fullscreen + 1, 0, FULLSCREEN_STATES.size())

func _calculate_vsync() -> bool:
	return !States.user.vsync

func _update_info() -> void:
	var year: String = str(States.VERSION_DATE.year).substr(2)
	var date: String = "%s.%s.%s" % [States.VERSION_DATE.month, States.VERSION_DATE.day, year]

	var history: String = "version %s: %s\n" % [States.GAME_VERSION, date]
	_game_info.text = history + _game_info.text

##################################################################################################

func _set_sensitivity(value: float) -> void:
	_sensitivity_slider.value = value
	_sensitivity_value.text = _format_range(value)

func _set_invert_cam_v(flag: bool) -> void:
	_invert_cam_v_button.text = _format_bool(flag)

func _set_invert_cam_h(flag: bool) -> void:
	_invert_cam_h_button.text = _format_bool(flag)

##################################################################################################

func _set_volume(value: float) -> void:
	_volume_slider.value = value
	_volume_value.text = _format_range(value)

func _set_frame_rate(value: int) -> void:
	_frame_rate_slider.value = FPS_INF if value == 0 else value
	_frame_rate_value.text = _format_fps(value)

func set_fullscreen(status: int) -> void:
	_fullscreen_button.text = FULLSCREEN_STATES[status]

func _set_vsync(enabled: bool) -> void:
	_vsync_button.text = _format_bool(enabled)

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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PAUSE") and visible:
		emit_signal("request", name, States.REQUEST.WORLD, States.WORLD.PAUSE, !get_tree().paused)
		get_viewport().set_input_as_handled()

func _ready() -> void:
	pause(false)
	connect("request", Callable(Service, "_on_service_request"))

	_set_sensitivity(States.user.sensitivity * FORMAT_MULT)
	_set_invert_cam_v(States.user.invert_cam_v)
	_set_invert_cam_h(States.user.invert_cam_h)
	_set_volume(States.user.volume * FORMAT_MULT)
	_set_frame_rate(States.user.frame_rate)
	set_fullscreen(States.user.fullscreen)
	_set_vsync(States.user.vsync)
	_update_info()

	_setup_only = false

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
	if !_setup_only:
		_set_invert_cam_v(!States.user.invert_cam_v)
		_user.set_invert_cam_v(!States.user.invert_cam_v)
		_invert_cam_v_button.grab_focus()

func _on_invert_cam_h_pressed() -> void:
	if !_setup_only:
		_set_invert_cam_h(!States.user.invert_cam_h)
		_user.set_invert_cam_h(!States.user.invert_cam_h)
		_invert_cam_h_button.grab_focus()

func _on_fullscreen_pressed() -> void:
	if !_setup_only:
		var fullscreen_status = _calculate_fullscreen()
		set_fullscreen(fullscreen_status)
		_user.set_fullscreen(fullscreen_status)
		_fullscreen_button.grab_focus()

func _on_vsync_pressed() -> void:
	if !_setup_only:
		var vsync_status = _calculate_vsync()
		_set_vsync(vsync_status)
		_user.set_vsync(vsync_status)
		_vsync_button.grab_focus()

##################################################################################################

func _on_sensitivity_slider_value_changed(value: float) -> void:
	if !_setup_only:
		_set_sensitivity(value)
		_user.set_sensitivity(value / FORMAT_MULT)
		_sensitivity_slider.grab_focus()

func _on_volume_slider_value_changed(value: float) -> void:
	if !_setup_only:
		_set_volume(value)
		_user.set_volume(value / FORMAT_MULT)
		_volume_slider.grab_focus()

func _on_frame_rate_slider_value_changed(value: int) -> void:
	if !_setup_only:
		if value == FPS_INF:
			value = 0
		_set_frame_rate(value)
		_user.set_frame_rate(value)
		_frame_rate_slider.grab_focus()

##################################################################################################
