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

@export var screen_margin : Vector2 = Vector2(128, 128) # Margin from the edge of the screen

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
	#position = Vector2(get_viewport_rect().size.x / 2 - 64, get_viewport_rect().size.y / 2 - 64) + direction * 100
	
	
	#var exit_screen_pos : Transform2D = exit.get_screen_transform()
	#
	##If exit is offscreen
	#if exit_screen_pos.origin.x <= 0 || exit_screen_pos.origin.x >= get_viewport_rect().size.x || exit_screen_pos.origin.y <= 0 || exit_screen_pos.origin.y >= get_viewport_rect().size.y:
		#clamp(exit_screen_pos.origin.x, 0, get_viewport_rect().size.x)
		#clamp(exit_screen_pos.origin.y, 0, get_viewport_rect().size.y)
		#
		## Calculate the position of the TextureRect at the edge of the screen
		#var edge_pos = camera_pos + direction.normalized() * (get_viewport_rect().size / 2)
		#position = edge_pos

#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
