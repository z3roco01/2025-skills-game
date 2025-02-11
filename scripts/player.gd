extends CharacterBody2D

const SPEED = 3000.0
# gets the main node, which contains the players preferences
@onready var mainNode = get_node("/root/main")

func _ready() -> void:
	pass
	#print(mainNode)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "back")
	
	velocity = direction * SPEED
	
	move_and_slide()
