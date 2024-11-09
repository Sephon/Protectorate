extends RigidBody3D

@export var speed: float = 500.0
@onready var bullet_manager = get_tree().get_root().find_node("BulletManager", true, false)  # Reference the manager

var direction: Vector3

func _ready():
	# Set the bullet to auto-remove after 2 seconds
	await get_tree().create_timer(2.0).timeout
	bullet_manager.return_bullet(self)

func _physics_process(delta):
	# Move bullet in the assigned direction
	global_transform.origin += direction * speed * delta

	# Optionally, check if offscreen or collided to return bullet early
	if is_offscreen():
		bullet_manager.return_bullet(self)

func is_offscreen() -> bool:
	var camera = get_viewport().get_camera_3d()
	var screen_pos = camera.unproject_position(global_transform.origin)
	return screen_pos.x < 0 or screen_pos.x > get_viewport().size.x or screen_pos.y < 0 or screen_pos.y > get_viewport().size.y