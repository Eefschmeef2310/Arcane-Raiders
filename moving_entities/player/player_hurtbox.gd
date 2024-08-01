extends Area2D
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
@onready var player = $".."

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
#endregion

#region Signal methods
func _on_body_entered(body):
	player.on_hurt(body)

func _on_area_entered(area):
	player.on_hurt(area as Node2D)
#endregion

#region Other methods (please try to separate and organise!)

#endregion


