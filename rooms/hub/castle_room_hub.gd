extends CastleRoom


# Called when the node enters the scene tree for the first time.
func _ready():
	## Connect signals
	# client connected
	# client disconnected
	# controller connected
	# controller disconnected
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#region - Player Management

#spawn a new player and give its control and auth to the matching client and controller
func add_player():
	pass

#destroy the relevant player, should work ingame too
func remove_player():
	pass

#add_player() for each player with the client
func client_connected():
	pass

#remove_player() everyhting that was with that client
func client_disconnected():
	pass

#called when the local client is disconnected from the host client
func disconnected():
	pass

#when any controllers are connected but not ingame, show join prompt
func controller_connected():
	pass

#remove the relevant player with remove_player()
func controller_disconnected():
	pass

#endregion 

#region - Game Management

#take the players that are currently active and send them into a castle_climb run
func start_game():
	pass

#called when a run finishes, returns player to hub
func game_finished():
	pass

#endregion

#region - Notes

#may need to manage syncing player choices here (animal, color, ect)

#endregion

