extends Node
class_name SpellBase
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
@export_group("Spell Scene")
# Damage the spell deals.
@export var base_damage : int = 10

# The time the player's startup animation plays for.
@export var start_time : float = 0.2

# The time the player's end animation plays for (before returning to idle).
@export var end_time : float = 0.5

# The time before the player can cast another spell.
@export var cancel_time : float = 0.3

# The time before this spell can be cast again.
@export var cooldown_time : float = 3.0

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var resource : Spell #This is set in code
var caster : Player #This is also set in code

#endregion

func transfer_data(new: Node2D):
	if "base_damage" in new:
		new.base_damage = base_damage
	if "resource" in new:
		new.resource = resource
	if "caster" in new:
		new.caster = caster
