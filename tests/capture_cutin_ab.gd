extends SceneTree

const CUTIN_2D: PackedScene = preload("res://scenes/combat/presentation/squad_clash_cutin_2d.tscn")
const CUTIN_HYBRID: PackedScene = preload("res://experiments/hybrid_cutin_3d/hybrid_cutin_ab_spike.tscn")
const OUTPUT_ROOT: String = "C:/Users/until/.codex/visualizations/2026/07/18/019f7294-7343-7a72-bad2-b897055a2c7e"


func _initialize() -> void:
	call_deferred(&"_capture")


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	var payload: Dictionary = _sample_payload()

	var cutin_2d: SquadClashCutin2D = CUTIN_2D.instantiate() as SquadClashCutin2D
	root.add_child(cutin_2d)
	await process_frame
	cutin_2d.play_clash(payload)
	await create_timer(0.66).timeout
	await process_frame
	if not _save_viewport("m4_clash_cutin_2d.png"):
		return
	cutin_2d.queue_free()
	await process_frame

	var cutin_hybrid: Node = CUTIN_HYBRID.instantiate()
	cutin_hybrid.set("autoplay_demo", false)
	root.add_child(cutin_hybrid)
	await process_frame
	cutin_hybrid.call("set_background_mode", true)
	cutin_hybrid.call("play_clash", payload)
	await create_timer(0.82).timeout
	await process_frame
	if not _save_viewport("m41_hybrid_cutin.png"):
		return

	print("[CAPTURE_CUTIN_AB] PASS 2D and hybrid frames saved")
	quit(0)


func _save_viewport(file_name: String) -> bool:
	var image: Image = root.get_texture().get_image()
	var output_path: String = OUTPUT_ROOT.path_join(file_name)
	var error: Error = image.save_png(output_path)
	if error != OK:
		push_error("[CAPTURE_CUTIN_AB] save failed %s: %s" % [output_path, error_string(error)])
		quit(1)
		return false
	print("[CAPTURE_CUTIN_AB] saved %s" % output_path)
	return true


func _sample_payload() -> Dictionary:
	return {
		"attacker_id": "jumong_squad",
		"defender_id": "trainer_squad",
		"attacker_troop_type": "archer",
		"defender_troop_type": "spear",
		"attacker_soldiers_before": 8,
		"attacker_soldiers_after": 8,
		"defender_soldiers_before": 8,
		"defender_soldiers_after": 4,
		"commander_damage": 0,
		"distance": 3,
		"advantage": "range",
		"nonlethal": true,
	}
