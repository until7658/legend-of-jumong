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
	var prologue: PrologueDirector = main.get_node("%Prologue") as PrologueDirector
	var observed_cuts: Array[int] = []
	prologue.cut_changed.connect(func(cut_id: int, _cut: Dictionary) -> void: observed_cuts.append(cut_id))
	for step: int in range(13):
		prologue.call(&"_advance")
		await process_frame
	prologue.call(&"_advance")
	await create_timer(0.7).timeout
	var completion: Control = main.get_node("%OpeningComplete") as Control
	var battle: SquadBattleController = main.get_node("%TrainingBattle") as SquadBattleController
	if prologue.visible or completion.visible or not battle.visible or observed_cuts.size() != 13:
		push_error("[SMOKE_FLOW] Invalid final visibility state")
		quit(1)
		return
	for index: int in range(observed_cuts.size()):
		if observed_cuts[index] != index + 2:
			push_error("[SMOKE_FLOW] Cut order mismatch")
			quit(1)
			return
	print("[SMOKE_FLOW] PASS title -> 14-cut prologue -> commander squad training battle")
	quit(0)
