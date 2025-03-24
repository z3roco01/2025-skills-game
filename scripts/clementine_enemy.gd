extends Enemy

# the amount we will push the player by when too close
@export var push = 500

@onready var homingScene = preload("res://scenes/clementine_homing.tscn")
# set when a homing has been created
var homingOut = false

func idleAction() -> void:
	pass

# run every physics tick when the attack cooldown is 0
func attack() -> void:
	# player is close
	if(distanceToPlayer() <= 400):
		var pushVec = inPlayerDir(push)
		get_tree().create_tween().tween_property(player, "position", player.position + pushVec, 0.4).set_trans(Tween.TRANS_BACK)
		attackCooldown = 100
	elif(!homingOut):
			homingOut = true
			# create instance of homing
			var scene = homingScene.instantiate()
			scene.player = player
			scene.position = position + inPlayerDir(90)
			scene.look_at(player.position)
			# connect the tree_exit which happens when queue_free is called
			scene.connect("tree_exited", onHomingDestroyed)
			add_child(scene)

func onHomingDestroyed() -> void:
	homingOut = false
	attackCooldown = 50
