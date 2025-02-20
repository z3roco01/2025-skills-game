extends CharacterBody2D

var startHealth = 100
var currentHealth

const DEFAULT_SPEED = 700.0
const DASH_SPEED = 3000

var speed = DEFAULT_SPEED

# gets the main node, which contains the players preferences
@onready var mainNode = get_node("/root/main")
# gets the health label from the parent, hardcoded bc has to be
@onready var healthLabel = get_node("/root/main/testworld/health")
@onready var dashCooldown = $dashCooldown
# create a tween
@onready var tween = get_tree().create_tween()

func _ready() -> void:
	# set current health to the starting health
	currentHealth = startHealth

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "back")
	
	# only dash when the dash key has been pressed, the cooldown is done and the player is moving in a direction
	if(Input.is_action_just_pressed("dash") and dashCooldown.is_stopped() and direction != Vector2.ZERO):
		# ensure the speed is at default so tween will work
		speed = DEFAULT_SPEED
		
		# kill the old tween then start a new one 
		tween.kill()
		tween = get_tree().create_tween()
		# start tweening the speed to the final speed
		tween.tween_property(self, "speed", DASH_SPEED, 0.2).set_trans(Tween.TRANS_EXPO)
		tween.tween_callback(dashTweenFinish)
		# start dash cooldown timer
		dashCooldown.start()
	
	# apply the speed based on the inputted direction
	velocity = direction * speed
	
	move_and_slide()

func decrementHealth(amount:int):
	# check for death
	if(currentHealth - amount > 0):
		currentHealth -= amount
	else:
		currentHealth = 0
		# TODO death stuff
	
	# update health :)
	healthLabel.text = str(currentHealth)
	#ts pmo

func _on_dash_timer_timeout() -> void:
	# go back to normal speed
	speed = DEFAULT_SPEED

# called once the tween for the dash speed has finished
func dashTweenFinish():
	speed = DEFAULT_SPEED
