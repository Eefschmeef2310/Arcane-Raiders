extends Node2D
class_name CastleRoom
#Authored by Xander. Please consult for any modifications or major feature requests.

signal room_exited
signal all_waves_cleared
signal all_players_dead
signal spell_change_requested(Player, int, SpellPickup)

@export var wave_total_difficulty : Array[int]
@export var gradient_map : GradientTexture1D
@export var saturation : float
@export var track_id : String

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

@onready var tile_map = $TileMap
@onready var room_exit = $RoomExit

var dead_players : Array = []
var all_players_dead_triggered := false
var room_exited_triggered := false

var player_data
var current_wave = 0
var max_waves
var difficulty_modifier = 1
var total_difficulty_left = 0
var number_of_enemies_left = 0
var live_players = 0

var spawn_keys = []
var number_of_players_health_scale: float = 1.0
var number_of_players_difficulty_scale: float = 1.0

func _ready():
	max_waves = wave_total_difficulty.size()
	if gradient_map:
		set_gradient_map(gradient_map, saturation)
	
	player_spawner.spawn_function = spawn_player
	enemy_spawner.spawn_function = spawn_enemy
	spell_pickup_spawner.spawn_function = spawn_spell_pickup

	for n in player_spawns:
		n.hide()
	for n in enemy_spawns.get_children():
		n.hide()
	
	if max_waves > 0:
		room_exit.lock()
		AudioManager.switch_to_battle()
		
		if is_multiplayer_authority():
			number_of_enemies_left = 0
			total_difficulty_left = wave_total_difficulty[0] * difficulty_modifier * number_of_players_difficulty_scale
			print("Difficulty modifier: " + str(difficulty_modifier))
			
			var arr = EnemyManager.Data.keys()
			if !spawn_keys.is_empty():
				arr = spawn_keys
			while total_difficulty_left > 0:
				var key = arr.pick_random()
				var spawn_pos = enemy_spawns.get_children().pick_random().global_position
				var enemy = enemy_spawner.spawn({ "key": key, "pos": spawn_pos })
				total_difficulty_left -= int(EnemyManager.Data[key]["difficulty"])
				# print("New total: " + str(number_of_enemies_left))
			
	if track_id != "":
		AudioManager.play_track_fade(track_id)
		
func _process(_delta):
	pass
	# $CanvasLayer/Label.text = "Enemies Left: " + str(number_of_enemies_left)

func _on_enemy_zero_health():
	await get_tree().process_frame
	if is_multiplayer_authority():
		number_of_enemies_left -= 1
		print("Enemies left: " + str(number_of_enemies_left))
		if number_of_enemies_left <= 0:
			on_floor_cleared.rpc()

func _on_boss_zero_health():
	pass

@rpc("authority", "call_local", "reliable")
func on_floor_cleared():
	all_waves_cleared.emit()
	AudioManager.switch_to_calm()

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
	player.spell_pickup_requested.connect(_on_player_spell_pickup_requested)
	player.dead.connect(report_player_death)
	dynamic_camera.add_target(player)
	live_players += 1
	print("Spawned player of peer_id " + str(player.data.peer_id))
	return player

func report_player_death(player):
	if !(player in dead_players):
		dead_players.append(player)
		if dead_players.size() >= live_players and !all_players_dead_triggered:
			all_players_dead_triggered = true
			all_players_dead.emit()

func _on_player_spell_pickup_requested(p: Player, i: int, sp: SpellPickup):
	print("Sending spell change request.")
	spell_change_requested.emit(p.data, i, sp)

func spawn_enemy(data) -> Node2D:
	var id = data.key
	var pos = data.pos
	
	print("Spawning " + str(id))
	var enemy_data = EnemyManager.Data[id]
	var enemy: Entity = enemy_data["scene"].instantiate()
	enemy.global_position = pos
	enemy.zero_health.connect(_on_enemy_zero_health)
	number_of_enemies_left += 1
	
	if enemy.is_in_group("boss"):
		enemy.max_health *= number_of_players_health_scale
		enemy.zero_health.connect(_on_boss_zero_health)

	return enemy

func spawn_spell_pickup(spell_string: String):
	var pickup: SpellPickup = SPELL_PICKUP.instantiate()
	pickup.set_spell_from_string(spell_string)
	return pickup
	
func set_gradient_map(new_map: GradientTexture1D, saturation_value : float):
	gradient_map = new_map
	saturation = saturation_value
	
	(tile_map.material as ShaderMaterial).set_shader_parameter("gradient", new_map)
	(tile_map.material as ShaderMaterial).set_shader_parameter("final_saturation", saturation)
	(room_exit.material as ShaderMaterial).set_shader_parameter("gradient", new_map)
	(room_exit.material as ShaderMaterial).set_shader_parameter("final_saturation", saturation)
	
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
		
