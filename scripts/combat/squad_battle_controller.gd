class_name SquadBattleController
extends Node2D

signal battle_finished(victory: bool, summary: Dictionary)

enum BattleState {
	SETUP,
	PLAYER_SELECT,
	PLAYER_MOVE,
	PLAYER_COMMAND,
	RESOLVE,
	ENEMY_TURN,
	ROUND_END,
	VICTORY,
	DEFEAT,
}

const DATA_PATH: String = "res://data/combat/demo_training_encounter.json"
const GRID_ORIGIN: Vector2 = Vector2(640.0, 145.0)
const CELL_WIDTH: float = 124.0
const CELL_HEIGHT: float = 62.0

@onready var title_label: Label = %TitleLabel
@onready var state_label: Label = %StateLabel
@onready var player_label: Label = %PlayerLabel
@onready var enemy_label: Label = %EnemyLabel
@onready var help_label: Label = %HelpLabel
@onready var attack_button: Button = %AttackButton
@onready var defend_button: Button = %DefendButton
@onready var end_turn_button: Button = %EndTurnButton

var state: BattleState = BattleState.SETUP
var round_number: int = 1
var grid_size: Vector2i = Vector2i(6, 5)
var cursor: Vector2i = Vector2i.ZERO
var player_squad: Dictionary = {}
var enemy_squad: Dictionary = {}
var rules: Dictionary = {}
var _running: bool = false


func _ready() -> void:
	attack_button.pressed.connect(_on_attack_pressed)
	defend_button.pressed.connect(command_defend)
	end_turn_button.pressed.connect(end_player_turn)
	begin_battle()


func begin_battle() -> void:
	var encounter: Dictionary = _load_encounter()
	if encounter.is_empty():
		push_error("[SQUAD_BATTLE] Encounter data unavailable")
		return
	var raw_size: Array = encounter.get("grid_size", [6, 5]) as Array
	grid_size = Vector2i(int(raw_size[0]), int(raw_size[1]))
	player_squad = _prepare_squad(encounter.get("player", {}) as Dictionary)
	enemy_squad = _prepare_squad(encounter.get("enemy", {}) as Dictionary)
	rules = (encounter.get("rules", {}) as Dictionary).duplicate(true)
	title_label.text = str(encounter.get("title", "분대 대련"))
	round_number = 1
	cursor = player_squad.position
	_running = true
	_set_state(BattleState.PLAYER_SELECT)
	print("[SQUAD_BATTLE] ready commander+troops player=%s enemy=%s" % [player_squad.id, enemy_squad.id])


func _unhandled_input(event: InputEvent) -> void:
	if not _running:
		return
	var direction := Vector2i.ZERO
	if event.is_action_pressed(&"move_left") or event.is_action_pressed(&"ui_left"):
		direction = Vector2i.LEFT
	elif event.is_action_pressed(&"move_right") or event.is_action_pressed(&"ui_right"):
		direction = Vector2i.RIGHT
	elif event.is_action_pressed(&"move_up") or event.is_action_pressed(&"ui_up"):
		direction = Vector2i.UP
	elif event.is_action_pressed(&"move_down") or event.is_action_pressed(&"ui_down"):
		direction = Vector2i.DOWN
	if direction != Vector2i.ZERO:
		cursor = _clamp_cell(cursor + direction)
		queue_redraw()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"game_confirm") or event.is_action_pressed(&"ui_accept"):
		if state == BattleState.PLAYER_SELECT:
			select_player_squad()
		elif state == BattleState.PLAYER_MOVE:
			move_selected(cursor)
		elif state == BattleState.PLAYER_COMMAND:
			_on_attack_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"game_cancel") or event.is_action_pressed(&"ui_cancel"):
		if state == BattleState.PLAYER_MOVE:
			cursor = player_squad.position
			_set_state(BattleState.PLAYER_SELECT)
		elif state == BattleState.PLAYER_COMMAND:
			_set_state(BattleState.PLAYER_MOVE)
		get_viewport().set_input_as_handled()


func select_player_squad() -> bool:
	if state != BattleState.PLAYER_SELECT:
		return false
	cursor = player_squad.position
	_set_state(BattleState.PLAYER_MOVE)
	return true


func move_selected(target: Vector2i) -> bool:
	if state != BattleState.PLAYER_MOVE:
		return false
	if not _inside_grid(target):
		return false
	if _grid_distance(player_squad.position, target) > int(player_squad.move_range):
		return false
	if target == enemy_squad.position:
		return false
	player_squad.position = target
	cursor = target
	_set_state(BattleState.PLAYER_COMMAND)
	return true


func command_attack(target_id: String = "trainer_squad") -> bool:
	if state != BattleState.PLAYER_COMMAND or target_id != str(enemy_squad.id):
		return false
	var distance: int = _grid_distance(player_squad.position, enemy_squad.position)
	if distance < int(player_squad.attack_min) or distance > int(player_squad.attack_max):
		help_label.text = "사거리 밖입니다. 방어하거나 턴을 종료하세요."
		return false
	_set_state(BattleState.RESOLVE)
	var damage: int = int(rules.get("base_damage", 2))
	if str(player_squad.troop_type) == "archer" and str(enemy_squad.troop_type) == "spear" and distance >= 2:
		damage += int(rules.get("range_advantage_bonus", 2))
	_apply_damage(enemy_squad, damage)
	print("[SQUAD_BATTLE] player attack distance=%d damage=%d" % [distance, damage])
	if _is_defeated(enemy_squad):
		_finish(true)
	else:
		_run_enemy_turn()
	return true


func command_defend() -> void:
	if state != BattleState.PLAYER_COMMAND:
		return
	player_squad.defending = true
	_run_enemy_turn()


func end_player_turn() -> void:
	if state not in [BattleState.PLAYER_MOVE, BattleState.PLAYER_COMMAND]:
		return
	_run_enemy_turn()


func get_snapshot() -> Dictionary:
	return {
		"state": BattleState.keys()[state],
		"round": round_number,
		"player": player_squad.duplicate(true),
		"enemy": enemy_squad.duplicate(true),
	}


func _run_enemy_turn() -> void:
	_set_state(BattleState.ENEMY_TURN)
	var distance: int = _grid_distance(enemy_squad.position, player_squad.position)
	if distance > int(enemy_squad.attack_max):
		enemy_squad.position = _step_toward(enemy_squad.position, player_squad.position)
		distance = _grid_distance(enemy_squad.position, player_squad.position)
	if distance >= int(enemy_squad.attack_min) and distance <= int(enemy_squad.attack_max):
		var damage: int = int(rules.get("base_damage", 2))
		if str(enemy_squad.troop_type) == "spear" and str(player_squad.troop_type) == "archer" and distance == 1:
			damage += int(rules.get("adjacent_advantage_bonus", 2))
		_apply_damage(player_squad, damage)
		print("[SQUAD_BATTLE] enemy attack distance=%d damage=%d" % [distance, damage])
	if _is_defeated(player_squad):
		_finish(false)
		return
	_set_state(BattleState.ROUND_END)
	round_number += 1
	player_squad.defending = false
	enemy_squad.defending = false
	cursor = player_squad.position
	_set_state(BattleState.PLAYER_SELECT)


func _apply_damage(target: Dictionary, incoming: int) -> void:
	var damage: int = incoming
	if bool(target.get("defending", false)):
		damage = maxi(0, damage - int(rules.get("defend_reduction", 1)))
	var soldier_morale: int = int(target.get("soldier_morale", 0))
	var absorbed: int = mini(soldier_morale, damage)
	soldier_morale -= absorbed
	damage -= absorbed
	target.soldier_morale = soldier_morale
	target.soldier_count = soldier_morale
	if damage > 0:
		target.commander_morale = maxi(0, int(target.commander_morale) - damage)
	queue_redraw()
	_refresh_ui()


func _finish(victory: bool) -> void:
	_running = false
	_set_state(BattleState.VICTORY if victory else BattleState.DEFEAT)
	help_label.text = "훈련 승리 · 분대 지휘 합격" if victory else "훈련 패배 · 대열을 다시 정비하세요"
	battle_finished.emit(victory, get_snapshot())
	print("[SQUAD_BATTLE] finished victory=%s round=%d" % [victory, round_number])


func _set_state(next_state: BattleState) -> void:
	state = next_state
	_refresh_ui()
	queue_redraw()


func _refresh_ui() -> void:
	if not is_node_ready() or player_squad.is_empty() or enemy_squad.is_empty():
		return
	state_label.text = "제 %d합 · %s" % [round_number, BattleState.keys()[state]]
	player_label.text = "%s  %s %d명  기세 %d" % [player_squad.commander_name, player_squad.troop_name, player_squad.soldier_count, player_squad.commander_morale]
	enemy_label.text = "%s  %s %d명  기세 %d" % [enemy_squad.commander_name, enemy_squad.troop_name, enemy_squad.soldier_count, enemy_squad.commander_morale]
	attack_button.disabled = state != BattleState.PLAYER_COMMAND
	defend_button.disabled = state != BattleState.PLAYER_COMMAND
	end_turn_button.disabled = state not in [BattleState.PLAYER_MOVE, BattleState.PLAYER_COMMAND]
	match state:
		BattleState.PLAYER_SELECT:
			help_label.text = "주몽 분대를 선택하세요 · 확인/A"
		BattleState.PLAYER_MOVE:
			help_label.text = "이동할 칸을 고르세요 · 방향키/WASD · 확인/A"
		BattleState.PLAYER_COMMAND:
			help_label.text = "군령을 선택하세요 · 기본 사격은 거리 2~3칸"
		BattleState.ENEMY_TURN:
			help_label.text = "훈련대장의 군령을 처리합니다."


func _draw() -> void:
	for y: int in range(grid_size.y):
		for x: int in range(grid_size.x):
			var cell := Vector2i(x, y)
			_draw_cell(cell)
	if not player_squad.is_empty():
		_draw_squad(player_squad, Color("58a8c9"), true)
	if not enemy_squad.is_empty():
		_draw_squad(enemy_squad, Color("b56b52"), false)


func _draw_cell(cell: Vector2i) -> void:
	var center: Vector2 = _grid_to_screen(cell)
	var points := PackedVector2Array([
		center + Vector2(0.0, -CELL_HEIGHT * 0.5),
		center + Vector2(CELL_WIDTH * 0.5, 0.0),
		center + Vector2(0.0, CELL_HEIGHT * 0.5),
		center + Vector2(-CELL_WIDTH * 0.5, 0.0),
	])
	var color := Color("31463b") if (cell.x + cell.y) % 2 == 0 else Color("3b513f")
	if state == BattleState.PLAYER_MOVE and _grid_distance(player_squad.position, cell) <= int(player_squad.move_range):
		color = Color("315d70")
	elif state == BattleState.PLAYER_COMMAND:
		var distance: int = _grid_distance(player_squad.position, cell)
		if distance >= int(player_squad.attack_min) and distance <= int(player_squad.attack_max):
			color = Color("70453c")
	if cell == cursor and state in [BattleState.PLAYER_SELECT, BattleState.PLAYER_MOVE]:
		color = color.lightened(0.28)
	draw_colored_polygon(points, color)
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), Color("91a27d"), 2.0)


func _draw_squad(squad: Dictionary, color: Color, player_side: bool) -> void:
	var center: Vector2 = _grid_to_screen(squad.position)
	var offsets := [
		Vector2(-42, 12), Vector2(-14, 18), Vector2(14, 18), Vector2(42, 12),
		Vector2(-32, 35), Vector2(-11, 42), Vector2(11, 42), Vector2(32, 35),
	]
	var visible_soldiers: int = mini(int(squad.soldier_count), offsets.size())
	for index: int in range(visible_soldiers):
		_draw_sd_actor(center + offsets[index], color.darkened(0.12), false)
	_draw_sd_actor(center + Vector2(0, -10), color, true)
	var banner_x: float = -24.0 if player_side else 24.0
	draw_line(center + Vector2(banner_x, -52), center + Vector2(banner_x, 6), Color("35251d"), 4.0)
	draw_rect(Rect2(center + Vector2(banner_x, -52), Vector2(22.0 if player_side else -22.0, 15.0)), color.lightened(0.2))


func _draw_sd_actor(position: Vector2, color: Color, commander: bool) -> void:
	var scale_factor: float = 1.15 if commander else 0.62
	draw_set_transform(Vector2(round(position.x), round(position.y)), 0.0, Vector2.ONE * scale_factor)
	draw_colored_polygon(PackedVector2Array([Vector2(-14, 14), Vector2(14, 14), Vector2(21, 20), Vector2(-21, 20)]), Color(0.03, 0.04, 0.04, 0.38))
	draw_rect(Rect2(-11, -11, 22, 28), color)
	draw_rect(Rect2(-14, -28, 28, 20), Color("d7a06e"))
	draw_rect(Rect2(-13, -31, 26, 7), Color("292a2f"))
	draw_rect(Rect2(-13, 16, 10, 10), Color("29242a"))
	draw_rect(Rect2(3, 16, 10, 10), Color("29242a"))
	if commander:
		draw_rect(Rect2(-13, 5, 26, 5), Color("a54839"))
	draw_set_transform(Vector2.ZERO)


func _prepare_squad(raw: Dictionary) -> Dictionary:
	var squad: Dictionary = raw.duplicate(true)
	var raw_position: Array = squad.get("position", [0, 0]) as Array
	squad.position = Vector2i(int(raw_position[0]), int(raw_position[1]))
	squad.defending = false
	return squad


func _load_encounter() -> Dictionary:
	if not FileAccess.file_exists(DATA_PATH):
		return {}
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed as Dictionary if parsed is Dictionary else {}


func _step_toward(from: Vector2i, to: Vector2i) -> Vector2i:
	var delta: Vector2i = to - from
	if absi(delta.x) >= absi(delta.y) and delta.x != 0:
		return _clamp_cell(from + Vector2i(signi(delta.x), 0))
	if delta.y != 0:
		return _clamp_cell(from + Vector2i(0, signi(delta.y)))
	return from


func _grid_to_screen(cell: Vector2i) -> Vector2:
	return GRID_ORIGIN + Vector2((cell.x - cell.y) * CELL_WIDTH * 0.5, (cell.x + cell.y) * CELL_HEIGHT * 0.5)


func _grid_distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


func _inside_grid(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < grid_size.x and cell.y < grid_size.y


func _clamp_cell(cell: Vector2i) -> Vector2i:
	return Vector2i(clampi(cell.x, 0, grid_size.x - 1), clampi(cell.y, 0, grid_size.y - 1))


func _is_defeated(squad: Dictionary) -> bool:
	return int(squad.commander_morale) <= 0


func _on_attack_pressed() -> void:
	command_attack(str(enemy_squad.get("id", "trainer_squad")))
