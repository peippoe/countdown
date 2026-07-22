extends CharacterBody3D



@onready var player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	
	var to_player = player.global_position - global_position
	
	
	
	var target: Basis = Basis.looking_at(to_player.normalized())
	basis = basis.slerp(target, 3 * delta)
	
	velocity = to_player * 20 * delta
	
	move_and_slide()

const PROJECTILE = preload("uid://bd2fokwokprq8")
func _on_attack_timer_timeout() -> void:
	var new_projectile = PROJECTILE.instantiate()
	get_tree().root.add_child(new_projectile)
	new_projectile.global_position = global_position -global_basis.z
	new_projectile.linear_velocity = -global_basis.z * 20
