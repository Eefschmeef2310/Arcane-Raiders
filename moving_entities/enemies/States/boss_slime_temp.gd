extends State
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var prefix: String = "w"
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
	enemy.swap_modulate(true)
	enemy.aim_direction = enemy.global_position.direction_to(get_closest_player().global_position)
	enemy.attempt_cast(1)

func physics_update(delta):
	super.physics_update(delta)
	if(enemy.can_cast):
		Transitioned.emit(self,prefix+"slimechase")

func exit():
	enemy.enraged = false
	enemy.swap_modulate(false)
#endregion

