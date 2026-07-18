extends SceneTree

const Resolver := preload("res://scripts/combat/squad_combat_resolver.gd")

const RULES: Dictionary = {
	"base_damage": 2,
	"range_advantage_bonus": 2,
	"adjacent_advantage_bonus": 2,
	"defend_reduction": 1,
	"nonlethal": true,
}


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var archer: Dictionary = _squad("archers", "archer", 8, 4)
	var spear: Dictionary = _squad("spears", "spear", 8, 4)
	var archer_before: Dictionary = archer.duplicate(true)
	var spear_before: Dictionary = spear.duplicate(true)

	var ranged: Dictionary = Resolver.resolve_clash(archer, spear, 2, RULES)
	if archer != archer_before or spear != spear_before:
		_fail("resolver mutated an input dictionary")
		return
	if not _expect_result(ranged, 4, 4, 0, "range"):
		return

	var defended_spear: Dictionary = spear.duplicate(true)
	defended_spear["defending"] = true
	var defended: Dictionary = Resolver.resolve_clash(archer, defended_spear, 2, RULES)
	if not _expect_result(defended, 3, 5, 0, "range"):
		return

	var adjacent: Dictionary = Resolver.resolve_clash(spear, archer, 1, RULES)
	if not _expect_result(adjacent, 4, 4, 0, "adjacent"):
		return

	var exposed_commander: Dictionary = _squad("last_line", "spear", 1, 4)
	var breakthrough: Dictionary = Resolver.resolve_clash(archer, exposed_commander, 2, RULES)
	if not _expect_result(breakthrough, 4, 0, 3, "range"):
		return
	var breakthrough_defender: Dictionary = breakthrough.get("defender", {}) as Dictionary
	if int(breakthrough_defender.get("commander_morale", -1)) != 1:
		_fail("commander morale did not absorb overflow deterministically")
		return

	var repeated: Dictionary = Resolver.resolve_clash(archer, exposed_commander, 2, RULES)
	if repeated != breakthrough:
		_fail("identical inputs produced different outputs")
		return

	var payload: Dictionary = breakthrough.get("payload", {}) as Dictionary
	var required_keys: PackedStringArray = [
		"attacker_id", "defender_id", "attacker_troop_type", "defender_troop_type",
		"attacker_soldiers_before", "attacker_soldiers_after",
		"defender_soldiers_before", "defender_soldiers_after",
		"commander_damage", "distance", "advantage", "nonlethal",
	]
	for key: String in required_keys:
		if not payload.has(key):
			_fail("payload missing required key: %s" % key)
			return
	if not bool(payload.get("nonlethal", false)):
		_fail("training clash must remain nonlethal")
		return

	print("[COMBAT_RESOLVER_SMOKE] PASS deterministic range/adjacent/defend/nonlethal payload")
	quit(0)


func _squad(id: String, troop_type: String, soldiers: int, commander_morale: int) -> Dictionary:
	return {
		"id": id,
		"troop_type": troop_type,
		"soldier_count": soldiers,
		"soldier_morale": soldiers,
		"commander_morale": commander_morale,
		"defending": false,
	}


func _expect_result(
	result: Dictionary,
	expected_damage: int,
	expected_soldiers: int,
	expected_commander_damage: int,
	expected_advantage: String
) -> bool:
	if int(result.get("resolved_damage", -1)) != expected_damage:
		_fail("expected damage %d, got %d" % [expected_damage, int(result.get("resolved_damage", -1))])
		return false
	var defender: Dictionary = result.get("defender", {}) as Dictionary
	if int(defender.get("soldier_count", -1)) != expected_soldiers:
		_fail("expected %d soldiers, got %d" % [expected_soldiers, int(defender.get("soldier_count", -1))])
		return false
	var payload: Dictionary = result.get("payload", {}) as Dictionary
	if int(payload.get("commander_damage", -1)) != expected_commander_damage:
		_fail("expected commander damage %d" % expected_commander_damage)
		return false
	if str(payload.get("advantage", "")) != expected_advantage:
		_fail("expected advantage %s" % expected_advantage)
		return false
	return true


func _fail(message: String) -> void:
	push_error("[COMBAT_RESOLVER_SMOKE] %s" % message)
	quit(1)
