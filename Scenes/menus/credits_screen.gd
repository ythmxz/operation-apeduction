extends Control


@export var default_button: Button = null


func _ready() -> void:
	default_button.grab_focus()


func _on_back_button_pressed() -> void:
	Global.game.change_scene(&"gui", "uid://bf62aaybcwjik", Global.game.ChangeMode.DELETE, Transitions.FADE_BLACK)
