extends CharacterBody2D

@export var speed = 300.0
@onready var sprite = $playerSprite
# the area used to detect when we are at a door
@onready var doorArea = $doorArea
@onready var camera = $Camera2D
@onready var pauseMenu = preload("res://scenes/menus/pause_menu.tscn")

var insideBuilding = false

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "back")
	
	if(Input.is_action_pressed("left")):
		sprite.flip_h = false
	elif(Input.is_action_pressed("right")):
		sprite.flip_h = true
	
	# apply the speed based on the inputted direction
	velocity = direction * speed
	
	if(!insideBuilding):
		move_and_slide()

func _on_door_area_area_entered(area: Area2D) -> void:
	if(area.is_in_group("doors") and !insideBuilding):
		area.enter()

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("pause")):
		var pauseMenuInstance = pauseMenu.instantiate()
		pauseMenuInstance.position = self.position - Vector2(960, 540)
		camera.zoom.x = 1
		camera.zoom.y = 1
		get_parent().add_sibling(pauseMenuInstance)
