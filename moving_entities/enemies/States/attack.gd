extends State
class_name Attack
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var spell_num: int = 0
	#Onready Variables

	#Other Variables (please try to separate and organise!)
var previous_state= ""
#endregion

#region Godot methods
func enter():
	play_anim()
	set_position()
	enemy.attempt_cast(spell_num)

func physics_update(delta):
	super.physics_update(delta)
	if enemy.can_cast:
		Transitioned.emit(self, previous_state)
		
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion

