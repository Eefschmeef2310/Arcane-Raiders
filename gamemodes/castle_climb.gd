extends Node
class_name CastleClimb

@onready var basic_level_spawner = $BasicLevelSpawner

@export var start_on_spawn : bool = false
@export var player_data : Array[PlayerData]
@export var player_ui : Array[PlayerUI]

@export var basic_rooms: Array[PackedScene]

var number_of_players = 0
var rng_floors: RandomNumberGenerator = RandomNumberGenerator.new()
var current_floor : int = -1

var current_room_node : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	basic_level_spawner.spawn_function = spawn_basic_level
	
	if start_on_spawn:
		set_number_of_players(1)
		start_climb()

func _process(delta):
	if MultiplayerInput.is_action_just_pressed(-1, "debug_next_floor"):
		start_next_floor()

func start_climb():
	# Do any server-sided stuff here
	if number_of_players <= 0:
		number_of_players = 1
	start_next_floor()

func start_next_floor():
	# Increase floor count
	current_floor += 1
	print("Current floor: " + str(current_floor))
	
	play_room_transition.rpc(current_floor-1, current_floor)
	
	await get_tree().create_timer(1).timeout
	
	if current_room_node != null:
		print("Freeing old room.")
		current_room_node.queue_free()
	
	await get_tree().create_timer(0.8).timeout
	
	# Spawn new room
	print("Creating new room.")
	basic_level_spawner.spawn(rng_floors.randi_range(0, basic_rooms.size() - 1))
	
	await get_tree().create_timer(0.2).timeout
	current_room_node.spawn_players(number_of_players)

func spawn_basic_level(index: int) -> Node:
	current_room_node = basic_rooms[index].instantiate() as CastleRoom
	current_room_node.player_data = player_data
	return current_room_node

@rpc("authority", "call_local", "reliable")
func play_room_transition(last_floor: int, next_floor: int):
	$RoomTransitionUI/Items/VBoxContainer/NextFloorLabel.text = get_floor_name(current_floor)
	$RoomTransitionUI/Items/VBoxContainer/LastFloorLabel.text = get_floor_name(current_floor-1)
	$RoomTransitionUI/AnimationPlayer.play("next_floor")
	var tween = create_tween()
	tween.tween_property($RoomTransitionUI/Items, "modulate:a", 1, 0.25)
	tween.tween_interval(2)
	tween.tween_property($RoomTransitionUI/Items, "modulate:a", 0, 0.25)
	
	await get_tree().create_timer(0.5).timeout
	$RunUI/FloorLabel.text = get_floor_name(current_floor)

func set_number_of_players(n: int):
	number_of_players = n
	var i = 0
	for child in $GameUI/PlayerUIContainer.get_children():
		if i >= number_of_players:
			child.hide()
		else:
			child.show()
		i += 1

func get_floor_name(floor: int) -> String:
	if floor < 0:
		return ""
	elif floor == 0:
		return "Foyer"
	else:
		return str(floor) + "F"

@rpc("authority", "call_local", "reliable")
func setup_from_parent_multiplayer_lobby():
	var arr = get_parent().get_card_data()
	var i = 0
	for dict in arr:
		set_player_data(i, dict["device_id"], dict["peer_id"], dict["spells"], dict["raider"])
		i += 1

func set_player_data(slot: int, device_id: int, peer_id: int, spells: Array[String], character: RaiderRes):
	var data = player_data[slot]
	data.device_id = device_id
	data.peer_id = peer_id
	data.set_multiplayer_authority(peer_id)
	
	for i in 3:
		if spells[i] != "":
			data.set_spell_from_string(i, spells[i])
	
	data.character = character
	
	if number_of_players < slot + 1:
		number_of_players = slot + 1
	
	$GameUI/PlayerUIContainer.get_child(slot).show()
