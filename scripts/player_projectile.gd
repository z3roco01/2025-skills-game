extends Node2D

const PROJECTILE_DAMAGE = 5 # damage of projectile
@onready var indicator = $indicator # indicator of path
@onready var deathTimer = $deathTimer # keeps track of how long to live

# things that are set by lance
var speed
var timeUntilStart
var size 
static var enemy # enemy node

var shouldMove = false # checks if should be currently moving

# Called when the heart is instantiated
func instantiated() -> void:
	scale = Vector2(size, size) # set size
	shouldMove = true # start moving
	indicator.visible = false
	deathTimer.start()

func _on_death_timer_timeout() -> void:
	queue_free() # die

# Called every physics tick
func _physics_process(delta: float) -> void:
	if(shouldMove):
		var direction = Vector2.RIGHT.rotated(rotation) # find rotation
		position += direction * speed * delta # go forward

func _on_area_2d_body_entered(body: Node2D) -> void:
	# check if enemy is hit
	if(body == enemy):
		enemy.damage(PROJECTILE_DAMAGE) # do damage
