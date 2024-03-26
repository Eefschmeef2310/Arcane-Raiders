extends Node

var input: DeviceInput
var devices: Array[int]

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.joy_connection_changed.connect(update_device_list)
	update_device_list(0, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var dir: Vector2
	
	# If we have an input object, use it
	# Otherwise, use any connected controller
	if input:
		dir = input.get_vector("left", "right", "up", "down")
	else:
		for device in devices:
			var d: Vector2 = MultiplayerInput.get_vector(device, "left", "right", "up", "down")
			if d.length() > dir.length():
				dir = d
			
	owner.direction = dir

func update_device_list(_device: int, _connected: bool):
	devices.clear()
	devices = Input.get_connected_joypads()
	devices.append(-1)
	
func clear_device():
	input = null
