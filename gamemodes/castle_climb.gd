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
@export var sector_room_split_starts: Array[int]
var sector_room_pool: Array
@export var shop_floors: Array[int]
@export var boss_floors: Array[int]
@export var sector_gradient_maps: Array[GradientTexture1D]
@export var sector_gradient_saturations : Array[float]
@export var sector_noise_min : Array[float]

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
	["slime_big", "bat_small", "bee"],
	["bat_big", "bat_small", "bee", "spider_big"],
	[], # boss
	[], # end
]
var difficulty_values_array = [
	{
		"enemy_spawn_mult" : 1.0, "pickup_spawn_mult" : 1.0, "enemy_speed_mult" : 1.0, "enemy_health_mult" : 1.0, "healing" : 1.0
	},
	{
		"enemy_spawn_mult" : 1.5, "pickup_spawn_mult" : 0.5, "enemy_speed_mult" : 1.0, "enemy_health_mult" : 1.0, "healing" : 1.0
	},
	{
		"enemy_spawn_mult" : 1.5, "pickup_spawn_mult" : 0.5, "enemy_speed_mult" : 1.5, "enemy_health_mult" : 1.5, "healing" : 1.0
	},
	{
		"enemy_spawn_mult" : 1.5, "pickup_spawn_mult" : 0, "enemy_speed_mult" : 1.5, "enemy_health_mult" : 1.5, "healing" : 0.0
	},
]
@export var difficulty_setting : int = 0

@export var james_mode: bool = false
var damageless = true

var number_of_players = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@export var use_preset_seed: bool = false
@export var preset_seed: int = 0
var seed_text : String = ""
@export var current_floor : int = -1

var current_room_node : CastleRoom

@export_group("Game Stats")
@export var show_speedrun_timer := false
var time_elapsed : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	common_level_spawner.spawn_function = spawn_common_level
	basic_level_spawner.spawn_function = spawn_basic_level
	boss_level_spawner.spawn_function = spawn_boss_level
	
	if get_parent().has_signal("player_left"):
		get_parent().player_left.connect(_on_player_left)
	
	print(rng.seed)
	
	sector_room_pool.resize(sector_start_floors.size())
	for j in sector_room_pool.size():
		sector_room_pool[j] = []
	var i = 0
	var n = 0
	while n < basic_levels.size():
		if i < sector_room_pool.size() - 1 and n >= sector_room_split_starts[i + 1]:
			i += 1
		sector_room_pool[i].append(n)
		n += 1
	
	AudioManager.play_track_fade()
	
	if start_on_spawn:
		set_number_of_players(1)
		start_climb()

func _process(delta):
	time_elapsed += delta
	$SpeedrunUI/Control/HBoxContainer/SpeedrunTimer.text = GameManager.format_timer(time_elapsed)
	set_difficulty_label()
	$SpeedrunUI.visible = show_speedrun_timer
	
	if InputMap.has_action("debug_next_floor") and MultiplayerInput.is_action_just_pressed(-1, "debug_next_floor"):
		start_next_floor()
		
	check_crown()

func set_difficulty_label():
	var difficulty_label : Label = $SpeedrunUI/Control/HBoxContainer/DifficultyDisplay
	if difficulty_setting == 0:
		difficulty_label.text = "Easy"
		difficulty_label.label_settings.font_color = Color.GREEN
	elif difficulty_setting == 1:
		difficulty_label.text = "Medium"
		difficulty_label.label_settings.font_color = Color.YELLOW
	elif difficulty_setting == 2:
		difficulty_label.text = "Hard"
		difficulty_label.label_settings.font_color = Color.RED
	elif difficulty_setting == 3:
		difficulty_label.text = "Extreme"
		difficulty_label.label_settings.font_color = Color.PURPLE
		

func check_crown():
	#calculate who should have the crown and gives it to them
	#remove from all and check for highest score
	#var total_damage : int = 0
	var highest_dmg = 0
	var highest_player = -1
	var players : int = number_of_players
	if players > 1:
		for i in players:
			#total_damage += player_data[i].damage
			player_data[i].has_crown = false
			if(player_data[i].damage > highest_dmg):
				highest_dmg = player_data[i].damage
				highest_player = i
		if(highest_player != -1):
			player_data[highest_player].has_crown = true
	return [0, player_data[highest_player if highest_player != -1 else 0], player_data[highest_player if highest_player != -1 else 0].damage, player_data[highest_player if highest_player != -1 else 0].hat_sprite]
	# this func shouldnt be used for stats see get_highest_damage

func get_highest_damage():
	var highest : int = 0
	var player_id = -1
	var total_damage = 0
	for i in number_of_players:
		total_damage += player_data[i].damage
		if player_data[i].kills > highest:
			player_id = i
			highest = player_data[i].kills
	return [total_damage, player_data[player_id if player_id != -1 else 0], player_data[player_id if player_id != -1 else 0].damage, player_data[player_id if player_id != -1 else 0].hat_sprite]



func get_highest_kills():
	var highest : int = 0
	var player_id = -1
	var total_kills = 0
	for i in number_of_players:
		total_kills += player_data[i].kills
		if player_data[i].kills > highest:
			player_id = i
			highest = player_data[i].kills
	return [total_kills, player_data[player_id if player_id != -1 else 0], player_data[player_id if player_id != -1 else 0].kills, player_data[player_id if player_id != -1 else 0].hat_sprite]

func get_highest_earner():
	var highest : int = 0
	var player_id = -1
	var total_earnings = 0
	for i in number_of_players:
		total_earnings += player_data[i].total_money
		if player_data[i].total_money > highest:
			player_id = i
			highest = player_data[i].total_money
	return [total_earnings, player_data[player_id if player_id != -1 else 0], player_data[player_id if player_id != -1 else 0].kills, player_data[player_id if player_id != -1 else 0].hat_sprite]
	
func get_most_pickups():
	var highest : int = 0
	var player_id = -1
	var most_pickups = 0
	for i in number_of_players:
		most_pickups += player_data[i].pickups_obtained
		if player_data[i].pickups_obtained > highest:
			player_id = i
			highest = player_data[i].pickups_obtained
	return [most_pickups, player_data[player_id if player_id != -1 else 0], player_data[player_id if player_id != -1 else 0].pickups_obtained, player_data[player_id if player_id != -1 else 0].hat_sprite]

func get_most_reactions():
	var highest : int = 0
	var player_id = -1
	var most_reactions = 0
	for i in number_of_players:
		most_reactions += player_data[i].reactions_created
		if player_data[i].reactions_created > highest:
			player_id = i
			highest = player_data[i].reactions_created
	return [most_reactions, player_data[player_id if player_id != -1 else 0], player_data[player_id if player_id != -1 else 0].reactions_created, player_data[player_id if player_id != -1 else 0].hat_sprite]



func get_leaderboard() -> Array[int]:
	var leaders : Array[int] = [] # player id's only
	var data : Array[PlayerData] = player_data.duplicate()
	var passes = 0
	
	
	
	while passes < 4:
		var most_damage = -1
		var player_id = -1
		for i in number_of_players:
			if data[i].damage > most_damage:
				most_damage = data[i].damage
				player_id = i
		
		if(data[player_id].damage != -1 and data[player_id].damage != 0):
			leaders.append(player_id)
			data[player_id].damage = -1
		passes += 1
	
	
	#returns an array of player id's from 1st to 4th, missing players will return -1
	return leaders 


func start_climb():
	# Do any server-sided stuff here
	SteamManager.damageless = true
	print("Number of players: " + str(number_of_players))
	if number_of_players <= 0:
		number_of_players = 1
	start_next_floor()

func start_next_floor():
	if !is_multiplayer_authority():
		return
		
	# Close any current dialogue boxes
	Dialogic.end_timeline()
	
	# Delete any lingering ghost sprites
	for child in get_tree().get_nodes_in_group("temp_ghost"):
		child.queue_free()
	
	# Increase floor count
	current_floor += 1
	
	play_room_transition.rpc(current_floor)
	
	await get_tree().create_timer(1, false).timeout
	
	if current_room_node != null:
		print("Freeing old room.")
		current_room_node.free()
	
	# Reset spell cooldowns 
	for data in player_data:
		data.spell_cooldowns.fill(0)
	
	await get_tree().create_timer(0.8).timeout
	
	# Spawn new room
	print("Creating new room.")
	if current_floor <= 0:
		common_level_spawner.spawn("foyer")
	elif current_floor == total_floors:
		common_level_spawner.spawn("final")
	elif current_floor in shop_floors:
		common_level_spawner.spawn("shop")
		for data in player_data:
			data.health += (400 * difficulty_values_array[difficulty_setting]["healing"])
	elif current_floor in boss_floors:
		boss_level_spawner.spawn(get_current_sector())
	else:
		var sector = get_current_sector()
		var id_pool = sector_room_pool[sector]
		var rn = rng.randi_range(id_pool[0], id_pool[id_pool.size()-1])
		sector_room_pool[sector].erase(rn)
		basic_level_spawner.spawn(rn)
	
	await get_tree().create_timer(0.2).timeout
	current_room_node.spawn_players(number_of_players)
	
	if(number_of_players > 1):
		DiscordRPC.state = "Raiding the tower in a group of " + str(number_of_players) + " friends!"
	else:
		DiscordRPC.state = "Raiding the tower alone..."
	DiscordRPC.details = "Currently on Floor " + str(current_floor) 
	DiscordRPC.refresh()

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
	current_room_node.number_of_players = number_of_players
	current_room_node.number_of_players_health_scale = number_of_players_health_scale[number_of_players - 1]
	current_room_node.number_of_players_difficulty_scale = number_of_players_difficulty_scale[number_of_players - 1]
	current_room_node.difficulty_values = difficulty_values_array[difficulty_setting]
	current_room_node.room_exited.connect(_on_room_exited)
	current_room_node.spell_change_requested.connect(_on_spell_change_requested)
	current_room_node.all_players_dead.connect(_on_room_all_players_dead)
	
	current_room_node.rng = RandomNumberGenerator.new()
	current_room_node.rng.seed = rng.randi()
	
	if current_floor > 0 and current_floor < enemy_types_per_floor.size():
		current_room_node.spawn_keys = enemy_types_per_floor[current_floor]
	
	var i = get_current_sector()
	#print("Using Sector "+ str(i) +" data.")
	current_room_node.gradient_map = sector_gradient_maps[i]
	current_room_node.saturation = sector_gradient_saturations[i]
	current_room_node.noise_min = sector_noise_min[i]

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
	call_deferred("add_child", game_over_screen)

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
	for ui in player_ui:
		ui.hide_equip_ui()
		ui.hide_stats_ui()
	
	$RoomTransitionUI/Items/VBoxContainer/NextFloorLabel.text = get_floor_name(next_floor)
	$RoomTransitionUI/Items/VBoxContainer/LastFloorLabel.text = get_floor_name(next_floor-1)
	$RoomTransitionUI/AnimationPlayer.play("next_floor")
	var tween = create_tween()
	tween.tween_property($RoomTransitionUI/Items, "modulate:a", 1, 0.25)
	tween.tween_interval(2)
	tween.tween_property($RoomTransitionUI/Items, "modulate:a", 0, 0.25)
	
	await get_tree().create_timer(0.5, false).timeout
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
		return "Floor " + str(fl)

@rpc("authority", "call_local", "reliable")
func setup_from_parent_multiplayer_lobby():
	var arr = get_parent().get_card_data()
	var i = 0
	for dict in arr:
		set_player_data(i, dict["device_id"], dict["peer_id"], dict["spells"], dict["raider"], dict["color"], dict["name"], dict["hat"], dict["new_hat_sprite"], dict["body_sprite"])
		i += 1
	difficulty_setting = get_parent().chosen_difficulty

func set_player_data(slot: int, device_id: int, peer_id: int, spells: Array[String], character: RaiderRes, color: Color, input_name: String, hat : StringName, new_hat_sprite : Texture2D, body_sprite : Texture2D):
	var data = player_data[slot]
	data.device_id = device_id
	data.peer_id = peer_id
	data.player_name = input_name
	data.set_multiplayer_authority(peer_id)
	
	for i in 3:
		if spells[i] != "":
			data.set_spell_from_string(i, spells[i])
	
	data.character = character
	data.main_color = color
	
	data.hat_string = hat
	data.hat_sprite = new_hat_sprite
	data.body_sprite = body_sprite
	
	if number_of_players < slot + 1:
		number_of_players = slot + 1
	
	var ui = $GameUI/PlayerUIContainer.get_child(slot)
	ui.show()
	ui.set_data(data)
	#print(data.device_id)

func set_seed(seed_string: String):
	var seed_int = hash(seed_string)
	print("Setting seed to " + str(seed_int))
	use_preset_seed = true
	preset_seed = seed_int
	rng.seed = seed_int 
	seed_text = seed_string


func _on_player_left(id : int):
	remove_player_from_run.rpc(id)

@rpc("authority", "call_local", "reliable")
func remove_player_from_run(id):
	var n = 0
	for data in player_data:
		if data.peer_id == id:
			player_data.erase(data)
			player_data.append(data)
			
			var ui = player_ui[n]
			ui.hide()
			player_ui.erase(ui)
			player_ui.append(ui)
			
			number_of_players -= 1
			return
		n += 1
