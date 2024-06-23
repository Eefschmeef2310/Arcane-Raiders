extends Control
#Authored by Tom. Please consult for any modifications or major feature requests.

#region Variables
#Signals

#Enums

#Constants

#Exported Variables
@export_group("Card Values")
@export var username : String
@export var peer_id : int = 1 # for online multiplayer
@export var device_id : int = -2 # for local multiplayer
@export var selected_raider : int = 0
@export var selected_loadout : int = 0
@export var selected_color : int = 0
@export var selected_panel : int = 1 #0=close_button 1=raider, 2=loadout, 3=ready
@export var show_panels : bool = true #dont show stuff until a player connects
@export var player_ready : bool = false
@export var highlight_color : Color = Color.RED: # this should be player colour
	set(value):
		highlight_color = value
		#Sets LED colour of controller when the colour changes
		#print(str(SteamControllerInput.get_controllers()) + ", " + str(SteamControllerInput.get_controllers()[device_id+1]))
		if SteamControllerInput.get_controllers().size() > 1 and SteamControllerInput.get_controllers().size() < device_id: #In case Steam isnt open
			Steam.setLEDColor(SteamControllerInput.get_controllers()[device_id + 1], int(value.r * 255), int(value.g * 255), int(value.b * 255), 0)
			Steam.triggerVibration(SteamControllerInput.get_controllers()[device_id + 1], 100, 100)

@export_group("Other Resources")
@export var pip_texture : Texture2D

@export_group("References")
@export var lobby_manager : Node
@export var player_name : Label
@export var all_panels : VBoxContainer # hide and show this depending on if a player has joined 
@export var most_panels : VBoxContainer # modulate this to grey when a player is ready to show their choices are "locked"
@export var panels_array : Array[Control]
@export var ready_button : Button
@export var ready_text : Label
@export var remove_button : Button
@export_subgroup("raider")
@export var raider_portrait : TextureRect
@export var raider_name : Label 
@export var raider_desc : Label 
@export var character_pips_box : HBoxContainer
@export_subgroup("loadout")
@export var loadout_name : Label
@export var loadout_desc : Label
@export var loadout_pips_box : HBoxContainer
@export var spells_box : HBoxContainer
@export_subgroup("color")
@export var color_name : Label
@export var color_pips_box : HBoxContainer
@export_subgroup("preview")
@export var pre_head : Sprite2D
@export var pre_body : Sprite2D
@export var pre_l_hand : Sprite2D
@export var pre_r_hand : Sprite2D

#Onready Variables

#Other Variables (please try to separate and organise!)
var finished_connecting : bool
var valid_color : bool
var input
var mouse_input: Array[String]
var devices: Array[int]
var connected_time : float
var readied_up : bool = false

#endregion

#region Godot methods
func _ready():
	Input.joy_connection_changed.connect(update_device_list)
	update_device_list(0, true)
	
	if GameManager.isLocal():
		input = DeviceInput.new(device_id)
	else:
		input = null
	
	remove_button.visible = GameManager.isLocal()
	
	player_name.label_settings = player_name.label_settings.duplicate()
	
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
	
	
	for child in loadout_pips_box.get_children():
		child.queue_free()
		
	for loadoutCount in lobby_manager.loadouts.size():
		var new_pip = TextureRect.new()
		new_pip.texture = pip_texture
		if loadoutCount > 0:
			new_pip.modulate = Color.DIM_GRAY
		loadout_pips_box.add_child(new_pip)
	pass
	
	
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

func get_cropped_texture(texture : Texture, region : Rect2) -> AtlasTexture:
		var atlas_texture := AtlasTexture.new()
		atlas_texture.set_atlas(texture)
		atlas_texture.set_region(region)
		return atlas_texture

func _process(_delta):
	connected_time += _delta
	if !finished_connecting:
		resendValues.rpc()
		finished_connecting = true
	
	get_controller_input()
	
	if (GameManager.isOnline() && multiplayer.get_unique_id() == peer_id) || GameManager.isLocal():
		var changed = false
		if(connected_time < 1):
			changed =  true
		
		if("down" in mouse_input):
			if not player_ready:
				selected_panel = clampi(selected_panel + 1, 0,panels_array.size()-1)
			changed = true
		
		if("up" in mouse_input):
			if not player_ready:
				if(GameManager.isLocal()):
					selected_panel = clampi(selected_panel - 1, 0,panels_array.size()-1)
				else:
					selected_panel = clampi(selected_panel - 1, 1,panels_array.size()-1)
			changed = true
		
		if(("left" in mouse_input) and not player_ready):
			if(selected_panel == 1): #raider panel selected 
				selected_raider = wrapi(selected_raider - 1, 0,lobby_manager.raiders.size())
				while lobby_manager.picked_raiders.has(selected_raider) and not lobby_manager.allow_duplicate_animals:
					selected_raider = wrapi(selected_raider - 1, 0,lobby_manager.raiders.size())
			elif(selected_panel == 2): #color selected
				selected_color = wrapi(selected_color - 1, 0,lobby_manager.player_colors.size())
				while lobby_manager.picked_colors.has(selected_color) and not lobby_manager.allow_duplicate_colors:
					selected_color = wrapi(selected_color - 1, 0,lobby_manager.player_colors.size())
			#elif(selected_panel == 3): #loadout selected
				#selected_loadout = wrapi(selected_loadout - 1, 0,lobby_manager.loadouts.size())
			changed = true
			
		if(("right" in mouse_input) and not player_ready):
			if(selected_panel == 1): #raider panel selected 
				selected_raider = wrapi(selected_raider + 1, 0,lobby_manager.raiders.size())
				while lobby_manager.picked_raiders.has(selected_raider) and not lobby_manager.allow_duplicate_animals:
					selected_raider = wrapi(selected_raider + 1, 0,lobby_manager.raiders.size())
			elif(selected_panel == 2): #loadout selected
				selected_color = wrapi(selected_color + 1, 0,lobby_manager.player_colors.size())
				while lobby_manager.picked_colors.has(selected_color) and not lobby_manager.allow_duplicate_colors:
					selected_color = wrapi(selected_color + 1, 0,lobby_manager.player_colors.size())
			#elif(selected_panel == 3): #loadout selected
				#selected_loadout = wrapi(selected_loadout + 1, 0,lobby_manager.loadouts.size())
			changed = true
		
		if("confirm" in mouse_input):
			if(selected_panel == 0):
				_remove_player()
			if(selected_panel == 3 and valid_color): #ready button selected
				player_ready = !player_ready
				changed = true
				
		if changed:
			setValues.rpc(Steam.getPersonaName(),selected_raider,selected_color,selected_loadout,selected_panel,player_ready)
	
	UpdateDisplay()
	mouse_input.clear()

#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
@rpc("any_peer","call_local")
func setValues(new_username : String, new_raider : int, new_color : int, new_loadout : int, new_panel : int, new_ready : bool ):
	username = new_username
	
	#raider name, picture and description will be an array get from lobby manager 
	#loadout name and desc will be an array get from lobby manager 
	selected_raider = new_raider
	selected_color = new_color
	selected_loadout = new_loadout
	selected_panel = new_panel
	player_ready = new_ready

@rpc("any_peer")
func resendValues():
	setValues.rpc(username, selected_raider, selected_color, selected_loadout, selected_panel, player_ready)

func UpdateDisplay():
	
	# hide everything if there isnt a player to use it
	all_panels.visible = show_panels
	
	# set some basic values
	if GameManager.isLocal():
		var s = "Keyboard & Mouse"
		if device_id >= 0:
			s = Input.get_joy_name(device_id)
		player_name.text = s
	else:
		player_name.text = username
	
	#player_name.label_settings.font_color = lobby_manager.player_colors[selected_color]
	#player_name.add_theme_color_override("font_color",lobby_manager.player_colors[selected_color])
	raider_name.text = lobby_manager.raiders[selected_raider].raider_name
	raider_desc.text = lobby_manager.raiders[selected_raider].raider_desc
	#raider_portrait.texture = lobby_manager.raiders[selected_raider].portrait
	loadout_name.text = lobby_manager.loadouts[selected_loadout].loadout_name
	loadout_desc.text = lobby_manager.loadouts[selected_loadout].loadout_desc
	#color_name.text ="Color: " + str(selected_color+1)
	color_name.text ="Color"
	
	# prepare spell icons
	for spell : int in spells_box.get_children().size():
		var spell_resource: Spell = SpellManager.get_spell_from_string(lobby_manager.loadouts[selected_loadout].spell_ids[spell])
		if spell_resource:
			spells_box.get_child(spell).texture = spell_resource.ui_texture
			spells_box.get_child(spell).modulate = spell_resource.element.colour
	
	# Manage the pips under raider and loadout title
	for pip in character_pips_box.get_children().size():
		if pip == selected_raider:
			character_pips_box.get_child(pip).modulate = Color.WHITE
		elif lobby_manager.picked_raiders.has(pip) and not lobby_manager.allow_duplicate_animals:
			character_pips_box.get_child(pip).modulate = Color8(255,255,255,40)
		else: 
			character_pips_box.get_child(pip).modulate = Color.DIM_GRAY
			
	for pip in loadout_pips_box.get_children().size():
		if pip == selected_loadout:
			loadout_pips_box.get_child(pip).modulate = Color.WHITE
		else: 
			loadout_pips_box.get_child(pip).modulate = Color.DIM_GRAY
	
	for pip in color_pips_box.get_children().size():
		if pip == selected_color:
			color_pips_box.get_child(pip).modulate = Color.WHITE
		elif lobby_manager.picked_colors.has(pip) and not lobby_manager.allow_duplicate_colors:
			color_pips_box.get_child(pip).modulate = Color8(255,255,255,40)
		else: 
			color_pips_box.get_child(pip).modulate = Color.DIM_GRAY
	
	
	#Highlight the correct panel
	highlight_color = lobby_manager.player_colors[selected_color]
	if player_ready:
		if !($AudioStreamPlayer as AudioStreamPlayer).playing and !readied_up:
			$AudioStreamPlayer.stream = lobby_manager.raiders[selected_raider].animal_sound
			$AudioStreamPlayer.play()
		readied_up = true
		self_modulate = Color.DIM_GRAY
		ready_text.text = "UNREADY"
		$AnimationPlayer.play("ready")
		$VBoxContainer/VBoxContainer/CharacterContainer.modulate = Color.DIM_GRAY
		$VBoxContainer/VBoxContainer/ColorContainer.modulate = Color.DIM_GRAY
	else:
		readied_up = false
		$AudioStreamPlayer.stop()
		self_modulate = Color.WHITE 
		$AnimationPlayer.play("character_bob")
		ready_text.text = "READY"
		$VBoxContainer/VBoxContainer/CharacterContainer.modulate = Color.WHITE
		$VBoxContainer/VBoxContainer/ColorContainer.modulate = Color.WHITE
	
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
	for card in lobby_manager.player_card_hbox.get_children():
		if card.selected_color == selected_color and not player_ready and not card.peer_id == peer_id:
			valid_color = false

	#update preview
	pre_body.self_modulate = highlight_color
	pre_head.texture = lobby_manager.raiders[selected_raider].head_texture
	pre_l_hand.self_modulate = lobby_manager.raiders[selected_raider].skin_color
	pre_r_hand.self_modulate = lobby_manager.raiders[selected_raider].skin_color

#endregion

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

func update_device_list(_device: int, _connected: bool):
	devices.clear()
	devices = Input.get_connected_joypads()
	devices.append(-1)

func is_event_click(event):
	return device_id <= -1 and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed

func _on_character_container_mouse_entered():
	if device_id <= -1 and !player_ready and is_multiplayer_authority():
		selected_panel = 1

func _on_color_container_mouse_entered():
	if device_id <= -1 and !player_ready and is_multiplayer_authority():
		selected_panel = 2

func _on_loadout_container_mouse_entered():
	if device_id <= -1 and !player_ready and is_multiplayer_authority():
		selected_panel = 3

func _on_button_mouse_entered():
	if device_id <= -1 and is_multiplayer_authority():
		selected_panel = 3

func _on_left_arrow_clicked(event):
	if is_event_click(event) and device_id <= -1 and is_multiplayer_authority():
		mouse_input.append("left")

func _on_right_arrow_clicked(event):
	if is_event_click(event) and device_id <= -1 and is_multiplayer_authority():
		mouse_input.append("right")

func _on_button_pressed():
	if device_id <= -1 and is_multiplayer_authority():
		mouse_input.append("confirm")

func _remove_player():
	queue_free()

func _on_raider_pip_gui_input(event, node):
	if is_event_click(event) and device_id <= -1 and !player_ready and is_multiplayer_authority():
		var raider_int = node.get_index()
		if !(lobby_manager.picked_raiders.has(raider_int) and not lobby_manager.allow_duplicate_animals):
			selected_raider = raider_int
		
func _on_color_pip_gui_input(event, node):
	if is_event_click(event) and device_id <= -1 and !player_ready and is_multiplayer_authority():
		var color_int = node.get_index()
		if !(lobby_manager.picked_colors.has(color_int) and not lobby_manager.allow_duplicate_colors):
			selected_color = color_int
