extends Node2D
class_name JoinSelectUI

@export var username : String
@export var peer_id : int = 1 # for online multiplayer
@export var device_id : int = -2 # for local multiplayer
@export var selected_raider : int = 0
@export var selected_loadout : int = 0
@export var selected_color : int = 0
@export var selected_panel : int = 1 #0=close_button 1=raider, 2=loadout, 3=ready

@onready var character_pips_box = $PanelContainer/VBoxContainer/CharacterContainer/CharacterPips
@onready var color_pips_box = $PanelContainer/VBoxContainer/ColorContainer/ColorPips

@export var lobby_manager : Node
@export var raiders : Array[RaiderRes]
@export var player_colors : Array[Color]

var devices: Array[int]
var input

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
