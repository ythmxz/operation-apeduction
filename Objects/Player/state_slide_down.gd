extends State

@onready var sm: StateMachine = $".."
@onready var player := $"../.."

var timer: float

func enter() -> void:
	timer = 0.5
	player.set_crouch(true)
	player.anim_player.play("BAKED_Jump Air", 0.1)

func process(delta: float) -> void:
	timer = maxf(0.0, timer - delta)
	if timer <= 0.0 and not Input.is_action_pressed("ui_down") and player.has_upper_collision():
		sm.transition(^"Walk")

func leave() -> void:
	pass
