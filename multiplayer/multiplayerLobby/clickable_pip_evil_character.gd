extends ClickablePipCharacter
class_name ClickablePipEvilCharacter
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Exported Variables
@export var character_key : StringName
#endregion

#region Godot methods
func _ready():
	#gui_input.connect(_on_gui_input)
	
	is_unlocked = lobby_select and SaveManager.characters_completed.has(character_key)
	print(SaveManager.characters_completed.has(character_key))
	
	super()
#endregion
