extends Control

@export var first_button: Button = null

func _ready() -> void:
	first_button.grab_focus()


func _on_start_button_pressed() -> void:
	Global.game.switch_context(&"world_3d", "uid://c0g4l4d2g20kq", Transitions.FADE_BLACK)

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_credits_button_pressed() -> void:
	Global.game.change_scene(&"gui", "uid://74ixr2ss8r5m", Global.game.ChangeMode.DELETE, Transitions.FADE_BLACK)
