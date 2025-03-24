extends Node2D

const SCISSOR_DAMAGE = 5 # damage of scissor
@onready var indicator = $indicator # indicator of path
@onready var startTimer = $startTimer # keeps track until when it moves
@onready var deathTimer = $deathTimer # keeps track of how long to live

# things that are set by lance
var speed
var timeUntilStart
var size 
static var lanceEnemy # lance node
static var player # player node

var shouldMove = false # checks if should be currently moving

# Called when the dagger is instantiated
func instantiated() -> void:
	# look for player if null
	if(player == null):
		player = get_parent().get_node("./player")
	# look for lance if null
	if(lanceEnemy == null):
		lanceEnemy = get_parent().get_node("./lanceEnemy")
	scale = Vector2(size, size) # set size
	startTimer.wait_time = timeUntilStart
	# start timer
	startTimer.start()

# Called when startTimer is done
func _on_start_timer_timeout() -> void:
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
	# check if player is hit
	if(body == player):
		player.damage(5) # do damage
		lanceEnemy.scissorHit() # signal to lance that it hit
