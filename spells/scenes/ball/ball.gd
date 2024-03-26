extends RigidBody2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants
	
	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var force : float = 1000

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var resource : Spell

#endregion

#region Godot methods
func _ready():
	var angle = get_angle_to(get_global_mouse_position())
	apply_impulse(Vector2(cos(angle), sin(angle)) * force)

func _process(_delta):
	#Runs per frame
	pass
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
