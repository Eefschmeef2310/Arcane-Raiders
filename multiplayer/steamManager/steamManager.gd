extends Node

var player_id = 0 ## 0 = host/offline, 1-2-3 are players that join

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_environment("SteamAppID", str(2899410))
	OS.set_environment("SteamGameID", str(2899410))
	Steam.steamInitEx()
	
	## Spacewar (test app) : 480
	## untitiled wizard game (real app) : 2899410

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	Steam.run_callbacks()
