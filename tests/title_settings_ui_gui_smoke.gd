extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/bootstrap/main.tscn")


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	var title: TitleScreen = main.get_node("TitleScreen") as TitleScreen
	var menu: SettingsMenu = title.get_node("SettingsMenu") as SettingsMenu
	var service: DisplaySettings = main.get_node("DisplaySettings") as DisplaySettings
	if not service.display_available:
		print("[TITLE_SETTINGS_UI_SMOKE] SKIP no display")
		quit(0)
		return
	title.call(&"_open_settings")
	await process_frame
	if not menu.visible:
		_fail("settings menu did not open")
		return
	_select_mode(menu, DisplaySettings.DisplayMode.EXCLUSIVE)
	menu.call(&"_apply")
	await process_frame
	await process_frame
	if not menu.get_node("ConfirmDialog").visible:
		_fail("confirmation dialog did not open")
		return
	menu.call(&"_keep_changes")
	await process_frame
	if not FileAccess.file_exists(DisplaySettings.SETTINGS_PATH):
		_fail("display settings were not saved")
		return
	_select_mode(menu, DisplaySettings.DisplayMode.WINDOWED)
	menu.call(&"_apply")
	await process_frame
	await process_frame
	menu.call(&"_revert_changes")
	await process_frame
	if int(service.current_settings.mode) != DisplaySettings.DisplayMode.EXCLUSIVE:
		_fail("revert did not restore the confirmed mode")
		return
	service.apply_without_saving(service.default_settings())
	await process_frame
	print("[TITLE_SETTINGS_UI_SMOKE] PASS open/apply/confirm/save/revert")
	quit(0)


func _select_mode(menu: SettingsMenu, mode: int) -> void:
	var option: OptionButton = menu.get_node("Panel/Margin/Content/ModeOption") as OptionButton
	for index: int in range(option.item_count):
		if option.get_item_id(index) == mode:
			option.select(index)
			option.item_selected.emit(index)
			return


func _fail(message: String) -> void:
	push_error("[TITLE_SETTINGS_UI_SMOKE] %s" % message)
	quit(1)
