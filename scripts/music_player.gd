extends AudioStreamPlayer

#holds all of tracks as value and an id as key
@export var musicBank : Dictionary
# keep track of the playing track, since looping doesnt exist for some reason
var curMusic = ""

func _ready() -> void:
	finished.connect(on_finished)

func playMusic(id: String):
	if(id == curMusic and playing): return
	
	if(id in musicBank):
		curMusic = id
		stream = musicBank[id]
		play()

func on_finished() -> void:
	playMusic(curMusic)

func stopMusic() -> void:
	curMusic = ""
	stop()
