extends CharacterBody2D
class_name Entity
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals
signal zero_health
signal health_updated(health)
signal dealt_damage(Entity, int)
signal killed_entity(Entity)

	#Constants
const SHOCK_EFFECT_LASER = preload("res://moving_entities/shock_effect_laser.tscn")
const DAMAGE_NUMBER = preload("res://ui/damage_number.tscn")

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var ignoreForStats : bool # if true then this entity is exempt from stat tracking 
@export var kill_credited : bool

@export var death_sound : AudioStream
@export var max_health : int = 1000
@export var health : int = 1000:
	set(value):
		health = clamp(value, 0, max_health)
		if health <= 0 and !is_dead:
			
			#Play death sound
			AudioManager.play_audio2D_at_point(global_position, death_sound)
			
			is_dead = true
			zero_health.emit()
		health_updated.emit(health)
var is_dead: bool = false

@export var do_damage_numbers: bool = true
@export var print_velocity: bool = false

@export_subgroup("Knockback")
@export var knockback_lerp_strength : float = 20
@export var knockback_initial_velocity : float = 300

@export_subgroup("Attraction")
@export var attraction_strength : float = 1

	#Onready Variables
@onready var hit_sound = $HitSound

var monetary_value : int = 0

	#Other Variables (please try to separate and organise!)
var current_inflictions_dictionary : Dictionary #Stores the element as the key, and the time until removal (in float) as the value
var current_reactions_dictionary : Dictionary #Stores the reactions as the key, and the time till that reaction can be made again
var damage_number : DamageNumber

var burn_timer : float
var burn_tick_rate : float = 0.5
var frost_speed_scale : float = 1.0
var ice_speed_scale : float = 1.0
var shocked_this_frame : bool = false

var can_input : bool = true
var input_preventing_node : Node

var knockback_velocity : float
var knockback_direction : Vector2
var knockback_floor : float = 0.5
var knockback_hold_timer = 0

#for attraction stuff
var attraction_direction : Vector2

#Damage multiplier
var entity_damage_multiplier = 1.0
#endregion

#region Godot methods
#TODO DON'T FORGET TO CALL THE SUPER!!!!
func _process(delta):
	frost_speed_scale = 1.0
	shocked_this_frame = false
	
	#Loop through each key in the dictionary, run the element's effect, then tick down the element's timer for removal
	for key in current_inflictions_dictionary:
		#following line ticks down each key's timer, while taking wetness into account
		current_inflictions_dictionary[key] -= delta
		if current_inflictions_dictionary[key] <= 0:
			current_inflictions_dictionary.erase(key)
		
		if key == SpellManager.elements["burn"]:
			burn_effect(delta)
		elif key == SpellManager.elements["frost"] and ice_speed_scale == 1.0:
			frost_effect(0.5)
		elif key == SpellManager.elements["stun"]:
			frost_effect(0)
			
	#count down current reactions dictionary:
	for key in current_reactions_dictionary:
		current_reactions_dictionary[key] -= delta
		if current_reactions_dictionary[key] <= 0:
			current_reactions_dictionary.erase(key)

func _physics_process(delta):
	if knockback_hold_timer > 0:
		knockback_hold_timer -= delta
	else:
		knockback_velocity = lerp(knockback_velocity, 0.0, clamp(delta * knockback_lerp_strength, 0, 1.0))
		if knockback_velocity >= 0 and knockback_velocity <= knockback_floor:
			can_input = true
		elif knockback_velocity <= 0 and knockback_velocity >= -knockback_floor:
			can_input = true
	
	set_deferred("ice_speed_scale", 1.0)
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
	var should_make_new_numbers : bool = false
	var cast_uuid : CastUUIDManager
	
	#Apply base damage
	if "base_damage" in attack:
		damage = attack.base_damage
	
	if "cast_uuid" in attack:
		if is_instance_valid(attack.cast_uuid):
			cast_uuid = attack.cast_uuid
			#print("~~~~~~~~~~~~~~~~~~~~~")
			#print("Max damage: " + str(cast_uuid.max_damage))
			if cast_uuid.damage_dealt_to_each_enemy.has(self):
				#print("Running total damage: " + str(cast_uuid.damage_dealt_to_each_enemy[self]))
				var total_damage = cast_uuid.damage_dealt_to_each_enemy[self] + damage
				if cast_uuid.max_damage != 0 and total_damage > cast_uuid.max_damage:
					damage = total_damage - cast_uuid.max_damage
					#print("Limiting damage to " + str(damage))
				cast_uuid.damage_dealt_to_each_enemy[self] = cast_uuid.damage_dealt_to_each_enemy[self] + damage
			else:
				cast_uuid.damage_dealt_to_each_enemy[self] = damage
	
	if "infliction_time" in attack:
		infliction_time = attack.infliction_time
	
	#Add element to current inflictions dictionary
	if "resource" in attack and attack.resource:
		element = attack.resource.element
	elif "element" in attack and attack.element:
		element = attack.element
		
	if "should_make_new_numbers" in attack:
		should_make_new_numbers = attack.should_make_new_numbers
	
	# RPC call for damage
	deal_damage.rpc(attack.get_path(), damage, SpellManager.elements.find_key(element), infliction_time, should_make_new_numbers)
			
	#if shocked, run shock effect
	if current_inflictions_dictionary.has(SpellManager.elements["shock"]):
		shock_effect()
	
	if (!("can_knockback" in attack) || attack.can_knockback):
		add_knockback.rpc(attack.get_path())

@rpc("authority", "call_local", "reliable")
func deal_damage(attack_path, damage, element_string, infliction_time, create_new):
	var is_critical = false
	
	#Play hurt sound
	if hit_sound:
		hit_sound.play()
		
	if element_string != null and attack_path != null:
		#var attack = get_node(attack_path)
		var element = SpellManager.elements[element_string]
		if element != SpellManager.elements["null"]:
			if !current_inflictions_dictionary.has(element):
				current_inflictions_dictionary[element] = 0
			current_inflictions_dictionary[element] += infliction_time
			current_inflictions_dictionary[element] = clamp(current_inflictions_dictionary[element], 0, element.max_infliction_time)
		
		#Check if a reaction has occurred, may need to be moved further up the method
		#for key in current_inflictions_dictionary.keys():
			#continue
			#var reaction = SpellManager.get_reaction(key, element)
			#if reaction and !current_reactions_dictionary.has(reaction):
				##apply bonus damage (Extra 1/4 of the spell you were just hit by to cause the reaction)
				#damage *= 1.25
				#is_critical = true
				#
				#current_inflictions_dictionary.erase(key)
				#current_inflictions_dictionary.erase(element)
				#
				#var new_reaction = reaction.instantiate()
				#
				#if "caster" in new_reaction and attack != null:
					#new_reaction.caster = attack.caster
					#new_reaction.set_multiplayer_authority(attack.get_multiplayer_authority())
					##print_debug(attack.caster.name)
					#if attack and attack.caster and "add_reaction" in attack.caster:
						#attack.caster.add_reaction.rpc()
						##print_debug("Reactions: " + str(attack.caster.data.reactions_created))
					#
				#if "elements" in new_reaction:
					#new_reaction.elements = [key, element]
				#
				#if "entity" in new_reaction:
					#new_reaction.entity = self
					#call_deferred("add_child", new_reaction)
				#else:
					#get_tree().root.call_deferred("add_child", new_reaction)
					#new_reaction.global_position = global_position
					#
				##Add to reactions dictionary
				#current_reactions_dictionary[SpellManager.get_reaction(key, element)] = 1.0
		
	#Calculate final damage (bonus damage with wet)
	var final_damage = damage * (1.5 if current_inflictions_dictionary.has(SpellManager.elements["wet"]) else 1.0)
	if is_in_group("player") and get_parent() is CastleRoom and get_parent().james_mode: final_damage *= 2
	
	# Tell attack caster that they're the GOAT
	if attack_path != null:
		var attack = get_node(attack_path)
		if "caster" in attack and is_instance_valid(attack.caster) and attack.caster is Entity:
			if not self.ignoreForStats :
				attack.caster.dealt_damage.emit(self, final_damage)
				if health - final_damage <= 0 and not kill_credited:
					attack.caster.killed_entity.emit(self)
	
	# Deal damage!!!
	health -= final_damage
	
	if do_damage_numbers and final_damage > 0:
		var dm: DamageNumber
		if !is_instance_valid(damage_number) or create_new or is_critical:
			dm = DAMAGE_NUMBER.instantiate()
			add_sibling(dm)
			if !create_new and !is_critical:
				print(str(is_critical) + ", " + str(create_new))
				damage_number = dm
		else:
			dm = damage_number
		dm.global_position = global_position
		if element_string != null and SpellManager.elements[element_string]:
			dm.set_color(SpellManager.elements[element_string].colour)
		dm.set_critical(is_critical)
		dm.add(final_damage)

@rpc("any_peer", "call_local", "reliable")
func heal_damage(amount):
	health += amount
	
	var dm: DamageNumber
	dm = DAMAGE_NUMBER.instantiate()
	add_sibling(dm)
	dm.global_position = global_position
	dm.set_color(Color.GREEN)
	dm.add(amount/10)
	
@rpc("authority", "call_local", "reliable")
func set_health(amount):
	health = amount

func burn_effect(delta):
	if is_multiplayer_authority():
		if burn_timer > 0:
			burn_timer -= delta
		if burn_timer <= 0:
			deal_damage.rpc(null, 10, null, null, true)
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
			if entity is Entity and entity != self and global_position.distance_to(entity.global_position) < closest_distance and !entity.shocked_this_frame:
				closest = entity
				closest_distance = global_position.distance_to(entity.global_position)
	
	if closest:
		#damage closest enemy
		closest.deal_damage.rpc(null, 5, null, null, true)
		
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
func add_knockback(attack_path):
	var attack = get_node(attack_path)
	knockback_velocity = knockback_initial_velocity
	if current_inflictions_dictionary.has(SpellManager.elements["wind"]):
		knockback_velocity *= 2
		knockback_hold_timer = 0.1
	if attack:
		knockback_direction = get_node(attack_path).global_position.direction_to(global_position)
		if "knockback" in attack:
			knockback_velocity *= attack.knockback
	can_input = false

func get_knockback_velocity():
	#if print_velocity:
		#print(can_input)
	return knockback_direction * knockback_velocity

func get_attraction_velocity():
	return attraction_direction * attraction_strength
#endregion
