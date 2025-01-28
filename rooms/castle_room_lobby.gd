extends CastleRoom
class_name CastleRoomLobby

#Signals
signal player_joined
signal player_left(id:int)
signal restart_requested()

#Enums

#Constants
const MAX_PLAYERS = 4

@export_group("Node References")
@export var player_ui : Array[PlayerUI]
@onready var player_ui_container = $GameUI/PlayerUIContainer
@onready var game_ui = $GameUI
@onready var notif_ui = $NotifUI

@export_group("Other Resources")
@export var chosen_difficulty : int
@export var raiders : Array[RaiderRes]
@export var player_colors : Array[Color]
@export var body_sprites : Array[Texture2D]
#@export var menu_scene : PackedScene
@export var castle_climb_scene : PackedScene
const lobby_player_select_scene = preload("res://multiplayer/multiplayerLobby/lobby_player_select.tscn")
const player_notif_scene = preload("res://rooms/hub/hub_notif.tscn")

@onready var multiplayer_spawner = $MultiplayerSpawner
@onready var castle_climb_spawner = $CastleClimbSpawner

@export var destroy_on_game_start: Array[Node]
@export var invis_on_game_start: Array[Node]

#Other Variables (please try to separate and organise!)
var sent_first_update : bool = false
var start_game_called : bool = false
var ready_timer : float 
var ready_timer_last_step : float = 4
var lobby_id : int
var picked_colors : Array[int]
var picked_raiders : Array[int]
var server_browser_node : Node
@export var join_indicator_node: Control
@onready var no_players_label = $GameUI/NoPlayersLabel

var difficulty_names = ["Easy", "Medium", "Hard", "Extreme"]

var custom_seed = ""

func _enter_tree():
	#Initialise Steam Achievements before pips are loaded into memory
	SteamManager.count_unlocked_achievements()

func _ready():
	#debug_start_button.disabled = not multiplayer.is_server()
	##Runs when all children have entered the tree
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	Input.joy_connection_changed.connect(_on_controller_changed)
	
	multiplayer_spawner.spawn_function = CreateNewCard
	player_spawner.spawn_function = spawn_player_from_ids
	
	room_exited.connect(_on_hub_room_exited)
	
	set_multiplayer_authority(1)
	
	await get_tree().create_timer(0.1, true).timeout
	
	if(GameManager.isOnline()):
		server_browser_node = get_parent()
		if is_multiplayer_authority():
			for id in get_tree().get_multiplayer().get_peers():
				if id != 1:
					_on_peer_connected(id)

func _process(delta):
	if !start_game_called:
		if GameManager.isLocal():
			handle_join_input()
			if is_instance_valid(join_indicator_node) and is_instance_valid(no_players_label):
				player_ui_container.move_child(join_indicator_node, -1)
				no_players_label.visible = player_ui_container.get_child_count() <= 1
				join_indicator_node.visible = player_ui_container.get_child_count() < 5 and !no_players_label.visible
		else:
			if is_instance_valid(join_indicator_node):
				join_indicator_node.hide()
				no_players_label.hide()

@rpc("any_peer", "call_local", "reliable")
func CreateNewCard(peer_id : int):
	
	var new_player_card : JoinSelectUI = lobby_player_select_scene.instantiate()
	new_player_card.lobby_manager = self
	new_player_card.peer_id = peer_id
	new_player_card.raider_selected.connect(_on_card_raider_selected)
	
	new_player_card.set_multiplayer_authority(peer_id, true)
	player_joined.emit()
	return new_player_card

func _on_card_raider_selected(p, d):
	player_spawner.spawn({peer_id = p, device_id = d})
	

#region Local Input Management
# call this from a loop in the main menu or anywhere they can join
# this is an example of how to look for an action on all devices
func handle_join_input():
	for device in get_unjoined_devices():
		if MultiplayerInput.is_action_just_pressed(device, "join"):
			#Destroy the prompt
			#if()
			
			#run join function (create card)
			#join(device)
			var new_card = CreateNewCard(1)
			new_card.device_id = device
			player_ui_container.add_child(new_card)
			pass

func is_device_joined(device: int) -> bool:
	for card in player_ui_container.get_children():
		if card is JoinSelectUI:
			var d = card.device_id
			if device == d: return true
	return false

# returns a valid player integer for a new player.
# returns -1 if there is no room for a new player.
func next_player() -> int:
	var i = player_ui_container.get_child_count() -1
	if i < MAX_PLAYERS:
		return i
	return -1

# returns an array of all valid devices that are *not* associated with a joined player
func get_unjoined_devices():
	var devices = Input.get_connected_joypads()
	# also consider keyboard player
	devices.append(-1)
	
	# filter out devices that are joined:
	return devices.filter(func(device): return !is_device_joined(device))
#endregion

func _on_peer_connected(id:int): #this isnt triggering when a client joins 
	# send a new card update with everything for the new player 
	print("Peer connected! id: " + str(id))
	#CreateNewCard.rpc(id)
	multiplayer_spawner.spawn(id)
	#rpc("request_updates", id)
	pass

func _on_peer_disconnected(id:int):
	print("Peer " + str(id) + " has disconnected D:")
	#destroy their player card
	if is_instance_valid(player_ui_container):
		for card in player_ui_container.get_children():
			if card is JoinSelectUI and card.peer_id == id:
				card._remove_player()
				
				var s = card.username + " has left the room."
				create_notification(s)
				
	for player in get_tree().get_nodes_in_group("player"):
		if player is Player and player.data.peer_id == id:
			player.queue_free()
	
	#emit a signal for removing them from the actual game 
	player_left.emit(id)

func _on_connected_to_server(): #this isnt working at all
	#get all the data from the other players and spawn their cards too
	print("I have connected to the server!")
	pass
	
func _on_server_disconnected():
	# send player to menu / reload server browser scene
	#also show error?
	pass

func _on_controller_changed(device : int, connected : bool):
	if not connected and GameManager.isLocal():
		for card in player_ui_container.get_children():
			if card is JoinSelectUI and card.device_id == device:
				card._remove_player()

func spawn_player_from_ids(dict: Dictionary) -> Node2D:
	var player: Player = PLAYER_SCENE.instantiate()
	var i = 0
	
	player.global_position = player_spawns[0].global_position
	player.spell_pickup_requested.connect(_on_player_spell_pickup_requested)
	player.dead.connect(report_player_death)
	player.revived.connect(report_player_revival)
	dynamic_camera.add_target(player)
	live_players += 1
	#print("Spawned player of peer_id " + 1str(player.data.peer_id))
	
	player.add_to_group("hub_exclusive")
	call_deferred("find_select", player, dict)
	
	return player

func find_select(player : Player, dict: Dictionary):
	for card in player_ui_container.get_children():
		if card is JoinSelectUI and card.peer_id == dict.peer_id and card.device_id == dict.device_id:
			player.set_data(card.player_data, false)
			player.peer_id = card.peer_id  
			card.player_node = player
			break
 
func get_card_data() -> Array:
	var arr = []
	for card in player_ui_container.get_children():
		if card is JoinSelectUI:
			arr.append({
				"device_id": card.device_id,
				"peer_id": card.peer_id,
				"spells": card.player_data.spell_strings,
				"raider": raiders[card.selected_raider],
				"color": player_colors[card.selected_color],
				"name": card.display_name,
				"hat": card.player_data.hat_string,
				"new_hat_sprite" : card.player_data.hat_sprite,
				"body_sprite" : card.player_data.body_sprite,
				})
	return arr

func _on_hub_room_exited():
	if is_multiplayer_authority():
		if get_tree().get_nodes_in_group("player").size() >= get_tree().get_nodes_in_group("hub_select").size():
			StartGame()

func StartGame():
	print("Attempting to spawn castle climb.")
	start_game_called = true
	if GameManager.isOnline() and server_browser_node.peer.has_method("set_lobby_joinable"):
		server_browser_node.peer.set_lobby_joinable(false)
	print("START THE GAME!!!!")
	
	
	var castle_climb : CastleClimb = castle_climb_scene.instantiate()
	if custom_seed != "":
		castle_climb.set_seed(custom_seed)
	if james_mode: castle_climb.james_mode = true
	add_child(castle_climb)
	
	castle_climb.setup_from_parent_multiplayer_lobby.rpc()
	hide_lobby.rpc()
	
	castle_climb.start_climb()

@rpc("reliable", "call_local", "authority")
func hide_lobby():
	await get_tree().create_timer(0.1).timeout
	for node in destroy_on_game_start:
		if is_instance_valid(node):
			node.queue_free()
	for node in invis_on_game_start:
		node.hide()
	for node in get_tree().get_nodes_in_group("hub_exclusive"):
		node.queue_free()
	for ghost in get_tree().get_nodes_in_group("temp_ghost"):
		if is_instance_valid(ghost):
			ghost.queue_free()
	for node in player_ui_container.get_children():
		node.queue_free()
 

func _on_party_exit_player_entered(player):
	for card in player_ui_container.get_children():
		if card is JoinSelectUI and card.player_data == player.data:
			card._remove_player()
			
			var s = "A"
			var raider_name = card.player_data.character.raider_name.to_lower()
			if raider_name[0] in ['a', 'e', 'i', 'o', 'u']:
				s += "n"
			s += " " + raider_name + " has left the raid."
			create_notification(s)


## called after the lobby mode has been decided 
func InitLobby(new_lobby_id : int):
	#mode = online_mode
	lobby_id = new_lobby_id
	
	#server_browser_scene = preload("res://multiplayer/serverBrowser/serverBrowser.tscn") if mode == MultiplayerMode.Online else preload("res://menus/main_menu.tscn")
	
	if GameManager.isOnline():
		#get the peer id the player who has just joined (by loading this scenes ready func)
		var incoming_peer_id = multiplayer.get_unique_id()
		
		if(multiplayer.is_server()):
		#CreateNewCard.rpc(incoming_peer_id)
			#CreateNewCard(incoming_peer_id)
			multiplayer_spawner.spawn(incoming_peer_id)
		
			
		print("Player ID: " + str(SteamManager.player_id) + ", Peer ID: " + str(incoming_peer_id))
		pass
	pass


func create_notification(s : String = "DUMMY DUMMY DUMMY", pos : Vector2 = Vector2(960, 150 )):
	var notif = player_notif_scene.instantiate()
	notif_ui.add_child(notif)
	notif.position = pos
	notif.set_text(s)
	notif.start_tween()
	
	print(notif.position)


func _on_customise_exit_player_entered(player : Player):
	player.data.customise.emit()

@rpc("authority", "reliable", "call_local")
func set_difficulty(val: int):
	chosen_difficulty = val
	
	var s = "The difficulty has been set to " + difficulty_names[chosen_difficulty] + "."
	create_notification(s)


func request_lobby_restart():
	if GameManager.isLocal():
		get_tree().reload_current_scene()
	else:
		restart_requested.emit()
