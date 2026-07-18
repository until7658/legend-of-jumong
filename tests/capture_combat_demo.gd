extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/combat/demo_training_battle.tscn")
const OUTPUT_PATH: String = "C:/Users/until/.codex/visualizations/2026/07/18/019f7294-7343-7a72-bad2-b897055a2c7e/m4_squad_battle.png"


func _initialize() -> void:
	call_deferred(&"_capture")


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	var battle: SquadBattleController = BATTLE_SCENE.instantiate() as SquadBattleController
	root.add_child(battle)
	await process_frame
	await process_frame
	battle.select_player_squad()
	await process_frame
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(OUTPUT_PATH)
	if error != OK:
		push_error("[CAPTURE_COMBAT] save failed: %s" % error_string(error))
		quit(1)
		return
	print("[CAPTURE_COMBAT] saved %s" % OUTPUT_PATH)
	quit(0)
