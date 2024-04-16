extends Node
class_name State
#Authored by AlexV. Please consult for any modifications or major feature requests.
signal Transitioned

@export_group("Navigation Timer")
@export var nav_timer_interval: float = 0.5
@export var nav_timer = 0

@onready var enemy = $"../.."

var navigation_agent: NavigationAgent2D
#region Other methods
func enter():
	pass
	
func exit():
	pass
	
func update(delta):
	pass

#TODO MAKE SURE TO CALL THE SUPER WHEN MAKING A NEW STATE
func physics_update(delta):
	nav_timer -= delta
	if nav_timer <= 0:
		set_position()
		nav_timer = nav_timer_interval
	
func set_position():
	pass
	
func get_closest_player() -> CharacterBody2D:
	var p_arr = get_tree().get_nodes_in_group("player")
	var target
	var dist = INF
	for p in p_arr:
		if p is Player and enemy.global_position.distance_to(p.global_position) < dist:
			target = p
			dist = enemy.global_position.distance_to(p.global_position)
			
	if target: return target
	return null
	
	
func set_nav_agent(nav_agent: NavigationAgent2D):
	navigation_agent = nav_agent
	nav_timer = 0
#endregion

