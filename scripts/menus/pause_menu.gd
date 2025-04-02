extends Control

@onready var player = get_parent().get_node("world/worldPlayer")

func _exit_tree() -> void:
	# need to reset the zoom..
	player.camera.zoom.x = 1.3
	player.camera.zoom.y = 1.3
