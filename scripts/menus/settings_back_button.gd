extends Button
# only dif is that is saves config at the end

# since the root of the scene may not be the parent
@export var root : Node

func _pressed() -> void:
	root.queue_free()
	Settings.saveToConfig(Prefs._prefs, Prefs._PREFS_PATH)
