class_name AlphaTransition extends SceneTransition


func _init(p_duration: float = 0.5) -> void:
	duration = p_duration


func transition_out(_scene: Node, container: Node) -> void:
	if not _scene is CanvasItem:
		return

	var canvas_item := _scene as CanvasItem
	var tween := container.get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(canvas_item, "modulate:a", 0.0, duration / 2.0)
	await tween.finished


func transition_in(_scene: Node, container: Node) -> void:
	if not _scene is CanvasItem:
		return

	var canvas_item := _scene as CanvasItem
	# Reset or start at 0 opacity
	canvas_item.modulate.a = 0.0

	var tween := container.get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(canvas_item, "modulate:a", 1.0, duration / 2.0)
	await tween.finished
