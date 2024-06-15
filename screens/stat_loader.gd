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

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func load_data(data : PlayerData, value : int):
	$Stat/Head.texture = data.character.head_texture
	$Stat/Head/Panel.self_modulate = data.main_color
	$Stat/MarginContainer/Number.text = str(value)
#endregion
