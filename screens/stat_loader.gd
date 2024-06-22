extends PanelContainer
class_name FinalStat
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var stat_title : Label

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func load_data(packedData : Array):
	#personal stat, only relevant in online
	#if GameManager.isOnline():
	$Stat/Stat1.text += str(packedData[0])
	
	#best player stat
	$Stat/HBoxContainer/Control/Head.texture = packedData[1].character.head_texture
	$Stat/HBoxContainer/Control/Head/Panel.self_modulate = packedData[1].main_color
	$Stat/HBoxContainer/Label.text += str(packedData[2])
#endregion
