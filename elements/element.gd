extends Resource
class_name ElementResource
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
@export_group("Element Parameters")

@export var prefix : String
@export_multiline var descrption_bb : String
@export var colour : Color
@export var gradient : GradientTexture1D
@export var gradient_inverse : GradientTexture1D
@export var pip_texture : Texture2D
@export var max_infliction_time : float = 5
@export var sound : AudioStream

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion
