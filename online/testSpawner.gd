extends MultiplayerSpawner

@export var playerScene : PackedScene
var players = {}
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

#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	spawn_function = spawnPlayer 
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(removePlayer)

func _process(delta):
	#Runs per frame
	pass
	#if Input.is_action_just_pressed("spawn"):
		#spawn(1)
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func spawnPlayer(data):
	var p = playerScene.instantiate()
	p.position = Vector2(1285,484)
	p.set_multiplayer_authority(data, true)
	players[data] = p
	return p

func removePlayer(data):
	players[data].queue_free()
	players.erase(data)
#endregion
