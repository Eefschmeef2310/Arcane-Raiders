extends Node2D
class_name CastleRoom
#Authored by Xander. Please consult for any modifications or major feature requests.

signal room_exited
signal all_waves_cleared
signal all_players_dead
signal spell_change_requested(Player, int, SpellPickup)
signal tilemap_updated()

@export var wave_total_difficulty : Array[int]
@export var gradient_map : GradientTexture1D
@export var saturation : float
@export var noise_min : float
@export var track_id : String

@export var pickups : Array[PackedScene]

@onready var dynamic_camera: DynamicCamera = $DynamicCamera

@onready var player_spawns = [$PlayerSpawn0, $PlayerSpawn1, $PlayerSpawn2, $PlayerSpawn3]
@onready var player_spawner = $PlayerSpawner
@onready var PLAYER_SCENE = preload("res://moving_entities/player/player.tscn")

@onready var enemy_spawns = $EnemySpawns
@onready var enemy_spawner = $EnemySpawner
@onready var boss_bars = $CanvasLayer/BossBars
@onready var BOSSBAR_SCENE = preload("res://ui/boss_bar.tscn")

@onready var spell_pickup_spawner = $SpellPickupSpawner
const SPELL_PICKUP = preload("res://spells/pickups/spell_pickup.tscn")

@onready var health_pickup_spawner = $HealthPickupSpawner

@onready var tile_map = $TileMap
@onready var room_exit = $RoomExit
@onready var camera_background = $DynamicCamera/ParallaxBackground/ColorRect

var rng : RandomNumberGenerator

var dead_players : Array = []
var all_players_dead_triggered := false
var room_exited_triggered := false

var player_data
var current_wave = 0
var max_waves
var difficulty_modifier = 1
var total_difficulty_left = 0
var number_of_enemies_left = 0
var number_of_players = 1
var live_players = 0

var spawn_keys = []
var number_of_players_health_scale: float = 1.0
var number_of_players_difficulty_scale: float = 1.0
var james_mode = false
var difficulty_values : Dictionary = {
		"enemy_spawn_mult" : 1.0, "pickup_spawn_mult" : 1.0, "enemy_speed_mult" : 1.0, "enemy_health_mult" : 1.0, "healing" : 1.0
	}

func _ready():
	print(difficulty_values)
	
	if !rng:
		rng = RandomNumberGenerator.new()
	
	max_waves = wave_total_difficulty.size()
	if gradient_map:
		set_gradient_map(gradient_map, saturation, noise_min)
	
	player_spawner.spawn_function = spawn_player
	enemy_spawner.spawn_function = spawn_enemy
	spell_pickup_spawner.spawn_function = spawn_spell_pickup
	health_pickup_spawner.spawn_function = spawn_health_pickup
	for n in player_spawns:
		n.hide()
	for n in enemy_spawns.get_children():
		n.hide()
	
	if max_waves > 0:
		room_exit.lock()
		AudioManager.switch_to_battle()
		
		if is_multiplayer_authority():
			number_of_enemies_left = 0
			total_difficulty_left = wave_total_difficulty[0] * difficulty_values["enemy_spawn_mult"] * number_of_players_difficulty_scale
		
			var arr = EnemyManager.Data.keys()
			if !spawn_keys.is_empty():
				arr = spawn_keys
			var spawn_nodes = enemy_spawns.get_children()
			while total_difficulty_left > 0:
				var key = arr[rng.randi_range(0, arr.size() - 1)]
				var spawn_pos_node = spawn_nodes[rng.randi_range(0, spawn_nodes.size() - 1)]
				var spawn_pos = spawn_pos_node.global_position
				var _enemy = enemy_spawner.spawn({ "key": key, "pos": spawn_pos })
				total_difficulty_left -= int(EnemyManager.Data[key]["difficulty"])
				# print("New total: " + str(number_of_enemies_left))
	if track_id != "":
		AudioManager.play_track_fade(track_id)

func _on_enemy_zero_health():
	await get_tree().process_frame
	if is_multiplayer_authority():
		number_of_enemies_left -= 1
		#print("Enemies left: " + str(number_of_enemies_left))
		if number_of_enemies_left <= 0:
			on_floor_cleared.rpc()

func _on_boss_zero_health():
	pass

@rpc("authority", "call_local", "reliable")
func on_floor_cleared():
	all_waves_cleared.emit()
	AudioManager.switch_to_calm()

# Runs only on the server
func spawn_players(num_players: int):
	for i in num_players:
		if i < player_data.size():
			player_spawner.spawn(i)

# Runs on all peers
func spawn_player(player_number: int) -> Node2D:
	var player: Player = PLAYER_SCENE.instantiate()
	player.set_data(player_data[player_number]) 
	player.global_position = player_spawns[player_number].global_position
	player.spell_pickup_requested.connect(_on_player_spell_pickup_requested)
	player.dead.connect(report_player_death)
	player.revived.connect(report_player_revival)
	dynamic_camera.add_target(player)
	live_players += 1
	#print("Spawned player of peer_id " + 1str(player.data.peer_id))
	return player

func report_player_death(player):
	if !(player in dead_players):
		dead_players.append(player)
		if dead_players.size() >= live_players and !all_players_dead_triggered:
			all_players_dead_triggered = true
			all_players_dead.emit()

func report_player_revival(player):
	if player in dead_players:
		dead_players.erase(player)

func _on_player_spell_pickup_requested(p: Player, i: int, sp: SpellPickup):
	#print("Sending spell change request.")
	spell_change_requested.emit(p.data, i, sp)

func spawn_enemy(data) -> Node2D:
	var id = data.key
	var pos = data.pos
	
	#print("Spawning " + str(id))
	var enemy_data = EnemyManager.Data[id]
	var enemy: Entity = enemy_data["scene"].instantiate()
	enemy.global_position = pos
	enemy.monetary_value = enemy_data["difficulty"] * 10
	
	#Max health in all entities, movement speed in base enemy and player classes
	enemy.max_health *= difficulty_values["enemy_health_mult"]
	enemy.movement_speed *= difficulty_values["enemy_speed_mult"]
	
	#Not present in shadow wizards lol
	#if "health_pickup_chance" in enemy:
		#enemy.health_pickup_chance *= difficulty_values["healing"]
		
	if !enemy.zero_health.is_connected(_on_enemy_zero_health): enemy.zero_health.connect(_on_enemy_zero_health) #This is already connected in the BaseEnemy scene
	number_of_enemies_left += 1
	
	if enemy.is_in_group("boss"):
		enemy.max_health = floor(enemy.max_health * number_of_players_health_scale)
		if !enemy.zero_health.is_connected(_on_boss_zero_health): enemy.zero_health.connect(_on_boss_zero_health) #See above
	return enemy

func spawn_spell_pickup(spell_string: String):
	var pickup: SpellPickup = SPELL_PICKUP.instantiate()
	pickup.set_spell_from_string(spell_string)
	return pickup

func server_spawn_health_pickup(pos : Vector2):
	var chance = 0.4 * difficulty_values["pickup_spawn_mult"]
	if is_multiplayer_authority() and rng.randf() < chance:
		health_pickup_spawner.call_deferred("spawn", {"pos" : pos, "scene_index": rng.randi_range(0, pickups.size() - 1)})
	
func spawn_health_pickup(info : Dictionary):
	var pickup = pickups[info["scene_index"]].instantiate()
	pickup.global_position = info["pos"]
	return pickup
	
func set_gradient_map(new_map: GradientTexture1D, saturation_value : float, noise_min_value : float):
	gradient_map = new_map
	saturation = saturation_value
	
	(tile_map.material as ShaderMaterial).set_shader_parameter("gradient", new_map)
	(tile_map.material as ShaderMaterial).set_shader_parameter("final_saturation", saturation)
	tilemap_updated.emit()
	(room_exit.material as ShaderMaterial).set_shader_parameter("gradient", new_map)
	(room_exit.material as ShaderMaterial).set_shader_parameter("final_saturation", saturation)
	camera_background.material = tile_map.material
	
	($TileMap/Floor/Floor.material as ShaderMaterial).set_shader_parameter("noise_min", noise_min_value)
	
	
func _on_room_exit_player_entered(_player):
	print("Exit detected. Telling climb...")
	if is_multiplayer_authority() and !room_exited_triggered:
		room_exited_triggered = true
		room_exited.emit()

func create_boss_bar(e: Entity):
	if e:
		var bossbar: BossBar = BOSSBAR_SCENE.instantiate()
		bossbar.set_entity(e)
		boss_bars.add_child(bossbar)
		
