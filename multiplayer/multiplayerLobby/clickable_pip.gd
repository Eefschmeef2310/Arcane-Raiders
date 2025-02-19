extends PanelContainer
class_name ClickablePip

signal gui_input_pass_self(event, node)

@export var lobby_select : JoinSelectUI
@export var achievements_required : int = 0
@export var unlock_with_achivements : bool = true

var is_unlocked : bool = false

func _ready():
	is_unlocked = lobby_select and SteamManager.unlocked_achievements >= achievements_required

func _on_gui_input(event):
	gui_input_pass_self.emit(event, self)
