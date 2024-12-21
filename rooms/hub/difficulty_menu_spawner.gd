extends Area2D
#Authored by Ethan

const DIFFICULTY_MENU = preload("res://menus/difficulty_menu.tscn")

@export var interact_label : Label
@export var current_difficulty : RichTextLabel

var player_in_bounds := false:
	set(value):
		player_in_bounds = value
		if player_in_bounds:
			interact_label.show()
		else:
			interact_label.hide()

func _ready():
	update_current_label()

func _input(event):
	if interact_label.visible and event.is_action_pressed("interact"):
		var menu = DIFFICULTY_MENU.instantiate()
		menu.difficulty_set.connect(update_current_label)
		add_sibling(menu)
		

func _on_area_entered(area):
	if area.owner is Player:
		player_in_bounds = true

func _on_area_exited(area):
	player_in_bounds = get_overlapping_areas().size() > 0

func update_current_label():
	current_difficulty.text = "[center]Current Difficulty: "
	match (get_parent() as CastleRoomLobby).chosen_difficulty:
		0:
			current_difficulty.text += "[color=green]Easy"
		1:
			current_difficulty.text += "[color=yellow]Medium"
		2:
			current_difficulty.text += "[color=red]Hard"
		3:
			current_difficulty.text += "[color=purple]Extreme"
