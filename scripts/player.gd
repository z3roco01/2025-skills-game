extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "back")
	
	velocity = direction * SPEED
	
	move_and_slide()
