extends Node
# authored by Xander

func _process(_delta):
	if MultiplayerInput.is_action_just_pressed(-1, "pause") && OS.get_name() != "Web":
		get_tree().quit()
