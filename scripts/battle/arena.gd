extends Node2D

# the scenes to show on win and lose
# using @export_file to get around cyclic dependacy issues
@export_file("*.tscn") var winPath = ""
@export_file("*.tscn") var losePath = ""
var winScene: PackedScene
var loseScene: PackedScene
@onready var enemy = $lanceEnemy
@onready var player = $player
@onready var waittimer = $waittimer

func _ready() -> void:
	MusicPlayer.playMusic("lanceBattle")
	enemy.connect("death", onenemyDeath)
	player.death.connect(onPlayerDeath)
	# load our scens, needed to get around cyclic dependacies
	winScene = ResourceLoader.load(winPath)
	loseScene = ResourceLoader.load(losePath)

func onenemyDeath() -> void:
	switchToScene(winScene)

func onPlayerDeath() -> void:
	switchToScene(loseScene)

# switches to the passed scene
func switchToScene(scene: PackedScene) -> void:
	var instance = scene.instantiate()
	add_sibling(instance)
	queue_free()
