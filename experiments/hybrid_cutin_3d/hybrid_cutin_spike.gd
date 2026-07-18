extends Control

signal presentation_finished(payload: Dictionary)

const INTERNAL_VIEWPORT_SIZE := Vector2i(640, 360)
const DEFAULT_DURATION_SECONDS: float = 2.0
const TEXT_DATA_PATH: String = "res://experiments/hybrid_cutin_3d/ui_text.json"
const OverlayScript := preload("res://experiments/hybrid_cutin_3d/hybrid_cutin_overlay.gd")

@export var use_hybrid_background: bool = true
@export var allow_2d_fallback: bool = true
@export var autoplay_demo: bool = true
@export var presentation_duration_seconds: float = DEFAULT_DURATION_SECONDS
@export var force_background_failure_for_test: bool = false

var _active_payload: Dictionary = {}
var _elapsed_seconds: float = 0.0
var _playing: bool = false
var _using_fallback: bool = false
var _hybrid_available: bool = false
var _hybrid_viewport: SubViewport
var _hybrid_texture: TextureRect
var _overlay: Control
var _mode_label: Label
var _help_label: Label
var _texts: Dictionary = {}


func _ready() -> void:
	set_process(false)
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_load_text_data()
	_build_hybrid_background()
	_build_2d_presentation()
	_apply_background_mode()
	if autoplay_demo:
		play_clash(_demo_payload())


func play_clash(payload: Dictionary) -> void:
	_active_payload = _sanitize_payload(payload)
	_elapsed_seconds = 0.0
	_playing = true
	_apply_background_mode()
	_overlay.call("set_presentation", _active_payload, 0.0, true)
	set_process(true)
	visible = true


func skip() -> void:
	if not _playing:
		return
	_finish_presentation()


func set_background_mode(hybrid_enabled: bool) -> void:
	use_hybrid_background = hybrid_enabled
	_apply_background_mode()


func is_using_2d_fallback() -> bool:
	return _using_fallback


func is_hybrid_background_available() -> bool:
	return _hybrid_available and not force_background_failure_for_test


func internal_viewport_size() -> Vector2i:
	return INTERNAL_VIEWPORT_SIZE


func _process(delta: float) -> void:
	if not _playing:
		return
	_elapsed_seconds += delta
	var safe_duration: float = maxf(presentation_duration_seconds, 0.05)
	var phase: float = clampf(_elapsed_seconds / safe_duration, 0.0, 1.0)
	_overlay.call("set_presentation", _active_payload, phase, true)
	if phase >= 1.0:
		_finish_presentation()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			set_background_mode(not use_hybrid_background)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE or event.keycode == KEY_ENTER:
			skip()
			get_viewport().set_input_as_handled()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#11181c"))
	if _using_fallback:
		_draw_2d_fallback_stage()
	draw_rect(Rect2(0.0, 0.0, size.x, 46.0), Color(0.025, 0.035, 0.04, 0.88))
	draw_rect(Rect2(0.0, size.y - 42.0, size.x, 42.0), Color(0.025, 0.035, 0.04, 0.88))


func _draw_2d_fallback_stage() -> void:
	var center := Vector2(size.x * 0.5, size.y * 0.56)
	var ground := PackedVector2Array([
		center + Vector2(-size.x * 0.46, -size.y * 0.22),
		center + Vector2(size.x * 0.34, -size.y * 0.22),
		center + Vector2(size.x * 0.46, size.y * 0.17),
		center + Vector2(-size.x * 0.34, size.y * 0.17),
	])
	draw_colored_polygon(ground, Color("#65724e"))
	for index in range(7):
		var y: float = center.y - 58.0 + index * 22.0
		draw_line(Vector2(size.x * 0.13, y), Vector2(size.x * 0.87, y + 32.0), Color(0.25, 0.29, 0.21, 0.34), 2.0)
	for side in [-1.0, 1.0]:
		for index in range(3):
			var x: float = center.x + side * (205.0 + index * 20.0)
			draw_rect(Rect2(x - 8.0, center.y - 75.0 + index * 15.0, 16.0, 62.0), Color("#463b2b"))


func _build_hybrid_background() -> void:
	_hybrid_viewport = SubViewport.new()
	_hybrid_viewport.name = "HybridViewport"
	_hybrid_viewport.size = INTERNAL_VIEWPORT_SIZE
	_hybrid_viewport.own_world_3d = true
	_hybrid_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_hybrid_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	_hybrid_viewport.transparent_bg = false
	add_child(_hybrid_viewport)

	var stage := Node3D.new()
	stage.name = "HybridStage3D"
	_hybrid_viewport.add_child(stage)
	var camera := Camera3D.new()
	camera.name = "FixedOrthographicCamera3D"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 11.0
	stage.add_child(camera)
	camera.look_at_from_position(Vector3(8.5, 7.0, 8.5), Vector3.ZERO, Vector3.UP)
	camera.current = true

	var light := DirectionalLight3D.new()
	light.name = "MatteDirectionalLight3D"
	light.rotation_degrees = Vector3(-58.0, -34.0, 0.0)
	light.light_color = Color("#f1d8a8")
	light.light_energy = 1.15
	light.shadow_enabled = false
	stage.add_child(light)

	var environment := WorldEnvironment.new()
	environment.name = "FlatWorldEnvironment"
	var environment_resource := Environment.new()
	environment_resource.background_mode = Environment.BG_COLOR
	environment_resource.background_color = Color("#1c292a")
	environment_resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment_resource.ambient_light_color = Color("#a9b78f")
	environment_resource.ambient_light_energy = 0.62
	environment.environment = environment_resource
	stage.add_child(environment)

	_add_box(stage, "Ground", Vector3(0.0, -0.18, 0.0), Vector3(12.0, 0.3, 7.0), Color("#69744e"))
	_add_box(stage, "RaisedBank", Vector3(0.0, -0.02, -2.85), Vector3(12.0, 0.35, 1.3), Color("#566242"))
	for side in [-1.0, 1.0]:
		for index in range(3):
			_add_post(stage, "Post_%s_%s" % [str(side), str(index)], Vector3(side * (4.4 + index * 0.32), 0.55, -1.6 + index * 1.3))
	_add_box(stage, "StoneLeft", Vector3(-4.2, 0.05, 2.2), Vector3(1.1, 0.45, 0.8), Color("#64665c"), Vector3(0.0, 21.0, 0.0))
	_add_box(stage, "StoneRight", Vector3(4.1, 0.02, 2.0), Vector3(0.9, 0.38, 0.7), Color("#64665c"), Vector3(0.0, -18.0, 0.0))

	_hybrid_texture = TextureRect.new()
	_hybrid_texture.name = "HybridViewportTexture"
	_hybrid_texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hybrid_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_hybrid_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_hybrid_texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_hybrid_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hybrid_texture.texture = _hybrid_viewport.get_texture()
	add_child(_hybrid_texture)
	_hybrid_available = _hybrid_texture.texture != null


func _build_2d_presentation() -> void:
	_overlay = OverlayScript.new()
	_overlay.name = "CharactersVfx2D"
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)

	_mode_label = Label.new()
	_mode_label.name = "ModeLabel"
	_mode_label.position = Vector2(20.0, 12.0)
	_mode_label.add_theme_color_override("font_color", Color("#f1e3bc"))
	_mode_label.add_theme_font_size_override("font_size", 18)
	_mode_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_mode_label)

	_help_label = Label.new()
	_help_label.name = "HelpLabel"
	_help_label.position = Vector2(20.0, 320.0)
	_help_label.add_theme_color_override("font_color", Color("#d4d8cf"))
	_help_label.add_theme_font_size_override("font_size", 14)
	_help_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_help_label)


func _apply_background_mode() -> void:
	var requested_hybrid: bool = use_hybrid_background
	var usable_hybrid: bool = requested_hybrid and is_hybrid_background_available()
	_using_fallback = not usable_hybrid
	if _using_fallback and not allow_2d_fallback:
		_playing = false
		set_process(false)
	if is_instance_valid(_hybrid_texture):
		_hybrid_texture.visible = usable_hybrid
	if is_instance_valid(_mode_label):
		var mode_key: String = "mode_hybrid" if usable_hybrid else "mode_fallback"
		_mode_label.text = str(_texts.get(mode_key, mode_key))
	if is_instance_valid(_help_label):
		_help_label.text = str(_texts.get("controls", "controls"))
	queue_redraw()


func _finish_presentation() -> void:
	_playing = false
	set_process(false)
	_overlay.call("set_presentation", _active_payload, 1.0, false)
	presentation_finished.emit(_active_payload.duplicate(true))


func _sanitize_payload(payload: Dictionary) -> Dictionary:
	var sanitized := payload.duplicate(true)
	for prefix in ["attacker", "defender"]:
		var before_key: String = "%s_soldiers_before" % prefix
		var after_key: String = "%s_soldiers_after" % prefix
		var before_count: int = clampi(int(sanitized.get(before_key, 8)), 0, 12)
		var after_count: int = clampi(int(sanitized.get(after_key, before_count)), 0, before_count)
		sanitized[before_key] = before_count
		sanitized[after_key] = after_count
	return sanitized


func _load_text_data() -> void:
	if not FileAccess.file_exists(TEXT_DATA_PATH):
		return
	var file := FileAccess.open(TEXT_DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		var locale: String = TranslationServer.get_locale().left(2)
		var localized: Variant = parsed.get(locale, parsed.get("ko", {}))
		if localized is Dictionary:
			_texts = localized


func _add_box(
	parent: Node3D,
	node_name: String,
	position: Vector3,
	size_3d: Vector3,
	color: Color,
	rotation: Vector3 = Vector3.ZERO
) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = position
	mesh_instance.rotation_degrees = rotation
	var box := BoxMesh.new()
	box.size = size_3d
	box.material = _matte_material(color)
	mesh_instance.mesh = box
	parent.add_child(mesh_instance)


func _add_post(parent: Node3D, node_name: String, position: Vector3) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = position
	var cylinder := CylinderMesh.new()
	cylinder.height = 1.25
	cylinder.top_radius = 0.11
	cylinder.bottom_radius = 0.15
	cylinder.radial_segments = 6
	cylinder.material = _matte_material(Color("#4b3828"))
	mesh_instance.mesh = cylinder
	parent.add_child(mesh_instance)


func _matte_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	material.metallic = 0.0
	return material


func _demo_payload() -> Dictionary:
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
