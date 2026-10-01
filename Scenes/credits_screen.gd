extends Control


func _on_button_pressed() -> void:
	Global.game.change_scene(&"gui", "uid://bf62aaybcwjik", Global.game.ChangeMode.DELETE, Transitions.FADE_BLACK)
