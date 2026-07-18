class_name PrologueRiverCutsceneMap2D
extends Node2D

signal map_ready(map_id: String)
signal shot_started(shot_id: String)
signal shot_finished(shot_id: String)

const MAP_ID: String = "prologue_river_cuts_01_03_2d"
const TERRAIN_PATH: String = "res://assets/tiles/golden_candidates/prologue_river_terrain_candidate_v02.png"
const TILE_SOURCE_SIZE: int = 256
const TILE_WORLD_SIZE: int = 128
const GRID_SIZE: Vector2i = Vector2i(10, 6)
const SHORE_X_BY_ROW: PackedInt32Array = [3, 4, 3, 4, 4, 3]

@export_range(0.1, 20.0, 0.1) var camera_travel_seconds: float = 4.5
@export_range(0.1, 30.0, 0.1) var boat_travel_seconds: float = 8.0

var _camera_tween: Tween
var _boat_tween: Tween
var _active_shot_id: String = ""


func _ready() -> void:
	_build_tile_layers()
	_configure_navigation_draft()
	_snap_to_marker(1)
	map_ready.emit.call_deferred(MAP_ID)
	print("[PROLOGUE_RIVER_2D] ready tiles=%d" % (GRID_SIZE.x * GRID_SIZE.y))


func start_shot(shot_index: int) -> void:
	var index: int = clampi(shot_index, 1, 3)
	_cancel_motion()
	_active_shot_id = "prologue_river_cut_%02d_2d" % index
	shot_started.emit(_active_shot_id)
	_snap_to_marker(index)
	if index == 2:
		_play_cut_two()
	else:
		_finish_static_shot.call_deferred()


func skip_active_shot() -> void:
	if _active_shot_id.is_empty():
		return
	_cancel_motion()
	if _active_shot_id == "prologue_river_cut_02_2d":
		$CameraTravelPath2D/CameraFollow2D.progress_ratio = 1.0
		$BoatTravelPath2D/BoatFollow2D.progress_ratio = 1.0
	var finished_id: String = _active_shot_id
	_active_shot_id = ""
	shot_finished.emit(finished_id)


func get_rescue_marker() -> Marker2D:
	return $Markers/RescueMarker2D as Marker2D


func get_gameplay_camera_marker() -> Marker2D:
	return $Markers/GameplayCameraMarker2D as Marker2D


func _play_cut_two() -> void:
	$CameraTravelPath2D/CameraFollow2D.progress_ratio = 0.0
	$BoatTravelPath2D/BoatFollow2D.progress_ratio = 0.0
	_camera_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_camera_tween.tween_property($CameraTravelPath2D/CameraFollow2D, "progress_ratio", 1.0, camera_travel_seconds)
	_boat_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_boat_tween.tween_property($BoatTravelPath2D/BoatFollow2D, "progress_ratio", 1.0, boat_travel_seconds)
	_boat_tween.finished.connect(_finish_cut_two)


func _finish_cut_two() -> void:
	if _active_shot_id != "prologue_river_cut_02_2d":
		return
	var finished_id: String = _active_shot_id
	_active_shot_id = ""
	shot_finished.emit(finished_id)


func _finish_static_shot() -> void:
	if _active_shot_id.is_empty():
		return
	var finished_id: String = _active_shot_id
	_active_shot_id = ""
	shot_finished.emit(finished_id)


func _cancel_motion() -> void:
	if _camera_tween != null:
		_camera_tween.kill()
	if _boat_tween != null:
		_boat_tween.kill()


func _snap_to_marker(index: int) -> void:
	var marker: Marker2D = get_node("Markers/Cut%02dCameraMarker2D" % index) as Marker2D
	$CameraTravelPath2D/CameraFollow2D.global_position = marker.global_position


func _build_tile_layers() -> void:
	var texture: Texture2D = load(TERRAIN_PATH) as Texture2D
	for y: int in range(GRID_SIZE.y):
		var shore_x: int = SHORE_X_BY_ROW[y]
		for x: int in range(GRID_SIZE.x):
			var layer: Node2D
			var cell: Vector2i
			if x < shore_x:
				layer = $Water
				cell = Vector2i((x + y) % 2, 1)
			elif x == shore_x:
				layer = $Shore
				cell = Vector2i(3 if y % 2 == 0 else 2, 2)
			else:
				layer = $Ground
				cell = Vector2i((x + y) % 2, 0)
			_add_tile(layer, texture, cell, Vector2i(x, y))


func _add_tile(layer: Node2D, texture: Texture2D, atlas_cell: Vector2i, grid_cell: Vector2i) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(Vector2(atlas_cell * TILE_SOURCE_SIZE), Vector2(TILE_SOURCE_SIZE, TILE_SOURCE_SIZE))
	var sprite := Sprite2D.new()
	sprite.texture = atlas
	sprite.centered = false
	sprite.scale = Vector2(0.5, 0.5)
	sprite.position = Vector2(grid_cell * TILE_WORLD_SIZE)
	layer.add_child(sprite)


func _configure_navigation_draft() -> void:
	var polygon := NavigationPolygon.new()
	polygon.vertices = PackedVector2Array([Vector2(520, 32), Vector2(1248, 32), Vector2(1248, 736), Vector2(520, 736)])
	polygon.add_polygon(PackedInt32Array([0, 1, 2, 3]))
	$NavigationRegion2D.navigation_polygon = polygon
