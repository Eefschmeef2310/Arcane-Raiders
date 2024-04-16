extends Node2D
class_name CastleRoom
#Authored by Xander. Please consult for any modifications or major feature requests.

signal room_exited

@export var wave_total_difficulty : Array[int]

@onready var dynamic_camera: DynamicCamera = $DynamicCamera
@onready var player_spawns = [$PlayerSpawn0, $PlayerSpawn1, $PlayerSpawn2, $PlayerSpawn3]
@onready var player_spawner = $PlayerSpawner
@onready var PLAYER_SCENE = preload("res://moving_entities/player/player.tscn")
@onready var enemy_spawns = $EnemySpawns
@onready var enemy_spawner = $EnemySpawner

var player_data
var current_wave = 0
var max_waves
var total_difficulty_left = 0
var number_of_enemies_left = 0

func _ready():
	max_waves = wave_total_difficulty.size()
	
	player_spawner.spawn_function = spawn_player
	enemy_spawner.spawn_function = spawn_enemy
	
	if is_multiplayer_authority() and max_waves > 0:
		total_difficulty_left = wave_total_difficulty[0]
		while total_difficulty_left > 0:
			#var key = EnemyManager.Data.keys().pick_random()
			var key = "dummy"
			enemy_spawner.spawn(key)
			total_difficulty_left -= int(EnemyManager.Data[key]["difficulty"])

func _on_enemy_zero_health():
	if is_multiplayer_authority():
		number_of_enemies_left -= 1
		if number_of_enemies_left <= 0:
			room_exited.emit()

# Runs only on the server
func spawn_players(number_of_players: int):
	for i in number_of_players:
		if i < player_data.size():
			player_spawner.spawn(i)

# Runs on all peers
func spawn_player(player_number: int) -> Node2D:
	var player: Player = PLAYER_SCENE.instantiate()
	player.set_data(player_data[player_number])
	player.global_position = player_spawns[player_number].global_position
	dynamic_camera.add_target(player)
	print("Spawned player of peer_id " + str(player.data.peer_id))
	return player

@rpc("call_local", "reliable")
func spawn_enemy(id: String) -> Node2D:
	print("spawning...")
	var data = EnemyManager.Data[id]
	var enemy: Entity = data["scene"].instantiate()
	enemy.global_position = enemy_spawns.get_children().pick_random().global_position
	enemy.zero_health.connect(_on_enemy_zero_health)
	number_of_enemies_left += 1
	print(number_of_enemies_left)
	return enemy
