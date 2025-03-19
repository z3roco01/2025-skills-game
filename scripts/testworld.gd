extends Node2D

@onready var clementine = $clementineEnemy
@onready var waittimer = $waittimer

func _ready() -> void:
	clementine.connect("death", onEnemyDeath)

func onEnemyDeath() -> void:
	waittimer.start()
	print("asd1")
	await waittimer.timeout
	print("asd2")
	queue_free()
