class_name NarrativeMapPreview
extends Node3D

signal map_ready(map_id: String, entry_marker: Marker3D)
signal scene_started(map_id: String, context: Dictionary)
signal scene_finished(map_id: String, result: Dictionary)

enum MapKind {
	PROLOGUE_RIVERBANK,
	CHAPTER_01_TRAINING_GROUND,
}

const GRID_SIZE: Vector2i = Vector2i(12, 8)
const TILE_WORLD_SIZE: float = 1.5
const ATLAS_GRID_SIZE: float = 4.0
const ATLAS_UV_SCALE: Vector3 = Vector3(0.25, 0.25, 1.0)
const TILE_TEXTURES: Dictionary = {
	"ground": "res://assets/tiles/normalized/basic_northern_wilderness_tiles_1024.png",
	"path": "res://assets/tiles/normalized/northern_wilderness_path_tiles_1024.png",
	"water": "res://assets/tiles/normalized/northern_wilderness_water_terrain_1024.png",
	"cliff": "res://assets/tiles/normalized/northern_wilderness_cliff_connections_1024.png",
}
const TREE_TEXTURE_PATH: String = "res://assets/objects/northern_tree_objects.png"
const ROCK_TEXTURE_PATH: String = "res://assets/objects/northern_rock_objects.png"

@export var map_kind: MapKind = MapKind.PROLOGUE_RIVERBANK

var _tile_count: int = 0
var _object_count: int = 0
var _is_built: bool = false
var _is_started: bool = false
var _scene_context: Dictionary = {}


func _ready() -> void:
	_build_map()
	print("[MAP_PREVIEW] kind=%s tiles=%d objects=%d" % [_map_name(), _tile_count, _object_count])
	map_ready.emit.call_deferred(_map_name(), get_entry_marker())


## Starts this map's narrative beat. The vertical-slice director owns scene changes
## and may pass arbitrary read-only context such as the preceding choice result.
func start_scene(context: Dictionary = {}) -> void:
	_scene_context = context.duplicate(true)
	_is_started = true
	visible = true
	var camera: Camera3D = get_node_or_null("Camera3D") as Camera3D
	if camera != null:
		camera.current = true
	scene_started.emit(_map_name(), _scene_context.duplicate(true))


## Ends the current beat without changing scenes. The director receives the result
## and decides which map or narrative scene is next.
func finish_scene(result: Dictionary = {}) -> void:
	if not _is_started:
		return
	_is_started = false
	scene_finished.emit(_map_name(), result.duplicate(true))


func get_entry_marker() -> Marker3D:
	return get_node("EntryMarker") as Marker3D


func get_exit_marker() -> Marker3D:
	return get_node("ExitMarker") as Marker3D


func get_map_id() -> String:
	return _map_name()


func _build_map() -> void:
	if _is_built:
		return
	_is_built = true
	var ground_texture: Texture2D = load(TILE_TEXTURES["ground"])
	for y: int in range(GRID_SIZE.y):
		for x: int in range(GRID_SIZE.x):
			var variation := Vector2i((x + y * 2) % 2, 0)
			_add_tile(ground_texture, variation, Vector2i(x, y), 0.0)

	match map_kind:
		MapKind.PROLOGUE_RIVERBANK:
			_build_prologue_riverbank()
		MapKind.CHAPTER_01_TRAINING_GROUND:
			_build_chapter_01_training_ground()


func _build_prologue_riverbank() -> void:
	var water_texture: Texture2D = load(TILE_TEXTURES["water"])
	for y: int in range(GRID_SIZE.y):
		for x: int in range(5):
			var atlas_coord := Vector2i((x + y) % 2, 0)
			if x == 4:
				atlas_coord = Vector2i(3, 0)
			_add_tile(water_texture, atlas_coord, Vector2i(x, y), 0.02)

	# 얕은 여울과 구조 지점은 중앙 시야에 놓고 나루 동선은 동쪽 육지로 연다.
	for y: int in range(2, 6):
		_add_tile(water_texture, Vector2i(2, 1), Vector2i(4, y), 0.035)
	_add_tree(Vector2i(0, 0), Vector3(8.5, 0.05, 1.0), 0.78)
	_add_tree(Vector2i(1, 0), Vector3(10.2, 0.05, 8.7), 0.68)
	_add_tree(Vector2i(2, 1), Vector3(12.0, 0.05, 3.0), 0.62)
	_add_rock(Vector2i(0, 0), Vector3(7.0, 0.05, 7.4), 0.54)
	_add_rock(Vector2i(2, 0), Vector3(5.8, 0.05, 2.2), 0.48)


func _build_chapter_01_training_ground() -> void:
	var path_texture: Texture2D = load(TILE_TEXTURES["path"])
	var cliff_texture: Texture2D = load(TILE_TEXTURES["cliff"])

	# 남쪽 왕성 방향에서 궁술장으로 이어지는 길과 중앙 시험장을 구성한다.
	for y: int in range(GRID_SIZE.y):
		_add_tile(path_texture, Vector2i(2, 0), Vector2i(5, y), 0.02)
	for y: int in range(3, 7):
		for x: int in range(6, 10):
			_add_tile(path_texture, Vector2i(0, 3), Vector2i(x, y), 0.025)

	# 북쪽 능선은 제1장 사냥터와 매복 구역으로 이어지는 시각적 경계다.
	for x: int in range(GRID_SIZE.x):
		_add_tile(cliff_texture, Vector2i(x % 4, 0), Vector2i(x, 0), 0.05)

	_add_tree(Vector2i(0, 0), Vector3(1.2, 0.05, 8.6), 0.72)
	_add_tree(Vector2i(2, 0), Vector3(15.5, 0.05, 8.1), 0.8)
	_add_tree(Vector2i(0, 1), Vector3(16.5, 0.05, 2.2), 0.62)
	_add_rock(Vector2i(1, 1), Vector3(3.0, 0.05, 2.0), 0.5)
	_add_rock(Vector2i(0, 1), Vector3(3.8, 0.05, 7.2), 0.46)


func _add_tile(texture: Texture2D, atlas_coord: Vector2i, grid_coord: Vector2i, height: float) -> void:
	var tile := MeshInstance3D.new()
	tile.name = "Tile_%02d_%02d_%02d" % [grid_coord.x, grid_coord.y, _tile_count]
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(TILE_WORLD_SIZE, TILE_WORLD_SIZE)
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.uv1_scale = ATLAS_UV_SCALE
	material.uv1_offset = Vector3(float(atlas_coord.x) / ATLAS_GRID_SIZE, float(atlas_coord.y) / ATLAS_GRID_SIZE, 0.0)
	material.roughness = 0.96
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material = material
	tile.mesh = mesh
	tile.position = Vector3(float(grid_coord.x) * TILE_WORLD_SIZE, height, float(grid_coord.y) * TILE_WORLD_SIZE)
	$Tiles.add_child(tile)
	_tile_count += 1


func _add_tree(cell: Vector2i, position_3d: Vector3, scale_factor: float) -> void:
	_add_atlas_object(TREE_TEXTURE_PATH, cell, Vector2i(3, 3), position_3d, scale_factor, "Tree")


func _add_rock(cell: Vector2i, position_3d: Vector3, scale_factor: float) -> void:
	_add_atlas_object(ROCK_TEXTURE_PATH, cell, Vector2i(3, 3), position_3d, scale_factor, "Rock")


func _add_atlas_object(texture_path: String, cell: Vector2i, grid: Vector2i, position_3d: Vector3, scale_factor: float, prefix: String) -> void:
	var texture: Texture2D = load(texture_path)
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	var cell_size := Vector2(texture.get_width() / grid.x, texture.get_height() / grid.y)
	atlas.region = Rect2(Vector2(cell) * cell_size, cell_size)
	var sprite := Sprite3D.new()
	sprite.name = "%s_%02d" % [prefix, _object_count]
	sprite.texture = atlas
	sprite.position = position_3d
	sprite.pixel_size = 0.0075 * scale_factor
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.centered = false
	sprite.offset = Vector2(-cell_size.x * 0.5, -cell_size.y)
	$Objects.add_child(sprite)
	_object_count += 1


func _map_name() -> String:
	return "prologue_riverbank" if map_kind == MapKind.PROLOGUE_RIVERBANK else "chapter_01_training_ground"
