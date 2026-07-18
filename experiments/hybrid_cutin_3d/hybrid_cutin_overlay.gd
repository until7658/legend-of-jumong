extends Control

## Draw-only 2D presentation layer for the isolated hybrid cut-in spike.
## It never calculates combat results; it only visualizes a resolved payload.

const MAX_VISIBLE_SOLDIERS: int = 8
const ALLY_COLOR := Color("#d9a441")
const ALLY_ACCENT := Color("#f3df9a")
const ENEMY_COLOR := Color("#4c718f")
const ENEMY_ACCENT := Color("#b8d0db")
const SHADOW_COLOR := Color(0.04, 0.05, 0.06, 0.48)
const HIT_COLOR := Color("#fff0a8")

var _payload: Dictionary = {}
var _phase: float = 0.0
var _playing: bool = false


func set_presentation(payload: Dictionary, phase: float, playing: bool) -> void:
	_payload = payload.duplicate(true)
	_phase = clampf(phase, 0.0, 1.0)
	_playing = playing
	queue_redraw()


func visible_figure_count() -> int:
	var ally_count: int = clampi(int(_payload.get("attacker_soldiers_before", 8)), 0, MAX_VISIBLE_SOLDIERS)
	var enemy_count: int = clampi(int(_payload.get("defender_soldiers_before", 8)), 0, MAX_VISIBLE_SOLDIERS)
	return 2 + ally_count + enemy_count


func _draw() -> void:
	if _payload.is_empty():
		return
	var center_y: float = size.y * 0.58
	var ally_advance: float = _attack_advance(true)
	var enemy_advance: float = _attack_advance(false)
	_draw_squad(true, Vector2(size.x * 0.27 + ally_advance, center_y), ALLY_COLOR, ALLY_ACCENT)
	_draw_squad(false, Vector2(size.x * 0.73 - enemy_advance, center_y), ENEMY_COLOR, ENEMY_ACCENT)
	_draw_impact_fx(Vector2(size.x * 0.5, center_y - 18.0))


func _draw_squad(is_attacker: bool, anchor: Vector2, body_color: Color, accent_color: Color) -> void:
	var before_key: String = "attacker_soldiers_before" if is_attacker else "defender_soldiers_before"
	var after_key: String = "attacker_soldiers_after" if is_attacker else "defender_soldiers_after"
	var before_count: int = clampi(int(_payload.get(before_key, 8)), 0, MAX_VISIBLE_SOLDIERS)
	var after_count: int = clampi(int(_payload.get(after_key, before_count)), 0, before_count)
	var facing: float = 1.0 if is_attacker else -1.0
	for index in range(before_count):
		var row: int = index / 4
		var column: int = index % 4
		var soldier_position := anchor + Vector2(facing * (-42.0 - column * 24.0), row * 34.0 - 8.0)
		var survives: bool = index < after_count
		_draw_sd_figure(soldier_position, facing, body_color, accent_color, false, survives)
	_draw_sd_figure(anchor + Vector2(facing * -4.0, -18.0), facing, body_color, accent_color, true, true)


func _draw_sd_figure(
	position: Vector2,
	facing: float,
	body_color: Color,
	accent_color: Color,
	commander: bool,
	survives: bool
) -> void:
	var retreat: float = 0.0
	var alpha: float = 1.0
	if not survives and _phase > 0.56:
		var defeat_phase: float = inverse_lerp(0.56, 1.0, _phase)
		retreat = -facing * defeat_phase * 18.0
		alpha = 1.0 - defeat_phase * 0.7
	var p := position + Vector2(retreat, 0.0)
	var scale_factor: float = 1.18 if commander else 0.9
	var shadow_width: float = 17.0 * scale_factor
	draw_set_transform(p, 0.0, Vector2.ONE)
	_draw_ellipse_2d(Vector2(0.0, 11.0 * scale_factor), Vector2(shadow_width, 6.0 * scale_factor), SHADOW_COLOR)
	var body := body_color
	body.a *= alpha
	var accent := accent_color
	accent.a *= alpha
	draw_rect(Rect2(-8.0 * scale_factor, -5.0 * scale_factor, 16.0 * scale_factor, 20.0 * scale_factor), body)
	draw_circle(Vector2(0.0, -12.0 * scale_factor), 8.0 * scale_factor, accent)
	draw_rect(Rect2(-9.0 * scale_factor, -18.0 * scale_factor, 18.0 * scale_factor, 5.0 * scale_factor), body)
	draw_line(Vector2(facing * 5.0, -2.0) * scale_factor, Vector2(facing * 17.0, 7.0) * scale_factor, accent, 3.0 * scale_factor)
	if commander:
		draw_line(Vector2(-7.0, -22.0) * scale_factor, Vector2(0.0, -28.0) * scale_factor, accent, 3.0)
		draw_line(Vector2(0.0, -28.0) * scale_factor, Vector2(7.0, -22.0) * scale_factor, accent, 3.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_ellipse_2d(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(16):
		var angle: float = TAU * float(index) / 16.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)


func _draw_impact_fx(center: Vector2) -> void:
	if not _playing or _phase < 0.36 or _phase > 0.72:
		return
	var intensity: float = 1.0 - absf(_phase - 0.54) / 0.18
	var radius: float = lerpf(8.0, 42.0, clampf(intensity, 0.0, 1.0))
	for index in range(8):
		var angle: float = TAU * float(index) / 8.0
		var direction := Vector2(cos(angle), sin(angle))
		draw_line(center + direction * 8.0, center + direction * radius, HIT_COLOR, 3.0)
	draw_circle(center, 6.0 + intensity * 6.0, Color(1.0, 0.82, 0.35, 0.7))


func _attack_advance(is_attacker: bool) -> float:
	if not _playing:
		return 0.0
	if _phase < 0.38:
		return ease(_phase / 0.38, 2.0) * 64.0
	if _phase < 0.62:
		return 64.0
	var retreat_phase: float = inverse_lerp(0.62, 1.0, _phase)
	var side_scale: float = 1.0 if is_attacker else 0.72
	return lerpf(64.0, 20.0, retreat_phase) * side_scale
