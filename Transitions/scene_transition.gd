class_name SceneTransition extends Resource


## The total duration of the transition in seconds, split between
## [method transition_out] and [method transition_in].
@export var duration: float = 0.5


## Animates the old scene out of view.
## [br][br]
## Override this method to define the exit animation. The method must
## [code]await[/code] until the animation is complete before returning.
## [br][br]
## [param scene]: The scene being transitioned out. May be [code]null[/code]
## if no scene is currently active.
## [br]
## [param container]: The parent node that holds the scene.
func transition_out(_scene: Node, container: Node) -> void:
	await container.get_tree().create_timer(duration / 2.0, true, false, true).timeout


## Called repeatedly during asynchronous scene loading.
## [br][br]
## Override this method to update a loading indicator such as a progress bar.
## [br][br]
## [param progress]: The loading progress from [code]0.0[/code] to
## [code]1.0[/code].
func transition_hold(_progress: float) -> void:
	pass


## Animates the new scene into view.
## [br][br]
## Override this method to define the entrance animation. The method must
## [code]await[/code] until the animation is complete before returning.
## [br][br]
## [param scene]: The scene being transitioned in. May be [code]null[/code]
## if no scene is available.
## [br]
## [param container]: The parent node that holds the scene.
func transition_in(_scene: Node, container: Node) -> void:
	await container.get_tree().create_timer(duration / 2.0, true, false, true).timeout
