extends ClickablePip
class_name ClickablePipCharacter
#Authored by Ethan. Please consult for any modifications or major feature requests.

@export var head : TextureRect

#region Godot methods
func _ready():
	super._ready()
	
	if lobby_select:
		gui_input_pass_self.connect(lobby_select._on_raider_pip_gui_input)
	
	if !is_unlocked:
		locked()
#endregion

func locked_and_selected():
	self_modulate = Color.WHITE
	head.self_modulate = Color.BLACK

func locked():
	self_modulate = Color.BLACK
	head.self_modulate = Color.BLACK
