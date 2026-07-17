extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/bootstrap/main.tscn")
const CAPTURE_PATH: String = "C:/Users/until/.codex/visualizations/2026/07/17/019f6ea1-8e12-7930-a20b-cc70b59ebe91/prologue_cut03.png"


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var title: TitleScreen = main.get_node("TitleScreen") as TitleScreen
	var button: Button = title.get_node("Menu/NewGameButton") as Button
	button.pressed.emit()
	await create_timer(0.6).timeout
	await process_frame
	var prologue: PrologueDirector = main.get_node("Prologue") as PrologueDirector
	prologue.call(&"_advance")
	prologue.call(&"_advance")
	await create_timer(0.6).timeout
	print("[CAPTURE_NEW_GAME] title_valid=%s prologue_visible=%s" % [is_instance_valid(title), prologue.visible])
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(CAPTURE_PATH)
	print("[CAPTURE_NEW_GAME] save=%s path=%s" % [error, CAPTURE_PATH])
	quit(0 if error == OK and prologue.visible else 1)
