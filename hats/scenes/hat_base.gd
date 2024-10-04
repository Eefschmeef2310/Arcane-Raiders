extends Node
class_name Hat
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var sprite : Texture
@export var manager_key : StringName

	#Onready Variables
@onready var player : Player = get_parent()

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	player.crown.texture = sprite
	player.data.hat_string = manager_key
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
