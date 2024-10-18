extends Control

func _ready():
	pass


func _input(e):
	if e is InputEventKey or e is InputEventJoypadButton:
		get_tree().change_scene_to_file("res://menus/main_menu.tscn")
