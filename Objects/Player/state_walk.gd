extends State


@onready var sm: StateMachine = $".."
@onready var player: Player = Utils.find_player()


func enter() -> void:
	player.set_crouch(false)
	player.anim_player.play("BAKED_Running",0.15)


func process(_delta: float) -> void:
	pass


func leave() -> void:
	pass
