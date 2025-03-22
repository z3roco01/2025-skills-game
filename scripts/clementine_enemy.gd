extends Enemy

# the amount we will push the player by when too close
@export var push = 500

# used to get the rotation for pushing
@onready var pushRotator = $pushRotator

func idleAction() -> void:
	pass

# run every physics tick when the attack cooldown is 0
func attack() -> void:
	# player is close
	if(distanceToPlayer() <= 400):
		pushRotator.look_at(player.position)
		var pushVec = Vector2.RIGHT.rotated(pushRotator.rotation) * push
		get_tree().create_tween().tween_property(player, "position", player.position + pushVec, 0.4).set_trans(Tween.TRANS_BACK)
		attackCooldown = 100
		#var angle = push.angle_to(player.position)
		#print(rad_to_deg(angle))
		#var rotatedPush = push.rotated(push.angle_to(player.position))
		
		
		#print(rotatedPush)
		#get_tree().create_tween().tween_property(player, "position", player.position + rotatedPush, 0.2)
		#attackCooldown = 200  
