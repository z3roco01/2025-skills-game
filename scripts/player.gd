extends CharacterBody2D

var startHealth = 100
var currentHealth = startHealth

const DEFAULT_SPEED = 700.0
const DASH_SPEED = 3000

var speed = DEFAULT_SPEED
@export var enemy: Node2D

# gets the main node, which contains the players preferences
@onready var mainNode = get_node("../")
# gets the health label from the parent, hardcoded bc has to be
@onready var healthLabel = get_node("../uis/health")
@onready var dashCooldown = $dashCooldown
@onready var rotators = $rotators
@onready var slashAreaColour = $rotators/slashArea/CollisionShape2D/ColorRect
@onready var stabArea = $rotators/stabArea
@onready var stabAreaColour = $rotators/stabArea/CollisionShape2D/ColorRect
@onready var slashTimer = $slashTimer
@onready var slashArea = $rotators/slashArea
@onready var sprite = $playerSprite
@onready var animPlayer = $playerSprite/AnimationPlayer # plays hurt animation
# create a tween
@onready var tween = get_tree().create_tween()

# damage that should be delt to the enemey each physics tick
var enemyDamage = 0
var stabbing = false

#tracks if enemy is going to be hit by slash
#tracks if slash has already hit the enemy
var slashHitEnemy = false 
var slashing = false

func _physics_process(_delta: float) -> void:
	rotators.look_at(get_global_mouse_position())
	var direction := Input.get_vector("left", "right", "up", "back")
	
	if(Input.is_action_pressed("left")):
		sprite.flip_h = false
	elif(Input.is_action_pressed("right")):
		sprite.flip_h = true
	
	# only dash when the dash key has been pressed, the cooldown is done and the player is moving in a direction
	if(Input.is_action_just_pressed("dash") and dashCooldown.is_stopped() and direction != Vector2.ZERO):
		# ensure the speed is at default so tween will work
		speed = DEFAULT_SPEED
		
		# create a new tween since it was just killed
		tween = get_tree().create_tween()
		# start tweening the speed to the final speed
		tween.tween_property(self, "speed", DASH_SPEED, 0.2).set_trans(Tween.TRANS_EXPO)
		tween.tween_callback(dashTweenFinish)
		# start dash cooldown timer
		dashCooldown.start()
	
	# apply the speed based on the inputted direction
	velocity = direction * speed
	
	move_and_slide()
	
	if(Input.is_action_just_pressed("primaryAttack") and !slashing):
		# track slashing
		slashing = true
		# set slashhitenemy to false to track when its been hit
		slashHitEnemy = false
		# set the alpha to full
		slashAreaColour.color.a = 1
		# start slash timer
		slashTimer.start()
	if(Input.is_action_just_pressed("secondaryAttack") and !stabbing):
		stabbing = true
		stabAreaColour.color.a = 1
		var tween2 = get_tree().create_tween()
		tween2.tween_property(stabArea, "scale:x", 1.0, 0.25).set_trans(Tween.TRANS_EXPO)
		tween2.tween_callback(stabTweenFinish)
	
	# if the enemy is inside the slash area and has not already been hit, hit it
	if(slashArea.overlaps_body(enemy) and !slashHitEnemy and slashing):
		enemy.damage(5)
		slashHitEnemy = true

func damage(amount:int):
	# check for death
	if(currentHealth - amount > 0):
		currentHealth -= amount
	else:
		currentHealth = 0
		# TODO death stuff
	
	# update health :)
	healthLabel.text = str(currentHealth)
	animPlayer.stop() # play hurt animation
	animPlayer.play("hurt")

# called once the tween for the dash speed has finished
func dashTweenFinish():
	speed = DEFAULT_SPEED
	tween.kill()

func stabTweenFinish():
	var timer = get_tree().create_timer(0.125)
	await timer.timeout
	var tween2 = get_tree().create_tween()
	tween2.tween_property(stabArea, "scale:x", 0.0, 0.25).set_trans(Tween.TRANS_EXPO)
	tween2.tween_callback(stabTweenFinishFinish)

func stabTweenFinishFinish():
	stabbing = false

func _on_stab_area_body_entered(body: Node2D) -> void:
	if(body == enemy and stabbing):
		enemy.damage(6)

# fired when the slash timer ends
func _on_slash_timer_timeout() -> void:
	# hide the slash area
	slashAreaColour.color.a = 0
	# reset slash tracking vars
	slashing = false
	slashHitEnemy = false
