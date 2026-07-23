extends RigidBody3D



func _ready() -> void:
	await get_tree().create_timer(5).timeout
	queue_free()

func _on_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		body.health -= 10
