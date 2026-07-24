extends CharacterBody3D


var max_speed = 18.0
const AIR_ACCEL = 4.0
const GROUND_ACCEL = 22.0
var accel = GROUND_ACCEL
const GROUND_FRICTION = 12.0

const GRAVITY = 18.5
const WALLRUN_GRAVITY = 5
var gravity = GRAVITY
const JUMP_VELOCITY = 8
const JUMP_FLOAT = 42
@export var jump_float_curve: Curve
const JUMP_BOOST = 4

const SLIDE_BOOST = 4

var grounded = false
var can_jump = false
var sliding = false
var wallrunning = 0
var wallruns_left = [1, 1]

var input_dir: Vector2 = Vector2.ZERO
var wish_dir: Vector3 = Vector3.ZERO
var boost_dir: Vector3 = Vector3.ZERO

@onready var cam: Camera3D = $Pivot/Camera
@onready var pivot: Node3D = $Pivot
@onready var coll: CollisionShape3D = $CollisionShape3D
@export var HEIGHT: float = 2.0
@export var SLIDE_HEIGHT: float = 0.6

@export var max_health = 100
var health = max_health:
	set(value):
		health = minf(value, max_health)
		$UI/Health/Health2.scale.x = health / max_health
		
		$UI/Vignette.modulate = Color(0.2, 0.0, 0.0, 0.8).lerp(Color(0, 0, 0, 0), health/max_health)
		#var diff = value - health
		#if diff < 0:
			#$UI/Vignette.modulate = Color(0.6, 0.0, 0.0, 0.72)
		#elif diff > 0:
			#$UI/Vignette.modulate = Color(0.6, 1.0, 0.0, 0.72)
		#var tween = get_tree().create_tween()
		#tween.tween_property($UI/Vignette, "modulate", Color(0, 0, 0, 0), 0.1)
		
		if health <= 0:
			$UI/LoseScreen.show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
var health_drain = 1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		pivot.rotate_y(-event.screen_relative.x * 0.0001 * GameManager.sensitivity)
		cam.rotate_x(-event.screen_relative.y * 0.0001 * GameManager.sensitivity)
		
		cam.rotation.x = clampf(cam.rotation.x, -PI/2, PI/2)
	
	
	elif event is InputEventMouseButton:
		if Input.is_action_just_pressed("attack"):
			shoot()
	
	elif event is InputEventKey:
		if Input.is_action_just_pressed("space"):
			$JumpBufferTimer.start()
		elif Input.is_action_just_pressed("slide"):
			$SlideBufferTimer.start()
		elif Input.is_action_just_pressed("interact"):
			if interactables.size() > 0 and interactables[0].has_method("interact"):
				interactables[0].interact()
		elif Input.is_action_just_pressed("ctrl") and $DownshiftCooldown.is_stopped():
			$DownshiftCooldown.start()
			velocity.y -= 20

func shoot():
	Util.play_sound()
	
	var from = cam.global_position
	var to = from + -cam.global_basis.z * 100
	var result = Util.raycast(from, to, 3, self, true)
	if result:
		var coll = result.collider
		#print(coll)
		if coll.name == "HealthComponent":
			coll.change_health(-4000)
	
	
	
	if result:
		to = result.position
	
	Util.spawn_trail(from + cam.global_basis.x*0.5 + cam.global_basis.y*-0.5 + cam.global_basis.z*-1, to)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.player = self

func _process(delta: float) -> void:
	health -= health_drain * delta
	
	if global_position.y < -60:
		global_position = Vector3(0, 10, 0)
		velocity = Vector3.ZERO
















func get_horizontal_velocity():
	return Vector3(velocity.x, 0, velocity.z)

func _physics_process(delta: float) -> void:
	
	# VARIABLE SETTING
	if grounded and !is_on_floor(): $CoyoteTimeTimer.start()
	grounded = is_on_floor()
	can_jump = grounded or !$CoyoteTimeTimer.is_stopped()
	
	gravity = GRAVITY
	if wallrunning != 0:
		gravity = WALLRUN_GRAVITY
	
	accel = GROUND_ACCEL
	if not grounded:
		accel = AIR_ACCEL
		velocity.y += -gravity * delta
	if sliding:
		accel = AIR_ACCEL
	
	if grounded:
		wallruns_left = [1, 1]
	
	
	# INPUT HANDLING
	input_dir = Input.get_vector("a", "d", "w", "s")
	wish_dir = pivot.global_basis * Vector3(input_dir.x, 0, input_dir.y).normalized()
	var slope_quat = Quaternion.IDENTITY
	if grounded:
		var normal = get_floor_normal()
		if not normal: normal = Vector3.UP
		slope_quat = Quaternion(Vector3.UP, normal)
		wish_dir = slope_quat * wish_dir
	
	boost_dir = wish_dir
	if not boost_dir:
		boost_dir = (-pivot.global_basis.z * slope_quat).normalized()
	
	
	# SLIDE
	if grounded:
		if !$SlideBufferTimer.is_stopped():
			var result = Util.raycast(global_position, global_position - Vector3.UP*6, 1, [self])
			if result: global_position.y = result.position.y + SLIDE_HEIGHT / 2
			
			if $SlideBoostCooldown.is_stopped():
				velocity = boost_dir * (get_horizontal_velocity().length() + SLIDE_BOOST)
				$SlideBoostCooldown.start()
			$SlideBufferTimer.stop()
	
	if Input.is_action_pressed("slide"):
		sliding = true
		coll.shape.height = SLIDE_HEIGHT
	elif sliding:
		sliding = false
		coll.shape.height = HEIGHT
		if grounded: position.y += (HEIGHT-SLIDE_HEIGHT) / 2
	cam.position.y = 0.75 * coll.shape.height/2
	
	
	
	
	# WALLRUN
	if $Pivot/WallrunCastLeft.is_colliding() and wallruns_left[0] or $Pivot/WallrunCastRight.is_colliding() and wallruns_left[1]:
		$WallrunCoyoteTimeTimer.start()
	
	if wallrunning != 0 and Input.is_action_just_released("space"):
		jump()
		var conversion = 0
		if wish_dir: conversion = 5
		velocity = boost_dir*(get_horizontal_velocity().length() + conversion) + Vector3.UP*(velocity.y - conversion)
		#print("WAHOO")
	
	if grounded or not Input.is_action_pressed("space") or $WallrunCoyoteTimeTimer.is_stopped():
		wallrunning = 0
		$WallrunCoyoteTimeTimer.stop()
	elif Input.is_action_just_pressed("space"):
		if $Pivot/WallrunCastLeft.is_colliding():
			if wallrunning == 0:
				wallruns_left[0] = 0
			wallrunning = -1
		elif $Pivot/WallrunCastRight.is_colliding():
			if wallrunning == 0:
				wallruns_left[1] = 0
			wallrunning = 1
	
	
	
	
	
	if can_jump and !$JumpBufferTimer.is_stopped():
		jump()
	
	# JUMP FLOAT
	if Input.is_action_pressed("space") and !$JumpFloatTimer.is_stopped():
		var f = JUMP_FLOAT * jump_float_curve.sample_baked(1.0 - $JumpFloatTimer.time_left / $JumpFloatTimer.wait_time)
		velocity.y += f * delta
	
	
	accelerate(wish_dir, max_speed, delta)
	if grounded and !sliding:
		apply_friction(delta)
	#if is_on_floor():
		#velocity = quat * velocity
	
	move_and_slide()


func jump():
	velocity.y = maxf(velocity.y, 0)+JUMP_VELOCITY
	velocity += wish_dir * JUMP_BOOST
	grounded = false
	$CoyoteTimeTimer.stop()
	$JumpBufferTimer.stop()
	$JumpFloatTimer.start()
	$WallrunCoyoteTimeTimer.stop()










func accelerate(wish_dir, wish_speed, delta):
	var current_speed = velocity.dot(wish_dir)
	var add_speed = maxf(wish_speed - current_speed, 0)
	#print(add_speed)
	var current_accel = accel
	if current_speed <= 0 and current_accel == AIR_ACCEL:
		current_accel *= 1.4
	#if add_speed <= 0:
		#current_accel = 0
		#print("slow down?")
	var accel_speed = current_accel * delta * wish_speed
	
	if accel_speed > add_speed:
		accel_speed = add_speed
	
	var move_vec = wish_dir * accel_speed
	velocity += move_vec

func apply_friction(delta):
	var speed = velocity.length()
	
	if speed < 0.01:
		velocity = Vector3.ZERO
		return
	
	var drop = speed * GROUND_FRICTION * delta
	var new_speed = maxf(speed - drop, 0)
	
	velocity *= new_speed / speed








var interactables = []
func update_interact():
	if interactables.size() > 0:
		$UI/InteractLabel.show()
		$UI/InteractLabel.text = "[E] interact (%s)" % interactables[0].name
	else:
		$UI/InteractLabel.hide()

func _on_interact_area_area_entered(area: Area3D) -> void:
	interactables.append(area.get_parent())
	update_interact()

func _on_interact_area_area_exited(area: Area3D) -> void:
	interactables.erase(area.get_parent())
	update_interact()
