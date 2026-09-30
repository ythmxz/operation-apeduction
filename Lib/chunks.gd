extends Node3D

# TODO: mais chunks diferentes
const CHUNK_1 := preload("uid://cwj6as3qj2bj0")

var scroll_speed: float = 0.0
var choices: Array[PackedScene] = [CHUNK_1]

func _ready() -> void:
	# TODO: detectar quando que precisa com base na distância do fog ou algo assim (ou ter uma linha de limite lá longe mesmo)
	var timer := get_tree().create_timer(1.0)
	timer.timeout.connect(spawn_chunk)

func _physics_process(delta: float) -> void:
	for c in get_children():
		c.position.z += scroll_speed * delta
		if c.get_node(^"EndIndicator").global_position.z >= 0.0:
			# TODO: deixar isso inmperceptível p/ a câmera
			c.queue_free()

func spawn_chunk() -> void:
	var arr: Array[PackedScene] = choices.duplicate()
	arr.shuffle()

	var last_chunk := get_children()[-1]
	print("Last chunk: ", last_chunk)

	var chunk := arr[0].instantiate()
	add_child(chunk)
	chunk.global_position = last_chunk.get_node(^"EndIndicator").global_position
