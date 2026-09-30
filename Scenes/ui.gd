extends CanvasLayer

@onready var camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D
var player: CharacterBody3D = null

func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().root.find_child("Player", true, false) as CharacterBody3D

	if is_instance_valid(player):
		camera.global_position = player.global_position + Vector3(0, 4, 0)
