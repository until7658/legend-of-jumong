class_name PrologueYuhwaActor
extends Node2D

signal state_changed(state_id: StringName)

const COLLAPSED_TEXTURE_PATH: String = "res://assets/characters/prologue/yuhwa_collapsed_base_v1.png"

enum State { COLLAPSED, BREATHING }

const STATE_IDS: Dictionary = {
	State.COLLAPSED: &"collapsed",
	State.BREATHING: &"breathing",
}

@export var initial_state: State = State.BREATHING
@export var show_candidate_label: bool = false

@onready var visual: Node2D = %Visual
@onready var body: Sprite2D = %Body
@onready var placeholder_label: Label = %PlaceholderLabel

var _state: State = State.BREATHING
var _elapsed: float = 0.0
var _base_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	_fit_placeholder_texture()
	_base_scale = visual.scale
	placeholder_label.visible = show_candidate_label
	set_state(initial_state, true)


func _process(delta: float) -> void:
	_elapsed += delta
	_apply_pose()


func set_state(next_state: State, force: bool = false) -> void:
	if not force and _state == next_state:
		return
	_state = next_state
	_elapsed = 0.0
	visual.position = Vector2.ZERO
	visual.rotation = 0.0
	visual.scale = _base_scale
	body.texture = load(COLLAPSED_TEXTURE_PATH) as Texture2D
	state_changed.emit(get_state_id())


func set_state_by_id(state_id: StringName) -> bool:
	for key: Variant in STATE_IDS:
		if STATE_IDS[key] == state_id:
			set_state(key as State)
			return true
	push_warning("[YUHWA_PLACEHOLDER] Unknown state: %s" % state_id)
	return false


func get_state_id() -> StringName:
	return STATE_IDS.get(_state, &"collapsed") as StringName


func _fit_placeholder_texture() -> void:
	if body.texture == null:
		push_error("[YUHWA_PLACEHOLDER] Missing concept texture")
		return
	if body.texture.get_size() != Vector2(384.0, 384.0):
		push_warning("[YUHWA_CANDIDATE] Expected 384x384 texture")
	visual.scale = Vector2.ONE


func _apply_pose() -> void:
	visual.rotation = 0.0
	if _state == State.COLLAPSED:
		visual.position = Vector2.ZERO
		visual.scale = _base_scale
		return
	var breath: float = (sin(_elapsed * 1.35) + 1.0) * 0.5
	visual.position = Vector2(0.0, -breath * 1.2)
	visual.scale = Vector2(_base_scale.x, _base_scale.y * (1.0 + breath * 0.008))
