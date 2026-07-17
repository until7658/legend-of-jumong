extends SceneTree


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var service := DisplaySettings.new()
	root.add_child(service)
	await process_frame
	if not service.display_available:
		print("[DISPLAY_GUI_SMOKE] SKIP no display")
		quit(0)
		return
	var cases: Array[Dictionary] = [
		{"name": "windowed", "mode": DisplaySettings.DisplayMode.WINDOWED, "size": Vector2i(1280, 720)},
		{"name": "borderless", "mode": DisplaySettings.DisplayMode.BORDERLESS, "size": service.native_size},
		{"name": "exclusive", "mode": DisplaySettings.DisplayMode.EXCLUSIVE, "size": service.native_size},
	]
	for test_case: Dictionary in cases:
		service.apply_without_saving(test_case)
		await process_frame
		await process_frame
		var result: Dictionary = service.verify_current_settings()
		print("[DISPLAY_GUI_SMOKE] %s %s" % [str(test_case.name), str(result.message)])
		if not bool(result.success):
			quit(1)
			return
	service.apply_without_saving(service.default_settings())
	await process_frame
	print("[DISPLAY_GUI_SMOKE] PASS all display modes")
	quit(0)
