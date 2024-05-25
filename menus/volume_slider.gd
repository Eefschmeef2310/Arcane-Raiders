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

func _process(delta):
	pass
	#if editable:
		#for device in GameManager.devices:
			#var scroll_dir = MultiplayerInput.get_axis(device, "lobby_up", "lobby_down")
			#value += scroll_dir * delta

func _input(event):
	if has_focus():
		if event.is_action_pressed("ui_accept"):
			if editable:
				#unfocus()
				pass
			else:
				editable = true
				for child in get_tree().get_nodes_in_group("settings_navigable"):
					if child is Control and child != self:
						child.focus_mode = Control.FOCUS_NONE
				
		elif event.is_action_pressed("ui_cancel"): #this acutally closes the menu lol
			unfocus()
		
#endregion

#region Signal methods
func _on_value_changed(_value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
	PlayerPreferenceManager.player_preferences.bus_volumes[bus_index] = linear_to_db(value)
#endregion

func unfocus():
	editable = false
	for child in get_tree().get_nodes_in_group("settings_navigable"):
		if child is Control and child != self:
			child.focus_mode = Control.FOCUS_ALL
