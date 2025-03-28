extends Node2D

const TIME_BETWEEN_DAMAGE = 0.3 # time between each damage tick
const CLOUD_DAMAGE = 1 # damage to do each time

# set by lance when created
var duration = 0 
var size = 0
static var player

var playerInCloud = false # tracks if player is in cloud
var lifetime = 0 # tracks how long cloud been alive
var playerTimeInCloud = 0 # tracks how long player been in cloud

var random = RandomNumberGenerator.new()

@onready var particles = $GPUParticles2D
@onready var indCircle = $circle
@onready var hairsprayTexture = $texture

const CIRCLE_OPACITY_BASE = 0.15 # opacity to be spawned at
const TEXTURE_OPACITY_BASE = 0.5
const APPEAR_TIME = 0.5
# Called when lance creates the cloud
func instantiated():
	if(player == null):
		get_parent().get_node("./player")
	# set size
	self.scale = Vector2(size, size)
	# set particle size
	particles.process_material.scale_min = 0.02 * size
	particles.process_material.scale_max = 0.04 * size
	
	# set opacities to 0
	indCircle.modulate.a = 0
	hairsprayTexture.modulate.a = 0
	
	# set texture to random rotation
	hairsprayTexture.rotation = random.randi_range(0, 360)

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
	
	# set opacities
	indCircle.modulate.a = findOpacity(CIRCLE_OPACITY_BASE)
	hairsprayTexture.modulate.a = findOpacity(TEXTURE_OPACITY_BASE)
	
func findOpacity(base:float):
	if(lifetime > APPEAR_TIME):
		return base - pow(lifetime/duration, 3) * base
	else:
		return 0 + lifetime/APPEAR_TIME * base

func _on_hitbox_body_entered(body: Node2D) -> void:
	# check if body is player
	if(body == player):
		playerInCloud = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if(body == player):
		playerInCloud = false
		playerTimeInCloud = 0 # reset time in cloud
