extends Node
#class_name
#Authored by Tom. Please consult for any modifications or major feature requests.

#region Variables
#Signals

#Enums

#Constants

#Exported Variables
#@export_group("Group")
#@export_subgroup("Subgroup")

#Onready Variables

#Other Variables (please try to separate and organise!)
var counted_players : int = 0
#endregion

#region Godot methods
func _ready():
	
	#Runs when all children have entered the tree
	pass

func _process(delta):
	var number_of_players : int = max(get_tree().get_nodes_in_group("player").size(), get_tree().get_nodes_in_group("hub_select").size())
	if (counted_players != number_of_players):
		counted_players = number_of_players
		update_rp(counted_players)
	#Runs per frame
	pass
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func update_rp(new_players : int):
	if(GameManager.isOnline()):
		DiscordRPC.details = "Getting ready to raid the tower online!"
	else:
		DiscordRPC.details = "Getting ready to raid the tower locally!"
	
	DiscordRPC.state = str(new_players) + "/4 Players Joined"
	DiscordRPC.refresh()
#endregion
