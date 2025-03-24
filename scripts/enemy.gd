@icon("res://485b60d7-628c-4763-8717-b0b0f7a0f7f5")
extends RigidBody2D

class_name Enemy

const startHealth = 100
var currentHealth = startHealth
var attackCooldown = 0
@export var cooldownMult = 1

@export var SPEED = 4
var vel = Vector2.ZERO
# get the player from the parent
@onready var player = get_parent().get_node("./player")
@onready var healthText = get_parent().get_node("./enemyHealth")

signal death()

# Called every physics tick
func _physics_process(_delta: float) -> void:
	if(alive()):
		# if we can attack then run attack selection logic
		if(attackCooldown <= 0):
			attack()
		else: # if it is not attacking, run any idle actions
			idleAction()
			attackCooldown -= 1

# function that decides what attack to do then does it
# to be implemented by specific enemies
func attack() -> void:
	pass

# function that does actions when not attacking 
func idleAction() -> void:
	move_and_collide(position.direction_to(player.position))

func alive() -> bool:
	return currentHealth > 0

func damage(amount: int):
	# check for death
	if(currentHealth - amount > 0):
		currentHealth -= amount
	else:
		currentHealth = 0
	
	if(currentHealth <= 0):
		onDie()
	healthText.text = str(currentHealth)
	# update health :)
	# TODO make health label

func onDie() -> void:
	emit_signal("death")

# a helper function, used by enemies that inherit this
func distanceToPlayer() -> float:
	return position.distance_to(player.position)

func setAttackCooldown(cooldown: int) -> void:
	attackCooldown = cooldown * cooldownMult

# creates a Vector2 pointing to the player from the enemy with a supplide length
func inPlayerDir(length: float) -> Vector2:
	var rot = get_angle_to(player.position)
	return Vector2.RIGHT.rotated(rot) * length
