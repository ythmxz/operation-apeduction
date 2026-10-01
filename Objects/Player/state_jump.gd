extends State

@onready var sm: StateMachine = $".."
@onready var player := $"../.."

func enter() -> void:
	player.set_crouch(false)
	player.anim_player.play("BAKED_Jump_Up",0.1)
	
func process(_delta: float) -> void:
	if player.velocity.y <= 0.0 and player.is_on_floor():
		sm.transition(^"Walk")

func leave() -> void:
	pass
