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
@export_group("Card Values")
@export var raider_portrait : TextureRect
@export var raider_name : Label
@export var raider_desc : Label
@export var player_name : Label

@export_group("Other Resources")
@export var default_slot_icon : Texture2D

@export_group("References")
@export var lobby_manager : Node


#Onready Variables

#Other Variables (please try to separate and organise!)


#endregion

#region Godot methods
func _ready():
	setOnlineDefault()
	pass

func _process(delta):
	#Runs per frame
	
	if(Input.is_action_just_pressed("debug_random")):
		if(Steam.getPersonaName() == player_name.text):
			#raider_desc.text += " •⩊• "
			##rpc("setValues", default_slot_icon, "Cool Player", str(raider_desc.text + " •⩊• "), Steam.getPersonaName())
			lobby_manager.rpc("UpdateCard", SteamManager.player_id, default_slot_icon, "Cool Player", str(raider_desc.text + " •⩊• "), Steam.getPersonaName())
	pass
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
@rpc("any_peer","call_local")
func setValues(portrait : Texture2D, raider : String, description : String, username : String):
	raider_portrait.texture = portrait
	raider_name.text = raider
	raider_desc.text = description
	player_name.text = username
	#also set colour ect

func setLocalDefault():
	setValues(default_slot_icon, "???", "Press any key to join", " ")
	pass

func setOnlineDefault():
	setValues(default_slot_icon, "???", "Join through the lobby", " ")
	pass
#endregion
