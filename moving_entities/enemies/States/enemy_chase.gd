extends State
class_name EnemyFollow
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
#Signals

#Enums

#Constants

#Exported Variables
#@export_group("Group")
#@export_subgroup("Subgroup")
@export var attack_distance: float = 50

#Onready Variables
@onready var small_fry = $"../.."
#Other Variables (please try to separate and organise!)
var player: CharacterBody2D
#endregion

#region Godot methods

#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func enter():
	player = get_tree().get_first_node_in_group("player")
	#TODO Grab the closest player

func physics_update(delta):
	if(navigation_agent and player):
		super.physics_update(delta)
		var distance = player.global_position.distance_to(small_fry.global_position)
		if distance < attack_distance:
			small_fry.attempt_cast(0)
		
func set_position():
	#TODO Grab the closest player
	navigation_agent.target_position = player.global_position
#endregion

