extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/bootstrap/main.tscn")


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.call(&"_on_new_game_requested")
	await process_frame
	var narrative: NarrativeSequence = main.get_node("NarrativeSequence") as NarrativeSequence
	for step: int in range(128):
		if not narrative.visible:
			break
		narrative.call(&"_advance")
		await process_frame
	var prologue_map: NarrativeMapPreview = main.get_node("PrologueMap") as NarrativeMapPreview
	var chapter_map: NarrativeMapPreview = main.get_node("Chapter01Map") as NarrativeMapPreview
	if narrative.visible or prologue_map.visible or not chapter_map.visible:
		push_error("[SMOKE_FLOW] Invalid final visibility state")
		quit(1)
		return
	print("[SMOKE_FLOW] PASS title -> prologue -> chapter_01; chapter map retained")
	quit(0)
