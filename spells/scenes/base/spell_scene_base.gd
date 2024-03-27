extends Node
class_name SpellScene
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
@export_group("Spell Scene")
@export var base_damage : int = 10

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var resource : Spell #This is set in code

#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass

func _process(_delta):
	#Runs per frame
	pass
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
