extends SceneTree

const CUTIN_SCENE: PackedScene = preload("res://scenes/combat/presentation/squad_clash_cutin_2d.tscn")

var _completed_ids: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var cutin: SquadClashCutin2D = CUTIN_SCENE.instantiate() as SquadClashCutin2D
	root.add_child(cutin)
	await process_frame
	cutin.presentation_finished.connect(_on_presentation_finished)
	cutin.size = Vector2(1280.0, 720.0)
	var player_payload := _payload("jumong_squad", "archer", "trainer_squad", "spear", 8, 5)
	var enemy_payload := _payload("trainer_squad", "spear", "jumong_squad", "archer", 8, 7)
	enemy_payload["attacker_side"] = "right"
	cutin.play_clash(player_payload)
	cutin.play_clash(enemy_payload)
	await process_frame
	var first_snapshot: Dictionary = cutin.get_render_snapshot()
	if not bool(first_snapshot.playing) or int(first_snapshot.queued) != 1:
		_fail("queued playback contract failed")
		return
	if int(first_snapshot.attacker_actors) != 9 or int(first_snapshot.defender_actors) != 9:
		_fail("expected commander+8 soldiers on both sides")
		return
	if first_snapshot.stage_size != Vector2(1280.0, 720.0):
		_fail("720p stage size mismatch")
		return
	cutin.skip()
	await process_frame
	await process_frame
	if _completed_ids != ["jumong_squad"]:
		_fail("first skip did not preserve payload order")
		return
	var second_snapshot: Dictionary = cutin.get_render_snapshot()
	if not bool(second_snapshot.playing) or int(second_snapshot.queued) != 0:
		_fail("second queued cutin did not start")
		return
	cutin.size = Vector2(1280.0, 800.0)
	await process_frame
	if cutin.get_render_snapshot().stage_size != Vector2(1280.0, 800.0):
		_fail("800p stage size mismatch")
		return
	cutin.skip()
	await process_frame
	if _completed_ids != ["jumong_squad", "trainer_squad"]:
		_fail("queued completion order mismatch")
		return
	if bool(cutin.get_render_snapshot().playing):
		_fail("cutin remained active after queue completed")
		return
	print("[CLASH_CUTIN_2D_SMOKE] PASS 1+8, queue, skip, 720p/800p")
	quit(0)


func _payload(attacker_id: String, attacker_type: String, defender_id: String, defender_type: String, soldiers_before: int, soldiers_after: int) -> Dictionary:
	return {
		"attacker_id": attacker_id,
		"defender_id": defender_id,
		"attacker_troop_type": attacker_type,
		"defender_troop_type": defender_type,
		"attacker_soldiers_before": 8,
		"attacker_soldiers_after": 8,
		"defender_soldiers_before": soldiers_before,
		"defender_soldiers_after": soldiers_after,
		"commander_damage": 0,
		"distance": 2,
		"advantage": true,
		"nonlethal": true,
	}


func _on_presentation_finished(payload: Dictionary) -> void:
	_completed_ids.append(str(payload.get("attacker_id", "")))


func _fail(message: String) -> void:
	push_error("[CLASH_CUTIN_2D_SMOKE] %s" % message)
	quit(1)
