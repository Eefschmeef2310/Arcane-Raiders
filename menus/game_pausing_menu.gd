extends CanvasLayer
class_name GamePausingMenu
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var panels_array : Array[Control]

@export var stylebox_normal : StyleBoxFlat
@export var stylebox_selected : StyleBoxFlat

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var device_id : int = -2
var input : DeviceInput
var current_button = 0
var mouse_input = []
var devices = []

var stored_player : Player

var submenu = null

#endregion

#region Godot methods
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	#Pause the game if we're LOCAL ONLY
	get_tree().paused = GameManager.isLocal()
	
	Input.joy_connection_changed.connect(update_device_list)
	update_device_list(0, true)
	
	if device_id != -2:
		input = DeviceInput.new(device_id)
	
	_on_button_mouse_entered(panels_array[0])
	
	for panel in panels_array:
		panel.mouse_entered.connect(_on_button_mouse_entered.bind(panel))

func _process(_delta):
	if !is_instance_valid(submenu):
		get_controller_input()
		
		if ("down") in mouse_input:
			current_button = clampi(current_button + 1, 0, panels_array.size()-1)
			
		elif ("up") in mouse_input:
			current_button = clampi(current_button - 1, 0, panels_array.size()-1)
		
	for i in panels_array.size():
		if current_button == i:
			if panels_array[i] is LineEdit:
				if panels_array[i].has_focus():
					panels_array[i].add_theme_stylebox_override("focus", stylebox_selected.duplicate())
				else:
					panels_array[i].add_theme_stylebox_override("normal", stylebox_selected.duplicate())
				
			else:
				panels_array[i].add_theme_stylebox_override("panel", stylebox_selected.duplicate())
		else:
			panels_array[i].add_theme_stylebox_override("normal" if panels_array[i] is LineEdit else "panel", stylebox_normal.duplicate())
	
	#NOTE: Every subclass should clear the mouse input array at the end of their process
#endregion

#region Signal methods
func _on_button_mouse_entered(node : Control):
	if device_id <= -1 and is_multiplayer_authority() and (!(panels_array[current_button] is LineEdit) or !(panels_array[current_button] as LineEdit).has_focus()):
		current_button = panels_array.find(node)

func unpause_game():
	if is_instance_valid(stored_player):
		stored_player.preparing_cast_slot = -1
		
	get_tree().paused = false
	GameManager.isPaused = false
	queue_free()
#endregion

#region Other methods (please try to separate and organise!)
func update_device_list(_device: int, _connected: bool):
	devices.clear()
	devices = Input.get_connected_joypads()
	devices.append(-1)

func get_controller_input():
	if !(panels_array[current_button] is LineEdit) or !(panels_array[current_button] as LineEdit).has_focus(): #stop navigating if we're selecting a text input
		if input:
			if input.is_action_just_pressed("lobby_up"):
				mouse_input.append("up")
			if input.is_action_just_pressed("lobby_down"):
				mouse_input.append("down")
			if input.is_action_just_pressed("lobby_pause"):
				mouse_input.append("pause")
			if input.is_action_just_pressed("lobby_confirm"):
				mouse_input.append("confirm")
			if input.is_action_just_pressed("lobby_cancel"):
				mouse_input.append("cancel")
			if input.device == -1 and input.is_action_just_pressed("lobby_click"):
				mouse_input.append("click_confirm")
		else:
			for device in GameManager.devices:
				if MultiplayerInput.is_action_just_pressed(device, "lobby_up"):
					mouse_input.append("up")
				if MultiplayerInput.is_action_just_pressed(device, "lobby_down"):
					mouse_input.append("down")
				if MultiplayerInput.is_action_just_pressed(device, "lobby_pause"):
					mouse_input.append("pause")
				if MultiplayerInput.is_action_just_pressed(device, "lobby_confirm"):
					mouse_input.append("confirm")
				if MultiplayerInput.is_action_just_pressed(device, "lobby_cancel"):
					mouse_input.append("cancel")
				if device <= -1 and MultiplayerInput.is_action_just_pressed(device, "lobby_click"):
					mouse_input.append("click_confirm")
	else:
		if input: #Perform actions regardless
			if input.is_action_just_pressed("lobby_confirm"):
				mouse_input.append("confirm")
			if input.is_action_just_pressed("lobby_cancel"):
				mouse_input.append("cancel")
			if input.device == -1 and input.is_action_just_pressed("lobby_click"):
				mouse_input.append("click_confirm")
		else:
			for device in GameManager.devices:
				if MultiplayerInput.is_action_just_pressed(device, "lobby_confirm"):
					mouse_input.append("confirm")
				if MultiplayerInput.is_action_just_pressed(device, "lobby_cancel"):
					mouse_input.append("cancel")
				if device <= -1 and MultiplayerInput.is_action_just_pressed(device, "lobby_click"):
					mouse_input.append("click_confirm")
#endregion
