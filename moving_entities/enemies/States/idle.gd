extends State
class_name Idle
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
@export var actual_first_state: State

#endregion

#region Godot methods

#endregion

#region Signal methods
func enter():
	navigation_agent.target_position = enemy.global_position
	play_anim()
#endregion

#region Other methods (please try to separate and organise!)
func update(_delta):
	if get_closest_player() && actual_first_state:
		Transitioned.emit(self, actual_first_state.name.to_lower())
#endregion

