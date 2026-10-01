extends State

# TODO: talvez tirar esse estado (acho que fica ruim na hora de jogar com movimento)

@onready var sm: StateMachine = $".."
@onready var player := $"../.."

func enter() -> void:
	player.set_crouch(true)
	player.anim_player.play("BAKED_Jump Air",0.15)

func process(_delta: float) -> void:
	if player.is_on_floor():
		sm.transition(^"SlideDown")

func leave() -> void:
	pass
