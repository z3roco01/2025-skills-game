extends AudioStreamPlayer

#holds all of tracks as value and an id as key
@export var musicBank : Dictionary

func playMusic(id: String):
	if(id in musicBank):
		stream = musicBank[id]
		play()
