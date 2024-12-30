extends Node

signal file_saved()
signal file_loaded()

var file_path = "user://save.json"
var autosave_timer : Timer

# player can only select up to this difficulty
var highest_difficulty_unlocked : int = 0

# key = hat string, value = highest completed difficulty with that hat
# if hat string isn't in there, assume -1 (no completion yet)
var hats_highest_difficulty_completed : Dictionary = {}

func _ready():
	autosave_timer = Timer.new()
	autosave_timer.wait_time = 0.2
	autosave_timer.one_shot = true
	autosave_timer.timeout.connect(_on_autosave_timer_timeout)
	add_child(autosave_timer)
	autosave_timer.stop()
	
	if !FileAccess.file_exists(file_path):
		save_file()
	else:
		load_file()


func save_file():
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	var dict: Dictionary = {
		"highest_difficulty_unlocked" : highest_difficulty_unlocked,
		"hats_highest_difficulty_completed" : hats_highest_difficulty_completed,
	}
	
	var json_string = JSON.stringify(dict)
	file.store_string(json_string)
	print("File saved.")


func load_file():
	if !FileAccess.file_exists(file_path):
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_line()
	var dict = JSON.parse_string(json_string)
	
	# dict entries to load go here
	# make sure to check if the dict actually has what you're looking for
	# in case changes to this script are made and saves become incompatible
	if "highest_difficulty_unlocked" in dict.keys():
		highest_difficulty_unlocked = dict["highest_difficulty_unlocked"]
	if "hats_highest_difficulty_completed" in dict.keys():
		hats_highest_difficulty_completed = dict["hats_highest_difficulty_completed"]


func request_save():
	autosave_timer.stop()
	autosave_timer.start()
	print(autosave_timer.is_stopped())


func _on_autosave_timer_timeout():
	save_file()
