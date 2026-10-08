extends Node3D


enum State {
	PLAYING,
	DIED,
}

const SCROLL_SPEED: float = 10.0
const BACK_INIT_SCROLL_SPEED: float = -15.0
const BACK_DECCEL: float = 60.0

var state := State.PLAYING
var player: Node3D = null
var song_choices: Array[StringName] = [&"Tmp1", &"Tmp2", &"Tmp3", &"Tmp4", &"Tmp5", &"Tmp6"]

@onready var chunks: Node3D = $Chunks
@onready var camera := $Camera3D


func _ready() -> void:
	_push_ui()
	player = $"Player"
	player.died.connect(on_died)
	chunks.scroll_speed = SCROLL_SPEED
	Music.play(song_choices.pick_random(), -5)


func on_died() -> void:
	state = State.DIED
	chunks.scroll_speed = BACK_INIT_SCROLL_SPEED
	Music.play(&"Results")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		Global.game.switch_context(&"gui", "uid://bf62aaybcwjik", Transitions.FADE_BLACK)


func _push_ui() -> void:
	while Global.game.is_transitioning(&"gui"):
		var layer = await Global.game.transition_finished

		if layer == &"gui":
			break

	# push_scene marks the layer as transitioning until it finishes, so any
	# further push must be awaited before starting the next one.
	await Global.game.push_scene(&"gui", "uid://y232dhvambw3", false)


func _physics_process(delta: float) -> void:
	if state == State.PLAYING:
		pass # chunks.scroll_speed += 1 * delta
	elif state == State.DIED:
		chunks.scroll_speed = move_toward(chunks.scroll_speed, 0.0, BACK_DECCEL * delta)

	var cam_y: float = camera.global_position.y
	var tgt_y: float = max(-2, player.global_position.y + 3.5)
	var dist := absf(cam_y - tgt_y)

	var follow_factor := (
		0.00 if (dist <= 1) else
		0.02 if (dist <= 3) else
		0.08 if (dist <= 5) else
		0.10
	)

	camera.global_position.y = move_toward(cam_y, tgt_y, abs(cam_y - tgt_y) * follow_factor)
