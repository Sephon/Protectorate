extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


var ray_origin = Vector3()
var ray_target = Vector3()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	#print("Mouse position: ", mouse_position)
	
	
	ray_origin = $GameCamera.project_ray_origin(mouse_position)
	
	ray_target = ray_origin + $GameCamera.project_ray_normal(mouse_position) * 2000
	
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = ray_origin
	ray_params.to = ray_target
	
	var space_state = get_world_3d().direct_space_state
	var intersection = space_state.intersect_ray(ray_params)
	var offset = Vector3(0,1,0)
	if not intersection.is_empty():
		var pos = intersection.position + offset
		$PlayerCharacter.look_at(pos, Vector3.UP)
	
