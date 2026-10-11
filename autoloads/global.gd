extends Node


var game: Game = null

var final_time: Array[int] = [0, 0, 0]
var final_coins: int = 0
var final_score: int = 0
var position: int = 0

var leaderboard_points: Array[int] = [0, 0, 0, 0, 0]
var leaderboard_names: Array[String] = ["???", "???", "???", "???", "???"]

var leaderboard_path := "user://leaderboard.dat"

func load_leaderboard() -> void:
	var fd := FileAccess.open(leaderboard_path, FileAccess.READ)
	if fd == null:
		print("Leaderboard ({0}) could not be loaded".format([leaderboard_path]))
		return

	var data = fd.get_var()
	leaderboard_points = data.points
	leaderboard_names = data.names

func save_leaderboard() -> void:
	var fd := FileAccess.open(leaderboard_path, FileAccess.WRITE)
	fd.store_var({"points": leaderboard_points, "names": leaderboard_names})

func _ready() -> void:
	load_leaderboard()
