extends ProgressBar
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
	max_value = owner.max_health
	_on_dummy_enemy_health_updated(owner.health)
#endregion

#region Signal methods
func _on_dummy_enemy_health_updated(amount):
	value = amount
#endregion

#region Other methods (please try to separate and organise!)

#endregion
