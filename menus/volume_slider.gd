extends HSlider
#Authored by Ethan. Please consult for any modifications or major feature requests.
#this also makes it so the slider cannot be edited until pressing the accept button

#region Variables
	#Exported Variables
@export var bus_name : String

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var bus_index : int

#endregion

#region Godot methods
func _ready():
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	
func _input(event):
	if has_focus():
		if event.is_action_pressed("ui_accept"):
			print(find_valid_focus_neighbor(SIDE_LEFT))
			#owner.get_node(focus_neighbor_left).focus_mode = Control.FOCUS_NONE
		elif event.is_action_pressed("ui_cancel"):
			focus_mode = Control.FOCUS_ALL
		
#endregion

#region Signal methods
func _on_value_changed(_value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
	PlayerPreferenceManager.player_preferences.bus_volumes[bus_index] = linear_to_db(value)
#endregion
