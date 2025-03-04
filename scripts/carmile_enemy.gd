extends "enemy.gd"

@onready var backstabTimer = $backstabTimer
@onready var backstabArea = $rotators/backstabArea
@onready var backstabTestColour = $rotators/backstabArea/CollisionShape2D/ColorRect

func idleAction() -> void:
	pass 

func attack() -> void:
	backstab()
	attackCooldown = 100

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
