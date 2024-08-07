extends Node
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		var array = get_all_children(get_tree().root)
		for child in array:
			if child is CastleRoom:
				print(child)
				child.add_child(load("res://screens/win_screen.tscn").instantiate())
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_G:
		var array = get_all_children(get_tree().root)
		for child in array:
			if child is CastleRoom:
				print(child)
				child.add_child(load("res://screens/game_over_screen.tscn").instantiate())
#endregion

#region Signal methods 
func get_all_children(in_node, array := []):
	array.push_back(in_node)
	for child in in_node.get_children():
		array = get_all_children(child, array)
	return array
#endregion

#region Other methods (please try to separate and organise!)

#endregion
