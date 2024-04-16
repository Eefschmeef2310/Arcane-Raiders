extends Node2D
class_name CastleRoom
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var wave_size : Array[int] = [15]

@onready var dynamic_camera: DynamicCamera = $DynamicCamera
@onready var player_spawns = [$PlayerSpawn0, $PlayerSpawn1, $PlayerSpawn2, $PlayerSpawn3]
@onready var player_spawner = $PlayerSpawner
@onready var PLAYER_SCENE = preload("res://moving_entities/player/player.tscn")

var player_data

func _ready():
	player_spawner.spawn_function = spawn_player

# Runs only on the server
func spawn_players(number_of_players: int):
	for i in number_of_players:
		if i < player_data.size():
			player_spawner.spawn(i)

# Runs on all peers
func spawn_player(player_number: int) -> Node:
	var player: Player = PLAYER_SCENE.instantiate()
	player.set_data(player_data[player_number])
	player.global_position = player_spawns[player_number].global_position
	dynamic_camera.add_target(player)
	print("Spawned player of peer_id " + str(player.data.peer_id))
	return player
