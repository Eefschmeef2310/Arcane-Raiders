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
var size : float = 1

#endregion

#region Godot methods
func _ready():
	scale *= size
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(self.queue_free)
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
