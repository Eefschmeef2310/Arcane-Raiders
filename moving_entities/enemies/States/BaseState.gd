extends Node
class_name State
#Authored by AlexV. Please consult for any modifications or major feature requests.
signal Transitioned

@export var nav_timer_interval: float = 0.5
var nav_timer = 0

var navigation_agent: NavigationAgent2D
#region Other methods
func enter():
	pass
	
func exit():
	pass
	
func update(delta):
	pass

func physics_update(delta):
	nav_timer -= delta
	if nav_timer <= 0:
		set_position()
		nav_timer = nav_timer_interval
	
func set_position():
	pass
	
func set_nav_agent(nav_agent: NavigationAgent2D):
	navigation_agent = nav_agent
	nav_timer = 0
#endregion

