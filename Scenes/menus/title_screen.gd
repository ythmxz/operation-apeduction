extends Control


@export var default_button: Button = null
@export var version_label: Label = null


func _ready() -> void:
	version_label.text = ProjectSettings.get_setting("application/config/version")
	default_button.grab_focus()
	Music.play(&"TitleScreen")


func _on_start_button_pressed() -> void:
	Global.game.switch_context(&"world_3d", "uid://c0g4l4d2g20kq", Transitions.FADE_BLACK)


func _on_leaderboard_button_pressed() -> void:
	Global.game.change_scene(&"gui", "uid://4ijkhmr1cggm", Global.game.ChangeMode.DELETE, Transitions.FADE_BLACK)


func _on_credits_button_pressed() -> void:
	Global.game.change_scene(&"gui", "uid://74ixr2ss8r5m", Global.game.ChangeMode.DELETE, Transitions.FADE_BLACK)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
