extends Resource
class_name ElementResource
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums
enum ElementType {
	Fire,
	Frost,
	Shock
}

	#Constants

	#Exported Variables
@export_group("Element Parameters")

@export var colour : Color
@export var particle_texture : Texture2D
@export var pip_texture : Texture2D #May be deleted later - E
@export var element_type : ElementType
@export var max_infliction_time : float = 5

	#Onready Variables

	#Other Variables (please try to separate and organise!)

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
func effect(object):
	match element_type:
		ElementType.Fire:
			print("now run fire effect")
		ElementType.Frost:
			frost_effect(object)

func frost_effect(object):
	object.velocity *= 0.5
#endregion
