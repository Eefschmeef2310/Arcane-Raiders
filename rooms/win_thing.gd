extends Area2D
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Signal methods
func _on_body_entered(body):
	var win_screen = load("res://screens/win.tscn").instantiate()
	win_screen.game = get_parent()
	get_tree().root.call_deferred("add_child", win_screen)
#endregion
