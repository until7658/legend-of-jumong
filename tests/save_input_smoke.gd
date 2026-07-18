extends SceneTree

const TEST_SAVE_PATH: String = "user://prototype_checkpoint_test.json"
const REQUIRED_ACTIONS: Array[StringName] = [
	&"move_left", &"move_right", &"move_up", &"move_down",
	&"interact", &"game_confirm", &"game_cancel", &"pause",
]


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var input_profile := InputProfile.new()
	root.add_child(input_profile)
	await process_frame
	for action: StringName in REQUIRED_ACTIONS:
		if not InputMap.has_action(action) or InputMap.action_get_events(action).is_empty():
			push_error("[SAVE_INPUT_SMOKE] Missing action: %s" % action)
			quit(1)
			return
	var save_service := SaveService.new()
	save_service.save_path = TEST_SAVE_PATH
	root.add_child(save_service)
	save_service.delete_save()
	if not save_service.save_checkpoint("training_complete", {"rounds": 3, "locale": "ko"}):
		quit(1)
		return
	var loaded: Dictionary = save_service.load_checkpoint()
	if str(loaded.get("checkpoint_id", "")) != "training_complete":
		push_error("[SAVE_INPUT_SMOKE] Checkpoint mismatch")
		quit(1)
		return
	var payload: Dictionary = loaded.get("payload", {}) as Dictionary
	if int(payload.get("rounds", 0)) != 3:
		push_error("[SAVE_INPUT_SMOKE] Payload mismatch")
		quit(1)
		return
	if not save_service.delete_save():
		quit(1)
		return
	print("[SAVE_INPUT_SMOKE] PASS actions=%d save_round_trip=true" % REQUIRED_ACTIONS.size())
	quit(0)
