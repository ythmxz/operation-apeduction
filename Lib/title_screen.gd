extends Control

func start_game() -> void:
	Global.game.switch_context(&"world_3d", "uid://c0g4l4d2g20kq", Transitions.FADE_BLACK)

func _on_start_button_pressed() -> void:
	start_game()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		start_game()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
