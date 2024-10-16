extends Control
class_name JoinSelectUI

signal raider_selected(peer_id, device_id)

@export var username : String
@export var peer_id : int = 1 # for online multiplayer
@export var device_id : int = -2 # for local multiplayer
@export var selected_raider : int = 0
@export var selected_loadout : int = 0
@export var selected_color : int = 0
@export var selected_panel : int = 0 # 0 raider, 1 color, 2 ready
@export var show_panels : bool = true #dont show stuff until a player connects
@export var player_ready : bool = false
@export var highlight_color : Color = Color.RED # this should be player colour

@onready var character_pips_box = $PanelContainer/VBoxContainer/CharacterContainer/CharacterPips
@onready var color_pips_box = $PanelContainer/VBoxContainer/ColorContainer/ColorPips
@onready var player_ui_scene = preload("res://ui/player_ui.tscn")
@onready var notif_spawn_pos = $NotifSpawnPos

@export var lobby_manager : Node
#@export var player_name : Label
@export var select_controls_panel : Control # hide and show this depending on if a player has joined
@export var panels_array : Array[Control]
@export var ready_button : Button
@export var ready_text : Label
@export var remove_button : Button

var display_name : String

var finished_connecting : bool
var valid_raider : bool
var valid_color : bool
var input
var mouse_input: Array[String]
var devices: Array[int]
var connected_time : float
var readied_up : bool = false

@export var player_data : PlayerData
var player_node : Player

var new_ui : PlayerUI

func _ready():
	Input.joy_connection_changed.connect(update_device_list)
	update_device_list(0, true)
	
	if GameManager.isLocal():
		input = DeviceInput.new(device_id)
	else:
		input = null
	
	# create and prepare the ui pips
	for child in character_pips_box.get_children():
		child.queue_free()
	
	for raiderCount in lobby_manager.raiders.size():
		var box = StyleBoxFlat.new()
		var box_box : ClickablePip = ClickablePip.new()
		#new_pip.add_theme_stylebox_override("panel",StyleBoxFlat.new())
		box.bg_color = Color8(0,0,0,0)
		box.set_border_width_all(3)
		box.set_corner_radius_all(12)
		box.border_color = Color.WHITE
		box_box.add_theme_stylebox_override("panel",box)
		box_box.gui_input_pass_self.connect(_on_raider_pip_gui_input)
		box_box.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var new_pip = TextureRect.new()
		new_pip.texture = lobby_manager.raiders[raiderCount].head_texture
		var region = Rect2(35,35,80,80)
		new_pip.texture = get_cropped_texture(new_pip.texture, region) 
		new_pip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		new_pip.custom_minimum_size =  Vector2(40,40)
		
		if raiderCount > 0:
			#new_pip.modulate = Color.DIM_GRAY
			box_box.modulate = Color.DIM_GRAY
		
		box_box.add_child(new_pip)
		character_pips_box.add_child(box_box)
	
	for child in color_pips_box.get_children():
		child.queue_free()
		
	for colorCount in lobby_manager.player_colors.size():
		var new_pip = ClickablePip.new()
		var box = StyleBoxFlat.new()
		#new_pip.add_theme_stylebox_override("panel",StyleBoxFlat.new())
		box.bg_color = lobby_manager.player_colors[colorCount]
		box.set_border_width_all(3)
		box.set_corner_radius_all(12)
		box.border_color = Color.WHITE
		new_pip.add_theme_stylebox_override("panel",box)
		new_pip.gui_input_pass_self.connect(_on_color_pip_gui_input)
		new_pip.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		#new_pip.color = lobby_manager.player_colors[colorCount]
		new_pip.custom_minimum_size =  Vector2(46,46)
		
		if colorCount > 0:
			new_pip.modulate = Color.WHITE
		color_pips_box.add_child(new_pip)
	pass
	
	selected_raider = max(get_index()-1, 0)
	selected_color = max(get_index()-1, 0)
	while !has_valid_color():
		selected_color = wrapi(selected_color + 1, 0,lobby_manager.player_colors.size())
	
	if is_multiplayer_authority():
		username = Steam.getPersonaName()
		
	UpdateDisplay()
	
	#await get_tree().create_timer(0.05).timeout
	
	if !GameManager.isOnline():
		spawn_player.rpc(display_name, selected_raider, selected_color)
		print("I'm the authority.")
		  
	if !is_multiplayer_authority():
		print("I'm a remote peer.")
	
		call_deferred("check_for_existing_player")

func check_for_existing_player():
	if GameManager.isOnline():
		player_data.player_name = username
		player_data.character = lobby_manager.raiders[selected_raider]
		player_data.main_color = lobby_manager.player_colors[selected_color]
		player_data.peer_id = peer_id
		player_data.device_id = device_id
		for player in get_tree().get_nodes_in_group("player"):
			if player.data.peer_id == peer_id:
				print("Existing player found: " + str(peer_id))
				player_node = player
				player.set_data(player_data, false)
				convert_to_ui(true)

func _process(_delta):
	connected_time += _delta
	if !finished_connecting:
		#resendValues.rpc()
		finished_connecting = true
	
	if (GameManager.isOnline() && multiplayer.get_unique_id() == peer_id) || GameManager.isLocal():
		$PanelContainer/OnlineShieldPanel.hide() 
		if $PanelContainer.visible:
			get_controller_input()
			
			if("down" in mouse_input):
				if not player_ready:
					selected_panel = clampi(selected_panel + 1, 0,panels_array.size()-1)
			
			if("up" in mouse_input):
				if not player_ready:
					if(GameManager.isLocal()):
						selected_panel = clampi(selected_panel - 1, 0,panels_array.size()-1)
					else:
						selected_panel = clampi(selected_panel - 1, 0,panels_array.size()-1)
			
			if(("left" in mouse_input) and not player_ready):
				if(selected_panel == 0): #raider panel selected 
					selected_raider = wrapi(selected_raider - 1, 0,lobby_manager.raiders.size())
					while lobby_manager.picked_raiders.has(selected_raider) and not lobby_manager.allow_duplicate_animals:
						selected_raider = wrapi(selected_raider - 1, 0,lobby_manager.raiders.size())
				elif(selected_panel == 1): #color selected
					selected_color = wrapi(selected_color - 1, 0,lobby_manager.player_colors.size())
					while !has_valid_color():
						selected_color = wrapi(selected_color - 1, 0,lobby_manager.player_colors.size())
				#elif(selected_panel == 3): #loadout selected
					#selected_loadout = wrapi(selected_loadout - 1, 0,lobby_manager.loadouts.size())
				
			if(("right" in mouse_input) and not player_ready):
				if(selected_panel == 0): #raider panel selected 
					selected_raider = wrapi(selected_raider + 1, 0,lobby_manager.raiders.size())
					while lobby_manager.picked_raiders.has(selected_raider) and not lobby_manager.allow_duplicate_animals:
						selected_raider = wrapi(selected_raider + 1, 0,lobby_manager.raiders.size())
				elif(selected_panel == 1): #loadout selected
					selected_color = wrapi(selected_color + 1, 0,lobby_manager.player_colors.size())
					while !has_valid_color():
						selected_color = wrapi(selected_color + 1, 0,lobby_manager.player_colors.size())
				#elif(selected_panel == 3): #loadout selected
					#selected_loadout = wrapi(selected_loadout + 1, 0,lobby_manager.loadouts.size())
			
			if ("confirm" in mouse_input):
				if (valid_color): # NOTE: removed ready button hover requirement
					spawn_player.rpc(display_name, selected_raider, selected_color)
			
			if ("confirm_click" in mouse_input):
				if (valid_color and selected_panel == 2):
					spawn_player.rpc(display_name, selected_raider, selected_color)
			
			UpdateDisplay()
			mouse_input.clear()
	else:
		$PanelContainer/OnlineShieldPanel.show()
	
	

func UpdateDisplay():
	# hide everything if there isnt a player to use it
	# select_controls_panel.visible = show_panels
	
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
			character_pips_box.get_child(pip).modulate = Color.WHITE
		elif lobby_manager.picked_raiders.has(pip) and not lobby_manager.allow_duplicate_animals:
			character_pips_box.get_child(pip).modulate = Color8(255,255,255,40)
		else: 
			character_pips_box.get_child(pip).modulate = Color.DIM_GRAY
	
	for pip in color_pips_box.get_children().size():
		if pip == selected_color:
			color_pips_box.get_child(pip).modulate = Color.WHITE
		elif some_player_has_color(pip):
			color_pips_box.get_child(pip).modulate = Color8(255,255,255,20)
		else: 
			color_pips_box.get_child(pip).modulate = Color.DIM_GRAY
	
	#Highlight the correct panel
	self_modulate = Color.WHITE 
	$PanelContainer/VBoxContainer/CharacterContainer.modulate = Color.WHITE
	$PanelContainer/VBoxContainer/ColorContainer.modulate = Color.WHITE
	
	for panel_num in panels_array.size():
		if selected_panel == panel_num:
			#highlight panel with moduate
			(panels_array[panel_num] as Control).self_modulate = highlight_color
			pass
		else:
			#restore it to normal modulation
			(panels_array[panel_num] as Control).self_modulate = Color("363636")
			pass
	#self_modulate = highlight_color
	pass
	
	#check for valid color
	valid_raider = true
	#ready_button.text = "READY"
	for card in lobby_manager.player_ui_container.get_children():
		if card is JoinSelectUI and card.selected_raider == selected_raider and not card.peer_id == peer_id:
			valid_raider = false
	
	#check for valid color
	has_valid_color()
	
	$ColorLabel.text = str(selected_color)
		

@rpc("authority", "call_local", "reliable")
func spawn_player(na, raider_id, color_id):
	
	player_data.player_name = na
	player_data.character = lobby_manager.raiders[raider_id]
	player_data.main_color = lobby_manager.player_colors[color_id]
	player_data.peer_id = peer_id
	player_data.device_id = device_id

	raider_selected.emit(peer_id, device_id)
	convert_to_ui()

func convert_to_ui(is_on_join : bool = false):
	print("Converting to UI: " + str(get_multiplayer_authority()))
	new_ui = player_ui_scene.instantiate()
	add_child(new_ui)
	new_ui.set_data(player_data)
	new_ui.scale = Vector2(1,1)
	$PanelContainer.visible = false
	
	if !is_on_join and player_data.character.animal_sound != null and is_instance_valid(player_node):
		(player_node.animal_sound_player as AudioStreamPlayer2D).stream.set_stream(0, player_data.character.animal_sound)
		player_node.animal_sound_player.play()
	
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

#@rpc("any_peer", "call_remote", "reliable")
#func request_update_from_authority():
	#if is_multiplayer_authority():
		#var dict = {
			#"raider" : selected_raider,
			#"color" : selected_color,
			#"hat" : player_data.hat_string
		#}
		#receive_from_authority.rpc(dict)
		#
#@rpc("authority", "call_remote", "reliable")
#func receive_from_authority(dict : Dictionary):
	#selected_raider = dict["raider"]
	#selected_color = dict["color"]
	#player_data.set_hat_from_string(dict["hat"])
	#player_data.reassign.emit()
	#UpdateDisplay()


func get_cropped_texture(texture : Texture, region : Rect2) -> AtlasTexture:
	var atlas_texture := AtlasTexture.new()
	atlas_texture.set_atlas(texture)
	atlas_texture.set_region(region)
	return atlas_texture

func update_device_list(_device: int, _connected: bool):
	devices.clear()
	devices = Input.get_connected_joypads()
	devices.append(-1)

func is_event_click(event):
	return device_id <= -1 and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed

func _on_character_container_mouse_entered():
	if device_id <= -1 and !player_ready and is_multiplayer_authority():
		selected_panel = 0

func _on_color_container_mouse_entered():
	if device_id <= -1 and !player_ready and is_multiplayer_authority():
		selected_panel = 1

func _on_button_mouse_entered():
	if device_id <= -1 and is_multiplayer_authority():
		selected_panel = 2

func _on_left_arrow_clicked(event):
	if is_event_click(event) and device_id <= -1 and is_multiplayer_authority():
		mouse_input.append("left")

func _on_right_arrow_clicked(event):
	if is_event_click(event) and device_id <= -1 and is_multiplayer_authority():
		mouse_input.append("right")

func _on_button_pressed():
	if device_id <= -1 and is_multiplayer_authority():
		mouse_input.append("confirm_click")

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
	#ready_button.text = "READY"
	for card in lobby_manager.player_ui_container.get_children():
		if card is JoinSelectUI and card != self and card.selected_color == selected_color:
			valid_color = false
	return valid_color


func some_player_has_color(i : int) -> bool:
	for card in lobby_manager.player_ui_container.get_children():
		if card is JoinSelectUI and card != self and card.selected_color == i:
			print(valid_color)
			return true
	return false
