extends Node
class_name MovementBase
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var movement_speed : float = 300

	#Onready Variables
var direction: Vector2

var can_input: bool = true

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _process(_delta):
	if(can_input):
		owner.velocity = direction * movement_speed
	else:
		owner.velocity = Vector2(0,0)
	
	owner.move_and_slide()
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func set_direction(dir: Vector2):
	direction = dir
#endregion
