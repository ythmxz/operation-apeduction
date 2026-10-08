class_name FadeTransition
extends SceneTransition


## The color to fade through.
@export var color: Color = Color.BLACK

var _canvas_layer: CanvasLayer
var _overlay: ColorRect


func _init(p_duration: float = 0.5, p_color: Color = Color.BLACK) -> void:
	duration = p_duration
	color = p_color


func transition_out(_scene: Node, container: Node) -> void:
	_create_overlay(container)
	var tween := container.get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_overlay, "color:a", 1.0, duration / 2.0)
	await tween.finished


func transition_in(_scene: Node, container: Node) -> void:
	if not _overlay:
		_create_overlay(container)
		_overlay.color.a = 1.0
	var tween := container.get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_overlay, "color:a", 0.0, duration / 2.0)
	await tween.finished
	_cleanup()


func _create_overlay(container: Node) -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 128
	container.get_tree().root.add_child(_canvas_layer)

	_overlay = ColorRect.new()
	_overlay.color = Color(color, 0.0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas_layer.add_child(_overlay)


func _cleanup() -> void:
	if _canvas_layer:
		_canvas_layer.queue_free()
		_canvas_layer = null
		_overlay = null
