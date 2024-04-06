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
@export var cardRes : PlayerCardRes
@export var raider_portrait : TextureRect 
@export var raider_name : Label 
@export var raider_desc : Label 
@export var player_name : Label

@export_group("Other Resources")
@export var default_slot_icon : Texture2D
@export var default_online_card : PlayerCardRes
@export var default_offline_card : PlayerCardRes

@export_group("References")
@export var lobby_manager : Node


#Onready Variables

#Other Variables (please try to separate and organise!)


#endregion

#region Godot methods
func _ready():
	cardRes = PlayerCardRes.new()
	setOnlineDefault()
	pass

func _process(delta):
	#Runs per frame
	
	
	pass
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
@rpc("any_peer","call_local")
func setValues(newValues : PlayerCardRes):
	raider_portrait.texture = newValues.raiderRes.portrait
	raider_name.text = newValues.raiderRes.raider_name
	raider_desc.text = newValues.raiderRes.raider_desc
	player_name.text = newValues.username
	#also set colour ect

func setLocalDefault():
	setValues(default_offline_card)
	pass

func setOnlineDefault():
	setValues(default_online_card)
	pass
#endregion
