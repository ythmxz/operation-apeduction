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
	visible = false
	Global.game.push_scene(&"gui", "uid://bojqeli1y7w6u", false)

func atualizaMoedas(quant: int):
	quant_moedas.text = "%d" % quant;
