extends SpellBase
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

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
	if(caster):global_position = caster.global_position
	await get_tree().create_timer(end_time).timeout
	queue_free()
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion

