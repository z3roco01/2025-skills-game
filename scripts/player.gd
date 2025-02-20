extends CharacterBody2D

var startHealth = 100
var currentHealth

const DEFAULT_SPEED = 700.0
const DASH_SPEED = 2000

var speed = DEFAULT_SPEED
var dashOnCD = false

# gets the main node, which contains the players preferences
@onready var mainNode = get_node("/root/main")
@onready var healthLabel = get_node("/root/main/testworld/health")
@onready var dashTimer = $dashTimer
@onready var dashCooldown = $dashCooldown

func _ready() -> void:
	# set current health to the starting health
	currentHealth = startHealth
	

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "back")
	
	velocity = direction * speed
	
	# check for dash input and able to use
	if(Input.is_action_just_pressed("dash") and dashCooldown.is_stopped()):
		
		# start dash
		speed = DASH_SPEED
		dashTimer.start()
		
		# start dash cooldown
		dashCooldown.start()
	
	
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
	
	pass #ts pmo


func _on_dash_timer_timeout() -> void:
	# go back to normal speed
	speed = DEFAULT_SPEED
