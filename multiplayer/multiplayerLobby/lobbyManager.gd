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
#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass

func _process(delta):
	rpc("UpdateCard", SteamManager.player_id, default_slot_icon, "Connected", "This player has successfully connected!", Steam.getPersonaName())
	pass
#endregion

#region Signal methods

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
func UpdateCard(playerID : int, portrait : Texture2D, raider : String, description : String, username : String):
	var cardToSet = player_card_hbox.get_children()[playerID]
	cardToSet.setValues(portrait, raider, description, username)


#endregion
