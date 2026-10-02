extends Node

var songs: Dictionary[StringName, Variant] = {
	# cada entry aqui tem como valor: [resource_path, stream]
	# stream começa como nulo mas em _ready() a gente seta ele
	&"TitleScreen": ["res://Assets/Sound/mus_title_screen.mp3", null],
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

func play(name_: StringName) -> void:
	stop()
	var stream = songs[name_][1]
	stream.stop()
	stream.play()
	current_stream = stream

func stop() -> void:
	if current_stream == null:
		return
	current_stream.stop()
	current_stream = null
