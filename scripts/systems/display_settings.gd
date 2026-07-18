class_name DisplaySettings
extends Node

signal apply_verified(success: bool, message: String)

const SETTINGS_PATH: String = "user://display_settings.cfg"
const SETTINGS_VERSION: int = 2
const FALLBACK_SIZE: Vector2i = Vector2i(1280, 720)
const STANDARD_RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1024, 576), Vector2i(1280, 720), Vector2i(1280, 800), Vector2i(1366, 768),
	Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440),
	Vector2i(3200, 1800), Vector2i(3840, 2160),
]

enum DisplayMode { WINDOWED, BORDERLESS, EXCLUSIVE }

var current_settings: Dictionary = {}
var pending_previous_settings: Dictionary = {}
var screen_index: int = 0
var native_size: Vector2i = FALLBACK_SIZE
var display_available: bool = false
var _initialized: bool = false


func _enter_tree() -> void:
	add_to_group(&"display_settings")


func _ready() -> void:
	initialize()


func initialize() -> void:
	if _initialized:
		return
	_initialized = true
	screen_index = max(DisplayServer.window_get_current_screen(), 0)
	native_size = DisplayServer.screen_get_size(screen_index)
	display_available = native_size.x > 0 and native_size.y > 0
	if not display_available:
		native_size = FALLBACK_SIZE
		current_settings = _fallback_settings()
		_apply_settings_internal(current_settings)
		print("[DISPLAY] Screen unavailable; using safe 1280x720 windowed fallback")
		return
	var loaded: Dictionary = load_saved_settings()
	current_settings = loaded if not loaded.is_empty() else default_settings()
	current_settings = sanitize_settings(current_settings)
	_apply_settings_internal(current_settings)
	print("[DISPLAY] Applied mode=%s size=%s native=%s" % [mode_label(int(current_settings.mode)), current_settings.size, native_size])


func default_settings() -> Dictionary:
	if not display_available:
		return _fallback_settings()
	return {"mode": DisplayMode.BORDERLESS, "size": native_size}


func resolution_options() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for size: Vector2i in STANDARD_RESOLUTIONS:
		if size.x <= native_size.x and size.y <= native_size.y:
			result.append(size)
	if not result.has(native_size):
		result.append(native_size)
	result.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x * a.y < b.x * b.y)
	return result


func begin_preview(settings: Dictionary) -> Dictionary:
	pending_previous_settings = current_settings.duplicate(true)
	var sanitized: Dictionary = sanitize_settings(settings)
	_apply_settings_internal(sanitized)
	current_settings = sanitized
	return pending_previous_settings.duplicate(true)


func confirm_preview() -> bool:
	pending_previous_settings.clear()
	return save_settings(current_settings)


func revert_preview() -> void:
	if pending_previous_settings.is_empty():
		return
	current_settings = pending_previous_settings.duplicate(true)
	pending_previous_settings.clear()
	_apply_settings_internal(current_settings)


func apply_without_saving(settings: Dictionary) -> void:
	current_settings = sanitize_settings(settings)
	_apply_settings_internal(current_settings)


func sanitize_settings(settings: Dictionary) -> Dictionary:
	if not display_available:
		return _fallback_settings()
	var mode: int = clampi(int(settings.get("mode", DisplayMode.BORDERLESS)), DisplayMode.WINDOWED, DisplayMode.EXCLUSIVE)
	var requested: Vector2i = settings.get("size", native_size) as Vector2i
	requested.x = clampi(requested.x, 640, native_size.x)
	requested.y = clampi(requested.y, 360, native_size.y)
	if mode != DisplayMode.WINDOWED:
		requested = native_size
	return {"mode": mode, "size": requested}


func load_saved_settings() -> Dictionary:
	var config: ConfigFile = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return {}
	var size := Vector2i(
		int(config.get_value("display", "width", native_size.x)),
		int(config.get_value("display", "height", native_size.y))
	)
	return {"mode": int(config.get_value("display", "mode", DisplayMode.BORDERLESS)), "size": size}


func save_settings(settings: Dictionary) -> bool:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("meta", "version", SETTINGS_VERSION)
	config.set_value("display", "mode", int(settings.mode))
	var size: Vector2i = settings.size as Vector2i
	config.set_value("display", "width", size.x)
	config.set_value("display", "height", size.y)
	return config.save(SETTINGS_PATH) == OK


func mode_label(mode: int) -> String:
	match mode:
		DisplayMode.WINDOWED: return "창 모드"
		DisplayMode.BORDERLESS: return "테두리 없는 전체 화면"
		DisplayMode.EXCLUSIVE: return "독점 전체 화면"
	return "알 수 없음"


func _fallback_settings() -> Dictionary:
	return {"mode": DisplayMode.WINDOWED, "size": FALLBACK_SIZE}


func _apply_settings_internal(settings: Dictionary) -> void:
	var mode: int = int(settings.mode)
	var size: Vector2i = settings.size as Vector2i
	if not display_available:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(FALLBACK_SIZE)
		return
	DisplayServer.window_set_current_screen(screen_index)
	match mode:
		DisplayMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(size)
			var usable: Rect2i = DisplayServer.screen_get_usable_rect(screen_index)
			var centered: Vector2i = usable.position + (usable.size - size) / 2
			DisplayServer.window_set_position(centered)
		DisplayMode.BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayMode.EXCLUSIVE:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	call_deferred(&"_verify_applied_state")


func verify_current_settings() -> Dictionary:
	if not display_available:
		return {"success": true, "message": "화면이 없는 실행 환경에서는 1280 × 720 창 모드를 사용합니다."}
	var expected_mode: int = int(current_settings.mode)
	var actual_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	var mode_matches: bool = false
	match expected_mode:
		DisplayMode.WINDOWED:
			mode_matches = actual_mode == DisplayServer.WINDOW_MODE_WINDOWED and not DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
		DisplayMode.BORDERLESS:
			mode_matches = actual_mode == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayMode.EXCLUSIVE:
			mode_matches = actual_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	var actual_size: Vector2i = DisplayServer.window_get_size()
	var size_matches: bool = actual_size == (current_settings.size as Vector2i)
	if expected_mode != DisplayMode.WINDOWED:
		size_matches = actual_size.x >= native_size.x - 1 and actual_size.y >= native_size.y - 1
	var success: bool = mode_matches and size_matches
	var message: String = "적용됨: %s · %d × %d" % [mode_label(expected_mode), actual_size.x, actual_size.y]
	if not success:
		message = "적용 확인 실패: 요청 %s %s / 실제 모드 %d, 크기 %s" % [mode_label(expected_mode), current_settings.size, actual_mode, actual_size]
	return {"success": success, "message": message}


func _verify_applied_state() -> void:
	var result: Dictionary = verify_current_settings()
	print("[DISPLAY] %s" % str(result.message))
	apply_verified.emit(bool(result.success), str(result.message))
