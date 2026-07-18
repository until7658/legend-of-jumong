class_name SaveService
extends Node

signal save_changed(has_save: bool)

const SAVE_VERSION: int = 1
const DEFAULT_SAVE_PATH: String = "user://prototype_checkpoint.json"

var save_path: String = DEFAULT_SAVE_PATH


func _enter_tree() -> void:
	add_to_group(&"save_service")


func has_save() -> bool:
	return not load_checkpoint().is_empty()


func save_checkpoint(checkpoint_id: String, payload: Dictionary = {}) -> bool:
	if checkpoint_id.strip_edges().is_empty():
		push_error("[SAVE] Empty checkpoint id")
		return false
	var document: Dictionary = {
		"version": SAVE_VERSION,
		"checkpoint_id": checkpoint_id,
		"saved_at_unix": int(Time.get_unix_time_from_system()),
		"payload": payload.duplicate(true),
	}
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("[SAVE] Cannot open %s" % save_path)
		return false
	file.store_string(JSON.stringify(document, "\t"))
	file.close()
	save_changed.emit(true)
	print("[SAVE] checkpoint=%s path=%s" % [checkpoint_id, save_path])
	return true


func load_checkpoint() -> Dictionary:
	if not FileAccess.file_exists(save_path):
		return {}
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		push_warning("[SAVE] Invalid JSON ignored")
		return {}
	var document := parsed as Dictionary
	if int(document.get("version", -1)) != SAVE_VERSION:
		push_warning("[SAVE] Unsupported version ignored")
		return {}
	if str(document.get("checkpoint_id", "")).is_empty():
		push_warning("[SAVE] Missing checkpoint ignored")
		return {}
	if not document.get("payload", {}) is Dictionary:
		push_warning("[SAVE] Invalid payload ignored")
		return {}
	return document.duplicate(true)


func delete_save() -> bool:
	if not FileAccess.file_exists(save_path):
		return true
	var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	if error != OK:
		push_error("[SAVE] Delete failed: %s" % error_string(error))
		return false
	save_changed.emit(false)
	return true
