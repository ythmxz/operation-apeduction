extends Control


@export var name_input: LineEdit = null
@export var proceed_button: TextureButton = null


func _ready() -> void:
	name_input.grab_focus()


func _on_name_input_text_changed(new_text: String) -> void:
	name_input.text = new_text.to_upper()
	name_input.caret_column = name_input.text.length()


func _on_name_input_text_submitted(_new_text: String) -> void:
	proceed_button.pressed.emit()


func _on_proceed_button_pressed() -> void:
	var player_name = name_input.text

	Global.leaderboard_names.insert(Global.position, player_name)
	Global.leaderboard_names.pop_back()

	Global.game.change_scene(&"gui", "uid://bojqeli1y7w6u")
