extends Enemy

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
# 0 = not earthquaking, 1/2/3 = phase 1/2/3, 4 = done earthquake
var earthquakePhase = 0
# if this earthquake phase should be a wait or not
var earthquakeWait = false
# when set, no attacks will happen
var attackBlocking = false
# if the earthquake dealt damage this phase
var earthquakeDamaged = false

func idleAction() -> void:
	pass 

func attack() -> void:
	if(attackBlocking):
		# if we are earthquaking, then do the damage
		if(earthquakePhase > 0 and earthquakePhase < 4):
			earthquakeDamage()
	else:
		if(distanceToPlayer() >= 400):
			backstab()
			setAttackCooldown(100)
		elif(distanceToPlayer() <= 400):
			if(!shielding):
				shield()
				# set attack cooldown
				setAttackCooldown(100)
			else:
				
				earthquake()
				# block attacks while earthquaking
				attackBlocking = true

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
		player.damage(10)
	backstabTestColour.color.a = 0

# holds all the logic that runs when the shield is enabled
func shield() -> void:
	shielding = true
	#restart sheild timer
	shieldTimer.stop()
	shieldTimer.start()
	shieldColour.visible = true

func damage(health: int) -> void:
	if(!shielding):
		super.damage(health)
	else:
		# reflect 1/2 damage back to player
		player.damage(health/2.0)
		#disableShield()

# when thishows times out and the sheild has not already been broken by the player, break the shield
func _on_shield_timer_timeout() -> void:
	disableShield()

# helper func, runs the logic that runs when the shield is disabled
func disableShield() -> void:
	shielding = false
	shieldColour.visible = false

func earthquake() -> void:
	setEarthquakes(true)
	# make the first earthquake pahse a wait
	earthquakeWait = true
	earthquakeTimer.start()
	earthquakeDamaged = false

func setEarthquakes(visibility: bool) -> void:
	earthquakeOuter.visible = visibility
	earthqakeMiddle.visible = visibility
	earthquakeInner.visible = visibility

# handles switching earthquake zones
func _on_earthquake_timer_timeout() -> void:
	# increment phase
	earthquakePhase += 1
	earthquakeDamaged = false
	if(earthquakeWait):
		# do nothing except stop waiting and start timer again
		earthquakeWait = false
		earthquakeTimer.start()
	elif(earthquakePhase <= 3):
		# start timer again 
		earthquakeTimer.start()
	elif(earthquakePhase == 4):
		attackBlocking = false
		setEarthquakes(false)
		earthquakePhase = 0
		setAttackCooldown(200)

# helper function that checks if the player is in the current earthquake range
# and then does the damage if applicable
func earthquakeDamage() -> void:
	var distToPlayer = distanceToPlayer()
	# damage that will be dealt
	var damageToDeal = 0
	match(earthquakePhase):
		1: # in the inner ring
			if(distToPlayer <= INNER_RADIUS):
				damageToDeal = INNER_DAMAGE
		2: # in the middle ring
			if(distToPlayer > INNER_RADIUS and distToPlayer <= MIDDLE_RADIUS):
				damageToDeal = MIDDLE_DAMAGE
		3: # in the outer ring
			if(distToPlayer > MIDDLE_RADIUS and distToPlayer <= OUTER_RADIUS):
				damageToDeal = OUTER_DAMAGE
	# actually do the damage if they havent already been damaged
	if(!earthquakeDamaged):
		player.damage(damageToDeal)
		earthquakeDamaged = true
