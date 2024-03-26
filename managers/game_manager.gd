extends Node
# authored by Xander

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()
