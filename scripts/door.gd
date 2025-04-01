extends Area2D

@onready var player = get_node("../worldPlayer")
@export var buildingScene : PackedScene
var entered = false

# will exectue the logic to enter the building
func enter():
	if(!entered):
		# disable player movement and make the camera move the the scene
		player.insideBuilding = true
		player.camera.enabled = false
		var sceneInstance = buildingScene.instantiate()
		sceneInstance.connect("tree_exited", leftBuilding)
		get_parent().add_child(sceneInstance)

func leftBuilding():
	player.insideBuilding = false
	player.camera.enabled = true
