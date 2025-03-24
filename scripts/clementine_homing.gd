extends RigidBody2D

# gets passed by clementine on instantiation
@export var player: CharacterBody2D
# how much the rotation should be scaled down, so homing isnt 100% accurate
@export var rotationScale = 0.02
@export var speed = 5
# the amount of time to wait before starting 
@onready var waitTime = $waitTime
# the amount of time to rotate for 
@onready var rotateTime = $rotateTime

var moving = false
var rotating = true

func _process(delta: float) -> void:
	if(moving):
		if(rotating):
			# rotate a bit more towards player
			rotate(get_angle_to(player.position) * rotationScale)
		# move forward
		var collision = move_and_collide(Vector2.RIGHT.rotated(rotation) * speed)
		
		# on collision always destroy, and damage player if needed
		if(collision != null):
			if(collision.get_collider() == player):
				player.damage(8)
			self.free()
			

# when this timer ends it will no longer rotate
func _on_rotate_time_timeout() -> void:
	rotating = false

# start movement and roate timer
func _on_wait_time_timeout() -> void:
	rotateTime.start()
	moving = true
