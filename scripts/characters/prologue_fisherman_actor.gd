class_name PrologueFishermanActor
extends Node2D

signal state_changed(state_id: StringName)

const TEXTURE_PATHS: Dictionary = {
	&"front": "res://assets/characters/prologue/fisherman_front_base_v1.png",
	&"back": "res://assets/characters/prologue/fisherman_back_base_v1.png",
	&"left": "res://assets/characters/prologue/fisherman_left_base_v1.png",
}

enum State { IDLE, ROWING, WALKING, CHECKING }

const STATE_IDS: Dictionary = {
	State.IDLE: &"idle",
	State.ROWING: &"rowing",
	State.WALKING: &"walking",
	State.CHECKING: &"checking",
}

@export var initial_state: State = State.IDLE
@export var show_candidate_label: bool = false

@onready var visual: Node2D = %Visual
@onready var body: Sprite2D = %Body
@onready var oar: Line2D = %Oar
@onready var placeholder_label: Label = %PlaceholderLabel

var _state: State = State.IDLE
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
	oar.visible = _state == State.ROWING
	body.texture = _texture_for_state(_state)
	state_changed.emit(get_state_id())


func set_state_by_id(state_id: StringName) -> bool:
	for key: Variant in STATE_IDS:
		if STATE_IDS[key] == state_id:
			set_state(key as State)
			return true
	push_warning("[FISHERMAN_PLACEHOLDER] Unknown state: %s" % state_id)
	return false


func get_state_id() -> StringName:
	return STATE_IDS.get(_state, &"idle") as StringName


func _fit_placeholder_texture() -> void:
	if body.texture == null:
		push_error("[FISHERMAN_PLACEHOLDER] Missing concept texture")
		return
	if body.texture.get_size() != Vector2(384.0, 384.0):
		push_warning("[FISHERMAN_CANDIDATE] Expected 384x384 texture")
	visual.scale = Vector2.ONE
	placeholder_label.position = Vector2(-92.0, 18.0)


func _texture_for_state(state: State) -> Texture2D:
	var direction: StringName = &"front" if state == State.IDLE else &"left"
	return load(str(TEXTURE_PATHS[direction])) as Texture2D


func _apply_pose() -> void:
	match _state:
		State.IDLE:
			visual.position.y = sin(_elapsed * 2.0) * 1.2
			visual.rotation = sin(_elapsed * 1.3) * 0.006
		State.ROWING:
			var stroke: float = sin(_elapsed * 2.7)
			visual.position = Vector2(stroke * 2.0, absf(stroke) * 1.5)
			visual.rotation = -0.055 + stroke * 0.075
			oar.rotation = -0.35 + stroke * 0.52
		State.WALKING:
			var step: float = sin(_elapsed * 7.0)
			visual.position = Vector2(step * 2.0, -absf(step) * 3.0)
			visual.rotation = step * 0.012
		State.CHECKING:
			var settle: float = 1.0 - exp(-_elapsed * 5.0)
			visual.position = Vector2(8.0 * settle, 12.0 * settle)
			visual.rotation = 0.16 * settle + sin(_elapsed * 2.0) * 0.008
