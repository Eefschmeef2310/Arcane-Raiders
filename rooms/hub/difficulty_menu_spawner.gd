extends Area2D
#Authored by Ethan

const DIFFICULTY_MENU = preload("res://menus/difficulty_menu.tscn")

@export var interact_label : Label
@export var current_difficulty : RichTextLabel
@export var container : Node2D

@onready var init_pos = $"../Shadow".scale

var base_y = 0
var t = 0
var amp = 10
var freq = 2

var player_in_bounds := false:
	set(value):
		player_in_bounds = value
		if player_in_bounds:
			interact_label.show()
		else:
			interact_label.hide()

func _ready():
	(container.get_parent() as CastleRoomLobby).chosen_difficulty = SaveManager.most_recent_difficulty
	update_current_label()
	
	base_y = global_position.y

func _physics_process(delta):
	t += delta
	if t >= 360:
		t -= 360
	global_position.y = base_y + (sin(t * freq) * amp)
	
	var test = 1 + sin(t*2)*0.25
	$"../Shadow".scale = Vector2(init_pos.x*test, init_pos.y*test)

func on_interact(player: Player):
	if player.data.peer_id == 1:
		var menu = DIFFICULTY_MENU.instantiate()
		menu.difficulty_set.connect(update_current_label)
		menu.device_id = player.data.device_id
		add_sibling(menu)
		player.input_preventing_node = menu
		menu.custom_seed_entry.text = owner.custom_seed
	else:
		owner.create_notification("Only the host can change the difficulty.")

				
func _on_area_entered(area):
	if area.owner is Player:
		player_in_bounds = true

func _on_area_exited(area):
	player_in_bounds = get_overlapping_areas().size() > 0

func update_current_label():
	current_difficulty.text = "[font_size=32][center][outline_size=12]Current Difficulty: "
	match (container.get_parent() as CastleRoomLobby).chosen_difficulty:
		0:
			current_difficulty.text += "[color=green]Easy"
		1:
			current_difficulty.text += "[color=yellow]Medium"
		2:
			current_difficulty.text += "[color=red]Hard"
		3:
			current_difficulty.text += "[color=purple]Extreme"
	
	#Update save
	SaveManager.most_recent_difficulty = (container.get_parent() as CastleRoomLobby).chosen_difficulty
	SaveManager.request_save()
