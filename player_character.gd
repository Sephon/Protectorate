extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var bullet_speed: float = 500.0  # Speed of the bullet

@onready var bullet_manager = get_node("/root/bullet_manager")  # Adjust the path if needed

func shoot_bullet():
	print("Shooting bullet")
	# Get the mouse position in world space
	var camera = get_viewport().get_camera_3d()
	var ray_origin = camera.project_ray_origin(get_viewport().get_mouse_position())
	var ray_direction = camera.project_ray_normal(get_viewport().get_mouse_position())
	var ray_target = ray_origin + ray_direction * 1000  # Extend the ray into the distance

	# Calculate the direction from the player to the target
	var target_direction = (ray_target - global_transform.origin).normalized()

	# Retrieve a bullet from the BulletManager
	var bullet = bullet_manager.get_bullet()
	if bullet:
		# Set the bullet's position to the player's position
		bullet.global_transform.origin = global_transform.origin

		# Apply a velocity to the bullet to make it move in the calculated direction
		bullet.linear_velocity = target_direction * bullet_speed

		# Make the bullet visible 
		bullet.visible = true


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("mbutton_left"):
		shoot_bullet()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir_ui := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input_dir_wasd := Input.get_vector("wasd_left", "wasd_right", "wasd_up", "wasd_down")

# Combine both input directions
	var input_dir := input_dir_ui + input_dir_wasd
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
