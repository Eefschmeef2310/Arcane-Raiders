extends Hat
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var dash_window : Timer

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var allowed_dashes : int = 2

#endregion

#region Godot methods
func _ready():
	player.dash_signal.connect(dash_input)
	#player.dash_cooldown_complete.connect(dash_cooldown_complete)
#endregion

#region Signal methods
func dash_input():
	allowed_dashes -= 1
	#print(dash_window.time_left > 0)
	if allowed_dashes > 0 and dash_window.time_left > 0:
		player.dash_cooldown = 0
		#player.attempt_dash()
		#print(player.dash_cooldown)
		dash_window.start()
	else:
		dash_window.start()
		
func dash_cooldown_complete():
	allowed_dashes = 2
#endregion

#region Other methods (please try to separate and organise!)

#endregion
