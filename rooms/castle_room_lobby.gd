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
@onready var player_ui_scene = preload("res://ui/player_ui.tscn")

@onready var player_ui_spawner = $PlayerUISpawner
@onready var castle_climb_spawner = $CastleClimbSpawner

var server_browser_node

func _ready():
	#debug_start_button.disabled = not multiplayer.is_server()
	###Runs when all children have entered the tree
	#multiplayer.peer_connected.connect(_on_peer_connected)
	#multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	#multiplayer.connected_to_server.connect(_on_connected_to_server)
	#Input.joy_connection_changed.connect(_on_controller_changed)
	#
	#multiplayer_spawner.spawn_function = CreateNewCard
	
	set_multiplayer_authority(1)
	
	if(GameManager.isOnline()):
		server_browser_node = get_parent()
		if !is_multiplayer_authority():
			$Lobby/VBoxContainer.hide()
		#print("browser node: "+ server_browser_node.name)

func _process(delta):
	if GameManager.isLocal():
		handle_join_input()

@rpc("any_peer", "call_local")
func CreateNewCard(peer_id : int):
	
	var new_player_card = player_ui_scene.instantiate()
	new_player_card.select.lobby_manager = self
	new_player_card.select.peer_id = peer_id
	
	new_player_card.set_multiplayer_authority(peer_id, true)
	player_joined.emit()
	return new_player_card

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
			new_card.select.device_id = device
			player_ui_container.add_child(new_card)
			new_card.show_select_ui()
			pass

func is_device_joined(device: int) -> bool:
	for card in player_ui_container.get_children():
		var d = card.select.device_id
		if device == d: return true
	return false

# returns a valid player integer for a new player.
# returns -1 if there is no room for a new player.
func next_player() -> int:
	var i = player_ui_container.get_child_count() -1
	if player_ui_container.get_child_count() -1 < MAX_PLAYERS:
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
