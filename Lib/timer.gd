extends Label

var tempo_decorrido: float = 0.0
var esta_contando: bool = true 

func _process(delta: float) -> void:
	if esta_contando:
		tempo_decorrido += delta
		var segundos_totais := int(tempo_decorrido)
		var minutos := int(segundos_totais / 60)
		var segundos := segundos_totais % 60
		text = "%d:%02d" % [minutos, segundos]
