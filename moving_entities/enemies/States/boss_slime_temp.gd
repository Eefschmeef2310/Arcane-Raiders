extends State
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
@export var prefix: String = "w"
var attacked:bool = false
#endregion


#region Other methods (please try to separate and organise!)
func enter():
	play_anim()
	enemy.aim_direction = enemy.global_position.direction_to(get_closest_player().global_position)
	enemy.attempt_cast(1)

func physics_update(delta):
	super.physics_update(delta)
	if(enemy.can_cast):
		Transitioned.emit(self,prefix+"slimechase")

func exit():
	enemy.enraged = false
#endregion

