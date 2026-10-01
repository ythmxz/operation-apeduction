extends Control

@export var first_button: Button = null


func _ready() -> void:
	first_button.grab_focus()


func _on_button_pressed() -> void:
	Global.game.change_scene(&"gui", "uid://bf62aaybcwjik", Global.game.ChangeMode.DELETE, Transitions.FADE_BLACK)
