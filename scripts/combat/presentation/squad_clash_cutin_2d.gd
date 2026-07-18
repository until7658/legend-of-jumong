class_name SquadClashCutin2D
extends Control

signal presentation_finished(payload: Dictionary)

enum Phase {
	PREPARE,
	IMPACT,
	RETREAT,
}

const PHASE_DURATIONS: Array[float] = [0.42, 0.56, 0.44]
const MAX_SOLDIERS: int = 8
const FORMATION_OFFSETS: Array[Vector2] = [
	Vector2(-58.0, -58.0), Vector2(-18.0, -40.0), Vector2(22.0, -22.0),
	Vector2(-76.0, -10.0), Vector2(-36.0, 8.0), Vector2(4.0, 26.0),
	Vector2(-56.0, 48.0), Vector2(-16.0, 66.0),
]

@onready var skip_button: Button = %SkipButton

var _play_queue: Array[Dictionary] = []
var _active_payload: Dictionary = {}
var _source_payload: Dictionary = {}
var _phase: Phase = Phase.PREPARE
var _phase_elapsed: float = 0.0
var _playback_speed: float = 1.0
var _playing: bool = false


func _ready() -> void:
	skip_button.pressed.connect(skip)
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)
	hide()


func play_clash(payload: Dictionary) -> void:
	_play_queue.append(payload.duplicate(true))
	if not _playing:
		_start_next()


func skip() -> void:
	if _playing:
		_finish_current()


func get_render_snapshot() -> Dictionary:
	return {
		"playing": _playing,
		"queued": _play_queue.size(),
		"phase": Phase.keys()[_phase],
		"attacker_actors": 1 + _visible_soldiers(true),
		"defender_actors": 1 + _visible_soldiers(false),
		"stage_size": size,
	}


func _process(delta: float) -> void:
	if not _playing:
		return
	_phase_elapsed += delta * _playback_speed
	var phase_duration: float = PHASE_DURATIONS[int(_phase)]
	while _phase_elapsed >= phase_duration and _playing:
		_phase_elapsed -= phase_duration
		if _phase == Phase.RETREAT:
			_finish_current()
			break
		_phase = int(_phase) + 1
		phase_duration = PHASE_DURATIONS[int(_phase)]
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	var game_cancel_pressed: bool = InputMap.has_action(&"game_cancel") and event.is_action_pressed(&"game_cancel")
	if _playing and (event.is_action_pressed(&"ui_cancel") or game_cancel_pressed):
		skip()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _start_next() -> void:
	if _play_queue.is_empty():
		return
	_source_payload = _play_queue.pop_front()
	_active_payload = _normalize_payload(_source_payload)
	_phase = Phase.PREPARE
	_phase_elapsed = 0.0
	_playback_speed = clampf(float(_active_payload.get("playback_speed", 1.0)), 0.25, 8.0)
	_playing = true
	show()
	set_process(true)
	skip_button.grab_focus()
	queue_redraw()


func _finish_current() -> void:
	var completed_payload: Dictionary = _source_payload.duplicate(true)
	_playing = false
	set_process(false)
	hide()
	_active_payload.clear()
	_source_payload.clear()
	presentation_finished.emit(completed_payload)
	if not _play_queue.is_empty():
		call_deferred(&"_start_next")


func _normalize_payload(raw: Dictionary) -> Dictionary:
	var payload: Dictionary = raw.duplicate(true)
	payload["attacker_soldiers_before"] = clampi(int(payload.get("attacker_soldiers_before", MAX_SOLDIERS)), 0, MAX_SOLDIERS)
	payload["attacker_soldiers_after"] = clampi(int(payload.get("attacker_soldiers_after", payload.attacker_soldiers_before)), 0, int(payload.attacker_soldiers_before))
	payload["defender_soldiers_before"] = clampi(int(payload.get("defender_soldiers_before", MAX_SOLDIERS)), 0, MAX_SOLDIERS)
	payload["defender_soldiers_after"] = clampi(int(payload.get("defender_soldiers_after", payload.defender_soldiers_before)), 0, int(payload.defender_soldiers_before))
	payload["attacker_troop_type"] = str(payload.get("attacker_troop_type", "archer"))
	payload["defender_troop_type"] = str(payload.get("defender_troop_type", "spear"))
	payload["commander_damage"] = maxi(0, int(payload.get("commander_damage", 0)))
	payload["nonlethal"] = bool(payload.get("nonlethal", true))
	return payload


func _phase_progress() -> float:
	return clampf(_phase_elapsed / PHASE_DURATIONS[int(_phase)], 0.0, 1.0)


func _visible_soldiers(attacker: bool) -> int:
	if _active_payload.is_empty():
		return 0
	var prefix: String = "attacker" if attacker else "defender"
	var before: int = int(_active_payload.get("%s_soldiers_before" % prefix, MAX_SOLDIERS))
	if _phase != Phase.RETREAT:
		return before
	var after: int = int(_active_payload.get("%s_soldiers_after" % prefix, before))
	return before - floori(float(before - after) * _phase_progress())


func _draw() -> void:
	if not _playing or _active_payload.is_empty():
		return
	var viewport_size: Vector2 = size if size.x > 0.0 and size.y > 0.0 else Vector2(1280.0, 720.0)
	var center := viewport_size * 0.5
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.018, 0.024, 0.026, 0.96))
	_draw_quarter_view_stage(center, viewport_size)
	_draw_status_pips(center, viewport_size)
	var left_anchor := center + Vector2(-viewport_size.x * 0.24, 24.0)
	var right_anchor := center + Vector2(viewport_size.x * 0.24, 24.0)
	var attacker_on_right: bool = str(_active_payload.get("attacker_side", "left")) == "right"
	var attacker_anchor: Vector2 = right_anchor if attacker_on_right else left_anchor
	var defender_anchor: Vector2 = left_anchor if attacker_on_right else right_anchor
	var attack_direction: float = -1.0 if attacker_on_right else 1.0
	attacker_anchor.x += _attacker_motion() * attack_direction
	defender_anchor.x += _defender_motion() * attack_direction
	_draw_formation(attacker_anchor, true, attack_direction)
	_draw_formation(defender_anchor, false, -attack_direction)
	_draw_attack_effect(attacker_anchor, defender_anchor, attack_direction)


func _draw_quarter_view_stage(center: Vector2, viewport_size: Vector2) -> void:
	var half_width: float = minf(viewport_size.x * 0.43, 560.0)
	var half_height: float = minf(viewport_size.y * 0.30, 220.0)
	var stage := PackedVector2Array([
		center + Vector2(0.0, -half_height), center + Vector2(half_width, 0.0),
		center + Vector2(0.0, half_height), center + Vector2(-half_width, 0.0),
	])
	draw_colored_polygon(stage, Color("283d32"))
	draw_polyline(PackedVector2Array([stage[0], stage[1], stage[2], stage[3], stage[0]]), Color("8b9b69"), 4.0)
	for index: int in range(-5, 6):
		var offset: float = float(index) * half_width / 5.0
		draw_line(center + Vector2(offset - half_width, 0.0), center + Vector2(offset, half_height), Color(0.42, 0.50, 0.34, 0.22), 2.0)
		draw_line(center + Vector2(offset, -half_height), center + Vector2(offset + half_width, 0.0), Color(0.42, 0.50, 0.34, 0.22), 2.0)
	# Flat silhouettes keep the placeholder stage readable as a 2D quarter-view space.
	draw_colored_polygon(PackedVector2Array([center + Vector2(-half_width * 0.78, -22.0), center + Vector2(-half_width * 0.60, -72.0), center + Vector2(-half_width * 0.46, -12.0)]), Color("1b2b24"))
	draw_colored_polygon(PackedVector2Array([center + Vector2(half_width * 0.58, 54.0), center + Vector2(half_width * 0.76, 4.0), center + Vector2(half_width * 0.88, 62.0)]), Color("1b2b24"))


func _draw_status_pips(center: Vector2, viewport_size: Vector2) -> void:
	var y: float = maxf(34.0, center.y - minf(viewport_size.y * 0.36, 270.0))
	_draw_side_pips(Vector2(center.x - minf(viewport_size.x * 0.25, 320.0), y), true)
	_draw_side_pips(Vector2(center.x + minf(viewport_size.x * 0.25, 320.0), y), false)


func _draw_side_pips(origin: Vector2, attacker: bool) -> void:
	var color: Color = _side_color(attacker)
	var direction: float = 1.0 if attacker else -1.0
	draw_colored_polygon(PackedVector2Array([origin + Vector2(-8.0, 0.0), origin + Vector2(0.0, -8.0), origin + Vector2(8.0, 0.0), origin + Vector2(0.0, 8.0)]), color.lightened(0.22))
	var count: int = _visible_soldiers(attacker)
	for index: int in range(MAX_SOLDIERS):
		var pip_origin := origin + Vector2(direction * (22.0 + index * 14.0), 0.0)
		var pip_color: Color = color if index < count else Color(0.17, 0.19, 0.18, 0.8)
		draw_rect(Rect2(pip_origin - Vector2(5.0, 4.0), Vector2(10.0, 8.0)), pip_color)


func _draw_formation(anchor: Vector2, attacker: bool, facing: float) -> void:
	var soldier_count: int = _visible_soldiers(attacker)
	var prefix: String = "attacker" if attacker else "defender"
	var troop_type: String = str(_active_payload.get("%s_troop_type" % prefix, "archer"))
	var color: Color = _side_color(attacker)
	for index: int in range(soldier_count):
		var local_offset: Vector2 = FORMATION_OFFSETS[index]
		local_offset.x *= facing
		var retreat_offset := Vector2.ZERO
		if _phase == Phase.RETREAT and not attacker:
			retreat_offset.x = -facing * 34.0 * _phase_progress()
		_draw_sd_actor(anchor + local_offset + retreat_offset, color.darkened(0.10), troop_type, facing, false)
	var commander_position := anchor + Vector2(58.0 * facing, 10.0)
	if not attacker and _phase == Phase.IMPACT and int(_active_payload.get("commander_damage", 0)) > 0:
		commander_position.x += sin(_phase_progress() * TAU * 4.0) * 5.0
	_draw_sd_actor(commander_position, color, troop_type, facing, true)


func _draw_sd_actor(actor_position: Vector2, color: Color, troop_type: String, facing: float, commander: bool) -> void:
	var actor_scale: float = 1.18 if commander else 0.82
	draw_set_transform(Vector2(round(actor_position.x), round(actor_position.y)), 0.0, Vector2.ONE * actor_scale)
	draw_colored_polygon(PackedVector2Array([Vector2(-19.0, 18.0), Vector2(19.0, 18.0), Vector2(27.0, 24.0), Vector2(-27.0, 24.0)]), Color(0.02, 0.025, 0.025, 0.45))
	draw_rect(Rect2(-10.0, -10.0, 20.0, 28.0), color)
	draw_rect(Rect2(-13.0, -27.0, 26.0, 18.0), Color("d59a69"))
	draw_rect(Rect2(-14.0, -30.0, 28.0, 7.0), Color("282b2e"))
	draw_rect(Rect2(-12.0, 15.0, 9.0, 10.0), Color("25272a"))
	draw_rect(Rect2(3.0, 15.0, 9.0, 10.0), Color("25272a"))
	if commander:
		draw_rect(Rect2(-12.0, 2.0, 24.0, 5.0), Color("d6b34c"))
		draw_line(Vector2(-facing * 15.0, -18.0), Vector2(-facing * 15.0, -50.0), Color("4b3523"), 4.0)
		var banner_left: float = -15.0 if facing > 0.0 else -3.0
		draw_rect(Rect2(Vector2(banner_left, -50.0), Vector2(18.0, 12.0)), color.lightened(0.25))
	_draw_weapon(troop_type, facing)
	draw_set_transform(Vector2.ZERO)


func _draw_weapon(troop_type: String, facing: float) -> void:
	if troop_type == "archer":
		var hand := Vector2(8.0 * facing, -1.0)
		draw_arc(hand + Vector2(6.0 * facing, 0.0), 13.0, -PI * 0.5, PI * 0.5, 9, Color("8f6737"), 2.5)
		draw_line(hand + Vector2(6.0 * facing, -13.0), hand + Vector2(6.0 * facing, 13.0), Color("d9c79b"), 1.5)
	else:
		draw_line(Vector2(-7.0 * facing, 10.0), Vector2(34.0 * facing, -20.0), Color("8a6c44"), 3.0)
		draw_colored_polygon(PackedVector2Array([Vector2(33.0 * facing, -22.0), Vector2(43.0 * facing, -26.0), Vector2(38.0 * facing, -15.0)]), Color("c7d0cd"))


func _draw_attack_effect(attacker_anchor: Vector2, defender_anchor: Vector2, direction: float) -> void:
	if _phase != Phase.IMPACT:
		return
	var progress: float = _phase_progress()
	if str(_active_payload.get("attacker_troop_type", "archer")) == "archer":
		for index: int in range(6):
			var arrow_progress: float = clampf((progress - float(index) * 0.055) / 0.72, 0.0, 1.0)
			var start := attacker_anchor + Vector2(78.0 * direction, -72.0 + index * 25.0)
			var finish := defender_anchor + Vector2(-54.0 * direction, -48.0 + index * 21.0)
			var arrow_position: Vector2 = start.lerp(finish, arrow_progress) + Vector2(0.0, -80.0 * sin(arrow_progress * PI))
			draw_line(arrow_position - Vector2(20.0 * direction, -5.0), arrow_position, Color("e4d4a5"), 3.0)
	else:
		var impact_position: Vector2 = attacker_anchor.lerp(defender_anchor, 0.54)
		for index: int in range(5):
			var angle: float = TAU * float(index) / 5.0 + progress
			var ray: Vector2 = Vector2(cos(angle), sin(angle)) * (18.0 + 30.0 * progress)
			draw_line(impact_position, impact_position + ray, Color("f2c75c", 1.0 - progress * 0.55), 4.0)


func _attacker_motion() -> float:
	var progress: float = _phase_progress()
	match _phase:
		Phase.PREPARE:
			return lerpf(0.0, -18.0, progress)
		Phase.IMPACT:
			return lerpf(-18.0, 48.0, sin(progress * PI * 0.5))
		Phase.RETREAT:
			return lerpf(48.0, 12.0, progress)
	return 0.0


func _defender_motion() -> float:
	var progress: float = _phase_progress()
	match _phase:
		Phase.IMPACT:
			return lerpf(0.0, 18.0, sin(progress * PI))
		Phase.RETREAT:
			return lerpf(18.0, 42.0, progress)
	return 0.0


func _side_color(attacker: bool) -> Color:
	var key: String = "attacker_color" if attacker else "defender_color"
	var fallback := Color("4f9db6") if attacker else Color("b86450")
	var value: Variant = _active_payload.get(key, fallback)
	return value as Color if value is Color else Color.from_string(str(value), fallback)
