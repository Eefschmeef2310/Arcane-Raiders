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
	
	if lobby_select and SaveManager.characters_completed.has(character_key) and SaveManager.area_3_complete:
		is_unlocked = true
	
	if lobby_select:
		gui_input_pass_self.connect(lobby_select._on_raider_pip_gui_input)
#endregion
