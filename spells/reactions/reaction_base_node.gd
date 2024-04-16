extends Node2D
class_name ReactionNode
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var base_damage : int = 10

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var should_continue: bool = true
var caster: Node2D
#var bonus_points : int #Stores however many reactions were destroyed to make room (tying this to damage bonuses and stuff)

#for calculating everages

#endregion

#region Godot methods
func _ready():
	for node in get_tree().get_nodes_in_group(get_groups()[0]):
		if node != self and node.global_position.distance_to(global_position) < 300:
			node.global_position = (node.global_position + global_position)/2
			#node.bonus_points += 1;
			remove_from_group(get_groups()[0])
			should_continue = false
			queue_free()
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
