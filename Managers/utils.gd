extends Node

func find_recursive(name_: StringName) -> Node:
	var cur_scene := get_tree().current_scene

	if not is_instance_valid(cur_scene):
		return null

	return cur_scene.find_child(name_, true, false)

func find_player() -> Player:
	return find_recursive(&"Player") as Player
