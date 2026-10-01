extends Node3D

@onready var chunks: Node3D = $Chunks
@onready var camera := $Camera3D

const SCROLL_SPEED := 10.0
const BACK_INIT_SCROLL_SPEED := -15.0
const BACK_DECCEL := 60.0

enum State { Playing, Died }
var state := State.Playing

var player: Node3D = null

func _ready() -> void:
	_push_ui()
	player = $"Player"
	player.died.connect(func():
		state = State.Died
		chunks.scroll_speed = BACK_INIT_SCROLL_SPEED
	)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Global.game.switch_context(&"gui", "uid://bf62aaybcwjik", Transitions.FADE_BLACK)

func _push_ui() -> void:
	while Global.game.is_transitioning(&"gui"):
		var layer = await Global.game.transition_finished
		if layer == &"gui":
			break
	Global.game.push_scene(&"gui", "uid://coe5waorggm7n", false)

func _physics_process(delta: float) -> void:
	if state == State.Playing:
		chunks.scroll_speed = SCROLL_SPEED
	elif state == State.Died:
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
