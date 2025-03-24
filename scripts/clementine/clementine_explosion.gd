extends Area2D

# gets set by clem when instanciate
var player: Node

func _ready() -> void:
	$fuseTime.start()

func _on_fuse_time_timeout() -> void:
	if(overlaps_body(player)):
		player.damage(15)
	queue_free()
