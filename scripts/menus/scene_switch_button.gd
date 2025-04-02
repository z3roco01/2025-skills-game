extends Button

# the scene to be switched to
@export var scene : PackedScene

func _pressed() -> void:
	var instance = scene.instantiate()
	get_parent().get_parent().add_child(instance)
