extends Control

# @export var game_scene : PackedScene

func _on_start_button_pressed() -> void:
	Global.game.switch_context(&"world_3d", "uid://c0g4l4d2g20kq", Transitions.FADE_BLACK)
	# get_tree().change_scene_to_packed(game_scene)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
