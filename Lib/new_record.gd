extends TextureRect

@onready var input: LineEdit = $Input

func _on_avançar_pressed() -> void:
	var nome = input.text
	Global.leaderboard_names.insert(Global.posicao, nome)
	Global.leaderboard_names.pop_back()
	
	# Tela Game Over
	Global.game.push_scene(&"gui", "uid://bojqeli1y7w6u", false)
	visible = false
