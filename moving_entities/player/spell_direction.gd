extends Node2D
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
	#Runs when all children have entered the tree
	pass

func _process(_delta):
	$Sprite2D.look_at($Sprite2D.global_position + owner.aim_direction)
	$Sprite2DShadow.look_at($Sprite2DShadow.global_position + owner.aim_direction)
	$Sprite2DProjection.look_at($Sprite2DProjection.global_position + owner.aim_direction)
#endregion

#region Signal methods
 
#endregion

#region Other methods (please try to separate and organise!)

#endregion
