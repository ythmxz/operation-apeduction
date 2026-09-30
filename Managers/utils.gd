extends Node

func get_in_scene(p: NodePath = ^".") -> Node:
	if not is_instance_valid(get_tree().current_scene):
		return null
	var node = get_tree().current_scene.get_node_or_null(p)
	if node:
		return node
	return get_tree().current_scene.find_child(str(p).get_file(), true, false)
