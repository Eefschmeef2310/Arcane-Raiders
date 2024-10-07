extends Node

const version_id : int = 3062240
#3062240 for DEMO
#2899410 for MAIN GAME
#480 for SPACEWAR

const live_mode = true #switches the app id to the real id and 
#enables functions such as leaderboards and acheivements

var player_id = 0 ## 0 = host/offline, 1-2-3 are players that join

var server_browser_node : Node

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
	
	#SteamControllerInput.init()
	
	## Spacewar (test app) : 480
	## untitiled wizard game (real app) : 2899410
	## Baladins (unowned game, will fail) : 1866320

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	Steam.run_callbacks()

func upload_acheivement(acheivement_name : String):
	#Note: if you want to have an acheievemtn with a progress bar then it needs to be setup with a corresponding stat!
	if (live_mode):
		print("Giving acheivement: " + acheivement_name)
		Steam.setAchievement(acheivement_name)
		Steam.storeStats()
	else:
		print("Would have given acheievement " + acheivement_name + " but live_mode is false!")

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
