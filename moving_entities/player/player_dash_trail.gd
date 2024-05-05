extends Line2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var max_length : int

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var queue : Array
var point : Vector2

#endregion

#region Godot methods
func _ready():
	gradient.colors[1] = get_parent().data.main_color

func _process(_delta):
	global_position = Vector2.ZERO
	point = get_parent().global_position
		
	add_point(point)
	while get_point_count()>max_length:
		remove_point(0)
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
