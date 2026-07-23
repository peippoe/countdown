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




func raycast(from, to, collision_mask = 3, exclude = [], coll_areas = false, coll_bodies = true):
	if exclude is not Array:
		exclude = [exclude]
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to, collision_mask, [])
	query.collide_with_areas = coll_areas
	query.collide_with_bodies = coll_bodies
	var result = space_state.intersect_ray(query)
	return result


func spawn_trail(from, to):
	var new_mesh = load("res://Projectiles/trail.tscn").instantiate()#MeshInstance3D.new()
	new_mesh.mesh = new_mesh.mesh.duplicate()
	
	get_tree().root.get_node("Main/World").add_child(new_mesh)
	
	var mat = load("res://bullet_mat.tres").duplicate()
	new_mesh.material_override = mat
	var to_from = to - from
	var dir = to_from.normalized()
	new_mesh.look_at_from_position(from + dir * new_mesh.mesh.height / 2, to)
	new_mesh.rotation_degrees.x += 90
	
	#var draw_mesh = ImmediateMesh.new()
	#new_mesh.mesh = draw_mesh
	#draw_mesh.surface_begin(Mesh.PRIMITIVE_LINES, mat)
	#draw_mesh.surface_add_vertex(from)
	#draw_mesh.surface_add_vertex(to)
	#draw_mesh.surface_end()
	
	
	
	
	var speed = 800
	var length = to_from.length()
	var tween_time = maxf(length / speed, 0.01)
	#print(tween_time)
	
	var tween = get_tree().create_tween()
	#tween.tween_property(mat, "albedo_color", Color(1, 0, 0, 0.12), .06)
	#tween.tween_property(mat, "albedo_color", Color(1, 0, 0, 0), tween_time)
	tween.parallel().tween_property(new_mesh, "global_position", to, tween_time)
	tween.parallel().tween_property(new_mesh.mesh, "height", .1, tween_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(new_mesh.queue_free)
	
	#await get_tree().create_timer(1).timeout
	
	#new_mesh.queue_free()

func spawn_damage_indicator(pos, damage):
	var new_indicator = Label3D.new()
	get_tree().root.get_node("Main/World").add_child(new_indicator)
	new_indicator.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	pos += Vector3.UP * 1
	new_indicator.global_position = pos
	new_indicator.fixed_size = true
	new_indicator.font_size = 32
	new_indicator.pixel_size = 0.001
	new_indicator.outline_size = 6
	new_indicator.text = str(int(damage))
	
	var tween_time = 0.6
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(mat, "albedo_color", Color(1, 0, 0, 0.12), .06)
	tween.tween_property(new_indicator, "modulate", Color(1, 0, 0, 0), tween_time)
	tween.parallel().tween_property(new_indicator, "outline_modulate", Color(0, 0, 0, 0), tween_time)
	tween.parallel().tween_property(new_indicator, "offset", Vector2(randf_range(-20, 20), 20), tween_time).set_ease(Tween.EASE_OUT)
	#tween.parallel().tween_property(new_indicator, "global_position", pos + Vector3.UP, tween_time).set_ease(Tween.EASE_OUT)
	#tween.tween_property(new_indicator, "offset", pos, 1).set_ease(Tween.EASE_OUT)
	tween.tween_callback(new_indicator.queue_free)
	
	
