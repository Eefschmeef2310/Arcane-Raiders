extends Control

@export var close_button : Button
@export var local_play_button : Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	local_play_button.grab_focus()
	hide()


func _on_rich_text_label_meta_clicked(meta):
	OS.shell_open(meta);
