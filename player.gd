extends CharacterBody3D



const JUMP_VELOCITY = 8
const JUMP_BOOST = 8

const SLIDE_BOOST = 8

const AIR_ACCEL = 3.0
const GROUND_ACCEL = 20.0
var accel = GROUND_ACCEL

const GROUND_FRICTION = 10.0


var speed = 20.0

var grounded = false
var can_jump = false
var sliding = false


@onready var cam: Camera3D = %Camera
@onready var head: Node3D = %Head
@onready var coll: CollisionShape3D = $CollisionShape3D
@export var HEIGHT: float = 2.0
@export var SLIDE_HEIGHT: float = 0.6

@export var max_health = 100
var health = max_health:
	set(value):
		health = minf(value, max_health)
		$UI/Health/Health2.scale.x = health / max_health
		
		if health <= 0:
			$UI/LoseScreen.show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
var health_drain = 10

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.screen_relative.x * 0.0001 * GameManager.sensitivity)
		cam.rotate_x(-event.screen_relative.y * 0.0001 * GameManager.sensitivity)
		
		cam.rotation.x = clampf(cam.rotation.x, -PI/2, PI/2)
	
	
	elif event is InputEventMouseButton:
		if Input.is_action_just_pressed("attack"):
			shoot()
	
	elif event is InputEventKey:
		if Input.is_action_just_pressed("space"):
			$JumpBufferTimer.start()
		if Input.is_action_just_pressed("slide"):
			$SlideBufferTimer.start()
		if Input.is_action_just_pressed("interact"):
			if interactables.size() > 0 and interactables[0].has_method("interact"):
				interactables[0].interact()

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
	
	if global_position.y < -200:
		global_position = Vector3(0, 10, 0)
		velocity = Vector3.ZERO
















func get_horizontal_velocity():
	return Vector3(velocity.x, 0, velocity.z)

func _physics_process(delta: float) -> void:
	
	if grounded and !is_on_floor():
		$CoyoteTimeTimer.start()
	
	grounded = is_on_floor()
	can_jump = grounded or !$CoyoteTimeTimer.is_stopped()
	
	
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var wish_dir := head.global_basis * Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	var quat = Quaternion.IDENTITY
	var normal = get_floor_normal()
	if not normal: normal = Vector3.UP
	if grounded:
		quat = Quaternion(Vector3.UP, normal)
		wish_dir = quat * wish_dir
	
	var boost_dir = wish_dir
	if not boost_dir:
		boost_dir = (-head.global_basis.z * quat).normalized()
	
	
	
	
	
	if grounded:
		if !$SlideBufferTimer.is_stopped() and $SlideCooldown.is_stopped():
			var result = Util.raycast(global_position, global_position - Vector3.UP*6, 1, [self])
			if result: global_position.y = result.position.y + SLIDE_HEIGHT / 2
			velocity = boost_dir * (get_horizontal_velocity().length() + SLIDE_BOOST)
			$SlideBufferTimer.stop()
			$SlideCooldown.start()
	
	if Input.is_action_pressed("slide"):
		sliding = true
		coll.shape.height = SLIDE_HEIGHT
	elif sliding:
		sliding = false
		coll.shape.height = HEIGHT
		if grounded: position.y += (HEIGHT-SLIDE_HEIGHT) / 2
	%Head.position.y = 0.7 * coll.shape.height/2
	
	
	
	
	
	
	accel = GROUND_ACCEL
	if not grounded:
		accel = AIR_ACCEL
		velocity.y -= 15.5 * delta # gravity
	if sliding:
		accel = AIR_ACCEL
	
	if can_jump and !$JumpBufferTimer.is_stopped():
		velocity.y = maxf(velocity.y, 0)+JUMP_VELOCITY
		if wish_dir:
			velocity += boost_dir * JUMP_BOOST
		grounded = false
		$CoyoteTimeTimer.stop()
		$JumpBufferTimer.stop()
	
	
	accelerate(wish_dir, speed, delta)
	if grounded and !sliding:
		apply_friction(delta)
	#if is_on_floor():
		#velocity = quat * velocity
	
	
	move_and_slide()















func accelerate(wish_dir, wish_speed, delta):
	var current_speed = velocity.dot(wish_dir)
	var add_speed = maxf(wish_speed - current_speed, 0)
	
	var current_accel = accel
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
