extends Area3D


const ROTATION_SPEED := 150.0


func _process(delta: float) -> void:
	rotate_y(deg_to_rad(ROTATION_SPEED * delta))


func _on_body_entered(body: Node3D) -> void:
	var player := body as Player

	if player == null:
		return

	player.collect_coin()
	queue_free()
