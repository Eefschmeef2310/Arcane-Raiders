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
@export var health_increase : int = -250
@export var damage_buff : float = 1.0

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	super._ready()
	player.movement_speed *= 0.75
	player.entity_damage_multiplier *= 1.5 
	player.data.hat_label_changed.emit("-25% movement, +50% damage")

func _exit_tree():
	player.movement_speed /= 0.75
	player.entity_damage_multiplier /= 1.5
#endregion

#region Signal methods
#endregion

#region Other methods (please try to separate and organise!)

#endregion
