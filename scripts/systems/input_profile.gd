class_name InputProfile
extends Node


func _ready() -> void:
	ensure_default_actions()


func ensure_default_actions() -> void:
	_ensure_key_action(&"move_left", KEY_A)
	_ensure_key_action(&"move_right", KEY_D)
	_ensure_key_action(&"move_up", KEY_W)
	_ensure_key_action(&"move_down", KEY_S)
	_ensure_key_action(&"interact", KEY_E)
	_ensure_key_action(&"game_confirm", KEY_ENTER)
	_ensure_key_action(&"game_cancel", KEY_ESCAPE)
	_ensure_key_action(&"pause", KEY_ESCAPE)
	_ensure_joy_motion(&"move_left", JOY_AXIS_LEFT_X, -1.0)
	_ensure_joy_motion(&"move_right", JOY_AXIS_LEFT_X, 1.0)
	_ensure_joy_motion(&"move_up", JOY_AXIS_LEFT_Y, -1.0)
	_ensure_joy_motion(&"move_down", JOY_AXIS_LEFT_Y, 1.0)
	_ensure_joy_button(&"interact", JOY_BUTTON_A)
	_ensure_joy_button(&"game_confirm", JOY_BUTTON_A)
	_ensure_joy_button(&"game_cancel", JOY_BUTTON_B)
	_ensure_joy_button(&"pause", JOY_BUTTON_START)


func _ensure_key_action(action: StringName, physical_keycode: Key) -> void:
	_ensure_action(action)
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == physical_keycode:
			return
	var key_event := InputEventKey.new()
	key_event.physical_keycode = physical_keycode
	InputMap.action_add_event(action, key_event)


func _ensure_joy_button(action: StringName, button_index: JoyButton) -> void:
	_ensure_action(action)
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and (event as InputEventJoypadButton).button_index == button_index:
			return
	var button_event := InputEventJoypadButton.new()
	button_event.button_index = button_index
	InputMap.action_add_event(action, button_event)


func _ensure_joy_motion(action: StringName, axis: JoyAxis, axis_value: float) -> void:
	_ensure_action(action)
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventJoypadMotion:
			var motion := event as InputEventJoypadMotion
			if motion.axis == axis and is_equal_approx(motion.axis_value, axis_value):
				return
	var motion_event := InputEventJoypadMotion.new()
	motion_event.axis = axis
	motion_event.axis_value = axis_value
	InputMap.action_add_event(action, motion_event)


func _ensure_action(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.35)
