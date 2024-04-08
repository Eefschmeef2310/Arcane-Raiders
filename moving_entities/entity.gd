extends CharacterBody2D
class_name Entity
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals
signal zero_health
signal health_updated(health)

	#Constants
const SHOCK_EFFECT_LASER = preload("res://moving_entities/shock_effect_laser.tscn")
const DAMAGE_NUMBER = preload("res://ui/damage_number.tscn")

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var max_health : int = 1000
@export var health : int = 1000:
	set(value):
		health = clamp(value, 0, max_health)
		if health == 0:
			zero_health.emit()
		health_updated.emit(health)

@export var do_damage_numbers: bool = true
	#Onready Variables

	#Other Variables (please try to separate and organise!)
var current_inflictions_dictionary : Dictionary #Stores 

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
		#following line ticks down each key's timer, while taking wetness into account
		current_inflictions_dictionary[key] -= (delta * (0.5 if (key != SpellManager.elements["Wet"] and current_inflictions_dictionary.has(SpellManager.elements["wet"])) else 1.0))
		if current_inflictions_dictionary[key] <= 0:
			current_inflictions_dictionary.erase(key)
		
		if key == SpellManager.elements["burn"]:
			burn_effect(delta)
		elif key == SpellManager.elements["frost"]:
			frost_effect(0.5)
		elif key == SpellManager.elements["stun"]:
			frost_effect(0)
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func on_hurt(hit_node):
	if !is_multiplayer_authority():
		return

	var damage: int = 0
	var infliction_time: float
	var element: ElementResource
	
	#Apply base damage
	if "base_damage" in hit_node:
		damage = hit_node.base_damage
		health -= hit_node.base_damage
		infliction_time = hit_node.base_damage / 10
		
	
	#Add element to current inflictions dictionary
	if "resource" in hit_node and hit_node.resource:
		element = hit_node.resource.element
	elif "element" in hit_node and hit_node.element:
		element = hit_node.element
		
	if element:
		if element != SpellManager.elements["null"]:
			if !current_inflictions_dictionary.has(element):
				current_inflictions_dictionary[element] = 0
			current_inflictions_dictionary[element] += infliction_time
			current_inflictions_dictionary[element] = clamp(current_inflictions_dictionary[element], 0, element.max_infliction_time)
			
			#Check if a reaction has occurred, may need to be moved further up the method
			for key in current_inflictions_dictionary.keys():
				var reaction = SpellManager.get_reaction(key, element)
				if reaction:
					if reaction is StringName:
						print(reaction) #TODO This is for debug, as not all reactions have scenes yet
					elif reaction is PackedScene:
						current_inflictions_dictionary.erase(key)
						current_inflictions_dictionary.erase(element)
						
						reaction = reaction.instantiate()
						if "entity" in reaction:
							reaction.entity = self
							add_child(reaction)
						else:
							reaction.global_position = global_position
							get_tree().root.add_child(reaction)

	#if shocked, run shock effect
	if current_inflictions_dictionary.has(SpellManager.elements["shock"]):
		shock_effect()
	
	if do_damage_numbers:
		var damage_number: DamageNumber = DAMAGE_NUMBER.instantiate()
		add_sibling(damage_number)
		damage_number.global_position = global_position
		damage_number.set_number(damage)
		if element:
			damage_number.set_color(element.colour)
		damage_number.animate()

func burn_effect(delta):
	if burn_timer > 0:
		burn_timer -= delta
	if burn_timer <= 0:
		health -= 20
		burn_timer = burn_tick_rate

func frost_effect(amount):
	frost_speed_scale = amount

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
		
		if current_inflictions_dictionary.has(SpellManager.elements["shock"]):
			shock_effect()
		
		#draw line between guys
		var shock_effect_laser = SHOCK_EFFECT_LASER.instantiate()
		(shock_effect_laser as Line2D).points[0] = global_position
		(shock_effect_laser as Line2D).points[0].y -= 16
		(shock_effect_laser as Line2D).points[1] = closest.global_position
		(shock_effect_laser as Line2D).points[1].y -= 16
		add_sibling(shock_effect_laser)
#endregion
