extends Node


## Cada entry aqui tem como valor: [resource_path, stream].
## Stream começa como nulo mas em _ready() a gente seta ele.
var songs: Dictionary[StringName, Variant] = {
	&"TitleScreen": ["uid://thut0lhwlygl", null],
	&"Results": ["uid://ci2a0jsukmc0h", null],
	&"Tmp1": ["uid://c5jsbbpfbiqle", null],
	&"Tmp2": ["uid://ssbx6iev783i", null],
	&"Tmp3": ["uid://c2qlad01vb5mo", null],
	&"Tmp4": ["uid://cl2p36siuybqv", null],
	&"Tmp5": ["uid://bkybqdym6k55y", null],
	&"Tmp6": ["uid://bmixkotqfjbxo", null],
}

var current_stream: AudioStreamPlayer = null


func _ready() -> void:
	for name_ in songs:
		var arr = songs[name_]
		var uid = arr[0]

		var asp = AudioStreamPlayer.new()
		asp.stream = load(uid) as AudioStreamMP3
		asp.stream.loop = true
		print(asp.stream)
		add_child(asp)
		arr[1] = asp


func play(name_: StringName, volume_db: float = 0.0) -> void:
	stop()
	var stream = songs[name_][1]
	stream.volume_db = volume_db
	stream.stop()
	stream.play()
	current_stream = stream


func stop() -> void:
	if current_stream == null:
		return
	current_stream.stop()
	current_stream = null
