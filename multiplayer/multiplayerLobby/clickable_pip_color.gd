extends ClickablePip
class_name ClickablePipColor
#Authored by Ethan. Please consult for any modifications or major feature requests.

@export var color : Panel

#region Godot methods
func _ready():
	super._ready()
	
	if is_unlocked:
		gui_input_pass_self.connect(lobby_select._on_color_pip_gui_input)
#endregion

func locked_and_selected():
	self_modulate = Color.WHITE
	color.self_modulate = Color.BLACK

func locked():
	self_modulate = Color.BLACK
	color.self_modulate = Color.BLACK
