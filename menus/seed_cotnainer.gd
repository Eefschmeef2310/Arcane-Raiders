extends HBoxContainer
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var seed_label : Label
@export var button : Button

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	if owner.get_parent().get_parent() is CastleClimb and (owner.get_parent().get_parent() as CastleClimb).seed_text != "":
		seed_label.text = "Seed: " + (owner.get_parent().get_parent() as CastleClimb).seed_text
	elif owner.get_parent() is CastleClimb and (owner.get_parent() as CastleClimb).seed_text != "":
		seed_label.text = "Seed: " + (owner.get_parent() as CastleClimb).seed_text
	else:
		visible = false
		button.visible = false
	
	
#endregion

#region Signal methods
func _on_copy_seed_pressed():
	DisplayServer.clipboard_set((owner.get_parent().get_parent() as CastleClimb).seed_text)
#endregion

#region Other methods (please try to separate and organise!)

#endregion
