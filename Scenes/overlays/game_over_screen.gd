extends Control


@export var default_button: TextureButton = null
@export var time_label: Label = null
@export var coins_label: Label = null
@export var score_label: Label = null

var seconds: int = 0
var minutes: int = 0
var seconds_totais: int = 0
var coins: int = 0

func _ready() -> void:
	default_button.grab_focus(true)

	minutes = Global.final_time[0]
	seconds = Global.final_time[1]
	seconds_totais = Global.final_time[2]
	coins = Global.final_coins

	coins_label.text = str(coins)
	time_label.text = "%02d:%02d" % [minutes, seconds]
	score_label.text = str(Global.final_score)

func _on_menu_button_pressed() -> void:
	Global.game.switch_context(&"gui", "uid://bf62aaybcwjik", Transitions.FADE_BLACK)


func _on_retart_button_pressed() -> void:
	Global.game.switch_context(&"world_3d", "uid://c0g4l4d2g20kq", Transitions.FADE_BLACK)
