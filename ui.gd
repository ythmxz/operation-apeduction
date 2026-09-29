extends CanvasLayer

@onready var camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D
@onready var player: CharacterBody3D = $"../Player"

func _process(_delta: float) -> void:
	camera.global_position = player.global_position + Vector3(0, 4, 0)
