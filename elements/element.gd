extends Resource
class_name ElementResource
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
@export_group("Element Parameters")

@export var colour : Color
@export var particle_texture : Texture2D
@export var pip_texture : Texture2D #May be deleted later - E
@export var max_infliction_time : float = 5
#@export var reactive_with : Array[ElementResource]

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#func reaction_occurred(key):
	#return reactive_with.has(key)
