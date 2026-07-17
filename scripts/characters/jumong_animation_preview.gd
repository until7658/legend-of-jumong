extends Node2D

const FRAME_ROOT: String = "res://assets/characters/jumong/frames_v1"
const ANIMATION_ORDER: Array[String] = [
	"idle",
	"walk_front",
	"walk_left",
	"walk_back",
	"walk_right",
	"combat_idle",
	"draw_bow",
	"read_wind",
	"precision_shot",
	"hit",
	"evade",
	"defeat",
]
const DISPLAY_NAMES: Dictionary = {
	"idle": "대기",
	"walk_front": "걷기 · 정면",
	"walk_left": "걷기 · 왼쪽",
	"walk_back": "걷기 · 후면",
	"walk_right": "걷기 · 오른쪽",
	"combat_idle": "전투 대기",
	"draw_bow": "활 꺼내기",
	"read_wind": "바람 가늠",
	"precision_shot": "정밀 사격",
	"hit": "피격",
	"evade": "회피",
	"defeat": "쓰러짐",
}
const LOOPING_ANIMATIONS: Array[String] = [
	"idle", "walk_front", "walk_left", "walk_back", "walk_right", "combat_idle"
]

@onready var character: AnimatedSprite2D = %Character
@onready var animation_label: Label = %AnimationLabel

var _animation_index: int = 0
var _elapsed: float = 0.0
var _hold_time: float = 2.4


func _ready() -> void:
	character.sprite_frames = _build_sprite_frames()
	_play_current_animation()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _hold_time:
		_step_animation(1)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_LEFT:
		_step_animation(-1)
	elif event.keycode == KEY_RIGHT or event.keycode == KEY_SPACE:
		_step_animation(1)


func _build_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	_add_animation(frames, "idle", "walk_front", 1, 1.0, true)
	_add_animation(frames, "walk_front", "walk_front", 4, 7.0, true)
	_add_animation(frames, "walk_left", "walk_left", 4, 7.0, true)
	_add_animation(frames, "walk_back", "walk_back", 4, 7.0, true)
	_add_animation(frames, "walk_right", "walk_right", 4, 7.0, true)
	_add_animation(frames, "combat_idle", "combat_idle", 4, 5.0, true)
	_add_animation(frames, "draw_bow", "draw_bow", 4, 8.0, false)
	_add_animation(frames, "read_wind", "read_wind", 4, 6.0, false)
	_add_animation(frames, "precision_shot", "precision_shot", 4, 10.0, false)
	_add_animation(frames, "hit", "hit", 4, 10.0, false)
	_add_animation(frames, "evade", "evade", 4, 10.0, false)
	_add_animation(frames, "defeat", "defeat", 4, 6.0, false)
	return frames


func _add_animation(
	frames: SpriteFrames,
	animation_name: String,
	file_prefix: String,
	frame_count: int,
	fps: float,
	loops: bool
) -> void:
	var animation_id := StringName(animation_name)
	frames.add_animation(animation_id)
	frames.set_animation_speed(animation_id, fps)
	frames.set_animation_loop(animation_id, loops)
	for frame_index: int in range(frame_count):
		var path := "%s/%s_%02d.png" % [FRAME_ROOT, file_prefix, frame_index]
		var texture := load(path) as Texture2D
		if texture == null:
			push_error("주몽 애니메이션 프레임을 불러오지 못했습니다: %s" % path)
			continue
		frames.add_frame(animation_id, texture)


func _step_animation(direction: int) -> void:
	_animation_index = wrapi(_animation_index + direction, 0, ANIMATION_ORDER.size())
	_play_current_animation()


func _play_current_animation() -> void:
	_elapsed = 0.0
	var animation_name: String = ANIMATION_ORDER[_animation_index]
	character.play(StringName(animation_name))
	animation_label.text = "%02d / %02d   %s" % [
		_animation_index + 1,
		ANIMATION_ORDER.size(),
		DISPLAY_NAMES[animation_name],
	]
	_hold_time = 2.4 if animation_name in LOOPING_ANIMATIONS else 1.8
