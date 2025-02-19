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

var runs_completed : int = 0

#Array of the RAIDER NAMES that completed the run (we use this to track what characters have beat the shadow wizards)
var characters_completed : Array

#Count of all games (win and lose)
var games_played : int = 0

var area_1_complete : bool = false
var area_2_complete : bool = false
var area_3_complete : bool = false

var total_kills : int = 0

#Get most recent difficulty, so hub loads it
var most_recent_difficulty : int = 0

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

func _input(event):
	if InputMap.has_action("debug_full_save_file") and event.is_action_pressed("debug_full_save_file"):
		highest_difficulty_unlocked = 3
		hats_highest_difficulty_completed = {}
		runs_completed = 4
		games_played = 12
		area_1_complete = true
		area_2_complete = true
		area_3_complete = true
		most_recent_difficulty = 3
		characters_completed = ["Cat", "Cow", "Croc", "Horse", "Lizard", "Owl", "Squid", "Wolf"]
		request_save()
	elif InputMap.has_action("debug_new_save_file") and event.is_action_pressed("debug_new_save_file"):
		highest_difficulty_unlocked = 0
		hats_highest_difficulty_completed = {}
		runs_completed = 0
		games_played = 0
		area_1_complete = false
		area_2_complete = false
		area_3_complete = false
		characters_completed = []
		most_recent_difficulty = 0
		request_save()
	elif InputMap.has_action("debug_reset_steam_stats") and  event.is_action_pressed("debug_reset_steam_stats"):
		SteamManager.reset_stats_and_achievements()

func save_file():
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	var dict: Dictionary = {
		"highest_difficulty_unlocked" : highest_difficulty_unlocked,
		"hats_highest_difficulty_completed" : hats_highest_difficulty_completed,
		"runs_completed" : runs_completed,
		"games_played" : games_played,
		"area_1_complete" : area_1_complete,
		"area_2_complete" : area_2_complete,
		"total_kills" : total_kills,
		"characters_completed" : characters_completed,
		"most_recent_difficulty" : most_recent_difficulty,
	}
	
	var json_string = JSON.stringify(dict)
	file.store_string(json_string)

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
	if "runs_completed" in dict.keys():
		runs_completed = dict["runs_completed"]
	if "games_played" in dict.keys():
		games_played = dict["games_played"]
	if "area_1_complete" in dict.keys():
		area_1_complete = dict["area_1_complete"]
	if "area_2_complete" in dict.keys():
		area_2_complete = dict["area_2_complete"]
	if "total_kills" in dict.keys():
		total_kills = dict["total_kills"]
	if "characters_completed" in dict.keys():
		characters_completed = dict["characters_completed"]
	if "most_recent_difficulty" in dict.keys():
		most_recent_difficulty = dict["most_recent_difficulty"]

func request_save():
	autosave_timer.stop()
	autosave_timer.start()

func _on_autosave_timer_timeout():
	save_file()
