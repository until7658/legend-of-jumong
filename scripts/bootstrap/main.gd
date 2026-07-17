extends Node

const MILESTONE: String = "M2"

@onready var world: Hd2dTestWorld = %Hd2dTestWorld
@onready var hud: Hd2dTestHud = %Hd2dTestHud
@onready var title_screen: TitleScreen = %TitleScreen
@onready var narrative_sequence: NarrativeSequence = %NarrativeSequence
@onready var prologue_map: NarrativeMapPreview = %PrologueMap
@onready var chapter_01_map: NarrativeMapPreview = %Chapter01Map

var _story_started: bool = false


func _ready() -> void:
	world.hide()
	hud.hide()
	narrative_sequence.hide()
	prologue_map.hide()
	chapter_01_map.hide()
	hud.camera_reset_requested.connect(_on_camera_reset_requested)
	hud.interaction_requested.connect(_on_interaction_requested)
	title_screen.new_game_requested.connect(_on_new_game_requested)
	title_screen.quit_requested.connect(_on_quit_requested)
	narrative_sequence.sequence_started.connect(_on_sequence_started)
	narrative_sequence.all_sequences_finished.connect(_on_all_sequences_finished)
	hud.set_location("HD-2D 시험장")
	hud.set_status("%s 통합 환경 준비 완료" % MILESTONE)
	hud.set_interaction_enabled(true, "표식 확인")
	print("[BOOTSTRAP] %s title screen ready" % MILESTONE)


func _on_new_game_requested() -> void:
	if _story_started:
		return
	_story_started = true
	title_screen.queue_free()
	narrative_sequence.show()
	narrative_sequence.start_sequence()
	print("[BOOTSTRAP] %s story route started: title -> prologue -> chapter_01" % MILESTONE)


func _on_sequence_started(sequence_id: String) -> void:
	if not _story_started:
		return
	if sequence_id.begins_with("prologue"):
		chapter_01_map.hide()
		prologue_map.start_scene({"sequence_id": sequence_id})
		print("[FLOW] Prologue riverbank active")
	elif sequence_id.begins_with("chapter_01"):
		prologue_map.finish_scene({"next": sequence_id})
		prologue_map.hide()
		chapter_01_map.start_scene({"sequence_id": sequence_id})
		print("[FLOW] Chapter 01 training ground active")


func _on_all_sequences_finished() -> void:
	narrative_sequence.hide()
	prologue_map.hide()
	chapter_01_map.start_scene({"sequence_id": "chapter_01", "narrative_complete": true})
	print("[FLOW] Opening and Chapter 01 narrative complete; chapter map retained")


func _on_quit_requested() -> void:
	get_tree().quit()


func _on_camera_reset_requested() -> void:
	world.reset_camera()
	hud.set_status("시험 시점을 초기화했습니다.")


func _on_interaction_requested() -> void:
	hud.set_status("플레이스홀더 표식 명령을 확인했습니다.")
