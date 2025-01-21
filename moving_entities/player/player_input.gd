extends Node

const PAUSE_MENU = preload("res://menus/pause_menu.tscn")

var input: DeviceInput

var move_dir: Vector2
var aim_dir: Vector2
var spell_down: Array[bool] = [false]
var spell_press: Array[bool] = [false]
var spell_release: Array[bool] = [false]
var do_dash: bool = false
var interact: bool = false

var is_keyb: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	spell_down.resize(3)
	spell_press.resize(3)
	spell_release.resize(3)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_multiplayer_authority() and is_instance_valid(owner.data):
		#region - For pausing
		var do_pause = false
		if input: # For local
			do_pause = input.is_action_just_pressed("lobby_pause")
		else: # For online
			for device in GameManager.devices:
				do_pause = MultiplayerInput.is_action_just_pressed(device, "lobby_pause")
				if do_pause: break
		
		#Run a pause check to make sure at least one player is alive. this check occurs regardless of online or offline - E 21/1
		if do_pause:
			var dead_players := 0
			for player in get_tree().get_nodes_in_group("player"):
				if !(player as Player).is_dead: break
				dead_players += 1
			if dead_players == get_tree().get_nodes_in_group("player").size():
				do_pause = false
				
		if do_pause and !GameManager.isPaused:
			GameManager.isPaused = true
			#if input:
				#MultiplayerInput.set_ui_action_device(input.device)
			
			var pause_menu = PAUSE_MENU.instantiate()
			pause_menu.set_panel_color(owner.data.main_color)
			if input:
				pause_menu.device_id = input.device
				pause_menu.stored_player = owner as Player
				
			#NOTE : Originally this was owner.parent.add_child. not sure why this is the case - E
			owner.add_sibling(pause_menu)
		#endregion
		
		# Reset all input values
		move_dir = Vector2.ZERO
		aim_dir = Vector2.ZERO
		spell_down.fill(false)
		spell_press.fill(false)
		spell_release.fill(false)
		do_dash = false
		interact = false
		
		# Ignore input if we are dead
		if !owner.is_dead:
			
			# Ignore input if we are paused or have something freezing us
			if !GameManager.isPaused and !is_instance_valid(owner.input_preventing_node):
				
				# If we have an input object, use it
				if input: #Online
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
						var a : Vector2 = input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
						if a == Vector2.ZERO:
							a = input.get_vector("left", "right", "up", "down")
						if a.length() > 0:
							aim_dir = a.normalized()
					
					# Buttons
					for i in spell_down.size():
						spell_down[i] = input.is_action_pressed("spell" + str(i))
						spell_press[i] = input.is_action_just_pressed("spell" + str(i))
						spell_release[i] = input.is_action_just_released("spell" + str(i))
					do_dash = input.is_action_just_pressed("dash")
					
					#Emotes
					for i in 3:
						if input.is_action_just_pressed("Emote" + str(i)):
							owner.play_emote.rpc(i)
					#print(input.is_action_just_pressed("Emote2"))
					
					if input.is_action_just_pressed("interact"):
						interact = true
				
				# Otherwise, use any connected controller
				else:	
					for device in GameManager.devices: #Local play
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
							var a : Vector2 = MultiplayerInput.get_vector(device, "aim_left", "aim_right", "aim_up", "aim_down")
							if a == Vector2.ZERO:
								a = MultiplayerInput.get_vector(device, "left", "right", "up", "down")
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
						
						for i in 3:
							if MultiplayerInput.is_action_just_pressed(device, "Emote" + str(i)):
								owner.play_emote.rpc(i)
								
						if MultiplayerInput.is_action_just_pressed(device, "interact"):
							interact = true
						
					
			# Send input to owner
			owner.move_direction = move_dir
			if aim_dir != Vector2.ZERO:
				owner.aim_direction = aim_dir
			for i in spell_down.size():
				if spell_press[i] and $"../SpellPickupDetector".closest_pickup != null:
					#print("Picking up spell.")
					owner.spell_pickup_requested.emit(owner, i, $"../SpellPickupDetector".closest_pickup)
				else:
					if spell_press[i]:
						owner.prepare_cast_down(i)
						owner.prepare_cast(i)
					if spell_down[i]:
						pass
					if spell_release[i]:
						owner.attempt_cast(i)
			if do_dash:
				owner.attempt_dash()
			if interact:
				if $"../Interactor".closest_interactable != null:
					$"../Interactor".closest_interactable.on_interact(owner)
				elif $"../HatPickupDetector".closest_pickup != null and $"../HatPickupDetector".closest_pickup.unlocked:
					owner.set_hat_from_pickup.rpc($"../HatPickupDetector".closest_pickup.hat_string)

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
