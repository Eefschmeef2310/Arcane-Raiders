extends ClickablePip
class_name ClickablePipBody
#Authored by Ethan. Please consult for any modifications or major feature requests.

@export var sprite : TextureRect

#region Godot methods
func _ready():
	super._ready()
	
	if lobby_select:
		gui_input_pass_self.connect(lobby_select._on_body_pip_gui_input)
#endregion
