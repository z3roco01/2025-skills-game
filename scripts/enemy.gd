extends RigidBody2D

@export var SPEED = 4
var vel = Vector2.ZERO
# get the player from the parent
@onready var player = get_parent().get_node("./player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var collision = move_and_collide(position.direction_to(player.position) * SPEED)
	
	if(collision and collision.get_collider() == player):
		player.decrementHealth(1)
