extends Node
#class_name
#Authored by Tom. Please consult for any modifications or major feature requests.

#region Variables
#Signals
signal player_joined
signal player_left(id:int)
#Enums


#Constants
const MAX_PLAYERS = 4

#Exported Variables
@export_group("Configuration")
@export var ready_delay : float = 3 #amount in time in seconds the start the game after every player readys up
@export var allow_duplicate_animals : bool = false
@export var allow_duplicate_colors : bool = false
@export_group("Node References") 
@export var player_card_hbox : HBoxContainer #hold all the player cards!
@export var multiplayer_spawner : MultiplayerSpawner
@export var debug_start_button : Button
@export var ready_progress_bar : TextureProgressBar
@export var lobby_title : Label
@export var custom_seed_entry : LineEdit
@export_group("Other Resources")
@export var raiders : Array[RaiderRes]
@export var loadouts : Array[LoadoutRes]
@export var player_colors : Array[Color]
#@export var menu_scene : PackedScene
@export var player_card_scene : PackedScene
@export var castle_climb_scene : PackedScene

#Onready Variables
@onready var castle_climb_spawner = $CastleClimbSpawner

#Other Variables (please try to separate and organise!)
var sent_first_update : bool = false
var start_game_called : bool = false
var ready_timer : float 
var ready_timer_last_step : float = 4
var lobby_id : int
var picked_colors : Array[int]
var picked_raiders : Array[int]
var server_browser_node : Node

var james_mode := false

var back_timer : float

#var server_browser_scene : PackedScene
#endregion

#region Godot methods
func _ready():
	debug_start_button.disabled = not multiplayer.is_server()
	##Runs when all children have entered the tree
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	Input.joy_connection_changed.connect(_on_controller_changed)
	
	multiplayer_spawner.spawn_function = CreateNewCard
	
	set_multiplayer_authority(1)
	
	if(GameManager.isOnline()):
		server_browser_node = get_parent()
		if !is_multiplayer_authority():
			$Lobby/VBoxContainer.hide()
		#print("browser node: "+ server_browser_node.name)

func _process(delta):
	if GameManager.isLocal():
		handle_join_input()
	
	## ready timer
	# determine if all the players are ready
	var all_players_ready : bool = true
	if player_card_hbox.get_child_count() < 1:
		all_players_ready = false
	
	picked_colors.clear()
	picked_raiders.clear()
	for card in player_card_hbox.get_children():
		picked_colors.append(card.selected_color)
		picked_raiders.append(card.selected_raider)
		if card.player_ready == false:
			all_players_ready = false
	# when they are, start the timer, update the progress bar, and change the title 
	ready_progress_bar.value = ready_timer/ready_delay
	if all_players_ready:
		ready_timer -= delta
		if ready_timer < 0:
			ready_timer = 0
		lobby_title.text = "Starting in " + str(ceil(ready_timer)) + "..."
		if floor(ready_timer) < ready_timer_last_step:
			ready_timer_last_step = floor(ready_timer)
			$CountdownPlayer.play()
	else:
		ready_timer = ready_delay
		ready_timer_last_step = ready_delay + 1
		lobby_title.text= "Prepare to raid!"
		
	# if the timer runs out, start the game 
	if (is_multiplayer_authority() or GameManager.isLocal()) and !start_game_called and ready_timer <= 0:
		print("StartGame triggered.")
		StartGame()
		
	if Input.is_action_pressed("ui_cancel") and !start_game_called and !is_instance_valid(get_node("CastleClimb")):
		back_timer += delta
		if back_timer > 1:
			_on_back_button_pressed()
	else:
		back_timer = 0
	$Lobby/BackButton/ProgressBar.value = (back_timer / 1) * 100
	$Lobby/MarginContainer/Label.visible = GameManager.isLocal() and $Lobby/MarginContainer/PlayerCardBox.get_child_count() < 4
	$Lobby/ReadyProgress.visible = all_players_ready

#func _input(event):
	##Player presses excape or right action button
	#if event.is_action_pressed("ui_cancel"):
		#_on_back_button_pressed()
#endregion

@rpc("any_peer", "call_local")
func CreateNewCard(peer_id : int):
	
	var new_player_card = player_card_scene.instantiate()
	new_player_card.lobby_manager = self
	new_player_card.peer_id = peer_id
	
	# select new player color
	var color_found = -1
	for i in player_colors.size():
		if color_found == -1:
			print ("checking: " + str(i))
			color_found = i
			for card in player_card_hbox.get_children():
				if card.selected_color == i:
					# match found check next
					color_found = -1
	if color_found != -1:
		new_player_card.selected_color = color_found
	
	# select new animal
	var animal_found = -1
	for i in raiders.size():
		if animal_found == -1:
			print ("checking: " + str(i))
			animal_found = i
			for card in player_card_hbox.get_children():
				if card.selected_raider == i:
					# match found check next
					animal_found = -1
	if animal_found != -1:
		new_player_card.selected_raider = animal_found
	
	new_player_card.set_multiplayer_authority(peer_id, true)
	player_joined.emit()
	return new_player_card


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
	if GameManager.isOnline() and multiplayer.is_server():
		var result = server_browser_node.peer.set_lobby_joinable(false)
		print("Did the lobby close??: "+str(result))
		pass
	#print("peer: "+str(multiplayer.multiplayer_peer))
	#multiplayer.multiplayer_peer = null
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	if (GameManager.isOnline()):
		get_tree().change_scene_to_file("res://multiplayer/serverBrowser/serverBrowser.tscn") 
	elif (GameManager.isLocal()):
		get_tree().change_scene_to_file("res://menus/main_menu.tscn")
		#queue_free()
	pass # Replace with function body.

func _on_start_button_pressed(): 
	StartGame()

func _on_controller_changed(device : int, connected : bool):
	if not connected and GameManager.isLocal():
		for card in player_card_hbox.get_children():
			if card.device_id == device:
				card.queue_free()
	#if connected and GameManager.isLocal():
		#var new_card = CreateNewCard(1)
		#new_card.device_id = device
		#player_card_hbox.add_child(new_card)

#endregion

#region Other methods (please try to separate and organise!)

## called after the lobby mode has been decided 
func InitLobby(new_lobby_id : int):
	#mode = online_mode
	lobby_id = new_lobby_id
	
	#server_browser_scene = preload("res://multiplayer/serverBrowser/serverBrowser.tscn") if mode == MultiplayerMode.Online else preload("res://menus/main_menu.tscn")
	
	if GameManager.isOnline():
		#get the peer id the player who has just joined (by loading this scenes ready func)
		var incoming_peer_id = multiplayer.get_unique_id()
		
		if(multiplayer.is_server()):
		#CreateNewCard.rpc(incoming_peer_id)
			#CreateNewCard(incoming_peer_id)
			multiplayer_spawner.spawn(incoming_peer_id)
		
			
		print("Player ID: " + str(SteamManager.player_id) + ", Peer ID: " + str(incoming_peer_id))
		pass
	pass
	
	
func StartGame():
	print("Attempting to spawn castle climb.")
	start_game_called = true
	if GameManager.isOnline():
		server_browser_node.peer.set_lobby_joinable(false)
	print("START THE GAME!!!!")
	
	var castle_climb : CastleClimb = castle_climb_scene.instantiate()
	if custom_seed_entry.text != "":
		castle_climb.set_seed(custom_seed_entry.text)
	if james_mode: castle_climb.james_mode = true
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
			"raider": raiders[card.selected_raider],
			"color": player_colors[card.selected_color],
			"name": card.player_name.text
			})
	return arr
	
#endregion

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
			player_card_hbox.add_child(new_card)
			pass

func is_device_joined(device: int) -> bool:
	for card in player_card_hbox.get_children():
		var d = card.device_id
		if device == d: return true
	return false

# returns a valid player integer for a new player.
# returns -1 if there is no room for a new player.
func next_player() -> int:
	var i = player_card_hbox.get_child_count() -1
	if player_card_hbox.get_child_count() -1 < MAX_PLAYERS:
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


func _on_custom_seed_entry_text_changed(new_text):
	$Lobby/VBoxContainer/CustomSeedEntry/Label.visible = new_text != ""


func _on_james_mode_toggle_toggled(toggled_on):
	james_mode = toggled_on
