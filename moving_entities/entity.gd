extends CharacterBody2D
class_name Entity
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums
const elements = {
	ElementResource.ElementType.Burn : preload("res://elements/burn.tres"),
	ElementResource.ElementType.Frost : preload("res://elements/frost.tres"),
	ElementResource.ElementType.Shock : preload("res://elements/shock.tres"),
	ElementResource.ElementType.Weak : preload("res://elements/weak.tres"),
	ElementResource.ElementType.Null : preload("res://elements/null.tres")
}

	#Constants
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

var burn_timer : float
var burn_tick_rate : float = 0.5
var frost_speed_scale : float = 1.0
var shocked_this_frame : bool = false

#endregion

#region Godot methods
#TODO DON'T FORGET TO CALL THE SUPER!!!!
func _process(delta):
	frost_speed_scale = 1.0
	shocked_this_frame = false
	
	#Loop through each key in the dictionary, run the element's effect, then tick down the element's timer for removal
	for key in current_inflictions_dictionary:
		#apply effects
		if current_inflictions_dictionary.has(ElementResource.ElementType.Frost): frost_effect()

		#following line ticks down each key's timer, while taking weakness into account
		current_inflictions_dictionary[key] -= (delta * (0.5 if (key != elements[ElementResource.ElementType.Weak] and current_inflictions_dictionary.has(elements[ElementResource.ElementType.Weak])) else 1.0))
		if current_inflictions_dictionary[key] <= 0:
			current_inflictions_dictionary.erase(key)
		
		match key:
			elements[ElementResource.ElementType.Burn]:
				burn_effect(delta)
			elements[ElementResource.ElementType.Frost]:
				frost_effect()
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func on_hurt(spell : Node2D):
	#Apply base damage
	health -= spell.base_damage
	
	#Add element to current inflictions dictionary
	if spell.resource and spell.resource.element != elements[ElementResource.ElementType.Null]:
		if !current_inflictions_dictionary.has(spell.resource.element):
			current_inflictions_dictionary[spell.resource.element] = 0
		current_inflictions_dictionary[spell.resource.element] += spell.resource.infliction_time
		current_inflictions_dictionary[spell.resource.element] = clamp(current_inflictions_dictionary[spell.resource.element], 0, spell.resource.element.max_infliction_time)

	#if shocked, run shock effect
	if current_inflictions_dictionary.has(elements[ElementResource.ElementType.Shock]):
		shock_effect()

func burn_effect(delta):
	if burn_timer > 0:
		burn_timer -= delta
	if burn_timer <= 0:
		health -= 20
		burn_timer = burn_tick_rate

func frost_effect():
	frost_speed_scale = 0.5

func shock_effect():
	#get closest entity with same tag
	var closest : Node2D
	var closest_distance : float = INF
	for entity in get_tree().get_nodes_in_group(get_groups()[0]):
		if entity != self and global_position.distance_to(entity.global_position) < closest_distance and !entity.shocked_this_frame:
			closest = entity
			closest_distance = global_position.distance_to(entity.global_position)
	
	if closest:
		#damage closest enemy
		closest.health -= 50
		
		# stop ourselves and the other guy from getting shocked again
		shocked_this_frame = true
		closest.shocked_this_frame = true
		
		if current_inflictions_dictionary.has(ElementResource.ElementType.Shock):
			shock_effect()
		
		#draw line between guys
		var shock_effect_laser = SHOCK_EFFECT_LASER.instantiate()
		(shock_effect_laser as Line2D).points[0] = global_position
		(shock_effect_laser as Line2D).points[0].y -= 16
		(shock_effect_laser as Line2D).points[1] = closest.global_position
		(shock_effect_laser as Line2D).points[1].y -= 16
		add_sibling(shock_effect_laser)
			
	#spawn laser
	#if closest:
		#var shock_laser_spell = SHOCK_LASER_SPELL.spell_scene.instantiate()
		#(shock_laser_spell.get_children()[0] as RayCast2D).global_position = global_position
		#(shock_laser_spell.get_children()[0] as RayCast2D).add_exception(self)
		#(shock_laser_spell.get_children()[0] as RayCast2D).target_position = closest.global_position #I LOVE DEPENDENCIES
		#
		#get_tree().root.add_child(shock_laser_spell)
#endregion
