class_name DialogueBox
extends PanelContainer

signal advance_requested

@onready var speaker_label: Label = %SpeakerLabel
@onready var dialogue_label: Label = %DialogueLabel
@onready var portrait: TextureRect = %Portrait
@onready var advance_button: Button = %AdvanceButton


func _ready() -> void:
	advance_button.pressed.connect(_request_advance)
	advance_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_accept"):
		_request_advance()
		get_viewport().set_input_as_handled()


func present(entry: Dictionary, is_last: bool = false) -> void:
	var speaker: String = str(entry.get("speaker", "내레이션")).strip_edges()
	var line: String = str(entry.get("line", "…")).strip_edges()
	speaker_label.text = speaker if not speaker.is_empty() else "내레이션"
	dialogue_label.text = line if not line.is_empty() else "…"
	advance_button.text = "마치기" if is_last else "계속"
	_apply_portrait(str(entry.get("portrait", "")))
	advance_button.grab_focus()


func _apply_portrait(path: String) -> void:
	portrait.texture = null
	portrait.visible = false
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var resource: Resource = load(path)
	if resource is Texture2D:
		portrait.texture = resource as Texture2D
		portrait.visible = true


func _request_advance() -> void:
	advance_requested.emit()
