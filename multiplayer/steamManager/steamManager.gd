extends Node

const live_mode = false #switches the app id to the real id and 
#enables functions such as leaderboards and acheivements

var player_id = 0 ## 0 = host/offline, 1-2-3 are players that join

# Called when the node enters the scene tree for the first time.
func _ready():
	if live_mode:
		OS.set_environment("SteamAppID", str(2899410))
		OS.set_environment("SteamGameID", str(2899410))
	else:
		OS.set_environment("SteamAppID", str(480))
		OS.set_environment("SteamGameID", str(480))
	Steam.steamInitEx()
	
	## Spacewar (test app) : 480
	## untitiled wizard game (real app) : 2899410

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	Steam.run_callbacks()

func upload_acheivememt(acheivement_name : String):
	if (live_mode):
		print("Giving acheivement: " + acheivement_name)
		Steam.setAchievement(acheivement_name)
		Steam.storeStats()
	else:
		print("Would have given acheievement " + acheivement_name + " but live_mode is false!")

func upload_leaderboard(score, keep_best, details, handle):
	if (live_mode):
		# actually update the leaderbaord
		Steam.uploadLeaderboardScore( score, keep_best, details, handle )
	else:
		print("Leaderboard " + handle + " not updated because the game is not in live_mode!")
