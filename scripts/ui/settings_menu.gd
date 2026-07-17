class_name SettingsMenu
extends Control

signal closed

const CONFIRM_SECONDS: int = 12

@onready var mode_option: OptionButton = %ModeOption
@onready var resolution_option: OptionButton = %ResolutionOption
@onready var help_text: Label = %HelpText
@onready var apply_button: Button = %ApplyButton
@onready var cancel_button: Button = %CancelButton
@onready var defaults_button: Button = %DefaultsButton
@onready var confirm_dialog: PanelContainer = %ConfirmDialog
@onready var countdown_label: Label = %CountdownLabel
@onready var keep_button: Button = %KeepButton
@onready var revert_button: Button = %RevertButton
@onready var confirm_timer: Timer = %ConfirmTimer

var display_settings: DisplaySettings
var _resolutions: Array[Vector2i] = []
var _remaining_seconds: int = CONFIRM_SECONDS
var _preview_active: bool = false


func setup(service: DisplaySettings) -> void:
	display_settings = service
	_populate_options()
	_load_controls(display_settings.current_settings)
	show()
	mode_option.grab_focus()


func _ready() -> void:
	mode_option.item_selected.connect(_on_mode_selected)
	apply_button.pressed.connect(_apply)
	cancel_button.pressed.connect(_cancel)
	defaults_button.pressed.connect(_defaults)
	keep_button.pressed.connect(_keep_changes)
	revert_button.pressed.connect(_revert_changes)
	confirm_timer.timeout.connect(_on_confirm_tick)
	_configure_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event.is_action_pressed(&"ui_cancel"):
		return
	if _preview_active:
		_revert_changes()
	else:
		_cancel()
	get_viewport().set_input_as_handled()


func _populate_options() -> void:
	mode_option.clear()
	mode_option.add_item("창 모드", DisplaySettings.DisplayMode.WINDOWED)
	mode_option.add_item("테두리 없는 전체 화면", DisplaySettings.DisplayMode.BORDERLESS)
	mode_option.add_item("독점 전체 화면", DisplaySettings.DisplayMode.EXCLUSIVE)
	resolution_option.clear()
	_resolutions = display_settings.resolution_options()
	for size: Vector2i in _resolutions:
		var native_suffix: String = " (모니터 최대)" if size == display_settings.native_size else ""
		resolution_option.add_item("%d × %d%s" % [size.x, size.y, native_suffix])


func _load_controls(settings: Dictionary) -> void:
	var requested_mode: int = int(settings.mode)
	for index: int in range(mode_option.item_count):
		if mode_option.get_item_id(index) == requested_mode:
			mode_option.select(index)
			break
	var size: Vector2i = settings.size as Vector2i
	var index: int = _resolutions.find(size)
	resolution_option.select(max(index, 0))
	_on_mode_selected(mode_option.selected)


func _on_mode_selected(index: int) -> void:
	var mode: int = mode_option.get_item_id(index)
	var fullscreen: bool = mode != DisplaySettings.DisplayMode.WINDOWED
	resolution_option.disabled = fullscreen
	help_text.text = "전체 화면은 현재 모니터의 최대 해상도를 사용합니다." if fullscreen else "창 크기를 현재 모니터 최대 해상도 이하에서 선택할 수 있습니다."


func _selected_settings() -> Dictionary:
	var size: Vector2i = display_settings.native_size
	if not _resolutions.is_empty() and resolution_option.selected >= 0:
		size = _resolutions[resolution_option.selected]
	return {"mode": mode_option.get_selected_id(), "size": size}


func _apply() -> void:
	if _preview_active:
		return
	display_settings.begin_preview(_selected_settings())
	await get_tree().process_frame
	var verification: Dictionary = display_settings.verify_current_settings()
	help_text.text = str(verification.message)
	if not bool(verification.success):
		display_settings.revert_preview()
		_load_controls(display_settings.current_settings)
		return
	_preview_active = true
	_remaining_seconds = CONFIRM_SECONDS
	_update_countdown()
	confirm_dialog.show()
	_set_main_controls_enabled(false)
	revert_button.grab_focus()
	confirm_timer.start()


func _keep_changes() -> void:
	if not _preview_active:
		return
	confirm_timer.stop()
	display_settings.confirm_preview()
	_finish_preview()
	help_text.text = "화면 설정을 저장했습니다."


func _revert_changes() -> void:
	if not _preview_active:
		return
	confirm_timer.stop()
	display_settings.revert_preview()
	_load_controls(display_settings.current_settings)
	_finish_preview()
	help_text.text = "이전 화면 설정으로 되돌렸습니다."


func _finish_preview() -> void:
	_preview_active = false
	confirm_dialog.hide()
	_set_main_controls_enabled(true)
	mode_option.grab_focus()


func _on_confirm_tick() -> void:
	_remaining_seconds -= 1
	if _remaining_seconds <= 0:
		_revert_changes()
	else:
		_update_countdown()


func _update_countdown() -> void:
	countdown_label.text = "%d초 안에 확인하지 않으면 이전 설정으로 돌아갑니다." % _remaining_seconds


func _defaults() -> void:
	_load_controls(display_settings.default_settings())
	help_text.text = "기본값은 현재 모니터 최대 해상도의 테두리 없는 전체 화면입니다. 적용을 눌러 확인하세요."


func _cancel() -> void:
	hide()
	closed.emit()


func _set_main_controls_enabled(enabled: bool) -> void:
	mode_option.disabled = not enabled
	resolution_option.disabled = not enabled or mode_option.get_selected_id() != DisplaySettings.DisplayMode.WINDOWED
	apply_button.disabled = not enabled
	cancel_button.disabled = not enabled
	defaults_button.disabled = not enabled


func _configure_focus() -> void:
	mode_option.focus_neighbor_bottom = mode_option.get_path_to(resolution_option)
	resolution_option.focus_neighbor_top = resolution_option.get_path_to(mode_option)
	resolution_option.focus_neighbor_bottom = resolution_option.get_path_to(apply_button)
	apply_button.focus_neighbor_top = apply_button.get_path_to(resolution_option)
	apply_button.focus_neighbor_right = apply_button.get_path_to(defaults_button)
	defaults_button.focus_neighbor_left = defaults_button.get_path_to(apply_button)
	defaults_button.focus_neighbor_right = defaults_button.get_path_to(cancel_button)
	cancel_button.focus_neighbor_left = cancel_button.get_path_to(defaults_button)
	keep_button.focus_neighbor_right = keep_button.get_path_to(revert_button)
	revert_button.focus_neighbor_left = revert_button.get_path_to(keep_button)
