extends Button

class_name MenuButtonGrow

var MIN_SCALE = scale.x
const MAX_SCALE = 1.1 # max scale for button
const SCALE_SPEED = 5.0 # how fast to scale at
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(is_hovered() && self.scale.x < MAX_SCALE): # check if hovered on
		# grow
		var newScale = scale.x + delta * SCALE_SPEED
		scale.x = newScale
		scale.y = newScale
	elif(!is_hovered() && self.scale.y > MIN_SCALE):
		# shrink
		var newScale = scale.x - delta * SCALE_SPEED
		scale.x = newScale
		scale.y = newScale
