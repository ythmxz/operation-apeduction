extends CharacterBody3D
class_name Player

signal died()

var min_lane := -1
var max_lane := 1
var cur_lane := 0
const LANE_WIDTH: float = 1.65

const GRAVITY: float = 40

@onready var hud: Control = $"../HUD"
var moedas := 0

@onready var x_center := position.x
@onready var sm: StateMachine = $StateMachine

@onready var areas_lower: Array[Area3D] = [$AreaLF, $AreaLL, $AreaLR]
@onready var areas_upper: Array[Area3D] = [$AreaUF, $AreaUL, $AreaUR]
@onready var collider_u: CollisionShape3D = $ColliderU

@onready var placeholder_model: Node3D = $Mona
@onready var placeholder_model_crouch: Node3D = $PlaceholderModelCrouch
@onready var anim_player: AnimationPlayer = $Mona/AnimationPlayer

const STATE_TO_ANIMATION := {
	&"Walk": "BAKED_Running",
	&"Jump": "BAKED_Jump_Up",
	&"DashDown": "BAKED_Jump Air",
}

var l_cur_state: Debug.Entry = null

var is_dead := false
var is_crouching := false

func _ready() -> void:
	after_ready.call_deferred()

func after_ready() -> void:
	var sensors: Array[Area3D] = []
	var labels: Array[Debug.Entry] = []
	var callbacks := []

	for s in areas_lower:
		sensors.append(s)
		labels.append(Debug.alloc_entry("Coll.{0}".format([s.name]), self))
		callbacks.append(on_lower_front_collision)

	for s in areas_upper:
		sensors.append(s)
		labels.append(Debug.alloc_entry("Coll.{0}".format([s.name]), self))
		callbacks.append(on_upper_front_collision)

	for i in range(0, len(sensors)):
		var s = sensors[i]
		var l = labels[i]
		var c = callbacks[i]

		s.body_entered.connect(func(body: Node3D) -> void:
			l.set_text(str(body))
			c.call(body)
		)

		s.body_exited.connect(func(_body: Node3D) -> void:
			l.set_text("")
		)

	l_cur_state = Debug.alloc_entry("State", self)
	sm.transitioned.connect(func(_old, new):
		l_cur_state.set_text(new.name)
	)

	anim_player.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	velocity.y -= GRAVITY * delta
	move_and_slide()

	if is_dead:
		velocity.x = 0
		velocity.z = 0
	else:
		var x_dest := x_center + cur_lane * LANE_WIDTH
		velocity.x = (x_dest - position.x) * 0.3 / delta
		velocity.z = (0 - position.z) * 0.8 / delta
		handle_input()

	if global_position.y <= -5.0:
		die()

	cur_lane = clampi(cur_lane, min_lane, max_lane)

	if Input.is_action_just_pressed("debug_restart") or Input.is_action_just_pressed("restart"):
		Global.game.switch_context(&"world_3d", "uid://c0g4l4d2g20kq", Transitions.FADE_BLACK)

func handle_input():
	if Input.is_action_just_pressed("move_right"):
		shift_lane(&"Right")
	if Input.is_action_just_pressed("move_left"):
		shift_lane(&"Left")

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = 15
		sm.transition(^"Jump")

	if sm.get_state_name() == &"Jump" and Input.is_action_just_pressed("slide"):
		velocity.y = minf(velocity.y, -30)
		sm.transition(^"DashDown")

	if sm.get_state_name() == &"Walk" and Input.is_action_just_pressed("slide"):
		sm.transition(^"SlideDown")

func has_upper_collision() -> bool:
	for a in areas_upper:
		if a.get_overlapping_bodies().size() == 0:
			return true
	return false

func die() -> void:
	if is_dead:
		return
	is_dead = true
	died.emit()

func set_crouch(crouch: bool) -> void:
	placeholder_model.visible = not crouch
	placeholder_model_crouch.visible = crouch
	collider_u.disabled = crouch
	is_crouching = crouch

func on_lower_front_collision(_body: Node3D) -> void:
	die()

func on_upper_front_collision(_body: Node3D) -> void:
	if not is_crouching:
		die()

func coleta_moedas():
	moedas += 1
	hud.atualizaMoedas(moedas)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "BAKED_Shift Left" or anim_name == "BAKED_Shift Right":
		var current_anim: String = STATE_TO_ANIMATION.get(sm.get_state_name(), "BAKED_Running")
		anim_player.play(current_anim, 0.15)

func shift_lane(direction: StringName) -> void:
	cur_lane += -1 if (direction == &"Left") else 1
	anim_player.play("BAKED_Shift %s" % direction, 0.1, 1.25)
