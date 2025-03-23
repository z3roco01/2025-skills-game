extends Enemy

var attackPhase = 0 # tracks which phase lance is currently in
var random = RandomNumberGenerator.new()
# phases: 
# 0 - fast dash attacks
# 1 - comb + jab attack
# 2 - poison clouds

var dashAttacking = false

const P1_DASH_DAMAGE = 10
const P1_DASH_AMOUNT = 10 #amount of dashes in first phase

const P2_SCISSOR_SIZE = 150 # scale of daggers
const P2_SCISSOR_SPEED = 4000 # speed of daggers
const P2_SCISSOR_DELAY = 0.5 # time before daggers start going
const P2_SCISSOR_WAVES = 10 # AMT OF SCISSOR WAVES

const TOP_WALL = 0
const BOTTOM_WALL = 1
const LEFT_WALL = 2
const RIGHT_WALL = 3

const ARENA_WIDTH = 1920.0
const ARENA_HEIGHT = 1080.0

const SPRITE_WIDTH = 60.0
const SPRITE_HEIGHT = 120.0

@onready var dashWaitTimer = $dashWaitTimer
@onready var dashCDTimer = $dashCDTimer
@onready var throwWaitTimer = $throwWaitTimer
@onready var dashArrow = $rotators/dashArrow

var scissor_throwable = preload("res://scenes/lance_scissor.tscn")

func idleAction() -> void:
	pass 

func attack() -> void:
	if(attackPhase == 0):
		p1DashAttack()
	elif(attackPhase == 1):
		p2ScissorAttack()
		pass #TODO: IMPLEMENT THE ATTACK

# lance dashes across the screen, if player is hit damage is done!
func p1DashAttack() -> void:
	attackCooldown = 1000000
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
		dashArrow.visible = true # show arrow
		dashWaitTimer.start() # wait until attacking
		await dashWaitTimer.timeout
		dashArrow.visible = false # hide arrow
		# start dashing
		dashAttacking = true
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "position", endPoint, 0.3)
		await tween.finished
		dashAttacking = false
		# wait a little more before starting next dash
		dashCDTimer.start()
		await dashCDTimer.timeout
	attackCooldown = 200
	attackPhase = 1 # next attack phase

func p2ScissorAttack() -> void:
	attackCooldown = 10000
	for n in range(P2_SCISSOR_WAVES):
		if(n % 2 == 0):
			var currentPosition = 0 # track current position of dagger spawn
			var daggerStart = random.randi_range(0, 1)
			if(daggerStart == 1):
				currentPosition += P2_SCISSOR_SIZE # start on every other
			# check if able to spawn scissor
			while(currentPosition <= ARENA_WIDTH):
				# find where to put scissor
				var scissorPos = Vector2(currentPosition -ARENA_WIDTH/2, -ARENA_HEIGHT/2 - P2_SCISSOR_SIZE)
				# spawn scissor
				createScissor(scissorPos, P2_SCISSOR_SPEED, P2_SCISSOR_DELAY, P2_SCISSOR_SIZE, 0.5*PI)
				currentPosition += P2_SCISSOR_SIZE * 2  # move to next spot\
		else:
			var currentPosition = 0 # track current position of dagger spawn
			var daggerStart = random.randi_range(0, 1)
			if(daggerStart == 1):
				currentPosition += P2_SCISSOR_SIZE # start on every other
			# check if able to spawn scissor
			while(currentPosition <= ARENA_HEIGHT):
				# find where to put scissor
				var scissorPos = Vector2(-ARENA_WIDTH/2 - P2_SCISSOR_SIZE, -ARENA_HEIGHT/2 + currentPosition)
				# spawn scissor
				createScissor(scissorPos, P2_SCISSOR_SPEED, P2_SCISSOR_DELAY, P2_SCISSOR_SIZE, 0)
				currentPosition += P2_SCISSOR_SIZE * 2  # move to next spot\
				
		
		throwWaitTimer.start()
		await throwWaitTimer.timeout
	
	attackCooldown = 200

func createScissor(position:Vector2, speed:float, timeUntilStart:float, size:float, rotation:float):
	var scissor = scissor_throwable.instantiate()
	scissor.position = position
	scissor.speed = speed
	scissor.timeUntilStart = timeUntilStart
	scissor.size = size
	scissor.rotation = rotation
	get_parent().add_child(scissor)
	scissor.instantiated() # tell scissor its been instantiated

# helper method that gives a random Vector2 on one of the side walls of arena
func randomiseWallPosition(wall: int) -> Vector2:
	
	# initialise position vector
	var wallPos = Vector2(0,0)
	
	# decide where the attack will start and end
	if(wall == TOP_WALL):
		wallPos.y += (-ARENA_HEIGHT/2 + SPRITE_HEIGHT/2)
		wallPos.x += random.randi_range(-ARENA_WIDTH/2, ARENA_WIDTH/2)
	elif(wall == LEFT_WALL):
		wallPos.x += (-ARENA_WIDTH/2 + SPRITE_WIDTH/2)
		wallPos.y += random.randi_range(-ARENA_HEIGHT/2, ARENA_HEIGHT/2)
	elif(wall == BOTTOM_WALL):
		wallPos.y += ARENA_HEIGHT/2 - SPRITE_HEIGHT/2
		wallPos.x += random.randi_range(-ARENA_WIDTH/2, ARENA_WIDTH/2)
	elif(wall == RIGHT_WALL):
		wallPos.x += ARENA_WIDTH/2 - SPRITE_WIDTH/2
		wallPos.y += random.randi_range(-ARENA_HEIGHT/2, ARENA_HEIGHT/2)
	
	return wallPos


# helper method that returns int of opposite wall
func findOppositeWall(wall: int) -> int:
	if(wall == BOTTOM_WALL || wall == RIGHT_WALL):
		return wall - 1
	elif(wall == TOP_WALL || wall == LEFT_WALL):
		return wall + 1
	else:
		return 0
	


func _on_dash_attack_hit_box_body_entered(body: Node2D) -> void:
	if(dashAttacking && body == player): #check for dash hit
		player.damage(P1_DASH_DAMAGE) # do damage
