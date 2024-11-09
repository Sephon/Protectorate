extends Node3D  # or `Spatial` if you are using Godot 4.1+

@export var bullet_scene: PackedScene  # Reference to the bullet scene
@export var pool_size: int = 100       # Number of bullets to preload in the pool

# Maintain a pool of inactive bullets for reuse
var bullet_pool: Array[RigidBody3D] = []

func _ready():
	# Preload bullets into the pool without adding them as children
	for i in range(pool_size):
		var bullet = bullet_scene.instantiate() as RigidBody3D
		bullet_pool.append(bullet)
		bullet.queue_free()  # Free initially; they’ll be instanced on demand

func get_bullet() -> RigidBody3D:
	# Retrieve a bullet from the pool, or create a new one if the pool is empty
	var bullet: RigidBody3D
	if bullet_pool.size() > 0:
		bullet = bullet_pool.pop_back()
	else:
		bullet = bullet_scene.instantiate() as RigidBody3D

	# Add bullet to the root of the scene tree (or a designated "bullets" layer)
	get_tree().root.add_child(bullet)
	return bullet

func return_bullet(bullet: RigidBody3D):
	# Deactivate the bullet and return it to the pool
	bullet_pool.append(bullet)
	bullet.queue_free()  # Remove it from the scene tree for reuse later
