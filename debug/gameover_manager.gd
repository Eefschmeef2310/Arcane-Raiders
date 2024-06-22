extends Node
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants
const GAME_OVER_SCREEN = preload("res://screens/game_over_screen.tscn")

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var players : Array[PlayerData]
var enemies : Array[Node2D]

#endregion

#region Godot methods
func _ready():
	get_players()

func _process(_delta):
	#TODO - Move this the heck out of process - E
	if get_tree().get_nodes_in_group("enemy").size() <= 0:
		get_tree().root.add_child(GAME_OVER_SCREEN.instantiate())
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func get_players():
	players.clear()
	for data in get_tree().get_nodes_in_group("player_data"):
		players.append(data)
		data.health_changed.connect(is_player_dead)
		
	enemies.clear()
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemies.append(enemy)

func is_player_dead(data, amount):
	if amount <= 0:
		players.erase(data)
	if players.size() <= 0:
		get_tree().root.add_child(GAME_OVER_SCREEN.instantiate())
#endregion
