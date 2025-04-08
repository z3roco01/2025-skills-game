extends Control

@onready var playButton = $playButton

func _ready() -> void:
	MusicPlayer.playMusic("title")
	playButton.button_up.connect(die)

func die() -> void:
	queue_free()
