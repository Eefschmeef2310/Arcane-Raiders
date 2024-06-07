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

	# Onready Variables

	# Other Variables (please try to separate and organise!)
var screen_margin : float = 10.0 # Margin from the edge of the screen
#endregion

#region Godot methods
func _process(_delta):
	var screen_size = get_viewport_rect().size
	var angle = exit.global_position.angle_to_point(camera.global_position) + PI
	
	var x = screen_size.x / 2 * cos(angle) + screen_size.x / 2
	var y = screen_size.y / 2 * sin(angle) + screen_size.y / 2

	# Apply margin to avoid going out of screen bounds
	x = clamp(x, screen_margin, screen_size.x - screen_margin)
	y = clamp(y, screen_margin, screen_size.y - screen_margin)

	position = Vector2(x, y)

func _draw():
	draw_line(exit.global_position, camera.global_position, Color.RED)
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
