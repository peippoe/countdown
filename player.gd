extends CharacterBody3D



const JUMP_VELOCITY = 8


const AIR_ACCEL = 4.0
const GROUND_ACCEL = 20.0
var accel = GROUND_ACCEL

const GROUND_FRICTION = 10.0


var speed = 20.0

var grounded = true
var can_jump = true



@onready var cam: Camera3D = %Camera
@onready var head: Node3D = %Head

@export var max_health = 100
var health = max_health:
	set(value):
		health = value
		$UI/Health/Health2.scale.x = health / max_health
		
		if health <= 0:
			$UI/LoseScreen.show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
var health_drain = 1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.screen_relative.x * 0.0001 * GameManager.sensitivity)
		cam.rotate_x(-event.screen_relative.y * 0.0001 * GameManager.sensitivity)
	
	
	elif event is InputEventMouseButton:
		if Input.is_action_just_pressed("attack"):
			shoot()
	
	elif event is InputEventKey:
		if Input.is_action_just_pressed("space"):
			$JumpBufferTimer.start()

func shoot():
	Util.play_sound()
	
	var from = cam.global_position
	var to = from + -cam.global_basis.z * 100
	var result = Util.raycast(from, to, 1, self, true, false)
	if !result: return
	
	var coll = result.collider
	#print(coll)
	if coll.name == "HealthComponent":
		coll.change_health(-40)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	health -= health_drain * delta
	
	if global_position.y < -200:
		global_position = Vector3(0, 10, 0)
		velocity = Vector3.ZERO


















func _physics_process(delta: float) -> void:
	
	if grounded and !is_on_floor():
		$CoyoteTimeTimer.start()
	
	grounded = is_on_floor()
	can_jump = grounded or !$CoyoteTimeTimer.is_stopped()
	
	
	accel = GROUND_ACCEL
	if not grounded:
		accel = AIR_ACCEL
		velocity.y -= 14 * delta
	
	if can_jump and !$JumpBufferTimer.is_stopped():
		velocity.y = maxf(velocity.y, 0)+JUMP_VELOCITY
		grounded = false
		$CoyoteTimeTimer.stop()
		$JumpBufferTimer.stop()
	
	var horizontal_vel = Vector3(velocity.x, 0, velocity.z)
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var wish_dir := head.global_basis * Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	
	if is_on_floor():
		var quat = Quaternion(Vector3.UP, get_floor_normal())
		wish_dir = quat * wish_dir
	
	accelerate(wish_dir, speed, delta)
	if grounded:
		apply_friction(delta)
	
	
	move_and_slide()















func accelerate(wish_dir, wish_speed, delta):
	var current_speed = velocity.dot(wish_dir)
	var add_speed = wish_speed - current_speed
	
	var current_accel = accel
	#if add_speed <= 0 and not is_on_floor():
		#current_accel = 0
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
