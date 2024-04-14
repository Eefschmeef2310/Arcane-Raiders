extends Node
class_name StateMachine
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
#Signals

#Enums

#Constants

#Exported Variables
#@export_group("Group")
#@export_subgroup("Subgroup")
@export var initial_state : State
#Onready Variables

#Other Variables (please try to separate and organise!)
var current_state: State
var states : Dictionary = {}
#endregion

#region Godot methods
func _ready():
	pass

func _process(delta):
	if current_state:
		current_state.update(delta)
	
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)
#endregion

#region Signal methods

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.exit()
		
	new_state.enter()
	
	current_state = new_state
#endregion

#region Other methods (please try to separate and organise!)
func start_state_machine(nav_agent: NavigationAgent2D):
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			child.set_nav_agent(nav_agent)

	if(initial_state):
		initial_state.enter()
		current_state = initial_state
		
func update_position():
	current_state.set_position()
#endregion
