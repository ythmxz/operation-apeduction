extends Control

@onready var quant_moedas: Label = $QuantMoedas

func atualizaMoedas(quant: int):
	quant_moedas.text = "%d" % quant;
