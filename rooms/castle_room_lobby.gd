extends CastleRoom
class_name CastleRoomLobby

#Signals
signal player_joined
signal player_left(id:int)

#Enums

#Constants
const MAX_PLAYERS = 4

@export_group("Node References")
@export var player_ui : Array[PlayerUI]
@onready var player_ui_container = $GameUI/PlayerUIContainer

@export_group("Other Resources")
@export var raiders : Array[RaiderRes]
@export var player_colors : Array[Color]
#@export var menu_scene : PackedScene
@export var castle_climb_scene : PackedScene
@onready var lobby_player_select_scene = preload("res://multiplayer/multiplayerLobby/lobby_player_select.tscn")

@onready var multiplayer_spawner = $MultiplayerSpawner
@onready var castle_climb_spawner = $CastleClimbSpawner

@export var hide_on_game_start: Array[Node]

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
	
	if(GameManager.isOnline()):
		server_browser_node = get_parent()
		if !is_multiplayer_authority():
			$Lobby/VBoxContainer.hide()
		#print("browser node: "+ server_browser_node.name)

func _process(delta):
	if !start_game_called:
		if GameManager.isLocal():
			handle_join_input()
			join_indicator_node.show()
			player_ui_container.move_child(join_indicator_node, -1)
		else:
			join_indicator_node.hide()

@rpc("any_peer", "call_local")
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
	for card in player_ui_container.get_children():
		if card is JoinSelectUI and card.peer_id == id:
			card.queue_free()
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
	for card in player_ui_container.get_children():
		if card is JoinSelectUI and card.peer_id == dict.peer_id and card.device_id == dict.device_id:
			player.set_data(card.player_data)
			card.player_node = player
			break
		else:
			i += 1
	player.global_position = player_spawns[i].global_position
	player.spell_pickup_requested.connect(_on_player_spell_pickup_requested)
	player.dead.connect(report_player_death)
	player.revived.connect(report_player_revival)
	dynamic_camera.add_target(player)
	live_players += 1
	#print("Spawned player of peer_id " + 1str(player.data.peer_id))
	
	player.add_to_group("hub_exclusive")
	
	return player

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
				"name": card.player_name.text
				})
	return arr

func _on_hub_room_exited():
	if is_multiplayer_authority():
		if get_tree().get_nodes_in_group("player").size() >= get_tree().get_nodes_in_group("hub_select").size():
			StartGame()

func StartGame():
	print("Attempting to spawn castle climb.")
	start_game_called = true
	if GameManager.isOnline():
		server_browser_node.peer.set_lobby_joinable(false)
	print("START THE GAME!!!!")
	
	var castle_climb : CastleClimb = castle_climb_scene.instantiate()
	#if custom_seed_entry.text != "":
		#castle_climb.set_seed(custom_seed_entry.text)
	#if james_mode: castle_climb.james_mode = true
	add_child(castle_climb)
	
	hide_lobby.rpc()
	castle_climb.setup_from_parent_multiplayer_lobby.rpc()
	
	castle_climb.start_climb()

@rpc("reliable", "call_local", "authority")
func hide_lobby():
	for node in hide_on_game_start:
		node.queue_free()
	for node in get_tree().get_nodes_in_group("hub_exclusive"):
		node.queue_free()


func _on_party_exit_player_entered(player):
	for card in player_ui_container.get_children():
		if card is JoinSelectUI and card.player_data == player.data:
			card._remove_player()