class_name PrologueDirector
extends Control

signal cut_changed(cut_id: int, cut: Dictionary)
signal prologue_finished(skipped: bool)
signal map_shot_requested(cut_id: int)

const DATA_PATH: String = "res://data/narrative/prologue_cuts.json"
const BACKDROP_PATH: String = "res://assets/ui/title/keyvisual_dawn_river_stylized_02.png"
const ACTOR_PATHS: Dictionary = {
	"yuhwa": "res://assets/portraits/dialogue/yuhwa/calm.png",
	"fisherman": "res://assets/portraits/dialogue/fisherman/concerned.png",
	"ferry_warden": "res://assets/portraits/dialogue/ferry_warden/alert.png",
	"king_geumwa": "res://assets/portraits/dialogue/king_geumwa/neutral.png",
	"court_official": "res://assets/portraits/dialogue/court_official/neutral.png",
}
const BACKDROP_COLORS: Dictionary = {
	"river": Color(0.38, 0.52, 0.62, 1.0),
	"ferry": Color(0.38, 0.25, 0.17, 1.0),
	"palace": Color(0.18, 0.24, 0.31, 1.0),
	"chamber": Color(0.62, 0.52, 0.40, 1.0),
	"sky": Color(0.55, 0.68, 0.78, 1.0),
	"title": Color(0.72, 0.56, 0.38, 1.0),
}

@export_range(0.01, 4.0, 0.01) var duration_scale: float = 1.0

@onready var backdrop: TextureRect = %Backdrop
@onready var backdrop_tint: ColorRect = %BackdropTint
@onready var left_actor: TextureRect = %LeftActor
@onready var right_actor: TextureRect = %RightActor
@onready var scene_label: Label = %SceneLabel
@onready var cut_label: Label = %CutLabel
@onready var speaker_label: Label = %SpeakerLabel
@onready var line_label: Label = %LineLabel
@onready var progress_label: Label = %ProgressLabel
@onready var title_block: VBoxContainer = %TitleBlock
@onready var timer: Timer = %CutTimer
@onready var fade: ColorRect = %Fade
@onready var skip_dialog: ConfirmationDialog = %SkipDialog

var _cuts: Array[Dictionary] = []
var _cut_index: int = -1
var _running: bool = false


func _ready() -> void:
	backdrop.texture = load(BACKDROP_PATH) as Texture2D
	timer.timeout.connect(_advance)
	%ContinueButton.pressed.connect(_advance)
	%SkipButton.pressed.connect(func() -> void: skip_dialog.popup_centered())
	skip_dialog.confirmed.connect(_finish.bind(true))
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not _running:
		return
	if event.is_action_pressed(&"ui_accept"):
		_advance()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_cancel"):
		skip_dialog.popup_centered()
		get_viewport().set_input_as_handled()


func start_prologue() -> void:
	if _running:
		return
	_cuts = _load_cuts()
	if _cuts.is_empty():
		push_error("[PROLOGUE] No cuts available")
		return
	_cut_index = -1
	_running = true
	show()
	_advance()
	print("[PROLOGUE] Started 14-cut opening")


func _advance() -> void:
	if not _running:
		return
	timer.stop()
	_cut_index += 1
	if _cut_index >= _cuts.size():
		_finish(false)
		return
	_show_cut(_cuts[_cut_index])


func _show_cut(cut: Dictionary) -> void:
	var cut_id: int = int(cut.get("id", _cut_index + 1))
	var uses_map: bool = cut_id <= 3
	var backdrop_id: String = str(cut.get("backdrop", "river"))
	scene_label.text = str(cut.get("scene", "오프닝"))
	cut_label.text = "%02d · %s" % [cut_id, str(cut.get("title", ""))]
	progress_label.text = "%d / %d" % [cut_id, _cuts.size()]
	var speaker: String = str(cut.get("speaker", ""))
	var line: String = str(cut.get("line", cut.get("caption", "")))
	speaker_label.text = speaker if not speaker.is_empty() else "내레이션"
	line_label.text = line
	_set_actor(left_actor, str(cut.get("left", "")), false)
	_set_actor(right_actor, str(cut.get("right", "")), true)
	backdrop.visible = not uses_map
	backdrop_tint.visible = not uses_map
	left_actor.visible = left_actor.visible and not uses_map
	right_actor.visible = right_actor.visible and not uses_map
	map_shot_requested.emit(cut_id)
	var tint_color: Color = BACKDROP_COLORS.get(backdrop_id, Color.WHITE)
	backdrop_tint.color = tint_color
	backdrop_tint.color.a = 0.42 if backdrop_id in ["river", "sky", "title"] else 0.68
	title_block.visible = cut_id == 14
	var tween: Tween = create_tween()
	fade.color.a = 1.0
	tween.tween_property(fade, "color:a", 0.0, 0.45)
	cut_changed.emit(cut_id, cut.duplicate(true))
	var duration: float = maxf(float(cut.get("duration", 5.0)) * duration_scale, 0.1)
	timer.start(duration)
	print("[PROLOGUE] Cut %02d/%02d %s" % [cut_id, _cuts.size(), str(cut.get("title", ""))])


func _set_actor(target: TextureRect, actor_id: String, _flip: bool) -> void:
	target.visible = not actor_id.is_empty() and ACTOR_PATHS.has(actor_id)
	if not target.visible:
		return
	target.texture = load(str(ACTOR_PATHS[actor_id])) as Texture2D


func _finish(skipped: bool) -> void:
	if not _running:
		return
	_running = false
	timer.stop()
	var tween: Tween = create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.6)
	await tween.finished
	hide()
	prologue_finished.emit(skipped)
	print("[PROLOGUE] Finished skipped=%s" % skipped)


func _load_cuts() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not FileAccess.file_exists(DATA_PATH):
		return result
	var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return result
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return result
	for raw: Variant in (parsed as Dictionary).get("cuts", []):
		if raw is Dictionary:
			result.append(raw as Dictionary)
	return result
