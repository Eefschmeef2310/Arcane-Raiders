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
	#if direction.length() < attack_distance:
		#print("attack")
	pass
		
func set_position():
	navigation_agent.target_position = player.global_position
#endregion

