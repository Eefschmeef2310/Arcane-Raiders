extends State
class_name BatChase
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var transition_range: float = 500
	#Onready Variables

	#Other Variables (please try to separate and organise!)
var player: CharacterBody2D
#endregion

#region Godot methods

#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func enter():
	set_position()
	
func physics_update(delta):
#If within transition range, transition into strafe mode
	if navigation_agent:
		super.physics_update(delta)
		var distance = player.global_position.distance_to(enemy.global_position)
		if distance < transition_range:
			Transitioned.emit(self, "batattack")
	
func set_position():
	player = get_closest_player()
	if(player):
		navigation_agent.target_position = player.global_position
	
#endregion

