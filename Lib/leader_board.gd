extends Control

@export var first_button: Button = null
@onready var top_1: Label = $MarginContainer/VBoxContainer/Top1
@onready var top_2: Label = $MarginContainer/VBoxContainer/Top2
@onready var top_3: Label = $MarginContainer/VBoxContainer/Top3
@onready var top_4: Label = $MarginContainer/VBoxContainer/Top4
@onready var top_5: Label = $MarginContainer/VBoxContainer/Top5

func _ready() -> void:
	first_button.grab_focus()
	
	top_1.text = Global.leaderboard_names[0] + " : " + str(Global.leaderboard_pont[0])
	top_2.text = Global.leaderboard_names[1] + " : " + str(Global.leaderboard_pont[1])
	top_3.text = Global.leaderboard_names[2] + " : " + str(Global.leaderboard_pont[2])
	top_4.text = Global.leaderboard_names[3] + " : " + str(Global.leaderboard_pont[3])
	top_5.text = Global.leaderboard_names[4] + " : " + str(Global.leaderboard_pont[4])

func _on_button_pressed() -> void:
	Global.game.change_scene(&"gui", "uid://bf62aaybcwjik", Global.game.ChangeMode.DELETE, Transitions.FADE_BLACK)
