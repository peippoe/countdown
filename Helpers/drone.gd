extends CharacterBody3D



var target = null

func _physics_process(delta: float) -> void:
	if not target:
		var enemies = get_tree().root.get_node("Main/World/Enemies")
		if enemies.get_child_count() > 0:
			target = enemies.get_child(0)
		return
	
	var to_target = target.global_position - global_position
	
	
	var t: Basis = Basis.looking_at(to_target.normalized())
	basis = basis.slerp(t, 3 * delta)
	
	#velocity += to_target * 1 * delta
	#velocity += -velocity * 0.8 * delta
	#move_and_slide()
	
	var to_player = GameManager.player.global_position - global_position
	var point = GameManager.player.global_position - to_player.normalized() * 10
	var to_point = point - global_position
	global_position += to_point * delta
