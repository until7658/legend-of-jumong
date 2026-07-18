extends Node

const MILESTONE: String = "M4"

@onready var title_screen: TitleScreen = %TitleScreen
@onready var river_cutscene: PrologueRiverCutscene = %RiverCutscene
@onready var prologue: PrologueDirector = %Prologue
@onready var training_battle: SquadBattleController = %TrainingBattle
@onready var opening_complete: Control = %OpeningComplete
@onready var completion_message: Label = %OpeningComplete.get_node("Message") as Label
@onready var save_service: SaveService = %SaveService

var _story_started: bool = false


func _ready() -> void:
	prologue.hide()
	opening_complete.hide()
	river_cutscene.hide()
	training_battle.hide()
	title_screen.new_game_requested.connect(_on_new_game_requested)
	title_screen.continue_requested.connect(_on_continue_requested)
	title_screen.quit_requested.connect(_on_quit_requested)
	prologue.prologue_finished.connect(_on_prologue_finished)
	prologue.map_shot_requested.connect(_on_map_shot_requested)
	training_battle.battle_finished.connect(_on_training_battle_finished)
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
	training_battle.show()
	training_battle.begin_battle()
	print("[FLOW] Opening complete -> commander squad training battle. skipped=%s" % skipped)


func _on_continue_requested(checkpoint: Dictionary) -> void:
	if _story_started:
		return
	_story_started = true
	title_screen.queue_free()
	var checkpoint_id: String = str(checkpoint.get("checkpoint_id", ""))
	if checkpoint_id == "m4_training_complete":
		completion_message.text = "훈련 완료\n주몽의 첫 분대가 편성되었습니다."
		opening_complete.show()
	else:
		training_battle.show()
		training_battle.begin_battle()
	print("[BOOTSTRAP] continue checkpoint=%s" % checkpoint_id)


func _on_training_battle_finished(victory: bool, summary: Dictionary) -> void:
	training_battle.hide()
	if victory:
		save_service.save_checkpoint("m4_training_complete", {"round": int(summary.get("round", 0))})
		completion_message.text = "훈련 승리\n주몽의 첫 분대가 편성되었습니다."
	else:
		completion_message.text = "훈련 종료\n대열을 정비해 다시 도전하세요."
	opening_complete.show()
	print("[FLOW] M4 training complete victory=%s" % victory)


func _on_map_shot_requested(cut_id: int) -> void:
	if cut_id <= 3:
		river_cutscene.start_shot(cut_id)
	else:
		river_cutscene.stop_cutscene()


func _on_quit_requested() -> void:
	get_tree().quit()
