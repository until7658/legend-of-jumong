class_name TitleScreen
extends Control

signal new_game_requested
signal quit_requested

const INTRO_DURATION: float = 0.55
const TRANSITION_DURATION: float = 0.55
const MENU_HELP: Dictionary = {
	"NewGameButton": "오프닝과 제1장 이야기를 시작합니다.",
	"ContinueButton": "저장된 여정이 없습니다.",
	"SettingsButton": "표시 모드와 해상도를 조정합니다.",
	"QuitButton": "게임을 종료합니다.",
}

@onready var title_block: VBoxContainer = %TitleBlock
@onready var menu: VBoxContainer = %Menu
@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var help_text: Label = %HelpText
@onready var title_music: AudioStreamPlayer = %TitleMusic
@onready var fade_overlay: ColorRect = %FadeOverlay
@onready var quit_dialog: PanelContainer = %QuitDialog
@onready var no_button: Button = %NoButton
@onready var yes_button: Button = %YesButton
@onready var settings_menu: SettingsMenu = %SettingsMenu

var _transitioning: bool = false
var _dialog_open: bool = false
var _last_menu_focus: Control
var _menu_buttons: Array[Button] = []
var _display_settings: DisplaySettings


func _ready() -> void:
	_display_settings = get_node_or_null("../DisplaySettings") as DisplaySettings
	if _display_settings == null:
		_display_settings = DisplaySettings.new()
		add_child(_display_settings)
	_display_settings.initialize()
	_menu_buttons = [new_game_button, continue_button, settings_button, quit_button]
	_connect_signals()
	_configure_focus_neighbors()
	new_game_button.grab_focus()
	_last_menu_focus = new_game_button
	_update_help(new_game_button)
	_play_intro()
	print("[TITLE] Cartoon key visual 02 ready; title music disabled pending streamed-audio integration")


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning:
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"ui_cancel"):
		if _dialog_open:
			_close_quit_dialog()
		else:
			_open_quit_dialog()
		get_viewport().set_input_as_handled()


func _connect_signals() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_unavailable_pressed.bind(continue_button))
	settings_button.pressed.connect(_open_settings)
	settings_menu.closed.connect(_close_settings)
	quit_button.pressed.connect(_open_quit_dialog)
	no_button.pressed.connect(_close_quit_dialog)
	yes_button.pressed.connect(_confirm_quit)
	for button: Button in _menu_buttons:
		button.focus_entered.connect(_on_menu_focus_entered.bind(button))
		button.mouse_entered.connect(_on_menu_hovered.bind(button))


func _configure_focus_neighbors() -> void:
	var count: int = _menu_buttons.size()
	for index: int in count:
		var button: Button = _menu_buttons[index]
		button.focus_neighbor_top = button.get_path_to(_menu_buttons[(index - 1 + count) % count])
		button.focus_neighbor_bottom = button.get_path_to(_menu_buttons[(index + 1) % count])
	no_button.focus_neighbor_left = no_button.get_path_to(yes_button)
	no_button.focus_neighbor_right = no_button.get_path_to(yes_button)
	yes_button.focus_neighbor_left = yes_button.get_path_to(no_button)
	yes_button.focus_neighbor_right = yes_button.get_path_to(no_button)


func _play_intro() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, INTRO_DURATION)


func _on_menu_focus_entered(button: Button) -> void:
	if _dialog_open:
		return
	_last_menu_focus = button
	_update_help(button)


func _on_menu_hovered(button: Button) -> void:
	if not _dialog_open:
		_update_help(button)


func _update_help(button: Button) -> void:
	help_text.text = str(MENU_HELP.get(button.name, ""))


func _on_unavailable_pressed(button: Button) -> void:
	_update_help(button)
	button.grab_focus()


func _open_settings() -> void:
	if _transitioning or _dialog_open:
		return
	_dialog_open = true
	_last_menu_focus = settings_button
	_set_menu_input(false)
	settings_menu.setup(_display_settings)


func _close_settings() -> void:
	_dialog_open = false
	_set_menu_input(true)
	settings_button.grab_focus()


func _on_new_game_pressed() -> void:
	if _transitioning or _dialog_open:
		return
	_transitioning = true
	_set_menu_input(false)
	print("[TITLE] New game accepted once; story route requested")
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	tween.tween_property(title_block, "modulate:a", 0.0, 0.35)
	tween.tween_property(menu, "modulate:a", 0.0, 0.3)
	tween.tween_property(help_text, "modulate:a", 0.0, 0.3)
	tween.tween_property(fade_overlay, "color:a", 1.0, TRANSITION_DURATION)
	tween.tween_property(title_music, "volume_db", -50.0, TRANSITION_DURATION)
	await tween.finished
	new_game_requested.emit()


func _open_quit_dialog() -> void:
	if _transitioning or _dialog_open:
		return
	_dialog_open = true
	_set_menu_input(false)
	quit_dialog.show()
	no_button.grab_focus()
	print("[TITLE] Quit confirmation opened; safe default is No")


func _close_quit_dialog() -> void:
	if not _dialog_open:
		return
	_dialog_open = false
	quit_dialog.hide()
	_set_menu_input(true)
	if is_instance_valid(_last_menu_focus):
		_last_menu_focus.grab_focus()
	else:
		new_game_button.grab_focus()


func _confirm_quit() -> void:
	if _transitioning:
		return
	_transitioning = true
	no_button.disabled = true
	yes_button.disabled = true
	quit_requested.emit()


func _set_menu_input(enabled: bool) -> void:
	for button: Button in _menu_buttons:
		button.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
		button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
