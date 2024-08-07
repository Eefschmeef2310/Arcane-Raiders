extends Node

#class_name
#Authored by Tom. Please consult for any modifications or major feature requests.

#region Variables
#Signals

#Enums

#Constants

#Exported Variables
@export_group("Node references")
@export var multiplayer_spawner : MultiplayerSpawner
@export var server_browser : Control
@export var lobbies_vbox : VBoxContainer
@export var server_count_text : Label
@export var loading_text : Label
@export var loading_panel : Node
@export var template_button : Button

@export_group("Scenes")
@export var gameScene : String = "res://multiplayer/multiplayerLobby/multiplayerLobby.tscn"
@export var disconnect_scene : PackedScene


#@export_group("Group")
#@export_subgroup("Subgroup")

#Onready Variables


#Other Variables (please try to separate and organise!)
var lobby_id = 0 ## id of the currently connected lobby, 0 if not connected 

var peer = SteamMultiplayerPeer.new()

#endregion

#region Godot methods
func _ready():
	multiplayer_spawner.spawn_function = spawn_level
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(on_lobby_match_list)
	open_lobby_list()
#endregion

#region Signal methods
func _on_refresh_pressed():
	if lobbies_vbox.get_child_count() >0:
		for n in lobbies_vbox.get_children():
			n.queue_free()
	open_lobby_list()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")

func _on_disconnect_button_pressed():
	# TODO this doesnt work yet! we should probably have it go back to the menu rather than try and reload te server browser
	get_tree().paused = false
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	get_tree().change_scene_to_packed(disconnect_scene) 
	
func _on_host_pressed():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC) #create lobby on steam
	multiplayer.multiplayer_peer = peer
	var lobby_scene = multiplayer_spawner.spawn(gameScene)
	lobby_scene.InitLobby(lobby_id)
	server_browser.hide()

func _on_local_pressed():
	var lobby_scene = multiplayer_spawner.spawn(gameScene)
	lobby_scene.InitLobby(0)
	server_browser.hide()
#endregion

#region Other methods (please try to separate and organise!)

func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	
	return a 

func join_lobby(id):
	loading_panel.show()
	loading_text.text = "Loading into...\n" + Steam.getLobbyData(id,"name")
	peer.connect_lobby(id)
	#print("TimerDebuging - multiplayer_peer, before join_lobby set: "+ str(multiplayer.multiplayer_peer))
	multiplayer.multiplayer_peer = peer
	#print("TimerDebuging - multiplayer_peer, afetr join_lobby set: "+ str(multiplayer.multiplayer_peer))
	lobby_id = id
	SteamManager.player_id = Steam.getNumLobbyMembers(id)
	server_browser.hide()

func _on_lobby_created(connected, id):
	if connected:
		lobby_id = id
		Steam.setLobbyData(lobby_id,"name",str(Steam.getPersonaName()+"'s Arcane Raiders Lobby " + Time.get_time_string_from_system()))
		Steam.setLobbyJoinable(lobby_id, true)
		print(lobby_id)
		
func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()
	
func on_lobby_match_list(lobbies):
	var valid_lobbies_count : int = 0
	var all_lobbies_count = lobbies.size()
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby,"name")
		if (lobby_name.contains("Arcane Raiders")):
			var memb_count = Steam.getNumLobbyMembers(lobby)
			var button = template_button.duplicate()
			button.get_node("MarginContainer/HBoxContainer/ServerName").text = str(lobby_name)
			button.get_node("MarginContainer/HBoxContainer/ServerFill").text = str(memb_count) + "/4 Players"
			button.connect("pressed",Callable(self,"join_lobby").bind(lobby))
			button.show()
			lobbies_vbox.add_child(button)
			valid_lobbies_count += 1
	server_count_text.text = str(valid_lobbies_count," / ",all_lobbies_count," Servers Shown")

#endregion
