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
var attacked: bool = false
#endregion

#region Godot methods

#endregion

#region Signal methods
func _on_animation_player_animation_finished(anim_name):
	if anim_name == animation:
		attacked = true
		Transitioned.emit(self,"lobattackex")
#endregion

#region Other methods (please try to separate and organise!)
func enter():
	play_anim()

func physics_update(delta):
	if attacked == true && enemy.can_cast: 
		attacked = false
		Transitioned.emit(self,"calmdown")
#endregion

