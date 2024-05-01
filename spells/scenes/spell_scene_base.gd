extends Node2D
class_name SpellBase
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
@export_group("Spell Scene")
# Damage the spell deals.
@export var base_damage : int = 50

#How long the entity will be affected for
@export var infliction_time : float = 1

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
var caster : Entity #This is also set in code

#endregion

func _enter_tree():
	AudioManager.play_audio2D_at_point(global_position, resource.element.sound)

func transfer_data(new: Node2D):
	if "base_damage" in new:
		new.base_damage = base_damage
	if "resource" in new:
		new.resource = resource
	if "caster" in new:
		new.caster = caster
	if "infliction_time" in new:
		new.infliction_time = infliction_time
