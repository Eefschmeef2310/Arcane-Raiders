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
@export var head_sprite : TextureRect
@export var hat_sprite : TextureRect
@export var head_panel : Panel
@export var label : Label
	
@export var stat_title : Label
var captured_player : Color

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Other methods (please try to separate and organise!)
func load_data(packedData : Array):
	#personal stat, only relevant in online
	#if GameManager.isOnline():
	$Stat/Stat1.text += str(packedData[0])
	
	#best player stat
	head_sprite.texture = packedData[1].character.head_texture
	hat_sprite.texture = packedData[3]
	head_panel.self_modulate = packedData[1].main_color
	label.text += str(packedData[2])
	captured_player = packedData[1].main_color
#endregion

#returns the playerData of the player hwo is winning for this stat
func top_player() -> Color:
	return captured_player
