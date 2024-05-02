extends Node
# authored by Xander

enum MultiplayerMode {Online ,Local}
var mode : MultiplayerMode

func isLocal() -> bool:
	return mode == MultiplayerMode.Local
	
func isOnline() -> bool:
	return mode == MultiplayerMode.Online
