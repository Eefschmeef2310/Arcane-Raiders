extends Entity
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
	#Runs when all children have entered the tree
	pass


#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func _on_hurtbox_body_entered(body):
	on_hurt(body as Spell)
#endregion
