extends Control


@export var default_button: Button = null

@export_group("Positions")
@export var top_1: Label = null
@export var top_2: Label = null
@export var top_3: Label = null
@export var top_4: Label = null
@export var top_5: Label = null


func _ready() -> void:
	default_button.grab_focus()

	top_1.text = "1. " + _get_name(0) + " : " + str(Global.leaderboard_pont[0])
	top_2.text = "2. " + _get_name(1) + " : " + str(Global.leaderboard_pont[1])
	top_3.text = "3. " + _get_name(2) + " : " + str(Global.leaderboard_pont[2])
	top_4.text = "4. " + _get_name(3) + " : " + str(Global.leaderboard_pont[3])
	top_5.text = "5. " + _get_name(4) + " : " + str(Global.leaderboard_pont[4])


func _get_name(index: int) -> String:
	return "???" if Global.leaderboard_names[index].is_empty() else Global.leaderboard_names[index]


func _on_back_button_pressed() -> void:
	Global.game.change_scene(&"gui", "uid://bf62aaybcwjik", Global.game.ChangeMode.DELETE, Transitions.FADE_BLACK)
