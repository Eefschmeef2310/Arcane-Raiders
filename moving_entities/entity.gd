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
@export var max_health : int = 1000
@export var health : int = 1000:
	set(value):
		health = clamp(value, 0, max_health)
		if health == 0:
			print("I am dead, not big surprise")

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var current_inflictions_dictionary : Dictionary

#endregion

#region Godot methods
func _process(delta):
	#Loop through each key in the dictionary, run the element's effect, then tick down the element's timer for removal
	for key in current_inflictions_dictionary:
		key.effect(self) #Key is the element itself, so the effect can be run through the key
		current_inflictions_dictionary[key] -= delta
		if current_inflictions_dictionary[key] <= 0:
			current_inflictions_dictionary.erase(key)
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func on_hurt(spell):
	#Apply base damage
	health -= spell.base_damage
	
	#Add element to current inflictions dictionary
	if !current_inflictions_dictionary.has(spell.resource.element):
		current_inflictions_dictionary[spell.resource.element] = 0
	current_inflictions_dictionary[spell.resource.element] += spell.resource.infliction_time
	current_inflictions_dictionary[spell.resource.element] = clamp(current_inflictions_dictionary[spell.resource.element], 0, spell.resource.element.max_infliction_time)
#endregion
