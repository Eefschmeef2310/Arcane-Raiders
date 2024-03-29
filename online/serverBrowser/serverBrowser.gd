extends Node

#class_name
#Authored by Tom. Please consult for any modifications or major feature requests.

#region Variables
#Signals

#Enums

#Constants

#Exported Variables
@export_group("Editor references")
@export var multiplayer_spawner : MultiplayerSpawner
@export var server_browser : Control
@export var lobbies_vbox : VBoxContainer
@export var server_count_text : Label
@export var gameScene : PackedScene


#@export_group("Group")
#@export_subgroup("Subgroup")

#Onready Variables


#Other Variables (please try to separate and organise!)
var lobby_id = 0
var peer = SteamMultiplayerPeer.new()

#endregion

#region Godot methods
func _ready():
	multiplayer_spawner.spawn_function = spawn_level
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(on_lobby_match_list)
	open_lobby_list()

func _process(delta):
	#Runs per frame
	pass
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion



func spawn_level(data):
	var a = (data as PackedScene).instantiate()
	return a 

func _on_host_pressed():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	multiplayer_spawner.spawn(gameScene)
	#$Host.disabled = true
	#$Refresh.disabled = true
	#$LobbyContainer/Lobbies.hide()
	server_browser.hide()

func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	#$Host.disabled = true
	#$Refresh.disabled = true
	#$LobbyContainer/Lobbies.hide()
	server_browser.hide()

func _on_lobby_created(connect, id):
	if connect:
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
		
			var button = Button.new()
			button.set_text(str(lobby_name," | Player Count: ",memb_count))
			button.set_size(Vector2(100,5))
			button.connect("pressed",Callable(self,"join_lobby").bind(lobby))
			lobbies_vbox.add_child(button)
	server_count_text.text = str(valid_lobbies_count," / ",all_lobbies_count," Servers Shown")


func _on_refresh_pressed():
	if lobbies_vbox.get_child_count() >0:
		for n in lobbies_vbox.get_children():
			n.queue_free()
	open_lobby_list()


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
