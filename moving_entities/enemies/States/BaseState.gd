extends Node
class_name State
#Authored by AlexV. Please consult for any modifications or major feature requests.
signal Transitioned

var navigation_agent: NavigationAgent2D
#region Other methods
func enter():
	pass
	
func exit():
	pass
	
func update(delta):
	pass

func physics_update(delta):
	pass
	
func set_position():
	pass
	
func set_nav_agent(nav_agent: NavigationAgent2D):
	navigation_agent = nav_agent
	print("set nav agent")
#endregion

