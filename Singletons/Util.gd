extends Node3D


func play_sound(path = "res://pew.mp3", pos = null, pitch = Vector2(0.9, 1.1)):
	
	var new_sound
	if pos:
		new_sound = AudioStreamPlayer3D.new()
	else:
		new_sound = AudioStreamPlayer.new()
	
	get_tree().root.add_child(new_sound)
	new_sound.pitch_scale = randf_range(pitch.x, pitch.y)
	new_sound.stream = load(path)
	new_sound.play()
	
	
	await new_sound.finished
	
	new_sound.queue_free()




func raycast(from, to, collision_mask = 2, exclude = [], coll_areas = false, coll_bodies = true):
	if exclude is not Array:
		exclude = [exclude]
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to, collision_mask, [])
	query.collide_with_areas = coll_areas
	query.collide_with_bodies = coll_bodies
	var result = space_state.intersect_ray(query)
	return result
