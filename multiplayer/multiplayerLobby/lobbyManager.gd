extends Node
#class_name
#Authored by Tom. Please consult for any modifications or major feature requests.

#region Variables
#Signals
signal player_joined
signal player_left(id:int)
#Enums
enum MultiplayerMode {Local,Online}

#Constants

#Exported Variables
@export_group("Setup")
@export var mode : MultiplayerMode
@export var ready_delay : float = 3 #amount in time in seconds the start the game after every player readys up
@export_group("Node References") 
@export var player_card_hbox : HBoxContainer #hold all the player cards!
@export var multiplayer_spawner : MultiplayerSpawner
@export var debug_start_button : Button
@export var ready_progress_bar : TextureProgressBar
@export var lobby_title : Label
@export_group("Other Resources")
@export var raiders : Array[RaiderRes]
@export var loadouts : Array[LoadoutRes]
@export var player_colors : Array[Color]
@export var server_browser_scene : PackedScene
@export var player_card_scene : PackedScene
@export var castle_climb_scene : PackedScene

#Onready Variables
@onready var castle_climb_spawner = $CastleClimbSpawner

#Other Variables (please try to separate and organise!)
var sent_first_update : bool = false
var ready_timer : float 
var lobby_id : int
#endregion

#region Godot methods
func _ready():
	debug_start_button.disabled = not multiplayer.is_server()
	##Runs when all children have entered the tree
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer_spawner.spawn_function = CreateNewCard
	#castle_climb_spawner.spawn_function = spawn_castle_climb
	
	
	#get the peer id the player who has just joined (by loading this scenes ready func)
	var incoming_peer_id = multiplayer.get_unique_id()
	
	if(multiplayer.is_server()):
	#CreateNewCard.rpc(incoming_peer_id)
		#CreateNewCard(incoming_peer_id)
		multiplayer_spawner.spawn(incoming_peer_id)
	
		
	print("Player ID: " + str(SteamManager.player_id) + ", Peer ID: " + str(incoming_peer_id))
	pass

func _process(delta):
	## TODO find a way of checking when the scene is ready to do the first update, _ready(), peer connected, server connected and Init all seem to be too early 
	#if (not sent_first_update):
		#sent_first_update = true
		##set inital card values
		##SendNewCard()
		
	## ready timer
	# determine if all the players are ready
	var all_players_ready : bool = true
	for card in player_card_hbox.get_children():
		if card.player_ready == false:
			all_players_ready = false
	# when they are, start the timer, update the progress bar, and change the title 
	ready_progress_bar.value = ready_timer/ready_delay
	if all_players_ready:
		ready_timer -= delta
		lobby_title.text= "STARTING IN... " + str(roundi(ready_timer)) 
	else:
		ready_timer = ready_delay
		lobby_title.text= "CHOOSE YOUR RAIDER!"
	# if the timer runs out, start the game 
	if ready_timer <= 0:
		StartGame()
	
	pass
	
#endregion

@rpc("any_peer", "call_local")
func CreateNewCard(peer_id : int):
	var new_player_card = player_card_scene.instantiate()
	new_player_card.lobby_manager = self
	new_player_card.peer_id = peer_id
	new_player_card.set_multiplayer_authority(peer_id, true)
	player_joined.emit()
	return new_player_card

#@rpc("authority","call_local")
#func request_updates(from : int):
	#print("Completing an update request for player " + str(from))
	#var raider : int = player_card_hbox.get_children()[SteamManager.player_id].selected_raider
	#var loadout : int = player_card_hbox.get_children()[SteamManager.player_id].selected_loadout
	#var selection : int = player_card_hbox.get_children()[SteamManager.player_id].selected_panel
	#var gaming : bool = player_card_hbox.get_children()[SteamManager.player_id].player_ready
	#rpc("UpdateCard", SteamManager.player_id, Steam.getPersonaName(), raider,loadout,selection,gaming)
	

#region Signal methods


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
	for card in player_card_hbox.get_children():
		if card.peer_id == id:
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
	
func _on_back_button_pressed():
	#TODO close server
	if multiplayer.is_server():
		Steam.setLobbyJoinable(lobby_id, false)
		pass
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_packed(server_browser_scene) 
	pass # Replace with function body.


func _on_start_button_pressed(): 
	StartGame()


#endregion

#region Other methods (please try to separate and organise!)

## called after the lobby mode has been decided 
func InitLobby(_online_mode : MultiplayerMode, new_lobby_id : int):
	lobby_id = new_lobby_id
	pass
	


func StartGame():
	Steam.setLobbyJoinable(lobby_id, false)
	print("START THE GAME!!!!")
	
	var castle_climb : CastleClimb = castle_climb_scene.instantiate()
	add_child(castle_climb)
	
	hide_lobby.rpc()
	castle_climb.setup_from_parent_multiplayer_lobby.rpc()
	
	castle_climb.start_climb()

@rpc("authority", "call_local", "reliable")
func hide_lobby():
	$Lobby.hide()
	$Lobby.process_mode = PROCESS_MODE_DISABLED

func get_card_data() -> Array:
	var arr = []
	for card in player_card_hbox.get_children():
		arr.append({
			"device_id": card.device_id,
			"peer_id": card.peer_id,
			"spells": loadouts[card.selected_loadout].spell_ids,
			"raider": raiders[card.selected_raider]
			})
	return arr
	

#func spawn_castle_climb() -> Node:
	#print(player_card_hbox.get_child(0).peer_id)
	#
	#var node = castle_climb_scene.instantiate() as CastleClimb
	#print(node)
	#return node

#func SendNewCard():
	#rpc("UpdateCard", SteamManager.player_id, Steam.getPersonaName(), 0,0,0,false)
#
#func SendCard(raider,loadout,selection,gaming):
	#rpc("UpdateCard", SteamManager.player_id, Steam.getPersonaName(), raider,loadout,selection,gaming)
#
#@rpc("any_peer","call_local")
#func UpdateCard(playerID : int, username : String, n_raider : int, n_loadout : int, n_selection : int, n_ready : bool):
	#var cardToSet = player_card_hbox.get_children()[playerID]
	##cardToSet.rpc("setValues",portrait, raider, description, username)
	#print("Update called by player: " + str(playerID))
	#cardToSet.setValues(username, n_raider, n_loadout, n_selection, n_ready)


#endregion


