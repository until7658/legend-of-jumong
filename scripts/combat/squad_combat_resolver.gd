class_name SquadCombatResolver
extends RefCounted

## Pure deterministic squad clash resolver.
##
## This class never mutates the supplied squad or rules dictionaries. Presentation
## layers receive the returned payload and must not recalculate combat results.

const PAYLOAD_VERSION: int = 1


static func resolve_clash(
	attacker: Dictionary,
	defender: Dictionary,
	distance: int,
	rules: Dictionary
) -> Dictionary:
	var resolved_attacker: Dictionary = attacker.duplicate(true)
	var resolved_defender: Dictionary = defender.duplicate(true)
	var attacker_soldiers_before: int = maxi(0, int(attacker.get("soldier_count", 0)))
	var defender_soldiers_before: int = maxi(0, int(defender.get("soldier_count", 0)))
	var advantage: String = _advantage_kind(attacker, defender, distance)

	var raw_damage: int = maxi(0, int(rules.get("base_damage", 2)))
	if advantage == "range":
		raw_damage += maxi(0, int(rules.get("range_advantage_bonus", 2)))
	elif advantage == "adjacent":
		raw_damage += maxi(0, int(rules.get("adjacent_advantage_bonus", 2)))

	var defend_reduction: int = 0
	if bool(defender.get("defending", false)):
		defend_reduction = maxi(0, int(rules.get("defend_reduction", 1)))
	var resolved_damage: int = maxi(0, raw_damage - defend_reduction)

	var soldier_morale_before: int = maxi(
		0,
		int(defender.get("soldier_morale", defender_soldiers_before))
	)
	var soldier_damage: int = mini(soldier_morale_before, resolved_damage)
	var soldier_morale_after: int = soldier_morale_before - soldier_damage
	var commander_damage: int = resolved_damage - soldier_damage
	var commander_morale_before: int = maxi(0, int(defender.get("commander_morale", 0)))
	var commander_morale_after: int = maxi(0, commander_morale_before - commander_damage)
	commander_damage = commander_morale_before - commander_morale_after

	resolved_defender["soldier_morale"] = soldier_morale_after
	resolved_defender["soldier_count"] = maxi(0, defender_soldiers_before - soldier_damage)
	resolved_defender["commander_morale"] = commander_morale_after

	var payload: Dictionary = {
		"payload_version": PAYLOAD_VERSION,
		"attacker_id": str(attacker.get("id", "")),
		"defender_id": str(defender.get("id", "")),
		"attacker_troop_type": str(attacker.get("troop_type", "")),
		"defender_troop_type": str(defender.get("troop_type", "")),
		"attacker_soldiers_before": attacker_soldiers_before,
		"attacker_soldiers_after": int(resolved_attacker.get("soldier_count", 0)),
		"defender_soldiers_before": defender_soldiers_before,
		"defender_soldiers_after": int(resolved_defender.get("soldier_count", 0)),
		"commander_damage": commander_damage,
		"distance": maxi(0, distance),
		"advantage": advantage,
		"nonlethal": bool(rules.get("nonlethal", false)),
	}

	return {
		"attacker": resolved_attacker,
		"defender": resolved_defender,
		"payload": payload,
		"raw_damage": raw_damage,
		"defend_reduction": defend_reduction,
		"resolved_damage": resolved_damage,
		"soldier_damage": soldier_damage,
		"commander_damage": commander_damage,
	}


static func _advantage_kind(attacker: Dictionary, defender: Dictionary, distance: int) -> String:
	var attacker_type: String = str(attacker.get("troop_type", ""))
	var defender_type: String = str(defender.get("troop_type", ""))
	if attacker_type == "archer" and defender_type == "spear" and distance >= 2:
		return "range"
	if attacker_type == "spear" and defender_type == "archer" and distance == 1:
		return "adjacent"
	return "none"
