extends Camera3D

@export var zoom_speed: float = 1  # Speed of zooming in/out
@export var min_zoom: float = 5.0    # Minimum zoom distance
@export var max_zoom: float = 20.0   # Maximum zoom distance

var zoom_distance: float = 10.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		update_camera_position()

func _input(event):
	# Check for scroll wheel input
	if event is InputEventMouseMotion:
		return  # Skip mouse motion events
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_distance -= zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_distance += zoom_speed

		# Clamp the zoom distance within limits
		zoom_distance = clamp(zoom_distance, min_zoom, max_zoom)

		# Update the camera's position
		update_camera_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_camera_position():
	# Assuming the camera is positioned behind the character, along the Z-axis
	var current_position = global_transform.origin
	current_position.y = zoom_distance
	global_transform.origin = current_position
