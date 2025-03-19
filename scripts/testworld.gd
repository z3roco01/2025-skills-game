extends Node2D

@onready var carmile = $lanceEnemy
@onready var waittimer = $waittimer

func _ready() -> void:
	carmile.connect("death", onCarmileDeath)

func onCarmileDeath() -> void:
	waittimer.start()
	print("asd1")
	await waittimer.timeout
	print("asd2")
	queue_free()
