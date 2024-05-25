extends Button
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.
#Used be all submenu buttons to hide and show the appropriate settings

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var showing_container : Control
@export var focused_button : bool = false

	#Onready Variables
@onready var margin_container = $"../../../Contents/MarginContainer"

	#Other Variables (please try to separate and organise!)

#endregion

func _ready():
	if focused_button:
		grab_focus()

#region Signal methods
func on_button_down():
	for child in margin_container.get_children():
		child.visible = false
	
	showing_container.visible = true
#endregion

#region Other methods (please try to separate and organise!)

#endregion
