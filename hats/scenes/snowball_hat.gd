extends Hat
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
	super._ready()
	player.killed_entity.connect(increase_damage)
	
#endregion

#region Signal methods
func increase_damage():
	print("damage increase")
#endregion

#region Other methods (please try to separate and organise!)

#endregion
