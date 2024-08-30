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
	#player.max_health += health_increase
	player.set_health(player.health + health_increase)
	player.data.max_health += health_increase
	player.entity_damage_multiplier += damage_buff

func _exit_tree():
	if is_instance_valid(player.data.max_health):
		player.data.max_health -= health_increase
		player.set_health(player.health - health_increase)
		player.entity_damage_multiplier -= damage_buff
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
