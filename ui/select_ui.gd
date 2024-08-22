extends Control
class_name JoinSelectUI

signal raider_selected(peer_id, device_id)

@export var username : String
@export var peer_id : int = 1 # for online multiplayer
@export var device_id : int = -2 # for local multiplayer
@export var selected_raider : int = 0
@export var selected_loadout : int = 0
@export var selected_color : int = 0
@export var selected_panel : int = 1 #0=close_button 1=raider, 2=loadout, 3=ready
@export var show_panels : bool = true #dont show stuff until a player connects
@export var player_ready : bool = false
@export var highlight_color : Color = Color.RED # this should be player colour

@onready var character_pips_box = $PanelContainer/VBoxContainer/CharacterContainer/CharacterPips
@onready var color_pips_box = $PanelContainer/VBoxContainer/ColorContainer/ColorPips
@onready var player_ui_scene = preload("res://ui/player_ui.tscn")

@export var lobby_manager : Node
@export var player_name : Label
@export var select_controls_panel : Control # hide and show this depending on if a player has joined
@export var panels_array : Array[Control]
@export var ready_button : Button
@export var ready_text : Label
@export var remove_button : Button

var finished_connecting : bool
var valid_color : bool
var input
var mouse_input: Array[String]
var devices: Array[int]
var connected_time : float
var readied_up : bool = false

@export var player_data : PlayerData
var player_node : Player

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
	
	UpdateDisplay()

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
						selected_panel = clampi(selected_panel - 1, 1,panels_array.size()-1)
			
			if(("left" in mouse_input) and not player_ready):
				if(selected_panel == 0): #raider panel selected 
					selected_raider = wrapi(selected_raider - 1, 0,lobby_manager.raiders.size())
					while lobby_manager.picked_raiders.has(selected_raider) and not lobby_manager.allow_duplicate_animals:
						selected_raider = wrapi(selected_raider - 1, 0,lobby_manager.raiders.size())
				elif(selected_panel == 1): #color selected
					selected_color = wrapi(selected_color - 1, 0,lobby_manager.player_colors.size())
					while lobby_manager.picked_colors.has(selected_color) and not lobby_manager.allow_duplicate_colors:
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
					while lobby_manager.picked_colors.has(selected_color) and not lobby_manager.allow_duplicate_colors:
						selected_color = wrapi(selected_color + 1, 0,lobby_manager.player_colors.size())
				#elif(selected_panel == 3): #loadout selected
					#selected_loadout = wrapi(selected_loadout + 1, 0,lobby_manager.loadouts.size())
			
			if("confirm" in mouse_input):
				if(selected_panel == 2 and valid_color): #ready button selected
					spawn_player.rpc(player_name.text, selected_raider, selected_color)
			
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
		player_name.text = s
	else:
		player_name.text = username
	
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
		elif lobby_manager.picked_colors.has(pip) and not lobby_manager.allow_duplicate_colors:
			color_pips_box.get_child(pip).modulate = Color8(255,255,255,40)
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
	valid_color = true
	#ready_button.text = "READY"
	for card in lobby_manager.player_ui_container.get_children():
		if card is JoinSelectUI and card.selected_color == selected_color and not player_ready and not card.peer_id == peer_id:
			valid_color = false

@rpc("authority", "call_local", "reliable")
func spawn_player(na, raider_id, color_id):
	
	player_data.player_name = na
	player_data.character = lobby_manager.raiders[raider_id]
	player_data.main_color = lobby_manager.player_colors[color_id]
	player_data.peer_id = peer_id
	player_data.device_id = device_id
	
	raider_selected.emit(peer_id, device_id)
	
	var new_ui = player_ui_scene.instantiate()
	add_child(new_ui)
	new_ui.set_data(player_data)
	
	$PanelContainer.visible = false
	

func _remove_player():
	# Clean up player here
	player_data.destroy.emit()
	if player_node:
		player_node.queue_free()
	queue_free()

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
		mouse_input.append("confirm")

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
