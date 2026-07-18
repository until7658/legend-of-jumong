extends Node

const MILESTONE: String = "M3"

@onready var title_screen: TitleScreen = %TitleScreen
@onready var river_cutscene: PrologueRiverCutscene = %RiverCutscene
@onready var prologue: PrologueDirector = %Prologue
@onready var opening_complete: Control = %OpeningComplete

var _story_started: bool = false


func _ready() -> void:
	prologue.hide()
	opening_complete.hide()
	river_cutscene.hide()
	title_screen.new_game_requested.connect(_on_new_game_requested)
	title_screen.quit_requested.connect(_on_quit_requested)
	prologue.prologue_finished.connect(_on_prologue_finished)
	prologue.map_shot_requested.connect(_on_map_shot_requested)
	print("[BOOTSTRAP] %s title screen ready" % MILESTONE)


func _on_new_game_requested() -> void:
	if _story_started:
		return
	_story_started = true
	title_screen.queue_free()
	prologue.start_prologue()
	print("[BOOTSTRAP] %s opening-only route started: title -> 14-cut prologue" % MILESTONE)


func _on_prologue_finished(skipped: bool) -> void:
	river_cutscene.stop_cutscene()
	opening_complete.show()
	print("[FLOW] Opening complete; Chapter 01 intentionally not started. skipped=%s" % skipped)


func _on_map_shot_requested(cut_id: int) -> void:
	if cut_id <= 3:
		river_cutscene.start_shot(cut_id)
	else:
		river_cutscene.stop_cutscene()


func _on_quit_requested() -> void:
	get_tree().quit()
