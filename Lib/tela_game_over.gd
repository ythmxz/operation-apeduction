extends TextureRect

@onready var tempo_l: Label = $Tempo
@onready var moedas_l: Label = $Moedas
@onready var pontuacao_l: Label = $Pontuação

var segundos := 0
var minutos := 0
var segundos_totais := 0
var moedas := 0

func _ready() -> void:
	minutos = Global.tempo_final[0]
	segundos = Global.tempo_final[1]
	segundos_totais = Global.tempo_final[2]
	moedas = Global.moedas_finais

	moedas_l.text = str(moedas)
	tempo_l.text = "%d:%02d" % [minutos, segundos]

	var calculo_pontuacao = (segundos_totais * 10) + (moedas * 200)
	pontuacao_l.text = str(calculo_pontuacao)

func _on_menu_principal_pressed() -> void:
	Global.game.switch_context(&"gui", "uid://bf62aaybcwjik", Transitions.FADE_BLACK)

func _on_reset_pressed() -> void:
	Global.game.switch_context(&"world_3d", "uid://c0g4l4d2g20kq", Transitions.FADE_BLACK)
