extends CharacterBody3D



var target = null

func _physics_process(delta: float) -> void:
	
	if not target:
		var enemies = get_tree().root.get_node("Main/World/Enemies")
		if enemies.get_child_count() > 0:
			target = enemies.get_child(0)
	
	
	var to_player = GameManager.player.global_position - global_position
	var point = GameManager.player.global_position - to_player.normalized() * 10
	var to_point = point - global_position
	#global_position += to_point * delta
	
	var look_target = target
	if not look_target: look_target = GameManager.player
	var dir = (look_target.global_position - global_position).normalized()
	var t: Basis = Basis.looking_at(dir)
	basis = basis.slerp(t, 3 * delta)
	
	var lift = (sin(GameManager.elapsed_time) + 0.99) * 90 * delta
	velocity.y += lift
	
	velocity += to_point * 20 * delta
	velocity += -velocity * 3 * delta
	move_and_slide()
	
	
	
