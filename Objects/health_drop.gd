extends Area3D


func _physics_process(delta: float) -> void:
	position.y -= 1 * delta
	
	var to_player = GameManager.player.global_position - global_position
	global_position += to_player * delta * 6


func _on_body_entered(body: Node3D) -> void:
	if !body.is_in_group("player"): return
	
	body.health += 50
	Util.play_sound("res://pew.mp3", null, Vector2(1.5, 1.6))
	queue_free()
