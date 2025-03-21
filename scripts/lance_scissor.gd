extends Node2D

@onready var player # player
@onready var indicator = $indicator # indicator of path
@onready var startTimer = $startTimer # keeps track until when it moves
@onready var deathTimer = $deathTimer # keeps track of how long to live

var speed = 1.0
var timeUntilStart = 1.0
var size = 1.0

var shouldMove = false
var currentLifetime = 0.0

# Called when the dagger is instantiated
func instantiated() -> void:
	player = get_parent().player
	scale = Vector2(size, size) # set size
	startTimer.wait_time = timeUntilStart
	# start timer
	startTimer.start()

# Called when startTimer is done
func _on_start_timer_timeout() -> void:
	shouldMove = true # start moving
	indicator.visible = false
	deathTimer.start()

func _on_death_timer_timeout() -> void:
	queue_free() # die

# Called every physics tick
func _physics_process(delta: float) -> void:
	if(shouldMove):
		var direction = Vector2.RIGHT.rotated(rotation) # find rotation
		position += direction * speed * delta # go forward

func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body == player):
		player.damage(5)
