extends Control
class_name JoinSelectUI

signal raider_selected(peer_id, device_id)

@export var username : String
@export var peer_id : int = 1 # for online multiplayer
@export var device_id : int = -2 # for local multiplayer

@export var selected_raider : int = 0
@export var selected_color : int = 0
@export var selected_body : int = 0

@export var selected_loadout : int = 0

@export var selected_panel : int = 0 # 0 raider, 1 color, 2 body
@export var player_ready : bool = false
@export var highlight_color : Color = Color.RED # this should be player colour

@export var character_pips_box : Container
@onready var color_pips_box = $PanelContainer/VBoxContainer/ColorContainer/ColorPips
@onready var body_pips_box = $PanelContainer/VBoxContainer/BodyContainer/BodyPips
@onready var player_ui_scene = preload("res://ui/player_ui.tscn")
@onready var notif_spawn_pos = $NotifSpawnPos

@export var lobby_manager : Node
@export var select_controls_panel : Control # hide and show this depending on if a player has joined
@export var panels_array : Array[Control]

@export var player_data : PlayerData

@export_category("Condition Texts")
@export var character_condition : RichTextLabel
@export var color_condition : RichTextLabel
@export var press_button_label : RichTextLabel

var display_name : String

var finished_connecting : bool
var valid_raider : bool
var valid_color : bool
var input
var mouse_input: Array[String]
var devices: Array[int]
var connected_time : float
var readied_up : bool = false

var player_node : Player

var new_ui : PlayerUI

func _ready():
	Input.joy_connection_changed.connect(update_device_list)
	update_device_list(0, true)
	
	input = DeviceInput.new(device_id) if GameManager.isLocal() else null
	
	selected_raider = max(get_index()-1, 0)
	selected_color = max(get_index()-1, 0)
	while !has_valid_color():
		selected_color = wrapi(selected_color + 1, 0,lobby_manager.player_colors.size())
	
	if is_multiplayer_authority():
		username = Steam.getPersonaName()
		
	UpdateDisplay()
	
	#await get_tree().create_timer(0.05).timeout
	
	if !GameManager.isOnline():
		spawn_player.rpc(display_name, selected_raider, selected_color, selected_body)
		#print("I'm the authority. " + str(peer_id))
		  
	if !is_multiplayer_authority():
		#print("I'm a remote peer. " + str(peer_id))
		call_deferred("check_for_existing_player")

func check_for_existing_player():
	if GameManager.isOnline():
		player_data.player_name = username
		player_data.character = lobby_manager.raiders[selected_raider]
		player_data.main_color = lobby_manager.player_colors[selected_color]
		player_data.peer_id = peer_id
		player_data.device_id = device_id
		#print("Starting loop for " + str(peer_id))
		for player in get_tree().get_nodes_in_group("player"):
			if player.peer_id == peer_id:
				#print("Existing player found: " + str(peer_id))
				player_node = player
				player.set_data(player_data, false)
				if is_instance_valid(new_ui):
					new_ui.set_data(player_data)
				convert_to_ui(true)

func _process(_delta):
	connected_time += _delta
	if !finished_connecting:
		finished_connecting = true
	
	if (GameManager.isOnline() && multiplayer.get_unique_id() == peer_id) || GameManager.isLocal():
		$PanelContainer/OnlineShieldPanel.hide() 
		if $PanelContainer.visible:
			get_controller_input()
			
			if("down" in mouse_input):
				if not player_ready:
					#if selected_panel == 0: #For handling multiple rows, this should be refacotred if we want more in another panel lol
						#if selected_raider + (character_pips_box as GridContainer).columns < (character_pips_box as GridContainer).get_child_count():
							#selected_raider = wrapi(selected_raider + (character_pips_box as GridContainer).columns, 0, character_pips_box.get_child_count())
						#else:
							#selected_panel = clampi(selected_panel + 1, 0,panels_array.size()-1)
					#else:
						#selected_panel = clampi(selected_panel + 1, 0,panels_array.size()-1)
					selected_panel = wrapi(selected_panel + 1, 0,panels_array.size())
			
			if("up" in mouse_input):
				if not player_ready:
					#if selected_panel == 0: #For handling multiple rows, this should be refacotred if we want more in another panel lol
						#if selected_raider - (character_pips_box as GridContainer).columns >= 0:
							#selected_raider = wrapi(selected_raider - (character_pips_box as GridContainer).columns, 0, character_pips_box.get_child_count())
						#else:
							#selected_panel = clampi(selected_panel - 1, 0,panels_array.size()-1)
					#else:
						#selected_panel = clampi(selected_panel - 1, 0,panels_array.size()-1)
					selected_panel = wrapi(selected_panel - 1, 0,panels_array.size())
			
			if(("left" in mouse_input) and not player_ready):
				if(selected_panel == 0): #raider panel selected 
					selected_raider = wrapi(selected_raider - 1, 0, character_pips_box.get_children().size())
					while lobby_manager.picked_raiders.has(selected_raider) and not lobby_manager.allow_duplicate_animals:
						selected_raider = wrapi(selected_raider - 1, 0, character_pips_box.get_children().size())
				elif(selected_panel == 1): #color selected
					selected_color = wrapi(selected_color - 1, 0, color_pips_box.get_children().size())
					while !has_valid_color():
						selected_color = wrapi(selected_color - 1, 0, color_pips_box.get_children().size())
				elif(selected_panel == 2): #body selected
					selected_body = wrapi(selected_body - 1, 0, body_pips_box.get_children().size())
				
			if(("right" in mouse_input) and not player_ready):
				if(selected_panel == 0): #raider panel selected 
					selected_raider = wrapi(selected_raider + 1, 0, character_pips_box.get_children().size())
					while lobby_manager.picked_raiders.has(selected_raider) and not lobby_manager.allow_duplicate_animals:
						selected_raider = wrapi(selected_raider + 1, 0, character_pips_box.get_children().size())
				elif(selected_panel == 1): #loadout selected
					selected_color = wrapi(selected_color + 1, 0, color_pips_box.get_children().size())
					while !has_valid_color():
						selected_color = wrapi(selected_color + 1, 0, color_pips_box.get_children().size())
				elif(selected_panel == 2): #body selected
					selected_body = wrapi(selected_body + 1, 0, body_pips_box.get_children().size())
			
			if ("confirm" in mouse_input):
				if (valid_color) and (character_pips_box.get_child(selected_raider) as ClickablePip).is_unlocked and (color_pips_box.get_child(selected_color) as ClickablePip).is_unlocked:
					spawn_player.rpc(display_name, selected_raider, selected_color, selected_body)
			
			UpdateDisplay()
			mouse_input.clear()
	else:
		$PanelContainer/OnlineShieldPanel.show()
	
func UpdateDisplay():
	# set some basic values
	if GameManager.isLocal():
		var s = "Keyboard & Mouse"
		if device_id >= 0:
			s = Input.get_joy_name(device_id)
		display_name = s
	else:
		display_name = username
	
	# Manage the pips under raider and loadout title
	highlight_color = lobby_manager.player_colors[selected_color]
	for pip in character_pips_box.get_children().size():
		if pip == selected_raider:
			if !(character_pips_box.get_child(pip) as ClickablePipCharacter).is_unlocked: #If is locked
				(character_pips_box.get_child(pip) as ClickablePipCharacter).locked_and_selected()
				#Show text
				if character_pips_box.get_child(pip) is ClickablePipEvilCharacter:
					character_condition.text = "[center][wave]Complete Floor 11 with " + (character_pips_box.get_child(pip) as ClickablePipEvilCharacter).character_key + " to unlock!"
				else:
					character_condition.text = "[center][wave]Complete " + \
					str((character_pips_box.get_child(pip) as ClickablePip).achievements_required - SteamManager.unlocked_achievements) + \
					" more achievement" + \
					("s" if (character_pips_box.get_child(pip) as ClickablePipCharacter).achievements_required - SteamManager.unlocked_achievements > 1 else "") + \
					" to unlock this character!"
				character_condition.show()
			else: #Unlocked pip
				character_pips_box.get_child(pip).modulate = Color.WHITE
				character_condition.hide()
		elif lobby_manager.picked_raiders.has(pip) and not lobby_manager.allow_duplicate_animals:
			character_pips_box.get_child(pip).modulate = Color8(255,255,255,40)
		elif (character_pips_box.get_child(pip) as ClickablePip).is_unlocked:
			character_pips_box.get_child(pip).modulate = Color.DIM_GRAY
		else:
			(character_pips_box.get_child(pip) as ClickablePipCharacter).locked()
	
	#Manage colour pips
	for pip in color_pips_box.get_children().size():
		if pip == selected_color:
			if !(color_pips_box.get_child(pip) as ClickablePip).is_unlocked: #If is locked
				(color_pips_box.get_child(pip) as ClickablePipColor).locked_and_selected()
				#Show text
				color_condition.text = "[center][wave]Complete " + str((color_pips_box.get_child(pip) as ClickablePip).achievements_required - SteamManager.unlocked_achievements) + " more run" + ("s" if (color_pips_box.get_child(pip) as ClickablePip).achievements_required - SteamManager.unlocked_achievements > 1 else "") + " to unlock this colour!"
				color_condition.show()
			else: #Unlocked pip
				color_pips_box.get_child(pip).modulate = Color.WHITE
				color_condition.hide()
		elif some_player_has_color(pip):
			color_pips_box.get_child(pip).modulate = Color8(255,255,255,20)
		elif (color_pips_box.get_child(pip) as ClickablePip).is_unlocked:
			color_pips_box.get_child(pip).modulate = Color.DIM_GRAY
		else:
			(color_pips_box.get_child(pip) as ClickablePipColor).locked()
		
	#Manage body pips
	for pip in body_pips_box.get_children().size():
		if pip == selected_body:
			body_pips_box.get_child(pip).modulate = Color.WHITE
		else:
			body_pips_box.get_child(pip).modulate = Color.DIM_GRAY
	
	#Manage the button prompt
	if character_condition.visible or color_condition.visible:
		press_button_label.text = "[center]Select a valid combination!"
	else:
		press_button_label.text = "[center]Space/[img width=32]res://ui/join_button.svg[/img] to jump in!"
	
	#Highlight the correct panel
	self_modulate = Color.WHITE 
	$PanelContainer/VBoxContainer/CharacterContainer.modulate = Color.WHITE
	$PanelContainer/VBoxContainer/ColorContainer.modulate = Color.WHITE
	
	for panel_num in panels_array.size():
		if selected_panel == panel_num:
			#highlight panel with moduate
			(panels_array[panel_num] as Control).self_modulate = highlight_color if (color_pips_box.get_child(selected_color) as ClickablePipColor).is_unlocked else Color.WEB_GRAY
		else:
			#restore it to normal modulation
			(panels_array[panel_num] as Control).self_modulate = Color("363636")
	pass
	
	#check for valid color
	valid_raider = true
	for card in lobby_manager.player_ui_container.get_children():
		if card is JoinSelectUI and card.selected_raider == selected_raider and not card.peer_id == peer_id:
			valid_raider = false
	
	#check for valid color
	has_valid_color()

@rpc("authority", "call_local", "reliable")
func spawn_player(na, raider_id, color_id, body_id):
	player_data.player_name = na
	player_data.character = lobby_manager.raiders[raider_id]
	player_data.main_color = lobby_manager.player_colors[color_id]
	player_data.body_sprite = lobby_manager.body_sprites[body_id]
	player_data.peer_id = peer_id
	player_data.device_id = device_id

	raider_selected.emit(peer_id, device_id)
	convert_to_ui()

func convert_to_ui(is_on_join : bool = false):
	if !$PanelContainer.visible: return
	
	print("Converting to UI: " + str(get_multiplayer_authority()))
	new_ui = player_ui_scene.instantiate()
	add_child(new_ui)
	new_ui.set_data(player_data)
	new_ui.scale = Vector2(1,1)
	$PanelContainer.visible = false
	
	await get_tree().create_timer(0.00001).timeout 
	
	if !is_on_join:
		if GameManager.isOnline():
			var s = username + " has joined the raid!"
			lobby_manager.create_notification(s, notif_spawn_pos.global_position)
		else:
			var s = "A"
			var raider_name = player_data.character.raider_name.to_lower()
			if raider_name[0] in ['a', 'e', 'i', 'o', 'u']:
				s += "n"
			s += " " + raider_name + " has joined the raid!"
			var pos = get_parent().position +  Vector2(get_rect().size.x / 2, -24)
			lobby_manager.create_notification(s, notif_spawn_pos.global_position)

@rpc("authority", "call_local", 'reliable')
func convert_to_select():
	if is_instance_valid(player_node):
		player_node.queue_free()
	new_ui.queue_free()
	$PanelContainer.visible = true

func _on_player_data_customise():
	if is_multiplayer_authority():
		convert_to_select.rpc()

func _remove_player():
	# Clean up player here
	player_data.destroy.emit()
	if is_instance_valid(player_node):
		player_node.queue_free()
	queue_free()

func update_device_list(_device: int, _connected: bool):
	devices.clear()
	devices = Input.get_connected_joypads()
	devices.append(-1)

func is_event_click(event):
	return device_id <= -1 and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed

func _on_panel_container_mouse_entered(num):
	if device_id <= -1 and !player_ready and is_multiplayer_authority():
		selected_panel = num

func _on_raider_pip_gui_input(event, node):
	if is_event_click(event) and device_id <= -1 and visible and is_multiplayer_authority():
		var raider_int = node.get_index()
		if !(lobby_manager.picked_raiders.has(raider_int) and not lobby_manager.allow_duplicate_animals):
			selected_raider = raider_int
		
func _on_color_pip_gui_input(event, node):
	if is_event_click(event) and device_id <= -1 and visible and is_multiplayer_authority():
		var color_int = node.get_index()
		if !(lobby_manager.picked_colors.has(color_int) and not lobby_manager.allow_duplicate_colors):
			selected_color = color_int

func _on_body_pip_gui_input(event, node):
	if is_event_click(event) and device_id <= -1 and visible and is_multiplayer_authority():
		var body_int = node.get_index()
		selected_body = body_int

func get_controller_input():
	if input:
		if input.is_action_just_pressed("lobby_up"):
			mouse_input.append("up")
		if input.is_action_just_pressed("lobby_down"):
			mouse_input.append("down")
		if input.is_action_just_pressed("lobby_left"):
			mouse_input.append("left")
		if input.is_action_just_pressed("lobby_right"):
			mouse_input.append("right")
		if input.is_action_just_pressed("lobby_confirm"):
			mouse_input.append("confirm")
		if input.is_action_just_pressed("lobby_cancel"):
			mouse_input.append("cancel")
	else:
		for device in GameManager.devices:
			if MultiplayerInput.is_action_just_pressed(device, "lobby_up"):
				mouse_input.append("up")
			if MultiplayerInput.is_action_just_pressed(device, "lobby_down"):
				mouse_input.append("down")
			if MultiplayerInput.is_action_just_pressed(device, "lobby_left"):
				mouse_input.append("left")
			if MultiplayerInput.is_action_just_pressed(device, "lobby_right"):
				mouse_input.append("right")
			if MultiplayerInput.is_action_just_pressed(device, "lobby_confirm"):
				mouse_input.append("confirm")
			if MultiplayerInput.is_action_just_pressed(device, "lobby_cancel"):
				mouse_input.append("cancel")

func has_valid_color():
	valid_color = true
	for card in lobby_manager.player_ui_container.get_children():
		if card is JoinSelectUI and card != self and card.selected_color == selected_color:
			valid_color = false
	return valid_color

func some_player_has_color(i : int) -> bool:
	for card in lobby_manager.player_ui_container.get_children():
		if card is JoinSelectUI and card != self and card.selected_color == i:
			return true
	return false

func _on_multiplayer_synchronizer_synchronized():
	if !lobby_manager.start_game_called:
		call_deferred("check_for_existing_player")
