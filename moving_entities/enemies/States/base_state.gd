extends Node
class_name State
#Authored by AlexV. Please consult for any modifications or major feature requests.
signal Transitioned


@export var animation: String = "idle"
@export_group("Navigation Timer")
@export var nav_timer_interval: float = 0.5
@export var nav_timer = 0

@onready var enemy: Entity = $"../.."

var navigation_agent: NavigationAgent2D
#region Other methods
func enter():
	pass
	
func exit():
	pass
	
func update(_delta):
	pass

#TODO MAKE SURE TO CALL THE SUPER WHEN MAKING A NEW STATE
func physics_update(delta):
	nav_timer -= delta
	if nav_timer <= 0:
		set_position()
		nav_timer = nav_timer_interval
	
func set_position():
	navigation_agent.target_position = enemy.global_position
	
func get_closest_player() -> CharacterBody2D:
	var p_arr = get_tree().get_nodes_in_group("player")
	var target
	var dist = INF
	for p in p_arr:
		if p is Player and enemy.global_position.distance_to(p.global_position) < dist and !p.is_in_group("enemy"):
			target = p
			dist = enemy.global_position.distance_to(p.global_position)
			
	if target: return target
	return null

func get_furthest_player() -> CharacterBody2D:
	var p_arr = get_tree().get_nodes_in_group("player")
	var target
	var dist = 0
	for p in p_arr:
		if p is Player and enemy.global_position.distance_to(p.global_position) > dist:
			target = p
			dist = enemy.global_position.distance_to(p.global_position)
			
	if target: return target
	return null

func can_cast_spell(spell_slot: int) -> bool:
	return enemy.enemy_spells.spell_cooldowns[spell_slot] <= 0 && enemy.can_cast
	
func can_cast_spell_player(spell_slot: int) -> bool:
	return owner.data.spell_cooldowns[spell_slot] <= 0 && owner.can_cast
	
func play_anim():
	if "attempt_anim" in owner and animation != "": enemy.attempt_anim(animation)
	
func set_nav_agent(nav_agent: NavigationAgent2D):
	if nav_agent:
		navigation_agent = nav_agent
		nav_timer = 0
#endregion

