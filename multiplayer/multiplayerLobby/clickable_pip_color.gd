extends ClickablePip
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Godot methods
func _ready():
	super._ready()
	
	if is_unlocked:
		gui_input_pass_self.connect(lobby_select._on_color_pip_gui_input)
#endregion
