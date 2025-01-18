extends PanelContainer
class_name ClickablePip

signal gui_input_pass_self(event, node)

@export var lobby_select : JoinSelectUI
@export var achievements_required : int = 0

var is_unlocked : bool = false

func _ready():
	#gui_input.connect(_on_gui_input)
	
	if lobby_select and SteamManager.unlocked_achievements >= achievements_required:
		is_unlocked = true
	
	#if !is_unlocked:
		#mouse_default_cursor_shape = Control.CURSOR_ARROW

func _on_gui_input(event):
	gui_input_pass_self.emit(event, self)
	
