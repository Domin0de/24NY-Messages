extends Control

@onready var _dialogue : RichTextLabel = $VBoxContainer/Text
@onready var _continue : Button = $Box/Continue

var text := []
var textIndex := 0

func _ready() -> void:
	var json_as_text = FileAccess.get_file_as_string("messages.json")
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict and Global.owner_code in json_as_dict:
		text = json_as_dict[Global.owner_code]

func display_line(opening: bool = false):
	if opening and textIndex != 0:
		return

	if textIndex < len(text):
		print(textIndex)
		_dialogue.text = text[textIndex]

		open()
		_continue.grab_focus()

		textIndex += 1
	else:
		close()
		textIndex = 0

func open():
	visible = true
	
func close():
	visible = false

func _on_continue_pressed() -> void:
	display_line()
