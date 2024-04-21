extends Control

@export var menu_scene : PackedScene =  preload("res://menus/main_menu.tscn")

var clock : float
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	clock += delta
	if clock > 0.1:
		clock = -10
		get_tree().change_scene_to_packed(menu_scene)
	pass
