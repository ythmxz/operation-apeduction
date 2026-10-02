extends Control

@onready var timer: Label = $Timer

@onready var quant_moedas: Label = $QuantMoedas

@onready var player: CharacterBody3D = $"../Player"

var tempo_decorrido: float = 0.0

var esta_contando: bool = true

var temp_arm := [0,0,0]

func _ready() -> void:
	player.died.connect(tela_game_over)

func _physics_process(delta: float) -> void:

	if esta_contando:

		tempo_decorrido += delta

		var segundos_totais = int(tempo_decorrido)

		var minutos = segundos_totais / 60
		var segundos = segundos_totais % 60

		temp_arm = [minutos, segundos, segundos_totais]

		timer.text = "%d:%02d" % [minutos, segundos]

func tela_game_over():
	Global.tempo_final = temp_arm
	Global.moedas_finais = int(quant_moedas.text)
	var pont = (temp_arm[2] * 10) + (int(quant_moedas.text) * 200)
	Global.pontuacao_final = pont
	visible = false

	var recorde = false

	for x in range(5):
		if pont > Global.leaderboard_pont[x]:
			Global.leaderboard_pont.insert(x, pont)
			Global.leaderboard_pont.pop_back()
			Global.posicao = x
			recorde = true
			break

	if recorde:
		# Tela Novo Recorde
		Global.game.push_scene(&"gui", "uid://bsykrsga2gh2b", false)
	else:
		# Tela Game Over
		Global.game.push_scene(&"gui", "uid://bojqeli1y7w6u", false)

func atualizaMoedas(quant: int):
	quant_moedas.text = "%d" % quant;
