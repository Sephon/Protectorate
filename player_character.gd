extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var bullet_speed: float = 80.0  # Speed of the bullet
@export var bullet_source: NodePath
@export var character_camera: Camera3D
@export var autofire_delay = 0.15

var CorrectSound = preload("res://Pistol2.mp3")

func shoot_bullet():
	var pistol = get_parent().get_node("PistolSound")	
	if pistol.is_playing():
		pistol.stop()
	
	pistol.play()
		
	print("Shooting bullet")
	# Get camera and mouse position
	var camera = get_viewport().get_camera_3d()
	var mouse_position = get_viewport().get_mouse_position()

	# Calculate ray origin and direction
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_direction = camera.project_ray_normal(mouse_position)

	# Define a ground plane at the player's Y level
	var ground_y = global_transform.origin.y
	var t = (ground_y - ray_origin.y) / ray_direction.y

	# Calculate the intersection point of the ray with the ground plane
	var ray_target = ray_origin + ray_direction * t

	# Calculate the direction towards the target
	var target_direction = (ray_target - global_transform.origin).normalized()

	# Fire the bullet
	var manager = get_node(bullet_source) as Node3D
	var bullet = manager.get_bullet()

	if bullet:
		# Set the bullet's position to the player's position
		get_tree().root.add_child(bullet)
		bullet.global_transform.origin = global_transform.origin
		bullet.gravity_scale = 0
		bullet.linear_velocity = target_direction * bullet_speed
		bullet.visible = true

		var mesh_instance = bullet.get_node("BulletMeshInstance3D") as MeshInstance3D
		var particles = mesh_instance.get_node("BulletTrailParticles") as GPUParticles3D
		var trail_velocity = -bullet.linear_velocity
		var material = particles.process_material as ParticleProcessMaterial
		material = ParticleProcessMaterial.new() #New instance of material so we don't modify the same instance that all are referenced to
		particles.process_material = material
			
		material.initial_velocity_min = trail_velocity.length()
		material.initial_velocity_max = trail_velocity.length() +10
		material.direction = trail_velocity
		material.gravity = Vector3(0, 0, 0)  # Set gravity to zero in all directions
		
		material.spread = 1
		#particles.look_at(global_transform.origin + bullet.linear_velocity)


		particles.restart()


		# Make the bullet visible 

func fire_delay():
	await get_tree().create_timer(autofire_delay).timeout

var can_fire = true ;

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("mbutton_left"):
		for i in range(2):
			shoot_bullet()
			await get_tree().create_timer(0.05).timeout
			
	if Input.is_action_pressed("mbutton_left") and can_fire:
		can_fire = false  # Disable firing until the delay is over
		shoot_bullet()
		await fire_delay()  # Wait for the delay to complete
		can_fire = true  # Re-enable firing after the delay

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
	
