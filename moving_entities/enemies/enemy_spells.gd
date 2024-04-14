extends Node
class_name EnemySpells

# Called every frame. 'delta' is the elapsed time since the previous frame.

#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var spells : Array[Spell] = [null]
@export var spell_cooldowns : Array[float] = [0]
	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():	
	spell_cooldowns.resize(spells.size())
	spell_cooldowns.fill(0)


func _process(delta):
	for i in spell_cooldowns.size():
		if spell_cooldowns[i] > 0:
			spell_cooldowns[i] -= delta
			if spell_cooldowns[i] < 0:
				spell_cooldowns[i] = 0
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func start_cooldown(slot: int, time: float):
	spell_cooldowns[slot] = time
#endregion

