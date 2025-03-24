extends Node2D

const TIME_BETWEEN_DAMAGE = 1 # time between each damage tick
const CLOUD_DAMAGE = 2 # damage to do each time

# set by lance when created
var duration = 0 
var size = 0
static var player

var playerInCloud = false # tracks if player is in cloud
var lifetime = 0 # tracks how long cloud been alive
var playerTimeInCloud = 0 # tracks how long player been in cloud
# Called when lance creates the cloud
func instantiated():
	if(player == null):
		get_parent().get_node("./player")
	# set size
	self.scale = Vector2(size, size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# add to lifetime
	lifetime += delta
	# check if should dissapear
	if(lifetime > duration):
		queue_free() # disappear
	
	# check if player is in cloud
	if(playerInCloud == true):
		# add to time in cloud
		playerTimeInCloud += delta
	# check if should do damage
	if(playerTimeInCloud >= TIME_BETWEEN_DAMAGE):
		player.damage(CLOUD_DAMAGE) # do damage
		playerTimeInCloud = 0 # reset counter

func _on_hitbox_body_entered(body: Node2D) -> void:
	# check if body is player
	if(body == player):
		playerInCloud = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if(body == player):
		playerInCloud = false
		playerTimeInCloud = 0 # reset time in cloud
