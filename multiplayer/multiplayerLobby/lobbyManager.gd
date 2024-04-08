extends Node
#class_name
#Authored by Tom. Please consult for any modifications or major feature requests.

#region Variables
#Signals
signal player_joined

#Enums
enum MultiplayerMode {Local,Online}

#Constants

#Exported Variables
@export_group("Setup")
@export var mode : MultiplayerMode
@export_group("Node References") 
@export var player_card_hbox : HBoxContainer #hold all the player cards!
@export_group("Other Resources")
@export var raiders : Array[RaiderRes]
@export var loadouts : Array[LoadoutRes]
@export var server_browser_scene : PackedScene
@export var player_card_scene : PackedScene

#Onready Variables

#Other Variables (please try to separate and organise!)
var sent_first_update : bool = false
#endregion

#region Godot methods
func _ready():
	##Runs when all children have entered the tree
	#Steam.lobby_joined.connect(_on_lobby_joined)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	
	#get the peer id the player who has just joined (by loading this scenes ready func)
	var incoming_peer_id = multiplayer.get_unique_id()
	
	#CreateNewCard.rpc(incoming_peer_id)
	CreateNewCard(incoming_peer_id)
	
		
	print("Player ID: " + str(SteamManager.player_id) + ", Peer ID: " + str(incoming_peer_id))
	pass

func _process(delta):
	## TODO find a way of checking when the scene is ready to do the first update, _ready(), peer connected, server connected and Init all seem to be too early 
	#if (not sent_first_update):
		#sent_first_update = true
		##set inital card values
		##SendNewCard()
	pass
	
#endregion

@rpc("any_peer", "call_local")
func CreateNewCard(peer_id : int):
	var new_player_card = player_card_scene.instantiate()
	new_player_card.lobby_manager = self
	new_player_card.set_multiplayer_authority(peer_id, true)
	player_card_hbox.add_child(new_player_card)
	player_joined.emit()

#@rpc("authority","call_local")
#func request_updates(from : int):
	#print("Completing an update request for player " + str(from))
	#var raider : int = player_card_hbox.get_children()[SteamManager.player_id].selected_raider
	#var loadout : int = player_card_hbox.get_children()[SteamManager.player_id].selected_loadout
	#var selection : int = player_card_hbox.get_children()[SteamManager.player_id].selected_panel
	#var gaming : bool = player_card_hbox.get_children()[SteamManager.player_id].player_ready
	#rpc("UpdateCard", SteamManager.player_id, Steam.getPersonaName(), raider,loadout,selection,gaming)
	

#region Signal methods

#func _on_lobby_joined():
	#print("lobby joined")
	#rpc("UpdateCard", SteamManager.player_id, default_slot_icon, "Connected", "This player has successfully connected!", Steam.getPersonaName())
	

func _on_peer_connected(id:int):
	# send a new card update with everything for the new player 
	print("Peer connected! id: " + str(id))
	#SendNewCard()
	rpc("request_updates", id)
	pass


func _on_connected_to_server():
	print("connected to server!")
	#SendNewCard()
#endregion

#region Other methods (please try to separate and organise!)

## called after the lobby mode has been decided 
func InitLobby(mode : MultiplayerMode):
	pass
	

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


func _on_back_button_pressed():
	#TODO close server
	get_tree().change_scene_to_packed(server_browser_scene) 
	pass # Replace with function body.
