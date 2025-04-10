extends Enemy

var attackPhase = 0 # tracks which phase lance is currently in
var random = RandomNumberGenerator.new()
# phases: 
# 0 - fast dash attacks
# 1 - comb + jab attack
# 2 - poison clouds

var dashAttacking = false
var dazed = false # tracks if dazed (able to be attacked)

const P1_DASH_DAMAGE = 10
const P1_DASH_AMOUNT = 10 #amount of dashes in first phase

const P2_SCISSOR_SIZE = 200 # scale of daggers
const P2_SCISSOR_SPEED = 4000 # speed of daggers
const P2_SCISSOR_DELAY = 0.5 # time before daggers start going
const P2_SCISSOR_WAVES = 10 # AMT OF SCISSOR WAVES

const P3_CLOUD_DURATION = 5 # how long clouds last
const P3_CLOUD_SIZE = 25 # size of clouds
const P3_CLOUD_AMT = 10 # amount of clouds
const P3_TIME_BETWEEN_CLOUD = 3 # time until lance relocates and spawns cloud
const P3_TARGET_PLAYER_CHANCE = 0.4 # chance to teleport to player instead (out of 1)

const TOP_WALL = 0
const BOTTOM_WALL = 1
const LEFT_WALL = 2
const RIGHT_WALL = 3

const ARENA_WIDTH = 1920
const ARENA_HEIGHT = 920

const SPRITE_WIDTH = 80
const SPRITE_HEIGHT = 158

@onready var dashWaitTimer = $dashWaitTimer
@onready var dashCDTimer = $dashCDTimer
@onready var throwWaitTimer = $throwWaitTimer
@onready var stabTimer = $stabTimer
@onready var cloudWaitTimer = $cloudWaitTimer
@onready var dashArrow = $rotators/dashArrow
@onready var dashArrowAnim = $rotators/dashArrow/AnimationPlayer
@onready var dashParticles = $dashParticles
@onready var stabHitbox = $rotators/stabAttackHitbox
@onready var sprite = $lanceSprite
@onready var scissorAnim = $rotators/scissorSlash
@onready var sfxPlayer = $sfxPlayer
@onready var collider = $CollisionShape2D

var scissor_throwable = preload("res://scenes/lance/lance_scissor.tscn")
var poison_cloud = preload("res://scenes/lance/lance_poison_cloud.tscn")

# colors to turn into when hit
const SHIELDED_HIT_COLOUR = Color.ROYAL_BLUE
const HIT_COLOUR = Color.RED

# sound effects
@onready var shieldSound = preload("res://sfx/battle/lance_shield.mp3")
@onready var hurtSound = preload("res://sfx/battle/lance_hurt.mp3")
@onready var dashSound = preload("res://sfx/battle/lance_dash.mp3")
@onready var scissorSound = preload("res://sfx/battle/lance_scissor.mp3")
@onready var spraySound = preload("res://sfx/battle/lance_spray.mp3")

var min_x
var max_x
var min_y
var max_y

const START_ATTACK_CD = 50 # small attack cd

func _ready() -> void:
	# calculate where enemy can be
	min_x = SPRITE_WIDTH / 2
	max_x = ARENA_WIDTH - SPRITE_WIDTH / 2
	min_y = SPRITE_HEIGHT / 2
	max_y = ARENA_HEIGHT - SPRITE_HEIGHT / 2
	attackCooldown = START_ATTACK_CD
	sprite.material.set_shader_parameter("enabled", false)
	super._ready()

func idleAction() -> void:
	pass 

func attack() -> void:
	if(attackPhase == 0):
		p1DashAttack()
	elif(attackPhase == 1):
		p2ScissorAttack()
	elif(attackPhase == 2):
		p3PoisonAttack()

# lance dashes across the screen, if player is hit damage is done!
func p1DashAttack() -> void:
	attackStarted()
	for n in range(P1_DASH_AMOUNT):
		# pick a wall to start at
		var startWall = random.randi_range(0, 3)
		var endWall = findOppositeWall(startWall)
		# find pos to start at
		var startPoint = randomiseWallPosition(startWall)
		# find pos to end at
		var endPoint = randomiseWallPosition(endWall)
		
		position = startPoint # move to start point
		rotators.look_at(endPoint)
		sprite.rotation = 0
		sprite.look_at(endPoint)
		# check if needed to invert based on pos
		if(position.x < ARENA_WIDTH/2):
			sprite.flip_h = true
			sprite.flip_v = false
		else:
			sprite.flip_h = true
			sprite.flip_v = true
			
		dashParticles.emitting = true # start particle emission
		
		sprite.play("p1DashStartup")
		sprite.material.set_shader_parameter("enabled", true)
		
		dashArrowAnim.play("RESET")
		dashArrow.visible = true # show arrow
		dashWaitTimer.start() # wait until attacking
		
		await dashWaitTimer.timeout
		
		dashArrowAnim.play("start",-1,1/0.3 * 2) #play disappear animation
		sprite.play("p1DashLoop")
		sprite.material.set_shader_parameter("enabled", true)
		# start dashing
		dashAttacking = true
		# play dash sound
		sfxPlayer.stream = dashSound
		sfxPlayer.play()
		
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "position", endPoint, 0.3)
		await tween.finished
		
		dashParticles.emitting = false # stop particle emission
		dashAttacking = false
		# wait a little more before starting next dash
		dashCDTimer.start()
		await dashCDTimer.timeout
		resetSprite()
	attackFinished()

func p2ScissorAttack() -> void:
	attackStarted()
	var currentPosition
	for n in range(P2_SCISSOR_WAVES):
			currentPosition = 0 # track current position of dagger spawn
			var scissorStart = random.randi_range(0, 1)
			var scissorWall  # wall to start at
			if(scissorStart == 1):
				currentPosition += P2_SCISSOR_SIZE # start on every other
			# randomise daggerWall
			if(n % 2 == 0):
				# even num = top or bott
				scissorWall = random.randi_range(0,1)
			else:
				# odd num = left or right
				scissorWall = random.randi_range(2,3)
			
			var scissorMax # tracks how far scissors can spawn
			var scissorRot # the rotation of the scissors
			# determin scissorMax and scissorRot based on wall start
			if(scissorWall == TOP_WALL):
				scissorMax = ARENA_WIDTH
				scissorRot = 0.5 * PI
			elif(scissorWall == BOTTOM_WALL):
				scissorMax = ARENA_WIDTH
				scissorRot = 1.5 * PI
			elif(scissorWall == LEFT_WALL):
				scissorMax = ARENA_HEIGHT
				scissorRot = 0
			elif(scissorWall == RIGHT_WALL):
				scissorMax = ARENA_HEIGHT
				scissorRot = PI
			
			# check if able to spawn scissor
			while(currentPosition <= scissorMax):
				# find where to put scissor based on start wall
				var scissorPos
				if(scissorWall == TOP_WALL):
					# top left
					scissorPos = Vector2(
						currentPosition, 
						- P2_SCISSOR_SIZE)
				elif(scissorWall == LEFT_WALL):
					# top left
					scissorPos = Vector2(
						- P2_SCISSOR_SIZE, 
						currentPosition
						)
				elif(scissorWall == BOTTOM_WALL):
					# bottom left
					scissorPos = Vector2(
						currentPosition, 
						ARENA_HEIGHT + P2_SCISSOR_SIZE
						)
				elif(scissorWall == RIGHT_WALL):
					# top right
					scissorPos = Vector2(
						ARENA_WIDTH + P2_SCISSOR_SIZE, 
						currentPosition
						)
				
				# spawn scissor
				createScissor(scissorPos, P2_SCISSOR_SPEED, P2_SCISSOR_DELAY, P2_SCISSOR_SIZE, scissorRot)
				currentPosition += P2_SCISSOR_SIZE * 2  # move to next spot
			# play scissor sound
			sfxPlayer.stream = scissorSound
			sfxPlayer.play()
			
			throwWaitTimer.start()
			await throwWaitTimer.timeout
	attackFinished()

func p3PoisonAttack() -> void:
	attackStarted()
	for n in range(P3_CLOUD_AMT):
		# delay before spawning
		cloudWaitTimer.start()
		await cloudWaitTimer.timeout
		var targetPos # where lance will go
		# roll if lance will target player
		if(randi_range(0, 1) > P3_TARGET_PLAYER_CHANCE):
			targetPos = player.position #target player
		else:
			# randomise a spot in the arena if not
			targetPos = Vector2(
				random.randf_range(
					min_x,
					max_x
				),
				random.randf_range(
					min_y,
					max_y
				)
			)
		# move lance to spot with a tween
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO)
		# dash animation
		sprite.play("p1DashStartup", 4.0)
		sprite.material.set_shader_parameter("enabled", true)
		tween.tween_property(self, "position", targetPos, 0.2)
		
		if(targetPos.x > position.x):
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
		await tween.finished # wait for lance to finish moving
		
		sprite.play("neutral") # neutral stance
		sprite.material.set_shader_parameter("enabled", false)
		# make cloud
		createPoisonCloud(targetPos, P3_CLOUD_DURATION, P3_CLOUD_SIZE)
		# play spray sound
		sfxPlayer.stream = spraySound
		sfxPlayer.play()
	attackFinished()
	

func createScissor(position:Vector2, speed:float, timeUntilStart:float, size:float, rotation:float):
	var scissor = scissor_throwable.instantiate()
	# set pos, speed, delay, size, rot, of daggers
	scissor.position = position
	scissor.speed = speed
	scissor.timeUntilStart = timeUntilStart
	scissor.size = size
	scissor.rotation = rotation
	scissor.player = player
	scissor.lanceEnemy = self
	
	get_parent().add_child(scissor)
	scissor.instantiated() # tell scissor its been instantiated]

# creates a poison cloud
func createPoisonCloud(position:Vector2, duration:float, size:float):
	var cloud = poison_cloud.instantiate() # make cloud
	cloud.size = size
	cloud.position = position # set position
	cloud.duration = duration # set duration
	cloud.player = player # set player track var
	
	get_parent().add_child(cloud) # add to main scene
	cloud.instantiated() # tell cloud its been instantiated]

# triggered by scissor when it hits players
func scissorHit():
	# get rotation the player is attacking in
	var playerAttackRotation = player.rotators.transform.get_rotation()
	# get a vector for the direction the player is attacking in
	var playerFacingVec = Vector2.RIGHT.rotated(playerAttackRotation)
	# calculate a position to be going to
	var positionTarget = player.position + (playerFacingVec * 140)
	# start tween of going towards player
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO)
	
	tween.tween_property(self, "position", positionTarget, 0.2)
	
	sprite.play("p1DashStartup")
	sprite.material.set_shader_parameter("enabled", true)
	
	if(positionTarget.x > position.x):
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		
	await tween.finished # wait for lance to finish moving
	
	sprite.play("neutral") # neutral stance
	sprite.material.set_shader_parameter("enabled", false)
	
	rotators.look_at(player.position) # point stab towards player
	# show stab 
	# start timer to count towards attack
	stabTimer.start()
	scissorAnim.visible = true
	scissorAnim.play("default")
	
	await stabTimer.timeout
	# actually do attack
	scissorAnim.visible = false
	if(stabHitbox.overlaps_body(player)):
		player.damage(10)
	# hide hitbox

# helper method that gives a random Vector2 on one of the side walls of arena
func randomiseWallPosition(wall: int) -> Vector2:
	# initialise position vector
	var wallPos = Vector2(0,0)
	
	# decide where the attack will start and end
	if(wall == TOP_WALL):
		wallPos.y += min_y
		wallPos.x += random.randi_range(min_x, max_x)
	elif(wall == LEFT_WALL):
		wallPos.x += min_x
		wallPos.y += random.randi_range(min_y, max_y)
	elif(wall == BOTTOM_WALL):
		wallPos.y += max_y
		wallPos.x += random.randi_range(min_x, max_x)
	elif(wall == RIGHT_WALL):
		wallPos.x += max_x
		wallPos.y += random.randi_range(min_y, max_y)
	
	return wallPos


# helper method that returns int of opposite wall
func findOppositeWall(wall: int) -> int:
	if(wall == BOTTOM_WALL || wall == RIGHT_WALL):
		return wall - 1
	elif(wall == TOP_WALL || wall == LEFT_WALL):
		return wall + 1
	else:
		return 0
	

func damage(health: int) -> void:
	# only do damage if dazed (not attacking)
	if(dazed):
		super.damage(health)
		hitAnimation() # play hit animation
		# play hurt sound
		sfxPlayer.stream = hurtSound
		sfxPlayer.play()
	else:
		shieldedHitAnimation() # show lance cannot be hit
		# play shielded sound
		sfxPlayer.stream = shieldSound
		sfxPlayer.play()

func _on_dash_attack_hit_box_body_entered(body: Node2D) -> void:
	if(dashAttacking && body == player): #check for dash hit
		player.damage(P1_DASH_DAMAGE) # do damage

# things to do when an attack is starting
func attackStarted() -> void:
	attackBlocking = true
	dazed = false # no daze
	# un collidable
	add_collision_exception_with(player)
	resetSprite()

# things to do when an attack is done
func attackFinished() -> void:
	attackBlocking = false
	attackCooldown = 200 # wait until next attack
	dazed = true # become dazed
	# next phase, go next phase or loop around
	if(attackPhase == 2):
		attackPhase = 0
	else:
		attackPhase += 1
	# collidable
	remove_collision_exception_with(player)
	resetSprite() # make sure sprite is reset before dazed animation
	
	sprite.play("dazed") # dazed animation
	sprite.material.set_shader_parameter("enabled", true)

# sprite will go back to default
func resetSprite() -> void:
	sprite.play("neutral") # reset sprite anim
	sprite.material.set_shader_parameter("enabled", false)
	sprite.rotation = 0 # reset sprite rotation
	sprite.flip_h = false # reset sprite flips
	sprite.flip_v = false
	collider.rotation = 0 # reset collider rotation

func hitAnimation() -> void:
	colorFade(set_color_hitAnimation)

func shieldedHitAnimation() -> void:
	colorFade(set_color_shieldedHitAnimation)

func colorFade(method:Callable):
	var colorTweener = create_tween()
	 # tweens the color of lance
	colorTweener.tween_method(method, 1.0, 0.0, 0.2)

# helper method for colorFade
func set_color_hitAnimation(value: float):
	sprite.material.set_shader_parameter("colour", lerp(Color.WHITE, HIT_COLOUR, value))

# another helper method for a shielded hit
func set_color_shieldedHitAnimation(value: float):
	sprite.material.set_shader_parameter("colour", lerp(Color.WHITE, SHIELDED_HIT_COLOUR, value))
