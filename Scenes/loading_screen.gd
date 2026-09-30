extends Control

# https://www.gotut.net/loading-screen-in-godot-4/

var progress: Array[float]
@onready var progress_bar: ProgressBar = $ProgressBar
var target: String = ""

func load_scene(target: String) -> void:
	ResourceLoader.load_threaded_request(target)

func _process(_delta: float) -> void:
	if target == "":
		return

	var loading_status := ResourceLoader.load_threaded_get_status(target, progress)

	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100
		ResourceLoader.THREAD_LOAD_LOADED:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(target))
		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("COULD NOT LOAD RESOURCE")
