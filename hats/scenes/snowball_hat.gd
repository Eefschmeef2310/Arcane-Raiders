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
@export var bonus := 0.1

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var total_bonus : float

#endregion

#region Godot methods
func _ready():
	super._ready()
	player.data.call_deferred("emit_signal", "hat_label_changed", str(total_bonus*100) + "% bonus damage!") 
	player.killed_entity.connect(increase_damage)
	player.taken_damage.connect(damage_taken)
	
func _exit_tree():
	player.entity_damage_multiplier -= total_bonus
	total_bonus = 0.0
#endregion

#region Signal methods
func increase_damage(entity : Entity):
	if !entity.ignoreForStats:
		player.data.hat_label_changed.emit(str(total_bonus*100) + "% bonus damage!")
		player.entity_damage_multiplier += bonus
		total_bonus += bonus
	
func damage_taken():
	player.data.hat_label_changed.emit(str(total_bonus*100) + "% bonus damage!")
	player.entity_damage_multiplier -= total_bonus
	total_bonus = 0.0
#endregion

#region Other methods (please try to separate and organise!)

#endregion
