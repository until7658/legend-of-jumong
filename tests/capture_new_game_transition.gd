extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/bootstrap/main.tscn")
const DEFAULT_CAPTURE_PATH: String = "res://tmp/prologue_cut03.png"


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var capture_path: String = OS.get_environment("JUMONG_CAPTURE_PATH")
	if capture_path.is_empty():
		capture_path = DEFAULT_CAPTURE_PATH
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var capture_size: String = OS.get_environment("JUMONG_CAPTURE_SIZE")
	if capture_size == "1280x800":
		var display_settings: DisplaySettings = main.get_node("%DisplaySettings") as DisplaySettings
		display_settings.apply_without_saving({"mode": DisplaySettings.DisplayMode.WINDOWED, "size": Vector2i(1280, 800)})
		await process_frame
		await process_frame
	var title: TitleScreen = main.get_node("%TitleScreen") as TitleScreen
	var button: Button = title.get_node("Menu/NewGameButton") as Button
	button.pressed.emit()
	await create_timer(0.6).timeout
	await process_frame
	var prologue: PrologueDirector = main.get_node("%Prologue") as PrologueDirector
	prologue.call(&"_advance")
	prologue.call(&"_advance")
	await create_timer(0.6).timeout
	print("[CAPTURE_NEW_GAME] title_valid=%s prologue_visible=%s" % [is_instance_valid(title), prologue.visible])
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(capture_path)
	print("[CAPTURE_NEW_GAME] save=%s path=%s" % [error, capture_path])
	quit(0 if error == OK and prologue.visible else 1)
