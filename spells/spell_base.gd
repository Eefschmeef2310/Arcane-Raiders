extends Resource
class_name Spell
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Exported Variables
@export var spell_scene : Resource
@export var element : ElementResource
@export var ui_texture : Texture2D
@export var modulate_icon : bool = true

@export var name : String
@export var infliction_time: float = 3
#endregion
