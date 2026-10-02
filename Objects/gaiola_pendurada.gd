extends Node3D

const ANEL_CORRENTE = preload("uid://ce7ylst4rcwse")

var time: float = 0.0
var aneis: Array[Node3D] = []
var bases: Array[Vector3] = []
var dirs: Array[Vector3] = []
var timeoffs: Array[float] = []

func register_anel(a: Node3D) -> void:
	aneis.append(a)
	bases.append(a.position)
	dirs.append(Vector3(1, 0, 0).rotated(Vector3.UP, randf_range(-2, 2)))
	timeoffs.append(randf_range(-2, 2))

func _ready() -> void:
	var anel0: Node3D = $AnelCorrente
	register_anel(anel0)
	
	var p := anel0.position
	for i in range(1, 20):
		p.y += 0.5
		var ac := ANEL_CORRENTE.instantiate()
		add_child(ac)
		ac.position = p
		ac.rotation_degrees.y = i * 70

		register_anel(ac)
		
func _physics_process(delta: float) -> void:
	for i in range(aneis.size()):
		var a := aneis[i]
		var dir := dirs[i]
		var to := timeoffs[i]
		var bp := bases[i]
		a.position = bp + dir * sin((time + to) * 2) * 0.15

	time += delta
