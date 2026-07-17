extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/bootstrap/main.tscn")
const CAPTURE_PATH: String = "C:/Users/until/.codex/visualizations/2026/07/17/019f6ea1-8e12-7930-a20b-cc70b59ebe91/new_game_transition.png"


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
	await create_timer(1.2).timeout
	await process_frame
	var narrative: CanvasItem = main.get_node("NarrativeSequence") as CanvasItem
	print("[CAPTURE_NEW_GAME] title_valid=%s narrative_visible=%s" % [is_instance_valid(title), narrative.visible])
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(CAPTURE_PATH)
	print("[CAPTURE_NEW_GAME] save=%s path=%s" % [error, CAPTURE_PATH])
	quit(0 if error == OK and narrative.visible else 1)
