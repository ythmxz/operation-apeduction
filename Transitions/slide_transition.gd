class_name SlideTransition extends SceneTransition


## The direction the old scene exits toward during [method transition_out].
## The new scene enters from the opposite side during [method transition_in].
enum Direction {
	LEFT,
	RIGHT,
	UP,
	DOWN,
}


## The exit direction for [method transition_out].
@export var direction: Direction = Direction.LEFT


func _init(p_duration: float = 0.3, p_direction: Direction = Direction.LEFT) -> void:
	duration = p_duration
	direction = p_direction


func transition_out(_scene: Node, container: Node) -> void:
	if not _scene is CanvasItem:
		return

	var canvas_item := _scene as CanvasItem
	var original_position: Vector2 = canvas_item.position
	canvas_item.set_meta(&"_slide_original_position", original_position)

	var offset := _get_offset(container)
	var tween := container.get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(
		canvas_item, "position", original_position + offset, duration / 2.0
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	await tween.finished


func transition_in(_scene: Node, container: Node) -> void:
	if not _scene is CanvasItem:
		return

	var canvas_item := _scene as CanvasItem

	# Determine target position (restore saved or use current).
	var target_position: Vector2
	if canvas_item.has_meta(&"_slide_original_position"):
		target_position = canvas_item.get_meta(&"_slide_original_position")
		canvas_item.remove_meta(&"_slide_original_position")
	else:
		target_position = canvas_item.position

	# Start off-screen from the opposite side.
	var offset := _get_offset(container)
	canvas_item.position = target_position - offset
	canvas_item.visible = true

	var tween := container.get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(
		canvas_item, "position", target_position, duration / 2.0
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished


func _get_offset(container: Node) -> Vector2:
	var viewport_size := container.get_viewport().get_visible_rect().size
	match direction:
		Direction.LEFT:
			return Vector2(-viewport_size.x, 0.0)
		Direction.RIGHT:
			return Vector2(viewport_size.x, 0.0)
		Direction.UP:
			return Vector2(0.0, -viewport_size.y)
		Direction.DOWN:
			return Vector2(0.0, viewport_size.y)
	return Vector2.ZERO
