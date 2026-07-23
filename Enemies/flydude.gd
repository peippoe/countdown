extends CharacterBody3D





func _physics_process(delta: float) -> void:
	
	var to_player = GameManager.player.global_position - global_position
	
	
	
	var target: Basis = Basis.looking_at(to_player.normalized())
	basis = basis.slerp(target, 3 * delta)
	
	velocity += to_player * 1 * delta
	velocity += -velocity * 0.8 * delta
	
	move_and_slide()

const PROJECTILE = preload("uid://bd2fokwokprq8")
func _on_attack_timer_timeout() -> void:
	var new_projectile = PROJECTILE.instantiate()
	get_tree().root.add_child(new_projectile)
	new_projectile.global_position = global_position -global_basis.z * 2
	new_projectile.linear_velocity = -global_basis.z * 30
	velocity += (global_basis.z*6 + global_basis.x * randf_range(-1, 1) + Vector3.UP*randf_range(0, .1)).normalized() * 20
	await get_tree().create_timer(5).timeout
	new_projectile.queue_free()
