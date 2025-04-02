extends Button

# since the root of the scene may not be the parent
@export var root : Node

func _pressed() -> void:
	root.queue_free()
