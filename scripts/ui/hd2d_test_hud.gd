class_name Hd2dTestHud
extends CanvasLayer

signal interaction_requested
signal camera_reset_requested

@onready var location_label: Label = %LocationLabel
@onready var status_label: Label = %StatusLabel
@onready var objective_label: Label = %ObjectiveLabel
@onready var interact_button: Button = %InteractButton


func _ready() -> void:
	interact_button.pressed.connect(_on_interact_pressed)
	%CameraResetButton.pressed.connect(_on_camera_reset_pressed)


func set_location(value: String) -> void:
	location_label.text = value


func set_status(value: String) -> void:
	status_label.text = value


func set_objective(value: String) -> void:
	objective_label.text = value


func set_interaction_enabled(enabled: bool, prompt: String = "상호작용") -> void:
	interact_button.disabled = not enabled
	interact_button.text = prompt


func _on_interact_pressed() -> void:
	interaction_requested.emit()


func _on_camera_reset_pressed() -> void:
	camera_reset_requested.emit()
