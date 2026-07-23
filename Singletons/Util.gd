extends Node3D


func play_sound(path = "res://pew.mp3", pos = null, pitch = Vector2(0.9, 1.1)):
	
	var new_sound
	if pos:
		new_sound = AudioStreamPlayer3D.new()
	else:
		new_sound = AudioStreamPlayer.new()
	
	get_tree().root.get_node("Main").add_child(new_sound)
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


func spawn_trail(from, to):
	var new_mesh = MeshInstance3D.new()
	get_tree().root.get_node("Main/World").add_child(new_mesh)
	
	var draw_mesh = ImmediateMesh.new()
	new_mesh.mesh = draw_mesh
	
	var mat = load("res://bullet_mat.tres").duplicate()
	draw_mesh.surface_begin(Mesh.PRIMITIVE_LINES, mat)
	draw_mesh.surface_add_vertex(from)
	draw_mesh.surface_add_vertex(to)
	draw_mesh.surface_end()
	
	var tween = get_tree().create_tween()
	
	#tween.tween_property(mat, "albedo_color", Color(1, 0, 0, 0.12), .06)
	tween.tween_property(mat, "albedo_color", Color(1, 0, 0, 0), .6)
	tween.tween_callback(new_mesh.queue_free)
	
	#await get_tree().create_timer(1).timeout
	
	#new_mesh.queue_free()
