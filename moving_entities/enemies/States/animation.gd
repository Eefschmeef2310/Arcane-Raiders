extends State
class_name AnimationState
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables

@export var next_state: String = ""

var previous_state= ""

#endregion

#region Godot methods
func enter():
	play_anim()

func _on_animation_player_animation_finished(_anim_name):
	if get_parent().current_state == self:
		if next_state != "": Transitioned.emit(self, next_state)
		else: Transitioned.emit(self, previous_state)
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion

