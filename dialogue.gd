extends Control

@onready var _dialogue : RichTextLabel = $VBoxContainer/Text
@onready var _continue : Button = $Box/Continue

func _ready() -> void:
	display_line("Hello world")

func display_line(line: String):
	_dialogue.text = line
	open()
	_continue.grab_focus()

func open():
	visible = true
	
func close():
	visible = false

func _on_continue_pressed() -> void:
	close()
