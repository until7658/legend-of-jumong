extends Node

const MILESTONE: String = "M3"

@onready var world: Hd2dTestWorld = %Hd2dTestWorld
@onready var hud: Hd2dTestHud = %Hd2dTestHud
@onready var title_screen: TitleScreen = %TitleScreen
@onready var prologue: PrologueDirector = %Prologue
@onready var opening_complete: Control = %OpeningComplete

var _story_started: bool = false


func _ready() -> void:
	world.hide()
	hud.hide()
	prologue.hide()
	opening_complete.hide()
	hud.camera_reset_requested.connect(_on_camera_reset_requested)
	hud.interaction_requested.connect(_on_interaction_requested)
	title_screen.new_game_requested.connect(_on_new_game_requested)
	title_screen.quit_requested.connect(_on_quit_requested)
	prologue.prologue_finished.connect(_on_prologue_finished)
	hud.set_location("HD-2D 시험장")
	hud.set_status("%s 통합 환경 준비 완료" % MILESTONE)
	hud.set_interaction_enabled(true, "표식 확인")
	print("[BOOTSTRAP] %s title screen ready" % MILESTONE)


func _on_new_game_requested() -> void:
	if _story_started:
		return
	_story_started = true
	title_screen.queue_free()
	prologue.start_prologue()
	print("[BOOTSTRAP] %s opening-only route started: title -> 14-cut prologue" % MILESTONE)


func _on_prologue_finished(skipped: bool) -> void:
	opening_complete.show()
	print("[FLOW] Opening complete; Chapter 01 intentionally not started. skipped=%s" % skipped)


func _on_quit_requested() -> void:
	get_tree().quit()


func _on_camera_reset_requested() -> void:
	world.reset_camera()
	hud.set_status("시험 시점을 초기화했습니다.")


func _on_interaction_requested() -> void:
	hud.set_status("플레이스홀더 표식 명령을 확인했습니다.")
