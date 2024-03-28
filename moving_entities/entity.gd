extends CharacterBody2D
class_name Entity
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants
const elements = {
	ElementResource.ElementType.Fire : preload("res://elements/fire.tres"),
	ElementResource.ElementType.Frost : preload("res://elements/frost.tres"),
	ElementResource.ElementType.Shock : preload("res://elements/shock.tres"),
	ElementResource.ElementType.Weakened : preload("res://elements/weakened.tres")
}
const SHOCK_EFFECT_LASER = preload("res://moving_entities/shock_effect_laser.tscn")

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var max_health : int = 1000
@export var health : int = 1000:
	set(value):
		health = clamp(value, 0, max_health)
		if health == 0:
			queue_free()

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var current_inflictions_dictionary : Dictionary

#endregion

#region Godot methods
func _process(delta):
	#Loop through each key in the dictionary, run the element's effect, then tick down the element's timer for removal
	for key in current_inflictions_dictionary:
		#apply effects
		if current_inflictions_dictionary.has(ElementResource.ElementType.Frost): frost_effect()
		
		#following line ticks down each key's timer, while taking weakness into account
		current_inflictions_dictionary[key] -= (delta * (0.5 if (key != ElementResource.ElementType.Weakened and current_inflictions_dictionary.has(ElementResource.ElementType.Weakened)) else 1))
		if current_inflictions_dictionary[key] <= 0:
			current_inflictions_dictionary.erase(key)
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func on_hurt(spell : Node2D):
	#Apply base damage
	health -= spell.base_damage
	
	#Add element to current inflictions dictionary
	print(spell.resource)
	if spell.resource:
		if !current_inflictions_dictionary.has(spell.resource.element):
			current_inflictions_dictionary[spell.resource.element] = 0
		current_inflictions_dictionary[spell.resource.element] += spell.resource.infliction_time
		current_inflictions_dictionary[spell.resource.element] = clamp(current_inflictions_dictionary[spell.resource.element], 0, spell.resource.element.max_infliction_time)

	#if shocked, run shock effect
	if current_inflictions_dictionary.has(ElementResource.ElementType.Shock):
		shock_effect(spell)
		
func shock_effect(spell):
	#get closest entity with same tag
	var closest : Node2D
	var closest_distance : float = INF
	for entity in get_tree().get_nodes_in_group(get_groups()[0]):
		if entity != self and global_position.distance_to(entity.global_position) < closest_distance:
			closest = entity
			closest_distance = global_position.distance_to(entity.global_position)
			
	#damage closest enemy
	closest.health -= 50
	
	#draw line between guys
	var shock_effect_laser = SHOCK_EFFECT_LASER.instantiate()
	(shock_effect_laser as Line2D).points[0] = global_position
	(shock_effect_laser as Line2D).points[1] = closest.global_position
	
	#current_inflictions_dictionary[spell.resource.element] += spell.resource.infliction_time
	#current_inflictions_dictionary[spell.resource.element] = clamp(current_inflictions_dictionary[spell.resource.element], 0, spell.resource.element.max_infliction_time)
	#
	#if current_inflictions_dictionary.has(SHOCK):
		#shock_effect(spell)
	
	get_tree().root.add_child(shock_effect_laser)

func frost_effect():
	velocity *= 0.5
#endregion
