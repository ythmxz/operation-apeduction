extends Control


@export var default_button: Button = null

@export_group("Positions")
@export var top_1: Label = null
@export var top_2: Label = null
@export var top_3: Label = null
@export var top_4: Label = null
@export var top_5: Label = null

var positions: Array[Label] = []


func _ready() -> void:
	default_button.grab_focus(true)
	for node in get_tree().get_nodes_in_group("Position"):
		positions.append(node)

	for pos in positions:
		var index: int = pos.get_index()
		pos.text = str(index + 1) + ". " + Global.leaderboard_names[index] + " : " + str(Global.leaderboard_points[index])


func _on_back_button_pressed() -> void:
	Global.game.change_scene(&"gui", "uid://bf62aaybcwjik", Global.game.ChangeMode.DELETE, Transitions.FADE_BLACK)
