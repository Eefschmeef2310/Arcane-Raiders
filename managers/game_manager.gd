extends Node
# authored by Xander

enum MultiplayerMode {Online ,Local}
var mode : MultiplayerMode
var isPaused : bool
var devices : Array = []

func _ready():
	Input.joy_connection_changed.connect(update_device_list)
	update_device_list()

func isLocal() -> bool:
	return mode == MultiplayerMode.Local
	
func isOnline() -> bool:
	return mode == MultiplayerMode.Online

func update_device_list(_device: int = 0, _connected: bool = false):
	devices.clear()
	devices = Input.get_connected_joypads()
	devices.append(-1)
	print(str(_device) +  ', ' + str(_connected))
	if _connected:
		print(Input.get_joy_name(_device))
