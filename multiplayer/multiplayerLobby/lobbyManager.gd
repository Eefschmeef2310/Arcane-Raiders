extends Node
#class_name
#Authored by Tom. Please consult for any modifications or major feature requests.

#region Variables
#Signals

#Enums
enum MultiplayerMode {Local,Online}

#Constants

#Exported Variables
#@export_group("Group")
#@export_subgroup("Subgroup")
@export_group("Setup")
@export var mode : MultiplayerMode
@export_group("Node References") 
@export var player_card_hbox : HBoxContainer #hold all the player cards!
@export_group("Other Resources")
#@export var default_slot_icon : Texture2D
@export var raiders : Array[RaiderRes]
@export var loadouts : Array[LoadoutRes]
@export var server_browser_scene : PackedScene
#Onready Variables

#Other Variables (please try to separate and organise!)
var sent_first_update : bool = false
#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	##Steam.lobby_joined.connect(_on_lobby_joined)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
		
	print("Player ID: " + str(SteamManager.player_id))
	#rpc("UpdateCard", SteamManager.player_id, default_slot_icon, "Connected", "This player has successfully connected!", Steam.getPersonaName())
	pass

func _process(delta):
	## TODO find a way of checking when the scene is ready to do the first update, _ready(), peer connected, server connected and Init all seem to be too early 
	if (not sent_first_update):
		sent_first_update = true
		#set inital card values
		rpc("UpdateCard", SteamManager.player_id, Steam.getPersonaName(), 0,0,0,false)
	
	var raider : int = player_card_hbox.get_children()[SteamManager.player_id].selected_raider
	var loadout : int = player_card_hbox.get_children()[SteamManager.player_id].selected_loadout
	var selection : int = player_card_hbox.get_children()[SteamManager.player_id].selected_panel
	var gaming : bool = player_card_hbox.get_children()[SteamManager.player_id].player_ready
	
	#it just works 
	if(Input.is_action_just_pressed("down")):
		if not gaming:
			selection = clampi(selection + 1, 0,2)
		rpc("UpdateCard", SteamManager.player_id, Steam.getPersonaName(), raider,loadout,selection,gaming)
	
	if(Input.is_action_just_pressed("up")):
		if not gaming:
			selection = clampi(selection - 1, 0,2)
		rpc("UpdateCard", SteamManager.player_id, Steam.getPersonaName(), raider,loadout,selection,gaming)
	
	if(Input.is_action_just_pressed("left")):
		if(selection == 0): #raider panel selected 
			raider = clampi(raider - 1, 0,raiders.size()-1)
		elif(selection == 1): #loadout selected
			loadout = clampi(loadout - 1, 0,loadouts.size()-1)
		rpc("UpdateCard", SteamManager.player_id, Steam.getPersonaName(), raider,loadout,selection,gaming)
		
	if(Input.is_action_just_pressed("right")):
		if(selection == 0): #raider panel selected 
			raider = clampi(raider + 1, 0,raiders.size()-1)
		elif(selection == 1): #loadout selected
			loadout = clampi(loadout + 1, 0,loadouts.size()-1)
		rpc("UpdateCard", SteamManager.player_id, Steam.getPersonaName(), raider,loadout,selection,gaming)
	
	if(Input.is_action_just_pressed("lobby_confirm")):
		if(selection == 2): #ready button selected
			gaming = !gaming
		rpc("UpdateCard", SteamManager.player_id, Steam.getPersonaName(), raider,loadout,selection,gaming)
#endregion

@rpc("authority","call_local")
func request_updates(from : int):
	print("Completing an update request for player " + str(from))
	var raider : int = player_card_hbox.get_children()[SteamManager.player_id].selected_raider
	var loadout : int = player_card_hbox.get_children()[SteamManager.player_id].selected_loadout
	var selection : int = player_card_hbox.get_children()[SteamManager.player_id].selected_panel
	var gaming : bool = player_card_hbox.get_children()[SteamManager.player_id].player_ready
	rpc("UpdateCard", SteamManager.player_id, Steam.getPersonaName(), raider,loadout,selection,gaming)
	

#region Signal methods
#func _on_lobby_joined():
	#print("lobby joined")
	#rpc("UpdateCard", SteamManager.player_id, default_slot_icon, "Connected", "This player has successfully connected!", Steam.getPersonaName())
	

func _on_peer_connected(id:int):
	# send a new card update with everything for the new player 
	print("Peer connected! id: " + str(id))
	rpc("UpdateCard", SteamManager.player_id, Steam.getPersonaName(), 0,0,0,false)
	rpc("request_updates", id)
	pass


func _on_connected_to_server():
	print("connected to server")
	rpc("UpdateCard", SteamManager.player_id, Steam.getPersonaName(), 0,0,0,false)
#endregion

#region Other methods (please try to separate and organise!)

## called after the lobby mode has been decided 
func InitLobby(mode : MultiplayerMode):
	if mode == MultiplayerMode.Local:
		for card in player_card_hbox.get_children():
			card.setLocalDefault()
	elif mode == MultiplayerMode.Online:
		for card in player_card_hbox.get_children():
			card.setOnlineDefault()
	

@rpc("any_peer","call_local")
func UpdateCard(playerID : int, username : String, n_raider : int, n_loadout : int, n_selection : int, n_ready : bool):
	var cardToSet = player_card_hbox.get_children()[playerID]
	#cardToSet.rpc("setValues",portrait, raider, description, username)
	print("Update called by player: " + str(playerID))
	cardToSet.setValues(username, n_raider, n_loadout, n_selection, n_ready)


#endregion


func _on_back_button_pressed():
	#TODO close server
	get_tree().change_scene_to_packed(server_browser_scene) 
	pass # Replace with function body.
