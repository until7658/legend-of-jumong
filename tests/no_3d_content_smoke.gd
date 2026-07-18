extends SceneTree

const SCAN_ROOTS: PackedStringArray = [
	"res://scenes",
	"res://scripts",
	"res://shaders",
	"res://data",
	"res://assets",
]
const TEXT_EXTENSIONS: PackedStringArray = ["gd", "tscn", "tres", "gdshader", "json", "cfg", "godot"]
const MODEL_EXTENSIONS: PackedStringArray = ["glb", "gltf", "fbx", "obj", "dae", "blend", "3ds"]
const BANNED_TOKENS: PackedStringArray = [
	"Node3D",
	"Camera3D",
	"Sprite3D",
	"MeshInstance3D",
	"MultiMeshInstance3D",
	"CharacterBody3D",
	"PhysicsBody3D",
	"RigidBody3D",
	"StaticBody3D",
	"AnimatableBody3D",
	"Area3D",
	"CollisionObject3D",
	"CollisionShape3D",
	"CollisionPolygon3D",
	"RayCast3D",
	"ShapeCast3D",
	"WorldEnvironment",
	"DirectionalLight3D",
	"OmniLight3D",
	"SpotLight3D",
	"NavigationRegion3D",
	"NavigationAgent3D",
	"Path3D",
	"PathFollow3D",
	"Skeleton3D",
	"BoneAttachment3D",
	"StandardMaterial3D",
	"BoxMesh",
	"PlaneMesh",
	"CylinderMesh",
	"SphereMesh",
	"PrismMesh",
	"CSGBox3D",
]

var _violations: PackedStringArray = []


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	for root_path: String in SCAN_ROOTS:
		_scan_directory(root_path)
	_scan_text_file("res://project.godot")
	if not _violations.is_empty():
		for violation: String in _violations:
			push_error("[NO_3D_SMOKE] %s" % violation)
		quit(1)
		return
	print("[NO_3D_SMOKE] PASS roots=%d banned_tokens=%d model_extensions=%d" % [SCAN_ROOTS.size(), BANNED_TOKENS.size(), MODEL_EXTENSIONS.size()])
	quit(0)


func _scan_directory(path: String) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	for file_name: String in directory.get_files():
		var file_path: String = path.path_join(file_name)
		var extension: String = file_name.get_extension().to_lower()
		if extension in MODEL_EXTENSIONS:
			_violations.append("3D model file: %s" % file_path)
		elif extension in TEXT_EXTENSIONS:
			_scan_text_file(file_path)
	for child_name: String in directory.get_directories():
		_scan_directory(path.path_join(child_name))


func _scan_text_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_violations.append("cannot read: %s" % path)
		return
	var content: String = file.get_as_text()
	file.close()
	for token: String in BANNED_TOKENS:
		if content.contains(token):
			_violations.append("%s contains %s" % [path, token])
