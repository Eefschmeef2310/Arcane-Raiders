extends GPUParticles2D
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
	if get_parent().resource.element:
		texture = get_parent().resource.element.pip_texture
		modulate = get_parent().resource.element.colour
		
func _process(_delta):
	for particle in get_children():
		pass
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
