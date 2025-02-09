extends Node

const version_id : int = 2899410
#3062240 for DEMO
#2899410 for MAIN GAME
#480 for SPACEWAR

const live_mode = true #switches the app id to the real id and 
#enables functions such as leaderboards and achievements

var player_id = 0 ## 0 = host/offline, 1-2-3 are players that join

var server_browser_node : Node

var damageless : bool = true
var unlocked_achievements : int = 0
var achievement_list : Array[String] = ["100_plays","50_wins","win_easy","win_medium","win_hard","win_expert","21st_night","4_players","speed","speed_expert","all_hats","no_damage","synergy","1000_kills","1_player_expert"]

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_environment("SteamAppID", str(version_id))
	OS.set_environment("SteamGameID", str(version_id))
	
	var initialize_response: Dictionary = Steam.steamInitEx()
	print("Did Steam initialize?: %s" % initialize_response)
	# status : 0 means it all worked, anything else means an error occured
	
		
	Steam.steamInit()
	Steam.inputInit()
	Steam.enableDeviceCallbacks()
	
	Steam.current_stats_received.connect(_on_current_stats_received)
	#SteamControllerInput.init()
	
	## Spacewar (test app) : 480
	## untitiled wizard game (real app) : 2899410
	## Baladins (unowned game, will fail) : 1866320

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	Steam.run_callbacks()
	
	#if Input.is_action_just_pressed("debug_count_achievements"):
		#count_unlocked_achievements()

func grant_achievement(achievement_name : String):
	#Note: if you want to have an acheievemtn with a progress bar then it needs to be setup with a corresponding stat!
	if (live_mode):
		print("Giving achievement: " + achievement_name)
		Steam.setAchievement(achievement_name)
		Steam.storeStats()
	else:
		print("Would have given acheievement " + achievement_name + " but live_mode is false!")

func upload_leaderboard(score, keep_best : bool, details, handle):
	if (live_mode):
		# actually update the leaderbaord
		Steam.uploadLeaderboardScore(score, keep_best , details, handle)
		#score - the highscore itself
		#keep_best - should the scoreonly update if it is higher than the previously saved score
		#details - extra integers which we can use for 'basically anything'
		#handle - name of the leaderboard to apply this score to
	else:
		print("Leaderboard " + handle + " not updated because the game is not in live_mode!")

func download_stat_int(stat_name : String) -> int:
	return Steam.getStatInt(stat_name)

func download_stat_float(stat_name : String) -> float:
	return Steam.getStatFloat(stat_name)

func upload_stat_int(stat_name : String, stat_value : int):
	if(live_mode):
		Steam.setStatInt(stat_name, stat_value)
		Steam.storeStats()

func upload_stat_float(stat_name : String, stat_value : float):
	if(live_mode):
		Steam.setStatFloat(stat_name, stat_value)
		Steam.storeStats()

func get_version_string() -> String:
	match version_id:
		3062240:
			return " - DEMO"
		2899410:
			return ""
		480:
			return " - SPACEWAR"
		_:
			return " - UNKNOWN"

func is_demo() -> bool:
	if version_id == 3062240:
		return true
	else:
		return false

#post each stat to steam api
func update_stats_and_achievements() -> void:		
	upload_stat_int("plays", SaveManager.games_played)
	upload_stat_int("wins", SaveManager.runs_completed)
	if SaveManager.runs_completed >= 1 and SaveManager.games_played >= 10:
		SteamManager.grant_achievement("all_hats")
	upload_stat_int("kills", SaveManager.total_kills)
	Steam.storeStats()

func reset_stats_and_achievements() -> void:
	Steam.resetAllStats(true)

# counts how many acheiveemnts the user has unlocked and puts it in unlocked_achievements
func count_unlocked_achievements() -> void:
	Steam.requestCurrentStats()
	
	#Steam.getUserAchievement()

func _on_current_stats_received(game : int, result : int, user : int):
	var achievement_count : int = 0
	for achievement in achievement_list:
		if Steam.getAchievement(achievement)['achieved']:
			achievement_count += 1
	#print("Tabby~ Unlocked: " + str(achievement_count) +"/" +str(achievement_list.size()) )
	unlocked_achievements = achievement_count
