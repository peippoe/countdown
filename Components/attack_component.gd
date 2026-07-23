extends Node3D

@export var projectile: PackedScene = null
@export var projectile_speed: float = 30.0
@export var knockback: float = 20.0
@export var damage: float = 1.0
@export var attack_cooldown: float = 1.0

signal attacked

func _ready() -> void:
	$AttackTimer.start(attack_cooldown)

func _on_attack_timer_timeout() -> void:
	
	if projectile:
		var new_projectile = projectile.instantiate()
		get_tree().root.get_node("Main/World").add_child(new_projectile)
		new_projectile.global_position = global_position -global_basis.z * 2
		new_projectile.linear_velocity = -global_basis.z * projectile_speed
	elif get_parent().target:
		var from = global_position
		
		var target_pos = get_parent().target.global_position
		var to_target = target_pos - from
		var to = target_pos + to_target.normalized()
		
		
		var result = Util.raycast(from, to, 3, [self], true)
		
		if result:
			to = result.position
			
			if result.collider.name == "HealthComponent":
				result.collider.change_health(-damage)
		
		Util.spawn_trail(from, to)
	
	
	get_parent().velocity += (global_basis.z*6 + global_basis.x * randf_range(-1, 1) + Vector3.UP*randf_range(0, .1)).normalized() * knockback
	
	attacked.emit()
