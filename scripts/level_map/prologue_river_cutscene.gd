class_name PrologueRiverCutscene
extends Node2D

signal shot_finished(cut_id: int)

@onready var river_map: PrologueRiverCutsceneMap2D = %RiverMap
@onready var fisherman: PrologueFishermanActor = %Fisherman
@onready var yuhwa: PrologueYuhwaActor = %Yuhwa

var _active_tween: Tween
var _active_cut_id: int = 0


func _ready() -> void:
	hide()
	river_map.shot_finished.connect(_on_map_shot_finished)


func start_shot(cut_id: int) -> void:
	show()
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_cut_id = cut_id
	match cut_id:
		1:
			_setup_river_establishing()
		2:
			_play_boat_arrival()
		3:
			_play_rescue()
		_:
			_active_cut_id = 0
			hide()


func stop_cutscene() -> void:
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_cut_id = 0
	river_map.skip_active_shot()
	hide()


func _setup_river_establishing() -> void:
	fisherman.hide()
	yuhwa.hide()
	river_map.start_shot(1)


func _play_boat_arrival() -> void:
	fisherman.show()
	yuhwa.hide()
	fisherman.set_state_by_id(&"rowing")
	fisherman.position = Vector2(80.0, 584.0)
	river_map.start_shot(2)
	_active_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(fisherman, "position", Vector2(470.0, 294.0), river_map.boat_travel_seconds)


func _play_rescue() -> void:
	fisherman.show()
	yuhwa.show()
	fisherman.set_state_by_id(&"walking")
	yuhwa.set_state_by_id(&"breathing")
	river_map.start_shot(3)
	fisherman.position = Vector2(470.0, 390.0)
	yuhwa.position = river_map.get_rescue_marker().position
	_active_tween = create_tween()
	_active_tween.tween_property(fisherman, "position", yuhwa.position + Vector2(-54.0, 0.0), 2.0)
	_active_tween.tween_callback(func() -> void: fisherman.set_state_by_id(&"checking"))
	_active_tween.tween_interval(2.0)
	_active_tween.finished.connect(_finish_rescue)


func _finish_rescue() -> void:
	if _active_cut_id != 3:
		return
	_active_cut_id = 0
	shot_finished.emit(3)


func _on_map_shot_finished(_shot_id: String) -> void:
	if _active_cut_id != 1 and _active_cut_id != 2:
		return
	var finished_cut_id: int = _active_cut_id
	_active_cut_id = 0
	shot_finished.emit(finished_cut_id)
