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
#endregion

#region Godot methods
func _ready():
	#Get all reactions
	#Distance check
	for node in get_tree().get_nodes_in_group(get_groups()[0]):
		if node != self and node.global_position.distance_to(global_position) < 300:
			should_continue = false
			queue_free()

func _process(_delta):
	#Runs per frame
	pass
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
