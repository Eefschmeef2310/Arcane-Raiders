extends Control
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
@onready var element_1 = $AnimationContainer/VBoxContainer/ReactionElementsUI/Element1
@onready var plus_icon = $AnimationContainer/VBoxContainer/ReactionElementsUI/PlusIcon
@onready var element_2 = $AnimationContainer/VBoxContainer/ReactionElementsUI/Element2
@onready var reaction_name = $AnimationContainer/VBoxContainer/ReactionName

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func set_panel_color(col: Color):
	var new_panel = ($AnimationContainer/Panel as Panel).get_theme_stylebox("panel").duplicate()
	col.a = 0.85
	new_panel.set("bg_color", col)
	$AnimationContainer/Panel.add_theme_stylebox_override("panel", new_panel)
#endregion
