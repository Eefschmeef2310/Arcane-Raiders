extends State
class_name GSlimeEnraged
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods

#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func enter():
	#TODO enraged anim
	pass

func physics_update(_delta):
	if(enemy.can_cast):
		enemy.attempt_cast(2)
		Transitioned.emit(self,"gslime")

func exit():
	enemy.enraged = false
#endregion

