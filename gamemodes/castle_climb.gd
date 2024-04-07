extends Node

@onready var level_spawner = $LevelSpawner

@export var start_on_spawn : bool = false
@export var player_data : Array[PlayerData]

@export var basic_rooms: Array[PackedScene]

var number_of_players = 3
var seed : int = 6969
var current_floor : int = -1

var current_room_node : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if start_on_spawn:
		start_climb()

func _process(delta):
	if MultiplayerInput.is_action_just_pressed(-1, "debug_next_floor"):
		start_next_floor()

func start_climb():
	var i = 0
	for child in $GameUI/PlayerUIContainer.get_children():
		if i >= number_of_players:
			child.hide()
		i += 1
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
	level_spawner.spawn_function = spawn_basic_level
	level_spawner.spawn(randi_range(0, basic_rooms.size() - 1))
	
	await get_tree().create_timer(0.2).timeout
	current_room_node.spawn_players(number_of_players)

func spawn_basic_level(index: int) -> Node:
	current_room_node = basic_rooms[index].instantiate() as CastleRoom
	current_room_node.player_data = player_data
	return current_room_node

@rpc("authority", "call_local", "reliable")
func play_room_transition(last_floor: int, next_floor: int):
	$GameUI/FloorLabel.text = str(current_floor) + "F"
	$RoomTransitionUI/Items/VBoxContainer/NextFloorLabel.text = str(current_floor) + "F"
	$RoomTransitionUI/Items/VBoxContainer/LastFloorLabel.text = str(current_floor - 1) + "F"
	$RoomTransitionUI/AnimationPlayer.play("next_floor")
	var tween = create_tween()
	tween.tween_property($RoomTransitionUI/Items, "modulate:a", 1, 0.25)
	tween.tween_interval(2)
	tween.tween_property($RoomTransitionUI/Items, "modulate:a", 0, 0.25)
