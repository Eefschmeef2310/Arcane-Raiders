extends State
class_name LSpiderRetreat
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
func physics_update(delta):
	super.physics_update(delta)
	if(enemy.global_position.distance_to(enemy.zone_pos) < 20):
		Transitioned.emit(self, "lspiderpassive")
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func enter():
	enemy.movement_speed = enemy.retreat_movespeed
	set_position()
	play_anim()
	
func set_position():
	navigation_agent.target_position = enemy.zone_pos
#endregion

