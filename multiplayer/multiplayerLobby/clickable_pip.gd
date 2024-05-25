extends PanelContainer
class_name ClickablePip

signal gui_input_pass_self(event, node)

func _ready():
	gui_input.connect(_on_gui_input)

func _on_gui_input(event):
	gui_input_pass_self.emit(event, self);
