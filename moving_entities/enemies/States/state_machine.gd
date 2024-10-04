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
@export var debug_label : Label
#Onready Variables

#Other Variables (please try to separate and organise!)
var current_state: State
var states : Dictionary = {}
#endregion

#region Godot methods

func _process(delta):
	if current_state:
		current_state.update(delta)
	
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)
#endregion

#region Signal methods

func on_child_transition(state, new_state_name):
	if is_multiplayer_authority():
		transition_state.rpc(get_path_to(state), new_state_name)

@rpc("authority", "call_local", "reliable")
func transition_state(relative_state_path, new_state_name):
	if has_node(relative_state_path):
		var state = get_node(relative_state_path)
		if state != current_state:
			return
		var new_state = states.get(new_state_name.to_lower())
		if !new_state:
			return
			
		if current_state:
			current_state.exit()
			
		if "previous_state" in new_state:
			new_state.previous_state = current_state.name.to_lower()
			
		current_state = new_state
		
		current_state.enter()
		
		if debug_label:
			debug_label.text = current_state.name
	else:
		print("fk")
#endregion

#region Other methods (please try to separate and organise!)
func start_state_machine(nav_agent: NavigationAgent2D):
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			if !child.Transitioned.is_connected(on_child_transition): child.Transitioned.connect(on_child_transition)
			child.set_nav_agent(nav_agent)

	if(initial_state):
		initial_state.enter()
		current_state = initial_state
		
#func update_position():
	#current_state.set_position()
#endregion

