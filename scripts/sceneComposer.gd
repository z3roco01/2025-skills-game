extends Node2D

@export var scenes: Array[PackedScene]
@export var propertyOverides: Array[Dictionary]

var curSceneIdx = 0
var curScene: Node

func _ready() -> void:
	if(scenes.size() > 0 ):
		switchScene()

func onTreeExit() -> void:
	if(curSceneIdx+1 < scenes.size()):
		curSceneIdx += 1
		switchScene()

func switchScene() -> void:
	curScene = scenes[curSceneIdx].instantiate()
	setSceneProperties()
	curScene.connect("tree_exited", onTreeExit)
	add_child(curScene)

func setSceneProperties() -> void:
	if(!propertyOverides[curSceneIdx].is_empty()):
		for key in propertyOverides[curSceneIdx].keys():
			curScene.set(key, propertyOverides[curSceneIdx][key])
