extends Enemy

# the amount we will push the player by when too close
@export var push = 500

@onready var homingScene = preload("res://scenes/clementine/clementine_homing.tscn")
@onready var explosionScene = preload("res://scenes/clementine/clementine_explosion.tscn")

func idleAction() -> void:
	pass

# run every physics tick when the attack cooldown is 0
func attack() -> void:
	# player is close
	if(distanceToPlayer() <= 400):
		var pushVec = inPlayerDir(push)
		get_tree().create_tween().tween_property(player, "position", player.position + pushVec, 0.4).set_trans(Tween.TRANS_BACK)
		attackCooldown = 100
	else:
		createExplosion()
		attackCooldown = 25

func homingAttack(homers: int) -> void:
	var scene = homingScene.instantiate()
	scene.player = player
	scene.position = position + inPlayerDir(130)
	scene.look_at(player.position)
	add_child(scene)

func createExplosion() -> void:
	var scene = explosionScene.instantiate()
	scene.player = player
	scene.position = player.position
	add_child(scene)
