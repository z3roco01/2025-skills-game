extends "enemy.gd"

@onready var shieldTimer = $shieldTimer
@onready var backstabTimer = $backstabTimer
@onready var backstabArea = $rotators/backstabArea
@onready var backstabTestColour = $rotators/backstabArea/CollisionShape2D/ColorRect
@onready var shieldColour = $shieldColour
@onready var earthquakeTimer = $earthquakeTimer
@onready var earthquakeInner = $earthquakeInner
@onready var earthqakeMiddle = $earthquakeMiddle
@onready var earthquakeOuter = $earthquakeOuter
# BETTER NAMES
const INNER_RADIUS = 300
const MIDDLE_RADIUS = 600
const OUTER_RADIUS = 1000
const INNER_DAMAGE = 20
const MIDDLE_DAMAGE = 15
const OUTER_DAMAGE = 5

# keep track if were using the shield
var shielding = false
var tookSheildDamage = false
var playerEarthquakeDamage = false

func idleAction() -> void:
	pass 

func attack() -> void:
	if(distanceToPlayer() >= 400):
		backstab()
		attackCooldown = 100
	elif(distanceToPlayer() <= 400):
		if(!shielding):
			shield()
			# set attack cooldown
			attackCooldown = 100
		else:
			earthquake()
			attackCooldown = 150

# an attack that will trigger once chosen
# will teleport behind player then stab them
func backstab() -> void:
	# get rotation the player is attacking in
	var playerAttackRotation = player.rotators.transform.get_rotation()
	# get a vector for the direction the player is attacking in
	var playerFacingVec = Vector2.RIGHT.rotated(playerAttackRotation)
	# move carmile back in the direction opposite the player is attacking in
	position = player.position - (playerFacingVec * 140)
	# make attacks look at player
	rotators.look_at(player.position)
	# show attack area
	backstabTestColour.color.a = 0.25
	
	# start timer to count towards attack
	backstabTimer.start()
	await backstabTimer.timeout
	# actually do attack 
	backstabTestColour.color.a = 0.75
	if(backstabArea.overlaps_body(player)):
		player.decrementHealth(10)

# holds all the logic that runs when the shield is enabled
func shield() -> void:
	shielding = true
	#restart sheild timer
	shieldTimer.stop()
	shieldTimer.start()
	shieldColour.visible = true

func decrementHealth(health: int) -> void:
	if(!shielding):
		super.decrementHealth(health)
	else:
		# reflect 1/2 damage back to player
		player.decrementHealth(health/2)
		disableShield()

# when this times out and the sheild has not already been broken by the player, break the shield
func _on_shield_timer_timeout() -> void:
	disableShield()

# helper func, runs the logic that runs when the shield is disabled
func disableShield() -> void:
	shielding = false
	shieldColour.visible = false

func earthquake() -> void:
	print("EARTH")
	setEarthquakes(true)
	
	playerEarthquakeDamage = false
	earthquakeTimer.start()
	# do first check of inner circle
	while(!earthquakeTimer.is_stopped() and !playerEarthquakeDamage):
		if(distanceToPlayer() <= INNER_RADIUS and !playerEarthquakeDamage):
			player.decrementHealth(INNER_DAMAGE)
			playerEarthquakeDamage = true
	# then check middle
	playerEarthquakeDamage = false
	earthquakeTimer.start()
	while(!earthquakeTimer.is_stopped()):
		if(distanceToPlayer() > INNER_RADIUS and distanceToPlayer() <= MIDDLE_RADIUS and !playerEarthquakeDamage):
			player.decrementHealth(MIDDLE_DAMAGE)
			playerEarthquakeDamage = true
	# then check outer
	playerEarthquakeDamage = false
	earthquakeTimer.star()
	while(!earthquakeTimer.is_stopped()):
		if(distanceToPlayer() > MIDDLE_RADIUS and distanceToPlayer() <= OUTER_RADIUS and !playerEarthquakeDamage):
			player.decrementHealth(OUTER_DAMAGE)
			playerEarthquakeDamage = true
	
	setEarthquakes(false)

func setEarthquakes(visibility: bool) -> void:
	earthquakeOuter.visible = visibility
	earthqakeMiddle.visible = visibility
	earthquakeInner.visible = visibility
