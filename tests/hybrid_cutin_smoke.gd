extends SceneTree

const SCENE_PATH: String = "res://experiments/hybrid_cutin_3d/hybrid_cutin_ab_spike.tscn"

var _failures: Array[String] = []
var _finished_payloads: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("[HYBRID_CUTIN_SMOKE] load scene")
	var packed: PackedScene = load(SCENE_PATH)
	_check(packed != null, "hybrid A/B scene loads")
	if packed == null:
		_finish()
		return
	var cutin: Node = packed.instantiate()
	print("[HYBRID_CUTIN_SMOKE] scene instantiated")
	cutin.set("autoplay_demo", false)
	root.add_child(cutin)
	print("[HYBRID_CUTIN_SMOKE] scene added")
	await process_frame
	print("[HYBRID_CUTIN_SMOKE] first frame")

	var viewport := cutin.get_node_or_null("HybridViewport") as SubViewport
	_check(viewport != null, "isolated SubViewport exists")
	if viewport != null:
		_check(viewport.size == Vector2i(640, 360), "SubViewport is fixed at 640x360")
		_check(viewport.own_world_3d, "SubViewport owns isolated 3D world")
	var camera := cutin.get_node_or_null("HybridViewport/HybridStage3D/FixedOrthographicCamera3D") as Camera3D
	_check(camera != null and camera.projection == Camera3D.PROJECTION_ORTHOGONAL, "camera is fixed orthographic Camera3D")
	var texture := cutin.get_node_or_null("HybridViewportTexture") as TextureRect
	_check(texture != null and texture.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "viewport output uses nearest filtering")
	_check(cutin.get_node_or_null("CharactersVfx2D") is Control, "characters and VFX use outer 2D Control layer")
	_check(not _contains_forbidden_3d_node(cutin), "no Sprite3D, 3D physics, collision, or navigation nodes")

	cutin.connect("presentation_finished", _on_presentation_finished)
	var payload: Dictionary = _sample_payload()
	cutin.set("force_background_failure_for_test", true)
	cutin.call("set_background_mode", true)
	cutin.call("play_clash", payload)
	await process_frame
	_check(bool(cutin.call("is_using_2d_fallback")), "forced 3D failure activates 2D fallback")
	var overlay: Node = cutin.get_node("CharactersVfx2D")
	_check(int(overlay.call("visible_figure_count")) == 18, "fallback presents 1 commander + 8 soldiers per side")
	cutin.call("skip")
	await process_frame
	_check(_finished_payloads.size() == 1, "skip emits presentation_finished exactly once")
	if _finished_payloads.size() == 1:
		_check(_finished_payloads[0] == payload, "fallback completion preserves resolved payload")

	cutin.set("force_background_failure_for_test", false)
	cutin.call("set_background_mode", true)
	cutin.call("play_clash", payload)
	await process_frame
	_check(not bool(cutin.call("is_using_2d_fallback")), "hybrid background is available in normal mode")
	cutin.call("skip")
	await process_frame
	_check(_finished_payloads.size() == 2, "hybrid completion uses the same signal contract")
	if _finished_payloads.size() == 2:
		_check(_finished_payloads[1] == payload, "hybrid completion preserves resolved payload")
	_finish()


func _on_presentation_finished(payload: Dictionary) -> void:
	_finished_payloads.append(payload.duplicate(true))


func _contains_forbidden_3d_node(node: Node) -> bool:
	var forbidden_classes: Array[String] = [
		"Sprite3D",
		"PhysicsBody3D",
		"CollisionObject3D",
		"CollisionShape3D",
		"CollisionPolygon3D",
		"NavigationRegion3D",
		"NavigationAgent3D",
		"NavigationObstacle3D",
	]
	for forbidden_class in forbidden_classes:
		if node.is_class(forbidden_class):
			return true
	for child in node.get_children():
		if _contains_forbidden_3d_node(child):
			return true
	return false


func _sample_payload() -> Dictionary:
	return {
		"attacker_id": "jumong_training_squad",
		"defender_id": "training_captain_squad",
		"attacker_troop_type": "archer",
		"defender_troop_type": "spearman",
		"attacker_soldiers_before": 8,
		"attacker_soldiers_after": 7,
		"defender_soldiers_before": 8,
		"defender_soldiers_after": 5,
		"commander_damage": 2,
		"distance": 2,
		"advantage": true,
		"nonlethal": true,
	}


func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		_failures.append(label)
		push_error("FAIL: %s" % label)


func _finish() -> void:
	if _failures.is_empty():
		print("HYBRID_CUTIN_SMOKE: PASS")
		quit(0)
	else:
		print("HYBRID_CUTIN_SMOKE: FAIL (%d)" % _failures.size())
		quit(1)
