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

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func enter():
	play_anim()
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion



func _on_animation_player_animation_finished(_anim_name):
	if get_parent().current_state == self:
		Transitioned.emit(self, "bslimeperma")
