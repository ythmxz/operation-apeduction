extends State

@onready var sm: StateMachine = $".."
@onready var player := $"../.."

func enter() -> void:
	player.set_crouch(false)

func process(_delta: float) -> void:
	if player.velocity.y <= 0.0 and player.is_on_floor():
		sm.transition(^"Walk")

func leave() -> void:
	pass
