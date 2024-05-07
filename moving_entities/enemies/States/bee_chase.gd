extends State
class_name BeeChase
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
var distance = 200
var player: Player
#endregion

#region Godot methods

#endregion

#region Signal methods
func _on_navigation_agent_2d_target_reached():
	nav_timer = 0.5
#endregion

#region Other methods (please try to separate and organise!)
	
	
func set_position():
	player = get_closest_player()
	if !player: 
		Transitioned.emit(self, "idle")
		return
	
	#direction to player, rotate, then set that as the target pos
	var direction = enemy.global_position.direction_to(player.global_position).rotated(deg_to_rad(randi()%121 - 60))
	navigation_agent.target_position = direction * distance + enemy.global_position
#endregion



