extends TextureRect

# Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	# Signals

	# Enums

	# Constants

	# Exported Variables
	# @export_group("Group")
	# @export_subgroup("Subgroup")
@export var exit : Node2D
@export var camera : Camera2D

@export var screen_margin : float = 10 # Margin from the edge of the screen

	# Onready Variables

	# Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _process(_delta):
	var target_pos = exit.global_position
	var camera_pos = camera.get_screen_center_position()
	
	var direction : Vector2 = (target_pos - camera_pos).normalized()
	var angle = direction.angle()
	
	rotation = angle
	
	var exit_screen_pos : Transform2D = exit.get_screen_transform()
	
	# Calculate the aspect ratio
	var aspect_ratio = get_viewport_rect().size.x / get_viewport_rect().size.y

	#If exit is offscreen
	if exit_screen_pos.origin.x <= 0 || exit_screen_pos.origin.x >= get_viewport_rect().size.x || exit_screen_pos.origin.y <= 0 || exit_screen_pos.origin.y >= get_viewport_rect().size.y:
		exit_screen_pos.origin.x = clamp(exit_screen_pos.origin.x, 0 + screen_margin, get_viewport_rect().size.x - screen_margin)
		exit_screen_pos.origin.y = clamp(exit_screen_pos.origin.y, 0 + screen_margin, get_viewport_rect().size.y - screen_margin)
	else:
		rotation_degrees = 180
		
	position = exit_screen_pos.origin
#endregion
