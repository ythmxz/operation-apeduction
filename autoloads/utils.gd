extends Node


func find_recursive(node_name: StringName) -> Node:
	var current_scene: Node = get_tree().current_scene

	if not is_instance_valid(current_scene):
		return null

	return current_scene.find_child(node_name, true, false)


func find_player() -> Player:
	return find_recursive(&"Player") as Player
