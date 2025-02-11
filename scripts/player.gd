extends CharacterBody2D

const SPEED = 3000.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "back")
	
	velocity = direction * SPEED
	
	move_and_slide()
