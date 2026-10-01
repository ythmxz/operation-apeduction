extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_menu_principal_pressed() -> void:
	Global.game.switch_context(&"gui", "uid://bf62aaybcwjik", Transitions.FADE_BLACK)

func _on_reset_pressed() -> void:
	Global.game.switch_context(&"world_3d", "uid://c0g4l4d2g20kq", Transitions.FADE_BLACK)
