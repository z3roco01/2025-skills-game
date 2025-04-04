extends Object

# the id of the music to switch to
# gets switched in _ready()
@export var musicId : String

func _ready() -> void:
	MusicPlayer.playMusic(musicId)
