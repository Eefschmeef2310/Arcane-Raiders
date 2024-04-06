extends Resource
class_name Spell
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Exported Variables
@export var spell_scene : SpellSceneResource
@export var element : ElementResource
@export var modulate_icon : bool = true
#endregion

#region Godot Methods	
#NOTE: looks weird, but default values MUST be used in a constructor. they're all overwritten immediately, so don't worry about it - E
func _init(element_to_use = preload("res://elements/null.tres"), scene_to_use = preload("res://spells/resources/null.tres"), modulate = true):
	element = element_to_use
	spell_scene = scene_to_use
	modulate_icon = modulate
#endregion
