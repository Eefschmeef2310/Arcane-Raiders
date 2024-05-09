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
@export var spells : Array[Spell] = [null] #Just the spell resource
@export var cast_time: Array[float] = [0.2, 0.2, 0.2] #Change cast_time to add startup frames before an attack
@export var spell_cooldowns : Array[float] = [1, 1, 1] #Change spell_cooldowns if you want a spell to START OFF on cooldown
@export var spell_is_child: Array[bool] = [false, false, false] #Adds the spell as child or sibling of enemy


	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods

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

