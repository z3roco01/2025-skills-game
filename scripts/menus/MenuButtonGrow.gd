extends Button

class_name MenuButtonGrow

@export var shouldGrow = true
@onready var defaultScale = scale
const MAX_SCALE = 1.1 # max scale for button
# the current tween, will either be for growing for shrinking
var curTween : Tween 

func _ready() -> void:
	mouse_entered.connect(onMouse)
	mouse_exited.connect(onUnmouse)

# when focus is gained, stop any previous tween and grow
func onMouse() -> void:
	startNewTween(MAX_SCALE)

# when focus is lost, do the same as gain but shrink
func onUnmouse() -> void:
	startNewTween(1)

# stops old tween and start the new one
func startNewTween(scale: float) -> void:
	if(!shouldGrow): return
	
	# only stop if it exists and is running
	if(curTween != null and curTween.is_running()):
		curTween.stop()
	curTween = get_tree().create_tween()
	curTween.tween_property(self, "scale", defaultScale * scale, 0.1)
