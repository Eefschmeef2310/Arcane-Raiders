extends Node
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var anim_player : AnimationPlayer

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	SteamManager.damageless_updated.connect(func(boolean): anim_player.play("destroy" if !boolean else "RESET"))
#endregion

#region Signal methods
#endregion

#region Other methods (please try to separate and organise!)

#endregion
