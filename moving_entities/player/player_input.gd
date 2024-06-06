extends Node

var input: DeviceInput

var move_dir: Vector2
var aim_dir: Vector2
var spell_down: Array[bool] = [false]
var spell_press: Array[bool] = [false]
var spell_release: Array[bool] = [false]
var do_dash: bool = false

var is_keyb: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	spell_down.resize(3)
	spell_press.resize(3)
	spell_release.resize(3)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#For pausing
	var do_pause = false
	if input: # For local
		do_pause = input.is_action_just_pressed("keyboard_pause") if input.device == -1 else input.is_action_just_pressed("ui_pause")
	else: # For online
		do_pause = Input.is_action_pressed("ui_pause") or Input.is_action_just_pressed("keyboard_pause")
	
	if do_pause and !GameManager.isPaused:
		GameManager.isPaused = true
		if input:
			MultiplayerInput.set_ui_action_device(input.device)
		
		var pause_menu = load("res://menus/pause_menu.tscn").instantiate()
		pause_menu.set_panel_color(owner.data.main_color)
		if input:
			pause_menu.device_index = input.device
			
		#NOTE : Originally this was owner.parent.add_child. not sure why this is the case - E
		get_tree().root.add_child(pause_menu)
	
	if is_multiplayer_authority() and is_instance_valid(owner.data) and !owner.is_dead:
		
		move_dir = Vector2.ZERO
		aim_dir = Vector2.ZERO
		spell_down.fill(false)
		spell_press.fill(false)
		spell_release.fill(false)
		do_dash = false
		
		# If we have an input object, use it
		if !GameManager.isPaused:
			if input:
				# Movement
				move_dir = input.get_vector("left", "right", "up", "down").normalized()
				if input.is_keyboard():
					if abs(move_dir.y) <= sqrt(0.5) + 0.1 and abs(move_dir.y) >= sqrt(0.5) - 0.1:
						move_dir.y *= 0.5
						move_dir = move_dir.normalized()
				
				# Aim
				if input.is_keyboard():
					aim_dir = owner.get_global_mouse_position() - owner.global_position
					aim_dir = aim_dir.normalized()
				else:
					var a : Vector2 = input.get_vector("left", "right", "up", "down")
					if a.length() > 0:
						aim_dir = a.normalized()
				
				# Buttons
				for i in spell_down.size():
					spell_down[i] = input.is_action_pressed("spell" + str(i))
					spell_press[i] = input.is_action_just_pressed("spell" + str(i))
					spell_release[i] = input.is_action_just_released("spell" + str(i))
				do_dash = input.is_action_just_pressed("dash")
			
			# Otherwise, use any connected controller
			else:
				for device in GameManager.devices:
					var d: Vector2 = MultiplayerInput.get_vector(device, "left", "right", "up", "down")
					if d.length() > move_dir.length():
						move_dir = d
					if is_keyb:
						if abs(move_dir.y) <= sqrt(0.5) + 0.1 and abs(move_dir.y) >= sqrt(0.5) - 0.1:
							move_dir.y *= 0.5
							move_dir = move_dir.normalized()
						
					if is_keyb:
						aim_dir = owner.get_global_mouse_position() - owner.global_position
						aim_dir = aim_dir.normalized()
					else:
						var a : Vector2 = MultiplayerInput.get_vector(device, "left", "right", "up", "down")
						if a.length() > 0:
							aim_dir = a.normalized()
						
					for i in spell_down.size():
						if spell_down[i] == false:
							spell_down[i] = MultiplayerInput.is_action_pressed(device, "spell" + str(i))
						if spell_press[i] == false:
							spell_press[i] = MultiplayerInput.is_action_just_pressed(device, "spell" + str(i))
						if spell_release[i] == false:
							spell_release[i] = MultiplayerInput.is_action_just_released(device, "spell" + str(i))
					if do_dash == false:
						do_dash = MultiplayerInput.is_action_just_pressed(device, "dash")
		
		# Send input to owner
		owner.move_direction = move_dir
		if aim_dir != Vector2.ZERO:
			owner.aim_direction = aim_dir
		for i in spell_down.size():
			if spell_press[i] and $"../SpellPickupDetector".closest_pickup != null:
				print("Picking up spell.")
				owner.spell_pickup_requested.emit(owner, i, $"../SpellPickupDetector".closest_pickup)
			else:
				if spell_down[i]:
					owner.prepare_cast(i)
				if spell_release[i]:
					owner.attempt_cast(i)
		if do_dash:
			owner.attempt_dash()

func _input(event):
	if !input:
		if (event is InputEventJoypadButton) or (event is InputEventJoypadMotion and abs(event.axis_value) > 0.5):
			is_keyb = false
			if is_instance_valid(owner.data) and owner.data.device_id != -3:
				owner.data.device_changed.emit(event.device)
		elif (event is InputEventKey) or (event is InputEventMouseButton) or (event is InputEventMouse):
			is_keyb = true
			if is_instance_valid(owner.data) and owner.data.device_id != -3:
				owner.data.device_changed.emit(-1)
	
	

#func update_device_list(_device: int, _connected: bool):
	#devices.clear()
	#devices = Input.get_connected_joypads()
	#devices.append(-1)

func set_device(id: int):
	if id <= -2:
		input = null
	else:
		input = DeviceInput.new(id)
	if is_instance_valid(owner.data):
		owner.data.device_changed.emit(id)

func clear_device():
	input = null
