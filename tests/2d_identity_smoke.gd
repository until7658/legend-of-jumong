extends SceneTree

const CORE_2D_ROOTS: PackedStringArray = [
	"res://scenes/bootstrap",
	"res://scenes/maps",
	"res://scenes/combat",
	"res://scenes/characters",
	"res://scenes/narrative",
	"res://scenes/ui",
	"res://scripts/bootstrap",
	"res://scripts/level_map",
	"res://scripts/combat",
	"res://scripts/characters",
	"res://scripts/narrative",
	"res://scripts/systems",
	"res://scripts/ui",
]
const TEXT_EXTENSIONS: PackedStringArray = ["gd", "tscn", "tres", "gdshader", "json", "cfg", "godot"]
const CORE_3D_TOKENS: PackedStringArray = [
	"Node3D",
	"Camera3D",
	"CharacterBody3D",
	"PhysicsBody3D",
	"RigidBody3D",
	"StaticBody3D",
	"Area3D",
	"CollisionShape3D",
	"NavigationRegion3D",
	"NavigationAgent3D",
]

var _violations: PackedStringArray = []


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	for root_path: String in CORE_2D_ROOTS:
		_scan_directory(root_path)
	_scan_text_file("res://project.godot")
	if not _violations.is_empty():
		for violation: String in _violations:
			push_error("[2D_IDENTITY_SMOKE] %s" % violation)
		quit(1)
		return
	print("[2D_IDENTITY_SMOKE] PASS core_roots=%d gameplay_tokens=%d" % [CORE_2D_ROOTS.size(), CORE_3D_TOKENS.size()])
	quit(0)


func _scan_directory(path: String) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	for file_name: String in directory.get_files():
		if file_name.get_extension().to_lower() in TEXT_EXTENSIONS:
			_scan_text_file(path.path_join(file_name))
	for child_name: String in directory.get_directories():
		_scan_directory(path.path_join(child_name))


func _scan_text_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_violations.append("cannot read: %s" % path)
		return
	var content: String = file.get_as_text()
	file.close()
	for token: String in CORE_3D_TOKENS:
		if content.contains(token):
			_violations.append("%s contains gameplay 3D dependency %s" % [path, token])
