class_name Hd2dTestWorld
extends Node3D

@export_range(0.0, 0.25, 0.01) var bob_height: float = 0.06
@export_range(0.1, 4.0, 0.1) var bob_speed: float = 1.5

@onready var character_anchor: Node3D = %CharacterAnchor
@onready var camera_rig: Node3D = %CameraRig

var _elapsed: float = 0.0
var _character_origin: Vector3
var _camera_origin: Transform3D


func _ready() -> void:
	_character_origin = character_anchor.position
	_camera_origin = camera_rig.transform


func _process(delta: float) -> void:
	_elapsed += delta
	character_anchor.position = _character_origin + Vector3.UP * sin(_elapsed * bob_speed) * bob_height


func reset_camera() -> void:
	camera_rig.transform = _camera_origin
