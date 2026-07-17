class_name NarrativeSequence
extends Control

signal sequence_started(sequence_id: String)
signal entry_changed(sequence_id: String, index: int, entry: Dictionary)
signal sequence_changed(sequence_id: String)
signal sequence_finished(sequence_id: String)
signal all_sequences_finished

const DEFAULT_PROLOGUE_PATH: String = "res://data/narrative/prologue.json"
const DEFAULT_CHAPTER_PATH: String = "res://data/narrative/chapter_01.json"

@onready var backdrop: ColorRect = %Backdrop
@onready var sequence_label: Label = %SequenceLabel
@onready var scene_label: Label = %SceneLabel
@onready var progress_label: Label = %ProgressLabel
@onready var dialogue_box: DialogueBox = %DialogueBox

var _sequences: Array[Dictionary] = []
var _sequence_index: int = 0
var _entry_index: int = 0
var _running: bool = false


func _ready() -> void:
	dialogue_box.advance_requested.connect(_advance)
	start_sequence()


func start_sequence(prologue_path: String = DEFAULT_PROLOGUE_PATH, chapter_path: String = DEFAULT_CHAPTER_PATH) -> void:
	_sequences.clear()
	var prologue: Dictionary = _load_json(prologue_path)
	var chapter: Dictionary = _load_json(chapter_path)
	if not prologue.is_empty():
		_sequences.append(_build_prologue(prologue))
	if not chapter.is_empty():
		_sequences.append(_build_chapter(chapter))
	_sequence_index = 0
	_entry_index = 0
	_running = not _sequences.is_empty()
	if not _running:
		_show_error("서사 데이터를 불러오지 못했습니다.")
		return
	sequence_started.emit(_current_id())
	_show_current_entry()


func _advance() -> void:
	if not _running:
		return
	var entries: Array = _current_sequence().get("entries", []) as Array
	_entry_index += 1
	if _entry_index < entries.size():
		_show_current_entry()
		return
	var finished_id: String = _current_id()
	sequence_finished.emit(finished_id)
	_sequence_index += 1
	_entry_index = 0
	if _sequence_index >= _sequences.size():
		_running = false
		all_sequences_finished.emit()
		return
	sequence_changed.emit(_current_id())
	sequence_started.emit(_current_id())
	_show_current_entry()


func _show_current_entry() -> void:
	var sequence: Dictionary = _current_sequence()
	var entries: Array = sequence.get("entries", []) as Array
	if entries.is_empty():
		_advance()
		return
	var entry: Dictionary = entries[_entry_index] as Dictionary
	sequence_label.text = str(sequence.get("title", "이야기"))
	scene_label.text = str(entry.get("scene", ""))
	progress_label.text = "%d / %d" % [_entry_index + 1, entries.size()]
	dialogue_box.present(entry, _sequence_index == _sequences.size() - 1 and _entry_index == entries.size() - 1)
	entry_changed.emit(_current_id(), _entry_index, entry)


func _build_prologue(data: Dictionary) -> Dictionary:
	var entries: Array[Dictionary] = []
	entries.append({"speaker": "내레이션", "line": str(data.get("start", "새벽의 강")), "scene": "오프닝"})
	for raw: Variant in data.get("dialogue", []):
		if raw is Dictionary:
			var item: Dictionary = raw as Dictionary
			entries.append({"speaker": str(item.get("speaker", "내레이션")), "line": str(item.get("line", "…")), "portrait": str(item.get("portrait", "")), "scene": "강에서 온 여인"})
	var transition: Dictionary = data.get("chapter_01_transition", {}) as Dictionary
	entries.append({"speaker": "내레이션", "line": str(transition.get("time_card", "열일곱 해 뒤, 동부여")), "scene": "시간의 전환"})
	return {"id": str(data.get("id", "prologue")), "title": str(data.get("title", "오프닝")), "entries": entries}


func _build_chapter(data: Dictionary) -> Dictionary:
	var entries: Array[Dictionary] = []
	for raw_scene: Variant in data.get("scenes", []):
		if not raw_scene is Dictionary:
			continue
		var scene: Dictionary = raw_scene as Dictionary
		var scene_title: String = "%d. %s" % [int(scene.get("id", entries.size() + 1)), str(scene.get("title", "장면"))]
		for raw_beat: Variant in scene.get("beats", []):
			entries.append({"speaker": "내레이션", "line": str(raw_beat), "scene": scene_title})
	return {"id": str(data.get("id", "chapter_01")), "title": "제1장 · %s" % str(data.get("title", "이름 없는 왕자")), "entries": entries}


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("[NARRATIVE] Missing data: %s" % path)
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[NARRATIVE] Cannot open data: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("[NARRATIVE] Invalid JSON root: %s" % path)
		return {}
	return parsed as Dictionary


func _current_sequence() -> Dictionary:
	return _sequences[_sequence_index]


func _current_id() -> String:
	return str(_current_sequence().get("id", "unknown"))


func _show_error(message: String) -> void:
	sequence_label.text = "이야기를 시작할 수 없습니다"
	scene_label.text = "데이터 오류"
	progress_label.text = ""
	dialogue_box.present({"speaker": "안내", "line": message}, true)
