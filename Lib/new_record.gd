extends TextureRect

@onready var input: LineEdit = $Input
@export var texto_label: Label = null
@export var avancar_button: Button = null

func _ready() -> void:
	texto_label.grab_focus()

func _on_avançar_pressed() -> void:
	var nome = input.text
	Global.leaderboard_names.insert(Global.posicao, nome)
	Global.leaderboard_names.pop_back()

	# Tela Game Over
	Global.game.push_scene(&"gui", "uid://bojqeli1y7w6u", false)
	visible = false


func _on_texto_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		avancar_button.grab_focus()
