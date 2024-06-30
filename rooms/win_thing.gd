extends Area2D
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Signal methods
func _on_body_entered(_body):
	var win_screen = load("res://screens/win_screen.tscn").instantiate()
	win_screen.game = get_parent()
	call_deferred("add_sibling", win_screen)
#endregion
