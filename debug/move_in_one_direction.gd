extends Node
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var direction : Vector2

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass

func _process(_delta):
	get_parent().velocity = direction
	get_parent().move_and_slide()
	
func _input(event):
	if event is InputEventKey && event.pressed && event.keycode == KEY_T:
		direction *= -1
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
