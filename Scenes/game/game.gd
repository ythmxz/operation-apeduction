class_name Game
extends Node


signal transition_started(layer: StringName)
signal transition_finished(layer: StringName)
signal scene_changed(layer: StringName, old_scene: Node, new_scene: Node)

## Determines how the old scene is handled during a scene change.
enum ChangeMode {
	## Removes the scene from memory.
	DELETE,
	## Keeps the scene in memory and running, but hidden.
	HIDE,
	## Keeps the scene in memory without running (removed from the scene tree).
	DISABLE,
}

@export var world_3d: Node3D = null
@export var world_2d: Node2D = null
@export var gui: Control = null

var _layers: Dictionary[StringName, Node] = {}

## Maps layer names to their scene stacks. Each element is a [Dictionary]
## with keys [code]"scene"[/code] ([Node]) and [code]"blocker"[/code]
## ([Control] or [code]null[/code]).
var _scene_stacks: Dictionary[StringName, Array] = {}

## Caches scene instances by resource path for reuse after [constant HIDE] or
## [constant DISABLE] operations.
var _scene_cache: Dictionary[String, Node] = {}

## Tracks which layers are currently in the middle of a transition.
var _transitioning: Dictionary[StringName, bool] = {}


func _init() -> void:
	if Global.game == null:
		Global.game = self


func _ready() -> void:
	# Ensure the Game manager and GUI always process, while worlds can be paused.
	process_mode = Node.PROCESS_MODE_ALWAYS

	if world_3d:
		world_3d.process_mode = Node.PROCESS_MODE_PAUSABLE
	if world_2d:
		world_2d.process_mode = Node.PROCESS_MODE_PAUSABLE
	if gui:
		gui.process_mode = Node.PROCESS_MODE_ALWAYS

	_register_layer(&"world_3d", world_3d)
	_register_layer(&"world_2d", world_2d)
	_register_layer(&"gui", gui)

	# Cache any scenes that were placed in the tree via the editor.
	for layer_name: StringName in _layers:
		_cache_existing_children(layer_name)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		elif DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


## Replaces the topmost scene in the given [param layer].
## [br][br]
## If the layer's stack is empty, the new scene is pushed as the first entry.
## Otherwise, the topmost scene is handled according to [param mode] and
## replaced with the scene at [param scene_path].
## [br][br]
## [param layer]: The target layer name.
## [br]
## [param scene_path]: The resource path of the new scene
## ([code]res://...[/code]).
## [br]
## [param mode]: How to handle the old scene. Defaults to [constant DELETE].
## [br]
## [param transition]: Optional [SceneTransition] to animate the change.
func change_scene(layer: StringName, scene_path: String, mode: ChangeMode = ChangeMode.DELETE, transition: SceneTransition = null) -> void:
	if not _validate_layer(layer):
		return

	if _transitioning[layer]:
		push_warning("Game: Layer '%s' is already transitioning." % layer)

		return

	var container: Node = _layers[layer]
	var stack: Array = _scene_stacks[layer]
	var old_scene: Node = _get_top_scene(layer)
	var t := transition.duplicate() if transition else null

	_transitioning[layer] = true
	transition_started.emit(layer)

	# Transition out the old scene.
	if t and old_scene:
		await t.transition_out(old_scene, container)

	# Handle the old scene according to the requested mode.
	if old_scene:
		_handle_old_scene(old_scene, mode)

	# Load and add the new scene.
	var new_scene := await _load_and_instantiate(scene_path, t, true, container)

	if not new_scene:
		_transitioning[layer] = false
		transition_finished.emit(layer)

		return

	_add_scene_to_container(new_scene, container)

	# Update the stack: replace the top entry or create a new one.
	if stack.size() > 0:
		stack[-1]["scene"] = new_scene
	else:
		stack.append({"scene": new_scene, "blocker": null})

	# Transition in the new scene.
	if t:
		await t.transition_in(new_scene, container)

	_transitioning[layer] = false
	transition_finished.emit(layer)
	scene_changed.emit(layer, old_scene, new_scene)


## Wipes all layers completely and loads a new scene into the target
## [param layer]. Ideal for major state changes (e.g. Menu to Game).
func switch_context(layer: StringName, scene_path: String, transition: SceneTransition = null) -> void:
	if not _validate_layer(layer):
		return

	for l: StringName in _layers:
		if _transitioning[l]:
			push_warning("Game: Cannot switch context, layer '%s' is transitioning." % l)

			return

	var container: Node = _layers[layer]
	var t := transition.duplicate() if transition else null

	for l: StringName in _layers:
		_transitioning[l] = true
		transition_started.emit(l)

	# 1. Transition out the topmost visual scene across all layers
	var top_visual_scene: Node = null

	for l in [&"gui", &"world_2d", &"world_3d"]:
		if _layers.has(l) and not _scene_stacks[l].is_empty():
			top_visual_scene = _scene_stacks[l][-1]["scene"]
			break

	if t and top_visual_scene:
		await t.transition_out(top_visual_scene, container)
	elif t:
		await t.transition_out(null, container)

	# 2. Silently wipe all layers (delete everything)
	for l: StringName in _layers:
		var stack: Array = _scene_stacks[l]

		while not stack.is_empty():
			var entry: Dictionary = stack.pop_back()
			_handle_old_scene(entry["scene"], ChangeMode.DELETE)
			var blocker: Control = entry["blocker"]

			if blocker and is_instance_valid(blocker):
				blocker.queue_free()

	# 3. Load and add new scene to the target layer
	var new_scene := await _load_and_instantiate(scene_path, t, false, container)

	if new_scene:
		_add_scene_to_container(new_scene, container)
		_scene_stacks[layer].append({"scene": new_scene, "blocker": null})

	# 4. Transition in
	if t:
		await t.transition_in(new_scene, container)

	for l: StringName in _layers:
		_transitioning[l] = false
		transition_finished.emit(l)

		if l == layer:
			scene_changed.emit(l, null, new_scene)
		else:
			scene_changed.emit(l, null, null)


## Pushes a new scene on top of the given [param layer]'s stack.
## [br][br]
## The current topmost scene remains in the tree. An optional input blocker
## can be placed between the old and new scenes to prevent mouse interaction
## with scenes below.
## [br][br]
## [param layer]: The target layer name.
## [br]
## [param scene_path]: The resource path of the scene to push
## ([code]res://...[/code]).
## [br]
## [param block_input]: If [code]true[/code], a full-screen [Control] is
## added below the new scene to block mouse input to scenes underneath.
## Only effective when the layer container is a [Control].
## [br]
## [param transition]: Optional [SceneTransition] to animate the entrance.
func push_scene(layer: StringName, scene_path: String, block_input: bool = true, transition: SceneTransition = null) -> void:
	if not _validate_layer(layer):
		return

	if _transitioning[layer]:
		push_warning("Game: Layer '%s' is already transitioning." % layer)

		return

	var container: Node = _layers[layer]
	var old_scene: Node = _get_top_scene(layer)
	var t := transition.duplicate() if transition else null

	_transitioning[layer] = true
	transition_started.emit(layer)

	# Transition out the current scene.
	if t and old_scene:
		await t.transition_out(old_scene, container)

	# Restore position if the transition displaced the old scene (e.g. slide).
	_restore_scene_position(old_scene)

	# Add an input blocker before the new scene when requested.
	var blocker: Control = null
	if block_input:
		blocker = _create_input_blocker(container)

	# Load and add the new scene (always a fresh instance for push).
	var new_scene := await _load_and_instantiate(scene_path, t, false, container)

	if not new_scene:
		if blocker:
			blocker.queue_free()

		_transitioning[layer] = false
		transition_finished.emit(layer)

		return

	_add_scene_to_container(new_scene, container)
	_scene_stacks[layer].append({"scene": new_scene, "blocker": blocker})

	# Transition in the new scene.
	if t:
		await t.transition_in(new_scene, container)

	_transitioning[layer] = false
	transition_finished.emit(layer)
	scene_changed.emit(layer, old_scene, new_scene)


## Pops the topmost scene from the given [param layer]'s stack.
## [br][br]
## The popped scene is handled according to [param mode]. If the stack still
## has scenes below, the next one becomes the active scene.
## [br][br]
## [param layer]: The target layer name.
## [br]
## [param mode]: How to handle the popped scene. Defaults to [constant DELETE].
## [br]
## [param transition]: Optional [SceneTransition] to animate the removal.
func pop_scene(layer: StringName, mode: ChangeMode = ChangeMode.DELETE, transition: SceneTransition = null) -> void:
	if not _validate_layer(layer):
		return

	if _transitioning[layer]:
		push_warning("Game: Layer '%s' is already transitioning." % layer)

		return

	var stack: Array = _scene_stacks[layer]

	if stack.is_empty():
		push_warning("Game: Layer '%s' stack is empty, nothing to pop." % layer)

		return

	var container: Node = _layers[layer]
	var entry: Dictionary = stack[-1]
	var popped_scene: Node = entry["scene"]
	var blocker: Control = entry["blocker"]
	var t := transition.duplicate() if transition else null

	_transitioning[layer] = true
	transition_started.emit(layer)

	# Transition out the scene being popped.
	if t and popped_scene:
		await t.transition_out(popped_scene, container)

	# Handle the popped scene and remove its input blocker.
	_handle_old_scene(popped_scene, mode)
	if blocker and is_instance_valid(blocker):
		blocker.queue_free()

	stack.pop_back()

	# Transition in the scene that was underneath.
	var revealed_scene: Node = _get_top_scene(layer)
	if t:
		if revealed_scene:
			_restore_scene_position(revealed_scene)
		await t.transition_in(revealed_scene, container)

	_transitioning[layer] = false
	transition_finished.emit(layer)
	scene_changed.emit(layer, popped_scene, revealed_scene)


## Returns the topmost scene in the given [param layer]'s stack, or
## [code]null[/code] if the stack is empty.
func get_current_scene(layer: StringName) -> Node:
	if not _validate_layer(layer):
		return null

	return _get_top_scene(layer)


## Returns a shallow copy of the scene stack for the given [param layer].
## Each element is the [Node] instance in the stack, ordered from bottom to
## top.
func get_scene_stack(layer: StringName) -> Array[Node]:
	if not _validate_layer(layer):
		return []

	var result: Array[Node] = []

	for entry: Dictionary in _scene_stacks[layer]:
		result.append(entry["scene"])

	return result


## Returns [code]true[/code] if the given [param layer] is currently in the
## middle of a scene transition.
func is_transitioning(layer: StringName) -> bool:
	return _transitioning.get(layer, false)


## Removes all scenes and input blockers from the given [param layer]'s stack
## and deletes them from memory. An optional [param transition] is applied to
## the topmost scene only.
func clear_layer(layer: StringName, transition: SceneTransition = null) -> void:
	if not _validate_layer(layer):
		return

	if _transitioning[layer]:
		push_warning("Game: Layer '%s' is already transitioning." % layer)

		return

	var stack: Array = _scene_stacks[layer]

	if stack.is_empty():
		return

	var container: Node = _layers[layer]
	var top_scene: Node = _get_top_scene(layer)
	var t := transition.duplicate() if transition else null

	_transitioning[layer] = true
	transition_started.emit(layer)

	# Transition out the topmost scene only.
	if t and top_scene:
		await t.transition_out(top_scene, container)

	# Delete every scene and blocker in the stack.
	while not stack.is_empty():
		var entry: Dictionary = stack.pop_back()
		_handle_old_scene(entry["scene"], ChangeMode.DELETE)
		var blocker: Control = entry["blocker"]

		if blocker and is_instance_valid(blocker):
			blocker.queue_free()

	# Transition in (reveals empty layer — useful for fade-from-black effect).
	if t:
		await t.transition_in(null, container)

	_transitioning[layer] = false
	transition_finished.emit(layer)
	scene_changed.emit(layer, top_scene, null)


func _register_layer(layer_name: StringName, container: Node) -> void:
	if container == null:
		push_warning("Game: Container for layer '%s' is null. Layer not registered." % layer_name)

		return

	_layers[layer_name] = container
	_scene_stacks[layer_name] = []
	_transitioning[layer_name] = false


## Scans a layer's container for scenes placed in the editor and registers
## them in both the stack and the cache.
func _cache_existing_children(layer_name: StringName) -> void:
	var container: Node = _layers.get(layer_name)

	if not container:
		return

	for child: Node in container.get_children():
		if child.scene_file_path:
			_scene_cache[child.scene_file_path] = child
			_scene_stacks[layer_name].append({
				"scene": child,
				"blocker": null,
			})


func _validate_layer(layer: StringName) -> bool:
	if layer not in _layers:
		push_error("Game: Unknown layer '%s'." % layer)

		return false

	return true


func _get_top_scene(layer: StringName) -> Node:
	var stack: Array = _scene_stacks[layer]

	if stack.is_empty():
		return null

	return stack[-1]["scene"]


## Loads and returns a scene instance. When [param use_cache] is
## [code]true[/code], a previously cached instance (from [constant HIDE] or
## [constant DISABLE]) is returned if available. Otherwise a fresh instance is
## always created.
func _load_and_instantiate(scene_path: String, transition: SceneTransition, use_cache: bool, container: Node) -> Node:
	if use_cache and scene_path in _scene_cache:
		var cached: Node = _scene_cache[scene_path]
		var cached_parent: Node = cached.get_parent()

		# Only reuse the cached instance if it belongs to this container or
		# has been removed from the tree entirely (DISABLE mode).
		if cached_parent == null or cached_parent == container:
			_scene_cache.erase(scene_path)

			return cached

	var packed_scene := await _load_scene_async(scene_path, transition)

	if not packed_scene:
		return null

	return packed_scene.instantiate()


## Loads a [PackedScene] asynchronously via [ResourceLoader]. Calls
## [method SceneTransition.transition_hold] on the transition (if provided)
## while loading progresses.
func _load_scene_async(scene_path: String, transition: SceneTransition) -> PackedScene:
	var error := ResourceLoader.load_threaded_request(scene_path)

	if error != OK:
		push_error("Game: Failed to start loading '%s': %s." % [scene_path, error_string(error)])

		return null

	var progress: Array = []

	while true:
		var status := ResourceLoader.load_threaded_get_status(scene_path, progress)

		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				if transition:
					transition.transition_hold(
						progress[0] if progress.size() > 0 else 0.0
					)
				await get_tree().process_frame
			ResourceLoader.THREAD_LOAD_LOADED:
				if transition:
					transition.transition_hold(1.0)
				return ResourceLoader.load_threaded_get(scene_path) as PackedScene
			_:
				push_error("Game: Failed to load '%s'." % scene_path)
				return null

	return null


## Adds a scene to a container node. If the scene is already a child (e.g.
## reactivated from [constant HIDE]), it is moved to the end of the child
## list to maintain correct draw order.
func _add_scene_to_container(scene: Node, container: Node) -> void:
	if scene.get_parent() == null:
		container.add_child(scene)
	elif scene.get_parent() == container:
		container.move_child(scene, container.get_child_count() - 1)

	if scene is CanvasItem:
		(scene as CanvasItem).visible = true
	elif scene is Node3D:
		(scene as Node3D).visible = true


## Processes an old scene according to the given [param mode].
func _handle_old_scene(scene: Node, mode: ChangeMode) -> void:
	if not scene:
		return

	match mode:
		ChangeMode.DELETE:
			_scene_cache.erase(scene.scene_file_path)
			scene.queue_free()
		ChangeMode.HIDE:
			if scene is CanvasItem:
				(scene as CanvasItem).visible = false
			elif scene is Node3D:
				(scene as Node3D).visible = false
			if scene.scene_file_path:
				_scene_cache[scene.scene_file_path] = scene
		ChangeMode.DISABLE:
			if scene.get_parent():
				scene.get_parent().remove_child(scene)
			if scene.scene_file_path:
				_scene_cache[scene.scene_file_path] = scene


## Creates a full-screen [Control] that blocks mouse input. Used by
## [method push_scene] to prevent interaction with scenes below the pushed
## scene. Only works when [param container] is a [Control].
func _create_input_blocker(container: Node) -> Control:
	if not container is Control:
		push_warning("Game: Input blocking is only supported for Control-based layers.")

		return null

	var blocker := Control.new()

	blocker.name = "_InputBlocker"
	blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	container.add_child(blocker)

	return blocker


## Restores a scene's position if it was displaced by a [SlideTransition].
func _restore_scene_position(scene: Node) -> void:
	if not scene or not scene is CanvasItem:
		return

	var canvas_item := scene as CanvasItem

	if canvas_item.has_meta(&"_slide_original_position"):
		canvas_item.position = canvas_item.get_meta(&"_slide_original_position")
		canvas_item.remove_meta(&"_slide_original_position")
