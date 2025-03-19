extends Enemy

# the amount we will push the player from ( ONLY SET X )
@export var push = Vector2(500, 0)

func idleAction() -> void:
	pass

# run every physics tick when the attack cooldown is 0
func attack() -> void:
	# player is close
	if(distanceToPlayer() <= 400):
		var angle = push.angle_to(player.position)
		print(rad_to_deg(angle))
		var rotatedPush = push.rotated(push.angle_to(player.position))
		
		
		print(rotatedPush)
		#get_tree().create_tween().tween_property(player, "position", player.position + rotatedPush, 0.2)
		attackCooldown = 200  
