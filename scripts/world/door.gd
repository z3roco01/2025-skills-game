extends Area2D

@onready var player = get_node("../worldPlayer")
# need to hide it, since it gets in the way of the building
@onready var worldBg = get_node("../worldBg")
@export var buildingScene : PackedScene
@export var isDialogueScene = true
@export var dialogue : String
@export var expressions = {}
@export var defaultExpression: String
var entered = false

# will exectue the logic to enter the building
func enter():
	if(!entered):
		# disable player movement and make the camera move the the scene
		player.insideBuilding = true
		player.camera.enabled = false
		var sceneInstance = buildingScene.instantiate()
		if(isDialogueScene):
			sceneInstance.dialogueScript = dialogue
			sceneInstance.expressions = expressions
			sceneInstance.defaultExpression = defaultExpression
		worldBg.visible = false
		sceneInstance.connect("tree_exited", leftBuilding)
		get_parent().get_parent().add_child(sceneInstance)

func leftBuilding():
	player.insideBuilding = false
	player.camera.enabled = true
	worldBg.visible = true
