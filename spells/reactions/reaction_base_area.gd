extends Area2D
class_name ReactionArea
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Exported Variables
@export var base_damage : int = 10
#endregion

#region Godot methods
func _ready():
	#Get all reactions
	#Distance check
	for node in get_tree().get_nodes_in_group(get_groups()[0]):
		if node != self and node.global_position.distance_to(global_position) < 300:
			print("dingus")
			call_deferred("queue_free")
#endregion
