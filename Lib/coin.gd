extends Area3D

const ROTATION_SPEED := 150.0

@export var player: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(deg_to_rad(ROTATION_SPEED * delta))

func _on_body_entered(body: Node3D) -> void:
	if(body == player):
		queue_free()
