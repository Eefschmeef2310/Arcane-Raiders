extends ProgressBar
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	#self_modulate = owner.data.main_color
	pass
#endregion

#region Signal methods
func _on_value_changed(_value):
	visible = value > 0
#endregion

#region Other methods (please try to separate and organise!)

#endregion



