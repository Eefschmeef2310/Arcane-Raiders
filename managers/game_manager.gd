extends Node
# authored by Xander

enum MultiplayerMode {Online ,Local}
var mode : MultiplayerMode
var isPaused : bool
var devices : Array = []

func _ready():
	Input.joy_connection_changed.connect(update_device_list)
	process_mode = Node.PROCESS_MODE_ALWAYS
	update_device_list()

func isLocal() -> bool:
	return mode == MultiplayerMode.Local
	
func isOnline() -> bool:
	return mode == MultiplayerMode.Online

func update_device_list(_device: int = 0, _connected: bool = false):
	devices.clear()
	devices = Input.get_connected_joypads()
	devices.append(-1)
	#print(str(_device) +  ', ' + str(_connected))
	if _connected:
		print(Input.get_joy_name(_device))

func format_timer(time_elapsed: float) -> String:
	var minutes = time_elapsed / 60
	var seconds = fmod(time_elapsed, 60)
	var milliseconds = fmod(time_elapsed, 1) * 100
	var time_string = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	return time_string
