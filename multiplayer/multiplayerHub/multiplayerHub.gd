extends Node2D
#class_name
#Authored by Tom. Please consult for any modifications or major feature requests.

@onready var castle_climb = $CastleClimb as CastleClimb

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
	load_hub()

func _process(delta):
	#Runs per frame
	pass
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func load_hub():
	var test_spells : Array[String] = ["null-proj_ball","null-proj_spread","null-aoe_large"]
	var cat : RaiderRes = load("res://multiplayer/multiplayerLobby/raiders/Cat.tres")
	castle_climb.set_player_data(0,-2,1,test_spells,cat,Color.PURPLE)
	castle_climb.start_hub_floor()

#endregion
