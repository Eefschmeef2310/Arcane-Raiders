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
	player.data.hat_label_changed.emit("Defeat enemies to heal!")
	player.killed_entity.connect(attack_made)
#endregion

#region Signal methods
func attack_made(entity : Entity):
	if !entity.ignoreForStats:
		player.heal_damage(10)
#endregion

#region Other methods (please try to separate and organise!)

#endregion
