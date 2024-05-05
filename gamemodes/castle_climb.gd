extends Node
class_name CastleClimb

@onready var common_level_spawner = $CommonLevelSpawner
@onready var basic_level_spawner = $BasicLevelSpawner
@onready var boss_level_spawner = $BossLevelSpawner

@export_group("Debug")
@export var start_on_spawn : bool = false

@export_group("Node References")
@export var player_data : Array[PlayerData]
@export var player_ui : Array[PlayerUI]

@export_group("Level Scenes")
@export var common_levels: Dictionary
@export var basic_levels: Array[PackedScene]
@export var boss_levels: Array[PackedScene]

@export_group("Sector Data")
@export var total_floors: int
@export var sector_start_floors: Array[int]
@export var shop_floors: Array[int]
@export var boss_floors: Array[int]
@export var sector_gradient_maps: Array[GradientTexture1D]
@export var sector_gradient_saturations : Array[float]

@export_group("Difficulty")
@export var number_of_players_health_scale : Array = [1.0, 1.5, 2.0, 2.4]
@export var number_of_players_difficulty_scale : Array = [1.0, 1.3, 1.6, 1.9]
@export var wave_difficulty_curve : Curve
var enemy_types_per_floor : Array = [
	[], # foyer
	["slime_small", "slime_big"],
	["slime_small", "slime_big", "bat_small"],
	[], # boss
	[], # shop
	["slime_small", "slime_big", "nest"],
	["slime_small", "bat_small", "spider_big"],
	[], # boss
	[], # shop
	["slime_big", "bat_small", "spider_big"],
	["bat_big", "bat_small", "bat_small", "spider_big"],
	[], # boss
	[], # end
]

var number_of_players = 0
var rng_floors: RandomNumberGenerator = RandomNumberGenerator.new()
@export var current_floor : int = -1

var current_room_node : CastleRoom

# Called when the node enters the scene tree for the first time.
func _ready():
	common_level_spawner.spawn_function = spawn_common_level
	basic_level_spawner.spawn_function = spawn_basic_level
	boss_level_spawner.spawn_function = spawn_boss_level
	
	if start_on_spawn:
		set_number_of_players(1)
		start_climb()

func _process(_delta):
	if MultiplayerInput.is_action_just_pressed(-1, "debug_next_floor"):
		start_next_floor()

func start_climb():
	# Do any server-sided stuff here
	print("Number of players: " + str(number_of_players))
	if number_of_players <= 0:
		number_of_players = 1
	start_next_floor()

func start_next_floor():
	if !is_multiplayer_authority():
		return
	
	# Increase floor count
	current_floor += 1
	print("Current floor: " + str(current_floor))
	
	play_room_transition.rpc(current_floor)
	
	await get_tree().create_timer(1).timeout
	
	if current_room_node != null:
		print("Freeing old room.")
		current_room_node.free()
	
	# Reset player health
	for data in player_data:
		if data.health <= 0:
			data.health = 100
	
	await get_tree().create_timer(0.8).timeout
	
	# Spawn new room
	print("Creating new room.")
	if current_floor <= 0:
		common_level_spawner.spawn("foyer")
	elif current_floor == total_floors:
		common_level_spawner.spawn("final")
	elif current_floor in shop_floors:
		common_level_spawner.spawn("shop")
	elif current_floor in boss_floors:
		boss_level_spawner.spawn(rng_floors.randi_range(0, boss_levels.size() - 1))
	else:
		basic_level_spawner.spawn(rng_floors.randi_range(0, basic_levels.size() - 1))
	
	await get_tree().create_timer(0.2).timeout
	current_room_node.spawn_players(number_of_players)

func spawn_common_level(key) -> Node:
	AudioManager.play_sector(get_current_sector())
	current_room_node = common_levels[key].instantiate() as CastleRoom
	inject_data_to_current_room_node()
	return current_room_node

func spawn_basic_level(index: int) -> Node:
	AudioManager.play_sector(get_current_sector())
	current_room_node = basic_levels[index].instantiate() as CastleRoom
	inject_data_to_current_room_node()
	return current_room_node

func spawn_boss_level(index: int) -> Node:
	current_room_node = boss_levels[index].instantiate() as CastleRoom
	inject_data_to_current_room_node()
	return current_room_node

func inject_data_to_current_room_node():
	current_room_node.player_data = player_data
	current_room_node.difficulty_modifier *= wave_difficulty_curve.sample(float(current_floor)/float(total_floors))
	current_room_node.number_of_players_health_scale = number_of_players_health_scale[number_of_players - 1]
	current_room_node.number_of_players_difficulty_scale = number_of_players_difficulty_scale[number_of_players - 1]
	current_room_node.room_exited.connect(_on_room_exited)
	current_room_node.spell_change_requested.connect(_on_spell_change_requested)
	current_room_node.all_players_dead.connect(_on_room_all_players_dead)
	
	if current_floor > 0 and current_floor < enemy_types_per_floor.size():
		current_room_node.spawn_keys = enemy_types_per_floor[current_floor]
	
	var i = get_current_sector()
	print("Using Sector "+ str(i) +" data.")
	current_room_node.gradient_map = sector_gradient_maps[i]
	current_room_node.saturation = sector_gradient_saturations[i]

func get_current_sector():
	var i = 0
	while i < sector_start_floors.size():
		if i == sector_start_floors.size()-1 or current_floor < sector_start_floors[i+1]:
			return i
		i += 1

func _on_room_exited():
	if is_multiplayer_authority():
		start_next_floor()

func _on_room_all_players_dead():
	if is_multiplayer_authority():
		game_over.rpc()

@rpc("authority", "call_local", "reliable")
func game_over():
	await get_tree().create_timer(2.0).timeout
	var game_over_screen = load("res://screens/game_over_screen.tscn").instantiate()
	get_tree().root.call_deferred("add_child", game_over_screen)

func _on_spell_change_requested(d: PlayerData, i: int, sp: SpellPickup):
	use_spell_pickup_server.rpc(player_data.find(d), i, sp.get_path())

# Only called on the server.
# If multiple players try to pick up the same spell,
# whoever's packet arrived first gets it.
@rpc("any_peer", "call_local", "reliable")
func use_spell_pickup_server(p_i: int, i: int, sp_path: String):
	if is_multiplayer_authority():
		print("Attempting to use pickup at path: " + sp_path)
		var pickup: SpellPickup = get_node(sp_path)
		if is_instance_valid(pickup):
			# Pickup hasn't been claimed yet. Claim it!
			var new_pickup = current_room_node.spell_pickup_spawner.spawn(player_data[p_i].spell_strings[i])
			new_pickup.global_position = pickup.global_position
			
			set_spell_from_string.rpc(p_i, i, pickup.spell_string)
			
			pickup.free()
		else:
			# Failure.
			print("Pickup doesn't exist (anymore)!")

# Sets a player's spell slot on all clients.
@rpc("authority", "call_local", "reliable")
func set_spell_from_string(p_i: int, i: int, s: String):
	var data = player_data[p_i]
	data.set_spell_from_string(i, s)

@rpc("authority", "call_local", "reliable")
func play_room_transition(next_floor: int):
	current_floor = next_floor
	
	$RoomTransitionUI/Items/VBoxContainer/NextFloorLabel.text = get_floor_name(next_floor)
	$RoomTransitionUI/Items/VBoxContainer/LastFloorLabel.text = get_floor_name(next_floor-1)
	$RoomTransitionUI/AnimationPlayer.play("next_floor")
	var tween = create_tween()
	tween.tween_property($RoomTransitionUI/Items, "modulate:a", 1, 0.25)
	tween.tween_interval(2)
	tween.tween_property($RoomTransitionUI/Items, "modulate:a", 0, 0.25)
	
	await get_tree().create_timer(0.5).timeout
	$RunUI/FloorLabel.text = get_floor_name(next_floor)

func set_number_of_players(n: int):
	number_of_players = n
	var i = 0
	for child in $GameUI/PlayerUIContainer.get_children():
		if i >= number_of_players:
			child.hide()
		else:
			child.show()
		i += 1

func get_floor_name(fl: int) -> String:
	if fl < 0:
		return ""
	elif fl == 0:
		return "Foyer"
	else:
		return str(fl) + "F"

@rpc("authority", "call_local", "reliable")
func setup_from_parent_multiplayer_lobby():
	var arr = get_parent().get_card_data()
	var i = 0
	for dict in arr:
		set_player_data(i, dict["device_id"], dict["peer_id"], dict["spells"], dict["raider"], dict["color"])
		i += 1

func set_player_data(slot: int, device_id: int, peer_id: int, spells: Array[String], character: RaiderRes, color: Color):
	var data = player_data[slot]
	data.device_id = device_id
	data.peer_id = peer_id
	data.set_multiplayer_authority(peer_id)
	
	for i in 3:
		if spells[i] != "":
			data.set_spell_from_string(i, spells[i])
	
	data.character = character
	data.main_color = color
	
	if number_of_players < slot + 1:
		number_of_players = slot + 1
	
	var ui = $GameUI/PlayerUIContainer.get_child(slot)
	ui.show()
	ui.set_data(data)
	print(data.device_id)
