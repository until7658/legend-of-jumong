extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/combat/demo_training_battle.tscn")


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var battle: SquadBattleController = BATTLE_SCENE.instantiate() as SquadBattleController
	root.add_child(battle)
	await process_frame
	for attack_index: int in range(3):
		if not battle.select_player_squad():
			_fail("cannot select squad at attack %d" % attack_index)
			return
		var snapshot: Dictionary = battle.get_snapshot()
		var player: Dictionary = snapshot.player as Dictionary
		var destination: Vector2i = player.position as Vector2i
		if attack_index == 2:
			destination += Vector2i.LEFT
		if not battle.move_selected(destination):
			_fail("cannot confirm squad position at attack %d" % attack_index)
			return
		if not battle.command_attack():
			_fail("cannot attack at attack %d" % attack_index)
			return
	var final_snapshot: Dictionary = battle.get_snapshot()
	if str(final_snapshot.state) != "VICTORY":
		_fail("expected VICTORY, got %s" % final_snapshot.state)
		return
	var enemy: Dictionary = final_snapshot.enemy as Dictionary
	if int(enemy.commander_morale) != 0 or int(enemy.soldier_count) != 0:
		_fail("enemy squad did not resolve deterministically")
		return
	print("[COMBAT_DEMO_SMOKE] PASS commander+squad state machine round=%d" % int(final_snapshot.round))
	quit(0)


func _fail(message: String) -> void:
	push_error("[COMBAT_DEMO_SMOKE] %s" % message)
	quit(1)
