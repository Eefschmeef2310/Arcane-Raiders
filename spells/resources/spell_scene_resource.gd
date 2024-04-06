extends Resource
class_name SpellSceneResource
#Authored by Ethan. Please consult for any modifications or major feature requests.
#THIS RESOURCE STORES UI INFO AND THE SCENE TO INSTANTIATE. LIKE ELEMENTS, THESE WILL BE STORED IN THE FILES

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var scene_to_instantiate : PackedScene
@export var ui_texture : Texture2D

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass

func _process(_delta):
	#Runs per frame
	pass
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
