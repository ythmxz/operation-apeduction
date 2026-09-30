extends Node

var is_enabled: bool = true

var labels: Node = null
var entries: Array[Entry] = []

func _ready() -> void:
	if is_enabled:
		get_tree().node_added.connect(on_node_added)
		labels = get_tree().root.find_child("DebugLabels", true, false)
		if is_instance_valid(labels):
			_flush_entries()

func on_node_added(node: Node) -> void:
	if node.name == &"DebugLabels":
		labels = node
		_flush_entries()

func _flush_entries() -> void:
	if not is_instance_valid(labels):
		return
	for e in entries:
		if not is_instance_valid(e.label):
			var l := Label.new()
			labels.add_child(l)
			e.label = l
			e.update_text()

class Entry:
	var name: StringName
	var label: Label
	var current_val: String = ""

	func set_text(val: String) -> void:
		current_val = val
		update_text()

	func update_text() -> void:
		if is_instance_valid(label):
			label.text = "{0}: {1}".format([name, current_val])

	func on_exit() -> void:
		if is_instance_valid(label):
			label.queue_free()

func alloc_entry(name_: StringName, dep: Node) -> Entry:
	var e := Entry.new()
	e.name = name_

	if is_instance_valid(labels):
		var l := Label.new()
		labels.add_child(l)
		e.label = l

	e.set_text("")

	dep.tree_exiting.connect(func():
		e.on_exit()
		entries.erase(e)
	)
	entries.append(e)
	return e
