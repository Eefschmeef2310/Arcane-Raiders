extends Node2D
#class_name
#Authored by Tom. Please consult for any modifications or major feature requests.

@onready var castle_climb = $CastleClimb as CastleClimb

#region Variables
#Signals
signal player_joined
signal player_left(id:int)

#Enums

#Constants
const MAX_PLAYERS = 4

#Exported Variables
#@export_group("Group")
#@export_subgroup("Subgroup")

#Onready Variables

#Other Variables (please try to separate and organise!)
var server_browser_node : Node
var joined_players : int = 0
var player_nodes : Array[Player]

#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Input.joy_connection_changed.connect(_on_controller_changed)
	
	##maybe this should be a player spawner
	#multiplayer_spawner.spawn_function = CreateNewCard
	
	set_multiplayer_authority(1)
	
	if(GameManager.isOnline()):
		server_browser_node = get_parent()
		#print("browser node: "+ server_browser_node.name)
	load_hub()

func _process(delta):
	#Runs per frame
	if GameManager.isLocal():
		handle_join_input()
#endregion

#region Signal methods
func _on_peer_connected(id:int):
	## spawn a new player (online)
	print("Peer connected! id: " + str(id))
	#multiplayer_spawner.spawn(id)
	
	pass

func _on_peer_disconnected(id:int):
	print("Peer " + str(id) + " has disconnected D:")
	## remove the matching player (online)
	#for card in player_card_hbox.get_children():
		#if card.peer_id == id:
			#card.queue_free()
	## emit a signal for removing them from the actual game 
	player_left.emit(id)
	
func _on_controller_changed(device : int, connected : bool):
	## remove player that just disconnected (local)
	if not connected and GameManager.isLocal():
		#for data in castle_climb.player_data:
			#if data.device_id == device:
				#castle_climb.player_data.erase(data)
		for player in player_nodes:
			if player.data.device_id == device:
				castle_climb.current_room_node.dynamic_camera.remove_target(player)
				player.queue_free()
	#if not connected and GameManager.isLocal():
		#for card in player_card_hbox.get_children():
			#if card.device_id == device:
				#card.queue_free()
	pass
#endregion

#region Other methods (please try to separate and organise!)
func load_hub():
	var test_spells : Array[String] = ["null-proj_ball","null-proj_spread","null-aoe_large"]
	var cat : RaiderRes = load("res://multiplayer/multiplayerLobby/raiders/Cat.tres")
	#castle_climb.set_player_data(0,-1,1,test_spells,cat,Color.PURPLE)
	castle_climb.start_hub_floor()

func CreateNewPlayer(peer_id : int):
	var new_player = castle_climb.current_room_node.spawn_player(castle_climb.current_room_node.live_players)
	return new_player
#endregion

#region Local Input Management
# call this from a loop in the main menu or anywhere they can join
# this is an example of how to look for an action on all devices
func handle_join_input():
	for device in get_unjoined_devices():
		if MultiplayerInput.is_action_just_pressed(device, "join"):
			print("handleJoinInput() device_id:" + str(device))
			
			## replace with logic to pick new colors/animals
			var test_spells : Array[String] = ["null-proj_ball","null-proj_spread","null-aoe_large"]
			var cat : RaiderRes = load("res://multiplayer/multiplayerLobby/raiders/Cat.tres")
			castle_climb.set_player_data(joined_players,device,1,test_spells,cat,Color.CYAN)
			castle_climb.current_room_node.player_data = castle_climb.player_data
			## create the new player (local)
			var new_player = CreateNewPlayer(1)
			new_player.data.device_id = device
			castle_climb.current_room_node.player_spawner.spawn(joined_players)
			joined_players += 1
			## add player to room data
			#castle_climb.current_room_node.spawn_player(castle_climb.current_room_node.live_players + 1)
			#player_card_hbox.add_child(new_card)
			
			## track the player objects for when we want to remove them
			player_nodes.clear()
			
			for player in castle_climb.current_room_node.get_children():
				if player is Player:
					player_nodes.append(player)
					
			pass

func is_device_joined(device: int) -> bool:
	for player in castle_climb.player_data:
		var d = player.device_id
		if device == d: return true
	return false
	

# returns a valid player integer for a new player.
# returns -1 if there is no room for a new player.
func next_player() -> int:
	var i = castle_climb.player_data.size() -1
	if castle_climb.player_data.size() -1 < MAX_PLAYERS:
		return i
	return -1
	return 0==0

# returns an array of all valid devices that are *not* associated with a joined player
func get_unjoined_devices():
	var devices = Input.get_connected_joypads()
	# also consider keyboard player
	devices.append(-1)
	
	# filter out devices that are joined:
	return devices.filter(func(device): return !is_device_joined(device))
#endregion



#TODO TODAY
# [ ] create new players when they try to join
# [ ] remove players if they hold the back button for long enough
#- players will be managed through castle climb

