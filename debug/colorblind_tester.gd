extends CanvasLayer

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		visible = !visible
