extends Node2D

var input: DeviceInput
var devices: Array[int]

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.joy_connection_changed.connect(update_device_list)
	update_device_list(0, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_instance_valid(owner.data) and owner.get_multiplayer_authority() == owner.data.peer_id:
		var move_dir: Vector2
		var aim_dir: Vector2
		var spell: Array[bool]
		spell.resize(3)
		
		# If we have an input object, use it
		if input:
			move_dir = input.get_vector("left", "right", "up", "down")
			for i in spell.size():
				spell[i] = input.is_action_just_pressed("spell" + str(i))
			if input.is_keyboard():
				aim_dir = get_global_mouse_position() - owner.global_position
				aim_dir = aim_dir.normalized()
			else:
				pass
		
		# Otherwise, use any connected controller
		else:
			for device in devices:
				var d: Vector2 = MultiplayerInput.get_vector(device, "left", "right", "up", "down")
				if d.length() > move_dir.length():
					move_dir = d
				for i in spell.size():
					spell[i] = MultiplayerInput.is_action_just_pressed(device, "spell" + str(i))
		
		# Send input to owner
		owner.move_direction = move_dir
		owner.aim_direction = aim_dir
		for i in spell.size():
			if spell[i]:
				owner.cast_spell(i)

func update_device_list(_device: int, _connected: bool):
	devices.clear()
	devices = Input.get_connected_joypads()
	devices.append(-1)
	
func clear_device():
	input = null
