extends CharacterBody2D
class_name Entity
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var current_inflictions_dictionary : Dictionary

#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass

func _process(delta):
	for key in current_inflictions_dictionary:
		current_inflictions_dictionary[key] -= delta
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func on_hurt(body):
	if !(body as Spell) : return
	
	if !current_inflictions_dictionary.has(body.resource.element):
		current_inflictions_dictionary[body.resource.element] = 0
	current_inflictions_dictionary[body.resource.element] += body.resource.infliction_time
	current_inflictions_dictionary[body.resource.element] = clamp(current_inflictions_dictionary[body.resource.element], 0, body.resource.element.max_infliction_time)
#endregion
