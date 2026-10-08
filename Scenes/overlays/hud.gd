extends Control


@onready var player: CharacterBody3D = Utils.find_player()

var elapsed_time: float = 0.0
var is_counting := true
var stored_time: Array[int] = [0, 0, 0]

@export var time_label: Label = null
@export var coins_label: Label = null


func _ready() -> void:
	player.hud = self
	player.died.connect(_on_player_died)


func _physics_process(delta: float) -> void:
	if is_counting:
		elapsed_time += delta

		var total_seconds := int(elapsed_time)
		var minutes := int(float(total_seconds) / 60)
		var seconds: int = total_seconds % 60

		stored_time = [minutes, seconds, total_seconds]
		time_label.text = "%d:%02d" % [minutes, seconds]


func _on_player_died() -> void:
	Global.final_time = stored_time
	Global.final_coins = int(coins_label.text)

	var score: int = (stored_time[2] * 10) + (int(coins_label.text) * 200)
	Global.final_score = score

	var high_score := false

	for x in Global.leaderboard_points.size():
		if score > Global.leaderboard_points[x]:
			Global.leaderboard_points.insert(x, score)
			Global.leaderboard_points.pop_back()
			Global.position = x

			high_score = true
			break

	if high_score:
		Global.game.change_scene(&"gui", "uid://bsykrsga2gh2b")
	else:
		Global.game.change_scene(&"gui", "uid://bojqeli1y7w6u")


func update_coins(amount: int):
	coins_label.text = "%d" % amount
