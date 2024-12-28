extends Control

@onready var _close : Button = $Close

func _on_close_pressed() -> void:
	visible = false

func _input(event):
	if event.is_action_released("menu"):
		visible = !visible
