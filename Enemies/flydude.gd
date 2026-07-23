extends CharacterBody3D





func _physics_process(delta: float) -> void:
	
	var to_player = GameManager.player.global_position - global_position
	
	
	
	var t: Basis = Basis.looking_at(to_player.normalized())
	basis = basis.slerp(t, 3 * delta)
	
	velocity += to_player * 1 * delta
	velocity += -velocity * 0.8 * delta
	
	move_and_slide()
