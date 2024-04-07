extends Node

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
	
	# Setup room transition
	$RoomTransitionUI/Items/VBoxContainer/NextFloorLabel.text = str(current_floor) + "F"
	$RoomTransitionUI/Items/VBoxContainer/LastFloorLabel.text = str(current_floor - 1) + "F"
	$RoomTransitionUI/AnimationPlayer.play("next_floor")
	var tween = create_tween()
	tween.tween_property($RoomTransitionUI/Items, "modulate:a", 1, 0.25)
	tween.tween_interval(2)
	tween.tween_property($RoomTransitionUI/Items, "modulate:a", 0, 0.25)
	
	await get_tree().create_timer(1).timeout
	if current_room_node != null:
		print("Freeing old room.")
		current_room_node.queue_free()
	
	await get_tree().create_timer(1).timeout
	
	$GameUI/FloorLabel.text = str(current_floor) + "F"
	
	# Spawn new room
	print("Creating new room.")
	var next_scene = basic_rooms.pick_random()
	current_room_node = next_scene.instantiate() as CastleRoom
	add_child(current_room_node)
	current_room_node.spawn_players(player_data, 1)
