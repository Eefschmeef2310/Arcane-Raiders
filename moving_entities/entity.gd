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
		if health <= 0 and !is_dead:
			is_dead = true
			zero_health.emit()
		health_updated.emit(health)
var is_dead: bool = false

@export var do_damage_numbers: bool = true

@export_subgroup("Knockback")
@export var knockback_timeout : float = 20
@export var knockback_initial_velocity : float = 2000

@export_subgroup("Attraction")
@export var attraction_strength : float = 65
	#Onready Variables

	#Other Variables (please try to separate and organise!)
var current_inflictions_dictionary : Dictionary #Stores 
var damage_number : DamageNumber

var burn_timer : float
var burn_tick_rate : float = 0.5
var frost_speed_scale : float = 1.0
var shocked_this_frame : bool = false

var can_input : bool = true
var knockback_velocity : float
var knockback_direction : Vector2

#for attraction stuff
var attraction_direction : Vector2
#endregion

#region Godot methods
#TODO DON'T FORGET TO CALL THE SUPER!!!!
func _process(delta):
	frost_speed_scale = 1.0
	shocked_this_frame = false
	
	#Loop through each key in the dictionary, run the element's effect, then tick down the element's timer for removal
	for key in current_inflictions_dictionary:
		#following line ticks down each key's timer, while taking wetness into account
		current_inflictions_dictionary[key] -= (delta * (0.5 if (key != SpellManager.elements["wet"] and current_inflictions_dictionary.has(SpellManager.elements["wet"])) else 1.0))
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
func on_hurt(attack):
	if !is_multiplayer_authority():
		return
	
	if "caster" in attack and attack.caster == self:
		return
	
	var damage: int = 0
	var infliction_time: float
	var element: ElementResource
	
	#Apply base damage
	if "base_damage" in attack:
		damage = attack.base_damage
	
	if "infliction_time" in attack:
		infliction_time = attack.infliction_time
	
	#Add element to current inflictions dictionary
	if "resource" in attack and attack.resource:
		element = attack.resource.element
	elif "element" in attack and attack.element:
		element = attack.element
	
	# RPC call for damage
	deal_damage.rpc(attack.get_path(), damage, SpellManager.elements.find_key(element), infliction_time)
			
	#if shocked, run shock effect
	if current_inflictions_dictionary.has(SpellManager.elements["shock"]):
		print("Running shock effect for the first time.")
		shock_effect()
	
	if element == SpellManager.elements["wind"]:
		wind_effect.rpc(attack.get_path())

@rpc("authority", "call_local", "reliable")
func deal_damage(attack_path, damage, element_string, infliction_time):
	if element_string != null:
		var attack = get_node(attack_path)
		var element = SpellManager.elements[element_string]
		if element != SpellManager.elements["null"]:
			if !current_inflictions_dictionary.has(element):
				current_inflictions_dictionary[element] = 0
			current_inflictions_dictionary[element] += infliction_time
			current_inflictions_dictionary[element] = clamp(current_inflictions_dictionary[element], 0, element.max_infliction_time)
		
		#Check if a reaction has occurred, may need to be moved further up the method
		for key in current_inflictions_dictionary.keys():
			var reaction = SpellManager.get_reaction(key, element)
			if reaction:
				#apply bonus damage (Extra 1/4 of the spell you were just hit by to cause the reaction)
				damage *= 1.25
				
				current_inflictions_dictionary.erase(key)
				current_inflictions_dictionary.erase(element)
				
				var new_reaction = reaction.instantiate()
				
				if "caster" in new_reaction:
					new_reaction.caster = attack
				if "elements" in new_reaction:
					new_reaction.elements = [key, element]
				new_reaction.set_multiplayer_authority(attack.get_multiplayer_authority())
				
				if "entity" in new_reaction:
					new_reaction.entity = self
					call_deferred("add_child", new_reaction)
				else:
					get_tree().root.call_deferred("add_child", new_reaction)
					new_reaction.global_position = global_position
	
	health -= damage
	
	if do_damage_numbers:
		if !is_instance_valid(damage_number):
			damage_number = DAMAGE_NUMBER.instantiate()
			add_sibling(damage_number)
		damage_number.global_position = global_position
		damage_number.add(damage)
		if element_string != null and SpellManager.elements[element_string]:
			damage_number.set_color(SpellManager.elements[element_string].colour)

func burn_effect(delta):
	if is_multiplayer_authority():
		if burn_timer > 0:
			burn_timer -= delta
		if burn_timer <= 0:
			deal_damage.rpc(null, 5, null, null)
			burn_timer = burn_tick_rate

func frost_effect(amount):
	frost_speed_scale = amount

func shock_effect():
	# print("I've been shocked already.") if shocked_this_frame else print("I have NOT been shocked yet.")
	
	#get closest entity with same tag
	var closest : Node2D
	var closest_distance : float = INF
	
	if(get_groups().size() > 0):
		for entity in get_tree().get_nodes_in_group(get_groups()[0]):
			if entity != self and global_position.distance_to(entity.global_position) < closest_distance and !entity.shocked_this_frame:
				closest = entity
				closest_distance = global_position.distance_to(entity.global_position)
	
	if closest:
		#damage closest enemy
		closest.deal_damage.rpc(null, 50, null, null)
		
		# stop ourselves and the other guy from getting shocked again
		shocked_this_frame = true
		closest.shocked_this_frame = true
		
		if closest.current_inflictions_dictionary.has(SpellManager.elements["shock"]):
			closest.shock_effect()
		
		#draw line between guys
		spawn_shock_laser.rpc(global_position, closest.global_position)

# TODO: if too laggy, change to unreliable
@rpc("authority", "call_local", "reliable")
func spawn_shock_laser(p1: Vector2, p2: Vector2):
	var shock_effect_laser: Line2D = SHOCK_EFFECT_LASER.instantiate()
	shock_effect_laser.points[0] = p1
	shock_effect_laser.points[0].y -= 16
	shock_effect_laser.points[1] = p2
	shock_effect_laser.points[1].y -= 16
	add_sibling(shock_effect_laser)

@rpc("authority", "call_local", "reliable")
func wind_effect(attack_path):
	var attack = get_node(attack_path)
	knockback_velocity = knockback_initial_velocity
	if attack:
		knockback_direction = get_node(attack_path).global_position.direction_to(global_position)
	can_input = false
#endregion
