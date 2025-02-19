extends Node
#Authored by Ethan. Please consult for any modifications or major feature requests.

#NOTE - ATTACH THIS SCRIPT TO A NODE AS A CHILD OF A CASTLE ROOM

#region Godot methods
func _ready():
	if !OS.has_feature("editor"):
		queue_free()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_H:
		get_parent().add_child(load("res://screens/win_screen.tscn").instantiate())
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_G:
		get_parent().add_child(load("res://screens/game_over_screen.tscn").instantiate())
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_J:
		if owner is CastleRoomLobby:
			owner.request_lobby_restart()
#endregion
