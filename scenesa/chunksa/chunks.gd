extends Node3D


# Distâncias p/ spawnar e despawnar.
const DISTANCE_TO_SPAWN: float = 100.0
const DISTANCE_TO_DESPAWN: float = 5.0

var last_chunk_type: PackedScene = null
var scroll_speed: float = 0.0
var choices: Array[PackedScene] = [
	preload("res://scenes/chunks/chunk_1.tscn"),
	preload("res://scenes/chunks/chunk_2.tscn"),
	preload("res://scenes/chunks/chunk_3.tscn"),
	preload("res://scenes/chunks/chunk_3_v2.tscn"),
	preload("res://scenes/chunks/chunk_4.tscn"),
	preload("res://scenes/chunks/chunk_5.tscn"),
]


func _physics_process(delta: float) -> void:
	for c in get_children():
		c.position.z += scroll_speed * delta

		if c.get_node(^"EndIndicator").global_position.z >= DISTANCE_TO_DESPAWN:
			print("Freeing old chunk: ", c)
			c.queue_free()

	var ch := get_children()

	if ch.is_empty():
		spawn_chunk()
	else:
		var ei := ch[-1].get_node(^"EndIndicator")

		if ei.global_position.z >= -DISTANCE_TO_SPAWN:
			spawn_chunk()
			print(ei.global_position.z)


func spawn_chunk() -> void:
	print("Spawning new random chunk...")

	var arr: Array[PackedScene] = choices.duplicate()
	arr.shuffle()

	var picked: PackedScene = arr[0]

	if last_chunk_type != null and picked == last_chunk_type and arr.size() > 1:
		# trocar se for o exato mesmo tipo de chunk que antes
		picked = arr[1]
	last_chunk_type = picked

	var last_chunk := get_children()[-1]
	var chunk := picked.instantiate()

	add_child(chunk)
	chunk.global_position = last_chunk.get_node(^"EndIndicator").global_position
