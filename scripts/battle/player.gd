extends CharacterBody2D

signal death()

var startHealth = 100
var currentHealth = startHealth

const DEFAULT_SPEED = 700.0
const DASH_SPEED = 3000
const HIT_COLOUR = Color.RED # color to turn into when hit
const STAB_LENGTH = 400 # how far stab reaches in pixels
var speed = DEFAULT_SPEED
@export var enemy: Node2D

# gets the main node, which contains the players preferences
@onready var mainNode = get_node("../")
# gets the health label from the parent, hardcoded bc has to be
@onready var healthLabel = get_node("../uis/health")
@onready var dashCooldown = $dashCooldown
@onready var rotators = $rotators
@onready var slashAnim = $rotators/slashAnim
@onready var stabArea = $rotators/stabArea
@onready var stabSword = $rotators/stabSword
@onready var slashTimer = $slashTimer
@onready var slashArea = $rotators/slashArea
@onready var sprite = $playerSprite
@onready var sfxPlayer = $sfxPlayer
# create a tween
@onready var tween = get_tree().create_tween()
@onready var arena = get_parent()

# damage that should be delt to the enemey each physics tick
var enemyDamage = 0
var stabbing = false

#tracks if enemy is going to be hit by slash
#tracks if slash has already hit the enemy
var slashHitEnemy = false 
var slashing = false

var paused = false

@onready var swordSlashSound = preload("res://sfx/battle/mc_sword_slash.mp3")
@onready var dashSound = preload("res://sfx/battle/mc_dash.mp3")
@onready var hurtSound = preload("res://sfx/battle/mc_hurt.mp3")
@onready var stabSound = preload("res://sfx/battle/mc_stab.mp3")

func _ready() -> void:
	arena.pause.connect(pause)
	arena.unpause.connect(unpause)
	sprite.material.set_shader_parameter("enabled", false)

func pause() -> void:
	paused = true

func unpause() -> void:
	paused = false

func _physics_process(_delta: float) -> void:
	if(paused): return
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
		sprite.play("dash") # play dash animation
		sprite.material.set_shader_parameter("enabled", true)
		# create a new tween since it was just killed
		tween = get_tree().create_tween()
		# start tweening the speed to the final speed
		tween.tween_property(self, "speed", DASH_SPEED, 0.2).set_trans(Tween.TRANS_EXPO)
		tween.tween_callback(dashTweenFinish)
		# start dash cooldown timer
		dashCooldown.start()
		# play dash sound
		sfxPlayer.stream = dashSound
		sfxPlayer.play()
	elif(direction != Vector2.ZERO && sprite.animation != "dash"):
		sprite.material.set_shader_parameter("enabled", true)
		sprite.play("walk")
	elif(sprite.animation != "dash"):
		sprite.material.set_shader_parameter("enabled", false)
		sprite.play("neutral")
		
	
	# apply the speed based on the inputted direction
	velocity = direction * speed
	
	move_and_slide()
	
	if(Input.is_action_just_pressed("primaryAttack") and !slashing):
		# track slashing
		slashing = true
		# set slashhitenemy to false to track when its been hit
		slashHitEnemy = false
		# start slash timer
		slashTimer.start()
		# play slash sound
		sfxPlayer.stream = swordSlashSound
		sfxPlayer.play()
		# show sword and play animation
		slashAnim.visible = true
		slashAnim.play("slash")
	if(Input.is_action_just_pressed("secondaryAttack") and !stabbing):
		stabbing = true
		stabSword.visible = true
		var tween2 = get_tree().create_tween()
		tween2.tween_property(stabArea, "scale:x", 1.0, 0.25).set_trans(Tween.TRANS_EXPO)
		tween2.tween_callback(stabTweenFinish)
		var tween3 = create_tween()
		tween3.tween_property(stabSword, "position:x", STAB_LENGTH + 100, 0.25).set_trans(Tween.TRANS_EXPO)
		tween3.tween_property(stabSword, 'position:x', 100, 0.25).set_trans(Tween.TRANS_EXPO)
		# play stab sound
		sfxPlayer.stream = dashSound
		sfxPlayer.play()
	
	# if the enemy is inside the slash area and has not already been hit, hit it
	if(slashArea.overlaps_body(enemy) and !slashHitEnemy and slashing):
		enemy.damage(5)
		slashHitEnemy = true

func damage(amount:int):
	# check for death
	if(currentHealth - amount > 0):
		currentHealth -= amount
		hitAnimation()
		# play hurt sound
		sfxPlayer.stream = hurtSound
		sfxPlayer.play()
	else:
		currentHealth = 0
		death.emit()
	
	# update health :)
	healthLabel.text = str(currentHealth)

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
	stabSword.visible = false

func _on_stab_area_body_entered(body: Node2D) -> void:
	if(body == enemy and stabbing):
		enemy.damage(4)

# fired when the slash timer ends
func _on_slash_timer_timeout() -> void:
	# hide the sword
	slashAnim.visible = false
	# reset slash tracking vars
	slashing = false
	slashHitEnemy = false


func hitAnimation():
	var colorTweener = create_tween()
	 # tweens the color of lance
	colorTweener.tween_method(
		set_color_hitAnimation,
		1.0,
		0.0,
		0.2
	)

# helper method for colorFade
func set_color_hitAnimation(value: float):
	sprite.material.set_shader_parameter(
		"colour", 
		lerp(Color.WHITE, HIT_COLOUR, value)
	)

# go back to neutral once sprite animation is done
func _on_player_sprite_animation_finished() -> void:
	sprite.play("neutral")
	sprite.material.set_shader_parameter("enabled", false)
