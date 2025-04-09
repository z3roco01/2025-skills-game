extends Node2D

# the scenes to show on win and lose
# using @export_file to get around cyclic dependacy issues
@export_file("*.tscn") var winPath = ""
@export_file("*.tscn") var losePath = ""
@export var pauseMenu : PackedScene
var winScene: PackedScene
var loseScene: PackedScene
@onready var enemy = $lanceEnemy
@onready var player = $player
@onready var waittimer = $waittimer
var paused = false

signal pause()
signal unpause()

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

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("pause") and !paused):
		var pauseMenuInstance = pauseMenu.instantiate()
		pauseMenuInstance.position = self.position - Vector2(960, 380)
		pauseMenuInstance.connect("tree_exited", pauseMenuClose)
		add_sibling(pauseMenuInstance)
		pause.emit()
		paused = true

func pauseMenuClose() -> void:
	paused = false
	unpause.emit()
