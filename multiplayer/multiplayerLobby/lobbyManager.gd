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
@export var player_card_hbox : HBoxContainer
@export_group("Other Resources")
@export var default_slot_icon : Texture2D
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
		var card = PlayerCardRes.new()
		card.raiderRes = RaiderRes.new()
		card.loadoutRes = LoadoutRes.new()
		card.raiderRes.portrait = default_slot_icon
		card.raiderRes.raider_name = "Connected"
		card.raiderRes.raider_desc = "This player has successfully connected"
		card.username = Steam.getPersonaName()
		rpc("UpdateCard", SteamManager.player_id, card)
		
	if(Input.is_action_just_pressed("debug_random")):
		#raider_desc.text += " •⩊• "
		##rpc("setValues", default_slot_icon, "Cool Player", str(raider_desc.text + " •⩊• "), Steam.getPersonaName())
		var raider_desc = player_card_hbox.get_children()[SteamManager.player_id].raider_desc
		var card = PlayerCardRes.new()
		card.raiderRes = RaiderRes.new()
		card.loadoutRes = LoadoutRes.new()
		card.raiderRes.portrait = default_slot_icon
		card.raiderRes.raider_name = "Cool Player"
		card.raiderRes.raider_desc = raider_desc.text + " •⩊• "
		card.username = Steam.getPersonaName()
		rpc("UpdateCard", SteamManager.player_id, card)
		pass
#endregion

@rpc("authority","call_local")
func request_updates(from : int):
	print("Completing an update request for player " + str(from))
	var raider_desc = player_card_hbox.get_children()[SteamManager.player_id].raider_desc
	var card = PlayerCardRes.new()
	card.raiderRes = RaiderRes.new()
	card.loadoutRes = LoadoutRes.new()
	card.raiderRes.portrait = default_slot_icon
	card.raiderRes.raider_name = "Cool Player"
	card.raiderRes.raider_desc = raider_desc
	card.username = Steam.getPersonaName()
	rpc("UpdateCard", SteamManager.player_id, card)
	

#region Signal methods
#func _on_lobby_joined():
	#print("lobby joined")
	#rpc("UpdateCard", SteamManager.player_id, default_slot_icon, "Connected", "This player has successfully connected!", Steam.getPersonaName())
	

func _on_peer_connected(id:int):
	# send a new card update with everything for the new player 
	print("Peer connected! id: " + str(id))
	var raider_desc = player_card_hbox.get_children()[SteamManager.player_id].raider_desc
	var card = PlayerCardRes.new()
	card.raiderRes = RaiderRes.new()
	card.loadoutRes = LoadoutRes.new()
	card.raiderRes.portrait = default_slot_icon
	card.raiderRes.raider_name = "Connected"
	card.raiderRes.raider_desc = "This player has successfully connected"
	card.username = Steam.getPersonaName()
	rpc("UpdateCard", SteamManager.player_id, card)
	rpc("request_updates", id)
	pass


func _on_connected_to_server():
	print("connected to server")
	var card = PlayerCardRes.new()
	card.raiderRes = RaiderRes.new()
	card.loadoutRes = LoadoutRes.new()
	card.raiderRes.portrait = default_slot_icon
	card.raiderRes.raider_name = "Connected"
	card.raiderRes.raider_desc = "This player has successfully connected"
	card.username = Steam.getPersonaName()
	rpc("UpdateCard", SteamManager.player_id, card)
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
func UpdateCard(playerID : int, newCard : PlayerCardRes):
	var cardToSet = player_card_hbox.get_children()[playerID]
	#cardToSet.rpc("setValues",portrait, raider, description, username)
	print("Update called by player: " + str(playerID))
	cardToSet.setValues(newCard)


#endregion
