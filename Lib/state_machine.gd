extends Node
class_name StateMachine

@export var default_state: NodePath
@onready var current_state := get_node(default_state)

signal transitioned(old: Node2D, new: Node2D)

func get_state_name() -> StringName:
	return current_state.name

func transition(path: NodePath) -> void:
	var old_state = current_state
	var new_state = get_node(path)

	if old_state != null:
		old_state.leave()
	current_state = new_state
	current_state.enter()

	transitioned.emit(old_state, new_state)

func _process(delta: float) -> void:
	current_state.process(delta)
	
func _ready() -> void:
	current_state.enter.call_deferred()
